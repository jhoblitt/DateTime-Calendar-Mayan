package DateTime::Calendar::Mayan;

use strict;

use vars qw( $VERSION );
$VERSION = '0.04';

use DateTime;
use Params::Validate qw( validate SCALAR OBJECT );
use constant MAYAN_EPOCH => -1137142;

sub new {
	my( $class ) = shift;

	my %args = validate( @_,
		{
			baktun	=> { type => SCALAR, default => 0 },
			katun	=> { type => SCALAR, default => 0 },
			tun	=> { type => SCALAR, default => 0 },
			uinal	=> { type => SCALAR, default => 0 },
			kin	=> { type => SCALAR, default => 0 },
			epoch => {
				type => OBJECT,
				can => 'utc_rd_values',
				optional => 1,
			},
		}
	);

	$class = ref( $class ) || $class;

	my $alt_epoch;
	if ( exists $args{ epoch } ) {
		my $object = $args{ epoch };
		delete $args{ epoch };
		$object = $object->clone->set_time_zone( 'floating' )
			if $object->can( 'set_time_zone' );

		$alt_epoch = ( $object->utc_rd_values )[ 0 ];
	}

	my $self = {
		epoch => $alt_epoch || MAYAN_EPOCH,
	};

	my $rd = _long_count2rd( $self, \%args );

	$self->{ rd } = $rd;

	return( bless( $self, $class ) );
}

sub now {
	my( $class ) = shift;

	$class = ref( $class ) || $class;

	my $dt = DateTime->now;
	my $dtcm = $class->from_object( object => $dt );

	return( $dtcm );
}

sub today {
	my( $class ) = shift;

	$class = ref( $class ) || $class;

	my $dt = DateTime->today;
	my $dtcm = $class->from_object( object => $dt );

	return( $dtcm );
}

# lifted from DateTime
sub clone { bless { %{ $_[0] } }, ref $_[0] }

sub _long_count2rd {
	my( $self, $lc ) = @_;

	my $rd = $self->{ epoch }
	+ $lc->{ baktun } * 144000
	+ $lc->{ katun }  * 7200
	+ $lc->{ tun }    * 360
	+ $lc->{ uinal }  * 20
	+ $lc->{ kin };

	return( $rd );
}

sub _rd2long_count {
	my( $self ) = shift;

	my %lc;
	my $long_count	= $self->{ rd } - $self->{ epoch };
	$lc{ baktun }	= _floor( $long_count / 144000 );
	my $day_baktun	= $long_count % 144000;
	$lc{ katun }	= _floor( $day_baktun / 7200 );
	my $day_katun	= $day_baktun % 7200;
	$lc{ tun }	= _floor( $day_katun / 360 );
	my $day_tun	= $day_katun % 360;
	$lc{ uinal }	= _floor( $day_tun / 20 );
	$lc{ kin }	= _floor( $day_tun % 20 );

	return( \%lc );
}

sub from_object {
	my( $class ) = shift;
	my %args = validate( @_,
		{
			object => {
				type => OBJECT,
				can => 'utc_rd_values',
			},
		},
	);

	$class = ref( $class ) || $class;

	my $object = $args{ object };
	$object = $object->clone->set_time_zone( 'floating' )
			if $object->can( 'set_time_zone' );

	my( $rd, $rd_secs ) = $object->utc_rd_values();

	my $dtcm_epoch = $object->mayan_epoch
			if $object->can( 'mayan_epoch' );

	my $self = {
		rd	=> $rd,
		rd_secs	=> $rd_secs,
		epoch	=> $dtcm_epoch->{ rd } || MAYAN_EPOCH,
	};

	return( bless( $self, $class ) );
}

sub utc_rd_values {
	my( $self ) = shift;

	# days utc, seconds utc,
	return( $self->{ rd }, $self->{ rd_secs } || 0 );
}

