module hls_bridge_qos #(
  /////////////////////////////////////////////////////////////////////////////
  //                                Parameters                               //
  /////////////////////////////////////////////////////////////////////////////
  /*BSF:doc=Maximum number of HLS PORTS on AXI-Bridge side;*/
   parameter NUM_HLS_PORTS                 = 1,
  /*BSF:doc=Support for MSI IF;*/
   parameter KMAX_MSI_IF_SUPPORT           = 1,
  /*BSF:doc=Support for DTI module;*/
   parameter KMAX_DTI_SUPPORT              = 1,
  /*BSF:doc=Number of suported ID streams;*/
   parameter NUM_TLP_STREAMS               = 8,
  /*BSF:doc=MSI QOS data width Stream ID;*/
   parameter MSI_QOS_DATA_WIDTH            = 3, 

   parameter TLP_QOS_TDATA_WIDTH           = 24,
   parameter TLP_QOS_TDATA_CHK_WIDTH       = (TLP_QOS_TDATA_WIDTH +7)/8,
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
   //// base NODE for ctag
   //localparam QOS_ASF_NODE_ID_BASE  = ASF_NODE_ID_WIDTH +,

   localparam QOS_NUM_IF                    = NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT,
   localparam DTI_POINTER                   = NUM_HLS_PORTS,
   localparam MSI_POINTER                   = NUM_HLS_PORTS +KMAX_DTI_SUPPORT,

   localparam QOS_ASF_EVENT_VALID_WIDTH        = QOS_NUM_IF,
   localparam QOS_ASF_EVENT_TYPE_WIDTH         = QOS_NUM_IF*ASF_EVENT_TYPE_WIDTH      ,
   localparam QOS_ASF_EVENT_COUNT_WIDTH        = QOS_NUM_IF*ASF_EVENT_COUNT_WIDTH     ,
   localparam QOS_ASF_NODE_ID_WIDTH            = QOS_NUM_IF*ASF_NODE_ID_WIDTH         ,
   localparam QOS_ASF_EVENT_DIAG_FIELD_WIDTH   = QOS_NUM_IF*ASF_EVENT_DIAG_FIELD_WIDTH
  )(
  /*BSF:isClock=1,clock_group="CORE",doc= Power down / Power Shut-Off Core Clock ;*/
   input core_clk,
  /*BSF:isReset=1,clock=core_clk,doc= Power down / Power Shut-Off Core Reset ;*/
   input core_rst_n,
  //------------------------------------------------------------------------------
  // AXI RX QOS interface
  //------------------------------------------------------------------------------
  /*BSF_IF:axi_qos_rx_if,core_clk,core_rst_n,ipio=0,
    dis=AXI QOS RX interface,
    doc= Reduced AXI-Stream interface for handling TL buffer control from AXI-SW side,
  ;*/
  //BSF:doc= valid signla for info data;
   input wire [NUM_HLS_PORTS-1:0]                            axi_qos_rx_tvalid,
  /*BSF:doc=
    # [0+:13] - COUNT one count indicates that all data  or requests or responses associated with a single tlp from core side has been transferred/received
    # [13+:1] - QOS_TYPE 0: Request 1: Response.
    # [14+:1] - TLP_TYPE 0: Indicates that the count is for posted TLP. 1: Indicates that the count is for nonposted TLP. Correct transaction type needs to be detected from TLP. DMWR is a AXI write but a nonposted
    # [15+:3] - TLP_STREAM -stream selection posible configs: 1-8. This is field form HLS metadata.
    # [18+:6] - Dummy bits to fill IF.
  ;*/
   input wire [NUM_HLS_PORTS*TLP_QOS_TDATA_WIDTH-1:0]        axi_qos_rx_tdata,
   // ------------------------------ Parity
   /*BSF:doc=Valid parity;*/
   input wire [NUM_HLS_PORTS-1:0]                            axi_qos_rx_tvalid_chk,
   /*BSF:doc=Data parity;*/
   input wire [NUM_HLS_PORTS*TLP_QOS_TDATA_CHK_WIDTH-1:0]    axi_qos_rx_tdata_chk,
  //BSF_IF_END:axi_qos_rx_if;

  //------------------------------------------------------------------------------
  // DTI RX interface
  //------------------------------------------------------------------------------
  /*BSF_IF:dti_qos_rx_if,core_clk,core_rst_n,ipio=0,
    dis=DTI QOS RX interface,
    doc= Reduced AXI-Stream interface for handling TL buffer control from DTI side,
  ;*/
  //BSF:doc= valid signla for info data;
   input wire                                           dti_qos_rx_tvalid,
  /*BSF:doc=
    # [0+:13] - COUNT one count indicates that all data  or requests or responses associated with a single tlp from core side has been transferred/received
    # [13+:1] - QOS_TYPE 0: Request 1: Response.
    # [14+:1] - TLP_TYPE 0: Indicates that the count is for posted TLP. 1: Indicates that the count is for nonposted TLP. Correct transaction type needs to be detected from TLP. DMWR is a AXI write but a nonposted
    # [15+:3] - TLP_STREAMS  stream selection posible configs: 1-8. This is field form HLS metadata.
    # [18+:6] - Dummy bits to fill IF.
  ;*/
   input wire [TLP_QOS_TDATA_WIDTH-1:0]                 dti_qos_rx_tdata,
   // ------------------------------ Parity
   /*BSF:doc=Valid parity;*/
   input wire                                           dti_qos_rx_tvalid_chk,
   /*BSF:doc=Data parity;*/
   input wire [TLP_QOS_TDATA_CHK_WIDTH-1:0]             dti_qos_rx_tdata_chk,
  //BSF_IF_END:dti_qos_rx_if;

  //------------------------------------------------------------------------------
  // QOS MSI RX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:qos_rx_msi_if,core_clk,core_rst_n,ipio=0,
    dis=QOS MSI RX Interface
    doc= Reduced AXI-Stream interface for handling TL buffer control from MSI side,
  ;*/
  //bsf:doc=valid for qos count block;
  input wire                                              msi_qos_rx_valid,
  /*BSF:doc=
    # [0+:3] - TLP_STREAMS  stream selection posible configs: 1-8. This is field form HLS metadata.
    # [3+:1] - QOS_TYPE 0: Request 1: Response.
  ;*/
  input wire [MSI_QOS_DATA_WIDTH-1:0]                     msi_qos_rx_data,
  //bsf:doc=valid check for QOS count block;
  input wire                                              msi_qos_rx_valid_chk,
  //bsf:doc=data check for QOS count block;
  input wire                                              msi_qos_rx_data_chk,
  //BSF_IF_END:qos_rx_msi_if;

  //------------------------------------------------------------------------------
  // TX QOS interface
  //------------------------------------------------------------------------------
  /*BSF_IF:qos_tx_if,core_clk,core_rst_n,ipio=0,
    dis=QOS TX interface,
    doc= Reduced AXI-Stream interface for handling TL buffer control to HAL layer,
  ;*/
  //BSF:doc= valid signla for info data;
   output wire                                                tlp_qos_tx_tvalid,
  /*BSF:doc=
    # [0+:13] - COUNT one count indicates that all data  or requests or responses associated with a single tlp from core side has been transferred/received
    # [13+:1] - QOS_TYPE  0: outstanding completion count informaiton. One Count indicating when *all* BRESP or RRESP is received for one TLP request from protocol side. 1: pipeline transfer count information. One Count indicates when all related AW*+W* is transferred out to AXI interface. or when AR* request is transferred out.
    # [14+:1] - TLP_TYPE  0: Indicates that the count is for posted packets. 1: Indicates that the count is for NP Tlp. Correct transaction type needs to be detected from TLP. DMWR is a AXI write but a nonposted
    # [15+:3] - TLP_STREAMS stream selection posible configs: 1,2,4,8. This is field form HLS metadata.
    # [18+:6] - Dummy bits to fill IF.
  ;*/
   output wire [TLP_QOS_TDATA_WIDTH-1:0]                      tlp_qos_tx_tdata,
   // ------------------------------ Parity
   /*BSF:doc=Valid parity;*/
   output wire                                                tlp_qos_tx_tvalid_chk,
   /*BSF:doc=Data parity;*/
   output wire [TLP_QOS_TDATA_CHK_WIDTH-1:0]                  tlp_qos_tx_tdata_chk,
  //BSF_IF_END:qos_tx_if;

   //------------------------------------------------------------------------------
   // ASF error interface
   //------------------------------------------------------------------------------
   /*BSF_IF:asf_error_injection_if,core_clk,core_rst_n,ipio=0,
     dis=ASF Error Injection Interface,
     doc=Interface to control error injection in sub-components
   ;*/
   input                                        asf_error_inj__cmd_tvalid_i,
   input [ASF_ERROR_INJ_DATA_WIDTH-1:0]         asf_error_inj__tdata_i,
   input [ASF_ERROR_INJ_USER_WIDTH-1:0]         asf_error_inj__tuser_i,
    /*BSF_IF_END:asf_error_injection_if;*/

   /*BSF_IF:asf_status_and_diag_valid,core_clk,core_rst_n,ipio=0,
     dis=ASF Status and Diagnostic output,
     doc=ASF status and diagnostic signals when error is detected in this block.
     all unused signals can be tied to zero. outputs are flopped.
   ;*/
   output [QOS_ASF_EVENT_VALID_WIDTH-1:0]       asf_event__valid_qos_tvalid,
   output [QOS_ASF_EVENT_TYPE_WIDTH-1:0]        asf_event__type_qos_tvalid,
   output [QOS_ASF_EVENT_COUNT_WIDTH-1:0]       asf_event__count_qos_tvalid,
   output [QOS_ASF_NODE_ID_WIDTH-1:0]           asf_event__node_id_qos_tvalid,
   output [QOS_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]  asf_event__diag_field_qos_tvalid,
   /*BSF_IF_END:asf_status_and_diag_valid;*/


   /*BSF_IF:asf_status_and_diag_data,core_clk,core_rst_n,ipio=0,
     dis=ASF Status and Diagnostic output,
     doc=ASF status and diagnostic signals when error is detected in this block.
     all unused signals can be tied to zero. outputs are flopped.
   ;*/
   output [QOS_ASF_EVENT_VALID_WIDTH-1:0]       asf_event__valid_qos_tdata,
   output [QOS_ASF_EVENT_TYPE_WIDTH-1:0]        asf_event__type_qos_tdata,
   output [QOS_ASF_EVENT_COUNT_WIDTH-1:0]       asf_event__count_qos_tdata,
   output [QOS_ASF_NODE_ID_WIDTH-1:0]           asf_event__node_id_qos_tdata,
   output [QOS_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]  asf_event__diag_field_qos_tdata
   /*BSF_IF_END:asf_status_and_diag_data;*/
  );
  localparam DATA_SIZE                  = 13;
  localparam NUM_TLP_STREAMS_BIT        = $clog2(NUM_TLP_STREAMS);

  localparam NUM_TLP_STREAMS_MAX        = 8;
  localparam NUM_TLP_STREAMS_MAX_BIT    = $clog2(NUM_TLP_STREAMS_MAX);

  localparam COUNT_NUMBER               = NUM_TLP_STREAMS*4;
  localparam COUNT_NUMBER_BIT_SIZE      = $clog2(COUNT_NUMBER);

  wire [NUM_HLS_PORTS-1:0]                      axi_valid_rx_tlp_type;
  wire [NUM_HLS_PORTS-1:0]                      axi_valid_rx_req_type;
  wire [NUM_HLS_PORTS*NUM_TLP_STREAMS_MAX_BIT-1:0]   axi_valid_rx_tlp_stream;

  wire [TLP_QOS_TDATA_WIDTH-1:0]                qos_data_tab       [QOS_NUM_IF-1:0];
