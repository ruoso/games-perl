package Ball;
use Moose;

use constant g => 1.5;
use Util;
use SDL::Rect;

# how much space does it take
has radius => (is => 'rw', isa => 'Num', default => 0.005);

# Position - vertical and horizontal
has pos_v => (is => 'rw', isa => 'Num', default => 0.1);
has pos_h => (is => 'rw', isa => 'Num', default => 0.04);

# Velocty - vertical and horizontal
has vel_v => (is => 'rw', isa => 'Num', default => 0);
has vel_h => (is => 'rw', isa => 'Num', default => 0);

# Current acceleration - vertical and horizontal
# gravity is added later
has acc_v => (is => 'rw', isa => 'Num', default => 0);
has acc_h => (is => 'rw', isa => 'Num', default => 0);

sub time_lapse {
  my ($self, $old_time, $new_time, $height, $width) = @_;
  my $elapsed = ($new_time - $old_time)/1000; # convert to seconds...

  # now simple mechanics...
  $self->vel_h( $self->vel_h + $self->acc_h * $elapsed );
  # and add gravity for vertical velocity.
  $self->vel_v( $self->vel_v + ($self->acc_v - g) * $elapsed );

  # finally get the new position
  $self->pos_v( $self->pos_v + $self->vel_v * $elapsed );
  $self->pos_h( $self->pos_h + $self->vel_h * $elapsed );

  # this ball is supposed to bounce, so let's check $width and $height
  # if we're out of bounds, we assume a 100% efficient bounce.
  if ($self->pos_v < 0) {
    $self->pos_v($self->pos_v * -1);
    $self->vel_v($self->vel_v * -1);
  } elsif ($self->pos_v > $height) {
    $self->pos_v($height - ($self->pos_v - $height));
    $self->vel_v($self->vel_v * -1);
  }

  if ($self->pos_h < 0) {
    $self->pos_h($self->pos_h * -1);
    $self->vel_h($self->vel_h * -1);
  } elsif ($self->pos_h > $width) {
    $self->pos_h($width - ($self->pos_h - $width));
    $self->vel_h($self->vel_h * -1);
  }


}

sub get_rect {
  my ($self, $height, $width) = @_;

  my $inverted_v = $height - $self->pos_v;

  my $x = Util::m2px( $self->pos_h - $self->radius );
  my $y = Util::m2px( $inverted_v - $self->radius );
  my $h = Util::m2px( $self->radius * 2 );
  my $w = Util::m2px( $self->radius * 2 );

  my $screen_w = Util::m2px( $width );
  my $screen_h = Util::m2px( $height );

  if ($x < 0) {
    $w += $x;
    $x = 0;
  }

  if ($x + $w > $screen_w) {
    $w -= ($x + $w) - $screen_w;
  }

  if ($y < 0) {
    $h += $y;
    $h = 0;
  }

  if ($y + $h > $screen_h) {
    $h -= ($y + $h) - $screen_h;
  }

  return SDL::Rect->new( $x, $y, $w, $h );
}

my $color;
sub draw {
  my ($self, $surface, $height, $width) = @_;
  unless ($color) {
    $color = SDL::Video::map_RGB
      ( $surface->format(),
        0, 0, 255 ); # blue
  }
  SDL::Video::fill_rect
      ( $surface,
        $self->get_rect($height, $width),
        $color );
}

1;
