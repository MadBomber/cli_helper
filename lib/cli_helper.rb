# encoding: utf-8
##########################################################
###
##  File: cli_helper.rb
##  Desc: Some DRYed up stuff for quick and dirty CLI utilities
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#

# System Libraries
require 'pathname'
require 'erb'
require 'yaml'

# Third-party gems
require 'configatron'
require 'nenv'
require 'inifile'
require 'slop'

# Example Custom Type for Slop
module Slop
  class PathOption < Option
    def call(value)
      Pathname.new(value)
    end
  end

  class PathsOption < ArrayOption
    def finish(opts)
      self.value = value.map { |f| Pathname.new(f) }
    end
  end

  class SymbolOption < Option
    def call(value)
      value.to_sym
    end
  end

  # An example of how to incorporate default values into
  # the usage help text.  Would prefer a generic solution
  # in the base Option class.
  class StringOption
    #def to_s(offset: 0)
    #  "%-#{offset}s=%s  %s" % [flag, default_value, desc]
    #end
  end
end # module Slop

module CliHelper

  DEFAULTS = {
    version:        '0.0.1',# the version of this program
    arguments:      [],     # whats left after options and parameters are extracted
    verbose:        false,
    debug:          false,
    help:           false,
    enable_config_files: false,
    disable_help:   false,
    disable_debug:  false,
    disable_verbose: false,
    disable_version: false,
    suppress_errors: false,
    ini_comment:    '#',
    ini_seperator:  '=',
    ini_encoding:   'UTF-8',
    user_name:      Nenv.user || Nenv.user_name || Nenv.logname || 'The Unknown Programmer',
    home_path:      Pathname.new(Nenv.home),
    cli:            'a place holder for the Slop object',
    errors:         [],
    warnings:       []
  }

  configatron.configure_from_hash DEFAULTS

  configatron.required_by_filename = caller.last.split(':').first
  configatron.me       = Pathname.new(configatron.required_by_filename).realpath
  configatron.my_dir   = Pathname.new(configatron.required_by_filename).realpath.parent
  configatron.my_name  = Pathname.new(configatron.required_by_filename).realpath.basename.to_s


  # Return full pathname of program
  def me
    configatron.me
  end

  # Return full pathname of program
  def my_dir
    configatron.my_dir
  end
  alias :root :my_dir

  # Returns the basename of the program as a string
  def my_name
    configatron.my_name
  end

  # Returns the version of the program as a string
  def version
    configatron.version
  end

  def cli_helper_process_erb(file_contents)
    erb_contents = ERB.new(file_contents).result
    return erb_contents
  end

  def cli_helper_process_yaml(file_contents='')
    a_hash = YAML.load file_contents
    return a_hash
  end

  def cli_helper_process_ini(file_contents='')
    an_ini_object = IniFile.new(
                      content: file_contents,
                      comment: configatron.ini_comment,
                      parameter: configatron.ini_seperator,
                      encoding: configatron.ini_encoding
                    )
    return an_ini_object.to_h
  end

  def cli_helper_process_config_file(a_cf)
    cf = String == a_cf.class ? Pathname.new(a_cf) : a_cf
    if cf.directory?
      cf.children.each do |ccf|
        cli_helper_process_config_file(ccf)
      end
      return
    end
    unless cf.exist?
      error "Config file is missing: #{cf}"
    else
      file_type = case cf.extname.downcase
        when '.rb'
          :ruby
        when '.yml', '.yaml'
          :yaml
        when '.ini', '.txt'
          :ini
        when '.erb'
          extname = cf.basename.to_s.downcase.gsub('.erb','').split('.').last
          if %w[ yml yaml].include? extname
            :yaml
          elsif %w[ ini txt ].include? extname
            :ini
          elsif 'rb' == extname
            warning 'MakesNoSenseToMe: *.rb.erb is not supported'
            :unknown
          else
            :unknown
          end
      else
        :unknown
      end

      case file_type
        when :ruby
          load cf
        when :yaml
          configatron.configure_from_hash(
            config_file_hash = configatron.configure_from_hash(
              cli_helper_process_yaml(
                cli_helper_process_erb(cf.read)
              )
            )
          )
        when :ini
          configatron.configure_from_hash(
            configatron.configure_from_hash(
              cli_helper_process_ini(
                cli_helper_process_erb(cf.read)
              )
            )
          )
        else
          error "Do not know how to parse this file: #{cf}"
      end # case type_type
    end # unless cf.exist? || cf.directory?
  end # def cli_helper_process_config_file(cf)


  # Invoke Slop with common CLI parameters and custom
  # parameters provided via a block.  Create '?'
  # for all boolean parameters that have a '--name' flag form.
  # Returns a Slop::Options object
  def cli_helper(my_banner='')
    param = Slop::Options.new

    if my_banner.empty?
      param.banner = "Usage: #{my_name} [options] ..."
    else
      param.banner = my_banner
      param.separator "\nUsage: #{my_name} [options] ..."
    end

    param.separator "\nWhere:"

    if  configatron.disable_help      &&
        configatron.disable_verbose   &&
        configatron.disable_debug     &&
        configatron.disable_version
      # NOOP
    else
      param.separator "\n  Common Options Are:"
    end

    unless configatron.disable_help
      param.bool '-h', '--help',    'show this message'
    end

    unless configatron.disable_verbose
      param.bool '-v', '--verbose', 'enable verbose mode'
    end

    unless configatron.disable_debug
      param.bool '-d', '--debug',   'enable debug mode'
    end

    unless configatron.disable_version
      param.on '--version', "print the version: #{configatron.version}" do
        puts configatron.version
        exit
      end
    end

    param.separator "\n  Program Options Are:"

    yield(param) if block_given?

    if configatron.enable_config_files
      param.paths '--config',    'read config file(s) [*.rb, *.yml, *.ini, *.erb]'
    end

    parser = Slop::Parser.new(param, suppress_errors: configatron.suppress_errors)
    configatron.cli = parser.parse(ARGV)

    # NOTE: The config files are being process before the
    #       command line options in order for the command
    #       line options to over-write the values from the
    #       config files.
    if configatron.enable_config_files
      configatron.cli[:config].each do |cf|
        cli_helper_process_config_file(cf)
      end # configatron.cli.config.each do |cf|
    end # if configatron.enable_config_files

    configatron.configure_from_hash(configatron.cli.to_hash)
    configatron.arguments = configatron.cli.arguments

    bools = param.options.select do |o|
      o.is_a? Slop::BoolOption
    end.select{|o| o.flags.select{|f|f.start_with?('--')}}.
        map{|o| o.flags.last.gsub('--','')} # SMELL: depends on convention

    bools.each do |m|
      s = m.to_sym
      define_method(m+'?') do
        configatron[s]
      end unless self.respond_to?(m+'?')
      define_method((m+'!').to_sym) do
        configatron[s] = true
      end unless self.respond_to?(m+'!')
    end


    if self.respond_to?(:help?) && help?
      show_usage
      exit
    end

    return param
  end # def cli_helper

  # Returns the usage/help information as a string
  def usage
    a_string = configatron.cli.to_s + "\n"
    a_string += HELP + "\n" if defined?(HELP)
    return a_string
  end

  # Prints to STDOUT the usage/help string
  def show_usage
    puts usage()
  end


  # Returns an array of valid files of one type
  def get_pathnames_from(an_array, extnames=['.json', '.txt', '.docx'])
    an_array = [an_array] unless an_array.is_a? Array
    extnames = [extnames] unless extnames.is_a? Array
    extnames = extnames.map{|e| e.downcase}
    file_array = []
    an_array.each do |a|
      pfn = Pathname.new(a)
      if pfn.directory?
        file_array << get_pathnames_from(pfn.children, extnames)
      else
        if pfn.exist?
          if extnames.include?(pfn.extname.downcase)
            file_array << pfn
          else
            error "File extension is not #{extnames.join(' or ')} file: #{pfn}"
          end
        else
          error "File does not exist: #{pfn}"
        end
      end
    end
    return file_array.flatten
  end # def get_pathnames_from(an_array, extname='.json')


  # Display global warnings and errors arrays and exit if necessary
  def abort_if_errors
    unless configatron.warnings.empty?
      STDERR.puts
      STDERR.puts "The following warnings were generated:"
      STDERR.puts
      configatron.warnings.each do |w|
        STDERR.puts "\tWarning: #{w}"
      end
      STDERR.print "\nAbort program? (y/N) "
      answer = (STDIN.gets).chomp.strip.downcase
      configatron.errors << "Aborted by user" if answer.size>0 && 'y' == answer[0]
      configatron.warnings = []
    end
    unless configatron.errors.empty?
      STDERR.puts
      STDERR.puts "Correct the following errors and try again:"
      STDERR.puts
      configatron.errors.each do |e|
        STDERR.puts "\t#{e}"
      end
      STDERR.puts
      exit(-1)
    end
  end # def abort_if_errors

  # Adds a string to the global $errors array
  def error(a_string)
    configatron.errors << a_string
  end

  # Adds a string to the global $warnings array
  def warning(a_string)
    configatron.warnings << a_string
  end

end # module CliHelper

