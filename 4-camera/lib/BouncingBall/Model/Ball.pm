package BouncingBall::Model::Ball;
use Moose;

use constant g => 9.8;
use aliased 'BouncingBall::Event::Rect';
use Util;
use SDL::Rect;

with 'BouncingBall::Event::RectMovingObservable';

# how much space does it take
has radius => (is => 'rw', isa => 'Num', default => 0.5);

# Center - vertical and horizontal
has cen_v => (is => 'rw', isa => 'Num', default => 10);
has cen_h => (is => 'rw', isa => 'Num', default => 4);

# Velocty - vertical and horizontal
has vel_v => (is => 'rw', isa => 'Num', default => 0);
has vel_h => (is => 'rw', isa => 'Num', default => 0);

# Current acceleration - vertical and horizontal
# gravity is added later
has acc_v => (is => 'rw', isa => 'Num', default => 0);
has acc_h => (is => 'rw', isa => 'Num', default => 0);

# bounding rect
sub pos_v { $_[0]->cen_v - $_[0]->radius };
sub pos_h { $_[0]->cen_h - $_[0]->radius };
sub width { $_[0]->radius * 2 };
sub height { $_[0]->radius * 2 };

sub time_lapse {
  my ($self, $old_time, $new_time) = @_;
  my $elapsed = ($new_time - $old_time)/1000; # convert to seconds...

  # now simple mechanics...
  $self->vel_h( $self->vel_h + $self->acc_h * $elapsed );
  # and add gravity for vertical velocity.
  $self->vel_v( $self->vel_v + ($self->acc_v - g) * $elapsed );

  # finally get the new position
  $self->cen_v( $self->cen_v + $self->vel_v * $elapsed );
  $self->cen_h( $self->cen_h + $self->vel_h * $elapsed );
}

after qw(cen_v cen_h) => sub {
    my ($self, $newval) = @_;
    if ($newval) {
        $self->fire_rect_moved( undef,
                                Rect->new({ x => $self->pos_h,
                                            y => $self->pos_v,
                                            w => $self->width,
                                            h => $self->height }) );
    }
};

1;
