//segundo modulo de sincronizacion CON pulso habilitador (Adaptado para funcionar a 25Mhz, compatible con VGA)

module vgasync(clk, rst,hsync, vsync, ENclock,px_X, px_Y);

//Es preferible definir los parametros de retraso y tiempo de
//display como constantes que se pueden modificar y ajustar al
//dispositivo especfifico a utilizar.
input clk,rst;
output wire hsync, vsync,ENclock;
output wire [9:0] px_X, px_Y;

	localparam HD = 640;
	localparam HF = 48;
	localparam HB = 16;
	localparam HR = 96;
	localparam VD = 480;
	localparam VF = 10;
	localparam VB = 33;
	localparam VR = 2;

//estas variables controlan cuando se ejecutan los cambios a las variables
//para que conmuten con una frecuencia diferente de la del clock.

	reg ENpulse;
	wire ENpulse_next;
	
//con estos registros se lleva la cuenta de la columna y fila en que se encuentra el pixel
		
	reg [9:0] hcnt, hcnt_next;
	reg [9:0] vcnt, vcnt_next;
	
//estos registros indican si se ha terminado o no la linea o cuadro
	
	reg v_sync_reg, h_sync_reg;
	wire v_sync_next, h_sync_next;
	
	wire h_end, v_end;
	
//la estructura always permite configurar el reset y las condiciones iniciales de operacion del dispositivo
//y define las acciones a tomar si no se encuentra en estado de reset	
	
	always @(posedge clk, posedge rst)
		if(rst) begin //seccion para definir todos los parametros de inicio como cero
			vcnt <= 0;
			hcnt <= 0;
			v_sync_reg <= 1'b0;
			h_sync_reg <= 1'b0;
			ENpulse = 0;
			end
		else begin
			ENpulse <= ENpulse_next; //en cada ciclo de reloj se le asigna al pulso habilitador su valor siguiente
			vcnt <= vcnt_next;
			hcnt <= hcnt_next;
			v_sync_reg <= v_sync_next;
			h_sync_reg <= h_sync_next;
			end 
			

//aqui se configura la oscilacion del pulso habilitador
//dandole un valor siguiente que es el complemento de su valor actual			
		assign ENpulse_next = ~ENpulse;
		
//estas variables indican si ya se ha terminado o no una linea o pantalla
		assign h_end = (hcnt == (HD+HF+HB+HR-1));
		assign v_end = (vcnt == (VD+VF+VB+VR-1));
		
//estos ciclos determinan el siguiente estado que debe tener cada una de las variables
		always @*
			if(ENpulse_next)begin //solamente se cambia el valor del estado siguiente cuando el pulso habilitador lo permite
				if (h_end) hcnt_next = 0;
				else hcnt_next = hcnt + 1;
				end
			else begin hcnt_next = hcnt; end
		always @*
			if(ENpulse_next && h_end)begin
				if (v_end) vcnt_next= 0;
				else vcnt_next = vcnt + 1;
				end
			else begin vcnt_next = vcnt; end
			
//aqui se asignan los valores de los pulsos de sincronia vertical y horizontal
//de acuerdo con la posicion que tiene el "cursor" en una fila o columna
			
		assign h_sync_next = (hcnt >= (HD+HB) && hcnt <= (HD+HB+HR-1));
		assign v_sync_next = (vcnt >= (VD+VB) && vcnt <= (VD+VB+VR-1));
		
//finalmente, se asignan los valores de cada una de las variables utilizadas
//a la salida del modulo para que puedan ser utilizadas por otros modulos		
		assign hsync = h_sync_reg;
		assign vsync = v_sync_reg;
		assign px_X = hcnt;
		assign px_Y = vcnt;
		assign ENclock = ENpulse_next; 
		
endmodule 