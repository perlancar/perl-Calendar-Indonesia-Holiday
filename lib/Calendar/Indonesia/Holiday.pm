package Calendar::Indonesia::Holiday;

use 5.010001;
use strict;
use warnings;
use experimental 'smartmatch';
use Log::Any '$log';

use Data::Clone;
use DateTime;
use Perinci::Sub::Gen::AccessTable 0.16 qw(gen_read_table_func);
use Perinci::Sub::Util qw(wrapres);

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       list_id_holidays
                       enum_id_workdays
                       count_id_workdays
               );

# VERSION

our %SPEC;
my @fixed_holidays = (
    my $newyear = {
        day        =>  1, month =>  1,
        ind_name   => "Tahun Baru",
        eng_name   => "New Year",
        tags       => [qw/international/],
    },
    my $indep = {
        day        => 17, month =>  8,
        ind_name   => "Proklamasi",
        eng_name   => "Declaration Of Independence",
        tags       => [],
    },
    my $christmas = {
        day        => 25, month => 12,
        ind_name   => "Natal",
        eng_name   => "Christmas",
        tags       => [qw/international religious religion=christianity/],
    },

    # labor day becomes national holiday since 2014 (decreed by president @ apr
    # 29, 2013.
    my $labord = {
        day        => 1, month => 5,
        year_start => 2014,
        ind_name   => "Hari Buruh",
        eng_name   => "Labor Day",
        tags       => [qw/international/],
    },
);

sub _add_original_date {
    my ($r, $opts) = @_;
    if ($opts->{original_date}) {
        $r->{ind_name} .= " (diperingati $opts->{original_date})";
        $r->{eng_name} .= " (commemorated on $opts->{original_date})";
    }
}

sub _h_chnewyear {
    my ($r, $opts) = @_;
    $r->{ind_name}    = "Tahun Baru Imlek".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{eng_name}    = "Chinese New Year".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    _add_original_date($r, $opts);
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/international calendar=lunar/];
    ($r);
}

sub _h_mawlid {
    my ($r, $opts) = @_;
    $r->{ind_name}    = "Maulid Nabi Muhammad";
    $r->{eng_name}    = "Mawlid";
    _add_original_date($r, $opts);
    $r->{id_aliases} = [qw/Maulud/];
    $r->{en_aliases} = ["Mawlid An-Nabi"];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_nyepi {
    my ($r, $opts) = @_;
    $r->{ind_name}    = "Nyepi".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{eng_name}    = "Nyepi".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    _add_original_date($r, $opts);
    $r->{id_aliases} = ["Tahun Baru Saka"];
    $r->{en_aliases} = ["Bali New Year", "Bali Day Of Silence"];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=hinduism calendar=saka/];
    ($r);
}

sub _h_goodfri {
    my ($r, $opts) = @_;
    $r->{ind_name}    = "Jum'at Agung";
    $r->{eng_name}    = "Good Friday";
    _add_original_date($r, $opts);
    $r->{id_aliases} = ["Wafat Isa Al-Masih"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=christianity/];
    ($r);
}

sub _h_vesakha {
    my ($r, $opts) = @_;
    $r->{ind_name}    = "Waisyak".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    $r->{eng_name}    = "Vesakha".
        ($opts->{hyear} ? " $opts->{hyear}":"");
    _add_original_date($r, $opts);
    $r->{id_aliases} = [];
    $r->{en_aliases} = ["Vesak"];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=buddhism/];
    ($r);
}

sub _h_ascension {
    my ($r, $opts) = @_;
    $r->{ind_name}    = "Kenaikan Isa Al-Masih";
    $r->{eng_name}    = "Ascension Day";
    _add_original_date($r, $opts);
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=christianity/];
    ($r);
}

