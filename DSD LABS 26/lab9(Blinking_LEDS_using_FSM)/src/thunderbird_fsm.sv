module thunderbird_fsm (
    input clk,          // Connect to the 100MHz crystal on your board
    input reset,          // Connect to a switch or button
    input left,         // Left turn signal switch
    input right,        // Right turn signal switch
    output reg la, lb, lc, // Left LEDs
    output reg ra, rb, rc  // Right LEDs
);

    // --- Clock Divider ---
    // A 27-bit counter can divide a 100MHz clock down to ~0.75 Hz
    reg [26:0] counter;
    wire slow_clk;

    always @(posedge clk) begin
        if (reset) 
            counter <= 0;
        else 
            counter <= counter + 1;
    end

    // Use a high-order bit as the "slow" clock for the state machine
    assign slow_clk = counter[25]; 

    // --- FSM State Definitions ---
    typedef enum reg [3:0] {
        IDLE  = 4'b0000,
        L1    = 4'b0001, L2 = 4'b0010, L3 = 4'b0011,
        R1    = 4'b0100, R2 = 4'b0101, R3 = 4'b0110,
        HAZ   = 4'b0111
    } state_t;

    state_t current_state, next_state;

    // --- State Transition Logic (Sequential) ---
    always @(posedge slow_clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // --- Next State Logic (Combinational) ---
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (left && right) next_state = HAZ;
                else if (left)     next_state = L1;
                else if (right)    next_state = R1;
                else               next_state = IDLE;
            end
            // Left Sequence
            L1:   next_state = L2;
            L2:   next_state = L3;
            L3:   next_state = IDLE;
            // Right Sequence
            R1:   next_state = R2;
            R2:   next_state = R3;
            R3:   next_state = IDLE;
            // Hazard
            HAZ:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // --- Output Logic ---
    always @(*) begin
        // Default: all LEDs off
        {la, lb, lc, ra, rb, rc} = 6'b000_000;
        case (current_state)
            L1:   {la} = 1;
            L2:   {la, lb} = 2'b11;
            L3:   {la, lb, lc} = 3'b111;
            R1:   {ra} = 1;
            R2:   {ra, rb} = 2'b11;
            R3:   {ra, rb, rc} = 3'b111;
            HAZ:  {la, lb, lc, ra, rb, rc} = 6'b111_111;
            default: ; // IDLE state stays off
        endcase
    end

endmodule