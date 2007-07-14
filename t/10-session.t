#!perl -T
# $Id: 10-session.t,v 1.1 2007/07/13 06:33:52 pauldoom Exp $

use Test::More tests => 1;

BEGIN {
	use_ok( 'Apache::AppSamurai::Session' );
}

diag( "Testing Apache::AppSamurai::Session $Apache::AppSamurai::Session::REVISION, Perl $], $^X" );

