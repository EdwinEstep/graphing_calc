module input_test;
    logic clk;

    always@(posedge clk)
        #10 clk <= ~clk;



    cmd_parser uut(
        .clk(clk),
        .srst(srst),
        .rx_dv(rx_dv),
        .rx_byte(byte),
        .dec_out(dec_out),
        .stack_wr_data(wr_data),
        .stack_wr_en(wr_en),
        .opcode(opcode)
    );
endmodule