module top_adder_decoder(
    input  logic [2:0] a,    // SW2, SW1, SW0
    input  logic [2:0] b,    // SW5, SW4, SW3
    input  logic [2:0] sel,  // Selection for which display (AN0-AN7)
    input  logic       c_in, // SW6
    output logic [6:0] seg,  // Segment outputs (Cathodes)
    output logic [7:0] an    // Display selection (Anodes)
);

    logic [2:0] internal_sum;
    logic internal_cout;
    logic [3:0] combined_res;

    // Instantiate your 3-bit Ripple Carry Adder
    ripple_carry my_adder (
        .a(a), 
        .b(b), 
        .cin(c_in), 
        .sum(internal_sum), 
        .cout(internal_cout)
    );

    // Group the carry-out and sum into a 4-bit Hex value
    assign combined_res = {internal_cout, internal_sum};

    // Instantiate the Decoder module (defined below in this same file)
    decoder my_display (
        .x(combined_res),
        .sel(sel),
        .seg(seg),
        .an(an)
    );

endmodule

// 2. DECODER MODULE: The Wrapper for the two sub-decoders
module decoder(
    input  logic [3:0] x,
    input  logic [2:0] sel,
    output logic [6:0] seg,
    output logic [7:0] an
);
    // Connect the sub-modules defined below
    hex_to_7seg SEG_UNIT (.x(x), .seg(seg));
    anode_logic AN_UNIT  (.sel(sel), .an(an));
endmodule

// 3. SUB-DECODER: Hexadecimal to 7-Segment (Active-Low)
module hex_to_7seg(
    input  logic [3:0] x,
    output logic [6:0] seg
);
    always_comb begin
        case(x)
            // Segments: abc_defg (0 = ON, 1 = OFF)
            4'h0: seg = 7'b0000001;
            4'h1: seg = 7'b1001111;
            4'h2: seg = 7'b0010010;
            4'h3: seg = 7'b0000110;
            4'h4: seg = 7'b1001100;
            4'h5: seg = 7'b0100100;
            4'h6: seg = 7'b0100000;
            4'h7: seg = 7'b0001111;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0000100;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b1100000;
            4'hC: seg = 7'b0110001;
            4'hD: seg = 7'b1000010;
            4'hE: seg = 7'b0110000;
            4'hF: seg = 7'b0111000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule

// 4. SUB-DECODER: Anode Selection Logic (Active-Low)
module anode_logic(
    input  logic [2:0] sel,
    output logic [7:0] an
);
    always_comb begin
        an = 8'b11111111; // Default: all digits OFF
        an[sel] = 1'b0;   // Turn ON the selected digit
    end
endmodule