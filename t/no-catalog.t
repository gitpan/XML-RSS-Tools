#!/usr/bin/env perl -w
#   $Id: no-catalog.t,v 1.2 2004/02/14 16:34:23 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 2 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $rss_object = XML::RSS::Tools->new;
eval { $rss_object->set_xml_catalog('./t/catalog.xml'); };
ok(($@ =~ "XML Catalog Spport not enabled in your version of XML::LibXML"));

exit;

