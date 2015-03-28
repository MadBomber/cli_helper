#!/usr/bin/env ruby
# encoding: utf-8
##########################################################
###
##  File: cli_stub.rb
##  Desc: Example on how to use cli_helper for q&d CLI utilities
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#

require 'awesome_print'

require 'cli_helper'
include CliHelper

configatron.version = '0.0.1' # the version of this utility program
configatron.support_config_files = true # default is false
configatron.disable_help    = false # default is false set true to remove the option
configatron.disable_verbose = false # ditto
configatron.disable_debug   = false # ditto
configatron.disable_version = false # ditto
configatron.suppress_errors = false # set to true to eat exceptions; unknown options added to arguments

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
# by cli_helper.  If configatron.support_config_files is TRUE then a '--config' parameter
# will also be presented.  '--config' takes a comma-separated list of file paths.  Each
# config file is processed within cli_helper and results combined within the configatron
# structure.
#
# -h, --help will automatically show a usage message on STDOUT and exit the program
# --version will print the program's version string to STDOUT and exit
# =v, --verbose will set the verbose boolean to true.
# -d, --debug will set the debug boolean to true.
# All boolean options have '?' and '!' methods generated,  For example debug? and
# verbose? are automatically generated.  Any program-specific booleans specified will
# also get methods defined for them.  The debug! methods sets the debug boollean to true.
# Same for verbose! etc.

cli_helper("An example use of cli_helper") do |o|

  # For a complete list of stuff see Slop on github.com
  # https://github.com/leejarvis/slop

  o.string  '-s', '--string', 'example string parameter',  default: 'IamDefault'
  o.int     '-i', '--int',    'example integer parameter', default: 42

  # FIXME: an issue with Slop
  #o.float   '-f', '--float',  'example float parameter', default: (22.0 / 7.0)

  o.array   '-a', '--array',  'example array parameter',   default: [:bob, :carol, :ted, :alice]
  o.path    '-p', '--path',   'example Pathname parameter', default: Pathname.new('default/path/to/file.txt')
  o.paths         '--paths',  'example Pathnames parameter', delimiter: ',', default: ['default/path/to/file.txt',
'file2.txt'].map{|f| Pathname.new f}

  # FIXME: Issue with Slop; default is not passed to the block.  When no parameter is
  #        given, an exception is raised.  Using the suppress_errors: true option silents
  #        the exception BUT still the default value is not passed to the block.
  #        This issue has been raised with the Slop author and a fix is in the works.
  o.string '-n', '--name', 'print Hello <name>', default: 'World!', suppress_errors: true do |a_string|
    a_string = 'world' if a_string.empty?
    puts "Hello #{a_string}"
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

rescue
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

