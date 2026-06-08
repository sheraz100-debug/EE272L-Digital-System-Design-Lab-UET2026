
module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
)(
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output reg [WIDTH-1:0] debounced_signal
);

    reg [WRAPPING_CNT_WIDTH-1:0] sample_counter = 0;
    reg [SAT_CNT_WIDTH-1:0] saturating_counter [0:WIDTH-1];

    integer i;

    initial begin
        debounced_signal = 0;
        for(i=0;i<WIDTH;i=i+1)
            saturating_counter[i] = 0;
    end

    always @(posedge clk) begin

        if(sample_counter == SAMPLE_CNT_MAX-1) begin

            sample_counter <= 0;

            for(i=0;i<WIDTH;i=i+1) begin

                if(glitchy_signal[i]) begin

                    if(saturating_counter[i] < PULSE_CNT_MAX)
                        saturating_counter[i] <= saturating_counter[i] + 1'b1;

                end
                else begin

                    if(saturating_counter[i] > 0)
                        saturating_counter[i] <= saturating_counter[i] - 1'b1;

                end

                if(saturating_counter[i] == PULSE_CNT_MAX)
                    debounced_signal[i] <= 1'b1;
                else if(saturating_counter[i] == 0)
                    debounced_signal[i] <= 1'b0;

            end

        end
        else begin
            sample_counter <= sample_counter + 1'b1;
        end

    end

endmodule

