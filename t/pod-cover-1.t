#	$Id: pod-cover-1.t,v 1.1 2006-01-13 21:29:27 adam Exp $

use strict;
use Test;
use Pod::Coverage;

plan tests => 1;

my $pc = Pod::Coverage->new(
	package => 'XML::RSS::Tools',
	trustme => [qr/^(rss|xsl)_/]);
ok($pc->coverage == 1);
