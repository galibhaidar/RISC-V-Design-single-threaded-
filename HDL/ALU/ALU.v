module ALU (
    input [31:0] A,
    input [31:0] B,
    input [2:0] func,
    input sub_sra,
    input branch_type_op,
    input [4:0] shamt,
    output reg [31:0] Q,
    output reg EQ,
    output reg A_greater_than_equal_B_signed,
    output reg A_greater_than_equal_B_unsigned,
    output reg A_less_than_B_signed,
    output reg A_less_than_B_unsigned
);

always @ (*) begin
    case (func)
        3'b000 : begin
            if (sub_sra) begin
                Q = $signed(A) - $signed(B);
                $display("sub");
            end
            else begin
                Q = A + B;
                $display("sum");
            end
            if (branch_type_op) begin
                if ($signed(A) == $signed(B))
                    EQ = 1'b1;
                else
                    EQ = 1'b0;
            end
            else
                EQ = 1'b0;
                            
        end
        3'b001 : begin
            Q = A << B[4:0];
            if (branch_type_op) begin
                if ($signed(A) != $signed(B))
                    EQ = 1'b0;
                else
                    EQ = 1'b1;
            end
            else
                EQ = 1'b1;
        end

        3'b010 : begin
            if ( $signed(A) < $signed(B))
                Q = 32'b1;
            else
                Q = 32'b0;
        end

        3'b011 : begin
            if ( A < B)
                Q = 32'b1;
            else
                Q = 32'b0;
        end

        3'b100 : begin 
            Q = A ^ B;

            if (branch_type_op) begin
                if ($signed(A) < $signed(B))
                    A_less_than_B_signed = 1'b1;
                else
                    A_less_than_B_signed = 1'b0;
            end
            else
                A_less_than_B_signed = 1'b0;
        end
        
        3'b101 : begin
            if (sub_sra)
                Q = $signed(A) >>> B[4:0];
            else 
                Q = A >> B[4:0];

            if (branch_type_op) begin
                if ($signed(A) >= $signed(B))
                    A_greater_than_equal_B_signed = 1'b1;
                else
                    A_greater_than_equal_B_signed = 1'b0;
            end
            else
                A_greater_than_equal_B_signed = 1'b0;
        end

        3'b110 : begin 
            Q = A | B;

            if (branch_type_op) begin
                if (A < B)
                    A_less_than_B_unsigned = 1'b1;
                else
                    A_less_than_B_unsigned = 1'b0;
            end
            else
                A_less_than_B_unsigned = 1'b0;
        end
        3'b111 : begin 
            Q = A & B;

            if (branch_type_op) begin
                if (A >= B)
                    A_greater_than_equal_B_unsigned = 1'b1;
                else
                    A_greater_than_equal_B_unsigned = 1'b0;
            end
            else
                A_greater_than_equal_B_unsigned = 1'b0;
        end
        default: begin 
            Q = 32'b0;
            EQ = 1'b0;
            A_greater_than_equal_B_signed = 1'b0;
            A_greater_than_equal_B_unsigned = 1'b0;
            A_less_than_B_signed = 1'b0;
            A_less_than_B_unsigned = 1'b0;
        end
    endcase
end
endmodule