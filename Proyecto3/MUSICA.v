`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module MUSICA(
	input clk,
	output reg speaker
);

reg [29:0] tone;
always @(posedge clk) tone <= tone+30'd1;

wire [7:0] fullnote;
music_ROM get_fullnote(.clk(clk), .address(tone[29:22]), .note(fullnote));

wire [2:0] octave;
wire [3:0] note;
divide_by12 get_octave_and_note(.numerator(fullnote[5:0]), .quotient(octave), .remainder(note));

reg [8:0] clkdivider;
always @*
case(note)
	 0: clkdivider = 9'd511;//A
	 1: clkdivider = 9'd482;// A#/Bb
	 2: clkdivider = 9'd455;//B
	 3: clkdivider = 9'd430;//C
	 4: clkdivider = 9'd405;// C#/Db
	 5: clkdivider = 9'd383;//D
	 6: clkdivider = 9'd361;// D#/Eb
	 7: clkdivider = 9'd341;//E
	 8: clkdivider = 9'd322;//F
	 9: clkdivider = 9'd303;// F#/Gb
	10: clkdivider = 9'd286;//G
	11: clkdivider = 9'd270;// G#/Ab
	default: clkdivider = 9'd0;
endcase

reg [8:0] counter_note;
reg [7:0] counter_octave;
always @(posedge clk) counter_note <= counter_note==0 ? clkdivider : counter_note-9'd1;
always @(posedge clk) if(counter_note==0) counter_octave <= counter_octave==0 ? 8'd255 >> octave : counter_octave-8'd1;
always @(posedge clk) if(counter_note==0 && counter_octave==0 && fullnote!=0 && tone[21:18]!=0) speaker <= ~speaker;
endmodule


/////////////////////////////////////////////////////
module divide_by12(
	input [5:0] numerator,  // value to be divided by 12
	output reg [2:0] quotient, 
	output [3:0] remainder
);

reg [1:0] remainder3to2;
always @(numerator[5:2])
case(numerator[5:2])
	 0: begin quotient=0; remainder3to2=0; end
	 1: begin quotient=0; remainder3to2=1; end
	 2: begin quotient=0; remainder3to2=2; end
	 3: begin quotient=1; remainder3to2=0; end
	 4: begin quotient=1; remainder3to2=1; end
	 5: begin quotient=1; remainder3to2=2; end
	 6: begin quotient=2; remainder3to2=0; end
	 7: begin quotient=2; remainder3to2=1; end
	 8: begin quotient=2; remainder3to2=2; end
	 9: begin quotient=3; remainder3to2=0; end
	10: begin quotient=3; remainder3to2=1; end
	11: begin quotient=3; remainder3to2=2; end
	12: begin quotient=4; remainder3to2=0; end
	13: begin quotient=4; remainder3to2=1; end
	14: begin quotient=4; remainder3to2=2; end
	15: begin quotient=5; remainder3to2=0; end
endcase

assign remainder[1:0] = numerator[1:0];  // the first 2 bits are copied through
assign remainder[3:2] = remainder3to2;  // and the last 2 bits come from the case statement
endmodule
/////////////////////////////////////////////////////


module music_ROM(
	input clk,
	input [7:0] address,
	output reg [7:0] note
);



localparam DO  = 8'd18;
localparam RE  = 8'd20;
localparam MI  = 8'd22;
localparam FA  = 8'd23;
localparam SOL = 8'd25;
localparam LA  = 8'd27;
localparam SI  = 8'd29;

localparam DO_S  = 8'h30;
localparam RE_S  = 8'h32;
localparam MI_S  = 8'h34;
localparam FA_S  = 8'h35;
localparam SOL_S = 8'h37;
localparam LA_S  = 8'h39;
localparam SI_S  = 8'h41;



always @(posedge clk)
case(address)
	 
	 //////////////////////////
	 0: note<= FA;
	 3: note<= FA;	
	 6: note<= 00;	
	 9: note<= SOL;
	 12: note<= LA;	
	 15: note<= LA;
	 18: note<= 8'd00;
	 21: note<= MI;	 
	 
	 24: note<= FA;
	 27: note<= SOL;	
	 30: note<= LA;	
	 33: note<= RE;
	 36: note<= DO;	
	 39: note<= FA;
	 42: note<= LA;
	 45: note<= DO;	
	 
	 48: note<= 00;
 	 51: note<= 00;
	 54: note<= DO;
	 57: note<= DO;
	 60: note<= DO;
	 63: note<= DO;
	 66: note<= DO; 89: note<= SI; 90: note<= LA;
	 69: note<= FA; 93: note<= RE_S; 94: note<= FA;
	 
	 72: note<= FA;
	 75: note<= FA;
	 78: note<= FA;
	 81: note<= FA;
	 84: note<= 00;
	 87: note<= 00;
	 90: note<= 00;
	 93: note<= MI;
 
 ///////////////////
	 96: note<= FA;
	 99: note<= FA;	
	 102: note<= 00;	
	 105: note<= SOL;
	 108: note<= LA;	
	 111: note<= LA;
	 114: note<= 8'd00;
	 117: note<= MI;	 
	
 	 120: note<= FA;
	 123: note<= SOL;	
	 126: note<= LA;	
	 129: note<= RE;
	 132: note<= DO;	
	 135: note<= LA;
	 138: note<= DO;
	 141: note<= SI_S;	 
	 
	 
	 144: note<= SI;
	 147: note<= SI;	
	 150: note<= SI;	
	 153: note<= SI;
	 156: note<= SI;	
	 159: note<= SI;	 
	 162: note<= SI;
	 165: note<= SI;
	
	 168: note<= SI;
	 171: note<= SI;
	 174: note<= SI;	
	 177: note<= SI;	
	 200: note<= SI;
	 203: note<= 00;	
	 206: note<= 00;
	 209: note<= 00;
	 212: note<= MI;

	 215: note<= FA;
	 218: note<= FA;	
	 221: note<= 00;	
	 224: note<= SOL;
	 227: note<= LA;	

	default: note <= note;
endcase
endmodule ///////////////////////////////////////////////////