#!/usr/bin/env ruby
# encoding: utf-8
##########################################################
###
##  File: cli_stub.rb
##  Desc: Example on how to use cli_helper for q&d CLI utilities
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#

require 'debug_me'
include DebugMe

require 'amazing_print'

require '../lib/cli_helper'
include CliHelper

configatron.version = '0.1.9' # the version of this utility program
configatron.enable_config_files = false # default is false
configatron.disable_help    = false # default is false set true to remove the option
configatron.disable_verbose = false # ditto
configatron.disable_debug   = false # ditto
configatron.disable_version = false # ditto
configatron.suppress_errors = true  # default is true; set to false to receive exceptions from Slop


# Sometimes you may have a few default config files that you
# want to apply before the command-line options.  Do it like
# this:

=begin
%w[
  ../tests/config/sample.yml
  ../tests/config/sample.yml.erb
].each do |dcf|
  cli_helper_process_config_file(dcf)
end
=end

# OR just pass a directory and all of the config files in the
# directory will be processed:

#  cli_helper_process_config_file('../tests/config')


# HELP is extra stuff shown with usage.  It is optional.  You
# can put anything you want into it.  Since it is optional, it
# can be completely left out of your program.  This HELP text
# will appear at the end of the usage message after the help
# text for each option (command-line parameter).
HELP = <<EOHELP
Important:

  Put important stuff here.

  Config files also support ERB preprocessing.  use
  cile names like: *.uml.erb *.ini.erb *.txt.erb

  Do not use *.rb.erb that's just silly.

EOHELP

# The description (aka banner) text is optional.  The block is not required.it
# only the default options and config files are desired.  The block allows for
# the definition of program-specific options.
#
# Default options for help, debug, verbose, and version are automatically inserted
# by cli_helper.  If configatron.enable_config_files is TRUE then a '--config' parameter
# will also be presented.  '--config' takes a comma-separated list of file paths.  Each
# config file is processed within cli_helper and results combined within the configatron
# structure.
#
# -h, --help will automatically show a usage message on STDOUT and exit the program
# --version will print the program's version string to STDOUT and exit
# -v, --verbose will set the verbose boolean to true.
# -d, --debug will set the debug boolean to true.
# All boolean options have '?' and '!' methods generated,  For example debug? and
# verbose? are automatically generated.  Any program-specific booleans specified will
# also get methods defined for them.  The debug! methods sets the debug boollean to true.
# Same for verbose! etc.

cli_helper("An example use of cli_helper") do |o|

  # For a complete list of stuff see Slop on github.com
  # https://github.com/leejarvis/slop

  # boolean parameters will also generate the methods long-parameter? and long-parameter!
  # for example this line:
  o.bool    '-b', '--bullstuff', default: false

  # will auto generate the methods bullstuff? and bullstuff!
  # where bullstuff? returns the value of configatron.bullstuff
  #   and bullstuff! sets the value of configatron.bullstuff to true
  #
  # NOTE: boolean options are special in that default: false is assumed
  #       when no default item is provided.  This means that
  #         o.bool '-e', 'Example', default: false
  #   and   o.bool '-e', 'Example'
  #   are treated identically.  The value for the parameter will be false when the
  #   parameter is included on the command line.
  #
  #   This is NOT the case for other parameter classes.  For them, if no default is
  #   provided AND they are not present on the command line, THEN their value will be
  #   nil AND they will (by convention) be treated as a required parameter that has
  #   not been provided.  This will result in a warning message being generated.


  o.string  '-s', '--string', 'example string parameter',  default: 'IamDefault'
  o.string  '-r', '--required', 'a required parameter'     # I know its required because there is no default
  o.bool          '--xyzzy',  'a required boolean without a default', required: true

  # NOTE: you can use many "flags" in defining an option.  Each is valid on the command line.
  # However, only the last flag can be used to retrieve the value via the configatron capability.
  # To get the value entered by the user for this integer parameter you must use:
  #    configatron.i3  or  configatron['i3']  or  configatron[:i3]

  o.int     '-i', '--i2', '--i3', 'example integer parameter', default: 42


  o.float   '-f', '--float',  'example float parameter', default: (22.0 / 7.0)
  o.array   '-a', '--array',  'example array parameter',   default: [:bob, :carol, :ted, :alice]
  o.path    '-p', '--path',   'example Pathname parameter', default: Pathname.new('default/path/to/file.txt')
  o.paths         '--paths',  'example Pathnames parameter', delimiter: ',',
    default: ['default/path/to/file.txt', 'file2.txt'].map{|f| Pathname.new f}

  o.string '-n', '--name', 'print Hello <name>', default: 'World!', suppress_errors: true do |a_string|
    a_string = 'world' if a_string.empty?
    puts "Hello #{a_string}"
  end

  o.on '--quit', "print 'Take this option and do it!' and then exit" do
    puts 'Take this option and do it!'
    exit
  end

end

# ARGV is not touched.  However all command line parameters that are not consummed
# are available in configatron.arguments

# Display the usage info
if  ARGV.empty?
  show_usage
  exit
end


# Error check your stuff; use error('some message') and warning('some message')

unless configatron.arguments.empty?
  warning "These items were not processed #{configatron.arguments}"
end

if configatron.arguments.include?('error')
  error "You wanted an error, so you got one."
end

if configatron.arguments.include?('warning')
  warning "You wanted a warning, so you got one."
end

=begin
  configatron.errors and configatron.warnings are of type Array.
  All warnings will be presented to the user.  The user will
  be asked wither the program should be aborted.
=end

# present all warnings and all errors to the user
# if there are errors, the program will exit after
# displaying the error messages.
abort_if_errors


######################################################
# Local methods


######################################################
# Main

at_exit do
  puts
  puts "Done."
  puts
end

ap configatron.to_h  if verbose? || debug?

stub = <<EOS


   d888888o. 8888888 8888888888 8 8888      88 8 888888888o
 .`8888:' `88.     8 8888       8 8888      88 8 8888    `88.
 8.`8888.   Y8     8 8888       8 8888      88 8 8888     `88
 `8.`8888.         8 8888       8 8888      88 8 8888     ,88
  `8.`8888.        8 8888       8 8888      88 8 8888.   ,88'
   `8.`8888.       8 8888       8 8888      88 8 8888888888
    `8.`8888.      8 8888       8 8888      88 8 8888    `88.
8b   `8.`8888.     8 8888       ` 8888     ,8P 8 8888      88
`8b.  ;8.`8888     8 8888         8888   ,d8P  8 8888    ,88'
 `Y8888P ,88P'     8 8888          `Y88888P'   8 888888888P


EOS

puts stub

# The values of command line parameters are available anywhere via configatron as
# either methods or hash keys.  The name of the method/key is the name of the
# last "flag" defined for that option.  For example the name option was defined
# with the flags "-n" and "--name" so you can access that parameter like this:

puts "\n\nHello #{configatron.name}"

# or like this:

puts "Hello #{configatron['name']}"

# or like this:

puts "Hello #{configatron[:name]}\n\n"

__END__

The same thing is true if only a single letter "-z" is used.
Access the value like this:

  configatron.z
  configatron['z']
  configatron[:z]

Regardless of how many "flags" are defined for an option, it is only the
last one in the list that is used to access its value.  In the "name" example
about you CANNOT access the value via configatron.n because "--name" was the
last flag defined for the option.

When the user enters a "flag" more than once on a command line only the value of
The last entry will be kept.

Run this program with the following parameters and see what happens:

  -n Tom -n Dick -n Harry

you should get a warning that there were multiple entries on the command
line.  The value that is used will be the last one - "Harry"

