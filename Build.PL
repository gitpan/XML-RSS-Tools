#   $Id: Build.PL 74 2008-06-30 20:25:25Z adam $

use 5.006001;
use strict;
use Module::Build;

if ($] < 5.008) {
    print {*STDERR} "\n##########################################",
                    "\n# This module is not supported on Perls  #",
                    "\n# older than 5.8.x. Patches are welcome. #",
                    "\n##########################################\n\n";
}

my $build = Module::Build->new(
    module_name => 'XML::RSS::Tools',
    license     => 'gpl',
    requires    => {
        'perl'  => '5.6.1',
        'URI'   => '1.35',
        'LWP'   => '5.8',
        'XML::LibXSLT' => '1.59',
        'XML::LibXML'  => '1.59',
        'XML::RSS'     => '1.22'
    },
    build_requires => {
        'Pod::Coverage'    => '0.18',
        'URI::file'        => '4.19',
        'Test::Pod'        => '1.0',
        'Test::Warn'       => '0.09',
        'Test::NoWarnings' => '0.08',
        'IO::Capture'      => '0.04',
    },
);

$build->create_build_script;
