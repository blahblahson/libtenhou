#!/usr/bin/env perl

## PART OF libtenhou

# Creation date: Tue 12 Mar 2013 10:35:48 PM UTC
# Last modified: Mon 17 Jun 2013 03:34:26 PM UTC

# gtype.pl - game type utility functions for translation of game records
#
# this deserves to be its own file because in an ideal world big updates to
# tenhou can be fixed by minor alterations to these functions alone, without
# interfering with the process in the main translation/insertion script

use warnings;
use strict;

# convert a game type string to the internal tenhou game type id
#
# this function is *tremendously* important: it should work fine unless things
# change on tenhou, in which case behaviour is UNDEFINED. for this reason,
# gtypestr_sc MUST be called to ensure a safe conversion
sub str2gtype($) {
    my $str = shift;
    my $gtype = 0 | 0x0001; # multiplayer
    $gtype |= 0x0002 unless($str =~ /赤/); # no red 5s
    $gtype |= 0x0004 unless($str =~ /喰/); # no open tanyao
    $gtype |= 0x0008 if($str =~ /南/); # south
    $gtype |= 0x0010 if($str =~ /三/); # 3man
    $gtype |= 0x0020 if($str =~ /(?:特|琥)/); # upperdan
    $gtype |= 0x0040 if($str =~ /速/); # fast
    $gtype |= 0x0080 if($str =~ /(?:上|銀)/); # dan
    $gtype |= 0x20 | 0x80 if($str =~ /(?:鳳|孔)/); # houou
    $gtype |= 0x0100 if($str =~ /暗/); # tsumokiri (discontinued)
    if($str =~ /祝/) { # shuugi/jansou/whatever modes
        if($str =~ /祝５/) { $gtype |= 0x200 | 0x400; } # chip and jansou mode
        elsif($str =~ /祝２/) { $gtype |= 0x200; } # just chip mode
        elsif($str =~ /祝０/) { $gtype |= 0x400; } # just jansou mode
        else { $gtype |= 0x400; } # this corresponds to 祝０ (I think)
    }
    $gtype |= 0x800 if($str =~ /技/); # tech mode

    return $gtype;

# last reviewed: Mon 03 Jun 2013 02:14:45 AM UTC
# last reviewed: TIMESTAM P
}

# cf. http://tenhou.net/1/script/tenhou.js
sub gt_ISJANS($)   { my $x = shift; return ($x & (0x200|0x400)) != 0; }
sub gt_ISTECH($)   { my $x = shift; return ($x & 0x800) != 0; }
sub gt_ISDAN($)    { my $x = shift; return ($x & (0x200|0x400|0x800)) == 0; }
sub gt_GETTAKU($)  { my $x = shift; return (($x&0x20)>>4) | (($x&0x80)>>7); }
sub gt_GETTAKU2($) {
    my $x = shift;
    return gt_GETTAKU($x)+(gt_ISJANS($x)?4:0)+(gt_ISTECH($x)?8:0);
}

sub gtype2str($) {
    my $gtype = shift;
    my @a = ("般","上","特","鳳","若","銀","琥","孔","技","－","－","－");
    my $str = (($gtype&0x0010) ? "三" : "四").
              $a[gt_GETTAKU2($gtype)].
              (gt_ISTECH($gtype) ? "" : $gtype & 0x8 ? "南" : "東").
              (gt_ISJANS($gtype) ?
                  #"喰赤".
                  ($gtype & 0x4   ? "" : "喰"). # tenhou.js adds these
                  ($gtype & 0x2   ? "" : "赤"). #  indiscriminately...
                  #(($gtype&0x8) ? "" : "速").
                  ($gtype & 0x40  ? "速" : "").
                  (((~$gtype)&0x200) ? "祝０" :($gtype&0x400)? "祝５" : "祝２")
              :
                  ($gtype & 0x4   ? "" : "喰").
                  ($gtype & 0x2   ? "" : "赤").
                  ($gtype & 0x40  ? "速" : "").
                  ($gtype & 0x100 ? "暗" : "").
                  ($gtype & 0x200 ? "祝" : ""));
    return $str;

# last reviewed: Mon 03 Jun 2013 02:25:53 AM UTC
}

# v Mon 03 Jun 2013 02:25:53 AM UTC
# remark: there does seem to be some possible loss of information here. because
# tsuno wants to stop these gametype strings from getting stupidly long, his
# version of gtype2str will assume that, for example, any ISJANS game will be
# with red fives. this isn't actually always the case as far as I can tell,
# e.g.: 四般南喰－祝 vs 四般南喰赤祝 (both of these have occurred). I have
# taken the decision to take each string at face value and assume nothing in
# the reverse direction when computing str2gtype, and then gtype2str should be
# an inverse function of str2gtype up to instances of "－" (which are scattered
# pretty randomly and are not worth(/even possible to be) keeping track of).
# the consequence of this is that maybe some games were played that were e.g.
# red fives, but turn up in the database as not red fives. the rationale behind
# this being OK is simply that tenhou publishes it in the same way. at the end
# of the day the difference between red5/fast/nashi is fairly trivial and my
# database should still concur with the strings that are published (again, up
# to instances of "－").

# another annoying thing is that by this truncation that tenhou does, we never
# know if a game played in a championship lobby that is ISJANS is 祝５ or 祝２
# or (the seemingly never-occurring) 祝０. thus we assume that it is only CHIP
# and not JANS, thereby making it come up as 祝０ always. this can either be
# explained on ranking.pl or another possible workaround is to just filter it
# out post-extraction-from-database. I see no good reason to play with this on
# a gtype level, since there is no way of knowing and this is a justifiably
# neutral way to store it.
# ^ Mon 03 Jun 2013 02:25:53 AM UTC


# game type string sanity check
#
# this function is just as important as str2gtype (if not more important) - it
# will check for a revised game type string format, returning 1 if everything
# is fine, 0 if something is wrong. I don't really have an intelligent way of
# detailing what is wrong with the return value, and the means for checking if
# something is wrong are quite primitive anyway so this function is not
# foolproof. still, we do our best to ensure data integrity
sub gtypestr_sc($) {
    my $str = shift;
    return 0 if($str =~ /[^般上特鳳若銀琥孔技－四三東南赤喰速暗０２５]/);
    return 1;

    # told you it was primitive...

# last reviewed: Mon 03 Jun 2013 02:14:45 AM UTC
# last reviewed: TIMESTAM P
}
