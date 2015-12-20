package Racktk::Byte;

# prefix, unprefix, commify, and total_size

use strict;

my %si_prefix_hash = (1=>k, 2=>M, 3=>G, 4=>T, 5=>P, 6=>E, 7=>Z, 8=>Y);
my %reversed_si_prefix_hash = reverse %si_prefix_hash;

sub prefix {
  my $n = shift;
  my $i = 0;
  $i++ while($n >= 1024 ** ($i + 1));
  return ($n / 1024 ** $i, $si_prefix_hash{$i});
}

sub unprefix {
  my $si_prefix_list = join "", keys %reversed_si_prefix_hash;

  $_ = shift;
  /^(\d+)([$si_prefix_list]?)$/;

  if($1) {
    if($2) {
      return $1 * 1024 ** $reversed_si_prefix_hash{$2};
    } else {
      return $1;
    }
  } else {
    return undef;
  }
}

sub commify {
  my $n = shift;
  1 while ($n =~ s/^([+-]?\d+)(\d{3})/$1,$2/);
  return $n;
}

sub total_size {
  my $size = 0;

  foreach(@_) {
    if(-e) {
      if(-d) {
        push @_, glob "$_/*";
      }

      $size += -s;
    }
  }

  return $size;
}


1;
