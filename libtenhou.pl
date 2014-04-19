#!/usr/bin/env perl

## libtenhou 1.0
#
# libtenhou is a perl library for the popular online mahjong server Tenhou
# (tenhou.net). Most of it consists of support functions for interacting with
# Tenhou's server, or hand analysis functions based on original Tenhou code.
# For more information, see README and tenhoudoc.txt (not shipped with this).

# libtenhou.pl - require this to get all features of libtenhou at once
#
# 2014-04-19  bps

use strict;
use warnings;

require "auth.pl";
require "util.pl";
require "shanten.pl";
require "agari.pl";
require "agaripattern.pl";
require "tehai.pl";
require "gtype.pl"; # note gtype-test.pl should never be included like this
