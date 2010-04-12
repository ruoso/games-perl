package BouncingBall::Event::RectMovingObservable;
use Moose::Role;
use MooseX::Types::Moose qw(ArrayRef);

use aliased 'BouncingBall::Event::RectMovingObserver';
use aliased 'BouncingBall::Event::RectMoved';

has 'rect_moving_listeners' => ( traits => ['Array'],
                                 is => 'ro',
                                 isa => ArrayRef[RectMovingObserver],
                                 default => sub { [] },
                                 handles => { add_rect_moving_listener => 'push' } );

sub remove_rect_moving_listener {
    my ($self, $object) = @_;
    my $count = $self->rect_moving_listeners->count;
    my $found;
    for my $i (0..($count-1)) {
        if ($self->rect_moving_listeners->[$i] == $object) {
            $found = $i;
            last;
        }
    }
    if ($found) {
        splice @{$self->rect_moving_listeners}, $found, 1, ();
    }
}

sub fire_rect_moved {
    my ($self, $old_rect, $new_rect) = @_;
    my %args = ( new_rect => $new_rect );
    $args{old_rect} = $old_rect if $old_rect;
    my $ev = RectMoved->new(\%args);
    $_->rect_moved($ev) for @{$self->rect_moving_listeners};
}

1;
