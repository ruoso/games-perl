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

use aliased 'BouncingBall::Controller::InGame';
use aliased 'BouncingBall::View::MainSurface';

SDL::init( SDL_INIT_EVERYTHING );

my $fps = 60;

my $surf = MainSurface->new();

my $sevent = SDL::Event->new();
my $time = SDL::get_ticks;

my $controller = InGame->new({ main_surface => $surf });

while (1) {
    my $oldtime = $time;
    my $now = SDL::get_ticks;

    while (SDL::Events::poll_event($sevent)) {
        my $type = $sevent->type;
        if ($type == SDL_QUIT) {
            exit;
        } elsif ($controller->handle_sdl_event($sevent)) {
            # handled.
        } else {
            # unknown event.
        }
    }

    $controller->handle_frame($time, $now);

    $time = SDL::get_ticks;
    #if (($time - $oldtime) < (1000/$fps)) {
        SDL::delay((1000/$fps));# - ($time - $oldtime));
    #}
}
