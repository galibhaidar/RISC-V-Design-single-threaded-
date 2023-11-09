`timescale 1ns/1ns

module top_tb_new;
    reg clk, rst_n;
    wire run_complete;

    event sim_stop;

    TOP top (.clk(clk), .rst_n(rst_n), .run_complete(run_complete));

    always #5 clk = ~clk;

    // initial begin
    //     $display("sim started");
    //     @(sim_stop);
    //     $display("sim finished");
    //     $finish;
    // end

    initial begin
        // $dumpfile("test.vcd");
        // $dumpvars;
        $monitor ("at time [%0t] mem_reg_val[0] = %h mem_reg_val[1] = %h mem_reg_val[2] = %h stored_reg_val[1] = %h stored_reg_val[3] = %h stored_reg_val[4] = %h stored_reg_val[5] = %h stored_reg_val[6] = %h stored_reg_val[7] = %h stored_reg_val[8] = %h stored_reg_val[9] = %h stored_reg_val[10] = %h stored_reg_val[11] = %h read_complete = %b", $time , top.memory.register[0], top.memory.register[1], top.memory.register[2], top.Register.register[1], top.Register.register[3], top.Register.register[4], top.Register.register[5], top.Register.register[6], top.Register.register[7], top.Register.register[8], top.Register.register[9], top.Register.register[10], top.Register.register[11], run_complete);
        rst_n = 1'b0;
        clk = 1'b0;

        repeat (1) @ (posedge clk);
        rst_n = 1'b1;

        // repeat (38) @ (posedge clk);
        // $finish;

        // if (run_complete)
            // ->sim_stop;
    end

    always @ (posedge clk) begin
        if (run_complete) begin
            #10;
            $finish;
        end
    end

endmodule