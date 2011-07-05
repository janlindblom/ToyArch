#!/usr/bin/perl

use strict;
#use warnings;
use Toy2Arch qw(mnemonic2op op2mnemonic c2b parse d2h);

# Register definitions
my ($A, $PC, $T);

# Flags
my ($C, $Z);

# Instruction pipe
my ($current, $next);
my @pipe;

# Pseudo Memory
my %RAM;

sub init {
	($A, $T, $PC, $C, $Z) = (0,0,0,0,0);
	my @buffer = <>;
	my ($ram_ref, $start) = parse(\@buffer);
	%RAM = %{$ram_ref};
	$PC = $start;
	
	@pipe = ($PC, $PC+16);

#	use Data::Dumper;
#	print Dumper %RAM;
#	print "\n", @pipe, "\n";
}

sub execute {
	my $lpc = shift;
#	$PC+=16;
#	my ($b1, $b2) = c2b($RAM{$lpc}{'op'},$RAM{$lpc}{'da'});
#	print "bytes: $b1 $b2\n";
#	print "$RAM{$lpc}{hr}\n";
	print d2h($lpc) . " ";
	print d2h($RAM{$lpc}{b1});
	print d2h($RAM{$lpc}{b2}) . "\n";
	if ($RAM{$lpc}{'op'} == 0) {
#		$PC = $RAM{$lpc}{'da'};
		$PC += 16;
	} elsif ($RAM{$lpc}{'op'} == 1) {
		$A = $A + $RAM{$RAM{$lpc}{'da'}}{'data'};
		$PC += 16;
	} elsif ($RAM{$lpc}{'op'} == 5) {
		$T = $A;
		$PC += 16;
	} elsif ($RAM{$lpc}{'op'} == 14) {
		$A = $RAM{'data'}{$RAM{$lpc}{'da'}};
		$PC += 16;
	}
	$PC += 16;
	@pipe = ($PC, $PC+16);
}

sub step {
	$current = shift @pipe;
	$PC = $current;
	execute $PC;
	$next = $pipe[0] || 'EOF';
	
	printstate();
}

sub printstate {
	my ($chr, $nhr) = ($RAM{$current}{'hr'}, $RAM{$next}{'hr'});
	print "[$PC] A: $A, T: $T, C: $C, Z: $Z, Pipe: [$chr, $nhr]\n";
}

init;

#while (@pipe) {	
step;
#}
step;
step;
step;
step;
step;
step;
step;
step;
step;
step;
step;
print "\n";