# --------------------------------------------------
#
# XML::RSS::Tools
# Version 0.06 "ALPHA"
# August 2002
# Copyright iredale Consulting, all rights reserved
# http://www.iredale.net/
#
# --------------------------------------------------

# --------------------------------------------------
# Module starts here...
# --------------------------------------------------

package XML::RSS::Tools;

use 5.006;						# Not been tested on anything earlier
use strict;						# Naturally
use warnings;					# Naturally
use Carp;						# We're a nice module

use diagnostics;				# Will eventually be removed

use XML::RSS;					# Handle the RSS/RDF files
use XML::LibXML;				# Hand the XML file for XSL-T
use XML::LibXSLT;				# Hand the XSL file and do the XSL-T

require Exporter;

our $VERSION = '0.06';
our @ISA = qw(Exporter);

#
#	Tools Constructor
#

sub new {
	my $class = shift;
	my %args = @_;
	bless {
		_rss_version	=>	$args{version} || 0.91,				# We convert all feeds to this version
		_debug			=>  $args{debug} || 0,					# Debug flag
		_xml_string	 	=>  "",									# Where we hold the input RSS/RDF
		_xsl_string     =>  "",									# Where we hold the XSL-Template
		_output_string  =>  "",									# Where the output string goes
		_transformed    =>  0,									# Flag for transformation
		_auto_wash      =>  $args{auto_wash} || 1,				# Flag for auto_washing input RSS/RDF
		_error_message  =>  ""									# Error message
	}, ref($class) || $class;
}


#
#	Output what we have as a string
#
sub as_string {
	my $self = shift;
	my $mode = shift;

	$mode ||= '';
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
	$self->{_rss_version} = $version if defined $version;
	return $self->{_rss_version};
}


#
#	Load an RSS file, and call RSS conversion to standard RSS format
#
sub rss_file {
	my $self = shift;
	my $file_name = shift;

	if ($self->_check_file($file_name)) {
		open SOURCE_FILE, "<", $file_name or croak "Unable to open $file_name for reading";
		$self->{_rss_string} = $self->_load_filehandle(\*SOURCE_FILE);
		close SOURCE_FILE;
		_parse_rss_string($self);
		$self->{_transformed} = 0;
		return 1;
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
		open SOURCE_FILE, "<", $file_name or croak "Unable to open $file_name for reading";
		$self->{_xsl_string} = $self->_load_filehandle(\*SOURCE_FILE);
		close SOURCE_FILE;
		$self->{_transformed} = 0;
		return 1
	} else {
		return undef
	}
}


#
#	Load an RSS file via HTTP and call RSS conversion to standard RSS format
#
sub rss_uri {
	my $self = shift;
	my $uri  = shift;

	my $xml = $self->_http_get($uri);
	return unless $xml;
	$self->{_rss_string} = $xml;	
	_parse_rss_string($self);
	$self->{_transformed} = 0;
	return 1;
}


#
#	Load an XSL file via HTTP
#
sub xsl_uri {
	my $self = shift;
	my $uri  = shift;

	my $xml = $self->_http_get($uri);
	return uless $xml;
	$self->{_xsl_string} = $xml;
	$self->{_transformed} = 0;
	return 1;
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
	return 1;
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
	return 1;
}


#
#	Do the transformation
#
sub transform {
	my $self = shift;

	croak "No XSL-T loaded" unless $self->{_xsl_string};
	croak "No RSS loaded" unless $self->{_rss_string};
	croak "Can't transform twice without a change" if $self->{_transformed};
	
	my $xslt       = XML::LibXSLT->new;
	my $xml_parser = XML::LibXML->new;
	
	$xml_parser->keep_blanks(0);
	$xml_parser->expand_entities(0);
	$xml_parser->validation(0);
	
	$self->{_rss_string} =~ s/<!DOCTYPE.*?>//s;							# Evil hack to remove DTD

	my $source_xml = $xml_parser->parse_string($self->{_rss_string});	# Parse the source XML
	my $style_xsl  = $xml_parser->parse_string($self->{_xsl_string});	# and Template XSL files
	my $stylesheet = $xslt->parse_stylesheet($style_xsl);				# Load the parsed XSL into XSLT
	my $result_xml = $stylesheet->transform($source_xml);				# Transform the source XML
	$self->{_output_string} = $stylesheet->output_string($result_xml);	# Store the result
	$self->{_transformed} = 1;
	return 1;
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

	my $rss  = XML::RSS->new;
	$rss->parse($xml);
	if ($rss->{version} != $self->{_rss_version}) {
		$rss->{output} = $self->{_rss_version};
		$xml = $rss->as_string;
		$xml = _wash_xml($xml) if $self->{_auto_wash};
	}

	$self->{_rss_string} = $xml;
	return 1;
}


