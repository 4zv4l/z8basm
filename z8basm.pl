#!/usr/bin/env perl

use v5.38;

# 0000 0000 | 0000 0000
# OP        | ARGS
#             REG1 REG2
#             8bit literal
#             #label

my %registers = (
    'A' => 0,
    'B' => 1,
    'C' => 2,
    'BP' => 3,
    'SP' => 4,
    'PC' => 5,
    'FLAGS' => 6
);
my %instructions = (
    'nop' => 0,
    'add' => 1,
    'sub' => 2,
    'push' => 3,
    'pop' => 4,
    'jmpz' => 5,
    'jmpnz' => 6,
    'cmp' => 7
);

die "usage: $0 [code file]\n" unless $ARGV[0];

open my $input, '<', $ARGV[0] or die "$!";
my $code = join '', <$input>;
close($input);

sub remComments {
    $code =~ s/;.*//g;
}
sub remEmptyLines {
    $code =~ s/\s*\n/\n/g;
}

remComments();
remEmptyLines();
my $lines = join ' ', map { $_ =~ s/^\s+//; $_ } split "\n", $code;
my @tokens = split ' ', $lines;

sub getToken { shift @tokens; }

sub getUntilNext {
    my @arr = ();
    my $token;
    while ($token = getToken()) {
        last if grep(/^$token$/, keys %instructions) or $token =~ /:$/;
        push @arr, $token;
    }
    unshift @tokens, $token;
    return @arr;
}

# get statement
# addr -> statement
my $idx = 0;
my %statements;
my %labels;
while (my $token = getToken()) {
    if ($token =~ /:$/) {
        $labels{$token} = $idx*2;
    }
    if (grep(/^$token$/, keys %instructions)) {
        #print "found instruction: $token\n";
        @{$statements{$idx}} = ($token, getUntilNext());
        $idx++;
    }
}

# translate label to addr
for my $key (keys %statements) {
    @{$statements{$key}} = map { s/#//; $labels{$_.':'} || $_ } @{$statements{$key}};
}

# converts statements to hex and write it to a.out
my @all = @statements{sort { $a <=> $b } keys %statements};
open my $output, '>', 'a.out';
for my $arr (@all) {
    my @arr = @$arr;

    my $op = sprintf "%.2x", $instructions{shift(@arr)};
    print "0x$op ";
    print $output pack("H*", $op);
    if (exists $registers{$arr[0]}) {
        if (scalar @arr == 1) {
            my $regs = "0" . (sprintf "%x", $registers{$arr[0]} || "0");
            printf "0x%s", $regs;
            print $output pack("H*", $regs);
        } else {
            (my $r1, my $r2) = map {sprintf "%x", $registers{$_}} @arr;
            my $regs = ($r1 || "0") . ($r2 || "0");
            printf "0x%s", $regs;
            print $output pack("H*", $regs);
        }
    } else {
        my $literal = sprintf "%.2x", shift(@arr);
        print "0x$literal";
        print $output pack("H*", $literal);
    }
    print " ", join(' ', @$arr), "\n";
}
close($output);
