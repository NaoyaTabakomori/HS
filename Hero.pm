package Hero;

use strict;
use warnings;

use parent qw/Class::Accessor::Fast/;

my @attributes = qw/
	health
/;

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(@attributes);

my $DEFAULT_HEALTH = 30;

sub build {
	my $class = shift;

	return $class->new(+{
		health     => $DEFAULT_HEALTH,
	});

}

sub is_alive {
	my $self = shift;

	return $self->get_health > 0 ? 1 : 0;
}

sub add_damage {
	my $self = shift;
	my ($damage) = @_;

	my $new_health = $self->get_health - $damage;
	$self->set_health($new_health);
}

1;