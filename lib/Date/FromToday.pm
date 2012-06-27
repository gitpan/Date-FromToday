package Date::FromToday;

our $VERSION = '0.03';

use strict;

use Moose;
use Moose::Util::TypeConstraints;
use Carp;
use Date::Calc qw{ Today Day_of_Week Add_Delta_Days check_date };
use Data::Dumper;

use namespace::autoclean;


subtype 'ValidDate'
    => as 'Str'
    => where { _check_date( $_ ) }
    => message { "This date ($_), does not match MM_DD_YYYY!" };


has '_calculated_date' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_calculated_date_builder'
);

has 'day' => (
    is => 'ro',
    isa => 'Num',
    lazy => 1,
    builder => '_day_builder'
);

has 'month' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_month_builder'
);

has 'year' => (
    is => 'ro',
    isa => 'Num',
    lazy => 1,
    builder => '_year_builder'
);


has 'move' => (
    is => 'ro',
    isa => 'Num',
    required => 1,
);

has 'date_string_format' => (
    is => 'ro',
    isa => 'Str',
    default => '{M}_{D}_{Y}',
);

has 'month_translator' => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
);

has 'year_digits' => (
    is => 'ro',
    isa => enum([qw[ 1 2 3 4 ]]),
    default => '4',
);

#  used to force the date instead of today
has 'force_today' => (
    is => 'ro',
    isa => 'ValidDate',
);

has 'leading_zeros' => (
    is => 'ro',
    isa => enum([qw[ 0 1 ]]),
    default => 1,
);

#  check the date we're forcing is a valid date
sub _check_date{
    my ( $date ) = @_;

    my @date_elements = split "_", $date;

    return check_date( $date_elements[2], $date_elements[0], $date_elements[1]);
}

#  return the $self->force_today date formatted as Today();
sub _force_today {
    my ( $self ) = @_;

    my ( $month, $day, $year ) = split "_", $self->force_today;

    return ( $year, $month, $day );
}

#  internally calculate the date for later output
sub _calculated_date_builder {
    my ( $self ) = @_;

    #  calculate the date
    my ( $year, $month, $day ) = defined($self->force_today)? $self->_force_today : Today();
    ( $year, $month, $day ) = Add_Delta_Days( $year, $month, $day, $self->move );

    #  if you want leading zeros, do it
    ( $month, $day ) = ( sprintf("%02d", $month), sprintf("%02d", $day) ) if $self->leading_zeros;

    #  format the year for how many digits of the year you want
    my @year = split "", $year;
    foreach ( 0 .. ( 4 - ( ($self->year_digits) + 1 ) ) ) {
        shift @year;
    }
    $year = join "", @year;

    #return "02_11_2011";
    return "$month\_$day\_$year";
}

sub _day_builder {
        my ( $self ) = @_;

    my @date_elements = split "_", $self->_calculated_date;

    return $date_elements[1];
}

sub _month_builder {
    my ( $self ) = @_;

    my @date_elements = split "_", $self->_calculated_date;

    if ( defined( $self->month_translator )) {
        if ( defined(${$self->month_translator}[( $date_elements[0] - 1 ) ]) ) {

            return ${$self->month_translator}[ ( $date_elements[0]-1 ) ];

        }
    }

    return $date_elements[0];
}

sub _year_builder {
    my ( $self ) = @_;

    my @date_elements = split "_", $self->_calculated_date;

    return $date_elements[2];
}

#  still to do... work with format atrubute to make it
sub date_string {
    my  ( $self ) = @_;

    my $date_string = $self->date_string_format;
    my ( $month, $day, $year ) = ( $self->month, $self->day, $self->year );

    $date_string =~ s/{M}/$month/g;
    $date_string =~ s/{D}/$day/g;
    $date_string =~ s/{Y}/$year/g;

    return $date_string;
}


=head1 NAME

Date::FromToday - Calculate the date in the past or future X days from today

=head1 VERSION

Version 0.03

=head1 SYNOPSIS

C<Date::FromToday> is a Perl module for calculating a date in the past or
future X number of days from today.  It allows for custom formatting of the
date string with month/day/year placement, seperators, leading zeros, month
translation, forcing today's date, number of digits in the year.


    use Date::FromToday;

    my $date = Date::FromToday->new( move => -1 );

    #  prints yesterdays date in MM_DD_YYYY
    print $date->date_string;


-or-

    Date::FromToday->new(
        move => -1,
        month_translator => [
            qw(
                Jan Feb Mar Apr May June July Aug Sept Oct Nov Dec
            )
        ],
        date_string_format => '{M}.{D}.{Y}',
        leading_zeros => 0,
        year_digits => 2,
    );

    #  prints yesterday's date looking like Jan_1_11


=head1 CONSTRUCTOR AND STARTUP

=head2 new()

Creates and returns Date::FromToday object.

    my $date = Date::FromToday->new( move => -1 );

Here are the parms for Date::FromToday

=over 4

=item * C<< move => $days_to_add_or_subtract >>

Adds or subtracts days to the current date.  Negative numbers move back
in time, positive move into future. Required.

=item * C<< format => M_D_Y >>

Decides on how to format the date_string method.  M will be replaced by the
Month, D with the Day, and Y with the Year.
The delimiter is also configureable, M*D^Y = 12*31^2021

=item * C<< leading_zeros => [0|1] >>

Determines if leading zeros will be added. Default = 1 which means it will be
done.

=item * C<< month_translator => $month_names_list_ref >>

Determines how the month will be displayed:
    month_translator => [
        qw(
            Jan Feb Mar Apr May June July Aug Sept Oct Nov Dec
        )
    ],

=item * C<< force_today => MM_DD_YYYY >>

You can also force the current date.  Must be in MM_DD_YYYY format.

=item * C<< year_digits => [1|2|3|4] >>

Specifies the number of digits in the year:
4 ~ 1895
3 ~  895
2 ~   95
1 ~    5

=back

=head1 METHODS

=head2 day

Returns the calculated day, either numeric or translated from

=head2 month

Returns the calculated month

=head2 year

Returns the calculated year


=head2 date_string

Returns the date in a string as specified by the 'format' param.



=head1 AUTHOR

Adam H Wohld, C<< <adam at jamradar.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-date-fromtoday at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-FromToday>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::FromToday


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-FromToday>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-FromToday>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-FromToday>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-FromToday/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Adam H Wohld.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut


1;  #  end Date::FromToday
