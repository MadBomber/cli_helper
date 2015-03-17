#!/usr/bin/env ruby
# encoding: utf-8
##########################################################
###
##  File: cli_stub.rb
##  Desc: Example on how to use cli_helper for q&d CLI utilities
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#

#require 'cli_helper'
require_relative '../lib/cli_helper'

$options[:version] = '0.0.1' # the version of this utility program

# HELP is extra stuff shown with usage.  It is optional.
HELP = <<EOHELP
Important:

  Put important stuff here.

EOHELP

# The description (aka banner) text is optional.  The block is required.
cli_helper("An example use of cli_helper") do |o|

  # For a complete list of stuff see Slop on github.com
  # https://github.com/leejarvis/slop

  o.string  '-s', '--string', 'example string parameter',  default: 'IamDefault'
  o.int     '-i', '--int',    'example integer parameter', default: 42
  o.float   '-f', '--float',  'example float parameter', default: 22.0 / 7.0
  o.array   '-a', '--array',  'example array parameter',   default: [:bob, :carol, :ted, :alice]
  o.path    '-p', '--path',   'example Pathname parameter', default: Pathname.new('default/path/to/file.txt')
  o.paths         '--paths',  'example Pathnames parameter', delimiter: ',', default: ['default/path/to/file.txt', 'file2.txt'].map{|f| Pathname.new f}

  # FIXME: Issue with Slop; default is not passed to the block.  When no parameter is
  #        given, an exception is raised.  Using the suppress_errors: true option silents
  #        the exception BUT still the default value is not passed to the block.
  o.string '-n', '--name', 'print Hello <name>', default: 'World!', suppress_errors: true do |a_string|
    a_string = 'world' if a_string.empty?
    puts "Hello #{a_string}"
  end

end

# ARGV is not touched.  However all command line parameters that are not consummed
# are available in $options[:arguments]

# Display the usage info
if  ARGV.empty?
  show_usage
  exit
end


# Error check your stuff; use error('some message') and warning('some message')

unless $options[:arguments].empty?
  warning "These items were not processed #{$options[:arguments]}"
end

if $options[:arguments].include?('error')
  error "You wanted an error, so you got one."
end

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

ap $options  if verbose? || debug?

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

