package Player;

use strict;
use warnings;

use Hero;
use Deck;
use parent qw/Class::Accessor::Fast/;

my @attributes = qw/
	name
	used_mana
	max_mana
	hero
	deck
	hand
	field
	is_turn
	is_turn_initialized
/;

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(@attributes);

my $DEFAULT_MANA   = 0;
my $INIT_HAND_NUM  = 3;
my $LIMIT_MAX_MANA_NUM = 10;
my $NO_DECK_DAMAGE = 1;
my $MAX_HAND_NUM   = 10;
my $MAX_FIELD_NUM  = 7;

sub build_by_player_name {
	my $class = shift;
	my ($name) = @_;

	my $hero = Hero->build;
	my $deck = Deck->build;

	return $class->new(+{
		name      => $name,
		used_mana => 0,
		max_mana  => $DEFAULT_MANA,
		hero      => $hero,
		deck      => $deck,
		hand      => +[],
		field     => +[],
		is_turn   => 0,
		is_turn_initialized => 0, # turnごとのinitialize
	});

}

sub initialize {
	my $self = shift;

	# 手札を3枚つける
	for my $no (1 .. $INIT_HAND_NUM) {
		$self->draw_card;
	}
}

sub turn_initialize {
	my $self = shift;
	my (%options) = @_;

	$self->draw_card unless ($options{no_draw});
	$self->increment_max_mana;
	$self->reset_mana;
	$self->set_field_card_attackable;
	$self->set_is_turn_initialized(1);
}

sub is_turn {
	my $self = shift;

	return $self->get_is_turn ? 1 : 0;
}

sub is_turn_initialized {
	my $self = shift;

	return $self->get_is_turn_initialized ? 1 : 0;
}

sub turn_start {
	my $self = shift;

	$self->set_is_turn(1);
	$self->set_is_turn_initialized(0);
}

sub turn_end {
	my $self = shift;

	$self->set_is_turn(0);
}

sub draw_card {
	my $self = shift;

	# deckがないときはダメージ
	if ($self->get_deck->deck_num == 0) {
		$self->add_damage($NO_DECK_DAMAGE);
		return;
	}

	# handが多すぎるときはhandに加えず消去
	if ($self->hand_num > $MAX_HAND_NUM) {
		$self->get_deck->draw_card;
	}

	# handに加える
	push (@{$self->get_hand}, $self->get_deck->draw_card);
}

sub play_card_by_no {
	my $self = shift;
	my ($no) = @_;

	# fieldにcard多すぎ
	return +{
		has_error => 1,
		message   => "too much card on field",
	} unless ($self->field_num <= $MAX_FIELD_NUM);

	# no - 1 番目から 1枚取る
	my $played_card = splice(@{$self->get_hand}, $no - 1, 1);

	$played_card->set_played;
	$played_card->set_attacked;

	if ($played_card->get_cost > $self->usable_mana) {
		return +{
			has_error => 1,
			message   => "not enough mana",
		};
	}

	# mana使う
	$self->use_mana_by_cost($played_card->get_cost);

	push (@{$self->get_field}, $played_card);

	return +{
		has_error => 0,
	};
}

# popはしない！！名前が微妙？？
sub pick_field_card_by_no {
	my $self = shift;
	my ($no) = @_;

	return $self->get_field->[$no - 1];
}

sub add_damage {
	my $self = shift;
	my ($damage) = @_;

	$self->get_hero->add_damage($damage);
}

sub surrender {
	my $self = shift;

	my $damage = $self->get_hero->get_health;
	$self->add_damage($damage);
}

sub usable_mana {
	my $self = shift;

	return $self->get_max_mana - $self->get_used_mana;
}

sub use_mana_by_cost {
	my $self = shift;
	my ($cost) = @_;

	my $next_used_mana = $self->get_used_mana + $cost;
	$self->set_used_mana($next_used_mana);
}

sub reset_mana {
	my $self = shift;

	$self->set_used_mana(0);
}

sub increment_max_mana {
	my $self = shift;

	return if ($self->get_max_mana == $LIMIT_MAX_MANA_NUM);

	my $next_max_mana = $self->get_max_mana + 1;
	$self->set_max_mana($next_max_mana);
}

sub cleanup_field {
	my $self = shift;

	my $cleanuped_field = $self->field_list;
	$self->set_field($cleanuped_field);
}

sub set_field_card_attackable {
	my $self = shift;

	for my $card (@{$self->field_list}) {
		$card->set_no_attacked;
	}
}

sub can_attack {
	my $self = shift;

	return (scalar @{$self->attackable_card_list} > 0) ? 1 : 0
}

sub can_play {
	my $self = shift;

	return (scalar @{$self->playable_card_list} > 0) ? 1 : 0
}

sub get_hero_health {
	my $self = shift;

	return $self->get_hero->get_health;
}

sub is_alive {
	my $self = shift;

	return $self->get_hero->get_health > 0 ? 1 : 0;
}

sub attackable_card_list {
	my $self = shift;

	return +[ grep { $_->can_attack } @{$self->field_list} ];
}

sub playable_card_list {
	my $self = shift;

	return +[ grep { $_->get_cost <= $self->usable_mana } @{$self->hand_list} ];
}

sub field_list {
	my $self = shift;

	return +[ grep { $_->is_alive } @{$self->get_field}];
}

sub hand_list {
	my $self = shift;

	return +[ grep { $_->is_alive } @{$self->get_hand}];
}

sub hand_num {
	my $self = shift;

	return scalar @{$self->get_hand};
}

sub field_num {
	my $self = shift;

	return scalar @{$self->get_field};
}

1;