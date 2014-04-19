#!/usr/bin/env perl

## PART OF libtenhou

# shanten.pl - calculate minimum shanten given a hand and a tile to throw
# usage: shanten(34, c-type array);  OR  shanten(136, a-type array);
# return: shanten value; 0 = tenpai; -1 = agari
#
# 2009-07-24  bps

use strict;
use warnings;
use POSIX qw(floor);

sub run($);

my $n_eval = 0;

# input
my @c = (0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0);

# status
my $n_mentsu    = 0;
my $n_tatsu     = 0;
my $n_toitsu    = 0;
my $n_jidahai   = 0; # １３枚にしてから少なくとも打牌しなければならない字牌の数 -> これより向聴数は下がらない
my $f_n4        = 0; # 27bitを数牌、1bitを字牌で使用
my $f_koritsu   = 0; # 孤立牌

# final result
my $min_shanten = 8;

sub updateResult {
    my $ret_shanten = 8 - $n_mentsu*2 - $n_tatsu - $n_toitsu;
    my $n_mentsu_kouho = $n_mentsu + $n_tatsu;
    if($n_toitsu) {
        $n_mentsu_kouho += $n_toitsu-1;
    }
    elsif($f_n4 && $f_koritsu) {
        $ret_shanten++ if(($f_n4|$f_koritsu)==$f_n4); # 対子を作成できる孤立牌が無い
    }
    $ret_shanten += ($n_mentsu_kouho-4) if($n_mentsu_kouho > 4);
    $ret_shanten = $n_jidahai if($ret_shanten!=-1 && $ret_shanten<$n_jidahai);
    $min_shanten = $ret_shanten if($ret_shanten < $min_shanten);
}

sub init($@) {
    my ($n, @a) = @_;
    @c = @a; # assign internal hand to given hand

    $n_eval = 0;

    # status
    $n_mentsu    = 0;
    $n_tatsu     = 0;
    $n_toitsu    = 0;
    $n_jidahai   = 0; # １３枚にしてから少なくとも打牌しなければならない字牌の数 -> これより向聴数は下がらない
    $f_n4        = 0; # 27bitを数牌、1bitを字牌で使用
    $f_koritsu   = 0; # 孤立牌

    # final result
    $min_shanten = 8;

    if($n == 136) {
        for($n = 0; $n < 136; ++$n) {
            ++$c[$n>>2] if($a[$n]);
        }
    }
    elsif($n == 34) {
        for($n = 0; $n < 34; ++$n) {
            $c[$n] = $a[$n];
        }
    }
    else {
        for($n -= 1; $n >= 0; --$n) {
            $c[$a[$n]>>2]++;
        }
    }
}

# count number of tiles in @c
sub count34 {
    my $ret = 0;
    $ret += $_ for(@c);
    return $ret;
}

# ankou = concealed koutsu (i.e. 333p)
sub i_ankou($)   { $c[shift] -= 3; ++$n_mentsu; }
sub d_ankou($)   { $c[shift] += 3; --$n_mentsu; }

# toitsu = pair
sub i_toitsu($)  { $c[shift] -= 2; ++$n_toitsu; }
sub d_toitsu($)  { $c[shift] += 2; --$n_toitsu; }

# shuntsu = e.g. 123p
sub i_shuntsu($) { my $k=shift; $c[$k]--; $c[$k+1]--; $c[$k+2]--; ++$n_mentsu;}
sub d_shuntsu($) { my $k=shift; $c[$k]++; $c[$k+1]++; $c[$k+2]++; --$n_mentsu;}

# tatsu = 1 away from shuntsu, e.g. 35p (tatsu) needs 4p for shuntsu
sub i_tatsu_r($) { my $k=shift; $c[$k]--; $c[$k+1]--; ++$n_tatsu; }
sub d_tatsu_r($) { my $k=shift; $c[$k]++; $c[$k+1]++; --$n_tatsu; }
sub i_tatsu_k($) { my $k=shift; $c[$k]--; $c[$k+2]--; ++$n_tatsu; }
sub d_tatsu_k($) { my $k=shift; $c[$k]++; $c[$k+2]++; --$n_tatsu; }

