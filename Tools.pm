# --------------------------------------------------
#
# XML::RSS::Tools
# Version 0.13
# June 2003
# Copyright iredale Consulting, all rights reserved
# http://www.iredale.net/
#
# OSI Certified Open Source Software
#
# --------------------------------------------------

# --------------------------------------------------
# Module starts here...
# --------------------------------------------------

package XML::RSS::Tools;

use 5.006;						# Not been tested on anything earlier
use strict;						# Naturally
use warnings;					# Naturally
use warnings::register;			# So users can "use warnings 'XML::RSS::Tools'"
use Carp;						# We're a nice module
use XML::RSS;					# Handle the RSS/RDF files
use XML::LibXML;				# Hand the XML file for XSLT
use XML::LibXSLT;				# Hand the XSL file and do the XSLT
use URI;						# Deal with URIs nicely
use FileHandle;					# Alow the use of File Handle Objects

our $VERSION = '0.13_3';

#
#	Tools Constructor
#

sub new {
	my $class = shift;
	my %args = @_;

	my $object = bless {
		_rss_version	=>	0.91,								# We convert all feeds to this version
		_debug			=>  $args{debug} || 0,					# Debug flag
		_xml_string	 	=>  "",									# Where we hold the input RSS/RDF
		_xsl_string     =>  "",									# Where we hold the XSL Template
		_output_string  =>  "",									# Where the output string goes
		_transformed    =>  0,									# Flag for transformation
		_auto_wash      =>  $args{auto_wash} || 1,				# Flag for auto_washing input RSS/RDF
		_error_message  =>  "",									# Error message
		_uri_url        =>  "",									# URI URL
		_uri_file       =>  "",									# URI File
		_uri_scheme     =>  "",									# URI Scheme
		_xml_catalog	=>	"",									# XML Catalog file
		_http_client	=>	"auto"								# Which HTTP Client to use
	}, ref($class) || $class;

	if ($args{version}) {
		croak "No such version of RSS $args{version}" unless set_version($object, $args{version});
	}

	if ($args{http_client}) {
		croak "Not configured for HTTP Client $args{http_client}" unless set_http_client($object, $args{http_client});
	}

	if ($args{xml_catalog}) {
		croak "Unable to read XML catalog $args{xml_catalog}" unless set_xml_catalog($object, $args{xml_catalog});
	}

	return $object;
}


#
#	Output what we have as a string
#
sub as_string {
	my $self = shift;
	my $mode = shift || '';

	if ($mode) {
		if ($mode =~ /rss/i) {
			warn "No RSS File to output" if ! $self->{_rss_string} && $self->{_debug};
			return $self->{_rss_string};
		} elsif ($mode =~ /xsl/i) {
			warn "No XSL Template to output" if ! $self->{_xsl_string} && $self->{_debug};
			return $self->{_xsl_string};
		} elsif ($mode =~ /error/i) {
			if ($self->{_error_message}) {
				my $message = $self->{_error_message};
				$self->{_error_message} = "";
				return $message;
			}
		} else {
			croak "Unknown mode: $mode";
		}
	} else {
		warn "Nothing To Output Yet" if ! $self->{_transformed} && $self->{_debug};
		return $self->{_output_string};
	}
}


#
#	Set/Read the debug level
#
sub debug {
	my $self  = shift;
	my $debug = shift;
	$self->{_debug} = $debug if defined $debug;
	return $self->{_debug};
}


#
#	Read the auto_wash level
#
sub get_auto_wash {
	my $self = shift;
	return $self->{_auto_wash};
}


#
#	Set the auto_wash level
#
sub set_auto_wash {
	my $self = shift;
	my $wash = shift;
	$self->{_auto_wash} = $wash if defined $wash;
	return $self->{_auto_wash};
}


#
#	Read the HTTP Client mode
#
sub get_http_client {
	my $self = shift;
	return $self->{_http_client};
}


