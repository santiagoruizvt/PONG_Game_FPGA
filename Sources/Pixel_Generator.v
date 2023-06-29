`timescale 1ns / 1ps

module Pixel_Generator(
    input CLK,
    input CE,
    input RESET,
    input UP,
    input DOWN,
    input VIDEO_ON,
    input [9:0] X,
    input [9:0] Y,
    output reg [15:0] RGB
    );
    
    //Definición de valores máximos para la pantalla
    parameter X_MAX=639;
    parameter Y_MAX=479;
    
    //Se utiliza un tick de 60Hz
//    wire refresh_tick;
//    assign refresh_tick = ((Y == 481) && (X==0))? 1'b1: 1'b0;
    
    //Definiciones de los limites de la pared
    parameter X_WALL_L=32;
    parameter X_WALL_R=39;  //8 pixeles de ancho
    
    //Definiciones para el PADDLE
    //Condiciones de borde horizontales para el PADDLE
    parameter X_PAD_L=600;
    parameter X_PAD_R=603;  //4 pixeles de ancho
    //Condiciones de borde verticales para el PADDLE
    wire [9:0] y_pad_top,y_pad_bottom;  //Wires para el inicio y fin del paddle
    parameter PAD_HEIGHT = 72;  //72 pixeles de altura
    //Registros para trackear los bordes
    reg [9:0] y_pad_reg,y_pad_next;
    //Velocidad del PADDLE al moverse
    parameter PAD_VELOCITY = 15;
    
    //PELOTA
    parameter BALL_SIZE = 8;
    //Condiciones de borde horizontales
    wire [9:0] X_BALL_L,X_BALL_R;
    //Condiciones de borde verticales
    wire [9:0] Y_BALL_TOP, Y_BALL_BOTTOM;
    //Registros para trackear
    reg [9:0] y_ball_reg, x_ball_reg;
    //Registros para actualizar cambios
    wire [9:0] y_ball_next,x_ball_next;
    //Registros para trackear la velocidad de la PELOTA
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    
    //VELOCIDADES
    parameter BALL_VELOCITY_POS = 2;
    parameter BALL_VELOCITY_NEG = -2;
    
    //Wires y registros para la ROM
    wire [2:0] rom_address, rom_col;
    wire [7:0] rom_data;
    wire rom_bit;
    
    //Control de registros
    always @(posedge CLK)begin
        if(RESET)begin
            y_pad_reg <= 1'b0;
            x_ball_reg <= 1'b0;
            y_ball_reg <= 1'b0;
            x_delta_reg <= 10'h002;
            y_delta_reg <= 10'h002;
        end
        else if(CE) begin
            y_pad_reg <= y_pad_next;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    end 
    
    //Instancia de ROM donde está definida la PELOTA
      ROM ROM_i(.ADDRESS(rom_address),.CLK(CLK),.DATA_OUT(rom_data));
    
    //Señales para los objetos: PARED, PADDLE y proximamente PELOTA
    wire wall_on,pad_on,sq_ball_on,ball_on;
    wire [15:0] wall_rgb,pad_rgb,ball_rgb,background_rgb;
    
    //Si un pixel está dentro de los limites definidos de la PARED, se debe pintar de un color determinado. Para esto se define la siguiente señal.
    assign wall_on = ((X_WALL_L <= X) && (X <= X_WALL_R)) ? 1'b1: 1'b0;
    
    //Asignación de colores para los objetos
    assign wall_rgb = 16'hFFFF; //Pared color blanco
    assign pad_rgb = 16'hFFFF; //Pad color blanco
    assign ball_rgb = 12'hFFFF; //Pelota color blanco
    assign background_rgb = 16'h0000;
    
    //Asignaciones para el PADDLE
    assign y_pad_top = y_pad_reg;   //Posición del PADDLE
    assign y_pad_bottom = y_pad_top + PAD_HEIGHT - 1;    //Posición de la parte inferior del PADDLE
    assign pad_on = (X_PAD_L <= X) && (X <= X_PAD_R) && (y_pad_top <= Y) && (Y <= y_pad_bottom); //Pixel que está dentro de los límites del PADDLE
    
    //Control del PADDLE
    always @* begin
        y_pad_next = y_pad_reg;         //No hay movimientos
            if(UP & (y_pad_top > PAD_VELOCITY))
                 y_pad_next = y_pad_reg - PAD_VELOCITY;      // Movimiento hacia arriba
            else if (DOWN & (y_pad_bottom < (Y_MAX - PAD_VELOCITY)))
                y_pad_next = y_pad_reg + PAD_VELOCITY;      //Movimiento hacia abajo
    end
              
    //Condiciones de borde ROM
    assign X_BALL_L = x_ball_reg;
    assign Y_BALL_TOP = y_ball_reg;
    assign X_BALL_R = X_BALL_L + BALL_SIZE - 1;
    assign Y_BALL_BOTTOM = Y_BALL_TOP + BALL_SIZE - 1;
    
    //Si un pixel está dentro de las condiciones de borde de la ROM
    assign sq_ball_on = (X_BALL_L <= X) && (X <= X_BALL_R) && (Y_BALL_TOP <= Y) && (Y <= Y_BALL_BOTTOM);  
    
    //Mapa del pixel actual para ROM
    assign rom_address = Y[2:0] - Y_BALL_TOP[2:0];
    assign rom_col = X [2:0] - X_BALL_L[2:0];
    assign rom_bit = rom_data[rom_col];
    //Si el pixel está dentro del dibujo de la PELOTA, se debe activar
    assign ball_on = sq_ball_on & rom_bit;      //Si se cumplen estas dos condiciones, es porque el pixel está dentro de la PELOTA
    
    //Nueva posición para la PELOTA
    assign x_ball_next = ((Y==481) && (X==0)) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = ((Y==481) && (X==0)) ? y_ball_reg + y_delta_reg : y_ball_reg;
    
    //Cambio de dirección de la PELOTA al chocar con un límite o con la PARED
    always @* begin
            x_delta_next = x_delta_reg;
            y_delta_next = y_delta_reg;
        if(Y_BALL_TOP < 1)                                          //Cuando el TOP de la pelota es 0, llegó al borde superior de la pantalla    
            y_delta_next = BALL_VELOCITY_POS;                       //Debe moverse hacia abajo
        else if(Y_BALL_BOTTOM > Y_MAX)                              //Cuando el BOTTOM de la pelota es Y_MAX, llegó al borde inferior de la pantalla
            y_delta_next = BALL_VELOCITY_NEG;                       //Debe moverse hacia arriba 
        else if(X_BALL_L <= X_WALL_R)                               //Cuando el LEFT de la pelota es menor que el borde derecho de la PARED
            x_delta_next = BALL_VELOCITY_POS;                       //Debe moverse hacia la derecha
        else if((X_PAD_L <= X_BALL_R) && (X_BALL_R <= X_PAD_R) && (y_pad_top <= Y_BALL_BOTTOM) && (Y_BALL_TOP <= y_pad_bottom))    //Condicion de choque con el PADDLE     
            x_delta_next = BALL_VELOCITY_NEG;                       //Debe moverse hacia la izquierda
    end
    
    //Multiplexado de RGB
    always @* begin
        if(~VIDEO_ON)
            RGB = 16'h0000;             //Cuando la señal de video está deshabilitada dejo en 0 los RGB
        else if(wall_on)
            RGB = wall_rgb;             //Color de la PARED
        else if(pad_on)
            RGB = pad_rgb;              //Color del PADDLE
        else if(ball_on)
            RGB = ball_rgb;             //Color de la PELOTA
        else
            RGB = background_rgb;       //Color del FONDO
    end                  
endmodule
