module write_master ( 

    //Control Slave
    input  wire        iClk,              
    input  wire        iReset_n,          
    input  wire        iStart,            
    input  wire [31:0] iWM_startaddress,  // Địa chỉ bắt đầu ghi vào RAM đích
    input  wire [31:0] iLength,           


    //Avalon Master
    input  wire        iWM_waitrequest,   // Bus báo bận
    output reg         oWM_done,          // Báo hiệu đã ghi xong
    output reg         oWM_write,         // Xin phép ghi gửi ra Bus
    output reg  [31:0] oWM_writeaddress,  // Địa chỉ cần ghi gửi ra Bus
    output reg  [31:0] oWM_writedata,     // Dữ liệu cần ghi gửi ra Bus

    //FIFO
    input  wire        iFF_empty,        
    input  wire [31:0] iFF_q,             
    output wire        oFF_readrequest    // Xin phép lấy data từ FIFO
);

    reg [1:0]  state;
    reg [31:0] WM_lastwriteaddress;
    assign oFF_readrequest = (~iReset_n) ? 1'b0 : (~iFF_empty && ~|state);  // Ở State 0, xin phép đọc trong FIFO

    always @ (posedge iClk) begin
        if (~iReset_n) begin
            state               <= 2'h0;
            oWM_write           <= 1'b0;
            oWM_done            <= 1'b0;
            oWM_writedata       <= 32'h0;
            oWM_writeaddress    <= 32'h0;
            WM_lastwriteaddress <= 32'h0;
        end
        else begin
            if (iStart) begin
                oWM_writeaddress    <= iWM_startaddress;
                WM_lastwriteaddress <= iWM_startaddress + iLength;
            end
            else if (~iFF_empty || |state) begin // Chạy khi FIFO không empty hoặc state khác 0
                case (state)
                    2'h0: begin 
                        state         <= 2'h1;
                        oWM_write     <= 1'b1;  // Xin phép gửi giá trị cho Bus
                        oWM_writedata <= iFF_q; // Đưa Data từ FIFO vào Bus
                    end
                    2'h1: begin
                        if (~iWM_waitrequest) begin 
                            if (WM_lastwriteaddress == (oWM_writeaddress + 4)) begin
                                oWM_write <= 1'b0;
                                oWM_done  <= 1'b1; // Bật cờ hoàn thành báo cho control
                                state     <= 2'h2;
                            end
                            else begin
                                oWM_writeaddress <= oWM_writeaddress + 3'h4;
                                oWM_write        <= 1'b0;               
                                state            <= 2'h0;                 
                            end
                        end
                    end
                    2'h2: begin
                        oWM_done <= 1'b0; 
                        state    <= 2'h0;
                    end
                endcase
            end
        end
    end

endmodule