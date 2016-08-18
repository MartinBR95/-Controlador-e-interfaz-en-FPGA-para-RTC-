module TOP(R,G,B,L,clk,reset,hsinc,vsinc,ENclock);

input wire R,G,B,reset,clk;
output wire [2:0]L;
output wire hsinc,vsinc,ENclock;

wire [9:0]X,Y;

vgasync Sincronizacion (clk,reset,hsinc,vsinc,ENclock,X,Y);

Objetos_Top objets (L,X,Y,R,G,B);

endmodule 