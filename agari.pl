#!/usr/bin/env perl

## PART OF libtenhou

# agari.pl - is a hand "complete" (agari)?
#
# 2014-04-19  bps

use strict;
use warnings;

# take compound suit number and verify whether all of its tiles match up
sub is_mentsu($) {
    my $m = shift; # meld value
    my ($a, $b, $c) = ($m&7, 0, 0);

    # first tile (1man/pin/sou)
    if($a == 1 || $a == 4)  { $b = $c = 1; } # if there are 1 or 4 1man/pin/sou
    elsif($a == 2)          { $b = $c = 2; } # if there are 2

    for(1..6) {
        $m >>= 3; $a = ($m&7)-$b; # next tile; $a = #tile - $b
        # this is where it gets clever;
        # if there were 1 of the previous tile, then it must be part of a chi,
        # so there can't be fewer than 1 of this next tile (as $b would be 1,
        # 0-1=-1) -- as such if there is less then the tiles do not make full
        # melds
        return 0 if($a < 0);

        # of course, this can't go forever
        # making $b $c and $c 0 means it'll work on 3 tiles
        $b = $c; $c = 0;

        # note it adds to $b and $c so the effects can stack
        if($a == 1 || $a == 4)  { $b += 1; $c += 1; }
        elsif($a == 2)          { $b += 2; $c += 2; }
    }

    # second from last tile, but it's different because it's the edge; you
    # can't have a higher chi than 789
    $m >>= 3; $a = ($m&7)-$b;
    # should tiles match up correctly, $a should be 0 (3 counts too, since it's a pon)
    return 0 if($a != 0 && $a != 3);
    # last tile
    $m >>= 3; $a = ($m&7)-$c;
    # must match up or be pon, etc.
    return ($a == 0 || $a == 3);
}

# is pair?
sub is_atama_mentsu($$) {
    my ($nn, $m) = @_; # ??

    if($nn == 0) {
        # if there are more than 2 tile x and tiles other than tile x match up
        return 1 if(($m&(7<< 6)) >= (2<< 6) && is_mentsu($m-(2<< 6))); # 3
        return 1 if(($m&(7<<15)) >= (2<<15) && is_mentsu($m-(2<<15))); # 6
        return 1 if(($m&(7<<24)) >= (2<<24) && is_mentsu($m-(2<<24))); # 9
    } elsif($nn == 1) {
        return 1 if(($m&(7<< 3)) >= (2<< 3) && is_mentsu($m-(2<< 3))); # 2
        return 1 if(($m&(7<<12)) >= (2<<12) && is_mentsu($m-(2<<12))); # 5
        return 1 if(($m&(7<<21)) >= (2<<21) && is_mentsu($m-(2<<21))); # 8
    } elsif($nn == 2) {
        return 1 if(($m&(7<< 0)) >= (2<< 0) && is_mentsu($m-(2<< 0))); # 1
        return 1 if(($m&(7<< 9)) >= (2<< 9) && is_mentsu($m-(2<< 9))); # 4
        return 1 if(($m&(7<<18)) >= (2<<18) && is_mentsu($m-(2<<18))); # 7
    }

    return 0;
}

# create compound suit number from array of tiles by suit (size 34)
sub cc2m($$) {
    my @c = @_;
    my $d = pop @c;
    return if(@c != 34); # in theory this should never happen
    return  ($c[$d+0]<< 0)|($c[$d+1]<< 3)|($c[$d+2]<< 6)|
            ($c[$d+3]<< 9)|($c[$d+4]<<12)|($c[$d+5]<<15)|
            ($c[$d+6]<<18)|($c[$d+7]<<21)|($c[$d+8]<<24);
}

