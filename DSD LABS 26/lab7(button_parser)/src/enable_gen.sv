module enable_gen (
    input  logic clk,
    input  logic sync_signal,
    output logic enable
);

    logic prev;

    always_ff @(posedge clk) begin
        prev <= sync_signal;
    end

    assign enable = (sync_signal == prev);

endmodule