#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

typedef struct st_list list;
typedef struct st_node node;

struct st_list {
    node *head;
    node **iterator;
    UV len;
};

struct st_node {
    node *next;
    SV *sv;
};

static list *
list_new() {
    list *l = (list*)malloc(sizeof(list));
    l->head = NULL;
    l->iterator = &l->head;
    l->len = 0;
    return l;
}

static node *
node_new(SV *sv) {
    node *n = (node *)malloc(sizeof(node));
    n->next = NULL;
    n->sv = newSVsv(sv);
    return n;
}

static UV
list_length(list *l) {
    return l->len;
}

static SV *
list_head(list *l) {
    node *h = l->head;
    return (h ? newSVsv(h->sv) : &PL_sv_undef);
}

static SV *
list_next(list *l) {
    node *n = *(l->iterator);
    return (n ? newSVsv(n->sv) : &PL_sv_undef);
}

static int
list_advance(list *l) {
    node *n = *(l->iterator);
    if (n) {
        l->iterator = &n->next;
        return 1;
    }
    return 0;
}

static void
list_insert_at(list *l, node **at, SV *sv) {
    node *n = node_new(sv);
    n->next = *at;
    *at = n;
    l->len++;
}

static SV *
list_remove_at(list *l, node **at) {
    node *n = *at;
    if (n) {
        SV *sv = n->sv;
        *at = n->next;
        if (l->iterator == &n->next) l->iterator = at;
        free(n);
        l->len--;
        return sv;
    }
    return &PL_sv_undef;
}

static void
list_unshift(list *l, SV *sv) {
    list_insert_at(l, &l->head, sv);
}

static SV *
list_shift(list *l) {
    return list_remove_at(l, &l->head);
}

static void
list_insert(list *l, SV *sv) {
    list_insert_at(l, l->iterator, sv);
}

static SV *
list_remove(list *l) {
    return list_remove_at(l, l->iterator);
}

static void
list_reset(list *l) {
    l->iterator = &l->head;
}

static list *
list_clone(list *l) {
    list *c = list_new();
    node *n, **t;
    for (n = l->head, t = &(c->head);
         n;
         n = n->next, t = &((*t)->next)) {
        *t = node_new(n->sv);
    }
    c->len = l->len;
    return c;
}

static void
list_reverse_iterative(list *l) {
    node *n = l->head;
    node *prev = NULL;
    while (n) {
        node *next = n->next;
        n->next = prev;
        prev = n;
        n = next;
    }
    l->head = prev;
    l->iterator = &l->head;
}

static node *
list_reverse_nodes_recursive(node *n, node *acu) {
    /* the funny thing is that as this function is tail recursive, GCC
     * transforms it into an iterative one and at the end, the machine
     * code generated for both variants is almost identical */
    if (n) {
        node *tail = n->next;
        n->next = acu;
        return list_reverse_nodes_recursive(tail, n);
    }
    return acu;
}

static void
list_reverse_recursive(list *l) {
    l->head = list_reverse_nodes_recursive(l->head, NULL);
    l->iterator = &l->head;
}

static void
list_DESTROY(list *l) {
    node *n = l->head;
    while (n) {
        node *next = n->next;
        SvREFCNT_dec(n->sv);
        free(n);
        n = next;
    }
    free(l);
}

MODULE = List::SinglyLinked		PACKAGE = List::SinglyLinked		PREFIX = list_

list *
list_new(klass)
    SV *klass = NO_INIT
C_ARGS:

list *
list_clone(list *l)

UV
list_length(list *l)

SV *
list_head(list *l)

void
list_unshift(list *l, SV *sv)

SV *
list_shift(list *l)

void
list_reset(list *l)

void
list_insert(list *l, SV *sv)

SV *
list_remove(list *l)

SV *
list_next(list *l)

void
list_reverse_iterative(list *l)

void
list_reverse_recursive(list *l)

void
list_DESTROY(list *l)

SV *
list_advance(list *l)
CODE:
    RETVAL = (list_advance(l) ? &PL_sv_yes : &PL_sv_no);
OUTPUT:
    RETVAL

void
elements(list *l)
PPCODE:
    if (GIMME_V == G_ARRAY) {
        node *n = l->head;
        while (n) {
            mXPUSHs(newSVsv(n->sv));
            n = n->next;
        }
        XSRETURN(l->len);
    }
    else {
        mPUSHu(l->len);
        XSRETURN(1);
    }



