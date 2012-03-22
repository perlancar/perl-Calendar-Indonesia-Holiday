package Calendar::ID::Holiday;
use Calendar::Indonesia::Holiday;
# VERSION
our @ISA       = @Calendar::Indonesia::Holiday::ISA;
our @EXPORT    = @Calendar::Indonesia::Holiday::EXPORT;
our @EXPORT_OK = @Calendar::Indonesia::Holiday::EXPORT_OK;
our %SPEC      = %Calendar::Indonesia::Holiday::SPEC;
for my $f (keys %SPEC) {
    *{$f} = \&{"Calendar::Indonesia::Holiday::$f"};
}

1;
# ABSTRACT: Alias for Calendar::Indonesia::Holiday
