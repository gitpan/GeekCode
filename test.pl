use lib 'blib/lib';
use Convert::GeekCode;
use Test;
use strict;

BEGIN { plan tests => 2 }
ok(1);

my @out = geek_decode(<<'.', 'geekcode', 3.12, 'zh_tw');
-----BEGIN GEEK CODE BLOCK-----
Version: 3.12
GB/C/CM/CS/CC/ED/H/IT/L/M/MU/P/SS/TW/AT d---x s+: a--- C++++ UB++++
P++++$ L+ E--- W+++$ N++ o? K w++(++++) O-- M- V-- PS+++ PE Y+
PGP- t+ 5? X+ R+++ !tv b++++ DI+++@ D++ G+++ e-- h* r+ z**
------END GEEK CODE BLOCK------
.

ok($#out, 65);
