# encoding: utf-8
##########################################################
###
##  File: cli_helper.rb
##  Desc: Some DRYed up stuff for quick and dirty CLI utilities
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#

require 'debug_me'
#include DebugMe

require 'awesome_print'

require 'pathname'
require 'nenv'

require 'erb'
require 'yaml'
require 'parseconfig'

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

  # An example of how to incorporate default values into
  # the usage help text.  Would prefer a generic solution
  # in the base Option class.
  class StringOption
    #def to_s(offset: 0)
    #  "%-#{offset}s=%s  %s" % [flag, default_value, desc]
    #end
  end
end # module Slop

require 'configatron'

module CliHelper

  DEFAULTS = {
    version:        '0.0.1',# the version of this program
    arguments:      [],     # whats left after options and parameters are extracted
    verbose:        false,
    debug:          false,
    help:           false,
    support_config_files: false,
    user_name:      Nenv.user || Nenv.user_name || Nenv.logname || 'Dewayne VanHoozer',
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

  # Returns the basename of the program as a string
  def my_name
    configatron.my_name
  end

  # Returns the version of the program as a string
  def version
    configatron.version
  end

  def cli_helper_process_erb(a_pathname)
    # TODO: open file; send through erb
    file_contents = ''
    return file_contents
  end

  def cli_helper_process_yaml(file_contents='')
    a_hash = YAML.parse file_contents
    return a_hash
  end

  def cli_helper_process_ini(file_contents='')
    an_ini_object = ParseConfig.parse(file_contents)
    return an_ini_object.params
  end

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
    param.separator "\n  Common Options Are:"

    param.bool '-h', '--help',    'show this message'
    param.bool '-v', '--verbose', 'enable verbose mode'
    param.bool '-d', '--debug',   'enable debug mode'

    param.on '--version', "print the version: #{configatron.version}" do
      puts $options[:version]
      exit
    end

    param.separator "\n  Program Options Are:"

    yield(param) if block_given?

    if configatron.support_config_files
      param.paths '--config',    'read config file(s) [*.rb, *.yml, *.ini]'
    end

    parser = Slop::Parser.new(param)
    configatron.cli = parser.parse(ARGV)

    # TODO: DRY this conditional block
    if configatron.support_config_files
      configatron.cli.config.each do |cf|
        unless cf.exist? || cf.directory?
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
              extname = cf.basename.downcase.gsub('.erb','')split('.').last
              if %w[ yml yaml].include? extname
                :yaml
              elsif %w[ ini txt ].include? extname
                :ini
              else
                :unknown
              end
          else
            :unknown
          end

          case type_type
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
                  cli_helper_process_yaml(
                    cli_helper_process_erb(cf.read)
                  )
                )
              )
            else
              error "Do not known how to parse this file: #{cf}"
          end # case type_type
        end # unless cf.exist? || cf.directory?
      end # configatron.cli.config.each do |cf|
    end # if configatron.support_config_files

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


    if help?
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
        file_array << pfn if pfn.exist? && extnames.include?(pfn.extname.downcase)
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

