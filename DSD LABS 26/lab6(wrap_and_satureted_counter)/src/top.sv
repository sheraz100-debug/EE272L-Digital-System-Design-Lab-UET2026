module top #(parameter N = 4)(
    input  logic clk,
    input  logic reset,
    input  logic mode,
    output logic [N-1:0] leds,
    output logic [6:0] seg,
    output logic [7:0] an
);

    logic slow_clk;
    logic [N-1:0] count_out;

    // Frequency Divider (UNCHANGED)
    freq_divider fd (
        .clk(clk),
        .reset(reset),
        .clk_out(slow_clk)
    );

    // Counter
    counter #(N) cnt (
        .clk(slow_clk),
        .reset(reset),
        .mode(mode),
        .count(count_out)
    );

    // LED output
    assign leds = count_out;

    // 7-segment Decoder (UNCHANGED)
    decoder dec (
        .in(count_out[3:0]),
        .seg(seg),
        .an(an)
    );

endmodule