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

my $ball = Ball->new;
my $width = 0.2;
my $height = 0.15;
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

while (1) {
  my $oldtime = $time;
  my $now = SDL::get_ticks;

  while (SDL::Events::poll_event($sevent)) {
    my $type = $sevent->type;
    if ($type == SDL_QUIT) {
      exit;

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_LEFT) {
      $ball->acc_h(-1);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_LEFT) {
      $ball->acc_h(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_RIGHT) {
      $ball->acc_h(1);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_RIGHT) {
      $ball->acc_h(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_UP) {
      $ball->acc_v(1);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_UP) {
      $ball->acc_v(0);

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_DOWN) {
      $ball->acc_v(-1);

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_DOWN) {
      $ball->acc_v(0);

    }

  }

  my $old_ball_rect = $ball_rect;

  $ball->time_lapse($oldtime, $now, $height, $width);

  $ball_rect = $ball->get_rect($height, $width);

  SDL::Video::fill_rect
      ( $app,
        $app_rect,
        $black );

  $ball->draw($app, $height, $width);

  SDL::Video::update_rects
      ( $app,
        $old_ball_rect, $ball_rect );

  $time = SDL::get_ticks;
  if (($time - $oldtime) < (1000/$fps)) {
    SDL::delay((1000/$fps) - ($time - $oldtime));
  }
}
