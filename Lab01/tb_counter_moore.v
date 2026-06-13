`timescale 1ns/1ps

module tb_counter_moore();
  reg clk, reset, preset;
  reg [2:0] load_value;
  wire [2:0] out;
  
  counter_moore dut
  (
    .clk(clk),
    .reset(reset),
    .preset(preset),
    .load_value(load_value),
    .out(out)
  );
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    reset = 1;
    preset = 0;
    load_value = 3'b000;
    
    #10 reset = 0;
    
    repeat(6) @(posedge clk);
    
    reset = 1;
    #10 reset = 0;
    
    load_value = 3'b101;
    preset = 1;
    #10 preset = 0;
    
    repeat(5) @(posedge clk);
    
    load_value = 3'b001;
    preset = 1;
    #10 preset = 0;
    
    repeat(7) @(posedge clk);
    
    reset = 1;
    preset = 1;
    #10 reset = 0;
    preset = 0;
    
    $finish;
  end
  
  initial begin
    $monitor("t = %0t | reset = %b | preset = %b | load_value = %b | out = %b", $time, reset, preset, load_value, out);
  end
    
endmodule
