module DMAFinal (
    
    // Control Slave (Giao tiếp với CPU Nios II)
    input  wire        iClk,
    input  wire        iReset_n,
    input  wire        iChipselect_n,
    input  wire        iRead,
    input  wire        iWrite,
    input  wire [2:0]  iAddress,
    input  wire [31:0] iWritedata,
    
    output wire [31:0] oReaddata,
    output wire        oIRQ,

    
    // Read Master (Đọc dữ liệu từ RAM nguồn)
    input  wire        iRM_readdatavalid,
    input  wire        iRM_waitrequest,
    input  wire [31:0] iRM_readdata,
    
    output wire        oRM_read,
    output wire [31:0] oRM_readaddress, 

    
    // Write Master (Ghi dữ liệu vào RAM đích)
    input  wire        iWM_waitrequest,
    
    output wire        oWM_write,
    output wire [31:0] oWM_writeaddress,
    output wire [31:0] oWM_writedata
);


// Internal Wires (Dây kết nối nội bộ giữa các module)
wire [31:0] RM_startaddress;
wire [31:0] WM_startaddress;
wire [31:0] length;
wire [31:0] FF_data;
wire [31:0] FF_q;

wire        Start;
wire        WM_done;
wire        FF_almostfull;
wire        FF_writerequest;
wire        FF_empty;
wire        FF_readrequest;

control_slave control (
    .iClk             (iClk), 
    .iReset_n         (iReset_n), 
    .iChipselect_n    (iChipselect_n), 
    .iWrite           (iWrite), 
    .iRead            (iRead), 
    .iMW_done         (WM_done), 
    .iAddress         (iAddress), 
    .iWritedata       (iWritedata), 
    .oStart           (Start), 
    .oReaddata        (oReaddata), 
    .oRM_startaddress (RM_startaddress), 
    .oWM_startaddress (WM_startaddress), 
    .oLength          (length), 
    .oIRQ             (oIRQ)
);

read_master rm (
    .iClk             (iClk), 
    .iReset_n         (iReset_n), 
    .iStart           (Start), 
    .iLength          (length), 
    .iRM_startaddress (RM_startaddress), 
    .iRM_readdatavalid(iRM_readdatavalid), 
    .iRM_waitrequest  (iRM_waitrequest),
    .oRM_read         (oRM_read), 
    .oRM_readaddress  (oRM_readaddress), 
    .iRM_readdata     (iRM_readdata), 
    .iFF_almostfull   (FF_almostfull), 
    .oFF_writerequest (FF_writerequest), 
    .oFF_data         (FF_data)
);

FIFO fi (
    .iClk             (iClk), 
    .iReset_n         (iReset_n), 
    .FF_empty         (FF_empty), 
    .FF_almostfull    (FF_almostfull), 
    .FF_data          (FF_data), 
    .FF_q             (FF_q), 
    .FF_readrequest   (FF_readrequest), 
    .FF_writerequest  (FF_writerequest)
);

write_master wm (
    .iClk             (iClk), 
    .iReset_n         (iReset_n), 
    .iStart           (Start), 
    .iWM_startaddress (WM_startaddress), 
    .iLength          (length), 
    .iWM_waitrequest  (iWM_waitrequest), 
    .iFF_empty        (FF_empty), 
    .iFF_q            (FF_q), 
    .oFF_readrequest  (FF_readrequest), 
    .oWM_done         (WM_done), 
    .oWM_write        (oWM_write), 
    .oWM_writeaddress (oWM_writeaddress), 
    .oWM_writedata    (oWM_writedata)
);

endmodule