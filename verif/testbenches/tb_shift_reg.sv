`timescale 1ns/100ps

module tb_shift_reg();
    logic clk = 1'b0;
    always #10 clk = ~clk;

    localparam WIDTH = 4;
    localparam LENGTH = 10;

    // data signals
    logic [WIDTH-1:0] data;
    logic [WIDTH*LENGTH-1:0] q_out;

    // ctrl signals
    logic srst, rdy;
    logic [1:0] ctrl;


    initial begin
        srst = 1;
        data = '0;

        #20
        srst = 0;        
        ctrl = 2'b01;
    end

    always@(posedge clk) begin
        if(!srst) begin
            if(rdy) begin
                if(data < LENGTH)
                    data <= data + 1;
                else
                    ctrl <= 2'b00;
            end
        end
    end


    // representative of digit array
    shift_reg #(
        .WIDTH(WIDTH),
        .LENGTH(LENGTH)
    ) uut (
        .clk(clk),
        .srst(srst),
        .ctrl(ctrl),
        .shift_in(data),
        .rdy(rdy),
        .q_out(q_out)
    );

endmodule
