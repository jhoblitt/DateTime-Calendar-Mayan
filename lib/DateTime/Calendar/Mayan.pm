package DateTime::Calendar::Mayan;

use strict;

use vars qw( $VERSION );
$VERSION = '0.03';

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
		}
	);

	my $rd = _long_count2rd( \%args );

	my $self = bless( { rd => $rd }, $class );

	return( $self );
}

sub now {
	my $dt = DateTime->now;
	my $dtcm = DateTime::Calendar::Mayan->from_object( object => $dt );

	return( $dtcm );
}

# lifted from DateTime
sub clone { bless { %{ $_[0] } }, ref $_[0] }

sub _long_count2rd {
	my( $lc ) = @_;

	my $rd = MAYAN_EPOCH
	+ $lc->{ baktun } * 144000
	+ $lc->{ katun }  * 7200
	+ $lc->{ tun }    * 360
	+ $lc->{ uinal }  * 20
	+ $lc->{ kin };

	return( $rd );
}

sub _rd2long_count {
	my( $rd ) = @_;

	my %lc;
	my $long_count	= $rd - MAYAN_EPOCH;
	$lc{ baktun }	= _floor( $long_count / 144000 );
	my $day_baktun	= $long_count % 144000;
	$lc{ katun }	= _floor( $day_baktun / 7200 );
	my $day_katun	= $day_baktun % 7200;
	$lc{ tun }	= _floor( $day_katun / 360 );
	my $day_tun	= $day_katun % 360;
	$lc{ uinal }	= _floor( $day_tun / 20 );
	$lc{ kin }	= _floor( $day_tun % 20 );

	# conversion from Date::Maya
	# set baktun to [1-13], 13 == 0
	$lc{ baktun } %= 13;
	$lc{ baktun } = 13 if $lc{ baktun } == 0;

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

	my $object = $args{ object };
	$object = $object->clone->set_time_zone( 'floating' )
			if $object->can( 'set_time_zone' );

	my( $rd, $rd_secs ) = $object->utc_rd_values();

	my $self = bless( { rd => $rd, rd_secs => $rd_secs }, $class );

	return( $self );
}

sub utc_rd_values {
	my( $self ) = @_;

	# days utc, seconds utc,
	return( $self->{ rd }, $self->{ rd_secs } || 0 );
}

sub set {
	my( $self, %args ) = @_;

	my $lc = _rd2long_count( $self->{ rd } );

	$lc->{ baktun }	= $args{ baktun } if defined $args{ baktun };
	$lc->{ katun }	= $args{ katun } if defined $args{ katun };
	$lc->{ tun }	= $args{ tun } if defined $args{ tun };
	$lc->{ uinal }	= $args{ uinal } if defined $args{ uinal };
	$lc->{ kin }	= $args{ kin } if defined $args{ kin };

	$self->{ rd } =  _long_count2rd( $lc ); 

	return( $self );
}

sub add {
	my( $self, %args ) = @_;

	my $lc = _rd2long_count( $self->{ rd } );

	$lc->{ baktun }	+= $args{ baktun } if defined $args{ baktun };
	$lc->{ katun }	+= $args{ katun } if defined $args{ katun };
	$lc->{ tun }	+= $args{ tun } if defined $args{ tun };
	$lc->{ uinal }	+= $args{ uinal } if defined $args{ uinal };
	$lc->{ kin }	+= $args{ kin } if defined $args{ kin };

	$self->{ rd } =  _long_count2rd( $lc ); 
	
	return( $self );
}

sub subtract {
	my( $self, %args ) = @_;

	my $lc = _rd2long_count( $self->{ rd } );

	$lc->{ baktun }	-= $args{ baktun } if defined $args{ baktun };
	$lc->{ katun }	-= $args{ katun } if defined $args{ katun };
	$lc->{ tun }	-= $args{ tun } if defined $args{ tun };
	$lc->{ uinal }	-= $args{ uinal } if defined $args{ uinal };
	$lc->{ kin }	-= $args{ kin } if defined $args{ kin };

	$self->{ rd } =  _long_count2rd( $lc ); 

	return( $self );
}

sub baktun {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self->{ rd } );

	if ( defined $arg ) {
		$lc->{ baktun } = $arg;
		$self->{ rd } = _long_count2rd( $lc ); 

		return( $self );
	}

	return( $lc->{ baktun } );
}

sub katun {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self->{ rd } );

	if ( defined $arg ) {
		$lc->{ katun } = $arg;
		$self->{ rd } = _long_count2rd( $lc ); 

		return( $self );
	}

	return( $lc->{ katun } );
}

sub tun {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self->{ rd } );

	if ( defined $arg ) {
		$lc->{ tun } = $arg;
		$self->{ rd } = _long_count2rd( $lc ); 

		return( $self );
	}

	return( $lc->{ tun } );
}

sub uinal {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self->{ rd } );

	if ( defined $arg ) {
		$lc->{ uinal } = $arg;
		$self->{ rd } = _long_count2rd( $lc ); 

		return( $self );
	}

	return( $lc->{ uinal } );
}

sub kin {
	my( $self, $arg ) = @_;

	my $lc = _rd2long_count( $self->{ rd } );

	if ( defined $arg ) {
		$lc->{ kin } = $arg;
		$self->{ rd } = _long_count2rd( $lc ); 

		return( $self );
	}

	return( $lc->{ kin } );
}

sub bktuk {
	my( $self, $sep ) = @_;
	$sep = '.' unless defined $sep;

	my $lc = _rd2long_count( $self->{ rd } ); 

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
              );

   print $dtcm->bktuk; 
   # prints 12.19.10.2.8

=head1 DESCRIPTION

An implementation of the Mayan Long Count Calendar as
defined in "Calendrical Calculations The Millennium Edition".

=head1 METHODS

=over 4

=item * new( %hash ) 

Accepts a hash representing the number of days since the Mayan epoch.

   The units are:
   kin   = 1 day
   uinal = 20 days
   tun   = 360 days
   katun = 7200 days
   baktun = 144000 days

In the future pictuns, calabtuns, kinchiltuns, and alautuns may be accepted.

=item * now

Alternate constructor.  Uses DateTime->now to set the current date.

=item * from_object( object => $object, ... )

Accepts a "DateTime::Calendar" object.  Although this calendar doesn't support time it will preserve the time value of objects passed to it.  This prevents a loss of precision when chaining calendars.

Note: Language support is not implemented.

=item * utc_rd_values

Returns the current UTC Rata Die days and seconds as a two element list. 

=item * bktuk( $str )

Think DateTime::ymd.  Like ymd this method also accepts an optional
field separator string.

=item * date

Aliased to bktuk.

=item * baktun

=item * katun

=item * tun

=item * uinal

=item * kin( $str )

Gets/Sets the long count value of the function name.

=item * set( %hash )

Accepts a hash specifying new long count values.  All units are optional.

=item * add

=item * subtract( %hash )

Accepts a hash specifying values to add or subject from the long count.  All units are optional.

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

Abigail (ABIGAIL) for Date::Maya from which I got the algorithm
for Mayan years.

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
