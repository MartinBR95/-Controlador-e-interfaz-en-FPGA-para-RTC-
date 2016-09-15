//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:54:47 09/13/2016 
// Design Name: 
// Module Name:    FSM_Puntero 
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
module FSM_Puntero(cond1,Bcentro,Punt,Numup,Numdown,CLK,RST);
input Bcentro,cond1,CLK,RST;
output reg [2:0] Punt; //Es un puntero que guarda la direccion donde se estan editando los valores
output reg Numup,Numdown;
//////////////////////////////////////Maquina de estados de Puntero////////////////////////////////////
//Registros de estado
reg [2:0] EstadoActualp;
reg [2:0] EstadoSiguientep;
//Valores Iniciales y asignacion de estado
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		EstadoActualp <= 2'd1;
	end
	else
	begin
		EstadoActualp <= EstadoSiguientep ;
	end
end


always @(*)
begin
	case(EstadoActualp)
	
	1'd1:if(cond1)
		begin
		EstadoSiguientep=1'd2;	
		end
		else
		begin
		EstadoSiguientep=1'd1;
		end
	2'd1:if(Bcentro)
		begin
			Punt=1'd1;
			Numup=1'b0;
			Numdown=1'b0;
			EstadoSiguientep=1'd1;
		end
		else
		begin
			EstadoSiguientep=1'd2;
		end
	default
	begin
		Punt=3'b1;
		Numup=1'b0;
		Numdown=1'b0;
	end	
	endcase
end


endmodule

















