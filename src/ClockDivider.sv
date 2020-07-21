
module ClockDivider
# (
	parameter VALUE = 2
)
(
	input clkIN,
	input nResetIN,
	output clkOUT
);

Counter # (.TOP(VALUE)) counter (
	.clkIN(clkIN),
	.nResetIN(nResetIN),
	.counterOverflowOUT(clkOUT)
);

endmodule
