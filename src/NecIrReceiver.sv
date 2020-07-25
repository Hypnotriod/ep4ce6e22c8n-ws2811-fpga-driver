
/*
*  Author: Ilya Pikin
*/

module NecIrReceiver
# (
	CLOCK_SPEED = 50_000
)
(
	input	clkIN,
	input rxIN,
	output rxReadyOUT,
	output [31:0] dataOUT
);

localparam DIVIDER_281250_NS = 3556; // 562.5µs / 2 = 281.25µs

reg [23:0] timingShift;
reg [33:0] dataShift;
reg rxPositiveEdgeDetect;
reg clock281250nsParity;
reg clock281250nsNReset;

wire clock281250ns;
wire startFrameReceived;

initial begin
	rxPositiveEdgeDetect = 0;
	clock281250nsParity = 0;
	clock281250nsNReset = 1;
	timingShift = 24'd0;
	dataShift = 34'd0;
end

assign dataOUT = dataShift[31:0];
assign rxReadyOUT = dataShift[32];
assign startFrameReceived = dataShift[33];

ClockDivider #(.VALUE(CLOCK_SPEED / DIVIDER_281250_NS)) clock281250nsDivider (
	.clkIN(clkIN),
	.nResetIN(clock281250nsNReset),
	.clkOUT(clock281250ns)
);

always @(posedge clkIN) begin
	if (rxIN && ~rxPositiveEdgeDetect) begin
		rxPositiveEdgeDetect <= 1;
		clock281250nsParity <= 0;
		clock281250nsNReset <= 0;
		timingShift <= 24'd0;
		
		case ({startFrameReceived, rxReadyOUT, timingShift})
			26'h0ffff00 : dataShift <= 34'h200000001;
			26'h2000002 : dataShift <= {dataShift[33], dataShift[31:0], 1'd0};
			26'h2000008 : dataShift <= {dataShift[33], dataShift[31:0], 1'd1};
			default : dataShift <= 34'd0;
		endcase
	end
	
	if (clock281250ns) begin
		clock281250nsParity <= ~clock281250nsParity;
		
		if (~clock281250nsParity) begin
			timingShift <= {timingShift[22:0], rxIN};
		end
	end
	
	if (rxPositiveEdgeDetect == 1) begin
		clock281250nsNReset <= 1;
	end
	
	if (~rxIN && rxPositiveEdgeDetect) begin
		rxPositiveEdgeDetect <= 0;
	end
end

endmodule
