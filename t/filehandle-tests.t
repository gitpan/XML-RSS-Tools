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
