use strict;

use DateTime::Calendar::Mayan;
use Test::More tests => 14;

{
	ok( my $dtcm = DateTime::Calendar::Mayan->new() );
	ok( $dtcm = DateTime::Calendar::Mayan->now() );
	ok( $dtcm->bktuk );
	ok( $dtcm->date );
	ok( DateTime::Calendar::Mayan->from_object( object => $dtcm ) );
	ok( my @values = $dtcm->utc_rd_values );
	ok( $dtcm->baktun);
	ok( $dtcm->katun );
	ok( $dtcm->tun );
	ok( $dtcm->uinal );
	ok( $dtcm->kin );
	ok( $dtcm->set( baktun => 1 ) );
	ok( $dtcm->add( baktun => 1 ) );
	ok( $dtcm->subtract( baktun => 1 ) );
}
