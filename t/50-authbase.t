#!perl -T
# $Id: 50-authbase.t,v 1.1 2007/07/13 06:33:52 pauldoom Exp $

use Test::More tests => 1;

BEGIN {
	use_ok( 'Apache::AppSamurai::AuthBase' );
}

diag( "Testing Apache::AppSamurai::AuthBase $Apache::AppSamurai::AuthBase::REVISION, Perl $], $^X" );

