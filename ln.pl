#!/usr/bin/env perl

## PART OF libtenhou

# ln.pl - lobby number unpacking/formatting
# TODO: some things may have changed and I have an uncomfortable feeling that
# ln_decode may not always work - check this (2014-04-19)
#
# 2014-04-19  bps

use strict;
use warnings;

# LN data is encoded in base52 for some reason
# this algorithm should take a string like "CQf1D1D6B3B" and spit out an LN
# array (for this, see the tenhoudoc.txt/LN INDEX section)

# I made this diagram to describe decoding a simple LN string; this is what the
# algorithm below does

# take the string...   and split it up every time it switches from character
#       |                |                                       to number
#       |                |     +---------------------+
#       |                |     | +------------------~|~------+
#       |                |     | | +----------------~|~-----~|~--+
#       v                v     | | | +--------------~|~-----~|~-~|~--+
#   CQf1D1D6B3B -> CQf 1 D 1 D 6 B 3 B      etc...   |       |   |   |
#                   |  | | | +----------------+      |       |   |   |
#      base52 decode|  | | +---------------+  |      |       |   |   |
#      +------------+  | | base52 decode   |  |      |       |   |   |
#      |               | +-------------+   |  |      |       |   |   |
#      |               |               |   |  |      |       |   |   |
#      |   add 1 comma |               |   |  |      |       |   |   |
#      v               v               v   v  v      v       v   v   v
#     6271             ,               3   ,  3   ,,,,,,     1  ,,,  1
#
# for every number, 'add' that many commas (,)
# for every string of characters, decode it for base52
# * any empty values, like in ,,,,,,,, are hence zero
# * the ultimate array from this algorithm will but cut short as far as nonzero
#   values go. that is, you won't get an end like ,0 -- only ,x where x > 0. on
#   that basis, you should assume that any undefined LN indexes are 0
sub ln_decode ($) {
    # 52 characters [A-Za-z] for base52 decoding
    my $alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    my @ret; # array to return
    my $ln = shift;

    my $commas = 0; # number of commas to add
    my $acu = 0; # accumulated value
    my $i = 0; # iterator
    while($i < length $ln) {
        #last if length $ln <= $iterator; # do not exceed length
        my $c = substr $ln, $i, 1;

        # stop on -; anything after that is ignored
        last if($c eq '-');

        my $pos = index $alpha, $c;
        if($pos < 0) { # digit (not found)
            # if there is any accumulated value, push it
            push @ret, int($acu) if $acu;
            $acu = 0; # then reset

            # multiply any previous number of commas in case the number of
            # commas ot add is greater than 1 -- then add this
            $commas = $commas*10+int($c);
        }
        else {
            # push the "commas" on
            while(1) {
                # because this is actually pushing 0 values, then the number of
                # 0 values should be 1 less than the number of commas required
                last if $commas <= 1;
                push @ret, 0;
                $commas--;
            } $commas = 0;

            $acu = $acu * 52 + $pos;
        }

        $i++;
    }

    # push any remaining value
    push @ret, $acu;

    return @ret; # and return
}

sub ln_decode_format {
    my $alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    my @ret = ();
    my $ln = shift;

    my $result = ""; # v4
    my $commas = 0; # v5
    my $acu = 0; # v6
    my $t = 1; # v7
    my $iterator = 0; # v8
    while(1) {
        last if length $ln <= $iterator; # do not exceed length
        my $c = substr $ln, $iterator, 1;
        if($c eq '-') {
            #$t = -1;
            #next;
            last;
        }
        
        $t = 1;
        my $pos = index $alpha, $c;
        if($pos < 0) {
            $result .= $acu * $t if $acu;
            $acu = 0;
            $t = 1;
            $commas = $commas * 10 + (ord($c) - 48);
        }
        else {
            # number of commas to add
            while(1) {
                last if $commas <= 0;
                $result .= ',';
                $commas--;
            }
            $commas = 0;
            $acu = $acu * 52 + $pos;
        }

        $iterator++;
    }

    $result .= $acu * $t;
    #push @ret, $result;
    return substr($result, 0, length($result)-1);
    #print "$result\n";
}
