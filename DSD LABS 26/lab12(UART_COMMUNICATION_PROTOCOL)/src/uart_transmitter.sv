
module uart_transmitter
#(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE  = 115200
)
(
    input  wire       clk,
    input  wire       rst,

    input  wire [7:0] data_in,
    input  wire       data_in_valid,
    output wire       data_in_ready,

    output wire       serial_out
);

    // =====================================================
    // PARAMETERS
    // =====================================================

    localparam SYMBOL_EDGE_TIME =
                CLOCK_FREQ / BAUD_RATE;

    localparam COUNTER_WIDTH =
                $clog2(SYMBOL_EDGE_TIME);

    // =====================================================
    // INTERNAL REGISTERS
    // =====================================================

    reg [9:0] shift_reg;

    reg [COUNTER_WIDTH-1:0] clk_counter;

    reg [3:0] bit_counter;

    reg transmitting;

    // =====================================================
    // CONTROL
    // =====================================================

    wire fire;

    wire symbol_edge;

    assign fire =
            data_in_valid &
            data_in_ready;

    assign symbol_edge =
            (clk_counter == SYMBOL_EDGE_TIME - 1);

    // =====================================================
    // OUTPUTS
    // =====================================================

    assign data_in_ready =
            ~transmitting;

    assign serial_out =
            transmitting ?
            shift_reg[0] :
            1'b1;

    // =====================================================
    // MAIN UART LOGIC
    // =====================================================

    always @(posedge clk or posedge rst) begin

        // =================================================
        // RESET
        // =================================================

        if (rst) begin

            shift_reg    <= 10'b1111111111;

            clk_counter  <= 0;

            bit_counter  <= 0;

            transmitting <= 1'b0;

        end

        // =================================================
        // NORMAL OPERATION
        // =================================================

        else begin

            // =============================================
            // IDLE STATE
            // =============================================

            if (!transmitting) begin

                clk_counter <= 0;

                bit_counter <= 0;

                shift_reg <= 10'b1111111111;

                // START NEW FRAME

                if (fire) begin

                    transmitting <= 1'b1;

                    shift_reg <=
                        {1'b1, data_in, 1'b0};

                end

            end

            // =============================================
            // ACTIVE TRANSMISSION
            // =============================================

            else begin

                // COUNT CLOCKS

                if (!symbol_edge) begin

                    clk_counter <=
                        clk_counter + 1'b1;

                end

                // NEXT UART BIT

                else begin

                    clk_counter <= 0;

                    // STOP AFTER LAST BIT

                    if (bit_counter == 4'd9) begin

                        transmitting <= 1'b0;

                        bit_counter <= 0;

                        shift_reg <=
                            10'b1111111111;

                    end

                    else begin

                        bit_counter <=
                            bit_counter + 1'b1;

                        shift_reg <=
                            {1'b1, shift_reg[9:1]};

                    end

                end

            end

        end

    end

endmodule

