#!/usr/bin/env perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 9 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $test_no = 2;


my $rss_object = XML::RSS::Tools->new;

my $dummy_fh = FileHandle->new('foo.bar');
if ($rss_object->rss_fh($dummy_fh)) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

if ($rss_object->as_string('error') ne "FileHandle error: No FileHandle Object Passed") {
	dump_debug($rss_object->as_string('error'), $test_no);
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

if ($rss_object->xsl_fh($dummy_fh)) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

if ($rss_object->as_string('error') ne "FileHandle error: No FileHandle Object Passed") {
	dump_debug($rss_object->as_string('error'), $test_no);
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}


#	Do some real tests

my $rss_fh = FileHandle->new('./t/test.rdf');
my $xsl_fh = FileHandle->new('./t/test.xsl');

if ($rss_object->rss_fh($rss_fh)) {
	print "\nok ", $test_no++;
} else {
	dump_debug($rss_object->as_string('error'), $test_no);
	print "\nNOT ok", $test_no++;
} 

if ($rss_object->xsl_fh($xsl_fh)) {
	print "\nok ", $test_no++;
} else {
	dump_debug($rss_object->as_string('error'), $test_no);
	print "\nNOT ok", $test_no++;
}

eval { $rss_object->transform; };

if ($@) {
	dump_debug($@, $test_no);
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
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
