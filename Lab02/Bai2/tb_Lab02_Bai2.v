`timescale 1ns/1ps

module tb_Lab02_Bai2;

parameter Width = 2048;
parameter Height = 1365;
parameter Total = Width * Height;
parameter N_gen = 8;    // N_gen là số block chạy song song

reg clk, rst_n, done_in;

reg [7:0] Red [0:N_gen - 1];
reg [7:0] Green [0:N_gen - 1];
reg [7:0] Blue [0:N_gen - 1];

wire done_out[0:N_gen - 1];
wire [7:0] Gray_out[0:N_gen - 1];

genvar i;
generate
    for(i = 0; i < N_gen; i = i + 1 ) begin: block_gen
        Lab02_Bai2 #
        (
            .Brightness(-9'sd50)  // Ghi đè
        ) dut 
        (
            .clk(clk),
            .rst_n(rst_n),
            .done_in(done_in),
            .Red(Red[i]),
            .Green(Green[i]),
            .Blue(Blue[i]),
            .done_out(done_out[i]),
            .Gray_out(Gray_out[i])
        );
    end
endgenerate


reg [7:0] image[0:Total *3 - 1];
reg [7:0] result[0:Total - 1];
integer file_out;
integer j, k, l;

initial begin
    clk = 0;
    forever #20 clk = ~clk;
end

initial begin
    $readmemh("pic_input.txt", image);
    $display("Doc anh xong: %0d x %0d = %0d", Width, Height, Total);

    rst_n = 0;
    repeat (4) @(posedge clk); #1;
    rst_n = 1;
    repeat (4) @(posedge clk); #1;

    k = 0;
    repeat (Total / N_gen) begin
        for(j = 0; j < N_gen; j = j + 1) begin
            //       0 1 2 3 4 5 6 7 8 9 
            //imgae: R G B R G B R G B R ....
            Red[j] = image[(k + j) * 3];
            Green[j] = image[(k + j) * 3 + 1];
            Blue[j] = image[(k + j) * 3 + 2];
        end
        done_in = 1;

        @(posedge clk); #10;  // Chạy post thì bị xx nên delay thêm cho ổn định dữ liệu

        for(j = 0; j < N_gen; j = j + 1) begin
            if(done_out[j])
                result[k+j] = Gray_out[j];
        end
        k = k + N_gen;
    end

    @(negedge clk);
    done_in = 0;

    file_out = $fopen("pic_output.txt", "w");
    for(l = 0; l < Total; l = l + 1)
        $fwrite(file_out, "%02x\n", result[l]);
    $fclose(file_out);

    $display("Da ghi xong %0d pixel vao pic_output.txt", Total);
    #20;
    $finish;
end

endmodule