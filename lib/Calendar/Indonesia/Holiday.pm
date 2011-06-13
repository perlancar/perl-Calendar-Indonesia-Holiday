package Calendar::Indonesia::Holiday;
# ABSTRACT: List Indonesian public holidays

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

#use Data::Clone;
use Sub::Spec::Gen::ReadTable qw(gen_read_table_func);

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(list_id_holidays is_id_holiday);

our %SPEC;

my @fixed_holidays = (
    {
        day        =>  1, month =>  1,
        id_name    => "Tahun Baru",
        en_name    => "New Year",
        is_holiday => 1,
        tags       => [qw/international/],
    },
    {
        day        => 17, month =>  8,
        id_name    => "Proklamasi",
        en_name    => "Declaration Of Independence",
        is_holiday => 1,
        tags       => [],
    },
    {
        day        => 25, month => 12,
        id_name    => "Natal",
        en_name    => "Christmas",
        is_holiday => 1,
        tags       => [qw/international religious religion=christianity/],
    },
);

sub _h_imlek {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Tahun Baru Imlek";
    $r->{en_name}    = "Chinese New Year";
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/international calendar=lunar/];
    ($r);
}

sub _h_maulid {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Maulid Nabi Muhammad";
    $r->{en_name}    = "Mawlid";
    $r->{id_aliases} = [qw/Maulud/];
    $r->{en_aliases} = ["Mawlid An-Nabi"];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_nyepi {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Nyepi";
    $r->{en_name}    = "Nyepi";
    $r->{id_aliases} = [];
    $r->{en_aliases} = ["Bali New Year", "Bali Day Of Silence"];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=hinduism calendar=saka/];
    ($r);
}

sub _h_jumagung {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Jum'at Agung";
    $r->{en_name}    = "Good Friday";
    $r->{id_aliases} = ["Wafat Isa Al-Masih"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=christianity/];
    ($r);
}

sub _h_waisyak {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Waisyak";
    $r->{en_name}    = "Vesakha";
    $r->{id_aliases} = [];
    $r->{en_aliases} = ["Vesak"];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=buddhism/];
    ($r);
}

sub _h_kenaikan {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Kenaikan Isa Al-Masih";
    $r->{en_name}    = "Ascension Day";
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=christianity/];
    ($r);
}

sub _h_isra_miraj {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Isra Miraj";
    $r->{en_name}    = "Isra And Miraj";
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_lebaran {
    my ($r, $opts) = @_;
    $opts //= {};
    $r->{id_name}    = "Idul Fitri".($opts->{day} ? ", Hari $opts->{day}":"");
    $r->{en_name}    = "Eid Ul-Fitr".($opts->{day} ? ", Day $opts->{day}":"");
    $r->{id_aliases} = ["Lebaran"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_idul_adha {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Idul Adha";
    $r->{en_name}    = "Eid Al-Adha";
    $r->{id_aliases} = ["Idul Kurban"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_1muharam {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Tahun Baru Hijriyah";
    $r->{en_name}    = "Hijra";
    $r->{id_aliases} = ["1 Muharam"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/calendar=lunar/];
    ($r);
}

my %year_holidays;

$year_holidays{2011} = [
    _h_imlek     ({day =>  3, month =>  2}),
    _h_maulid    ({day => 16, month =>  2}),
    _h_nyepi     ({day =>  5, month =>  3}),
    _h_jumagung  ({day => 22, month =>  4}),
    _h_waisyak   ({day => 17, month =>  5}),
    _h_kenaikan  ({day =>  2, month =>  6}),
    _h_isra_miraj({day => 29, month =>  6}),
    _h_lebaran   ({day => 31, month =>  8}, {day=>1}),
    _h_lebaran   ({day =>  1, month =>  9}, {day=>2}),
    _h_idul_adha ({day =>  7, month => 11}),
    _h_1muharam  ({day => 27, month => 11}),
];

1;
__END__

=head1 SYNOPSIS

 use Calendar::Indonesia::Holiday qw(list_id_holidays is_id_holiday);

 # list Indonesian holidays for the year 2011, only the dates
 my $res = list_id_holidays(year => 2011);

 # sample result

 # list religious Indonesian holidays from 2012 to 2013, full details
 my $res = list_id_holidays(min_year => 2012, max_year=>2013,
                            has_tags => ['religious'], detail=>1);

 # sample result


=head1 DESCRIPTION

This module provides two functions: B<list_id_holidays> and B<is_id_holiday>.
See documentation for respective function for more details.

This module uses L<Log::Any> logging framework.

This module's functions has L<Sub::Spec> specs.


=head1 FUNCTIONS

None are exported by default, but they are exportable.


=head1 FAQ


=head1 SEE ALSO

This API is available on GudangAPI, http://www.gudangapi.com/ , under
"calendar/id" module.

=cut
