#!perl -T
# $Id: 00-main.t,v 1.1 2007/07/13 06:33:52 pauldoom Exp $

use Test::More tests => 1;

BEGIN {
	use_ok( 'Apache::AppSamurai' );
}

diag( "Testing Apache::AppSamurai $Apache::AppSamurai::VERSION, Perl $], $^X" );
