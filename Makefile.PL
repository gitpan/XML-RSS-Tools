#   $Id: Makefile.PL 67 2008-06-29 14:17:37Z adam $

use ExtUtils::MakeMaker;
use strict;
use 5.006001;

if ($] < 5.008) {
    print {*STDERR} "\n##########################################",
                    "\n# This module is not supported on Perls  #",
                    "\n# older than 5.8.x. Patches are welcome. #",
                    "\n##########################################\n\n";
}

eval { require Module::Build };
if (! $@) {
    print {*STDERR} "\n#############################################",
                    "\n# This Makefile.PL is deprecated please use #",
                    "\n# the Build.PL file if possible.            #",
                    "\n#############################################\n\n";
}

WriteMakefile(
    'NAME'      => 'XML::RSS::Tools',
    'VERSION_FROM'     => 'lib/XML/RSS/Tools.pm',
    'PREREQ_PM'        => {
        'URI'          => 1.35,
        'XML::LibXSLT' => 1.59,
        'XML::LibXML'  => 1.59,
        'XML::RSS'     => 1.22,
        'LWP'          => 5.8,
        },
    'PL_FILES'      => {},
    dist             => {
       COMPRESS      => 'gzip -9f',
       SUFFIX        => 'gz'
       },
    ($] >= 5.005 ?
      (ABSTRACT_FROM => 'lib/XML/RSS/Tools.pm',
       AUTHOR        => 'Dr A. J. Trickett <atrickett@cpan.org>') : ()),
);

