`timescale 1ns/1ps

module uart_transmitter_tb();
  localparam CLOCK_FREQ   = 100_000_000; // 100MHz clock
  localparam CLOCK_PERIOD = 1_000_000_000 / CLOCK_FREQ; // 10 ns
  localparam BAUD_RATE    = 115_200;
  localparam integer BAUD_PERIOD  = 1_000_000_000 / BAUD_RATE; // 8680.55 ns

  localparam integer SYMBOL_EDGE_TIME = CLOCK_FREQ / BAUD_RATE; // 868
  localparam integer SAMPLE_TIME      = SYMBOL_EDGE_TIME / 2;   // 434

  localparam CHAR0 = 8'h61; // ~ 'a'
  localparam NUM_CHARS = 16;
  localparam INPUT_DELAY = 1000;

  reg clk, rst;
  initial clk = 0;
  always #(CLOCK_PERIOD / 2) clk = ~clk;

  wire [7:0] data_in;
  reg data_in_valid;
  wire data_in_ready;
  wire serial_out;

  // Instantiate the Transmitter Device Under Test (DUT)
  uart_transmitter #(
    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(BAUD_RATE)
  ) DUT (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),             
    .data_in_valid(data_in_valid), 
    .data_in_ready(data_in_ready), 
    .serial_out(serial_out)        
  );

  // =========================================================================
  // TOP-LEVEL WAVEFORM EXPOSURE TRACKING LOGIC
  // =========================================================================
  // These signals mirror the internal state machine counters so they are 
  // automatically pulled straight into your standard top-level wave window.

  reg [31:0] tb_clk_counter;
  reg [3:0]  tb_bit_counter;
  
  wire tb_symbol_edge;
  wire tb_sample_time;

  // Combined logic tracking the exact symbol clock division and bit indexing
  always @(posedge clk) begin
    if (rst) begin
      tb_clk_counter <= 0;
      tb_bit_counter <= 0;
    end else if (DUT.transmitting) begin
      // Inside active transmission frames
      if (tb_clk_counter == SYMBOL_EDGE_TIME - 1) begin
        tb_clk_counter <= 0;
        if (tb_bit_counter == 4'd9) begin
          tb_bit_counter <= 0;
        end else begin
          tb_bit_counter <= tb_bit_counter + 1;
        end
      end else begin
        tb_clk_counter <= tb_clk_counter + 1;
      end
    end else begin
      // Idle state behavior
      tb_clk_counter <= 0;
      tb_bit_counter <= 0;
    end
  end

  // Exposing the key strobe events to your top-level view
  assign tb_symbol_edge = (DUT.transmitting) && (tb_clk_counter == SYMBOL_EDGE_TIME - 1);
  assign tb_sample_time = (DUT.transmitting) && (tb_clk_counter == SAMPLE_TIME - 1);

  // =========================================================================
  // AUTOMATIC WAVEFORM BACKEND ENABLER
  // =========================================================================
  initial begin
    $dumpfile("uart_sim_waves.vcd");
    $dumpvars(0, uart_transmitter_tb);
  end

  // =========================================================================
  // ARRAYS & DATA STIMULUS
  // =========================================================================
  integer i, j, c;
  reg [10-1:0] chars_to_host [NUM_CHARS-1:0];
  reg [7:0] chars_from_data_in [NUM_CHARS-1:0];

  initial begin
    #0;
    for (c = 0; c < NUM_CHARS; c = c + 1) begin
      chars_from_data_in[c] = CHAR0 + c;
    end
  end

  reg [31:0] cnt;
  assign data_in = chars_from_data_in[cnt];
  reg data_in_fired;

  always @(posedge clk) begin
    if (rst) begin
      cnt <= 0;
    end
    else begin
      if (data_in_fired === 1'b1) begin
        data_in_fired <= 1'b0;
        if (data_in_ready === 1'b1) begin
          $error("[time %t] Failed: data_in_ready should go LOW in the next clock edge after firing data_in\n", $time);
        end
      end
      else if (data_in_valid === 1'b1 && data_in_ready === 1'b1) begin
        data_in_fired <= 1'b1;
        cnt <= cnt + 1;
        $display("[time %t] [data_in] Sent char: 8'h%h (=%s)", $time, data_in, data_in);
      end
    end
  end

  // Handshake interface generation
  initial begin
    data_in_valid = 1'b0;
    repeat (10) @(posedge clk);

    for (j = 0; j < NUM_CHARS; j = j + 1) begin
      wait (data_in_ready === 1'b1);
      #(INPUT_DELAY);
      @(negedge clk);
      data_in_valid = 1'b1;
      @(negedge clk);
      data_in_valid = 1'b0; 
    end
  end

  integer num_mismatches = 0;

  // Validation checking loop
  initial begin
    #0;
    rst = 1'b1;
    cnt = 0;

    repeat (10) @(posedge clk);
    @(negedge clk);
    rst = 1'b0;

    if (data_in_ready === 1'b0) begin
      $error("[time %t] Failed: data_in_ready should not be LOW after reset", $time);
      repeat (5) @(posedge clk);
      $fatal();
    end

    if (serial_out !== 1) begin
      $error("[time %t] Failed: serial_out should stay HIGH if there is no data_in to receive by handshake!", $time);
      repeat (5) @(posedge clk);
      $fatal();
    end

    repeat (100) @(posedge clk);

    for (c = 0; c < NUM_CHARS; c = c + 1) begin
      wait (serial_out === 1'b0); // Wait for Start Bit edge

      for (i = 0; i < 10; i = i + 1) begin
        #(BAUD_PERIOD / 2);
        chars_to_host[c][i] = serial_out;
        #(BAUD_PERIOD / 2);
      end
      $display("[time %t] [serial_out] Got char: start_bit=%b, payload=8'h%h (=%s), stop_bit=%b",
               $time, chars_to_host[c][0], chars_to_host[c][8:1], chars_to_host[c][8:1], chars_to_host[c][9]);
    end

    repeat (10) @(posedge clk);

    for (c = 0; c < NUM_CHARS; c = c + 1) begin
      if (chars_from_data_in[c] !== chars_to_host[c][8:1]) begin
        $display("Matching HOST DATA and DATA sent");
        $error("Mismatches at char %d: char_to_host=%h (=%s), char_from_data_in=%h (=%s)",
                 c, chars_to_host[c][8:1], chars_to_host[c][8:1], chars_from_data_in[c], chars_from_data_in[c]);
        num_mismatches = num_mismatches + 1;
      end

      if (chars_to_host[c][0] !== 0)
        $error("[char #%d] Failed: Start bit is expected to be LOW!", c);
      if (chars_to_host[c][9] !== 1)
        $error("[char #%d] Failed: End bit is expected to HIGH!", c);
    end

    if (num_mismatches > 0)
      $display("Tests failed!");
    else
      $display("Tests passed!");

    #100;
    $finish();
  end

  // Fail-safe Timeout simulation termination
  initial begin
    #((BAUD_PERIOD * 10 + INPUT_DELAY) * (NUM_CHARS) + 5000);
    $error("Timeout!");
    $fatal();
  end

endmodule