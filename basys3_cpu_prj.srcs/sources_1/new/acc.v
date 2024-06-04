`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module half_acc(
    input clk,
    input reset_p,
    input load_msb, // shift 연산할때 사용
    input load_lsb, // shift 연산할때 사용
    input rd_en,    // read enable
    input [1:0] s,  // 00: 데이터 유지,  10: <<,  01: >>,  11: 데이터 로드
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
                
            end

        endcase
    end

    shift_register_PIPO_p #(4) h_acc_inst ( 
        .clk          (clk),
        .reset_p      (reset_p),      
        .d            (d),
        .wr_en        (1'b1),
        .rd_en        (rd_en),
        .register_data (register_data),
        .q            (data2bus) 
    );

endmodule   
