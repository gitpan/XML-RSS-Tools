#!/usr/bin/env perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 4 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $test_no = 2;

my $rss_object = XML::RSS::Tools->new;

if ($rss_object->debug) {
	print "NOT ok ", $test_no++;
} else {
	print "ok ", $test_no++;
}

if ($rss_object->get_version == 0.91) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

if ($rss_object->get_auto_wash) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}
exit;

