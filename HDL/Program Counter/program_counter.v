module program_counter (
    input clk,
    input rst_n,
    input en,
    input pc_int_ext_alu_sel,
    input pc_alu_incr_4_imm_sel,
    input [31:0] ext_alu_in,
    input [31:0] imm_val,
    output reg [31:0] pc,
    output [31:0] pc_alu_out
);

wire [31:0] pc_d_in, adder_A_in;

reg [31:0] ext_alu_in_reg;

assign adder_A_in = pc_alu_incr_4_imm_sel ? imm_val : 32'h4;

assign pc_alu_out = adder_A_in + pc;

assign pc_d_in = pc_int_ext_alu_sel ? ext_alu_in_reg : pc_alu_out;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        pc <= 32'b0;
    else begin
        if (en)
            pc <= {pc_d_in[31:2], 2'b0};
        else
            pc <= pc;
    end

    ext_alu_in_reg <= ext_alu_in;
end


endmodule