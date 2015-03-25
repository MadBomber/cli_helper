#!/usr/bin/env ruby
################################################
## Here is how it works

require_relative '../lib/cli_helper'
c = CliHelper.new



#require 'minitest/autorun'
require 'kick_the_tires'

#describe 'how it works' do

#it '000 supports basic common parameters' do
  params = c.cli_helper
  assert params.is_a? Slop::Options
  assert c.usage.include?('--help')
  assert c.usage.include?('--debug')
  assert c.usage.include?('--verbose')
  assert c.usage.include?('--version')
  refute c.usage.include?('--xyzzy')
#end

=begin
# NOTE: The Test construct creates a dynamic class which
# does not incorporate 'define_method'  This Test results
# in errors that are a consequence of the testing framework
# not the object under test.
it '002 creates accessor methods to boolean options' do
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

#it '005 block inclusion' do
  c.cli_helper do |param|
    param.string '-x', '--xyxxy', 'example MAGIC parameter',  default: 'IamDefault'
  end
  assert usage.include?('MAGIC')
#end

#it '010 supports banner' do
  refute c.usage().include?('BANNER')
  c.cli_helper('This is my BANNER')
  assert c.usage().include?('BANNER')
#end

#it '015 supports additional help in usage' do
  refute c.usage.include?('HELP')
  HELP = "Do you need some HELP?"
  assert c.usage.include?('HELP')
#end

#it '020 put it all together' do
  cli_helper('This is my BANNER') do |o|
    o.string '-x', '--xyxxy', 'example MAGIC parameter',  default: 'IamDefault'
  end
  HELP = "Do you need some HELP?"
  assert c.usage.include?('BANNER')
  assert c.usage.include?('MAGIC')
  assert c.usage.include?('HELP')
#end

#it '025 Add to options.errors' do
  assert options.errors.empty?
  a_message = 'There is a serious problem here'
  c.error a_message
  refute c.options.errors.empty?
  assert_equal 1, c.options.errors.size
  assert_equal a_message, c.options.errors.first
#end

#it '030 Add to options.warnings' do
  assert c.options.warnings.empty?
  a_message = 'There is a minor problem here'
  c.warning a_message
  refute c.options.warnings.empty?
  assert_equal 1, c.options.warnings.size
  assert_equal a_message, c.options.warnings.first
#end

#it '035 Add to options.errors' do
  refute c.options.errors.empty?
  a_message = 'There is another serious problem here'
  c.error a_message
  assert_equal 2, c.options.errors.size
  assert_equal a_message, c.options.errors.last
#end

#it '040 Add to options.warnings' do
  refute c.warnings.empty?
  a_message = 'There is a another minor problem here'
  c.warning a_message
  assert_equal 2, c.options.warnings.size
  assert_equal a_message, c.options.warnings.last
#end





#it '888 prints usage()'  do
  puts
  puts "="*45
  c.show_usage
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

  assert_equal a_string, c.usage
#end

#it '999 Show the options structure' do
  ap c.options
#end

#end # decribe 'how it works'
