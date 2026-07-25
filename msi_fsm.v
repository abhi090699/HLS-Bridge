module hls_bridge_msi_fsm_tx #(

  /////////////////////////////////////////////////////////////////////////////
  //                                Parameters                               //
  /////////////////////////////////////////////////////////////////////////////

  /*BSF:doc=ASF_SUPPORTED enables parity generators and checkers inside CSR blocks;*/
   parameter  KMAX_ASF_SUPPORT          = 0,
  // MSI
   parameter  KMAX_MSI_TDATA_WIDTH      = 64,
   parameter  IB_TDATA_WIDTH            = 64+10,
   localparam KMAX_MSI_TDATA_WIDTH_CHK  = (KMAX_MSI_TDATA_WIDTH+7)/8,
   localparam IB_TDATA_WIDTH_CHK        = (IB_TDATA_WIDTH +7)/8,
   parameter MSI_DC_DATA_WIDTH         = 6,
   parameter MSI_LTIC_DATA_WIDTH       = 3,
   parameter MSI_QOS_DATA_WIDTH        = 3,
   //------------------------------------------------------------------------------
   //ASF
   //------------------------------------------------------------------------------
   /*BSF:doc=Following are the expected modes based on parameter values.;*/
   parameter ASF_SUPPORT                    = 1,
   /*BSF:doc=ASF node ID. This must be unique ID across all ASF components.
     When ASF error injection command's node_id matches with this parameter, command is decoded by this block;*/
   parameter ASF_NODE_ID_BASE               = 4096,
   /*BSF:doc=ASF Error Injection support. If set, Error injection is supported  ;*/
   parameter ASF_ERR_INJ_SUPPORT            = 1,
   /*BSF:doc= ASF Error injection interface data width  ;*/
   parameter ASF_ERROR_INJ_DATA_WIDTH       = 56,
   /*BSF:doc= ASF Error injection interface user width ;*/
   parameter ASF_ERROR_INJ_USER_WIDTH       = 8,
   /*BSF:doc= ASF  Event Type width ;*/
   parameter ASF_EVENT_TYPE_WIDTH           = 4,
   /*BSF:doc= ASF  Event count width ;*/
   parameter ASF_EVENT_COUNT_WIDTH          = 8,
   /*BSF:doc= ASF Node ID width ;*/
   parameter ASF_NODE_ID_WIDTH              = 16,
   /*BSF:doc= ASF Event Diagnostic Field width ;*/
   parameter ASF_EVENT_DIAG_FIELD_WIDTH     = 28

  )(

  /*BSF:isClock=1,clock_group="AXI",doc= AXI clock ;*/
   input axi_clk,
  /*BSF:isReset=1,clock=axi_clk,doc= AXI Reset ;*/
   input axi_rst_n,

  //------------------------------------------------------------------------------
  // AXI Sream MSI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:msi_axi_m_if,axi_clk,axi_rst_nipio=0,
    dis=MSI AXI-Stream Tx interface to GIC
  ;*/
   output wire                                     axis_msi_m_tvalid,
   input  wire                                     axis_msi_m_tready,
   input  wire                                     axis_msi_m_tready_chk,
   output wire                                     axis_msi_m_twakeup,
   output reg                                      axis_msi_m_twakeup_chk,
   output wire [KMAX_MSI_TDATA_WIDTH-1:0]          axis_msi_m_tdata,
   output wire [KMAX_MSI_TDATA_WIDTH_CHK-1:0]      axis_msi_m_tdata_chk,
  /*BSF_IF_END:msi_axi_m_if;*/

  //------------------------------------------------------------------------------
  // Delivery count MSI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:dc_tx_msi_if,axi_clk,axi_rst_n,ipio=0,
    dis=Delivery count MSI TX Interface
  ;*/
   input wire                                       cdc_rdy,
   output wire                                      pck_sended,
   output wire [MSI_DC_DATA_WIDTH-1:0]              dc_data,
   output wire [MSI_LTIC_DATA_WIDTH-1:0]            lti_data,
   output wire                                      ltic_bypass_axi_atu,
   output wire [MSI_QOS_DATA_WIDTH-1:0]            qos_data,

   output wire                                      dc_data_chk,
   output wire                                      lti_data_chk,
   output wire                                      qos_data_chk,

//   input wire                                       enable_msi_pck,
  //BSF_IF_END:dc_tx_msi_if;
  //------------------------------------------------------------------------------
  // CDC fifo IF
  //------------------------------------------------------------------------------
  /*BSF_IF:msi_fifo_if,axi_clk,axi_rst_nipio=0,
    dis=MSI AXI-Stream Tx interface to GIC
  ;*/
   output reg                                       pull,
   input wire                                       fifo_empty,
   input wire [IB_TDATA_WIDTH-1:0]                  synced_posted_data,
   input wire [IB_TDATA_WIDTH_CHK-1:0]              synced_posted_data_chk,
   //input wire [2:0]                                 synced_posted_vc,
   //input wire [2:0]                                 synced_posted_id,

   //input wire                                       synced_posted_lrctag,
   //input wire [1:0]                                 synced_posted_lti_port_num,
   //input wire                                       synced_posted_bypass_axi_atu
  /*BSF_IF_END:msi_fifo_if;*/
  //------------------------------------------------------------------------------
  // ASF error interface
  //------------------------------------------------------------------------------

  /*BSF_IF:asf_error_injection_if,axi_clk,axi_rst_n,ipio=0,
    dis=ASF Error Injection Interface,
    doc=Interface to control error injection in sub-components
  ;*/
  input                                   axi_clk_asf_error_inj__cmd_tvalid_i,
  input [ASF_ERROR_INJ_DATA_WIDTH-1:0]    axi_clk_asf_error_inj__tdata_i,
  input [ASF_ERROR_INJ_USER_WIDTH-1:0]    axi_clk_asf_error_inj__tuser_i,
   /*BSF_IF_END:asf_error_injection_if;*/


  /*BSF_IF:asf_status_and_diag_data,core_clk,core_rst_n,ipio=0,
    dis=ASF Status and Diagnostic output,
    doc=ASF status and diagnostic signals when error is detected in this block.
    all unused signals can be tied to zero. outputs are flopped.
  ;*/
  output                                   asf_event__valid_msi_tdata,
  output [ASF_EVENT_TYPE_WIDTH-1:0]        asf_event__type_msi_tdata,
  output [ASF_EVENT_COUNT_WIDTH-1:0]       asf_event__count_msi_tdata,
  output [ASF_NODE_ID_WIDTH-1:0]           asf_event__node_id_msi_tdata,
  output [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]  asf_event__diag_field_msi_tdata
  /*BSF_IF_END:asf_status_and_diag_data;*/

  );

  //------------------------------------------------------------------------------
  localparam FSM_IDLE        = 3'b001;
  localparam FSM_PENDING     = 3'b010;
  localparam FSM_SEND_PCK    = 3'b100;
  //------------------------------------------------------------------------------
   reg                               msi_m_tvalid;
   wire                              msi_m_tready;
   reg                               msi_m_tready_chk;
   reg                               msi_m_twakeup;
   reg                               msi_m_twakeup_chk;
   reg [IB_TDATA_WIDTH-1:0]          msi_m_tdata;
   reg [IB_TDATA_WIDTH_CHK-1:0]      msi_m_tdata_chk;
   reg [IB_TDATA_WIDTH_CHK-1:0]      msi_m_tdata_ff_chk;

   wire [IB_TDATA_WIDTH-1:0]          msi_m_tdata_ff;

  reg  [2:0]                                        axis_fsm;
  reg  [2:0]                                        axis_fsm_next;

  wire [3:0]                                        dc_data_chk_temp;
  //------------------------------------------------------------------------------
  //------------------------------------------------------------------------------
  //always @(posedge axi_clk or negedge axi_rst_n) begin


  always @(*) begin
    if(fifo_empty==1'b0   // data in fifo
    && axis_fsm == FSM_PENDING
    && ~axis_msi_m_tvalid
    && cdc_rdy)           // sync ready to send dc confirmation
    //&& enable_msi_pck   // enable from DC to process msi pckt
      pull = 1'b1;
    else
      pull = 1'b0;
  end

  // ----------------------------------------------------------------------------
  // AXI-Stream FSM
  // ----------------------------------------------------------------------------
  always @(*) begin
    axis_fsm_next = axis_fsm;
    case (axis_fsm)
      FSM_IDLE : begin
        if (!fifo_empty)
          axis_fsm_next = FSM_PENDING;
        else
          axis_fsm_next = FSM_IDLE;
      end
      FSM_PENDING : begin
        if (pull)
          axis_fsm_next = FSM_SEND_PCK;
        else if (!fifo_empty)
          axis_fsm_next = FSM_PENDING;
        else
          axis_fsm_next = FSM_IDLE;
      end
      FSM_SEND_PCK : begin
        if (msi_m_tready)
          axis_fsm_next = FSM_PENDING;
        else
          axis_fsm_next = FSM_SEND_PCK;
      end
    endcase
  end

  always @(posedge axi_clk or negedge axi_rst_n) begin
    if (axi_rst_n == 1'b0) begin
      axis_fsm <= FSM_IDLE;
    end
    else begin
      axis_fsm <= axis_fsm_next;
    end
  end

  // ----------------------------------------------------------------------------
  // Assign Outputs
  // ----------------------------------------------------------------------------
  always @(*) begin
    case (axis_fsm)
      FSM_IDLE : begin
        msi_m_tvalid                = 1'b0;
        msi_m_tdata                 = {IB_TDATA_WIDTH{1'b0}};
        msi_m_twakeup               = 1'b0;
        msi_m_twakeup_chk           = 1'b1;
        msi_m_tdata_chk             = {IB_TDATA_WIDTH_CHK{1'b1}};
      end
      FSM_PENDING : begin
        msi_m_tvalid                = 1'b0;
        msi_m_tdata                 = {IB_TDATA_WIDTH{1'b0}};
        msi_m_twakeup               = 1'b1;
        msi_m_twakeup_chk           = 1'b0;
        msi_m_tdata_chk             = {IB_TDATA_WIDTH_CHK{1'b1}};
      end
      FSM_SEND_PCK : begin
        msi_m_tvalid                = 1'b1;
        msi_m_twakeup               = 1'b1;
        msi_m_twakeup_chk           = 1'b0;
        msi_m_tdata                 = synced_posted_data    ;
        msi_m_tdata_chk             = synced_posted_data_chk;
      end
      default: begin
        msi_m_tvalid                = 1'b0;
        msi_m_tdata                 = {IB_TDATA_WIDTH{1'b0}};
        msi_m_tdata_chk             = {IB_TDATA_WIDTH_CHK{1'b1}};
        msi_m_twakeup               = 1'b0;
        msi_m_twakeup_chk           = 1'b1;
      end
    endcase
  end

  assign pck_sended = axis_msi_m_tvalid & axis_msi_m_tready;


  // delivery count data
  assign dc_data[0 +:3] = pck_sended ? msi_m_tdata_ff[64 +:3] : 3'b000; //dc_vc
  assign dc_data[3 +:3] = pck_sended ? msi_m_tdata_ff[67 +:3] : 3'b000; //dc_stream_id

  //Lti completion
  assign lti_data[0]         = pck_sended ? msi_m_tdata_ff[70]     : 1'b0;   //ltic_ctag
  assign lti_data[1 +:2]     = pck_sended ? msi_m_tdata_ff[71 +:2] : 2'b00;  //ltic_id
  assign ltic_bypass_axi_atu = pck_sended ? msi_m_tdata_ff[73]     : 1'b0;   //ltic_bypass_axi_atu

  // QOS
  assign qos_data[0 +:3] = pck_sended ? msi_m_tdata_ff[67 +:3] : {MSI_QOS_DATA_WIDTH{1'b0}}; //qos_stream_id

  // ----------------------------------------------------------------------------
  // SKID BUFFER
  // ----------------------------------------------------------------------------
  hlsif_valid_ready_flop #(
      .DATA_WD                                 (IB_TDATA_WIDTH
                                                +1)
     ,.BREAK_ONLY_DATA_TIMING_PATH             (1)
   )
   msi_if_skid_buffer (
      .clk                                      (axi_clk)
     ,.rst_n                                    (axi_rst_n)
     ,.valid_i                                  (msi_m_tvalid)
     ,.data_i                                   ({
                                                  msi_m_tdata,
                                                  msi_m_twakeup
                                                 })
     ,.ready_o                                  (msi_m_tready)
     ,.out_valid_o                              (axis_msi_m_tvalid)
     ,.out_data_o                               ({
                                                  msi_m_tdata_ff,
                                                  axis_msi_m_twakeup
                                                 })
     ,.out_ready_i                              (axis_msi_m_tready)
  );


  always @(posedge axi_clk or negedge axi_rst_n) begin
    if (axi_rst_n == 1'b0) begin
      axis_msi_m_twakeup_chk <= 1'b1;
      msi_m_tdata_ff_chk     <= {IB_TDATA_WIDTH_CHK{1'b1}};
    end
    else begin
      if (msi_m_tready) begin
        axis_msi_m_twakeup_chk <= msi_m_twakeup_chk;
        msi_m_tdata_ff_chk     <= msi_m_tdata_chk;
      end
    end
  end

  assign axis_msi_m_tdata     = msi_m_tdata_ff     [KMAX_MSI_TDATA_WIDTH-1:0];
  assign axis_msi_m_tdata_chk = msi_m_tdata_ff_chk [KMAX_MSI_TDATA_WIDTH_CHK-1:0];

  // ----------------------------------------------------------------------------
  // ASF
  // ----------------------------------------------------------------------------
  generate
  if (ASF_SUPPORT > 1) begin : msi_tdata_asf
    // <mkdocs_chk_data> ID: 081 ; Checker Name: i_asf_par_081_msi_data ; ASF Group: DAP ; Constrain: KMAX_MSI_IF_SUPPORT == 1
    asf_parity_check_and_regen_w_errinj #(
     .ASF_SUPPORT                          (ASF_SUPPORT),  // = 3,
     .ASF_NODE_ID                          (ASF_NODE_ID_BASE[15:0] +16'd81), // = 16 (HLS Bridge offset) + 81 (node ID),
     .ASF_ERR_INJ_SUPPORT                  (ASF_ERR_INJ_SUPPORT),  // = 1,
     .NUM_DATA_UNITS__CHKER                (1)
    ) i_asf_par_081_msi_data (
     .clk                                  (axi_clk),                 // input
     .rst_n                                (axi_rst_n),               // input
     .chk__data_block_valid_i              (1'b1),
     .chk__data_i                          ({22'd0 ,msi_m_tdata_ff[73:64]}),
     .chk__datachk_i                       ({2'b11 ,msi_m_tdata_ff_chk[9:8]}),
     .chk__parity_error_detected_outside_i (1'b0),
     .regen__data_block_valid_i            (1'b1),
     .regen__data_i                        ({26'b0,dc_data}),
     .regen__datachk_o                     (dc_data_chk_temp),

     .asf_error_inj__cmd_tvalid_i          (axi_clk_asf_error_inj__cmd_tvalid_i),
     .asf_error_inj__tdata_i               (axi_clk_asf_error_inj__tdata_i),
     .asf_error_inj__tuser_i               (axi_clk_asf_error_inj__tuser_i),

     .asf_event__valid_o                   (asf_event__valid_msi_tdata     ),
     .asf_event__type_o                    (asf_event__type_msi_tdata      ),
     .asf_event__count_o                   (asf_event__count_msi_tdata     ),
     .asf_event__node_id_o                 (asf_event__node_id_msi_tdata   ),
     .asf_event__diag_field_o              (asf_event__diag_field_msi_tdata)
    );

    assign dc_data_chk  = dc_data_chk_temp[0];
    assign lti_data_chk = ~(^lti_data);
    assign qos_data_chk = ~(^qos_data);
  end
  else begin : g_no_msi_tdata_asf
    assign dc_data_chk  = 1'b1;
    assign lti_data_chk = 1'b1;
    assign qos_data_chk = 1'b1;
  end
  endgenerate

  endmodule
