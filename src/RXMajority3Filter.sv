
/*
* RXMajority3Filter.sv
*
*  Author: Ilya Pikin
*/

module RXMajority3Filter
(
	input clockIN,
	input nResetIN,
	input rxIN,
	output rxOUT
);

wire out;

reg [2:0] rxShift;

initial begin
	rxShift = 3'b111;
end

assign rxOUT = out;
assign out = (rxShift[0] & rxShift[1]) | (rxShift[0] & rxShift[2]) | (rxShift[1] & rxShift[2]);

always @(posedge clockIN or negedge nResetIN) begin
	if (!nResetIN) begin
		rxShift = 3'b111;
	end
	else begin
		rxShift <= {rxIN, rxShift[2:1]};
	end
end

endmodule
