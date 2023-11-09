`timescale 1ns/1ns
`include "ALU.v"

module alu_tb;

    reg [31:0] A, B;
    reg [2:0] opcode;
    reg sub_sra;
    reg [4:0] shamt;
    wire EQ, A_less_than_B_signed, A_less_than_B_unsigned;
    wire [31:0] out;

    ALU DUT (.A(A), .B(B), .func(opcode), .sub_sra(sub_sra), .shamt(shamt), .EQ(EQ), .A_less_than_B_signed(A_less_than_B_signed),
    .A_less_than_B_unsigned(A_less_than_B_unsigned), .Q(out));

    initial begin
        $monitor("at time [%0t] A = %h B = %h opcode = %h out = %h", $time, A, B, opcode, out);
        #5;

        A = 32'h12345000;
        B = 32'h67890000;
        sub_sra = 1'b0;
        opcode = 3'd0;
        #10;
    end

endmodule