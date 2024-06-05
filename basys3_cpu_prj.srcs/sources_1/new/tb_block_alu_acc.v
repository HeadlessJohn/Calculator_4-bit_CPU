`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module tb_block_alu_acc();  

    reg clk;
    reg reset_p;
    reg acc_high_reset_p;
    reg rd_en;
    reg acc_in_select;
    reg op_add; 
    reg op_sub; 
    reg op_mul; 
    reg op_div; 
    reg op_and; 
    reg op_or;
    reg [1:0] acc_high_select_in;
    reg [1:0] acc_low_select;
    reg [3:0] bus_data; // 버스로부터 ACC를 거쳐 받는 데이터
    reg [3:0] bus_reg_data; // BREG로부터 받는 데이터
    wire zero_flag;
    wire sign_flag;
    wire [7:0] acc_data;

    block_alu_acc DUT_inst (
        .clk                (clk),
        .reset_p            (reset_p),
        .acc_high_reset_p   (acc_high_reset_p),
        .rd_en              (rd_en),
        .acc_in_select      (acc_in_select),
        .op_add             (op_add),
        .op_sub             (op_sub),
        .op_mul             (op_mul),
        .op_div             (op_div),
        .op_and             (op_and),
        .op_or              (op_or),
        .acc_high_select_in (acc_high_select_in),
        .acc_low_select     (acc_low_select),
        .bus_data           (bus_data), // 버스로부터 ACC를 거쳐 받는 데이터
        .bus_reg_data       (bus_reg_data), // BREG로부터 받는 데이터
        .zero_flag          (zero_flag), 
        .sign_flag          (sign_flag),
        .acc_data           (acc_data)
    );

    initial begin
        clk = 0;
        reset_p = 1;
        acc_high_reset_p = 0;
        rd_en = 1;
        acc_in_select = 0;
        acc_high_select_in = 2'b00;
        acc_low_select = 2'b00;
        bus_data = 4'b1011;
        bus_reg_data = 4'b0010;
        op_add = 0; 
        op_sub = 0;
        op_mul = 0;
        op_div = 0;
        op_and = 0;
        op_or = 0;
    end

    always #5 clk = ~clk;

    /* //multiply
    initial begin
        #10 reset_p = 0; #10;
        // 1: bus_data, 0: alu_data
        acc_in_select = 1; acc_high_select_in = 2'b11; #10; // bus_data load
        acc_in_select = 0; acc_high_select_in = 2'b00; acc_low_select = 2'b11; #10; // acc_low data load
        acc_low_select = 0; acc_high_reset_p = 1; #10; // acc_high reset
        acc_high_reset_p = 0; 
        op_mul = 1; #10; // op_mul =1
        op_mul = 0; acc_low_select = 2'b01; acc_high_select_in = 2'b01; #10; // shift
        op_mul = 1; acc_low_select = 0;     acc_high_select_in = 0;     #10; // load
        op_mul = 0; acc_low_select = 2'b01; acc_high_select_in = 2'b01; #10; // shift
        op_mul = 1; acc_low_select = 0;     acc_high_select_in = 0;     #10; // load
        op_mul = 0; acc_low_select = 2'b01; acc_high_select_in = 2'b01; #10; // shift
        op_mul = 1; acc_low_select = 0;     acc_high_select_in = 0;     #10; // load
        op_mul = 0; acc_low_select = 2'b01; acc_high_select_in = 2'b01; #10; // shift

        // #100 op_mul = 0;

        $stop;
    end
    */

    // divide
    initial begin
        #10 reset_p = 0; #10;
        // 1: bus_data, 0: alu_data
        acc_in_select = 1; acc_high_select_in = 2'b11; #10; // bus_data load
        acc_in_select = 0; acc_high_select_in = 2'b00; acc_low_select = 2'b11; #10; // acc_low data load
        acc_low_select = 0; acc_high_reset_p = 1; #10; // acc_high reset
        acc_high_reset_p = 0; 

        acc_low_select = 2'b10; acc_high_select_in = 2'b10; #10; // shift
        acc_low_select = 2'b00; op_div = 1; #10;
        op_div = 0;
        acc_low_select = 2'b10; acc_high_select_in = 2'b10; #10; // shift
        acc_low_select = 2'b00; op_div = 1; #10;
        op_div = 0;
        acc_low_select = 2'b10; acc_high_select_in = 2'b10; #10; // shift
        acc_low_select = 2'b00; op_div = 1; #10;
        op_div = 0;
        acc_low_select = 2'b10; acc_high_select_in = 2'b10; #10; // shift
        acc_low_select = 2'b00; op_div = 1; #10;
        op_div = 0;
        acc_low_select = 2'b10; acc_high_select_in = 2'b00; #10; // 하위 4비트만 shift
        acc_low_select = 2'b00;
        #10 $stop;
    end

endmodule
