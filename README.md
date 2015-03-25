# cli_helper.rb

Notes for Branch kill_the_globalist

As I continue to tweek cli_helper the more it seems to morph into
a configuration manager that also uses the command line options.
There are already lots of configuration managers.  Why would I
want to reinvent this wheel?

IF I wanted to use cli_helper in more complex applications beyond
the domain of quick and dirty utilities, I would want to remove
the use of $global variables.  Why?  because of the possibility
of dirty-fication in concurrent real-threads.

So this branch is to experiment around with different ideas - all
breaking ideas.

Ought to look at existing configuration managers to see which ones
will integrate most easily.

What I want from a configuration manager:

`1) full support for the command line with beautiful usage help text
 2) support for ENV
 3) support for YAML/ERB
 4) support for defaults

We start with defaults, trumped by config files, trumped by ENV
finally trumped by command line options.

This branch may go too far beyound the original intent for cli_help to
be simple.





I had this code just being lazy on my computer.  It might be of use
to someone else; but, its just really intended to support my own
quick and dirty command-line based utilities.  Mostly they are one-offs
but sometimes they hang around.

I typically create thes cli utilities using my own code generater which
resulted in lots of duplicate source blocks roll around on the deck.  This
little library will DRYup my code a little.


## Usage

TODO: Write usage instructions here in case someone can't figure it out
      for themselves.


## License

You want it?  Its yours.
# cli_helper
