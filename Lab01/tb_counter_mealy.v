`timescale 1ns/1ps

module tb_counter_mealy();
  reg clk, reset, preset, en;
  reg [2:0] load_value;
  wire [2:0] out;
  
  counter_mealy dut(
    .clk(clk),
    .reset(reset),
    .preset(preset),
    .en(en),
    .load_value(load_value),
    .out(out)
  );
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    reset = 1;
    en = 0;
    preset = 0;
    load_value = 3'b000;
    
    #10 reset = 0;
    
    en = 1;
    repeat(3) @(posedge clk);
    
    en = 0;
    repeat(3) @(posedge clk);
    
    en = 1;
    
    reset = 1;
    #10 reset = 0;
    
    load_value = 3'b101;
    preset = 1;
    #10 preset = 0;
    
    en = 0;
    repeat(4) begin
      @(posedge clk);
      #3 en = 1;
      #7 en = 0;
    end
  
    
    en = 1;
    repeat(6) @(posedge clk);
    
    $finish;
    
  end
  
  initial begin
    $monitor("t = %0t | reset = %b | preset = %b | en = %b | load_value = %b | out = %b", $time, reset, preset, en, load_value, out);
  end
  
endmodule
