
/*
* ColorSwap.sv
*
*  Author: Ilya Pikin
*/

module ColorSwap
(
	input [23:0]dataIN,
	input [2:0] swapIN,
	output [23:0] dataOUT
);

always @(*) begin
	case (swapIN)
		3'd1 : dataOUT[23:0] = {dataIN[23:16], dataIN[7:0],   dataIN[15:8]};
		3'd2 : dataOUT[23:0] = {dataIN[7:0],   dataIN[15:8],  dataIN[23:16]};
		3'd3 : dataOUT[23:0] = {dataIN[7:0],   dataIN[23:16], dataIN[15:8]};
		3'd4 : dataOUT[23:0] = {dataIN[15:8],  dataIN[7:0],   dataIN[23:16]};
		3'd5 : dataOUT[23:0] = {dataIN[15:8],  dataIN[23:16], dataIN[7:0]};
		default : dataOUT[23:0] = {dataIN[23:16], dataIN[15:8],  dataIN[7:0]};
	endcase
end

endmodule