#
#	Load file from File Handle
#
sub	_load_filehandle {
	my $self   = shift;
	my $handle = shift;
	my $content;

	while (<$handle>) {
		$content .= $_
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
	return $xml
}


#
#	Check that the requested file is there and readable
#
sub _check_file {
	my $self      = shift;
	my $file_name = shift;
	
	retrun $self->_raise_error("File error: No file name supplied") unless $file_name;
	return $self->_raise_error("File error: Cannot find file $file_name") unless -e $file_name;
	return $self->_raise_error("File error: $file_name isn't a real file") unless -f _;
	return $self->_raise_error("File error: Cannot read file $file_name") unless -r _;
	return $self->_raise_error("File error: $file_name is zero bytes long") if -z _;
	return 1;
}


#
#	Grab something via HTTP
#
sub _http_get {
	my $self= shift;
	my $uri = shift;

	unless ($uri) {
		$self->_raise_error("HTTP error: No URI provided.");
		return;
	}

	eval {													# Try and use Gnome HTTP, it's faster
		require HTTP::GHTTP;
	};
	if ($@) {												# Otherwise use LWP
 		require LWP::UserAgent;
		my $ua = LWP::UserAgent->new;
		$ua->agent("iC-XML::RSS::Tools/$VERSION " . $ua->agent . " ($^O)");
		my $response = $ua->request(HTTP::Request->new('GET', $uri));
		$self->_raise_error("HTTP error: " . $response->status_line) if $response->is_error;
		return $response->content();
	} else {
		my $r = HTTP::GHTTP->new($uri);
		$r->process_request;
		my $xml = $r->get_body;
		if ($xml) {
			my ($status, $message) = $r->get_status;
			$self->_raise_error("HTTP error: $status, $message") unless $status == 200;
			return $xml;
		} else {
			$self->_raise_error("HTTP error: Unable to connect to server: $uri");
		}
	}	
}


#
#	Fix Entities
#	This subroutine is a mix of Matt Sergents rss-mirror script
#	And chunks of the HTML::Entites module
#
sub	_clean_entities {
	my $xml  = shift;
	
	my %entity = (
		trade	=> "&#8482;",
		euro	=> "&#8364;",
		quot	=> '"',  # double quote
 		apos	=> "'",
		AElig	=> 'Æ',  # capital AE diphthong (ligature)
		Aacute	=> 'Á',  # capital A, acute accent
		Acirc	=> 'Â',  # capital A, circumflex accent
		Agrave	=> 'À',  # capital A, grave accent
		Aring	=> 'Å',  # capital A, ring
		Atilde	=> 'Ã',  # capital A, tilde
		Auml	=> 'Ä',  # capital A, dieresis or umlaut mark
		Ccedil	=> 'Ç',  # capital C, cedilla
		ETH		=> 'Ð',  # capital Eth, Icelandic
		Eacute	=> 'É',  # capital E, acute accent
		Ecirc	=> 'Ê',  # capital E, circumflex accent
		Egrave	=> 'È',  # capital E, grave accent
		Euml	=> 'Ë',  # capital E, dieresis or umlaut mark
		Iacute	=> 'Í',  # capital I, acute accent
		Icirc	=> 'Î',  # capital I, circumflex accent
		Igrave	=> 'Ì',  # capital I, grave accent
		Iuml	=> 'Ï',  # capital I, dieresis or umlaut mark
		Ntilde	=> 'Ñ',  # capital N, tilde
		Oacute	=> 'Ó',  # capital O, acute accent
		Ocirc	=> 'Ô',  # capital O, circumflex accent
		Ograve	=> 'Ò',  # capital O, grave accent
		Oslash	=> 'Ø',  # capital O, slash
		Otilde	=> 'Õ',  # capital O, tilde
		Ouml	=> 'Ö',  # capital O, dieresis or umlaut mark
		THORN	=> 'Þ',  # capital THORN, Icelandic
		Uacute	=> 'Ú',  # capital U, acute accent
		Ucirc	=> 'Û',  # capital U, circumflex accent
		Ugrave	=> 'Ù',  # capital U, grave accent
		Uuml	=> 'Ü',  # capital U, dieresis or umlaut mark
		Yacute	=> 'Ý',  # capital Y, acute accent
		aacute	=> 'á',  # small a, acute accent
		acirc	=> 'â',  # small a, circumflex accent
		aelig	=> 'æ',  # small ae diphthong (ligature)
		agrave	=> 'à',  # small a, grave accent
		aring	=> 'å',  # small a, ring
		atilde	=> 'ã',  # small a, tilde
		auml	=> 'ä',  # small a, dieresis or umlaut mark
		ccedil	=> 'ç',  # small c, cedilla
		eacute	=> 'é',  # small e, acute accent
		ecirc	=> 'ê',  # small e, circumflex accent
		egrave	=> 'è',  # small e, grave accent
		eth		=> 'ð',  # small eth, Icelandic
		euml	=> 'ë',  # small e, dieresis or umlaut mark
		iacute	=> 'í',  # small i, acute accent
		icirc	=> 'î',  # small i, circumflex accent
		igrave	=> 'ì',  # small i, grave accent
		iuml	=> 'ï',  # small i, dieresis or umlaut mark
		ntilde	=> 'ñ',  # small n, tilde
		oacute	=> 'ó',  # small o, acute accent
		ocirc	=> 'ô',  # small o, circumflex accent
		ograve	=> 'ò',  # small o, grave accent
		oslash	=> 'ø',  # small o, slash
		otilde	=> 'õ',  # small o, tilde
		ouml	=> 'ö',  # small o, dieresis or umlaut mark
		szlig	=> 'ß',  # small sharp s, German (sz ligature)
		thorn	=> 'þ',  # small thorn, Icelandic
		uacute	=> 'ú',  # small u, acute accent
		ucirc	=> 'û',  # small u, circumflex accent
		ugrave	=> 'ù',  # small u, grave accent
		uuml	=> 'ü',  # small u, dieresis or umlaut mark
		yacute	=> 'ý',  # small y, acute accent
		yuml	=> 'ÿ',  # small y, dieresis or umlaut mark
		copy	=> '©',  # copyright sign
		reg		=> '®',  # registered sign
		nbsp	=> "\240", # non breaking space
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
#print "\n\n$xml\n";
	$xml =~ s/&(?!(#[0-9]+|#x[0-9a-fA-F]+|\w+);)/&amp;/g;			# Matt's ampersand entity fixer
	$xml =~ s/&($entities);/$entity{$1}/gi;							# Deal with odd entities
#print "\n\n$xml\n";
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

XML::RSS::Tools - Perl extension for very high level RSS Feed manipulation

=head1 SYNOPSIS

  use XML::RSS::Tools;
  my $rss_feed = XML::RSS::Tools->new;
  $rss_feed->rss_uri('http:://foo/bar.rdf');
  $rss_feed->xsl_file('/my/rss_transformation.xsl');
  $rss_feed->transform;
  print $rss_feed->as_string;

=head1 DESCRIPTION

RSS/RDF feeds are commonly available ways of distributing the latest news about a
given web site for news syndication. This module provides a VERY high level way of
manipulating them. You can easily use LWP, the XML::RSS and XML::LibXSLT do to this
yourself.

When working with XML if the file is invalid for some reason this module will craok
bringing your application down. When calling methods that deal with XML manipulation
you should enclose them in an eval statemanet should you wish your program to fail
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

=head1 CONSTRUCTOR

  my $rss_object = XML::RSS::Tools->new;

Or with optional parameters.

  my $rss_object = XML::RSS::Tools->new(
    version   => 0.91,
    auto_wash => 1,
    debug     => 1);

=head1 METHODS

=head2 Source RSS feed

  $rss_object->rss_file('/my/file.rss');

or

  $rss_object->rss_uri('http://my.server.com/index.rss');

or

  $rss_object->rss_string($xml_file);

All return true on success, false on failure. If an XML file was provided but was invalid
XML the parser will fail fataly at this time. The input RSS feed will automatically be
normalised to the prefered RSS version at this time. Chose your version before you load it.

=head2 Source XSL-Template

  $rss_object->xsl_file('/my/file.xsl');

or

  $rss_object->xsl_uri('http://my.server.com/index.xsl');

or

  $rss_object->xsl_string($xml_file);

All return true on success, false on failure. The XSL-T file is not parsed or verified at this time.

=head2 Other Methods

  $rss_object->as_string;

Returns the RSS file after it's been though the XSL-T process. Optionally you can pass this method
one additional parameter to obtain the source RSS, XSL Tempate and any error message:

  $rss_object->as_string(xsl);
  $rss_object->as_string(rss);
  $rss_object->as_string(error);

If there is nothing to stringify you will get nothing.

  $rss_object->debug(1);

A simple switch that control the debug status of the module. By default debug is off. Returns the
current status.

  $rss_object->get_auto_wash;
  $rss_object->get_version;

and

  $rss_object->set_auto_wash(1);
  $rss_object->set_version(0.92);  

These methods control the core RSS functionality. The get methods return the current setting, and
set method sets the value. By default RSS version is set to 0.91, and auto_wash to true. All incoming
RSS feeds are automatically converted to one RSS version. If auto_wash is true, then all RSS files
are cleaned before RSS normaisation to replace known entities by their numeric value, and fix know
invalid XML constructs.

=head1 PREREQUISITES

To function you must have at least C<XML::RSS> installed, and to be of any real use C<XML::LibXSLT>
and C<XML::LibXML>.

Either C<HTTP::GHTTP> or C<LWP> will bring this module to full functionality. HTTP::GHTTP is much
faster than LWP but not as widely available.

=pod OSNAMES

Any OS able to run the core requirments.

=head2 EXPORT

None by default.

=head1 HISTORY

0.06 Changes to HTML Documentation. Tests fixed.

0.05 More minor stuff. Change to entities routine - still not ideal. Test suite upgraded and expanded again.

0.04 Removed un-used test files, other minor changes. Defect in Test script corrected, tested module on Linux.

0.03 Minor code changes and defect corrections. Example script included.

0.02 Some code changes, POD expanded, and test suite more developed.

0.01 Initial Build. Shown to the public on PerlMonks May 2002, for feedback.

See Chnages file for more detail

=head2 ToDo

This module needs expanded testing, and beta testing in the wild. It also
needs the ability to accept rss/xsl files directly from file handles.

The URI handler needs to redirect "file:" requests to the file processor
rather than the HTTP tool. In theory I could remove the xxx_file method
all together if we treat all files as URIs.

Provide xmlcatalog exmaple so the the manual removal of DTDs can be taken
out.

Possibly re-write XML::RSS based on the LibXML parser, or fix it's output
on the older XML::Parser core. Try and develop a more effective XML stream
pre-parsing auto-wash function...

=head2 Defects and Limitations

If an RSS or XSL-T file is passed into LibXML and it contains references to
external files, such as a DTD or external entites, LibXML will automatically
attempt to obtain the files, before performing the transformation. If the files
refered to are on the public INTERNET, and you do not have a connection when this
happens you may find that the process waits around for several minutes until
LibXML gives up. If you plan to use this module in an asyncronous manner, you
should setup an XML Catalog for LibXML using the GNOME xmlcatalog command. See:
http://www.xmlsoft.org/catalog.html for more details.

Many commercial RSS feeds are derived from the Content Managment System in use
at the site. Often the RSS feed is either not well formed or it is invalid. In
either case this will prevent the RSS parser from functioning, and you will get
no output. The auto_wash option attempts to fix these errors, but it's is neither
perfect nor ideal. Some people report good succes with complaining to the site.

XML::RSS on which this module uses for RSS normalisation has a defect in that in
does not escape & " ' < > in it's output stream, resulting in invalid XML. Again
the auto_wash option attempts to correct this, but again, the correction is not
reliable....

Perl pre 5.7.x is not able to handle Unicode fully, strange things happen... Things
should get better as 5.8.0 is now available.

=head1 AUTHOR

Adam Trickett, E<lt>atrickett@cpan.orgE<gt>

This module contains the direct and indirect input of a number of Perlmonks: Ovid, Matts and more...

=head1 SEE ALSO

C<perl>, C<XML::RSS>, C<XML::LibXSLT>, C<XML::LibXML>, C<LWP> and C<HTTP::GHTTP>.

=head1 COPYRIGHT

XML::RSS::Tools, Copyright iredale Consulting 2002

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details. 

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA  02111, USA.

=cut

