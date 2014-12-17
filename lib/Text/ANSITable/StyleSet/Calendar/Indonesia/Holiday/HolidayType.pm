package Text::ANSITable::StyleSet::Calendar::Indonesia::Holiday::HolidayType;

# DATE
# VERSION

use 5.010;
use Moo;
use experimental 'smartmatch';
use namespace::clean;

use List::MoreUtils ();

has holiday_bgcolor     => (is => 'rw');
has holiday_fgcolor     => (is => 'rw');
has joint_leave_bgcolor => (is => 'rw');
has joint_leave_fgcolor => (is => 'rw');

sub summary {
    "Set foreground and/or background color for different holiday types";
}

sub apply {
    my ($self, $table) = @_;

    $table->add_cond_row_style(
        sub {
            my ($t, %args) = @_;
            my %styles;

            my $r = $args{row_data};
            my $cols = $t->columns;

            my $is_h_idx  = List::MoreUtils::firstidx(
                sub {$_ eq 'is_holiday'}, @$cols);
            my $is_jl_idx = List::MoreUtils::firstidx(
                sub {$_ eq 'is_joint_leave'}, @$cols);

            if ($is_h_idx >= 0 && $r->[$is_h_idx]) {
                $styles{bgcolor} = $self->holiday_bgcolor
                    if defined $self->holiday_bgcolor;
                $styles{fgcolor}=$self->holiday_fgcolor
                    if defined $self->holiday_fgcolor;
            } elsif ($is_jl_idx >= 0 && $r->[$is_jl_idx]) {
                $styles{bgcolor} = $self->joint_leave_bgcolor
                    if defined $self->joint_leave_bgcolor;
                $styles{fgcolor} = $self->joint_leave_fgcolor
                    if defined $self->joint_leave_fgcolor;
            }
            \%styles;
        },
    );
}

1;
# ABSTRACT: Set foreground and/or background color for different holiday types

=for Pod::Coverage ^(summary|apply)$

=head1 ATTRIBUTES

=head2 holiday_bgcolor

=head2 holiday_fgcolor

=head2 joint_leave_bgcolor

=head2 joint_leave_fgcolor
