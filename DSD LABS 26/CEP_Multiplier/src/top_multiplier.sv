// =======================================================================
// Module Name: top_multiplier
// Description: Unified Top-Level Integration Wrapper Module for Synthesis
// =======================================================================
module top_multiplier (
    input  logic        clk,          // 100 MHz onboard master oscillator pin
    input  logic        btn_rst,      // Hardware reset pushbutton 
    input  logic        btn_start,    // Hardware start computation pushbutton
    input  logic [5:0]  sw_X,         // 6-Bit Multiplier Input Switches
    input  logic [5:0]  sw_Y,         // 6-Bit Multiplicand Input Switches
    output logic        led_done,     // LED indicating calculation complete
    output logic [1:0]  led_state,    // LEDs displaying the active FSM state
    output logic [3:0]  anode,        // Physical 7-Segment Anode control lines
    output logic [6:0]  cathode       // Physical 7-Segment Cathode segment lines
);

    // Active-Low Reset Routing
    logic rst_n;
    assign rst_n = ~btn_rst; 

    // Interconnect wires
    logic clk_slow;
    logic clk_refresh;
    logic start_debounced;
    logic signed [11:0] product_out;

    // 1. Clock Divider Instance
    clk_divider clk_gen (
        .clk_100MHz(clk),
        .rst_n(rst_n),
        .clk_slow(clk_slow),
        .clk_refresh(clk_refresh)
    );

    // 2. Start Button Debouncer Instance
    debouncer start_filter (
        .clk_100MHz(clk),
        .rst_n(rst_n),
        .btn_in(btn_start),
        .btn_clean(start_debounced)
    );

    // 3. Core Radix-4 Booth Multiplier Instance (Fixed to N=6)
    radix4_multiplier #(.N(6)) core_multiplier (
        .clk(clk_slow),  // Drives the FSM using the human-visible slow clock
        .rst_n(rst_n),
        .start(start_debounced),
        .X(sw_X),
        .Y(sw_Y),
        .P(product_out),
        .done(led_done),
        .state_led(led_state)
    );

    // 4. 7-Segment Display Driver Array Instance
    // Zero-pad the 12-bit signed product output safely to fit the 16-bit display frame
    seven_seg_mux display_driver (
        .clk_refresh(clk_refresh),
        .rst_n(rst_n),
        .data_in({ {4{product_out[11]}}, product_out }), 
        .anode(anode),
        .cathode(cathode)
    );

endmodule