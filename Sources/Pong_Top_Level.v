`timescale 1ns / 1ps

module Pong_Top_Level(
    input RESET,
    input UP,
    input DOWN,
    output HSYNC,
    output VSYNC,
    output reg [15:0] RGB,
    output LED_UP,
    output LED_DOWN
    );
    
    wire CLK;
    //Como señal de CLK, se utiliza el Block_Design activar el CLK de 50MHz, solo es necesario instanciarlo
    design_1 design_1_i (.CLK_OUT(CLK));
    
    
    wire CLK_25MHZ;
    reg  r_25MHZ;
    //Busco un CLOCK de 25MHz, partiendo de un CLK de 50MHz solamente los divido por 2
    always @(posedge CLK)
        if(RESET)
            r_25MHZ <= 1'd0;
        else
            r_25MHZ <= r_25MHZ +1'd1;    
            
    assign CLK_25MHZ = (r_25MHZ==0) ? 1'd1: 1'd0; //Division del CLK de 50MHz por 2 --> 25MHz
    
    //Se crean algunos wires para realizar conexiones entre modulos
    wire up_debounced,down_debounced;
    wire video_ON;
    wire [9:0] contador_x,contador_y;
    wire [15:0] rgb_next;
    
    
    //Intancias para módulo del proyecto
    Controlador_VGA controlador_vga (CLK,CLK_25MHZ,RESET,video_ON,HSYNC,VSYNC,contador_x,contador_y);
    Pixel_Generator pixel_generator (CLK,1'b1,RESET,up_debounced,down_debounced,video_ON,contador_x,contador_y,rgb_next);
    
    //Debouncers para cada pulsador del proyecto
    Debouncer debounce_UP (CLK,RESET,UP,up_debounced,LED_UP);
    Debouncer debounce_DOWN (CLK,RESET,DOWN,down_debounced,LED_DOWN);
    
    always @(posedge CLK) begin
        if(RESET)
            RGB <= 16'b0;
        if(CLK_25MHZ)
            RGB <= rgb_next;
    end     
  
endmodule
