module btn_parser_tb();

    logic clk;
    logic rst;
    logic async_signal;

    logic sync_signal;
    logic [1:0] count_wrap;
    logic ENABLE;
    logic [1:0] count_sat;
    logic deb_out;
    logic edge_detect_pulse;

    // DUT
    button_parser DUT (
        .clk(clk),
        .rst(rst),
        .async_signal(async_signal),
        .sync_signal(sync_signal),
        .count_wrap(count_wrap),
        .ENABLE(ENABLE),
        .count_sat(count_sat),
        .deb_out(deb_out),
        .edge_detect_pulse(edge_detect_pulse)
    );

    // clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        async_signal = 0;

        #20;
        rst = 0;

        // Simulate button bounce (IMPORTANT)
        #20 async_signal = 1;
        #10 async_signal = 0;
        #10 async_signal = 1;
        #10 async_signal = 0;
        #10 async_signal = 1;  // finally stable

        #200;

        // Release button (with bounce)
        async_signal = 0;
        #10 async_signal = 1;
        #10 async_signal = 0;
        #10 async_signal = 1;
        #10 async_signal = 0;

        #200;
        $stop;
    end

endmodule