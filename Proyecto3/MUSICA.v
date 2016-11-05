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

always @(posedge clk)
case(address)
	  0: note<= 8'd00;
	  1: note<= 8'd00;
	  2: note<= 8'd00;
	  3: note<= 8'd00;
	  4: note<= 8'd00;
	  5: note<= 8'd00;
	  6: note<= 8'd00;
	  7: note<= 8'd00;
	  8: note<= 8'd00;
	  9: note<= 8'd00;
	 10: note<= 8'd00;
	 11: note<= 8'd00;
	 12: note<= 8'd00;
	 13: note<= 8'd33;
	 14: note<= 8'd34;
	 15: note<= 8'd33;
	 
	 16: note<= 8'd35;
	 17: note<= 8'd35;
	 18: note<= 8'd35;
	 19: note<= 8'd35;
	 20: note<= 8'd35;
	 21: note<= 8'd35;
	 22: note<= 8'd35;
	 23: note<= 8'd35;
	 24: note<= 8'd35;
	 25: note<= 8'd35;
	 26: note<= 8'd35;
	 27: note<= 8'd35;
	 28: note<= 8'd35;
	 29: note<= 8'd35;
	 30: note<= 8'd35;
	 31: note<= 8'd35;
	 
	 32: note<= 8'd35;
	 33: note<= 8'd35;
	 34: note<= 8'd35;
	 35: note<= 8'd35;
	 36: note<= 8'd35;
	 37: note<= 8'd35;
	 38: note<= 8'd35;
	 39: note<= 8'd35;
	 40: note<= 8'd35;
	 41: note<= 8'd35;
	 42: note<= 8'd33;
	 43: note<= 8'd33;
	 44: note<= 8'd34;
	 45: note<= 8'd34;
	 46: note<= 8'd34;
	 47: note<= 8'd34;
	 
	 48: note<= 8'd35;
	 49: note<= 8'd35;
	 50: note<= 8'd35;
	 51: note<= 8'd35;
	 52: note<= 8'd35;
	 53: note<= 8'd35;
	 54: note<= 8'd35;
	 55: note<= 8'd35;
	 56: note<= 8'd35;
	 57: note<= 8'd35;
	 58: note<= 8'd35;
	 59: note<= 8'd35;
	 60: note<= 8'd35;
	 61: note<= 8'd35;
	 62: note<= 8'd35;
	 63: note<= 8'd35; 

	 64: note<= 8'd35;
	 65: note<= 8'd35;	 
	 66: note<= 8'd35;
	 67: note<= 8'd35;
	 68: note<= 8'd35;
	 69: note<= 8'd35;
	 70: note<= 8'd35;
	 71: note<= 8'd35;
	 72: note<= 8'd00;
	 73: note<= 8'd00;
	 74: note<= 8'd00;
	 75: note<= 8'd00;
	 76: note<= 8'd00;
	 77: note<= 8'd00;
	 78: note<= 8'd34;
	 79: note<= 8'd34;
	 
	 80: note<= 8'd36;
	 81: note<= 8'd36;
	 82: note<= 8'd36;
	 83: note<= 8'd36;
	 84: note<= 8'd00;
	 85: note<= 8'd00;
	 86: note<= 8'd00;
	 87: note<= 8'd25;
	 88: note<= 8'd25;
	 89: note<= 8'd26;
	 90: note<= 8'd26;
	 91: note<= 8'd26;
	 92: note<= 8'd26;
	 93: note<= 8'd00;
	 94: note<= 8'd00;
	 95: note<= 8'd33;
	
	 96: note<= 8'd34;
	 97: note<= 8'd34;
	 98: note<= 8'd25;
	 99: note<= 8'd25;
	100: note<= 8'd26;
	101: note<= 8'd26;
	102: note<= 8'd00;
	103: note<= 8'd00;
	104: note<= 8'd35;
	105: note<= 8'd37;
	106: note<= 8'd37;
	107: note<= 8'd37;
	108: note<= 8'd37;
	109: note<= 8'd00;
	110: note<= 8'd00;
	111: note<= 8'd34;
	
	112: note<= 8'd34;
	113: note<= 8'd34;
	114: note<= 8'd34;
	115: note<= 8'd35;
	116: note<= 8'd37;
	117: note<= 8'd37;
	118: note<= 8'd37;
	119: note<= 8'd27;
	120: note<= 8'd17;
	121: note<= 8'd37;
	122: note<= 8'd29;
	123: note<= 8'd29;
	124: note<= 8'd29;
	125: note<= 8'd34;
	126: note<= 8'd34;
	127: note<= 8'd34;
	
	128: note<= 8'd22;
	129: note<= 8'd22;
	130: note<= 8'd22;
	131: note<= 8'd22;
	132: note<= 8'd22;
	133: note<= 8'd22;
	134: note<= 8'd22;
	135: note<= 8'd22;
	136: note<= 8'd22;
	137: note<= 8'd22;
	138: note<= 8'd22;
	139: note<= 8'd22;
	140: note<= 8'd22;
	141: note<= 8'd22;
	142: note<= 8'd22;
	143: note<= 8'd22;
	
	144: note<= 8'd22;
	145: note<= 8'd22;
	146: note<= 8'd22;
	147: note<= 8'd22;
	148: note<= 8'd22;
	149: note<= 8'd22;
	150: note<= 8'd22;
	151: note<= 8'd22;
	152: note<= 8'd22;
	153: note<= 8'd22;
	154: note<= 8'd22;
	155: note<= 8'd22;
	156: note<= 8'd00;
	157: note<= 8'd00;
	158: note<= 8'd00;
	159: note<= 8'd32;
	
	160: note<= 8'd34;
	161: note<= 8'd34;
	162: note<= 8'd34;
	163: note<= 8'd34;
	164: note<= 8'd00;
	165: note<= 8'd00;
	166: note<= 8'd00;
	167: note<= 8'd00;
	168: note<= 8'd35;
	169: note<= 8'd37;
	170: note<= 8'd37;
	171: note<= 8'd37;
	172: note<= 8'd37;
	173: note<= 8'd00;
	174: note<= 8'd00;
	175: note<= 8'd34;

	176: note<= 8'd34;
	177: note<= 8'd34;
	178: note<= 8'd34;
	179: note<= 8'd35;
	180: note<= 8'd37;
	181: note<= 8'd37;
	182: note<= 8'd37;
	183: note<= 8'd18;
	184: note<= 8'd17;
	185: note<= 8'd17;
	186: note<= 8'd17;
	187: note<= 8'd35;
	188: note<= 8'd37;
	189: note<= 8'd37;
	190: note<= 8'd37;
	191: note<= 8'd17;

	192: note<= 8'd17;
	193: note<= 8'd17;
	194: note<= 8'd17;
	195: note<= 8'd17;
	196: note<= 8'd17;
	197: note<= 8'd17;
	198: note<= 8'd17;
	199: note<= 8'd17;
	200: note<= 8'd17;
	201: note<= 8'd17;
	202: note<= 8'd17;
	203: note<= 8'd17;
	204: note<= 8'd17;
	205: note<= 8'd17;
	206: note<= 8'd17;
	207: note<= 8'd17;
	
	208: note<= 8'd17;
	209: note<= 8'd17;
	210: note<= 8'd17;
	211: note<= 8'd17;
	212: note<= 8'd17;
	213: note<= 8'd17;
	214: note<= 8'd24;
	215: note<= 8'd24;
	216: note<= 8'd25;
	217: note<= 8'd25;
	218: note<= 8'd34;
	219: note<= 8'd34;
	220: note<= 8'd32;
	221: note<= 8'd32;
	222: note<= 8'd34;
	223: note<= 8'd34;
	
	224: note<= 8'd17;
	225: note<= 8'd17;
	226: note<= 8'd17;
	227: note<= 8'd17;
	228: note<= 8'd17;
	229: note<= 8'd17;
	230: note<= 8'd38;
	231: note<= 8'd38;
	232: note<= 8'd37;
	233: note<= 8'd37;
	234: note<= 8'd34;
	235: note<= 8'd34;
	236: note<= 8'd32;
	237: note<= 8'd32;
	238: note<= 8'd34;
	239: note<= 8'd34; 
	
	240: note<= 8'd34;
	241: note<= 8'd34;
	242: note<= 8'd34;
	243: note<= 8'd34;
	244: note<= 8'd34;
	245: note<= 8'd34;
	246: note<= 8'd34;
	247: note<= 8'd34;
	248: note<= 8'd00;
	249: note<= 8'd00;
	240: note<= 8'd00;
	251: note<= 8'd00;
	252: note<= 8'd00;
	253: note<= 8'd00;
	254: note<= 8'd00;
	255: note<= 8'd00; 
		
	default: note <= 8'd0;
endcase
endmodule ///////////////////////////////////////////////////