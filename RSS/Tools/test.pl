# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use Strict;
use warnings;

BEGIN { plan tests => 11 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $test_no = 2;


#	First off create our object and test it's default values, test 2-5

	my $rss_object = XML::RSS::Tools->new;

	if ($rss_object->debug) {
		print "NOT ok ", $test_no++, "\tDebug level fail\n";
	} else {
		print "ok ", $test_no++, "\tDebug level okay\n";
	}

	if ($rss_object->get_version == 0.91) {
		print "ok ", $test_no++, "\tRSS Level okay\n";
	} else {
		print "NOT ok ", $test_no++, "\tRSS Level fail\n";
	}

	if ($rss_object->get_auto_wash) {
		print "ok ", $test_no++, "\tAuto Wash level okay\n";
	} else {
		print "NOT ok ", $test_no++, "\tAuto Wash level fail\n";
	}

#	Test that we can't do anything with it yet, test 5-7

eval { $rss_object->transform; };

if ($@ =~ /No XSL-T loaded/) {
	print "ok ", $test_no++, "\tWon't transform when it's got nothing to transform, okay\n";
} else {
	print "NOT ok ", $test_no++, "\tFailed to detect that we have nothing to transform\n";
}

if ($rss_object->rss_file('foo.bar')) {
	print "NOT ok ", $test_no++, "\tFailed to deal with bad file name correctly\n";
} else {
	print "ok ", $test_no++, "\tBad file name correctly dealt with\n";
}

if ($rss_object->as_string(error) ne "File error: Cannot find file foo.bar") {
	print "NOT ok ", $test_no++, "\tFailed to report bad file error correctly\n";
} else {
	print "ok ", $test_no++, "\tBad file name error correctly reported\n";
}

#	Do some real tests, tests 8-11

eval { $rss_object->rss_file('test.rdf'); };

if ($@) {
	print "NOT ok", $test_no++, "\tFailed to load and parse an RDF file\n";
} else {
	print "ok ", $test_no++, "\tLoaded and parsed an RDF file\n";
}

eval { $rss_object->xsl_file('test.xsl'); };

if ($@) {
	print "NOT ok", $test_no++, "\tFailed to load an XSL-Template\n";
} else {
	print "ok ", $test_no++, "\tLoaded an XSL-Template okay\n";
}

eval { $rss_object->transform; };

if ($@) {
	print "NOT ok", $test_no++, "\tFailed to perform XSL-T on RSS file\n";
} else {
	print "ok ", $test_no++, "\tPerfomed XSL-T on RSS file okay\n";
}

my $output_html = $rss_object->as_string;

if (length $output_html == 1333) {
	print "ok ", $test_no++, "\tTransformed file expected length\n";
} else {
	print "NOT ok", $test_no++, "\tTransformed file unexpected length\n";
}

exit;

