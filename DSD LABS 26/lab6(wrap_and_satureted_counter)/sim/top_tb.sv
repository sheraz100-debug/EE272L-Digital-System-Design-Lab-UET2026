module top_tb;

    parameter N = 4;

    logic clk;
    logic reset;
    logic mode;
    logic [N-1:0] leds;
    logic [6:0] seg;
    logic [7:0] an;

    // DUT
    top #(N) uut (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .leds(leds),
        .seg(seg),
        .an(an)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        mode = 0;

        #20;
        reset = 0;

        // Wrap mode
        #500;

        // Switch to saturated mode
        mode = 1;

        #500;

        $stop;
    end

endmodule