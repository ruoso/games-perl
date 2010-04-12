package BouncingBall::Event::Rect;
use Moose;

has x => ( is => 'ro',
           isa => 'Num',
           required => 1 );
has y => ( is => 'ro',
           isa => 'Num',
           required => 1 );
has w => ( is => 'ro',
           isa => 'Num',
           required => 1 );
has h => ( is => 'ro',
           isa => 'Num',
           required => 1 );

1;
