`timescale 1ns / 1ps

module FF_D_CE(
    input D,
    input CLK,
    input CE,
    input RESET,
    output reg Q
    );
    
    always @ (posedge CLK or posedge RESET)
    begin
        if(RESET)
            Q = 1'b0;
        else if(CE)
			Q = D;
    end
endmodule
