`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////
module TraductorPS2(DATA_IN,ps2c,Reloj,RST,DATA_OUT,S_DATA);


///////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////      FUNCIONAMIENTO DE MODULO        /////////////////////////////////////////
/* 
Este modulo se encarga de traducir la informacion enviada por el teclado al circuito para que este pueda entender
lo que el usuario desea ejecutar. Conta de 3 secciones:

1- Recepcion de datos
2- Almacenamiento de datos
3- Envio de datos
 
*/
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////Se declaran las conecciones del teclado, estas son dos de entrada y dos in/outs

input  Reloj,RST;              		//Reloj del circuito (100MHz)
input  ps2c;    				      	//Reloj del teclado 
input  DATA_IN;   			   		//Datos del teclado (son de tipo serial)
output reg [7:0]DATA_OUT;	         //Datos de salida 
output reg S_DATA;						//Indica se se puede o no leer el dato que se encuentra en los registros de salida 

//EL  teclado trabaja en base a los negedges del puerto CLK
reg ON = 1'h0; 			       //El protocolo posee un bit de inicio (Primer negedge del protocolo) y un bit de cierre (ultimo negedge del protocolo)
wire Paridad;  			 //Asi mismo el protocolo posee un bit de paridad (impar)
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////    RECEPCION DE DATO Y ATRIBUTOS      /////////////////////////////////////////
		
		
////////DETECTOR DE FLANCO DE BAJADA////////

reg [7:0]filter_reg;   //Filtro que se usa para evitar algun ruido en la señal
reg f_ps2c_reg;        //Señal previa a la salida del flanco de bajada 

wire[7:0] filter_next; 
wire f_ps2c_next;      

wire fall_edge;        //Señal indicadora de si se ha detectado un flanco de bajada

always @(posedge Reloj, posedge RST)
begin    
	if (RST) 
		begin 
		filter_reg  <= 0;
		f_ps2c_reg	<= 0;
		end 		
	else  
		begin
		filter_reg <= filter_next;
		f_ps2c_reg <= f_ps2c_next;
		end   
end         
	         
assign filter_next = {ps2c,filter_reg[7:1]};              //Se va modificado la señal del filtro
assign f_ps2c_next = (filter_reg == 8'b11111111) ? 1'b1 :
							(filter_reg == 8'b00000000) ? 1'b0 :
							f_ps2c_reg;
			  			
assign fall_edge = f_ps2c_reg && ~f_ps2c_next;            
            
/////////////////////////////////////

//Señales necesarias para recepcion de datos del teclado 
reg [1:0]state_reg, state_next;  //State es el estado en el que se encuentra la recepcion de datos 
reg [3:0]n_reg;
reg [3:0]n_next;
reg [10:0]b_reg, b_next;


localparam	idle = 2'b00;
localparam	dps  = 2'b01;
localparam	load = 2'b10;

always@ (posedge Reloj, posedge RST) //En esta seccion se van guardando los registros 
begin
	if (RST) //En caso de que se haga un reset, se devuelven las señales a sus valores iniciales 	
		begin
			state_reg <= idle;
			n_reg <= 0;
			b_reg <= 0;
		end
	else 
		begin
			state_reg <= state_next;  //Se guardan en los registros los datos modificados
			n_reg <= n_next;
			b_reg <= b_next;
		end
end

always @*    //En esta seccion se modifican las señales que no son constantes
begin
	 state_next = state_reg;
	 n_next = n_reg;
	 b_next = b_reg;
	 
	 case(state_reg)          //Se tiene tres estados durante la recepcion de datos
			idle :              //Estado inicial 
			if(fall_edge)
			begin 
				b_next = {DATA_IN, b_reg[10:1]};
				n_next = 4'b1001;
				state_next = dps;
			end
			
			dps  :              //Estado de guardado de datos
			if(fall_edge)
			begin 
				b_next = {DATA_IN, b_reg[10:1]};
				if(n_reg == 0) state_next = load;
				else 	n_next = n_reg - 1'b1;
			end
			
			load :              //Estado final, termino de recepcion 
			begin 
				state_next = idle;
			end
	endcase 
end 

wire [7:0]DATA_P;   

assign Paridad = b_reg[9];    //Se guarda la paridad 
assign DATA_P = b_reg[8:1];   //Se guarda en el registro DATA_P la recepcion de datos


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////    ALMACENAMIENTO DE DATO Y ATRIBUTOS      //////////////////////////////////////


//Sub seccion de almacenan los datos cuando estos ya se encuentran completamente cargados y se a comprobado la paridad, se guardan dos datos (dos ciclos de lectura)
//Para en uno almacenar el dato recibido y en el otro almacenar la señal "F0" indicando la necesidad de enviar el dato 

//////////////////////////////////////////////////////////
/////////////  Comprobacion de paridad  //////////////////

wire Paridad_OK; //Define si la paridad es correcta o no 

Paridad P_OK (Reloj, DATA_P, Paridad, Paridad_OK); //Comprobador de paridad
     
//////////////////////////////////////////////////////////
reg [7:0]DATA_REG = 8'h00;          	       //Se crea el registro de almacenamiento de ultimo dato
reg [7:0]DATA_REG_ANTERIOR = 8'h00; 			 //Se crea el registro de almacenamiento de ultimo dato 
reg [7:0]DATA_REG_ANTERIOR_ANTERIOR1 = 8'h00; //Se crea el registro de almacenamiento de ultimo dato 
reg [7:0]DATA_REG_ANTERIOR_ANTERIOR2 = 8'h00; //Se crea el registro de almacenamiento de ultimo dato 

always @(posedge Reloj)
begin 
	if(n_reg == 4'h0 && Paridad_OK == 1'b1)begin  					  //Si se ha terminado de cargar el dato y la paridad es correcta, se guarda el dato
		DATA_REG_ANTERIOR_ANTERIOR1 <= DATA_REG_ANTERIOR_ANTERIOR1;		
		DATA_REG_ANTERIOR <= DATA_REG_ANTERIOR; 	 					  //Se mantiene el dato
		DATA_REG <= DATA_P;            				  					  //Guarda dato nuevo 
		end 
	else 
		if (n_reg == 4'h9) begin                                   //Si se esta en la cuenta 9	
		DATA_REG_ANTERIOR_ANTERIOR2 <= DATA_REG_ANTERIOR_ANTERIOR1;//Se guarda los datos anteriores del registro de almacenamiento anterior 1
		DATA_REG_ANTERIOR_ANTERIOR1 <= DATA_REG_ANTERIOR_ANTERIOR1;//Se mantiene el dato
		DATA_REG_ANTERIOR <= DATA_REG_ANTERIOR; 	  	          	  //Se mantiene el dato 
		DATA_REG <= DATA_REG;            			  		           //Se mantiene el dato
		end      
		else 
			begin
			if (n_reg == 4'h8)                                            //Si se esta en la cuenta 8	
				begin 
				DATA_REG_ANTERIOR_ANTERIOR2 <= DATA_REG_ANTERIOR_ANTERIOR2;//Se mantiene el dato
				DATA_REG_ANTERIOR_ANTERIOR1 <= DATA_REG_ANTERIOR;			  //Se guarda los datos anteriores del registro de almacenamiento anterior 0
				DATA_REG_ANTERIOR <= DATA_REG_ANTERIOR; 						  //Se mantiene el dato
				DATA_REG <= DATA_REG; 						 						  //Se mantiene el dato
				end 
			else  
				begin 
				if (n_reg == 4'h7)                                             //Si se esta en la cuenta 7	
					begin 
					DATA_REG_ANTERIOR_ANTERIOR2 <= DATA_REG_ANTERIOR_ANTERIOR2;//Se mantiene el dato
					DATA_REG_ANTERIOR_ANTERIOR1 <= DATA_REG_ANTERIOR_ANTERIOR1;//Se mantiene el dato
					DATA_REG_ANTERIOR <= DATA_REG; 									  //Se guarda los datos anteriores del registro de almacenamiento  
					DATA_REG <= DATA_REG; 						 					     //Se mantiene el dato
					end 
				else   
					begin                                                      //Si no se cumple ninguna de las condiciones anteriores  
					DATA_REG_ANTERIOR_ANTERIOR2 <= DATA_REG_ANTERIOR_ANTERIOR2;//Se mantiene el dato
					DATA_REG_ANTERIOR_ANTERIOR1 <= DATA_REG_ANTERIOR_ANTERIOR1;//Se mantiene el dato
					DATA_REG_ANTERIOR <= DATA_REG_ANTERIOR;                    //Se mantiene el dato
					DATA_REG <= DATA_REG;                                      //Se mantiene el dato
					end 
			end 
			end 
end 



////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////    ENVIO DE DATO Y ATRIBUTOS      /////////////////////////////////////////

reg SEND;               //Señal que indica que se puede enviar un dato 

reg SEND_Reg;           //Registros para el detector de flanco 
reg SEND_Reg_Anterior;  

always @(posedge Reloj)														
begin
	if(DATA_REG_ANTERIOR == 8'hF0 && (DATA_REG == DATA_REG_ANTERIOR_ANTERIOR1 || DATA_REG == DATA_REG_ANTERIOR_ANTERIOR2)) SEND = 1'b1; 
	//Si se recibe la señal "F0H" y la senal del registro de almacenamiento es igual a alguna de las que se guardo con anterioridad se envia el dato a salida 
	else SEND = 1'b0;
end 
//////


//////
always@ (posedge Reloj, posedge RST)              //Detector de flanco para enviar datos 
begin
	if (RST)	begin
		SEND_Reg <= 1'b0;
		SEND_Reg_Anterior <= 1'b0;
	end

	else begin
		SEND_Reg_Anterior <= SEND;
		if(~SEND_Reg_Anterior && SEND) SEND_Reg <= 1'b1;
		else  SEND_Reg <= 1'b0;
	end
end
//////

reg S_DATA_ON;
//////
always @(posedge Reloj)
begin 
	if(SEND_Reg == 1'b1) begin DATA_OUT <= DATA_REG; S_DATA_ON <= 1'b1; end  	//Si se recibe la señal "F0H" se envia el dato a salida 
	else begin DATA_OUT <= DATA_OUT; S_DATA_ON <= 1'b0; end
end 
//////

always @(posedge Reloj) S_DATA = S_DATA_ON;
endmodule 