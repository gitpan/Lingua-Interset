# ABSTRACT: Common code for drivers of tagsets from files in CoNLL 2006 format.
# This will be the common ancestor of e.g. BG::Conll and DA::Conll.
# It will not be used for tagsets that are derived from non-Conll tagsets, e.g. CS::Conll and EN::Conll.
# (Most Conll tagsets are derived from non-Conll tagsets but we do not care unless we also have a driver for the non-Conll ancestor.)
# Copyright © 2014 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::Conll;
use strict;
use warnings;
our $VERSION = '2.014'; # VERSION: generated by DZP::OurPkgVersion

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset';



###!!!



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode_conll
{
    my $self = shift;
    my $tag = shift;
    my $tagset = shift; # e.g. 'da::conll'
    my $fs = Lingua::Interset::FeatureStructure->new();
    $fs->set_tagset($tagset);
    my $atoms = $self->atoms();
    my $feature_names = $self->features_all();
    # Three components: coarse-grained pos, fine-grained pos, features
    # Only features with non-empty values appear in the tag.
    # example: N\nNC\ngender=common|number=sing|case=unmarked|def=indef
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    $features = '' if($features eq '_');
    my @features_conll = split(/\|/, $features);
    my %features_conll;
    foreach my $f (@features_conll)
    {
        if($f =~ m/^(\w+)=(.+)$/)
        {
            $features_conll{$1} = $2;
        }
        else
        {
            $features_conll{$f} = $f;
        }
    }
    $atoms->{pos}->decode_and_merge_hard($subpos, $fs);
    foreach my $name (@{$feature_names})
    {
        if(defined($features_conll{$name}) && $features_conll{$name} ne '')
        {
            $atoms->{$name}->decode_and_merge_hard($features_conll{$name}, $fs);
        }
    }
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
# Encodes only features while the CPOS and POS must have been encoded in
# tagset-specific code.
#------------------------------------------------------------------------------
sub encode_conll
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    # Every CoNLL tagset has a different relation between pos and subpos, so we want them already encoded.
    my $pos = shift;
    my $subpos = shift;
    # The list of feature names may differ for different parts of speech so we want to get a reference to the list.
    my $feature_names = shift;
    my $atoms = $self->atoms();
    my $subpos = $atoms->{pos}->encode($fs);
    my @features;
    foreach my $name (@{$feature_names})
    {
        # Sanity check: did we define atoms for all features?
        confess("Undefined atom for feature $name") if(!defined($atoms->{$name}));
        my $value = $atoms->{$name}->encode($fs);
        if($value ne '')
        {
            # Value adjustments tailored for this physical tagset would come here.
            push(@features, "$name=$value");
        }
    }
    my $features = '_';
    if(scalar(@features) > 0)
    {
        $features = join('|', @features);
    }
    my $tag = "$pos\t$subpos\t$features";
    return $tag;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

Lingua::Interset::Tagset::Conll - Common code for drivers of tagsets from files in CoNLL 2006 format.

=head1 VERSION

version 2.014

Zatím mám čistě conllí (2006) ovladače pro bulharštinu a dánštinu, ale i ty jsou odvozené z jiných tagsetů, akorát je nemám podchycené.
Taky vlastně neodvozuju arabštinu (Conll a Conll2007).
Společné rysy:

- značka se skládá ze tří částí, CPOS, POS a FEATS; rysy (FEATS) lze ještě dále rozložit
- seznam rysů je pro každý jazyk jiný; pořadí rysů se může lišit i podle slovního druhu
- při encode je občas potřeba trochu čarovat, protože někdy se rys má prostě vynechat a jindy se má uvést, ale s nějakou všeobjímající hodnotou (unmarked)
- při decode se občas čaruje taky, aby se dovyplnily rysy, které daný tagset neznačí, ale automaticky vyplývají; zlepší to spolupráci s jinými ovladači

=head1 DESCRIPTION
# ABSTRACT: Common code for drivers of tagsets from files in CoNLL 2006 format.
# This will be the common ancestor of e.g. BG::Conll and DA::Conll.
# It will not be used for tagsets that are derived from non-Conll tagsets, e.g. CS::Conll and EN::Conll.
# (Most Conll tagsets are derived from non-Conll tagsets but we do not care unless we also have a driver for the non-Conll ancestor.)

Common code for drivers of tagsets from files in the CoNLL 2006 format.
These tags always consists of three tab-separated parts:
C<pos> (from the CoNLL C<CPOS> column),
C<subpos> (from the CoNLL C<POS> column), and
C<features> (from the CoNLL C<FEATS> column).
Features are always separated by a vertical bar.
The values of C<CPOS>, C<POS> and features differ across tagsets/treebanks.
Nevertheless, there is some minimal code that repeats for every CoNLL tagset.
This module provides the code and is thus intended as a common predecessor of
the language-specific CoNLL drivers.

Most CoNLL tagsets are derived from other pre-existing tagsets that use
a different format. If we have a driver for such pre-existing tagset,
then its CoNLL variant will be probably derived from that driver rather than
from this common CoNLL module.

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::BG::Conll>,
L<Lingua::Interset::Tagset::DA::Conll>,
L<Lingua::Interset::FeatureStructure>

=head1 AUTHOR

Dan Zeman <zeman@ufal.mff.cuni.cz>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Univerzita Karlova v Praze (Charles University in Prague).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
