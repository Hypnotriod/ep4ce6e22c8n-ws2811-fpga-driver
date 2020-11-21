
/*
* Main.sv
*
*  Author: Ilya Pikin
*/

module Main
(
	input	clkIN,
	input	nResetIN,
	input rxIN,
	output txOUT
);

localparam IR_COMMAND_EQ   = 32'h00ff906f;
localparam IR_COMMAND_PLAY = 32'h00ffc23d;
localparam IR_COMMAND_PREV = 32'h00ff22dd;
localparam IR_COMMAND_NEXT = 32'h00ff02fd;
localparam IR_COMMAND_MINS = 32'h00ffe01f;
localparam IR_COMMAND_PLUS = 32'h00ffa857;

localparam UNITS_NUMBER = 100;
localparam PATTERN_COLORS_NUMBER = 128;
localparam PATTERNS_NUMBER = 4;
localparam CLOCK_SPEED = 50_000_000;
localparam UPDATES_PER_SECOND = 20;

reg [$clog2(PATTERNS_NUMBER) - 1:0] patternIndex;
reg [$clog2(PATTERN_COLORS_NUMBER) - 1:0] colorIndex;
reg [$clog2(PATTERN_COLORS_NUMBER) - 1:0] colorIndexShift;
reg colorIndexShiftDirection;
reg [2:0] colorSwapIndex;
reg [$clog2(UNITS_NUMBER) - 1:0] unitCounter;
reg txStart;
reg pause;
reg beginTransmissionDelay;

wire ws2811Busy;
wire beginTransmission;
wire [23:0] colorData;
wire [23:0] colorDataSwapped;
wire [0:$clog2(PATTERNS_NUMBER * PATTERN_COLORS_NUMBER) - 1] colorIndexComputed;
wire irCommandReceived;
wire [31:0] irCommand;
wire rxFiltered;

initial begin
	patternIndex = 0;
	colorIndex = 0;
	colorIndexShift = 0;
	colorIndexShiftDirection = 0;
	colorSwapIndex = 0;
	unitCounter = 0;
	txStart = 0;
	pause = 0;
	beginTransmissionDelay <= 0;
end

assign colorIndexComputed = {patternIndex, (colorIndex + colorIndexShift)};

ROM1 rom(
	.clock(clkIN),
	.address(colorIndexComputed),
	.q(colorData)
);

ColorSwap colorSwapper (
	.dataIN(colorData),
	.swapIN(colorSwapIndex),
	.dataOUT(colorDataSwapped)
);

RXMajority3Filter rxInFilter (
	.clockIN(clkIN),
	.nResetIN(nResetIN),
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
	.dataIN(colorDataSwapped),
	.busyOUT(ws2811Busy),
	.txOUT(txOUT)
);

always @(posedge clkIN or negedge nResetIN) begin
	if (!nResetIN) begin
		patternIndex <= 0;
		colorIndex <= 0;
		colorIndexShift <= 0;
		colorIndexShiftDirection <= 0;
		colorSwapIndex <= 0;
		unitCounter <= 0;
		txStart <= 0;
		pause <= 0;
		beginTransmissionDelay <= 0;
	end
	else begin
		if (irCommandReceived) begin
			case (irCommand)
				IR_COMMAND_PLAY : pause <= ~pause;
				IR_COMMAND_EQ   : colorIndexShiftDirection <= ~colorIndexShiftDirection;
				IR_COMMAND_NEXT : patternIndex <= patternIndex + 1;
				IR_COMMAND_PREV : patternIndex <= patternIndex - 1;
				IR_COMMAND_PLUS : colorSwapIndex <= (colorSwapIndex == 3'd5) ? 0 : (colorSwapIndex + 1);
				IR_COMMAND_MINS : colorSwapIndex <= (colorSwapIndex == 0) ? 3'd5 : (colorSwapIndex - 1);
			endcase
		end
	
		if (beginTransmission) begin
			unitCounter <= UNITS_NUMBER;
			colorIndex <= 0;
			case ({colorIndexShiftDirection, pause})
				2'b10 : colorIndexShift <= colorIndexShift + 1;
				2'b00 : colorIndexShift <= colorIndexShift - 1;
			endcase
			beginTransmissionDelay <= 1;
		end
		else if (beginTransmissionDelay) begin
			beginTransmissionDelay <= 0;
		end
		else if (unitCounter != 0 && !ws2811Busy) begin
			colorIndex <= colorIndex + 1;
			unitCounter <= unitCounter - 1;
			txStart <= 1;
		end
		else begin
			txStart <= 0;
		end
	end
end

endmodule
