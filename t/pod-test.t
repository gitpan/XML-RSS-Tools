#!/usr/bin/env perl -w

use strict;
use Test::Pod;
use Test::More tests=>1;

pod_file_ok("./Tools.pm", "Valid POD file" );

