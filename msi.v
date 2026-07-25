module hls_bridge_msi #(

  /////////////////////////////////////////////////////////////////////////////
  //                                Parameters                               //
  /////////////////////////////////////////////////////////////////////////////

  /*BSF:doc=ASF_SUPPORTED enables parity generators and checkers inside CSR blocks;*/
   parameter  KMAX_ASF_SUPPORT          = 0,
   //BSF:doc= Data width for GIC;
   parameter KMAX_MSI_TDATA_WIDTH      = 64,
   /*BSF:doc=Delivery count data width (VC[2:0] + Stream ID[2:0];*/
   parameter MSI_DC_DATA_WIDTH         = 6,
   /*BSF:doc= MSI_LTI data width (CTAG[1:0] + Porti ID);*/
   parameter MSI_LTIC_DATA_WIDTH       = 3,
   /*BSF:doc= MSI_QOS data width Stream ID[2:0];*/
   parameter MSI_QOS_DATA_WIDTH        = 3,

   localparam KMAX_MSI_TDATA_WIDTH_CHK  = (KMAX_MSI_TDATA_WIDTH+7)/8,
   //BSF:doc=MSI DATA + data for delivered, CTAG, QOS modules;
   localparam  IB_TDATA_WIDTH          = 64 + 10,
   //BSF:doc=MSI DATA + data for deliverd and CTAG modules;
   localparam  IB_TDATA_WIDTH_CHK      = (IB_TDATA_WIDTH +7)/8, // 
   //
   // Width definitions for internal signals
   //BSF:doc=Packet counter width for valid/ready tracking;
   localparam PACKET_CNTR_WIDTH         = 10,
   //BSF:doc=Async FIFO address width (depth = 2^4 = 16);
   localparam FIFO_ADDR_WIDTH           = 4,
   //BSF:doc=CDC bus sync data width;
   localparam CDC_BUS_WIDTH             = MSI_DC_DATA_WIDTH+MSI_LTIC_DATA_WIDTH+MSI_QOS_DATA_WIDTH+4,
   //BSF:doc=ASF parity check padding width;
   localparam ASF_PAD_WIDTH             = 31,
   //BSF:doc=Width of LTI port ID signal;
   localparam LTI_PORT_ID_WIDTH         = 2,
   //BSF:doc=Width of temporary parity check signal;
   localparam PARITY_CHK_TEMP_WIDTH     = 4,
   //BSF:doc=Packet counter threshold (993 decimal);
   localparam PACKET_CNTR_THRESHOLD     = 10'h3e1,
   //BSF:doc=Width of threshold value;
   localparam THRESHOLD_WIDTH           = 10,

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

  /*BSF:isClock=1,clock_group="CORE",doc= Power down / Power Shut-Off Core Clock ;*/
   input core_clk,
  /*BSF:isReset=1,clock=core_clk,doc= Power down / Power Shut-Off Core Reset ;*/
   input core_rst_n,

  /*BSF:isClock=1,clock_group="AXI",doc= AXI clock ;*/
   input axi_clk,
  /*BSF:isReset=1,clock=axi_clk,doc= AXI Reset ;*/
   input axi_rst_n,


   /*BSF:doc=Selectes datasync reset..0: asynchronous, 1: synchronous reset;*/
   input  wire                                               k_sync_reset,
   /*BSF:doc=Selectes number of stages in datasync..0: 2 stages, 1: 3 stages;*/
   input  wire                                               k_sync_cell_stages,

   /*BSF:doc=Enables axi_msi_clk;*/
   output wire                                               axi_qactive,

  //------------------------------------------------------------------------------
  // HLS RX Posted * n times depand on KMAX_NUM_HLS_PORTS
  //------------------------------------------------------------------------------
  /*BSF_IF:hls_rx_posted,core_clk,core_rst_n,ipio=0
  ,dis=MSI HLS Rx Posted interface
  ;*/
  //BSF:doc=data valid;
   input wire                                               rx_posted_valid,
  //BSF:doc=data;
   input wire [IB_TDATA_WIDTH-1:0]                          rx_posted_data,
  /*BSF:doc=module ready;
    # [0  +: 64] - GIC data.
    # [64 +: 3] - VC number.
    # [67 +: 3] - Stream ID.
    # [70 +: 1] - CTAG, index of LTI port which gave the translated response.
    # [71 +: 2] - Port number, index of LTI port which gave the translated response.
    # [73 +: 1] - Atu, expected to set for LTI translated transactions.
    ;*/
   output wire                                              rx_posted_ready,
  //BSF:doc=data valid check;
   input wire                                               rx_posted_valid_chk,
  /*BSF:doc=data check;*/
   input wire [IB_TDATA_WIDTH_CHK-1:0]                      rx_posted_data_chk,
  /*BSF_IF_END:hls_rx_posted;*/



  //------------------------------------------------------------------------------
  // AXI Sream MSI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:msi_axi_m_if,axi_clk,axi_rst_n,ipio=1,
    dis=MSI AXI-Stream Tx interface to GIC
  ;*/
  //BSF:doc=data valid;
   output wire                                                axis_msi_m_tvalid,
  //BSF:doc=data valid check;
   output wire                                                axis_msi_m_tvalid_chk,
  //BSF:doc=ready;
   input  wire                                                axis_msi_m_tready,
  //BSF:doc=ready check;
   input  wire                                                axis_msi_m_tready_chk,
  //BSF:doc=wakeup;
   output wire                                                axis_msi_m_twakeup,
  //BSF:doc=wakeup;
   output wire                                                axis_msi_m_twakeup_chk,
  //BSF:doc=data;
   output wire   [KMAX_MSI_TDATA_WIDTH-1:0]                   axis_msi_m_tdata,
  //BSF:doc=data check;
   output wire   [KMAX_MSI_TDATA_WIDTH_CHK-1:0]               axis_msi_m_tdata_chk,
  /*BSF_IF_END:msi_axi_m_if;*/

  //------------------------------------------------------------------------------
  // LTI Completion MSI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:ltic_tx_msi_if,core_clk,core_rst_n,ipio=0,
    dis=LTI completion MSI TX Interface
  ;*/
  /*BSF:doc=Comfirmed deliverd of LTI packet
     # [0+:1] - CTAG  Tag for LTI completion.
     # [1+:2] - Port  ID Port number of LTI request.
  ;*/
   output wire [MSI_LTIC_DATA_WIDTH-1:0]                          ltic_tx_msi_data,
  //BSF:doc=data valid;
   output wire                                               ltic_tx_msi_valid,
  //BSF:doc=data check;
   output wire                                               ltic_tx_msi_data_chk,
  //BSF:doc=data valid check;
   output wire                                               ltic_tx_msi_valid_chk,
  //BSF_IF_END:ltic_tx_msi_if;

  //------------------------------------------------------------------------------
  // Delivery count MSI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:dc_tx_msi_if,core_clk,core_rst_n,ipio=0,
    dis=Delivery count MSI TX Interface
  ;*/
  //bsf:doc=valid for delivert count block;
  output wire                                                dc_tx_msi_valid,
  //bsf:doc=data for delivery count block;
  output wire [MSI_DC_DATA_WIDTH-1:0]                            dc_tx_msi_data,
  //bsf:doc=valid check for delivert count block;
  output wire                                                dc_tx_msi_valid_chk,
  //bsf:doc=data check for delivery count block;
  output wire                                                dc_tx_msi_data_chk,
  //bsf:doc= enable from delivery count to process msi packet;
