`include "modules.vh"

module TOP (
    input clk,
    input rst_n,
    output run_complete
    );

    wire [31:0] instr_reg_out, instr_mem_out, pc_out, pc_alu_out, mem_address, ALU_result, sx_imm_val;
    wire [31:0] A_in, B_in, rs1_val, rs2_val, mux_4x1_out;
    wire [2:0] ALU_func_data;

    wire pc_alu_incr_4_imm_sel, pc_int_ext_alu_sel, EQ, A_less_than_B_signed, A_less_than_B_unsigned;
    wire sub_sra_data, ALU_pc_adder_select, ALU_A_select, ALU_B_select, mem_en, mem_rd_en, mem_wr_en;
    wire reg_en, reg_rd_en, reg_wr_en, instruction_reg_en, pc_en, mem_data_read_L_type_instr;
    wire A_greater_than_equal_B_signed, A_greater_than_equal_B_unsigned, branch_type_op;
    wire [1:0] write_reg_sel, data_length;
    wire [2:0] sx_type;

    program_counter pgm_cntr (.clk(clk), .rst_n(rst_n), .en(pc_en), .pc_alu_incr_4_imm_sel(pc_alu_incr_4_imm_sel), 
    .pc_int_ext_alu_sel(pc_int_ext_alu_sel), .imm_val(sx_imm_val), .ext_alu_in(ALU_result), .pc(pc_out), .pc_alu_out(pc_alu_out));

    controller_new fsm_controller (.clk(clk), .rst_n(rst_n), .data_from_instruction_reg(instr_reg_out), .EQ(EQ), .A_less_than_B_signed(A_less_than_B_signed), 
    .A_less_than_B_unsigned(A_less_than_B_unsigned), .sub_sra_out(sub_sra_data) , .ALU_func(ALU_func_data), 
    .ALU_pc_adder_select(ALU_pc_adder_select), .write_reg_sel(write_reg_sel), .ALU_A_select(ALU_A_select), 
    .ALU_B_select(ALU_B_select), .mem_en(mem_en), .mem_rd_en(mem_rd_en), .mem_wr_en(mem_wr_en), .reg_en(reg_en), 
    .reg_rd_en(reg_rd_en), .reg_wr_en(reg_wr_en), .instruction_reg_en(instruction_reg_en), .pc_en(pc_en), .sx_type(sx_type),
    .pc_alu_incr_4_imm_sel(pc_alu_incr_4_imm_sel), .pc_int_ext_alu_sel(pc_int_ext_alu_sel), .data_length(data_length), 
    .mem_data_read_L_type_instr(mem_data_read_L_type_instr), .run_complete(run_complete), 
    .A_greater_than_equal_B_signed(A_greater_than_equal_B_signed), .A_greater_than_equal_B_unsigned(A_greater_than_equal_B_unsigned),
    .branch_type_op(branch_type_op));

    assign mem_address = ALU_pc_adder_select ? ALU_result : pc_out;

    mem memory (.clk(clk), .rst_n(rst_n), .en(mem_en) ,.wr_en(mem_wr_en), .rd_en(mem_rd_en), .address(mem_address), .D(rs2_val), 
    .mem_data_length(data_length), .data_read_L_type_instr(mem_data_read_L_type_instr), .Q(instr_mem_out));

    instruction_register ins_reg (.clk(clk), .rst_n(rst_n), .en(instruction_reg_en), .D(instr_mem_out), .Q(instr_reg_out));

    sign_extender sx (.sx_type(sx_type), .instruction(instr_reg_out), .imm_sign_extended(sx_imm_val));
    
    assign A_in = ALU_A_select ? pc_out : rs1_val;
    assign B_in = ALU_B_select ? sx_imm_val : rs2_val;

    ALU main_ALU (.func(ALU_func_data), .sub_sra(sub_sra_data), .shamt(sx_imm_val[4:0]), .A(A_in), .B(B_in), .Q(ALU_result), 
    .EQ(EQ), .A_less_than_B_signed(A_less_than_B_signed), .A_less_than_B_unsigned(A_less_than_B_unsigned), 
    .A_greater_than_equal_B_signed(A_greater_than_equal_B_signed), .A_greater_than_equal_B_unsigned(A_greater_than_equal_B_unsigned),
    .branch_type_op(branch_type_op));

    registers Register (.clk(clk), .rst_n(rst_n), .wr_en(reg_wr_en), .rd_en(reg_rd_en), .write_address(instr_reg_out[11:7]),
    .address_A(instr_reg_out[19:15]), .address_B(instr_reg_out[24:20]), .write_data(mux_4x1_out), 
    .data_A(rs1_val), .data_B(rs2_val), .reg_data_length(data_length));

    mux_4x1 mux_0 (.select(write_reg_sel), .A0(pc_alu_out), .A1(ALU_result), .A2(instr_mem_out), .A3(sx_imm_val), .Z(mux_4x1_out));
    
endmodule