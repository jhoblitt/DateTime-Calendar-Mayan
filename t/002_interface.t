use strict;

use DateTime::Calendar::Mayan;
use Test::More tests => 6;

{
	ok( my $dtcm = DateTime::Calendar::Mayan->new() );
	ok( DateTime::Calendar::Mayan->now() );
	ok( $dtcm->bktuk );
	ok( $dtcm->date );
	ok( DateTime::Calendar::Mayan->from_object( object => $dtcm ) );
	ok( my @values = $dtcm->utc_rd_values );
}
