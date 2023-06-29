`timescale 1ns / 1ps

module Debouncer(
    input CLK,
    input RESET,
    input P,
    output SALIDA,
    output LED
    );
    
    wire CE;
    wire Q0;
    wire Q1;
    wire Q2;
    wire Q3;
    wire CE_SALIDA=Q0 & Q1 & Q2 & (~Q3);
    
    Clock_Enable(CLK,RESET,CE);
    FF_D_CE D0 (P,CLK,CE,RESET,Q0);
    FF_D_CE D1 (Q0,CLK,CE,RESET,Q1);
    FF_D_CE D2 (Q1,CLK,CE,RESET,Q2);
    FF_D_CE D3 (Q2,CLK,1'b1,RESET,Q3);
    FF_T_CE T (1'b1,CLK,RESET,CE_SALIDA,LED);
    
    assign SALIDA = CE_SALIDA;
endmodule
