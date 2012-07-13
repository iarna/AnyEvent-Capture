use strict;
use warnings;
use Test::More tests => 1;
use AnyEvent::Capture;
use AnyEvent::Socket qw( inet_aton );

# As of this writing (AnyEvent 7.01), "localhost" is hard coded into AnyEvent::Socket.    
my @ips = capture { inet_aton( 'localhost', shift ) };

ok( scalar @ips, "we looked up ips for localhost" );
