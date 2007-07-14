#!perl -T
# $Id: 15-tracker.t,v 1.1 2007/07/13 06:33:52 pauldoom Exp $

use Test::More tests => 1;

BEGIN {
	use_ok( 'Apache::AppSamurai::Tracker' );
}

diag( "Testing Apache::AppSamurai::Tracker $Apache::AppSamurai::Tracker::REVISION, Perl $], $^X" );
 
