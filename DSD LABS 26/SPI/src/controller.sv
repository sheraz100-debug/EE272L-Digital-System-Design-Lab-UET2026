module controller_SPI(
    input logic clk,
    input logic rst,
    input logic serial_in,
    input logic [1:0] down_count,
    output logic shift_enable, data_ready , counter_enable
);
typedef enum logic[1:0]{
    WAIT,LOAD,DONE
}state_t;
state_t present_state,next_state;
//memory for present_state
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        present_state <= WAIT;
    end
    else begin
        present_state <= next_state;
    end
end
// combinational block for next_state
always_comb begin
    next_state = present_state;
    case(present_state)
    WAIT:
    begin
        if (serial_in) begin
            next_state = WAIT;
        end
        else begin
            next_state = LOAD;
        end
    end
    LOAD:
    begin
        if (down_count==0) begin
            next_state = DONE;
            
        end
        else begin
            next_state = LOAD;
        end
    end
    DONE:
    begin
        next_state = WAIT;
    end
    default:
    begin
        next_state = WAIT;
    end
    endcase
end
//combinational block for output
always_comb begin
//always initialize output first
    shift_enable = 0;
    counter_enable = 0;
    data_ready = 0;
    case (present_state)
    WAIT:
    begin
        shift_enable = 0;
        counter_enable = 1;
        data_ready = 0;
    end
    LOAD:
    begin
        shift_enable = 1;
        counter_enable = 0;
        data_ready = 0;
    end
    DONE:
    begin
        shift_enable = 0;
        counter_enable = 1;
        data_ready = 1;
    end
        
    endcase
end
endmodule