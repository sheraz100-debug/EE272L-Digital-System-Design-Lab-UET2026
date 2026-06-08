// =======================================================================
// Module Name: radix4_multiplier
// Description: Parameterized Sequential Radix-4 Booth Multiplier
// =======================================================================
module radix4_multiplier #(
    parameter N = 6 // Parameterized bit-width
)(
    input  logic                 clk,     // Slowed-down system clock
    input  logic                 rst_n,   // Active-low asynchronous reset
    input  logic                 start,   // Debounced start trigger
    input  logic signed [N-1:0]  X,       // Multiplier input
    input  logic signed [N-1:0]  Y,       // Multiplicand input
    output logic signed [2*N-1:0] P,       // 2N-bit Output Product Register
    output logic                 done,    // Execution completion flag
    output logic [1:0]           state_led // Exposes internal state to physical LEDs
);

    // FSM State Encoding using SystemVerilog Strong Enums
    typedef enum logic [1:0] {
        ST_IDLE  = 2'b00,
        ST_LOAD  = 2'b01,
        ST_CALC  = 2'b10,
        ST_DONE  = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Internal Registers for Datapath
    logic signed [2*N-1:0] accum;
    logic signed [2*N-1:0] multiplicand_reg;
    logic        [N:0]     multiplier_reg; // Pad extra bit for X_{-1} overlap
    logic        [$clog2(N/2):0] count;    // Loop counter

    // Booth Recoding Signal Paths
    logic signed [2*N-1:0] partial_prod;
    logic [2:0]            booth_window;

    // Slice the lowest remaining 2 bits plus the previous overlap bit
    assign booth_window = multiplier_reg[2:0];

    // Combinational Radix-4 Product Selection Logic (No built-in multipliers)
    always_comb begin
        unique case (booth_window)
            3'b000, 3'b111: partial_prod = '0;
            3'b001, 3'b010: partial_prod = multiplicand_reg;
            3'b011:         partial_prod = multiplicand_reg << 1;
            3'b100:         partial_prod = -(multiplicand_reg << 1);
            3'b101, 3'b110: partial_prod = -multiplicand_reg;
            default:        partial_prod = '0;
        endcase
    end

    // Sequential State Transition and Register Control Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state    <= ST_IDLE;
            accum            <= '0;
            multiplicand_reg <= '0;
            multiplier_reg   <= '0;
            count            <= '0;
        end else begin
            current_state <= next_state;

            case (current_state)
                ST_IDLE: begin
                    count <= '0;
                end

                ST_LOAD: begin
                    accum            <= '0;
                    multiplicand_reg <= {{(N){Y[N-1]}}, Y}; // Sign-extend to 2N track
                    multiplier_reg   <= {X, 1'b0};          // Insert implicit X_{-1} = 0
                    count            <= '0;
                end

                ST_CALC: begin
                    accum            <= accum + partial_prod;
                    multiplicand_reg <= multiplicand_reg << 2; // Step up base-4 significance
                    multiplier_reg   <= multiplier_reg >> 2;   // Drop processed bit pair
                    count            <= count + 1'b1;
                end

                ST_DONE: begin
                    // Maintain stable output lines
                end
            endcase
        end
    end

    // Next-State Logic Block
    always_comb begin
        next_state = current_state;
        case (current_state)
            ST_IDLE: if (start) next_state = ST_LOAD;
            ST_LOAD: next_state = ST_CALC;
            // Loop finishes dynamically after exactly N/2 iterations
            ST_CALC: if (count == (N/2) - 1) next_state = ST_DONE;
            ST_DONE: next_state = ST_IDLE;
            default: next_state = ST_IDLE;
        endcase
    end

    // Hardware Interface Assignments
    assign P         = accum;
    assign done      = (current_state == ST_DONE);
    assign state_led = current_state;

endmodule