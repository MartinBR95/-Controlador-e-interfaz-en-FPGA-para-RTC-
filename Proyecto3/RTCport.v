
module RTCport(
  //Entradas y salidas conectadas al picoblaze y sincronía
  input clk, rst, Limpiar, WR_Di, WR_Dir, WR_Stat,
  input [1:0] SEL,
  input [7:0] data_in,
  output reg [7:0] data_out,
  //Entradas y salidas conectadas al RTC
  input IRQ,
  output AD,CS,RD,WR,
  inout [7:0] bus
  );

  reg [7:0] Direccion, D_i, D_o, Status, Status2;
  wire Fetch, Send, Address, FRW;

  always @(posedge clk) begin

    Status2[1] <= IRQ;

    if(rst)begin
      Status <= 8'h00;
      Status2<= 8'h00;
    end

    if (WR_Di) D_i <= data_in;
    if (WR_Dir) Direccion <= data_in;
    if (WR_Stat) Status <= data_in;

    if (Fetch) D_o <= bus;
    if (FRW) Status2[0] <= 1;
    if (Limpiar) begin
      Status2[0] <= 0;
    end

  end

  always @(*) begin

    data_out = Status;
    if (SEL[0]) data_out = Status2;
    if (SEL[1]) data_out = D_o;

  end

  transfer control(Status[1],~Status[0],clk,rst,AD,CS,RD,WR,FRW, Address, Send, Fetch);

  assign bus = (Address) ? Direccion : (Send) ? D_i : 8'bz;


endmodule
