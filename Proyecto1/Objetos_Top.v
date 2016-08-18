module Objetos_Top(L,X,Y,R,G,B);

//Este modulo es el encargado de pintar en pantalla las letras segun el lugar en el que se encuentre el cursor 
/////////////////// Entradas y salidas del circuito /////////////////// 

input wire R,G,B;    //Entradas provenientes de interruptores (Colores Rojo, Verde y Azul)
input wire [9:0]X;
input wire [9:0]Y;   //Estas entradas provienen del modulo "Sincronizacion" le dicen a objetos por que parte de la pantalla se esta recorriendo
output reg [2:0] L;  //Despues de ser condicionadas estas senales son las que le indican a la pantalla que color debe ser pintado 


///////////////////     Cables de seccion de Selector de Objetos      /////////////////// 
// Entradas 
// Las entradas de esta seccion son las senales X y Y ya mencionadas 


///////////////////   Cables de seccion de Almacenamiento de objetos  /////////////////// 
// Entradas 
wire [3:0]PY = {Y[3],Y[2],Y[1],Y[0]};
wire [2:0]PX = {X[2],X[1],X[0]};
reg  [1:0]EN; 


///////////////////          Cables de seccion de filtro              /////////////////// 
// Entradas
reg Activador;         //A grandes razgos es el que determina si las senales R,G,B llegan a pantalla o no 


///////////////////    Submodulo "Selector de Objetos"    /////////////////// 

localparam X_in_J  = 0;
localparam X_end_J = 7;

localparam X_in_V  = 8;
localparam X_end_V = 15;

localparam X_in_M  = 23;
localparam X_end_M = 30;

localparam X_in_B  = 31;
localparam X_end_B = 38;
 
localparam X_in_S  = 46;
localparam X_end_S = 53;

localparam X_in_L  = 54;
localparam X_end_L = 60;


localparam  Y_in  = 0;
localparam  Y_end = 15;

wire J_on,V_on,M_on,B_on,S_on,L_on;

assign J_on = (X_in_J <=X) && (X <=X_end_J) && (Y_in <=Y) && (Y <=Y_end);
assign V_on = (X_in_V <=X) && (X <=X_end_V) && (Y_in <=Y) && (Y <=Y_end);
assign M_on = (X_in_M <=X) && (X <=X_end_M) && (Y_in <=Y) && (Y <=Y_end);
assign B_on = (X_in_B <=X) && (X <=X_end_B) && (Y_in <=Y) && (Y <=Y_end);
assign S_on = (X_in_S <=X) && (X <=X_end_S) && (Y_in <=Y) && (Y <=Y_end);
assign L_on = (X_in_L <=X) && (X <=X_end_L) && (Y_in <=Y) && (Y <=Y_end);

always @(*)                 //A partir de las entradas X y Y se determinan PX, PY y EN, que son las senales responsables de encontrar el dato deseado 
begin
		if (J_on)
			EN <= 4'h1;
		else 
			if (V_on)
			EN <= 3'h2;
		
		else 
			if (M_on)
			EN <= 3'h3;
		
		else
			if (B_on)
			EN <= 3'h4;
		
		else 
			if (S_on)
			EN <= 3'h5;
		
		else 
			if (L_on)
			EN <= 3'h6;
			
		else 
			EN <= 3'h0;
end 

///////////////////  Submodulo "Almacenamiento de objetos" /////////////////// 
wire [7:0] Data;               //Esta es la salida de datos de la memoria ROM
Almacenamiento ROM (EN,PY,Data);

always @(*)                   //El dato de la ROM posee 8 bits, pero solo se necesita 1, en esta seccion se escoge cual; dependiendo directamente del valor de PX 
begin 
	case (PX)
	
	4'h0 : Activador <= Data[0];
	4'h1 : Activador <= Data[1];
	4'h2 : Activador <= Data[2];
	4'h3 : Activador <= Data[3];
	4'h4 : Activador <= Data[4];
	4'h5 : Activador <= Data[5];
	4'h6 : Activador <= Data[6];
	4'h7 : Activador <= Data[7];
	
	default : Activador <= Data[0];
	endcase 
end  

///////////////////           Submodulo "Filtro"          /////////////////// 

always @(Activador,R,G,B)
begin 
	case (Activador)
	
	1'b1 : L <= {R,G,B};
	default : L <= 3'b000;
	
	endcase
end 
endmodule 