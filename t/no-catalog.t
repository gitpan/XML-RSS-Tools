#!/usr/bin/env perl -w
#   $Id: no-catalog.t,v 1.3 2005/02/06 11:40:00 adam Exp $

use Test;
use strict;
use warnings;

BEGIN { plan tests => 2 };

use XML::RSS::Tools;
ok(1); # If we made it this far, we're ok.

#########################

my $rss_object = XML::RSS::Tools->new;
eval { $rss_object->set_xml_catalog('./t/catalog.xml'); };
ok(($@ =~ "XML Catalog Support not enabled in your version of XML::LibXML"));

exit;

