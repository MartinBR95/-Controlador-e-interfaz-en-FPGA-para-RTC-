module TOP(R,G,B,L,clk,reset,hsinc,vsinc,ENclock);

input wire R,G,B,reset,clk;
output wire [2:0]L;
output wire hsinc,vsinc,ENclock;

wire [9:0] X;
wire [9:0] Y;

vgasync Sincronizacion (.clk(clk),.rst(reset),.hsync(hsinc),.vsync(vsinc),.ENclock(ENclock),.px_X(X),.px_Y(Y));

Objetos_Top objets (.L(L),.X(X),.Y(Y),.R(R),.G(G),.B(B));

endmodule 