To be able to write "example_bash_script.sh" in the terminal 
without writing out the full path the script has to be placed inside /usr/bin.

This will copy all bash scripts (*.sh) from the specified folder. 
cp /media/alpha/36E9-17E4/Scripts/*.sh /usr/bin

Se file CustomBashScriptShortcut.png for how to manually setup a custom shortcut. 



!/bin/bash.


In simple words, the she-bang at the head of the 
script tells the system that this file is 
a set of commands to be fed to the 
command interpreter indicated.


#!/bin/sh :Executes the script using the Bourne shell or a compatible shell, with path /bin/sh
#!/bin/bash :Executes the script using the Bash shell.
#!/bin/csh -f :Executes the script using C shell or a compatible shell.
#!/usr/bin/perl -T :Executes the script using perl with the option of taint checks
#!/usr/bin/env python :Executes the script using python by looking up the path 
to the python interpreter automatically from the environment variables
