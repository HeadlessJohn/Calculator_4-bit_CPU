`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module calculator_top(
    input clk, reset_p,
    input [3:0] row,
    output [3:0] col,
    output [3:0] com,
    output [7:0] seg_7
    );

    wire key_valid;
    wire [3:0] key_value;
    wire [3:0] kout;
    wire [7:0] outreg_data;
    processor processor_inst(
        .clk         (clk), 
        .reset_p     (reset_p),
        .key_valid   (key_valid),
        .key_value   (key_value),
        .kout        (kout),
        .outreg_data (outreg_data)
    );
    key_matrix_4x4 key_inst(
        .clk       (clk), 
        .reset_p   (reset_p),
        .row       (row),
        .col       (col),
        .key_value (key_value), //키가 눌린 16가지 경우
        .key_valid (key_valid) //아무 키도 눌리지 않은 경우
    );

    wire [15:0] value;
    wire [15:0] dec_data;
    assign value = {4'hF, kout, dec_data[7:0]}; // 키입력, F, 결과
    bin_to_dec bcd_inst(
        .bin(outreg_data),
        .bcd(dec_data)
    );

    fnd_4_digit_cntr fnd_inst (
        .clk             (clk), 
        .reset_p         (reset_p),
        .value           (value),
        .segment_data_an (seg_7),
        .com_sel         (com)
    ); 
endmodule
