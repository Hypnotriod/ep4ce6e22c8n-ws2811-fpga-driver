
/*
*  Author: Ilya Pikin
*/

module ColorSwap
(
	input	[23:0]dataIN,
	input [2:0] swapIN,
	output [23:0] dataOUT
);

always @(*) begin
	case (swapIN)
		2'b001 : dataOUT[23:0] = {dataIN[23:16], dataIN[7:0],   dataIN[15:8]};
		2'b010 : dataOUT[23:0] = {dataIN[7:0],   dataIN[15:8],  dataIN[23:16]};
		2'b011 : dataOUT[23:0] = {dataIN[7:0],   dataIN[23:16], dataIN[15:8]};
		2'b100 : dataOUT[23:0] = {dataIN[15:8],  dataIN[7:0],   dataIN[23:16]};
		2'b101 : dataOUT[23:0] = {dataIN[15:8],  dataIN[23:16], dataIN[7:0]};
		default : dataOUT[23:0] = {dataIN[23:16], dataIN[15:8],  dataIN[7:0]};
	endcase
end

endmodule
