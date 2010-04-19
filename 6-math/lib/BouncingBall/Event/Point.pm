package BouncingBall::Event::Point;
use Moose;

has x => ( is => 'ro',
           isa => 'Num',
           required => 1 );
has y => ( is => 'ro',
           isa => 'Num',
           required => 1 );

1;
