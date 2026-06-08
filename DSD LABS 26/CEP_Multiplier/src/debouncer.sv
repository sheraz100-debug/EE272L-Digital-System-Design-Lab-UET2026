// =======================================================================
// Module Name: debouncer
// Description: Filters mechanical contact noise from physical pushbuttons
// =======================================================================
module debouncer (
    input  logic clk_100MHz,
    input  logic rst_n,
    input  logic btn_in,
    output logic btn_clean
);

    // 5ms delay at 100MHz requires a 19-bit counter (up to 500,000)
    logic [18:0] count;
    logic        sync_0, sync_1;
    logic        state_reg;

    // Double-flop stage to eliminate metastability risks
    always_ff @(posedge clk_100MHz or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= btn_in;
            sync_1 <= sync_0;
        end
    end

    always_ff @(posedge clk_100MHz or negedge rst_n) begin
        if (!rst_n) begin
            count     <= '0;
            state_reg <= 1'b0;
        end else begin
            if (sync_1 != state_reg) begin
                count <= count + 1'b1;
                if (count >= 19'd499_999) begin
                    state_reg <= sync_1;
                    count     <= '0;
                end
            end else begin
                count <= '0;
            end
        end
    end

    assign btn_clean = state_reg;

endmodule