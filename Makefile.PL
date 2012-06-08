use 5.008;

use ExtUtils::MakeMaker;

WriteMakefile( NAME           => 'List::SinglyLinked',
               VERSION_FROM   => 'lib/List/SinglyLinked.pm',
               ABSTRACT_FROM  => 'lib/List/SinglyLinked.pm',
               AUTHOR         => 'Salvador Fandiño <sfandino@yahoo.com>',
               INC            => '-I.' );