sub from_epoch {
	my( $class ) = shift;
	my %args = validate( @_,
		{
			epoch => { type => SCALAR },
		}
	);

	$class = ref( $class ) || $class;

	my $dt = DateTime->from_epoch( epoch => $args{ epoch } );

	my $self = $class->from_object( object => $dt );

	return( $self );
}

sub epoch {
	my( $self ) = shift;

	my $dt = DateTime->from_object( object => $self );

	return( $dt->epoch );
}

sub set_mayan_epoch {
	my( $self ) = shift;

	my %args = validate( @_,
		{
			object => {
				type => OBJECT,
				can => 'utc_rd_values',
			},
		},
	);

	my $object = $args{ object };
	$object = $object->clone->set_time_zone( 'floating' )
			if $object->can( 'set_time_zone' );

	# this can not handle rd values larger then a Mayan year
	# $self->{ rd } = _long_count2rd( $self, _rd2long_count( $self ) );

	$self->{ epoch } = ( $object->utc_rd_values )[ 0 ];
	if ( $self->{ epoch } > MAYAN_EPOCH ) {
		$self->{ rd } += abs( $self->{ epoch } - MAYAN_EPOCH );
	} else {
		$self->{ rd } -= abs( $self->{ epoch } - MAYAN_EPOCH );
	}

	return( $self );
}

sub mayan_epoch {
	my( $self ) = shift;

	my $new_self = $self->clone();

	$new_self->{ rd } = $self->{ epoch };
	$new_self->{ rd_secs } = 0;
	$new_self->{ epoch } = MAYAN_EPOCH;

	# calling from_object causes a method loop

	my $class = ref( $self );
	my $dtcm = bless( $new_self, $class );

	return( $dtcm );
}

sub set {
	my( $self ) = shift;

	my %args = validate( @_,
		{
			baktun	=> { type => SCALAR, optional => 1 },
			katun	=> { type => SCALAR, optional => 1 },
			tun	=> { type => SCALAR, optional => 1 },
			uinal	=> { type => SCALAR, optional => 1 },
			kin	=> { type => SCALAR, optional => 1 },
		}
	);

	my $lc = _rd2long_count( $self );

	$lc->{ baktun }	= $args{ baktun } if defined $args{ baktun };
	$lc->{ katun }	= $args{ katun } if defined $args{ katun };
	$lc->{ tun }	= $args{ tun } if defined $args{ tun };
	$lc->{ uinal }	= $args{ uinal } if defined $args{ uinal };
	$lc->{ kin }	= $args{ kin } if defined $args{ kin };

	$self->{ rd } =  _long_count2rd( $self, $lc ); 

	return( $self );
}

sub add {
	my( $self ) = shift;

	my %args = validate( @_,
		{
			baktun	=> { type => SCALAR, optional => 1 },
			katun	=> { type => SCALAR, optional => 1 },
			tun	=> { type => SCALAR, optional => 1 },
			uinal	=> { type => SCALAR, optional => 1 },
			kin	=> { type => SCALAR, optional => 1 },
		}
	);

	my $lc = _rd2long_count( $self );

	$lc->{ baktun }	+= $args{ baktun } if defined $args{ baktun };
	$lc->{ katun }	+= $args{ katun } if defined $args{ katun };
	$lc->{ tun }	+= $args{ tun } if defined $args{ tun };
	$lc->{ uinal }	+= $args{ uinal } if defined $args{ uinal };
	$lc->{ kin }	+= $args{ kin } if defined $args{ kin };

	$self->{ rd } =  _long_count2rd( $self, $lc ); 
	
	return( $self );
}

sub subtract {
	my( $self ) = shift;

	my %args = validate( @_,
		{
			baktun	=> { type => SCALAR, optional => 1 },
			katun	=> { type => SCALAR, optional => 1 },
			tun	=> { type => SCALAR, optional => 1 },
			uinal	=> { type => SCALAR, optional => 1 },
			kin	=> { type => SCALAR, optional => 1 },
		}
	);

	my $lc = _rd2long_count( $self );

	$lc->{ baktun }	-= $args{ baktun } if defined $args{ baktun };
	$lc->{ katun }	-= $args{ katun } if defined $args{ katun };
	$lc->{ tun }	-= $args{ tun } if defined $args{ tun };
	$lc->{ uinal }	-= $args{ uinal } if defined $args{ uinal };
	$lc->{ kin }	-= $args{ kin } if defined $args{ kin };

	$self->{ rd } =  _long_count2rd( $self, $lc ); 

	return( $self );
}

