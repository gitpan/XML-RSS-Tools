#!/usr/bin/env perl -w
use Test;
use strict;
use warnings;
use IO::Socket;
use Sys::Hostname;

BEGIN { plan tests => 7 }

use XML::RSS::Tools;

my $hostname = hostname;
my $r_host   = "www.iredale.net";
my $socket   = IO::Socket::INET->new(
	PeerAddr => "$r_host:80",
	Timeout  => 10
);

my $uri;
if ($socket) {
	close($socket);
	$uri = "http://" . $r_host . "/";
} elsif ($socket = IO::Socket::INET->new(PeerAddr => "$hostname:80", Timeout  => 10)) {
	close($socket);
	$uri = "http://" . $hostname . "/";
}  

if ($uri) {

	my $rss = XML::RSS::Tools->new;
	ok($rss);
	
	eval { require HTTP::GHTTP };
	if ($@) {
		skip("HTTP::GHTTP isn't installed");
		skip("HTTP::GHTTP isn't installed");
	} else {
		ok($rss->set_http_client('ghttp'));
		ok($rss->xsl_uri($uri));
	}

	eval { require HTTP::Lite };
	if ($@) {
		skip("HTTP::Lite isn't installed");
		skip("HTTP::Lite isn't installed");
	} else {
		ok($rss->set_http_client('lite'));
		ok($rss->xsl_uri($uri));
	}

	eval { require LWP };
	if ($@) {
		skip("LWP isn't installed");
		skip("LWP isn't installed");
	} else {
		ok($rss->set_http_client('lwp'));
		ok($rss->xsl_uri($uri));
	}

} else {
	for (1..7) {
		skip("Unable to locate a HTTP Server to test HTTP clients.");
	};
}

exit;

