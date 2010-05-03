package BouncingBall::View::MainSurface;
use Moose;
use SDL ':all';
use SDL::Video;# ':all';

has 'surface' => (is => 'rw');
has 'width' => (is => 'ro', default => 800);
has 'height' => (is => 'ro', default => 600);
has 'depth' => (is => 'ro', default => 16);

sub BUILD {
    my ($self) = @_;

    die 'Cannot init ' . SDL::get_error()
      if ( SDL::init( SDL_INIT_VIDEO ) == -1 );

    $self->surface
      ( SDL::Video::set_video_mode
        ( $self->width, $self->height, $self->depth,
          SDL_HWSURFACE | SDL_DOUBLEBUF | SDL_HWACCEL ))
        or die 'Error initializing video.';

    return 1;
}

1;
