#!/usr/bin/env perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
use strict;
use warnings;

BEGIN { plan tests => 44 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $test_no = 2;
my $error;
my $rss_object = XML::RSS::Tools->new;

#	2	Try and transform with nothing

eval { $rss_object->transform; };

if ($@ =~ /No XSLT loaded/) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#	3/4	Load a good XSLT file and re-transform
eval { $rss_object->xsl_file('./t/test.xsl'); };

if ($@) {
	dump_debug($@, $test_no);
	print "\nNOT ok", $test_no++;
} else {
	print "\nok ", $test_no++;
}

eval { $rss_object->transform; };

if ($@ =~ /No RSS loaded/) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#	5	Load a duff RSS file

if ($rss_object->rss_file('foo.bar')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	6	Did we get the right error?

if ($rss_object->as_string('error') ne "File error: Cannot find foo.bar") {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	7	Load a duff XSL file

if ($rss_object->xsl_file('foo.bar')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	8	Did we get the right error?

if ($rss_object->as_string('error') ne "File error: Cannot find foo.bar") {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	9	Load an empty RSS file

if ($rss_object->rss_file()) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	10	Did we get the right error?

if ($rss_object->as_string('error') ne "File error: No file name supplied") {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	11	Load an empty XSL file

if ($rss_object->xsl_file()) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	12	Did we get the right error?

if ($rss_object->as_string('error') ne "File error: No file name supplied") {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	13	If we ask for a silly stringify do we get an error?

eval { $rss_object->as_string('fake call') };

if ($@ =~ "Unknown mode: fake call") {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#	14	If we requrest a blank RSS URI

if ($rss_object->rss_uri) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	15	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne "No URI provided.") {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	16	If we requrest a blank XSL URI

if ($rss_object->xsl_uri) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	17	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne "No URI provided.") {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	18	If we Request a duff RSS URI

if ($rss_object->rss_uri("wibble wobble")) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	19	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne "No URI Scheme in wibble%20wobble.") {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	20	If we Request a duff XSL URI

if ($rss_object->xsl_uri("wibble wobble")) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	21	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne "No URI Scheme in wibble%20wobble.") {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	22 Try and load a RSS file that's a folder

if ($rss_object->rss_file('./')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	23	Did we get the right error?

if ($rss_object->as_string('error') ne "File error: ./ isn't a real file") {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	24 Try and load a XSL file that's a folder

if ($rss_object->xsl_file('./')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	25	Did we get the right error?

if ($rss_object->as_string('error') ne "File error: ./ isn't a real file") {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	26	If we requrest an unsupported RSS URI

if ($rss_object->rss_uri('mailto:foo@bar')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	27	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne "Unsupported URI Scheme (mailto).") {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	28	If we requrest an unsupported XSL URI

if ($rss_object->xsl_uri('mailto:foo@bar')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	29	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne "Unsupported URI Scheme (mailto).") {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	30	Check for an empty RSS File

if ($rss_object->rss_file('./t/empty-file')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	31	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne "File error: ./t/empty-file is zero bytes long") {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	32	Check for an empty XSL File

if ($rss_object->xsl_file('./t/empty-file')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	33	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne "File error: ./t/empty-file is zero bytes long") {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	34	Check for an empty RSS File by URI

if ($rss_object->rss_uri('file:./t/empty-file')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	35	Did we get the right error?

$error = $rss_object->as_string('error');
$error =~ s#\\#/#g;
if ($error ne 'File error: ./t/empty-file is zero bytes long') {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	36	Check for an empty XSL File by URI

if ($rss_object->xsl_uri('file:./t/empty-file')) {
	print "\nNOT ok ", $test_no++;
} else {
	print "\nok ", $test_no++;
}

#	37	Did we get the right error?

$error = $rss_object->as_string('error');
$error =~ s#\\#/#g;
if ($error ne 'File error: ./t/empty-file is zero bytes long') {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	38	Does setting a duff HTTP client cause an error?

if ($rss_object->set_http_client("Internet Explorer")) {
	print "\nNOT ok ", $test_no++;
} else{
	print "\nok ", $test_no++;
}

#	39	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne 'Not configured for HTTP Client Internet Explorer') {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	40	Does setting a null HTTP client cause an error?

if ($rss_object->set_http_client()) {
	print "\nNOT ok ", $test_no++;
} else{
	print "\nok ", $test_no++;
}

#	41	Did we get the right error?

$error = $rss_object->as_string('error');
if ($error ne 'No HTTP Client requested') {
	dump_debug($error, $test_no);
	print "\nNOT ok ", $test_no++;
	undef $error;
} else {
	print "\nok ", $test_no++;
}

#	42	Test a duff constructor, bad HTTP client

eval {
	$rss_object = XML::RSS::Tools->new(http_client => "Internet Explorer");
};

if ($@ =~ /Not configured for HTTP Client Internet Explorer/) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#	43	Test a duff constructor, bad RSS Version

eval {
	$rss_object = XML::RSS::Tools->new(version => 51);
};

if ($@ =~ /No such version of RSS 51/) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

#	44	Test a duff constructor, bad RSS Version

eval {
	$rss_object = XML::RSS::Tools->new(xml_catalog => "duff");
};

if ($@ =~ /Unable to read XML catalog duff/) {
	print "\nok ", $test_no++;
} else {
	print "\nNOT ok ", $test_no++;
}

exit;



sub dump_debug {
	my $output  = shift;
	my $test_no = shift;
	
	open OUT, ">>", "./test-debug.out";
	print OUT "\n$test_no\t$output\n";
	close OUT;
}
