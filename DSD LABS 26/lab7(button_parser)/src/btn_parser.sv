module button_parser (
    input  logic clk, rst,
    input  logic async_signal,

    output logic sync_signal,
    output logic [1:0] count_wrap,
    output logic ENABLE,
    output logic [1:0] count_sat,
    output logic deb_out,
    output logic edge_detect_pulse
);

    // 1) Synchronizer
    synchronizer SYNC (
        .clk(clk),
        .rst(rst),
        .async_signal(async_signal),
        .sync_signal(sync_signal)
    );

    // 2) Wrap counter
    wrap_counter WC (
        .clk(clk),
        .rst(rst),
        .count_wrap(count_wrap)
    );

    // 3) ENABLE pulse (matches expected waveform)
    assign ENABLE = (count_wrap == 2'd3);

    // 4) Saturated counter
    sat_counter SAT (
        .clk(clk),
        .rst(rst),
        .enable(ENABLE),
        .in_signal(sync_signal),
        .count_sat(count_sat)
    );

    // 5) Debounced output
    assign deb_out = (count_sat == 2'd3);

    // 6) Edge detector
    edge_detector ED (
        .clk(clk),
        .rst(rst),
        .signal_in(deb_out),
        .pulse(edge_detect_pulse)
    );

endmodule