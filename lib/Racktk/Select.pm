package Racktk::Select;


# Copyright (C) 2009-2010, 2012-2013, 2015 Bibliotheca Alexandrina
# <http://www.bibalex.org/>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


use strict;

use Net::NIS::Netgroup;

sub select
{


my @results;
my %results_hash;

my @include;
my @exclude;

    if ( $_[0]->{m} )
    {
#     @results = ( @results,       lookup_ranges ( $_[0]->{m}, 0 )         );

      @include = ( @include,       lookup_ranges ( $_[0]->{m}, 0 )         );
      @exclude = ( @exclude,       lookup_ranges ( $_[0]->{m}, 1 )         );
    }

    if ( $_[0]->{g} )
    {
#     @results = ( @results,       lookup_groups ( $_[0]->{g}, 0 )         );

      @include = ( @include,       lookup_groups ( $_[0]->{g}, 0 )         );
      @exclude = ( @exclude,       lookup_groups ( $_[0]->{g}, 1 )         );
    }

    if ( $_[0]->{a} )
    {
#     @results = ( @results,       lookup_groups ( "all"     , 0 )         );

      @include = ( @include,       lookup_groups ( "all"     , 0 )         );
      @exclude = ( @exclude,       lookup_groups ( "all"     , 1 )         );
    }

#   # SORT and UNIQ

#   %results_hash = ();

#   @results = grep { ! $results_hash{ $_->{h} }++ }
#     ( sort { $a->{h} cmp $b->{h} } @results );

    # SORT and UNIQ

    %results_hash = ();

    @include = grep { ! $results_hash{ $_->{h} }++ }
      ( sort { $a->{h} cmp $b->{h} } @include );

    # SORT and UNIQ

    %results_hash = ();

    @exclude = grep { ! $results_hash{ $_->{h} }++ }
      ( sort { $a->{h} cmp $b->{h} } @exclude );

    @results = exls (
      \@include,
      \@exclude );

    @results;


}

sub show
{
}

# I exclude any element in @{$_[0]} that matches an element in @{$_[1]}
# and return the resulting list. The two input lists must be sorted.

sub exls
{
  my @results;

  my $i = 0;
  my $j = 0;

  my $k = 0;

  while ( $i < @{$_[0]} &&
          $j < @{$_[1]} )
  {
      if ( ( $_[0]->[$i]->{h} cmp $_[1]->[$j]->{h} ) == -1 )
      {
         $results[$k] = $_[0]->[$i];
         $i++;
         $k++;
      }
   elsif ( ( $_[0]->[$i]->{h} cmp $_[1]->[$j]->{h} ) ==  1 )
      {
         $j++;
      }
   else
      {
         $i++;
      }
  }

  while ( $i < @{$_[0]} )
  {
         $results[$k] = $_[0]->[$i];
         $i++;
         $k++;
  }

  return @results;
}

sub lookup_groups
{

  map {
    /(!)?(.*)/ && ( ! $_[1] && ! $1 ||
                      $_[1] &&   $1 ) ?
    lookup_group ( $2 ) : () } split /,/, $_[0];
}

sub packup_group
{
}

sub lookup_group
{
  my $g = $_[0];

  if ( $g =~ s/^@// )
  {
    lookup_group_net ( $g );
  }
  else
  {
    lookup_group_dsh ( $g );
  }
}

sub lookup_group_dsh
{
  my @results;

   open    FH,
    locate_group_dsh ( "$_[0]" ) ||

    return undef;

  while ( <FH> )
  {

  # # Double quotes necessary around subpattern variables
  # lookup_range ( "$1", "$1" ) if ( /^\s*(\w+)/ );

    if ( /^\s*(\w+)/ )
    {

    push @results, $_ foreach lookup_range ( "$1", "$1" );

    }
  }

  close    FH;

  return @results;
}

sub lookup_group_net
{
  my @results;

  foreach my $m ( listnetgr ( $_[0] ) )
  {
    push @results, $_ foreach lookup_range ( $m->{host}, $m->{host} );
  }

  return @results;
}

sub locate_group_dsh
{
  -f "$ENV{HOME}/.dsh/group/$_[0]" &&
     "$ENV{HOME}/.dsh/group/$_[0]" || "/etc/dsh/group/$_[0]";
}

sub lookup_group_and_show # show as we go
{
}

sub lookup_all
{
}

sub locate_all
{
}

sub lookup_ranges
{

  map {
    /(!)?(.*)/ && ( ! $_[1] && ! $1 ||
                      $_[1] &&   $1 ) ?
    packup_range ( $2 ) : () } split /,/, $_[0];
}

sub packup_range
{
  if ( $_[0] =~ /^(.*?)(\.\.(.*?))?$/ )
  {
    # Double quotes necessary around subpattern variables
    lookup_range ( "$1", ($3) ? "$3" : "$1" );
  }
  else
  {
    return undef;
  }
}

sub lookup_range_dsh
{
}

sub lookup_range_dns
{
}

sub lookup_range
{
  my @results;

  my @m;
  my @n;

  my @i;

  my $i; # address
  my $x; # address (hexadecimal)

  my $h; # hostname
  my $d = `hostname -d`;

  my $w;

  if ( $_[0] =~ /^(\D+)(\d+)$/ )
  {
    @m = ( $1, $2 );
  }
  else
  {
    return undef;
  }

  if ( $_[1] =~ /^(\D+)(\d+)$/ )
  {
    @n = ( $1, $2 );
  }
  else
  {
    return undef;
  }

  # Prefix has to match string-wise
 
  if (        $m[0] ne        $n[0] )
  {
    return undef;
  }

  # Suffix has to match length-wise

  if ( length $m[1] != length $n[1] )
  {
    return undef;
  }

  @i = @m;
  $w = length $i[1];

  while ( $i[1] <= $n[1] )
  {
    $h = join "", @i;

    my ($name, $aliases, $addrtype, $length, @addrs) = gethostbyname $h;
    $i = join ".", unpack ("C4", $addrs[0]);

    $x = format_ip ( $i );

    if ( "$i" )
    {

#   if ( ! ( $opts{h} || $opts{i} || $opts{x} ) )
#   {
#       print "$h", " ";

#       print "$i", " ";

#       print "$x", " ";
#   }
#   else
#   {
#     if ( $opts{h} )
#     {
#       print "$h", " ";
#     }

#     if ( $opts{i} )
#     {
#       print "$i", " ";
#     }

#     if ( $opts{x} )
#     {
#       print "$x", " ";
#     }
#   }

#       print "\n";

    push @results, { h => $h, i => $i, x => $x };

    }

    $i[1] = sprintf ( "%0${w}d", $i[1] + 1 );
  }

  return @results;
}

sub lookup_range_and_show # show as we go
{
}

# Format IP address in hexadecimal notation.

sub format_ip
{

  join "", map { sprintf ( "%02X", $_ ); } split /\./, $_[0];
}

1;