//  input wire                                                 rx_send_msi_pck,
  //BSF_IF_END:dc_tx_msi_if;

  //------------------------------------------------------------------------------
  // QOS MSI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:qos_tx_msi_if,core_clk,core_rst_n,ipio=0,
    dis=Quality of service MSI TX Interface
  ;*/
  //bsf:doc=valid for qos count block;
  output wire                                              qos_tx_msi_valid,
  //bsf:doc=data for QOS count block;
  output wire [MSI_QOS_DATA_WIDTH-1:0]                     qos_tx_msi_data,
  //bsf:doc=valid check for QOS count block;
  output wire                                              qos_tx_msi_valid_chk,
  //bsf:doc=data check for QOS count block;
  output wire                                              qos_tx_msi_data_chk,
  //BSF_IF_END:qos_tx_msi_if;

  //------------------------------------------------------------------------------
  // ASF error interface
  //------------------------------------------------------------------------------

  /*BSF_IF:asf_error_injection_if,core_clk,core_rst_n,ipio=0,
    dis=ASF Error Injection Interface,
    doc=Interface to control error injection in sub-components
  ;*/
  input                                   core_clk_asf_error_inj__cmd_tvalid_i,
  input [ASF_ERROR_INJ_DATA_WIDTH-1:0]    core_clk_asf_error_inj__tdata_i,
  input [ASF_ERROR_INJ_USER_WIDTH-1:0]    core_clk_asf_error_inj__tuser_i,
   /*BSF_IF_END:asf_error_injection_if;*/

  /*BSF_IF:asf_error_injection_if,axi_clk,axi_rst_n,ipio=0,
    dis=ASF Error Injection Interface,
    doc=Interface to control error injection in sub-components
  ;*/
  input                                   axi_clk_asf_error_inj__cmd_tvalid_i,
  input [ASF_ERROR_INJ_DATA_WIDTH-1:0]    axi_clk_asf_error_inj__tdata_i,
  input [ASF_ERROR_INJ_USER_WIDTH-1:0]    axi_clk_asf_error_inj__tuser_i,
   /*BSF_IF_END:asf_error_injection_if;*/

  /*BSF_IF:asf_status_and_diag_valid,core_clk,core_rst_n,ipio=0,
    dis=ASF Status and Diagnostic output,
    doc=ASF status and diagnostic signals when error is detected in this block.
    all unused signals can be tied to zero. outputs are flopped.
  ;*/
  output                                   asf_event__valid_msi_tvalid,
  output [ASF_EVENT_TYPE_WIDTH-1:0]        asf_event__type_msi_tvalid,
  output [ASF_EVENT_COUNT_WIDTH-1:0]       asf_event__count_msi_tvalid,
  output [ASF_NODE_ID_WIDTH-1:0]           asf_event__node_id_msi_tvalid,
  output [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]  asf_event__diag_field_msi_tvalid,
  /*BSF_IF_END:asf_status_and_diag_valid;*/

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

  wire                                        pull;
  wire                                        fifo_empty;
  wire                                        fifo_full;
  wire                                        fsm_pck_sended;


  // registered versions of synchronized signals for cdc
  reg                                         r_msi_valid;
  reg                                         r_ltisc_msi_valid;
  reg [MSI_DC_DATA_WIDTH-1:0]                     r_dc_data;
  reg [MSI_LTIC_DATA_WIDTH-1:0]                    r_lti_data;
  reg [MSI_QOS_DATA_WIDTH-1:0]                    r_qos_data;

  reg                                         r_msi_valid_chk;
  reg                                         r_ltisc_msi_valid_chk;
  reg                                         r_dc_data_chk;
  reg                                         r_lti_data_chk;
  reg                                         r_qos_data_chk;


  wire                                            synced_valid;
  wire                                            fsm_ltic_bypass_axi_atu;
  wire [MSI_DC_DATA_WIDTH-1:0]                    fsm_dc_data;
  wire [MSI_LTIC_DATA_WIDTH-1:0]                  fsm_lti_data;
  wire [MSI_QOS_DATA_WIDTH-1:0]                   fsm_qos_data;
  wire                                            synced_ltic_bypass_axi_atu;
  wire [MSI_DC_DATA_WIDTH-1:0]                    synced_dc_data;
  wire [MSI_LTIC_DATA_WIDTH-1:0]                  synced_lti_data;
  wire [MSI_QOS_DATA_WIDTH-1:0]                   synced_qos_data;

  wire                                        fsm_dc_data_chk;
  wire                                        fsm_lti_data_chk;
  wire                                        fsm_qos_data_chk;
  wire                                        synced_dc_data_chk;
  wire                                        synced_lti_data_chk;
  wire                                        synced_qos_data_chk;

  wire                                        msi_valid;
  wire                                        ltic_msi_valid;

  wire [MSI_DC_DATA_WIDTH-1:0]                    dc_msi_data;
  wire [MSI_LTIC_DATA_WIDTH-1:0]                   ltic_msi_data;
  wire [MSI_QOS_DATA_WIDTH-1:0]                   qos_msi_data;

  wire                                        msi_valid_chk;
  wire                                        ltic_msi_valid_chk;
  wire                                        dc_msi_data_chk;
  wire                                        ltic_msi_data_chk;
  wire                                        qos_msi_data_chk;

  wire [IB_TDATA_WIDTH-1:0]                   synced_posted_data;
  wire [IB_TDATA_WIDTH_CHK-1:0]               synced_posted_data_chk;

  wire [PARITY_CHK_TEMP_WIDTH-1:0]            axis_msi_tvalid_chk_temp;

  reg [PACKET_CNTR_WIDTH-1:0]                 packet_cntr_core_clk; //valid_rdy counter at cdc fifo input, used to generate axi_qactiuve
  reg [PACKET_CNTR_WIDTH-1:0]                 packet_cntr_core_clk_next; // Next value for packet_cntr_core_clk
  wire                                        packet_cntr_core_clk_en;   // Enable signal for packet_cntr_core_clk
  reg [PACKET_CNTR_WIDTH-1:0]                 packet_cntr_axi_msi_clk; // valid_rdy counter at cdc_output
  reg [PACKET_CNTR_WIDTH-1:0]                 packet_cntr_axi_msi_clk_next; // Next value for packet_cntr_axi_msi_clk
  wire                                        packet_cntr_axi_msi_clk_en;   // Enable signal for packet_cntr_axi_msi_clk
  reg [PACKET_CNTR_WIDTH-1:0]                 packet_cntr_flop; // counter value registered for subtraction
  wire [PACKET_CNTR_WIDTH-1:0]                packet_cntr_flop_core_clk; // counter value registered for subtraction synchronized to core_clk
  reg [PACKET_CNTR_WIDTH-1:0]                 r_packet_cntr_flop_core_clk; // counter value registered for subtraction synchronized to core_clk
  reg                                         packet_cntr_valid_r;  // valid value registered
  wire                                        packet_cntr_cdc_rdy;  // cdc is ready for data
  wire                                        packet_cntr_cdc_valid; // cdc_valid value
  reg                                         r_packet_cntr_cdc_valid; // cdc_valid value registered version
  wire                                        packet_cntr_flop_en;
  wire                                        fsm_cdc_rdy;




  assign rx_posted_ready = !fifo_full;


 //-------------------------------------------------------
 // Input FIFO
 //-------------------------------------------------------
  async_fifo
  #(
    .CDNSDRU_ASYNC_FIFO_V0_DATA_W           (IB_TDATA_WIDTH +IB_TDATA_WIDTH_CHK),
    .CDNSDRU_ASYNC_FIFO_V0_ADDR_W           (FIFO_ADDR_WIDTH),         // depth
    .CDNSDRU_ASYNC_FIFO_V0_REG_OUTPUT_STAGE (1'b1),  // 1 - registered outputs
    .CDNSDRU_ASYNC_FIFO_V0_RESET_VAL        ({{IB_TDATA_WIDTH_CHK{1'b1}},{IB_TDATA_WIDTH{1'b0}}})
  )
    i_cdns_hls_bridge_msi_async_fifo
  (

   // Clock and Reset
   .clk_push                  (core_clk),   //input
   .clk_pop                   (axi_clk),           //input
   .reset_push_n              (core_rst_n), //input
   .reset_pop_n               (axi_rst_n),         //input

   // k_wire,s
   .k_sync_reset              (k_sync_reset),       //input //Selectes datasync reset (0: asynchronous            1: synchronous reset)
   .k_sync_cell_stages        (k_sync_cell_stages), //input // Selectes number of stages in datasync (0: 2 stages 1: 3 stages)

   // Push Interface
   .push                      (rx_posted_valid),  //input  // Push Data to the FIFO
   .pushd                     ({rx_posted_data_chk,rx_posted_data}),
                               // ,rx_posted_idg,rx_posted_vc
                               // ,rx_posted_lrctag,rx_posted_lti_port_num,rx_posted_bypass_axi_atu}),   //input  // Push Data
   .push_full                 (fifo_full), //output // Full (push side)
   .push_overflow             (), //output // Overflow
   .push_size                 (), //output // Number of entries (push side) in FIFO

   // Pop Interface
   .pop                       (pull),//input   // Pop Data from the FIFO
   .popd                      ({synced_posted_data_chk,synced_posted_data}),
                               // ,synced_posted_id,synced_posted_vc
                               // ,synced_posted_lrctag,synced_posted_lti_port_num,synced_posted_bypass_axi_atu}),//output  // Pop Data
   .pop_empty                 (fifo_empty),//output  // Empty (pop side)
   .pop_underflow             (),//output
   .pop_size                  () //output  // Number of entries (pop side) in FIFO
   );

 //-------------------------------------------------------
 // AXI-S FSM
 //-------------------------------------------------------
  hls_bridge_msi_fsm_tx
  #(
   .KMAX_MSI_TDATA_WIDTH                  (KMAX_MSI_TDATA_WIDTH),
   .IB_TDATA_WIDTH                        (IB_TDATA_WIDTH),
   // ------------------ ASF-------------------------------
   .ASF_SUPPORT                            (ASF_SUPPORT),
   .ASF_NODE_ID_BASE                       (4096),
   .ASF_ERR_INJ_SUPPORT                    (ASF_ERR_INJ_SUPPORT),
   .ASF_ERROR_INJ_DATA_WIDTH               (56),
   .ASF_ERROR_INJ_USER_WIDTH               (8),
   .ASF_EVENT_TYPE_WIDTH                   (4),
   .ASF_EVENT_COUNT_WIDTH                  (8),
   .ASF_NODE_ID_WIDTH                      (16),
   .ASF_EVENT_DIAG_FIELD_WIDTH             (28)
  )
  i_hls_bridge_msi_fsm_tx
  (
   .axi_clk                       (axi_clk),
   .axi_rst_n                     (axi_rst_n),

   .pull                          (pull),//input wire
   .fifo_empty                    (fifo_empty),//input wire
   .synced_posted_data            (synced_posted_data),//input wire [KMAX_MSI_TDATA_WIDTH-1:0]
   .synced_posted_data_chk        (synced_posted_data_chk),//input wire [KMAX_MSI_TDATA_WIDTH_CHK-1:0]
   //.synced_posted_vc              (synced_posted_vc),//input wire [2:0]
   //.synced_posted_id              (synced_posted_id),//input wire [2:0]
   //.synced_posted_lrctag          (synced_posted_lrctag),//input wire
   //.synced_posted_lti_port_num    (synced_posted_lti_port_num),//input wire [2:0]
   //.synced_posted_bypass_axi_atu  (synced_posted_bypass_axi_atu),//input wire

   .cdc_rdy                       (fsm_cdc_rdy),
   .pck_sended                    (fsm_pck_sended),//output wire
   .dc_data                       (fsm_dc_data),//output wire [2:0]
   .lti_data                      (fsm_lti_data),//output wire [2:0]
   .qos_data                      (fsm_qos_data),//output wire [3:0]

   .dc_data_chk                   (fsm_dc_data_chk),//output wire
   .lti_data_chk                  (fsm_lti_data_chk),//output wire
   .qos_data_chk                  (fsm_qos_data_chk),//output wire

//   .enable_msi_pck                  (send_msi_pck),
   //.dc_vc                         (fsm_dc_vc),//output wire [2:0]
   //.dc_id                         (fsm_dc_id),//output wire [2:0]

   .ltic_bypass_axi_atu           (fsm_ltic_bypass_axi_atu),//output wire
   //.ltic_ctag                     (fsm_ltic_ctag),//output wire
   //.ltic_id                       (fsm_ltic_id),//output wire [2:0]

   .axis_msi_m_tvalid             (axis_msi_m_tvalid),
  // .axis_msi_m_tvalid_chk         (axis_msi_m_tvalid_chk),
   .axis_msi_m_tready             (axis_msi_m_tready),
   .axis_msi_m_tready_chk         (axis_msi_m_tready_chk),
   .axis_msi_m_tdata              (axis_msi_m_tdata),
   .axis_msi_m_tdata_chk          (axis_msi_m_tdata_chk ),
   .axis_msi_m_twakeup            (axis_msi_m_twakeup),
   .axis_msi_m_twakeup_chk        (axis_msi_m_twakeup_chk),


   // ASF -----------------------------
   .axi_clk_asf_error_inj__cmd_tvalid_i    (axi_clk_asf_error_inj__cmd_tvalid_i),//input
   .axi_clk_asf_error_inj__tdata_i         (axi_clk_asf_error_inj__tdata_i),//input [ASF_ERROR_INJ_DATA_WIDTH-1:0]
   .axi_clk_asf_error_inj__tuser_i         (axi_clk_asf_error_inj__tuser_i),//input [ASF_ERROR_INJ_USER_WIDTH-1:0]

   .asf_event__valid_msi_tdata             (asf_event__valid_msi_tdata),//output [DC_ASF_EVENT_VALID_WIDTH-1:0]
   .asf_event__type_msi_tdata              (asf_event__type_msi_tdata),//output [DC_ASF_EVENT_TYPE_WIDTH-1:0]
   .asf_event__count_msi_tdata             (asf_event__count_msi_tdata),//output [DC_ASF_EVENT_COUNT_WIDTH-1:0]
   .asf_event__node_id_msi_tdata           (asf_event__node_id_msi_tdata),//output [DC_ASF_NODE_ID_WIDTH-1:0]
   .asf_event__diag_field_msi_tdata        (asf_event__diag_field_msi_tdata)//output [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]
  );

 //-------------------------------------------------------
 // TX cdc sync
 //-------------------------------------------------------
  cdnsdru_bus_sync_v2 # (
  .CDNSDRU_BUS_SYNC_DWIDTH         (CDC_BUS_WIDTH),//= 32,    // Width of bus to transfer
  .CDNSDRU_BUS_SYNC_REG_OUT        (1'b1),//= 1'b0,  // Decide whether or not to register output
  // The features below are for simulation purposes only.
  .CDNSDRU_BUS_SYNC_REALISTIC_MODE (1'b0)//= 1'b0   // Vunit randomisation mode: 0=pessimistic(default), 1=realistic
  )
  i_cdns_hls_bridge_msi_pck_conf_sync
  (
   .src_clk                        (axi_clk),//input                           // Clock of source domain
   .src_rst_n                      (axi_rst_n),//input                         // Asynchronous reset
   .dest_clk                       (core_clk),//input                   // clock of destination domain
   .dest_rst_n                     (core_rst_n),//input                 // Asynchronous reset
   .src_data                       ({fsm_ltic_bypass_axi_atu,
                                     fsm_dc_data,
                                     fsm_dc_data_chk,
                                     fsm_lti_data,
                                     fsm_lti_data_chk,
                                     fsm_qos_data,
                                     fsm_qos_data_chk}),//input [CDNSDRU_BUS_SYNC_DWIDTH-1:0]        // Data to be synchronised
   //.src_data                       ({fsm_dc_vc,fsm_dc_id
   //                                  ,fsm_ltic_ctag,fsm_ltic_id,fsm_ltic_bypass_axi_atu}),//input [CDNSDRU_BUS_SYNC_DWIDTH-1:0]        // Data to be synchronised
   .src_xfer_en                    (fsm_pck_sended),//input                       // Signal to enable transfer
   .src_data_last                  (),   //output  [CDNSDRU_BUS_SYNC_DWIDTH-1:0]  // Last captured data
   .src_rdy                        (fsm_cdc_rdy),//output                   // Ready to accept new data
   .dest_data                      ({synced_ltic_bypass_axi_atu,
                                     synced_dc_data,
                                     synced_dc_data_chk,
                                     synced_lti_data,
                                     synced_lti_data_chk,
                                     synced_qos_data,
                                     synced_qos_data_chk}),//output  [CDNSDRU_BUS_SYNC_DWIDTH-1:0]                                // Data in destination clock domain
   //.dest_data                      ({synced_dc_vc,synced_dc_id
   //                                 ,synced_ltic_ctag,synced_ltic_id,synced_ltic_bypass_axi_atu}),//output  [CDNSDRU_BUS_SYNC_DWIDTH-1:0]                                // Data in destination clock domain
   .dest_val                       (synced_valid),//output              // Pulse to indicate new data avail
   .k_sync_reset                   (k_sync_reset),//input        1: synchronous reset)
   .k_sync_cell_stages             (k_sync_cell_stages)//input   1: 3 stages)
   );

  //hls_bridge_msi_pck_conf
  //i_hls_bridge_msi_pck_conf
  //(
  //  // inputs
  // .valid                         (synced_valid),
  // .dc_vc                         (synced_dc_vc),//input wire [2:0]
  // .dc_id                         (synced_dc_id),//input wire [2:0]
  // .ltic_bypass_axi_atu           (synced_ltic_bypass_axi_atu),//input wire
  // .ltic_ctag                     (synced_ltic_ctag),//input wire
  // .ltic_id                       (synced_ltic_id),//input wire [2:0]

  //  //outpus
  // .dc_tx_data                    (dc_tx_msi_data),//output wire
  // .dc_tx_vc                      (dc_tx_msi_vc),//output wire [2:0]
  // .dc_tx_id                      (dc_tx_msi_idg),//output wire [2:0]
  // .ltic_tx_data                  (ltic_tx_msi_data),//output wire
  // .ltic_tx_ctag                  (ltic_tx_msi_ctag),//output wire
  // .ltic_tx_id                    (ltic_tx_msi_idg)   //output wire [2:0]
  //);


  // -------------------------------------------------------------
  // core clk functionality
  // -------------------------------------------------------------
  always @(posedge core_clk or negedge core_rst_n)
  begin : PACKET_CNTR_FLOP_CORE_CLK_R_PROC
    if (!core_rst_n)
      r_packet_cntr_flop_core_clk <= {PACKET_CNTR_WIDTH{1'b0}};
    else if (packet_cntr_cdc_valid)
      r_packet_cntr_flop_core_clk <= packet_cntr_flop_core_clk;
  end

  always @(posedge core_clk or negedge core_rst_n)
  begin : PACKET_CNTR_CDC_VALID_R_PROC
    if (!core_rst_n)
      r_packet_cntr_cdc_valid <= 1'b0;
    else
      r_packet_cntr_cdc_valid <= packet_cntr_cdc_valid;
  end

  // Enable signal for packet_cntr_core_clk
  assign packet_cntr_core_clk_en = (rx_posted_valid && rx_posted_ready) || r_packet_cntr_cdc_valid;

  // Combinational logic for packet_cntr_core_clk
  always @(*) begin : PACKET_CNTR_CORE_CLK_COMB_PROC
    if (rx_posted_valid && rx_posted_ready) begin
      if (r_packet_cntr_cdc_valid)
        packet_cntr_core_clk_next = packet_cntr_core_clk - r_packet_cntr_flop_core_clk + {{(PACKET_CNTR_WIDTH-1){1'b0}}, 1'b1};
      else
        packet_cntr_core_clk_next = packet_cntr_core_clk + {{(PACKET_CNTR_WIDTH-1){1'b0}}, 1'b1};
    end
    else if (r_packet_cntr_cdc_valid)
      packet_cntr_core_clk_next = packet_cntr_core_clk - r_packet_cntr_flop_core_clk;
    else
      packet_cntr_core_clk_next = packet_cntr_core_clk;
  end

  // Sequential logic for packet_cntr_core_clk
  always @(posedge core_clk or negedge core_rst_n)
  begin : PACKET_CNTR_CORE_CLK_SEQ_PROC
    if (!core_rst_n)
      packet_cntr_core_clk <= {PACKET_CNTR_WIDTH{1'b0}};
    else if (packet_cntr_core_clk_en)
      packet_cntr_core_clk <= packet_cntr_core_clk_next;
  end

  //Assignment of qactive
  assign axi_qactive = |packet_cntr_core_clk;

  // CDC valid_rdy
  cdnsdru_bus_sync_v2 #(
    .CDNSDRU_BUS_SYNC_DWIDTH  (PACKET_CNTR_WIDTH),
    .CDNSDRU_BUS_SYNC_REG_OUT (1'b1)
  ) i_packet_cntr_flop_sync (
    .src_clk       (axi_clk),        // Clock of source domain
    .src_rst_n     (axi_rst_n),      // Asynchronous reset
    .dest_clk      (core_clk),       // clock of destination domain
    .dest_rst_n    (core_rst_n),     // Asynchronous reset
    .src_data      (packet_cntr_flop),       // Data to be synchronised
    .src_xfer_en   (packet_cntr_valid_r),    // Signal to enable transfer
    .src_data_last (),  // Last captured data - not used intentionally
    .src_rdy       (packet_cntr_cdc_rdy),        // Ready to accept new data
    .dest_data     (packet_cntr_flop_core_clk),      // Data in destination clock domain
    .dest_val      (packet_cntr_cdc_valid),       // Pulse to indicate new data avail
    .k_sync_reset  (1'h0),   //Selectes datasync reset (0: asynchronous, 1: synchronous reset)
    .k_sync_cell_stages (1'h0) // 2 stages of sync
  );


  assign packet_cntr_flop_en = !packet_cntr_valid_r &  (packet_cntr_axi_msi_clk > {PACKET_CNTR_WIDTH{1'b0}}) &(fifo_empty ||
                                                      (packet_cntr_axi_msi_clk >= {{(PACKET_CNTR_WIDTH-THRESHOLD_WIDTH){1'b0}}, PACKET_CNTR_THRESHOLD}));

  always @(posedge axi_clk or negedge axi_rst_n)
  begin
    if (!axi_rst_n)
      packet_cntr_flop <= {PACKET_CNTR_WIDTH{1'b0}};
    else if (packet_cntr_flop_en)
      packet_cntr_flop <= packet_cntr_axi_msi_clk;
  end

  always @(posedge axi_clk or negedge axi_rst_n)
  begin
    if (!axi_rst_n)
      packet_cntr_valid_r <= 1'b0;
    else begin
      if (packet_cntr_valid_r && packet_cntr_cdc_rdy)
        packet_cntr_valid_r <= 1'b0;
      else if (packet_cntr_flop_en )
        packet_cntr_valid_r <= 1'b1;
    end
  end

  // Enable signal for packet_cntr_axi_msi_clk
  assign packet_cntr_axi_msi_clk_en = (packet_cntr_cdc_rdy && packet_cntr_valid_r) || (axis_msi_m_tready && axis_msi_m_tvalid);

  // Combinational logic for packet_cntr_axi_msi_clk
  always @(*) begin
    if (packet_cntr_cdc_rdy && packet_cntr_valid_r) begin
      if (axis_msi_m_tready && axis_msi_m_tvalid) // transfer from fifo.
        packet_cntr_axi_msi_clk_next = packet_cntr_axi_msi_clk - packet_cntr_flop + {{(PACKET_CNTR_WIDTH-1){1'b0}}, 1'b1};
      else
        packet_cntr_axi_msi_clk_next = packet_cntr_axi_msi_clk - packet_cntr_flop;
    end
    else if (axis_msi_m_tready && axis_msi_m_tvalid) // transfer from fifo.
      packet_cntr_axi_msi_clk_next = packet_cntr_axi_msi_clk + {{(PACKET_CNTR_WIDTH-1){1'b0}}, 1'b1};
    else
      packet_cntr_axi_msi_clk_next = packet_cntr_axi_msi_clk;
  end

  // Sequential logic for packet_cntr_axi_msi_clk
  always @(posedge axi_clk or negedge axi_rst_n)
  begin
    if (!axi_rst_n)
      packet_cntr_axi_msi_clk <= {PACKET_CNTR_WIDTH{1'b0}};
    else if (packet_cntr_axi_msi_clk_en)
      packet_cntr_axi_msi_clk <= packet_cntr_axi_msi_clk_next;
  end


 //-------------------------------------------------------
 // valid output logic
 //-------------------------------------------------------
  assign msi_valid     = synced_valid;
  assign msi_valid_chk = ~synced_valid;

  // delivery count data
  assign dc_msi_data     = synced_valid ? synced_dc_data     : {MSI_DC_DATA_WIDTH{1'b0}} ;
  assign dc_msi_data_chk = synced_valid ? synced_dc_data_chk : 1'd1 ;

  // QOS data
  assign qos_msi_data     = synced_valid ? synced_qos_data     : {MSI_QOS_DATA_WIDTH{1'b0}} ;
  assign qos_msi_data_chk = synced_valid ? synced_qos_data_chk : 1'd1 ;

  //lti completion data
  assign ltic_msi_data     = synced_ltic_bypass_axi_atu && synced_valid ? synced_lti_data     : {MSI_LTIC_DATA_WIDTH{1'b0}};
  assign ltic_msi_data_chk = synced_ltic_bypass_axi_atu && synced_valid ? synced_lti_data_chk : 1'b1;

  assign ltic_msi_valid     = synced_ltic_bypass_axi_atu && synced_valid;
  assign ltic_msi_valid_chk = ~(synced_ltic_bypass_axi_atu && synced_valid);


 //-------------------------------------------------------
 // FF
 //-------------------------------------------------------
  always @(posedge core_clk or negedge core_rst_n) begin
    if (!core_rst_n) begin
      r_msi_valid           <= 1'b0 ;
      r_ltisc_msi_valid     <= 1'b0 ;

      r_msi_valid_chk       <= 1'b1 ;
      r_ltisc_msi_valid_chk <= 1'b1 ;
    end else begin
      r_msi_valid           <= msi_valid ;
      r_ltisc_msi_valid     <= ltic_msi_valid;


      r_msi_valid_chk       <= msi_valid_chk ;
      r_ltisc_msi_valid_chk <= ltic_msi_valid_chk;
    end
  end

  always @(posedge core_clk or negedge core_rst_n) begin : reg_of_mux_synced_data_proc
    if (!core_rst_n) begin
      r_dc_data             <= {MSI_DC_DATA_WIDTH{1'b0}} ;
      r_lti_data            <= {MSI_LTIC_DATA_WIDTH{1'b0}};
      r_qos_data            <= {MSI_QOS_DATA_WIDTH{1'b0}};
      r_dc_data_chk         <= 1'b1 ;
      r_lti_data_chk        <= 1'b1 ;
      r_qos_data_chk        <= 1'b1 ;
    end else if (msi_valid) begin
      r_dc_data             <= dc_msi_data     ;
      r_dc_data_chk         <= dc_msi_data_chk ;
      r_lti_data            <= ltic_msi_data    ;
      r_lti_data_chk        <= ltic_msi_data_chk;
      r_qos_data            <= qos_msi_data        ;
      r_qos_data_chk        <= qos_msi_data_chk    ;
    end
  end


 //-------------------------------------------------------
 // Assign to Output
 //-------------------------------------------------------
  assign dc_tx_msi_valid     = r_msi_valid;
  assign dc_tx_msi_valid_chk = r_msi_valid_chk;

  assign dc_tx_msi_data     =  r_dc_data    ;
  assign dc_tx_msi_data_chk =  r_dc_data_chk;

  assign qos_tx_msi_valid     = r_msi_valid;
  assign qos_tx_msi_valid_chk = r_msi_valid_chk;

  assign qos_tx_msi_data     = r_qos_data    ;
  assign qos_tx_msi_data_chk = r_qos_data_chk;

  //lti completion data
  assign ltic_tx_msi_data     = r_lti_data    ;
  assign ltic_tx_msi_data_chk = r_lti_data_chk;

  assign ltic_tx_msi_valid     = r_ltisc_msi_valid;
  assign ltic_tx_msi_valid_chk = r_ltisc_msi_valid_chk;

  assign axis_msi_m_tvalid_chk = axis_msi_tvalid_chk_temp[0];



 //-------------------------------------------------------
 // ASF
 //-------------------------------------------------------
  generate
  if (ASF_SUPPORT > 1) begin : msi_tvalid_asf
    // <mkdocs_chk_data> ID: 080 ; Checker Name: i_asf_par_080_msi_valid ; ASF Group: DAP ; Constrain: KMAX_MSI_IF_SUPPORT == 1
    asf_parity_check_and_regen_w_errinj #(
     .ASF_SUPPORT                          (ASF_SUPPORT),  // = 3,
     .ASF_NODE_ID                          (ASF_NODE_ID_BASE[15:0] +16'd80), // = 16 (HLS Bridge offset) + 80 (node ID),
     .ASF_ERR_INJ_SUPPORT                  (ASF_ERR_INJ_SUPPORT),  // = 1,
     .NUM_DATA_UNITS__CHKER                (1)
    ) i_asf_par_080_msi_valid (
     .clk                                  (core_clk),                 // input
     .rst_n                                (core_rst_n),               // input
     .chk__data_block_valid_i              (1'b1),
     .chk__data_i                          ({{ASF_PAD_WIDTH{1'b0}}  ,rx_posted_valid}),
     .chk__datachk_i                       ({3'b111 ,rx_posted_valid_chk}),
     .chk__parity_error_detected_outside_i (1'b0),
     .regen__data_block_valid_i            (1'b1),
     .regen__data_i                        ({{ASF_PAD_WIDTH{1'b0}},axis_msi_m_tvalid}),
     .regen__datachk_o                     (axis_msi_tvalid_chk_temp),

     .asf_error_inj__cmd_tvalid_i          (core_clk_asf_error_inj__cmd_tvalid_i),
     .asf_error_inj__tdata_i               (core_clk_asf_error_inj__tdata_i),
     .asf_error_inj__tuser_i               (core_clk_asf_error_inj__tuser_i),

     .asf_event__valid_o                   (asf_event__valid_msi_tvalid     ),
     .asf_event__type_o                    (asf_event__type_msi_tvalid      ),
     .asf_event__count_o                   (asf_event__count_msi_tvalid     ),
     .asf_event__node_id_o                 (asf_event__node_id_msi_tvalid   ),
     .asf_event__diag_field_o              (asf_event__diag_field_msi_tvalid)
    );
  end
  else begin :g_no_msi_tvalid_asf
    assign axis_msi_tvalid_chk_temp = 4'b1111;
  end
  endgenerate
endmodule
