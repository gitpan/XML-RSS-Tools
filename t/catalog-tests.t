#!/usr/bin/env perl -w
#   $Id: catalog-tests.t,v 1.6 2007-01-28 15:00:01 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 12 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

my $rss_object = XML::RSS::Tools->new;

eval { $rss_object = XML::RSS::Tools->new(xml_catalog => './t/catalog.xml'); };
ok(!($@));

$rss_object->set_version(0);
$rss_object->set_auto_wash(0);

ok(! $rss_object->set_xml_catalog('duff'));
ok($rss_object->as_string("error"), 'File error: Cannot find duff');

eval { $rss_object->set_xml_catalog('./t/catalog.xml'); };
ok(!($@));

ok($rss_object->get_xml_catalog, './t/catalog.xml');

ok( ! $rss_object->set_xml_catalog('./t/no-catalog.xml') );

eval { $rss_object->rss_file('./t/test-0.91.rdf'); };
ok(!($@));

eval { $rss_object->xsl_file('./t/test.xsl'); };
ok (!($@));

if ($XML::LibXML::VERSION > 1.56) {
	# Skip on these versions, See RT bug #7912
	skip ("Your version of LibXML may have broken catalog support");
	skip ("Your version of LibXML may have broken catalog support");
	skip ("Your version of LibXML may have broken catalog support");
} else {
	eval { $rss_object->transform; };
	ok (!($@));

	my $output_html = $rss_object->as_string;
	ok($output_html);
	my $length = length $output_html;
	ok(($length == 844) || ($length == 1487));
}

exit;

