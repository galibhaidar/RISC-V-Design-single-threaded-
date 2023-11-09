module sign_extender (
    input [31:0] instruction,
    input [2:0] sx_type,
    output reg [31:0] imm_sign_extended
    );

always @ (instruction or sx_type) begin
    case (sx_type)
        3'b000 : imm_sign_extended = 32'b0;
        3'b001 : imm_sign_extended = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
        3'b010 : imm_sign_extended = { {20{instruction[31]}}, instruction[31:20] };
        3'b011 : imm_sign_extended = { {20'b0}, instruction[31:20] };
        3'b100 : imm_sign_extended = { instruction[31:12], {12'b0} };
        3'b101 : imm_sign_extended = { {19{instruction[31]}}, instruction[31], instruction[7] , instruction[30:25] , instruction[11:8] , 1'b0};
        3'b110 : imm_sign_extended = { {11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        3'b111 : imm_sign_extended = { {27{instruction[31]}}, instruction[24:20] };
        default: imm_sign_extended = 32'b0;
    endcase
end
    
endmodule