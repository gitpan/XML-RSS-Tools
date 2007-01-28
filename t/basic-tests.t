#!/usr/bin/env perl -w
#   $Id: basic-tests.t,v 1.9 2007-01-26 21:40:41 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 9 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

ok($XML::RSS::Tools::VERSION eq "0.20");

my $rss_object = XML::RSS::Tools->new;

ok(defined $rss_object);
ok($rss_object->isa('XML::RSS::Tools'));
ok(!($rss_object->debug));
ok($rss_object->get_version, 0.91);
ok($rss_object->get_auto_wash);

$rss_object = XML::RSS::Tools->new(debug => 1);
ok($rss_object->debug);

$rss_object = XML::RSS::Tools->new(auto_wash => 1);
ok($rss_object->get_auto_wash);

exit;
