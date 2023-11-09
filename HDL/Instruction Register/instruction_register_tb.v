`timescale 1ns/1ns
`include "instruction_register.v"

module instruction_register_tb;
	reg clk, rst_n;
	reg [31:0] D;
	wire [31:0] Q;

	instruction_register INS_reg (.clk(clk), .rst_n(rst_n), .D(D), .Q(Q));

	always #5 clk = ~clk;

	initial begin
		$dumpfile("dump.vcd"); 
		$dumpvars;
		$monitor("at time [%0t] rst_n = %b D = %h Q = %h", $time, rst_n, D, Q);
		clk = 1'b0;
		rst_n = 1'b0;

		repeat (1) @ (posedge clk);
		rst_n = 1'b1;
		D = 32'h32;
		repeat (1) @ (posedge clk);
		$finish;
	end
endmodule // instruction_register_tb