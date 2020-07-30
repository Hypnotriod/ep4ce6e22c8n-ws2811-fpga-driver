
/*
*  Author: Ilya Pikin
*/

module Counter
# (
	parameter TOP = 2
)
(
	input clkIN,
	input nResetIN,
	output [$clog2(TOP) - 1:0] counterOUT,
	output counterOverflowOUT
);

reg [$clog2(TOP - 1):0] counter;
reg counterOverflow;

initial begin
	counter = 0;
end

assign counterOUT = counter;
assign counterOverflowOUT = counterOverflow;

always @(posedge clkIN or negedge nResetIN) begin
	if (~nResetIN) begin
		counter <= 0;
		counterOverflow <= 0;
	end
	else if (counter == TOP - 1) begin
		counter <= 0;
		counterOverflow <= 1;
	end
	else begin
		counter <= counter + 1;
		counterOverflow <= 0;
	end
end
	 
endmodule
