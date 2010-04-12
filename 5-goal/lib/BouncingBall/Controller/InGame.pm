package BouncingBall::Controller::InGame;
use Moose;
use MooseX::Types::Moose qw(ArrayRef);

use SDL::Events ':all';
use aliased 'BouncingBall::Model::Ball';
use aliased 'BouncingBall::Model::Wall';
use aliased 'BouncingBall::View';
use aliased 'BouncingBall::View::Plane';
use aliased 'BouncingBall::View::FilledRect';
use aliased 'BouncingBall::View::Camera';
use aliased 'BouncingBall::View::MainSurface';
use aliased 'BouncingBall::Event::Rect';
use aliased 'BouncingBall::Event::Point';

has 'ball' => ( is => 'rw',
                isa => Ball,
                default => sub { Ball->new() } );

has 'goal' => ( is => 'rw',
                isa => Point );

has 'main_surface' => ( is => 'ro',
                        isa => MainSurface,
                        required => 1 );

has 'camera' => ( is => 'ro',
                  isa => Camera );

has 'walls' => ( traits => ['Array'],
                 is => 'rw',
                 isa => ArrayRef[Wall] );
has 'views' => ( traits => ['Array'],
                 is => 'rw',
                 isa => ArrayRef[View] );


sub BUILD {
    my $self = shift;

    my $background = Plane->new({ main => $self->main_surface,
                                  color => 0xFFFFFF });

    my $camera = Camera->new({ pixels_w => $self->main_surface->width,
                               pixels_h => $self->main_surface->height,
                               pointing_x => $self->ball->cen_h,
                               pointing_y => $self->ball->cen_v });
    $self->ball->add_rect_moving_listener($camera);

    my $ball_view = FilledRect->new({ color => 0x0000FF,
                                      camera => $camera,
                                      main => $self->main_surface,
                                      x => $self->ball->pos_h,
                                      y => $self->ball->pos_v,
                                      w => $self->ball->width,
                                      h => $self->ball->height });
    $self->ball->add_rect_moving_listener($ball_view);

    $self->goal(Point->new({ x => 10, y => 12.5 }));
    my $goal_view = FilledRect->new({ color => 0xFFFF00,
                                      camera => $camera,
                                      main => $self->main_surface,
                                      x => $self->goal->x - 0.1,
                                      y => $self->goal->y - 0.1,
                                      w => 0.2,
                                      h => 0.2 });

    $self->views([]);
    push @{$self->views}, $background, $ball_view, $goal_view;

    $self->walls([]);

    # now we need to build four walls, to enclose our ball.
    foreach my $rect ( Rect->new({ x => 0,
                                   y => 0,
                                   w => 20,
                                   h => 1 }), # left wall
                       Rect->new({ x => 0,
                                   y => 0,
                                   h => 20,
                                   w => 1 }), # bottom wall
                       Rect->new({ x => 20,
                                   y => 0,
                                   h => 20,
                                   w => 1 }), # right wall
                       Rect->new({ x => 0,
                                   y => 20,
                                   w => 21,
                                   h => 1 }), # top wal
                       Rect->new({ x => 7,
                                   y => 0,
                                   h => 9,
                                   w => 1 }),
                       Rect->new({ x => 7,
                                   y => 11,
                                   h => 9,
                                   w => 1 }),
                       Rect->new({ x => 12,
                                   y => 0,
                                   h => 9,
                                   w => 1 }),
                       Rect->new({ x => 12,
                                   y => 11,
                                   h => 9,
                                   w => 1 }),
                       Rect->new({ x => 9.2,
                                   y => 11,
                                   h => 1,
                                   w => 1.6 }),
                     ) {

        my $wall_model = Wall->new({ pos_v => $rect->y,
                                     pos_h => $rect->x,
                                     width => $rect->w,
                                     height => $rect->h });

        push @{$self->walls}, $wall_model;

        my $wall_view = FilledRect->new({ color => 0xFF0000,
                                          camera => $camera,
                                          main => $self->main_surface,
                                          x => $rect->x,
                                          y => $rect->y,
                                          w => $rect->w,
                                          h => $rect->h });

        push @{$self->views}, $wall_view;

    }

}

sub handle_sdl_event {
    my ($self, $sevent) = @_;

    my $ball = $self->ball;
    my $type = $sevent->type;

    if ($type == SDL_KEYDOWN &&
        $sevent->key_sym() == SDLK_LEFT) {
        $ball->acc_h(-5);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_LEFT) {
        $ball->acc_h(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_RIGHT) {
        $ball->acc_h(5);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_RIGHT) {
        $ball->acc_h(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_UP) {
        $ball->acc_v(5);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_UP) {
        $ball->acc_v(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_DOWN) {
        $ball->acc_v(-5);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_DOWN) {
        $ball->acc_v(0);

    } else {
        return 0;
    }
    return 1;
}

sub reset_ball {
    my ($self) = @_;
    my $default = Ball->new();
    $self->ball->cen_v($default->cen_v);
    $self->ball->cen_h($default->cen_h);
}

sub handle_frame {
    my ($self, $oldtime, $now) = @_;

    my $frame_elapsed_time = ($now - $oldtime)/1000;
    my $ball = $self->ball;

    foreach my $wall (@{$self->walls}) {
        if (my $coll = collide($ball, $wall, $frame_elapsed_time)) {
            # need to place the ball in the result after the bounce given
            # the time elapsed after the collision.
            my $collision_remaining_time = $frame_elapsed_time - $coll->time;
            my $movement_before_collision_h = $ball->vel_h * ($coll->time - 0.001);
            my $movement_before_collision_v = $ball->vel_v * ($coll->time - 0.001);
            $ball->cen_h($ball->cen_h + $movement_before_collision_h);
            $ball->cen_v($ball->cen_v + $movement_before_collision_v);
            if ($coll->axis eq 'x') {
                $ball->vel_h($ball->vel_h * -1);
            } elsif ($coll->axis eq 'y') {
                $ball->vel_v($ball->vel_v * -1);
            } elsif (ref $coll->axis eq 'ARRAY') {
                my ($xv, $yv) = @{$coll->bounce_vector};
                $ball->vel_h($xv);
                $ball->vel_v($yv);
            } else {
                warn 'BAD BALL!';
                $ball->vel_h($ball->vel_h * -1);
                $ball->vel_v($ball->vel_v * -1);
            }
            return $self->handle_frame($oldtime + ($coll->time*1000), $now);
        }
    }

    if (collide_goal($ball, $self->goal, $frame_elapsed_time)) {
        $self->reset_ball();
    }

    $ball->time_lapse($oldtime, $now);


    foreach my $view (@{$self->views}) {
        my $ret = $view->draw();
    }

    SDL::Video::flip($self->main_surface->surface);

}

use Collision::2D ':all';
sub collide_goal {
    my ($ball, $goal, $time) = @_;
    my $rect = hash2point({ x => $goal->x, y => $goal->y });
    my $circ = hash2circle({ x => $ball->cen_h, y => $ball->cen_v,
                             radius => $ball->radius,
                             xv => $ball->vel_h,
                             yv => $ball->vel_v });
    return dynamic_collision($circ, $rect, interval => $time);
}

sub collide {
    my ($ball, $wall, $time) = @_;
    my $rect = hash2rect({ x => $wall->pos_h, y => $wall->pos_v,
                           h => $wall->height, w => $wall->width });
    my $circ = hash2circle({ x => $ball->cen_h, y => $ball->cen_v,
                             radius => $ball->radius,
                             xv => $ball->vel_h,
                             yv => $ball->vel_v });
    return dynamic_collision($circ, $rect, interval => $time);
}


1;
