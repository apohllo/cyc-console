= cyc-console

* http://github.com/apohllo/cyc-colors

== DESCRIPTION:

Console for the Cyc ontology written in Ruby.

== FEATURES/PROBLEMS:

* support for history
* highlighting of unmatched parenthesis
* colorful prompt
* readline based editing (arrows, delete, etc. works!)

* problems with multiline commands
* messeges send to stdout are not visible
* errors are not printed - only nil is returned

== SYNOPSIS:

Cyc-console is console for the Cyc ontology written in Ruby.
It is inspired by the Ruby console - irb. The original Cyc console
has many limitations. There is no support for readline, which
means that arrow keys doesn't work as expected. There is also
no auto-completion, no history, etc. This console aims at overcomming
these limitations.

== INSTALL:

You need RubyGems v. 1.2 

* gem -v 
* 1.2.0 #=> ok

You need the github.com repository to be added to your sources list:

* gem sources -a http://gems.github.com

Then you can type:

* sudo gem install apohllo-cyc-console

== BASIC USAGE: 

The gem comes with +cyc+ command, so you can simply:

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

One helpful features is to brows the history by providing the beginning of the command.
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

