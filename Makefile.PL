#	$Id: Makefile.PL,v 1.3 2004/04/21 18:10:32 adam Exp $

use ExtUtils::MakeMaker;
use strict;
use 5.006;
use Sys::Hostname;

my @tests;
my $test_list  = 't/config.t t/use.t t/basic-tests.t t/standard-tests.t t/version-tests.t t/filehandle-tests.t t/error-tests.t';
my $ghttp;
my $lite;

eval { require Test::Pod; };
$test_list .= ' t/pod-test.t' unless ($@);

print "Checking which HTTP clients you have installed...\n";

eval { require HTTP::GHTTP; };
if ($@) {
	print "You don't have HTTP::GHTTP installed.\nIt's not a requirment, but it's one\nof the fastest HTTP clients about.\n";
} else {
	print "Good you have HTTP::GHTTP installed.\n";
	$ghttp++;
}

eval { require HTTP::Lite; };
if ($@) {
	print "\nYou don't have HTTP::Lite installed either.\nIt's also not a requirment, but it's faster\nthan LWP.\n" unless $ghttp;
} else {
	$lite++;
	if ($ghttp) {
		print "You have HTTP::Lite installed too.\n";
	} else {
		print "\nBut you do have HTTP::Lite installed.\n";
	}
}

eval { require LWP };
if ($@) {
	print "\nYou don't have LWP installed!\n" unless $ghttp && $lite;
} else {
	if ($ghttp || $lite) {
		print "You have LWP installed too.\n";
	} else {
		print "\nBut at least you have LWP installed.\n";
	}
}

eval { require XML::LibXML };
if ($@) {
	print "\nYou don't have XML::LibXML installed!\n";
} else {
	if ($XML::LibXML::VERSION < 1.53) {
		print "Your version of LibXML is too old to support XML Catalog.\n";
		$test_list .= " t/no-catalog.t";
	} else {
		$test_list .= " t/catalog-tests.t";
	}
}

# Check if we have internet connection
# (I lifted this code from Net::DNS which lifted it from LWP...)
print "Probing for a HTTP Server, this may take a few seconds...\n";
require IO::Socket;
my $hostname =hostname;
my $s = IO::Socket::INET->new(
	PeerAddr => "www.iredale.net:80",
	Timeout  => 10
);

if ($s) {
	close($s);
	print "Good, you are connected to the Internet!\nWill test HTTP clients for you...\n";
	$test_list .= " t/http-tests.t";
} elsif ($s = IO::Socket::INET->new(PeerAddr => "$hostname:80", Timeout  => 10)) {
		print "Good, $hostname is running a HTTP server.\nWill test HTTP clients for you...\n";
		$test_list .= " t/http-tests.t";
		close($s);
} else {
	print "Can't reach the Internet or find a HTTP server on $hostname\nAborting HTTP client tests.\n";
}

push @tests, test => { TESTS => $test_list};
WriteMakefile(
    'NAME'		=> 'XML::RSS::Tools',
    'VERSION_FROM'	   => 'lib/XML/RSS/Tools.pm', 
    'PREREQ_PM'		   => {
    	URI            => 1.21,
    	'XML::LibXSLT' => 1.5,
    	'XML::LibXML'  => 1.5,
    	'XML::RSS'     => 1.0,
    	LWP            => 5.6,
    	},
    @tests,
    dist             => {
       COMPRESS      => 'gzip -9f',
       SUFFIX        => 'gz'
       }, 
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'lib/XML/RSS/Tools.pm', 
       AUTHOR        => 'Dr A. J. Trickett <atrickett@cpan.org>') : ()),
);

