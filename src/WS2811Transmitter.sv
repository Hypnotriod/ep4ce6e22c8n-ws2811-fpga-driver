
/*
*  Author: Ilya Pikin
*/

module WS2811Transmitter
# (
	CLOCK_SPEED = 50_000_000
)
(
	input	clkIN,
	input startIN,
	input [23:0] dataIN,
	output busyOUT,
	output dataOUT
);

localparam DIVIDER_100_NS = 10_000_000;

reg [4:0]  cnt100ns;
reg [24:0] dataShift;
reg busy;
reg data;

wire [24:0] dataShifted = (dataShift << 1);
wire clock100ns;

initial begin
	busy = 0;
	data  = 0;
	cnt100ns = 5'd0;
end

assign busyOUT = busy;
assign dataOUT = data;

ClockDivider #(.VALUE(CLOCK_SPEED / DIVIDER_100_NS)) clock100nsDivider (
	.clkIN(clkIN),
	.nResetIN(busy),
	.clkOUT(clock100ns)
);

always @(negedge clkIN) begin
	if (startIN && ~busy) begin
		busy <= 1;
		dataShift <= {dataIN, 1'b1};
		data <= 1;
	end
	
	if (clock100ns && busy) begin
		cnt100ns <= cnt100ns + 5'd1;
		if (cnt100ns == 5'd4 && ~dataShift[24]) begin
			data <= 0;
		end
		if (cnt100ns == 5'd11 && dataShift[24]) begin
			data <= 0;
		end
		if (cnt100ns == 5'd24) begin
			cnt100ns <= 5'd0;
			dataShift <= dataShifted;
			if (dataShifted == 25'h1000000) begin
				busy <= 0;
			end
			else begin
				data <= 1;
			end			
		end
	end
end

endmodule