# koritsu = ?
sub i_koritsu($) { my $k=shift; $c[$k]--; $f_koritsu |= (1<<$k); }
sub d_koritsu($) { my $k=shift; $c[$k]++; $f_koritsu &= (~(1<<$k)); }

sub scanChiitoiKokushi {
    my $n13 = # 幺九牌の対子候補の数 # number of yaochuhai there are more than 1 of
        ($c[ 0]>=2)+($c[ 8]>=2)+ # 19m
        ($c[ 9]>=2)+($c[17]>=2)+ # 19p
        ($c[18]>=2)+($c[26]>=2)+ # 19s
        ($c[27]>=2)+($c[28]>=2)+($c[29]>=2)+($c[30]>=2)+ # 1234z
        ($c[31]>=2)+($c[32]>=2)+($c[33]>=2); # 567z

    my $m13 = # 幺九牌の種類数 # number of yaochuhai there are any of
        ($c[ 0]!=0)+($c[ 8]!=0)+ # 19m
        ($c[ 9]!=0)+($c[17]!=0)+ # 19p
        ($c[18]!=0)+($c[26]!=0)+ # 19s
        ($c[27]!=0)+($c[28]!=0)+($c[29]!=0)+($c[30]!=0)+ # 1234z
        ($c[31]!=0)+($c[32]!=0)+($c[33]!=0); # 567z

    my $n7 = $n13 + # 対子候補の数 # number of non-yaochuhai there are more than 1 of
        ($c[ 1]>=2)+($c[ 2]>=2)+($c[ 3]>=2)+($c[ 4]>=2)+($c[ 5]>=2)+($c[ 6]>=2)+($c[ 7]>=2)+
        ($c[10]>=2)+($c[11]>=2)+($c[12]>=2)+($c[13]>=2)+($c[14]>=2)+($c[15]>=2)+($c[16]>=2)+
        ($c[19]>=2)+($c[20]>=2)+($c[21]>=2)+($c[22]>=2)+($c[23]>=2)+($c[24]>=2)+($c[25]>=2);

    my $m7 = $m13 + # 牌の種類数 # number of non-yaochuhai there are any of
        ($c[ 1]!=0)+($c[ 2]!=0)+($c[ 3]!=0)+($c[ 4]!=0)+($c[ 5]!=0)+($c[ 6]!=0)+($c[ 7]!=0)+
        ($c[10]!=0)+($c[11]!=0)+($c[12]!=0)+($c[13]!=0)+($c[14]!=0)+($c[15]!=0)+($c[16]!=0)+
        ($c[19]!=0)+($c[20]!=0)+($c[21]!=0)+($c[22]!=0)+($c[23]!=0)+($c[24]!=0)+($c[25]!=0);

    # 七対子 # chiitoitsu
    my $ret_shanten = 6-$n7+($m7<7?7-$m7:0);
    $min_shanten = $ret_shanten if($ret_shanten < $min_shanten);

    # 国士無双 # kokushi musou
    $ret_shanten = 13-$m13-($n13?1:0);
    $min_shanten = $ret_shanten if($ret_shanten < $min_shanten);
}

sub removeJihai ($) { # jihai = characters
    my $nc = shift;
    my $j_n4 = 0; # 7bitを字牌で使用 # 7bit is used with character tiles (?)
    my $j_koritsu = 0; # 孤立牌 # isolated tile
    my $i;

    for($i=27; $i<34; ++$i) {
        if($c[$i] == 4) { $n_mentsu++; $j_n4|=(1<<($i-27)); $j_koritsu|=(1<<($i-27)); $n_jidahai++; }
        elsif($c[$i] == 3) { $n_mentsu++; }
        elsif($c[$i] == 2) { $n_toitsu++; }
        elsif($c[$i] == 1) { $j_koritsu|=(1<<($i-27)); }
    }
    
    $n_jidahai-- if($n_jidahai && ($nc%3)==2);

    if($j_koritsu) { # 孤立牌が存在する # ?
        $f_koritsu|=(1<<27);
        $f_n4|=(1<<27) if(($j_n4|$j_koritsu)==$j_n4); # 対子を作成できる孤立牌が無い # ?
    }
}

