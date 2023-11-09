module controller_new (
    input clk,
    input rst_n,    
    input [31:0] data_from_instruction_reg,
    input EQ,
    input A_greater_than_equal_B_signed,
    input A_greater_than_equal_B_unsigned,
    input A_less_than_B_signed,
    input A_less_than_B_unsigned,
    output reg sub_sra_out,
    output reg [2:0] ALU_func,
    output reg ALU_pc_adder_select,
    output reg [1:0] write_reg_sel,
    output reg ALU_A_select,
    output reg ALU_B_select,
    output reg mem_en, 
    output reg mem_wr_en,
    output reg mem_rd_en,
    output reg reg_en,
    output reg reg_wr_en,
    output reg reg_rd_en,
    output reg instruction_reg_en,
    output reg pc_en,
    output reg pc_alu_incr_4_imm_sel,
    output reg pc_int_ext_alu_sel,
    output reg [2:0] sx_type,
    output reg [1:0] data_length,
    output reg mem_data_read_L_type_instr,
    output reg run_complete,
    output reg branch_type_op
);
    

    parameter IDLE = 0,
              R_type_opcode = 1,
              S_type_opcode = 2,
              I_load_type_opcode = 3,
              I_arithmatic_type_opcode = 4,
              I_jump_type_opcode = 5,
              B_type_opcode = 6,
              U_load_type_opcode = 7,
              U_arithmatic_type_opcode = 8,
              JUMP_AND_LINK_type_opcode = 9,
              NOP = 10,
              R_type_opcode_write = 11,
              I_arithmatic_type_opcode_write = 12,
              S_type_opcode_write = 13,
              I_load_type_opcode_mem_read = 14,
              I_load_type_opcode_reg_write = 15,
              E_type_opcode = 16,
              JUMP_AND_LINK_REG_write_type_opcode = 17,
              JUMP_AND_LINK_REG_read_type_opcode = 18,
              JUMP_AND_LINK_REG_NOP = 19,
              B_type_opcode_decide = 20,
              B_type_opcode_branch = 21,
              B_type_opcode_NOP_first = 22,
              B_type_opcode_NOP_second = 23;

    parameter zero_extend = 0,
              imm_s_extend = 1,
              imm_i_sign_extend = 2,
              imm_i_zero_extend = 3,
              imm_u_extend = 4,
              imm_b_extend = 5,
              imm_j_extend = 6,
              shamt_i_extend = 7;

    parameter init_state = 0,
              mem_read_en_state = 1,
              mem_read_off_instruction_reg_en_state = 2,
              instruction_reg_off_state = 3,
              pc_IDLE_state = 4,              
              program_counter_enable_state = 5;
    
    parameter full_word = 0,
              half_word = 1,
              byte_word = 2;
              
    reg [4:0] next_state;
    reg [2:0] next_init_stage;
    

    wire [6:0] opcode;
    wire [2:0] func;
    wire sub_sra_in;

    assign opcode = data_from_instruction_reg[6:0];
    assign func = data_from_instruction_reg[14:12];
    assign sub_sra_in = data_from_instruction_reg[30];

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ALU_func = 3'b0;
            ALU_pc_adder_select = 1'b0;
            write_reg_sel = 2'b10;
            ALU_A_select = 1'b0;
            ALU_B_select = 1'b0;
            mem_en = 1'b0;
            mem_wr_en = 1'b0;
            mem_rd_en = 1'b0;
            instruction_reg_en = 1'b0;
            pc_en = 1'b0; 
            pc_alu_incr_4_imm_sel = 1'b0;
            pc_int_ext_alu_sel = 1'b0;
            sx_type = 3'b0;
            run_complete <= 1'b0;
            sub_sra_out <= 1'b0;
            
            next_init_stage <= init_state;

        end
        else begin
            case (next_init_stage)
                init_state : begin
                    mem_en = 1'b1;
                    mem_wr_en = 1'b1;
                    next_init_stage <= mem_read_en_state;
                end

                mem_read_en_state : begin                    
                    mem_wr_en = 1'b0;
                    mem_rd_en = 1'b1;   
                    pc_en = 1'b0;                                     
                    next_init_stage <= mem_read_off_instruction_reg_en_state;
                end

                mem_read_off_instruction_reg_en_state : begin
                    mem_rd_en = 1'b0;
                    instruction_reg_en = 1'b1;
                    next_init_stage <= instruction_reg_off_state;
                end

                instruction_reg_off_state : begin
                    instruction_reg_en = 1'b0;
                    next_init_stage <= pc_IDLE_state;
                end

                pc_IDLE_state : begin                    
                    next_init_stage <= program_counter_enable_state;
                end

                program_counter_enable_state : begin
                    if (next_state == 4'hA) begin
                        next_init_stage <= mem_read_en_state;
                        pc_en = 1'b1;
                    end
                    else begin
                        next_init_stage <= program_counter_enable_state;
                        pc_en = 1'b0;
                    end
                end

                default : next_init_stage <= init_state;
            endcase
        end
    end

    always @ ( data_from_instruction_reg ) begin
        case (next_state)
            IDLE : begin
                case (opcode)                       //opcode
                    7'b0110011 : next_state <= R_type_opcode;
                    7'b0100011 : next_state <= S_type_opcode;
                    7'b0000011 : next_state <= I_load_type_opcode;
                    7'b0010011 : next_state <= I_arithmatic_type_opcode;
                    7'b1100011 : next_state <= B_type_opcode;
                    7'b0110111 : next_state <= U_load_type_opcode;
                    7'b0010111 : next_state <= U_arithmatic_type_opcode;
                    7'b1101111 : next_state <= JUMP_AND_LINK_type_opcode;
                    7'b1100111 : next_state <= JUMP_AND_LINK_REG_write_type_opcode;
                    7'b1110011 : next_state <= E_type_opcode;
                    default    : next_state <= IDLE;
                endcase  

                pc_int_ext_alu_sel <= 1'b0;                  
            end
        endcase
    end

    always @ (posedge clk) begin
        case(next_state)
            R_type_opcode : begin
                ALU_func = func; // func
                sub_sra_out = sub_sra_in; // sub_sra
                sx_type <= zero_extend;
                reg_rd_en <= 1'b1;
                next_state <= R_type_opcode_write;
            end

            S_type_opcode : begin
                sx_type <= imm_s_extend;
                reg_rd_en <= 1'b1;
                ALU_B_select <= 1'b1;
                next_state <= S_type_opcode_write;
                ALU_func <= 3'b000;

                if (func == 3'b000)
                    data_length <= byte_word;
                else if (func == 3'b001)
                    data_length <= half_word;
                else if (func == 3'b010)
                    data_length <= full_word;
            end

            I_arithmatic_type_opcode : begin
                if (func == 3'd1 || func == 3'd5 ) begin
                    sx_type <= shamt_i_extend;
                    sub_sra_out <= sub_sra_in;
                    reg_rd_en <= 1'b1;
                    ALU_B_select <= 1'b1;                   
                end
                else begin
                    sx_type <= imm_i_sign_extend;
                    ALU_B_select <= 1'b1;                    
                    reg_rd_en <= 1'b1;
                    // if ( data_from_instruction_reg[31] == 1'b1 )
                    //     sub_sra_out <= 1'b1;
                    // else
                    sub_sra_out <= 1'b0;
                end
                ALU_func <= func;
                next_state <= I_arithmatic_type_opcode_write;
            end

            I_load_type_opcode : begin
                if (func >= 4) begin
                    sx_type <= imm_i_zero_extend;
                    reg_rd_en <= 1'b1;
                    ALU_B_select <= 1'b1;
                    ALU_pc_adder_select <= 1'b1;
                    ALU_func <= 3'b000;
                    next_state <= I_load_type_opcode_mem_read;
                    if (func == 3'b101)
                        data_length <= byte_word;
                    else
                        data_length <= half_word;
                    end
                    
                else begin
                    sx_type <= imm_i_sign_extend;
                    reg_rd_en <= 1'b1;
                    ALU_B_select <= 1'b1;
                    ALU_func <= 3'b000;
                    next_state <= I_load_type_opcode_mem_read;

                    if (func == 3'b000)
                        data_length <= byte_word;
                    else if (func == 3'b001)
                        data_length <= half_word;
                    else
                        data_length <= full_word;
                end
            end

            B_type_opcode : begin
                sx_type <= imm_b_extend;
                branch_type_op <= 1'b1;
                reg_rd_en <= 1'b1;
                ALU_func <= func;
                next_state <= B_type_opcode_NOP_first;             
            end

            B_type_opcode_NOP_first : begin
                next_state <= B_type_opcode_decide;    
            end

            B_type_opcode_decide : begin
                case (func)
                    3'b000 : begin
                        if (EQ == 1'b1)
                            next_state <= B_type_opcode_branch;
                        else
                            next_state <= NOP;
                    end
                    3'b001 : begin
                        if (EQ == 1'b0)
                            next_state <= B_type_opcode_branch;
                        else
                            next_state <= NOP;
                    end
                    3'b100 : begin
                        if (A_less_than_B_signed == 1'b1)
                            next_state <= B_type_opcode_branch;
                        else
                            next_state <= NOP;
                    end
                    3'b101 : begin
                        if (A_greater_than_equal_B_signed == 1'b1)
                            next_state <= B_type_opcode_branch;
                        else
                            next_state <= NOP;
                    end
                    3'b110 : begin
                        if (A_less_than_B_unsigned == 1'b1)
                            next_state <= B_type_opcode_branch;
                        else
                            next_state <= NOP;
                    end
                    3'b111 : begin
                        if (A_greater_than_equal_B_unsigned == 1'b1)
                            next_state <= B_type_opcode_branch;
                        else
                            next_state <= NOP;
                    end
                endcase
            end

            B_type_opcode_branch : begin
                ALU_A_select <= 1'b1;
                ALU_B_select <= 1'b1;
                pc_int_ext_alu_sel <= 1'b1;
                ALU_func <= 3'b000;
                next_state <= NOP;
            end

            U_load_type_opcode: begin
                sx_type <= imm_u_extend;
                write_reg_sel <= 2'b11;
                reg_wr_en <= 1'b1;
                next_state <= NOP;                    
            end

            U_arithmatic_type_opcode : begin
                sx_type <= imm_u_extend;
                ALU_A_select <= 1'b1;
                ALU_B_select <= 1'b1;
                reg_wr_en <= 1'b1;
                write_reg_sel <= 2'b01;
                ALU_func <= 3'b000;
                next_state <= NOP;
            end

            JUMP_AND_LINK_type_opcode : begin
                sx_type <= imm_j_extend;
                write_reg_sel <= 2'b00;
                reg_wr_en <= 1'b1;
                ALU_func <= 3'b000;
                ALU_A_select <= 1'b1;
                ALU_B_select <= 1'b1;
                pc_int_ext_alu_sel <= 1'b1;
                next_state <= NOP;
            end

            JUMP_AND_LINK_REG_write_type_opcode : begin
                sx_type <= imm_i_sign_extend;
                reg_wr_en <= 1'b1;
                write_reg_sel <= 2'b00;
                next_state <= JUMP_AND_LINK_REG_read_type_opcode;
            end

            JUMP_AND_LINK_REG_read_type_opcode : begin
                reg_wr_en <= 1'b0;
                reg_rd_en <= 1'b1;
                ALU_B_select <= 1'b1;
                ALU_func <= 3'b000;
                pc_int_ext_alu_sel <= 1'b1;
                next_state <= JUMP_AND_LINK_REG_NOP;
            end     

            JUMP_AND_LINK_REG_NOP : begin
                next_state <= NOP;
            end        

            R_type_opcode_write : begin
                reg_rd_en = 1'b0;
                reg_wr_en = 1'b1;
                write_reg_sel = 2'b01;
                next_state <= NOP;
            end

            I_arithmatic_type_opcode_write : begin
                reg_rd_en = 1'b0;
                reg_wr_en = 1'b1;
                write_reg_sel = 2'b01;
                next_state <= NOP;
            end

            S_type_opcode_write : begin
                ALU_pc_adder_select <= 1'b1;
                mem_wr_en <= 1'b1;
                next_state <= NOP;
            end

            I_load_type_opcode_mem_read : begin
                ALU_pc_adder_select <= 1'b1;
                mem_data_read_L_type_instr <= 1'b1;
                mem_rd_en <= 1'b1;
                next_state <= I_load_type_opcode_reg_write;
            end

            I_load_type_opcode_reg_write : begin
                write_reg_sel <= 2'b10;
                reg_wr_en <= 1'b1;
                next_state <= NOP;
            end

            E_type_opcode : begin
                if (data_from_instruction_reg[20] == 1'b1)
                    run_complete <= 1'b1;
            end

            NOP : begin
                reg_wr_en <= 1'b0;
                reg_rd_en <= 1'b0;
                ALU_A_select <= 1'b0;
                ALU_B_select <= 1'b0;
                ALU_pc_adder_select <= 1'b0;
                mem_wr_en <= 1'b0;
                mem_rd_en <= 1'b0;
                mem_data_read_L_type_instr <= 1'b0;
                branch_type_op <= 1'b0;
                sub_sra_out <= 1'b0;
                next_state <= IDLE;
            end

            default: next_state <= IDLE;
        endcase
    end
    
endmodule