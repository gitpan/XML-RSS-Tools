#!/usr/bin/env perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 12 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $test_no = 2;


#	First off create our object and test it's default values, test 2-5

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

#	Test that we can't do anything with it yet, test 5-8

eval { $rss_object->transform; };

if ($@ =~ /No XSL-T loaded/) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

if ($rss_object->rss_file('foo.bar')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

if ($rss_object->as_string('error') ne "File error: Cannot find file foo.bar") {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

if ($rss_object->rss_uri) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	Do some real tests, tests 9-12

eval { $rss_object->rss_file('./t/test.rdf'); };

if ($@) {
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
}

eval { $rss_object->xsl_file('./t/test.xsl'); };

if ($@) {
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
}

eval { $rss_object->transform; };

if ($@) {
	print "\nNOT ok", $test_no++;
	dump_debug($@);
} else {
	print "\nok ", $test_no++;
}

my $output_html = $rss_object->as_string;
my $length = length $output_html;

if (($length == 1333) || ($length == 1487)) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok", $test_no++;
	dump_debug($output_html);
}

exit;

sub dump_debug {
	my $output = shift;
	open OUT, ">>", "./test-debug.out";
	print OUT "\n$output\n";
	close OUT;
}