#
#	Set the auto_wash level
#
sub set_http_client {
	my $self = shift;
	my $client = shift;
	
	return $self->_raise_error("No HTTP Client requested")
		unless defined $client;
	return $self->_raise_error("Not configured for HTTP Client $client")
		unless (grep {/$client/} qw(auto ghttp lwp lite));
		
	$self->{_http_client} = lc($client);
	return $self->{_http_client};
}


#
#	Get the RSS Version
#
sub get_version {
	my $self = shift;
	return $self->{_rss_version};
}


#
#	Set the RSS Version
#
sub set_version {
	my $self    = shift;
	my $version = shift;

	return $self->_raise_error("No RSS version supplied")
		unless defined $version;
	return $self->_raise_error("No such version of RSS $version")
		unless (grep {/$version/} qw(0 0.9 0.91 0.92 0.93 0.94 1.0 2.0));
	
	$self->{_rss_version} = $version;
	if ($version) {
		return $self->{_rss_version};
	} else {
		return "0.0";
	}
}


#
#	Get XML Catalog File
#
sub get_xml_catalog {
	my $self = shift;
	return $self->{_xml_catalog};
}


#
#	Set XML catalog file
#
sub set_xml_catalog {
	my $self = shift;
	my $catalog_file = shift;
	if ($self->_check_file($catalog_file)) {
		$self->{_xml_catalog} = $catalog_file;
		return $self;
	} else {
		return undef;
	}
}


#
#	Load an RSS file, and call RSS conversion to standard RSS format
#
sub rss_file {
	my $self = shift;
	my $file_name = shift;

	if ($self->_check_file($file_name)) {
		my $fh = FileHandle->new($file_name, "r") or croak "Unable to open $file_name for reading";
		$self->{_rss_string} = $self->_load_filehandle($fh);
		undef $fh;
		_parse_rss_string($self);
		$self->{_transformed} = 0;
		return $self;
	} else {
		return undef;
	}
}


#
#	Load an XSL file
#
sub xsl_file {
	my $self = shift;
	my $file_name = shift;

	if ($self->_check_file($file_name)) {
		my $fh = FileHandle->new($file_name, "r") or croak "Unable to open $file_name for reading";
		$self->{_xsl_string} = $self->_load_filehandle($fh);
		undef $fh;
		$self->{_transformed} = 0;
		return $self
	} else {
		return undef
	}
}


#
#	Load an RSS file from a FH, and call RSS conversion to standard RSS format
#
sub rss_fh {
	my $self = shift;
	my $file_name = shift;

	if (ref($file_name) eq "FileHandle") {
		$self->{_rss_string} = $self->_load_filehandle($file_name);
		_parse_rss_string($self);
		$self->{_transformed} = 0;
		return $self;
	} else {
		return $self->_raise_error("FileHandle error: No FileHandle Object Passed");
	}
}


#
#	Load an XSL file from a FH
#
sub xsl_fh {
	my $self = shift;
	my $file_name = shift;

	if (ref($file_name) eq "FileHandle") {
		$self->{_xsl_string} = $self->_load_filehandle($file_name);
		$self->{_transformed} = 0;
		return $self
	} else {
		return $self->_raise_error("FileHandle error: No FileHandle Object Passed");
	}
}


#
#	Load an RSS file via HTTP and call RSS conversion to standard RSS format
#
sub rss_uri {
	my $self = shift;
	my $uri  = shift;

	$uri = $self->_process_uri($uri);
	return unless $uri;

	return $self->rss_file($self->{_uri_file}) if ($self->{_uri_scheme} eq "file");
		
	my $xml = $self->_http_get($uri);
	return unless $xml;
	$self->{_rss_string} = $xml;	
	_parse_rss_string($self);
	$self->{_transformed} = 0;
	return $self;
}


#
#	Load an XSL file via HTTP
#
sub xsl_uri {
	my $self = shift;
	my $uri  = shift;

	$uri = $self->_process_uri($uri);
	return unless $uri;

	return $self->xsl_file($self->{_uri_file}) if ($self->{_uri_scheme} eq "file");

	my $xml = $self->_http_get($uri);
	return unless $xml;
	$self->{_xsl_string} = $xml;
	$self->{_transformed} = 0;
	return $self;
}


