# Simple template for HW1, problem #3a 

import sys, re

# You may find it convenient to define shorthand to use in your solution.
# For example,
#
#    LETTER = r'[a-z]'
#    ALPHANUM = r'[a-z0-9]'
#
# Later, inside a regular expression in the rules section, you can concatenate
# these definitions with other things, like this:
#
#    ANSWER = LETTER + ALPHANUM + "*"

ANSWER = r'.*a.*e.*i.*o.*u.*'

# Restrictions: Besides ordinary characters (which stand for themselves),
#     ANSWER must use only the constructs [...], *, +, |, ^, $, (...), ?,
#     and . 


# To test your solution, put the inputs to be tested, one to a
# line, in some file INPUTFILE, and enter the command
#
#    python P3a.py INPUTFILE
# or
#
#    python P3a.py < INPUTFILE
#
# Or, just type
#
#    python P3a.py
#
# and enter inputs, one per line, by hand (on Unix, use ^D to end this input,
# or ^C^D in an Emacs shell).

if len (sys.argv) > 1:
    inp = open (sys.argv[1])
else:
    inp = sys.stdin

# Note for Python novices: A nicer way to write the next three lines and
# the readline at the end of the loop is to use the single line
#   for line inp:
# However, since the Python runtime would buffer input in that case, it
# would not work well for interactive input (it would wait until you indicated
# end-of-file).

line = inp.readline ()
while line:
    line = re.sub (r'[\n\r]', '', line)

    try:
        if re.match (ANSWER, line):
            print 'Input "%s" accepted.' % line
        else:
            print 'Input "%s" rejected.' % line
    except:
        print 'Error in regular expression:', ANSWER
        sys.exit (1)

    line = inp.readline ()
