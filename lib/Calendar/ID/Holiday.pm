package Calendar::ID::Holiday;
use Calendar::Indonesia::Holiday;
our %SPEC = %Calendar::Indonesia::Holiday::SPEC;
for my $f (keys %SPEC) {
    *{$f} = \&{"Calendar::Indonesia::Holiday::$f"};
}

1;
# ABSTRACT: Alias for Calendar::Indonesia::Holiday
