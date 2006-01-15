#!/usr/bin/env perl -w
#   $Id: error-tests.t,v 1.4 2006-01-15 15:25:03 adam Exp $

use Test;
use strict;
use warnings;

BEGIN {
    plan tests => 44;
    use URI::file;
    if ($URI::VERSION >= 1.32) {
		no warnings;
        $URI::file::DEFAULT_AUTHORITY = undef;
    }
};

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

my $rss_object = XML::RSS::Tools->new;

#	2	Try and transform with nothing
eval { $rss_object->transform; };
ok($@ =~ /No XSLT loaded/);

#	3/4	Load a good XSLT file and re-transform
eval { $rss_object->xsl_file('./t/test.xsl'); };
ok(!($@));

eval { $rss_object->transform; };
ok($@ =~ /No RSS loaded/);

#	5	Load a duff RSS file
ok(!($rss_object->rss_file('foo.bar')));

#	6	Did we get the right error?
ok($rss_object->as_string('error'), "File error: Cannot find foo.bar");

#	7	Load a duff XSL file
ok(!($rss_object->xsl_file('foo.bar')));

#	8	Did we get the right error?
ok($rss_object->as_string('error'), "File error: Cannot find foo.bar");

#	9	Load an empty RSS file
ok(!($rss_object->rss_file()));

#	10	Did we get the right error?
ok($rss_object->as_string('error'), "File error: No file name supplied");

#	11	Load an empty XSL file
ok(!($rss_object->xsl_file()));

#	12	Did we get the right error?
ok($rss_object->as_string('error'), "File error: No file name supplied");

#	13	If we ask for a silly stringify do we get an error?
eval { $rss_object->as_string('fake call') };
ok($@ =~ "Unknown mode: fake call");

#	14	If we requrest a blank RSS URI
ok(!($rss_object->rss_uri));

#	15	Did we get the right error?
ok($rss_object->as_string('error'), "No URI provided.");

#	16	If we requrest a blank XSL URI
ok(!($rss_object->xsl_uri));

#	17	Did we get the right error?
ok($rss_object->as_string('error'), "No URI provided.");

#	18	If we Request a duff RSS URI
ok(!($rss_object->rss_uri("wibble wobble")));

#	19	Did we get the right error?
ok($rss_object->as_string('error'), "No URI Scheme in wibble%20wobble.");

#	20	If we Request a duff XSL URI
ok(!($rss_object->xsl_uri("wibble wobble")));

#	21	Did we get the right error?
ok($rss_object->as_string('error'), "No URI Scheme in wibble%20wobble.");

#	22 Try and load a RSS file that's a folder
ok(!($rss_object->rss_file('./')));

#	23	Did we get the right error?
ok($rss_object->as_string('error'), "File error: ./ isn't a real file");

#	24 Try and load a XSL file that's a folder
ok(!($rss_object->xsl_file('./')));

#	25	Did we get the right error?
ok($rss_object->as_string('error'), "File error: ./ isn't a real file");

#	26	If we requrest an unsupported RSS URI
ok(!($rss_object->rss_uri('mailto:foo@bar')));

#	27	Did we get the right error?
ok($rss_object->as_string('error'), "Unsupported URI Scheme (mailto).");

#	28	If we requrest an unsupported XSL URI
ok(!($rss_object->xsl_uri('mailto:foo@bar')));

#	29	Did we get the right error?
ok($rss_object->as_string('error'), "Unsupported URI Scheme (mailto).");

#	30	Check for an empty RSS File
ok(!($rss_object->rss_file('./t/empty-file')));

#	31	Did we get the right error?
ok($rss_object->as_string('error'), "File error: ./t/empty-file is zero bytes long");

#	32	Check for an empty XSL File
ok(!($rss_object->xsl_file('./t/empty-file')));

#	33	Did we get the right error?
ok($rss_object->as_string('error'), "File error: ./t/empty-file is zero bytes long");

#	34	Check for an empty RSS File by URI
ok(!($rss_object->rss_uri('file:./t/empty-file')));

#	35	Did we get the right error?
my $error = $rss_object->as_string('error');
$error =~ s#\\#/#g;
ok($error, 'File error: ./t/empty-file is zero bytes long');

#	36	Check for an empty XSL File by URI
ok(!($rss_object->xsl_uri('file:./t/empty-file')));

#	37	Did we get the right error?
$error = $rss_object->as_string('error');
$error =~ s#\\#/#g;
ok($error, 'File error: ./t/empty-file is zero bytes long');

#	38	Does setting a duff HTTP client cause an error?
ok(!($rss_object->set_http_client("Internet Explorer")));

#	39	Did we get the right error?
ok($rss_object->as_string('error'), 'Not configured for HTTP Client Internet Explorer');

#	40	Does setting a null HTTP client cause an error?
ok(!($rss_object->set_http_client()));

#	41	Did we get the right error?
ok($rss_object->as_string('error'), 'No HTTP Client requested');

#	42	Test a duff constructor, bad HTTP client
eval { $rss_object = XML::RSS::Tools->new(http_client => "Internet Explorer"); };

ok($@ =~ /Not configured for HTTP Client Internet Explorer/);

#	43	Test a duff constructor, bad RSS Version
eval { $rss_object = XML::RSS::Tools->new(version => 51); };
ok($@ =~ /No such version of RSS 51/);

#	44 Test bad XML/RSS strings
eval { $rss_object->rss_string("<rss</rss>"); };
ok ($@ =~ /not well-formed \(invalid token\) at line 1, column 4, byte 4/);

exit;
