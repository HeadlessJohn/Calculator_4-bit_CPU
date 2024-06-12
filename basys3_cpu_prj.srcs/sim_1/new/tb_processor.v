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

    integer i = 0;
    integer j = 0;
    integer k = 0;

    initial begin
                                      #10;
        reset_p = 0;                  #10;
        // for (k=10; k<15; k=k+1) begin
        //     for (i=0; i<10; i=i+1) begin
        //         for (j=0; j<10; j=j+1) begin
                    i = 9; j = 7; k = 14;
                    key_value = i;  key_valid = 1; #10_000; // 3 press
                    key_value = 0;  key_valid = 0; #10_000; //   release
                    key_value = k;  key_valid = 1; #10_000; // + press
                    key_value = 0;  key_valid = 0; #10_000; //   release
                    key_value = j;  key_valid = 1; #10_000; // 5 press
                    key_value = 0;  key_valid = 0; #10_000; //   release
                    key_value = 15; key_valid = 1; #10_000; // = press
                    key_value = 0;  key_valid = 0; #10_000; //   release
                    $display("%d %d %d = %d\n", i, k, j, outreg_data);

                    #10_000;
                    i = 7; j = 9; k = 14;
                    key_value = i;  key_valid = 1; #10_000; // 3 press
                    key_value = 0;  key_valid = 0; #10_000; //   release
                    key_value = k;  key_valid = 1; #10_000; // + press
                    key_value = 0;  key_valid = 0; #10_000; //   release
                    key_value = j;  key_valid = 1; #10_000; // 5 press
                    key_value = 0;  key_valid = 0; #10_000; //   release
                    key_value = 15; key_valid = 1; #10_000; // = press
                    key_value = 0;  key_valid = 0; #10_000; //   release
                    $display("%d %d %d = %d\n", i, k, j, outreg_data);
        //         end
        //     end
        // end

        $stop;
    end

endmodule
