module a7top_mytb();

    // Inputs
    logic clk;

    logic [15:0] SWITCH;

    logic [4:0] push_button;

    // Outputs
    logic AUD_PWM;

    logic AUD_SD;

    logic [15:0] led;

    logic [7:0] an;

    logic [6:0] abcdefg;

    logic [7:0] pmod_a;

    // Internal monitored signals
    logic [9:0] code;

    logic [9:0] dac_count;

    logic next_sample;

    logic [7:0] count_dac_samples;

    // DUT
    a7top TOP (

        .clk(clk),

        .switch(SWITCH),

        .push_button(push_button),

        .aud_pwm(AUD_PWM),

        .aud_sd(AUD_SD),

        .led(led),

        .an(an),

        .abcdefg(abcdefg),

        .pmod_a(pmod_a)

    );

    // Connect internal DUT signals to TB signals
    assign code = TOP.SQ_WAVE_GEN.code;

    assign dac_count = TOP.DAC.count;

    assign next_sample = TOP.next_sample;

    assign count_dac_samples = TOP.SQ_WAVE_GEN.count_dac_samples;

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;

        SWITCH = 16'h0000;

        push_button = 5'b00000;

        // Apply reset
        push_button[0] = 1'b1;

        // Enable audio
        SWITCH[0] = 1'b1;

        // Hold reset
        repeat(5) @(posedge clk);

        // Release reset
        push_button[0] = 1'b0;

        // Run simulation
        #3_000_000;

        $stop;

    end

endmodule