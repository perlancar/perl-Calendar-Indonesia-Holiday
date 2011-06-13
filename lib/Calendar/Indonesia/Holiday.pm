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
    my $newyear = {
        day        =>  1, month =>  1,
        id_name    => "Tahun Baru",
        en_name    => "New Year",
        tags       => [qw/international/],
    },
    {
        day        => 17, month =>  8,
        id_name    => "Proklamasi",
        en_name    => "Declaration Of Independence",
        tags       => [],
    },
    my $christmas = {
        day        => 25, month => 12,
        id_name    => "Natal",
        en_name    => "Christmas",
        tags       => [qw/international religious religion=christianity/],
    },
);

sub _h_chnewyear {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Tahun Baru Imlek".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{en_name}    = "Chinese New Year".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/international calendar=lunar/];
    ($r);
}

sub _h_mawlid {
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
    $r->{id_name}    = "Nyepi".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{en_name}    = "Nyepi".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{id_aliases} = ["Tahun Baru Saka"];
    $r->{en_aliases} = ["Bali New Year", "Bali Day Of Silence"];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=hinduism calendar=saka/];
    ($r);
}

sub _h_goodfri {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Jum'at Agung";
    $r->{en_name}    = "Good Friday";
    $r->{id_aliases} = ["Wafat Isa Al-Masih"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=christianity/];
    ($r);
}

sub _h_vesakha {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Waisyak".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{en_name}    = "Vesakha".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{id_aliases} = [];
    $r->{en_aliases} = ["Vesak"];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=buddhism/];
    ($r);
}

sub _h_ascension {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Kenaikan Isa Al-Masih";
    $r->{en_name}    = "Ascension Day";
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=christianity/];
    ($r);
}

