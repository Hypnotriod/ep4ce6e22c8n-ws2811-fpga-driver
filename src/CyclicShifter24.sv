
/*
*  Author: Ilya Pikin
*/

module CyclicShifter24
(
	input	[23:0]dataIN,
	input [4:0] shiftIN,
	output [23:0] dataOUT
);

always @(*) begin
	case (shiftIN)
		5'h01 : dataOUT[23:0] = {dataIN[22:0], dataIN[23:23]};
		5'h02 : dataOUT[23:0] = {dataIN[21:0], dataIN[23:22]};
		5'h03 : dataOUT[23:0] = {dataIN[20:0], dataIN[23:21]};
		5'h04 : dataOUT[23:0] = {dataIN[19:0], dataIN[23:20]};
		5'h05 : dataOUT[23:0] = {dataIN[18:0], dataIN[23:19]};
		5'h06 : dataOUT[23:0] = {dataIN[17:0], dataIN[23:18]};
		5'h07 : dataOUT[23:0] = {dataIN[16:0], dataIN[23:17]};
		5'h08 : dataOUT[23:0] = {dataIN[15:0], dataIN[23:16]};
		5'h09 : dataOUT[23:0] = {dataIN[14:0], dataIN[23:15]};
		5'h0a : dataOUT[23:0] = {dataIN[13:0], dataIN[23:14]};
		5'h0b : dataOUT[23:0] = {dataIN[12:0], dataIN[23:13]};
		5'h0c : dataOUT[23:0] = {dataIN[11:0], dataIN[23:12]};
		5'h0d : dataOUT[23:0] = {dataIN[10:0], dataIN[23:11]};
		5'h0e : dataOUT[23:0] = {dataIN[9:0], dataIN[23:10]};
		5'h0f : dataOUT[23:0] = {dataIN[8:0], dataIN[23:9]};
		5'h10 : dataOUT[23:0] = {dataIN[7:0], dataIN[23:8]};
		5'h11 : dataOUT[23:0] = {dataIN[6:0], dataIN[23:7]};
		5'h12 : dataOUT[23:0] = {dataIN[5:0], dataIN[23:6]};
		5'h13 : dataOUT[23:0] = {dataIN[4:0], dataIN[23:5]};
		5'h14 : dataOUT[23:0] = {dataIN[3:0], dataIN[23:4]};
		5'h15 : dataOUT[23:0] = {dataIN[2:0], dataIN[23:3]};
		5'h16 : dataOUT[23:0] = {dataIN[1:0], dataIN[23:2]};
		5'h17 : dataOUT[23:0] = {dataIN[0:0], dataIN[23:1]};
		default : dataOUT[23:0] = dataIN[23:0];
	endcase
end

endmodule