sub removeJihaiSanma19 ($) {
    my $nc = shift;
    my $j_n4 = 0; # 7+9bitを字牌で使用 # ?
    my $j_koritsu = 0; # 孤立牌 # isolated tile
    my $i;

    for($i=27; $i<34; $i++) {
        if($c[$i] == 4) { $n_mentsu++; $j_n4|=(1<<($i-18)); $j_koritsu|=(1<<($i-18)); $n_jidahai++; }
        elsif($c[$i] == 3) { $n_mentsu++; }
        elsif($c[$i] == 2) { $n_toitsu++; }
        elsif($c[$i] == 1) { $j_koritsu|=(1<<($i-18)); }
    }

    for($i=0; $i<9; $i+=8) {
        if($c[$i] == 4) { $n_mentsu++; $j_n4|=(1<<$i); $j_koritsu|=(1<<$i); $n_jidahai++; }
        elsif($c[$i] == 3) { $n_mentsu++; }
        elsif($c[$i] == 2) { $n_toitsu++; }
        elsif($c[$i] == 1) { $j_koritsu|=(1<<$i); }
    }

    $n_jidahai-- if($n_jidahai && ($nc%3)==2);

    if($j_koritsu) { # 孤立牌が存在する # ?
        $f_koritsu|=(1<<27);
        $f_n4|=(1<<27) if(($j_n4|$j_koritsu)==$j_n4); # 対子を作成できる孤立牌が無い # ?
    }
}

sub scanNormal ($) {
    my $init_mentsu = shift;
    $f_n4 |= # 孤立しても対子(雀頭)になれない数牌 # ?
        (($c[ 0]==4)<< 0)|(($c[ 1]==4)<< 1)|(($c[ 2]==4)<< 2)|(($c[ 3]==4)<< 3)|(($c[ 4]==4)<< 4)|
        (($c[ 5]==4)<< 5)|(($c[ 6]==4)<< 6)|(($c[ 7]==4)<< 7)|(($c[ 8]==4)<< 8)|(($c[ 9]==4)<< 9)|
        (($c[10]==4)<<10)|(($c[11]==4)<<11)|(($c[12]==4)<<12)|(($c[13]==4)<<13)|(($c[14]==4)<<14)|
        (($c[15]==4)<<15)|(($c[16]==4)<<16)|(($c[17]==4)<<17)|(($c[18]==4)<<18)|(($c[19]==4)<<19)|
        (($c[20]==4)<<20)|(($c[21]==4)<<21)|(($c[22]==4)<<22)|(($c[23]==4)<<23)|(($c[24]==4)<<24)|
        (($c[25]==4)<<25)|(($c[26]==4)<<26);
    $n_mentsu+=$init_mentsu;
    run(0);
}

