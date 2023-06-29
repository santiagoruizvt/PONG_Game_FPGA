`timescale 1ns / 1ps

module Controlador_VGA(
    input CLK,
    input CE,
    input RESET,
    output VIDEO_ON,
    output HSYNC,
    output VSYNC,
    output [9:0] X,
    output [9:0] Y
    );
    
    //El módulo recibe una señal de CLK de 50MHz como CLK_principal y una señal de CE de 25MHz generado con el Clocking_Wizard en el Top_Level
    
    //Para una resolución de 640x800
    //Ancho Horizontal de la pantalla ---> 800 pixels
    parameter Horizontal_display =640;
    parameter Horizontal_front_porch = 48;
    parameter Horizontal_back_porch = 16;
    parameter Horizontal_retrace_width = 96;
    parameter Horizontal_MAX = Horizontal_display+Horizontal_front_porch+Horizontal_back_porch+Horizontal_retrace_width;
    //Alto Vertical de la pantalla ----> 525 pixels
    parameter Vertical_display=480;
    parameter Vertical_front_porch=10;
    parameter Vertical_back_porch=33;
    parameter Vertical_retrace_length =2;
    parameter Vertical_MAX=Vertical_display+Vertical_front_porch+Vertical_back_porch+Vertical_retrace_length;    
    
    //Contadores para el barrido horizontal y vertical
    reg [9:0] h_contador, h_contador_next;
    reg [9:0] v_contador, v_contador_next;
    
    //Buffers de salida
    reg v_sync,h_sync;
    wire v_sync_next,h_sync_next;
    
    //Control de registros
    always @(posedge CLK) begin
        if(RESET) begin
            v_contador <= 10'b0;
            h_contador <= 10'b0;
            v_sync <= 1'b0;
            h_sync <= 1'b0;
        end
        else begin
            v_contador <= v_contador_next;
            h_contador <= h_contador_next;
            v_sync <= v_sync_next;
            h_sync <= h_sync_next;
        end     
    end
    
    //Control del barrido horizontal
    always @(posedge CLK)
    begin
        if(RESET)
            h_contador_next =0;
        else if(CE) begin 
        if (h_contador == Horizontal_MAX)
            h_contador_next = 0;
        else
            h_contador_next = h_contador + 1;
        end     
    end
    
    //Control del barrido vertical
    always @(posedge CLK)
    begin
        if(RESET)
            v_contador_next = 0;
        else if(CE) begin 
        if (h_contador == Horizontal_MAX)
            if((v_contador == Vertical_MAX))
                v_contador_next = 0;
            else
                v_contador_next = v_contador +1;
        end         
    end
    
    //Asignaciones de las señales de sincronimos con los registros correspondientes
    assign h_sync_next = (h_contador >= (Horizontal_display+Horizontal_back_porch) && h_contador <= (Horizontal_display+Horizontal_back_porch+Horizontal_retrace_width-1));    
    assign v_sync_next = (v_contador >= (Vertical_display+Vertical_back_porch) && v_contador <= (Vertical_display+Vertical_back_porch+Vertical_retrace_length-1));
    
    //Señal de Video_ON/OFF para saber cuando los pixeles están en el área visible
    assign VIDEO_ON = (h_contador < Horizontal_display) && (v_contador < Vertical_display);
    
    //Salidas del módulo
    assign HSYNC    = h_sync;
    assign VSYNC    = v_sync;
    assign X        = h_contador;
    assign Y        = v_contador;
    
endmodule
