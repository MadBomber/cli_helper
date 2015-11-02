# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "cli_helper"
  spec.version       = '0.1.6.1'
  spec.authors       = ["Dewayne VanHoozer"]
  spec.email         = ["dvanhoozer@gmail.com"]

  spec.summary       = %q{An encapsulation of an integration of slop, nenv, inifile and configatron.}
  spec.description   = %q{
     An encapsulation of a convention I have been using
     with the slop, nenv, inifile and configatron gems for quick and dirty
     development of
     command-line based utility programs.  Slop parses ARGV; Nenv parses ENV;
     inifile parses INI; Configatron keeps it all together.  YAML and ERB
     preprocessing is also available.  Ruby configuration files are also supported.
     and you can specify multiple config files of mixed types at once.
  }
  spec.homepage      = "http://github.com/MadBomber/cli_helper"
  spec.license       = "You want it?  It's yours."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  end

  spec.add_dependency 'configatron'
  spec.add_dependency 'nenv'
  spec.add_dependency 'inifile'
  spec.add_dependency 'slop', "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'kick_the_tires'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'debug_me'
  spec.add_development_dependency 'timecop'

end
