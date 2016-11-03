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
  input clk,reset,IRQ,
  output wire AD,RD,WR,CS,HS,VS,
  inout [7:0] bus,
  output reg [7:0] Segundos,
  //Pruebas
  output wire	[7:0] address2,
  output wire [11:0] RGB
  //,output wire	[7:0] instruction2
  );

  //assign instruction2[7:0] =instruction[7:0];
//Definición de identificadores de puertos, debe coincidir con los valores en el código de ensamblador
  parameter RTC_Dir =              8'd12;
  parameter RTC_Ctrl_in =          8'd13;
  parameter RTC_Ctrl_out =          8'd1;
  parameter RTC_Data_in =          8'd15;
  parameter RTC_Data_out =          8'd2;
  parameter DirInicial =            5'd2;    //Este no es un numero de puerto como tal, pero los puertos siguientes dependen de este parametro
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
  parameter VGA_Punt =                14;
  parameter ps2_data =                 3;
  parameter ps2_status =              13;

  wire	[11:0]	address;
  wire	[17:0]	instruction;
  wire			bram_enable;
  wire	[7:0]	port_id;
  wire	[7:0]	out_port;
  reg	[7:0]	in_port;
  wire			write_strobe;
  wire			k_write_strobe;
  wire			read_strobe;
  reg			interrupt;            //See note above
  wire			interrupt_ack;
  wire			kcpsm6_sleep;         //See note above
  wire			kcpsm6_reset;         //See note above
  wire			rdl;
  wire			int_request;
  reg  [7:0] teclado = 8'h00;
  wire [7:0] rtc_port;

  //Pruebas
  assign address2[7:0] =address[7:0];

//////////////////////////////////////////Procesador/////////////////////////////////
  kcpsm6
  #(
  .interrupt_vector	(12'h3FF),
  .scratch_pad_memory_size(64),
  .hwbuild		(8'h00)
  )
  processor
  (
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
  .reset 			(kcpsm6_reset),
  .sleep			(kcpsm6_sleep),
  .clk 			(clk)
  );

  assign kcpsm6_sleep = 1'b0;
  assign kcpsm6_reset = reset | rdl;

//////////////////////////////////////////   RTC   //////////////////////////////////////////

      RTCport #(
			.RTC_Dir (RTC_Dir),
			.RTC_Ctrl_in (RTC_Ctrl_in),
			.RTC_Ctrl_out (RTC_Ctrl_out),
			.RTC_Data_in (RTC_Data_in),
			.RTC_Data_out (RTC_Data_out)
			)

		RTC(
		    //Puertos internos
		    .clk(clk),.rst(reset),
		    .data_in(out_port),.data_out(rtc_port),.port_id (port_id),
		    .read_strobe(read_strobe),.write_strobe(write_strobe),
		    //Salidas al dispositivo externo RTC
		    .IRQ(IRQ),//La señal IRQ proveniente del RTC viene con lógica negativa, acá se utiliza su valor negado para trabajarlo en positiva
		    .AD(AD),.CS(CS),.RD(RD),.WR(WR),
		    .bus(bus)
			);

//////////////////////////////////////////   VGA y TECLADO  //////////////////////////////////////////

    Conexion_CONTROL_VGA_TECLADO Perifericos
    (
        //input wire[7:0]TecladoREG,
    		//input wire[7:0]TecladoREG_ANTERIOR,

    		/////////////////////////////
    		//ENTRADA
    		.RST(reset),
    		.CLK(clk),
    		.ALARMA(~IRQ),

    		//SE�ALES PROBENIENTES DEL CONTROL
    		.WRITE_STROBE(write_strobe),            //Se�al de actualizar registro
    		.POR_ID(port_id),              //Donde escribo
    		.OUT_PORT(out_port),            //Datos de entrada

    		/////////////////////////////
    		//SALIDAS
    		.RGB(RGB),
    		.VS(VS),
    		.HS(HS),

        .ps2c(),
        .DATA_IN(),
        .DATA_OUT_TEC(),
        .SOLICITUD(),
        .TecladoREG_ANTERIOR(),
        .TecladoREG()

    		//SIMULACION
/*    		.ADDRV(),
    		.ADDRH(),
    		.Video_ON() */
    );

//////////////////////////////////////////ROM////////////////////////////////////////
  hexrom progra(
  .rdl 			(rdl),
  .enable 		(bram_enable),
  .address 		(address),
  .instruction 	(instruction),
  .clk 			(clk));

//////////////////////////////////////////Control Entradas Picoblaze////////////////////////////////////

	always @(*)begin
		case (port_id)
    	ps2_data:		in_port <= teclado;
    	RTC_Dir:		in_port<= rtc_port;
    	RTC_Ctrl_out:	in_port<= rtc_port;
    	//RTC_Ctrl_out:	in_port<= {5'b00000,1'b1,FRW_P};
    	RTC_Data_out:	in_port<= rtc_port;
    	default : in_port <= 8'b00000000 ;
    endcase

	end

  always @ (posedge clk)
  begin
    if(reset) Segundos <= 8'h66;
  	if(port_id==VGA_seg && write_strobe)Segundos<=out_port;
    else Segundos <= Segundos;
  end


endmodule
