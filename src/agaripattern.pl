#!/usr/bin/env perl

## PART OF libtenhou

# agaripattern.pl
# TODO: this is incomplete
#
# 2014-04-19  bps

use strict;
use warnings;

my @toitsu34 = (-1,-1,-1,-1,-1,-1,-1); # ??
my @v =({atama34 => -1, mmmm35 => 0},
        {atama34 => -1, mmmm35 => 0},
        {atama34 => -1, mmmm35 => 0},
        {atama34 => -1, mmmm35 => 0}); # ??

sub get_agari_pattern($$) {
    my (@c, $n) = @_;
    return 0 if($n != 34);

    # ?
    my @e_toitsu34 = @toitsu34;
    my @e_v = @v;

    my $j = (1<<$c[27])|(1<<$c[28])|(1<<$c[29])|(1<<$c[30])| # ESWN
            (1<<$c[31])|(1<<$c[32])|(1<<$c[33]); # haku, hatsu, chun

    # 4 of an honor
    return 0 if($j >= 0x10);

    # 国士無双/kokushi # 14 tiles only
    if((($j&3) == 2) && # must have all honors
            # 1 of every terminal plus another terminal # (1*1*1*...*2*1*1)=2
           ($c[0] *$c[8] *$c[9] *$c[17]*$c[18]*$c[26]*$c[27]*
            $c[28]*$c[29]*$c[30]*$c[31]*$c[32]*$c[33] == 2)) {

        # find the pair
        my @a = (0,8,9,17,18,26,27,28,29,30,31,32,33);
        my $i = undef;
        for $i (0..12) { last if($c[$a[$i]] == 2); } # from this loop
        $v[0]{atama34} = $a[$i]; # and store it
        $v[0]{mmmm35} = 0xFFFFFFFF; # set kokushi flag
        return 1;
    }

    # 1 or more stray honors
    return 0 if($j&2);

    my $ok = 0; # ?

    # 七対子/chiitoitsu # 14 tiles only
    if(!($j&10) && # even number of honors (or 0)
            # 7 pairs of tiles (no duplicates)
           (($c[ 0]==2)+($c[ 1]==2)+($c[ 2]==2)+($c[ 3]==2)+($c[ 4]==2)+
            ($c[ 5]==2)+($c[ 6]==2)+($c[ 7]==2)+($c[ 8]==2)+($c[ 9]==2)+
            ($c[10]==2)+($c[11]==2)+($c[12]==2)+($c[13]==2)+($c[14]==2)+
            ($c[15]==2)+($c[16]==2)+($c[17]==2)+($c[18]==2)+($c[19]==2)+
            ($c[20]==2)+($c[21]==2)+($c[22]==2)+($c[23]==2)+($c[24]==2)+
            ($c[25]==2)+($c[26]==2)+($c[27]==2)+($c[28]==2)+($c[29]==2)+
            ($c[30]==2)+($c[31]==2)+($c[32]==2)+($c[33]==2)) == 7) {
        $v[3]{mmmm35} = 0xFFFFFFFF; # set chiitoitsu
        my ($i,$n)=(0,0);

        for $i (0..33) { # for every tile type
            if($c[$i]==2) { # if double
                $e_toitsu34[$n] = $i; # store
                $n += 1; # next slot
            }
        }
        
        $ok = 1; # ? # doesn't return yet?
        # 二盃口へ
    }

    # 147m, 258m, 369m
    my ($n00,$n01,$n02)=($c[ 0]+$c[ 3]+$c[ 6], $c[ 1]+$c[ 4]+$c[ 7], $c[ 2]+$c[ 5]+$c[ 8]);
    # 147p, 258p, 369s
    my ($n10,$n11,$n12)=($c[ 9]+$c[12]+$c[15], $c[10]+$c[13]+$c[16], $c[11]+$c[14]+$c[17]);
    # 147s, 258s, 369s
    my ($n20,$n21,$n22)=($c[18]+$c[21]+$c[24], $c[19]+$c[22]+$c[25], $c[20]+$c[23]+$c[26]);


    # number of man tiles
    my $k0 = ($n00+$n01+$n02)%3; # (total man)%3
    # neither grouped nor in pair
    return $ok if($k0 == 1);
    # number of  pin tiles
    my $k1 = ($n10+$n11+$n12)%3; # (total pin)%3
    # neither grouped nor in pair
    return $ok if($k1 == 1);
    # number of sou tiles
    my $k2 = ($n20+$n21+$n22)%3; # (total sou)%3
    # neither grouped nor in pair
    return $ok if($k2 == 1);

    # no pairs
    return $ok if(($k0==2)+($k1==2)+($k2==2)+ # regular
            ($c[27]==2)+($c[28]==2)+($c[29]==2)+($c[30]==2)+ # winds
            ($c[31]==2)+($c[32]==2)+($c[33]==2) != 1); # honors

    # TODO: finish this funciton
    # this is sort of useless I think
}

########## agaripattern1003.js
########## http://tenhou.net/2/agaripattern1003.js
