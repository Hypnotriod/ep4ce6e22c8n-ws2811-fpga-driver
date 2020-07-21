
module WS2811Transmitter
# (
	CLOCK_SPEED = 50_000_000
)
(
	input	clkIN,
	input startIN,
	input [23:0] dataIN,
	output reg busyOUT,
	output reg dataOUT
);

initial begin
	busyOUT = 0;
	dataOUT  = 0;
	cnt100ns = 5'd0;
end

parameter DIVIDER_100_NS = 10_000_000;

reg [4:0]  cnt100ns;
reg [24:0] dataShift;

wire [24:0] dataShifted = (dataShift << 1);
wire clock;

ClockDivider #(.VALUE(CLOCK_SPEED / DIVIDER_100_NS)) clockDivider (
	.clkIN(clkIN),
	.nResetIN(busyOUT),
	.clkOUT(clock)
);

always @(negedge clkIN) begin
	if (startIN && ~busyOUT) begin
		busyOUT <= 1;
		dataShift <= {dataIN, 1'b1};
		dataOUT <= 1;
	end
	
	if (clock && busyOUT) begin
		cnt100ns <= cnt100ns + 5'd1;
		if (cnt100ns == 5'd4 && ~dataShift[24]) begin
			dataOUT <= 0;
		end
		if (cnt100ns == 5'd11 && dataShift[24]) begin
			dataOUT <= 0;
		end
		if (cnt100ns == 5'd24) begin
			cnt100ns <= 5'd0;
			dataShift <= dataShifted;
			if (dataShifted == 25'h1000000) begin
				busyOUT <= 0;		
			end
			else begin
				dataOUT <= 1;
			end			
		end
	end
end

endmodule
