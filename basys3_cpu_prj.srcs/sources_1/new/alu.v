`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module alu(
    input clk, reset_p,
    input op_add, op_sub, op_mul, op_div, op_and, alu_lsb,
    input [3:0] acc_high_data, bus_reg_data,
    output [3:0] alu_data,
    output zero_flag, sign_flag, carry_flag, cout
    // zero_flag : 연산결과가 0이면 1로 세트
    // sign_flag : 연산결과가 음쉬면 1로 세트
    // carry_flag : 연산결과가 carry가 발생하면 1로 세트

    );

    wire [3:0] sum;
    full_add_sub_4bit fadd_sub_inst( 
        .A(acc_high_data),
        .B(bus_reg_data),
        .s(op_sub | op_div), // s가 1이면 빼기, 나누기도 빼기로 처리
        .sum(sum),           // 연산결과
        .carry(cout)        // carry out
    );

    assign alu_data = op_and ? (acc_high_data & bus_reg_data) : sum;

    shift_register_PIPO_p #(1) sign_flag_inst ( 
        .clk      (clk),
        .reset_p  (reset_p),      
        .d        (!cout & op_sub),
        .wr_en    (op_sub),
        .rd_en    (1'b1),
        .q        (sign_flag) 
    );

    shift_register_PIPO_p #(1) zero_flag_inst ( 
        .clk      (clk),
        .reset_p  (reset_p),      
        .d        (~( |sum)), // sum의 모든 성분을 or 연산
        .wr_en    (op_sub),
        .rd_en    (1'b1),
        .q        (zero_flag) 
    );

    shift_register_PIPO_p #(1) carry_flag_inst ( 
        .clk      (clk),
        .reset_p  (reset_p),      
        .d        (cout & (op_add | op_div | (op_mul & alu_lsb) ) ), // sum의 모든 성분을 or 연산
        .wr_en    (1'b1),
        .rd_en    (1'b1),
        .q        (zero_flag) 
    );


endmodule
