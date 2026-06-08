module controller(
    input logic clk,rst,Start,Next_Zero,
    output logic ld_next,ld_sum,sum_select,next_select,Address_select,Finish
);
typedef enum logic [1:0] { 
    Idle,Read_data,Get_Next,Done
} state_t;
state_t present_state,next_state;
  
//memory of present_state
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        present_state<=Idle;
    end
    else begin
        present_state <= next_state;
    end
end  

// combinational block to calculate next_state
always_comb begin
    next_state = present_state;
    case (present_state)

    Idle:
    if(!Start) begin
        next_state = Read_data;
    end else begin
        next_state = Idle;
    end

    Read_data:
    
        next_state = Get_Next;
      
    Get_Next:
    if (!Next_Zero) begin
        next_state = Read_data;
    end
    else begin
        next_state = Done;
    end
    Done:
    if (Start) begin
        next_state = Idle;
    end
    else begin
        next_state = Done;
    end
    default:
    next_state = Idle;
    endcase
end
// combinational block to calculate output
always_comb begin
    ld_sum = 0;
    ld_next= 0;
    next_select = 0;
    sum_select = 0;
    Address_select = 0;
    Finish = 0;
    case (present_state)
        Idle:
        begin
            ld_sum = 1;
            ld_next= 1;
            sum_select = 0;
            next_select = 0;
            Finish = 0;
        end
        Read_data:
        begin
            ld_sum = 1;
            sum_select = 1;
            ld_next = 0;
            next_select = 0;
            Address_select = 1;
            Finish = 0;
        end
        Get_Next:
        begin
            ld_sum = 0;
            sum_select = 0;
            ld_next = 1;
            next_select = 1;
            Address_select = 0;
            Finish = 0;
        end
        Done:
        begin
            
            Finish = 1;
        end
    endcase
end
endmodule