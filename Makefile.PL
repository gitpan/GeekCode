# Makefile.PL for Convert::GeekCode module  -*- perl -*-

use ExtUtils::MakeMaker;

WriteMakefile (
    NAME         => 'Convert::GeekCode',
    DISTNAME     => 'GeekCode',
    ABSTRACT     => 'Convert and generate geek codes sequences',
    AUTHOR       => 'Autrijus Tang (autrijus@autrijus.org)',
    VERSION_FROM => 'GeekCode.pm',
    EXE_FILES    => [ <bin/*> ],
    dist         => { COMPRESS => 'gzip', SUFFIX => 'gz' }
);
