#!/usr/bin/perl -w

# $Id: Build.PL,v 1.5 2007/07/13 20:17:42 pauldoom Exp $

use strict;
use warnings;
use Module::Build;

# Add extra processing to install example files
my $class = Module::Build->subclass(code => <<'EOF');
sub  process_examples_files {
    my $self = shift;
    
    # Just copy the examples/ tree into ./blib/examples/
    my $dir = "examples";
    my @found = ();
    
    # Define a find matcher
    my $mat = sub {-f $_ && ! /^(Root|Repository|Entries|Tag|.cvsignore)\z/s &&
		       push(@found, $File::Find::name);};
    # Run a find under $dir for normal, non-CVS files
    File::Find::find({wanted => $mat}, $dir);
    
    # Copy into ./bdir
    foreach (@found) {
	$self->copy_if_modified(from => $_, to => "blib/" . $_);
    }
}
EOF

my $builder = $class->new(
			  module_name         => 'Apache::AppSamurai',
			  license             => 'perl',
			  dist_author         => 'Paul M. Hirsch <paul@voltagenoir.org>',
			  dist_version_from   => 'lib/Apache/AppSamurai.pm',
			  dist_abstract       => 'Web application authentication and filtering reverse proxy front end',
			  build_requires => {
			      'Test::More'   => 0,
			      'mod_perl'     => 1.07,
			      'Apache'       => 0,
			      'Apache::Log'  => 0,
			      'Apache::Util' => 0,
			      'CGI::Cookie'  => 0,
			      'URI'          => 0,
			      'Time::HiRes'  => 0,
			      'MIME::Base64' => 0,
			      'Carp'         => 0,
			      'Apache::Session' => 0,
			      'Digest::SHA'  => 0,
			      'Storable'     => 0,
			      'Crypt::Rijndael' => 0,
			  },
			  add_to_cleanup      => [ 'Apache-AppSamurai-*' ],
			  recommends => {
			      'LWP::UserAgent' => 0,   # AuthBasic.pm
			      'HTTP::Request'  => 0,   # AuthBasic.pm
			      'Authen::Radius' => 0,   # AuthRadius.pm
			  },
			  auto_features => {
			      YAML_support =>
			      {
				  description => "Use YAML.pm to write META.yml files",
				  requires => { YAML => ' >= 0.35, != 0.49_01 ' },
			      },
			      manpage_support =>
			      {
				  description => "Create Unix man pages",
				  requires => { 'Pod::Man' => 0 },
			      },
			      HTML_support =>
			      {
				  description => "Create HTML documentation",
				  requires => { 'Pod::Html' => 0 },
			      },
			  },
			  add_to_cleanup => ['t/session/sessions/*', 't/session/slock/*'],
			  meta_merge => {
			      resources =>
			      {
				  homepage => 'http://appsamurai.sourceforge.net',
				  #bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Build',
				  #MailingList => 'mailto:module-build@perl.org',
				  #repository => 'http://svn.perl.org/modules/Module-Build/'
			      }
			  }			  
			  );

# Build examples: Note - YOU MUST DEFINE THE examples INSTALLATION PATH
# FOR Build install TO INSTALL.  (See README) 
$builder->add_build_element('examples');

$builder->create_build_script();