sub add_duration {
	my( $self, $duration ) = @_;

	my $dt = DateTime->from_object( object => $self );
	$dt->add_duration( $duration );

	my $new_self = $self->from_object( object => $dt );

	# if there is an alternate epoch defined don't touch it
	$self->{ rd } = $new_self->{ rd };
	$self->{ rd_secs } = $new_self->{ rd_secs };

	return( $self );
}

sub subtract_duration {
	my( $self, $duration ) = @_;

	my $dt = DateTime->from_object( object => $self );
	$dt->subtract_duration( $duration );

	my $new_self = $self->from_object( object => $dt );

	# if there is an alternate epoch defined don't touch it
	$self->{ rd } = $new_self->{ rd };
	$self->{ rd_secs } = $new_self->{ rd_secs };

	return( $self );
}

sub baktun {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self );

	if ( defined $arg ) {
		$lc->{ baktun } = $arg;
		$self->{ rd } = _long_count2rd( $self, $lc ); 

		return( $self );
	}

	# conversion from Date::Maya
	# set baktun to [1-13]
	$lc->{ baktun } %= 13;
	$lc->{ baktun } = 13 if $lc->{ baktun } == 0;

	return( $lc->{ baktun } );
}

*set_baktun = \&baktun;

sub katun {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self );

	if ( defined $arg ) {
		$lc->{ katun } = $arg;
		$self->{ rd } = _long_count2rd( $self, $lc ); 

		return( $self );
	}

	return( $lc->{ katun } );
}

*set_katun= \&katun;

sub tun {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self );

	if ( defined $arg ) {
		$lc->{ tun } = $arg;
		$self->{ rd } = _long_count2rd( $self, $lc ); 

		return( $self );
	}

	return( $lc->{ tun } );
}

*set_tun= \&tun;

sub uinal {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self );

	if ( defined $arg ) {
		$lc->{ uinal } = $arg;
		$self->{ rd } = _long_count2rd( $self, $lc ); 

		return( $self );
	}

	return( $lc->{ uinal } );
}

*set_uinal= \&uinal;

sub kin {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self );

	if ( defined $arg ) {
		$lc->{ kin } = $arg;
		$self->{ rd } = _long_count2rd( $self, $lc ); 

		return( $self );
	}

	return( $lc->{ kin } );
}

*set_kin= \&kin;

sub bktuk {
	my( $self, $sep ) = @_;
	$sep = '.' unless defined $sep;

	my $lc = _rd2long_count( $self ); 

	$lc->{ baktun } %= 13;
	$lc->{ baktun } = 13 if $lc->{ baktun } == 0;

	return(
		$lc->{ baktun } . $sep .
		$lc->{ katun } . $sep .
		$lc->{ tun } . $sep .
		$lc->{ uinal } . $sep .
		$lc->{ kin }
	);
}

*date = \&bktuk;

# lifted from DateTime::Calendar::Julian;
sub _floor {
	my $x  = shift;
	my $ix = int $x;
	if ($ix <= $x) {
		return $ix;
	} else {
		return $ix - 1;
	}
}

1;

__END__

=head1 NAME

DateTime::Calendar::Mayan - The Mayan Long Count Calendar

=head1 SYNOPSIS
 
   use DateTime::Calendar::Mayan
   # 2003-04-01 UTC
   my $dtcm = DateTime::Calendar::Mayan->new(
		baktun  => 12,
		katun   => 19,
		tun     => 10,
		uinal   => 2,
		kin     => 8,
		# alternate epoch
		epoch   => DateTime->new(
				year	=> -3113,
				month	=> 8,
				day	=> 13,
			);
	);

   print $dtcm->bktuk; 
   # prints 12.19.10.2.8

