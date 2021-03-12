main:
	lui	$r0,7
	add	$r1,$r0,$r0
	sw	$r1,$r5(4)
	beq	$r0,$r1,main
func:
	sll	$r2,$r0,1
	lw	$r3,$r5(4)
	bgezal	$r0,func1
func1:
	jr	$r0
	jal	func
