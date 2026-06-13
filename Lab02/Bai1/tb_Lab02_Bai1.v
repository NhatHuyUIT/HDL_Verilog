`timescale 1ns/1ps

module tb_Lab02_Bai1;

reg clk, rst_n, done_in;
reg [7:0] a, b, c, d, e, f, g, h, i;
wire done_out;
wire [7:0] median_out;

parameter Width = 430;
parameter Height = 554;
parameter Total = Width * Height;

Lab02_Bai1 dut(
	.clk(clk),
	.rst_n(rst_n),
	.done_in(done_in),
	.a(a),
	.b(b),
	.c(c),
	.d(d),
	.e(e),
	.f(f),
	.g(g),
	.h(h),
	.i(i),
	.done_out(done_out),
	.median_out(median_out)
);
 
initial begin
	clk = 0;
	forever #20 clk = ~clk;
end

reg [7:0] image[0:Total - 1];	//Tao 1 mang image

function [7:0]value_pixel;		// Ham co chuc nang lay gia tri trong ma tran 3x3
	input integer row, col;
	begin
		if(row < 0 || row >= Height || col < 0 || col >= Width)
			value_pixel = 8'b0;
		else
			value_pixel = image[row * Width + col];
	end
endfunction

reg [7:0] result[0:Total-1];		// Tao 1 mang luu ket qua trung vi
integer file_out;
integer r, cl, index, k;

initial begin
	
	$readmemh("pic_input.txt", image);
	$display("Doc anh xong: %0d x %0d = %0d pixel", Width, Height, Total);
	
	rst_n = 0;
	repeat(4) @(posedge clk); #1;
	rst_n = 1;
	repeat(2) @(posedge clk); #1;
	
	index = 0;

	for(r = 0; r < Height; r = r + 1) begin
		for(cl = 0; cl < Width; cl = cl + 1) begin
		
			@(negedge clk);
			a = value_pixel(r - 1, cl - 1);
			b = value_pixel(r - 1, cl);
			c = value_pixel(r - 1, cl + 1);
		
			d = value_pixel(r, cl - 1);
			e = value_pixel(r, cl);
			f = value_pixel(r, cl + 1);
		
			g = value_pixel(r + 1, cl - 1);
			h = value_pixel(r + 1, cl);
			i = value_pixel(r + 1, cl + 1);
		
			done_in = 1;
			
			@(posedge clk); #1;
			if(done_out) begin
				result[index] = median_out;
				index = index + 1;
			end
		end
	end
	
	@(negedge clk); 
	done_in = 0;
	
	@(posedge clk); #1;         
	if(done_out) begin
    	result[index] = median_out;
    	index = index + 1;
	end

	file_out = $fopen("pic_output.txt", "w");
	for(k = 0; k < Total; k = k + 1)
		$fwrite(file_out, "%02X\n", result[k]);
	$fclose(file_out);
	
	$display("Xong! Ghi %0d ra pic_output.txt", index);
	#20;
	$finish;

end

endmodule
