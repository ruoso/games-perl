package BouncingBall::View::Camera;
use Moose;

with 'BouncingBall::Event::RectMovingObserver';

has pointing_x => ( is => 'rw',
                    default => 0 );
has pointing_y => ( is => 'rw',
                    default => 0 );
has dpi        => ( is => 'rw',
                    default => 0.96 );
has pixels_w   => ( is => 'ro',
                    required => 1 );
has pixels_h   => ( is => 'ro',
                    required => 1 );

sub m2px {
    my ($self, $input) = @_;
    return int((($input) * ($self->dpi / 0.0254)) + 0.5);
}

sub px2m {
    my ($self, $input) = @_;
    return ($input) / ($self->dpi / .0254);
}

sub width {
    my ($self) = @_;
    return $self->px2m($self->pixels_w);
}

sub height {
    my ($self) = @_;
    return $self->px2m($self->pixels_h);
}

sub translate_point {
    my ($self, $x, $y) = @_;
    my $uplf_x = $self->pointing_x - ($self->width / 2);
    my $uplf_y = $self->pointing_y - ($self->height / 2);
    my $rel_x = $x - $uplf_x;
    my $rel_y = $y - $uplf_y;
    my $pix_x = $self->m2px($rel_x);
    my $pix_y = $self->m2px($rel_y);
    my $inv_y = $self->pixels_h - $pix_y;
    return ($pix_x, $inv_y);
}

sub translate_rect {
    my ($self, $x, $y, $w, $h) = @_;
    my ($pix_x, $inv_y) = $self->translate_point($x, $y);
    my $pix_h = $self->m2px($h);
    my $pix_w = $self->m2px($w);
    return ($pix_x, $inv_y - $pix_h, $pix_w, $pix_h);
}

sub is_visible {
    my ($self, $x, $y) = @_;
    my ($tx, $ty) = $self->translate($x, $y);
    if ($tx > 0 && $ty > 0 &&
        $tx < $self->pixels_w &&
        $ty < $self->pixels_h) {
        return 1;
    } else {
        return 0;
    }
}

sub rect_moved {
    my ($self, $ev) = @_;
    # implement a loose following of the ball.  if the ball gets near
    # the border of the screen, we follow it so it stays inside the
    # desired area.

    my $lf_x = $self->pointing_x - ($self->width / 2);
    my $br_lf_x = $lf_x + $self->width * 0.2;

    my $rt_x = $self->pointing_x + ($self->width / 2);
    my $br_rt_x = $rt_x - $self->width * 0.2;

    my $up_y = $self->pointing_y + ($self->height / 2);
    my $br_up_y = $up_y - $self->height * 0.2;

    my $dw_y = $self->pointing_y - ($self->height / 2);
    my $br_dw_y = $dw_y + $self->height * 0.2;

    if ($ev->new_rect->x < $br_lf_x) {
        $self->pointing_x( $self->pointing_x - ($br_lf_x - $ev->new_rect->x))
    } elsif ($ev->new_rect->x > $br_rt_x) {
        $self->pointing_x( $self->pointing_x + ($ev->new_rect->x - $br_rt_x));
    }

    if ($ev->new_rect->y < $br_dw_y) {
        $self->pointing_y( $self->pointing_y - ($br_dw_y - $ev->new_rect->y))
    } elsif ($ev->new_rect->y > $br_up_y) {
        $self->pointing_y( $self->pointing_y + ($ev->new_rect->y - $br_up_y));
    }

    return 1;
}

1;
