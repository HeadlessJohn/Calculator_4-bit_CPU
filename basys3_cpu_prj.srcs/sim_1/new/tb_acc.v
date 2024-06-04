`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2024 04:01:18 PM
// Design Name: 
// Module Name: tb_acc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_acc();

    reg clk;
    reg reset_p;
    reg acc_high_reset_p; //상위 4비트만 리셋
    reg fill_value;
    reg rd_en;
    reg acc_in_select;
    reg [1:0] acc_high_select;
    reg [1:0] acc_low_select;
    reg [3:0] bus_data;
    reg [3:0] alu_data;

    wire [3:0] acc_high_data2bus;
    wire [3:0] acc_high_data2alu;
    wire [3:0] acc_low_data2bus;
    wire [3:0] acc_low_data;
    
    // acc 인스턴스
    acc DUT_acc_inst(
        .clk               (clk),
        .reset_p           (reset_p),
        .acc_high_reset_p  (acc_high_reset_p),
        .fill_value        (fill_value),
        .rd_en             (rd_en),
        .acc_in_select     (acc_in_select),
        .acc_high_select   (acc_high_select),
        .acc_low_select    (acc_low_select),
        .bus_data          (bus_data),
        .alu_data          (alu_data),
        .acc_high_data2bus (acc_high_data2bus),
        .acc_high_data2alu (acc_high_data2alu),
        .acc_low_data2bus  (acc_low_data2bus),
        .acc_low_data      (acc_low_data)
    );

    // 초기값 설정
    initial begin
        clk             = 0; 
        reset_p         = 1;
        acc_high_reset_p= 1;
        fill_value      = 0; 
        rd_en           = 1; 
        acc_in_select   = 0;  // 0: alu_data, 1: bus_data
        acc_high_select = 0; 
        acc_low_select  = 0; 
        bus_data        = 4'b0010; // 2 
        alu_data        = 4'b0101; // 5
    end

    // 클록 생성
    always #5 clk = ~clk;

    initial begin
        #10 reset_p = 0; acc_high_reset_p = 0;
        #10 acc_high_select = 2'b11;                                              // ACC HIGH에 데이터 5 로드  (acc_low_select 초기값 0: alu_data)
        #10 acc_high_select = 2'b00;                                              // ACC HIGH 데이터 유지
        #10 acc_high_select = 2'b11;                         acc_in_select   = 1; // ACC HIGH에 2를 로드
        #10 acc_high_select = 2'b00; acc_low_select = 2'b11;                      // ACC LOW에 2(high에 있는 데이터)를 로드
        #10                          acc_low_select = 2'b00;                      // ACC LOW 데이터 유지
        #10 acc_high_select = 2'b11;                         acc_in_select   = 0; // ACC HIGH에 5를 로드
        #10 acc_high_select = 2'b01; acc_low_select = 2'b01;                      // ACC HIGH, LOW 우쉬프트
        #30;                                                                      // 일정 시간 대기
        #10 acc_high_select = 2'b11; acc_low_select = 2'b00; acc_in_select   = 1; // ACC HIGH에 2를 로드
        #10 acc_high_select = 2'b00; acc_low_select = 2'b11;                      // ACC LOW에 2를 로드
        #10 acc_high_select = 2'b11; acc_low_select = 2'b00; acc_in_select   = 0; // ACC HIGH에 5를 로드                                     
        #10 acc_high_select = 2'b00;
        #10 acc_high_select = 2'b01;                                              // ACC HIGH를 우쉬프트
        #10;
        #10 acc_high_reset_p = 1;                                                 // ACC HIGH 리셋
        #10 acc_high_reset_p = 0;
        #10;
        $stop;
    end




endmodule
