#   $Id: Build.PL 87 2012-06-18 09:50:44Z adam $

use 5.008000; use 5.8.0;
use strict;
use Module::Build;

if ($] < 5.0010) {
    print {*STDERR} "\n##########################################",
                    "\n# This module is not supported on Perls  #",
                    "\n# older than 5.8.x. Patches are welcome. #",
                    "\n##########################################\n\n";
}

my $build = Module::Build->new(
    module_name => 'XML::RSS::Tools',
    license     => 'gpl',
    requires    => {
        'perl'  => '5.8.0',
        'URI'   => '1.58',
        'LWP'   => '6.0',
        'XML::LibXSLT' => '1.70',
        'XML::LibXML'  => '1.70',
        'XML::RSS'     => '1.46'
    },
    build_requires => {
        'Pod::Coverage'    => '0.21',
        'URI::file'        => '4.19',
        'Test::Pod'        => '1.0',
        'Test::Warn'       => '0.09',
        'Test::NoWarnings' => '0.08',
        'IO::Capture'      => '0.04',
        'YAML'             => '0.60',
    },
);

$build->create_build_script;
