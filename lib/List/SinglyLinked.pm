package List::SinglyLinked;

our $VERSION = '0.01';

use strict;
use warnings;

require XSLoader;
XSLoader::load('List::SinglyLinked', $VERSION);

*reverse = \&reverse_iterative;

1;
__END__

=head1 NAME

List::SinglyLinked - Singly linked list in Perl

=head1 SYNOPSIS

  use List::SinglyLinked;

  my $l = List::SinglyLinked->new;
  $l->unshift($_) for qw(foo bar doz fuu miou);
  $l->reverse;
  say "head: ", $l->head;
  my $head = $l->shift;

=head1 DESCRIPTION

This module provides an efficient implementation of singly linked list
for Perl.

Elements can be inserted or removed at the head of the list in O(1) time.

Also, in order to allow access to the rest of the elements of the
list, every List::SinglyLinked object provides a forward iterator.

List elements can be read, removed or inserted in O(1) time at the
iterator position.

=head2 Methods

=over 4

=item $l = List::SinglyLinked->new;

Returns a new and empty singly linked list object.

=item $len = $l->length

Returns the number of elements on the list.

Note that this is a O(1) operation as the object caches the list
length.

=item $head = $l->head

Returns the first element of the list.

If the list is empty returns undef.

=item $l->unshift($e)

Inserts the given element at the beginning of the list.

=item $e = $l->shift

Removes the first element on the list and returns it.

If the list is empty returns undef.

=item $l2 = $l1->clone

Returns a copy of the given list.

=item @e = $l->elements

Returns a Perl list with the elements inside the object.

=item $l->reverse_iterative

=item $l->reverse_recursive

=item $l->reverse

Reverses the list in place.

These methods reset the iterator making it point to the list head.

=item $l->reset

Resets the list iterator making it point to the head element.

=item $l->advance

Advances the iterator to the next element.

Return a false value when the end of the list is reached.

=item $e = $l->next

Returns the next element at the iterator possition.

=item $l->insert($e)

Inserts the given element at the iterator position.

This method can be used to insert elements at the end of the list:

  1 while ($l->advance); # moves to the end
  $l->insert("tail element");

=item $e = $l->remove

Removes the next element at the iterator position.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Salvador FandiE<ntilde>o (sfandino@yahoo.com)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
