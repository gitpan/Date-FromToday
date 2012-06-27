#!perl -T

use strict;
use warnings;

use Test::More tests => 33;
use Date::Calc qw{ Today Add_Delta_Days };
use Test::Moose;

BEGIN {
    use_ok( 'Date::FromToday' ) || print "Bail out!";
}

diag( "Testing Date::FromToday $Date::FromToday::VERSION, Perl $], $^X" );

#  test Moose
{
    ok(
        my $date = Date::FromToday->new( move => 10 ), 'create date object'
    );

    #  calculate the date
    my @today = Today();
    my ( $year, $month, $day ) = Add_Delta_Days( @today[ 0 .. 2 ], 10 );
    ( $month, $day ) = ( sprintf("%02d", $month), sprintf("%02d", $day) );

    cmp_ok(
        $date->date_string,
        'eq',
        "$month\_$day\_$year",
        "got yesterday: " . $date->date_string
    );

    has_attribute_ok(
        $date, 'move', 'has move attribute'
    );

    has_attribute_ok(
        $date, '_calculated_date', 'has _calculated_date attribute'
    );

    has_attribute_ok(
        $date, 'day', 'has day attribute'
    );

    has_attribute_ok(
        $date, 'month', 'has month attribute'
    );

    has_attribute_ok(
        $date, 'year', 'has year attribute'
    );

    has_attribute_ok(
        $date, 'date_string_format', 'has date_string_format attribute'
    );

    has_attribute_ok(
        $date, 'month_translator', 'has month_translator attribute'
    );

    has_attribute_ok(
        $date, 'year_digits', 'has year_digits attribute'
    );

    has_attribute_ok(
        $date, 'force_today', 'has force_today attribute'
    );

    has_attribute_ok(
        $date, 'leading_zeros', 'has leading_zeros attribute'
    );

}

#  check for yesterdays date
{
    ok(
        my $date = Date::FromToday->new( move => -1 ), 'create date object'
    );

    #  calculate the date
    my @today = Today();
    my ( $year, $month, $day ) = Add_Delta_Days( @today[ 0 .. 2 ], -1 );
    ( $month, $day ) = ( sprintf("%02d", $month), sprintf("%02d", $day) );

    cmp_ok(
        $date->date_string,
        'eq',
        "$month\_$day\_$year",
        "got yesterday: " . $date->date_string
    );
}

#  check for tomorrows date, no leading zeros
{
    ok(
        my $date = Date::FromToday->new( move => 1, leading_zeros => 0 ), 'create date object'
    );

    #  calculate the date
    my @today = Today();
    my ( $year, $month, $day ) = Add_Delta_Days( @today[ 0 .. 2 ], 1 );

    cmp_ok(
        $date->date_string,
        'eq',
        "$month\_$day\_$year",
        "got tomorrow, no leading zeros: " . $date->date_string
    );
}

#  force date to Y2K, get the last day of 1999
{
    ok(
        my $date = Date::FromToday->new( move => -1, force_today => '01_01_2000' ), 'create date object'
    );

    cmp_ok(
        $date->date_string,
        'eq',
        "12_31_1999",
        "force_today to 01/01/2000, go back 1 day: got " . $date->date_string . ", expected 12_31_1999"
    );

}

#  make year digits 3
{
    ok(
        my $date = Date::FromToday->new(
            move => -1,
            force_today => '01_01_2346',
            year_digits => 3,
        ), 'create date object'
    );

    cmp_ok(
        $date->date_string,
        'eq',
        "12_31_345",
        "use only 3 digits in the year: got " . $date->date_string . ", expected 12_31_345"
    );

}

#  make year digits 2
{
    ok(
        my $date = Date::FromToday->new(
            move => -1,
            force_today => '01_01_2346',
            year_digits => 2,
        ), 'create date object'
    );

    cmp_ok(
        $date->date_string,
        'eq',
        "12_31_45",
        "use only 2 digits in the year: got " . $date->date_string . ", expected 12_31_45"
    );

}

#  make year digits 1
{
    ok(
        my $date = Date::FromToday->new(
            move => 1,
            force_today => '01_01_2345',
            year_digits => 1,
        ), 'create date object'
    );

    cmp_ok(
        $date->date_string,
        'eq',
        "01_02_5",
        "use only 1 digit in the year: got " . $date->date_string . ", expected 01_02_5"
    );

}

#  try month translator
{
    ok(
        my $date = Date::FromToday->new(
            move => -1,
            force_today => '01_01_2000',
            month_translator => [
                qw(
                    Jan Feb Mar Apr May June July Aug Sept Oct Nov Dec
                )
            ],
        ), 'create date object'
    );

    cmp_ok(
        $date->date_string,
        'eq',
        "Dec_31_1999",
        "test month translator: got " . $date->date_string . ", expected Dec_31_1999"
    );

}

#  try month translator
{
    ok(
        my $date = Date::FromToday->new(
            move => 1,
            force_today => '01_01_2015',
            month_translator => [
                qw(
                    Jan Feb Mar Apr May June July Aug Sept Oct Nov Dec
                )
            ],
        ), 'create date object'
    );

    cmp_ok(
        $date->date_string,
        'eq',
        "Jan_02_2015",
        "test month translator: got " . $date->date_string . ", expected Jan_02_2015"
    );

}

#  check date string formatter
{
    ok(
        my $date = Date::FromToday->new(
            move => 1,
            force_today => '01_01_2015',
            month_translator => [
                qw(
                    Jan Feb Mar Apr May June July Aug Sept Oct Nov Dec
                )
            ],
        ), 'create date object'
    );

    cmp_ok(
        $date->date_string,
        'eq',
        "Jan_02_2015",
        "test month translator: got " . $date->date_string . ", expected Jan_02_2015"
    );

}

#  check for tomorrows date with custom format
{
    ok(
        my $date = Date::FromToday->new(
            move => 1,
            date_string_format => '{M}-{D}-{Y}:{M}'
        ), 'create date object'
    );

    #  calculate the date
    my @today = Today();
    my ( $year, $month, $day ) = Add_Delta_Days( @today[ 0 .. 2 ], 1 );
    ( $month, $day ) = ( sprintf("%02d", $month), sprintf("%02d", $day) );

    cmp_ok(
        $date->date_string,
        'eq',
        $month .'-'. $day .'-'. $year .':'. $month,
        "custom format = " .  $date->date_string_format . " -> translated to: " . $date->date_string
    );
}
