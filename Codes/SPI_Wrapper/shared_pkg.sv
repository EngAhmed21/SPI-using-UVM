package shared_pkg;
    localparam MEM_DEPTH = 256;
    localparam ADDR_SIZE = $clog2(MEM_DEPTH);
    
    typedef enum bit [2 : 0] {IDLE, CHK_CMD, WRITE, READ_ADD, READ_DATA} STATE_e;    
endpackage