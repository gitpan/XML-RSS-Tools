use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @tests;

eval {
	require Test::Pod;
};

if ($@) {
	push @tests, test => { TESTS => 't/use.t t/basic-tests.t t/standard-tests.t t/version-tests.t t/filehandle-tests.t t/error-tests.t'};
} else {
	push @tests, test => { TESTS => 't/use.t t/basic-tests.t t/standard-tests.t t/version-tests.t t/filehandle-tests.t t/error-tests.t t/pod-test.t'};
}

WriteMakefile(
    'NAME'		=> 'XML::RSS::Tools',
    'VERSION_FROM'	 => 'Tools.pm', 
    'PREREQ_PM'		 => {
    	URI          => 1.21,
    	XML::LibXSLT => 1.5,
    	XML::LibXML  => 1.5,
    	XML::RSS     => 1.0,
    	LWP          => 5.6,
    	},
    @tests,
    dist             => {
       COMPRESS      => 'gzip',
       SUFFIX        => 'gz -9f'
       }, 
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Tools.pm', 
       AUTHOR        => 'Dr A. J. Trickett <adam@iredale.net>') : ()),

);

