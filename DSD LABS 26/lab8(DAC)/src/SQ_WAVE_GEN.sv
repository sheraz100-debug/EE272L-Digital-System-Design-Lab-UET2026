module SQ_WAVE_GEN(

    input  logic        clk,

    input  logic        rst,

    input  logic        next_sample,

    output logic [9:0]  code,

    output logic [7:0] count_dac_samples

);

    logic state;

    // For 100 MHz clock
    localparam HALF_PERIOD = 11'd111;

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            count_dac_samples <= 0;

            state <= 0;

            code <= 10'd462;

        end
        else begin

            if (next_sample) begin

                if (count_dac_samples == HALF_PERIOD - 1) begin

                    count_dac_samples <= 0;

                    state <= ~state;

                    if (state)
                        code <= 10'd462;
                    else
                        code <= 10'd562;

                end
                else begin

                    count_dac_samples <= count_dac_samples + 1;

                end

            end

        end

    end

endmodule