# this method of hand storage is so much better than (122,34,...)
# basically, all 34 tile types are elements of an array, with values 0-4
# meaning 0-4 tiles in the hand; nice and simple. so if c[0] is 4, it means
# there are 4 1man tiles
#
# agari = complete hand
sub is_agari(@) {
    my @c = @_;
    return if(@c != 34); # 34 tiles

    my $j = (1<<$c[27])|(1<<$c[28])|(1<<$c[29])|(1<<$c[30])| # ESWN
            (1<<$c[31])|(1<<$c[32])|(1<<$c[33]); # haku, hatsu, chun

    # 4 of an honor
    return 0 if($j >= 0x10);

    # 国士無双/kokushi # 14 tiles only
    return 1 if((($j&3) == 2) && # must have all honors
            # 1 of every terminal plus another terminal # (1*1*1*...*2*1*1)=2
           ($c[0] *$c[8] *$c[9] *$c[17]*$c[18]*$c[26]*$c[27]*
            $c[28]*$c[29]*$c[30]*$c[31]*$c[32]*$c[33] == 2));
    
    # 1 or more stray honors
    return 0 if($j&2);

    # 七対子/chiitoitsu # 14 tiles only
    return 1 if(!($j&10) && # even number of honors (or 0)
            # 7 pairs of tiles (no duplicates)
           (($c[ 0]==2)+($c[ 1]==2)+($c[ 2]==2)+($c[ 3]==2)+($c[ 4]==2)+
            ($c[ 5]==2)+($c[ 6]==2)+($c[ 7]==2)+($c[ 8]==2)+($c[ 9]==2)+
            ($c[10]==2)+($c[11]==2)+($c[12]==2)+($c[13]==2)+($c[14]==2)+
            ($c[15]==2)+($c[16]==2)+($c[17]==2)+($c[18]==2)+($c[19]==2)+
            ($c[20]==2)+($c[21]==2)+($c[22]==2)+($c[23]==2)+($c[24]==2)+
            ($c[25]==2)+($c[26]==2)+($c[27]==2)+($c[28]==2)+($c[29]==2)+
            ($c[30]==2)+($c[31]==2)+($c[32]==2)+($c[33]==2)) == 7);

    # 147m, 258m, 369m
    my ($n00,$n01,$n02)=($c[ 0]+$c[ 3]+$c[ 6], $c[ 1]+$c[ 4]+$c[ 7], $c[ 2]+$c[ 5]+$c[ 8]);
    # 147p, 258p, 369s
    my ($n10,$n11,$n12)=($c[ 9]+$c[12]+$c[15], $c[10]+$c[13]+$c[16], $c[11]+$c[14]+$c[17]);
    # 147s, 258s, 369s
    my ($n20,$n21,$n22)=($c[18]+$c[21]+$c[24], $c[19]+$c[22]+$c[25], $c[20]+$c[23]+$c[26]);

    # number of man tiles
    my $n0 = ($n00+$n01+$n02)%3; # (total man)%3
    # neither grouped nor in pair
    return 0 if($n0 == 1);
    # number of  pin tiles
    my $n1 = ($n10+$n11+$n12)%3; # (total pin)%3
    # neither grouped nor in pair
    return 0 if($n1 == 1);
    # number of sou tiles
    my $n2 = ($n20+$n21+$n22)%3; # (total sou)%3
    # neither grouped nor in pair
    return 0 if($n2 == 1);

    # no pairs
    return 0 if(($n0==2)+($n1==2)+($n2==2)+ # regular
            ($c[27]==2)+($c[28]==2)+($c[29]==2)+($c[30]==2)+ # winds
            ($c[31]==2)+($c[32]==2)+($c[33]==2) != 1); # honors

    # this is rather strange
    # $nn0-2 = pair location by way of bit voodoo:
    # this is annoying to explain, so instead just imagine the following:
    # pair of 4m; pair of 4m; pair of 6m -- refer to is_atama_mentsu
    # $m0-2 = man/pin/sou tile configuration packed into one number
    my ($nn0, $m0) = (($n00*1+$n01*2)%3, cc2m(@c, 0));
    my ($nn1, $m1) = (($n10*1+$n11*2)%3, cc2m(@c, 9));
    my ($nn2, $m2) = (($n20*1+$n21*2)%3, cc2m(@c,18));

    # general hands

    return !($n0|$nn0|$n1|$nn1|$n2|$nn2) && # no excess tiles
            is_mentsu($m0) && is_mentsu($m1) && is_mentsu($m2) # all matching
            if($j&4); # if there's a pair of honors

    return !($n1|$nn1|$n2|$nn2) && # no excess pin/sou tiles
            is_mentsu($m1) && # matching pin tiles
            is_mentsu($m2) && # matching sou tiles
            is_atama_mentsu($nn0, $m0) # matching man tiles + man pair
            if($n0 == 2); # if there's a man pair

    return !($n2|$nn2|$n0|$nn0) && # no excess sou/man tiles
            is_mentsu($m2) && # matching sou tiles
            is_mentsu($m0) && # matching man tiles
            is_atama_mentsu($nn1, $m1) # matching pin tiles + pin pair
            if($n1 == 2); # if there's a pin pair

    return !($n0|$nn0|$n1|$nn1) && # no excess man/pin tiles
            is_mentsu($m0) && # matching man tiles
            is_mentsu($m1) && # matching pin tiles
            is_atama_mentsu($nn2, $m2) # matching sou tiles + sou pair
            if($n2 == 2); # if there's a sou pair

    return 0;
}

########## agari1001.js
########## http://tenhou.net/2/agari1001.js
