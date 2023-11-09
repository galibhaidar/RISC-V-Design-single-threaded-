`timescale 1ns/1ns
`include "sign_extender.v"

module sign_extender_tb;

    reg [31:0] instruction;
    reg [2:0] sx_type;
    wire [31:0] imm_sign_extended;

    sign_extender imm_sx (.instruction(instruction), .sx_type(sx_type), .imm_sign_extended(imm_sign_extended));

    initial begin
        $monitor("instruction = %h, sx_type = %b out = %b", instruction, sx_type, imm_sign_extended);
        sx_type = 3'b001;
        instruction = 32'h47f83f82;
    end
endmodule