package BouncingBall::View::Camera;
use Moose;

has pointing_x => ( is => 'rw',
                    isa => 'Int',
                    default => 0 );
has pointing_y => ( is => 'rw',
                    isa => 'Int',
                    default => 0 );
has dpi        => ( is => 'rw',
                    isa => 'Int',
                    default => 0.96 );
has pixels_w   => ( is => 'ro',
                    isa => 'Int',
                    required => 1 );
has pixels_h   => ( is => 'ro',
                    isa => 'Int',
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

sub translate {
    my ($self, $x, $y) = @_;
    # here is where we translate our system from the simulated
    # universe, where 0m is at the bottom and the screen where 0px is
    # at the top of the screen.  We also translate the point relative
    # to where the camera is pointing right now.
    my $uplf_x = $self->pointing_x - ($self->width / 2);
    my $uplf_y = $self->pointing_y - ($self->height / 2);
    my $rel_x = $x - $uplf_x;
    my $rel_y = $y - $uplf_y;
    my $pix_x = $self->m2px($rel_x);
    my $pix_y = $self->m2px($rel_y);
    my $inv_y = $self->pixels_h - $pix_y;
    return ($pix_x, $inv_y);
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

1;
