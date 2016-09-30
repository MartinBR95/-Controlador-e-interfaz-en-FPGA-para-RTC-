`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:59:10 09/29/2016 
// Design Name: 
// Module Name:    Debouncers 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Debouncers(IN,CLK,RST,OUT_reg);

input IN,CLK,RST;
reg [7:0] IN_reg_in;
output reg OUT_reg;
reg [7:0] IN_reg_ant;
always@(posedge CLK, posedge RST)
begin
	if(RST)
	begin
		IN_reg_in<=8'h00;
		OUT_reg<=1'b0;
		IN_reg_ant<=8'h00;
	end
	else
	begin
		IN_reg_in<={IN_reg_in[6:0],IN};
		if((IN_reg_in==8'h00)||(IN_reg_in==8'hff))
		begin
			IN_reg_ant<=IN_reg_in;
		end
		else
		begin
			IN_reg_ant<=IN_reg_ant;
		end
		case({IN_reg_ant,IN_reg_in})
			16'h00ff:OUT_reg<=1'b1;
			16'hff00:OUT_reg<=1'b0;
			default
			begin
				OUT_reg<=OUT_reg;
			end
		endcase
	end
end
   
endmodule
