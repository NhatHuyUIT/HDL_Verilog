module Lab02_Bai1
(
	input clk,
	input rst_n,
	input done_in, // Tin hieu cho biet input da vao
	input [7:0] a, b, c,
	input [7:0] d, e, f,
	input [7:0] g, h, i,
	
	output reg done_out,	// Tin hieu cho biet output da ra va su dung duoc
	output reg [7:0] median_out
);

parameter [7:0] PERCENT_THRESHOLD = 8'd20;	//20%

//Tim kiem max cua 3 
function [7:0] max_3;
	input [7:0] a, b, c;
									// Khong thay doi gia tri a, b, c nen khong can reg 
	begin
		if(a >= b && a >= c)
			max_3 = a;
		else if(b >= a && b >= c)
			max_3 = b;
		else
			max_3 = c;
	end
endfunction

//Tim kiem min cua 3
function [7:0] min_3;
	input [7:0] a, b, c;
	
	begin
		if(a <= b && a <= c)
			min_3 = a;
		else if(b <= a && b <= c)
			min_3 = b;
		else
			min_3 = c;
	end
endfunction
	
// Tim kiem phan tu o giua: a b c d e f g h i -> find value e
function [7:0] mid_3;
	input [7:0] a, b, c;
	reg [7:0] a1, b1, c1, temp;
	
	begin
		a1 = a;
		b1 = b;
		c1 = c;
		if(a1 > b1)
			begin
				temp = a1;
				a1 = b1;
				b1 = temp;
			end
		if(b1 > c1)
			begin
				temp = b1;
				b1 = c1;
				c1 = temp;
			end
		if(a1 > b1)
			begin
				temp = a1;
				a1 = b1;
				b1 = temp;
			end
			
		mid_3 = b1;
		
	end
endfunction

	wire [7:0] max_r0, mid_r0, min_r0;
	wire [7:0] max_r1, mid_r1, min_r1;
	wire [7:0] max_r2, mid_r2, min_r2;
	
	assign max_r0 = max_3(a, b, c);
	assign mid_r0 = mid_3(a, b, c);
	assign min_r0 = min_3(a, b, c);
	
	assign max_r1 = max_3(d, e, f);
	assign mid_r1 = mid_3(d, e, f);
	assign min_r1 = min_3(d, e, f);
	
	assign max_r2 = max_3(g, h, i);
	assign mid_r2 = mid_3(g, h, i);
	assign min_r2 = min_3(g, h, i);

	
	wire [7:0] max_3min;
	wire [7:0] min_3max;
	wire [7:0] mid_3mid;
	
	assign max_3min = max_3(min_r0, min_r1, min_r2);
	assign min_3max = min_3(max_r0, max_r1, max_r2);
	assign mid_3mid = mid_3(mid_r0, mid_r1, mid_r2);
	
	wire [7:0] median;
	assign median = mid_3(max_3min, min_3max, mid_3mid);

	wire [7:0] diff_em;
	wire [10:0] diff_x5; //  11 bit de chua ket qua nhan 5 cua so 8 bit
	wire [7:0] filtered_pixel;

	
	assign diff_em = (e >= median) ? (e - median) : (median - e);
	assign diff_x5 = (diff_em << 2) + diff_em;
	assign filtered_pixel = ((median == 8'd0 && e != 8'd0) || (median != 8'd0 && diff_x5 > median)) ? median : e;
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			begin
				done_out <= 1'b0;
				median_out <= 8'b0;
			end
		else 
			begin
				done_out <= done_in;
				
				if(done_in)
					median_out <= filtered_pixel;
			end
	end
	
endmodule