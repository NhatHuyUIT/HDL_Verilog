module read_master (

    //Control Slave

    input  wire        iClk,              
    input  wire        iReset_n,          
    input  wire        iStart,            
    input  wire [31:0] iLength,          
    input  wire [31:0] iRM_startaddress,  // Địa chỉ RAM đầu 

    //Avalon Master (Đọc RAM nguồn)
    input  wire        iRM_waitrequest,   
    input  wire        iRM_readdatavalid, // Dữ liệu trên dây iRM_readdata là hợp lệ
    input  wire [31:0] iRM_readdata,      // Dữ liệu thực tế lấy được từ RAM
    output reg         oRM_read,          // Lệnh xin phép đọc gửi ra Bus
    output reg  [31:0] oRM_readaddress,   // Địa chỉ cần đọc gửi ra Bus

    //FIFO
    input  wire        iFF_almostfull,   
    output wire        oFF_writerequest,  // Xin phép ghi vào FIFO
    output reg  [31:0] oFF_data           // Data đưa vào FIFO
);

    reg [1:0]  state;
    reg [31:0] RM_lastwriteaddress;
    assign oFF_writerequest = (~iReset_n) ? 1'b0 : (~iFF_almostfull && ~|state && iRM_readdatavalid);

    always @(*) begin
        if (~iReset_n)
            oFF_data = 32'h0;
        else if (iRM_readdatavalid)
            oFF_data = iRM_readdata;
        else 
            oFF_data = oFF_data;
    end


    always @(posedge iClk) begin
        if (~iReset_n) begin
            state               <= 2'h0;
            oRM_readaddress     <= 32'h0;
            oRM_read            <= 1'b0;
            RM_lastwriteaddress <= 32'h0;
        end
        else begin
            if (iStart) begin
                oRM_readaddress     <= iRM_startaddress;
                RM_lastwriteaddress <= iRM_startaddress + iLength; 
            end
            else begin
                if (~iFF_almostfull || |state) begin
                    case (state)
                        2'h0: begin
                            state <= 2'h1;
                        end
                        2'h1: begin
                            if (oRM_readaddress == RM_lastwriteaddress) begin
                                state <= 2'h0;
                            end
                            else begin
                                oRM_read <= 1'b1;   // Xin phép đọc từ bus
                                state    <= 2'h2;
                            end
                        end
                        2'h2: begin
                            if (~iRM_waitrequest) begin 
                                oRM_readaddress <= oRM_readaddress + 3'h4;
                                oRM_read        <= 1'b0;
                                state           <= 2'h0;
                            end
                        end
                    endcase
                end
            end
        end
    end

endmodule