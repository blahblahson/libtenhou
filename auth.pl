#!/usr/bin/env perl

## PART OF libtenhou

# auth.pl - decode the AUTH string for access to tenhou's server (see
# tenhoudoc.txt/AUTHENTICATION for more information on how this works)
#
# 2014-04-19  bps

use strict;
use warnings;

# auth keys
my @tt2 = (63006, 9570, 49216, 45888, 9822, 23121, 59830, 51114, 54831, 4189,
    580, 5203, 42174, 59972, 55457, 59009, 59347, 64456, 8673, 52710, 49975,
    2006, 62677, 3463, 17754, 5357);

# decode it
sub authdecode ($) {
    my $auth = shift;
    my @a = split /-/,$auth;
    return $auth if(@a!=2);
    return $auth if(length($a[0])!=8);
    return $auth if(length($a[1])!=8);
    my $b = int("2".substr($a[0],2,6))%(13-int(substr($a[0],7,1))-1);
    return $a[0]."-".sprintf("%x%x",($tt2[$b*2+0]^hex(substr($a[1],0,4))),
                                    ($tt2[$b*2+1]^hex(substr($a[1],4,4))));
}
