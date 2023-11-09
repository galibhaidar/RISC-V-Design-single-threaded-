module instruction_register (
	input clk,
	input en,
	input [31:0] D,
	input rst_n,
	output reg [31:0] Q);

	always @ (posedge clk or negedge rst_n) begin
		if (!rst_n)
			Q <= 32'b0;
		else begin
			if (en)
				Q <= D;
			else
				Q <= D;
		end
	end

endmodule // instruction_register