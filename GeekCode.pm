package Convert::GeekCode;

=head1 NAME

Convert::GeekCode - Convert and generate geek code sequences.

=head1 SYNOPSIS

    use Convert::GeekCode; # exports geek_decode()

    print geek_decode(<<'.'); # yes, that's author's geek code
-----BEGIN GEEK CODE BLOCK-----
Version: 3.12
GB/C/CM/CS/CC/ED/H/IT/L/M/MU/P/SS/TW/AT d---x s+: a--- C++++ UB++++
P++++$ L+ E--- W+++$ N++ o? K w++(++++) O-- M- V-- PS+++ PE Y+
PGP- t+ 5? X+ R+++ !tv b++++ DI+++@ D++ G+++ e-- h* r+ z**
------END GEEK CODE BLOCK------
.

=cut

# ------------------------
# Modules and declarations
# ------------------------

require 5.001;

use vars qw/@ISA @EXPORT $VERSION $DELIMITER/;

$VERSION = '0.2';
$DELIMITER = " ";

use strict;
use Exporter;

# ----------------
# Exporter section
# ----------------

@ISA    = qw/Exporter/;
@EXPORT = qw/geek_encode geek_decode/;

sub new {
    my $class   = shift;
    my $id      = shift || 'geekcode';
    my $version = shift || '3.12';
    my $lang    = shift || 'en_us';
    my $self    = { _ => {}};
    my ($cursec, $curcode, $curval);

    $lang =~ tr/-/_/; # paranoia

    open _, locate("$id-$version-$lang.txt")
        or die "canno locate $id-$version-$lang.txt in @INC";
    while (<_>) {
        chomp;
        if (/^\[([^:]*):(.*)\]$/) {
            $cursec = $1;
            $self->{_}{$cursec}{_} = $2;
        }
        elsif (!$_) {
            if (defined $cursec) {
                $self->{_}{$cursec}{$curcode} = $curval;
            }
            elsif ($curcode) {
                $self->{$curcode} = $curval;
            }
            $curcode = '';
        }
        elsif ($curcode) {
            $curval .= $_;
        }
        else {
            $curcode = $_;
            $curval  = '';
        }
    }
    close _;

    return bless($self, $class);
}

sub decode {
    my $self = shift;
    my $code = shift;
    my @ret;

    $code = $1
        if $code =~ m|\Q$self->{Head}\E([\x00-\xff]+)\Q$self->{Tail}\E| or
            die "can't find geek code block; stop.";
    $code =~ s|[\x00-\xff]*?^$self->{Begin}|_|m or die;

    foreach my $chunk (split(/[\s\t\n\r]+/, $code)) {
        next unless $chunk =~ m|^(\!?\w+)\b|;
        my $head = $1;
        while ($head) {
            if (exists($self->{_}{$head})) {
                my $sec = $self->{_}{$head};
                my $out;

                push @ret, $sec->{_};
                $chunk = substr($chunk, length($head));
                $out = $sec->{"''"} . $DELIMITER
                    if !$chunk or $chunk =~ /^[\>\(]/;

                while ($chunk) {
                    next if $self->tokenize($sec, \$chunk, \$out);
                    next if $self->tokenize($self->{_}{''}, \$chunk, \$out);

                    warn "parse error: ", substr($chunk, 0, 1);
                    $chunk = substr($chunk, 1);
                }
                push @ret, $out;
                last;
            }
            $head = substr($head, 0, -1);
        }
    }

    return @ret;
}

sub encode {
    my $self = shift;
    my $code = shift;
    my @out;

    foreach my $sec (split(/[\s\t\n\r]+/, $self->{Sequence})) {
        my $secref = $self->{_}{$sec} or next;
        $sec = $self->{Begin} if $sec eq '_';
        push @out, $code->($secref->{_}, map {
            my $sym = $secref->{$_};
            s/[\x27\/]//g;
            (((index($_, $sec) > -1) ? $_ : $_ eq '!' ? "$_$sec" : "$sec$_"), $sym);
        } grep {
            $_ ne '_' and length($_)
        } sort {
            calcv($a) cmp calcv($b);
        } keys(%{$secref}));
        $out[-1] =~ s|\s+|/|g;
        $out[-1] =~ s|/+$||;
        $out[-1] =~ s|(?<=.)$sec||g;
    }

    return join("\n",
        $self->{Head},
        $self->{Ver}.$self->{Version},
        join(' ', @out),
        $self->{Tail},
        '',
    );
}

sub calcv {
    my $sym = shift or return '';

    if (substr($sym, 1, 1) eq '+') {
        return chr(0) x (10 - length($sym));
    }
    elsif (substr($sym, 1, 1) eq '-') {
        return chr(2) x length($sym);
    }
    elsif ($sym eq "''") {
        return chr(1);
    }
    else {
        return $sym;
    }
}

sub tokenize {
    my ($self, $sec, $chunk, $out) = @_;

    foreach my $key (sort {length($b) <=> length($a)} keys(%{$sec})) {
        next if $key eq '_' or !$key or $key eq "''";

        if ($key =~ m|/(.+)/|) {
            if ($$chunk =~ s|^$1||) {
                $$out .= $sec->{$key} . $DELIMITER;
                return 1;
            }
        }
        else {
            if (substr($$chunk, 0, length($key)-2) eq substr($key, 1, -1)) {
                $$chunk = substr($$chunk, length($key)-2);
                $$out .= $sec->{$key} . $DELIMITER;
                return 1;
            }
        }
    }
    return;
}

sub locate {
    my $path = (caller)[0];
    my $file = $_[0];

    $path =~ s|::|/|g;
    $path =~ s|\w+\$||;

    unless (-e $file) {
        foreach my $inc (@INC) {
            last if -e ($file = join('/', $inc, $_[0]));
            last if -e ($file = join('/', $inc, $path, $_[0]));
        }
    }

    return -e $file ? $file : undef;
}

sub geek_decode {
    my $code = shift;
    my $obj = __PACKAGE__->new(@_); # XXX should auto-detect version

    return $obj->decode($code);
}

sub geek_encode {
    my $code = shift;
    my $obj = __PACKAGE__->new(@_); # XXX should auto-detect version

    return $obj->encode($code);
}

1;

__END__

=head1 DESCRIPTION

Convert::GeekCode converts and generates Geek Code L<http://geekcode.com/>
sequences. It supports different charsets and user-customizable codesets.

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.org>

Copyright (c) 2001 by Autrijus Tang.  All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
