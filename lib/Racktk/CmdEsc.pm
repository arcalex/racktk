package Racktk::CmdEsc;

#
# Youssef Eldakar <youssef.eldakar@bibalex.org>
#

use strict;

# Where sed is invoked indirectly as unquoted arguments to a remote
# shell (rsh), this is intended for escaping a string for use as regexp
# or replacement in an 's' command. 

sub escsedrsh
{
  $_ = $_[0];

  # Escape these characters twice to escape interpretation in the shell
  # as well as to escape interpretation in sed. Note that the backslash
  # escape character itself requires escaping in the shell. In addition,
  # all that obviously requires escaping here in the regular
  # expressions.
  s/\$/\\\\\\\$/g; s/\//\\\\\\\//g;

  # sed 's/\//\\\\\//g' | sed 's/\\\$/\\\\\\\$/g'

  $_;
}
