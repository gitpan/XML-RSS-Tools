#!/usr/bin/env perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 13 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $test_no = 2;


my $rss_object = XML::RSS::Tools->new;

eval { $rss_object->transform; };

if ($@ =~ /No XSLT loaded/) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

if ($rss_object->rss_file('foo.bar')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

if ($rss_object->as_string('error') ne "File error: Cannot find foo.bar") {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

if ($rss_object->rss_uri) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

if ($rss_object->rss_uri("wibble wobble")) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	Do some real tests

eval { $rss_object->rss_file('./t/test.rdf'); };

if ($@) {
	dump_debug($@, $test_no);
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
}

eval { $rss_object->rss_uri('file:./t/test.rdf'); };

if ($@) {
	dump_debug($@, $test_no);
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
}

eval { $rss_object->xsl_file('./t/test.xsl'); };

if ($@) {
	dump_debug($@, $test_no);
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
}

eval { $rss_object->xsl_uri('file:./t/test.xsl'); };

if ($@) {
	dump_debug($@, $test_no);
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
}

eval { $rss_object->transform; };

if ($@) {
	dump_debug($@, $test_no);
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
}

eval { $rss_object->transform; };

if ($@ =~ /Can't transform twice without a change/) {
	print "\nok ", $test_no++;
} else {
	dump_debug($@, $test_no);
	print "\nNOT ok", $test_no++;
}

my $output_html = $rss_object->as_string;
my $length = length $output_html;

if (($length == 1333) || ($length == 1487)) {
	print "\nok ", $test_no++;
} else {
	dump_debug($output_html, $test_no);
	print "\nNOT ok", $test_no++;
}

exit;

sub dump_debug {
	my $output  = shift;
	my $test_no = shift;
	
	open OUT, ">>", "./test-debug.out";
	print OUT "\n$test_no\t$output\n";
	close OUT;
}
