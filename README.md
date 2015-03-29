# cli_helper

If you write lots of command-line utility programs, or
even if you don't the cli_helper gem can be a helper
to you.  It integrates several common gems to give
a comprehensive configuration management experience.

Here are the gems used and what they do:

* configatron
  * makes config info available
  * http://github.com/markbates/configatron

* nenv
  * parses ENV for friendly use
  * http://github.com/e2/nenv

* inifile
  * parses INI files (or *.txt if you want to avoid windoze terms)
  * http://github.com/twp/inifile

* slop
  * parses ARGV
  * http://github.com/leejarvis/slop


## Convention

The convention w/r/t what value amoung concurrent sources
is the correct one to use is hierarchic
where the layer above trumps all the layers below.  This is the order:

* command-line parameter
  * config file value
    * system environment variable
      * default

This ordering says that regardless what you have set in
a config file or ENV or as a default, the value of the
command line parameter will be used.

I like to use ERB within my config files.  Consider 'default.yml.erb'
below:

```ruby
---
  host: <%= Nenv.host || 'localhost' %>
```

Processing this file will give me either the default value for host
of 'localhost' or if defined the value of the system environment
variable HOST.  I like Nenv over ENV.

Now suppose I use cli_helper within a program and execute the
program like this:

```ruby
program.rb --host devhost --config default.yml.erb,prod.ini
```

Because I have specifically called out the value of host on the
command line, that value will trump anything that comes from the
config file.

Did you notice that I had two files specified with the --config option?

The config files are processed in the order that they are given on the command
line.  Whatever values were obtained from the first file will be over-written
by the second and any subsequent config files.  Regardless of their
values for host, the command-line value trumps them all.


## Config files

cli_helper supports multiple types of configuration files:

```text
  *.rb
  *.yml
  *.ini
  *.txt (in the INI format)
  *.ini.erb
  *.txt.erb
  *.yml.erb
```

All values obtained from config files and command line parameters are
held in the configatron structure.


## Common Command-line Options

cli_helper predefines common command-line options.  These
can to disabled by the program if necessary.  The common options
are:

```text
  -h, --help
  -d, --debug
  -v, --verbose
  --version
  --config (optional)
```

To enable the support for config files do this before
calling the #cli_helger() method:

```ruby
configatron.support_config_files = true
```

To disable any of the other common options do this before
involking cli_helper:

```ruby
configatron.disable_help = true
configatron.disable_debug = true
configatron.disable_verbose = true
cpnfogatrpm/dosab;e_version = true
```

## Other options

The default behavior is to raise an exception if an unspecified option is
used on the command line.  For example if your program just uses the common
options and someone invokes the program with --xyzzy then an exception will be
raised saying that the option is unknown.

To prevent this exception you can set the suppress_errors parameter.  With
this parameter set to true an unknown option will just be added to the unprocessed
arguments array.

```ruby
configatron.suppress_errors = true
```

The unprocessed options can be access via the arguments array:

```ruby
configatron.arguments
```

The arguments array is also where you will find anything else from the
command line that was not processed by the cli_helper.  For example:

```ruby
my_program.rb -v *.txt
```

The file names matching the '*.txt' glob will be put into the configatron.arguments
array.

When process INI or TXT config files the following options can
be useful:

```ruby
configatron.ini_comment   # default: '#'
configatron.ini_encoding  # default: 'UTF-8'
configatron.ini_seperator # default: '='
```


## Boolean options auto-generate methods

Any boolean command-line option specified, even the predefined common ones,
have two methods defined: query(?) and banger(!).  For the help options
the methods look like this:

```ruby
def help?
  configatron.help
end

def help!
  configatron.help = true
end
```

## Names of command-line options

If you specify a command-line option of xyzzy, then an
entry in the configatron structure will be created having the
name 'xyzzy'.  If you do not use a long-form for the option
the short option name will be used.  For example '-x' will
be accessed as configatron.x


## Support methods

There are several support methods that I have included in cli_helper
that you may want to use.  The first three deal with
errors and warnings and what to do with them.

* warning(a_string)
* error(a_string)
* abort_if_errors

cli_helper defines two arrays within configatron: errors and warnings.  The
warning() and error() methods insert their strings into these arrays.  The
abort_if_errors method first looks at the warnings array and presents all of
those strings to the user via STDOUT.  It then asks the user if they want
to abort the program.  The default answer is no.

After presenting the warnings to the user, the abort_if_error method presents
all of the errors to the user.  Then it exits the program.

These next support methods are self explanatory:

* usage() #=> a_string
* show_usage() #=> usage string sent to STDOUT
* me()  #=> The full path to the file that "require 'cli_helper"" was involked
* my_name() #=> the basename of me

But this one needs some explaining:

* get_pathnames_from(an_array, extnames=['.json', '.txt', '.docx'])

The method get_pathnames_from() returns an array of pathnames matching a specific
set of file types.  The default types are txt, json and docx because that tends to
be the majority of the files in which I am interested.  Might add wcml to the default list
later.  Regardless you propabily ought to provide your own array of file extensions.  And
don't forget the dot!

If an entry in the array is a directory then its children will be search including any sub-directories recursively.

Here is how I typically use it :)

```ruby
get_pathnames_from(configatron.arguments, '.php').each do |f|
  f.delete_without_regret!
end
```


## Usage

Take a look at http://github.com/MadBomber/cli_helper/blob/master/example/cli_stub.rb


## License

You want it?  Its yours.
