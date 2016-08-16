module Objetos_Top (L,X,Y,R,G,B);

//Este modulo es el encargado de pintar en pantalla las letras segun el lugar en el que se encuentre el cursor 

/////////////////// Entradas y salidas del circuito /////////////////// 

input wire R,G,B; //Entradas provenientes de interruptores (Colores Rojo, Verde y Azul)
input wire X,Y;   //Estas entradas provienen del modulo "Sincronizacion" le dicen a objetos por que parte de la pantalla se esta recorriendo
output reg [2:0] L;     //Despues de ser condicionadas estas senales son las que le indican a la pantalla que color debe ser pintado 


///////////////////     Cables de seccion de Selector de Objetos      /////////////////// 
// Entradas 
// Las entradas de esta seccion son las senales X y Y ya mencionadas 


///////////////////   Cables de seccion de Almacenamiento de objetos  /////////////////// 
// Entradas 
wire [3:0] PY; 
wire [2,0] PX; 
wire [2:0] EN; 


///////////////////          Cables de seccion de filtro              /////////////////// 
// Entradas
reg Activador;  //A grandes razgos es el que determina si las senales R,G,B llegan a pantalla o no 


///////////////////     Submodulo "Selector de Objetos"     /////////////////// 

wire [6:0] SelectorX1 = {X[9],X[8],X[7],X[6],X[5],X[4],X[3]};
wire [2:0] SelectorX2 = {X[2],X[1],X[0]};

wire [5:0] SelectorY1 = {Y[9],Y[8],Y[7],Y[6],Y[5],Y[4]};
wire [3:0] SelectorY2 = {Y[3],Y[2],Y[1],Y[0]};


always @(X,Y)                 //A partir de las entradas X y Y se determinan PX, PY y EN, que son las senales responsables de encontrar el dato deseado 
begin 
	case (SelectorX1)                     //Se determina EN
	7'bxxxxxxx : EN = 3b'000;
	7'bxxxxxxx : EN = 3b'001;
	7'bxxxxxxx : EN = 3b'010;
	7'bxxxxxxx : EN = 3b'011;
	7'bxxxxxxx : EN = 3b'100;
	7'bxxxxxxx : EN = 3b'101;
	default : EN = 3b'111;
	endcase 

	case (SelectorX1)                     //Se determina PX	
	7'bxxxxxxx : PX = SelectorX2;
	7'bxxxxxxx : PX = SelectorX2;
	7'bxxxxxxx : PX = SelectorX2;
	7'bxxxxxxx : PX = SelectorX2;
	7'bxxxxxxx : PX = SelectorX2;
	7'bxxxxxxx : PX = SelectorX2;
	default : PX = 000;
	endcase 

	case (SelectorY1)                     //Se determina PY	
	6'bxxxxxx : PY = SelectorY2;
	default : PY = 0000;	
	endcase 
end 

///////////////////  Submodulo "Almacenamiento de objetos" /////////////////// 
wire [7:0] Data;               //Esta es la salida de datos de la memoria ROM
Almacenamiento ROM (EN,PY,Data)

always @(PX)                   //El dato de la ROM posee 8 bits, pero solo se necesita 1, en esta seccion se escoge cual; dependiendo directamente del valor de PX 
begin 
	case (PX)

	4b'0000 : Activador = Data[0];
	4b'0001 : Activador = Data[1];
	4b'0010 : Activador = Data[2];
	4b'0011 : Activador = Data[3];
	4b'0100 : Activador = Data[4];
	4b'0101 : Activador = Data[5];
	4b'0110 : Activador = Data[6];
	4b'0111 : Activador = Data[7];
	4b'1000 : Activador = Data[8];
	4b'1001 : Activador = Data[9];
	4b'1010 : Activador = Data[10];
	4b'1011 : Activador = Data[11];
	4b'1100 : Activador = Data[12];
	4b'1101 : Activador = Data[13];
	4b'1110 : Activador = Data[14];
	4b'1111 : Activador = Data[15];
	
	default : Activador = Data[0];
	endcase 
end  

///////////////////           Submodulo "Filtro"          /////////////////// 

always @(Activador,R,G,B)
begin 
	case (Activador)
	
	1'b1 : L = {R,G,B};
	default : L = 3'b000;
	
	endcase
end 
endmodule 