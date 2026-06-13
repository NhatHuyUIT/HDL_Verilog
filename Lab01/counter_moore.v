module counter_moore
(
    input [0:0] KEY,    
    input [4:0] SW,
    output [2:0] LEDR
);

    wire clk    = ~KEY[0];
    wire reset  = SW[0];
    wire preset = SW[1];
    wire [2:0] load_value = SW[4:2];

    reg [2:0] state;
    reg [2:0] next_state;
	 
	 always @(state)
    begin
        case(state)
            3'b000: next_state = 3'b110;
            3'b110: next_state = 3'b100;
            3'b100: next_state = 3'b111;
            3'b111: next_state = 3'b011;
            3'b011: next_state = 3'b000;
            3'b001: next_state = 3'b110;
            3'b101: next_state = 3'b010;
            3'b010: next_state = 3'b111;
            default: next_state = 3'b000;
        endcase
    end

    always @(posedge clk or posedge reset or posedge preset)
    begin
        if(reset)
            state <= 3'b000;
        else if(preset)
            state <= load_value;
        else 
            state <= next_state;
    end
    
    assign LEDR = state;

endmodule