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
my $skip;
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
#	$rss->set_http_proxy(proxy_server => "http://marmot:3128/");		# HTTP PROXY TEST
	
	eval { require HTTP::GHTTP };
	$skip = "HTTP::GHTTP isn't installed" if $@;
	skip($skip, $rss->set_http_client('ghttp'));
	skip($skip, $rss->xsl_uri($uri));
	undef $skip;

	eval { require HTTP::Lite };
	$skip = "HTTP::Lite isn't installed" if $@;
	skip($skip, $rss->set_http_client('lite'));
	skip($skip, $rss->xsl_uri($uri));
	undef $skip;

	eval { require LWP };
	$skip = "LWP isn't installed" if $@;
	skip($skip, $rss->set_http_client('lwp'));
	skip($skip, $rss->xsl_uri($uri));
	undef $skip;

} else {
	for (1..7) {
		skip("Unable to locate a HTTP Server to test HTTP clients.", 1);
	};
}

exit;

