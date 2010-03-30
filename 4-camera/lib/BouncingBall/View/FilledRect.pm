package BouncingBall::View::FilledRect;
use Moose;
use SDL::Video ':all';
use SDL::Surface;

with 'BouncingBall::Event::RectMovingObserver';

has x         => ( is => 'rw',
                   default => 0 );
has y         => ( is => 'rw',
                   default => 0 );
has w         => ( is => 'rw',
                   default => 0 );
has h         => ( is => 'rw',
                   default => 0 );
has color     => ( is => 'rw',
                   default => 0 );
has rect_obj  => ( is => 'rw' );
has surface   => ( is => 'rw' );
has color_obj => ( is => 'rw' );
has camera    => ( is => 'rw',
                   required => 1 );
has main      => ( is => 'rw',
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
          $self->camera->m2px($self->w),
          $self->camera->m2px($self->h),
          $self->main->depth,
          0, 0, 0, 255 ) );
}

sub _init_color_object {
    my ($self) = @_;
    $self->color_obj
      ( SDL::Video::map_RGB
        ( $self->main->surface->format,
          0xFF0000 & $self->color,
          0x00FF00 & $self->color,
          0x0000FF & $self->color ));
}

sub _init_rect {
    my ($self) = @_;
    $self->rect_obj
      ( SDL::Rect->new
        ( 0, 0,
          $self->camera->m2px($self->w),
          $self->camera->m2px($self->h) ) );
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

after qw(w h) => sub {
    my ($self, $newval) = @_;
    if ($newval) {
        $self->_init_surface;
        $self->_init_rect;
        $self->_fill_rect;
    }
    return $newval;
};

sub draw {
    my ($self) = @_;
    SDL::Video::blit_surface
        ( $self->surface, $self->rect_obj,
          $self->main->surface,
          SDL::Rect->new
          ( $self->camera->translate( $self->x, $self->y ),
            $self->rect_obj->w, $self->rect_obj->h ) );
}

sub rect_moved {
    my ($self, $ev) = @_;
    $self->$_($ev->$_) for qw(x y w h);
}

1;
