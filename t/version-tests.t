#!/usr/bin/env perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 10 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $test_no = 2;

my $rss_object = XML::RSS::Tools->new;

#
#	By default the initial version is 0.91
#
if ($rss_object->get_version == 0.91) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#
#	There is no version 5 so it should fail
#
if ($rss_object->set_version(5)) {
	print "\nNOT ok ", $test_no++;
} else{
	print "\nok ", $test_no++;
}

#
#	As the last set fail it should still be 0.91
#
if ($rss_object->get_version == 0.91) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#
#	There is an RSS version of 2.0
#
if ($rss_object->set_version(2.0)) {
	print "\nok ", $test_no++;
} else{
	print "\nNOT ok ", $test_no++;
}

#
#	As the last set should work it should be 2.0
#
if ($rss_object->get_version == 2.0) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#
#	Trying to set nothing should do nothing, but not raise an error
#
if ($rss_object->set_version()) {
	print "\nNOT ok ", $test_no++;
} else{
	print "\nok ", $test_no++;
}

#
#	As the last set did nothing it should still be 2.0
#

if ($rss_object->get_version == 2.0) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#
#	Turn off normalisation by setting to 0
#

if ($rss_object->set_version(0)) {
	print "\nok ", $test_no++;
} else{
	print "\nNOT ok ", $test_no++;
}

#
#	As the last set it to 0 it should be 0
#
my $version = $rss_object->get_version;
if (defined($version) && not $version) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

exit;

