package Card;

use strict;
use warnings;

use parent qw/Class::Accessor::Fast/;

my @attributes = qw/
	cost
	attack
	health
	charge
	is_attacked
/;

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(@attributes);

sub build_by_conf {
	my $class = shift;
	my ($conf) = @_;

	return $class->new(+{
		cost        => $conf->{cost},
		attack      => $conf->{attack},
		health      => $conf->{health},
		charge      => $conf->{charge} || 0,
		is_attacked => 0,
	});

}

sub is_alive {
	my $self = shift;

	return $self->get_health > 0 ? 1 : 0;
}

sub set_attacked {
	my $self = shift;

	$self->set_is_attacked(1);
}

sub set_no_attacked {
	my $self = shift;

	$self->set_is_attacked(0);
}

sub has_charge {
	my $self = shift;

	$self->get_charge ? 1 : 0;
}

sub add_damage {
	my $self = shift;
	my ($damage) = @_;

	my $new_health = $self->get_health - $damage;
	$self->set_health($new_health);
}

sub can_attack {
	my $self = shift;

	return $self->get_is_attacked ? 0 : 1;
}

1;