#
#	Parse a string and convert to standard RSS
#
sub rss_string {
	my $self = shift;
	my $xml  = shift;

	return unless $xml;
	$self->{_rss_string} = $xml;
	_parse_rss_string($self);
	$self->{_transformed} = 0;
	return $self;
}


#
#	Import an XSL from string
#
sub xsl_string {
	my $self = shift;
	my $xml  = shift;

	return unless $xml;
	_$self->{_xsl_string} = $xml;
	$self->{_transformed} = 0;
	return $self;
}


#
#	Do the transformation
#
sub transform {
	my $self = shift;

	croak "No XSLT loaded" unless $self->{_xsl_string};
	croak "No RSS loaded" unless $self->{_rss_string};
	croak "Can't transform twice without a change" if $self->{_transformed};
	
	my $xslt       = XML::LibXSLT->new;
	my $xml_parser = XML::LibXML->new;
	if ($self->{_xml_catalog}) {
		$xml_parser->load_catalog($self->{_xml_catalog});				# Load the catalogue
	} else {
		$xml_parser->expand_entities(0);								# Otherwise don't touch entities
	}
	$xml_parser->keep_blanks(0);
	$xml_parser->validation(0);
	$xml_parser->complete_attributes(0);
	
	my $source_xml = $xml_parser->parse_string($self->{_rss_string});	# Parse the source XML
	my $style_xsl  = $xml_parser->parse_string($self->{_xsl_string});	# and Template XSL files
	my $stylesheet = $xslt->parse_stylesheet($style_xsl);				# Load the parsed XSL into XSLT
	my $result_xml = $stylesheet->transform($source_xml);				# Transform the source XML
	$self->{_output_string} = $stylesheet->output_string($result_xml);	# Store the result
	$self->{_transformed} = 1;
	return $self;
}


#	---------------
#	Private Methods
#	---------------

#
#	Parse the RSS string
#
sub _parse_rss_string {
	my $self = shift;
	my $xml  = $self->{_rss_string};

	$xml = _wash_xml($xml) if $self->{_auto_wash};

	if ($self->{_rss_version}) {							# Only normalise if version is true
		my $rss  = XML::RSS->new;
		$rss->parse($xml);
		if ($rss->{version} != $self->{_rss_version}) {
			$rss->{output} = $self->{_rss_version};
			$xml = $rss->as_string;
			$xml = _wash_xml($xml) if $self->{_auto_wash};
		}
	}
	$self->{_rss_string} = $xml;
	return $self;
}


#
#	Load file from File Handle
#
sub	_load_filehandle {
	my $self   = shift;
	my $handle = shift;
	my $content;

	while (my $line = $handle->getline) {
		$content .= $line;
	}
	return $content;
}


#
#	Wash the XML File of known nasties
#
sub _wash_xml {
	my $xml = shift;

	$xml = _clean_entities($xml);
	$xml =~ s/\s+/ /gs;
	$xml =~ s/> />/g;
	$xml =~ s/^.*(<\?xml)/$1/gs;		# Remove bogus content before <?xml start
	return $xml
}


#
#	Check that the requested file is there and readable
#
sub _check_file {
	my $self      = shift;
	my $file_name = shift;

	return $self->_raise_error("File error: No file name supplied") unless $file_name;
	return $self->_raise_error("File error: Cannot find $file_name") unless -e $file_name;
	return $self->_raise_error("File error: $file_name isn't a real file") unless -f _;
	return $self->_raise_error("File error: Cannot read file $file_name") unless -r _;
	return $self->_raise_error("File error: $file_name is zero bytes long") if -z _;
	return $self;
}


