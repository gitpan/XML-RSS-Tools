#!/usr/bin/env perl -w
#   $Id: basic-tests.t,v 1.4 2004/04/21 18:11:26 adam Exp $
#	Before `make install' is performed this script should be runnable with
#	`make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 6 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################
ok($XML::RSS::Tools::VERSION eq "0.14");

my $rss_object = XML::RSS::Tools->new;

ok($rss_object);
ok(!($rss_object->debug));
ok($rss_object->get_version, 0.91);
ok($rss_object->get_auto_wash);

exit;
