
module Counter
# (
	parameter TOP = 2
)
(
	input clkIN,
	input nResetIN,
	output reg [$clog2(TOP - 1):0] counterOUT,
	output reg counterOverflowOUT
);

initial begin
	counterOUT = 0;
end

always @(posedge clkIN or negedge nResetIN) begin
	if (~nResetIN) begin
		counterOUT <= 0;
		counterOverflowOUT <= 0;
	end
	else if (counterOUT == TOP - 1) begin
		counterOUT <= 0;
		counterOverflowOUT <= 1;
	end
	else begin
		counterOUT <= counterOUT + 1;
		counterOverflowOUT <= 0;
	end
end
	 
endmodule
