`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module program_address_counter(
    input clk, reset_p,
    input pc_inc, load_pc, pc_rd_en,
    input [7:0] pc_in,
    output [7:0] pc_out
    );
    
    wire [7:0] sum, cur_addr, next_addr;
    assign next_addr = load_pc ? pc_in : sum;
    
    half_adder_N_bit #(.N(8)) pc(
        .inc(pc_inc), 
        .load_data(cur_addr),
        .sum(sum));
        
    shift_register_PIPO_p #(.N(8)) pc_reg(
        .clk(clk), .reset_p(reset_p),
        .d(next_addr),
        .wr_en(1), .rd_en(pc_rd_en),
        .register_data(cur_addr),
        .q(pc_out));
    
    
endmodule