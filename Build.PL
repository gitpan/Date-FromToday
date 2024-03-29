use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Date::FromToday',
    license             => 'perl',
    dist_author         => q{Adam Wohld <adam@spatialsystems.org>},
    dist_version_from   => 'lib/Date/FromToday.pm',
    build_requires => {
        'Test::More' => 0,
	'Moose' => 0,
	'Moose::Util::TypeConstraints' => 0,
        'namespace::autoclean' => 0,
        'Carp' => 0,
        'Date::Calc' => 0,
        'Test::Moose' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Date-FromToday-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
