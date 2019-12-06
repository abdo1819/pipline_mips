addi	$t0, $0, 0xf1		# $t0 = 1
andi    $t1, $t0, 0xff          # $t1 = 0xF1
sw $t1, 84($0)                  # addr 84, write 0xcd
