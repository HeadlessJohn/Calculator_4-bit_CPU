`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module half_acc(
    input clk,
    input reset_p,
    input load_msb, // shift 연산할때 사용
    input load_lsb, // shift 연산할때 사용
    input rd_en,    // read enable
    input [1:0] s,  // 00: 데이터 유지,  10: <<,  01: >>,  11: 데이터 로드
    input [3:0] data_in, // 입력 데이터
    output [3:0] data2bus, // bus에 데이터 출력
    output [3:0] register_data // 레지스터에 데이터 출력
    );

    reg [3:0] d;

    always @* begin // @* : level trigger, 조합회로 생성
        case (s)
            2'b00 : begin
                d = register_data;
            end
            2'b01 : begin
                d = {load_msb, register_data[3:1]}; // 우쉬프트 하고 최상위비트 받아옴
            end
            2'b10 : begin
                d = {register_data[2:0], load_lsb}; // 좌쉬프트 하고 최하위비트 받아옴
            end
            2'b11 : begin
                d = data_in; // 데이터 로드
            end

        endcase
    end

    shift_register_PIPO_p #(4) h_acc_inst ( 
        .clk           (clk),
        .reset_p       (reset_p),      
        .d             (d),
        .wr_en         (1'b1),
        .rd_en         (rd_en),
        .register_data (register_data), // 상시 출력
        .q             (data2bus)       // bus로 출력할 데이터
    );

endmodule   

module acc (
    input clk,
    input reset_p,
    input acc_high_reset_p, //상위 4비트만 리셋
    input fill_value, // 빈자리 채울 값
    input rd_en,
    input acc_in_select,
    input [1:0] acc_high_select,
    input [1:0] acc_low_select,
    input [3:0] bus_data,
    input [3:0] alu_data,
    output [3:0] acc_high_data2bus,
    output [3:0] acc_high_data2alu, // 상시 출력
    output [3:0] acc_low_data2bus,
    output [3:0] acc_low_data
    );
    
    // acc_in_select이 1이면 bus_data, 0이면 alu_data 로 부터 입력
    wire [3:0] acc_high_load_data;
    assign acc_high_load_data = acc_in_select ? bus_data : alu_data; 

    half_acc acc_high_inst (
        .clk           (clk),
        .reset_p       (reset_p | acc_high_reset_p),
        .load_msb      (fill_value),        // 시프트 할때 빈자리 채울 값
        .load_lsb      (acc_low_data[3]),   // 좌시프트 할 때 low_data의 최상위 비트를 받아옴
        .rd_en         (rd_en),
        .s             (acc_high_select),   // 00 유지, 10 <<, 01 >>, 11 데이터 로드
        .data_in       (acc_high_load_data),// 로드할 데이터
        .data2bus      (acc_high_data2bus), // BUS로 데이터 출력
        .register_data (acc_high_data2alu)  // ALU로 상시 출력
    );

    half_acc acc_low_inst (
        .clk           (clk),
        .reset_p       (reset_p),
        .load_msb      (acc_high_data2alu[0]), // 우쉬프트 할때 high_data의 최하위 비트를 받아옴
        .load_lsb      (fill_value),         // 시프트 할때 채울 값
        .rd_en         (rd_en),
        .s             (acc_low_select),     // 00 유지, 10 <<, 01 >>, 11 데이터 로드
        .data_in       (acc_high_data2alu),  // 상위 4비트의 출력을 입력으로 받음
        .data2bus      (acc_low_data2bus),   // BUS로 데이터 출력
        .register_data (acc_low_data)
    );
endmodule