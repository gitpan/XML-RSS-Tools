#!/usr/bin/env perl -w
#   $Id: basic-tests.t,v 1.5 2004/04/24 09:39:36 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 6 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################
ok($XML::RSS::Tools::VERSION eq "0.15");

my $rss_object = XML::RSS::Tools->new;

ok($rss_object);
ok(!($rss_object->debug));
ok($rss_object->get_version, 0.91);
ok($rss_object->get_auto_wash);

exit;