sub _h_isramiraj {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Isra Miraj";
    $r->{en_name}    = "Isra And Miraj";
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_eidulf {
    my ($r, $opts) = @_;
    $opts //= {};
    $r->{id_name0}   = "Idul Fitri".
        ($opts->{hyear} ? " $opts->{hyear}H":"");
    $r->{en_name0}   = "Eid Ul-Fitr".
        ($opts->{hyear} ? " $opts->{hyear}H":"");
    $r->{id_name}    = $r->{id_name0}.($opts->{day} ? ", Hari $opts->{day}":"");
    $r->{en_name}    = $r->{en_name0}.($opts->{day} ? ", Day $opts->{day}":"");
    $r->{id_aliases} = ["Lebaran"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_eidula {
    my ($r, $opts) = @_;
    $r->{id_name}    = "Idul Adha";
    $r->{en_name}    = "Eid Al-Adha";
    $r->{id_aliases} = ["Idul Kurban"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_hijra {
    my ($r, $opts) = @_;
    $opts //= {};
    $r->{id_name}    = "Tahun Baru Hijriyah".
        ($opts->{hyear} ? " $opts->{hyear}H":"");
    $r->{en_name}    = "Hijra".
        ($opts->{hyear} ? " $opts->{hyear}H":"");
    $r->{id_aliases} = ["1 Muharam"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/calendar=lunar/];
    ($r);
}

sub _jointlv {
    my ($r, $opts) = @_;
    $opts //= {};
    my $h = $opts->{holiday};
    $r->{id_name}        = "Cuti Bersama".
        ($h ? " (".($h->{id_name0} // $h->{id_name}).")": "");
    $r->{en_name}        = "Joint Leave".
        ($h ? " (".($h->{en_name0} // $h->{en_name}).")": "");
    $r->{id_aliases}     = [];
    $r->{en_aliases}     = [];
    $r->{is_joint_leave} = 1;
    $r->{tags}           = [];
    ($r);
}

my %year_holidays;

# ditetapkan x xxx 2007
my $hijra2008a;
my $eidulf2008;
$year_holidays{2008} = [
    _h_hijra     ({day => 10, month =>  1}, {hyear=>1929}),
    _h_chnewyear ({day =>  7, month =>  2}, {hyear=>2559}),
    _h_nyepi     ({day =>  7, month =>  3}, {hyear=>1930}),
    _h_mawlid    ({day => 20, month =>  3}),
    _h_goodfri   ({day => 21, month =>  3}),
    _h_ascension ({day =>  1, month =>  5}),
    _h_vesakha   ({day => 20, month =>  5}, {hyear=>2552}),
    _h_isramiraj ({day => 30, month =>  7}),
    ($eidulf2008 =
    _h_eidulf    ({day =>  1, month => 10}, {hyear=>1929, day=>1})),
    _h_eidulf    ({day =>  2, month => 10}, {hyear=>1929, day=>2}),
    _h_eidula    ({day =>  8, month => 12}),
    _h_hijra     ({day => 29, month => 12}, {hyear=>1930}),

    _jointlv     ({day => 11, month =>  1}, {holiday=>$hijra2008a}),
    _jointlv     ({day => 29, month =>  9}, {holiday=>$eidulf2008}),
    _jointlv     ({day => 30, month =>  9}, {holiday=>$eidulf2008}),
    _jointlv     ({day =>  3, month => 10}, {holiday=>$eidulf2008}),
    _jointlv     ({day => 26, month => 12}, {holiday=>$christmas}),
];

# ditetapkan 9 juni 2008
my $eidulf2009;
$year_holidays{2009} = [
    _h_chnewyear ({day => 26, month =>  1}, {hyear=>2560}),
    _h_mawlid    ({day =>  9, month =>  3}),
    _h_nyepi     ({day => 26, month =>  3}, {hyear=>1931}),
    _h_goodfri   ({day => 10, month =>  4}),
    _h_vesakha   ({day =>  9, month =>  5}, {hyear=>2553}),
    _h_ascension ({day => 21, month =>  5}),
    _h_isramiraj ({day => 20, month =>  7}),
    ($eidulf2009 =
    _h_eidulf    ({day => 21, month =>  9}, {hyear=>1930, day=>1})),
    _h_eidulf    ({day => 22, month =>  9}, {hyear=>1930, day=>2}),
    _h_eidula    ({day => 27, month => 11}),
    _h_hijra     ({day => 18, month => 12}, {hyear=>1931}),

    _jointlv     ({day =>  2, month =>  1}, {holiday=>$newyear}),
    _jointlv     ({day => 18, month =>  9}, {holiday=>$eidulf2009}),
    _jointlv     ({day => 23, month =>  9}, {holiday=>$eidulf2009}),
    _jointlv     ({day => 24, month => 12}, {holiday=>$christmas}),
];

# ditetapkan x xxx 2009
my $eidulf2010;
$year_holidays{2010} = [
    _h_chnewyear ({day => 14, month =>  2}, {hyear=>2561}),
    _h_mawlid    ({day => 26, month =>  2}),
    _h_nyepi     ({day => 16, month =>  3}, {hyear=>1932}),
    _h_goodfri   ({day =>  2, month =>  4}),
    _h_vesakha   ({day => 28, month =>  5}, {hyear=>2554}),
    _h_ascension ({day =>  2, month =>  6}),
    _h_isramiraj ({day => 10, month =>  7}),
    ($eidulf2010 =
    _h_eidulf    ({day => 10, month =>  9}, {hyear=>1931, day=>1})),
    _h_eidulf    ({day => 11, month =>  9}, {hyear=>1931, day=>2}),
    _h_eidula    ({day => 17, month => 11}),
    _h_hijra     ({day =>  7, month => 12}, {hyear=>1932}),

    _jointlv     ({day =>  9, month =>  9}, {holiday=>$eidulf2010}),
    _jointlv     ({day => 13, month =>  9}, {holiday=>$eidulf2010}),
    _jointlv     ({day => 24, month => 12}, {holiday=>$christmas}),
];

# ditetapkan x xxx 2010
my $eidulf2011;
$year_holidays{2011} = [
    _h_chnewyear ({day =>  3, month =>  2}, {hyear=>2562}),
    _h_mawlid    ({day => 16, month =>  2}),
    _h_nyepi     ({day =>  5, month =>  3}, {hyear=>1933}),
    _h_goodfri   ({day => 22, month =>  4}),
    _h_vesakha   ({day => 17, month =>  5}, {hyear=>2555}),
    _h_ascension ({day =>  2, month =>  6}),
    _h_isramiraj ({day => 29, month =>  6}),
    ($eidulf2011 =
    _h_eidulf    ({day => 30, month =>  8}, {hyear=>1932, day=>1})),
    _h_eidulf    ({day => 31, month =>  8}, {hyear=>1932, day=>2}),
    _h_eidula    ({day =>  7, month => 11}),
    _h_hijra     ({day => 27, month => 11}, {hyear=>1933}),

    _jointlv     ({day => 29, month =>  8}, {holiday=>$eidulf2011}),
    _jointlv     ({day =>  1, month =>  9}, {holiday=>$eidulf2011}),
    _jointlv     ({day =>  2, month =>  9}, {holiday=>$eidulf2011}),
    _jointlv     ({day => 26, month => 12}, {holiday=>$christmas}),
];

# ditetapkan x xxx 2011

my @years     = sort keys %year_holidays;
our $min_year = $years[0];
our $max_year = $years[-1];
our $max_joint_leave_year;
for my $y (reverse @years) {
    if (grep {$_->{is_joint_leave}} @{$year_holidays{$y}}) {
        $max_joint_leave_year = $y;
        last;
    }
}

my @holidays;
for my $year ($min_year .. $max_year) {
    my @hf;
    for my $h0 (@fixed_holidays) {
        my $h = clone $h0;
        push @{$h->{tags}}, "fixed-date";
        $h->{is_holiday}     = 1;
        $h->{is_joint_leave} = 0;
        push @hf, $h;
    }

    my @hy;
    for my $h0 (@{$year_holidays{$year}}) {
        my $h = clone $h0;
        $h->{is_holiday}     //= 0;
        $h->{is_joint_leave} //= 0;
        delete $h->{id_name0};
        delete $h->{en_name0};
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
                column_sortable => 0,
            }],
            id_name => ['str*'=>{
                summary => 'Indonesian name',
                column_index => 6,
                column_filterable => 0,
                column_sortable => 0,
            }],
            en_aliases => ['array*'=>{
                summary => 'English other names, if any',
                column_index => 7,
                column_filterable => 0,
                column_sortable => 0,
            }],
            id_aliases => ['array*'=>{
                summary => 'Indonesian other names, if any',
                column_index => 8,
                column_filterable => 0,
                column_sortable => 0,
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
                column_sortable => 0,
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

Contains data from years $min_year to $max_year (joint leave days until
$max_joint_leave_year).

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
