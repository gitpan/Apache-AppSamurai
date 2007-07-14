#!perl -T
# $Id: 12-session-ser-cryptbase64.t,v 1.2 2007/07/13 21:37:39 pauldoom Exp $

use Test::More tests => 3;

BEGIN {
	use_ok( 'Apache::AppSamurai::Session::Serialize::CryptBase64' );
}

diag( "Testing Apache::AppSamurai::Session::Serialize::CryptBase64 $Apache::AppSamurai::Session::Serialize::CryptBase64::REVISION, Perl $], $^X" );

$user = 'the luser';
$pass = 'my password is password';

$sess = { data => {
    user => $user,
    pass => $pass
    },
	args => {
	    ServerKey => '21fccb94da476b7c2a8e4ebfc88526590f14ba37410c5106a9df672fc42626f5',
	    key => '94ee059335e587e501cc4bf90613e0814f00a7b08bc7c648fd865a2af6a22cc2'
	    }
      };


ok(Apache::AppSamurai::Session::Serialize::CryptBase64::serialize($sess), "serialize() - Serialized (encoded and encrypted) data");

# Clear session data before reloading
$sess->{data} = '';

ok((Apache::AppSamurai::Session::Serialize::CryptBase64::unserialize($sess)) && ($sess->{data}->{pass} eq $pass), "unserialize() - Correctly unserialized (decrypted and decoded) saved data");
