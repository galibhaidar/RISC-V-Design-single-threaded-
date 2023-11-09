module registers (
    input clk,
    input rst_n,
    input wr_en,
    input rd_en,
    input [4:0] write_address, address_A, address_B,
    input [31:0] write_data,
    input [1:0] reg_data_length,
    output reg [31:0] data_A, data_B
    );

    reg [31:0] register [31:0];

    integer i; // new

    always @ ( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            data_A <= 32'b0;
            data_B <= 32'b0;
            register[0] <= 32'b0;
            // for (i = 1; i <=31 ; i=i+1) begin  //new
            //     register[i] <= 32'b0;
            // end                              //new
        end
        else begin
            if (wr_en) begin
                if (write_address == 0)
                    register[write_address] <= 32'b0;
                else begin
                    if (reg_data_length == 2)
                        register[write_address][7:0] <= write_data;
                    else if (reg_data_length == 1)
                        register[write_address][15:0] <= write_data;
                    else
                        register[write_address] <= write_data;
                end
            end
            else if (rd_en) begin
                data_A <= register[address_A];
                data_B <= register[address_B];
            end
        end        
    end    
endmodule