module Lab02_Bai2 #(
    parameter signed [8:0] Brightness = 9'sd0  // [-255 255]
)
(
    input clk, rst_n, done_in,
    input [7:0] Red,
    input [7:0] Green, 
    input [7:0] Blue,

    output reg done_out,
    output reg [7:0] Gray_out
);

wire [17:0] Y_sum;
assign Y_sum = (18'd306 * Red) + (18'd601 * Green) + (18'd117 * Blue);

wire [7:0] Y_shift;
assign Y_shift = Y_sum[17:10]; // >> 10

wire signed [9:0] Y_bright;     // Dùng signed để có thể biểu diễn giá trị âm khi Brightness < 0
assign Y_bright = $signed({2'b00, Y_shift}) + $signed(Brightness);

wire [7:0]Y_gray;
assign Y_gray = (Y_bright > 10'sd255) ? 8'd255 : (Y_bright < 10'sd0) ? 8'd0 : Y_bright[7:0];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Gray_out <= 0;
        done_out <= 0;
    end
    else begin
        done_out <= done_in; 
        Gray_out <= 8'b0;
        if (done_in)
        Gray_out <= Y_gray;
    end
end
endmodule 