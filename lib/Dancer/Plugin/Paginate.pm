package Dancer::Plugin::Paginate;

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin;


=head1 NAME

Dancer::Plugin::Paginate - HTTP 1.1 Range-based Pagination for Dancer apps.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.1.0';

=head1 DESCRIPTION

HTTP 1.1 Range-based Pagination for Dancer apps.

Provides a simple wrapper to provide pagination of results via the HTTP 1.1 Range headers for AJAX requests.

=head1 SYNOPSIS

To use, simply add the "paginate" keyword to any route that should support HTTP Range headers.

    use Dancer::Plugin::Paginate;

    get '/secret' => paginate sub { ... }
    ...

=head1 Keywords

=head2 paginate

The paginate keyword serves as a wrapper. It will:

=over

=item Confirm the incoming request is AJAX
=item Determine if Range and Range-Unit are headers in it
=item Define these 2 as vars using Dancer's var keyword
=item Run the provided coderef
=item If the coderef returns without error, add the proper headers to the response

=back

Range will be provided as an arrayref as [start, end].
Range Unit is provided.

In your response, you an optionally provide the following vars to customize response:

=over

=item Total - The total count of items. Will be replaced with '*' if not provided.
=item return_range - An arrayref of provided [start, end] values in your response. Original will be reused if not provided.
=item return_range_unit - The unit of the range in your response. Original will be reused if not provided.

=back

=cut

sub paginate {
    my $coderef = shift;
    return sub {
        unless ( request->is_ajax() ) {
            return $coderef->();
        }
        my $range      = request->header('Range');
        my $range_unit = request->header('Range-Unit');
        unless ( defined $range && defined $range_unit ) {
            return $coderef->();
        }
        var range => [split '-', $range];
        var range_unit => $range_unit;
        my $content  = $coderef->();
        my $response = Dancer::SharedData->response;
        $response->content($content);
        unless ( $response->status == 200 ) {
            return $response;
        }
        my $total = var 'total';
        unless ($total) {
            $total = '*';
        }
        my $returned_range = var 'return_range';
        unless ($returned_range) {
            $returned_range = var 'range';
        }
        my $returned_range_string = "${$returned_range}[0]-${$returned_range}[1]";
        my $returned_range_unit = var 'return_range_unit';
        unless ($returned_range_unit) {
            $returned_range_unit = $range_unit;
        }
        my $content_range = "$returned_range_string/$total";
        $response->header( 'Content-Range' => $content_range );
        $response->header( 'Range-Unit'    => $returned_range_unit );
        my $accept_ranges = var 'accept_ranges';
        unless ($accept_ranges) {
            $accept_ranges = $range_unit;
        }
        $response->header( 'Accept-Ranges' => $accept_ranges );
        $response->status(206);
        return $response;
    };
}

register paginate => \&paginate;


=head1 AUTHOR

Colin Ewen, C<< <colin at draecas.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-plugin-paginate at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Plugin-Paginate>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::Paginate


This is developed on GitHub - please feel free to raise issues or pull requests
against the repo at:


=head1 ACKNOWLEDGEMENTS

My thanks to David Precious, C<< <davidp at preshweb.co.uk> >> for his
Dancer::Plugin::Auth::Extensible framework, which provided the Keyword
syntax used by this module.


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Colin Ewen.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

register_plugin;

true;

 # End of Dancer::Plugin::Paginate
