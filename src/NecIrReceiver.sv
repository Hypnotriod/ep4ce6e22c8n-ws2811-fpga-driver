
/*
*  Author: Ilya Pikin
*/

module NecIrReceiver
# (
	CLOCK_SPEED = 50_000
)
(
	input	clkIN,
	input	nResetIN,
	input rxIN,
	output dataReceivedOUT,
	output [31:0] dataOUT
);

localparam DIVIDER_281250_NS = 3556; // 562.5µs / 2 = 281.25µs; 1 / 0.00028125 ≈ 3556

reg [23:0] pulseSamplerShift;
reg [33:0] dataShift;
reg [31:0] dataBuffer;
reg [1:0] rxState;
reg rxPositiveEdgeDetect;
reg clock281250nsParity;
reg clock281250nsNReset;

wire clock281250ns;
wire startFrameReceived;
wire dataPacketReceived;

initial begin
	rxState = 2'd0;
	rxPositiveEdgeDetect = 0;
	clock281250nsParity = 0;
	clock281250nsNReset = 1;
	pulseSamplerShift = 24'd0;
	dataShift = 34'd0;
	dataBuffer = 32'd0;
end

assign dataReceivedOUT = rxState[0];
assign dataOUT = dataBuffer;
assign dataPacketReceived = dataShift[32];
assign startFrameReceived = dataShift[33];

ClockDivider #(.VALUE(CLOCK_SPEED / DIVIDER_281250_NS)) clock281250nsDivider (
	.clkIN(clkIN),
	.nResetIN(clock281250nsNReset),
	.clkOUT(clock281250ns)
);

always @(posedge clkIN or negedge nResetIN) begin
	if (~nResetIN) begin
		rxState <= 2'd0;
		rxPositiveEdgeDetect <= 0;
		clock281250nsParity <= 0;
		clock281250nsNReset <= 1;
		pulseSamplerShift <= 24'd0;
		dataShift <= 34'd0;
		dataBuffer <= 32'd0;
	end
	else begin
		case ({dataPacketReceived, rxState[1:0]})
			3'b100 : begin
				dataBuffer[31:0] <= dataShift[31:0];
				rxState <= 2'b11;
			end
			3'b111, 3'b110 : rxState <= 2'b10;
			default : rxState <= 2'd0;
		endcase
		
		case ({rxIN, rxPositiveEdgeDetect})
			2'b10 : begin
				rxPositiveEdgeDetect <= 1;
				clock281250nsParity <= 0;
				clock281250nsNReset <= 0;
				pulseSamplerShift <= 24'd0;
				
				case ({startFrameReceived, dataPacketReceived, pulseSamplerShift})
					26'h0ffff00 : dataShift <= 34'h200000001;
					26'h2000002 : dataShift <= {1'd1, dataShift[31:0], 1'd0};
					26'h2000008 : dataShift <= {1'd1, dataShift[31:0], 1'd1};
					default : dataShift <= 34'd0;
				endcase
			end
			2'b01 : rxPositiveEdgeDetect <= 0;
		endcase
		
		if (clock281250nsNReset == 0) begin
			clock281250nsNReset <= 1;
		end
		
		if (clock281250ns) begin
			clock281250nsParity <= ~clock281250nsParity;
			
			if (~clock281250nsParity) begin
				pulseSamplerShift <= {pulseSamplerShift[22:0], rxIN};
			end
		end
	end
end

endmodule
