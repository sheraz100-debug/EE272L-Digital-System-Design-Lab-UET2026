module synchronizer (
    input  logic clk, rst,
    input  logic async_signal,
    output logic sync_signal
);
    logic ff1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ff1 <= 0;
            sync_signal <= 0;
        end else begin
            ff1 <= async_signal;
            sync_signal <= ff1;
        end
    end
endmodule