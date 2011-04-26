use inc::Module::Install;

name     'Date-FromToday';
all_from 'lib/Date/FromToday.pm';
author   q{Adam H Wohld <adam@jamradar.com>};
license  'perl';

#  needed for build only
build_requires 'Test::More';
build_requires 'Test::Moose';

#  needed for module
requires 'Date::Calc';
requires 'Moose';
requires 'Moose::Util::TypeConstraints';
requires 'Carp';
requires 'namespace::autoclean';

auto_install;

WriteAll;
