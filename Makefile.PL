#!/usr/bin/perl
# $File: //member/autrijus/GeekCode/Makefile.PL $ $Author: autrijus $
# $Revision: #4 $ $Change: 2162 $ $DateTime: 2001/10/20 01:13:05 $

use ExtUtils::MakeMaker;
require 5.005;

WriteMakefile (
    NAME         => 'Convert::GeekCode',
    DISTNAME     => 'GeekCode',
    ABSTRACT     => 'Convert and generate geek codes sequences',
    AUTHOR       => 'Autrijus Tang (autrijus@autrijus.org)',
    VERSION_FROM => 'GeekCode.pm',
    EXE_FILES    => [ <bin/*> ],
    dist         => { COMPRESS => 'gzip', SUFFIX => 'gz' }
);
