package Wall;
use Moose;
use Util;
use SDL::Rect;

# Position - vertical and horizontal
has pos_v => (is => 'rw', isa => 'Num', default => 0);
has pos_h => (is => 'rw', isa => 'Num', default => 12);

# Width and height
has width => (is => 'rw', isa => 'Num', default => 0.8);
has height => (is => 'rw', isa => 'Num', default => 10);

sub get_rect {
  my ($self, $height, $width) = @_;

  my $inverted_v = ($height - ($self->pos_v + $self->height));

  my $x = Util::m2px( $self->pos_h );
  my $y = Util::m2px( $inverted_v );
  my $h = Util::m2px( $self->height );
  my $w = Util::m2px( $self->width );

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
        255, 0, 0 ); # red
  }
  SDL::Video::fill_rect
      ( $surface,
        $self->get_rect($height, $width),
        $color );
}



1;
