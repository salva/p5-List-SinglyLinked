#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8660;

BEGIN { use_ok('List::SinglyLinked') };

my $l = List::SinglyLinked->new;

is($l->head, undef, "head returns undef for empty lists");
is($l->length, 0, "length of the empty list is 0");
is_deeply([$l->elements], [], "elements returns and empty list");
is($l->next, undef, "no next element for empty list");
ok(!$l->advance, "iterator for empty list is always at the end");

$l->insert("foo");
is($l->head, "foo", "head returns the last element pushed");
is($l->head, "foo", "head returns the last element pushed repeatedly");
is($l->next, "foo", "iterator points at the element just inserted");
is($l->length, 1, "length after pushing one element is 1");
ok($l->advance, "iterator can advance over the element inserted");
is($l->next, undef, "iterator is at the end again");
is_deeply([$l->elements], ['foo'], "elements returns one element");
$l->reverse_iterative;
is_deeply([$l->elements], ['foo'], "reversing a one element list is a no op (iterative)");
is($l->next, "foo", "reversing the list resets the iterator (iterative)");
ok($l->advance, "can advance over element");
$l->reverse_recursive;
is_deeply([$l->elements], ['foo'], "reversing a one element list is a no op (recursive)");
is($l->next, "foo", "reversing the list resets the iterator (recursive)");
ok($l->advance, "can advance over element");

$l->unshift("bar");
is($l->head, "bar", "head returns the last element pushed");
is($l->length, 2, "length after pushing one element is 1");
is($l->next, undef, "iterator is at the end still");
is_deeply([$l->elements], [qw(bar foo)], "elements returns both elements in the right order");
$l->reverse_iterative;
is_deeply([$l->elements], [qw(foo bar)], "reverse_iterative works for two elements lists");
$l->reverse_recursive;
is_deeply([$l->elements], [qw(bar foo)], "reversing a one element list is a no op (recursive)");

$l->unshift("doz");
is($l->head, "doz", "head returns the last element pushed");
is($l->length, 3, "length is correct");
$l->reset;
is($l->next, "doz", "check iterator next");
ok($l->advance, "check iterator advance");
is($l->next, "bar", "check iterator next");
ok($l->advance, "check iterator advance");
is($l->next, "foo", "check iterator next");
ok($l->advance, "check iterator advance");
is($l->next, undef, "check iterator next");
ok(!$l->advance, "check iterator advance");

my $l2 = $l->clone;
is_deeply([$l2->elements], [qw(doz bar foo)], "clone elements");
is_deeply([$l2->elements], [$l->elements], "clone does not break source list");

$l->reverse_recursive;
is_deeply([$l->elements], [qw(foo bar doz)], "clone elements");
$l->reverse_iterative;
is_deeply([$l->elements], [qw(doz bar foo)], "clone elements");

ok($l->advance, "move to some place in the middle of the list") for (1..2);
$l->insert("goo");
$l->insert("fuu");
$l->advance;
$l->advance;
is_deeply([$l->elements], [qw(doz bar fuu goo foo)], "insert at iterator");
is($l->remove, "foo", "removed element");
is_deeply([$l->elements], [qw(doz bar fuu goo)], "remove at iterator");
is($l->remove, undef, "remove at the end returns undef");
is_deeply([$l->elements], [qw(doz bar fuu goo)], "remove at the end does nothing");

# and finally some brute force testing:

for my $size (10, 100, 500, 1000) {
    my @e = map { int rand 100 } 1..$size;
    my $l = List::SinglyLinked->new;
    $l->unshift($_) for reverse @e;
    for my $e (@e) {
        is ($e, $l->next, "check contents");
        ok($l->advance, "advance");
    }
    is ($l->next, undef, "undef at the end");
    ok(!$l->advance, "can advance after the end");
    is($l->length, $size, "list size is right");

    $l->reverse_iterative;
    is_deeply([$l->elements], [reverse @e], "reverse iterative");

    for (reverse @e) {
        is($l->head, $_, "head");
        is($l->shift, $_, "shift head");
    }

    $l = List::SinglyLinked->new;
    for my $e (@e) {
        $l->insert($e);
        ok($l->advance, "advance to the end");
    }
    is ($l->length, $size, "list size is right");
    is_deeply([$l->elements], \@e, "list contents");

    $l->reverse_recursive;
    is_deeply([$l->elements], [reverse @e], "reverse recursive");
    $l->reverse_recursive;

    $l->reset;
    my $pos = 0;
    for (1..($size/3)) {
        my $delta = int rand (@e/2);
        $pos += $delta;
        if ($pos >= @e) {
            $l->reset;
            $pos = $delta;
        }
        $l->advance for (1..$delta);
        splice(@e, $pos, 1);
        $l->remove;
        is_deeply([$l->elements], \@e, "elements after random remove");
    }
}


done_testing();

