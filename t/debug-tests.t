#!/usr/bin/env perl -w
#   $Id: debug-tests.t,v 1.1 2007-01-26 21:40:41 adam Exp $

use Test;
use strict;
use warnings;
use IO::Capture::Stderr;

BEGIN {
    plan tests => 62;
    use URI::file;
    if ($URI::VERSION >= 1.32) {
		no warnings;
        $URI::file::DEFAULT_AUTHORITY = undef;
    }
};

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

my $capture = IO::Capture::Stderr->new();
my $rss_object = XML::RSS::Tools->new;

#   2
ok( $rss_object->debug(1), 1 );

#	3	Load a duff RSS file
$capture->start();
ok(!($rss_object->rss_file('foo.bar')));
$capture->stop();
my $line = $capture->read;
#   4   Did we get the right error?
ok ($line =~ 'File error: Cannot find foo.bar');

#	5	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	6	Load a duff XSL file
$capture->start();
ok(!($rss_object->xsl_file('foo.bar')));
$capture->stop();
$line = $capture->read;

#	7	Did we get the right error?
ok ($line =~ 'File error: Cannot find foo.bar');

#	8	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	9	Load an empty RSS file
$capture->start();
ok(!($rss_object->rss_file()));
$capture->stop();
$line = $capture->read;

#   10  Did we get the right error?
ok ($line =~ 'File error: No file name supplied');

#	11	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	12	Load an empty XSL file
$capture->start();
ok(!($rss_object->xsl_file()));
$capture->stop();
$line = $capture->read;

#	13	Did we get the right error?
ok ($line =~ 'File error: No file name supplied');

#	14	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	15	If we ask for an empty stringify do we get an error?
$capture->start();
ok(!$rss_object->as_string('rss'));
$capture->stop();
$line = $capture->read;
#   16
ok($line =~ 'No RSS File to output');

#	17	If we ask for an empty stringify do we get an error?
$capture->start();
ok(!$rss_object->as_string('xsl'));
$capture->stop();
$line = $capture->read;
#   18
ok($line =~ 'No XSL Template to output');

#	19	If we ask for an empty stringify do we get an error?
$capture->start();
ok(!$rss_object->as_string());
$capture->stop();
$line = $capture->read;
#   20
ok($line =~ 'Nothing To Output Yet');

#	21	If we requrest a blank RSS URI
$capture->start();
ok(!($rss_object->rss_uri));
$capture->stop();
$line = $capture->read;
#   22
ok ($line =~ 'No URI provided.');

#	23	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	24	If we requrest a blank XSL URI
$capture->start();
ok(!($rss_object->xsl_uri));
$capture->stop();
$line = $capture->read;
#   25
ok ($line =~ 'No URI provided.');

#	26	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	27	If we Request a duff RSS URI
$capture->start();
ok(!($rss_object->rss_uri("wibble wobble")));
$capture->stop();
$line = $capture->read;
#   28
ok ($line =~ 'No URI Scheme in wibble%20wobble.');

#	29	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	30	If we Request a duff XSL URI
$capture->start();
ok(!($rss_object->xsl_uri("wibble wobble")));
$capture->stop();
$line = $capture->read;
#   31
ok ($line =~ 'No URI Scheme in wibble%20wobble.');

#	32	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	33 Try and load a RSS file that's a folder
$capture->start();
ok(!($rss_object->rss_file('./')));
$capture->stop();
$line = $capture->read;
#   34
ok ($line =~ "File error: ./ isn't a real file");

#	35	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	36 Try and load a XSL file that's a folder
$capture->start();
ok(!($rss_object->xsl_file('./')));
$capture->stop();
$line = $capture->read;
#   37
ok ($line =~ "File error: ./ isn't a real file");

#	38	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	39	If we requrest an unsupported RSS URI
$capture->start();
ok(!($rss_object->rss_uri('mailto:foo@bar')));
$capture->stop();
$line = $capture->read;
#   40
ok ($line =~ 'Unsupported URI Scheme \(mailto\)\.');

#	41	Did we get the right error?
ok($rss_object->as_string('error'), 'Unsupported URI Scheme (mailto).');

#	42	If we requrest an unsupported XSL URI
$capture->start();
ok(!($rss_object->xsl_uri('mailto:foo@bar')));
$capture->stop();
$line = $capture->read;
#   43
ok($line =~ 'Unsupported URI Scheme \(mailto\)\.');

#	44	Did we get the right error?
ok($rss_object->as_string('error'), 'Unsupported URI Scheme (mailto).');

#	45	Check for an empty RSS File
$capture->start();
ok(!($rss_object->rss_file('./t/empty-file')));
$capture->stop();
$line = $capture->read;
#   46
ok($line =~ 'File error: ./t/empty-file is zero bytes long');

#	47	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	48	Check for an empty XSL File
$capture->start();
ok(!($rss_object->xsl_file('./t/empty-file')));
$capture->stop();
$line = $capture->read;
#   49
ok($line =~ 'File error: ./t/empty-file is zero bytes long');

#	50	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	51	Check for an empty RSS File by URI
$capture->start();
ok(!($rss_object->rss_uri('file:./t/empty-file')));
$capture->stop();
$line = $capture->read;
#   52
ok($line =~ 'File error: ./t/empty-file is zero bytes long');

#	53	Did we get the right error?
my $error = $rss_object->as_string('error');
$error =~ s#\\#/#g;
ok($line =~ $error);

#	54	Check for an empty XSL File by URI
$capture->start();
ok(!($rss_object->xsl_uri('file:./t/empty-file')));
$capture->stop();
$line = $capture->read;
#   55
ok($line =~ 'File error: ./t/empty-file is zero bytes long');

#	56	Did we get the right error?
$error = $rss_object->as_string('error');
$error =~ s#\\#/#g;
ok($line =~ $error);

#	57	Does setting a duff HTTP client cause an error?
$capture->start();
ok(!($rss_object->set_http_client("Internet Explorer")));
$capture->stop();
$line = $capture->read;
#   58
ok($line =~ 'Not configured for HTTP Client Internet Explorer');

#	59	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

#	60	Does setting a null HTTP client cause an error?
$capture->start();
ok(!($rss_object->set_http_client()));
$capture->stop();
$line = $capture->read;
#   61
ok($line =~ 'No HTTP Client requested');

#	62	Did we get the right error?
ok($line =~ $rss_object->as_string('error'));

exit;
