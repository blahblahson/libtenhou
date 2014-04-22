#!/usr/bin/env perl

## PART OF libtenhou

# tehai.pl - refer to tenhoudoc.txt/MELD IDS section and this will make a lot
# more sense convert meld ID to array of format (tile
# dealer,tile1[,tile2,tile3[,tile4]]) for kans/extended kans, the called/added
# tile is the last element nuki is always ($kui,120); tenhou doesn't
# differentiate tiles are stored in order that they would be presented
#
# 2014-04-19  bps

use strict;
use warnings;
use POSIX qw(floor);

sub get_mentsu136($) {
    my $m = shift;
    my $kui = $m&3; # tile dealer

    if($m&(1<<2)) { # syunntsu # chii
        my $t = ($m&0xFC00)>>10;    # 1111110000000000
        my $r = $t%3; # called tile (0, 1 or 2 based on chii set)
        $t = floor($t/3);
        $t = floor($t/7)*9+($t%7);
        $t *= 4; # tile base
        
        my @h =($kui,                       # tile dealer
                $t+4*0+(($m&0x0018)>>3),    # tile 1
                $t+4*1+(($m&0x0060)>>5),    # tile 2
                $t+4*2+(($m&0x0180)>>7));   # tile 3

        # reorganize according to dealer
        unshift @h, splice(@h, 2, 1) if($r==1);
        unshift @h, splice(@h, 3, 1) if($r==2);
        
        return @h;
    }
    elsif($m&(1<<3)) { # koutsu # pon
        my $unused = ($m&0x0060)>>5; # unused tile
        my $t = ($m&0xFE00)>>9;     # 1111111000000000
        my $r = $t%3; # called tile
        $t = floor($t/3);
        $t *= 4;
        my @h = ($kui,$t,$t,$t);

        # set tiles according to the one not used
        if($unused==0) { $h[1]+=1; $h[2]+=2; $h[3]+=3; }
        if($unused==1) { $h[1]+=0; $h[2]+=2; $h[3]+=3; }
        if($unused==2) { $h[1]+=0; $h[2]+=1; $h[3]+=3; }
        if($unused==3) { $h[1]+=0; $h[2]+=1; $h[3]+=2; }

        # reorganize
        unshift @h, splice(@h, 2, 1) if($r==1);
        unshift @h, splice(@h, 3, 1) if($r==2);
        unshift @h, splice(@h, 3, 1) if($kui<3);
        unshift @h, splice(@h, 3, 1) if($kui<2);

        return @h;
    }
    elsif($m&(1<<4)) { # chakan # extended kan
        my $added = ($m&0x0060)>>5; # tile added
        my $t = ($m&0xFE00)>>9;     # 1111111000000000
        my $r = $t%3;
        $t = floor($t/3);
        $t *= 4;
        my @h = ($kui,$t,$t,$t,$added);

        # set tiles according to the one added
        if($added==0) { $h[1]+=1; $h[2]+=2; $h[3]+=3; }
        if($added==1) { $h[1]+=0; $h[2]+=2; $h[3]+=3; }
        if($added==2) { $h[1]+=0; $h[2]+=1; $h[3]+=3; }
        if($added==3) { $h[1]+=0; $h[2]+=1; $h[3]+=2; }

        # reorganize
        unshift @h, splice(@h, 2, 1) if($r==1);
        unshift @h, splice(@h, 3, 1) if($r==2);

        return @h;
    }
    elsif($m&(1<<5)) { # nuki
        return ($kui, 120); # it's always the same
    }
    else { # minnkann, annkann # kan
        my $hai0 = ($m&0xFF00)>>8;
        my $t = floor($hai0/4)*4;
        my @h = ($kui,$t,$t,$t,$hai0);

        if($hai0%4==0) { $h[1]+=1; $h[2]+=2; $h[3]+=3; }
        if($hai0%4==1) { $h[1]+=0; $h[2]+=2; $h[3]+=3; }
        if($hai0%4==2) { $h[1]+=0; $h[2]+=1; $h[3]+=3; }
        if($hai0%4==3) { $h[1]+=0; $h[2]+=1; $h[3]+=2; }
    }
}

########## tehai.js
########## http://tenhou.net/img/tehai.js
