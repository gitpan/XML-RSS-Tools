#!/usr/bin/env perl -w
#   $Id: basic-tests.t,v 1.6 2006-01-13 21:29:27 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 6 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################
ok($XML::RSS::Tools::VERSION eq "0.16");

my $rss_object = XML::RSS::Tools->new;

ok($rss_object);
ok(!($rss_object->debug));
ok($rss_object->get_version, 0.91);
ok($rss_object->get_auto_wash);

exit;
