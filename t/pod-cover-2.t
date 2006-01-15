#	$Id: pod-cover-2.t,v 1.1 2006-01-13 21:29:27 adam Exp $

use strict;
use Test::More;

eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;
plan tests => 1;

my $trustme = { trustme => [qr/^(xsl|rss)_/] };

pod_coverage_ok( "XML::RSS::Tools", $trustme);
