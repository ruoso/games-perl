#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;

use lib 'lib';

use aliased 'BouncingBall::Controller::InGame';
use aliased 'BouncingBall::View::MainSurface';

SDL::init( SDL_INIT_EVERYTHING );

my $fps = 60;

my $surf = MainSurface->new();

my $sevent = SDL::Event->new();
my $time = SDL::get_ticks;
my $first_time = $time;

my @maps = sort <maps/*.xml>;

my $controller = InGame->new({ main_surface => $surf,
                               mapname => shift @maps });

while (1) {
    my $oldtime = $time;
    my $now = SDL::get_ticks;

    while (SDL::Events::poll_event($sevent)) {
        my $type = $sevent->type;
        if ($type == SDL_QUIT) {
            exit;
        } elsif ($type == SDL_USEREVENT) {
            my $nextmap = shift @maps;
            if ($nextmap) {
                $controller = InGame->new({ main_surface => $surf,
                                            mapname => $nextmap });
            } else {
                print 'Finished course in '.(($now - $first_time)/1000)."\n";
                exit;
            }
        } elsif ($controller->handle_sdl_event($sevent)) {
            # handled.
        } else {
            # unknown event.
        }
    }

    $controller->handle_frame($time, $now);

    $time = SDL::get_ticks;
    SDL::delay(1000/$fps);
}
