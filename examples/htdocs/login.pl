#!/usr/bin/perl
#
# $Id: login.pl,v 1.2 2007/06/06 17:11:18 pauldoom Exp $
use strict;
use mod_perl;

# Point to HTML login page
my $formsource = "login.html";

# These will replace any __NAME__ values in the form
my %params = ( MESSAGE => '',
	       REASON => '',
	       URI => '',
	       FORMACTION => '/AppSamurai/LOGIN',
	       USERNAME => '' );


my $r = shift;
($r) or die "FATAL: NO REQUEST SENT TO SCRIPT!\n";

#$params{URI}  = $r->prev->uri;

# Use a hard URI login page instead, and without arguments
$params{URI} = '/';

#if ($args) {
#    $params{URI} .= "?$args";
#}

$r->status(200);

# if there are args, append that to the uri after checking for and removing
# any ASERRCODE code.
my $args = $r->prev->args;
if (($args) && ($args =~ s/&?ASERRCODE\=(bad_credentials|no_cookie|bad_cookie|expired_cookie)//)) {
    $params{REASON} = $1;
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

# Pull in previous username, if set (Note - Using hard redirects clears pnotes;
# this feature is not currently operational)
if (($r->prev) && ($r->prev->pnotes)) {
    my $pn = $r->prev->pnotes;
    foreach (keys %{$pn}) {
	$params{$_} = $pn->{$_};
    }
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
$r->send_http_header;

$r->print ($form);
