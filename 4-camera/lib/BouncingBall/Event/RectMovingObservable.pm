package BouncingBall::Event::RectMovingObservable;
use Moose::Role;
use MooseX::Types::Moose qw(ArrayRef);

use aliased 'BouncingBall::Event::RectMovingObserver';

has 'rect_moving_listeners' => ( traits => ['Array'],
                                 is => 'ro',
                                 isa => ArrayRef[RectMovingObserver],
                                 default => sub { [] },
                                 handles => { add_rect_moving_listener => 'push' }
                               );



1;
