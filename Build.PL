#!/usr/bin/perl -w

# $Id: Build.PL,v 1.16 2007/09/30 18:11:55 pauldoom Exp $

use strict;
use warnings;
use Module::Build;

# Add extra processing to install example files
my $class = Module::Build->subclass(code => <<'EOF');
sub process_misc_files {
    my $self = shift;
    
    # Copy the following trees into ./blib/
    my @dirs = ( "examples");
    my @found = ();
    
    # Define a find matcher
    my $mat = sub {-f $_ && ! /^(Root|Repository|Entries|Tag|.cvsignore)\z/s &&
		       push(@found, $File::Find::name);};

    # Run a find under each $dir for normal, non-CVS files
    foreach $dir (@dirs) { File::Find::find({wanted => $mat}, $dir); }

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
			  dist_abstract       => 'Web application/reverse proxy authenticating front end',
			  requires => {
			      'Test::More'   => 0,
			      'CGI::Cookie'  => 0,
			      'URI'          => 0,
			      'Time::HiRes'  => 0,
			      'MIME::Base64' => 0,
			      'Carp'         => 0,
			      'Apache::Session' => 0,
			      'Digest::SHA'  => 0,
			      'Storable'     => 0,
			      'Crypt::CBC' => 2.17,
			  },
			  add_to_cleanup      => [ 'Apache-AppSamurai-*' ],
			  recommends => {
			      'LWP::UserAgent'      => 0, # AuthBasic.pm
			      'HTTP::Request'       => 0, # AuthBasic.pm
			      'Authen::Radius'      => 0, # AuthRadius.pm
			      'Crypt::OpenSSL::AES' => 0, # Needs one
			      'Crypt::Twofish'      => 0, # good block cipher
			      'Crypt::Blowfish'     => 0, # for Crypt::CBC to
			      'Crypt::Rijndael'     => 0, # use.
			      'Apache::Test'        => 0, # Full tests
			  },
			  auto_features => {
			      MP1_support =>
			      {
				  description => "Check mod_perl 1.x kit",
				  requires => { 'mod_perl'     => 1.07 },
			      },
			      APR1_support =>
			      {
				  description => "Check Apache::Request (Perl module for libapreq)",
				  requires => { 'Apache::Request' => 0 },
			      },
			      MP2_support =>
			      {
				  description => "Check mod_perl 2.x kit",
				  requires => { 'mod_perl2'     => 1.9922 },
			      },
			      APR2_support =>
			      {
				  description => "Check Apache2::Request (Perl module for libapreq)",
				  requires => { 'Apache2::Request' => 0 },
			      },
			      Apache_Test_support =>
			      {
				  description => "Perform full Apache::Test testing",
				  requires => { 'Apache::Test' => 0},
			      },
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
			  },
                          # Build MakeMaker Makefile.PL (limited functionality)
			  create_makefile_pl => 'traditional',
			  );

# Check for installed and matching mod_perl and libapr Perl mods
if ($builder->feature("MP2_support")) {
    ($builder->feature("APR2_support")) or die "FATAL: Apache2::Request (libapreq) for mod_perl 2 not found\n";
} elsif ($builder->feature("MP1_support")) {
    ($builder->feature("APR1_support")) or die "FATAL: Apache::Request (libapreq) for mod_perl 1 not found\n";
} else {
    die "FATAL: MOD_PERL 1 or 2 NOT DETECTED!\n";
}

# Enable and setup optional Apache::Test tests
if ($builder->feature("Apache_Test_support")) {
    # Add t/*.at tests
    #$builder->test_files("t/*.at");
    print STDERR "NOTICE: Apache::Test tests not fully implemented (this is a place holder)\n";
} else {
    # Danger Will Wheaton....
    #print STDERR "WARNING: Apache::Test not found - Skipping live tests\n";
}
    

# Build examples: Note - YOU MUST DEFINE THE misc INSTALLATION PATH
# FOR Build install TO INSTALL.  (See README) 
$builder->add_build_element('misc');

$builder->create_build_script();
