#!/usr/bin/env perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 7 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $test_no = 2;

my $rss_object = XML::RSS::Tools->new;

$rss_object->set_version(0);
$rss_object->set_auto_wash(0);

eval { $rss_object->set_xml_catalog('./t/catalog.xml'); };
ok(!($@));

eval { $rss_object->rss_file('./t/test-0.91.rdf'); };
ok(!($@));

eval { $rss_object->xsl_file('./t/test.xsl'); };
ok (!($@));

eval { $rss_object->transform; };
ok (!($@));

my $output_html = $rss_object->as_string;
ok($output_html);
my $length = length $output_html;
ok(($length == 844) || ($length == 1487));

exit;

