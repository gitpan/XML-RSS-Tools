#!/usr/bin/env perl -w

use strict;
use Test::Pod;
use Test::More tests=>8;

pod_file_ok("./Tools.pm", "Valid POD file" );
pod_file_ok("./docs/example-1.pod", "Valid POD file" );
pod_file_ok("./docs/example-2.pod", "Valid POD file" );
pod_file_ok("./docs/example-3.pod", "Valid POD file" );
pod_file_ok("./docs/example-4.pod", "Valid POD file" );
pod_file_ok("./docs/example-5.pod", "Valid POD file" );
pod_file_ok("./docs/rss-introduction.pod", "Valid POD file" );
pod_file_ok("./docs/rss_with_xslt.pod", "Valid POD file" );