sub _h_isramiraj {
    my ($r, $opts) = @_;
    $r->{ind_name}    = "Isra Miraj";
    $r->{eng_name}    = "Isra And Miraj";
    _add_original_date($r, $opts);
    $r->{id_aliases} = [];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_eidulf {
    my ($r, $opts) = @_;
    $opts //= {};
    $r->{ind_name0}   = "Idul Fitri".
        ($opts->{hyear} ? " $opts->{hyear}H":"");
    $r->{eng_name0}   = "Eid Ul-Fitr".
        ($opts->{hyear} ? " $opts->{hyear}H":"");
    $r->{ind_name}    = $r->{ind_name0}.($opts->{day} ? ", Hari $opts->{day}":"");
    $r->{eng_name}    = $r->{eng_name0}.($opts->{day} ? ", Day $opts->{day}":"");
    _add_original_date($r, $opts);
    $r->{id_aliases} = ["Lebaran"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_eidula {
    my ($r, $opts) = @_;
    $r->{ind_name}    = "Idul Adha";
    $r->{eng_name}    = "Eid Al-Adha";
    _add_original_date($r, $opts);
    $r->{id_aliases} = ["Idul Kurban"];
    $r->{en_aliases} = [];
    $r->{is_holiday} = 1;
    $r->{tags}       = [qw/religious religion=islam calendar=lunar/];
    ($r);
}

sub _h_hijra {
    my ($r, $opts) = @_;
    $opts //= {};
    $r->{ind_name}    = "Tahun Baru Hijriyah".
        ($opts->{hyear} ? " $opts->{hyear}H":"");
    $r->{eng_name}    = "Hijra".
        ($opts->{hyear} ? " $opts->{hyear}H":"");
    _add_original_date($r, $opts);
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
    $r->{ind_name}        = "Cuti Bersama".
        ($h ? " (".($h->{ind_name0} // $h->{ind_name}).")": "");
    $r->{eng_name}        = "Joint Leave".
        ($h ? " (".($h->{eng_name0} // $h->{eng_name}).")": "");
    $r->{id_aliases}     = [];
    $r->{en_aliases}     = [];
    $r->{is_joint_leave} = 1;
    $r->{tags}           = [];
    ($r);
}

# can operate on a single holiday or multiple ones
sub _make_tentative {
    my ($h) = @_;
    my $hh = ref($h) eq 'ARRAY' ? $h : [$h];
    for (@$hh) {
        push @{ $_->{tags} }, 'tentative' unless $_->{tags} ~~ 'tentative';
    }
    return $h;
}

sub _make_jl_tentative {
    my ($holidays) = @_;
    for (@$holidays) {
        _make_tentative($_) if $_->{is_joint_leave};
    }
    $holidays;
}

sub _expand_dm {
    $_[0] =~ m!(\d+)[-/](\d+)! or die "Bug: bad dm syntax $_[0]";
    return (day => $1+0, month => $2+0);
}

my %year_holidays;

# decreed ?
my $eidulf2002;
$year_holidays{2002} = [
    _h_chnewyear ({_expand_dm("12-02")}, {hyear=>2553}),
    _h_eidula    ({_expand_dm("23-02")}, {hyear=>1422}),
    _h_hijra     ({_expand_dm("15-03")}, {hyear=>1423}),
    _h_goodfri   ({_expand_dm("29-03")}),
    _h_nyepi     ({_expand_dm("13-04")}, {hyear=>1924}),
    _h_ascension ({_expand_dm("09-05")}),
    _h_mawlid    ({_expand_dm("25-05")}, {hyear=>1423, original_date=>'2003-05-14'}),
    _h_vesakha   ({_expand_dm("26-05")}, {hyear=>2546}),
    _h_isramiraj ({_expand_dm("04-10")}),
    ($eidulf2002 =
    _h_eidulf    ({_expand_dm("06-12")}, {hyear=>1424, day=>1})),
    _h_eidulf    ({_expand_dm("07-12")}, {hyear=>1424, day=>2}),

    _jointlv     ({_expand_dm("05-12")}, {holiday=>$eidulf2002}),
    _jointlv     ({_expand_dm("09-12")}, {holiday=>$eidulf2002}),
    _jointlv     ({_expand_dm("10-12")}, {holiday=>$eidulf2002}),
    _jointlv     ({_expand_dm("26-12")}, {holiday=>$christmas}),
];

# decreed nov 25, 2002
my $eidulf2003;
$year_holidays{2003} = [
    _h_chnewyear ({_expand_dm("01-02")}, {hyear=>2554}),
    _h_eidula    ({_expand_dm("12-02")}, {hyear=>1423}),
    _h_hijra     ({_expand_dm("03-03")}, {hyear=>1424, original_date=>'2003-03-04'}),
    _h_nyepi     ({_expand_dm("02-04")}, {hyear=>1925}),
    _h_goodfri   ({_expand_dm("18-04")}),
    _h_mawlid    ({_expand_dm("15-05")}, {original_date=>'2003-05-14'}),
    _h_vesakha   ({_expand_dm("16-05")}, {hyear=>2547}),
    _h_ascension ({_expand_dm("30-05")}, {original_date=>'2003-05-29'}),
    _h_isramiraj ({_expand_dm("22-09")}, {original_date=>'2003-09-24'}),
    ($eidulf2003 =
    _h_eidulf    ({_expand_dm("25-11")}, {hyear=>1425, day=>1})),
    _h_eidulf    ({_expand_dm("26-11")}, {hyear=>1425, day=>2}),

    _jointlv     ({_expand_dm("24-11")}, {holiday=>$eidulf2003}),
    _jointlv     ({_expand_dm("27-11")}, {holiday=>$eidulf2003}),
    _jointlv     ({_expand_dm("28-11")}, {holiday=>$eidulf2003}),
    _jointlv     ({_expand_dm("26-12")}, {holiday=>$christmas}),
];
my $indep2003 = clone($indep); $indep2003->{day} = 18;
_add_original_date($indep2003, {original_date=>'2003-08-17'});

# decreed jul 17, 2003
my $eidulf2004;
$year_holidays{2004} = [
    _h_chnewyear ({_expand_dm("22-01")}, {hyear=>2555}),
    _h_eidula    ({_expand_dm("02-02")}, {hyear=>1424, original_date=>'2004-02-01'}),
    _h_hijra     ({_expand_dm("23-02")}, {hyear=>1425, original_date=>'2004-02-01'}),
    _h_nyepi     ({_expand_dm("22-03")}, {hyear=>1926}),
    _h_goodfri   ({_expand_dm("09-04")}),
    _h_mawlid    ({_expand_dm("03-05")}, {original_date=>'2004-05-02'}),
    _h_ascension ({_expand_dm("20-05")}),
    _h_vesakha   ({_expand_dm("03-06")}, {hyear=>2548}),
    _h_isramiraj ({_expand_dm("13-09")}, {original_date=>'2004-09-12'}),
    ($eidulf2004 =
    _h_eidulf    ({_expand_dm("14-11")}, {hyear=>1425, day=>1})),
    _h_eidulf    ({_expand_dm("15-11")}, {hyear=>1425, day=>2}),
    _h_eidulf    ({_expand_dm("16-11")}, {hyear=>1425, day=>3}),

    _jointlv     ({_expand_dm("17-11")}, {holiday=>$eidulf2004}),
    _jointlv     ({_expand_dm("18-11")}, {holiday=>$eidulf2004}),
    _jointlv     ({_expand_dm("19-11")}, {holiday=>$eidulf2004}),
];

# decreed jul ??, 2004
my $eidulf2005;
$year_holidays{2005} = [
    _h_eidula    ({_expand_dm("21-01")}, {hyear=>1425}),
    _h_chnewyear ({_expand_dm("09-02")}, {hyear=>2556}),
    _h_hijra     ({_expand_dm("10-02")}, {hyear=>1426}),
    _h_nyepi     ({_expand_dm("11-03")}, {hyear=>1927}),
    _h_goodfri   ({_expand_dm("25-03")}),
    _h_mawlid    ({_expand_dm("22-04")}, {original_date=>'2005-21-04'}),
    _h_ascension ({_expand_dm("05-05")}),
    _h_vesakha   ({_expand_dm("24-05")}, {hyear=>2549}),
    _h_isramiraj ({_expand_dm("02-09")}, {original_date=>'2005-09-01'}),
    ($eidulf2005 =
    _h_eidulf    ({_expand_dm("03-11")}, {hyear=>1426, day=>1})),
    _h_eidulf    ({_expand_dm("04-11")}, {hyear=>1426, day=>2}),

    _jointlv     ({_expand_dm("02-11")}, {holiday=>$eidulf2005}),
    _jointlv     ({_expand_dm("05-11")}, {holiday=>$eidulf2005}),
    _jointlv     ({_expand_dm("07-11")}, {holiday=>$eidulf2005}),
    _jointlv     ({_expand_dm("08-11")}, {holiday=>$eidulf2005}),
];

# decreed mar 22, 2006 (?)
my $nyepi2006;
my $ascension2006;
my $eidulf2006;
$year_holidays{2006} = [
    _h_eidula    ({_expand_dm("10-01")}, {hyear=>1426}),
    _h_hijra     ({_expand_dm("31-01")}, {hyear=>1427}),
    _h_chnewyear ({_expand_dm("29-01")}, {hyear=>2557}),
    ($nyepi2006 =
    _h_nyepi     ({_expand_dm("30-03")}, {hyear=>1928})),
    _h_mawlid    ({_expand_dm("10-04")}),
    _h_goodfri   ({_expand_dm("14-04")}),
    _h_vesakha   ({_expand_dm("13-05")}, {hyear=>2550}),
    ($ascension2006 =
    _h_ascension ({_expand_dm("25-05")})),
    _h_isramiraj ({_expand_dm("21-08")}),
    ($eidulf2006 =
    _h_eidulf    ({_expand_dm("24-10")}, {hyear=>1427, day=>1})),
    _h_eidulf    ({_expand_dm("25-10")}, {hyear=>1427, day=>2}),
    _h_eidula    ({_expand_dm("31-12")}, {hyear=>1427}),

    _jointlv     ({_expand_dm("31-03")}, {holiday=>$nyepi2006}),
    _jointlv     ({_expand_dm("26-05")}, {holiday=>$ascension2006}),
    _jointlv     ({_expand_dm("18-08")}, {holiday=>$indep}),
    _jointlv     ({_expand_dm("23-10")}, {holiday=>$eidulf2006}),
    _jointlv     ({_expand_dm("26-10")}, {holiday=>$eidulf2006}),
    _jointlv     ({_expand_dm("27-10")}, {holiday=>$eidulf2006}),
];

# decreed jul 24, 2006
my $ascension2007;
my $eidulf2007;
$year_holidays{2007} = [
    _h_hijra     ({_expand_dm("20-01")}, {hyear=>1428}),
    _h_chnewyear ({_expand_dm("18-02")}, {hyear=>2558}),
    _h_nyepi     ({_expand_dm("19-03")}, {hyear=>1929}),
    _h_mawlid    ({_expand_dm("31-03")}),
    _h_goodfri   ({_expand_dm("06-04")}),
    ($ascension2007 =
    _h_ascension ({_expand_dm("17-05")})),
    _h_vesakha   ({_expand_dm("01-06")}, {hyear=>2551}),
    _h_isramiraj ({_expand_dm("11-08")}),
    ($eidulf2007 =
    _h_eidulf    ({_expand_dm("13-10")}, {hyear=>1428, day=>1})),
    _h_eidulf    ({_expand_dm("14-10")}, {hyear=>1428, day=>2}),
    _h_eidula    ({_expand_dm("20-12")}, {hyear=>1428}),

    _jointlv     ({_expand_dm("18-05")}, {holiday=>$ascension2007}),
    _jointlv     ({_expand_dm("12-10")}, {holiday=>$eidulf2007}),
    _jointlv     ({_expand_dm("15-10")}, {holiday=>$eidulf2007}),
    _jointlv     ({_expand_dm("16-10")}, {holiday=>$eidulf2007}),
    _jointlv     ({_expand_dm("21-12")}, {holiday=>$christmas}),
    _jointlv     ({_expand_dm("24-12")}, {holiday=>$christmas}),
];

# decreed feb 5, 2008 (?)
my $hijra2008a;
my $eidulf2008;
$year_holidays{2008} = [
    ($hijra2008a =
    _h_hijra     ({_expand_dm("10-01")}, {hyear=>1429})),
    _h_chnewyear ({_expand_dm("07-02")}, {hyear=>2559}),
    _h_nyepi     ({_expand_dm("07-03")}, {hyear=>1930}),
    _h_mawlid    ({_expand_dm("20-03")}),
    _h_goodfri   ({_expand_dm("21-03")}),
    _h_ascension ({_expand_dm("01-05")}),
    _h_vesakha   ({_expand_dm("20-05")}, {hyear=>2552}),
    _h_isramiraj ({_expand_dm("30-07")}),
    ($eidulf2008 =
    _h_eidulf    ({_expand_dm("01-10")}, {hyear=>1429, day=>1})),
    _h_eidulf    ({_expand_dm("02-10")}, {hyear=>1429, day=>2}),
    _h_eidula    ({_expand_dm("08-12")}),
    _h_hijra     ({_expand_dm("29-12")}, {hyear=>1430}),

    _jointlv     ({_expand_dm("11-01")}, {holiday=>$hijra2008a}),
    _jointlv     ({_expand_dm("29-09")}, {holiday=>$eidulf2008}),
    _jointlv     ({_expand_dm("30-09")}, {holiday=>$eidulf2008}),
    _jointlv     ({_expand_dm("03-10")}, {holiday=>$eidulf2008}),
    _jointlv     ({_expand_dm("26-12")}, {holiday=>$christmas}),
];

# decreed juni 9, 2008
my $eidulf2009;
$year_holidays{2009} = [
    _h_chnewyear ({_expand_dm("26-01")}, {hyear=>2560}),
    _h_mawlid    ({_expand_dm("09-03")}),
    _h_nyepi     ({_expand_dm("26-03")}, {hyear=>1931}),
    _h_goodfri   ({_expand_dm("10-04")}),
    _h_vesakha   ({_expand_dm("09-05")}, {hyear=>2553}),
    _h_ascension ({_expand_dm("21-05")}),
    _h_isramiraj ({_expand_dm("20-07")}),
    ($eidulf2009 =
    _h_eidulf    ({_expand_dm("21-09")}, {hyear=>1430, day=>1})),
    _h_eidulf    ({_expand_dm("22-09")}, {hyear=>1430, day=>2}),
    _h_eidula    ({_expand_dm("27-11")}),
    _h_hijra     ({_expand_dm("18-12")}, {hyear=>1431}),

    _jointlv     ({_expand_dm("02-01")}, {holiday=>$newyear}),
    _jointlv     ({_expand_dm("18-09")}, {holiday=>$eidulf2009}),
    _jointlv     ({_expand_dm("23-09")}, {holiday=>$eidulf2009}),
    _jointlv     ({_expand_dm("24-12")}, {holiday=>$christmas}),
];

# decreed aug 7, 2009
my $eidulf2010;
$year_holidays{2010} = [
    _h_chnewyear ({_expand_dm("14-02")}, {hyear=>2561}),
    _h_mawlid    ({_expand_dm("26-02")}),
    _h_nyepi     ({_expand_dm("16-03")}, {hyear=>1932}),
    _h_goodfri   ({_expand_dm("02-04")}),
    _h_vesakha   ({_expand_dm("28-05")}, {hyear=>2554}),
    _h_ascension ({_expand_dm("02-06")}),
    _h_isramiraj ({_expand_dm("10-07")}),
    ($eidulf2010 =
    _h_eidulf    ({_expand_dm("10-09")}, {hyear=>1431, day=>1})),
    _h_eidulf    ({_expand_dm("11-09")}, {hyear=>1431, day=>2}),
    _h_eidula    ({_expand_dm("17-11")}),
    _h_hijra     ({_expand_dm("07-12")}, {hyear=>1432}),

    _jointlv     ({_expand_dm("09-09")}, {holiday=>$eidulf2010}),
    _jointlv     ({_expand_dm("13-09")}, {holiday=>$eidulf2010}),
    _jointlv     ({_expand_dm("24-12")}, {holiday=>$christmas}),
];

# decreed jun 15, 2010
my $eidulf2011;
$year_holidays{2011} = [
    _h_chnewyear ({_expand_dm("03-02")}, {hyear=>2562}),
    _h_mawlid    ({_expand_dm("16-02")}),
    _h_nyepi     ({_expand_dm("05-03")}, {hyear=>1933}),
    _h_goodfri   ({_expand_dm("22-04")}),
    _h_vesakha   ({_expand_dm("17-05")}, {hyear=>2555}),
    _h_ascension ({_expand_dm("02-06")}),
    _h_isramiraj ({_expand_dm("29-06")}),
    ($eidulf2011 =
    _h_eidulf    ({_expand_dm("30-08")}, {hyear=>1432, day=>1})),
    _h_eidulf    ({_expand_dm("31-08")}, {hyear=>1432, day=>2}),
    _h_eidula    ({_expand_dm("07-11")}),
    _h_hijra     ({_expand_dm("27-11")}, {hyear=>1433}),

    _jointlv     ({_expand_dm("29-08")}, {holiday=>$eidulf2011}),
    _jointlv     ({_expand_dm("01-09")}, {holiday=>$eidulf2011}),
    _jointlv     ({_expand_dm("02-09")}, {holiday=>$eidulf2011}),
    _jointlv     ({_expand_dm("26-12")}, {holiday=>$christmas}),
];

# decreed may 16, 2011
my $eidulf2012;
$year_holidays{2012} = [
    _h_chnewyear ({_expand_dm("23-01")}, {hyear=>2563}),
    _h_mawlid    ({_expand_dm("04-02")}),
    _h_nyepi     ({_expand_dm("23-03")}, {hyear=>1934}),
    _h_goodfri   ({_expand_dm("06-04")}),
    _h_vesakha   ({_expand_dm("06-05")}, {hyear=>2556}),
    _h_ascension ({_expand_dm("17-05")}),
    _h_isramiraj ({_expand_dm("16-06")}),
    ($eidulf2012 =
    _h_eidulf    ({_expand_dm("19-08")}, {hyear=>1433, day=>1})),
    _h_eidulf    ({_expand_dm("20-08")}, {hyear=>1433, day=>2}),
    _h_eidula    ({_expand_dm("26-10")}),
    _h_hijra     ({_expand_dm("15-11")}, {hyear=>1434}),

    _jointlv     ({_expand_dm("21-08")}, {holiday=>$eidulf2012}),
    _jointlv     ({_expand_dm("22-08")}, {holiday=>$eidulf2012}),
    _jointlv     ({_expand_dm("26-12")}, {holiday=>$christmas}),
];

# decreed jul 19, 2012
my $eidulf2013;
my $eidula2013;
$year_holidays{2013} = [
    _h_mawlid    ({_expand_dm("24-01")}),
    _h_chnewyear ({_expand_dm("10-02")}, {hyear=>2564}),
    _h_nyepi     ({_expand_dm("12-03")}, {hyear=>1935}),
    _h_goodfri   ({_expand_dm("29-03")}),
    _h_ascension ({_expand_dm("09-05")}),
    _h_vesakha   ({_expand_dm("25-05")}, {hyear=>2557}),
    _h_isramiraj ({_expand_dm("06-06")}),
    ($eidulf2013 =
    _h_eidulf    ({_expand_dm("08-08")}, {hyear=>1434, day=>1})),
    _h_eidulf    ({_expand_dm("09-08")}, {hyear=>1434, day=>2}),
    ($eidula2013 =
    _h_eidula    ({_expand_dm("15-10")})),
    _h_hijra     ({_expand_dm("05-11")}, {hyear=>1435}),

    _jointlv     ({_expand_dm("05-08")}, {holiday=>$eidulf2013}),
    _jointlv     ({_expand_dm("06-08")}, {holiday=>$eidulf2013}),
    _jointlv     ({_expand_dm("07-08")}, {holiday=>$eidulf2013}),
    _jointlv     ({_expand_dm("14-10")}, {holiday=>$eidula2013}),
    _jointlv     ({_expand_dm("26-12")}, {holiday=>$christmas}),
];

my $eidulf2014;
my $eidula2014;
$year_holidays{2014} = _make_tentative [ # tentative, no decree yet
    _h_mawlid    ({_expand_dm("14-01")}),
    _h_chnewyear ({_expand_dm("31-01")}, {hyear=>2565}),
    _h_goodfri   ({_expand_dm("18-04")}),
    _h_vesakha   ({_expand_dm("14-05")}, {hyear=>2558}),
    _h_isramiraj ({_expand_dm("25-05")}),
    _h_ascension ({_expand_dm("29-05")}),
    _h_nyepi     ({_expand_dm("18-04")}, {hyear=>1936}),

    ($eidulf2014 =
    _h_eidulf    ({_expand_dm("29-07")}, {hyear=>1435, day=>1})),
    _h_eidulf    ({_expand_dm("30-07")}, {hyear=>1435, day=>2}),
    ($eidula2014 =
    _h_eidula    ({_expand_dm("05-10")})),
    _h_hijra     ({_expand_dm("25-10")}, {hyear=>1436}),


    # not yet
    #_jointlv     ({_expand_dm("-")}, {holiday=>$eidulf2014}),
    #_jointlv     ({_expand_dm("-")}, {holiday=>$eidulf2014}),
    #_jointlv     ({_expand_dm("-")}, {holiday=>$eidulf2014}),
    #_jointlv     ({_expand_dm("-")}, {holiday=>$eidula2014}),
    #_jointlv     ({_expand_dm("-")}, {holiday=>$christmas}),
];

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
        next if $h0->{year_start} && $year < $h0->{year_start};
        next if $h0->{year_en}    && $year > $h0->{year_end};
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
        delete $h->{ind_name0};
        delete $h->{eng_name0};
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
    name => 'list_id_holidays',
    table_data => \@holidays,
    table_spec => {
        fields => {
            date => {
                schema => 'str*',
                index => 0,
                searchable => 0,
            },
            day => {
                schema => 'int*',
                index => 1,
            },
            month => {
                schema => 'int*',
                index => 2,
            },
            year => {
                schema => 'int*',
                index => 3,
            },
            dow => {
                schema => 'int*',
                summary => 'Day of week (1-7, Monday is 1)',
                index => 4,
            },
            eng_name => {
                schema => 'str*',
                summary => 'English name',
                index => 5,
                filterable => 0,
                sortable => 0,
            },
            ind_name => {
                schema => 'str*',
                summary => 'Indonesian name',
                index => 6,
                filterable => 0,
                sortable => 0,
            },
            en_aliases => {
                schema => ['array*'=>{of=>'str*'}],
                summary => 'English other names, if any',
                index => 7,
                filterable => 0,
                sortable => 0,
            },
            id_aliases => {
                schema => ['array*'=>{of=>'str*'}],
                summary => 'Indonesian other names, if any',
                index => 8,
                filterable => 0,
                sortable => 0,
            },
            is_holiday => {
                schema => 'bool*',
                index => 9,
            },
            is_joint_leave => {
                schema => 'bool*',
                summary => 'Whether this date is a joint leave day '.
                    '("cuti bersama")',
                index => 10,
            },
            tags => {
                schema => 'array*',
                index => 11,
                sortable => 0,
            },
        },
        pk => 'date',
    },
    langs => ['en_US', 'id_ID'],
);

die "BUG: Can't generate func: $res->[0] - $res->[1]"
    unless $res->[0] == 200;

my $AVAILABLE_YEARS =
    "Contains data from years $min_year to $max_year (joint leave days until\n".
    "$max_joint_leave_year).";

    my $meta = $res->[2]{meta};
$meta->{summary} = "List Indonesian holidays in calendar";
$meta->{description} = <<"_";

List holidays and joint leave days ("cuti bersama").

$AVAILABLE_YEARS

_

sub _check_date_arg {
    my ($date) = @_;
    if (ref($date) && $date->isa('DateTime')) {
        return $date;
    } elsif ($date =~ /\A(\d{4})-(\d{2})-(\d{2})\z/) {
        return DateTime->new(year=>$1, month=>$2, day=>$3);
    } else {
        return;
    }
}

$SPEC{enum_id_workdays} = {
    summary => 'Enumerate working days for a certain period',
    description => <<"_",

Working day is defined as day that is not Saturday*/Sunday/holiday/joint leave
days*. If work_saturdays is set to true, Saturdays are also counted as working
days. If observe_joint_leaves is set to false, joint leave days are also counted
as working days.

$AVAILABLE_YEARS

_
    args => {
        start_date => ['str*' => {
            summary => 'Starting date',
            description => <<'_',

Defaults to start of current month. Either a string in the form of "YYYY-MM-DD",
or a DateTime object, is accepted.

_
        }],
        end_date => ['str*' => {
            summary => 'End date',
            description => <<'_',

Defaults to end of current month. Either a string in the form of "YYYY-MM-DD",
or a DateTime object, is accepted.

_
        }],
        work_saturdays => ['bool' => {
            summary => 'If set to 1, Saturday is a working day',
            default => 0,
        }],
        observe_joint_leaves => ['bool' => {
            summary => 'If set to 0, do not observe joint leave as holidays',
            default => 1,
        }],
    },
};
sub enum_id_workdays {
    my %args = @_;

    # XXX args
    my $now = DateTime->now;
    my $som = DateTime->new(year => $now->year, month => $now->month, day => 1);
    my $eom = $som->clone->add(months=>1)->subtract(days=>1);
    my $start_date = _check_date_arg($args{start_date} // $som) or
        return [400, "Invalid start_date, must be string 'YYYY-MM-DD' ".
                    "or DateTime object"];
    my $end_date   = _check_date_arg($args{end_date} // $eom) or
        return [400, "Invalid end_date, must be string 'YYYY-MM-DD' ".
                    "or DateTime object"];
    for ($start_date, $end_date) {
        return [400, "Sorry, no data for year earlier than $min_year available"]
            if $_->year < $min_year;
        return [400, "Sorry, no data for year newer than $max_year available"]
            if $_->year > $max_year;
    }
    my $work_saturdays = $args{work_saturdays} // 0;
    my $observe_joint_leaves = $args{observe_joint_leaves} // 1;

    my @args;
    push @args, "year.min"=>$start_date->year;
    push @args, "year.max"=>$end_date->year;
    push @args, (is_holiday=>1) if !$observe_joint_leaves;
    my $res = list_id_holidays(@args);
    return wrapres([500, "Can't list holidays: "], $res)
        unless $res->[0] == 200;
    #use Data::Dump; dd $res;

    my @wd;
    my $dt = $start_date->clone->subtract(days=>1);
    while (1) {
        $dt->add(days=>1);
        next if $dt->day_of_week == 7;
        next if $dt->day_of_week == 6 && !$work_saturdays;
        last if DateTime->compare($dt, $end_date) > 0;
        my $ymd = $dt->ymd;
        next if $ymd ~~ @{$res->[2]};
        push @wd, $ymd;
    }

    [200, "OK", \@wd];
}

$meta = clone($SPEC{enum_id_workdays});
$meta->{summary} = "Count working days for a certain period";
$SPEC{count_id_workdays} = $meta;
sub count_id_workdays {
    my $res = enum_id_workdays(@_);
    return $res unless $res->[0] == 200;
    $res->[2] = @{$res->[2]};
    $res;
}

1;
# ABSTRACT: List Indonesian public holidays

=head1 SYNOPSIS

 use Calendar::Indonesia::Holiday qw(
     list_id_holidays
     enum_id_workdays
     count_id_workdays
 );

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
                            "tags.has" => ['religious'], detail=>1);

 # sample result
 [200, "OK", [
   {date       => '2011-02-16',
    day        => 16,
    month      => 2,
    year       => 2011,
    ind_name    => 'Maulid Nabi Muhammad',
    eng_name    => 'Mawlid',
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

 # enumerate working days for a certain period
 my $res = enum_id_workdays(year=>2011, month=>7);

 # idem, but returns a number instead. year/month defaults to current
 # year/month.
 my $res = count_id_workdays();


=head1 DESCRIPTION

This module provides functions to list Indonesian holidays.

This module uses L<Log::Any> logging framework.

This module has L<Rinci> metadata.


=head1 FAQ

=head2 What is "joint leave"?

Workers are normally granted 12 days of paid leave per year. They are free to
spend it on whichever days they want. The joint leave ("cuti bersama") is a
government program of recent years (since 2002) to recommend that some of these
leave days be spent together nationally on certain days, especially during
Lebaran (Eid Ul-Fitr). It is not mandated, but many do follow it anyway, e.g.
government civil workers, banks, etc. I am marking joint leave days with
is_joint_leave=1 and is_holiday=0, while the holidays themselves with
is_holiday=1, so you can differentiate/select both/either one.

=head2 Holidays before 2002?

Will be provided if there is demand and data source.

=head2 Holidays after (current year)+1?

Some religious holidays, especially Vesakha, are not determined yet. Joint leave
days are also usually decreed by the government in May/June of the preceding
year.


=head1 SEE ALSO

This API will also be available on GudangAPI, http://gudangapi.com/

=cut
