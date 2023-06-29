`timescale 1ns / 1ps

module Controlador_VGA_TB();

reg     CLK,CE,RESET;
wire    VIDEO_ON,HSYNC,VSYNC;
wire    [9:0] X,Y;

Controlador_VGA u0 (CLK,CE,RESET,VIDEO_ON,HSYNC,VSYNC,X,Y);

initial begin
    CLK=0;
    RESET=1;
    forever #1 CLK=~CLK;
end

initial begin
    CE=0;
    forever #2 CE=~CE;
end

initial begin
    #3;
    RESET=0;
end
endmodule
