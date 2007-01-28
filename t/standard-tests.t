#!/usr/bin/env perl -w
#   $Id: standard-tests.t,v 1.5 2007-01-28 15:00:01 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 26 };

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

ok ($rss_object = XML::RSS::Tools->new(version => 0.91));
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

my $output = $rss_object->as_string;
my $length = length $output;
ok($length);
ok(($length == 1333) || ($length == 1487));

$output = $rss_object->as_string('rss');
$length = length $output;
ok($length);
ok($length == 1966);

$output = $rss_object->as_string('xsl');
$length = length $output;
ok($length);
ok($length == 1013);

ok ($rss_object->set_auto_wash(1), 1);
ok ($rss_object->set_auto_wash(), 1);
ok (! $rss_object->set_auto_wash(0));


exit;

