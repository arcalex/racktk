# RackTk

RackTk is a command-line toolkit for working with computer clusters.
The Bibliotheca Alexandrina (BA) has been building up this toolkit over
the time out of the need to make life easier for administrators of
commodity-hardware computer clusters.  The toolkit features parallel
shell, parallel copy, and simple tools for netinstall management.  One
key feature in RackTk is flexible host selection syntax, also available
as a Perl module for reuse in applications.

RackTk is useful for system administrators seeking command-line tools
with a small footprint for their computer clusters.

Tools in the toolkit addresses the following needs: (1) enumeration of
hosts in the cluster; (2) batch execution of commands on remote hosts;
(3) batch copying of files to remote hosts; and (4) batch powering on
and off and managing network boot configuration of hosts in the cluster.

## Enumeration of hosts in the cluster

Host selection options in RackTk are like those in dsh(1) but with
extended functionality.  -m selects individual hosts (machines), -g
selects hosts as defined in NIS netgroups or in flat files under the
dsh(1) 'group' directory, -f selects hosts listed in arbitrary flat
files, and -a selects all hosts as defined in the 'all' group.  As
extension to the host selection syntax in dsh(1), in RackTk, host
selection options may be combined, and exclusions may be applied.

A few examples follow.

Select hostname, decimal IP, and hexadecimal IP of hosts in netgroup
'@1', excluding hosts in netgroup '@hadoop':

```
rack -g '@1,!@hadoop'
```

Select hexadecimal IP of hosts in netgroup '@irods', excluding hosts
'aa110021' and 'aa110043':

```
rack -g '@irods' -m '!aa110021,!aa110043' -x
```

Select hostname and decimal IP of hosts in netgroup '@irods', excluding
hosts 'aa110038', 'aa110043', and all hosts in between:

```
rack -g '@irods' -m '!aa110038..aa110043' -h -i
```

The Racktk::Select Perl module handles host selection in RackTk.
