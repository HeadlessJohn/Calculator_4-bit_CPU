`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module processor(
        input clk, reset_p,
        input [3:0] key_value,
        input key_valid,
        output [3:0] kout,
        output [7:0] outreg_data);
    
    wire [7:0] int_bus, mar_out, rom_out;
    wire mar_inen, mdr_inen, mdr_oen;
    
    shift_register_PIPO_p #(.N(8)) MAR(
        .clk(clk), .reset_p(reset_p),
        .d(int_bus),
        .wr_en(mar_inen), .rd_en(1),
        .register_data(mar_out));
        
    shift_register_PIPO_p #(.N(8)) MDR(
        .clk(clk), .reset_p(reset_p),
        .d(rom_out),
        .wr_en(mdr_inen), .rd_en(mdr_oen),
        .q(int_bus));
        
    wire [7:0] ir_in;
    shift_register_PIPO_p #(.N(8)) IR(
        .clk(clk), .reset_p(reset_p),
        .d(int_bus),
        .wr_en(ir_inen),
        .register_data(ir_in));
    
    wire pc_inc, load_pc, pc_oen;    
    program_address_counter pc(
        .clk(clk), .reset_p(reset_p),
        .pc_inc(pc_inc), .load_pc(load_pc), .pc_rd_en(pc_oen),
        .pc_in(int_bus),
        .pc_out(int_bus)); 
    
    wire acc_high_reset_p, acc_o_en, acc_in_select;
    wire [1:0] acc_high_select_in, acc_low_select;
    wire [3:0] bus_reg_data;
    wire op_add, op_sub, op_mul, op_div, op_and;
    wire zero_flag, sign_flag;
        
    block_alu_acc alu_acc(
        .clk(clk), .reset_p(reset_p), .acc_high_reset_p(acc_high_reset_p),
        .rd_en(acc_o_en), .acc_in_select(acc_in_select),
        .acc_high_select_in(acc_high_select_in), .acc_low_select(acc_low_select),
        .bus_data(int_bus[7:4]), .bus_reg_data(bus_reg_data),
        .op_add(op_add), .op_sub(op_sub), .op_mul(op_mul), .op_div(op_div), .op_and(op_and),
        .zero_flag(zero_flag), .sign_flag(sign_flag),
        .acc_data(int_bus));
    
    wire inreg_oen;
    
    shift_register_PIPO_p #(.N(4)) INREG(
        .clk(clk), .reset_p(reset_p),
        .d(key_value),
        .wr_en(1'b1), .rd_en(inreg_oen),
        .q(int_bus[7:4]));
    
    wire keych_oen;
    shift_register_PIPO_p #(.N(4)) KEYCHREG(
        .clk(clk), .reset_p(reset_p),
        .d({key_valid, key_valid, key_valid, key_valid}),
        .wr_en(1'b1), .rd_en(keych_oen),
        .q(int_bus[7:4]));    
    
    wire keyout_inen;
    shift_register_PIPO_p #(.N(4)) KEYOUTREG(
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]),
        .wr_en(keyout_inen),
        .register_data(kout));    
    
    wire breg_inen;    
    shift_register_PIPO_p #(.N(4)) BREG(
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]),
        .wr_en(breg_inen), 
        .register_data(bus_reg_data));
        
    wire tmpreg_inen, tmpreg_oen;
    shift_register_PIPO_p #(.N(4)) TEMPREG(.clk(clk), .reset_p(reset_p), .d(int_bus[7:4]),
        .wr_en(tmpreg_inen), .rd_en(tmpreg_oen),
        .q(int_bus[7:4]));

    wire creg_inen, creg_oen;
    shift_register_PIPO_p #(.N(4)) CREG(.clk(clk), .reset_p(reset_p), .d(int_bus[7:4]),
        .wr_en(creg_inen), .rd_en(creg_oen),
        .q(int_bus[7:4]));

    wire dreg_inen, dreg_oen;
    shift_register_PIPO_p #(.N(4)) DREG(.clk(clk), .reset_p(reset_p), .d(int_bus[7:4]),
        .wr_en(dreg_inen), .rd_en(dreg_oen),
        .q(int_bus[7:4]));

    wire rreg_inen, rreg_oen;
    shift_register_PIPO_p #(.N(4)) RREG(.clk(clk), .reset_p(reset_p), .d(int_bus[7:4]),
        .wr_en(rreg_inen), .rd_en(rreg_oen),
        .q(int_bus[7:4]));

    wire outreg_inen;
    
    shift_register_PIPO_p #(.N(8)) OUTREG(.clk(clk), .reset_p(reset_p), .d(int_bus),
        .wr_en(outreg_inen),
        .register_data(outreg_data));
       
    control_block cb(
        clk, reset_p,
        ir_in,
        zero_flag, sign_flag,
        mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
        breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen,
        dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
        acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div, 
        outreg_inen, inreg_oen, keych_oen, keyout_inen, rom_en,
        acc_low_select, acc_high_select_in);
        
    dist_mem_gen_0 rom(.a(mar_out), .qspo_ce(rom_en), .spo(rom_out));
        
        
endmodule
