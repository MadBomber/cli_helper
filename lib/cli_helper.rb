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

require 'slop'

=begin
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
=end

require 'hashie'

class CliHelper

  attr_accessor :options

  class Options < Hashie::Mash
    DEFAULTS = {
      version:        '0.0.1',# the version of this program
      arguments:      [],     # whats left after options and parameters are extracted
      verbose:        false,
      debug:          false,
      help:           false,
      user_name:      Nenv.user || Nenv.user_name || Nenv.logname || 'Dewayne VanHoozer',
      home_path:      Pathname.new(Nenv.home),
      cli:            'a place holder for the Slop object',
      errors:         [],
      warnings:       []
    }

    def initialize
      super(DEFAULTS)
    end

  end # class Options < Hashie::Mash

  def options
    @options
  end

  def initialize
    @options = Options.new
    @options.required_by_filename = caller.last.split(':').first
    @options.me       = Pathname.new(options.required_by_filename).realpath
    @options.my_dir   = Pathname.new(options.required_by_filename).realpath.parent
    @options.my_name  = Pathname.new(options.required_by_filename).realpath.basename.to_s
  end

  # Return full pathname of program
  def me
    options.me
  end

  # Returns the basename of the program as a string
  def my_name
    options.my_name
  end

  # Returns the version of the program as a string
  def version
    options.version
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
    param.separator "  Common Options Are:"

    param.bool '-h', '--help',    'show this message'
    param.bool '-v', '--verbose', 'enable verbose mode'
    param.bool '-d', '--debug',   'enable debug mode'

    param.on '--version', "print the version: #{options.version}" do
      puts $options[:version]
      exit
    end

    param.separator "  Program Options Are:"

    yield(param) if block_given?

    parser = Slop::Parser.new(param)
    options.cli = parser.parse(ARGV)

    options.merge!(options.cli.to_hash)
    options.arguments = options.cli.arguments


    bools = param.options.select do |o|
      o.is_a? Slop::BoolOption
    end.select{|o| o.flags.select{|f|f.start_with?('--')}}.
        map{|o| o.flags.last.gsub('--','')} # SMELL: depends on convention

=begin
    bools.each do |m|
      s = m.to_sym
      define_method((m+'?').to_sym) do
        options[s]
      end unless self.respond_to?((m+'?').to_sym)
      define_method((m+'!').to_sym) do
        options[s] = true
      end unless self.respond_to?((m+'!').to_sym)
    end
=end

    if help?
      show_usage
      exit
    end

    return param
  end # def dewaynelovesella
  cli_helper

  # Returns the usage/help information as a string
  def usage
    a_string = options.cli.to_s + "\n"
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
    unless $warnings.empty?
      STDERR.puts
      STDERR.puts "The following warnings were generated:"
      STDERR.puts
      options.warnings.each do |w|
        STDERR.puts "\tWarning: #{w}"
      end
      STDERR.print "\nAbort program? (y/N) "
      answer = (STDIN.gets).chomp.strip.downcase
      $errors << "Aborted by user" if answer.size>0 && 'y' == answer[0]
      $warnings = []
    end
    unless $errors.empty?
      STDERR.puts
      STDERR.puts "Correct the following errors and try again:"
      STDERR.puts
      options.errors.each do |e|
        STDERR.puts "\t#{e}"
      end
      STDERR.puts
      exit(-1)
    end
  end # def abort_if_errors

  # Adds a string to the global $errors array
  def error(a_string)
    options.errors << a_string
  end

  # Adds a string to the global $warnings array
  def warning(a_string)
    options.warnings << a_string
  end

end # class CliHelper

