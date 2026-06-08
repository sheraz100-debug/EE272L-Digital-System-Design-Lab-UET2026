// =======================================================================
// Module Name: seven_seg_mux
// Description: Multi-digit 7-segment driver array (Hexadecimal converter)
// =======================================================================
module seven_seg_mux (
    input  logic        clk_refresh, // ~1kHz display clock
    input  logic        rst_n,
    input  logic [15:0] data_in,     // 16-bit binary data slice to display
    output logic [3:0]  anode,       // Digit selection drivers (Active Low)
    output logic [6:0]  cathode      // Segment line patterns (Active Low: a-g)
);

    logic [1:0]  digit_select;
    logic [3:0]  hex_nibble;

    // Step through digits continuously
    always_ff @(posedge clk_refresh or negedge rst_n) begin
        if (!rst_n) begin
            digit_select <= '0;
        end else begin
            digit_select <= digit_select + 1'b1;
        end
    end

    // Anode Active-Low routing framework
    always_comb begin
        case (digit_select)
            2'b00: begin anode = 4'b1110; hex_nibble = data_in[3:0];   end // Digit 0
            2'b01: begin anode = 4'b1101; hex_nibble = data_in[7:4];   end // Digit 1
            2'b10: begin anode = 4'b1011; hex_nibble = data_in[11:8];  end // Digit 2
            2'b11: begin anode = 4'b0111; hex_nibble = data_in[15:12]; end // Digit 3
            default: begin anode = 4'b1111; hex_nibble = 4'h0;         end
        endcase
    end

    // Hex-to-7-Segment Cathode lookup decoder map (Active-Low logic)
    always_comb begin
        case (hex_nibble)
            4'h0: cathode = 7'b1000000; // 0
            4'h1: cathode = 7'b1111001; // 1
            4'h2: cathode = 7'b0100100; // 2
            4'h3: cathode = 7'b0110000; // 3
            4'h4: cathode = 7'b0011001; // 4
            4'h5: cathode = 7'b0010010; // 5
            4'h6: cathode = 7'b0000010; // 6
            4'h7: cathode = 7'b1111000; // 7
            4'h8: cathode = 7'b0000000; // 8
            4'h9: cathode = 7'b0010000; // 9
            4'hA: cathode = 7'b0001000; // A
            4'hB: cathode = 7'b0000011; // b
            4'hC: cathode = 7'b1000110; // C
            4'hD: cathode = 7'b0100001; // d
            4'hE: cathode = 7'b0000110; // E
            4'hF: cathode = 7'b0001110; // F
            default: cathode = 7'b1111111; // All OFF
        endcase
    end

endmodule