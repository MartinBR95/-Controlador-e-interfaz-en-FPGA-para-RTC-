module Almacenamiento(direccion,rom, rom_data);

input wire  [2:0]direccion; // Direccion de celdas (direccion) y de direccion en la celda de memoria (rom)
input wire  [3:0]rom;

output reg  [7:0]rom_data; // Datos de salida 

wire [7:0]rom_addr = {1'b0,direccion,rom};

always @(*) // Se ejecuta cada vez que se cabia la direccion ingresada 
begin
	case (rom_addr) // Dependiendo del lugar de memoria que se esta empleando se envia un bus de datos 

	8'h00 : rom_data <= 8'b00000000;
	8'h01 : rom_data <= 8'b00000000;
	8'h02 : rom_data <= 8'b00000000;
	8'h03 : rom_data <= 8'b00000000;
	8'h04 : rom_data <= 8'b00000000;
	8'h05 : rom_data <= 8'b00000000;
	8'h06 : rom_data <= 8'b00000000; //Espacio
	8'h07 : rom_data <= 8'b00000000;
	8'h08 : rom_data <= 8'b00000000;
	8'h09 : rom_data <= 8'b00000000;
	8'h0a : rom_data <= 8'b00000000;
	8'h0b : rom_data <= 8'b00000000;
	8'h0c : rom_data <= 8'b00000000;
	8'h0d : rom_data <= 8'b00000000;
	8'h0e : rom_data <= 8'b00000000;
	8'h0f : rom_data <= 8'b00000000;
	 
	8'h10 : rom_data <= 8'b00000000;
	8'h11 : rom_data <= 8'b00000000;
	8'h12 : rom_data <= 8'b11111110;
	8'h13 : rom_data <= 8'b11111110;
	8'h14 : rom_data <= 8'b00111000;
	8'h15 : rom_data <= 8'b00111000;
	8'h16 : rom_data <= 8'b00111000; //J
	8'h17 : rom_data <= 8'b00111000;
	8'h18 : rom_data <= 8'b00111000;
	8'h19 : rom_data <= 8'b00111000;
	8'h1a : rom_data <= 8'b00111000;
	8'h1b : rom_data <= 8'b00111000;
	8'h1c : rom_data <= 8'b11110000;
	8'h1d : rom_data <= 8'b11110000;
	8'h1e : rom_data <= 8'b00000000;
	8'h1f : rom_data <= 8'b00000000;

	8'h20 : rom_data <= 8'b00000000;
	8'h21 : rom_data <= 8'b00000000;
	8'h22 : rom_data <= 8'b11000110;
	8'h23 : rom_data <= 8'b11000110;
	8'h24 : rom_data <= 8'b11000110;
	8'h25 : rom_data <= 8'b11000110;
	8'h26 : rom_data <= 8'b11000110; //V
	8'h27 : rom_data <= 8'b11000110;
	8'h28 : rom_data <= 8'b11000110;
	8'h29 : rom_data <= 8'b01101100;
	8'h2a : rom_data <= 8'b01101100;
	8'h2b : rom_data <= 8'b01101100;
	8'h2c : rom_data <= 8'b00111000;
	8'h2d : rom_data <= 8'b00010000;
	8'h2e : rom_data <= 8'b00000000;
	8'h2f : rom_data <= 8'b00000000;

	8'h30 : rom_data <= 8'b00000000;
	8'h31 : rom_data <= 8'b00000000;
	8'h32 : rom_data <= 8'b10000010;
	8'h33 : rom_data <= 8'b11000110;
	8'h34 : rom_data <= 8'b11000110;
	8'h35 : rom_data <= 8'b11000110;
	8'h36 : rom_data <= 8'b11000110; //M
	8'h37 : rom_data <= 8'b11101110;
	8'h38 : rom_data <= 8'b11111110;
	8'h39 : rom_data <= 8'b11010110;
	8'h3a : rom_data <= 8'b11010110;
	8'h3b : rom_data <= 8'b11000110;
	8'h3c : rom_data <= 8'b11000110;
	8'h3d : rom_data <= 8'b00000000;
	8'h3e : rom_data <= 8'b00000000;
	8'h3f : rom_data <= 8'b00000000;

	8'h40 : rom_data <= 8'b00000000;
	8'h41 : rom_data <= 8'b00000000;
	8'h42 : rom_data <= 8'b11111100;
	8'h43 : rom_data <= 8'b11000110;
	8'h44 : rom_data <= 8'b11000010;
	8'h45 : rom_data <= 8'b11000010;
	8'h46 : rom_data <= 8'b11000100; //B
	8'h47 : rom_data <= 8'b11111000;
	8'h48 : rom_data <= 8'b11111000;
	8'h49 : rom_data <= 8'b11000100;
	8'h4a : rom_data <= 8'b11000010;
	8'h4b : rom_data <= 8'b11000010;
	8'h4c : rom_data <= 8'b11000110;
	8'h4d : rom_data <= 8'b11111110;
	8'h4e : rom_data <= 8'b00000000;
	8'h4f : rom_data <= 8'b00000000;

	8'h50 : rom_data <= 8'b00000000;
	8'h51 : rom_data <= 8'b00000000;
	8'h52 : rom_data <= 8'b01111110;
	8'h53 : rom_data <= 8'b11111110;
	8'h54 : rom_data <= 8'b11100000;
	8'h55 : rom_data <= 8'b11100000;
     8'h56 : rom_data <= 8'b01111000; //S	
	8'h57 : rom_data <= 8'b00111100;
	8'h58 : rom_data <= 8'b00001110;
	8'h59 : rom_data <= 8'b00000110;
	8'h5a : rom_data <= 8'b00000110;
	8'h5b : rom_data <= 8'b00000110;
	8'h5c : rom_data <= 8'b11111110;
	8'h5d : rom_data <= 8'b11111100;
	8'h5e : rom_data <= 8'b00000000;
	8'h5f : rom_data <= 8'b00000000;

	8'h60 : rom_data <= 8'b00000000;
	8'h61 : rom_data <= 8'b00000000;
	8'h62 : rom_data <= 8'b11000000;
	8'h63 : rom_data <= 8'b11000000;
	8'h64 : rom_data <= 8'b11000000;
	8'h65 : rom_data <= 8'b11000000;
	8'h66 : rom_data <= 8'b11000000; //L
	8'h67 : rom_data <= 8'b11000000;
	8'h68 : rom_data <= 8'b11000000;
	8'h69 : rom_data <= 8'b11000000;
	8'h6a : rom_data <= 8'b11000000;
	8'h6b : rom_data <= 8'b11000000;
	8'h6c : rom_data <= 8'b11111110;
	8'h6d : rom_data <= 8'b11111110;
	8'h6e : rom_data <= 8'b00000000;
	8'h6f : rom_data <= 8'b00000000;

	default : rom_data <= 8'b00000000;        //En caso de que se use una celda de memoria no especificada se envian ceros a la salida 
	endcase
end
endmodule  