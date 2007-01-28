#!/usr/bin/env perl -w
#   $Id: http-tests.t,v 1.5 2007-01-28 15:00:01 adam Exp $

use Test;
use strict;
use warnings;
use IO::Socket;
use Sys::Hostname;

BEGIN { plan tests => 18 }

use XML::RSS::Tools;

my $hostname = hostname;
my $r_host   = "www.iredale.net";
my $socket   = IO::Socket::INET->new(
	PeerAddr => "$r_host:80",
	Timeout  => 10
);

#   1
my $rss = XML::RSS::Tools->new;
ok($rss);

my $uri;
if ($socket) {
	close($socket);
	$uri = "http://" . $r_host . "/";
} elsif ($socket = IO::Socket::INET->new(PeerAddr => "$hostname:80", Timeout  => 10)) {
	close($socket);
	$uri = "http://" . $hostname . "/";
}  

if ($uri) {
	
	eval { require HTTP::GHTTP };
	if ($@) {
		skip("HTTP::GHHTP isn't installed", 1);
		skip("HTTP::GHTTP isn't installed", 1);
	} else {
		ok($rss->set_http_client('ghttp'));
		ok($rss->xsl_uri($uri));
	}

	eval { require HTTP::Lite };
	if ($@) {
		skip("HTTP::Lite isn't installed", 1);
		skip("HTTP::Lite isn't installed", 1);
	} else {
		ok($rss->set_http_client('lite'));
		ok($rss->xsl_uri($uri));
	}

	eval { require LWP };
	if ($@) {
		skip("LWP isn't installed", 1);
		skip("LWP isn't installed", 1);
	} else {
		ok($rss->set_http_client('lwp'));
        ok($rss->get_http_client, 'lwp');
		ok($rss->xsl_uri($uri));
		ok($rss->{_http_client} = 'useragent');
		ok($rss->xsl_uri($uri));
        ok ($rss = XML::RSS::Tools->new(http_client => 'lwp'));
	}

} else {
	for (2..11) {
		skip("Unable to locate a HTTP Server to test HTTP clients.", 1);
	};
}

#   12-18
ok (! $rss->get_http_proxy);
ok ($rss->set_http_proxy(proxy_server => 'foo:3128'));
ok ($rss->get_http_proxy, 'foo:3128');
ok ($rss->set_http_proxy(
    'proxy_server' => 'bar:3128',
    'proxy_user'   => 'me'));
ok ($rss->get_http_proxy, 'bar:3128');
ok ($rss->set_http_proxy(
    'proxy_server' => 'bar:3128',
    'proxy_user'   => 'me',
    'proxy_pass'   => 'secret'));
ok ($rss->get_http_proxy, 'me:secret@bar:3128');

exit;
