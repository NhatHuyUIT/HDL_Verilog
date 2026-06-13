module DMA_ISR ( 
    input wire [0:0] KEY,
    input wire       CLOCK_50
);

system u0 (
    .clk_clk       (CLOCK_50), 
    .reset_reset_n (KEY[0])    
);

endmodule