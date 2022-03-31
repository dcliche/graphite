module sdram_test #(
    parameter SDRAM_CLK_FREQ_MHZ	= 100 	// sdram clk freq in MHZ
) (
    // SDRAM interface
    input  wire logic                   sdram_rst,
    input  wire logic                   sdram_clk,
    output	    logic [1:0]	            sdram_ba_o,
    output	    logic [12:0]            sdram_a_o,
    output	    logic                   sdram_cs_n_o,
    output      logic                   sdram_ras_n_o,
    output      logic                   sdram_cas_n_o,
    output	    logic                   sdram_we_n_o,
    output      logic [1:0]	            sdram_dqm_o,
    inout  wire	logic [15:0]	        sdram_dq_io,
    output      logic                   sdram_cke_o,

    output logic error_o
);

    logic [15:0] sdram_dq_out;
    logic [15:0] sdram_dq_in;
    logic        sdram_dq_oe;

    always_ff @(posedge sdram_clk) begin
        sdram_dq_in <= sdram_dq_io;
    end

    assign sdram_dq_io = sdram_dq_oe ? sdram_dq_out : 16'hZZZZ;



    // Internal interface
    logic sc_idle;
    logic [31:0] sc_adr_in = 0;
    logic [31:0] sc_adr_out;
    logic [15:0] sc_dat_in = 0;
    logic [15:0] sc_dat_out;
    logic sc_acc = 0;
    logic sc_ack;
    logic sc_we = 0;

    logic [15:0] vram_data_out;

    sdram_ctrl #(
        .CLK_FREQ_MHZ(SDRAM_CLK_FREQ_MHZ),      // sdram_clk freq in MHZ
`ifdef SYNTHESIZE        
        .POWERUP_DELAY(200),    // power up delay in us
`else
        .POWERUP_DELAY(0),      // power up delay in us
`endif
        .REFRESH_MS(64),        // time to wait between refreshes in ms (0 = disable)
        .BURST_LENGTH(8),       // 0, 1, 2, 4 or 8 (0 = full page)
        .ROW_WIDTH(13),         // Row width
        .COL_WIDTH(9),          // Column width
        .BA_WIDTH(2),           // Ba width
        .tCAC(2),               // CAS Latency
        .tRAC(4),               // RAS Latency
        .tRP(2),                // Command Period (PRE to ACT)
        .tRC(8),                // Command Period (REF to REF / ACT to ACT)
        .tMRD(2)            	// Mode Register Set To Command Delay time
    ) sdram_ctrl (
        // SDRAM interface
        .sdram_rst(sdram_rst),
        .sdram_clk(sdram_clk),
        .ba_o(sdram_ba_o),
        .a_o(sdram_a_o),
        .cs_n_o(sdram_cs_n_o),
        .ras_n_o(sdram_ras_n_o),
        .cas_n_o(sdram_cas_n_o),
        .we_n_o(sdram_we_n_o),
        .dq_i(sdram_dq_in),
        .dq_o(sdram_dq_out),
        .dqm_o(sdram_dqm_o),
        .dq_oe_o(sdram_dq_oe),
        .cke_o(sdram_cke_o),

        // Internal interface
        .idle_o(sc_idle),
        .adr_i(sc_adr_in),
        .adr_o(sc_adr_out),
        .dat_i(sc_dat_in),
        .dat_o(sc_dat_out),
        .sel_i(2'b11),
        .acc_i(sc_acc),
        .ack_o(sc_ack),
        .we_i(sc_we)
    );


    enum { WAIT_IDLE, WRITE, WAIT_WRITE, READ, WAIT_READ } state;

    logic [31:0] adr = 32'd0;
    logic [15:0] expected_dat = 16'h0;
    logic [15:0] read_dat;

    always_ff @(posedge sdram_clk) begin
        case (state)
            WAIT_IDLE: begin
                if (sc_idle) state <= WRITE;
            end
            WRITE: begin
                sc_adr_in <= adr;
                sc_dat_in <= expected_dat;
                sc_acc <= 1'b1;
                sc_we <= 1'b1;
                state <= WAIT_WRITE;
            end

            WAIT_WRITE: begin
                if (sc_ack) begin
                    sc_acc <= 1'b0;
                    sc_we <= 1'b0;
                    state <= READ;
                end
            end

            READ: begin
                sc_adr_in <= adr;
                sc_acc <= 1'b1;
                state <= WAIT_READ;
            end

            WAIT_READ: begin
                if (sc_ack) begin
                    sc_acc <= 1'b0;
                    read_dat <= sc_dat_out;
                    error_o <= sc_dat_out != expected_dat;
                    expected_dat <= 16'(expected_dat + 2);
                    adr <= {7'd0, 25'(adr + 2)};
                    state <= WAIT_IDLE;
                end
            end
        endcase;

        if (sdram_rst) begin
            error_o <= 1'b0;
            read_dat <= 16'h0;
            sc_acc <= 1'b0;
            state <= WAIT_IDLE;
        end
    end

endmodule