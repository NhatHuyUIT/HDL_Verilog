module FIFO (
    input  wire        iClk,
    input  wire        iReset_n,

    // Write Master
    input  wire        FF_readrequest,  // Write Master xin phép đọc từ FF ra
    output wire [31:0] FF_q,            // Data nằm trong FF
    output wire        FF_empty,

    // Read Master
    input  wire        FF_writerequest, // Read Master xin phép ghi vào FF
    input  wire [31:0] FF_data,         // Data đưa vào FF
    output wire        FF_almostfull 
);

    reg [31:0] buffer [255:0]; 
    
    reg [7:0]  pos_read;  // Con trỏ đọc
    reg [7:0]  pos_write; // Con trỏ ghi

    wire fifo_rd; // FF cho phép đọc
    wire fifo_wr; // FF cho phép ghi
    wire compare; 
    wire equal; 

    assign FF_q = buffer[pos_read]; // Data nằm trong FF đang đợi sẵn
    assign fifo_wr = (~FF_almostfull) & FF_writerequest;
    assign fifo_rd = (~FF_empty)      & FF_readrequest;

    always @ (posedge iClk) begin
        if (~iReset_n)
            pos_write <= 8'b0000_0000;
        else if (fifo_wr) begin
            buffer[pos_write] <= FF_data;
            pos_write         <= pos_write + 1;
        end
    end


    always @ (posedge iClk) begin
        if (~iReset_n)
            pos_read <= 8'b0000_0000;
        else if (fifo_rd)
            pos_read <= pos_read + 1;
    end

    assign compare = pos_write[7] ^ pos_read[7];  // compare = 1 khi bit MSB của pos_write và pos_read khác nhau
    assign equal = ((pos_write[6:0] - pos_read[6:0]) == 0) ? 1'b1 : 1'b0; 
    assign FF_almostfull = compare & equal;    // 7 bit thấp bằng nhau nhưng MSB khác nhau => pos_write đi trước pos_read 128 ô FIFO
    assign FF_empty = (~compare) & equal;      // Báo trống khi pos_read và pos_write = nhau

endmodule