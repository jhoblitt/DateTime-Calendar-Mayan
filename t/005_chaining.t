use strict;
use warnings;

use DateTime;
use DateTime::Calendar::Mayan;
use Test::More tests => 2;

{
    # make sure that seconds are preserved
    my $dt1 =  DateTime->now();
    my $dtcm = DateTime::Calendar::Mayan->from_object( object => $dt1 );
    my $dt2 =  DateTime->from_object( object => $dtcm );
    is( DateTime->compare( $dt1, $dt2 ), 0, 'DT -> DTCM -> DT' );
}

{
    # make sure TZ gets converted to UTC correctly
    my $dt = DateTime->new(
            year    => 2003,
            month   => 4,
            day     => 3,
            hour    => 23,
            minute  => 0,
            second  => 0,
            time_zone => 'UTC',
        );
    $dt->set_time_zone( '+1200' );

    my $dtcm = DateTime::Calendar::Mayan->from_object( object => $dt );
    is( $dtcm->date, '12.19.10.2.11', 'DT->set_time_zone -> DTCM' );
}
