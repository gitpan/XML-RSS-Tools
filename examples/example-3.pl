#!/usr/bin/perl
#   $Id: example-3.pl 56 2008-06-23 16:54:31Z adam $

=head1 NAME

Example-3 Another simple example

=head2 Example 3

Another simple example shows how to create a basic command line tool. The
script would be called from the command line using local rdf and xsl files,
with output going to STDOUT. If any step fails, then the eval catches it, and
the error is printed instead.

=cut

use strict;
use XML::RSS::Tools;

my $rss = XML::RSS::Tools->new;
eval { print $rss->rss_file(shift)->xsl_file(shift)->transform->as_string; };
print $rss->as_string('error') if ($@);

