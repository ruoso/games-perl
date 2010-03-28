package Util;
use strict;
use warnings;
our $DPI = 0.96; # I think there's a sane way to fetch this value
sub m2px { int(((shift) * ($DPI / 0.0254)) + 0.5) }
sub px2m { (shift) / ($DPI / .0254) }

use Collision::2D ':all';
sub collide {
    my ($ball, $wall, $time) = @_;
    my $rect = hash2rect({ x => $wall->pos_h, y => $wall->pos_v,
                           h => $wall->height, w => $wall->width });
    my $circ = hash2circle({ x => $ball->cen_h, y => $ball->cen_v,
                             radius => $ball->radius,
                             xv => $ball->vel_h,
                             yv => $ball->vel_v });
    return dynamic_collision($circ, $rect, interval => $time);
}

1;
