package Date::FromToday;

use warnings;
use strict;

use Moose;
use Moose::Util::TypeConstraints;
use Carp;
use Date::Calc qw{ Today Day_of_Week Add_Delta_Days check_date };
use Data::Dumper;

use namespace::autoclean;



has '_calculated_date' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1
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

has 'date_string' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy => 1,
    builder => '_date_string_builder'
);

has 'move' => (
    is => 'ro',
    isa => 'Num',
    required => 1,
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


#  internally calculate the date for later output
sub _calculated_date_builder {
    my ( $self ) = @_;

    #  calculate the date
    my ( $year, $month, $day ) =  Today();
    ( $year, $month, $day ) = Add_Delta_Days( $year, $month, $day, $self->move );

    #  if you want leading zeros, do it
    ( $month, $day ) = ( sprintf("%02d", $month), sprintf("%02d", $day) ) if $self->leading_zeros;
    $month = $self->leading_zeros;    

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
    return $date_elements[0];
}

sub _year_builder {
    my ( $self ) = @_;
    my @date_elements = split "_", $self->_calculated_date;
    return $date_elements[2];
}

#  make the date string ie. 3_24_2011
sub _date_string_builder {
    my  ( $self ) = @_;
    return $self->month . '_' . $self->day . '_' . $self->year;
}


package Main;

use strict;
use warnings;

my $date = Date::FromToday->new( move => -1, leading_zeros => 1 );

print "Date:  " . $date->date_string . "\n";
print "Leading Zeros:  " . $date->leading_zeros . "\n";
print "Move:  " . $date->move . "\n";



