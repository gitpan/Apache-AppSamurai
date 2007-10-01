#!/usr/bin/perl
#
# $Id: login.pl,v 1.5 2007/08/23 07:44:25 pauldoom Exp $

# Decide which mod_perl to load
BEGIN {
    use vars qw($MP);
    if (eval{require mod_perl2;}) {
	$MP = 2;
    } else {
	require mod_perl;
	$MP = 1;
    }
}

use strict;
use warnings;

# Point to HTML login page
my $formsource = "login.html";

# Mod_Perl 2 does not chdir to the script's folder, so you must use
# a full path.  The list below includes common base paths.  Remove
# the other array items and enter your local path if none of these
# match you setup.
my @formpaths = ( "/var/www/htdocs/AppSamurai",
		  "/var/www/html/AppSamurai",
		  "/htdocs/AppSamurai",
		  "/html/AppSamurai"
		  );

# This is lame.  Just cycles the paths looking for the form source
# template ($formsource)
my $ffound = 0;
foreach (@formpaths) {
    if (-f "$_/$formsource") {
	$formsource = "$_/$formsource";
	$ffound = 1;
	last;
    }
}

($ffound) or die "FATAL: Could not find form source template file $formsource\n";

# These will replace any __NAME__ values in the form
my %params = ( MESSAGE => '',
	       REASON => '',
               URI => '',
	       FORMACTION => '/AppSamurai/LOGIN',
	       USERNAME => ''
	       );


my $r = shift;
($r) or die "FATAL: NO REQUEST SENT TO SCRIPT!\n";

# if there are args, append that to the uri after checking for and removing
# any ASERRCODE code.
$params{URI} = $r->prev->uri || '';

my $args = $r->prev->args || '';

if (($args) && ($args =~ s/&?ASERRCODE\=(bad_credentials|no_cookie|bad_cookie|expired_cookie)//)) {
    $params{REASON} = $1;
}

if ($args) { 
    $params{URI} .= '?' . $args;
}

# These messages have HTML in them with CSS. (Update as needed, or add a
# JavaScript snippet to check a hidden value and display the corresponding
# message, then just set a variable.)

# Default message
$params{MESSAGE} = "<span class=\"infonormal\">Please log in</span>";

if ($params{REASON} eq 'bad_credentials') {
    # Login failure	
    $params{MESSAGE} = "<span class=\"infored\">Access Denied - The credentials supplied were invalid. Please try again.</span>";
} elsif ($params{REASON} eq 'expired_cookie') {
    # Expired session
    $params{MESSAGE} = "<span class=\"infored\">Access Denied - Your session has expired. Please log in.</span>";
}

# Read in form
my $form = '';
open(F, "$formsource") or die "FATAL: Could not find/open login page content\n";
while (<F>) {
    $form .= $_;
}
close(F);

# Apply parameters
foreach (keys %params) {
    $form =~ s/__${_}__/$params{$_}/gs;
}

$r->no_cache(1);

$r->content_type("text/html");
$r->headers_out->set("Content-length", length($form));
$r->headers_out->set("Pragma", "no-cache");
# Only for mod_perl 1
($MP eq 1) and $r->send_http_header;

$r->print ($form);
