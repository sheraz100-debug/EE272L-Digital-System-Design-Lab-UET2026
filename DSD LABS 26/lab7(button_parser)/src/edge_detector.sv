module edge_detector (
    input  logic clk, rst,
    input  logic signal_in,
    output logic pulse
);

    logic prev;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            prev  <= 0;
            pulse <= 0;
        end else begin
            pulse <= signal_in & ~prev;
            prev  <= signal_in;
        end
    end

endmodule