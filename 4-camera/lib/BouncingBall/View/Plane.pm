package BouncingBall::View::Plane;
use Moose;
use SDL::Video ':all';
use SDL::Surface;

with 'BouncingBall::View';
has color     => ( is => 'rw',
                   default => 0 );
has surface   => ( is => 'rw' );
has rect_obj  => ( is => 'rw' );
has color_obj => ( is => 'rw' );
has main      => ( is => 'ro',
                   required => 1 );

sub BUILD {
    my ($self) = @_;
    $self->_init_surface;
    $self->_init_color_object;
    $self->_init_rect;
    $self->_fill_rect;
}

sub _init_surface {
    my ($self) = @_;
    $self->surface
      ( SDL::Surface->new
        ( SDL_SWSURFACE,
          $self->main->width,
          $self->main->height,
          $self->main->depth,
          0, 0, 0, 255 ) );
}

sub _init_color_object {
    my ($self) = @_;
    $self->color_obj
      ( SDL::Video::map_RGB
        ( $self->main->surface->format,
          ((0xFF0000 & $self->color)>>16),
          ((0x00FF00 & $self->color)>>8),
          0x0000FF & $self->color ));
}

sub _init_rect {
    my ($self) = @_;
    $self->rect_obj
      ( SDL::Rect->new
        ( 0, 0,
          $self->main->width,
          $self->main->height ) );
}

sub _fill_rect {
    my ($self) = @_;
    SDL::Video::fill_rect
        ( $self->surface,
          $self->rect_obj,
          $self->color_obj );
}

after 'color' => sub {
    my ($self, $color) = @_;
    if ($color) {
        $self->_init_color_object;
        $self->_fill_rect;
    }
    return $color;
};

sub draw {
    my ($self) = @_;
    SDL::Video::blit_surface
        ( $self->surface, $self->rect_obj,
          $self->main->surface, $self->rect_obj );
}


1;
