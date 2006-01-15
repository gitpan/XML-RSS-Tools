#
#	Configuration diagnostics idea taken from XML::Simple
#

#	$Id: config.t,v 1.3 2006-01-15 15:25:03 adam Exp $

use strict;
use Test::More tests => 1;

my @module_list = qw(
	XML::RSS
	XML::LibXML
	XML::LibXSLT
	XML::Parser
	LWP
	HTTP::GHTTP
	HTTP::Lite
	Test::Pod
	URI
	Test::Pod::Coverage
	Pod::Coverage
	Test::More);

my (%version);
foreach my $module (@module_list) {
	eval " require $module; ";
	unless ($@) {
		no strict 'refs';
		$version{$module} = ${$module . '::VERSION'} || "Unknown";
	} else {
		$version{module} = "Not Installed"
	}
}

eval ' use Config; $version{perl} = $config{version} ';
$version{perl} = $] if ($@);
unshift @module_list, 'perl';

diag(sprintf("\r# %-30s %s\n", 'Package', 'Version'));
foreach my $module (@module_list) {
	$version{$module} = "Not Installed" unless(defined($version{$module}));
	diag(sprintf(" %-30s %s\n", $module, $version{$module} ));
}

ok(1, "Dumped Configuration data");