=head1 DESCRIPTION

An implementation of the Mayan Long Count Calendar as defined in
"Calendrical Calculations The Millennium Edition".  Supplemented
by "Frequently Asked Questions about Calendars".

=head1 METHODS

=over 4

=item * new( baktun => $scalar, ..., epoch => $object ) 

Accepts a hash representing the number of days since the Mayan epoch
and a "DateTime::Calendar" object specifying an alternate epoch.
All keys are optional.

   The units are:
   kin   = 1 day
   uinal = 20 days
   tun   = 360 days
   katun = 7200 days
   baktun = 144000 days

In the future pictuns, calabtuns, kinchiltuns, and alautuns may be accepted.

=item * now

Alternate constructor.  Uses DateTime->now to set the current date.

=item * today

Alternate constructor.  Uses DateTime->today to set the current date.

=item * clone

This object method returns a replica of the given object.

=item * from_object( object => $object )

Accepts a "DateTime::Calendar" object.  Although this calendar doesn't support
time it will preserve the time value of objects passed to it.  This prevents a
loss of precision when chaining calendars.

Note: Language support is not implemented.

=item * utc_rd_values

Returns the current UTC Rata Die days and seconds as a two element list. 

=item * from_epoch( epoch => $scalar )

Creates a new object from a number of seconds relative to midnight 1970-01-01.

=item * epoch

Returns the number of seconds since midnight 1970-01-01.

=item * set_mayan_epoch( object => $object )

Accepts a "DateTime::Calendar" object.  The epoch is set to this value
on a per object basis

The default epoch is:

Goodman-Martinez-Thompson
   Aug. 11, -3113 / Sep. 6, 3114 B.C.E. / 584,283 JD

=itme * mayan_epoch

Returns a "DateTime::Calendar::Mayan" object set to the current Mayan epoch.

=item * bktuk( $scalar )

Think DateTime::ymd.  Like ymd this method also accepts an optional
field separator string.

=item * date

Aliased to bktuk.

=item * baktun

=item * katun

=item * tun

=item * uinal

=item * kin( $scalar )

Gets/Sets the long count value of the function name.

=item * set_baktun

=item * set_katun

=item * set_tun

=item * set_uinal

=item * set_kin( $scalar )

Aliases to the combined accessor/mutators.

=item * set( baktun => $scalar, ... )

Accepts a hash specifying new long count values.  All units are optional.

=item * add

=item * subtract( baktun => $scalar, ... )

Accepts a hash specifying values to add or subject from the long count.  All units are optional.

=item * add_duration

=item * subtract_duration( $object )

Accepts a "DateTime::Duration" object and either adds or subtracts it from the
current date.   See the DateTime::Duration docs for more details.  

=back

=head1 BACKGROUND

TODO :)
 
=head1 CREDITS

Dave Rolsky (DROLSKY) for the DateTime project and carrying
us this far.

Eugene van der Pijll (PIJLL) for DateTime::Calendar::Julian
which I looked at more then once.

Calendrical Calculations
"The Millennium Edition"
By Edward M. Reingold & Nachum Dershowitz.
(ISBN 0-521-77752-6)

Abigail (ABIGAIL) for Date::Maya from which I confirmed the algorithm
for Mayan years.

"Frequently Asked Questions about Calendars" by
Claus TE<248>ndering.
   http://www.tondering.dk/claus/calendar.html

=head1 SUPPORT

Support for this module is provided via the datetime@perl.org email
list. See http://lists.perl.org/ for more details.

=head1 AUTHOR

Joshua Hoblitt <jhoblitt@cpan.org>

=head1 COPYRIGHT
 
Copyright (c) 2003 Joshua Hoblitt.  All rights reserved.  This program
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

datetime@perl.org mailing list

http://datetime.perl.org/

=cut
