`timescale 1ns/1ps

`define CLOCK_PERIOD 10          // 10ns period = 100MHz clock
`define CLOCK_FREQ 100_000_000   // Calibrated to your physical FPGA clock
`define BAUD_RATE 115_200

/*
    In this testbench, we instantiate 2 UARTs. They are connected via the serial lines (FPGA_SERIAL_RX/TX).
    Our testbench is given access to the 1st UART's transmitter's ready/valid interface and the 2nd UART's
    receiver's ready/valid interface. The testbench then directs the transmitter to send a character and then
    waits for the receiver to acknowlege that data has been sent to it. It then reads the data from the receiver
    and compares it to what was transmitted.
*/
module uart2uart_tb();
    // Generate 100 MHz clock
    reg clk = 0;
    always #(`CLOCK_PERIOD/2) clk = ~clk;

    // I/O of off-chip and on-chip UART
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;
    reg reset;

    reg [7:0] data_in;
    reg data_in_valid;
    wire data_in_ready;

    wire [7:0] data_out;
    wire data_out_valid;
    reg data_out_ready;

    uart # (
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE)
    ) off_chip_uart (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(), // We aren't using the receiver of the off-chip UART, only the transmitter
        .data_out_valid(),
        .data_out_ready(1'b0),
        .serial_in(FPGA_SERIAL_RX),
        .serial_out(FPGA_SERIAL_TX)
    );

    uart # (
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE)
    ) on_chip_uart (
        .clk(clk),
        .reset(reset),
        .data_in(8'd0), // We aren't using the transmitter of the on-chip UART, only the receiver
        .data_in_valid(1'b0),
        .data_in_ready(),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_TX), // Notice these lines are connected opposite to the off_chip_uart
        .serial_out(FPGA_SERIAL_RX)
    );

    // =========================================================================
    // LOCALIZED TIMING LOGIC (BYPASSES INTERNAL OPTIMIZATION BLOCKS)
    // =========================================================================
    // 100,000,000 / 115,200 = 868 cycles per bit. 
    // Mid-bit sample point is at 868 / 2 = 434 cycles.
    localparam integer BIT_WINDOW_CYCLES = `CLOCK_FREQ / `BAUD_RATE; // 868
    localparam integer MID_SAMPLE_CYCLES = BIT_WINDOW_CYCLES / 2;    // 434

    reg [31:0] tb_tx_clk_counter;
    reg [3:0]  tb_tx_bit_counter;
    wire       tb_symbol_edge;
    wire       tb_sample_time;

    // Track TX serial baud timing locally via interface handshake observation
    reg tx_active;
    always @(posedge clk) begin
        if (reset) begin
            tx_active           <= 1'b0;
            tb_tx_clk_counter   <= 0;
            tb_tx_bit_counter   <= 0;
        end else begin
            if (data_in_valid && data_in_ready) begin
                tx_active           <= 1'b1;
                tb_tx_clk_counter   <= 0;
                tb_tx_bit_counter   <= 0;
            end else if (tx_active) begin
                if (tb_tx_clk_counter == BIT_WINDOW_CYCLES - 1) begin
                    tb_tx_clk_counter <= 0;
                    if (tb_tx_bit_counter == 4'd9) begin
                        tx_active <= 1'b0; // Transmission frame completed
                    end else begin
                        tb_tx_bit_counter <= tb_tx_bit_counter + 1;
                    end
                end else begin
                    tb_tx_clk_counter <= tb_tx_clk_counter + 1;
                end
            end
        end
    end

    // Expose exact strobe events straight onto your main wave timeline panel
    assign tb_symbol_edge = tx_active && (tb_tx_clk_counter == BIT_WINDOW_CYCLES - 1);
    assign tb_sample_time = tx_active && (tb_tx_clk_counter == MID_SAMPLE_CYCLES - 1);

    // Automatic wave logging execution
    initial begin
        $dumpfile("uart2uart_waves.vcd");
        $dumpvars(0, uart2uart_tb);
    end
    // =========================================================================

    reg done = 0;
    initial begin
        reset = 1'b0;
        data_in = 8'd0;
        data_in_valid = 1'b0;
        data_out_ready = 1'b0;
        repeat (2) @(posedge clk); #1;

        // Reset the UARTs
        reset = 1'b1;
        @(posedge clk); #1;
        reset = 1'b0;

        fork
            begin
                // Wait until the off_chip_uart's transmitter is ready
                while (data_in_ready == 1'b0) @(posedge clk); #1;

                // Send a character to the off chip UART's transmitter to transmit over the serial line
                data_in = 8'h55;
                data_in_valid = 1'b1;
                @(posedge clk); #1;
                data_in_valid = 1'b0;

                // Now, the transmitter should be sending the data_in over the FPGA_SERIAL_TX line to the on chip UART

                // We wait until the on chip UART's receiver indicates that is has valid data it has received
                while (data_out_valid == 1'b0) @(posedge clk); #1;

                // Now, data_out of the on chip UART should contain the data that was sent to it by the off chip UART
                if (data_out !== 8'h55) begin
                    $error("Failure 1: on chip UART got data: %h, but expected: %h", data_out, 8'h55);
                end

                // If we wait a few more clock cycles, the data should still be held by the receiver
                repeat (10) @(posedge clk); #1;
                if (data_out !== 8'h55) begin
                    $error("Failure 2: on chip UART got correct data, but it didn't hold data_out until data_out_ready was asserted");
                end

                // At this point, the off chip UART's transmitter should be idle and the FPGA_SERIAL_TX line should be in the idle state
                if (FPGA_SERIAL_TX !== 1'b1) begin
                    $error("Failure 3: FPGA_SERIAL_TX was not high when the off chip UART's transmitter should be idle");
                end

                // Now, if we assert data_out_ready to the on chip UART's receiver, it should pull its data_out_valid signal low
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;
                @(posedge clk); #1;
                if (data_out_valid == 1'b1) begin
                    $error("Failure 4: on chip UART didn't clear data_out_valid when data_out_ready was asserted");
                end
                done = 1;
            end
            begin
                repeat (25000) @(posedge clk);
                if (!done) begin
                    $error("Failure: timing out");
                    $fatal();
                end
            end
        join

        repeat (20) @(posedge clk);
        $display("Test finished");
        $finish();
    end
endmodule