sub run ($) { # ネストは高々１４回
    my $depth = shift;
    $n_eval++;
    return if($min_shanten == -1); # 和了は１つ見つければよい

    for(; $depth < 27 && !$c[$depth]; $depth++) { }
    return updateResult if($depth==27);

    my $i = $depth;
    $i -= 9 if($i>8);
    $i -= 9 if($i>8); # mod_9_in_27

    if($c[$depth] == 4) {
        # 暗刻＋順子|搭子|孤立
        i_ankou($depth);
        if($i<7 && $c[$depth+2]){
            if($c[$depth+1]) { i_shuntsu($depth); run($depth+1); d_shuntsu($depth); } # 順子
            i_tatsu_k($depth); run($depth+1); d_tatsu_k($depth); # 嵌張搭子
        }

        if($i<8 && $c[$depth+1]) {
            i_tatsu_r($depth); run($depth+1); d_tatsu_r($depth); # 両面搭子
        }

        # 孤立
        i_koritsu($depth); run($depth+1); d_koritsu($depth);

        d_ankou($depth);

        # 対子＋順子系 # 孤立が出てるか？ # 対子＋対子は不可
        i_toitsu($depth);
        if($i<7 && $c[$depth+2]){
            if($c[$depth+1]) { i_shuntsu($depth); run($depth); d_shuntsu($depth); } # 順子＋他
            i_tatsu_k($depth); run($depth+1); d_tatsu_k($depth); # 搭子は２つ以上取る必要は無い -> 対子２つでも同じ
        }

        if($i<8 && $c[$depth+1]) { i_tatsu_r($depth); run($depth+1); d_tatsu_r($depth); }
        d_toitsu($depth);
    }
    elsif($c[$depth] == 3) {
        # 暗刻のみ
        i_ankou($depth); run($depth+1); d_ankou($depth);

        # 対子＋順子|搭子
        i_toitsu($depth);
        if($i<7 && $c[$depth+1] && $c[$depth+2]){
            i_shuntsu($depth); run($depth+1); d_shuntsu($depth); # 順子
        }
        else { # 順子が取れれば搭子はその上でよい
            if($i<7 && $c[$depth+2]) { i_tatsu_k($depth); run($depth+1); d_tatsu_k($depth); } # 嵌張搭子は２つ以上取る必要は無い -> 対子２つでも同じ
            if($i<8 && $c[$depth+1]) { i_tatsu_r($depth); run($depth+1); d_tatsu_r($depth); } # 両面搭子
        }

        d_toitsu($depth);
        # 順子系
        if($i<7 && $c[$depth+2]>=2 && $c[$depth+1]>=2) { i_shuntsu($depth); i_shuntsu($depth); run($depth); d_shuntsu($depth); d_shuntsu($depth); } # 順子＋他
    }
    elsif($c[$depth] == 2) {
        # 対子のみ
        i_toitsu($depth); run($depth+1); d_toitsu($depth);
        # 順子系
        if($i<7 && $c[$depth+2] && $c[$depth+1]) { i_shuntsu($depth); run($depth); d_shuntsu($depth); } # 順子＋他
    }
    elsif($c[$depth] == 1) {
        # 孤立牌は２つ以上取る必要は無い -> 対子のほうが向聴数は下がる -> ３枚 -> 対子＋孤立は対子から取る
        # 孤立牌は合計８枚以上取る必要は無い
        if($i<6 && $c[$depth+1]==1 && $c[$depth+2] && $c[$depth+3]!=4) { # 延べ単
            i_shuntsu($depth), run($depth+2), d_shuntsu($depth); # 順子＋他
        }
        else{
            #if (n_koritsu<8) e.i_koritsu(depth), e.Run(depth+1), e.d_koritsu(depth);
            i_koritsu($depth); run($depth+1); d_koritsu($depth);
            # 順子系
            if($i<7 && $c[$depth+2]) {
                if($c[$depth+1]) { i_shuntsu($depth); run($depth+1); d_shuntsu($depth); } # 順子＋他
                i_tatsu_k($depth); run($depth+1); d_tatsu_k($depth); # 搭子は２つ以上取る必要は無い -> 対子２つでも同じ
            }
            if($i<8 && $c[$depth+1]) { i_tatsu_r($depth); run($depth+1); d_tatsu_r($depth); }
        }
    }
}

sub shanten ($@) {
    my ($n, @a) = @_;
    init($n, @a);

    my $nc = count34();
    return -2 if($nc > 14); # ネスト検査が爆発する

    my $init_mentsu = floor((14-$nc)/3); # 副露面子を逆算
    scanChiitoiKokushi($nc) if($nc >= 13); # １３枚より下の手牌は評価できない
    removeJihai($nc);
    scanNormal($init_mentsu);
    return $min_shanten;
}
