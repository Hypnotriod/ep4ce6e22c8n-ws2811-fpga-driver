
/*
*  Author: Ilya Pikin
*/

module Main
(
	input	clkIN,
	input	nResetIN,
	input rxIN,
	output txOUT
);

localparam IR_COMMAND_PREV = 32'h00ff22dd;
localparam IR_COMMAND_NEXT = 32'h00ff02fd;

localparam UNITS_NUMBER = 100;
localparam PATTERN_COLORS_NUMBER = 128;
localparam PATTERNS_NUMBER = 4;
localparam CLOCK_SPEED = 50_000_000;
localparam UPDATES_PER_SECOND = 20;

reg [$clog2(PATTERNS_NUMBER - 1):0] patternIndex;
reg [$clog2(PATTERN_COLORS_NUMBER - 1):0] colorIndex;
reg [$clog2(PATTERN_COLORS_NUMBER - 1):0] colorIndexShift;
reg [$clog2(UNITS_NUMBER - 1):0] unitIndex;
reg txStart;

wire busy;
wire beginTransmission;
wire [23:0] romData;
wire [$clog2(PATTERNS_NUMBER + PATTERN_COLORS_NUMBER - 1):0] colorIndexComputed = {patternIndex, colorIndex + colorIndexShift};
wire irCommandReceived;
wire [31:0] irCommand;
wire rxFiltered;

initial begin
	patternIndex = 0;
	colorIndex = 0;
	colorIndexShift = 0;
	unitIndex = UNITS_NUMBER;
	txStart = 0;
end

ROM1 rom(.clock(clkIN), .address(colorIndexComputed), .q(romData));

RXMajority3Filter rxInFilter (
	.clockIN(clkIN),
	.rxIN(rxIN),
	.rxOUT(rxFiltered)
);

NecIrReceiver #(.CLOCK_SPEED(CLOCK_SPEED))
	necIrReceiver (
	.clkIN(clkIN),
	.nResetIN(nResetIN),
	.rxIN(~rxFiltered),
	.dataReceivedOUT(irCommandReceived),
	.dataOUT(irCommand)
);

ClockDivider #(.VALUE(CLOCK_SPEED / UPDATES_PER_SECOND))
	beginTransmissionTrigger (
	.clkIN(clkIN),
	.nResetIN(nResetIN),
	.clkOUT(beginTransmission)
);

WS2811Transmitter #(.CLOCK_SPEED(CLOCK_SPEED)) 
	ws2811tx (
	.clkIN(clkIN),
	.nResetIN(nResetIN),
	.startIN(txStart),
	.dataIN(romData),
	.busyOUT(busy),
	.txOUT(txOUT)
);

always @(posedge clkIN or negedge nResetIN) begin
	if (~nResetIN) begin
		patternIndex <= 0;
		colorIndex <= 0;
		colorIndexShift <= 0;
		unitIndex <= UNITS_NUMBER;
		txStart <= 0;
	end
	else begin
		if (irCommandReceived) begin
			case (irCommand)
				IR_COMMAND_NEXT : patternIndex <= patternIndex + 1;
				IR_COMMAND_PREV : patternIndex <= patternIndex - 1;
			endcase
		end
	
		if (beginTransmission) begin
			unitIndex <= 0;
			colorIndex <= 0;
			txStart <= 1;
			colorIndexShift <= colorIndexShift + 1;
		end
		else if (unitIndex != UNITS_NUMBER && ~busy) begin
			colorIndex <= colorIndex + 1;
			unitIndex <= unitIndex + 1;
			txStart <= 1;
		end
		else begin
			txStart <= 0;
		end
	end
end

endmodule
