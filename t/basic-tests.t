#!/usr/bin/env perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 5 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $rss_object = XML::RSS::Tools->new;

ok($rss_object);
ok(!($rss_object->debug));
ok($rss_object->get_version, 0.91);
ok($rss_object->get_auto_wash);

exit;
