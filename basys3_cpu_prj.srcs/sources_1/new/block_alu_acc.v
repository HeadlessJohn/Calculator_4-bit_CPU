`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module block_alu_acc(
    input clk,
    input reset_p,
    input acc_high_reset_p,
    // input fill_value,
    input rd_en,
    input acc_in_select,
    input op_add, 
    input op_sub, 
    input op_mul, 
    input op_div, 
    input op_and, 
    input op_or,
    input [1:0] acc_high_select_in,
    input [1:0] acc_low_select,
    input [3:0] bus_data, // 버스로부터 ACC를 거쳐 받는 데이터
    input [3:0] bus_reg_data, // BREG로부터 받는 데이터
    output zero_flag, 
    output sign_flag,
    output [7:0] acc_data
    );

    //버스는 8비트, 레지스터는 4비트
    wire fill_value;
    wire [3:0] alu_data; // alu 로부터 acc로 보내는 데이터
    wire [3:0] acc_low_data;
    wire [3:0] acc_low_data2bus;
    wire [3:0] acc_high_data2alu;
    wire [3:0] acc_high_data2bus;

    wire [1:0] acc_high_select;
    wire cout; // cout이 1이면 뺄수 있음
    assign acc_high_select[0] = (op_mul | op_div) ?  ((op_mul & acc_low_data[0]) | (op_div & cout)) : acc_high_select_in[0]; // 곱셈 연산일때, 최하위 비트가 1이면 11을 넣어 데이터 로드
    assign acc_high_select[1] = (op_mul | op_div) ?  ((op_mul & acc_low_data[0]) | (op_div & cout)) : acc_high_select_in[1];

    acc acc_inst (
        .clk               (clk),
        .reset_p           (reset_p),
        .acc_high_reset_p  (acc_high_reset_p), //상위 4비트만 리셋
        .fill_value        (fill_value), // 빈자리 채울 값
        .rd_en             (rd_en),
        .acc_in_select     (acc_in_select),
        .acc_high_select   (acc_high_select),
        .acc_low_select    (acc_low_select),
        .bus_data          (bus_data),
        .alu_data          (alu_data),
        .acc_high_data2bus (acc_high_data2bus),
        .acc_high_data2alu (acc_high_data2alu), // 상시 출력
        .acc_low_data2bus  (acc_low_data2bus),
        .acc_low_data      (acc_low_data)
    );

    assign acc_data = {acc_high_data2bus, acc_low_data2bus}; // 출력

    wire alu_lsb;
    wire [3:0] acc_high_data;
    wire carry_flag;

    alu alu_inst (
        .clk           (clk),
        .reset_p       (reset_p),
        .op_add        (op_add),
        .op_sub        (op_sub),
        .op_mul        (op_mul),
        .op_div        (op_div),
        .op_and        (op_and),
        .op_or         (op_or),
        .alu_lsb       (alu_lsb),
        .acc_high_data (acc_high_data),
        .bus_reg_data  (bus_reg_data),
        .alu_data      (alu_data),
        .zero_flag     (zero_flag),
        .sign_flag     (sign_flag),
        .carry_flag    (carry_flag),
        .cout          (cout)
    );

    assign fill_value = carry_flag; 
    assign acc_high_data = acc_high_data2alu;
    assign alu_lsb = acc_high_data2alu[0];
endmodule
