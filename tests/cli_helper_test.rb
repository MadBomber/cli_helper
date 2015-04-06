#!/usr/bin/env ruby
################################################
## Here is how it works

require 'timecop'

# Freeze time for the erb tests
Timecop.freeze(Time.now)

require_relative '../lib/cli_helper'
include CliHelper


# can not use minitest because it requires pry which
# requires an older version of slop
#require 'minitest/autorun'
require 'kick_the_tires'
include KickTheTires

require 'debug_me'
include DebugMe


configatron.enable_config_files = true

#describe 'how it works' do

#it '000 supports basic common parameters' do
  params = cli_helper
  assert params.is_a? Slop::Options
  assert usage.include?('--help')
  assert usage.include?('--debug')
  assert usage.include?('--verbose')
  assert usage.include?('--version')
  refute usage.include?('--xyzzy')

  if configatron.enable_config_files
    assert usage.include?('--config')
  else
    refute usage.include?('--config')
  end

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
  cli_helper do |param|
    param.string '-x', '--xyxxy', 'example MAGIC parameter',  default: 'IamDefault'
  end
  assert usage.include?('MAGIC')
#end

#it '010 supports banner' do
  refute usage().include?('BANNER')
  cli_helper('This is my BANNER')
  assert usage().include?('BANNER')
#end

#it '015 supports additional help in usage' do
  refute usage.include?('HELP')
  HELP = "Do you need some HELP?"
  assert usage.include?('HELP')
#end

#it '020 put it all together' do
  cli_helper('This is my BANNER') do |o|
    o.string '-x', '--xyxxy', 'example MAGIC parameter',  default: 'IamDefault'
  end
  HELP = "Do you need some HELP?"
  assert usage.include?('BANNER')
  assert usage.include?('MAGIC')
  assert usage.include?('HELP')
#end

#it '025 Add to options.errors' do
  assert configatron.errors.empty?
  a_message = 'There is a serious problem here'
  error a_message
  refute configatron.errors.empty?
  assert_equal 1, configatron.errors.size
  assert_equal a_message, configatron.errors.first
#end

#it '030 Add to options.warnings' do
  assert configatron.warnings.empty?
  a_message = 'There is a minor problem here'
  warning a_message
  refute configatron.warnings.empty?
  assert_equal 1, configatron.warnings.size
  assert_equal a_message, configatron.warnings.first
#end

#it '035 Add to options.errors' do
  refute configatron.errors.empty?
  a_message = 'There is another serious problem here'
  error a_message
  assert_equal 2, configatron.errors.size
  assert_equal a_message, configatron.errors.last
#end

#it '040 Add to options.warnings' do
  refute configatron.warnings.empty?
  a_message = 'There is a another minor problem here'
  warning a_message
  assert_equal 2, configatron.warnings.size
  assert_equal a_message, configatron.warnings.last
#end

#it '050 support erb config files' do
  unless configatron.config.nil?
    configatron.config.each do |c|
      case c.basename.extname.to_s.downcase
        when '.erb'
          file_type = c.basename.to_s.downcase.gsub('.erb','').split('.').last
          case file_type
            when 'ini'
              assert_equal String, configatron.wall_clock.the_mouse_says.class
              assert_equal Time.now, configatron.wall_clock.the_mouse_says
            when 'txt'
              assert_equal String, configatron.wrist.watch_time.class
              assert_equal Time.now, configatron.wrist.watch_time
            when 'yml'
              assert_equal Time, configatron.production.watch_time.class
              assert_equal Time.now, configatron.production.watch_time
          else
          end
        when '.rb'
          assert_equal 'devhost', configatron.development.host
        when '.txt'
          assert_equal 6, configatron.fingers.right_hand
        when '.ini'
          assert_equal 'wedding ring', configatron.hands.left_hand
        when '.yml'
          assert_equal 'go fish', configatron.production.threes
          assert configatron.production.watch_time.nil?
        when '.xyzzy'
      else
      end
    end
  else
    # means test did not include config files
  end
#end





#it '888 prints usage()'  do
  puts
  puts "="*45
  show_usage
  puts "="*45
  puts
  a_string = <<EOS
This is my BANNER

Usage: cli_helper_test.rb [options] ...

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


a_string_with_config = <<EOS
This is my BANNER

Usage: cli_helper_test.rb [options] ...

Where:

  Common Options Are:
    -h, --help     show this message
    -v, --verbose  enable verbose mode
    -d, --debug    enable debug mode
    --version      print the version: 0.0.1

  Program Options Are:
    -x, --xyxxy    example MAGIC parameter
    --config       read config file(s) [*.rb, *.yml, *.ini, *.erb]

Do you need some HELP?
EOS

  if configatron.enable_config_files
    assert_equal a_string_with_config, usage
  else
    assert_equal a_string, usage
  end
#end

#it '999 Show the options structure' do
  puts '*'*45
  ap configatron.to_h
#end

#end # decribe 'how it works'
