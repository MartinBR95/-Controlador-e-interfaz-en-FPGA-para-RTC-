
//primer modulo de sincronizacion sin pulso habilitador (funciona a la velocidad maxima de la FPGA)

module vgasync1(input clk, rst, output wire hsync, vsync, output wire [9:0] px_X, px_Y);
	
	localparam HD = 640;
	localparam HF = 48;
	localparam HB = 16;
	localparam HR = 96;
	localparam VD = 480;
	localparam VF = 10;
	localparam VB = 33;
	localparam VR = 2;

	
	reg [9:0] hcnt, hcnt_next;
	reg [9:0] vcnt, vcnt_next;
	
	reg v_sync_reg, h_sync_reg;
	wire v_sync_next, h_sync_next;
	
	wire h_end, v_end;
	
	always @(posedge clk, posedge rst)
		if(rst) begin //seccion para definir todos los parametros de inicio como cero
			vcnt <= 0;
			hcnt <= 0;
			v_sync_reg <= 1'b0;
			h_sync_reg <= 1'b0;
			end
		else begin
			vcnt <= vcnt_next;
			hcnt <= hcnt_next;
			v_sync_reg <= v_sync_next;
			h_sync_reg <= h_sync_next;
			end 
		
		assign h_end = (hcnt == (HD+HF+HB+HR-1));
		assign v_end = (vcnt == (VD+VF+VB+VR-1));
//revisar esta seccion para dividir reloj		
		always @*
			if (h_end) hcnt_next = 0;
			else hcnt_next = hcnt + 1;
		always @*
			if (v_end) vcnt_next= 0;
			else vcnt_next = vcnt + 1;
			
			
		assign h_sync_next = (hcnt >= (HD+HB) && hcnt <= (HD+HB+HR-1));
		assign v_sync_next = (vcnt >= (VD+VB) && vcnt <= (VD+VB+VR-1));
		
		assign hsync = h_sync_reg;
		assign vsync = v_sync_reg;
		assign px_X = hcnt;
		assign px_Y = vcnt;
		
endmodule
		
		
		
		
		
	
	
