`timescale 1ns/1ns
`include "registers.v"

module registers_tb;
    reg clk, rst_n, wr_en, rd_en;
    reg [4:0] write_address, address_A, address_B;
    reg [31:0] write_data;
    wire [31:0] data_A, data_B;

    registers regs (.clk(clk), .rst_n(rst_n), .wr_en(wr_en), .rd_en(rd_en), .write_address(write_address), 
    .write_data(write_data), .address_A(address_A), .address_B(address_B), .data_A(data_A), .data_B(data_B));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        $monitor("at time [%0t] reg_value[7] = %d reg_value[20] = %d", $time, regs.register[7], regs.register[20]);
        clk = 1'b0;
        rst_n = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;

        repeat (1) @ (posedge clk);
        rst_n = 1'b1;
        wr_en = 1'b1;
        write_address = 5'd07;
        write_data = 32'd15;

        repeat (1) @ (posedge clk);
        write_address = 5'd20;
        write_data = 32'd32;

        repeat (1) @ (posedge clk);
        wr_en = 1'b0;
        repeat (1) @ (posedge clk);
        rd_en = 1'b1;
        address_A = 5'd07;
        address_B = 5'd20;

        repeat (2) @ (posedge clk);
        $finish;
    end
endmodule

