module hls_bridge_delivered #(
   /////////////////////////////////////////////////////////////////////////////
   //                                Parameters                               //
   /////////////////////////////////////////////////////////////////////////////
   /*BSF:doc=HLS data path width;*/
   parameter KMAX_DATAPATH_WD                              = 1024,
   /*BSF:doc=Number of HLS ports from AXI-Bridge side;*/
   parameter NUM_HLS_PORTS                                 = 2,
   /*BSF:doc=Maximum mumber of TLPs in single HLS cycle on core side;*/
   parameter KMAX_NUM_TLPS_PER_CLK                         = 1,
   /*BSF:doc=Delivery count data path width;*/
   parameter DC_TDATA_WIDTH                                = 12,
   /*BSF:doc=Maximum possible number of VCs to support;*/
   parameter NUM_TLP_STREAMS                                = 1,
   /*BSF:doc=Support for list based buffer on DL layer;*/
   parameter LBB_SUPPORT                                   = 0,
   /*BSF:doc=Support for DTI module;*/
   parameter KMAX_DTI_SUPPORT                              = 1,
   /*BSF:doc=Support for MSI module;*/
   parameter KMAX_MSI_IF_SUPPORT                           = 1,

   parameter METADATA_IDG_WD                               = 3,
   //localparam TOTAL_NUM_OF_TLPS_PER_CLK                    = NUM_HLS_PORTS*HLS_AXI_NUM_TLPS_PER_CLK,
   //localparam PCK_COUNT_WIDTH_AXI                          = (TOTAL_NUM_OF_TLPS_PER_CLK < 2 ) ? 1 : $clog2(TOTAL_NUM_OF_TLPS_PER_CLK),
   //localparam PCK_COUNT_WIDTH_DTI                          = (KMAX_NUM_TLPS_PER_CLK < 2) ? 1 : $clog2(KMAX_NUM_TLPS_PER_CLK),
   //localparam AXI_HLS_DATA_WD                              = KMAX_DATAPATH_WD/NUM_HLS_PORTS,
   //------------------------------------------------------------------------------
   //ASF
   //------------------------------------------------------------------------------
   /*BSF:doc=Following are the expected modes based on parameter values.;*/
   parameter ASF_SUPPORT       = 1,
   /*BSF:doc=ASF node ID. This must be unique ID across all ASF components.
     When ASF error injection command's node_id matches with this parameter, command is decoded by this block;*/
   parameter ASF_NODE_ID_BASE  = 4096,
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
   parameter ASF_EVENT_DIAG_FIELD_WIDTH     = 28,
   /*BSF:doc=Delivery count data path check width;*/
   localparam DC_TDATA_CHK_WIDTH             = (DC_TDATA_WIDTH    + 7)/8,

   localparam DC_INPUT_IF_NUMBER              = NUM_HLS_PORTS + KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT,

   localparam DC_RX_MSI_TDATA_WIDTH           = 6,

   localparam DC_ASF_EVENT_VALID_WIDTH        = DC_INPUT_IF_NUMBER,
   localparam DC_ASF_EVENT_TYPE_WIDTH         = DC_INPUT_IF_NUMBER*4,
   localparam DC_ASF_EVENT_COUNT_WIDTH        = DC_INPUT_IF_NUMBER*8,
   localparam DC_ASF_NODE_ID_WIDTH            = DC_INPUT_IF_NUMBER*16,
   localparam DC_ASF_EVENT_DIAG_FIELD_WIDTH   = DC_INPUT_IF_NUMBER*28
  )(
  /*BSF:isClock=1,clock_group="CORE",doc= Power down / Power Shut-Off Core Clock ;*/
   input core_clk,
  /*BSF:isReset=1,clock=core_clk,doc= Power down / Power Shut-Off Core Reset ;*/
   input core_rst_n,

   /*BSF:doc= Selects maximum number of AXI Master outstanding Write Requests.
      Value to set - maximum number of outstanding AXI Master Writes minus 1
      Number of outstanding should be in range [4,KMAX_AXI_M_OUTSTANDING_WRITES]
      Example: value 3 means maximum 4 outstanding AXI Master Writes
   ;*/
  // input wire [KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH-1:0]        k_axi_m_outstanding_writes_min1,

  //------------------------------------------------------------------------------
  // Sideband delivered count nterface
  //------------------------------------------------------------------------------
  /*BSF_IF:sb_ib_p_if,core_clk,core_rst_n,ipio=0,
    dis=Side-bound Posted i/f,
    doc=Information regarding poted ordering.
  ;*/
   input wire  [NUM_HLS_PORTS*KMAX_NUM_TLPS_PER_CLK-1:0]           i_tlp_route_to_axi,
   input wire  [KMAX_NUM_TLPS_PER_CLK-1:0]                         i_tlp_route_to_msi,
   input wire  [KMAX_NUM_TLPS_PER_CLK-1:0]                         i_tlp_route_to_dti,
   input wire  [KMAX_NUM_TLPS_PER_CLK*METADATA_IDG_WD-1:0]         i_tlp_stream_packed,

   output wire [NUM_HLS_PORTS-1:0]                                 sb_tx_axi_queue_empty,
   output wire                                                     sb_tx_msi_queue_empty,
   output wire                                                     sb_tx_dti_queue_empty,

   output wire [NUM_TLP_STREAMS*NUM_HLS_PORTS-1:0]                 sb_tx_axi_stream_empty,
   output wire [NUM_TLP_STREAMS-1:0]                               sb_tx_dti_stream_empty,
   output wire [NUM_TLP_STREAMS-1:0]                               sb_tx_msi_stream_empty,
  //BSF_IF_END:sb_ib_p_if;

  //------------------------------------------------------------------------------
  // AXI Sream RX delivered count nterface
  //------------------------------------------------------------------------------
  /*BSF_IF:dc_axi_s_if,core_clk,core_rst_n,ipio=0,
    dis=Posted delivery cout RX,
    doc=AXi-Stream subordinate
  ;*/
   input  wire  [NUM_HLS_PORTS-1:0]                    dc_rx_tvalid,
   input  wire  [DC_TDATA_WIDTH*NUM_HLS_PORTS-1:0]     dc_rx_tdata,
   // ------------------------------ Parity
   input  wire  [NUM_HLS_PORTS-1:0]                    dc_rx_tvalid_chk,
   input  wire  [DC_TDATA_CHK_WIDTH*NUM_HLS_PORTS-1:0] dc_rx_tdata_chk,
  //BSF_IF_END:dc_axi_s_if;

  //------------------------------------------------------------------------------
  // Delivery count MSI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:dc_rx_msi_tif,core_clk,core_rst_n,ipio=0,
    dis=Delivery count MSI RX Interface
    doc= Synced data/valid and Idg/Vc for eliverd MSI packet
  ;*/
  input wire                                           dc_rx_msi_tvalid,
  input wire [DC_RX_MSI_TDATA_WIDTH-1:0]               dc_rx_msi_tdata,
  input wire                                           dc_rx_msi_tvalid_chk,
  input wire                                           dc_rx_msi_tdata_chk,
  /*BSF_IF_END:dc_rx_msi_tif;*/

  //------------------------------------------------------------------------------
  // AXI Sream RX delivered count nterface
  //------------------------------------------------------------------------------
  /*BSF_IF:dc_rx_dti_if,core_clk,core_rst_n,ipio=0,
    dis=Posted delivery cout RX,
    doc=AXi-Stream subordinate
  ;*/
   input  wire                                         dc_rx_dti_tvalid,
   input  wire  [DC_TDATA_WIDTH-1:0]                   dc_rx_dti_tdata,
   // ------------------------------ Parity
   input  wire                                         dc_rx_dti_tvalid_chk,
   input  wire  [DC_TDATA_CHK_WIDTH-1:0]               dc_rx_dti_tdata_chk,
  //BSF_IF_END:dc_rx_dti_if;
  //------------------------------------------------------------------------------

  // AXI Sream TX delivered count nterface
  //------------------------------------------------------------------------------
  /*BSF_IF:dc_axi_m_if,core_clk,core_rst_n,ipio=0,
    dis=Posted delivery cout TX,
    doc=AXI-Stream manager
  ;*/
   output wire                                         dc_tx_tvalid,
   output wire  [DC_TDATA_WIDTH-1:0]                   dc_tx_tdata,
  // ------------------------------ Parity
   output wire                                         dc_tx_tvalid_chk,
   output wire  [DC_TDATA_CHK_WIDTH-1:0]               dc_tx_tdata_chk,
  //BSF_IF_END:dc_axi_m_if;

  //------------------------------------------------------------------------------
  // ASF error interface
  //------------------------------------------------------------------------------

  /*BSF_IF:asf_error_injection_if,core_clk,core_rst_n,ipio=0,
    dis=ASF Error Injection Interface,
    doc=Interface to control error injection in sub-components
  ;*/
  input                                      asf_error_inj__cmd_tvalid_i,
  input [ASF_ERROR_INJ_DATA_WIDTH-1:0]       asf_error_inj__tdata_i,
  input [ASF_ERROR_INJ_USER_WIDTH-1:0]       asf_error_inj__tuser_i,
   /*BSF_IF_END:asf_error_injection_if;*/

  /*BSF_IF:asf_status_and_diag_valid,core_clk,core_rst_n,ipio=0,
    dis=ASF Status and Diagnostic output,
    doc=ASF status and diagnostic signals when error is detected in this block.
    all unused signals can be tied to zero. outputs are flopped.
  ;*/
  output [DC_ASF_EVENT_VALID_WIDTH-1:0]       asf_event__valid_dc_tvalid,
  output [DC_ASF_EVENT_TYPE_WIDTH-1:0]        asf_event__type_dc_tvalid,
  output [DC_ASF_EVENT_COUNT_WIDTH-1:0]       asf_event__count_dc_tvalid,
  output [DC_ASF_NODE_ID_WIDTH-1:0]           asf_event__node_id_dc_tvalid,
  output [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]  asf_event__diag_field_dc_tvalid,
  /*BSF_IF_END:asf_status_and_diag_valid;*/

  /*BSF_IF:asf_status_and_diag_data,core_clk,core_rst_n,ipio=0,
    dis=ASF Status and Diagnostic output,
    doc=ASF status and diagnostic signals when error is detected in this block.
    all unused signals can be tied to zero. outputs are flopped.
  ;*/
  output [DC_ASF_EVENT_VALID_WIDTH-1:0]       asf_event__valid_dc_tdata,
  output [DC_ASF_EVENT_TYPE_WIDTH-1:0]        asf_event__type_dc_tdata,
  output [DC_ASF_EVENT_COUNT_WIDTH-1:0]       asf_event__count_dc_tdata,
  output [DC_ASF_NODE_ID_WIDTH-1:0]           asf_event__node_id_dc_tdata,
  output [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]  asf_event__diag_field_dc_tdata
  /*BSF_IF_END:asf_status_and_diag_data;*/
 );

  //----------------------------------------------------------------------------
  // Internal params
  //----------------------------------------------------------------------------
 // localparam NUM_TLP_STREAMS_SHIFT   = LBB_SUPPORT == 1 ? $clog2(NUM_TLP_STREAMS)  : 1;
  localparam NUM_TLP_STREAMS_OTPUT_SHIFT = NUM_TLP_STREAMS>1 ? $clog2(NUM_TLP_STREAMS) : 1;
  localparam SUM_WIDTH            = 9;

  // DC data field layout within dc_rx_tdata / dc_rx_dti_tdata:
  localparam TLP_STREAM_FIELD_WD  = 3;          // width of stream ID field

  // MSI tdata field layout (dc_rx_msi_tdata):
  localparam MSI_TDATA_OFF     = DC_RX_MSI_TDATA_WIDTH - TLP_STREAM_FIELD_WD; // bit 3

  // msi_event register width (one bit per Stream ID)
  localparam MSI_EVENT_WIDTH       = 7;

  // Stream-enable one-hot vector width (one bit per NUM_TLP_STREAMS slot)
  localparam STREAM_EN_WIDTH       = 8;

  localparam DC_LOCAL_WIDTH_1     = DC_TDATA_WIDTH - NUM_TLP_STREAMS * SUM_WIDTH;
 // localparam DC_LOCAL_WIDTH_2     = DC_TDATA_WIDTH -PCK_COUNT_WIDTH_AXI;
  //localparam AXI_CONTER_SIZE      = $clog2(KMAX_AXI_M_OUTSTANDING_WRITES);

  //----------------------------------------------------------------------------
  // Internal regs
  //----------------------------------------------------------------------------
  reg  [NUM_TLP_STREAMS-1:0]                                   clear_count;

  reg  [DC_TDATA_WIDTH-1:0]                                    dc_tx_data_reg;
  reg                                                          dc_tx_tvalid_reg;

  reg  [DC_TDATA_WIDTH-1:0]                                    dc_data_reg;
  reg  [DC_TDATA_CHK_WIDTH-1:0]                                dc_data_chk_reg;
  reg                                                          dc_tvalid_reg;

  reg [STREAM_EN_WIDTH-1:0]                                    tlp_stream_en [NUM_HLS_PORTS-1:0];

  reg [STREAM_EN_WIDTH-1:0]                                     msi_tlp_stream_en;
  reg [NUM_TLP_STREAMS-1:0]                                     msi_add_en;

  reg [STREAM_EN_WIDTH-1:0]                                     dti_tlp_stream_en;
  reg [NUM_TLP_STREAMS-1:0]                                          dti_add_en;

  reg                                                           tx_tvalid_reg;
  reg                                                           tx_tvalid_chk_reg;
  reg [DC_TDATA_CHK_WIDTH-1:0]                                  tx_tdata_chk_reg;

  reg  [2:0]                                                    axi_sop_tlp[NUM_HLS_PORTS-1:0];
  reg  [2:0]                                                    dti_sop_tlp;
  reg  [2:0]                                                    msi_sop_tlp;
  wire [MSI_EVENT_WIDTH-1:0]                                    msi_event_next;
  reg  [MSI_EVENT_WIDTH-1:0]                                    msi_event;

  wire [SUM_WIDTH-1:0]                                          sop_counter_dti_next;
  reg  [SUM_WIDTH-1:0]                                          sop_counter_dti_ff;

  reg  [SUM_WIDTH-1:0]                                          sop_counter_axi_next[NUM_HLS_PORTS-1:0];
  reg  [SUM_WIDTH-1:0]                                          sop_counter_axi_ff [NUM_HLS_PORTS-1:0];

  //----------------------------------------------------------------------------
  // Internal signals
  //----------------------------------------------------------------------------
  wire                                                          tx_tvalid;
  wire [DC_INPUT_IF_NUMBER*4-1:0]                               tx_tvalid_chk;
  wire [DC_INPUT_IF_NUMBER*4-1:0]                               tx_tdata_chk;

  wire [SUM_WIDTH-1:0]                                          data_add;
  wire [TLP_STREAM_FIELD_WD-1:0]                                tlp_stream [NUM_HLS_PORTS-1:0];
  wire [SUM_WIDTH-1:0]                                          dc_data    [NUM_HLS_PORTS-1:0];

  wire [TLP_STREAM_FIELD_WD-1:0]                        msi_tlp_stream;
  wire [TLP_STREAM_FIELD_WD-1:0]                        dti_tlp_stream;
  wire [SUM_WIDTH-1:0]                                          dti_dc_data;
  wire [SUM_WIDTH-1:0]                                          dti_valid_data;

  wire [SUM_WIDTH-1:0]                                          valid_dc_data [NUM_HLS_PORTS-1:0];
  wire [DC_TDATA_WIDTH-1:0]                                     output_count_tab [NUM_TLP_STREAMS-1:0];
  wire [DC_TDATA_CHK_WIDTH-1:0]                                 output_count_tab_chk [NUM_TLP_STREAMS-1:0];

  wire [NUM_HLS_PORTS*NUM_TLP_STREAMS-1:0]                      counter_en;

  wire                                                          tx_msi_queue_empty;
  wire                                                          tx_dti_queue_empty;
  reg  [NUM_HLS_PORTS-1:0]                                      tx_axi_queue_empty;
  wire [NUM_TLP_STREAMS*DC_TDATA_WIDTH-1:0]                     output_count;
  wire [SUM_WIDTH-1:0]                                          dc_count;
  wire [NUM_TLP_STREAMS*DC_TDATA_CHK_WIDTH-1:0]                 output_count_chk;



  //------------------------------------------------------------------------------
  // Colectind data from stream IF
  //------------------------------------------------------------------------------
  genvar gv_x;
  genvar n,cout_out;
  genvar asf_input_if_num;
  generate
    for (n=0 ; n<NUM_HLS_PORTS; n=n+1) begin : vc_id_valid
      assign dc_data   [n] =  dc_rx_tdata [n*DC_TDATA_WIDTH    +: SUM_WIDTH];
      assign tlp_stream[n] = (LBB_SUPPORT==1) ? dc_rx_tdata [n*DC_TDATA_WIDTH+SUM_WIDTH +: TLP_STREAM_FIELD_WD] : {TLP_STREAM_FIELD_WD{1'b0}};

      assign valid_dc_data[n] = (dc_rx_tvalid [n] == 1'b1) ? dc_data[n] : {SUM_WIDTH{1'b0}};

    end
  endgenerate

  assign  dti_dc_data   = dc_rx_dti_tdata [0  +: SUM_WIDTH];
  assign  dti_tlp_stream = (LBB_SUPPORT==1) ? dc_rx_dti_tdata [SUM_WIDTH +: TLP_STREAM_FIELD_WD] : {TLP_STREAM_FIELD_WD{1'b0}};

  assign  dti_valid_data = (dc_rx_dti_tvalid == 1'b1) ? dti_dc_data : {SUM_WIDTH{1'b0}};

  assign  msi_tlp_stream = dc_rx_msi_tvalid ? dc_rx_msi_tdata[MSI_TDATA_OFF +: TLP_STREAM_FIELD_WD] : {TLP_STREAM_FIELD_WD{1'b0}};

  //------------------------------------------------------------------------------
  // SOP decoder
  //------------------------------------------------------------------------------
  integer sop_axi,sop_dti,sop_msi;
  always @(i_tlp_route_to_axi) begin : axi_sop_adder
  integer i;
    for (i=0 ; i<NUM_HLS_PORTS ; i=i+1) begin
    axi_sop_tlp[i] = 3'h0;
      for (sop_axi=0 ; sop_axi<KMAX_NUM_TLPS_PER_CLK ; sop_axi=sop_axi+1) begin
        if (i_tlp_route_to_axi[sop_axi +i*KMAX_NUM_TLPS_PER_CLK])
          axi_sop_tlp[i] = axi_sop_tlp[i] +3'h1;
      end
    end
  end

  always @(i_tlp_route_to_dti) begin
    dti_sop_tlp = 3'h0;
    for (sop_dti=0 ; sop_dti<KMAX_NUM_TLPS_PER_CLK ; sop_dti=sop_dti+1) begin
      if (i_tlp_route_to_dti[sop_dti])
        dti_sop_tlp = dti_sop_tlp +3'h1;
    end
  end

  always @(i_tlp_route_to_msi) begin
    msi_sop_tlp = 3'h0;
    for (sop_msi=0 ; sop_msi<KMAX_NUM_TLPS_PER_CLK ; sop_msi=sop_msi+1) begin
      if (i_tlp_route_to_msi[sop_msi])
        msi_sop_tlp = msi_sop_tlp +3'h1;
    end
  end

  //------------------------------------------------------------------------------
  // Packet counter for DTI
  //------------------------------------------------------------------------------
  assign sop_counter_dti_next = sop_counter_dti_ff +dti_sop_tlp -dti_valid_data;
  always @(posedge core_clk or negedge core_rst_n) begin
    if (core_rst_n == 1'b0) begin
      sop_counter_dti_ff   <= {SUM_WIDTH{1'b0}};
    end
    else if (|i_tlp_route_to_dti || dc_rx_dti_tvalid) begin
      sop_counter_dti_ff   <= sop_counter_dti_next;
    end
  end

  //------------------------------------------------------------------------------
  //Number of MSI events/packet counter
  //------------------------------------------------------------------------------
  assign msi_event_next = msi_event +msi_sop_tlp -dc_rx_msi_tvalid;

  always @(posedge core_clk or negedge core_rst_n) begin
    if (core_rst_n == 1'b0) begin
      msi_event <= {MSI_EVENT_WIDTH{1'b0}};
    end
    else if(|i_tlp_route_to_msi || dc_rx_msi_tvalid) begin
      msi_event <= msi_event_next;
    end
  end

  //------------------------------------------------------------------------------
  // Packet counter for AXI bridge
  //------------------------------------------------------------------------------
  always @(*) begin : sop_counter_axi_next_c_proc
    integer i;
    for (i=0 ; i<NUM_HLS_PORTS ; i=i+1) begin
      sop_counter_axi_next[i] = sop_counter_axi_ff[i] +axi_sop_tlp[i] -valid_dc_data[i];
    end
  end
   
  always @(posedge core_clk or negedge core_rst_n) begin : axi_counter
    integer i;
    if (core_rst_n == 1'b0) begin
      for (i=0 ; i<NUM_HLS_PORTS ; i=i+1)
        sop_counter_axi_ff[i]   <= {SUM_WIDTH{1'b0}};
    end
    else  begin
      for (i=0 ; i<NUM_HLS_PORTS ; i=i+1)
        sop_counter_axi_ff[i] <= sop_counter_axi_next[i];
    end
  end

  always @(*) begin : axi_q_empty
  integer i; 
    for (i=0 ; i<NUM_HLS_PORTS ; i=i+1) begin 
      if (sop_counter_axi_ff[i]=={SUM_WIDTH{1'b0}})
        tx_axi_queue_empty[i] = 1'b1;
      else 
        tx_axi_queue_empty[i] = 1'b0;
    end
  end


  assign tx_dti_queue_empty = sop_counter_dti_ff=={SUM_WIDTH{1'b0}} ? 1'b1 : 1'b0;
  assign tx_msi_queue_empty = msi_event         =={MSI_EVENT_WIDTH{1'b0}} ? 1'b1 : 1'b0;

  //------------------------------------------------------------------------------
  // assign to output
  //------------------------------------------------------------------------------
  assign sb_tx_axi_queue_empty  = tx_axi_queue_empty;
  assign sb_tx_msi_queue_empty  = tx_msi_queue_empty;
  assign sb_tx_dti_queue_empty  = tx_dti_queue_empty;

  generate
  if  (LBB_SUPPORT == 1) begin : list_based_buffer_on
   reg [STREAM_EN_WIDTH-1:0]                hal_tlp_stream_en[KMAX_NUM_TLPS_PER_CLK-1:0];
   reg [KMAX_NUM_TLPS_PER_CLK-1:0]          hal_tlp_stream_en_reflect[NUM_TLP_STREAMS-1:0];
   reg [NUM_TLP_STREAMS*NUM_HLS_PORTS-1:0]  axi_stream_empty;
   reg [NUM_TLP_STREAMS_OTPUT_SHIFT-1:0]    rr_counter;
   
   reg [KMAX_NUM_TLPS_PER_CLK-1:0]          tlp_stream_valid;
   wire [NUM_HLS_PORTS-1:0]                 temp_axi_stream_empty_tab [NUM_TLP_STREAMS-1:0];

   wire [NUM_TLP_STREAMS*NUM_HLS_PORTS-1:0] temp_axi_stream_empty;

    always @(*) begin : gen_tlp_stream_valid
    integer i;
      tlp_stream_valid = i_tlp_route_to_msi | i_tlp_route_to_dti;

      for (i = 0; i < NUM_HLS_PORTS; i = i + 1)
        tlp_stream_valid =  tlp_stream_valid |
                            i_tlp_route_to_axi[i*KMAX_NUM_TLPS_PER_CLK +: KMAX_NUM_TLPS_PER_CLK];
    end

   //------------------------------------------------------------------------------
   // MSI TLP_Stream delivered
   //------------------------------------------------------------------------------
   always @(*) begin
     if (dc_rx_msi_tvalid == 1'b1) begin
       case (msi_tlp_stream)
         3'b000:  msi_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b000;
         3'b001:  msi_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b001;
         3'b010:  msi_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b010;
         3'b011:  msi_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b011;
         3'b100:  msi_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b100;
         3'b101:  msi_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b101;
         3'b110:  msi_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b110;
         3'b111:  msi_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b111;
         default: msi_tlp_stream_en = {STREAM_EN_WIDTH{1'b0}};
       endcase
     end
     else begin
       msi_tlp_stream_en = {STREAM_EN_WIDTH{1'b0}};
     end
   end

   //------------------------------------------------------------------------------
   // DTI TLP_Stream delivered
   //------------------------------------------------------------------------------
   always @(*) begin
     if (dc_rx_dti_tvalid == 1'b1) begin
       case (dti_tlp_stream)
         3'b000:  dti_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b000;
         3'b001:  dti_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b001;
         3'b010:  dti_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b010;
         3'b011:  dti_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b011;
         3'b100:  dti_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b100;
         3'b101:  dti_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b101;
         3'b110:  dti_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b110;
         3'b111:  dti_tlp_stream_en = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b111;
         default: dti_tlp_stream_en = {STREAM_EN_WIDTH{1'b0}};
       endcase
     end
     else
       dti_tlp_stream_en = {STREAM_EN_WIDTH{1'b0}};
   end

   //------------------------------------------------------------------------------
   // AXI TLP_Stream delivered
   //------------------------------------------------------------------------------
   // generate onehot from Stream ID from HLS i/f
   for (n=0 ; n<NUM_HLS_PORTS ; n=n+1) begin : dc_rx_stream_decoder
     always @(*) begin
       if (dc_rx_tvalid[n] == 1'b1) begin
         case (tlp_stream[n])
           3'b000:  tlp_stream_en [n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b000;
           3'b001:  tlp_stream_en [n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b001;
           3'b010:  tlp_stream_en [n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b010;
           3'b011:  tlp_stream_en [n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b011;
           3'b100:  tlp_stream_en [n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b100;
           3'b101:  tlp_stream_en [n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b101;
           3'b110:  tlp_stream_en [n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b110;
           3'b111:  tlp_stream_en [n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b111;
           default: tlp_stream_en [n] = {STREAM_EN_WIDTH{1'b0}};
         endcase
       end
       else
         tlp_stream_en [n] = {STREAM_EN_WIDTH{1'b0}};
     end
   end// FOR NUM_HLS_PORTS

    //------------------------------------------------------------------------------
    // Hal packed sended  by IB block
    //------------------------------------------------------------------------------
    for (n=0 ; n<KMAX_NUM_TLPS_PER_CLK ; n=n+1) begin : gen_tlp_in_stream_decoder
      always @(*) begin : tlp_stream_hal
        if (tlp_stream_valid[n] == 1'b1) begin
          case (i_tlp_stream_packed[n*3 +: 3])
            3'b000:  hal_tlp_stream_en[n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b000;
            3'b001:  hal_tlp_stream_en[n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b001;
            3'b010:  hal_tlp_stream_en[n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b010;
            3'b011:  hal_tlp_stream_en[n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b011;
            3'b100:  hal_tlp_stream_en[n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b100;
            3'b101:  hal_tlp_stream_en[n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b101;
            3'b110:  hal_tlp_stream_en[n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b110;
            3'b111:  hal_tlp_stream_en[n] = {{STREAM_EN_WIDTH-1{1'b0}}, 1'b1} << 3'b111;
            default: hal_tlp_stream_en[n] = {STREAM_EN_WIDTH{1'b0}};
          endcase
        end
        else
          hal_tlp_stream_en[n] = {STREAM_EN_WIDTH{1'b0}};
      end
    end// FOR KMAX_NUM_TLPS_PER_CLK

    //------------------------------------------------------------------------------
    // TAB reflect 
    //------------------------------------------------------------------------------
    always @(*) begin : gen_hal_steam_tab_reflect
    integer i,j;
    for (j=0 ; j<NUM_TLP_STREAMS ; j=j+1)
      hal_tlp_stream_en_reflect[j] = {KMAX_NUM_TLPS_PER_CLK{1'b0}};

      for (i=0 ; i<KMAX_NUM_TLPS_PER_CLK ; i=i+1) begin
        for (j=0 ; j<NUM_TLP_STREAMS ; j=j+1)
            hal_tlp_stream_en_reflect[j][i] = hal_tlp_stream_en[i][j];
      end
    end

    `HLSB_2D_TO_WIDE (axi_data_w,valid_dc_data,gen_data_wire,NUM_HLS_PORTS,SUM_WIDTH)
    `HLSB_2D_TO_WIDE (hal_tlp_stream_en_w,hal_tlp_stream_en_reflect,gen_hal_steam_valid_wire,NUM_TLP_STREAMS,KMAX_NUM_TLPS_PER_CLK)
    
     //for (gv_x=0 ; gv_x<NUM_TLP_STREAMS ; gv_x=gv_x+1) begin : hal_tab2wire
     //  always @(*) begin : gen_hal_steam_valid_wire
     //  integer i;
     //    for (i=0 ; i<KMAX_NUM_TLPS_PER_CLK ; i=i+1) 
     //      hal_tlp_stream_en_w[gv_x*KMAX_NUM_TLPS_PER_CLK +: KMAX_NUM_TLPS_PER_CLK] = hal_tlp_stream_en[gv_x][i];
     //  end
     //end

    for(n=0 ; n<NUM_TLP_STREAMS ; n=n+1) begin : delivered_sum
      //------------------------------------------------------------------------------
      // TLP_Stream AXI&HAL Counter enable
      //------------------------------------------------------------------------------
     if (NUM_HLS_PORTS == 1) begin
       assign counter_en[n] = tlp_stream_en[0][n];
     end
     else if (NUM_HLS_PORTS == 2) begin
       assign counter_en[n*2 +: 2] = {tlp_stream_en[1][n],tlp_stream_en[0][n]};
     end
     else if (NUM_HLS_PORTS == 4) begin
       assign counter_en[n*4 +: 4] = {tlp_stream_en[3][n],tlp_stream_en[2][n],tlp_stream_en[1][n],tlp_stream_en[0][n]};
     end
     else if (NUM_HLS_PORTS == 8) begin
       assign counter_en[n*8 +: 8] = {tlp_stream_en[7][n],tlp_stream_en[6][n],tlp_stream_en[5][n],tlp_stream_en[4][n],
                                       tlp_stream_en[3][n],tlp_stream_en[2][n],tlp_stream_en[1][n],tlp_stream_en[0][n]};
     end

     hls_bridge_dc_sum
     #(
       .NUM_HLS_PORTS               (NUM_HLS_PORTS),
       .DATA_WIDTH_SUM              (SUM_WIDTH),
       .KMAX_NUM_TLPS_PER_CLK       (KMAX_NUM_TLPS_PER_CLK),
       .TLP_STREAM                  (n),
       .DC_TDATA_WIDTH              (DC_TDATA_WIDTH),
       .ASF_ENABLE                  (ASF_SUPPORT>1)
     )
     i_hls_bridge_dc_sum
     (
       .core_clk             (core_clk),//input
       .core_rst_n           (core_rst_n),//input


       .axi_enable           (counter_en[n*NUM_HLS_PORTS +: NUM_HLS_PORTS]), //delivered
       .axi_count            (axi_data_w),

       .dti_enable           (dti_tlp_stream_en[n]), //delivered
       .dti_count            (dti_valid_data),

       .msi_enable           (msi_tlp_stream_en[n]), //delivered
       .msi_count            (dc_rx_msi_tvalid),

       //.tlp_per_stream_enable(from_hal_stream_en[n*KMAX_NUM_TLPS_PER_CLK +: KMAX_NUM_TLPS_PER_CLK]), //delivered
       .tlp_per_stream_enable(hal_tlp_stream_en_w[n*KMAX_NUM_TLPS_PER_CLK +: KMAX_NUM_TLPS_PER_CLK]), //delivered

       .i_tlp_route_to_axi   (i_tlp_route_to_axi),
       .i_tlp_route_to_msi   (i_tlp_route_to_msi),
       .i_tlp_route_to_dti   (i_tlp_route_to_dti),

//       .tlp_stream_empty     (sb_tx_tlp_stream_empty[n]),
       .tlp_stream_empty_axi  (temp_axi_stream_empty[n*NUM_HLS_PORTS +: NUM_HLS_PORTS]),
       .tlp_stream_empty_msi  (sb_tx_msi_stream_empty[n]),
       .tlp_stream_empty_dti  (sb_tx_dti_stream_empty[n]),

       .clear                (clear_count[n]),
       .output_count         (output_count[n*DC_TDATA_WIDTH +: DC_TDATA_WIDTH]),
       .output_count_chk     (output_count_chk[n*DC_TDATA_CHK_WIDTH +: DC_TDATA_CHK_WIDTH])
     ); //no carry ower for this sum

    //------------------------------------------------------------------------------
    // Ouput tab for ADD block
    //------------------------------------------------------------------------------
      assign output_count_tab[n]          = output_count     [n*DC_TDATA_WIDTH +: DC_TDATA_WIDTH];
      assign output_count_tab_chk[n]      = output_count_chk [n*DC_TDATA_CHK_WIDTH +: DC_TDATA_CHK_WIDTH];
      assign temp_axi_stream_empty_tab[n] = temp_axi_stream_empty[n*NUM_HLS_PORTS +: NUM_HLS_PORTS];
    end  // FOR NUM_TLP_STREAMS

    //------------------------------------------------------------------------------
    //Convertion tabo to wire
    //------------------------------------------------------------------------------
    always @(*) begin : output_stream_empty_axi
    integer i,j;
    axi_stream_empty = {NUM_TLP_STREAMS*NUM_HLS_PORTS{1'b1}};

      for (i=0 ; i<NUM_HLS_PORTS ; i=i+1) begin
        for (j=0 ; j<NUM_TLP_STREAMS ; j=j+1)
          axi_stream_empty[i*NUM_TLP_STREAMS+j] =temp_axi_stream_empty_tab[j][i];
      end
    end

    assign sb_tx_axi_stream_empty = axi_stream_empty;

    //------------------------------------------------------------------------------
    // RR counter for add blocks selection
    //------------------------------------------------------------------------------
    always @(posedge core_clk or negedge core_rst_n) begin
      if (core_rst_n == 1'b0)
        rr_counter <= {NUM_TLP_STREAMS_OTPUT_SHIFT{1'b0}};
      else
        rr_counter <= rr_counter +1'b1;
    end

    //------------------------------------------------------------------------------
    // DC data send
    //------------------------------------------------------------------------------
    always @(*) begin
      if (output_count_tab[rr_counter][SUM_WIDTH-1:0]!={SUM_WIDTH{1'd0}}) begin
        dc_data_reg     = output_count_tab [rr_counter];
        dc_data_chk_reg = output_count_tab_chk [rr_counter];
        dc_tvalid_reg   = 1'b1;
        clear_count              = {NUM_TLP_STREAMS{1'b0}};   // default all-zero
        clear_count[rr_counter]  = 1'b1;                      // one-hot pulse
      end
      else begin
        dc_data_reg     = {DC_TDATA_WIDTH{1'd0}};
        dc_data_chk_reg = {DC_TDATA_CHK_WIDTH{1'd1}};
        dc_tvalid_reg   = 1'b0;
        clear_count     = {NUM_TLP_STREAMS{1'b0}};
      end
    end

    assign tx_tvalid = dc_tvalid_reg;
    //------------------------------------------------------------------------------
    // DC data send
    //------------------------------------------------------------------------------
    always @(posedge core_clk or negedge core_rst_n) begin
      if (core_rst_n == 1'b0) begin
        dc_tx_data_reg    <= {DC_TDATA_WIDTH{1'd0}};
        dc_tx_tvalid_reg  <= 1'b0;

        tx_tvalid_chk_reg <= 1'b1;
        tx_tdata_chk_reg  <= {DC_TDATA_CHK_WIDTH{1'b1}};
      end
      else begin
        dc_tx_data_reg    <= dc_data_reg;
        dc_tx_tvalid_reg  <= tx_tvalid;

        tx_tvalid_chk_reg <= tx_tvalid_chk[0];
        tx_tdata_chk_reg  <= dc_data_chk_reg;
      end
    end

    //------------------------------------------------------------------------------
    // OUTPUT
    //------------------------------------------------------------------------------
    assign dc_tx_tdata      = dc_tx_data_reg;
    assign dc_tx_tvalid     = dc_tx_tvalid_reg;

    assign dc_tx_tvalid_chk = tx_tvalid_chk_reg;
    assign dc_tx_tdata_chk  = tx_tdata_chk_reg;

  end // LBB_SUPPORT

  else begin : not_lbb_support
    assign dc_count = valid_dc_data[0] +dti_valid_data +dc_rx_msi_tvalid;
    assign tx_tvalid = |{dc_rx_tvalid,dc_rx_dti_tvalid,dc_rx_msi_tvalid};

    always @(posedge core_clk or negedge core_rst_n) begin
      if (core_rst_n == 1'b0) begin
        tx_tvalid_reg  <= 1'b0;
        dc_tx_data_reg <= {DC_TDATA_WIDTH{1'b0}};

        tx_tvalid_chk_reg <= 1'b1;
        tx_tdata_chk_reg  <= {DC_TDATA_CHK_WIDTH{1'b1}};
      end
      else begin
        tx_tvalid_reg  <= tx_tvalid;
        dc_tx_data_reg <= {{DC_TDATA_WIDTH-SUM_WIDTH{1'b0}},dc_count[SUM_WIDTH-1:0]};

        tx_tvalid_chk_reg <= tx_tvalid_chk[0];
        tx_tdata_chk_reg  <= tx_tdata_chk;
      end
    end

    //------------------------------------------------------------------------------
    // OUTPUT
    //------------------------------------------------------------------------------
    assign  dc_tx_tdata      = dc_tx_data_reg;
    assign  dc_tx_tvalid     = tx_tvalid_reg;

    assign  dc_tx_tdata_chk  = tx_tdata_chk_reg;
    assign  dc_tx_tvalid_chk = tx_tvalid_chk_reg;

    assign sb_tx_axi_stream_empty = {(NUM_TLP_STREAMS*NUM_HLS_PORTS){1'b0}};
    assign sb_tx_dti_stream_empty = {NUM_TLP_STREAMS{1'b0}};
    assign sb_tx_msi_stream_empty = {NUM_TLP_STREAMS{1'b0}};
    for(n=0 ; n<NUM_TLP_STREAMS ; n=n+1) begin : g_output_count_tab
      assign output_count_tab[n] = {DC_TDATA_WIDTH{1'b0}};
    end
  end
  endgenerate

  //------------------------------------------------------------------------------
  // counter overflow assertion
  //------------------------------------------------------------------------------
 `ifdef ABV_ON
   `define AXI_ABV_ON
  `endif

  `ifdef AXI_ABV_ON
    wire [8+2:0] hls_sum;

      if (NUM_HLS_PORTS == 1)
        assign hls_sum =  |dc_rx_tvalid ? valid_dc_data[0]                   : 'h0;
      else if (NUM_HLS_PORTS == 2)
        assign hls_sum =  |dc_rx_tvalid ? valid_dc_data[0] +valid_dc_data[1] : 'h0;

    generate 
    for (n=0 ; n<NUM_HLS_PORTS ; n=n+1) begin : assert_for_n_axi_ports
      assert property (
         @(posedge core_clk) disable iff (!core_rst_n)
          (
          ($past(!dc_rx_tvalid[n]) |-> $past(sop_counter_axi_ff[n]) <= sop_counter_axi_ff[n])
          ));
    end
    endgenerate

    property dc_dti_internal_counter_ofverflow;
      @(posedge core_clk) disable iff (!core_rst_n)
      (
      ( $past(!dc_rx_dti_tvalid) |-> $past(sop_counter_dti_ff) <= sop_counter_dti_ff)
      );
    endproperty

    property dc_msi_internal_counter_ofverflow;
      @(posedge core_clk) disable iff (!core_rst_n)
      (
      ( $past(!dc_rx_msi_tvalid) |-> $past(msi_event) <= msi_event)
      );
    endproperty

    property dc_axi_internal_counter_ofverflow_in_single_cycle;
      @(posedge core_clk) disable iff (!core_rst_n)
      (|dc_rx_tvalid |-> hls_sum <= 8'hff);
    endproperty


    a_dc_dti_internal_counter_ofverflow : assert property (dc_dti_internal_counter_ofverflow);
    a_dc_msi_internal_counter_ofverflow : assert property (dc_msi_internal_counter_ofverflow);

    a_dc_axi_internal_counter_ofverflow_in_single_cycle : assert property (dc_axi_internal_counter_ofverflow_in_single_cycle);
  `endif


    generate
    //------------------------------------------------------------------------------
    // ASF
    //------------------------------------------------------------------------------
    if (ASF_SUPPORT >1) begin : dc_asf_gen
    wire [DC_INPUT_IF_NUMBER-1:0]                      dc_rx_all_tvalid    ;
    wire [DC_INPUT_IF_NUMBER-1:0]                      dc_rx_all_tvalid_chk;
    wire [DC_INPUT_IF_NUMBER*DC_TDATA_WIDTH-1:0]       dc_rx_all_tdata     ;
    wire [DC_INPUT_IF_NUMBER*DC_TDATA_CHK_WIDTH-1:0]   dc_rx_all_tdata_chk ;

    if (KMAX_DTI_SUPPORT == 1 && KMAX_MSI_IF_SUPPORT == 1) begin : wire_all_on
      assign dc_rx_all_tvalid     = {dc_rx_dti_tvalid    ,dc_rx_msi_tvalid           ,dc_rx_tvalid};
      assign dc_rx_all_tvalid_chk = {dc_rx_dti_tvalid_chk,dc_rx_msi_tvalid_chk       ,dc_rx_tvalid_chk};
      assign dc_rx_all_tdata      = {dc_rx_dti_tdata     ,{{(DC_TDATA_WIDTH-DC_RX_MSI_TDATA_WIDTH){1'b0}},dc_rx_msi_tdata},dc_rx_tdata};
      assign dc_rx_all_tdata_chk  = {dc_rx_dti_tdata_chk ,{1'b1 ,dc_rx_msi_tdata_chk},dc_rx_tdata_chk};
    end  //All IF ON
    else if (KMAX_DTI_SUPPORT == 0 && KMAX_MSI_IF_SUPPORT == 1) begin : wire_msi_on
      assign dc_rx_all_tvalid     = {dc_rx_msi_tvalid           ,dc_rx_tvalid};
      assign dc_rx_all_tvalid_chk = {dc_rx_msi_tvalid_chk       ,dc_rx_tvalid_chk};
      assign dc_rx_all_tdata      = {{{(DC_TDATA_WIDTH-DC_RX_MSI_TDATA_WIDTH){1'b0}},dc_rx_msi_tdata},dc_rx_tdata};
      assign dc_rx_all_tdata_chk  = {{1'b1 ,dc_rx_msi_tdata_chk},dc_rx_tdata_chk};
    end //MSI ON
    else if (KMAX_DTI_SUPPORT == 1 && KMAX_MSI_IF_SUPPORT == 0) begin : wire_dti_on
      assign dc_rx_all_tvalid     = {dc_rx_dti_tvalid    ,dc_rx_tvalid};
      assign dc_rx_all_tvalid_chk = {dc_rx_dti_tvalid_chk,dc_rx_tvalid_chk};
      assign dc_rx_all_tdata      = {dc_rx_dti_tdata     ,dc_rx_tdata};
      assign dc_rx_all_tdata_chk  = {dc_rx_dti_tdata_chk ,dc_rx_tdata_chk};
    end //DTI ON
    else begin : wire_only_hls
      assign dc_rx_all_tvalid     = {dc_rx_tvalid};
      assign dc_rx_all_tvalid_chk = {dc_rx_tvalid_chk};
      assign dc_rx_all_tdata      = {dc_rx_tdata};
      assign dc_rx_all_tdata_chk  = {dc_rx_tdata_chk};
    end // ONLY HLS

    for (asf_input_if_num=0 ; asf_input_if_num<DC_INPUT_IF_NUMBER ; asf_input_if_num=asf_input_if_num+1) begin : afs_input_if_parity_check
    // <mkdocs_chk_data> ID: 032 ; Checker Name: i_asf_par_032_dc_m_valid[0] ; ASF Group: DAP
    // <mkdocs_chk_data> ID: 033 ; Checker Name: i_asf_par_032_dc_m_valid[1] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 2
    // <mkdocs_chk_data> ID: 034 ; Checker Name: i_asf_par_032_dc_m_valid[2] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 3
    // <mkdocs_chk_data> ID: 035 ; Checker Name: i_asf_par_032_dc_m_valid[3] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 4
    // <mkdocs_chk_data> ID: 036 ; Checker Name: i_asf_par_032_dc_m_valid[4] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 5
    // <mkdocs_chk_data> ID: 037 ; Checker Name: i_asf_par_032_dc_m_valid[5] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 6
    // <mkdocs_chk_data> ID: 038 ; Checker Name: i_asf_par_032_dc_m_valid[6] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 7
    // <mkdocs_chk_data> ID: 039 ; Checker Name: i_asf_par_032_dc_m_valid[7] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 8
    // <mkdocs_chk_data> ID: 040 ; Checker Name: i_asf_par_032_dc_m_valid[8] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 9
    // <mkdocs_chk_data> ID: 041 ; Checker Name: i_asf_par_032_dc_m_valid[9] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 10
      asf_parity_check_and_regen_w_errinj #(
       .ASF_SUPPORT                          (ASF_SUPPORT),  // = 3,
       .ASF_NODE_ID                          (ASF_NODE_ID_BASE[15:0]+16'd32+asf_input_if_num[15:0]), // = 16 (HLS Bridge offset) + 32 (node ID),
       .ASF_ERR_INJ_SUPPORT                  (ASF_ERR_INJ_SUPPORT),  // = 1,
       .NUM_DATA_UNITS__CHKER                (1)
      ) i_asf_par_032_dc_m_valid (
       .clk                                  (core_clk),                 // input
       .rst_n                                (core_rst_n),               // input
       .chk__data_block_valid_i              (1'b1),
       .chk__data_i                          ({31'd0  ,dc_rx_all_tvalid    [asf_input_if_num]}),
       .chk__datachk_i                       ({3'b111 ,dc_rx_all_tvalid_chk[asf_input_if_num]}),
       .chk__parity_error_detected_outside_i (1'b0),
       .regen__data_block_valid_i            (1'b1),
       .regen__data_i                        ({31'd0,tx_tvalid}),
       .regen__datachk_o                     (tx_tvalid_chk[asf_input_if_num*4 +:4]), // output for check take from blok [0]

       .asf_error_inj__cmd_tvalid_i          (asf_error_inj__cmd_tvalid_i),
       .asf_error_inj__tdata_i               (asf_error_inj__tdata_i),
       .asf_error_inj__tuser_i               (asf_error_inj__tuser_i),

       .asf_event__valid_o                   (asf_event__valid_dc_tvalid     [asf_input_if_num]),
       .asf_event__type_o                    (asf_event__type_dc_tvalid      [asf_input_if_num*ASF_EVENT_TYPE_WIDTH       +: ASF_EVENT_TYPE_WIDTH      ]),
       .asf_event__count_o                   (asf_event__count_dc_tvalid     [asf_input_if_num*ASF_EVENT_COUNT_WIDTH      +: ASF_EVENT_COUNT_WIDTH     ]),
       .asf_event__node_id_o                 (asf_event__node_id_dc_tvalid   [asf_input_if_num*ASF_NODE_ID_WIDTH          +: ASF_NODE_ID_WIDTH         ]),
       .asf_event__diag_field_o              (asf_event__diag_field_dc_tvalid[asf_input_if_num*ASF_EVENT_DIAG_FIELD_WIDTH +: ASF_EVENT_DIAG_FIELD_WIDTH])
      );

    // <mkdocs_chk_data> ID: 042 ; Checker Name: i_asf_par_042_dc_m_tdata[0] ; ASF Group: DAP
    // <mkdocs_chk_data> ID: 043 ; Checker Name: i_asf_par_042_dc_m_tdata[1] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 2
    // <mkdocs_chk_data> ID: 044 ; Checker Name: i_asf_par_042_dc_m_tdata[2] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 3
    // <mkdocs_chk_data> ID: 045 ; Checker Name: i_asf_par_042_dc_m_tdata[3] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 4
    // <mkdocs_chk_data> ID: 046 ; Checker Name: i_asf_par_042_dc_m_tdata[4] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 5
    // <mkdocs_chk_data> ID: 047 ; Checker Name: i_asf_par_042_dc_m_tdata[5] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 6
    // <mkdocs_chk_data> ID: 048 ; Checker Name: i_asf_par_042_dc_m_tdata[6] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 7
    // <mkdocs_chk_data> ID: 049 ; Checker Name: i_asf_par_042_dc_m_tdata[7] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 8
    // <mkdocs_chk_data> ID: 050 ; Checker Name: i_asf_par_042_dc_m_tdata[8] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 9
    // <mkdocs_chk_data> ID: 051 ; Checker Name: i_asf_par_042_dc_m_tdata[9] ; ASF Group: DAP ; Constrain: NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 10
      if (LBB_SUPPORT==31'b0) begin : g_no_lbb_support
        asf_parity_check_and_regen_w_errinj #(
         .ASF_SUPPORT                          (ASF_SUPPORT),  // = 3,
         .ASF_NODE_ID                          (ASF_NODE_ID_BASE[15:0]+16'd42+asf_input_if_num[15:0]), // = 16 (HLS Bridge offset) + 42 (node ID),
         .ASF_ERR_INJ_SUPPORT                  (ASF_ERR_INJ_SUPPORT),  // = 1,
         .NUM_DATA_UNITS__CHKER                (1)
        ) i_asf_par_042_dc_m_tdata (
         .clk                                  (core_clk),                 // input
         .rst_n                                (core_rst_n),               // input
         .chk__data_block_valid_i              (dc_rx_all_tvalid[asf_input_if_num]),
         .chk__data_i                          ({16'h0000,dc_rx_all_tdata    [asf_input_if_num*DC_TDATA_WIDTH     +: DC_TDATA_WIDTH    ]}),
         .chk__datachk_i                       ({2'b11   ,dc_rx_all_tdata_chk[asf_input_if_num*DC_TDATA_CHK_WIDTH +: DC_TDATA_CHK_WIDTH]}), // odd scheme
         .chk__parity_error_detected_outside_i (1'b0),
         .regen__data_block_valid_i            (1'b1),
         .regen__data_i                        ({{32-SUM_WIDTH{1'b0}},dc_count}),
//         .regen__data_i                        ({{32-DC_TDATA_WIDTH{1'b0}},{7{1'b0}},output_count}),
         .regen__datachk_o                     (tx_tdata_chk[asf_input_if_num*4 +:4]), // output for check take from blok [0]

         .asf_error_inj__cmd_tvalid_i          (asf_error_inj__cmd_tvalid_i),
         .asf_error_inj__tdata_i               (asf_error_inj__tdata_i),
         .asf_error_inj__tuser_i               (asf_error_inj__tuser_i),

         .asf_event__valid_o                   (asf_event__valid_dc_tdata     [asf_input_if_num]),
         .asf_event__type_o                    (asf_event__type_dc_tdata      [asf_input_if_num*ASF_EVENT_TYPE_WIDTH       +: ASF_EVENT_TYPE_WIDTH      ]),
         .asf_event__count_o                   (asf_event__count_dc_tdata     [asf_input_if_num*ASF_EVENT_COUNT_WIDTH      +: ASF_EVENT_COUNT_WIDTH     ]),
         .asf_event__node_id_o                 (asf_event__node_id_dc_tdata   [asf_input_if_num*ASF_NODE_ID_WIDTH          +: ASF_NODE_ID_WIDTH         ]),
         .asf_event__diag_field_o              (asf_event__diag_field_dc_tdata[asf_input_if_num*ASF_EVENT_DIAG_FIELD_WIDTH +: ASF_EVENT_DIAG_FIELD_WIDTH])
        );
      end
      else begin : g_lbb_support
        asf_parity_check_and_regen_w_errinj #(
         .ASF_SUPPORT                          (ASF_SUPPORT),  // = 3,
         .ASF_NODE_ID                          (ASF_NODE_ID_BASE[15:0]+16'd42+asf_input_if_num[15:0]), // = 16 (HLS Bridge offset) + 42 (node ID),
         .ASF_ERR_INJ_SUPPORT                  (ASF_ERR_INJ_SUPPORT),  // = 1,
         .NUM_DATA_UNITS__CHKER                (1)
        ) i_asf_par_042_dc_m_tdata (
         .clk                                  (core_clk),                 // input
         .rst_n                                (core_rst_n),               // input
         .chk__data_block_valid_i              (dc_rx_all_tvalid[asf_input_if_num]),
         .chk__data_i                          ({16'h0000,dc_rx_all_tdata    [asf_input_if_num*DC_TDATA_WIDTH     +: DC_TDATA_WIDTH    ]}),
         .chk__datachk_i                       ({2'b11   ,dc_rx_all_tdata_chk[asf_input_if_num*DC_TDATA_CHK_WIDTH +: DC_TDATA_CHK_WIDTH]}), // odd scheme
         .chk__parity_error_detected_outside_i (1'b0),
         .regen__data_block_valid_i            (1'b0),
         .regen__data_i                        (32'h0),
         .regen__datachk_o                     (),
         //.regen__data_i                        ({{32-DC_TDATA_WIDTH{1'b0}},dc_tx_data_reg}),
         //.regen__datachk_o                     (tx_tdata_chk[asf_input_if_num*4 +:4]), // output for check take from blok [0]

         .asf_error_inj__cmd_tvalid_i          (asf_error_inj__cmd_tvalid_i),
         .asf_error_inj__tdata_i               (asf_error_inj__tdata_i),
         .asf_error_inj__tuser_i               (asf_error_inj__tuser_i),

         .asf_event__valid_o                   (asf_event__valid_dc_tdata     [asf_input_if_num]),
         .asf_event__type_o                    (asf_event__type_dc_tdata      [asf_input_if_num*ASF_EVENT_TYPE_WIDTH       +: ASF_EVENT_TYPE_WIDTH      ]),
         .asf_event__count_o                   (asf_event__count_dc_tdata     [asf_input_if_num*ASF_EVENT_COUNT_WIDTH      +: ASF_EVENT_COUNT_WIDTH     ]),
         .asf_event__node_id_o                 (asf_event__node_id_dc_tdata   [asf_input_if_num*ASF_NODE_ID_WIDTH          +: ASF_NODE_ID_WIDTH         ]),
         .asf_event__diag_field_o              (asf_event__diag_field_dc_tdata[asf_input_if_num*ASF_EVENT_DIAG_FIELD_WIDTH +: ASF_EVENT_DIAG_FIELD_WIDTH])
        );
      end
    end // asf_input_if_num

    end // KMAX_ASF_SUPPORT
    else begin : asf_off
      assign tx_tdata_chk  = {DC_TDATA_CHK_WIDTH{1'b0}};
      assign tx_tvalid_chk = 1'b0;
    end
  endgenerate

endmodule
