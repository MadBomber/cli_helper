# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "cli_helper"
  spec.version       = '0.0.1'
  spec.authors       = ["Dewayne VanHoozer"]
  spec.email         = ["dvanhoozer@gmail.com"]

  spec.summary       = %q{An encapsulates of common junk used with Q&D CLI utilities.}
  spec.description   = %q{An encapsulation of a convention I have been using with the slop, nenv, and other gems for quick and dirty development of command-line based utility programs.  Its not pretty.  It may even break your code.  I wouldn't use it if I were you.  You could, if you wanted, namespace this stuff within CliHelper and establish a new convention.  You might even wrap not only slop but some of those other ARGV parsers.  I only did this much after being shamed into it by rubycritic.}
  spec.homepage      = "http://github.com/MadBomber/cli_helper"
  spec.license       = "You want it?  Its yours."

  spec.require_paths = ["lib"]

  spec.add_dependency 'slop'
  spec.add_dependency 'nenv'
  spec.add_dependency 'awesome_print'

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'test_inline'

end
