package cs_shared_pkg;
    typedef enum bit [2 : 0] {IDLE_cov, WRITE_ADD_cov, WRITE_DATA_cov, READ_ADD_cov, READ_DATA_cov} STATE_cov_e;
    STATE_cov_e cs_cov;
endpackage