= cyc-console

* http://github.com/apohllo/cyc-colors

== DESCRIPTION:

Console for the Cyc ontology written in Ruby.

== FEATURES/PROBLEMS:

* support for history
* highlighting of unmatched parenthesis
* colorful prompt
* readline based editing (arrows, delete, etc. works!)
* autocompletion of symbols (present in server answers)
  and functions (listed in ~/.cyc_functions)

* problems with multiline commands
* messeges send to stdout are not visible
* errors are not printed - only nil is returned
* text protocol is used (lenghty output is cut, it might be slower
  than the binary protocol, but is not as important when working
  in interactive mode)

== SYNOPSIS:

Cyc-console is console for the Cyc ontology written in Ruby.
It is inspired by the Ruby console - irb. The original Cyc console
has many limitations. There is no support for readline, which
means that arrow keys doesn't work as expected. There is also
no auto-completion, no history, etc. This console aims at overcomming
these limitations.

== INSTALL:

You need RubyGems v. 1.3.3

  $ gem -v 
  1.2.0 #=> not OK
  $ gem update --system
  ...
  $ gem -v
  1.3.3 #=> OK

You need the gemcutter repository to be added to your sources list:

 $ gem sources -a http://gemcutter.org

Then you can install the Cyc console with:

 $ sudo gem install cyc-console

If it doesn't work as expected:

 ERROR:  could not find gem cyc-console locally or in a repository

try installing the gemcutter gem, and issuing
the gem tumble command:

 $ sudo gem install gemcutter
 $ sudo gem tumble

And then try to install the gem once again:

 $ sudo gem install cyc-console

== BASIC USAGE: 

Prerequisites:
* Cyc server is running 
  * you can download it from http://www.opencyc.org
* Telnet connection is on
  * type (enable-tcp-server :cyc-api 3601) in the cyc console or Cyc Browser
    -> Tools -> Interactor
* rubygems +bin+ directory is in your PATH variable:
  * +export PATH=/usr/lib/ruby/gems/1.8/bin+
  * you might have to adjust it to your system (e.g. in Debian it would be
    +/var/lib/gems.../+
  * you might want to store it in your +.bashrc+
  

The gem comes with +cyc+ command, so you can simply type:

  $ cyc
  cyc@localhost:3601>

By defualt the console connects with Cyc on the localhost on the default port 3601.
You can change it, by providing the name of the host, and the port as parameters:

  $ cyc www.example.com 4567
  cyc@www.example.com:4567>

The console works like regular Cyc console (however, see problems above):

  cyc@localhost:3601>(genl? #$Cat #$Animal)
  T
  cyc@localhost:3601>

If you run the console once again, you will have access to previous commands. 
The history is kept ~/.cyc_history and remembers 1000 commands by default. 
You can change these, by providing CYC_HISTORY_FILE and CYC_HISTORY_SIZE 
environment varibles respectively.

One helpful feature is to brows the history by providing the beginning of the command.
If you type:

  cyc@localhost:3601>(genl?<PG-UP>

you'll get the latest command which has the same form:

  cyc@localhost:3601>(genl? #$Cat #$Animal)

This really speeds-up working with the console.


== LICENSE:
 
(The MIT License)

Copyright (c) 2009 Aleksander Pohl

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

== FEEDBACK

* mailto:apohllo@o2.pl

