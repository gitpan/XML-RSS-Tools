use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'		=> 'XML::RSS::Tools',
    'VERSION_FROM'	 => 'Tools.pm', 
    'PREREQ_PM'		 => {
    	URI          => 1.1,
    	XML::LibXSLT => 1.3,
    	XML::LibXML  => 1.4,
    	XML::RSS     => 0.9,
    	LWP          => 5.5,
    	},
    'test'           => {
	    TESTS		 => 't/use.t t/basic-tests.t t/standard-tests.t t/version-tests.t',
    	},
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Tools.pm', 
       AUTHOR        => 'Dr A. J. Trickett <adam@iredale.net>') : ()),
    dist             => {
       COMPRESS      => 'gzip',
       SUFFIX        => 'gz'
       }, 
);

eval "use XML::RSS 0.98;";

if ($@) {
	print <<XML_RSS

------------------------------------------------------
 XML::RSS versions older than 0.98 have a number of
 errors, and while they will work, you are advised to
 upgrade when convenient.
------------------------------------------------------

XML_RSS
}


