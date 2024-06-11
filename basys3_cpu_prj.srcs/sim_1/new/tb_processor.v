`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module tb_processor();
    reg clk;
    reg reset_p;
    reg key_valid;
    reg [3:0] key_value;
    wire [3:0] kout;
    wire [7:0] outreg_data;
    
    processor DUT_processor(
        .clk(clk), 
        .reset_p(reset_p),
        .key_valid(key_valid),
        .key_value(key_value),
        .kout(kout),
        .outreg_data(outreg_data)
    );

    initial begin
        clk = 0;
        reset_p = 1;
        key_valid = 0;
        key_value = 0;
        #10 reset_p = 0;
    end

    always #5 clk = ~clk;

    initial begin
                                      #10;
        reset_p = 0;                  #10;
        key_value = 3;  key_valid = 1; #10_000; // 3 press
        key_value = 0;  key_valid = 0; #10_000; //   release
        key_value = 10; key_valid = 1; #10_000; // + press
        key_value = 0;  key_valid = 0; #10_000; //   release
        key_value = 5;  key_valid = 1; #10_000; // 5 press
        key_value = 0;  key_valid = 0; #10_000; //   release
        key_value = 15; key_valid = 1; #10_000; // = press
        key_value = 0;  key_valid = 0; #10_000; //   release

        $stop;
    end

endmodule
