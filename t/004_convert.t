use strict;
use warnings;

use DateTime;
use DateTime::Calendar::Mayan;
use Test::More tests => 4;

{
	my $dt = DateTime->now;
	my $object = DateTime::Calendar::Mayan->from_object( object => $dt );
	isa_ok( $object, 'DateTime::Calendar::Mayan' );
}

{
	# now is implimented with DateTime->now internaly
	# so we're going full circle here
	my $dtcm = DateTime::Calendar::Mayan->now;
	my $object = DateTime->from_object( object => $dtcm );
	isa_ok( $object, 'DateTime' );
}

{
	my $dt = DateTime->new(
			year => 2003,
			month => 4,
			day => 1,
			time_zone => 'UTC'
		);
	my $dtcm = DateTime::Calendar::Mayan->from_object( object => $dt );
	is( $dtcm->bktuk, '12.19.10.2.8', 'DT -> DTCM' ); 
}

{
	my $dtcm = DateTime::Calendar::Mayan->new(
			baktun  => 12,
			katun   => 19,
			tun     => 10,
			uinal   => 2,
			kin     => 8,
		);
	my $dt = DateTime->from_object( object => $dtcm );
	is( $dt->ymd, '2003-04-01', 'DTCM -> DT' );
}          
