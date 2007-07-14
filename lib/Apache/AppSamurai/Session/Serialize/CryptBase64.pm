# Apache::AppSamurai::Session::Serialize::CryptBase64 - Apache::Session
#                                Serialize module.  Replaces Base64 serializer
#                                with one that uses AES (Crypt::Rijndael) to
#                                encrypt the Base64 encoded and frozen data
#                                before encoding into Base64 for final delivery

# $Id: CryptBase64.pm,v 1.7 2007/07/13 20:17:51 pauldoom Exp $

##
# Copyright (c) 2007 Paul M. Hirsch (paul@voltagenoir.org).
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify it under
# the same terms as Perl itself.
##

package Apache::AppSamurai::Session::Serialize::CryptBase64;
use strict;

# Keep VERSION (set manually) and REVISION (set by CVS)
use vars qw($VERSION $REVISION);
$VERSION = '0.01';
$REVISION = substr(q$Revision: 1.7 $, 10);

use MIME::Base64;
use Storable qw(nfreeze thaw);
use Crypt::Rijndael;

# Set keylength in hex chars (bytes x 2)
my $keylength = 64;

sub serialize {
    my $session = shift;

    # First pass through MIME (so we can safely pad end)
    my $serialized = encode_base64(nfreeze($session->{data}),'');

    # Pad to 16 bytes with blanks to make Crypt::Rijndael happy
    $serialized .= ' ' x (16 - length($serialized) % 16);

    # Setup crypt engine
    my $c = &setup_crypt($session);

    # Enkryptor!!!  Enmimeor!!!  (Crypt it then Base64 encode)
    ($serialized = encode_base64($c->encrypt($serialized),'')) or die "Problem while encrypting serialized data: $!";

    $session->{serialized} = $serialized;
}

sub unserialize {
    my $session = shift;
    my $data = '';

    # Setup key and crypt instance
    my $c = &setup_crypt($session);

    # Demimeor! Dekryptor! Demimeor! Unfruzen! (Demime, decrypt, demime, thaw, rock!)
    $data = thaw(decode_base64($c->decrypt(decode_base64($session->{serialized}))));
    
    $session->{data} = $data;
}

# Create symmetric key and create encryption instance 
sub setup_crypt {
    my $session = shift;
    my ($k, $c);
    # Very basic key checks
    (defined($session->{args}->{ServerKey}) && ($session->{args}->{ServerKey} =~ /^[a-f0-9]{$keylength}$/)) or die "ServerKey not set or invalid for use with this module";
    (defined($session->{args}->{key}) && ($session->{args}->{key} =~ /^[a-f0-9]{$keylength}$/)) or die "Session authentication key not set or invalid for use with this module $session->{args}->{key}";
    
    # Build the full key by xoring the server and auth key.  (I know what you
    # are thinking "Why not stop right there?  XOR!  Think of the performance....")
    $k = pack("H[64]", $session->{args}->{ServerKey}) ^ pack("H[64]", $session->{args}->{key});
    $c = new Crypt::Rijndael($k, Crypt::Rijndael::MODE_CBC);

    return $c;
}

1; # End of Apache::AppSamurai::Session::Serialize::CryptBase64

__END__

=head1 NAME

Apache::AppSamurai::Session::Serialize::CryptBase64 - Storable, AES,
and MIME::Base64 for session serializer

=head1 SYNOPSIS

 use Apache::AppSamurai::Session::Serialize::CryptBase64;
 
 # serialize and unserialze take a single hash reference with required
 # subhashes.  {args} must include two 256 bit hex string key/value pairs:
 # key = Session authentication key
 # ServerKey = Server key
 # (Examples keys are examples.  Don't use them!
 $s->{args}-> {ServerKey} = "628b49d96dcde97a430dd4f597705899e09a968f793491e4b704cae33a40dc02";
 $s->{args}->{key} = "c44474038d459e40e4714afefa7bf8dae9f9834b22f5e8ec1dd434ecb62b512e";

 # serialize() operates on the ->{data} subhash
 $s->{data}->{test} = "Testy!";
 $zipped = Apache::Session::Serialize::Base64::serialize($s);

 # unserialize works on the ->{serialized} subhash
 $s->{serialized} = $zipped;
 $data = Apache::Session::Serialize::Base64::unserialize($s);

=head1 DESCRIPTION

This module fulfills the serialization interface of
L<Apache::Session|Apache::Session> and
L<Apache::AppSamurai::Session|Apache::AppSamurai::Session>.
It serializes the data in the session object by use of L<Storable|Storable>'s
C<nfreeze()> function.  The data is then encoded using
L<MIME::Base64|MIME::Base64>'s C<encode_bas64> method. It then uses the
passed {args}->{key}, (session authentication key), and passed
{args}->{ServerKey}, (server key), to setup and encrypt using
L<Crypt::Rijndael|Crypt::Rijndael>'s c<encrypt> method.
Finally, MIME::Base64 encode is used on the ciphertext for safe storage.

The unserialize method uses a combination of MIME::Base64's C<decode_base64>,
Crypt::Rijndael's decrypt, and Storable's thaw methods to decode, decrypt,
and reconstitute the data.

The serialized data is ASCII text, suitable for storage in backing stores that
don't handle binary data gracefully, such as Postgres.  The pre-encryption
Base64 encoding is used for easy padding of data into chunks that can be
directly handled by AES (Rijndael).

=head1 SEE ALSO

L<Apache::Session::Serialize::Storable>, L<Apache::Session>

=head1 SEE ALSO

L<Apache::AppSamurai::Session>, L<Storable>, L<MIME::Base64>, 
L<Crypt::Rijndael>, L<Apache::Session>

=head1 AUTHOR

Paul M. Hirsch, C<< <paul at voltagenoir.org> >>

=head1 BUGS

See L<Apache::AppSamurai> for information on bug submission and tracking.

=head1 SUPPORT

See L<Apache::AppSamurai> for support information.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Paul M. Hirsch, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
