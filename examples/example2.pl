#!/usr/bin/perl
use strict;
use XML::RSS::Tools;

my $rss  = XML::RSS::Tools->new;
if ($rss->rss_uri(shift) &&
    $rss->xsl_file(shift) &&
    $rss->transform) {
    	print $rss->as_string
    } else {
    	print $rss->as_string('error')
    };
    