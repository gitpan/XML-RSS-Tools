use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'XML::RSS::Tools',
    'VERSION_FROM'	=> 'Tools.pm', 
    'PREREQ_PM'		=> {
    	HTML::Entities => 1.2,
    	XML::LibXSLT   => 1.3,
    	XML::LibXML    => 1.4,
    	XML::RSS       => 0.9,
    	LWP            => 5.5,
    	},
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Tools.pm', 
       AUTHOR     => 'A. J. Trickett <adam@iredale.net>') : ()),
);
