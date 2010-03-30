package BouncingBall::Event::RectMoved;
use Moose;

has old_rect => ( is => 'ro',
                  isa => 'BouncingBall::Event::Rect',
                  required => 1 );
has new_rect => ( is => 'ro',
                  isa => 'BouncingBall::Event::Rect',
                  required => 1 );

1;
