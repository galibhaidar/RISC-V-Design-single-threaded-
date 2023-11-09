module mux_4x1 (
    input [1:0] select,
    input [31:0] A0,
    input [31:0] A1,
    input [31:0] A2,
    input [31:0] A3,
    output reg [31:0] Z
);

always @ (*) begin
    case (select)
        2'b00 : Z = A0;
        2'b01 : Z = A1;
        2'b10 : Z = A2;
        2'b11 : Z = A3;
        default : Z = A0;
    endcase
end


endmodule