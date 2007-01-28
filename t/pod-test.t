#!/usr/bin/env perl -w
#   $Id: pod-test.t,v 1.3 2007-01-26 21:40:41 adam Exp $

use strict;
use Test::Pod;
use Test::More tests => 12;

pod_file_ok("./lib/XML/RSS/Tools.pm", "Valid POD file" );
pod_file_ok("./docs/example-1.pod", "Valid POD file" );
pod_file_ok("./docs/example-2.pod", "Valid POD file" );
pod_file_ok("./docs/example-3.pod", "Valid POD file" );
pod_file_ok("./docs/example-4.pod", "Valid POD file" );
pod_file_ok("./docs/example-5.pod", "Valid POD file" );
pod_file_ok("./examples/example-1.pl", "Valid POD file" );
pod_file_ok("./examples/example-2.pl", "Valid POD file" );
pod_file_ok("./examples/example-3.pl", "Valid POD file" );
pod_file_ok("./examples/example-4.pl", "Valid POD file" );
pod_file_ok("./examples/example-5.pl", "Valid POD file" );
pod_file_ok("./docs/rss-introduction.pod", "Valid POD file" );
