#	$Id: Build.PL,v 1.3 2007-01-26 22:24:06 adam Exp $

use Module::Build;

my @tests  = qw(t/config.t t/use.t t/basic-tests.t t/standard-tests.t t/version-tests.t t/filehandle-tests.t t/error-tests.t);
my $ghttp;
my $lite;

print "Checking which extra POD testing modules you have installed...\n";

eval { require Test::Pod; };
push @tests, 't/pod-test.t' unless ($@);

eval { require Pod::Coverage; };
push @tests, 't/pod-cover-1.t' unless ($@);

eval { require Test::Pod::Coverage; };
push @tests, 't/pod-cover-2.t' unless ($@);

eval { require IO::Capture; };
if (! $@) {
    push @tests, 't/debug-tests.t';
    push @tests, 't/no-debug-tests.t';
};

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
		push @tests, "t/no-catalog.t";
	} else {
		push @tests, "t/catalog-tests.t";
	}
}

# Check if we have internet connection
# (I lifted this code from Net::DNS which lifted it from LWP...)
print "\n\nProbing for a HTTP Server, this may take a few seconds...\n\n";
require IO::Socket;
my $hostname = hostname;
my $s = IO::Socket::INET->new(
	PeerAddr => "www.iredale.net:80",
	Timeout  => 10
);

if ($s) {
	close($s);
	print "Good, you are connected to the Internet!\nWill test HTTP clients for you...\n";
	push @tests, "t/http-tests.t";
} elsif ($s = IO::Socket::INET->new(PeerAddr => "$hostname:80", Timeout  => 10)) {
		print "Good, $hostname is running a HTTP server.\nWill test HTTP clients for you...\n";
		push @tests, "t/http-tests.t";
		close($s);
} else {
	print "Can't reach the Internet or find a HTTP server on $hostname\nAborting HTTP client tests.\n";
}

my $build = Module::Build->new(
	module_name => 'XML::RSS::Tools',
	license     => 'gpl',
	test_files  => \@tests,
	requires    => {
		'perl'  => '5.6.1',
		'URI'	=> '1.31',
        'LWP'   => '5.7',
        'XML::LibXSLT' => '1.5',
        'XML::LibXML'  => '1.5',
        'XML::RSS'     => '1.0',
	},
);

$build->create_build_script;
