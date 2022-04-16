module input_test();
    logic clk;

    always(@posedge clk)
        #10 clock <= ~clk;



    cmd_parser uut(

    );
endmodule