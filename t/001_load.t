use Test::More tests => 4;

BEGIN { use_ok( 'DateTime' ); }
BEGIN { use_ok( 'DateTime::Calendar::Mayan' ); }

my $object = DateTime->now();
isa_ok ($object, 'DateTime');

my $object = DateTime::Calendar::Mayan->new();
isa_ok ($object, 'DateTime::Calendar::Mayan');
