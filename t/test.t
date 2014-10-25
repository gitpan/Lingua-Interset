#!/usr/bin/env perl
# Testing DZ Interset 2.0.
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>
# Licence: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
# We must declare in advance how many tests we are going to perform.
# There are currently three tests per tagset driver.
use Test::More tests => 15*3;
use Lingua::Interset qw(get_driver_object);
use Lingua::Interset::Tagset;

# Run standard driver tests for all drivers that are part of the release.
###!!! Exclude selected tagsets that are too large: cs::conll cs::conll2009 cs::cnk cs::pmk
my @tagsets =
(
    'ar::padt', 'ar::conll', 'ar::conll2007',
    'bg::conll',
    'bn::conll',
    'cs::pdt', 'cs::ajka', 'cs::multext', 'cs::pmkkr',
    'en::penn', 'en::conll', 'en::conll2009',
    'hr::multext',
    'ja::ipadic',
    'mul::google'
);
foreach my $tagset (@tagsets)
{
    print STDERR ("Now testing the driver for the tagset '$tagset'...\n");
    my $driver = get_driver_object($tagset);
    ok(defined($driver), "tagset driver '$tagset' object defined");
    my $list = $driver->list();
    my $n = scalar(@{$list});
    ok($n > 0, "'$tagset' has non-empty list of tags");
    my @errors = $driver->test();
    if(@errors)
    {
        print STDERR (join('', @errors), "\n");
    }
    ok(!@errors, "'$tagset' driver integrity test");
}
