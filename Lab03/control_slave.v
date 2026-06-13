module control_slave (
    //Giao tiếp Avalon Slave (Làm việc với CPU Nios II)
    input  wire        iClk,           
    input  wire        iReset_n,       
    input  wire        iChipselect_n,  
    input  wire        iWrite,         // CPU ra lệnh Ghi 
    input  wire        iRead,          // CPU ra lệnh Đọc 
    input  wire [2:0]  iAddress,       // Địa chỉ thanh ghi CPU muốn thao tác (offset)
    input  wire [31:0] iWritedata,     // Dữ liệu từ CPU truyền xuống 
    output reg  [31:0] oReaddata,      // Dữ liệu phần cứng trả về cho CPU
    output wire        oIRQ,           


    //Giao tiếp nội bộ (Read/Write Master)
    input  wire        iMW_done,         
    output reg         oStart,           
    output reg  [31:0] oRM_startaddress, // Địa chỉ bắt đầu đọc
    output reg  [31:0] oWM_startaddress, // Địa chỉ bắt đầu ghi
    output reg  [31:0] oLength           
);


    reg [31:0] control;
    reg [31:0] status;
    reg [1:0]  state;
    reg        enable;

    wire GO, WORD, HW, BYTE;
    wire DONE, BUSY;

    assign {GO, WORD, HW, BYTE} = control[3:0]; // 4 bit thấp của control
    assign {BUSY, DONE}         = status[1:0];  // 2 bit thấp của status
    assign oIRQ                 = DONE;         // Nối trực tiếp cờ DONE ra dây chuông ngắt


    //Xử lý Đọc/Ghi Avalon
    always @ (posedge iClk) begin
        if (~iReset_n) begin
            oRM_startaddress <= 32'h0;
            oWM_startaddress <= 32'h0;
            oLength          <= 32'h0;
            control          <= 32'h0;
            oReaddata        <= 32'h0;                  
        end
        
        else if (DONE) begin
            control <= 32'h0;  
        end
            
        else if (~iChipselect_n) begin
            if (iWrite & ~BUSY) begin
                case (iAddress)
                    3'h0: oRM_startaddress <= iWritedata; 
                    3'h1: oWM_startaddress <= iWritedata; 
                    3'h2: oLength          <= iWritedata; 
                    3'h3: control          <= iWritedata;
                endcase
            end
            else if (iRead) begin
                case (iAddress)
                    3'h7: oReaddata <= status;
                endcase
            end
        end         
    end

    //State Machine điều phối
    always @ (posedge iClk) begin
        if (~iReset_n) begin
            status <= 32'h0;
            oStart <= 1'b0;
            state  <= 2'h0;
            enable <= 1'b0;
        end
        else begin
            case (state)
                2'h0: begin
                    if (GO && ~enable) begin
                        status <= 32'h2; //BUSY
                        oStart <= 1'b1;
                        state  <= 2'h1;
                    end
                end
                2'h1: begin
                    oStart <= 1'b0;
                    enable <= 1'b1;
                    if (iMW_done) begin  
                        status <= 32'h1; // Status = 1 => DONE. 
                        state  <= 2'h2;
                    end
                end
                2'h2: begin
                    enable <= 1'b0;
                    oStart <= 1'b0;
                    if (~iChipselect_n && iRead && (iAddress == 3'h7)) begin
                        status <= 32'h0;
                        state  <= 2'h0;
                    end
                end
            endcase
        end
    end

endmodule