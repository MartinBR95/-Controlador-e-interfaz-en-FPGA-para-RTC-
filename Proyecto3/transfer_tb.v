`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    03:57:31 09/14/2016
// Design Name:    Testbench
// Module Name:    transfer_tb
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
module transfer_tb;
	reg clk, reset, read, access;

	wire AD, CS, RD, WR, FRW, AValid, WValid, RValid;

	always begin
		clk <= ~clk;
		#5;
	end

	initial begin
		clk <= 0;
		reset <= 1;
		#50;
		reset <= 0;
		read <= 1;
		access <= 1;
		#400;
		access <= 0;
		#10;
		read <= 0;
		access <= 1;
		#1000;
		$stop;
	end

	transfer rtc(access, read, clk, reset, AD, CS, RD, WR, FRW, AValid, WValid, RValid);

endmodule
