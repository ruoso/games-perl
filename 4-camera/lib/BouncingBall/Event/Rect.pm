package BouncingBall::Event::Rect;
use Moose;

has x => ( is => 'ro',
           isa => 'Numeric',
           required => 1 );
has y => ( is => 'ro',
           isa => 'Numeric',
           required => 1 );
has w => ( is => 'ro',
           isa => 'Numeric',
           required => 1 );
has h => ( is => 'ro',
           isa => 'Numeric',
           required => 1 );

1;
