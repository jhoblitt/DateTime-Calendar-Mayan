use strict;

use DateTime::Duration;
use DateTime::Calendar::Mayan;
use Test::More tests => 27;

{
    ok( my $dtcm = DateTime::Calendar::Mayan->new() );
    ok( $dtcm = DateTime::Calendar::Mayan->now() );
    ok( $dtcm = DateTime::Calendar::Mayan->today() );
    ok( $dtcm->clone() );
    ok( DateTime::Calendar::Mayan->from_object( object => $dtcm ) );
    ok( my @values = $dtcm->utc_rd_values );
    ok( $dtcm->epoch );
    ok( $dtcm->from_epoch( epoch => 0 ) );
    ok( $dtcm->mayan_epoch );
    ok( $dtcm->set_mayan_epoch( object => $dtcm ) );
    ok( $dtcm->bktuk );
    ok( $dtcm->date );
    ok( $dtcm->baktun);
    ok( $dtcm->katun );
    ok( $dtcm->tun );
    ok( $dtcm->uinal );
    ok( $dtcm->kin );
    ok( $dtcm->set_baktun);
    ok( $dtcm->set_katun );
    ok( $dtcm->set_tun );
    ok( $dtcm->set_uinal );
    ok( $dtcm->set_kin );
    ok( $dtcm->set( baktun => 1 ) );
    ok( $dtcm->add( baktun => 1 ) );
    ok( $dtcm->subtract( baktun => 1 ) );
    ok( $dtcm->add_duration( DateTime::Duration->new( days => 1 ) ));
    ok( $dtcm->subtract_duration( DateTime::Duration->new( days => 1 ) ));
}
