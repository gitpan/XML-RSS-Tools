#!/usr/bin/env perl -w
#   $Id: filehandle-tests.t,v 1.2 2004/02/14 16:34:23 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 10 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $rss_object = XML::RSS::Tools->new;

my $dummy_fh = FileHandle->new('foo.bar');
ok(!($rss_object->rss_fh($dummy_fh)));
ok($rss_object->as_string('error'), "FileHandle error: No FileHandle Object Passed");
ok(!($rss_object->xsl_fh($dummy_fh)));
ok($rss_object->as_string('error'), "FileHandle error: No FileHandle Object Passed");

my $rss_fh = FileHandle->new('./t/test.rdf');
my $xsl_fh = FileHandle->new('./t/test.xsl');

ok($rss_object->rss_fh($rss_fh));
ok($rss_object->xsl_fh($xsl_fh));

eval { $rss_object->transform; };
ok(!($@));

my $output_html = $rss_object->as_string;
my $length = length $output_html;
ok($length);
ok(($length == 1333) || ($length == 1487));

exit;
