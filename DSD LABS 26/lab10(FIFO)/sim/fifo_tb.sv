`timescale 1ns/1ns

`define CLK_PERIOD 8

module fifo_tb1();

  localparam WIDTH = 32;
  localparam LOGDEPTH = 3;
  localparam DEPTH = (1 << LOGDEPTH);

  // =====================================================
  // CLOCK + RESET
  // =====================================================

  reg clk = 0;
  reg rst = 0;

  always #(`CLK_PERIOD/2) clk <= ~clk;

  // =====================================================
  // TEST DATA
  // =====================================================

  reg [WIDTH-1:0] test_values [0:49];
  reg [WIDTH-1:0] received_values [0:49];

  // =====================================================
  // FIFO INTERFACE
  // =====================================================

  // Write side
  reg wr_en;
  reg [WIDTH-1:0] din;
  wire full;

  // Read side
  reg rd_en;
  wire [WIDTH-1:0] dout;
  wire empty;

  // =====================================================
  // DUT
  // =====================================================

  fifo #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .POINTER_WIDTH(LOGDEPTH)
  ) dut (
    .clk(clk),
    .rst(rst),

    // Write side
    .wr_en(wr_en),
    .din(din),
    .full(full),

    // Read side
    .rd_en(rd_en),
    .dout(dout),
    .empty(empty)
  );

  // =====================================================
  // WRITE TASK
  // =====================================================

  task write_to_fifo;

    input [WIDTH-1:0] write_data;
    input violate_interface;

    begin

      #1;

      if (!violate_interface && full)
        wr_en = 1'b0;
      else
        wr_en = 1'b1;

      din = write_data;

      @(posedge clk);
      #1;

      wr_en = 1'b0;

    end

  endtask

  // =====================================================
  // READ TASK
  // =====================================================

  task read_from_fifo;

    input violate_interface;
    output [WIDTH-1:0] read_data;

    begin

      #1;

      if (!violate_interface && empty)
        rd_en = 1'b0;
      else
        rd_en = 1'b1;

      @(posedge clk);
      #1;

      read_data = dout;

      rd_en = 1'b0;

    end

  endtask

  // =====================================================
  // VARIABLES
  // =====================================================

  integer i;
  integer num_mismatches;

  // =====================================================
  // TESTBENCH
  // =====================================================

  initial begin

    $display("======================================");
    $display("         FIFO TEST START");
    $display("======================================");

    // Generate test data
    for (i = 0; i < 50; i = i + 1) begin
      test_values[i] = i + 1000;
    end

    // Initialize
    wr_en = 0;
    rd_en = 0;
    din   = 0;

    // =================================================
    // RESET
    // =================================================

    rst = 1'b1;

    @(posedge clk);
    #1;

    rst = 1'b0;

    @(posedge clk);
    #1;

    // =================================================
    // CHECK RESET CONDITIONS
    // =================================================

    if (empty !== 1'b1)
      $error("ERROR: FIFO is not empty after reset");

    if (full !== 1'b0)
      $error("ERROR: FIFO is full after reset");

    // =================================================
    // WRITE TEST
    // =================================================

    $display("Writing data into FIFO...");

    for (i = 0; i < DEPTH; i = i + 1) begin

      write_to_fifo(test_values[i], 1'b0);

      @(posedge clk);

    end

    // FIFO should now be full
    if (full !== 1'b1)
      $error("ERROR: FIFO did not become full");

    // =================================================
    // READ TEST
    // =================================================

    $display("Reading data from FIFO...");

    for (i = 0; i < DEPTH; i = i + 1) begin

      read_from_fifo(1'b0, received_values[i]);

      @(posedge clk);

    end

    // FIFO should now be empty
    if (empty !== 1'b1)
      $error("ERROR: FIFO did not become empty");

    // =================================================
    // VERIFY DATA
    // =================================================

    $display("Verifying FIFO data...");

    num_mismatches = 0;

    for (i = 0; i < DEPTH; i = i + 1) begin

      if (test_values[i] !== received_values[i]) begin

        $error(
          "Mismatch at index %0d : Expected = %0d Actual = %0d",
          i,
          test_values[i],
          received_values[i]
        );

        num_mismatches = num_mismatches + 1;

      end
      else begin

        $display(
          "PASS : index = %0d Expected = %0d Actual = %0d",
          i,
          test_values[i],
          received_values[i]
        );

      end

    end

    // =================================================
    // FINAL RESULT
    // =================================================

    if (num_mismatches == 0) begin

      $display("======================================");
      $display("      ALL FIFO TESTS PASSED!");
      $display("======================================");

    end
    else begin

      $display("======================================");
      $display("  %0d FIFO TESTS FAILED", num_mismatches);
      $display("======================================");

    end

    $finish;

  end

endmodule