use strict;
use warnings;

use DateTime;
use DateTime::Calendar::Mayan;
use Test::More tests => 1;

{
	# make sure that seconds are preserved
	my $dt1 =  DateTime->now();
	my $dtcm = DateTime::Calendar::Mayan->from_object( object => $dt1 );
	my $dt2 =  DateTime->from_object( object => $dtcm );
	is( DateTime->compare( $dt1, $dt2 ), 0, "DT -> DTCM -> DT" );
}