#
#	Process a URI ready for HTTP getting
#
sub _process_uri {
	my $self= shift;
	my $uri = shift;

	return $self->_raise_error("No URI provided.") unless $uri;
	my $uri_object = URI->new($uri)->canonical;
	return $self->_raise_error("URI provided ($uri) is not valid.") unless $uri_object;

	$self->{_uri_scheme} = $uri_object->scheme;
	return $self->_raise_error("No URI Scheme in " . $uri_object->as_string . ".") unless $self->{_uri_scheme};
	return $self->_raise_error("Unsupported URI Scheme (" . $self->{_uri_scheme} . ").") unless $self->{_uri_scheme} =~ /http|file/;

	$self->{_uri_file} = $uri_object->file if $self->{_uri_scheme} eq "file";
	
	return $uri_object->as_string;
}


#
#	Grab something via HTTP
#
sub _http_get {
	my $self= shift;
	my $uri = shift;

	if ($self->{_http_client} eq "auto"){
		my @modules = qw "HTTP::GHTTP HTTP::Lite LWP";
		foreach my $module (@modules) {
			eval "require $module";
			if (! $@) {
				$self->{_http_client} = lc($module);
				$self->{_http_client} =~ s/.*:://;
				last;
			}
		}
		return $self->_raise_error("HTTP error: No HTTP client library installed") if $self->{_http_client} eq "auto";
	}

	if ($self->{_http_client} eq "lite") {
		require HTTP::Lite;
		my $ua = HTTP::Lite->new;
		$ua->add_req_header("User-Agent", "XML::RSS::Tools/$VERSION HTTP::Lite/$HTTP::Lite::VERSION ($^O)");
		my $r = $ua->request($uri) or return $self->_raise_error("Unable to get document: $!");
		return $self->_raise_error("HTTP error: $r, " . $ua->status_message) unless $r == 200;
		return $ua->body;
	}
	
	if ($self->{_http_client} eq "lwp" || $self->{_http_client} eq "useragent") {
		require LWP::UserAgent;
		my $ua = LWP::UserAgent->new;
		$ua->agent("XML::RSS::Tools/$VERSION " . $ua->agent . " ($^O)");
		my $response = $ua->request(HTTP::Request->new('GET', $uri));
		return $self->_raise_error("HTTP error: " . $response->status_line) if $response->is_error;
		return $response->content();
	}

	if ($self->{_http_client} eq "ghttp") {
		require HTTP::GHTTP;
		my $ua = HTTP::GHTTP->new($uri);
		$ua->set_header("User-Agent", "XML::RSS::Tools/$VERSION libghttp/1.x ($^O)");
		$ua->process_request;
		my $xml = $ua->get_body;
		if ($xml) {
			my ($status, $message) = $ua->get_status;
			return $self->_raise_error("HTTP error: $status, $message") unless $status == 200;
			return $xml;
		} else {
			return $self->_raise_error("HTTP error: Unable to connect to server: $uri");
		}
	}
}


