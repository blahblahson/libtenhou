#!/usr/bin/env perl

## PART OF libtenhou

# util.pl - miscellaneous subroutines that are very helpful
# TODO: ideally I can move all things in this to their own file for better
# organisation
#
# 2009-02-21  bps

use strict;
use warnings;
use POSIX qw(floor);


########## a

sub expand_hand($) {
    my $handstr = shift;
    $handstr =~ s/(\d)(\d{0,8})(\d{0,8})(\d{0,8})(\d{0,8})(\d{0,8})(\d{0,8})(\d{8})(m|p|s|z)/$1$9$2$9$3$9$4$9$5$9$6$9$7$9$8$9/g;
    $handstr =~ s/(\d?)(\d?)(\d?)(\d?)(\d?)(\d?)(\d)(\d)(m|p|s|z)/$1$9$2$9$3$9$4$9$5$9$6$9$7$9$8$9/g;
    $handstr =~ s/(m|p|s|z)(m|p|s|z)+/$1/g;
    $handstr =~ s/^[^\d]//g;
    return $handstr;
}

sub reduce_hand($) {
    my $handstr = shift;
    $handstr =~ s/\d(m|p|s|z)(\d\1)*/$&/g;
    $handstr =~ s/(m|p|s|z)([^:])/$2/g;
    $handstr =~ s/://g;
    return $handstr;
}

sub exsort_hand($) {
    my $handstr = shift;
    $handstr =~ s/(\d)(m|p|s|z)/$2$1$1/g;
    $handstr =~ s/00/50/g;
    $handstr = join "", sort(split /,/, $handstr);
    $handstr =~ s/(m|p|s|z)\d(\d)/$2$1/g;
    return $handstr;
}

sub extract34($) {
    my $handstr = shift;
    $handstr =~ s/(\d)m/0$1/g;
    $handstr =~ s/(\d)p/1$1/g;
    $handstr =~ s/(\d)s/2$1/g;
    $handstr =~ s/(\d)z/3$1/g;

    # oh god 81 characters
    my @c=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    for(my $i = 0; $i < length $handstr; $i+=2) {
        my $n = substr $handstr, $i, 2;
        my $k = -1;
        if($n%10)   { $k = 9*floor($n/10)+(($n%10)-1); }
        else        { $k = 9*$n/10+4; } # red5
        return if($c[$k]>4);
        $c[$k]++;
    }
    return @c;
}

sub hai34tostr($) {
    my $hai = shift;
    my $ret = "";
    my $no = ($hai%9)+1;
    my $grp = floor($hai/9);
    $ret .= "$no";
    $ret .= "m" if($grp==0);
    $ret .= "p" if($grp==1);
    $ret .= "s" if($grp==2);
    $ret .= "z" if($grp==3);
    return $ret;
}

sub c136_to_c34 ($) {
    my @c136 = @_;
    my @c = (0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0);
    for(my $i=0; $i<136; $i++) { $c[$i>>2]++ if($c136[$i]); }
    return @c;
}

sub a2c34 (@) {
    my @a = @_;
    my @c =(0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0);
    for my $hai (@a) {
        $c[$hai>>2]++;
    }
    return @c;
}

sub format136 (@) {
    my @hand = sort {$a <=> $b} @_;
    my $str = ""; my $t = "";
    for my $a (@hand) {
        $str .= ":" if(!($str eq "") and !($t eq substr(hai34tostr($a>>2), -1)));
        $t = substr(hai34tostr($a>>2), -1); $str .= hai34tostr($a>>2);
    }
    
    return reduce_hand($str);
}

sub format136_nosort (@) {
    my @hand = @_;
    my $str = ""; my $t = "";
    for my $a (@hand) {
        $str .= ":" if(!($str eq "") and !($t eq substr(hai34tostr($a>>2), -1)));
        $t = substr(hai34tostr($a>>2), -1); $str .= hai34tostr($a>>2);
    }
    
    return reduce_hand($str);
}
