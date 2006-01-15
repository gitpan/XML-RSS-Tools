#!/usr/bin/env perl -w
#   $Id: standard-tests.t,v 1.3 2006-01-15 15:25:03 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 18 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

my $rss_object = XML::RSS::Tools->new;

ok(defined $rss_object);
ok($rss_object->isa('XML::RSS::Tools'));

eval { $rss_object->transform; };

ok($@ =~ /No XSLT loaded/);
ok(!($rss_object->rss_file('foo.bar')));
ok($rss_object->as_string('error'), "File error: Cannot find foo.bar");
ok(!($rss_object->rss_uri));
ok(!($rss_object->rss_uri("wibble wobble")));

eval { $rss_object->rss_string('<rss version="0.91"></rss>'); };
ok(!($@));

eval { $rss_object->rss_file('./t/test.rdf'); };
ok(!($@));

eval { $rss_object->rss_uri('file:./t/test.rdf'); };
ok(!($@));

eval { $rss_object->xsl_string("<xsl></xsl>"); };
ok(!($@));

eval { $rss_object->xsl_file('./t/test.xsl'); };
ok(!($@));

eval { $rss_object->xsl_uri('file:./t/test.xsl'); };
ok(!($@));

eval { $rss_object->transform; };
ok(!($@));

eval { $rss_object->transform; };
ok($@ =~ /Can't transform twice without a change/);

my $output_html = $rss_object->as_string;
my $length = length $output_html;
ok($length);
ok(($length == 1333) || ($length == 1487));

exit;

