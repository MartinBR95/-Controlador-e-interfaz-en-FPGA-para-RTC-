
module RTCport(
  //Entradas y salidas conectadas al picoblaze y sincronía
  input clk, rst,
  input read_strobe,
  input write_strobe,
  input [7:0] port_id,
  input [7:0] data_in,
  output reg [7:0] data_out,
  //Entradas y salidas conectadas al RTC
  input IRQ,
  output AD,CS,RD,WR,
  inout [7:0] bus
  );

  parameter RTC_Dir = 8'd12;
  parameter RTC_Ctrl_in = 8'd13;
  parameter RTC_Ctrl_out = 8'd1;
  parameter RTC_Data_in = 8'd15;
  parameter RTC_Data_out = 8'd2;

  reg [7:0] Ctrl_rtc_in, Ctrl_rtc_out, Direccion, Dato_in, Dato_out;//registros de variables de control
  wire Fetch, Send, Address, FRW;
  reg read_strobe_ant, read_strobe_reg;

  always @(posedge clk) begin

      read_strobe_reg <= read_strobe;
      read_strobe_ant <= read_strobe_reg;

      if(rst) begin
        Ctrl_rtc_in <= 0; Direccion <= 0; Dato_in <= 0;
      end

      if(write_strobe)begin
        case(port_id)
          RTC_Dir: Direccion <= data_in;
          RTC_Data_in: Dato_in <= data_in;
          RTC_Ctrl_in: Ctrl_rtc_in <= data_in;
          default begin
            Dato_in <= Dato_in;
            Ctrl_rtc_in <= Ctrl_rtc_in;
            Direccion <= Direccion;
          end
        endcase
      end

end


  always @(posedge clk) begin
	  if(rst) begin
		  Ctrl_rtc_out <= 0; Dato_out <= 0;
    end
    else begin
      Ctrl_rtc_out[1] <= IRQ;
      if (read_strobe_ant && ~read_strobe_reg && (port_id == RTC_Ctrl_out)) Ctrl_rtc_out[0] <= 1'b0;
      else begin
        if (FRW) Ctrl_rtc_out[0] <= 1'b1;
        else Ctrl_rtc_out <= Ctrl_rtc_out;
        if(Fetch) begin
          Dato_out <= bus;
        end
        else Dato_out <= Dato_out;
      end
    end
  end

  always @ ( * ) begin
    case(port_id)
      RTC_Data_out: data_out <= Dato_out;
      RTC_Ctrl_out: data_out <= Ctrl_rtc_out;
      default data_out <= Dato_out;
    endcase
  end

  assign bus = (Address) ? Direccion : (Send) ? Dato_in : 8'bz;

  transfer control(Ctrl_rtc_in[1],~Ctrl_rtc_in[0],clk,rst,AD,CS,RD,WR,FRW,Address, Send, Fetch);




endmodule
