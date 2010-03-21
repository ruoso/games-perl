#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;

use SDL;
use SDL::Video;
use SDL::App;
use SDL::Events;
use SDL::Event;
use SDL::Time;

use lib 'lib';
use Util;
use Ball;
use Wall;

my $ball = Ball->new;
my $wall = Wall->new;
my $width = 20;
my $height = 15;
my $fps = 60;

my $app = SDL::App->new
  ( -title => 'Bouncing Ball',
    -width => Util::m2px($width),
    -height => Util::m2px($height));

my $black = SDL::Video::map_RGB
  ( $app->format(),
    0, 0, 0 ); # black

my $sevent = SDL::Event->new();
my $time = SDL::get_ticks;
my $app_rect = SDL::Rect->new(0, 0, $app->w, $app->h);
my $ball_rect = $ball->get_rect($height, $width);

# let's draw the wall for the first time.
$wall->draw($app, $height, $width);
SDL::Video::update_rects
  ( $app,
    $wall->get_rect($height, $width) );

while (1) {
  my $oldtime = $time;
  my $now = SDL::get_ticks;

  while (SDL::Events::poll_event($sevent)) {
    my $type = $sevent->type;
    if ($type == SDL_QUIT) {
      exit;

    } elsif ($type == SDL_KEYDOWN &&
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

    }

  }

  my $old_ball_rect = $ball_rect;

  $ball->time_lapse($oldtime, $now, $height, $width);

  my $frame_elapsed_time = ($now - $oldtime)/1000;
  if (my $coll = Util::collide($ball, $wall, $frame_elapsed_time)) {
      # need to place the ball in the result after the bounce given
      # the time elapsed after the collision.
      my $collision_remaining_time = $frame_elapsed_time - $coll->time;
      my $movement_after_collision_h = $ball->vel_h * $collision_remaining_time;
      my $movement_after_collision_v = $ball->vel_v * $collision_remaining_time;
      if ($coll->axis eq 'x') {
          $ball->cen_h($ball->cen_h + ($movement_after_collision_h * -2));
          $ball->vel_h($ball->vel_h * -1);
      } elsif ($coll->axis eq 'y') {
          $ball->cen_v($ball->cen_v + ($movement_after_collision_v * -2));
          $ball->vel_v($ball->vel_v * -1);
      } elsif (ref $coll->axis eq 'ARRAY') {
          my ($xv, $yv) = @{$coll->bounce_vector};
          $ball->cen_h($ball->cen_h + ($movement_after_collision_h * -1) +
                       ($xv * $collision_remaining_time));
          $ball->vel_h($xv);
          $ball->cen_v($ball->cen_v + ($movement_after_collision_v * -1) +
                       ($yv * $collision_remaining_time));
          $ball->vel_v($yv);
      } else {
          warn 'BAD BALL!';
          $ball = Ball->new;
      }
  }

  $ball_rect = $ball->get_rect($height, $width);

  SDL::Video::fill_rect
      ( $app,
        $app_rect,
        $black );

  $ball->draw($app, $height, $width);
  $wall->draw($app, $height, $width);

  SDL::Video::update_rects
      ( $app,
        $old_ball_rect, $ball_rect );

  $time = SDL::get_ticks;
  if (($time - $oldtime) < (1000/$fps)) {
    SDL::delay((1000/$fps) - ($time - $oldtime));
  }
}
