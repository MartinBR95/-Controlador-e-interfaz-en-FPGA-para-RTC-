
module hexrom(address, instruction, enable, rdl, clk);

input         clk;
input  [11:0] address;
input         enable;
output reg [17:0] instruction;
output        rdl;

assign rdl = 0;

parameter ROM_WIDTH = 18;
parameter ROM_ADDR_BITS = 12;

reg [ROM_WIDTH-1:0] progra [(2**ROM_ADDR_BITS)-1:0];

initial
   $readmemh("program_rom.hex", progra, 12'h000, 12'hfff);

always @(posedge clk)
   if (enable)
      instruction = progra[address];

endmodule
