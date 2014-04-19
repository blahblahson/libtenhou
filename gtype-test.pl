#!/usr/bin/env perl

# First created: Tue 04 Jun 2013 14:22:35 AM UTC
# Last updated: Tue 11 Jun 2013 02:54:05 AM UTC
# bps
#
# gtype-test.pl -- test whether the gtype.pl library works properly
# 
# this program just reads stdin and does the obvious, as you can see for
# yourself below

require "gtype.pl";

for $i (<STDIN>) {
    $i =~ s/\n//g;
    print "$i -> ".str2gtype($i)." -> ".gtype2str(str2gtype($i))."\n";
}
