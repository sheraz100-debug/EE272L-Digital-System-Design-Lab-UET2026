
module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);

    reg [WIDTH-1:0] signal_dly;

    always @(posedge clk) begin
        signal_dly <= signal_in;
    end

    assign edge_detect_pulse = signal_in & ~signal_dly;

endmodule

