package Toy2Arch;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(mnemonic2op op2mnemonic c2b parse d2h);

# Mnemonic 2 OP hash

my %m2o = (
	JMP => 0,
	ADC => 1,
	XOR => 2,
	SBC => 3,
	ROR => 4,
	TAT => 5,
	OR => 6,
	AND => 8,
	LDC => 9,
	BCC => 0xA,
	BNE => 0xB,
	LDI => 0xC,
	STT => 0xD,
	LDA => 0xE,
	STA => 0xF
);

my @o2m = qw(JMP ADC XOR SBC ROR TAT OR ??? AND LDC BCC BNE LDI STT LDA STA);

sub mnemonic2op {
	my $m = shift;
	my $o = $m2o{$m};
	return $o;
}

sub op2mnemonic {
	my $o = shift;
	return $o2m[$o];
}

sub c2b {
	my ($o, $i) = @_;
	$i += 0;
	$o += 0;
	my $iu = ($i >> 8);
	my $b1 = ($o * 16) | $iu;
	my $b2 = $i & 4095;
	return ($b1, $b2);
}

sub d2h {
	my $dec = shift;
	return uc sprintf("%.2x", $dec);
}

sub bytes {
	my $val = shift;
	my $bytes = $val / 256;
	$bytes = '$bytes';
	($bytes, undef) = split '.', $bytes;
	return ($bytes+1);
}

sub parse {
	my $file_ref = shift;
	my @file = @$file_ref;
	my $lpc = 0;
	my %RAM;
	my $text;
	
	foreach my $line (@file) {
		chomp $line;
		if ($line eq 'TEXT') {
			$segment = 'T';
			$text = $lpc;
			next;
		} elsif ($line eq 'DATA') {
			$segment = 'D';
			next;
		}
		if ($segment eq 'T') {
			my ($m, $i) = split ' ', $line;
			$RAM{$lpc}{'op'} = mnemonic2op(uc($m));
			$RAM{$lpc}{'da'} = $i+0 || 0;
			my ($b1, $b2) = c2b($RAM{$lpc}{'op'}, $RAM{$lpc}{'da'});
			$RAM{$lpc}{'b1'} = $b1;
			$RAM{$lpc}{'b2'} = $b2;
			$RAM{$lpc}{'hr'} = $line;
			$lpc += 16;
		} elsif ($segment eq 'D') {
			$RAM{$lpc}{'data'} = $line+0;
			$lpc += 8*bytes($RAM{$lpc}{'data'});
		}
	}
	return (\%RAM, $text);
}