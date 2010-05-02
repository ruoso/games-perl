package BouncingBall::Model::Wall;
use Moose;

# Position - vertical and horizontal
has pos_v => (is => 'rw', isa => 'Num', default => 0);
has pos_h => (is => 'rw', isa => 'Num', default => 12);

# Width and height
has width => (is => 'rw', isa => 'Num', default => 0.8);
has height => (is => 'rw', isa => 'Num', default => 10);


1;
