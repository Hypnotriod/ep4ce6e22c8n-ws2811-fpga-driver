
/*
*  Author: Ilya Pikin
*/

module Main
(
	input	clkIN,
	input	nResetIN,
	output txOUT
);

localparam UNITS_NUMBER = 100;
localparam PATTERN_PIXELS_NUMBER = 128;
localparam CLOCK_SPEED = 50_000_000;
localparam UPDATES_PER_SECOND = 20;

reg [$clog2(PATTERN_PIXELS_NUMBER - 1):0] romAddress;
reg [$clog2(PATTERN_PIXELS_NUMBER - 1):0] romShiftAddress;
reg [$clog2(UNITS_NUMBER - 1):0] unitIndex;
reg txStart;

wire busy;
wire beginTransmission;
wire [23:0] romData;
wire [$clog2(PATTERN_PIXELS_NUMBER - 1):0] romAddressComputed = romAddress + romShiftAddress;

initial begin
	romAddress = 0;
	romShiftAddress = 0;
	unitIndex = UNITS_NUMBER;
	txStart = 0;
end

ROM1 rom(.clock(clkIN), .address(romAddressComputed), .q(romData));

ClockDivider #(.VALUE(CLOCK_SPEED / UPDATES_PER_SECOND))
	beginTransmissionTrigger (
	.clkIN(clkIN),
	.nResetIN(nResetIN),
	.clkOUT(beginTransmission)
);

WS2811Transmitter #(.CLOCK_SPEED(CLOCK_SPEED)) 
	ws2811tx (
	.clkIN(clkIN),
	.startIN(txStart),
	.dataIN(romData),
	.busyOUT(busy),
	.txOUT(txOUT)
);

always @(posedge clkIN) begin
	if (beginTransmission) begin
		unitIndex <= 0;
		romAddress <= 0;
		romShiftAddress <= romShiftAddress + 1;
	end

	if (unitIndex != UNITS_NUMBER && ~busy) begin
		romAddress <= romAddress + 1;
		unitIndex <= unitIndex + 1;
		txStart <= 1;
	end
	else begin
		txStart <= 0;
	end
end

endmodule