#
#	Fix Entities
#	This subroutine is a mix of Matt Sergent's rss-mirror script
#	And chunks of the HTML::Entites module if you have Perl 5.8.x you
#	don't need this code.
#
sub	_clean_entities {
	my $xml  = shift;
	
	my %entity = (
		trade	=> "&#8482;",
		euro	=> "&#8364;",
		quot	=> '"',
 		apos	=> "'",
		AElig	=> 'Æ',
		Aacute	=> 'Á',
		Acirc	=> 'Â',
		Agrave	=> 'À',
		Aring	=> 'Å',
		Atilde	=> 'Ã',
		Auml	=> 'Ä',
		Ccedil	=> 'Ç',
		ETH		=> 'Ð',
		Eacute	=> 'É',
		Ecirc	=> 'Ê',
		Egrave	=> 'È',
		Euml	=> 'Ë',
		Iacute	=> 'Í',
		Icirc	=> 'Î',
		Igrave	=> 'Ì',
		Iuml	=> 'Ï',
		Ntilde	=> 'Ñ',
		Oacute	=> 'Ó',
		Ocirc	=> 'Ô',
		Ograve	=> 'Ò',
		Oslash	=> 'Ø',
		Otilde	=> 'Õ',
		Ouml	=> 'Ö',
		THORN	=> 'Þ',
		Uacute	=> 'Ú',
		Ucirc	=> 'Û',
		Ugrave	=> 'Ù',
		Uuml	=> 'Ü',
		Yacute	=> 'Ý',
		aacute	=> 'á',
		acirc	=> 'â',
		aelig	=> 'æ',
		agrave	=> 'à',
		aring	=> 'å',
		atilde	=> 'ã',
		auml	=> 'ä',
		ccedil	=> 'ç',
		eacute	=> 'é',
		ecirc	=> 'ê',
		egrave	=> 'è',
		eth		=> 'ð',
		euml	=> 'ë',
		iacute	=> 'í',
		icirc	=> 'î',
		igrave	=> 'ì',
		iuml	=> 'ï',
		ntilde	=> 'ñ',
		oacute	=> 'ó',
		ocirc	=> 'ô',
		ograve	=> 'ò',
		oslash	=> 'ø',
		otilde	=> 'õ',
		ouml	=> 'ö',
		szlig	=> 'ß',
		thorn	=> 'þ',
		uacute	=> 'ú',
		ucirc	=> 'û',
		ugrave	=> 'ù',
		uuml	=> 'ü',
		yacute	=> 'ý',
		yuml	=> 'ÿ',
		copy	=> '©',
		reg		=> '®',
		nbsp	=> "\240",
		iexcl	=> '¡',
		cent	=> '¢',
		pound	=> '£',
		curren	=> '¤',
		yen		=> '¥',
		brvbar	=> '¦',
		sect	=> '§',
		uml		=> '¨',
		ordf	=> 'ª',
		laquo	=> '«',
		'not'	=> '¬',    # not is a keyword in perl
		shy		=> '­',
		macr	=> '¯',
		deg		=> '°',
		plusmn	=> '±',
		sup1	=> '¹',
		sup2	=> '²',
		sup3	=> '³',
		acute	=> '´',
		micro	=> 'µ',
		para	=> '¶',
		middot	=> '·',
		cedil	=> '¸',
		ordm	=> 'º',
		raquo	=> '»',
		frac14	=> '¼',
		frac12	=> '½',
		frac34	=> '¾',
		iquest	=> '¿',
		'times'	=> '×',    # times is a keyword in perl
		divide	=> '÷',
	);
	my $entities = join('|', keys %entity);
	$xml =~ s/&(?!(#[0-9]+|#x[0-9a-fA-F]+|\w+);)/&amp;/g;			# Matt's ampersand entity fixer
	$xml =~ s/&($entities);/$entity{$1}/gi;							# Deal with odd entities
	return $xml;
}

#
#	Raise error condition
#
sub _raise_error {
	my $self    = shift;
	my $message = shift;

	$self->{_error_message} = $message;
	warn $message if $self->{_debug};
	return undef;
}

1;

__END__

=head1 NAME

XML::RSS::Tools - A tool-kit providing a wrapper around a HTTP client, a RSS parser, and a
XSLT engine.

=head1 SYNOPSIS

  use XML::RSS::Tools;
  my $rss_feed = XML::RSS::Tools->new;
  $rss_feed->rss_uri('http:://foo/bar.rdf');
  $rss_feed->xsl_file('/my/rss_transformation.xsl');
  $rss_feed->transform;
  print $rss_feed->as_string;

=head1 DESCRIPTION

RSS/RDF feeds are commonly available ways of distributing or syndicating the latest
news about a given web site. Weblog (blog) sites in particular are prolific
generators of RSS feeds. This module provides a VERY high level way of
manipulating them. You can easily use LWP, the XML::RSS and XML::LibXSLT do to this
yourself, but this module is a wrapper around these modules, allowing for the simple
creation of a RSS client.

When working with XML if the file is invalid for some reason this module will croak
bringing your application down. When calling methods that deal with XML manipulation
you should enclose them in an eval statement should you wish your program to fail
gracefully.

Otherwise method calls will return true on success, and false on failure. For example
after loading a URI via HTTP, you may wish to check the error status before
proceeding with your code:

  unless ($rss_feed->rss_uri('http://this.goes.nowhere/')) {
  	print "Unable to obtain file via HTTP", $rss_feed->as_string(error);
    # Do what else
	# you have to.
  } else {
  	# carry on...
  }

Check the HTML documentation for extra examples, and background.

=head1 CONSTRUCTOR

=head2 new

  my $rss_object = XML::RSS::Tools->new;

Or with optional parameters.

  my $rss_object = XML::RSS::Tools->new(
    version     => 0.91,
    http_client => "lwp",
    auto_wash   => 1,
    debug       => 1);

The module will die if it's created with invalid parameters.

=head1 METHODS

=head2 Source RSS feed

  $rss_object->rss_file('/my/file.rss');
  $rss_object->rss_uri('http://my.server.com/index.rss');
  $rss_object->rss_uri('file:/my/file.rss');
  $rss_object->rss_string($xml_file);
  $rss_object->rss_fh($file_handle);

All return true on success, false on failure. If an XML file was provided but was invalid
XML the parser will fail fataly at this time. The input RSS feed will automatically be
normalised to the preferred RSS version at this time. Chose your version before you load it!

=head2 Source XSL Template

  $rss_object->xsl_file('/my/file.xsl');
  $rss_object->xsl_uri('http://my.server.com/index.xsl');
  $rss_object->xsl_uri('file:/my/file.xsl');
  $rss_object->xsl_string($xml_file);
  $rss_object->xsl_fh($file_handle);

All return true on success, false on failure. The XSLT file is NOT parsed or verified at this time.

=head2 Other Methods

=head3 transform

  $rss_object->transform();

Performs the XSL transformation on the source RSS file with the loaded XSLT file.

=head3 as_string

  $rss_object->as_string;

Returns the RSS file after it's been though the XSLT process. Optionally you can pass this method
one additional parameter to obtain the source RSS, XSL Template and any error message:

  $rss_object->as_string(xsl);
  $rss_object->as_string(rss);
  $rss_object->as_string(error);

If there is nothing to stringify you will get nothing.

=head3 debug

  $rss_object->debug(1);

A simple switch that control the debug status of the module. By default debug is off. Returns the
current status.

=head3 set_auto_wash and get_auto_wash

  $rss_object->set_auto_wash(1);
  $rss_object->get_auto_wash;

If auto_wash is true, then all RSS files are cleaned before RSS normalisation to replace
known entities by their numeric value, and fix known invalid XML constructs. By default
auto_wash is set to true.

=head3 set_version and get_version
  
  $rss_object->set_version(0.92);  
  $rss_object->get_version;

All incoming RSS feeds are automatically converted to one default RSS version. If RSS version
is set to 0 then normalisation is not performed. The default RSS version is 0.91.

=head3 set_http_client and get_http_client

  $rss_object->set_http_client('lwp');
  $rss_object->get_http_client;

These methods set the HTTP client to use, and get back the one selected. Acceptable values are:

=over

=item	*

auto

Will use attempt to use the HTTP client modules in order of performance.

=item	*

ghttp

Matt Sergeant's libghttp based C<HTTP::GHTTP>.

=item	*

lite

Roy Hooper's pure Perl C<HTTP::Lite> client. Slower than ghttp, but still faster than lwp.

=item	*

lwp

LWP is the Rolls-Royce solution, it can do everything, but it's rather big, so it's slow to
load, and it's not exactly fast. It is however far more common, and is the most complete.

=back

If set to auto the module will first try C<HTTP::GHTTP> then C<HTTP::Lite> then C<LWP>, to
retrieve files on the internet. Though C<GHTTP> is much faster than C<LWP> it is far less common and
doesn't work reliably on Windows Apache 1.3.x/mod_Perl, so this method allows you to specify which
client to use if you wish to.

=head2 XML Catalog

To speed up large scale XML processing it is advised to create an XML Catalog (I<sic>) so that the XML parser
does not have to make slow and expensive requests to files on the Internet. The catalogue contains details
of the DTD and external entities so that they can be retrieved from the local file system quicker and at
lower load that from the Internet. If XML processing is being carried out on a system not connected to
the Internet, the libxml2 parser will still attempt to connect to the Internet which will add a delay of
about 60 seconds per XML file. If a catalogue is created then the process will be much quicker as
the libxml2 parser will use the local information stored in the catalogue.

	$rss_object->set_xml_catalog( $xml_catalog_file);

This will pass the specified file to the XML parsers to use as a local XML Catalog.

	$rss_object->get_xml_catalog;

This will return the file name of the XML Catalog in use.

Depending upon how your core libxml2 library is compiled, you should also be able to use pre-configured
XML Catalog files stored in your C</etc/xml/catalog>.


=head1 PREREQUISITES

To function you must have C<URI> installed. If you plan to normalise your RSS before transforming you
must also have C<XML::RSS> installed. To transform any RSS files to HTML you will also need to use
C<XML::LibXSLT> and C<XML::LibXML>.

One of C<HTTP::GHTTP>, C<HTTP::Lite> or C<LWP> will bring this module to full functionality. GHTTP
is much faster than LWP, but is it not as widely available as LWP. By default GHTTP will be used if
it is available, then Lite, finally LWP. If you have two or more installed you may manually
select which one you wish to use.

=pod OSNAMES

Any OS able to run the core requirements.

=head2 EXPORT

None by default.

=head1 HISTORY

0.13

0.12 Numerous build fixes, module untouched.

0.11 POD and doc corrections. Minor bug fixes.

0.10 Initial XML Catalog support. HTTP client selection.

...

0.01 Initial Build. Shown to the public on PerlMonks May 2002, for feedback.

See CHANGES file for more detail

=head2 Defects and Limitations

=over

=item *

External Entities

If an RSS or XSLT file is passed into LibXML and it contains references to
external files, such as a DTD or external entities, LibXML will automatically
attempt to obtain the files, before performing the transformation. If the files
referred to are on the public INTERNET, and you do not have a connection when this
happens you may find that the process waits around for several minutes until
LibXML gives up. If you plan to use this module in an asynchronous manner, you
should setup an XML Catalog for LibXML using the xmlcatalog command. See:
http://www.xmlsoft.org/catalog.html for more details. You can pass your catalog
into the module, and a local copy will then be used rather than the one on the
Internet.

=item *

Defective XML

Many commercial RSS feeds are derived from the Content Management System in use
at the site. Often the RSS feed is not well formed and is thus invalid. This will
prevent the RSS parser and/or XSLT engine from functioning, and you will get
no output. The auto_wash option attempts to fix these errors, but it's is neither
perfect nor ideal. Some people report good success with complaining to the site.
Mark Pilgrim estimates that about 10% of RSS feeds have defective XML.

=item *

XML::RSS Limitations

XML::RSS upto and including version 0.96 has a number of defects. As of October
2002 brian d foy has taken over the module, and it is again under active
development on http://perl-rss.sourceforge.net/. Since the 1.xx family
have been release most problems have been fixed, please upgrade if you can.

=item *

Perl and Unicode

Perl pre 5.7.x is not able to handle Unicode properly, strange things happen...
Things should get better as 5.8.0 is now available.

=back

=head2 To Do

=over

=item *

Debug mode doesn't actually do much yet.

=item *

Possibly support C<HTTP::MHTTP> module, it seems to be even faster than GHTTP.

=item *

Implement HTTP Proxy support.

=item *

Fully test with Perl 5.8.x

=back

=head1 AUTHOR

Adam Trickett, E<lt>atrickett@cpan.orgE<gt>

This module contains the direct and indirect input of a number of friendly Perl Hackers on
Perlmonks/use.perl: Ovid; Matts; Merlyn and more...

=head1 SEE ALSO

L<perl>, L<XML::RSS>, L<XML::LibXSLT>, L<XML::LibXML>, L<URI>, L<LWP>, L<HTTP::Lite>, L<HTTP::GHTTP>.

=head1 COPYRIGHT

XML::RSS::Tools, Copyright iredale Consulting 2002-2003

OSI Certified Open Source Software

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details. 

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA  02111, USA.

=head1 DEDICATION

This module is dedicated to my beloved mother who believed in me, even when I didn't.

=cut

