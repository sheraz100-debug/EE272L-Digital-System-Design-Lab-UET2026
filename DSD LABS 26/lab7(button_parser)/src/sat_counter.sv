module sat_counter #(
    parameter N = 2
)(
    input  logic clk, rst,
    input  logic enable,
    input  logic in_signal,
    output logic [N-1:0] count_sat
);

    logic in_signal_d;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count_sat   <= 0;
            in_signal_d <= 0;
        end else begin
            in_signal_d <= in_signal;

            if (enable) begin
                if (in_signal_d) begin
                    // increment until max
                    if (count_sat != {N{1'b1}})
                        count_sat <= count_sat + 1;
                end else begin
                    // 🔥 reset immediately (NOT decrement)
                    count_sat <= 0;
                end
            end
        end
    end

endmodule