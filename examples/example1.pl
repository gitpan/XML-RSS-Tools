#!/bin/perl/bin/perl

#
#	Example1 for XML::RSS::Tools
#

use strict;
use warnings;
use CGI;
use CGI::Carp;
use XML::RSS::Tools;

$|++;

my $site = shift || '';
my $style= shift || '';
my $q    = CGI->new;
my $rss  = XML::RSS::Tools->new;
my $path_xsl = "./";

undef $q unless $q->request_method();

if ($q) {
	$site  = $q->param("site") if $q->param("site");
	$style = $q->param("style") if $q->param("style");
	print $q->header, $q->start_html(-title=>"RSS News Feed");
	tad ("Usage: newsfeed.pl?site=foo;style=bar\n", $q) unless $site && $style;
} else {
	tad ("Usage: newsfeed.pl (<RSS File> | <URI>) <XSLT stylesheet>\n") unless $site && $style;
}
$style = $path_xsl . $style;

if (! $rss->xsl_file($style)) {tad ($rss->as_string('error'), $q)};

if ($site =~ /^http/i) {
	if (! $rss->rss_uri($site)) {tad ($rss->as_string('error'), $q)};
} else {
	if (! $rss->rss_file($site)) {tad ($rss->as_string('error'), $q)};
}

if ($rss->transform) {
	print $rss->as_string;
} else {
	tad ($rss->as_string('error'), $q);
}

exit;

#
#	Called after script ends.
#

END {
	%ENV = ();
	printf "\n<!-- Transformation complete in %d seconds. -->\n", time - $^T;
	print $q->end_html if $q;
	}


#
#	Gracefully die
#

sub tad {
	my $error = shift || "Unkown Error";
	my $q     = shift;

	if ($q) {
		print $q->hr, $q->h1("RSS 2 HTML via XSL-T error:"), $q->h2($error), $q->hr;
		croak $error;
	} else {
		print "RSS 2 HTML via XSL-T error:\n\t$error";
		exit;
	}
}