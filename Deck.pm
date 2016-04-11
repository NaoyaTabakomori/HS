package Deck;

use strict;
use warnings;

use Conf;
use Card;
use List::Util qw/shuffle/;
use parent qw/Class::Accessor::Fast/;

my @attributes = qw/
	cards
/;

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(@attributes);

sub build {
	my $class = shift;

	my $DEFAULT_DECK_SEED = Conf->DEFAULT_DECK_SEED;

	my $cards = +[ shuffle map { Card->build_by_conf($_) } @$DEFAULT_DECK_SEED ];

	return $class->new(+{
		cards     => $cards,
	});

}

sub draw_card {
	my $self = shift;

	return shift @{$self->get_cards};
}

sub deck_num {
	my $self = shift;

	return scalar @{$self->get_cards};
}

1;