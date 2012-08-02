# ABSTRACT: Call asynchronous APIs synchronously
package AnyEvent::Capture;
use strict;
use warnings;
use AnyEvent ();
use Sub::Exporter -setup => {
    exports => [qw( capture )],
    groups => { default => [qw( capture )] },
};

=helper sub capture( CodeRef $todo ) returns Any

Executes $todo, passing it a CodeRef to be used as an event listener.  After
$todo returns, it enters the event loop and waits till the CodeRef is
called.  The return value of $todo will be stored until such time as the
CodeRef is called.  It then returns the arguments that were passed to the
CodeRef.

In so doing, it allows you to call an asychronous function in a synchronous
fashion.

This module is similar to L<Data::Monad::CondVar> but much simpler.  You
could write the example using L<Data::Monad::CondVar> this way:

    my @ips = (as_cv {inet_aton( 'localhost', shift ) })->recv;
=cut

sub capture(&) {
    my( $todo ) = @_;
    my $cv = AE::cv;
    my(@results) = $todo->( sub { $cv->send(@_) } );
    return $cv->recv;
}

1;

=head1 SYNOPSIS

    use AnyEvent::Capture;
    use AnyEvent::Socket qw( inet_aton );
    
    # Call the async version of inet_aton in a synchronous fashion, but
    # while we're doing this other events will fire.
    my @ips = capture { inet_aton( 'localhost', shift ) };

    # An example of waiting for a child without blocking events from firing
    # while we wait.
    sub wait_for_child($) {    
        my( $pid ) = @_;
        my($rpid,$rstatus) = capture { AnyEvent->child(pid=>$pid, cb=>shift) };
        return $rstatus;
    }

=head1 DESCRIPTION

Simple sugar to allow you to call an event based API in a blocking fashion. 
Other events will of course continue to fire while you're waiting.

The first argument passed to your block will be the event listener you
should use as your callback.  The capture call will return when that
subroutine is called.

Any return result from your block will be stored until the callback is
triggered.  This way guard objects returned from AnyEvent won't immediate
expire the listener.

=head1 SEE ALSO

Data::Monad::CondVar
