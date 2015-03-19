# encoding: utf-8
##########################################################
###
##  File: cli_helper.rb
##  Desc: Some DRYed up stuff for quick and dirty CLI utilities
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#

#require 'test_inline'

# NOTE: this conditional required by test_inline
if caller.empty?
  required_by_filename = __FILE__
else
  required_by_filename = caller.last.split(':').first
end

require 'debug_me'
include DebugMe

require 'awesome_print'

require 'pathname'
require 'nenv'
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
end # module Slop

$cli      = 'a place holder'
$errors   = []
$warnings = []

$options = {
  version:        '0.0.1',# the version of this program
  arguments:      [],     # whats left after options and parameters are extracted
  verbose:        false,
  debug:          false,
  help:           false,
  user_name:      Nenv.user || Nenv.user_name || Nenv.logname || 'Dewayne VanHoozer',
  me:             Pathname.new(required_by_filename).realpath,
  home_path:      Pathname.new(Nenv.home)
}

$options[:my_dir]   = $options[:me].parent
$options[:my_name]  = $options[:me].basename.to_s

# Return full pathname of program
def me
  $options[:me]
end

# Returns the basename of the program as a string
def my_name
  $options[:my_name]
end

# Returns the version of the program as a string
def version
  $options[:version]
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

  param.on '--version', "print the version: #{$options[:version]}" do
    puts $options[:version]
    exit
  end

  param.separator "  Program Options Are:"

  yield(param) if block_given?

  parser = Slop::Parser.new(param)
  $cli = parser.parse(ARGV)

  $options.merge!($cli.to_hash)
  $options[:arguments] = $cli.arguments


  bools = param.options.select do |o|
    o.is_a? Slop::BoolOption
  end.select{|o| o.flags.select{|f|f.start_with?('--')}}.
      map{|o| o.flags.last.gsub('--','')} # SMELL: depends on convention

  bools.each do |m|
    s = m.to_sym
    define_method(m+'?') do
      $options[s]
    end unless self.respond_to?(m+'?')
    define_method(m+'!') do
      $options[s] = true
    end unless self.respond_to?(m+'!')
  end

  if help?
    show_usage
    exit
  end

  return param
end # cli_helper

# Returns the usage/help information as a string
def usage
  a_string = $cli.to_s + "\n"
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
    $warnings.each do |w|
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
    $errors.each do |e|
      STDERR.puts "\t#{e}"
    end
    STDERR.puts
    exit(-1)
  end
end # def abort_if_errors

# Adds a string to the global $errors array
def error(a_string)
  $errors << a_string
end

# Adds a string to the global $warnings array
def warning(a_string)
  $warnings << a_string
end


__END__
################################################
## Here is how it works

Test '000 supports basic common parameters' do
  params = cli_helper
  assert params.is_a? Slop::Options
  assert usage.include?('--help')
  assert usage.include?('--debug')
  assert usage.include?('--verbose')
  assert usage.include?('--version')
  refute usage.include?('--xyzzy')
end

=begin
# NOTE: The Test construct creates a dynamic class which
# does not incorporate 'define_method'  This Test results
# in errors that are a consequence of the testing framework
# not the object under test.
Test '002 creates accessor methods to boolean options' do
  cli_helper
  all_methods = methods
  %w[ help? debug? verbose? version?
      help! debug! verbose! version!].each do |m|
    assert all_methods.include?(m)
  end
  refute all_methods.include?('xyzzy?')
  refute all_methods.include?('xyzzy!')
end
=end

Test '005 block inclusion' do
  cli_helper do |param|
    param.string '-x', '--xyxxy', 'example MAGIC parameter',  default: 'IamDefault'
  end
  assert usage.include?('MAGIC')
end

Test '010 supports banner' do
  refute usage().include?('BANNER')
  cli_helper('This is my BANNER')
  assert usage().include?('BANNER')
end

Test '015 supports additional help in usage' do
  refute usage.include?('HELP')
  HELP = "Do you need some HELP?"
  assert usage.include?('HELP')
end

Test '020 put it all together' do
  cli_helper('This is my BANNER') do |o|
    o.string '-x', '--xyxxy', 'example MAGIC parameter',  default: 'IamDefault'
  end
  HELP = "Do you need some HELP?"
  assert usage.include?('BANNER')
  assert usage.include?('MAGIC')
  assert usage.include?('HELP')
end

Test '025 Add to $errors' do
  assert $errors.empty?
  a_message = 'There is a serious problem here'
  error a_message
  refute $errors.empty?
  assert_equal 1, $errors.size
  assert_equal a_message, $errors.first
end

Test '030 Add to $warnings' do
  assert $warnings.empty?
  a_message = 'There is a minor problem here'
  warning a_message
  refute $warnings.empty?
  assert_equal 1, $warnings.size
  assert_equal a_message, $warnings.first
end

Test '035 Add to $errors' do
  refute $errors.empty?
  a_message = 'There is another serious problem here'
  error a_message
  assert_equal 2, $errors.size
  assert_equal a_message, $errors.last
end

Test '040 Add to $warnings' do
  refute $warnings.empty?
  a_message = 'There is a another minor problem here'
  warning a_message
  assert_equal 2, $warnings.size
  assert_equal a_message, $warnings.last
end





Test '999 prints usage()'  do
  puts
  puts "="*45
  show_usage
  puts "="*45
  puts
  a_string = <<EOS
This is my BANNER

Usage: cli_helper.rb [options] ...

Where:
  Common Options Are:
    -h, --help     show this message
    -v, --verbose  enable verbose mode
    -d, --debug    enable debug mode
    --version      print the version: 0.0.1
  Program Options Are:
    -x, --xyxxy    example MAGIC parameter

Do you need some HELP?
EOS

  assert_equal a_string, usage
end

