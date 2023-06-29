`timescale 1ns / 1ps

module FF_T_CE(
    input T,
    input CLK,
    input RESET,
    input CE,
    output reg Q
    );
    
    always @ (posedge CLK or posedge RESET)
    begin
        if(RESET)
            Q = 1'b0;
        else if (CE)begin
        case(T)
            1'b0 : Q =Q;
            1'b1 : Q =!Q;
        endcase
        end
    end
    
endmodule
