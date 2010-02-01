package Util;
use strict;
use warnings;
our $DPI = 96; # I think there's a sane way to fetch this value
sub m2px { int(((shift) * ($DPI / 0.0254)) + 0.5) }
sub px2m { (shift) / ($DPI / .0254) }

1;
