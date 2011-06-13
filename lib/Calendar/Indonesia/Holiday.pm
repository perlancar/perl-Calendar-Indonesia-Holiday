package Calendar::Indonesia::Holiday;
# ABSTRACT: List Indonesian public holidays

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

use Data::Clone;
use DateTime;
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

my @years     = sort keys %year_holidays;
our $min_year = $years[0];
our $max_year = $years[-1];

my @holidays;
for my $year ($min_year .. $max_year) {
    my @hf;
    for my $h0 (@fixed_holidays) {
        my $h = clone $h0;
        push @{$h->{tags}}, "fixed-date";
        push @hf, $h;
    }

    my @hy;
    for my $h0 (@{$year_holidays{$year}}) {
        my $h = clone $h0;
        push @hy, $h;
    }

    for my $h (@hf, @hy) {
        $h->{year} = $year;
        my $dt = DateTime->new(year=>$year, month=>$h->{month}, day=>$h->{day});
        $h->{date} = $dt->ymd;
        $h->{dow}  = $dt->day_of_week;
    }

    push @holidays, (sort {$a->{date} cmp $b->{date}} @hf, @hy);
}

my $res = gen_read_table_func(
    table_data => \@holidays,
    table_spec => {
        columns => {
            date => ['str*'=>{
                column_index => 0,
                column_searchable => 0,
            }],
            day => ['int*'=>{
                column_index => 1,
            }],
            month => ['int*'=>{
                column_index => 2,
            }],
            year => ['int*'=>{
                column_index => 3,
            }],
            dow => ['int*'=>{
                summary => 'Day of week (1-7, Monday is 1)',
                column_index => 4,
            }],
            en_name => ['str*'=>{
                summary => 'English name',
                column_index => 5,
                column_filterable => 0,
            }],
            id_name => ['str*'=>{
                summary => 'Indonesian name',
                column_index => 6,
                column_filterable => 0,
            }],
            en_aliases => ['array*'=>{
                summary => 'English other names, if any',
                column_index => 7,
                column_filterable => 0,
            }],
            id_aliases => ['array*'=>{
                summary => 'Indonesian other names, if any',
                column_index => 8,
                column_filterable => 0,
            }],
            is_holiday => ['bool*'=>{
                column_index => 9,
            }],
            is_joint_leave => ['bool*'=>{
                summary => 'Whether this date is a joint leave day '.
                    '("cuti bersama")',
                column_index => 10,
            }],
            tags => ['array*'=>{
                column_index => 11,
            }],
        },
        pk => 'date',
    },
);

die "BUG: Can't generate func: $res->[0] - $res->[1]"
    unless $res->[0] == 200;

my $spec = $res->[2]{spec};
$spec->{summary} = "List Indonesian holidays in calendar";
$spec->{description} = <<"_";
List holidays and joint leave days ("cuti bersama").

Contains data from years $min_year to $max_year.
_
$SPEC{list_id_holidays} = $spec;
no warnings;
*list_id_holidays = $res->[2]{code};
use warnings;

1;
__END__

=head1 SYNOPSIS

 use Calendar::Indonesia::Holiday qw(list_id_holidays);

 # list Indonesian holidays for the year 2011, without the joint leave days
 # ("cuti bersama"), show only the dates

 my $res = list_id_holidays(year => 2011, is_joint_leave=>0);
 # sample result
 [200, "OK", [
   '2011-01-01',
   '2011-02-03',
   '2011-02-16',
   '2011-03-05',
   '2011-04-22',
   '2011-05-17',
   '2011-06-02',
   '2011-06-29',
   '2011-08-17',
   '2011-08-31',
   '2011-09-01',
   '2011-11-07',
   '2011-11-27',
   '2011-12-25',
 ]];

 # list religious Indonesian holidays, show full details
 my $res = list_id_holidays(year => 2011,
                            has_tags => ['religious'], detail=>1);

 # sample result
 [200, "OK", [
   {date       => '2011-02-16',
    day        => 16,
    month      => 2,
    year       => 2011,
    id_name    => 'Maulid Nabi Muhammad',
    en_name    => 'Mawlid',
    en_aliases => ['Mawlid An-Nabi'],
    id_aliases => ['Maulud'],
    is_holiday => 1,
    tags       => [qw/religious religion=islam calendar=lunar/],
   },
   ...
 ]];

 # check whether 2011-02-16 is a holiday
 my $res = list_id_holidays(date => '2011-02-16');
 print "2011-02-16 is a holiday\n" if @{$res->[2]};


=head1 DESCRIPTION

This module provides two functions: B<list_id_holidays>.

This module uses L<Log::Any> logging framework.

This module's functions has L<Sub::Spec> specs.


=head1 FUNCTIONS

None are exported by default, but they are exportable.


=head1 FAQ


=head1 SEE ALSO

This API is available on GudangAPI, http://www.gudangapi.com/ , under
"calendar/id" module. To use GudangAPI, you can use L<WWW::GudangAPI>.

=cut
