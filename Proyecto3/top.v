`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    05:59:27 10/21/2016
// Design Name:
// Module Name:    top
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
module top(
  input clk, reset, IRQ,
  output wire AD,RD,WR,CS,HS,VS,
  inout [7:0] bus
  //output [11:0] RGB
  );

//Definición de identificadores de puertos, debe coincidir con los valores en el código de ensamblador
  parameter RTC_Dir =              8'd12;
  parameter RTC_Status =            8'd1;
  parameter RTC_Data_in =          8'd15;
  parameter RTC_Data_out =          8'd2;
  parameter DirInicial =           5'd21;    //Este no es un numero de puerto como tal, pero los puertos siguientes dependen de este parametro
  parameter VGA_seg =       (DirInicial);
  parameter VGA_min =     (DirInicial+1);
  parameter VGA_hor =     (DirInicial+2);
  parameter VGA_dia =     (DirInicial+3);
  parameter VGA_mes =     (DirInicial+3);
  parameter VGA_anio =    (DirInicial+4);
  parameter VGA_tseg =    (DirInicial+5);
  parameter VGA_tmin =    (DirInicial+6);
  parameter VGA_thor =    (DirInicial+7);
  parameter VGA_Alarma =  (DirInicial+8);
  parameter VGA_Punt =    (DirInicial+9);
  parameter ps2_data =                 3;
  parameter ps2_status =              13;

  wire	[11:0]	address;
  wire	[17:0]	instruction;
  wire			bram_enable;
  wire	[7:0]		port_id;
  wire	[7:0]		out_port;
  reg	[7:0]		in_port;
  wire			write_strobe;
  wire			k_write_strobe;
  wire			read_strobe;
  reg			interrupt;            //See note above
  wire			interrupt_ack;
  wire			kcpsm6_sleep;         //See note above
  wire			kcpsm6_reset;         //See note above

  wire			rdl;

  wire			int_request;

  kcpsm6 #(
  .interrupt_vector	(12'h3FF),
  .scratch_pad_memory_size(64),
  .hwbuild		(8'h00))
  processor (
  .address 		(address),
  .instruction 	(instruction),
  .bram_enable 	(bram_enable),
  .port_id 		(port_id),
  .write_strobe 	(write_strobe),
  .k_write_strobe 	(k_write_strobe),
  .out_port 		(out_port),
  .read_strobe 	(read_strobe),
  .in_port 		(in_port),
  .interrupt 		(interrupt),
  .interrupt_ack 	(interrupt_ack),
  .reset 		(kcpsm6_reset),
  .sleep		(kcpsm6_sleep),
  .clk 			(clk));

  hexrom progra(    		       	//Name to match your PSM file
  .rdl 			(rdl),
  .enable 		(bram_enable),
  .address 		(address),
  .instruction 	(instruction),
  .clk 			(clk));

  /*
   verilogPblzeRom  #(
  .C_FAMILY		   ("7S"),   	//Family 'S6' or 'V6'
  .C_RAM_SIZE_KWORDS	(1),  	//Program size '1', '2' or '4'
  .C_JTAG_LOADER_ENABLE	(0))
  program_rom (    				//Name to match your PSM file
  .rdl 			(kcpsm6_reset),
  .enable 		(bram_enable),
  .address 		(address),
  .instruction 	(instruction),
  .clk 			(clk));
  */

  assign kcpsm6_sleep = 1'b0;
  assign kcpsm6_reset = reset | rdl;

//DEFINIR HABILITADORES DE PUERTOS Y UTILIZAR EL CASE PARA DECODIFICARLOS
//Señales para habilitar/deshabilitar puertos de escritura en el RTC
  reg EN_RTC_Di, EN_RTC_Dir, EN_RTC_Stat;
//Señales para seleccionar entrada de datos desde el RTC
  reg [1:0] SEL_RTC;
  wire [7:0] out_rtc;

  always @(*) begin

    EN_RTC_Di = 1'b0;
    EN_RTC_Dir = 1'b0;
    EN_RTC_Stat = 1'b0;

    if(write_strobe) begin
      case(port_id)
      //Escrituras en puertos de RTC
        RTC_Data_in:
          EN_RTC_Di = 1'b1;
        RTC_Dir:
          EN_RTC_Dir = 1'b1;
        RTC_Status:
          EN_RTC_Stat = 1'b1;

/*      //Escrituras en puertos de VGA
      VGA_seg:
      VGA_min:
      VGA_hor:
      VGA_dia:
      VGA_mes:
      VGA_anio:
      VGA_tseg:
      VGA_tmin:
      VGA_thor:
      VGA_Alarma:
      VGA_Punt:
  */
      endcase
    end
  end

  always @ (posedge clk)
  begin

      case (port_id[1:0])

        //En estos dos primeros casos se seleccionan datos provenientes del puerto RTC
        //SEL_RTC es una señal que el puerto RTC utiliza para seleccionar sus datos de salida
        RTC_Status:begin
          in_port <= out_rtc;
          SEL_RTC <= 2'b01;
        end
        RTC_Data_out:begin
          in_port <= out_rtc;
          SEL_RTC <= 2'b10;
        end

        default : in_port <= 8'bXXXXXXXX ;

      endcase

  end


  RTCport RTC (
    //Puertos internos
    .clk(clk),.rst(reset),
    .WR_Di(EN_RTC_Di),.WR_Dir(EN_RTC_Dir),.WR_Stat(EN_RTC_Stat),
    .SEL(SEL_RTC),
    .data_in(out_port),.data_out(out_rtc),
    //Salidas al dispositivo externo RTC
    .IRQ(~IRQ),//La señal IRQ proveniente del RTC viene con lógica negativa, acá se utiliza su valor negado para trabajarlo en positiva
    .AD(AD),.CS(CS),.RD(RD),.WR(WR),
    .bus(bus)
    );

endmodule
