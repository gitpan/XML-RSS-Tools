#!/usr/bin/env perl -w
#   $Id: error-tests.t,v 1.5 2007-01-28 15:00:01 adam Exp $

use Test;
use strict;
use warnings;

BEGIN {
    plan tests => 46;
    use URI::file;
    if ($URI::VERSION >= 1.32) {
		no warnings;
        $URI::file::DEFAULT_AUTHORITY = undef;
    }
};

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

my $rss_object = XML::RSS::Tools->new;

ok (! $rss_object->as_string('error') );

#	3	Try and transform with nothing
eval { $rss_object->transform; };
ok($@ =~ /No XSLT loaded/);

#	4	Load a good XSLT file and re-transform
eval { $rss_object->xsl_file('./t/test.xsl'); };
ok(!($@));

eval { $rss_object->transform; };
ok($@ =~ /No RSS loaded/);

#	6	Load a duff RSS file
ok(!($rss_object->rss_file('foo.bar')));

#	7	Did we get the right error?
ok($rss_object->as_string('error'), "File error: Cannot find foo.bar");

#	8	Load a duff XSL file
ok(!($rss_object->xsl_file('foo.bar')));

#	9	Did we get the right error?
ok($rss_object->as_string('error'), "File error: Cannot find foo.bar");

#	10	Load an empty RSS file
ok(!($rss_object->rss_file()));

#	11	Did we get the right error?
ok($rss_object->as_string('error'), "File error: No file name supplied");

#	12	Load an empty XSL file
ok(!($rss_object->xsl_file()));

#	13	Did we get the right error?
ok($rss_object->as_string('error'), "File error: No file name supplied");

#	14	If we ask for a silly stringify do we get an error?
eval { $rss_object->as_string('fake call') };
ok($@ =~ "Unknown mode: fake call");

#	15	If we requrest a blank RSS URI
ok(!($rss_object->rss_uri));

#	16	Did we get the right error?
ok($rss_object->as_string('error'), "No URI provided.");

#	17	If we requrest a blank XSL URI
ok(!($rss_object->xsl_uri));

#	18	Did we get the right error?
ok($rss_object->as_string('error'), "No URI provided.");

#	19	If we Request a duff RSS URI
ok(!($rss_object->rss_uri("wibble wobble")));

#	20	Did we get the right error?
ok($rss_object->as_string('error'), "No URI Scheme in wibble%20wobble.");

#	21	If we Request a duff XSL URI
ok(!($rss_object->xsl_uri("wibble wobble")));

#	22	Did we get the right error?
ok($rss_object->as_string('error'), "No URI Scheme in wibble%20wobble.");

#	23 Try and load a RSS file that's a folder
ok(!($rss_object->rss_file('./')));

#	24	Did we get the right error?
ok($rss_object->as_string('error'), "File error: ./ isn't a real file");

#	25 Try and load a XSL file that's a folder
ok(!($rss_object->xsl_file('./')));

#	26	Did we get the right error?
ok($rss_object->as_string('error'), "File error: ./ isn't a real file");

#	27	If we requrest an unsupported RSS URI
ok(!($rss_object->rss_uri('mailto:foo@bar')));

#	28	Did we get the right error?
ok($rss_object->as_string('error'), "Unsupported URI Scheme (mailto).");

#	29	If we requrest an unsupported XSL URI
ok(!($rss_object->xsl_uri('mailto:foo@bar')));

#	30	Did we get the right error?
ok($rss_object->as_string('error'), "Unsupported URI Scheme (mailto).");

#	31	Check for an empty RSS File
ok(!($rss_object->rss_file('./t/empty-file')));

#	32	Did we get the right error?
ok($rss_object->as_string('error'), "File error: ./t/empty-file is zero bytes long");

#	33	Check for an empty XSL File
ok(!($rss_object->xsl_file('./t/empty-file')));

#	34	Did we get the right error?
ok($rss_object->as_string('error'), "File error: ./t/empty-file is zero bytes long");

#	35	Check for an empty RSS File by URI
ok(!($rss_object->rss_uri('file:./t/empty-file')));

#	36	Did we get the right error?
my $error = $rss_object->as_string('error');
$error =~ s#\\#/#g;
ok($error, 'File error: ./t/empty-file is zero bytes long');

#	37	Check for an empty XSL File by URI
ok(!($rss_object->xsl_uri('file:./t/empty-file')));

#	38	Did we get the right error?
$error = $rss_object->as_string('error');
$error =~ s#\\#/#g;
ok($error, 'File error: ./t/empty-file is zero bytes long');

#	39	Does setting a duff HTTP client cause an error?
ok(!($rss_object->set_http_client("Internet Explorer")));

#	40	Did we get the right error?
ok($rss_object->as_string('error'), 'Not configured for HTTP Client Internet Explorer');

#	41	Does setting a null HTTP client cause an error?
ok(!($rss_object->set_http_client()));

#	42	Did we get the right error?
ok($rss_object->as_string('error'), 'No HTTP Client requested');

#	43	Test a duff constructor, bad HTTP client
eval { $rss_object = XML::RSS::Tools->new(http_client => "Internet Explorer"); };

ok($@ =~ /Not configured for HTTP Client Internet Explorer/);

#	44	Test a duff constructor,
eval { $rss_object = XML::RSS::Tools->new(version => 51); };
ok($@ =~ /No such version of RSS 51/);

eval { $rss_object = XML::RSS::Tools->new(xml_catalog => './foo-bar.xml'); };
ok($@ =~ /Unable to read XML catalog/);

#	46 Test bad XML/RSS strings
eval { $rss_object->rss_string("<rss</rss>"); };
ok ($@ =~ /not well-formed \(invalid token\) at line 1, column 4, byte 4/);

exit;
