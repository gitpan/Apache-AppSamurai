#!/usr/bin/perl -wT
# $Id: logout.pl,v 1.1 2007/06/04 07:12:46 pauldoom Exp $

use strict;

use mod_perl;
use constant MODPERL2 => ($mod_perl::VERSION >= 1.99);
use Apache::Constants qw(:common M_GET FORBIDDEN REDIRECT);

if (MODPERL2) {
    require Apache2::Access;
}

my $r = MODPERL2 ? Apache2::RequestUtil->request 
                 : Apache->request;

my $auth_type = $r->auth_type;

# Delete the cookie, etc, and go to the URL in arg 2
return $auth_type->logout($r, "/");