//  wire [TLP_QOS_TDATA_WIDTH*QOS_NUM_IF-1:0]     qos_data_w;
  wire [TLP_QOS_TDATA_CHK_WIDTH-1:0]            qos_data_chk_tab   [QOS_NUM_IF-1:0];
  wire [QOS_NUM_IF-1:0]                         qos_valid    ;
  wire [QOS_NUM_IF-1:0]                         qos_valid_chk;
  wire [COUNT_NUMBER-1:0]                       qos_counter_en_tab [QOS_NUM_IF-1:0];

  wire [TLP_QOS_TDATA_WIDTH-1:0]                output_count_tab     [COUNT_NUMBER-1:0];
  wire [TLP_QOS_TDATA_CHK_WIDTH-1:0]            output_count_tab_chk [COUNT_NUMBER-1:0];

  wire [31:0]                                   data_reg_chk;

  reg                                           valid_reg;
  reg [COUNT_NUMBER-1:0]                        clear_count;
  reg [TLP_QOS_TDATA_WIDTH-1:0]                 data_reg;

  reg [TLP_QOS_TDATA_CHK_WIDTH-1:0]             data_chk_reg;

  reg                                           tx_valid_chk_reg;
  reg                                           tx_valid_reg;
  reg [TLP_QOS_TDATA_WIDTH-1:0]                 tx_data_reg;
  reg [TLP_QOS_TDATA_CHK_WIDTH-1:0]             tx_data_chk_reg;

  reg [COUNT_NUMBER_BIT_SIZE-1:0]               rr_counter;
  reg [QOS_NUM_IF-1:0]                          counter_en [COUNT_NUMBER-1:0];

  reg [NUM_TLP_STREAMS_MAX-1:0]                 qos_stream_en_axi [NUM_HLS_PORTS-1:0];
  reg [COUNT_NUMBER-1:0]                        axi_num_en        [NUM_HLS_PORTS-1:0];

  genvar gv_x,gv_y;
  generate
  for (gv_x=0 ; gv_x<NUM_HLS_PORTS ; gv_x=gv_x+1) begin : g_axi_qos_en
    assign axi_valid_rx_tlp_type   [gv_x*1  +:1]  = (axi_qos_rx_tvalid[gv_x] == 1'b1) ? axi_qos_rx_tdata [gv_x*TLP_QOS_TDATA_WIDTH+13 +:1] : 1'b0;
    assign axi_valid_rx_req_type   [gv_x*1  +:1]  = (axi_qos_rx_tvalid[gv_x] == 1'b1) ? axi_qos_rx_tdata [gv_x*TLP_QOS_TDATA_WIDTH+14 +:1] : 1'b0;
    assign axi_valid_rx_tlp_stream [gv_x*3  +:3]  = (axi_qos_rx_tvalid[gv_x] == 1'b1) ? axi_qos_rx_tdata [gv_x*TLP_QOS_TDATA_WIDTH+15 +:3] : 3'b000;

    // Decode the 3-bit stream ID from AXI QoS tdata[17:15] into a one-hot
    // 8-bit vector (qos_stream_en_axi). Zero when the port is not valid.
    always @(*) begin : axi_stream_en_decode
      if (axi_qos_rx_tvalid[gv_x]) begin
        case (axi_valid_rx_tlp_stream[gv_x*NUM_TLP_STREAMS_MAX_BIT +: NUM_TLP_STREAMS_MAX_BIT])
          3'b000 : qos_stream_en_axi[gv_x] = 8'b00000001;
          3'b001 : qos_stream_en_axi[gv_x] = 8'b00000010;
          3'b010 : qos_stream_en_axi[gv_x] = 8'b00000100;
          3'b011 : qos_stream_en_axi[gv_x] = 8'b00001000;
          3'b100 : qos_stream_en_axi[gv_x] = 8'b00010000;
          3'b101 : qos_stream_en_axi[gv_x] = 8'b00100000;
          3'b110 : qos_stream_en_axi[gv_x] = 8'b01000000;
          3'b111 : qos_stream_en_axi[gv_x] = 8'b10000000;
        endcase
      end
      else
        qos_stream_en_axi[gv_x] = 8'h00;
    end

    // Map the one-hot stream enable and TLP type/class bits into the correct
    // counter group slot. The 4*NUM_TLP_STREAMS enable bus is laid out as
    // {NP&RESP, P&RESP, NP&REQ, P&REQ}, each group NUM_TLP_STREAMS wide.
    // tlp_type[13]: 0=Request 1=Response  |  req_type[14]: 0=Posted 1=Non-Posted
    always @(*) begin : axi_counter_en_encode
      if (axi_qos_rx_tvalid[gv_x]) begin
        if      (!axi_valid_rx_tlp_type[gv_x] &&  !axi_valid_rx_req_type[gv_x])
          axi_num_en[gv_x] = {{3*NUM_TLP_STREAMS{1'b0}},qos_stream_en_axi[gv_x][NUM_TLP_STREAMS-1:0]};
        else if (axi_valid_rx_tlp_type[gv_x] && !axi_valid_rx_req_type[gv_x])
          axi_num_en[gv_x] = {{2*NUM_TLP_STREAMS{1'b0}},qos_stream_en_axi[gv_x][NUM_TLP_STREAMS-1:0],{NUM_TLP_STREAMS{1'b0}}};
        else if (!axi_valid_rx_tlp_type[gv_x] && axi_valid_rx_req_type[gv_x])
          axi_num_en[gv_x] = {{NUM_TLP_STREAMS{1'b0}},qos_stream_en_axi[gv_x][NUM_TLP_STREAMS-1:0],{2*NUM_TLP_STREAMS{1'b0}}};
        else
          axi_num_en[gv_x] = {qos_stream_en_axi[gv_x][NUM_TLP_STREAMS-1:0],{3*NUM_TLP_STREAMS{1'b0}}};
      end
      else 
        axi_num_en[gv_x] = {4*NUM_TLP_STREAMS{1'b0}};
    end

    assign qos_counter_en_tab [gv_x] = axi_num_en[gv_x];
    assign qos_data_tab       [gv_x] = axi_qos_rx_tvalid[gv_x] ? 
                                     axi_qos_rx_tdata[gv_x*TLP_QOS_TDATA_WIDTH +: TLP_QOS_TDATA_WIDTH] : 
                                     {TLP_QOS_TDATA_WIDTH{1'b0}};
    assign qos_valid          [gv_x] = axi_qos_rx_tvalid[gv_x];

    //ASF
    if (ASF_SUPPORT >1) begin : g_axi_asf_on
      assign qos_data_chk_tab[gv_x] = axi_qos_rx_tvalid[gv_x] ? 
                                    axi_qos_rx_tdata_chk[gv_x*TLP_QOS_TDATA_CHK_WIDTH +: TLP_QOS_TDATA_CHK_WIDTH] :
                                    {TLP_QOS_TDATA_CHK_WIDTH{1'b1}};
      assign qos_valid_chk   [gv_x] = axi_qos_rx_tvalid_chk[gv_x];
    end
    else begin : g_axi_asf_off
      assign qos_data_chk_tab[gv_x] = {TLP_QOS_TDATA_CHK_WIDTH{1'b0}};
      assign qos_valid_chk   [gv_x] = 1'b0;
    end
  end // NUM_HLS_PORTS

  if (KMAX_DTI_SUPPORT) begin : g_dti_qos_en
    wire                                          dti_valid_rx_tlp_type;
    wire                                          dti_valid_rx_req_type;
    wire [NUM_TLP_STREAMS_MAX_BIT-1:0]            dti_valid_rx_tlp_stream;
    reg  [NUM_TLP_STREAMS_MAX-1:0]                qos_stream_en_dti;
    reg  [COUNT_NUMBER-1:0]                       dti_num_en;

    assign dti_valid_rx_tlp_type   = (dti_qos_rx_tvalid == 1'b1) ? dti_qos_rx_tdata [13 +:1] : 1'b0;
    assign dti_valid_rx_req_type   = (dti_qos_rx_tvalid == 1'b1) ? dti_qos_rx_tdata [14 +:1] : 1'b0;
    assign dti_valid_rx_tlp_stream = (dti_qos_rx_tvalid == 1'b1) ? dti_qos_rx_tdata [15 +:3] : 3'b000;

    // Decode the 3-bit stream ID from DTI QoS tdata[17:15] into a one-hot
    // 8-bit vector (qos_stream_en_dti). Zero when the DTI port is not valid.
    always @(*) begin : dti_stream_en_decode
      if (dti_qos_rx_tvalid) begin
        case (dti_valid_rx_tlp_stream)
          3'b000 : qos_stream_en_dti = 8'b00000001;
          3'b001 : qos_stream_en_dti = 8'b00000010;
          3'b010 : qos_stream_en_dti = 8'b00000100;
          3'b011 : qos_stream_en_dti = 8'b00001000;
          3'b100 : qos_stream_en_dti = 8'b00010000;
          3'b101 : qos_stream_en_dti = 8'b00100000;
          3'b110 : qos_stream_en_dti = 8'b01000000;
          3'b111 : qos_stream_en_dti = 8'b10000000;
        endcase
      end
      else
        qos_stream_en_dti = 8'h00;
    end

    // Same counter-group encoding as the AXI path but for the DTI interface.
    // The 4*NUM_TLP_STREAMS enable bus is {NP&RESP, P&RESP, NP&REQ, P&REQ}.
    always @(*) begin : dti_counter_en_encode
      if (dti_qos_rx_tvalid) begin
        if (!dti_valid_rx_tlp_type  && !dti_valid_rx_req_type)
          dti_num_en = {{3*NUM_TLP_STREAMS{1'b0}},qos_stream_en_dti[NUM_TLP_STREAMS-1:0]};
        else if (dti_valid_rx_tlp_type && !dti_valid_rx_req_type)
          dti_num_en = {{2*NUM_TLP_STREAMS{1'b0}},qos_stream_en_dti[NUM_TLP_STREAMS-1:0],{NUM_TLP_STREAMS{1'b0}}};
        else if (!dti_valid_rx_tlp_type  && dti_valid_rx_req_type)
          dti_num_en = {{NUM_TLP_STREAMS{1'b0}},qos_stream_en_dti[NUM_TLP_STREAMS-1:0],{2*NUM_TLP_STREAMS{1'b0}}};
        else
          dti_num_en = {qos_stream_en_dti[NUM_TLP_STREAMS-1:0],{3*NUM_TLP_STREAMS{1'b0}}};
      end
      else 
        dti_num_en = {4*NUM_TLP_STREAMS{1'b0}};
    end

    assign qos_counter_en_tab[DTI_POINTER] = dti_num_en;
    assign qos_valid         [DTI_POINTER] = dti_qos_rx_tvalid;
    assign qos_data_tab      [DTI_POINTER] = dti_qos_rx_tvalid ? dti_qos_rx_tdata : {TLP_QOS_TDATA_WIDTH{1'b0}};
    if (ASF_SUPPORT >1) begin : g_dti_asf_on_with_msi
      assign qos_valid_chk   [DTI_POINTER] = dti_qos_rx_tvalid_chk;
      assign qos_data_chk_tab[DTI_POINTER] = dti_qos_rx_tvalid ? dti_qos_rx_tdata_chk : {TLP_QOS_TDATA_CHK_WIDTH{1'b1}};
    end
    else begin : g_dti_asf_off_with_msi
      assign qos_valid_chk   [DTI_POINTER] = 1'b0; 
      assign qos_data_chk_tab[DTI_POINTER] = {TLP_QOS_TDATA_CHK_WIDTH{1'b0}};
    end 
  end // KMAX_DTI_SUPPORT

  if (KMAX_MSI_IF_SUPPORT) begin : g_msi_qos_en
    //wire                                          msi_valid_rx_req_type;
    reg  [NUM_TLP_STREAMS_MAX-1:0]                qos_stream_en_msi;
    reg  [COUNT_NUMBER-1:0]                       msi_num_en;

    //assign msi_valid_rx_req_type   = (msi_qos_rx_valid == 1'b1) ? msi_qos_rx_data [3 +:1] : 1'b0;
    //assign msi_valid_rx_tlp_stream = (msi_qos_rx_valid == 1'b1) ? msi_qos_rx_data [0 +:3] : 3'b000;

    // Decode the 3-bit stream ID from MSI QoS data[3:0] into a one-hot
    // 8-bit vector (qos_stream_en_msi). Zero when the DTI port is not valid.
    always @(*) begin : msi_stream_en_decode
      if (msi_qos_rx_valid) begin
        case (msi_qos_rx_data[0 +:3])
          3'b000 : qos_stream_en_msi = 8'b00000001;
          3'b001 : qos_stream_en_msi = 8'b00000010;
          3'b010 : qos_stream_en_msi = 8'b00000100;
          3'b011 : qos_stream_en_msi = 8'b00001000;
          3'b100 : qos_stream_en_msi = 8'b00010000;
          3'b101 : qos_stream_en_msi = 8'b00100000;
          3'b110 : qos_stream_en_msi = 8'b01000000;
          3'b111 : qos_stream_en_msi = 8'b10000000;
        endcase
      end
      else
        qos_stream_en_msi = 8'h00;
    end
    // Same counter-group encoding as the AXI path but for the MSI interface.
    // The 4*NUM_TLP_STREAMS enable bus is {NP&RESP, P&RESP, NP&REQ, P&REQ}
    // For MSI each valid is req & resp.
    always @(*) begin : msi_counter_en_encode
      if (msi_qos_rx_valid) begin
        msi_num_en = {{NUM_TLP_STREAMS{1'b0}},qos_stream_en_msi[NUM_TLP_STREAMS-1:0],
                      {NUM_TLP_STREAMS{1'b0}},qos_stream_en_msi[NUM_TLP_STREAMS-1:0]};
        //if (!msi_valid_rx_req_type)
        //  msi_num_en = {{3*NUM_TLP_STREAMS{1'b0}},qos_stream_en_msi[NUM_TLP_STREAMS-1:0]};
        //else
        //  msi_num_en = {{NUM_TLP_STREAMS{1'b0}},qos_stream_en_msi[NUM_TLP_STREAMS-1:0],{2*NUM_TLP_STREAMS{1'b0}}};
      end
      else 
        msi_num_en = {4*NUM_TLP_STREAMS{1'b0}};
    end

    assign qos_counter_en_tab[MSI_POINTER] = msi_num_en;
    assign qos_valid         [MSI_POINTER] = msi_qos_rx_valid;
    assign qos_data_tab      [MSI_POINTER] = msi_qos_rx_valid ? {{TLP_QOS_TDATA_WIDTH-1{1'b0}},msi_qos_rx_valid} : {TLP_QOS_TDATA_WIDTH{1'b0}};
    if (ASF_SUPPORT >1) begin : g_msi_asf_on
      assign qos_data_chk_tab[MSI_POINTER] = {{TLP_QOS_TDATA_CHK_WIDTH-1{1'b1}},msi_qos_rx_valid_chk};
      assign qos_valid_chk   [MSI_POINTER] = msi_qos_rx_valid_chk;
    end
    else begin : g_msi_asf_off
      assign qos_data_chk_tab[MSI_POINTER] = {TLP_QOS_TDATA_CHK_WIDTH{1'b1}};
      assign qos_valid_chk   [MSI_POINTER] = 1'b1;
    end
  end  // KMAX_MSI_IF_SUPPORT
  endgenerate


  // Transpose qos_counter_en_tab[QOS_NUM_IF][COUNT_NUMBER] into
  // counter_en[COUNT_NUMBER][QOS_NUM_IF] so that each hls_bridge_qos_counter
  // instance receives a per-interface enable vector for its assigned slot.
  // All enables are cleared when no interface is valid.
  always @(*) begin : counter_en_transpose
   integer i,j;
    if (qos_valid != {QOS_NUM_IF{1'b0}}) begin 
      for (j=0 ; j<QOS_NUM_IF ; j=j+1) begin
        for (i=0 ; i<COUNT_NUMBER ; i=i+1)
          counter_en [i][j]= qos_counter_en_tab[j][i];
      end
    end
    else begin
      for (i=0 ; i<COUNT_NUMBER ; i=i+1)
        counter_en[i] = {QOS_NUM_IF{1'b0}};
    end 
  end


  generate
  `HLSB_2D_TO_WIDE (qos_data_w,qos_data_tab,gen_data_wire,QOS_NUM_IF,TLP_QOS_TDATA_WIDTH)
  //if (QOS_NUM_IF==1)
  //  assign counter_en = qos_counter_en_tab [0];
  //else if (QOS_NUM_IF==2)
  //  assign counter_en = qos_counter_en_tab [0] | qos_counter_en_tab[1];
  //else if (QOS_NUM_IF==3)
  //  assign counter_en = qos_counter_en_tab [0] | qos_counter_en_tab[1] | qos_counter_en_tab[2];
  //else if (QOS_NUM_IF==4)
  //  assign counter_en = qos_counter_en_tab [0] | qos_counter_en_tab[1] | qos_counter_en_tab[2] | qos_counter_en_tab[3];
  //else if (QOS_NUM_IF==5)
  //  assign counter_en = qos_counter_en_tab [0] | qos_counter_en_tab[1] | qos_counter_en_tab[2] | qos_counter_en_tab[3] | qos_counter_en_tab[4];
  //else if (QOS_NUM_IF==6)
  //  assign counter_en = qos_counter_en_tab [0] | qos_counter_en_tab[1] | qos_counter_en_tab[2] | qos_counter_en_tab[3] | qos_counter_en_tab[4] | qos_counter_en_tab[5];

  for (gv_y=0 ;gv_y<COUNT_NUMBER ; gv_y=gv_y+1) begin : g_qos_counter
    hls_bridge_qos_counter
    #(
     .BUS_WIDTH                      (TLP_QOS_TDATA_WIDTH),
     .DATA_SIZE                      (DATA_SIZE),
     .NUM_IF                         (QOS_NUM_IF),
     .ASF_SUPPORT                    (ASF_SUPPORT)
    )
      i_hls_bridge_qos_counter
    (
     .core_clk                       (core_clk),//input
     .core_rst_n                     (core_rst_n),//input
     .enable                         (counter_en[gv_y]),
     .clear                          (clear_count[gv_y]),
     .data                           (qos_data_w),
     .output_count                   (output_count_tab[gv_y]),
     .output_count_chk               (output_count_tab_chk[gv_y])
    );
  end
  endgenerate

  // RR counter for add blocks selection
  always @(posedge core_clk or negedge core_rst_n) begin
    if (core_rst_n == 1'b0) begin
      rr_counter <= {COUNT_NUMBER_BIT_SIZE{1'b0}};
    end
    else begin
      rr_counter <= rr_counter + {{COUNT_NUMBER_BIT_SIZE-1{1'b0}},1'b1};
    end
  end

  // Round-robin output mux. Reads the counter slot pointed to by rr_counter;
  // if non-zero, drives data_reg/valid_reg and pulses a one-hot clear_count
  // to reset that slot. Idles (valid_reg=0) when the selected slot is empty.
  always @(*) begin : rr_count_sel
    if (output_count_tab[rr_counter][DATA_SIZE-1:0]!={DATA_SIZE{1'b0}}) begin
      data_reg  = output_count_tab [rr_counter];
      valid_reg = 1'b1;
      clear_count  = {{(COUNT_NUMBER-1){1'b0}},1'b1} <<< rr_counter;
      data_chk_reg = output_count_tab_chk[rr_counter];
    end
    else begin
      data_reg    = {TLP_QOS_TDATA_WIDTH{1'b0}};
      valid_reg   = 1'b0;
      clear_count = {COUNT_NUMBER{1'b0}};
      data_chk_reg = {TLP_QOS_TDATA_CHK_WIDTH{1'b1}};
    end
  end

  always @(posedge core_clk or negedge core_rst_n) begin
    if (core_rst_n == 1'b0) begin
      tx_data_reg  <= {TLP_QOS_TDATA_WIDTH{1'b0}};
      tx_valid_reg <= 1'b0;
      tx_data_chk_reg <= {TLP_QOS_TDATA_CHK_WIDTH{1'b0}};
      tx_valid_chk_reg<= 1'b0;
    end
    else begin
      tx_data_reg  <= data_reg;
      tx_valid_reg <= valid_reg;
      tx_data_chk_reg  <= data_chk_reg;
      tx_valid_chk_reg <= ~valid_reg;
    end
  end

  assign tlp_qos_tx_tvalid = tx_valid_reg;
  assign tlp_qos_tx_tdata  = tx_data_reg;

 //------------------------------------------------------------------------------
 // ASF
 //------------------------------------------------------------------------------
  generate
    if (ASF_SUPPORT >1) begin : ctag_asf_gen
    assign tlp_qos_tx_tvalid_chk = tx_valid_chk_reg;
    assign tlp_qos_tx_tdata_chk  = tx_data_chk_reg;

      // <mkdocs_chk_data> ID: 052 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[0] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1
      // <mkdocs_chk_data> ID: 053 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[1] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 2
      // <mkdocs_chk_data> ID: 054 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[2] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 3
      // <mkdocs_chk_data> ID: 055 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[3] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 4
      // <mkdocs_chk_data> ID: 056 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[4] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 5
      // <mkdocs_chk_data> ID: 057 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[5] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 6
      // <mkdocs_chk_data> ID: 058 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[6] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 7
      // <mkdocs_chk_data> ID: 059 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[7] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 8
      // <mkdocs_chk_data> ID: 060 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[8] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 9
      // <mkdocs_chk_data> ID: 061 ; Checker Name: i_asf_par_052_qos_hls_tx_tvalid[9] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 10
      // <mkdocs_chk_data> ID: 062 ; Checker Name: i_asf_par_062_qos_hls_tdata[0] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1
      // <mkdocs_chk_data> ID: 063 ; Checker Name: i_asf_par_062_qos_hls_tdata[1] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 2
      // <mkdocs_chk_data> ID: 064 ; Checker Name: i_asf_par_062_qos_hls_tdata[2] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 3
      // <mkdocs_chk_data> ID: 065 ; Checker Name: i_asf_par_062_qos_hls_tdata[3] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 4
      // <mkdocs_chk_data> ID: 066 ; Checker Name: i_asf_par_062_qos_hls_tdata[4] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 5
      // <mkdocs_chk_data> ID: 067 ; Checker Name: i_asf_par_062_qos_hls_tdata[5] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 6
      // <mkdocs_chk_data> ID: 068 ; Checker Name: i_asf_par_062_qos_hls_tdata[6] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 7
      // <mkdocs_chk_data> ID: 069 ; Checker Name: i_asf_par_062_qos_hls_tdata[7] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 8
      // <mkdocs_chk_data> ID: 070 ; Checker Name: i_asf_par_062_qos_hls_tdata[8] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 9
      // <mkdocs_chk_data> ID: 071 ; Checker Name: i_asf_par_062_qos_hls_tdata[9] ; ASF Group: DAP ; Constrain: LBB_SUPPORT == 1, NUM_HLS_PORTS+KMAX_DTI_SUPPORT+KMAX_MSI_IF_SUPPORT >= 10
      for (gv_y=0 ; gv_y<QOS_NUM_IF ; gv_y=gv_y+1) begin : g_asf_valid_chk_per_if
        asf_parity_check_and_regen_w_errinj #(
         .ASF_SUPPORT                          (ASF_SUPPORT),  // = 3,
         .ASF_NODE_ID                          (ASF_NODE_ID_BASE[15:0]+16'd52+gv_y[15:0]), // = 16 (HLS Bridge offset) + 52 (node ID),
         .ASF_ERR_INJ_SUPPORT                  (ASF_ERR_INJ_SUPPORT),  // = 1,
         .NUM_DATA_UNITS__CHKER                (1)
        ) i_asf_par_052_qos_hls_tx_tvalid (
         .clk                                  (core_clk),                 // input
         .rst_n                                (core_rst_n),               // input
         .chk__data_block_valid_i              (1'b1),
         .chk__data_i                          ({31'd0  ,qos_valid[gv_y]}),
         .chk__datachk_i                       ({3'b111 ,qos_valid_chk[gv_y]}),
         .chk__parity_error_detected_outside_i (1'b0),
         .regen__data_block_valid_i            (1'b1),
         .regen__data_i                        (32'd0),
         .regen__datachk_o                     (),

         .asf_error_inj__cmd_tvalid_i          (asf_error_inj__cmd_tvalid_i), // input
         .asf_error_inj__tdata_i               (asf_error_inj__tdata_i),      // input [55:0]
         .asf_error_inj__tuser_i               (asf_error_inj__tuser_i),      // input [7:0]

         .asf_event__valid_o                   (asf_event__valid_qos_tvalid      [gv_y]),
         .asf_event__type_o                    (asf_event__type_qos_tvalid       [gv_y*ASF_EVENT_TYPE_WIDTH       +: ASF_EVENT_TYPE_WIDTH      ]),
         .asf_event__count_o                   (asf_event__count_qos_tvalid      [gv_y*ASF_EVENT_COUNT_WIDTH      +: ASF_EVENT_COUNT_WIDTH     ]),
         .asf_event__node_id_o                 (asf_event__node_id_qos_tvalid    [gv_y*ASF_NODE_ID_WIDTH          +: ASF_NODE_ID_WIDTH         ]),
         .asf_event__diag_field_o              (asf_event__diag_field_qos_tvalid [gv_y*ASF_EVENT_DIAG_FIELD_WIDTH +: ASF_EVENT_DIAG_FIELD_WIDTH])
        );
        asf_parity_check_and_regen_w_errinj #(
         .ASF_SUPPORT                          (ASF_SUPPORT),  // = 3,
         .ASF_NODE_ID                          (ASF_NODE_ID_BASE[15:0]+16'd62+gv_y[15:0]), // = 16 (HLS Bridge offset) + 62 (node ID),
         .ASF_ERR_INJ_SUPPORT                  (ASF_ERR_INJ_SUPPORT),  // = 1,
         .NUM_DATA_UNITS__CHKER                (1)
        ) i_asf_par_062_qos_hls_tdata (
         .clk                                  (core_clk),                 // input
         .rst_n                                (core_rst_n),               // input
         .chk__data_block_valid_i              (1'b1),
         .chk__data_i                          ({{32-TLP_QOS_TDATA_WIDTH{1'b0}},qos_data_tab[gv_y]}),
         .chk__datachk_i                       ({{4-TLP_QOS_TDATA_CHK_WIDTH{1'b0}},qos_data_chk_tab[gv_y]}),
         .chk__parity_error_detected_outside_i (1'b0),
         .regen__data_block_valid_i            (1'b1),
         .regen__data_i                        (32'd0),
         .regen__datachk_o                     (), // new check take from SUM module

         .asf_error_inj__cmd_tvalid_i          (asf_error_inj__cmd_tvalid_i), // input
         .asf_error_inj__tdata_i               (asf_error_inj__tdata_i),      // input [55:0]
         .asf_error_inj__tuser_i               (asf_error_inj__tuser_i),      // input [7:0]

         .asf_event__valid_o                   (asf_event__valid_qos_tdata      [gv_y]),
         .asf_event__type_o                    (asf_event__type_qos_tdata       [gv_y*ASF_EVENT_TYPE_WIDTH       +: ASF_EVENT_TYPE_WIDTH      ]),
         .asf_event__count_o                   (asf_event__count_qos_tdata      [gv_y*ASF_EVENT_COUNT_WIDTH      +: ASF_EVENT_COUNT_WIDTH     ]),
         .asf_event__node_id_o                 (asf_event__node_id_qos_tdata    [gv_y*ASF_NODE_ID_WIDTH          +: ASF_NODE_ID_WIDTH         ]),
         .asf_event__diag_field_o              (asf_event__diag_field_qos_tdata [gv_y*ASF_EVENT_DIAG_FIELD_WIDTH +: ASF_EVENT_DIAG_FIELD_WIDTH])
        );
      end
    end //ASF_SUPPORT
    else begin : g_no_asf
      assign tlp_qos_tx_tvalid_chk = 1'b0;
      assign tlp_qos_tx_tdata_chk  = {TLP_QOS_TDATA_CHK_WIDTH{1'b0}}; 
    end
  endgenerate

endmodule
