// =======================================================================
// Module Name: clk_divider
// Description: Divides 100MHz master clock down for Human Visibility & Displays
// =======================================================================
module clk_divider (
    input  logic clk_100MHz,
    input  logic rst_n,
    output logic clk_slow,     // ~1 Hz clock for FSM state transitions
    output logic clk_refresh   // ~1 kHz clock for 7-segment dynamic switching
);

    logic [25:0] slow_count;
    logic [16:0] refresh_count;

    always_ff @(posedge clk_100MHz or negedge rst_n) begin
        if (!rst_n) begin
            slow_count    <= '0;
            refresh_count <= '0;
            clk_slow      <= 1'b0;
            clk_refresh   <= 1'b0;
        end else begin
            // Generate ~1 Hz Execution Clock (Count up to 50,000,000 half-period)
            if (slow_count >= 26'd49_999_999) begin
                slow_count <= '0;
                clk_slow   <= ~clk_slow;
            end else begin
                slow_count <= slow_count + 1'b1;
            end

            // Generate ~1.5 kHz Display Refresh Clock (Count up to 33,333)
            if (refresh_count >= 16'd33_332) begin
                refresh_count <= '0;
                clk_refresh   <= ~clk_refresh;
            end else begin
                refresh_count <= refresh_count + 1'b1;
            end
        end
    end

endmodule