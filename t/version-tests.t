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

#	By default the initial version is 0.91
ok($rss_object->get_version, 0.91);

#	There is no version 5 so it should fail
ok(!($rss_object->set_version(5)));

#	As the last set fail it should still be 0.91
ok($rss_object->get_version, 0.91);

#	There is an RSS version of 2.0
ok($rss_object->set_version(2.0));

#	As the last set should work it should be 2.0
ok($rss_object->get_version, 2.0);

#	Trying to set nothing should do nothing, but not raise an error
ok(!($rss_object->set_version()));

#	As the last set did nothing it should still be 2.0
ok($rss_object->get_version, 2.0);

#	Turn off normalisation by setting to 0
ok($rss_object->set_version(0));

#	As the last set it to 0 it should be 0
my $version = $rss_object->get_version;
ok(defined($version) && not $version);

exit;
