module VGATop_2(
	input  [7:0]Puntero,
	input  CLK,RST,    		  //Senal de reloj 
   output [11:0] COLOR_OUT,  //bits de color hacia la VGA
   output HS,					  //Sincronizacion horizontal
   output VS,					  //Sincronizacion vertical
	input  [7:0]DIA_T,         //Senal de dia de la RTC
	input  ALARMA,             //Senal de alarma
	wire [7:0]MES_T,          //Senal de mes de la RTC
	input wire [7:0]ANO_T,          //Senal de ano de la RTC
	input wire [7:0]HORA_T,         //Senal de horas de la RTC
	input wire [7:0]MINUTO_T,       //Senal de minutos de la RTC 
	input wire [7:0]SEGUNDO_T,      //Senal de segundos de la RTC
	input wire [7:0]HORAT_T,        //Senal de horas de temporizador de la RTC
	input wire [7:0]MINUTOT_T,      //Senal de minutos de temporizador de la RTC
	input wire [7:0]SEGUNDOT_T 	  //Senal de segundos de temporizador de la RTC
    );

wire [4:0] Selector; 
wire [11:0] COLOR_OUT2;

ModuloVGA VGA
	(
   CLK,RST,    		  //Senal de reloj 
   COLOR_OUT2,  //bits de color hacia la VGA
   HS,					  //Sincronizacion horizontal
   VS,					  //Sincronizacion vertical
	DIA_T,         //Senal de dia de la RTC
	ALARMA,             //Senal de alarma
	MES_T,          //Senal de mes de la RTC
	ANO_T,          //Senal de ano de la RTC
	HORA_T,         //Senal de horas de la RTC
	MINUTO_T,       //Senal de minutos de la RTC 
	SEGUNDO_T,      //Senal de segundos de la RTC
	HORAT_T,        //Senal de horas de temporizador de la RTC
	MINUTOT_T,      //Senal de minutos de temporizador de la RTC
	SEGUNDOT_T, 	  //Senal de segundos de temporizador de la RTC
	Selector
	);
	
	reg [11:0]AUX = 12'h000; 
	
	always @(*)
	begin 
		case(Puntero)
			8'h24 : begin if(((Selector == 8'h3)||(Selector == 8'h2))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF;	//dia
							  else AUX = COLOR_OUT2; end
			
			8'h25 : begin if(((Selector == 8'h5)||(Selector == 8'h4))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF;	//mes
							  else AUX = COLOR_OUT2; end 
			
			8'h26 : begin if(((Selector == 8'h7)||(Selector == 8'h6))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF;	//ano
							  else AUX = COLOR_OUT2; end
							  
			8'h23 : begin if(((Selector == 8'h9)||(Selector == 8'h8))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF;	//hora
							  else AUX = COLOR_OUT2; end
							  
			8'h22 : begin if(((Selector == 8'hB)||(Selector == 8'hA))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF;	//min
							  else AUX = COLOR_OUT2; end
							  
			8'h21 : begin if(((Selector == 8'hD)||(Selector == 8'hC))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF;	//seg
							  else AUX = COLOR_OUT2; end
							  
			8'h43 : begin if(((Selector == 8'hF)||(Selector == 8'hE))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF;	//horat
							  else AUX = COLOR_OUT2; end
							  
			8'h42 : begin if(((Selector == 8'h11)||(Selector == 8'h10))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF; //mint
							  else AUX = COLOR_OUT2; end							  
							  
			8'h41 : begin if(((Selector == 8'h12)||(Selector == 8'h13))&& COLOR_OUT2 == 12'h000) AUX = 12'hFFF; //Segt
							  else AUX = COLOR_OUT2; end	
							  
		default AUX = COLOR_OUT2;
		endcase 
	end 
	
	assign COLOR_OUT = AUX;
endmodule    