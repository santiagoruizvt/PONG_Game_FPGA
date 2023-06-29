`timescale 1ns / 1ps

module Clock_Enable(
    input CLK,
    input RESET,
    output SALIDA
    );
    
    reg [17:0] contador;
    assign SALIDA = ~|{contador};
    
    always @(posedge CLK or posedge RESET)
    begin
        if(RESET | contador == 18'd99999)
            contador <= 18'd0;
        else
            contador <= contador + 18'd1;
    end 
endmodule
