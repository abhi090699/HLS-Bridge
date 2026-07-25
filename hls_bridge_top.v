module hls_bridge_top #(

  /////////////////////////////////////////////////////////////////////////////
  //                                Parameters                               //
  /////////////////////////////////////////////////////////////////////////////
  /*BSF:doc=Maximum number of HLS PORTS on AXI-Bridge side;*/
   parameter NUM_HLS_PORTS                                     = 1,
   parameter NUM_PORTS = NUM_HLS_PORTS,
   /*BSF:doc=Maximum data path width supported in the design;*/
   parameter  [NUM_HLS_PORTS*32-1:0]  HLS_PORT_DATA_WIDTH_ARR       = {NUM_HLS_PORTS{32'd1024}},
   localparam HLS_PORT_DATA_WIDTHS                                  = __sum_params(HLS_PORT_DATA_WIDTH_ARR,NUM_HLS_PORTS),
   localparam HLS_PORT_DATA_CHK_WIDTH_ARR                           = __parity_width(HLS_PORT_DATA_WIDTH_ARR, NUM_HLS_PORTS),
   localparam HLS_PORT_DATA_CHK_WIDTHS                              = __sum_params(HLS_PORT_DATA_CHK_WIDTH_ARR, NUM_HLS_PORTS),
   /*BSF:doc=Maximum number of ID groups;*/
   parameter  NUM_TLP_STREAMS                                       = 8,
   /*BSF:doc=Maximum number of PFs;*/
   parameter  KMAX_NUM_PFS                                          = 16,
   /*BSF:doc=Maximum number of TLPs to support per clock;*/
   parameter  [NUM_HLS_PORTS*32-1:0]  HLS_PORT_TLPS_PER_CLK_ARR     = __tlps_per_clk(HLS_PORT_DATA_WIDTH_ARR, NUM_HLS_PORTS),


  /*BSF:doc=Maximum data path width supported for HLS in the design;*/
   parameter KMAX_DATAPATH_WD                           = 1024,

  /*BSF:doc=Maximum data path width supported for HLS in the design;*/
   localparam KMAX_DATAPATH_WD_CHK                       = KMAX_DATAPATH_WD/8,

  /*BSF:doc=Maximum possible number of VCs to support;*/
   parameter KMAX_NUM_VCS                               = 4,

  /*BSF:doc=Maximum number of ID groups in each I/F;*/
  //   parameter KMAX_NUM_IDGS                              = 4,

  /*BSF:doc=Maximum number of TLPs to support per clock;*/
   parameter KMAX_NUM_TLPS_PER_CLK                      = KMAX_DATAPATH_WD == 1024 ? 4 : KMAX_DATAPATH_WD/128,

  /*BSF:doc=Enable/Disable MSI delivery interface;*/
   parameter KMAX_MSI_IF_SUPPORT                        = 1,

  /*BSF:doc=Enable/Disable DTI delivery interface;*/
   parameter KMAX_DTI_SUPPORT                           = 1,

  /*BSF:doc=ASF_SUPPORT enables parity generators and checkers inside CSR blocks
            Following are the expected modes based on parameter values. {|
      *Encoding* | *Mode Name* | *description* |-
      0 | No Protection | All protection and diagnostic logic is not present or disabled in this mode. |-
      1 | SRAM Protection  | Logic and interface for SRAM protection is available including error injection and reporting |-
      2 | E2E Data  | Logic and interface for SRAM protection and Data-path is available including error injection and reporting |-
      3 | Full Automotive  | All Protection and Error injection and diagnostic interfaces are present.
   |};*/
   parameter ASF_SUPPORT                                = 1,
   /*BSF:doc=ASF Error Injection support. If set, Error injection is supported  ;*/
   parameter ASF_ERR_INJ_SUPPORT                        = 1,
   /*BSF:doc=Error injection base address for all nodes in AXIs;*/
   parameter ASF_EI_BASE_ADDRESS                        = 4096,

  /*BSF:doc=Enable/Disable LTI functionality;*/
   parameter LTI_SUPPORT                                = 1,

  /*BSF:doc=Number of LTI port ID number;*/
   parameter NUM_LTI_PORTS                               = 4,

  /*BSF:doc=Support for unordered buffer on DL layer;*/
  parameter LBB_SUPPORT                                 = 0,
  //------------------------------------------------------------------------------
  // Parameters for fixed values
  //------------------------------------------------------------------------------
  /*BSF:doc=Start pointer alignment: 2: 64-bit (2 DWords), 4: 128-bit (4 DWords);*/
   parameter HLS_DW_ALIGNMENT                          = 4,

  /*BSF:doc=HLS Inboud Posted and Non-Posted Metadata bus width for each packet;*/
   parameter HLS_RX_PNP_METADATA_WD                         = 112,
  /*BSF:doc=HLS Inboud Completion Metadata bus width for each packet;*/
   parameter HLS_RX_C_METADATA_WD                           = 40,
  /*BSF:doc=HLS Outbound Posted and Non-Posted Metadata bus width for each packet;*/
   parameter HLS_TX_PNP_METADATA_WD                         = 40,
  /*BSF:doc=HLS Outbound Competion Metadata bus width for each packet;*/
   parameter HLS_TX_C_METADATA_WD                           = 40,

  parameter DISABLE_CSR_PARITY = 0,

  // DTI params
  localparam RAM_READ_LATENCY                        = 3,
  localparam DTI_TDATA_WIDTH                         = 160,
  localparam TOK_TRANS                               = 4096,
  localparam TOK_INV                                 = 16,
  parameter DTI_RAM_DATA_WIDTH                       = 325,

  // Number of Link IDE Streams. Supported values are {0-8}.
  parameter KMAX_IDE_NUM_LINK_STREAMS                = 0,

   // Number of Selective IDE Streams. Supported values are {0-8}
  parameter KMAX_IDE_NUM_SEL_STREAMS                 = 0,

  localparam IDE_NUM_LINK_STREAMS                    = (KMAX_IDE_NUM_LINK_STREAMS == 0) ? 1 : KMAX_IDE_NUM_LINK_STREAMS,
  localparam IDE_NUM_SEL_STREAMS                     = (KMAX_IDE_NUM_SEL_STREAMS == 0) ? 1 : KMAX_IDE_NUM_SEL_STREAMS,

  localparam DTI_TKEEP_WIDTH                         = DTI_TDATA_WIDTH/8,
  localparam DTI_TDATA_CHK_WIDTH                     = (DTI_TDATA_WIDTH +7)/8,
  localparam DTI_TKEEP_CHK_WIDTH                     = (DTI_TKEEP_WIDTH +7)/8,
  localparam NUM_TCS                                      = 8,

  localparam TOK_TRANS_BIN_WIDTH                     = $clog2(TOK_TRANS),
  localparam TOK_INV_BIN_WIDTH                       = $clog2(TOK_INV),
  localparam RAM_READ_LATENCY_WIDTH                  = (RAM_READ_LATENCY < 2) ? 1 : $clog2(RAM_READ_LATENCY),


  // AXI Lite widths
  localparam INTERNAL_AXIL_M_IF_NUMBER                 = 3,
  //localparam INTERNAL_AXIL_M_IF_NUMBER                 = NUM_HLS_PORTS +KMAX_DTI_SUPPORT,
  parameter  AXIL_DATA_WIDTH                           = 32,
  localparam AXIL_STRB_WIDTH                           = AXIL_DATA_WIDTH/8,
  localparam AXIL_RESP_WIDTH                           = 2,
  localparam AXIL_PROT_WIDTH                           = 3,
  parameter  AXIL_ADDR_WIDTH                           = 26,
  localparam AXIL_PROT_WIDTH_CHK                       = (AXIL_PROT_WIDTH +7)/8,
  localparam AXIL_RESP_WIDTH_CHK                       = (AXIL_RESP_WIDTH +7)/8,
  localparam AXIL_STRB_WIDTH_CHK                       = (AXIL_STRB_WIDTH +7)/8,
  localparam AXIL_DATA_WIDTH_CHK                       = (AXIL_DATA_WIDTH +7)/8,
  localparam AXIL_ADDR_WIDTH_CHK                       = (AXIL_ADDR_WIDTH +7)/8,
  parameter  AXIL_ARUSER_WIDTH                         = 1,
  parameter  AXIL_AWUSER_WIDTH                         = 1,
  parameter  AXIL_BUSER_WIDTH                          = 1,
  parameter  AXIL_RUSER_WIDTH                          = 1,
  parameter  AXIL_WUSER_WIDTH                          = 1,

  localparam  AXIL_ARUSER_WIDTH_CHK                    = (AXIL_ARUSER_WIDTH +7)/8,
  localparam  AXIL_AWUSER_WIDTH_CHK                    = (AXIL_AWUSER_WIDTH +7)/8,
  localparam  AXIL_BUSER_WIDTH_CHK                     = (AXIL_BUSER_WIDTH +7)/8 ,
  localparam  AXIL_RUSER_WIDTH_CHK                     = (AXIL_RUSER_WIDTH +7)/8 ,
  localparam  AXIL_WUSER_WIDTH_CHK                     = (AXIL_WUSER_WIDTH +7)/8 ,
  // AXIL width for regs module
  localparam AXIL_DATA_WIDTH_REGS                      = 32,
  localparam AXIL_PROT_WIDTH_REGS                      = 3,
  localparam AXIL_ADDR_WIDTH_REGS                      = 16,

  //------------------------------------------------------------------------------
  // AXI Bridge config
  //------------------------------------------------------------------------------
  parameter  KMAX_AXI_M_OUTSTANDING_WRITES                         = 4096,
  localparam KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH                   = (KMAX_AXI_M_OUTSTANDING_WRITES < 2) ? 1 : $clog2(KMAX_AXI_M_OUTSTANDING_WRITES),

   //------------------------------------------------------------------------------
   // LTI Completion AXI Stream
   //------------------------------------------------------------------------------
   parameter  LTI_C_TDATA_WIDTH                        = 16,
   localparam LTI_C_TDATA_CHK_WIDTH                    = (LTI_C_TDATA_WIDTH +7)/8,

   //------------------------------------------------------------------------------
   // TLP QoS AXI Stream - for TL's Unordered Buffer
   //------------------------------------------------------------------------------
   parameter  TLP_QOS_TDATA_WIDTH                      = 24,
   localparam TLP_QOS_TDATA_CHK_WIDTH                  = (TLP_QOS_TDATA_WIDTH +7)/8,

  //------------------------------------------------------------------------------
  // Credit interface
  //------------------------------------------------------------------------------
  parameter CRD_IN_LMT_HEADER_WIDTH                    = 9,
  parameter CRD_IN_LMT_PAYLOAD_WIDTH                   = 13,
  parameter CRD_IN_LMT_CNTL_WIDTH                      = 6,

  //------------------------------------------------------------------------------
  // MSI AXI Stream
  //------------------------------------------------------------------------------
  parameter  KMAX_MSI_TDATA_WIDTH                      = 64,
  localparam KMAX_MSI_TDATA_WIDTH_CHK                  = (KMAX_MSI_TDATA_WIDTH +7)/8,

  //------------------------------------------------------------------------------
  // Posted Delivered Count AXI Stream
  //------------------------------------------------------------------------------
  parameter  DC_TDATA_WIDTH                   = 16,
  localparam DC_TDATA_CHK_WIDTH               = ((DC_TDATA_WIDTH    + 7)/8),

  //------------------------------------------------------------------------------
  // TDISP
  //------------------------------------------------------------------------------
  /*BSF:doc=TDISP implementation for reisters;*/
    parameter   TDISP_SUPPORT               = 1,
    parameter   TDISP_ADDR_WIDTH            = 32,
    localparam  TDISP_ADDRCHK_WIDTH         = (TDISP_ADDR_WIDTH + 7) / 8,
    parameter   TDISP_FIELD_WIDTH           = 5,
    localparam  TDISP_FIELDCHK_WIDTH        = (TDISP_FIELD_WIDTH + 7) / 8,
    parameter   TDISP_INDEX_WIDTH           = 16,
    localparam  TDISP_INDEXCHK_WIDTH        = (TDISP_INDEX_WIDTH + 7) / 8,
    parameter   TDISP_ORIGIN_WIDTH          = 2,
    localparam  TDISP_ORIGINCHK_WIDTH       = (TDISP_ORIGIN_WIDTH + 7) / 8,
    parameter   TDISP_REXVALUE_WIDTH        = 4,
    localparam  TDISP_REXVALUECHK_WIDTH     = (TDISP_REXVALUE_WIDTH + 7) / 8,
    parameter   TDISP_NOTIFYVALUE_WIDTH     = 4,
    localparam  TDISP_NOTIFYVALUECHK_WIDTH  = (TDISP_NOTIFYVALUE_WIDTH + 7) / 8,

   //------------------------------------------------------------------------------
   // Local parameters which are derived from others
   //------------------------------------------------------------------------------
    localparam HLS_HAL_STR_PTR_WD                            = $clog2(KMAX_DATAPATH_WD/HLS_DW_ALIGNMENT/32),
    localparam HLS_HAL_END_PTR_WD                            = $clog2(KMAX_DATAPATH_WD/32),
    localparam HLS_HAL_PKT_CNTL_WD                           = KMAX_NUM_TLPS_PER_CLK * (3 + HLS_HAL_STR_PTR_WD + HLS_HAL_END_PTR_WD),
    localparam HLS_HAL_IB_PNP_CNTL_WD                        = HLS_HAL_PKT_CNTL_WD + KMAX_NUM_TLPS_PER_CLK*HLS_RX_PNP_METADATA_WD,
    localparam HLS_HAL_IB_C_CNTL_WD                          = HLS_HAL_PKT_CNTL_WD + KMAX_NUM_TLPS_PER_CLK*HLS_RX_C_METADATA_WD,
    localparam HLS_HAL_OB_PNP_CNTL_WD                        = HLS_HAL_PKT_CNTL_WD + KMAX_NUM_TLPS_PER_CLK*HLS_TX_PNP_METADATA_WD,
    localparam HLS_HAL_OB_C_CNTL_WD                          = HLS_HAL_PKT_CNTL_WD + KMAX_NUM_TLPS_PER_CLK*HLS_TX_C_METADATA_WD,
    localparam HLS_HAL_IB_PNP_CNTL_CHK_WD                    = (HLS_HAL_IB_PNP_CNTL_WD +7)/8,
    localparam HLS_HAL_IB_C_CNTL_CHK_WD                      = (HLS_HAL_IB_C_CNTL_WD +7)/8,
    localparam HLS_HAL_OB_PNP_CNTL_CHK_WD                    = (HLS_HAL_OB_PNP_CNTL_WD +7)/8,
    localparam HLS_HAL_OB_C_CNTL_CHK_WD                      = (HLS_HAL_OB_C_CNTL_WD +7)/8,



    localparam HLS_AXI_NUM_TLPS_PER_CLK_ARR  =  HLS_PORT_TLPS_PER_CLK_ARR,

    localparam [NUM_HLS_PORTS*32-1:0] HLS_AXI_STR_PTR_WD_ARR  = __hls_sptr_width(HLS_PORT_DATA_WIDTH_ARR, NUM_HLS_PORTS, HLS_DW_ALIGNMENT),
    localparam [NUM_HLS_PORTS*32-1:0] HLS_AXI_END_PTR_WD_ARR  = __hls_eptr_width(HLS_PORT_DATA_WIDTH_ARR, NUM_HLS_PORTS),
    localparam [NUM_HLS_PORTS*32-1:0] HLS_AXI_PKT_CNTL_WD_ARR = __hls_pkt_cntl_width(HLS_PORT_TLPS_PER_CLK_ARR,HLS_AXI_STR_PTR_WD_ARR,HLS_AXI_END_PTR_WD_ARR,NUM_HLS_PORTS),

    localparam [NUM_HLS_PORTS*32-1:0] HLS_AXI_IB_PNP_CNTL_WD_ARR = __hls_cntl_width(HLS_AXI_PKT_CNTL_WD_ARR,HLS_PORT_TLPS_PER_CLK_ARR,HLS_RX_PNP_METADATA_WD,NUM_HLS_PORTS),

    localparam [NUM_HLS_PORTS*32-1:0] HLS_AXI_IB_C_CNTL_WD_ARR = __hls_cntl_width(HLS_AXI_PKT_CNTL_WD_ARR,HLS_PORT_TLPS_PER_CLK_ARR,HLS_RX_C_METADATA_WD,NUM_HLS_PORTS),

    localparam [NUM_HLS_PORTS*32-1:0] HLS_AXI_OB_PNP_CNTL_WD_ARR = __hls_cntl_width(HLS_AXI_PKT_CNTL_WD_ARR,HLS_PORT_TLPS_PER_CLK_ARR,HLS_TX_PNP_METADATA_WD,NUM_HLS_PORTS),

    localparam [NUM_HLS_PORTS*32-1:0] HLS_AXI_OB_C_CNTL_WD_ARR = __hls_cntl_width(HLS_AXI_PKT_CNTL_WD_ARR,HLS_PORT_TLPS_PER_CLK_ARR,HLS_TX_C_METADATA_WD,NUM_HLS_PORTS),

    localparam HLS_AXI_IB_PNP_CNTL_CHK_WD_ARR                    = __parity_width(HLS_AXI_IB_PNP_CNTL_WD_ARR, NUM_HLS_PORTS) ,
    localparam HLS_AXI_IB_C_CNTL_CHK_WD_ARR                      = __parity_width(HLS_AXI_IB_C_CNTL_WD_ARR, NUM_HLS_PORTS) ,
    localparam HLS_AXI_OB_PNP_CNTL_CHK_WD_ARR                    = __parity_width(HLS_AXI_OB_PNP_CNTL_WD_ARR, NUM_HLS_PORTS) ,
    localparam HLS_AXI_OB_C_CNTL_CHK_WD_ARR                      = __parity_width(HLS_AXI_OB_C_CNTL_WD_ARR, NUM_HLS_PORTS) ,

    localparam HLS_AXI_IB_PNP_CNTL_WD = __sum_params(HLS_AXI_IB_PNP_CNTL_WD_ARR, NUM_HLS_PORTS),
    localparam HLS_AXI_IB_C_CNTL_WD = __sum_params(HLS_AXI_IB_C_CNTL_WD_ARR, NUM_HLS_PORTS),
    localparam HLS_AXI_OB_PNP_CNTL_WD = __sum_params(HLS_AXI_OB_PNP_CNTL_WD_ARR, NUM_HLS_PORTS),
    localparam HLS_AXI_OB_C_CNTL_WD = __sum_params(HLS_AXI_OB_C_CNTL_WD_ARR, NUM_HLS_PORTS),
    localparam HLS_AXI_IB_PNP_CNTL_CHK_WD = __sum_params(HLS_AXI_IB_PNP_CNTL_CHK_WD_ARR, NUM_HLS_PORTS),
    localparam HLS_AXI_IB_C_CNTL_CHK_WD = __sum_params(HLS_AXI_IB_C_CNTL_CHK_WD_ARR, NUM_HLS_PORTS),
    localparam HLS_AXI_OB_PNP_CNTL_CHK_WD = __sum_params(HLS_AXI_OB_PNP_CNTL_CHK_WD_ARR, NUM_HLS_PORTS),
    localparam HLS_AXI_OB_C_CNTL_CHK_WD = __sum_params(HLS_AXI_OB_C_CNTL_CHK_WD_ARR, NUM_HLS_PORTS),

    localparam CRD_DW_COUNTER_WD                                       = 9, //TBD change to parameter
    localparam CRD_DW_COUNTER_CHK_WD                                   = (CRD_DW_COUNTER_WD+7)/8,

    // METADATA
    localparam METADATA_VC_WD                            = 3,
    localparam METADATA_IDG_WD                           = 3,
    localparam METADATA_LRCTAG_WD                        = 1,
    localparam METADATA_LTI_PORT_NUM_WD                  = 2,
    localparam METADATA_BYPASS_AXI_ATU_WD                = 1,
    //localparam METADATA_QOS_TYPE_WD                       = 1,

    localparam IB_P_NP_METADATA_PKT_ROUTING_INFO_WD       = 2,
    localparam IB_P_NP_METADATA_PKT_ROUTING_INFO_OFFSET   = 51,
    localparam IB_P_NP_METADATA_PORT_INFO_OFFSET          = 53,
    localparam IB_C_METADATA_PKT_ROUTING_INFO_WD          = 1,
    localparam IB_C_METADATA_PKT_ROUTING_INFO_OFFSET      = 32,
    localparam IB_C_METADATA_PORT_INFO_OFFSET             = 33,

    localparam MSI_DC_DATA_WIDTH         = 6,// Delivery count data width (VC[3] + IDG[3])
    localparam MSI_LTIC_DATA_WIDTH       = 3,// MSI LTI data width (CTAG[1] + Port[2])
    localparam MSI_QOS_DATA_WIDTH        = 3,// MSI QOS data width Stream ID)
    localparam MSI_DATA_WD               = KMAX_MSI_TDATA_WIDTH,



    localparam MSI_PAYLOAD_WD            =(MSI_DATA_WD+
                                           METADATA_VC_WD+
                                           METADATA_IDG_WD+
                                           METADATA_LRCTAG_WD+
                                           METADATA_LTI_PORT_NUM_WD+
                                           METADATA_BYPASS_AXI_ATU_WD),//+
//                                           METADATA_QOS_TYPE_WD),
    localparam MSI_PAYLOAD_CHK_WD        = (MSI_PAYLOAD_WD+7)/8

   )(

  /*BSF:isClock=1,clock_group="CORE",doc= Core clock in always-on domain ;*/
   input core_clk,
  /*BSF:isReset=1,clock=core_clk,doc= Core Reset ;*/
   input core_rst_n,

  // TBD <-- thre is only AXI lite interface in port list is this needed ???
  /*BSF:isClock=1,clock_group="AXI",doc= AXI MSI clock ;*/
   input axi_msi_clk,
  /*BSF:isReset=1,clock=axi_msi_clk,doc= AXI MSI Reset ;*/
   input axi_msi_rst_n,

  /*BSF:isClock=1,clock_group="AXI",doc= AXI DTI clock ;*/
   input axi_dti_clk,
  /*BSF:isReset=1,clock=axi_dti_clk,doc= AXI DTI reset ;*/
   input axi_dti_rst_n,

  /*BSF:isClock=1,clock_group="CORE",doc= AXI Lite clock ;*/
   input axil_clk,
  /*BSF:isReset=1,clock=axil_clk,doc= AXI Lite Reset ;*/
   input axil_rst_n,
   //------------------------------------------------------------------------------
   //  Clock request interface
   //------------------------------------------------------------------------------
   /*BSF_IF:qactive_if,async,ipio=1
    ,dis= Qactive - clock request interface
    ,doc= Clock request signals per AXI Master/AXI Slave clock.
   ;*/
   /*BSF:doc=AXI DTI clock request. Indicates that AXI DTI clock is necessary to perform packet processing (1) or can be turned off (0).;*/
   output wire                                 axi_dti_qactive,
   /*BSF:doc=AXI MSI clock request. Indicates that AXI DTI clock is necessary to perform packet processing (1) or can be turned off (0).;*/
   output wire                                 axi_msi_qactive,
   /*BSF_IF_END:qactive_if;*/


   //------------------------------------------------------------------------------
   // Global constant-wire setting
   //------------------------------------------------------------------------------
   //BSF_IF:k_wires_if,static;
   /*BSF:doc=Start pointer alignment: 2: 64-bit (2 DWords), 4: 128-bit (4 DWords);*/
   input wire [2:0]                                                                k_hls_dw_alignment,
   /*BSF:doc=CXL IO supported - 1, CXL IO not supported - 0;*/
   input  wire                                                                     k_cxl_io_support,
   /*BSF:doc=CXL Port Based Routing Flit Support. For PBR to be supported, k_flit_mode_support and k_cxl_support both have to be set to 1.
    # 00=illegal,
    # 01=PBR Only,
    # 10=HBR Only,
    # 11=PBR + HBR
   ;*/
   input  wire [1:0]                                                               k_cxl_pbr_flit_support,
   /*BSF:doc=Selectes datasync reset..0: asynchronous, 1: synchronous reset;*/
   input  wire                                                                     k_sync_reset,
   /*BSF:doc=Selectes number of stages in datasync..0: 2 stages, 1: 3 stages;*/
   input  wire                                                                     k_sync_cell_stages,
   /*BSF:doc=Support TLP decoding of FLIT mode TLPs;*/
   input  wire                                                                     k_flit_mode_support,
   /*BSF:doc=Support of IDE;*/
   input  wire                                                                     k_ide_support,
   /*BSF:doc=PASID support
   # 1 - PASID supported
   # 0- PASID not supported
   ;*/
   input  wire                                                                      k_pasid_supported,
   /*BSF:doc=The number of invalidation tokens minus 1;*/
   input  wire [TOK_INV_BIN_WIDTH-1:0]                                              k_dti_tok_inv_min1,
   /*BSF:doc=The number of translation tokens minus 1;*/
   input  wire [TOK_TRANS_BIN_WIDTH-1:0]                                            k_dti_tok_trans_min1,
   /*BSF:doc=LUT RAM read latency. Allowed values - 1,2,3 = 1,2,3 latency;*/
   input wire [RAM_READ_LATENCY_WIDTH-1:0]                                          k_dti_ram_read_latency,
    /*BSF:doc=Is LUT RAM-based? ;*/
   input wire                                                                       k_dti_ram_enable,
   /*BSF:doc=
    # [0] - Vendor Defined Prefix L0 supported
    # [1] - Vendor Defined Prefix L1 supported
   ;*/
   input [1:0]                                                                      k_vendor_prefix_local_support,
   /*BSF:doc=ECRC generation support;*/
   input  wire                                                                      k_ecrc_capability_support,
   /*BSF:doc=OHC-E width (in DWords) allowed values are [0,1,2,4]:
    # 0 - OHC-E no supported (0 bits)
    # 1 - 1 DWords (32 bits)
    # 2 - 2 DWords (64 bits)
    # 4 - 4 DWords (128 bits)
   ;*/
   input  wire [2:0]                                                                k_ohc_e_wd,
   /*BSF:doc= Selects maximum number of AXI Master outstanding Write Requests.
      Value to set - maximum number of outstanding AXI Master Writes minus 1
      Number of outstanding should be in range [4,KMAX_AXI_M_OUTSTANDING_WRITES]
      Example: value 3 means maximum 4 outstanding AXI Master Writes
   ;*/
   input wire [NUM_HLS_PORTS*KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH-1:0]                             k_axi_m_outstanding_writes_min1,

   //BSF_IF_END:k_wires_if;

  /////////////////////////////////////////////////////////////////////////////
  //                                Interfaces                               //
  /////////////////////////////////////////////////////////////////////////////

   /*BSF:doc=Enable TDISP monitoring;*/
   input                                                                           tdisp_enable,

   //------------------------------------------------------------------------------
   // HLS TX Posted I/F to HAL
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_posted_ob_hal_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_master_reqcompl,prefix_pattern=hls_ob_posted_,agent_src=1
    ,dis=HLS Outbound Posted HAL
    ,doc=TX interface for Posted packets to HAL (OB). First set is for CIF0,
     second set is for CIF0 and so on.
   ;*/
   /*BSF:doc=Indicates that data and cntl are valid. Asserted only when credits are available.;*/
   output wire                                             hls_ob_posted_hal_valid,
   /*BSF:doc=Data for packets;*/
   output wire [KMAX_DATAPATH_WD-1:0]                      hls_ob_posted_hal_data,
   /*BSF:doc=
    docvar:common_hls_pkt_ctrl
   Fixed encoding, bits get reserved based on actual data widths and start alignments in kwire.
   Control bus decode:
    <p style="font-size : 16px"><b>[0                                               +: KMAX_NUM_TLPS_PER_CLK]                      START flags      </b>- One bit for each TLP</p>
    <p style="font-size : 16px"><b>[KMAX_NUM_TLPS_PER_CLK                           +: KMAX_NUM_TLPS_PER_CLK*HLS_HAL_STR_PTR_WD]   START pointers   </b>- HLS_STR_PTR_WD bits for each TLP. Valid with START</p>
    <p style="font-size : 16px"><b>[KMAX_NUM_TLPS_PER_CLK * (1 +HLS_HAL_STR_PTR_WD) +: KMAX_NUM_TLPS_PER_CLK]                      END flags    </b>- One bit for each TLP</p>
    <p style="font-size : 16px"><b>[KMAX_NUM_TLPS_PER_CLK * (2 +HLS_HAL_STR_PTR_WD) +: KMAX_NUM_TLPS_PER_CLK]                      ERROR flag   </b>- One bit for each TLP. Valid with END</p>
    <p style="font-size : 16px"><b>[KMAX_NUM_TLPS_PER_CLK * (3 +HLS_HAL_STR_PTR_WD) +: KMAX_NUM_TLPS_PER_CLK*HLS_HAL_END_PTR_WD]   END pointers </b>- HLS_HAL_END_PTR_WD bits for each TLP. Valid with END</p>
    <p style="font-size : 16px"><b>[HLS_HAL_PKT_CNTL_WD                             +: KMAX_NUM_TLPS_PER_CLK*HLS_HAL_OB_CNTL_WD]   METADATA     </b>- HLS_HAL_OB_CNTL_WD bits for each TLP. Valid with START</p>
   endvar:

   docvar:hls_ob_pnp_metadoc
   Meta-Data Decoding:
   <ul>
   <li><p style="font-size : 16px"><b>
    [0 +: 8]     PF                       </b></p>
    <p style="font-size : 16px">PF number or associated PF number in case of VF </p></li>
   <li><p style="font-size : 16px"><b>
    [8 +: 16]    VF                       </b></p>
    <p style="font-size : 16px">VF number in the associated PF </p></li>
   <li><p style="font-size : 16px"><b>
    [24 +: 1]    VF/PF                    </b></p>
    <p style="font-size : 16px">1 - Request is from VF<br> 0  Request is from PF </p></li>
   <li><p style="font-size : 16px"><b>
    [25 +: 1]    PF_VF_IS_VALID           </b></p>
    <p style="font-size : 16px">1 - controller computes {Dev,fn} number from supplied PF/VF
                                   (Only fn is updated if ari is disabled)<br>
                               0 - controller do not change {Dev,fn} </p></li>
   <li><p style="font-size : 16px"><b>
    [26 +: 1]    BUS_NUM_IN_TLP_IS_VALID  </b></p>
    <p style="font-size : 16px">1 - Controller do not change Bus number in TLP header<br>
                               0 - Controller inserts BUS number from captured bus number<br><br>
                               Device field is also updated if ARI is disabled.</p></li>
   <li><p style="font-size : 16px"><b>
    [27 +: 1]    REQ_SEG_IN_TLP_IS_VALID  </b></p>
    <p style="font-size : 16px">1 - Controller do not change segmentnumber in TLP header.<br>
                               0 - Controller insert segment number from captured segment number.<br><br>
                               If OHCA5 is present in completions or If RSV bit is set in OHCC for others,
                               then segmentno is inserted<br><br>This field is valid only when flit_mode is
                               active.</p>
   <li><p style="font-size : 16px"><b>
    [28 +: 12]   Reserved                </b></p>
    <p style="font-size : 16px">For future use</p>
   </ul>
   endvar:

   ;*/
   output wire [HLS_HAL_OB_PNP_CNTL_WD-1:0]                    hls_ob_posted_hal_cntl,
   /*BSF:doc=Credit grant signal from receive side.;*/
   input  wire                                             hls_ob_posted_hal_crdgnt,
   /*BSF:doc=Credit return during de-activation.;*/
   output wire                                             hls_ob_posted_hal_crdrtn,
   /*BSF:doc=Active request signal for activating and deactivating HLS bus;*/
   output wire                                             hls_ob_posted_hal_activereq,
   /*BSF:doc=Acknowledge from receive side for activereq. Client logic must acknowledge if deacthint is already asserted
      from client side. When link-down_in_progress is asserted, client logic must acknowledge HLS deactivation after
      handling link-down activities.;*/
   input  wire                                             hls_ob_posted_hal_activeack,
   /*BSF:doc=Hint from remote side to deactivate HLS bus. Client logic Need to assert this signal when its receive
      side buffers are idle. Controller uses that information to deactivate HLS bus and to enter low power state like L1.2;*/
   input  wire                                             hls_ob_posted_hal_deacthint,
   /*BSF:doc=Simple byte based parity information;*/
   output wire [KMAX_DATAPATH_WD_CHK-1:0]                    hls_ob_posted_hal_data_chk,
   /*BSF:doc=Spec compliant parity signal for packet control data. 5bits are reserved for packet-control parity.
   remaining bits holds byte-wise parity for metadata.;*/
   output wire [HLS_HAL_OB_PNP_CNTL_CHK_WD-1:0]                hls_ob_posted_hal_cntl_chk,
   /*BSF_IF_END:hls_posted_ob_hal_if;*/

   //------------------------------------------------------------------------------
   // HLS TX Non-posted I/F to HAL
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_nonposted_ob_hal_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_master_reqcompl,prefix_pattern=hls_ob_nonposted_
    ,dis=HLS Outbound Non-Posted HAL
    ,doc=TX interface for Non-Posted packets to HAL (ob). First set is for CIF0,
     second set is for CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ob_posted_hal_valid;*/
   output wire                                             hls_ob_nonposted_hal_valid,
   /*BSF:doc=printvar:hls_ob_posted_hal_data;*/
   output wire [KMAX_DATAPATH_WD-1:0]                      hls_ob_nonposted_hal_data,
   /*BSF:doc=printvar:hls_ob_posted_hal_cntl;*/
   output wire [HLS_HAL_OB_PNP_CNTL_WD-1:0]                    hls_ob_nonposted_hal_cntl,
   /*BSF:doc=printvar:hls_ob_posted_hal_crdgnt;*/
   input  wire                                             hls_ob_nonposted_hal_crdgnt,
   /*BSF:doc=printvar:hls_ob_posted_hal_crdrtn;*/
   output wire                                             hls_ob_nonposted_hal_crdrtn,
   /*BSF:doc=printvar:hls_ob_posted_hal_activereq;*/
   output wire                                             hls_ob_nonposted_hal_activereq,
   /*BSF:doc=printvar:hls_ob_posted_hal_activeack;*/
   input  wire                                             hls_ob_nonposted_hal_activeack,
   /*BSF:doc=printvar:hls_ob_posted_hal_deacthint;*/
   input  wire                                             hls_ob_nonposted_hal_deacthint,
   /*BSF:doc=printvar:hls_ob_posted_hal_data_chk;*/
   output wire [KMAX_DATAPATH_WD_CHK-1:0]                    hls_ob_nonposted_hal_data_chk,
   /*BSF:doc=printvar:hls_ob_posted_hal_cntl_chk;*/
   output wire [HLS_HAL_OB_PNP_CNTL_CHK_WD-1:0]                hls_ob_nonposted_hal_cntl_chk,
   /*BSF_IF_END:hls_nonposted_ob_hal_if;*/

   //------------------------------------------------------------------------------,
   // HLS TX Completion I/F to HAL
   //------------------------------------------------------------------------------,
   /*BSF_IF:hls_ob_compl_hal_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_slave_compl,prefix_pattern=hls_ob_compl_,agent_src=1,
    ,dis=HLS Outbound Completion HAL
    ,doc=TX interface for completion packets to HAL (OB). First set is for IDGO,CIF0,
     second set is for IDG1,CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ob_posted_hal_valid;*/
   output  wire                                            hls_ob_compl_hal_valid,
   /*BSF:doc=printvar:hls_ob_posted_hal_data;*/
   output  wire [KMAX_DATAPATH_WD-1:0]                     hls_ob_compl_hal_data,
   /*BSF:doc=
    printvar:common_hls_pkt_ctrl
   Meta-Data Decoding
   <ul>
    <li><p style="font-size : 16px"><b>
    [0 +: 8]     PF                </b></p><p style="font-size : 16px">        PF number or associated PF number in case of VF </p></li>
    <li><p style="font-size : 16px"><b>
    [8 +: 16]    VF                </b></p><p style="font-size : 16px">        VF number in the associated PF </p></li>
    <li><p style="font-size : 16px"><b>
    [24 +: 1]    VF/PF             </b></p><p style="font-size : 16px">        1 - Request is from VF<br>0 - Request is from PF </p></li>
    <li><p style="font-size : 16px"><b>
    [25 +: 1]    PF_VF_IS_VALID    </b></p><p style="font-size : 16px">        1 - controller computes {Dev,fn} number from supplied PF/VF (Only
                                                                                  fn is updated if ari is disabled)<br>
                                                                               0 - controller do not change {Dev,fn} </p></li>
    <li><p style="font-size : 16px"><b>
    [26 +: 1]    BUS_NUM_IN_TLP_IS_VALID </b></p><p style="font-size : 16px">  1 - Controller do not change Bus number in TLP header.<br>
                                                                               0 - Controller inserts BUS number from captured bus number<br><br>
                                                                               Device field is also updated if ARI is disabled.</p></li>
    <li><p style="font-size : 16px"><b>
    [27 +: 1]    REQ_SEG_IN_TLP_IS_VALID </b></p><p style="font-size : 16px">  1 - Controller do not change segment-number in TLP header.<br>
                                                                               0 - Controller insert segment-number from captured-segment-number<br><br>
                                                                               If OHC-A5 is present in completions or If RSV bit is set in
                                                                               OHC-C for others, then segment-no is inserted<br><br>
                                                                               This field is valid only when flit_mode is active.</p></li>
    <li><p style="font-size : 16px"><b>
    [28 +: 12]   Reserved                </b></p><p style="font-size : 16px">  For future use </p></li>
   </ul>
   ;*/
   output  wire [HLS_HAL_OB_C_CNTL_WD-1:0]                 hls_ob_compl_hal_cntl,
   /*BSF:doc=printvar:hls_ob_posted_hal_crdgnt;*/
   input wire                                            hls_ob_compl_hal_crdgnt,
   /*BSF:doc=printvar:hls_ob_posted_hal_crdrtn;*/
   output  wire                                          hls_ob_compl_hal_crdrtn,
   /*BSF:doc=printvar:hls_ob_posted_hal_activereq;*/
   output  wire                                          hls_ob_compl_hal_activereq,
   /*BSF:doc=printvar:hls_ob_posted_hal_activeack;*/
   input wire                                            hls_ob_compl_hal_activeack,
   /*BSF:doc=printvar:hls_ob_posted_hal_deacthint;*/
   input wire                                            hls_ob_compl_hal_deacthint,
   /*BSF:doc=printvar:hls_ob_posted_hal_data_chk;*/
   output  wire [KMAX_DATAPATH_WD_CHK-1:0]                 hls_ob_compl_hal_data_chk,
   /*BSF:doc=printvar:hls_ob_posted_hal_cntl_chk;*/
   output  wire [HLS_HAL_OB_C_CNTL_CHK_WD-1:0]             hls_ob_compl_hal_cntl_chk,
   /*BSF_IF_END:hls_ob_compl_hal_if;*/


   //------------------------------------------------------------------------------
   // HLS RX Posted I/F from AXI
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_ob_posted_axi_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_slave_req,prefix_pattern=hls_ob_posted_,agent_src=1
    ,dis=HLS Outbound  Posted AXI
    ,doc=RX interface for Posted packets from AXI bridge. First set is for IDGO,CIF0,
     second set is for IDG1,CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ob_posted_hal_valid;*/
    input  wire [NUM_HLS_PORTS-1:0]                          hls_ob_posted_axi_valid,
   /*BSF:doc=printvar:hls_ob_posted_hal_data;*/
    input  wire [HLS_PORT_DATA_WIDTHS-1:0]                   hls_ob_posted_axi_data,
   /*BSF:doc=printvar:hls_ob_posted_hal_cntl;*/
    input  wire [HLS_AXI_OB_PNP_CNTL_WD-1:0]                 hls_ob_posted_axi_cntl,
   /*BSF:doc=printvar:hls_ob_posted_hal_crdgnt;*/
    output wire [NUM_HLS_PORTS-1:0]                          hls_ob_posted_axi_crdgnt,
   /*BSF:doc=printvar:hls_ob_posted_hal_crdrtn;*/
    input  wire [NUM_HLS_PORTS-1:0]                          hls_ob_posted_axi_crdrtn,
   /*BSF:doc=printvar:hls_ob_posted_hal_activereq;*/
    input  wire [NUM_HLS_PORTS-1:0]                          hls_ob_posted_axi_activereq,
   /*BSF:doc=printvar:hls_ob_posted_hal_activeack;*/
    output wire [NUM_HLS_PORTS-1:0]                          hls_ob_posted_axi_activeack,
   /*BSF:doc=printvar:hls_ob_posted_hal_deacthint;*/
    output wire [NUM_HLS_PORTS-1:0]                          hls_ob_posted_axi_deacthint,
   /*BSF:doc=printvar:hls_ob_posted_hal_data_chk;*/
    input  wire [HLS_PORT_DATA_CHK_WIDTHS-1:0]               hls_ob_posted_axi_data_chk,
   /*BSF:doc=printvar:hls_ob_posted_hal_cntl_chk;*/
    input  wire [HLS_AXI_OB_PNP_CNTL_CHK_WD-1:0]             hls_ob_posted_axi_cntl_chk,
   /*BSF_IF_END:hls_ob_posted_axi_if;*/

   //------------------------------------------------------------------------------
   // HLS RX NonPosted I/F from AXI
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_ob_nonposted_axi_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_slave_req,prefix_pattern=hls_ob_nonposted_,agent_src=1
    ,dis=HLS Outbound  Non-Posted AXI
    ,doc=RX interface for Non-Posted packets from AXI bridge. First set is for IDGO,CIF0,
     second set is for IDG1,CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ob_posted_hal_valid;*/
    input  wire [NUM_HLS_PORTS-1:0]                          hls_ob_nonposted_axi_valid,
   /*BSF:doc=printvar:hls_ob_posted_hal_data;*/
    input  wire [HLS_PORT_DATA_WIDTHS-1:0]                   hls_ob_nonposted_axi_data,
   /*BSF:doc=printvar:hls_ob_posted_hal_cntl;*/
    input  wire [HLS_AXI_OB_PNP_CNTL_WD-1:0]                 hls_ob_nonposted_axi_cntl,
   /*BSF:doc=printvar:hls_ob_posted_hal_crdgnt;*/
    output wire [NUM_HLS_PORTS-1:0]                          hls_ob_nonposted_axi_crdgnt,
   /*BSF:doc=printvar:hls_ob_posted_hal_crdrtn;*/
    input  wire [NUM_HLS_PORTS-1:0]                          hls_ob_nonposted_axi_crdrtn,
   /*BSF:doc=printvar:hls_ob_posted_hal_activereq;*/
    input  wire [NUM_HLS_PORTS-1:0]                          hls_ob_nonposted_axi_activereq,
   /*BSF:doc=printvar:hls_ob_posted_hal_activeack;*/
    output wire [NUM_HLS_PORTS-1:0]                          hls_ob_nonposted_axi_activeack,
   /*BSF:doc=printvar:hls_ob_posted_hal_deacthint;*/
    output wire [NUM_HLS_PORTS-1:0]                          hls_ob_nonposted_axi_deacthint,
   /*BSF:doc=printvar:hls_ob_posted_hal_data_chk;*/
    input  wire [HLS_PORT_DATA_CHK_WIDTHS-1:0]               hls_ob_nonposted_axi_data_chk,
   /*BSF:doc=printvar:hls_ob_posted_hal_cntl_chk;*/
    input  wire [HLS_AXI_OB_PNP_CNTL_CHK_WD-1:0]             hls_ob_nonposted_axi_cntl_chk,
   /*BSF_IF_END:hls_ob_nonposted_axi_if;*/

   //------------------------------------------------------------------------------
   // HLS RX Completion I/F from AXI
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_ob_compl_axi_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_slave_reqcompl,prefix_pattern=hls_ib_compl_
    ,dis=HLS Outbound Completion AXI
    ,doc=RX interface for Completion packets from AXI bridge (OB). First set is for CIF0,
     second set is for CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ob_compl_hal_valid;*/
   input  wire [NUM_HLS_PORTS-1:0]                              hls_ob_compl_axi_valid,
   /*BSF:doc=printvar:hls_ob_compl_hal_data;*/
   input  wire [HLS_PORT_DATA_WIDTHS-1:0]                       hls_ob_compl_axi_data,
   /*BSF:doc=printvar:hls_ob_compl_hal_cntl;*/
   input  wire [HLS_AXI_OB_C_CNTL_WD-1:0]                       hls_ob_compl_axi_cntl,
   /*BSF:doc=printvar:hls_ob_compl_hal_crdgnt;*/
   output wire [NUM_HLS_PORTS-1:0]                              hls_ob_compl_axi_crdgnt,
   /*BSF:doc=printvar:hls_ob_compl_hal_crdrtn;*/
   input  wire [NUM_HLS_PORTS-1:0]                              hls_ob_compl_axi_crdrtn,
   /*BSF:doc=printvar:hls_ob_compl_hal_activereq;*/
   input  wire [NUM_HLS_PORTS-1:0]                              hls_ob_compl_axi_activereq,
   /*BSF:doc=printvar:hls_ob_compl_hal_activeack;*/
   output wire [NUM_HLS_PORTS-1:0]                              hls_ob_compl_axi_activeack,
   /*BSF:doc=printvar:hls_ob_compl_hal_deacthint;*/
   output wire [NUM_HLS_PORTS-1:0]                              hls_ob_compl_axi_deacthint,
   /*BSF:doc=printvar:hls_ob_compl_hal_data_chk;*/
   input  wire [HLS_PORT_DATA_CHK_WIDTHS-1:0]                   hls_ob_compl_axi_data_chk,
   /*BSF:doc=printvar:hls_ob_compl_hal_cntl_chk;*/
   input  wire [HLS_AXI_OB_C_CNTL_CHK_WD-1:0]                   hls_ob_compl_axi_cntl_chk,
   /*BSF_IF_END:hls_ob_compl_axi_if;*/

   //------------------------------------------------------------------------------
   // HLS RX Posted I/F from HAL
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_posted_ib_hal_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_master_req,prefix_pattern=hls_ib_posted_,agent_src=1
    ,dis=HLS Inbound Posted HAL
    ,doc=RX interface for Posted packets from HAL (IB). First set is for IDGO,CIF0,
     second set is for IDG1,CIF0 and so on.
   ;*/
   /*BSF:doc=Indicates that data and cntl are valid. Asserted only when credits are available.;*/
   input  wire                                             hls_ib_posted_hal_valid,
   /*BSF:doc=Data for packets;*/
   input  wire [KMAX_DATAPATH_WD-1:0]                      hls_ib_posted_hal_data,
   /*BSF:doc=
    printvar:common_hls_pkt_ctrl
    Meta Data decoding:
    <ul></p></li>
      <li><p style="font-size : 16px"><b>[0 +: 8]     PF                  </b></p><p style="font-size : 16px">PF Number or associated PF in VF case</p></li>
      <li><p style="font-size : 16px"><b>[8 +: 16]    VF                  </b></p><p style="font-size : 16px">VF number in the associated PF</p></li>
      <li><p style="font-size : 16px"><b>[24 +: 1]    VF/PF               </b></p><p style="font-size : 16px">1 - Request is from VF</p><p style="font-size : 16px"> 0 - Request is from PF</p></li>
      <li><p style="font-size : 16px"><b>[25 +: 1]    Reserved            </b></p></li>
      <li><p style="font-size : 16px"><b>[26 +: 1]    GENERATED_TLP       </b></p><p style="font-size : 16px">Internally generated TLP. Set for MSI, CPL timeout, Internally generated completions</p></li>
      <li><p style="font-size : 16px"><b>[27 +: 1]    BAR_PREFETCHABLE    </b></p><p style="font-size : 16px">Target BAR is pre-fetch-able</p></li>
      <li><p style="font-size : 16px"><b>[28 +: 3]    BAR                 </b></p><p style="font-size : 16px">for CXL {0-RCRB BAR, 1- MEMBAR0} for others {BAR number. 6- EROM, 7-No hit.}</p></li>
      <li><p style="font-size : 16px"><b>[31 +: 1]    Reserved            </b></p></li>
      <li><p style="font-size : 16px"><b>[32 +: 6]    BAR_APERTURE        </b></p><p style="font-size : 16px">Aperture of the target BAR. 0 - 128B, 1- 256B, 2- 512B aperture and so on</p></li>
      <li><p style="font-size : 16px"><b>[38+:  1]    CXL                 </b></p><p style="font-size : 16px">Request targets CXL.IO Space if enabled</p></li>
      <li><p style="font-size : 16px"><b>[39 +: 1]    Reserved            </b></li>
      <li><p style="font-size : 16px"><b>[40+:3]      TC                  </b></p><p style="font-size : 16px">TC field from TLP. This is for use in hls_split logic.</p></li>
      <li><p style="font-size : 16px"><b>[43+:3]      VC                  </b></p><p style="font-size : 16px">Associated VC for a packet. For use in hls_spilt logic and ordering logic.</p></li>
      <li><p style="font-size : 16px"><b>[46+:1]      IDO                 </b></p><p style="font-size : 16px">Matches IDO flag in TLP. Expected to be used by application in AXUser. Hls_split is expected to use the ID-Group field.</p></li>
      <li><p style="font-size : 16px"><b>[47+:1]      RO                  </b></p><p style="font-size : 16px">Matches RO flag in TLP. Expected to be used by hls_Split and application logic in AXUser.</p></li>
      <li><p style="font-size : 16px"><b>[48+:3]      idgroup             </b></p><p style="font-size : 16px">ID group of the associated packet if Requested-ID+PASID matches a window or hash. ID0 - no window match or SO(strict Order); </p></li>
      <li><p style="font-size : 16px"><b>[51+:14]     ro_tag              </b></p><p style="font-size : 16px">RO Tag associated with a packet. Used to track completion of a request at AXI</p></li>
      <li><p style="font-size : 16px"><b>[65+:1]      lrctag              </b></p><p style="font-size : 16px">LRCTAG response tag</p></li>
      <li><p style="font-size : 16px"><b>[6+:2]       lti_port_num        </b></p><p style="font-size : 16px">Index of LTI port which gave the translated response</p></li>
      <li><p style="font-size : 16px"><b>[8+:4]       lrattr              </b></p><p style="font-size : 16px">Translated response attributes</p></li>
      <li><p style="font-size : 16px"><b>[2+:3]       prot                </b></p><p style="font-size : 16px">AxPROT</p></li>
      <li><p style="font-size : 16px"><b>[5+:15]      mpam                </b></p><p style="font-size : 16px">AxMPAM</p></li>
      <li><p style="font-size : 16px"><b>[0+:16]      mecid               </b></p><p style="font-size : 16px">AxMECID</p></li>
      <li><p style="font-size : 16px"><b>[06+:1]      nse                 </b></p><p style="font-size : 16px">AxNSE</p></li>
      <li><p style="font-size : 16px"><b>[07+:8]      Rserved             </b></li></p></li>
   </ul>
   ;*/
   input  wire [HLS_HAL_IB_PNP_CNTL_WD-1:0]                    hls_ib_posted_hal_cntl,
   /*BSF:doc=Credit grant signal from receive side;*/
   output wire                                             hls_ib_posted_hal_crdgnt,
   /*BSF:doc=Credit return during de-activation;*/
   input  wire                                             hls_ib_posted_hal_crdrtn,
   /*BSF:doc=Active request signal for activating and deactivating HLS bus;*/
   input  wire                                             hls_ib_posted_hal_activereq,
   /*BSF:doc=Acknowledge from receive side for activereq. Client logic must acknowledge if deacthint is already asserted
      from client side. When link-down_in_progress is asserted, client logic must acknowledge HLS deactivation after
      handling link-down activities.;*/
   output wire                                             hls_ib_posted_hal_activeack,
   /*BSF:doc=Hint from remote side to deactivate HLS bus. Client logic Need to assert this signal when its receive
      side buffers are idle. Controller uses that information to deactivate HLS bus and to enter low power state like L1.2;*/
   output wire                                             hls_ib_posted_hal_deacthint,
   /*BSF:doc=Simple byte based parity information;*/
   input  wire [KMAX_DATAPATH_WD_CHK-1:0]                    hls_ib_posted_hal_data_chk,
   /*BSF:doc=Spec compliant parity signal for packet control data. 5bits are reserved for packet-control parity.
   remaining bits holds byte-wise parity for metadata.;*/
   input  wire [HLS_HAL_IB_PNP_CNTL_CHK_WD-1:0]                hls_ib_posted_hal_cntl_chk,
   /*BSF_IF_END:hls_posted_ib_hal_if;*/

   //------------------------------------------------------------------------------,
   // HLS RX Non-posted I/F to HAL
   //------------------------------------------------------------------------------,
   /*BSF_IF:hls_ib_nonposted_hal_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_master_req,prefix_pattern=hls_ib_nonposted_,
    ,dis=HLS Inbound Non-Posted HAL
    ,doc=RX interface for non-posted packets from HAL. First set is for IDGO,CIF0,
     second set is for IDG1,CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ib_posted_hal_valid;*/
    input  wire                                            hls_ib_nonposted_hal_valid,
   /*BSF:doc=printvar:hls_ib_posted_hal_data;*/
    input  wire [KMAX_DATAPATH_WD-1:0]                     hls_ib_nonposted_hal_data,
   /*BSF:doc=printvar:hls_ib_posted_hal_cntl;*/
    input  wire [HLS_HAL_IB_PNP_CNTL_WD-1:0]                   hls_ib_nonposted_hal_cntl,
   /*BSF:doc=printvar:hls_ib_posted_hal_crdgnt;*/
    output wire                                            hls_ib_nonposted_hal_crdgnt,
   /*BSF:doc=printvar:hls_ib_posted_hal_crdrtn;*/
    input  wire                                            hls_ib_nonposted_hal_crdrtn,
   /*BSF:doc=printvar:hls_ib_posted_hal_activereq;*/
    input  wire                                            hls_ib_nonposted_hal_activereq,
   /*BSF:doc=printvar:hls_ib_posted_hal_activeack;*/
    output wire                                            hls_ib_nonposted_hal_activeack,
   /*BSF:doc=printvar:hls_ib_posted_hal_deacthint;*/
    output wire                                            hls_ib_nonposted_hal_deacthint,
   /*BSF:doc=printvar:hls_ib_posted_hal_data_chk;*/
    input  wire [KMAX_DATAPATH_WD_CHK-1:0]                   hls_ib_nonposted_hal_data_chk,
   /*BSF:doc=printvar:hls_ib_posted_hal_cntl_chk;*/
    input  wire [HLS_HAL_IB_PNP_CNTL_CHK_WD-1:0]               hls_ib_nonposted_hal_cntl_chk,
   /*BSF_IF_END:hls_ib_nonposted_hal_if;*/
   //
   //------------------------------------------------------------------------------
   // HLS RX Completion I/F from HAL
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_ib_compl_hal_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_slave_reqcompl,prefix_pattern=hls_ib_compl_
    ,dis=HLS Inbound Completion HAL
    ,doc=RX interface for Completion packets from HAL (IB). First set is for CIF0,
     second set is for CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ib_posted_hal_valid;*/
   input  wire                                                       hls_ib_compl_hal_valid,
   /*BSF:doc=printvar:hls_ib_posted_hal_data;*/
   input  wire [KMAX_DATAPATH_WD-1:0]                                hls_ib_compl_hal_data,
   /*BSF:doc=
    printvar:common_hls_pkt_ctrl
    Meta Data decoding:
    <ul>
     <li>
      <p style="font-size : 16px"><b>[0 +: 8] PF</p></b>
      <p style="font-size : 16px">PF Number or associated PF in VF case </p>
     </li>
     <li>
      <p style="font-size : 16px"><b>[8 +: 16] VF</p></b>
      <p style="font-size : 16px">VF number in a PF</p>
     </li>
     <li>
      <p style="font-size : 16px"><b>[24 +: 1] VF/PF</p></b>
      <p style="font-size : 16px">1  Request is from VF<br>
                                  0  Request is from PF</p>
     </li>
     <li>
      <p style="font-size : 16px"><b>[25 +: 1] Reserved</p></b>
      <p style="font-size : 16px">For future use</p>
     </li>
     <li>
      <p style="font-size : 16px"><b>[26 +: 1] GENERATED_TLP</p></b>
      <p style="font-size : 16px">Internally generated TLP </p>
     </li>
     <li>
      <p style="font-size : 16px"><b>[27 +: 1] CPL_COMPLETE</p></b>
      <p style="font-size : 16px">Indicates that the current completions completes the request.</p>
     </li>
     <li>
      <p style="font-size : 16px"><b>[28 +: 4] CPL_ERROR_CODE</p></b>
        <p style="font-size : 16px">Error codes for completion:<br>
          0000  No error<br>
          0001  The Completion TLP is poisoned.<br>
          0010  RRS Received for Vendor ID Access. This code is set When CRS Software visibility is set and RRS received, for a CFG access to Vendor ID address<br>
          0011  Request terminated by a Completion with no data or there is byte count mismatch between request and completions from remote.<br>
          0100  The Current Completion being delivered has the same tag of an instanding request, but its Requester ID, TC, or Attr fields did not match with the parameters of the outstanding request.<br>
          0101  Error in starting address. The low address bits in the Completion TLP header did not match with the starting address of the next expected byte for the request.<br>
          0110  Request terminated as it is not in the type1 Base+limit range. Valid only for RP<br>
          1000  Request terminated by a Completion timein. Only TLPdescriptor fields are valid with this error.<br>
          1001  Request terminated by an FLR targeted at the Function that generated the request. Only TLPdescriptor fields are valid with this error.<br>
          1010  Request terminated with unexpected RRS or RCB violation for the memory packet<br>
          1100  Request terminated by a Completion with UR status(include other cases where spec allows to infer URCPL).<br>
          1101  Request terminated by a Completion with CA status.<br>
          1110  Request terminated by a Completion with RRS(CRS/MRS) status.
       </p>
     </li>
     <li><p style="font-size : 16px"><b>[32 +: 8]    Reserved            </b></li>
    </ul>
   ;*/
   input  wire [HLS_HAL_IB_C_CNTL_WD-1:0]                              hls_ib_compl_hal_cntl,
   /*BSF:doc=printvar:hls_ib_posted_hal_crdgnt;*/
   output wire                                                       hls_ib_compl_hal_crdgnt,
   /*BSF:doc=printvar:hls_ib_posted_hal_crdrtn;*/
   input  wire                                                       hls_ib_compl_hal_crdrtn,
   /*BSF:doc=printvar:hls_ib_posted_hal_activereq;*/
   input  wire                                                       hls_ib_compl_hal_activereq,
   /*BSF:doc=printvar:hls_ib_posted_hal_activeack;*/
   output wire                                                       hls_ib_compl_hal_activeack,
   /*BSF:doc=printvar:hls_ib_posted_hal_deacthint;*/
   output wire                                                       hls_ib_compl_hal_deacthint,
   /*BSF:doc=printvar:hls_ib_posted_hal_data_chk;*/
   input  wire [KMAX_DATAPATH_WD_CHK-1:0]                              hls_ib_compl_hal_data_chk,
   /*BSF:doc=printvar:hls_ib_posted_hal_cntl_chk;*/
   input  wire [HLS_HAL_IB_C_CNTL_CHK_WD-1:0]                          hls_ib_compl_hal_cntl_chk,
   /*BSF_IF_END:hls_ib_compl_hal_if;*/

   //------------------------------------------------------------------------------
   // HLS TX Posted I/F to AXI
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_posted_ib_axi_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_master_reqcompl,prefix_pattern=hls_ib_posted_
    ,dis=HLS Inbound Posted AXI
    ,doc=TX interface for Posted packets to AXI bridge (IB). First set is for CIF0,
     second set is for CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ib_posted_hal_valid;*/
   output wire [NUM_HLS_PORTS-1:0]                    hls_ib_posted_axi_valid,
   /*BSF:doc=printvar:hls_ib_posted_hal_data;*/
   output wire [HLS_PORT_DATA_WIDTHS-1:0]             hls_ib_posted_axi_data,
   /*BSF:doc=printvar:hls_ib_posted_hal_cntl;*/
   output wire [HLS_AXI_IB_PNP_CNTL_WD-1:0]           hls_ib_posted_axi_cntl,
   /*BSF:doc=printvar:hls_ib_posted_hal_crdgnt;*/
   input  wire [NUM_HLS_PORTS-1:0]                    hls_ib_posted_axi_crdgnt,
   /*BSF:doc=printvar:hls_ib_posted_hal_crdrtn;*/
   output wire [NUM_HLS_PORTS-1:0]                    hls_ib_posted_axi_crdrtn,
   /*BSF:doc=printvar:hls_ib_posted_hal_activereq;*/
   output wire [NUM_HLS_PORTS-1:0]                    hls_ib_posted_axi_activereq,
   /*BSF:doc=printvar:hls_ib_posted_hal_activeack;*/
   input  wire [NUM_HLS_PORTS-1:0]                    hls_ib_posted_axi_activeack,
   /*BSF:doc=printvar:hls_ib_posted_hal_deacthint;*/
   input  wire [NUM_HLS_PORTS-1:0]                    hls_ib_posted_axi_deacthint,
   /*BSF:doc=printvar:hls_ib_posted_hal_data_chk;*/
   output wire [HLS_PORT_DATA_CHK_WIDTHS-1:0]         hls_ib_posted_axi_data_chk,
   /*BSF:doc=printvar:hls_ib_posted_hal_cntl_chk;*/
   output wire [HLS_AXI_IB_PNP_CNTL_CHK_WD-1:0]       hls_ib_posted_axi_cntl_chk,
   /*BSF_IF_END:hls_posted_ib_axi_if;*/

   //------------------------------------------------------------------------------
   // HLS TX Non-posted I/F to AXI
   //------------------------------------------------------------------------------
   /*BSF_IF:hls_nonposted_ib_axi_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_master_reqcompl,prefix_pattern=hls_ib_nonposted_
    ,dis=HLS Inbound Non-Posted AXI
    ,doc=TX interface for Non-Posted packets to AXI bridge (IB). First set is for CIF0,
     second set is for CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ib_posted_hal_valid;*/
   output wire [NUM_HLS_PORTS-1:0]                    hls_ib_nonposted_axi_valid,
   /*BSF:doc=printvar:hls_ib_posted_hal_data;*/
   output wire [HLS_PORT_DATA_WIDTHS-1:0]             hls_ib_nonposted_axi_data,
   /*BSF:doc=printvar:hls_ib_posted_hal_cntl;*/
   output wire [HLS_AXI_IB_PNP_CNTL_WD-1:0]           hls_ib_nonposted_axi_cntl,
   /*BSF:doc=printvar:hls_ib_posted_hal_crdgnt;*/
   input  wire [NUM_HLS_PORTS-1:0]                    hls_ib_nonposted_axi_crdgnt,
   /*BSF:doc=printvar:hls_ib_posted_hal_crdrtn;*/
   output wire [NUM_HLS_PORTS-1:0]                    hls_ib_nonposted_axi_crdrtn,
   /*BSF:doc=printvar:hls_ib_posted_hal_activereq;*/
   output wire [NUM_HLS_PORTS-1:0]                    hls_ib_nonposted_axi_activereq,
   /*BSF:doc=printvar:hls_ib_posted_hal_activeack;*/
   input  wire [NUM_HLS_PORTS-1:0]                    hls_ib_nonposted_axi_activeack,
   /*BSF:doc=printvar:hls_ib_posted_hal_deacthint;*/
   input  wire [NUM_HLS_PORTS-1:0]                    hls_ib_nonposted_axi_deacthint,
   /*BSF:doc=printvar:hls_ib_posted_hal_data_chk;*/
   output wire [HLS_PORT_DATA_CHK_WIDTHS-1:0]         hls_ib_nonposted_axi_data_chk,
   /*BSF:doc=printvar:hls_ib_posted_hal_cntl_chk;*/
   output wire [HLS_AXI_IB_PNP_CNTL_CHK_WD-1:0]       hls_ib_nonposted_axi_cntl_chk,
   /*BSF_IF_END:hls_nonposted_ib_axi_if;*/

  //------------------------------------------------------------------------------,
   // HLS TX Completion I/F to AXI
   //------------------------------------------------------------------------------,
   /*BSF_IF:hls_ib_compl_axi_if,core_clk,core_rst_n,ipio=1
    ,agent=hls_master_compl,prefix_pattern=hls_ib_compl_,agent_src=1,
    ,dis=HLS Inbound Completion AXI
    ,doc=TX interface for completion packets to AXI bridge (IB). First set is for IDGO,CIF0,
     second set is for IDG1,CIF0 and so on.
   ;*/
   /*BSF:doc=printvar:hls_ib_compl_hal_valid;*/
   output wire [NUM_HLS_PORTS-1:0]                              hls_ib_compl_axi_valid,
   /*BSF:doc=printvar:hls_ib_compl_hal_data;*/
   output wire [HLS_PORT_DATA_WIDTHS-1:0]                       hls_ib_compl_axi_data,
   /*BSF:doc=printvar:hls_ib_compl_hal_cntl;*/
   output wire [HLS_AXI_IB_C_CNTL_WD-1:0]                       hls_ib_compl_axi_cntl,
   /*BSF:doc=printvar:hls_ib_compl_hal_crdgnt;*/
   input  wire [NUM_HLS_PORTS-1:0]                              hls_ib_compl_axi_crdgnt,
   /*BSF:doc=printvar:hls_ib_compl_hal_crdrtn;*/
   output wire [NUM_HLS_PORTS-1:0]                              hls_ib_compl_axi_crdrtn,
   /*BSF:doc=printvar:hls_ib_compl_hal_activereq;*/
   output wire [NUM_HLS_PORTS-1:0]                              hls_ib_compl_axi_activereq,
   /*BSF:doc=printvar:hls_ib_compl_hal_activeack;*/
   input  wire [NUM_HLS_PORTS-1:0]                              hls_ib_compl_axi_activeack,
   /*BSF:doc=printvar:hls_ib_compl_hal_deacthint;*/
   input  wire [NUM_HLS_PORTS-1:0]                              hls_ib_compl_axi_deacthint,
   /*BSF:doc=printvar:hls_ib_compl_hal_data_chk;*/
   output wire [HLS_PORT_DATA_CHK_WIDTHS-1:0]                   hls_ib_compl_axi_data_chk,
   /*BSF:doc=printvar:hls_ib_compl_hal_cntl_chk;*/
   output wire [HLS_AXI_IB_C_CNTL_CHK_WD-1:0]                   hls_ib_compl_axi_cntl_chk,
   /*BSF_IF_END:hls_ib_compl_axi_if;*/
   output wire                                                    dti_pri_supported,
   //------------------------------------------------------------------------------
   // AXI Lite Slave Interface
   //------------------------------------------------------------------------------
   /*BSF_IF:s_axil,axil_clk,axil_rst_n=0,ipio=1,
     agent=axil_master,prefix_pattern=axil_s_,agent_src=1,
     dis= AXI-Lite subordinate,
     doc= This AXI Lite Slave interface is for accessing the registers inside the HLS bridge
   ;*/
   /*BSF:doc=Write request valid;*/
   input   wire                                                      axil_s_awvalid,
   /*BSF:doc=Write request ready ;*/
   output wire                                                       axil_s_awready,
   /*BSF:doc=Transaction address;*/
   input   wire [AXIL_ADDR_WIDTH-1:0]                                axil_s_awaddr,
   /*BSF:doc=Protect;*/
   input   wire [AXIL_PROT_WIDTH-1:0]                                axil_s_awprot,
   /*BSF:doc=User;*/
   input   wire [AXIL_AWUSER_WIDTH-1:0]                              axil_s_awuser,
   /*BSF:doc=Write request valid;*/
   input   wire                                                      axil_s_wvalid,
   /*BSF:doc=Write request ready;*/
   output wire                                                       axil_s_wready,
   /*BSF:doc=Transaction data;*/
   input   wire [AXIL_DATA_WIDTH-1:0]                                axil_s_wdata,
   /*BSF:doc=strobe;*/
   input   wire [AXIL_STRB_WIDTH -1:0]                               axil_s_wstrb,
   /*BSF:doc=User;*/
   //input   wire [AXIL_WUSER_WIDTH-1:0]                               axil_s_wuser,  <-- TODO - confirm to remove
   /*BSF:doc=Write request valid;*/
   output wire                                                       axil_s_bvalid,
   /*BSF:doc=Write request ready;*/
   input   wire                                                      axil_s_bready,
   /*BSF:doc=Response;*/
   output wire [AXIL_RESP_WIDTH-1:0]                                 axil_s_bresp,
   /*BSF:doc=User;*/
//   output wire [AXIL_BUSER_WIDTH-1:0]                                axil_s_buser,
   /*BSF:doc=Read request valid;*/
   input   wire                                                      axil_s_arvalid,
   /*BSF:doc=Read request ready;*/
   output wire                                                       axil_s_arready,
   /*BSF:doc=Transaction address;*/
   input   wire [AXIL_ADDR_WIDTH-1:0]                                axil_s_araddr,
   /*BSF:doc=protect;*/
   input   wire [AXIL_PROT_WIDTH-1:0]                                axil_s_arprot,
   //BSF:doc=User;
   input   wire [AXIL_ARUSER_WIDTH-1:0]                              axil_s_aruser,
   /*BSF:doc=Read request valid;*/
   output wire                                                       axil_s_rvalid,
   /*BSF:doc=Read request ready;:*/
   input   wire                                                      axil_s_rready,
   /*BSF:doc=Transaction data;*/
   output wire [AXIL_DATA_WIDTH-1:0]                                 axil_s_rdata,
   /*BSF:doc=Response;*/
   output wire [AXIL_RESP_WIDTH-1:0]                                 axil_s_rresp,
   /*BSF:doc=User;*/
   //output wire [AXIL_RUSER_WIDTH-1:0]                                axil_s_ruser,
   //BSF:doc=User parity;
   //output wire [AXIL_RUSER_WIDTH_CHK-1:0]                            axil_s_ruser_chk,
   //BSF:doc=Write request valid parity;
   input   wire                                                      axil_s_awvalid_chk,
   //BSF:doc=Write request ready parity;
   output wire                                                       axil_s_awready_chk,
   //BSF:doc=Transaction address parity;
   input   wire [AXIL_ADDR_WIDTH_CHK-1:0]                            axil_s_awaddr_chk,
   //BSF:doc=User parity;
   input   wire [AXIL_AWUSER_WIDTH_CHK-1:0]                          axil_s_awuser_chk,
   //BSF:doc=AWPROT parity;
   input wire                                                        axil_s_awctl_chk0,
   /*BSF:doc=Write request valid parity;*/
   input   wire                                                      axil_s_wvalid_chk,
   //BSF:doc=Write request ready parity;
   output wire                                                       axil_s_wready_chk,
   //BSF:doc=Transaction data parity;
   input   wire [AXIL_DATA_WIDTH_CHK -1:0]                           axil_s_wdata_chk,
   //BSF:doc=strobe parity;
   input   wire [AXIL_STRB_WIDTH_CHK-1:0]                            axil_s_wstrb_chk,
   //BSF:doc=User parity;
//   input   wire [AXIL_WUSER_WIDTH_CHK-1:0]                           axil_s_wuser_chk, <-- TODO confirm to remove
   //BSF:doc=Write request valid parity;
   output wire                                                       axil_s_bvalid_chk,
   //BSF:doc=Write request ready parity;
   input   wire                                                      axil_s_bready_chk,
   //BSF:doc=Response parity;
   output wire [AXIL_RESP_WIDTH_CHK-1:0]                            axil_s_bresp_chk,
   //BSF:doc=User parity;
//   output wire [AXIL_BUSER_WIDTH_CHK-1:0]                            axil_s_buser_chk,
   //BSF:doc=Read request valid parity;
   input   wire                                                      axil_s_arvalid_chk,
   //BSF:doc=Read request ready parity;
   output wire                                                       axil_s_arready_chk,
   //BSF:doc=Transaction address parity;
   input   wire [AXIL_ADDR_WIDTH_CHK-1:0]                            axil_s_araddr_chk,
   //BSF:doc=control0 parity;
   input   wire                                                      axil_s_arctl_chk0,
   //BSF:doc=User parity;
   input   wire [AXIL_ARUSER_WIDTH_CHK-1:0]                          axil_s_aruser_chk,
   //BSF:doc=Read request valid parity;
   output wire                                                       axil_s_rvalid_chk,
   //BSF:doc=Read request ready;
   input   wire                                                      axil_s_rready_chk,
   //BSF:doc=Transaction data parity;
   output wire [AXIL_DATA_WIDTH_CHK-1:0]                             axil_s_rdata_chk,
   //BSF:doc=Response parity;
   output wire [AXIL_RESP_WIDTH_CHK-1:0]                             axil_s_rresp_chk,
  /*BSF_IF_END:s_axil;*/

   //------------------------------------------------------------------------------
   // AXI Lite Master Interface
   //------------------------------------------------------------------------------
   /*BSF_IF:m_axil,axil_clk,axil_rst_n=0,ipio=0,
     agent=axil_slave,prefix_pattern=axil_m_,agent_src=1,
     dis= AXI-Lite manager,
     doc= This AXI Lite Master of HLS bridge.
   ;*/
   /*BSF:ipio=0,doc=Write request valid;*/
   output  wire                                                      axil_m_awvalid,
   /*BSF:ipio=0,doc=Write request ready ;*/
   input wire                                                        axil_m_awready,
   /*BSF:doc=Transaction address;*/
   output  wire [AXIL_ADDR_WIDTH-1:0]                                axil_m_awaddr,
   /*BSF:doc=Protect;*/
   output  wire [AXIL_PROT_WIDTH-1:0]                                axil_m_awprot,
   /*BSF:doc=User;*/
   output  wire [AXIL_AWUSER_WIDTH-1:0]                              axil_m_awuser,
   /*BSF:ipio=0,doc=Write request valid;*/
   output  wire                                                      axil_m_wvalid,
   /*BSF:doc=Write request ready;*/
   input wire                                                        axil_m_wready,
   /*BSF:doc=Transaction data;*/
   output  wire [AXIL_DATA_WIDTH-1:0]                                axil_m_wdata,
   /*BSF:doc=strobe;*/
   output  wire [AXIL_STRB_WIDTH -1:0]                               axil_m_wstrb,
   /*BSF:doc=User;*/
//   output  wire [AXIL_WUSER_WIDTH-1:0]                               axil_m_wuser,
   /*BSF:ipio=0,doc=Write request valid;*/
   input wire                                                        axil_m_bvalid,
   /*BSF:doc=Write request ready;*/
   output  wire                                                      axil_m_bready,
   /*BSF:doc=Response;*/
   input wire [AXIL_RESP_WIDTH-1:0]                                  axil_m_bresp,
   /*BSF:doc=User;*/
//   input wire [AXIL_BUSER_WIDTH-1:0]                                 axil_m_buser,
   /*BSF:ipio=0,doc=Read request valid;*/
   output  wire                                                      axil_m_arvalid,
   /*BSF:doc=Read request ready;*/
   input wire                                                        axil_m_arready,
   /*BSF:doc=Transaction address;*/
   output  wire [AXIL_ADDR_WIDTH-1:0]                                axil_m_araddr,
   /*BSF:doc=protect;*/
   output  wire [AXIL_PROT_WIDTH-1:0]                                axil_m_arprot,
   //BSF:doc=User;
   output  wire [AXIL_ARUSER_WIDTH-1:0]                              axil_m_aruser,
   /*BSF:ipio=0,doc=Read request valid;*/
   input wire                                                        axil_m_rvalid,
   /*BSF:doc=Read request ready;:*/
   output  wire                                                      axil_m_rready,
   /*BSF:doc=Transaction data;*/
   input wire [AXIL_DATA_WIDTH-1:0]                                  axil_m_rdata,
   /*BSF:doc=Response;*/
   input wire [AXIL_RESP_WIDTH-1:0]                                  axil_m_rresp,
   /*BSF:doc=User;*/
 //  input wire [AXIL_RUSER_WIDTH-1:0]                                 axil_m_ruser,
   //BSF:doc=User parity;
//   input wire [AXIL_RUSER_WIDTH_CHK-1:0]                             axil_m_ruser_chk,
   //BSF:ipio=0,doc=Write request valid parity ;
   output  wire                                                      axil_m_awvalid_chk,
   //BSF:doc=Write request ready parity;
   input wire                                                        axil_m_awready_chk,
   //BSF:doc=Transaction address parity;
   output  wire [AXIL_ADDR_WIDTH_CHK-1:0]                            axil_m_awaddr_chk,
   //BSF:doc=User parity;
   output  wire [AXIL_AWUSER_WIDTH_CHK-1:0]                          axil_m_awuser_chk,
   //BSF:doc=Control0 parity;
   output  wire                                                      axil_m_awctl_chk0,
   /*BSF:doc=Write request valid parity;*/
   output  wire                                                      axil_m_wvalid_chk,
   //BSF:doc=Write request ready parity;
   input wire                                                        axil_m_wready_chk,
   //BSF:doc=Transaction data parity;
   output  wire [AXIL_DATA_WIDTH_CHK-1:0]                            axil_m_wdata_chk,
   //BSF:doc=strobe parity;
   output  wire [AXIL_STRB_WIDTH_CHK-1:0]                            axil_m_wstrb_chk,
   //BSF:doc=User parity;
//   output  wire [AXIL_WUSER_WIDTH_CHK-1:0]                           axil_m_wuser_chk,
   //BSF:doc=Write request valid parity;
   input wire                                                        axil_m_bvalid_chk,
   //BSF:doc=Write request ready parity;
   output  wire                                                      axil_m_bready_chk,
   //BSF:doc=Response parity;
   input wire [AXIL_RESP_WIDTH_CHK-1:0]                              axil_m_bresp_chk,
   //BSF:doc=User parity;
//   input wire [AXIL_BUSER_WIDTH_CHK-1:0]                             axil_m_buser_chk,
   //BSF:doc=Read request valid parity;
   output  wire                                                      axil_m_arvalid_chk,
   //BSF:doc=Read request ready parity;
   input wire                                                        axil_m_arready_chk,
   //BSF:doc=Transaction address parity;
   output  wire [AXIL_ADDR_WIDTH_CHK-1:0]                            axil_m_araddr_chk,
   //BSF:doc=control0 parity;
   output  wire                                                      axil_m_arctl_chk0,
   //BSF:doc=User parity;
   output  wire [AXIL_ARUSER_WIDTH_CHK-1:0]                          axil_m_aruser_chk,
   //BSF:doc=Read request valid parity;
   input wire                                                        axil_m_rvalid_chk,
   //BSF:doc=Read request ready;
   output  wire                                                      axil_m_rready_chk,
   //BSF:doc=Transaction data parity;
   input wire [AXIL_DATA_WIDTH_CHK-1:0]                              axil_m_rdata_chk,
   //BSF:doc=Response parity;
   input wire [AXIL_RESP_WIDTH_CHK-1:0]                              axil_m_rresp_chk,
  /*BSF_IF_END:m_axil;*/

   //------------------------------------------------------------------------------
   // AXI ASF Interface
   //------------------------------------------------------------------------------
   /*BSF_IF:asf_if,core_clk,core_rst_n,ipio=1,
     dis=ASF Interface,
     doc=Interface consists of signals related to ASF handling in HLS bridge.
   ;*/
//   input  wire                                                      asf_odd_parity,
//   output wire                                                      asf_error,
   input  wire                                                      asf_error_inj__cmd_tvalid,
//   output wire                                                      asf_error_inj__cmd_tready,
   input  wire [55:0]                                               asf_error_inj__tdata,
   input  wire [6:0]                                                asf_error_inj__tdatachk,
   input  wire [7:0]                                                asf_error_inj__tuser,
   input  wire                                                      asf_error_inj__tuserchk,
   input  wire                                                      asf_error_inj__tvalidchk,
//   output wire                                                      asf_diag__info_tready_o,
   output wire [31:0]                                               asf_diag__info_tdata_o,
   output wire [3:0]                                                asf_diag__info_tdatachk_o,
   output wire                                                      asf_diag__info_tvalid_o,
   output wire                                                      asf_diag__info_tvalidchk_o,
   output wire [47:0]                                               asf_diag__info_tuser_o,
   output wire [5:0]                                                asf_diag__info_tuserchk_o,
   /*BSF_IF_END:asf_if;*/

//// TBD ----> NUM_HLS_PORTS
//  Defines number of AXI ports.
//  It should match number of axi_bridge instances (NUM_HLS_PORTS) in most of the cases.
//  However IP configuration when AXI and HLS interfaces are exposed to SoC are also possible,
//  in this case:
//  NUM_HLS_PORTS != NUM_HLS_PORTS


//------------------------------------------------------------------------------
  // AXI Stream  Header to Log Master Interface //todo
  //------------------------------------------------------------------------------
  /*BSF_IF:hdr2log_s_if,core_clk,core_rst_n,ipio=1
   ,dis= Header to log subordinate
   ,doc=AXI Stream
  ;*/
  //BSF:doc=Data valid;
   input  wire  [NUM_HLS_PORTS-1:0]                            hdr2log_s_tvalid,
  //BSF:doc=Data valid parity;
   input  wire  [NUM_HLS_PORTS-1:0]                            hdr2log_s_tvalid_chk,
  //BSF:doc=Data ready;
   output wire  [NUM_HLS_PORTS-1:0]                            hdr2log_s_tready,
  //BSF:doc=Data ready parity;
   output wire  [NUM_HLS_PORTS-1:0]                            hdr2log_s_tready_chk,
  //BSF:doc=Data last;
   input  wire  [NUM_HLS_PORTS-1:0]                            hdr2log_s_tlast,
  //BSF:doc=Data last parity;
   input  wire  [NUM_HLS_PORTS-1:0]                            hdr2log_s_tlast_chk,
  //BSF:doc=Data ;
   input  wire  [HLS_PORT_DATA_WIDTHS-1:0]                     hdr2log_s_tdata,
  //BSF:doc=Data parity;
   input  wire  [HLS_PORT_DATA_CHK_WIDTHS-1:0]                 hdr2log_s_tdata_chk,
  //BSF:doc=User ;
   input  wire  [26*NUM_HLS_PORTS-1:0]                         hdr2log_s_tuser,
  //BSF:doc=User parity;
   input  wire  [4*NUM_HLS_PORTS-1:0]                          hdr2log_s_tuser_chk,
  //BSF_IF_END:hdr2log_s_if;

  //------------------------------------------------------------------------------
  // AXI Stream  Header to Log Slave Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:hdr2log_m_if,core_clk,core_rst_n,ipio=1
   ,dis= Header to log manager
   ,doc=AXI Stream
  ;*/
  //BSF:doc=Data valid;
   output  wire                                   hdr2log_m_tvalid,
  //BSF:doc=Data valid parity;
   output  wire                                   hdr2log_m_tvalid_chk,
  //BSF:doc=Data ready;
   input  wire                                    hdr2log_m_tready,
  //BSF:doc=Data ready parity;
   input  wire                                    hdr2log_m_tready_chk,
  //BSF:doc=Data last;
   output  wire                                   hdr2log_m_tlast,
  //BSF:doc=Data last parity;
   output  wire                                   hdr2log_m_tlast_chk,
  //BSF:doc=Data ;
   output  wire  [KMAX_DATAPATH_WD-1:0]           hdr2log_m_tdata,
  //BSF:doc=Data parity;
   output  wire  [KMAX_DATAPATH_WD_CHK-1:0]       hdr2log_m_tdata_chk,
  //BSF:doc=User ;
   output  wire  [25:0]                           hdr2log_m_tuser,
  //BSF:doc=User parity;
   output  wire  [3:0]                            hdr2log_m_tuser_chk,
  //BSF_IF_END:hdr2log_m_if;

  //------------------------------------------------------------------------------
  // AXI Stream DTI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:dti_axis_m_if,axi_dti_clk,axi_dti_rst_n,ipio=1,
    dis=DTI AXI Stream manager interface,
    doc=DTI downstream to SMMU.
  ;*/
  //BSF:doc=data valid;
   output wire                                                      tvalid_dti_dn,
  //BSF:doc=data valid parity;
   output wire                                                      tvalid_dti_dn_chk,
  //BSF:doc=data ready;
   input  wire                                                      tready_dti_dn,
  //BSF:doc=data ready parity;
   input  wire                                                      tready_dti_dn_chk,
  //BSF:doc=last;
   output wire                                                      tlast_dti_dn,
  //BSF:doc=last parity;
   output wire                                                      tlast_dti_dn_chk,
  //BSF:doc=keep;
   output wire  [DTI_TKEEP_WIDTH-1:0]                          tkeep_dti_dn,
  //BSF:doc=keep parity;
   output wire  [DTI_TKEEP_CHK_WIDTH-1:0]                      tkeep_dti_dn_chk,
  //BSF:doc=data;
   output wire  [DTI_TDATA_WIDTH-1:0]                          tdata_dti_dn,
  //BSF:doc=data parity;
   output wire  [DTI_TDATA_CHK_WIDTH-1:0]                      tdata_dti_dn_chk,
  //BSF:doc=wakeup;
   output wire                                                      twakeup_dti_dn,
  //BSF:doc=wakeup parity;
   output wire                                                      twakeup_dti_dn_chk,
  /*BSF_IF_END:dti_axis_m_if;*/

  //------------------------------------------------------------------------------
  // AXI Stream DTI RX Interface
  // ipio=1 ?? for intercses got outside pcie_IP
  //------------------------------------------------------------------------------
  /*BSF_IF:dti_axis_s_if,axi_dti_clk,axi_dti_rst_n=1,ipio=1,
    dis=DTI AXI Stream subordinate Interface,
    doc=DTI upstream to SMMU.
  ;*/
  //BSF:doc=data valid;
   input wire                                                      tvalid_dti_up,
  //BSF:doc=data valid parity;
   input wire                                                      tvalid_dti_up_chk,
  //BSF:doc=data ready;
   output  wire                                                    tready_dti_up,
  //BSF:doc=data ready parity;
   output  wire                                                    tready_dti_up_chk,
  //BSF:doc=last;
   input wire                                                      tlast_dti_up,
  //BSF:doc=last parity;
   input wire                                                      tlast_dti_up_chk,
  //BSF:doc=keep;
   input wire  [DTI_TKEEP_WIDTH-1:0]                          tkeep_dti_up,
  //BSF:doc=keep parity;
   input wire  [DTI_TKEEP_CHK_WIDTH-1:0]                      tkeep_dti_up_chk,
  //BSF:doc=data;
   input wire  [DTI_TDATA_WIDTH-1:0]                          tdata_dti_up,
  //BSF:doc=data parity;
   input wire  [DTI_TDATA_CHK_WIDTH-1:0]                      tdata_dti_up_chk,
  //BSF:doc=wakeup;
   input wire                                                      twakeup_dti_up,
  //BSF:doc=wakeup parity;
   input wire                                                      twakeup_dti_up_chk,
  /*BSF_IF_END:dti_axis_s_if;*/
  /*BSF_IF:dti_interrupt,core_clk,core_rst_n=1,ipio=0,
    dis=DTI AXI Interrupt Interface,
    doc=DTI interrupt to pcie core.
  ;*/
  //BSF:doc=DTI interrupt pulse;
   output wire                                                     dti_interrupt,
  /*BSF_IF_END:dti_interrupt;*/
  //---------------------------------------------------------------------
  // TDISP input request if
  //---------------------------------------------------------------------
  /* BSF_IF:tdisp_req_if,core_clk,core_rst_n,
   dis=Attribute Access Request (TDISP),
   doc=Interface for triggering Attribute Access Request towards register banks.;*/
  /*BSF:doc=Access Request valid indicator.;*/
  input wire                                          tdisp_req_valid,
  /*BSF:doc=Access Direction (0 – write 1 – read).;*/
  input wire                                          tdisp_req_read,
  /*BSF:doc=Register address in 32-bit register address space.;*/
  input wire [TDISP_ADDR_WIDTH-1:0]                   tdisp_req_register_address,
  /*BSF:doc=Field address in 32-bit register.;*/
  input wire [TDISP_FIELD_WIDTH-1:0]                  tdisp_req_field_address,
  /*BSF:doc=Written Attributes value.;*/
  input wire [TDISP_REXVALUE_WIDTH-1:0]               tdisp_req_value,
  //BSF_IF_END:tdisp_req_if;

  //---------------------------------------------------------------------
  // TDISP request ASF if
  //---------------------------------------------------------------------
  /*BSF_IF:tdisp_req_chk_if,core_clk,core_rst_n,
   dis=Attribute Access Acknowledge parity (TDISP),
  ;*/
  input wire                                   tdisp_req_validchk,
  input wire                                   tdisp_req_readchk,
  input wire [TDISP_ADDRCHK_WIDTH-1:0]         tdisp_req_addrchk,
  input wire [TDISP_FIELDCHK_WIDTH-1:0]        tdisp_req_fieldchk,
  input wire [TDISP_REXVALUECHK_WIDTH-1:0]     tdisp_req_valuechk,
  //BSF_IF_END:tdisp_req_chk_if;

  //---------------------------------------------------------------------
  // TDISP output read if
  //---------------------------------------------------------------------
  /*BSF_IF:tdisp_read_if,core_clk,core_rst_n,
   dis=Attribute Access Acknowledge (TDISP),
   doc=Intreface for receiving an attribute register value from register bank.;*/
  /*BSF:doc=Read attribute valid indicator.;*/
  output wire                             tdisp_read_valid,
  /*BSF:doc=Read register address.;*/
  output wire [TDISP_ADDR_WIDTH-1:0]      tdisp_read_register_address,
  /*BSF:doc=Read field address.;*/
  output wire [TDISP_FIELD_WIDTH-1:0]     tdisp_read_field_address,
  /*BSF:doc=Read Attributes value.;*/
  output wire [TDISP_REXVALUE_WIDTH-1:0]  tdisp_read_value,
  //BSF_IF_END:tdisp_read_if;

  //---------------------------------------------------------------------
  // TDISP request ASF if
  //---------------------------------------------------------------------
  /*BSF_IF:tdisp_read_chk_if,core_clk,core_rst_n,
   dis=Attribute Access Acknowledge parity (TDISP).;*/
   output wire                                    tdisp_read_validchk,
   output wire  [TDISP_ADDRCHK_WIDTH-1:0]         tdisp_read_addrchk,
   output wire  [TDISP_FIELDCHK_WIDTH-1:0]        tdisp_read_fieldchk,
   output wire  [TDISP_REXVALUECHK_WIDTH-1:0]     tdisp_read_valuechk,
  //BSF_IF_END:tdisp_read_chk_if;

  //---------------------------------------------------------------------
  //TDISP Notify if
  //---------------------------------------------------------------------
  /*BSF_IF:tdisp_notify_if,core_clk,core_rst_n,
   dis=Notification (TDISP),
   doc=Intreface for receiving suspicious access notification from register monitor in non-IDE register bank.;*/
  /*BSF:doc=Valid Notification ;*/
  output wire                                         tdisp_notify_valid,
  /*BSF:doc=Address pointing to a 32-bit register that TDISP monitor detects violation.;*/
  output wire [TDISP_ADDR_WIDTH-1:0]                  tdisp_notify_register_address,
  /*BSF:doc=Number pointing to a field that TDISP monitor detects violation.;*/
  output wire [TDISP_FIELD_WIDTH-1:0]                 tdisp_notify_field_address,
  /*BSF:doc=Notification value ;*/
  output wire [TDISP_NOTIFYVALUE_WIDTH-1:0]           tdisp_notify_value,
  /*BSF:doc=Notification origin.;*/
  output wire [TDISP_ORIGIN_WIDTH-1:0]                tdisp_notify_origin,
  /*BSF:doc=Notification index.;*/
  output wire [TDISP_INDEX_WIDTH-1:0]                 tdisp_notify_index,
  //BSF_IF_END:tdisp_notify_if;

  //---------------------------------------------------------------------
  // TDISP notofy ASF if
  //---------------------------------------------------------------------
  /*BSF_IF:tdisp_notify_chk_if,core_clk,core_rst_n,ipio=1,
    dis=Notify parity (TDISP),
  ;*/
   output wire                                    tdisp_notify_validchk,
   output wire  [TDISP_ADDRCHK_WIDTH-1:0]         tdisp_notify_addrchk,
   output wire  [TDISP_FIELDCHK_WIDTH-1:0]        tdisp_notify_fieldchk,
   output wire  [TDISP_NOTIFYVALUECHK_WIDTH-1:0]  tdisp_notify_valuechk,
   output wire  [TDISP_ORIGINCHK_WIDTH-1:0]       tdisp_notify_originchk,
   output wire  [TDISP_INDEXCHK_WIDTH-1:0]        tdisp_notify_indexchk,
  // BSF_IF_END:tdisp_notify_chk_if;

  //------------------------------------------------------------------------------
  // RAM interface
  //------------------------------------------------------------------------------
  //BSF_IF:np_lut_ram_if,core_clk,core_rst_n,ipio=1;
  output wire [15:0]                         ram_used_bits,
  output wire                                ram_write_valid,
  output wire [TOK_TRANS_BIN_WIDTH-1:0]      ram_write_addr,
  output wire [DTI_RAM_DATA_WIDTH-1:0]       ram_write_data,
  output wire                                ram_read_valid,
  output wire [TOK_TRANS_BIN_WIDTH-1:0]      ram_read_addr,
  input  wire [DTI_RAM_DATA_WIDTH-1:0]       ram_read_data,
  //BSF_IF_END:np_lut_ram_if;

  //------------------------------------------------------------------------------
  // AXI Stream MXI TX Interface
  //------------------------------------------------------------------------------
  /*BSF_IF:msi_axi_m_if,axi_msi_clk,axi_msi_rst_n=1,ipio=1,
    dis=MSI AXI Interface,
    doc=AXI Steream manager to Globabl Interupt Controller.
  ;*/
  //BSF:doc=data valid;
   output wire                                                     axis_msi_m_tvalid,
  //BSF:doc=data valid parity;
   output wire                                                     axis_msi_m_tvalid_chk,
  //BSF:doc=data ready;
   input  wire                                                     axis_msi_m_tready,
  //BSF:doc=data ready parity;
   input  wire                                                     axis_msi_m_tready_chk,
  //BSF:doc=data wakeup;
   output wire                                                     axis_msi_m_twakeup,
  //BSF:doc=data wakeup parity;
   output wire                                                     axis_msi_m_twakeup_chk,
  /*BSF:doc=Data to GIC:
     # [0  +:32] tlp_1st_dw from TLP
     # [32 +:16] tlp_req_id
     # [48 +:8]  lm_segment_num
     # [56 +:8]  8'h00
  ;*/
   output wire  [KMAX_MSI_TDATA_WIDTH-1:0]                         axis_msi_m_tdata,
  //BSF:doc=data parity;
   output wire  [KMAX_MSI_TDATA_WIDTH_CHK-1:0]                     axis_msi_m_tdata_chk,
  /*BSF_IF_END:msi_axi_m_if;*/

  //------------------------------------------------------------------------------
  // AXI Stream RX delivered count nterface
  //------------------------------------------------------------------------------
  /*BSF_IF:dc_axi_s_if,core_clk,core_rst_n,ipio=1,
    dis=Posted delivery count subordinate,
    doc=Delivered cound AXI-Stream Receiver from AXI-Bridge
  ;*/
  //BSF:doc=data valid;
   input  wire  [NUM_HLS_PORTS-1:0]                         dc_s_tvalid,
  //BSF:doc=data valid parity;
   input  wire  [NUM_HLS_PORTS-1:0]                         dc_s_tvalid_chk,
  /*BSF:doc= Posted Delivered Count Information
      # [0 +:9] COUNT Posted Delivered Count for given Stream ID.
      # [9 +:3] Stream ID number.
      # [12+:5] NA
   ;*/
   input  wire  [DC_TDATA_WIDTH*NUM_HLS_PORTS-1:0]          dc_s_tdata,
  //BSF:doc=data parity;
   input  wire  [DC_TDATA_CHK_WIDTH*NUM_HLS_PORTS-1:0]      dc_s_tdata_chk,
  //BSF_IF_END:dc_axi_s_if;

  //------------------------------------------------------------------------------
  // AXI Stream TX delivered count nterface
  //------------------------------------------------------------------------------
  /*BSF_IF:dc_axi_m_if,core_clk,core_rst_n,ipio=0,
    dis=Posted delivery count manager,
    doc=Delivered cound AXI-Stream transmiter to HAL.
  ;*/
  //BSF:doc=data valid;
   output wire                                                  dc_m_tvalid,
  //BSF:doc=data valid parity;
   output wire                                                  dc_m_tvalid_chk,
  /*BSF:doc= Posted Delivered Count Information
      # [0 +:9] COUNT Posted Delivered Count for given Stream ID.
      # [9 +:3] Stream ID number.
      # [12+:5] NA
  ;*/
   output wire  [DC_TDATA_WIDTH-1:0]                            dc_m_tdata,
  //BSF:doc=data parity;
   output wire  [DC_TDATA_CHK_WIDTH-1:0]                        dc_m_tdata_chk,
  //BSF_IF_END:dc_axi_m_if;

  //------------------------------------------------------------------------------
  //  Link down & low power mode interface
  //------------------------------------------------------------------------------
  /*BSF_IF:lp_if,async,ipio=0
   ,dis=Low Power Mode
   ,doc=When low_power_mode goes '1', it means that AXI Bridge is in low power mode, when the voltage supply is disabled.
        It is used to enable the logic in always-on power domain which will give signal to restore power to the rest of the controller.
  ;*/
  /*BSF:doc=When low_power_mode goes '1', it means that AXI Bridge is in low power mode, when the voltage supply is disabled.
            It is used to enable the logic in always-on power domain which will give signal to restore power to the rest of the controller.;*/
  input  wire                                                   low_power_mode,
   //BSF_IF_END:lp_if;

  /*BSF_IF:ld_if,core_clk,core_rst_n,ipio=1
   ,dis=Link Down handling in progress
   ,doc=When link_down_handling_in_progress goes ‘1’ then it means that PCIe link is lost and the link down handling procedure has started.
            This port will be cleared only when the procedure described in link down handling (flush) procedure is completed and all HLS interfaces are close.;*/
  input  wire                                                     link_down_handling_in_progress,
  //BSF_IF_END:ld_if;

  //------------------------------------------------------------------------------
  // Master Credit Limit interface
  //------------------------------------------------------------------------------
  /*BSF_IF:crd_m_lmt,core_clk,core_rst_n,ipio=1,
    dis=Credit limit interface manager,
    doc=Interface for posted and non-posted credit limit
    ;*/
   output  [KMAX_NUM_VCS*CRD_IN_LMT_HEADER_WIDTH-1:0]           crd_m_lmt_posted_header,
  //BSF:doc=manager posted credit limit payload;
   output  [KMAX_NUM_VCS*CRD_IN_LMT_PAYLOAD_WIDTH-1:0]          crd_m_lmt_posted_payload,
  /*BSF:doc=manager posted credit limit control
   # [0+:1] - header credits are infinite
   # [1+:1] - payload credits are infinite
   # [2+:2] - header scale value
   # [4+:2] - payload scale value
  ;*/
   output  [KMAX_NUM_VCS*CRD_IN_LMT_CNTL_WIDTH-1:0]             crd_m_lmt_posted_cntl,
  //BSF:doc=manager nonposted credit limit header;
   output  [KMAX_NUM_VCS*CRD_IN_LMT_HEADER_WIDTH-1:0]           crd_m_lmt_nonposted_header,
  //BSF:doc=manager nonposted credit limit payload;
   output  [KMAX_NUM_VCS*CRD_IN_LMT_PAYLOAD_WIDTH-1:0]          crd_m_lmt_nonposted_payload,
  /*BSF:doc=manager nonposted credit limit control;*/
   output  [KMAX_NUM_VCS*CRD_IN_LMT_CNTL_WIDTH-1:0]             crd_m_lmt_nonposted_cntl,
  //BSF_IF_END:crd_m_lmt;

  //------------------------------------------------------------------------------
  // Slave Credit Limit interface
  //------------------------------------------------------------------------------
  /*BSF_IF:crd_s_lmt,core_clk,core_rst_n,ipio=1,
    dis=Credit limit interface subordinate,
    doc=Interface for posted and non-posted credit limit
    ;*/
   input wire [KMAX_NUM_VCS*CRD_IN_LMT_HEADER_WIDTH-1:0]        crd_s_lmt_nonposted_header,
  //BSF:doc=subordinate posted credit limit payload;
   input wire [KMAX_NUM_VCS*CRD_IN_LMT_PAYLOAD_WIDTH-1:0]       crd_s_lmt_nonposted_payload,
  /*BSF:doc= subordinate posted credit limit control
    # [0+:1] - header credits are infinite
    # [1+:1] - payload credits are infinite
    # [2+:2] - header scale value
    # [4+:2] - payload scale value
  ;*/
   input wire [KMAX_NUM_VCS*CRD_IN_LMT_CNTL_WIDTH-1:0]          crd_s_lmt_nonposted_cntl,
  //BSF:doc=subordinate nonposted credit limit header;
   input wire [KMAX_NUM_VCS*CRD_IN_LMT_HEADER_WIDTH-1:0]        crd_s_lmt_posted_header,
  //BSF:doc=subordinate nonposted credit limit payload;
   input wire [KMAX_NUM_VCS*CRD_IN_LMT_PAYLOAD_WIDTH-1:0]       crd_s_lmt_posted_payload,
  /*BSF:doc=subordinate nonposted credit limit control
    # [0+:1] - header credits are infinite
    # [1+:1] - payload credits are infinite
    # [2+:2] - header scale value
    # [4+:2] - payload scale value
  ;*/
   input wire [KMAX_NUM_VCS*CRD_IN_LMT_CNTL_WIDTH-1:0]          crd_s_lmt_posted_cntl,
  //BSF_IF_END:crd_s_lmt;

  //------------------------------------------------------------------------------
  // QOS interface
  //------------------------------------------------------------------------------
  /*BSF_IF:qos_rx_if,core_clk,core_rst_n,ipio=1,
    dis=QOS RX interface,
    doc= Reduced AXI-Stream interface for handling TL buffer control from AXI-SW side,
  ;*/
   //bsf:doc= valid ;
   input wire [NUM_HLS_PORTS-1:0]                              tlp_qos_rx_tvalid,
   /*BSF:doc=TLP QOS Information
      {|
      {|
         [0  +:13]| COUNT      | One count indicates that all data, requests or responses associated with a single TLP from core side has been transferred/received. |-
         [13 +:1] | QOS_TYPE   | <b>1'b0</b> - Request <b>1'b1</b> - Response.|-
         [14 +:1] | TLP_TYPE   | <b>1'b0</b> - Indicates that the count is for Posted packets. <b>1'b1</b> - Indicates that the count is for NP TLPs.|-
         [15 +:3] | TLP_STREAM | TLP stream selection (NUM_TLP_STREAMS), possible configs: 1-8. This field is from HLS metadata. |-
         [18 +:6] | DUMMY      | Dummy bits to fill IF. |-
      |}
   ;*/
   input wire [NUM_HLS_PORTS*TLP_QOS_TDATA_WIDTH-1:0]          tlp_qos_rx_tdata,
   // ------------------------------ Parity
   /*BSF:doc=Valid parity;*/
   input wire [NUM_HLS_PORTS-1:0]                              tlp_qos_rx_tvalid_chk,
   /*BSF:doc=Data parity;*/
   input wire [NUM_HLS_PORTS*TLP_QOS_TDATA_CHK_WIDTH-1:0]      tlp_qos_rx_tdata_chk,
  //BSF_IF_END:qos_rx_if;

  //------------------------------------------------------------------------------
  // QOS interface
  //------------------------------------------------------------------------------
  /*BSF_IF:qos_tx_if,core_clk,core_rst_n,ipio=1,
    dis=QOS TX Interface,
    doc= Reduced AXI-Stream interface for handling TL buffer control to HAL layer,
  ;*/
   //bsf:doc= valid ;
   output wire                                                 tlp_qos_tx_tvalid,
   /*BSF:doc=TLP QOS Information
      {|
         [0  +:13] | COUNT      | One count indicates that all data, requests or responses associated with a single TLP from core side has been transferred/received. |-
         [13 +:1]  | QOS_TYPE   | <b>1'b0</b> - Request <b>1'b1</b> - Response. |-
         [14 +:1]  | TLP_TYPE   | <b>1'b0</b> - Indicates that the count is for Posted packets. <b>1'b1</b> - Indicates that the count is for NP TLPs.|-
         [15 +:3]  | TLP_STREAM | TLP stream selection (NUM_TLP_STREAMS), possible configs: 1-8. This field is from HLS metadata. |-
         [18 +:6]  | DUMMY      | Dummy bits to fill IF. |-
      |}
   ;*/
   output wire [TLP_QOS_TDATA_WIDTH-1:0]                      tlp_qos_tx_tdata,
   // ------------------------------ Parity
   /*BSF:doc=Valid parity;*/
   output wire                                                tlp_qos_tx_tvalid_chk,
   /*BSF:doc=Data parity;*/
   output wire [TLP_QOS_TDATA_CHK_WIDTH-1:0]                  tlp_qos_tx_tdata_chk,
  //BSF_IF_END:qos_tx_if;


  //------------------------------------------------------------------------------
  // LTI completion Rx interface
  //------------------------------------------------------------------------------
  /*BSF_IF:lti_completion_rx_if,core_clk,core_rst_n,ipio=1,
    dis=LTI completion Rx interface,
    doc=Reduced AXI-Stream interface for CTAG control from AXI-SW side,
  ;*/
   //BSF:doc=LTI completion valid;
    input wire [NUM_HLS_PORTS-1:0]                           lti_c_rx_tvalid,
    /*BSF:doc= vector multiply by NUM_HLS_PORTS
     # [0+:8] - Count Indicating how many packets received response with same tag and port_id 1 count indicates that all splits associated with that request is complete.
     # [8+:1] - CTAG  Tag for LTI completion.
     # [9+:2] - Port  ID Port number of LTI request.
     # [11+:5] - Dummy bits to fill i/f.
    ;*/
    input wire [NUM_HLS_PORTS*LTI_C_TDATA_WIDTH-1:0]         lti_c_rx_tdata,
   // ------------------------------ Parity
   //BSF:doc=LTI completion valid parity;
    input wire [NUM_HLS_PORTS-1:0]                           lti_c_rx_tvalid_chk,
   //BSF:doc=LTI completion data parity;
    input wire [NUM_HLS_PORTS*LTI_C_TDATA_CHK_WIDTH-1:0]     lti_c_rx_tdata_chk,
   //BSF_IF_END:lti_completion_rx_if;

  //------------------------------------------------------------------------------
  // LTI completion Tx interface
  //------------------------------------------------------------------------------
  /*BSF_IF:lti_completion_tx_if,core_clk,core_rst_n,ipio=1,
    dis=LTI completion Tx interface,
    doc=Reduced AXI-Stream interface for CTAG control to HAL layer,
  ;*/
   //BSF:doc=LTI completion valid;
    output wire                                              lti_c_tx_tvalid,
    /*BSF:doc=
     # [0+:8] - Count Indicating how many packets received response with same tag and port_id; 1 count indicates that all splits associated with that request is complete.
     # [8+:1] - CTAG  Tag for LTI completion.
     # [9+:2] - Port  ID Port number of LTI request.
     # [11+:5] - Dummy bits to fill i/f.
    ;*/
    output wire [LTI_C_TDATA_WIDTH-1:0]                      lti_c_tx_tdata,
   // ------------------------------ Parity
   //BSF:doc=LTI completion valid parity;
    output wire                                              lti_c_tx_tvalid_chk,
   //BSF:doc=LTI completion data parity;
    output wire [LTI_C_TDATA_CHK_WIDTH-1:0]                  lti_c_tx_tdata_chk,
   //BSF_IF_END:lti_completion_tx_if;

  //------------------------------------------------------------------------------
  //  Misc Inputs
  //------------------------------------------------------------------------------
  /*BSF_IF:misc_reg_clk_if,core_clk,core_rst_n,ipio=1,
    dis= Misc interface,
  ;*/
    /*BSF:doc=This signal indicates current mode (Non-Flit or Flit) of the controller:
     # 2'b00 - (Non-)Flit mode negotiation not complete
     # 2'b01 - Non-Flit mode active
     # 2'b10 - Flit mode active
     # 2'b11 - RESERVED
    ;*/
    input  wire [1:0]                                       misc_flit_mode,
    input  wire                                             misc_mld_negotiated,
    input  wire                                             misc_pbr_negotiated,
    input  wire [31:0]                                      misc_pbr_pth_for_generated,
    input  wire [61:0]                                      misc_msi_address,
    input  wire [31:0]                                      misc_hls_bridge_route_en,
    /*BSF:doc=Indicates whether 10-bit TAG Completer capability is enabled (1) or disabled (0).;*/
    input  wire                                             misc_10_bit_tag_completer_support,
    /*BSF:doc=Indicates whether 14-bit TAG Completer capability is enabled (1) or disabled (0).;*/
    input  wire                                             misc_14_bit_tag_completer_support,
    input  wire [7:0]                                       misc_captured_dest_segment,
    input  wire                                             misc_segment_captured,
    input  wire [KMAX_NUM_PFS-1:0]                          misc_ecrc_generation_enable_per_pf,
    /*BSF:doc=Indicates Read Completion Boundary (RCB) value (0 - 64 bytes, 1 - 128 bytes).;*/
    input  wire                                             misc_read_completion_boundary,
    /*BSF:doc=Mapping of Trafic-Class to Virtualc-Cannel;*/
    input  wire [4*NUM_TCS-1:0]                             tc_vc_mapping,
    /*BSF:doc=Tags offset and range for completion interface:
     # range_13_10   [26 +: 4]   TAG range - Client defines generated TAGs range,
     # range_9_0     [16 +: 10   TAG range - Client defines generated TAGs range,
     # offset_13_10  [10 +: 4]   TAG Offest - Client defines the offset from which TAGs are generated.
     # offset_9_0    [0  +: 10]  TAG Offest - Client defines the offset from which TAGs are generated.
    ;*/
    input wire  [NUM_HLS_PORTS*32-1:0]                    misc_tag_management,
    /*BSF:doc=Presents configuration of UIO Memory Write TAG pools (offset + range) for every AXI port. (width TBD);*/
    input  wire [NUM_HLS_PORTS*32-1:0]                    misc_uio_mwr_tag_management,
    /*BSF:doc= Link IDE Stream Control Register{Stream ID, TC, Enable};*/
    input  wire [IDE_NUM_LINK_STREAMS*12-1:0]               misc_ide_link_stream_control_reg,
    /*BSF:doc= Selective IDE Stream Control Register{Stream ID,TEE-Lim Stream,Default Stream TC, Enable};*/
    input  wire [IDE_NUM_SEL_STREAMS*14-1:0]                misc_ide_sel_stream_control_reg,
    /*BSF:doc= IDE RID Association Register 1{RID Limit};*/
    input  wire [IDE_NUM_SEL_STREAMS*16-1:0]                misc_ide_sel_stream_rid_assoc1_reg,
    /*BSF:doc= IDE RID Association Register 2{Segment Base,RID Base,Valid};*/
    input  wire [IDE_NUM_SEL_STREAMS*25-1:0]                misc_ide_sel_stream_rid_assoc2_reg,
  //BSF_IF_END:misc_reg_clk_if;

  //------------------------------------------------------------------------------
  // Configuration and control  ports
  //------------------------------------------------------------------------------
  /*BSF_IF:conf_control_if,core_clk,core_rst_n,ipio=1,
    dis=Control and cofiguration ports,
  ;*/
  /*BSF:doc=
   # Value 0 - select EP mode for IP
   # Value 1 - Select RP mode for IP
   # Value 2 - Select UP port mode for IP
   # Value 3 - Select DN port mode for IP
  ;*/
   input  [1:0]                                              strap_port_type,
  /*BSF:doc=
   # [0+:8] - segment number
   # [8+:1] - segment number valid
  ;*/
   input  [8:0]                                             lm_segment_num,
//BSF_IF_END:conf_control_if;


   output wire [(KMAX_DTI_SUPPORT+NUM_HLS_PORTS)-1:0]                       crd_dw_counter_ib_p_valid,
   output wire [(KMAX_DTI_SUPPORT+NUM_HLS_PORTS)*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_p,
   output wire [(KMAX_DTI_SUPPORT+NUM_HLS_PORTS)-1:0]                       crd_dw_counter_ib_p_valid_chk,
   output wire [(KMAX_DTI_SUPPORT+NUM_HLS_PORTS)*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_p_chk,
   output wire [(KMAX_DTI_SUPPORT+NUM_HLS_PORTS)-1:0]                       crd_dw_counter_ib_np_valid,
   output wire [(KMAX_DTI_SUPPORT+NUM_HLS_PORTS)*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_np,
   output wire [(KMAX_DTI_SUPPORT+NUM_HLS_PORTS)-1:0]                       crd_dw_counter_ib_np_valid_chk,
   output wire [(KMAX_DTI_SUPPORT+NUM_HLS_PORTS)*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_np_chk,
   output wire [                   NUM_HLS_PORTS-1:0]                       crd_dw_counter_ib_c_valid,
   output wire [                   NUM_HLS_PORTS*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_c,
   output wire [                   NUM_HLS_PORTS-1:0]                       crd_dw_counter_ib_c_valid_chk,
   output wire [                   NUM_HLS_PORTS*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_c_chk
   
   
//   output wire [1-1:0]                       crd_dw_counter_ib_p_valid,  //SUM OF: AXI0,AXI1,..,AXI7+DTI+MSI
//   output wire [1*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_p,
//   output wire [1-1:0]                       crd_dw_counter_ib_p_valid_chk,
//   output wire [1*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_p_chk,
//   output wire [1-1:0]                       crd_dw_counter_ib_np_valid, //SUM OF: AXI0,AXI1,..,AXI7+DTI
//   output wire [1*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_np,
//   output wire [1-1:0]                       crd_dw_counter_ib_np_valid_chk,
//   output wire [1*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_np_chk,
//   output wire [1-1:0]                       crd_dw_counter_ib_c_valid, //SUM OF: AXI0,AXI1,..,AXI7
//   output wire [1*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_c,
//   output wire [1-1:0]                       crd_dw_counter_ib_c_valid_chk,
//   output wire [1*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_c_chk
   
//   output wire [NUM_TLP_STREAMS-1:0]                       crd_dw_counter_ib_p_valid,
//   output wire [NUM_TLP_STREAMS*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_p,
//   output wire [NUM_TLP_STREAMS-1:0]                       crd_dw_counter_ib_p_valid_chk,
//   output wire [NUM_TLP_STREAMS*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_p_chk,
//   output wire [NUM_TLP_STREAMS-1:0]                       crd_dw_counter_ib_np_valid,
//   output wire [NUM_TLP_STREAMS*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_np,
//   output wire [NUM_TLP_STREAMS-1:0]                       crd_dw_counter_ib_np_valid_chk,
//   output wire [NUM_TLP_STREAMS*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_np_chk,
//   output wire [NUM_TLP_STREAMS-1:0]                       crd_dw_counter_ib_c_valid,
//   output wire [NUM_TLP_STREAMS*CRD_DW_COUNTER_WD-1:0]     crd_dw_counter_ib_c,
//   output wire [NUM_TLP_STREAMS-1:0]                       crd_dw_counter_ib_c_valid_chk,
//   output wire [NUM_TLP_STREAMS*CRD_DW_COUNTER_CHK_WD-1:0] crd_dw_counter_ib_c_chk




/// TBD ---> pcie_tag_start_end Input. Set of signals based on NUM_HLS_PORTS.
/*AUTOARG*/);

`include "param_arr_func.vh" //TBD PARAM
  /*AUTOREG*/

  // End of internal regs

  /*AUTOWIRE*/

  localparam NUM_RX_HLS_PORTS_OB_P  = NUM_HLS_PORTS+KMAX_DTI_SUPPORT;
  localparam NUM_RX_HLS_PORTS_OB_NP = NUM_HLS_PORTS;
  localparam NUM_RX_HLS_PORTS_OB_C  = NUM_HLS_PORTS+KMAX_DTI_SUPPORT;

  localparam NUM_TX_HLS_PORTS_IB_P  = NUM_HLS_PORTS+KMAX_DTI_SUPPORT;
  localparam NUM_TX_HLS_PORTS_IB_NP = NUM_HLS_PORTS+KMAX_DTI_SUPPORT;
  localparam NUM_TX_HLS_PORTS_IB_C  = NUM_HLS_PORTS;
 //------------------------------------------------------------------------------
  // MSI TX Delivery count I/F
  //------------------------------------------------------------------------------
  wire                                             dc_tx_send_msi_pck;
  wire                                             dc_tx_msi_valid;
  wire [MSI_DC_DATA_WIDTH-1:0]                     dc_tx_msi_data;
  wire                                             dc_tx_msi_valid_chk;
  wire                                             dc_tx_msi_data_chk;
  //------------------------------------------------------------------------------
  //  MSI TX LTIC Interface
  //------------------------------------------------------------------------------
  wire [MSI_LTIC_DATA_WIDTH-1:0]                   ltic_tx_msi_data;
  wire                                             ltic_tx_msi_valid;
  wire                                             ltic_tx_msi_data_chk;
  wire                                             ltic_tx_msi_valid_chk;

  //------------------------------------------------------------------------------
  //  MSI TX QOS Interface
  //------------------------------------------------------------------------------
  wire [MSI_QOS_DATA_WIDTH-1:0]                    qos_tx_msi_data;
  wire                                             qos_tx_msi_valid;
  wire                                             qos_tx_msi_data_chk;
  wire                                             qos_tx_msi_valid_chk;
  //------------------------------------------------------------------------------
  //  sideband delivery count Interface
  //------------------------------------------------------------------------------
  wire [NUM_HLS_PORTS-1:0]                         sb_ib_p_axi_queue_empty;
  wire                                             sb_ib_p_msi_queue_empty;
  wire                                             sb_ib_p_dti_queue_empty;

  wire [NUM_HLS_PORTS*KMAX_NUM_TLPS_PER_CLK-1:0]   sb_tlp_route_to_axi;
  wire [KMAX_NUM_TLPS_PER_CLK-1:0]                 sb_tlp_route_to_msi;
  wire [KMAX_NUM_TLPS_PER_CLK-1:0]                 sb_tlp_route_to_dti;
  wire [KMAX_NUM_TLPS_PER_CLK*METADATA_IDG_WD-1:0] sb_tlp_stream_packed;

  wire [NUM_TLP_STREAMS*NUM_HLS_PORTS-1:0]         sb_ib_p_axi_stream_empty;
  wire [NUM_TLP_STREAMS-1:0]                       sb_ib_p_dti_stream_empty;
  wire [NUM_TLP_STREAMS-1:0]                       sb_ib_p_msi_stream_empty;


  //------------------------------------------------------------------------------
  // DTI TX header to log I/F
  //------------------------------------------------------------------------------
   wire                                            hdr2log_tx_dti_tvalid;
   wire                                            hdr2log_tx_dti_tvalid_chk;
   wire                                            hdr2log_tx_dti_tready;
   wire                                            hdr2log_tx_dti_tready_chk;
   wire                                            hdr2log_tx_dti_tlast;
   wire                                            hdr2log_tx_dti_tlast_chk;
   wire  [KMAX_DATAPATH_WD-1:0]                    hdr2log_tx_dti_tdata;
   wire  [KMAX_DATAPATH_WD_CHK-1:0]                hdr2log_tx_dti_tdata_chk;
   wire  [25:0]                                    hdr2log_tx_dti_tuser;
   wire  [3:0]                                     hdr2log_tx_dti_tuser_chk;

  //------------------------------------------------------------------------------
  // DTI TX Delivery count I/F
  //------------------------------------------------------------------------------
   wire                                           dc_dti_tvalid;
   wire    [DC_TDATA_WIDTH-1:0]                   dc_dti_tdata;
   wire                                           dc_dti_tvalid_chk;
   wire    [DC_TDATA_CHK_WIDTH-1:0]               dc_dti_tdata_chk;


  //------------------------------------------------------------------------------
  // HLS IB Posted MSI I/F
  //------------------------------------------------------------------------------
   wire                                             ib_posted_msi_ready;
   wire                                             ib_posted_msi_valid;
   wire                                             ib_posted_msi_valid_chk;
   wire [MSI_PAYLOAD_WD-1:0]                        ib_posted_msi_payload;
   wire [MSI_PAYLOAD_CHK_WD-1:0]                    ib_posted_msi_payload_chk;


  //------------------------------------------------------------------------------
  // HLS IB Posted DTI I/F
  //------------------------------------------------------------------------------
   wire                                             hls_ib_posted_dti_valid;
   wire [KMAX_DATAPATH_WD-1:0]                      hls_ib_posted_dti_data;
   wire [HLS_HAL_IB_PNP_CNTL_WD-1:0]                hls_ib_posted_dti_cntl;
   wire                                             hls_ib_posted_dti_crdgnt;
   wire                                             hls_ib_posted_dti_crdrtn;
   wire                                             hls_ib_posted_dti_activereq;
   wire                                             hls_ib_posted_dti_activeack;
   wire                                             hls_ib_posted_dti_deacthint;
   wire [KMAX_DATAPATH_WD_CHK-1:0]                  hls_ib_posted_dti_data_chk;
   wire [HLS_HAL_IB_PNP_CNTL_CHK_WD-1:0]            hls_ib_posted_dti_cntl_chk;
   wire                                             hls_ib_posted_dti_pri_supported;
  //------------------------------------------------------------------------------
  // HLS IB nonposted DTI I/F
  //------------------------------------------------------------------------------
   wire                                             hls_ib_nonposted_dti_valid;
   wire [KMAX_DATAPATH_WD-1:0]                      hls_ib_nonposted_dti_data;
   wire [HLS_HAL_IB_PNP_CNTL_WD-1:0]                hls_ib_nonposted_dti_cntl;
   wire                                             hls_ib_nonposted_dti_crdgnt;
   wire                                             hls_ib_nonposted_dti_crdrtn;
   wire                                             hls_ib_nonposted_dti_activereq;
   wire                                             hls_ib_nonposted_dti_activeack;
   wire                                             hls_ib_nonposted_dti_deacthint;
   wire [KMAX_DATAPATH_WD_CHK-1:0]                  hls_ib_nonposted_dti_data_chk;
   wire [HLS_HAL_IB_PNP_CNTL_CHK_WD-1:0]            hls_ib_nonposted_dti_cntl_chk;

  //------------------------------------------------------------------------------
  // HLS IB completion DTI I/F
  //------------------------------------------------------------------------------
   wire                                             hls_ob_compl_dti_valid;
   wire [KMAX_DATAPATH_WD-1:0]                      hls_ob_compl_dti_data;
   wire [HLS_HAL_OB_C_CNTL_WD-1:0]                  hls_ob_compl_dti_cntl;
   wire                                             hls_ob_compl_dti_crdgnt;
   wire                                             hls_ob_compl_dti_crdrtn;
   wire                                             hls_ob_compl_dti_activereq;
   wire                                             hls_ob_compl_dti_activeack;
   wire                                             hls_ob_compl_dti_deacthint;
   wire [KMAX_DATAPATH_WD_CHK-1:0]                  hls_ob_compl_dti_data_chk;
   wire [HLS_HAL_OB_C_CNTL_CHK_WD-1:0]              hls_ob_compl_dti_cntl_chk;


  //------------------------------------------------------------------------------
  // HLS OB posted DTI I/F
  //------------------------------------------------------------------------------
   wire                                             hls_ob_posted_dti_valid;
   wire [KMAX_DATAPATH_WD-1:0]                      hls_ob_posted_dti_data;
   wire [HLS_HAL_OB_PNP_CNTL_WD-1:0]                hls_ob_posted_dti_cntl;
   wire                                             hls_ob_posted_dti_crdgnt;
   wire                                             hls_ob_posted_dti_crdrtn;
   wire                                             hls_ob_posted_dti_activereq;
   wire                                             hls_ob_posted_dti_activeack;
   wire                                             hls_ob_posted_dti_deacthint;
   wire [KMAX_DATAPATH_WD_CHK-1:0]                  hls_ob_posted_dti_data_chk;
   wire [HLS_HAL_OB_PNP_CNTL_CHK_WD-1:0]            hls_ob_posted_dti_cntl_chk;



  //------------------------------------------------------------------------------
  // DTI Slave Credit Limit interface
  //------------------------------------------------------------------------------
   wire  [KMAX_NUM_VCS*CRD_IN_LMT_HEADER_WIDTH-1:0]  crd_dti_lmt_posted_header;
   wire  [KMAX_NUM_VCS*CRD_IN_LMT_PAYLOAD_WIDTH-1:0] crd_dti_lmt_posted_payload;

  //------------------------------------------------------------------------------
  // AXIL Master interconnect internal interface
  //------------------------------------------------------------------------------
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_awvalid;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_awready;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_ADDR_WIDTH-1:0]             internal_axil_m_awaddr;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_PROT_WIDTH-1:0]             internal_axil_m_awprot;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_AWUSER_WIDTH-1:0]           internal_axil_m_awuser;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_wvalid;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_wready;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_DATA_WIDTH-1:0]             internal_axil_m_wdata;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_STRB_WIDTH -1:0]            internal_axil_m_wstrb;
//  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_WUSER_WIDTH-1:0]            internal_axil_m_wuser;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_bvalid;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_bready;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_RESP_WIDTH-1:0]             internal_axil_m_bresp;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_BUSER_WIDTH-1:0]            internal_axil_m_buser;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_arvalid;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_arready;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_ADDR_WIDTH-1:0]             internal_axil_m_araddr;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_PROT_WIDTH-1:0]             internal_axil_m_arprot;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_ARUSER_WIDTH-1:0]           internal_axil_m_aruser;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_rvalid;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_rready;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_DATA_WIDTH-1:0]             internal_axil_m_rdata;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_RESP_WIDTH-1:0]             internal_axil_m_rresp;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_RUSER_WIDTH-1:0]            internal_axil_m_ruser;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_RUSER_WIDTH_CHK-1:0]        internal_axil_m_ruser_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_awvalid_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_awready_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_ADDR_WIDTH_CHK-1:0]         internal_axil_m_awaddr_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_AWUSER_WIDTH_CHK-1:0]       internal_axil_m_awuser_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_awctl_chk0;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_wvalid_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_wready_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_DATA_WIDTH/8 -1:0]          internal_axil_m_wdata_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_STRB_WIDTH_CHK-1:0]         internal_axil_m_wstrb_par;
//  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_WUSER_WIDTH_CHK-1:0]        internal_axil_m_wuser_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_bvalid_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_bready_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_RESP_WIDTH_CHK-1:0]         internal_axil_m_bresp_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_BUSER_WIDTH_CHK-1:0]        internal_axil_m_buser_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_arvalid_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_arready_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_ADDR_WIDTH_CHK-1:0]         internal_axil_m_araddr_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_arctl_chk0;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_ARUSER_WIDTH_CHK-1:0]       internal_axil_m_aruser_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_rvalid_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER-1:0]                             internal_axil_m_rready_par;
  wire [AXIL_DATA_WIDTH_CHK-1:0]                                   internal_reg_axil_m_rdata_para;
  wire [AXIL_RESP_WIDTH_CHK-1:0]                                   internal_reg_axil_m_rresp_par;

  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_DATA_WIDTH_CHK-1:0]         internal_axil_m_rdata_par;
  wire [INTERNAL_AXIL_M_IF_NUMBER*AXIL_RESP_WIDTH_CHK-1:0]         internal_axil_m_rresp_par;
  //------------------------------------------------------------------------------
  // Connected signals from modules (positions [0:1]) - to avoid multiple drivers
  // These will be concatenated with external signals (position [2])
  // 0 is connection to hls_bridge_regs, 1 is dti regs
  //------------------------------------------------------------------------------
  wire [1:0]                                  connected_internal_axil_m_arready;
  wire [1:0]                                  connected_internal_axil_m_awready;
  wire [2*AXIL_RESP_WIDTH-1:0]                connected_internal_axil_m_bresp;
  wire [1:0]                                  connected_internal_axil_m_bvalid;
  wire [2*AXIL_RESP_WIDTH-1:0]                connected_internal_axil_m_rresp;
  wire [1:0]                                  connected_internal_axil_m_rvalid;
  wire [1:0]                                  connected_internal_axil_m_wready;
  wire [2*AXIL_DATA_WIDTH-1:0]                connected_internal_axil_m_rdata;
  // Parity/check signals
  wire [2*AXIL_RESP_WIDTH_CHK-1:0]            connected_internal_axil_m_rresp_par;
  wire [2*AXIL_RESP_WIDTH_CHK-1:0]            connected_internal_axil_m_bresp_par;
  wire [1:0]                                  connected_internal_axil_m_awready_par;
  wire [1:0]                                  connected_internal_axil_m_wready_par;
  wire [1:0]                                  connected_internal_axil_m_bvalid_par;
  wire [1:0]                                  connected_internal_axil_m_arready_par;
  wire [1:0]                                  connected_internal_axil_m_rvalid_par;
  wire [2*AXIL_DATA_WIDTH_CHK-1:0]            connected_internal_axil_m_rdata_par;
  //------------------------------------------------------------------------------
  // HLS-BRIDGE regs connection
  //------------------------------------------------------------------------------
  // hls_bridge_cfg Register
  wire          hls_bridge_cfg_idg_en_o;
  wire          hls_bridge_cfg_tc_en_o;
  wire          hls_bridge_cfg_vc_en_o;
  wire          hls_bridge_cfg_tfc_en_o;
  wire          hls_bridge_cfg_addr_window_en_o;
  wire          hls_bridge_cfg_tfc_ro_chk_en_o;
  wire          hls_bridge_cfg_axi_force_en_o;

  // hls_bridge_tlp_start_addr_lower Register
  wire [31 : 0] hls_bridge_tlp_start_addr_lower_hls_bridge_tlp_start_addr_lower_o;

  // hls_bridge_tlp_start_addr_upper Register
  wire [31 : 0] hls_bridge_tlp_start_addr_upper_hls_bridge_tlp_start_addr_upper_o;

  // hls_bridge_tlp_end_addr_lower Register
  wire [31 : 0] hls_bridge_tlp_end_addr_lower_hls_bridge_tlp_end_addr_lower_o;

  // hls_bridge_tlp_end_addr_upper Register
  wire [31 : 0] hls_bridge_tlp_end_addr_upper_hls_bridge_tlp_end_addr_upper_o;

  // hls_bridge_idg_port_map_1 Register
  wire          hls_bridge_idg_port_map_1_idg0_port1_en_o;
  wire          hls_bridge_idg_port_map_1_idg1_port1_en_o;
  wire          hls_bridge_idg_port_map_1_idg2_port1_en_o;
  wire          hls_bridge_idg_port_map_1_idg3_port1_en_o;
  wire          hls_bridge_idg_port_map_1_idg4_port1_en_o;
  wire          hls_bridge_idg_port_map_1_idg5_port1_en_o;
  wire          hls_bridge_idg_port_map_1_idg6_port1_en_o;
  wire          hls_bridge_idg_port_map_1_idg7_port1_en_o;

  // hls_bridge_tc_vc_port_map_1 Register
  wire          hls_bridge_tc_vc_port_map_1_tc0_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_tc1_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_tc2_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_tc3_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_tc4_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_tc5_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_tc6_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_tc7_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_vc0_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_vc1_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_vc2_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_vc3_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_vc4_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_vc5_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_vc6_axi_port1_en_o;
  wire          hls_bridge_tc_vc_port_map_1_vc7_axi_port1_en_o;

  // hls_bridge_tf_port_map_value Register
  wire [24 : 0] hls_bridge_tf_port_map_value_hls_bridge_tf_port_map_value_o;

  // hls_bridge_tf_port_map_mask Register
  wire [24 : 0] hls_bridge_tf_port_map_mask_hls_bridge_tf_port_map_mask_o;

  // hls_bridge_msi_gic_cfg Register
  wire          hls_bridge_msi_gic_cfg_hls_bridge_msi_gic_use_seg_o;

  // hls_bridge_dbg_order Register
  wire          hls_bridge_dbg_order_dbg_dis_o_chk_dti_o;
  wire          hls_bridge_dbg_order_dbg_dis_o_chk_msi_o;
  wire          hls_bridge_dbg_order_dbg_dis_per_port_o_chk_o;

  // hls_bridge_axi_ib_p_pck_count Register
  wire          hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i_capture;
  wire [31 : 0] hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i;
  wire [31 : 0] hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_axi_ib_np_pck_count Register
  wire          hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i_capture;
  wire [31 : 0] hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i;
  wire [31 : 0] hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_axi_ib_c_pck_count Register
  wire          hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i_capture;
  wire [31 : 0] hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i;
  wire [31 : 0] hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_axi_ob_p_pck_count Register
  wire          hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i_capture;
  wire [31 : 0] hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i;
  wire [31 : 0] hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_axi_ob_np_pck_count Register
  wire          hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i_capture;
  wire [31 : 0] hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i;
  wire [31 : 0] hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_axi_ob_c_pck_count Register
  wire          hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i_capture;
  wire [31 : 0] hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i;
  wire [31 : 0] hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_msi_ib_p_pck_count Register
  wire          hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i_capture;
  wire [15 : 0] hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i;
  wire [15 : 0] hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_dti_ib_p_pck_count Register
  wire          hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i_capture;
  wire [15 : 0] hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i;
  wire [15 : 0] hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_dti_ib_np_pck_count Register
  wire          hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i_capture;
  wire [15 : 0] hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i;
  wire [15 : 0] hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_dti_ob_c_pck_count Register
  wire          hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i_capture;
  wire [15 : 0] hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i;
  wire [15 : 0] hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_o;

  // hls_bridge_dti_ob_p_pck_count Register
  wire          hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i_capture;
  wire [15 : 0] hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i;
  wire [15 : 0] hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_o;

  //---------------------------------------------------------------------
  // TDISP hls_bridge request if
  //---------------------------------------------------------------------
  wire                                         hls_bridge_tdisp_read_valid;
  wire [TDISP_ADDR_WIDTH-1:0]                  hls_bridge_tdisp_read_register_address;
  wire [TDISP_FIELD_WIDTH-1:0]                 hls_bridge_tdisp_read_field_address;
  wire [TDISP_REXVALUE_WIDTH-1:0]              hls_bridge_tdisp_read_value;

  //---------------------------------------------------------------------
  // TDISP hls_bridge request ASF if
  //---------------------------------------------------------------------
  wire                                         hls_bridge_tdisp_read_validchk;
  wire  [TDISP_ADDRCHK_WIDTH - 1 : 0]          hls_bridge_tdisp_read_addrchk;
  wire  [TDISP_FIELDCHK_WIDTH - 1 : 0]         hls_bridge_tdisp_read_fieldchk;
  wire  [TDISP_REXVALUECHK_WIDTH - 1 : 0]      hls_bridge_tdisp_read_valuechk;

  //---------------------------------------------------------------------
  //TDISP hls_bridge Notify if
  //---------------------------------------------------------------------
  wire                                        hls_bridge_tdisp_notify_valid;
  wire [TDISP_ADDR_WIDTH-1:0]                 hls_bridge_tdisp_notify_register_address;
  wire [TDISP_FIELD_WIDTH-1:0]                hls_bridge_tdisp_notify_field_address;
  wire [TDISP_NOTIFYVALUE_WIDTH-1:0]          hls_bridge_tdisp_notify_value;
  wire [TDISP_ORIGIN_WIDTH-1:0]               hls_bridge_tdisp_notify_origin;
  wire [TDISP_INDEX_WIDTH-1:0]                hls_bridge_tdisp_notify_index;

  //---------------------------------------------------------------------
  // TDISP hls_bridge notofy ASF if
  //---------------------------------------------------------------------
  wire                                       hls_bridge_tdisp_notify_validchk;
  wire  [TDISP_ADDRCHK_WIDTH - 1 : 0]        hls_bridge_tdisp_notify_addrchk;
  wire  [TDISP_FIELDCHK_WIDTH - 1 : 0]       hls_bridge_tdisp_notify_fieldchk;
  wire  [TDISP_NOTIFYVALUECHK_WIDTH - 1 : 0] hls_bridge_tdisp_notify_valuechk;
  wire  [TDISP_ORIGINCHK_WIDTH - 1 : 0]      hls_bridge_tdisp_notify_originchk;
  wire  [TDISP_INDEXCHK_WIDTH - 1 : 0]       hls_bridge_tdisp_notify_indexchk;
  //---------------------------------------------------------------------
  // TDISP DTI request if
  //---------------------------------------------------------------------
  wire                                        dti_tdisp_read_valid;
  wire [TDISP_ADDR_WIDTH-1:0]                 dti_tdisp_read_register_address;
  wire [TDISP_FIELD_WIDTH-1:0]                dti_tdisp_read_field_address;
  wire [TDISP_REXVALUE_WIDTH-1:0]             dti_tdisp_read_value;

  //--------------------------------------------------------------------
  // TDISP DTI request ASF if
  //--------------------------------------------------------------------
  wire                                        dti_tdisp_read_validchk;
  wire  [TDISP_ADDRCHK_WIDTH - 1 : 0]         dti_tdisp_read_addrchk;
  wire  [TDISP_FIELDCHK_WIDTH - 1 : 0]        dti_tdisp_read_fieldchk;
  wire  [TDISP_REXVALUECHK_WIDTH - 1 : 0]     dti_tdisp_read_valuechk;

  //--------------------------------------------------------------------
  //TDISP DTI Notify if
  //--------------------------------------------------------------------
  wire                                        dti_tdisp_notify_valid;
  wire [TDISP_ADDR_WIDTH-1:0]                 dti_tdisp_notify_register_address;
  wire [TDISP_FIELD_WIDTH-1:0]                dti_tdisp_notify_field_address;
  wire [TDISP_NOTIFYVALUE_WIDTH-1:0]          dti_tdisp_notify_value;
  wire [TDISP_ORIGIN_WIDTH-1:0]               dti_tdisp_notify_origin;
  wire [TDISP_INDEX_WIDTH-1:0]                dti_tdisp_notify_index;

  //--------------------------------------------------------------------
  // TDISP DTI notofy ASF if
  //--------------------------------------------------------------------
  wire                                        dti_tdisp_notify_validchk;
  wire  [TDISP_ADDRCHK_WIDTH - 1 : 0]         dti_tdisp_notify_addrchk;
  wire  [TDISP_FIELDCHK_WIDTH - 1 : 0]        dti_tdisp_notify_fieldchk;
  wire  [TDISP_NOTIFYVALUECHK_WIDTH - 1 : 0]  dti_tdisp_notify_valuechk;
  wire  [TDISP_ORIGINCHK_WIDTH - 1 : 0]       dti_tdisp_notify_originchk;
  wire  [TDISP_INDEXCHK_WIDTH - 1 : 0]        dti_tdisp_notify_indexchk;

  //------------------------------------------------------------------------------
  // ASF
  //------------------------------------------------------------------------------
  localparam ASF_SUPPORT_GE_2                = ASF_SUPPORT >=2;
  localparam ASF_SUPPORT_GE_3                = ASF_SUPPORT >=3;
  localparam ASF_NODE_ID_BASE                = 4096; //ID:16  (16*256)
  //localparam DC_ASF_NODE_ID_BASE           = ASF_EI_BASE_ADDRESS;
  //localparam CTAG_ASF_NODE_ID_BASE         = ;

  localparam ASF_DIAG_INFO_DATA_WIDTH = 32;
  localparam ASF_DIAG_DATA_CHK_WIDTH  = ((ASF_DIAG_INFO_DATA_WIDTH+7)/8);
  localparam ASF_DIAG_INFO_USER_WIDTH =  48;
  localparam ASF_DIAG_USER_CHK_WIDTH  = ((ASF_DIAG_INFO_USER_WIDTH+7)/8);
  localparam ONE_BIT_WIDTH            = 1;

  localparam ASF_NODE_ID_OFFSET_IB_P  = 32'd128  + ASF_NODE_ID_BASE;
  localparam ASF_NODE_ID_OFFSET_IB_NP = 32'd256  + ASF_NODE_ID_BASE;
  localparam ASF_NODE_ID_OFFSET_IB_C  = 32'd384  + ASF_NODE_ID_BASE;
  localparam ASF_NODE_ID_OFFSET_OB_P  = 32'd512  + ASF_NODE_ID_BASE;
  localparam ASF_NODE_ID_OFFSET_OB_NP = 32'd640  + ASF_NODE_ID_BASE;
  localparam ASF_NODE_ID_OFFSET_OB_C  = 32'd768  + ASF_NODE_ID_BASE;

  localparam ASF_ERROR_INJ_DATA_WIDTH       = 56;
  localparam ASF_ERROR_INJ_USER_WIDTH       = 8;
  localparam ASF_EVENT_TYPE_WIDTH           = 4;
  localparam ASF_EVENT_COUNT_WIDTH          = 8;
  localparam ASF_NODE_ID_WIDTH              = 16;
  localparam ASF_EVENT_DIAG_FIELD_WIDTH     = 28;
  localparam ASF_EVENT_VALID_WIDTH          = 1;

  localparam DC_ASF_EVENT_VALID_WIDTH        = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)   ;
  localparam DC_ASF_EVENT_TYPE_WIDTH         = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)*4 ;
  localparam DC_ASF_EVENT_COUNT_WIDTH        = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)*8 ;
  localparam DC_ASF_NODE_ID_WIDTH            = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)*16;
  localparam DC_ASF_EVENT_DIAG_FIELD_WIDTH   = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)*28;

  localparam QOS_ASF_EVENT_VALID_WIDTH        = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)   ;
  localparam QOS_ASF_EVENT_TYPE_WIDTH         = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)*4 ;
  localparam QOS_ASF_EVENT_COUNT_WIDTH        = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)*8 ;
  localparam QOS_ASF_NODE_ID_WIDTH            = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)*16;
  localparam QOS_ASF_EVENT_DIAG_FIELD_WIDTH   = (NUM_HLS_PORTS +KMAX_DTI_SUPPORT +KMAX_MSI_IF_SUPPORT)*28;

  localparam CTAG_ASF_EVENT_VALID_WIDTH        = (KMAX_MSI_IF_SUPPORT +NUM_HLS_PORTS)    ;
  localparam CTAG_ASF_EVENT_TYPE_WIDTH         = (KMAX_MSI_IF_SUPPORT +NUM_HLS_PORTS)*4  ;
  localparam CTAG_ASF_EVENT_COUNT_WIDTH        = (KMAX_MSI_IF_SUPPORT +NUM_HLS_PORTS)*8  ;
  localparam CTAG_ASF_NODE_ID_WIDTH            = (KMAX_MSI_IF_SUPPORT +NUM_HLS_PORTS)*16 ;
  localparam CTAG_ASF_EVENT_DIAG_FIELD_WIDTH   = (KMAX_MSI_IF_SUPPORT +NUM_HLS_PORTS)*28 ;

  localparam MAX_IB_P_NUM_OF_ASF_IF            = 2;                  //msi + stored_ff
  localparam MAX_OB_P_NUM_OF_ASF_IF            = 5*NUM_HLS_PORTS+1;  //(gearbox_masker_cntl,gearbox_masker_data,gearbox_packer_cntl,gearbox_packer_data,labeled_axi)+labeled_dti
  localparam MAX_IB_P_NUM_OF_ASF_ALIGNER_IF    = 2*NUM_HLS_PORTS+1;  //(gearbox_axi+axi_aligner)*num_ports + dti_aligner + 
  localparam MAX_OB_P_NUM_OF_ASF_ALIGNER_IF    = NUM_HLS_PORTS+1;    //(gearbox_aligner)*num_ports + main_aligner

  localparam MAX_IB_NP_NUM_OF_ASF_IF            = 1;                  // stored_ff
  localparam MAX_OB_NP_NUM_OF_ASF_IF            = 5*NUM_HLS_PORTS;    //(gearbox_masker_cntl,gearbox_masker_data,gearbox_packer_cntl,gearbox_packer_data,labeled_axi)*num_ports
  localparam MAX_IB_NP_NUM_OF_ASF_ALIGNER_IF    = 2*NUM_HLS_PORTS+1;  //(gearbox_axi+axi_aligner)*num_ports + dti_aligner
  localparam MAX_OB_NP_NUM_OF_ASF_ALIGNER_IF    = NUM_HLS_PORTS+1;    //(gearbox_aligner)*num_ports + main_aligner
  
  localparam MAX_IB_C_NUM_OF_ASF_IF            = 1;                  // stored_ff
  localparam MAX_OB_C_NUM_OF_ASF_IF            = 5*NUM_HLS_PORTS+1;  //(gearbox_masker_cntl,gearbox_masker_data,gearbox_packer_cntl,gearbox_packer_data,labeled_axi)+labeled_dti
  localparam MAX_IB_C_NUM_OF_ASF_ALIGNER_IF    = 2*NUM_HLS_PORTS;    //(gearbox_axi+axi_aligner)*num_ports
  localparam MAX_OB_C_NUM_OF_ASF_ALIGNER_IF    = NUM_HLS_PORTS+1;    //(gearbox_aligner)*num_ports + main_aligner
  
  
  
  localparam ASF_ERR_INJ_QACTIVE_EXTENSION_CYCLES = 4'd15;

  wire                                            k_ecc_support;
  wire                                            k_asf_e2e_parity;
  wire                                            k_asf_addr_parity;
  wire                                            k_asf_csr_parity;
  wire                                            k_asf_time_support;
  wire                                            k_asf_support;

  wire                                            asf_errinj_chk_err;
  wire                                            sub_block_error_inj__cmd_tvalid;
  wire  [55:0]                                    sub_block_error_inj__tdata;
  wire  [7:0]                                     sub_block_error_inj__tuser;
  wire                                            sub_block_error_inj__cdc_cmd_tvalid_o;
  wire  [55:0]                                    sub_block_error_inj__cdc_tdata_o;
  wire  [7:0]                                     sub_block_error_inj__cdc_tuser_o;
  wire                                            sub_block_error_inj__cdc_cmd_tvalid;
  wire  [55:0]                                    sub_block_error_inj__cdc_tdata;
  wire  [7:0]                                     sub_block_error_inj__cdc_tuser;

  wire                                            asf_event__valid_o;
  wire [3:0]                                      asf_event__type_o;
  wire [7:0]                                      asf_event__count_o;
  wire [15:0]                                     asf_event__node_id_o;
  wire [27:0]                                     asf_event__diag_field_o;

  wire                                            asf_csr_injection_valid;
  wire [26:0]                                     asf_csr_injection_addr;
  wire [5:0]                                      asf_csr_injection_index;

  wire                                            asf_csr_injection_validchk;
  wire [(27+7)/8-1:0]                             asf_csr_injection_addrchk;
  wire [(6+7)/8-1:0]                              asf_csr_injection_indexchk;

  wire                                            asf_csr_notify_ready;
  wire                                            asf_csr_notify_valid;
  wire [26:0]                                     asf_csr_notify_addr;

  wire                                            asf_csr_notify_readychk;
  wire                                            asf_csr_notify_validchk;
  wire [(27+7)/8-1:0]                             asf_csr_notify_addrchk;

  wire                                            asf_event__valid_csr;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                 asf_event__type_csr;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                asf_event__count_csr;
  wire [ASF_NODE_ID_WIDTH-1:0]                    asf_event__node_id_csr;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]           asf_event__diag_field_csr;

  wire                                            asf_event__valid_msi_tvalid;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                 asf_event__type_msi_tvalid;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                asf_event__count_msi_tvalid;
  wire [ASF_NODE_ID_WIDTH-1:0]                    asf_event__node_id_msi_tvalid;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]           asf_event__diag_field_msi_tvalid;

  wire                                            asf_event__valid_msi_tdata;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                 asf_event__type_msi_tdata;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                asf_event__count_msi_tdata;
  wire [ASF_NODE_ID_WIDTH-1:0]                    asf_event__node_id_msi_tdata;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]           asf_event__diag_field_msi_tdata;

  wire [DC_ASF_EVENT_VALID_WIDTH-1:0]             asf_event__valid_dc_m_tvalid;
  wire [DC_ASF_EVENT_TYPE_WIDTH-1:0]              asf_event__type_dc_m_tvalid;
  wire [DC_ASF_EVENT_COUNT_WIDTH-1:0]             asf_event__count_dc_m_tvalid;
  wire [DC_ASF_NODE_ID_WIDTH-1:0]                 asf_event__node_id_dc_m_tvalid;
  wire [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]        asf_event__diag_field_dc_m_tvalid;

  wire [DC_ASF_EVENT_VALID_WIDTH-1:0]             asf_event__valid_dc_m_tdata;
  wire [DC_ASF_EVENT_TYPE_WIDTH-1:0]              asf_event__type_dc_m_tdata;
  wire [DC_ASF_EVENT_COUNT_WIDTH-1:0]             asf_event__count_dc_m_tdata;
  wire [DC_ASF_NODE_ID_WIDTH-1:0]                 asf_event__node_id_dc_m_tdata;
  wire [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]        asf_event__diag_field_dc_m_tdata;

  wire [CTAG_ASF_EVENT_VALID_WIDTH-1:0]           asf_event__valid_lti_c_tx_tvalid;
  wire [CTAG_ASF_EVENT_TYPE_WIDTH-1:0]            asf_event__type_lti_c_tx_tvalid;
  wire [CTAG_ASF_EVENT_COUNT_WIDTH-1:0]           asf_event__count_lti_c_tx_tvalid;
  wire [CTAG_ASF_NODE_ID_WIDTH-1:0]               asf_event__node_id_lti_c_tx_tvalid;
  wire [CTAG_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]      asf_event__diag_field_lti_c_tx_tvalid;

  wire [CTAG_ASF_EVENT_VALID_WIDTH-1:0]           asf_event__valid_lti_c_tx_tdata;
  wire [CTAG_ASF_EVENT_TYPE_WIDTH-1:0]            asf_event__type_lti_c_tx_tdata;
  wire [CTAG_ASF_EVENT_COUNT_WIDTH-1:0]           asf_event__count_lti_c_tx_tdata;
  wire [CTAG_ASF_NODE_ID_WIDTH-1:0]               asf_event__node_id_lti_c_tx_tdata;
  wire [CTAG_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]      asf_event__diag_field_lti_c_tx_tdata;


  wire [QOS_ASF_EVENT_VALID_WIDTH-1:0]           asf_event__valid_qos_tvalid;
  wire [QOS_ASF_EVENT_TYPE_WIDTH-1:0]            asf_event__type_qos_tvalid;
  wire [QOS_ASF_EVENT_COUNT_WIDTH-1:0]           asf_event__count_qos_tvalid;
  wire [QOS_ASF_NODE_ID_WIDTH-1:0]               asf_event__node_id_qos_tvalid;
  wire [QOS_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]      asf_event__diag_field_qos_tvalid;

  wire [QOS_ASF_EVENT_VALID_WIDTH-1:0]           asf_event__valid_qos_tdata;
  wire [QOS_ASF_EVENT_TYPE_WIDTH-1:0]            asf_event__type_qos_tdata;
  wire [QOS_ASF_EVENT_COUNT_WIDTH-1:0]           asf_event__count_qos_tdata;
  wire [QOS_ASF_NODE_ID_WIDTH-1:0]               asf_event__node_id_qos_tdata;
  wire [QOS_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]      asf_event__diag_field_qos_tdata;


  //_____ASF IB PATH_____
  //IB_P
  wire [ASF_EVENT_VALID_WIDTH-1:0]                          asf_event__stored_ff_cntl_ib_p_valid;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                           asf_event__stored_ff_cntl_ib_p_type;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                          asf_event__stored_ff_cntl_ib_p_count;
  wire [ASF_NODE_ID_WIDTH-1:0]                              asf_event__stored_ff_cntl_ib_p_node_id;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                     asf_event__stored_ff_cntl_ib_p_diag_field;
  
  wire [ASF_EVENT_VALID_WIDTH-1:0]                          asf_event__msi_ib_p_valid;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                           asf_event__msi_ib_p_type;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                          asf_event__msi_ib_p_count;
  wire [ASF_NODE_ID_WIDTH-1:0]                              asf_event__msi_ib_p_node_id;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                     asf_event__msi_ib_p_diag_field;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]         asf_event__aligner_axi_ib_p_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]          asf_event__aligner_axi_ib_p_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                    asf_event__aligner_axi_ib_p_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                    asf_event__aligner_axi_ib_p_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]         asf_event__aligner_axi_ib_p_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]          asf_event__aligner_axi_ib_p_tuserchk_o;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]         asf_event__gearbox_axi_ib_p_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]          asf_event__gearbox_axi_ib_p_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                    asf_event__gearbox_axi_ib_p_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                    asf_event__gearbox_axi_ib_p_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]         asf_event__gearbox_axi_ib_p_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]          asf_event__gearbox_axi_ib_p_tuserchk_o;

  wire [ASF_DIAG_INFO_DATA_WIDTH-1:0]                       asf_event__aligner_dti_ib_p_tdata_o;
  wire [ASF_DIAG_DATA_CHK_WIDTH-1:0]                        asf_event__aligner_dti_ib_p_tdatachk_o;
  wire [ONE_BIT_WIDTH-1:0]                                  asf_event__aligner_dti_ib_p_tvalid_o;
  wire [ONE_BIT_WIDTH-1:0]                                  asf_event__aligner_dti_ib_p_tvalidchk_o;
  wire [ASF_DIAG_INFO_USER_WIDTH-1:0]                       asf_event__aligner_dti_ib_p_tuser_o;
  wire [ASF_DIAG_USER_CHK_WIDTH-1:0]                        asf_event__aligner_dti_ib_p_tuserchk_o;

  //IB_NP
  wire [ASF_EVENT_VALID_WIDTH-1:0]                          asf_event__stored_ff_cntl_ib_np_valid;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                           asf_event__stored_ff_cntl_ib_np_type;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                          asf_event__stored_ff_cntl_ib_np_count;
  wire [ASF_NODE_ID_WIDTH-1:0]                              asf_event__stored_ff_cntl_ib_np_node_id;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                     asf_event__stored_ff_cntl_ib_np_diag_field;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]         asf_event__aligner_axi_ib_np_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]          asf_event__aligner_axi_ib_np_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                    asf_event__aligner_axi_ib_np_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                    asf_event__aligner_axi_ib_np_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]         asf_event__aligner_axi_ib_np_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]          asf_event__aligner_axi_ib_np_tuserchk_o;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]          asf_event__gearbox_axi_ib_np_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]           asf_event__gearbox_axi_ib_np_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                     asf_event__gearbox_axi_ib_np_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                     asf_event__gearbox_axi_ib_np_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]          asf_event__gearbox_axi_ib_np_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]           asf_event__gearbox_axi_ib_np_tuserchk_o;

  wire [ASF_DIAG_INFO_DATA_WIDTH-1:0]                        asf_event__aligner_dti_ib_np_tdata_o;
  wire [ASF_DIAG_DATA_CHK_WIDTH-1:0]                         asf_event__aligner_dti_ib_np_tdatachk_o;
  wire [ONE_BIT_WIDTH-1:0]                                   asf_event__aligner_dti_ib_np_tvalid_o;
  wire [ONE_BIT_WIDTH-1:0]                                   asf_event__aligner_dti_ib_np_tvalidchk_o;
  wire [ASF_DIAG_INFO_USER_WIDTH-1:0]                        asf_event__aligner_dti_ib_np_tuser_o;
  wire [ASF_DIAG_USER_CHK_WIDTH-1:0]                         asf_event__aligner_dti_ib_np_tuserchk_o;

  //IB_C
  wire [ASF_EVENT_VALID_WIDTH-1:0]                           asf_event__stored_ff_cntl_ib_c_valid;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                            asf_event__stored_ff_cntl_ib_c_type;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                           asf_event__stored_ff_cntl_ib_c_count;
  wire [ASF_NODE_ID_WIDTH-1:0]                               asf_event__stored_ff_cntl_ib_c_node_id;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                      asf_event__stored_ff_cntl_ib_c_diag_field;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]          asf_event__aligner_axi_ib_c_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]           asf_event__aligner_axi_ib_c_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                     asf_event__aligner_axi_ib_c_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                     asf_event__aligner_axi_ib_c_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]          asf_event__aligner_axi_ib_c_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]           asf_event__aligner_axi_ib_c_tuserchk_o;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]          asf_event__gearbox_axi_ib_c_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]           asf_event__gearbox_axi_ib_c_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                     asf_event__gearbox_axi_ib_c_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                     asf_event__gearbox_axi_ib_c_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]          asf_event__gearbox_axi_ib_c_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]           asf_event__gearbox_axi_ib_c_tuserchk_o;

  //ASF OB PATH 
  //OB_P
  wire [NUM_HLS_PORTS*ASF_EVENT_VALID_WIDTH-1:0]                        asf_event__hls_cntl_labeled_axi_ob_p_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_cntl_labeled_axi_ob_p_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_cntl_labeled_axi_ob_p_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_cntl_labeled_axi_ob_p_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_cntl_labeled_axi_ob_p_diag_field;

  wire [ASF_EVENT_VALID_WIDTH-1:0]                                      asf_event__hls_cntl_labeled_dti_ob_p_valid;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                                       asf_event__hls_cntl_labeled_dti_ob_p_type;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                                      asf_event__hls_cntl_labeled_dti_ob_p_count;
  wire [ASF_NODE_ID_WIDTH-1:0]                                          asf_event__hls_cntl_labeled_dti_ob_p_node_id;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                                 asf_event__hls_cntl_labeled_dti_ob_p_diag_field;

  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_packer_cntl_ob_p_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_packer_cntl_ob_p_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_packer_cntl_ob_p_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_packer_cntl_ob_p_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_packer_cntl_ob_p_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_packer_data_ob_p_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_packer_data_ob_p_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_packer_data_ob_p_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_packer_data_ob_p_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_packer_data_ob_p_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_masker_cntl_ob_p_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_masker_cntl_ob_p_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_masker_cntl_ob_p_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_masker_cntl_ob_p_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_masker_cntl_ob_p_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_masker_data_ob_p_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_masker_data_ob_p_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_masker_data_ob_p_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_masker_data_ob_p_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_masker_data_ob_p_diag_field;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]                     asf_event__ob_gearbox_aligner_ob_p_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]                      asf_event__ob_gearbox_aligner_ob_p_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                                asf_event__ob_gearbox_aligner_ob_p_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                                asf_event__ob_gearbox_aligner_ob_p_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]                     asf_event__ob_gearbox_aligner_ob_p_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]                      asf_event__ob_gearbox_aligner_ob_p_tuserchk_o;

  wire [ASF_DIAG_INFO_DATA_WIDTH-1:0]                                   asf_event__ob_main_aligner_ob_p_tdata_o;
  wire [ASF_DIAG_DATA_CHK_WIDTH-1:0]                                    asf_event__ob_main_aligner_ob_p_tdatachk_o;
  wire [ONE_BIT_WIDTH-1:0]                                              asf_event__ob_main_aligner_ob_p_tvalid_o;
  wire [ONE_BIT_WIDTH-1:0]                                              asf_event__ob_main_aligner_ob_p_tvalidchk_o;
  wire [ASF_DIAG_INFO_USER_WIDTH-1:0]                                   asf_event__ob_main_aligner_ob_p_tuser_o;
  wire [ASF_DIAG_USER_CHK_WIDTH-1:0]                                    asf_event__ob_main_aligner_ob_p_tuserchk_o;

  //OB_NP
  wire [NUM_HLS_PORTS*ASF_EVENT_VALID_WIDTH-1:0]                        asf_event__hls_cntl_labeled_axi_ob_np_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_cntl_labeled_axi_ob_np_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_cntl_labeled_axi_ob_np_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_cntl_labeled_axi_ob_np_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_cntl_labeled_axi_ob_np_diag_field;

  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_packer_cntl_ob_np_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_packer_cntl_ob_np_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_packer_cntl_ob_np_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_packer_cntl_ob_np_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_packer_cntl_ob_np_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_packer_data_ob_np_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_packer_data_ob_np_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_packer_data_ob_np_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_packer_data_ob_np_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_packer_data_ob_np_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_masker_cntl_ob_np_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_masker_cntl_ob_np_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_masker_cntl_ob_np_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_masker_cntl_ob_np_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_masker_cntl_ob_np_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_masker_data_ob_np_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_masker_data_ob_np_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_masker_data_ob_np_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_masker_data_ob_np_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_masker_data_ob_np_diag_field;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]                     asf_event__ob_gearbox_aligner_ob_np_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]                      asf_event__ob_gearbox_aligner_ob_np_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                                asf_event__ob_gearbox_aligner_ob_np_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                                asf_event__ob_gearbox_aligner_ob_np_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]                     asf_event__ob_gearbox_aligner_ob_np_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]                      asf_event__ob_gearbox_aligner_ob_np_tuserchk_o;

  wire [ASF_DIAG_INFO_DATA_WIDTH-1:0]                                   asf_event__ob_main_aligner_ob_np_tdata_o;
  wire [ASF_DIAG_DATA_CHK_WIDTH-1:0]                                    asf_event__ob_main_aligner_ob_np_tdatachk_o;
  wire [ONE_BIT_WIDTH-1:0]                                              asf_event__ob_main_aligner_ob_np_tvalid_o;
  wire [ONE_BIT_WIDTH-1:0]                                              asf_event__ob_main_aligner_ob_np_tvalidchk_o;
  wire [ASF_DIAG_INFO_USER_WIDTH-1:0]                                   asf_event__ob_main_aligner_ob_np_tuser_o;
  wire [ASF_DIAG_USER_CHK_WIDTH-1:0]                                    asf_event__ob_main_aligner_ob_np_tuserchk_o;


  //OB_C
  wire [NUM_HLS_PORTS*ASF_EVENT_VALID_WIDTH-1:0]                        asf_event__hls_cntl_labeled_axi_ob_c_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_cntl_labeled_axi_ob_c_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_cntl_labeled_axi_ob_c_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_cntl_labeled_axi_ob_c_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_cntl_labeled_axi_ob_c_diag_field;

  wire [ASF_EVENT_VALID_WIDTH-1:0]                                      asf_event__hls_cntl_labeled_dti_ob_c_valid;
  wire [ASF_EVENT_TYPE_WIDTH-1:0]                                       asf_event__hls_cntl_labeled_dti_ob_c_type;
  wire [ASF_EVENT_COUNT_WIDTH-1:0]                                      asf_event__hls_cntl_labeled_dti_ob_c_count;
  wire [ASF_NODE_ID_WIDTH-1:0]                                          asf_event__hls_cntl_labeled_dti_ob_c_node_id;
  wire [ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                                 asf_event__hls_cntl_labeled_dti_ob_c_diag_field;

  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_packer_cntl_ob_c_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_packer_cntl_ob_c_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_packer_cntl_ob_c_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_packer_cntl_ob_c_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_packer_cntl_ob_c_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_packer_data_ob_c_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_packer_data_ob_c_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_packer_data_ob_c_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_packer_data_ob_c_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_packer_data_ob_c_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_masker_cntl_ob_c_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_masker_cntl_ob_c_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_masker_cntl_ob_c_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_masker_cntl_ob_c_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_masker_cntl_ob_c_diag_field;
  
  wire [NUM_HLS_PORTS-1:0]                                              asf_event__hls_ob_gearbox_masker_data_ob_c_valid;
  wire [NUM_HLS_PORTS*ASF_EVENT_TYPE_WIDTH-1:0]                         asf_event__hls_ob_gearbox_masker_data_ob_c_type;
  wire [NUM_HLS_PORTS*ASF_EVENT_COUNT_WIDTH-1:0]                        asf_event__hls_ob_gearbox_masker_data_ob_c_count;
  wire [NUM_HLS_PORTS*ASF_NODE_ID_WIDTH-1:0]                            asf_event__hls_ob_gearbox_masker_data_ob_c_node_id;
  wire [NUM_HLS_PORTS*ASF_EVENT_DIAG_FIELD_WIDTH-1:0]                   asf_event__hls_ob_gearbox_masker_data_ob_c_diag_field;

  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_DATA_WIDTH-1:0]                     asf_event__ob_gearbox_aligner_ob_c_tdata_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_DATA_CHK_WIDTH-1:0]                      asf_event__ob_gearbox_aligner_ob_c_tdatachk_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                                asf_event__ob_gearbox_aligner_ob_c_tvalid_o;
  wire [NUM_HLS_PORTS*ONE_BIT_WIDTH-1:0]                                asf_event__ob_gearbox_aligner_ob_c_tvalidchk_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_INFO_USER_WIDTH-1:0]                     asf_event__ob_gearbox_aligner_ob_c_tuser_o;
  wire [NUM_HLS_PORTS*ASF_DIAG_USER_CHK_WIDTH-1:0]                      asf_event__ob_gearbox_aligner_ob_c_tuserchk_o;

  wire [ASF_DIAG_INFO_DATA_WIDTH-1:0]                                   asf_event__ob_main_aligner_ob_c_tdata_o;
  wire [ASF_DIAG_DATA_CHK_WIDTH-1:0]                                    asf_event__ob_main_aligner_ob_c_tdatachk_o;
  wire [ONE_BIT_WIDTH-1:0]                                              asf_event__ob_main_aligner_ob_c_tvalid_o;
  wire [ONE_BIT_WIDTH-1:0]                                              asf_event__ob_main_aligner_ob_c_tvalidchk_o;
  wire [ASF_DIAG_INFO_USER_WIDTH-1:0]                                   asf_event__ob_main_aligner_ob_c_tuser_o;
  wire [ASF_DIAG_USER_CHK_WIDTH-1:0]                                    asf_event__ob_main_aligner_ob_c_tuserchk_o;


  wire [31:0]                                     asf_event__tdata_o;
  wire [3:0]                                      asf_event__tdatachk_o;
  wire                                            asf_event__tready_o;
  wire                                            asf_event__tvalid_o;
  wire                                            asf_event__tvalidchk_o;
  wire [47:0]                                     asf_event__tuser_o;
  wire [5:0]                                      asf_event__tuserchk_o;

  wire [31:0]                                     asf_event__axi_tdata_o;
  wire [3:0]                                      asf_event__axi_tdatachk_o;
  wire                                            asf_event__axi_tready_o;
  wire                                            asf_event__axi_tvalid_o;
  wire                                            asf_event__axi_tvalidchk_o;
  wire [47:0]                                     asf_event__axi_tuser_o;
  wire [5:0]                                      asf_event__axi_tuserchk_o;

  wire [31:0]                                     asf_diag__synced_tdata_o;
  wire [3:0]                                      asf_diag__synced_tdatachk_o;
  wire                                            asf_diag__synced_tready_o;
  wire                                            asf_diag__synced_tvalid_o;
  wire                                            asf_diag__synced_tvalidchk_o;
  wire [47:0]                                     asf_diag__synced_tuser_o;
  wire [5:0]                                      asf_diag__synced_tuserchk_o;

  wire [31:0]                                     asf_diag__info_dti_tdata_o;
  wire [3:0]                                      asf_diag__info_dti_tdatachk_o;
  wire                                            asf_diag__info_dti_tvalid_o;
  wire                                            asf_diag__info_dti_tvalidchk_o;
  wire [47:0]                                     asf_diag__info_dti_tuser_o;
  wire [5:0]                                      asf_diag__info_dti_tuserchk_o;
  wire                                            asf_err_inj_tvalid_ack ;
  wire                                            c_axi_msi_err_inj_cntr ;
  wire                                            axi_msi_err_inj_cntr_en ;
  reg                                             r_axi_msi_err_inj_cntr ;
  wire [3:0]                                      c_axi_msi_err_inj_cntr_hist ;
  wire                                            axi_msi_err_inj_cntr_hist_en ;
  reg [3:0]                                       r_axi_msi_err_inj_cntr_hist ;
  wire                                            axi_msi_qactive_int;
  wire                                            axi_msi_qactive_err_inj;

  wire                                            unused_ok;
  // End of internal wires

  //------------------------------------------------------------------------------
  // ASF Interface tie-off
  //------------------------------------------------------------------------------
   wire [7:0] k_asf_enable;                                                                                         // todo
   assign k_asf_enable = 8'h00;

//   assign k_asf_odd_parity    = 1'b1;
   assign k_ecc_support       = k_asf_enable[0];
   assign k_asf_e2e_parity    = k_asf_enable[1]; //(k_asf_enable[1] || k_asf_enable[2] || k_asf_enable[3]);
   assign k_asf_addr_parity   = k_asf_enable[2];
   assign k_asf_csr_parity    = k_asf_enable[4];
   assign k_asf_time_support  = k_asf_enable[5];
   assign k_asf_support       = k_asf_enable != 8'h00;                                                              // todo

  //------------------------------------------------------------------------------
  // Signals that are unused intentionally, but may be used in future
  //------------------------------------------------------------------------------

  assign unused_ok = |{k_asf_e2e_parity,
                       k_asf_support};
  //------------------------------------------------------------------------------
  // TDISP Interface
  //------------------------------------------------------------------------------
  assign tdisp_read_valid             = dti_tdisp_read_valid             | hls_bridge_tdisp_read_valid;
  assign tdisp_read_register_address  = dti_tdisp_read_register_address  | hls_bridge_tdisp_read_register_address;
  assign tdisp_read_field_address     = dti_tdisp_read_field_address     | hls_bridge_tdisp_read_field_address;
  assign tdisp_read_value             = dti_tdisp_read_value             | hls_bridge_tdisp_read_value;

  assign tdisp_read_validchk          = dti_tdisp_read_validchk          | hls_bridge_tdisp_read_validchk;
  assign tdisp_read_addrchk           = dti_tdisp_read_addrchk           | hls_bridge_tdisp_read_addrchk;
  assign tdisp_read_fieldchk          = dti_tdisp_read_fieldchk          | hls_bridge_tdisp_read_fieldchk;
  assign tdisp_read_valuechk          = dti_tdisp_read_valuechk          | hls_bridge_tdisp_read_valuechk;

  assign tdisp_notify_valid           = dti_tdisp_notify_valid           | hls_bridge_tdisp_notify_valid;
  assign tdisp_notify_register_address= dti_tdisp_notify_register_address| hls_bridge_tdisp_notify_register_address;
  assign tdisp_notify_field_address   = dti_tdisp_notify_field_address   | hls_bridge_tdisp_notify_field_address;
  assign tdisp_notify_value           = dti_tdisp_notify_value           | hls_bridge_tdisp_notify_value;
  assign tdisp_notify_origin          = dti_tdisp_notify_origin          | hls_bridge_tdisp_notify_origin;
  assign tdisp_notify_index           = dti_tdisp_notify_index           | hls_bridge_tdisp_notify_index;

  assign tdisp_notify_validchk        = dti_tdisp_notify_validchk         | hls_bridge_tdisp_notify_validchk;
  assign tdisp_notify_addrchk         = dti_tdisp_notify_addrchk          | hls_bridge_tdisp_notify_addrchk;
  assign tdisp_notify_fieldchk        = dti_tdisp_notify_fieldchk         | hls_bridge_tdisp_notify_fieldchk;
  assign tdisp_notify_valuechk        = dti_tdisp_notify_valuechk         | hls_bridge_tdisp_notify_valuechk;
  assign tdisp_notify_originchk       = dti_tdisp_notify_originchk        | hls_bridge_tdisp_notify_originchk;
  assign tdisp_notify_indexchk        = dti_tdisp_notify_indexchk         | hls_bridge_tdisp_notify_indexchk;




  /////////////////////////////////////////////////////////////////////////////
  //                                Instances                                //
  /////////////////////////////////////////////////////////////////////////////
  hls_bridge_ib # (
  .NUM_HLS_PORTS                    (NUM_HLS_PORTS),
  .NUM_TLP_STREAMS                  (NUM_TLP_STREAMS),
  .HLS_DW_ALIGNMENT                 (HLS_DW_ALIGNMENT),
  .KMAX_DTI_SUPPORT                 (KMAX_DTI_SUPPORT),
  .KMAX_MSI_IF_SUPPORT              (KMAX_MSI_IF_SUPPORT),
  .ORDERING_SUPPORT                 (1),
  .CRD_DW_COUNTER_WD                (CRD_DW_COUNTER_WD),
  .KMAX_DATAPATH_WD                 (KMAX_DATAPATH_WD),
  .HLS_METADATA_WD                  (HLS_RX_PNP_METADATA_WD),
  .KMAX_NUM_TLPS_PER_CLK            (KMAX_NUM_TLPS_PER_CLK),
  .HLS_PORT_DATA_WIDTH_ARR          (HLS_PORT_DATA_WIDTH_ARR),
  .HLS_PORT_TLPS_PER_CLK_ARR        (HLS_PORT_TLPS_PER_CLK_ARR),
  .HLS_AXI_STR_PTR_WD_ARR           (HLS_AXI_STR_PTR_WD_ARR),
  .HLS_AXI_END_PTR_WD_ARR           (HLS_AXI_END_PTR_WD_ARR),
  .HLS_AXI_PKT_CNTL_WD_ARR          (HLS_AXI_PKT_CNTL_WD_ARR),
  .HLS_AXI_CNTL_WD_ARR              (HLS_AXI_IB_PNP_CNTL_WD_ARR),
  .HLS_AXI_CNTL_CHK_WD_ARR          (HLS_AXI_IB_PNP_CNTL_CHK_WD_ARR),
  .HLS_AXI_CNTLS_WD                 (HLS_AXI_IB_PNP_CNTL_WD),
  .HLS_AXI_CNTLS_CHK_WD             (HLS_AXI_IB_PNP_CNTL_CHK_WD),
   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   .ASF_SUPPORT                        (ASF_SUPPORT),
   .ASF_NODE_ID_OFFSET                 (ASF_NODE_ID_OFFSET_IB_P),
   .ASF_ERR_INJ_SUPPORT                (ASF_ERR_INJ_SUPPORT),
   .ASF_ERROR_INJ_DATA_WIDTH           (ASF_ERROR_INJ_DATA_WIDTH),
   .ASF_ERROR_INJ_USER_WIDTH           (ASF_ERROR_INJ_USER_WIDTH),
   .ASF_EVENT_TYPE_WIDTH               (ASF_EVENT_TYPE_WIDTH),
   .ASF_EVENT_COUNT_WIDTH              (ASF_EVENT_COUNT_WIDTH),
   .ASF_NODE_ID_WIDTH                  (ASF_NODE_ID_WIDTH),
   .ASF_EVENT_DIAG_FIELD_WIDTH         (ASF_EVENT_DIAG_FIELD_WIDTH),

   .RX_METADATA_PKT_ROUTING_INFO_WD              (IB_P_NP_METADATA_PKT_ROUTING_INFO_WD),
   .RX_METADATA_PKT_ROUTING_INFO_OFFSET          (IB_P_NP_METADATA_PKT_ROUTING_INFO_OFFSET),
   .RX_METADATA_PORT_INFO_OFFSET                 (IB_P_NP_METADATA_PORT_INFO_OFFSET)

  )
  i_cdns_hls_bridge_ib_p
  (
  .core_clk                                      (core_clk),
  .core_rst_n                                    (core_rst_n),
  //kwires
   .k_hls_dw_alignment                           (k_hls_dw_alignment),
   .k_sync_reset                                 (k_sync_reset),
   .k_sync_cell_stages                           (k_sync_cell_stages),
  //RX from HAL
   .hls_rx_valid                                 (hls_ib_posted_hal_valid),
   .hls_rx_data                                  (hls_ib_posted_hal_data),
   .hls_rx_cntl                                  (hls_ib_posted_hal_cntl),
   .hls_rx_crdgnt                                (hls_ib_posted_hal_crdgnt),
   .hls_rx_crdrtn                                (hls_ib_posted_hal_crdrtn),
   .hls_rx_activereq                             (hls_ib_posted_hal_activereq),
   .hls_rx_activeack                             (hls_ib_posted_hal_activeack),
   .hls_rx_deacthint                             (hls_ib_posted_hal_deacthint),
   .hls_rx_data_chk                              (hls_ib_posted_hal_data_chk),
   .hls_rx_cntl_chk                              (hls_ib_posted_hal_cntl_chk),
  //TX to AXI-Bridge
   .hls_tx_axi_valid                             (hls_ib_posted_axi_valid),
   .hls_tx_axi_data                              (hls_ib_posted_axi_data),
   .hls_tx_axi_cntl                              (hls_ib_posted_axi_cntl),
   .hls_tx_axi_crdgnt                            (hls_ib_posted_axi_crdgnt),
   .hls_tx_axi_crdrtn                            (hls_ib_posted_axi_crdrtn),
   .hls_tx_axi_activereq                         (hls_ib_posted_axi_activereq),
   .hls_tx_axi_activeack                         (hls_ib_posted_axi_activeack),
   .hls_tx_axi_deacthint                         (hls_ib_posted_axi_deacthint),
   .hls_tx_axi_data_chk                          (hls_ib_posted_axi_data_chk),
   .hls_tx_axi_cntl_chk                          (hls_ib_posted_axi_cntl_chk),

   .tx_msi_ready                                 (ib_posted_msi_ready),
   .tx_msi_valid                                 (ib_posted_msi_valid),
   .tx_msi_valid_chk                             (ib_posted_msi_valid_chk),
   .tx_msi_payload                               (ib_posted_msi_payload),
   .tx_msi_payload_chk                           (ib_posted_msi_payload_chk),


   .hls_tx_dti_valid                             (hls_ib_posted_dti_valid),
   .hls_tx_dti_data                              (hls_ib_posted_dti_data),
   .hls_tx_dti_cntl                              (hls_ib_posted_dti_cntl),
   .hls_tx_dti_crdgnt                            (hls_ib_posted_dti_crdgnt),
   .hls_tx_dti_crdrtn                            (hls_ib_posted_dti_crdrtn),
   .hls_tx_dti_activereq                         (hls_ib_posted_dti_activereq),
   .hls_tx_dti_activeack                         (hls_ib_posted_dti_activeack),
   .hls_tx_dti_deacthint                         (hls_ib_posted_dti_deacthint),
   .hls_tx_dti_data_chk                          (hls_ib_posted_dti_data_chk),
   .hls_tx_dti_cntl_chk                          (hls_ib_posted_dti_cntl_chk),
   .hls_tx_dti_pri_supported                     (hls_ib_posted_dti_pri_supported),

  .misc_flit_mode                                (misc_flit_mode),
  .misc_pbr_negotiated                           (misc_pbr_negotiated),
  .misc_hls_bridge_route_en                      (misc_hls_bridge_route_en),

  .lm_segment_num                                (lm_segment_num),

  .dc_sb_rx_axi_queue_empty                       (sb_ib_p_axi_queue_empty),
  .dc_sb_rx_msi_queue_empty                       (sb_ib_p_msi_queue_empty),
  .dc_sb_rx_dti_queue_empty                       (sb_ib_p_dti_queue_empty),

  .dc_sb_rx_axi_stream_queue_empty                (sb_ib_p_axi_stream_empty),
  .dc_sb_rx_msi_stream_queue_empty                (sb_ib_p_msi_stream_empty),
  .dc_sb_rx_dti_stream_queue_empty                (sb_ib_p_dti_stream_empty),

  .dc_tlp_route_to_axi                            (sb_tlp_route_to_axi),
  .dc_tlp_route_to_msi                            (sb_tlp_route_to_msi),
  .dc_tlp_route_to_dti                            (sb_tlp_route_to_dti),

  .dc_tlp_idg_streams                             (sb_tlp_stream_packed),

  .o_crd_dw_counter_valid                         (crd_dw_counter_ib_p_valid),
  .o_crd_dw_counter                               (crd_dw_counter_ib_p),
  .o_crd_dw_counter_valid_chk                     (crd_dw_counter_ib_p_valid_chk),
  .o_crd_dw_counter_chk                           (crd_dw_counter_ib_p_chk),

  .link_down_handling_in_progress                 (link_down_handling_in_progress),

  //INPUT REGS
  // hls_bridge_msi_gic_cfg Register
  .hls_bridge_msi_gic_cfg_hls_bridge_msi_gic_use_seg             (hls_bridge_msi_gic_cfg_hls_bridge_msi_gic_use_seg_o              ),

  .hls_bridge_dbg_order_dis_o_chk_dti_i                          (hls_bridge_dbg_order_dbg_dis_o_chk_dti_o                         ),
  .hls_bridge_dbg_order_dis_o_chk_msi_i                          (hls_bridge_dbg_order_dbg_dis_o_chk_msi_o                         ),
  .hls_bridge_dbg_order_dis_per_port_o_chk_i                     (hls_bridge_dbg_order_dbg_dis_per_port_o_chk_o                    ),

  //---------------------------------------------------------------------------------
  // ASF err inj
  //---------------------------------------------------------------------------------
  .asf_error_inj__ib_cmd_tvalid_i       (sub_block_error_inj__cmd_tvalid),
  .asf_error_inj__ib_tdata_i            (sub_block_error_inj__tdata     ),
  .asf_error_inj__ib_tuser_i            (sub_block_error_inj__tuser     ),

  .asf_event__stored_ff_cntl_valid      (asf_event__stored_ff_cntl_ib_p_valid),
  .asf_event__stored_ff_cntl_type       (asf_event__stored_ff_cntl_ib_p_type),
  .asf_event__stored_ff_cntl_count      (asf_event__stored_ff_cntl_ib_p_count),
  .asf_event__stored_ff_cntl_node_id    (asf_event__stored_ff_cntl_ib_p_node_id),
  .asf_event__stored_ff_cntl_diag_field (asf_event__stored_ff_cntl_ib_p_diag_field),

  .asf_event__msi_valid                 (asf_event__msi_ib_p_valid),
  .asf_event__msi_type                  (asf_event__msi_ib_p_type),
  .asf_event__msi_count                 (asf_event__msi_ib_p_count),
  .asf_event__msi_node_id               (asf_event__msi_ib_p_node_id),
  .asf_event__msi_diag_field            (asf_event__msi_ib_p_diag_field),

  .asf_event__aligner_axi_tdata_o       (asf_event__aligner_axi_ib_p_tdata_o),
  .asf_event__aligner_axi_tdatachk_o    (asf_event__aligner_axi_ib_p_tdatachk_o),
  .asf_event__aligner_axi_tvalid_o      (asf_event__aligner_axi_ib_p_tvalid_o),
  .asf_event__aligner_axi_tvalidchk_o   (asf_event__aligner_axi_ib_p_tvalidchk_o),
  .asf_event__aligner_axi_tuser_o       (asf_event__aligner_axi_ib_p_tuser_o),
  .asf_event__aligner_axi_tuserchk_o    (asf_event__aligner_axi_ib_p_tuserchk_o),

  .asf_event__gearbox_axi_tdata_o       (asf_event__gearbox_axi_ib_p_tdata_o),
  .asf_event__gearbox_axi_tdatachk_o    (asf_event__gearbox_axi_ib_p_tdatachk_o),
  .asf_event__gearbox_axi_tvalid_o      (asf_event__gearbox_axi_ib_p_tvalid_o),
  .asf_event__gearbox_axi_tvalidchk_o   (asf_event__gearbox_axi_ib_p_tvalidchk_o),
  .asf_event__gearbox_axi_tuser_o       (asf_event__gearbox_axi_ib_p_tuser_o),
  .asf_event__gearbox_axi_tuserchk_o    (asf_event__gearbox_axi_ib_p_tuserchk_o),

  .asf_event__aligner_dti_tdata_o       (asf_event__aligner_dti_ib_p_tdata_o),
  .asf_event__aligner_dti_tdatachk_o    (asf_event__aligner_dti_ib_p_tdatachk_o),
  .asf_event__aligner_dti_tvalid_o      (asf_event__aligner_dti_ib_p_tvalid_o),
  .asf_event__aligner_dti_tvalidchk_o   (asf_event__aligner_dti_ib_p_tvalidchk_o),
  .asf_event__aligner_dti_tuser_o       (asf_event__aligner_dti_ib_p_tuser_o),
  .asf_event__aligner_dti_tuserchk_o    (asf_event__aligner_dti_ib_p_tuserchk_o)
  );

  hls_bridge_ib # (
  .NUM_HLS_PORTS                    (NUM_HLS_PORTS),
  .NUM_TLP_STREAMS                  (NUM_TLP_STREAMS),
  .HLS_DW_ALIGNMENT                 (HLS_DW_ALIGNMENT),
  .KMAX_DTI_SUPPORT                 (KMAX_DTI_SUPPORT),
  .KMAX_MSI_IF_SUPPORT              (0),
  .ORDERING_SUPPORT                 (0),
  .CRD_DW_COUNTER_WD                (CRD_DW_COUNTER_WD),
  .KMAX_DATAPATH_WD                 (KMAX_DATAPATH_WD),
  .HLS_METADATA_WD                  (HLS_RX_PNP_METADATA_WD),
  .KMAX_NUM_TLPS_PER_CLK            (KMAX_NUM_TLPS_PER_CLK),
  .HLS_PORT_DATA_WIDTH_ARR          (HLS_PORT_DATA_WIDTH_ARR),
  .HLS_PORT_TLPS_PER_CLK_ARR        (HLS_PORT_TLPS_PER_CLK_ARR),
  .HLS_AXI_STR_PTR_WD_ARR           (HLS_AXI_STR_PTR_WD_ARR),
  .HLS_AXI_END_PTR_WD_ARR           (HLS_AXI_END_PTR_WD_ARR),
  .HLS_AXI_PKT_CNTL_WD_ARR          (HLS_AXI_PKT_CNTL_WD_ARR),
  .HLS_AXI_CNTL_WD_ARR              (HLS_AXI_IB_PNP_CNTL_WD_ARR),
  .HLS_AXI_CNTL_CHK_WD_ARR          (HLS_AXI_IB_PNP_CNTL_CHK_WD_ARR),
  .HLS_AXI_CNTLS_WD                 (HLS_AXI_IB_PNP_CNTL_WD),
  .HLS_AXI_CNTLS_CHK_WD             (HLS_AXI_IB_PNP_CNTL_CHK_WD),
   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   .ASF_SUPPORT                        (ASF_SUPPORT),
   .ASF_NODE_ID_OFFSET                 (ASF_NODE_ID_OFFSET_IB_NP),
   .ASF_ERR_INJ_SUPPORT                (ASF_ERR_INJ_SUPPORT),
   .ASF_ERROR_INJ_DATA_WIDTH           (ASF_ERROR_INJ_DATA_WIDTH),
   .ASF_ERROR_INJ_USER_WIDTH           (ASF_ERROR_INJ_USER_WIDTH),
   .ASF_EVENT_TYPE_WIDTH               (ASF_EVENT_TYPE_WIDTH),
   .ASF_EVENT_COUNT_WIDTH              (ASF_EVENT_COUNT_WIDTH),
   .ASF_NODE_ID_WIDTH                  (ASF_NODE_ID_WIDTH),
   .ASF_EVENT_DIAG_FIELD_WIDTH         (ASF_EVENT_DIAG_FIELD_WIDTH),

   .RX_METADATA_PKT_ROUTING_INFO_WD              (IB_P_NP_METADATA_PKT_ROUTING_INFO_WD),
   .RX_METADATA_PKT_ROUTING_INFO_OFFSET          (IB_P_NP_METADATA_PKT_ROUTING_INFO_OFFSET),
   .RX_METADATA_PORT_INFO_OFFSET                 (IB_P_NP_METADATA_PORT_INFO_OFFSET)
  )
  i_cdns_hls_bridge_ib_np
  (
  .core_clk                                      (core_clk),
  .core_rst_n                                    (core_rst_n),
  //kwires
   .k_hls_dw_alignment                           (k_hls_dw_alignment),
   .k_sync_reset                                 (k_sync_reset),
   .k_sync_cell_stages                           (k_sync_cell_stages),
  //RX from HAL
   .hls_rx_valid                                 (hls_ib_nonposted_hal_valid),
   .hls_rx_data                                  (hls_ib_nonposted_hal_data),
   .hls_rx_cntl                                  (hls_ib_nonposted_hal_cntl),
   .hls_rx_crdgnt                                (hls_ib_nonposted_hal_crdgnt),
   .hls_rx_crdrtn                                (hls_ib_nonposted_hal_crdrtn),
   .hls_rx_activereq                             (hls_ib_nonposted_hal_activereq),
   .hls_rx_activeack                             (hls_ib_nonposted_hal_activeack),
   .hls_rx_deacthint                             (hls_ib_nonposted_hal_deacthint),
   .hls_rx_data_chk                              (hls_ib_nonposted_hal_data_chk),
   .hls_rx_cntl_chk                              (hls_ib_nonposted_hal_cntl_chk),
  //TX to AXI-Bridge
   .hls_tx_axi_valid                             (hls_ib_nonposted_axi_valid),
   .hls_tx_axi_data                              (hls_ib_nonposted_axi_data),
   .hls_tx_axi_cntl                              (hls_ib_nonposted_axi_cntl),
   .hls_tx_axi_crdgnt                            (hls_ib_nonposted_axi_crdgnt),
   .hls_tx_axi_crdrtn                            (hls_ib_nonposted_axi_crdrtn),
   .hls_tx_axi_activereq                         (hls_ib_nonposted_axi_activereq),
   .hls_tx_axi_activeack                         (hls_ib_nonposted_axi_activeack),
   .hls_tx_axi_deacthint                         (hls_ib_nonposted_axi_deacthint),
   .hls_tx_axi_data_chk                          (hls_ib_nonposted_axi_data_chk),
   .hls_tx_axi_cntl_chk                          (hls_ib_nonposted_axi_cntl_chk),

   .hls_tx_dti_valid                             (hls_ib_nonposted_dti_valid),
   .hls_tx_dti_data                              (hls_ib_nonposted_dti_data),
   .hls_tx_dti_cntl                              (hls_ib_nonposted_dti_cntl),
   .hls_tx_dti_crdgnt                            (hls_ib_nonposted_dti_crdgnt),
   .hls_tx_dti_crdrtn                            (hls_ib_nonposted_dti_crdrtn),
   .hls_tx_dti_activereq                         (hls_ib_nonposted_dti_activereq),
   .hls_tx_dti_activeack                         (hls_ib_nonposted_dti_activeack),
   .hls_tx_dti_deacthint                         (hls_ib_nonposted_dti_deacthint),
   .hls_tx_dti_data_chk                          (hls_ib_nonposted_dti_data_chk),
   .hls_tx_dti_cntl_chk                          (hls_ib_nonposted_dti_cntl_chk),
   .hls_tx_dti_pri_supported                     (1'b0),
   .tx_msi_ready                                 (1'b0),
   .tx_msi_valid                                 (), // intentionally not connected
   .tx_msi_valid_chk                             (),
   .tx_msi_payload                               (),
   .tx_msi_payload_chk                           (),

  .misc_flit_mode                               (2'b00),
  .misc_pbr_negotiated                          (1'b0),
  .misc_hls_bridge_route_en                     (32'h0),

  .lm_segment_num                               (9'h0),

  .dc_sb_rx_axi_queue_empty                     ({NUM_HLS_PORTS{1'b1}}),
  .dc_sb_rx_msi_queue_empty                     (1'b1),
  .dc_sb_rx_dti_queue_empty                     (1'b1),
  .dc_sb_rx_axi_stream_queue_empty              ({(NUM_HLS_PORTS*NUM_TLP_STREAMS){1'b1}}),
  .dc_sb_rx_msi_stream_queue_empty              ({NUM_TLP_STREAMS{1'b1}}),
  .dc_sb_rx_dti_stream_queue_empty              ({NUM_TLP_STREAMS{1'b1}}),
  .dc_tlp_route_to_axi                          (),
  .dc_tlp_route_to_msi                          (),
  .dc_tlp_route_to_dti                          (),
  .dc_tlp_idg_streams                           (),

  .hls_bridge_msi_gic_cfg_hls_bridge_msi_gic_use_seg  (1'b0),
  .hls_bridge_dbg_order_dis_o_chk_dti_i         (1'b0),
  .hls_bridge_dbg_order_dis_o_chk_msi_i         (1'b0),
  .hls_bridge_dbg_order_dis_per_port_o_chk_i    (1'b0),

  .o_crd_dw_counter_valid                         (crd_dw_counter_ib_np_valid),
  .o_crd_dw_counter                               (crd_dw_counter_ib_np),
  .o_crd_dw_counter_valid_chk                     (crd_dw_counter_ib_np_valid_chk),
  .o_crd_dw_counter_chk                           (crd_dw_counter_ib_np_chk),
  
  .link_down_handling_in_progress                (link_down_handling_in_progress),

  //---------------------------------------------------------------------------------
  // ASF err inj
  //---------------------------------------------------------------------------------
  .asf_error_inj__ib_cmd_tvalid_i       (sub_block_error_inj__cmd_tvalid),
  .asf_error_inj__ib_tdata_i            (sub_block_error_inj__tdata     ),
  .asf_error_inj__ib_tuser_i            (sub_block_error_inj__tuser     ),

  .asf_event__stored_ff_cntl_valid      (asf_event__stored_ff_cntl_ib_np_valid),
  .asf_event__stored_ff_cntl_type       (asf_event__stored_ff_cntl_ib_np_type),
  .asf_event__stored_ff_cntl_count      (asf_event__stored_ff_cntl_ib_np_count),
  .asf_event__stored_ff_cntl_node_id    (asf_event__stored_ff_cntl_ib_np_node_id),
  .asf_event__stored_ff_cntl_diag_field (asf_event__stored_ff_cntl_ib_np_diag_field),

  .asf_event__msi_valid                 (),
  .asf_event__msi_type                  (),
  .asf_event__msi_count                 (),
  .asf_event__msi_node_id               (),
  .asf_event__msi_diag_field            (),

  .asf_event__aligner_axi_tdata_o       (asf_event__aligner_axi_ib_np_tdata_o),
  .asf_event__aligner_axi_tdatachk_o    (asf_event__aligner_axi_ib_np_tdatachk_o),
  .asf_event__aligner_axi_tvalid_o      (asf_event__aligner_axi_ib_np_tvalid_o),
  .asf_event__aligner_axi_tvalidchk_o   (asf_event__aligner_axi_ib_np_tvalidchk_o),
  .asf_event__aligner_axi_tuser_o       (asf_event__aligner_axi_ib_np_tuser_o),
  .asf_event__aligner_axi_tuserchk_o    (asf_event__aligner_axi_ib_np_tuserchk_o),

  .asf_event__gearbox_axi_tdata_o       (asf_event__gearbox_axi_ib_np_tdata_o),
  .asf_event__gearbox_axi_tdatachk_o    (asf_event__gearbox_axi_ib_np_tdatachk_o),
  .asf_event__gearbox_axi_tvalid_o      (asf_event__gearbox_axi_ib_np_tvalid_o),
  .asf_event__gearbox_axi_tvalidchk_o   (asf_event__gearbox_axi_ib_np_tvalidchk_o),
  .asf_event__gearbox_axi_tuser_o       (asf_event__gearbox_axi_ib_np_tuser_o),
  .asf_event__gearbox_axi_tuserchk_o    (asf_event__gearbox_axi_ib_np_tuserchk_o),

  .asf_event__aligner_dti_tdata_o       (asf_event__aligner_dti_ib_np_tdata_o),
  .asf_event__aligner_dti_tdatachk_o    (asf_event__aligner_dti_ib_np_tdatachk_o),
  .asf_event__aligner_dti_tvalid_o      (asf_event__aligner_dti_ib_np_tvalid_o),
  .asf_event__aligner_dti_tvalidchk_o   (asf_event__aligner_dti_ib_np_tvalidchk_o),
  .asf_event__aligner_dti_tuser_o       (asf_event__aligner_dti_ib_np_tuser_o),
  .asf_event__aligner_dti_tuserchk_o    (asf_event__aligner_dti_ib_np_tuserchk_o)
  );

  hls_bridge_ib #(
  .NUM_HLS_PORTS                    (NUM_HLS_PORTS),
  .NUM_TLP_STREAMS                  (NUM_TLP_STREAMS),
  .HLS_DW_ALIGNMENT                 (HLS_DW_ALIGNMENT),
  .KMAX_DTI_SUPPORT                 (0),
  .KMAX_MSI_IF_SUPPORT              (0),
  .ORDERING_SUPPORT                 (0),
  .CRD_DW_COUNTER_WD                (CRD_DW_COUNTER_WD),
  .KMAX_DATAPATH_WD                 (KMAX_DATAPATH_WD),
  .HLS_METADATA_WD                  (HLS_RX_C_METADATA_WD),
  .KMAX_NUM_TLPS_PER_CLK            (KMAX_NUM_TLPS_PER_CLK),
  .HLS_PORT_DATA_WIDTH_ARR          (HLS_PORT_DATA_WIDTH_ARR),
  .HLS_PORT_TLPS_PER_CLK_ARR        (HLS_PORT_TLPS_PER_CLK_ARR),
  .HLS_AXI_STR_PTR_WD_ARR           (HLS_AXI_STR_PTR_WD_ARR),
  .HLS_AXI_END_PTR_WD_ARR           (HLS_AXI_END_PTR_WD_ARR),
  .HLS_AXI_PKT_CNTL_WD_ARR          (HLS_AXI_PKT_CNTL_WD_ARR),
  .HLS_AXI_CNTL_WD_ARR              (HLS_AXI_IB_C_CNTL_WD_ARR),
  .HLS_AXI_CNTL_CHK_WD_ARR          (HLS_AXI_IB_C_CNTL_CHK_WD_ARR),
  .HLS_AXI_CNTLS_WD                 (HLS_AXI_IB_C_CNTL_WD),
  .HLS_AXI_CNTLS_CHK_WD             (HLS_AXI_IB_C_CNTL_CHK_WD),
   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   .ASF_SUPPORT                        (ASF_SUPPORT),
   .ASF_NODE_ID_OFFSET                 (ASF_NODE_ID_OFFSET_IB_C),
   .ASF_ERR_INJ_SUPPORT                (ASF_ERR_INJ_SUPPORT),
   .ASF_ERROR_INJ_DATA_WIDTH           (ASF_ERROR_INJ_DATA_WIDTH),
   .ASF_ERROR_INJ_USER_WIDTH           (ASF_ERROR_INJ_USER_WIDTH),
   .ASF_EVENT_TYPE_WIDTH               (ASF_EVENT_TYPE_WIDTH),
   .ASF_EVENT_COUNT_WIDTH              (ASF_EVENT_COUNT_WIDTH),
   .ASF_NODE_ID_WIDTH                  (ASF_NODE_ID_WIDTH),
   .ASF_EVENT_DIAG_FIELD_WIDTH         (ASF_EVENT_DIAG_FIELD_WIDTH),

   .RX_METADATA_PKT_ROUTING_INFO_WD       (IB_C_METADATA_PKT_ROUTING_INFO_WD),
   .RX_METADATA_PKT_ROUTING_INFO_OFFSET   (IB_C_METADATA_PKT_ROUTING_INFO_OFFSET),
   .RX_METADATA_PORT_INFO_OFFSET          (IB_C_METADATA_PORT_INFO_OFFSET)
  )
  i_cdns_hls_bridge_ib_c
  (
   .k_sync_reset                         (k_sync_reset),
   .k_sync_cell_stages                   (k_sync_cell_stages),

   .core_clk                             (core_clk),
   .core_rst_n                           (core_rst_n),
  //kwires
   .k_hls_dw_alignment                   (k_hls_dw_alignment),
  //RX HAL
   .hls_rx_valid                         (hls_ib_compl_hal_valid),
   .hls_rx_data                          (hls_ib_compl_hal_data),
   .hls_rx_cntl                          (hls_ib_compl_hal_cntl),
   .hls_rx_crdgnt                        (hls_ib_compl_hal_crdgnt),
   .hls_rx_crdrtn                        (hls_ib_compl_hal_crdrtn),
   .hls_rx_activereq                     (hls_ib_compl_hal_activereq),
   .hls_rx_activeack                     (hls_ib_compl_hal_activeack),
   .hls_rx_deacthint                     (hls_ib_compl_hal_deacthint),
   .hls_rx_data_chk                      (hls_ib_compl_hal_data_chk),
   .hls_rx_cntl_chk                      (hls_ib_compl_hal_cntl_chk),
  //TX AXI-Bridge
   .hls_tx_axi_valid                     (hls_ib_compl_axi_valid),
   .hls_tx_axi_data                      (hls_ib_compl_axi_data),
   .hls_tx_axi_cntl                      (hls_ib_compl_axi_cntl),
   .hls_tx_axi_crdgnt                    (hls_ib_compl_axi_crdgnt),
   .hls_tx_axi_crdrtn                    (hls_ib_compl_axi_crdrtn),
   .hls_tx_axi_activereq                 (hls_ib_compl_axi_activereq),
   .hls_tx_axi_activeack                 (hls_ib_compl_axi_activeack),
   .hls_tx_axi_deacthint                 (hls_ib_compl_axi_deacthint),
   .hls_tx_axi_data_chk                  (hls_ib_compl_axi_data_chk),
   .hls_tx_axi_cntl_chk                  (hls_ib_compl_axi_cntl_chk),
   .hls_tx_dti_valid                     (),
   .hls_tx_dti_data                      (),
   .hls_tx_dti_cntl                      (),
   .hls_tx_dti_crdgnt                    (1'b0),
   .hls_tx_dti_crdrtn                    (),
   .hls_tx_dti_activereq                 (),
   .hls_tx_dti_activeack                 (1'b0),
   .hls_tx_dti_deacthint                 (1'b0),
   .hls_tx_dti_data_chk                  (),
   .hls_tx_dti_cntl_chk                  (),
   .hls_tx_dti_pri_supported             (1'b0),
   .tx_msi_ready                         (1'b0),
   .tx_msi_valid                         (), // intentionally not connected
   .tx_msi_valid_chk                     (),
   .tx_msi_payload                       (),
   .tx_msi_payload_chk                   (),

  .misc_flit_mode                        (2'b00),
  .misc_pbr_negotiated                   (1'b0),
  .misc_hls_bridge_route_en              (32'h0),

  .lm_segment_num                        (9'h0),

  .dc_sb_rx_axi_queue_empty              ({NUM_HLS_PORTS{1'b1}}), // used only if ordering_support
  .dc_sb_rx_msi_queue_empty              (1'b1),
  .dc_sb_rx_dti_queue_empty              (1'b1),
  .dc_sb_rx_axi_stream_queue_empty       ({(NUM_HLS_PORTS*NUM_TLP_STREAMS){1'b1}}),
  .dc_sb_rx_msi_stream_queue_empty       ({NUM_TLP_STREAMS{1'b1}}),
  .dc_sb_rx_dti_stream_queue_empty       ({NUM_TLP_STREAMS{1'b1}}),
  .dc_tlp_route_to_axi                   (),
  .dc_tlp_route_to_msi                   (),
  .dc_tlp_route_to_dti                   (),
  .dc_tlp_idg_streams                    (),

  .hls_bridge_msi_gic_cfg_hls_bridge_msi_gic_use_seg  (1'b0),
  .hls_bridge_dbg_order_dis_o_chk_dti_i               (1'b0),
  .hls_bridge_dbg_order_dis_o_chk_msi_i               (1'b0),
  .hls_bridge_dbg_order_dis_per_port_o_chk_i          (1'b0),

  .o_crd_dw_counter_valid                             (crd_dw_counter_ib_c_valid),
  .o_crd_dw_counter                                   (crd_dw_counter_ib_c),
  .o_crd_dw_counter_valid_chk                         (crd_dw_counter_ib_c_valid_chk),
  .o_crd_dw_counter_chk                               (crd_dw_counter_ib_c_chk),

  .link_down_handling_in_progress                     (link_down_handling_in_progress),

  //---------------------------------------------------------------------------------
  // ASF err inj
  //---------------------------------------------------------------------------------
  .asf_error_inj__ib_cmd_tvalid_i       (sub_block_error_inj__cmd_tvalid),
  .asf_error_inj__ib_tdata_i            (sub_block_error_inj__tdata     ),
  .asf_error_inj__ib_tuser_i            (sub_block_error_inj__tuser     ),

  .asf_event__stored_ff_cntl_valid      (asf_event__stored_ff_cntl_ib_c_valid),
  .asf_event__stored_ff_cntl_type       (asf_event__stored_ff_cntl_ib_c_type),
  .asf_event__stored_ff_cntl_count      (asf_event__stored_ff_cntl_ib_c_count),
  .asf_event__stored_ff_cntl_node_id    (asf_event__stored_ff_cntl_ib_c_node_id),
  .asf_event__stored_ff_cntl_diag_field (asf_event__stored_ff_cntl_ib_c_diag_field),

  .asf_event__msi_valid                 (),
  .asf_event__msi_type                  (),
  .asf_event__msi_count                 (),
  .asf_event__msi_node_id               (),
  .asf_event__msi_diag_field            (),

  .asf_event__aligner_axi_tdata_o       (asf_event__aligner_axi_ib_c_tdata_o),
  .asf_event__aligner_axi_tdatachk_o    (asf_event__aligner_axi_ib_c_tdatachk_o),
  .asf_event__aligner_axi_tvalid_o      (asf_event__aligner_axi_ib_c_tvalid_o),
  .asf_event__aligner_axi_tvalidchk_o   (asf_event__aligner_axi_ib_c_tvalidchk_o),
  .asf_event__aligner_axi_tuser_o       (asf_event__aligner_axi_ib_c_tuser_o),
  .asf_event__aligner_axi_tuserchk_o    (asf_event__aligner_axi_ib_c_tuserchk_o),

  .asf_event__gearbox_axi_tdata_o       (asf_event__gearbox_axi_ib_c_tdata_o),
  .asf_event__gearbox_axi_tdatachk_o    (asf_event__gearbox_axi_ib_c_tdatachk_o),
  .asf_event__gearbox_axi_tvalid_o      (asf_event__gearbox_axi_ib_c_tvalid_o),
  .asf_event__gearbox_axi_tvalidchk_o   (asf_event__gearbox_axi_ib_c_tvalidchk_o),
  .asf_event__gearbox_axi_tuser_o       (asf_event__gearbox_axi_ib_c_tuser_o),
  .asf_event__gearbox_axi_tuserchk_o    (asf_event__gearbox_axi_ib_c_tuserchk_o),

  .asf_event__aligner_dti_tdata_o       (),
  .asf_event__aligner_dti_tdatachk_o    (),
  .asf_event__aligner_dti_tvalid_o      (),
  .asf_event__aligner_dti_tvalidchk_o   (),
  .asf_event__aligner_dti_tuser_o       (),
  .asf_event__aligner_dti_tuserchk_o    ()
  );

  hls_bridge_ob #(
  .NUM_HLS_PORTS                       (NUM_HLS_PORTS),
  .HLS_DW_ALIGNMENT                    (HLS_DW_ALIGNMENT),
  .KMAX_DTI_SUPPORT                    (KMAX_DTI_SUPPORT),
  .KMAX_DATAPATH_WD                    (KMAX_DATAPATH_WD),
  .HLS_METADATA_WD                     (HLS_TX_PNP_METADATA_WD),
  .KMAX_NUM_TLPS_PER_CLK               (KMAX_NUM_TLPS_PER_CLK),
  .HLS_PORT_DATA_WIDTH_ARR             (HLS_PORT_DATA_WIDTH_ARR),
  .HLS_PORT_TLPS_PER_CLK_ARR           (HLS_PORT_TLPS_PER_CLK_ARR),
  .HLS_AXI_STR_PTR_WD_ARR              (HLS_AXI_STR_PTR_WD_ARR),
  .HLS_AXI_END_PTR_WD_ARR              (HLS_AXI_END_PTR_WD_ARR),
  .HLS_AXI_PKT_CNTL_WD_ARR             (HLS_AXI_PKT_CNTL_WD_ARR),
  .HLS_AXI_CNTL_WD_ARR                 (HLS_AXI_OB_PNP_CNTL_WD_ARR),
  .HLS_AXI_CNTL_CHK_WD_ARR             (HLS_AXI_OB_PNP_CNTL_CHK_WD_ARR),
  .HLS_AXI_CNTLS_WD                    (HLS_AXI_OB_PNP_CNTL_WD),
  .HLS_AXI_CNTLS_CHK_WD                (HLS_AXI_OB_PNP_CNTL_CHK_WD),
   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   .ASF_SUPPORT                        (ASF_SUPPORT),
   .ASF_NODE_ID_OFFSET                 (ASF_NODE_ID_OFFSET_OB_P),
   .ASF_ERR_INJ_SUPPORT                (ASF_ERR_INJ_SUPPORT),
   .ASF_ERROR_INJ_DATA_WIDTH           (ASF_ERROR_INJ_DATA_WIDTH),
   .ASF_ERROR_INJ_USER_WIDTH           (ASF_ERROR_INJ_USER_WIDTH),
   .ASF_EVENT_TYPE_WIDTH               (ASF_EVENT_TYPE_WIDTH),
   .ASF_EVENT_COUNT_WIDTH              (ASF_EVENT_COUNT_WIDTH),
   .ASF_NODE_ID_WIDTH                  (ASF_NODE_ID_WIDTH),
   .ASF_EVENT_DIAG_FIELD_WIDTH         (ASF_EVENT_DIAG_FIELD_WIDTH),

   .PORT_SOURCE_LABELING               (1)
  )
  i_cdns_hls_bridge_ob_p
  (
   .k_sync_reset                                (k_sync_reset),
   .k_sync_cell_stages                          (k_sync_cell_stages),

   .core_clk                                    (core_clk),
   .core_rst_n                                  (core_rst_n),

   //kwires
   .k_hls_dw_alignment                          (k_hls_dw_alignment),

   .hls_rx_axi_valid                            (hls_ob_posted_axi_valid),
   .hls_rx_axi_data                             (hls_ob_posted_axi_data),
   .hls_rx_axi_cntl                             (hls_ob_posted_axi_cntl),
   .hls_rx_axi_crdgnt                           (hls_ob_posted_axi_crdgnt),
   .hls_rx_axi_crdrtn                           (hls_ob_posted_axi_crdrtn),
   .hls_rx_axi_activereq                        (hls_ob_posted_axi_activereq),
   .hls_rx_axi_activeack                        (hls_ob_posted_axi_activeack),
   .hls_rx_axi_deacthint                        (hls_ob_posted_axi_deacthint),
   .hls_rx_axi_data_chk                         (hls_ob_posted_axi_data_chk),
   .hls_rx_axi_cntl_chk                         (hls_ob_posted_axi_cntl_chk),

   .hls_rx_dti_valid                            (hls_ob_posted_dti_valid),
   .hls_rx_dti_data                             (hls_ob_posted_dti_data),
   .hls_rx_dti_cntl                             (hls_ob_posted_dti_cntl),
   .hls_rx_dti_crdgnt                           (hls_ob_posted_dti_crdgnt),
   .hls_rx_dti_crdrtn                           (hls_ob_posted_dti_crdrtn),
   .hls_rx_dti_activereq                        (hls_ob_posted_dti_activereq),
   .hls_rx_dti_activeack                        (hls_ob_posted_dti_activeack),
   .hls_rx_dti_deacthint                        (hls_ob_posted_dti_deacthint),
   .hls_rx_dti_data_chk                         (hls_ob_posted_dti_data_chk),
   .hls_rx_dti_cntl_chk                         (hls_ob_posted_dti_cntl_chk),

   .hls_tx_valid                                (hls_ob_posted_hal_valid),
   .hls_tx_data                                 (hls_ob_posted_hal_data),
   .hls_tx_cntl                                 (hls_ob_posted_hal_cntl),
   .hls_tx_crdgnt                               (hls_ob_posted_hal_crdgnt),
   .hls_tx_crdrtn                               (hls_ob_posted_hal_crdrtn),
   .hls_tx_activereq                            (hls_ob_posted_hal_activereq),
   .hls_tx_activeack                            (hls_ob_posted_hal_activeack),
   .hls_tx_deacthint                            (hls_ob_posted_hal_deacthint),
   .hls_tx_data_chk                             (hls_ob_posted_hal_data_chk),
   .hls_tx_cntl_chk                             (hls_ob_posted_hal_cntl_chk)

   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   ,.asf_error_inj__cmd_tvalid_i                          (sub_block_error_inj__cmd_tvalid)
   ,.asf_error_inj__tdata_i                               (sub_block_error_inj__tdata     )
   ,.asf_error_inj__tuser_i                               (sub_block_error_inj__tuser     )
                                                          
   ,.asf_event__hls_labeled_axi_cntl_valid                (asf_event__hls_cntl_labeled_axi_ob_p_valid)
   ,.asf_event__hls_labeled_axi_cntl_type                 (asf_event__hls_cntl_labeled_axi_ob_p_type)
   ,.asf_event__hls_labeled_axi_cntl_count                (asf_event__hls_cntl_labeled_axi_ob_p_count)
   ,.asf_event__hls_labeled_axi_cntl_node_id              (asf_event__hls_cntl_labeled_axi_ob_p_node_id)
   ,.asf_event__hls_labeled_axi_cntl_diag_field           (asf_event__hls_cntl_labeled_axi_ob_p_diag_field)
                                                          
   ,.asf_event__hls_labeled_dti_cntl_valid                (asf_event__hls_cntl_labeled_dti_ob_p_valid)
   ,.asf_event__hls_labeled_dti_cntl_type                 (asf_event__hls_cntl_labeled_dti_ob_p_type)
   ,.asf_event__hls_labeled_dti_cntl_count                (asf_event__hls_cntl_labeled_dti_ob_p_count)
   ,.asf_event__hls_labeled_dti_cntl_node_id              (asf_event__hls_cntl_labeled_dti_ob_p_node_id)
   ,.asf_event__hls_labeled_dti_cntl_diag_field           (asf_event__hls_cntl_labeled_dti_ob_p_diag_field)

   ,.asf_event__hls_ob_gearbox_packer_cntl_valid          (asf_event__hls_ob_gearbox_packer_cntl_ob_p_valid      )
   ,.asf_event__hls_ob_gearbox_packer_cntl_type           (asf_event__hls_ob_gearbox_packer_cntl_ob_p_type       )
   ,.asf_event__hls_ob_gearbox_packer_cntl_count          (asf_event__hls_ob_gearbox_packer_cntl_ob_p_count      )
   ,.asf_event__hls_ob_gearbox_packer_cntl_node_id        (asf_event__hls_ob_gearbox_packer_cntl_ob_p_node_id    )
   ,.asf_event__hls_ob_gearbox_packer_cntl_diag_field     (asf_event__hls_ob_gearbox_packer_cntl_ob_p_diag_field )
   
   ,.asf_event__hls_ob_gearbox_packer_data_valid          (asf_event__hls_ob_gearbox_packer_data_ob_p_valid      )
   ,.asf_event__hls_ob_gearbox_packer_data_type           (asf_event__hls_ob_gearbox_packer_data_ob_p_type       )
   ,.asf_event__hls_ob_gearbox_packer_data_count          (asf_event__hls_ob_gearbox_packer_data_ob_p_count      )
   ,.asf_event__hls_ob_gearbox_packer_data_node_id        (asf_event__hls_ob_gearbox_packer_data_ob_p_node_id    )
   ,.asf_event__hls_ob_gearbox_packer_data_diag_field     (asf_event__hls_ob_gearbox_packer_data_ob_p_diag_field )
   
   ,.asf_event__hls_ob_gearbox_masker_cntl_valid          (asf_event__hls_ob_gearbox_masker_cntl_ob_p_valid      )
   ,.asf_event__hls_ob_gearbox_masker_cntl_type           (asf_event__hls_ob_gearbox_masker_cntl_ob_p_type       )
   ,.asf_event__hls_ob_gearbox_masker_cntl_count          (asf_event__hls_ob_gearbox_masker_cntl_ob_p_count      )
   ,.asf_event__hls_ob_gearbox_masker_cntl_node_id        (asf_event__hls_ob_gearbox_masker_cntl_ob_p_node_id    )
   ,.asf_event__hls_ob_gearbox_masker_cntl_diag_field     (asf_event__hls_ob_gearbox_masker_cntl_ob_p_diag_field )
   
   ,.asf_event__hls_ob_gearbox_masker_data_valid          (asf_event__hls_ob_gearbox_masker_data_ob_p_valid      )
   ,.asf_event__hls_ob_gearbox_masker_data_type           (asf_event__hls_ob_gearbox_masker_data_ob_p_type       )
   ,.asf_event__hls_ob_gearbox_masker_data_count          (asf_event__hls_ob_gearbox_masker_data_ob_p_count      )
   ,.asf_event__hls_ob_gearbox_masker_data_node_id        (asf_event__hls_ob_gearbox_masker_data_ob_p_node_id    )
   ,.asf_event__hls_ob_gearbox_masker_data_diag_field     (asf_event__hls_ob_gearbox_masker_data_ob_p_diag_field )
   
   ,.asf_event__ob_gearbox_aligner_tdata_o                (asf_event__ob_gearbox_aligner_ob_p_tdata_o            )
   ,.asf_event__ob_gearbox_aligner_tdatachk_o             (asf_event__ob_gearbox_aligner_ob_p_tdatachk_o         )
   ,.asf_event__ob_gearbox_aligner_tvalid_o               (asf_event__ob_gearbox_aligner_ob_p_tvalid_o           )
   ,.asf_event__ob_gearbox_aligner_tvalidchk_o            (asf_event__ob_gearbox_aligner_ob_p_tvalidchk_o        )
   ,.asf_event__ob_gearbox_aligner_tuser_o                (asf_event__ob_gearbox_aligner_ob_p_tuser_o            )
   ,.asf_event__ob_gearbox_aligner_tuserchk_o             (asf_event__ob_gearbox_aligner_ob_p_tuserchk_o         )

   ,.asf_event__ob_main_aligner_tdata_o                   (asf_event__ob_main_aligner_ob_p_tdata_o               )
   ,.asf_event__ob_main_aligner_tdatachk_o                (asf_event__ob_main_aligner_ob_p_tdatachk_o            )
   ,.asf_event__ob_main_aligner_tvalid_o                  (asf_event__ob_main_aligner_ob_p_tvalid_o              )
   ,.asf_event__ob_main_aligner_tvalidchk_o               (asf_event__ob_main_aligner_ob_p_tvalidchk_o           )
   ,.asf_event__ob_main_aligner_tuser_o                   (asf_event__ob_main_aligner_ob_p_tuser_o               )
   ,.asf_event__ob_main_aligner_tuserchk_o                (asf_event__ob_main_aligner_ob_p_tuserchk_o            )
  );
hls_bridge_ob #(
  .NUM_HLS_PORTS                       (NUM_HLS_PORTS),
  .HLS_DW_ALIGNMENT                    (HLS_DW_ALIGNMENT),
  .KMAX_DTI_SUPPORT                    (KMAX_DTI_SUPPORT),
  .KMAX_DATAPATH_WD                    (KMAX_DATAPATH_WD),
  .HLS_METADATA_WD                     (HLS_TX_PNP_METADATA_WD),
  .KMAX_NUM_TLPS_PER_CLK               (KMAX_NUM_TLPS_PER_CLK),
  .HLS_PORT_DATA_WIDTH_ARR             (HLS_PORT_DATA_WIDTH_ARR),
  .HLS_PORT_TLPS_PER_CLK_ARR           (HLS_PORT_TLPS_PER_CLK_ARR),
  .HLS_AXI_STR_PTR_WD_ARR              (HLS_AXI_STR_PTR_WD_ARR),
  .HLS_AXI_END_PTR_WD_ARR              (HLS_AXI_END_PTR_WD_ARR),
  .HLS_AXI_PKT_CNTL_WD_ARR             (HLS_AXI_PKT_CNTL_WD_ARR),
  .HLS_AXI_CNTL_WD_ARR                 (HLS_AXI_OB_C_CNTL_WD_ARR),
  .HLS_AXI_CNTL_CHK_WD_ARR             (HLS_AXI_OB_C_CNTL_CHK_WD_ARR),
  .HLS_AXI_CNTLS_WD                    (HLS_AXI_OB_C_CNTL_WD),
  .HLS_AXI_CNTLS_CHK_WD                (HLS_AXI_OB_C_CNTL_CHK_WD),
   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   .ASF_SUPPORT                        (ASF_SUPPORT),
   .ASF_NODE_ID_OFFSET                 (ASF_NODE_ID_OFFSET_OB_C),
   .ASF_ERR_INJ_SUPPORT                (ASF_ERR_INJ_SUPPORT),
   .ASF_ERROR_INJ_DATA_WIDTH           (ASF_ERROR_INJ_DATA_WIDTH),
   .ASF_ERROR_INJ_USER_WIDTH           (ASF_ERROR_INJ_USER_WIDTH),
   .ASF_EVENT_TYPE_WIDTH               (ASF_EVENT_TYPE_WIDTH),
   .ASF_EVENT_COUNT_WIDTH              (ASF_EVENT_COUNT_WIDTH),
   .ASF_NODE_ID_WIDTH                  (ASF_NODE_ID_WIDTH),
   .ASF_EVENT_DIAG_FIELD_WIDTH         (ASF_EVENT_DIAG_FIELD_WIDTH),

   .PORT_SOURCE_LABELING               (0)
  )
  i_cdns_hls_bridge_ob_c
  (
   .k_sync_reset                                (k_sync_reset),
   .k_sync_cell_stages                          (k_sync_cell_stages),

   .core_clk                                    (core_clk),
   .core_rst_n                                  (core_rst_n),

   //kwires
   .k_hls_dw_alignment                          (k_hls_dw_alignment),

   .hls_rx_axi_valid                            (hls_ob_compl_axi_valid),
   .hls_rx_axi_data                             (hls_ob_compl_axi_data),
   .hls_rx_axi_cntl                             (hls_ob_compl_axi_cntl),
   .hls_rx_axi_crdgnt                           (hls_ob_compl_axi_crdgnt),
   .hls_rx_axi_crdrtn                           (hls_ob_compl_axi_crdrtn),
   .hls_rx_axi_activereq                        (hls_ob_compl_axi_activereq),
   .hls_rx_axi_activeack                        (hls_ob_compl_axi_activeack),
   .hls_rx_axi_deacthint                        (hls_ob_compl_axi_deacthint),
   .hls_rx_axi_data_chk                         (hls_ob_compl_axi_data_chk),
   .hls_rx_axi_cntl_chk                         (hls_ob_compl_axi_cntl_chk),

   .hls_rx_dti_valid                            (hls_ob_compl_dti_valid),
   .hls_rx_dti_data                             (hls_ob_compl_dti_data),
   .hls_rx_dti_cntl                             (hls_ob_compl_dti_cntl),
   .hls_rx_dti_crdgnt                           (hls_ob_compl_dti_crdgnt),
   .hls_rx_dti_crdrtn                           (hls_ob_compl_dti_crdrtn),
   .hls_rx_dti_activereq                        (hls_ob_compl_dti_activereq),
   .hls_rx_dti_activeack                        (hls_ob_compl_dti_activeack),
   .hls_rx_dti_deacthint                        (hls_ob_compl_dti_deacthint),
   .hls_rx_dti_data_chk                         (hls_ob_compl_dti_data_chk),
   .hls_rx_dti_cntl_chk                         (hls_ob_compl_dti_cntl_chk),

   .hls_tx_valid                                (hls_ob_compl_hal_valid),
   .hls_tx_data                                 (hls_ob_compl_hal_data),
   .hls_tx_cntl                                 (hls_ob_compl_hal_cntl),
   .hls_tx_crdgnt                               (hls_ob_compl_hal_crdgnt),
   .hls_tx_crdrtn                               (hls_ob_compl_hal_crdrtn),
   .hls_tx_activereq                            (hls_ob_compl_hal_activereq),
   .hls_tx_activeack                            (hls_ob_compl_hal_activeack),
   .hls_tx_deacthint                            (hls_ob_compl_hal_deacthint),
   .hls_tx_data_chk                             (hls_ob_compl_hal_data_chk),
   .hls_tx_cntl_chk                             (hls_ob_compl_hal_cntl_chk)

   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   ,.asf_error_inj__cmd_tvalid_i                         (sub_block_error_inj__cmd_tvalid)
   ,.asf_error_inj__tdata_i                              (sub_block_error_inj__tdata     )
   ,.asf_error_inj__tuser_i                              (sub_block_error_inj__tuser     )

   ,.asf_event__hls_labeled_axi_cntl_valid                (asf_event__hls_cntl_labeled_axi_ob_c_valid)
   ,.asf_event__hls_labeled_axi_cntl_type                 (asf_event__hls_cntl_labeled_axi_ob_c_type)
   ,.asf_event__hls_labeled_axi_cntl_count                (asf_event__hls_cntl_labeled_axi_ob_c_count)
   ,.asf_event__hls_labeled_axi_cntl_node_id              (asf_event__hls_cntl_labeled_axi_ob_c_node_id)
   ,.asf_event__hls_labeled_axi_cntl_diag_field           (asf_event__hls_cntl_labeled_axi_ob_c_diag_field)

   ,.asf_event__hls_labeled_dti_cntl_valid                (asf_event__hls_cntl_labeled_dti_ob_c_valid)
   ,.asf_event__hls_labeled_dti_cntl_type                 (asf_event__hls_cntl_labeled_dti_ob_c_type)
   ,.asf_event__hls_labeled_dti_cntl_count                (asf_event__hls_cntl_labeled_dti_ob_c_count)
   ,.asf_event__hls_labeled_dti_cntl_node_id              (asf_event__hls_cntl_labeled_dti_ob_c_node_id)
   ,.asf_event__hls_labeled_dti_cntl_diag_field           (asf_event__hls_cntl_labeled_dti_ob_c_diag_field)

   ,.asf_event__hls_ob_gearbox_packer_cntl_valid          (asf_event__hls_ob_gearbox_packer_cntl_ob_c_valid      )
   ,.asf_event__hls_ob_gearbox_packer_cntl_type           (asf_event__hls_ob_gearbox_packer_cntl_ob_c_type       )
   ,.asf_event__hls_ob_gearbox_packer_cntl_count          (asf_event__hls_ob_gearbox_packer_cntl_ob_c_count      )
   ,.asf_event__hls_ob_gearbox_packer_cntl_node_id        (asf_event__hls_ob_gearbox_packer_cntl_ob_c_node_id    )
   ,.asf_event__hls_ob_gearbox_packer_cntl_diag_field     (asf_event__hls_ob_gearbox_packer_cntl_ob_c_diag_field )
   
   ,.asf_event__hls_ob_gearbox_packer_data_valid          (asf_event__hls_ob_gearbox_packer_data_ob_c_valid      )
   ,.asf_event__hls_ob_gearbox_packer_data_type           (asf_event__hls_ob_gearbox_packer_data_ob_c_type       )
   ,.asf_event__hls_ob_gearbox_packer_data_count          (asf_event__hls_ob_gearbox_packer_data_ob_c_count      )
   ,.asf_event__hls_ob_gearbox_packer_data_node_id        (asf_event__hls_ob_gearbox_packer_data_ob_c_node_id    )
   ,.asf_event__hls_ob_gearbox_packer_data_diag_field     (asf_event__hls_ob_gearbox_packer_data_ob_c_diag_field )
   
   ,.asf_event__hls_ob_gearbox_masker_cntl_valid          (asf_event__hls_ob_gearbox_masker_cntl_ob_c_valid      )
   ,.asf_event__hls_ob_gearbox_masker_cntl_type           (asf_event__hls_ob_gearbox_masker_cntl_ob_c_type       )
   ,.asf_event__hls_ob_gearbox_masker_cntl_count          (asf_event__hls_ob_gearbox_masker_cntl_ob_c_count      )
   ,.asf_event__hls_ob_gearbox_masker_cntl_node_id        (asf_event__hls_ob_gearbox_masker_cntl_ob_c_node_id    )
   ,.asf_event__hls_ob_gearbox_masker_cntl_diag_field     (asf_event__hls_ob_gearbox_masker_cntl_ob_c_diag_field )
   
   ,.asf_event__hls_ob_gearbox_masker_data_valid          (asf_event__hls_ob_gearbox_masker_data_ob_c_valid      )
   ,.asf_event__hls_ob_gearbox_masker_data_type           (asf_event__hls_ob_gearbox_masker_data_ob_c_type       )
   ,.asf_event__hls_ob_gearbox_masker_data_count          (asf_event__hls_ob_gearbox_masker_data_ob_c_count      )
   ,.asf_event__hls_ob_gearbox_masker_data_node_id        (asf_event__hls_ob_gearbox_masker_data_ob_c_node_id    )
   ,.asf_event__hls_ob_gearbox_masker_data_diag_field     (asf_event__hls_ob_gearbox_masker_data_ob_c_diag_field )
   
   ,.asf_event__ob_gearbox_aligner_tdata_o                (asf_event__ob_gearbox_aligner_ob_c_tdata_o            )
   ,.asf_event__ob_gearbox_aligner_tdatachk_o             (asf_event__ob_gearbox_aligner_ob_c_tdatachk_o         )
   ,.asf_event__ob_gearbox_aligner_tvalid_o               (asf_event__ob_gearbox_aligner_ob_c_tvalid_o           )
   ,.asf_event__ob_gearbox_aligner_tvalidchk_o            (asf_event__ob_gearbox_aligner_ob_c_tvalidchk_o        )
   ,.asf_event__ob_gearbox_aligner_tuser_o                (asf_event__ob_gearbox_aligner_ob_c_tuser_o            )
   ,.asf_event__ob_gearbox_aligner_tuserchk_o             (asf_event__ob_gearbox_aligner_ob_c_tuserchk_o         )

   ,.asf_event__ob_main_aligner_tdata_o                   (asf_event__ob_main_aligner_ob_c_tdata_o               )
   ,.asf_event__ob_main_aligner_tdatachk_o                (asf_event__ob_main_aligner_ob_c_tdatachk_o            )
   ,.asf_event__ob_main_aligner_tvalid_o                  (asf_event__ob_main_aligner_ob_c_tvalid_o              )
   ,.asf_event__ob_main_aligner_tvalidchk_o               (asf_event__ob_main_aligner_ob_c_tvalidchk_o           )
   ,.asf_event__ob_main_aligner_tuser_o                   (asf_event__ob_main_aligner_ob_c_tuser_o               )
   ,.asf_event__ob_main_aligner_tuserchk_o                (asf_event__ob_main_aligner_ob_c_tuserchk_o            )
  );


generate
  if (KMAX_MSI_IF_SUPPORT == 1) begin : i_cdns_hls_bridge_msi_gen// TBD Tem WO for ASF
  hls_bridge_msi #(
   .KMAX_ASF_SUPPORT                     (ASF_SUPPORT),
   .KMAX_MSI_TDATA_WIDTH                 (KMAX_MSI_TDATA_WIDTH),
   .MSI_DC_DATA_WIDTH                    (MSI_DC_DATA_WIDTH),
   .MSI_LTIC_DATA_WIDTH                  (MSI_LTIC_DATA_WIDTH),
   .MSI_QOS_DATA_WIDTH                   (MSI_QOS_DATA_WIDTH),
   // ------------------ ASF-------------------------------
   .ASF_SUPPORT                          (ASF_SUPPORT),
   .ASF_NODE_ID_BASE                     (ASF_NODE_ID_BASE),
   .ASF_ERR_INJ_SUPPORT                  (ASF_ERR_INJ_SUPPORT),
   .ASF_ERROR_INJ_DATA_WIDTH             (ASF_ERROR_INJ_DATA_WIDTH),
   .ASF_ERROR_INJ_USER_WIDTH             (ASF_ERROR_INJ_USER_WIDTH),
   .ASF_EVENT_TYPE_WIDTH                 (ASF_EVENT_TYPE_WIDTH),
   .ASF_EVENT_COUNT_WIDTH                (ASF_EVENT_COUNT_WIDTH),
   .ASF_NODE_ID_WIDTH                    (ASF_NODE_ID_WIDTH),
   .ASF_EVENT_DIAG_FIELD_WIDTH           (ASF_EVENT_DIAG_FIELD_WIDTH)
   //.ASF_ERROR_INJ_DATA_WIDTH               (56),
   //.ASF_ERROR_INJ_USER_WIDTH               (8),
   //.ASF_EVENT_TYPE_WIDTH                   (4),
   //.ASF_EVENT_COUNT_WIDTH                  (8),
   //.ASF_NODE_ID_WIDTH                      (16),
   //.ASF_EVENT_DIAG_FIELD_WIDTH             (28)
  )
  i_cdns_hls_bridge_msi
  (
   .k_sync_reset                         (k_sync_reset),//input //Selectes datasync reset (0: asynchronous            1: synchronous reset)
   .k_sync_cell_stages                   (k_sync_cell_stages),//input // Selectes number of stages in datasync (0: 2 stages 1: 3 stages)

   .core_clk                      (core_clk),
   .core_rst_n                    (core_rst_n),
   .axi_clk                              (axi_msi_clk),
   .axi_rst_n                            (axi_msi_rst_n),
   .axi_qactive                          (axi_msi_qactive_int),

   .rx_posted_valid                      (ib_posted_msi_valid),
   .rx_posted_data                       (ib_posted_msi_payload),
   .rx_posted_ready                      (ib_posted_msi_ready),
   .rx_posted_valid_chk                  (ib_posted_msi_valid_chk),
   .rx_posted_data_chk                   (ib_posted_msi_payload_chk),

//   .rx_send_msi_pck                      (1'b1),

   .axis_msi_m_tvalid                    (axis_msi_m_tvalid),
   .axis_msi_m_tvalid_chk                (axis_msi_m_tvalid_chk),
   .axis_msi_m_tready                    (axis_msi_m_tready),
   .axis_msi_m_tready_chk                (axis_msi_m_tready_chk),
   .axis_msi_m_tdata                     (axis_msi_m_tdata),
   .axis_msi_m_tdata_chk                 (axis_msi_m_tdata_chk ),
   .axis_msi_m_twakeup                   (axis_msi_m_twakeup),
   .axis_msi_m_twakeup_chk               (axis_msi_m_twakeup_chk),

   .dc_tx_msi_data                       (dc_tx_msi_data),//output
   .dc_tx_msi_valid                      (dc_tx_msi_valid),//output
   .dc_tx_msi_data_chk                   (dc_tx_msi_data_chk),//output
   .dc_tx_msi_valid_chk                  (dc_tx_msi_valid_chk),//output
   //.dc_tx_msi_vc                         (dc_tx_msi_vc),//output
   //.dc_tx_msi_idg                        (dc_tx_msi_idg),//output

   .ltic_tx_msi_data                     (ltic_tx_msi_data),//output wire
   .ltic_tx_msi_valid                    (ltic_tx_msi_valid),//output wire
   .ltic_tx_msi_data_chk                 (ltic_tx_msi_data_chk),//output wire
   .ltic_tx_msi_valid_chk                (ltic_tx_msi_valid_chk),//output wire

   .qos_tx_msi_data                     (qos_tx_msi_data),//output wire
   .qos_tx_msi_valid                    (qos_tx_msi_valid),//output wire
   .qos_tx_msi_data_chk                 (qos_tx_msi_data_chk),//output wire
   .qos_tx_msi_valid_chk                (qos_tx_msi_valid_chk),//output wire
   //
   // ------------------ ASF-------------------------------
   .core_clk_asf_error_inj__cmd_tvalid_i   (sub_block_error_inj__cmd_tvalid),//input
   .core_clk_asf_error_inj__tdata_i        (sub_block_error_inj__tdata),//input [ASF_ERROR_INJ_DATA_WIDTH-1:0]
   .core_clk_asf_error_inj__tuser_i        (sub_block_error_inj__tuser),//input [ASF_ERROR_INJ_USER_WIDTH-1:0]

   .axi_clk_asf_error_inj__cmd_tvalid_i           (sub_block_error_inj__cdc_cmd_tvalid),//input
   .axi_clk_asf_error_inj__tdata_i                (sub_block_error_inj__cdc_tdata),//input [ASF_ERROR_INJ_DATA_WIDTH-1:0]
   .axi_clk_asf_error_inj__tuser_i                (sub_block_error_inj__cdc_tuser),//input [ASF_ERROR_INJ_USER_WIDTH-1:0]

   .asf_event__valid_msi_tvalid           (asf_event__valid_msi_tvalid),//output [DC_ASF_EVENT_VALID_WIDTH-1:0]
   .asf_event__type_msi_tvalid            (asf_event__type_msi_tvalid),//output [DC_ASF_EVENT_TYPE_WIDTH-1:0]
   .asf_event__count_msi_tvalid           (asf_event__count_msi_tvalid),//output [DC_ASF_EVENT_COUNT_WIDTH-1:0]
   .asf_event__node_id_msi_tvalid         (asf_event__node_id_msi_tvalid),//output [DC_ASF_NODE_ID_WIDTH-1:0]
   .asf_event__diag_field_msi_tvalid      (asf_event__diag_field_msi_tvalid),//output [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]

   .asf_event__valid_msi_tdata            (asf_event__valid_msi_tdata),//output [DC_ASF_EVENT_VALID_WIDTH-1:0]
   .asf_event__type_msi_tdata             (asf_event__type_msi_tdata),//output [DC_ASF_EVENT_TYPE_WIDTH-1:0]
   .asf_event__count_msi_tdata            (asf_event__count_msi_tdata),//output [DC_ASF_EVENT_COUNT_WIDTH-1:0]
   .asf_event__node_id_msi_tdata          (asf_event__node_id_msi_tdata),//output [DC_ASF_NODE_ID_WIDTH-1:0]
   .asf_event__diag_field_msi_tdata       (asf_event__diag_field_msi_tdata)//output [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]


  );
  assign axi_msi_qactive = axi_msi_qactive_int | axi_msi_qactive_err_inj;
  end
  else begin : no_msi
    assign axi_msi_qactive        = 1'b0;
    assign dc_tx_msi_valid        = 1'b0;
    assign dc_tx_msi_valid_chk    = 1'b1;
    assign axis_msi_m_tvalid      = 1'b0;
    assign axis_msi_m_tvalid_chk  = 1'b1;
    assign axis_msi_m_twakeup     = 1'b0;
    assign axis_msi_m_twakeup_chk = 1'b1;
    assign axis_msi_m_tdata       = {KMAX_MSI_TDATA_WIDTH{1'b0}};
    assign axis_msi_m_tdata_chk   = {KMAX_MSI_TDATA_WIDTH_CHK{1'b1}};
    assign ltic_tx_msi_data       = {MSI_LTIC_DATA_WIDTH{1'b0}};
    assign ltic_tx_msi_valid      = 1'b0;
    assign ltic_tx_msi_data_chk   = 1'b1;
    assign ltic_tx_msi_valid_chk  = 1'b1;
    assign qos_tx_msi_data        = {MSI_QOS_DATA_WIDTH{1'b0}};
    assign qos_tx_msi_valid       = 1'b0;
    assign qos_tx_msi_data_chk    = 1'b1;
    assign qos_tx_msi_valid_chk   = 1'b1;
    assign dc_tx_msi_data         = {MSI_DC_DATA_WIDTH{1'b0}};
    assign dc_tx_msi_data_chk     = 1'b1;
    assign ib_posted_msi_ready = 1'b0;
    assign asf_event__valid_msi_tvalid      = 1'b0;
    assign asf_event__type_msi_tvalid       = {ASF_EVENT_TYPE_WIDTH{1'b0}};
    assign asf_event__count_msi_tvalid      = {ASF_EVENT_COUNT_WIDTH{1'b0}};
    assign asf_event__node_id_msi_tvalid    = {ASF_NODE_ID_WIDTH{1'b0}};
    assign asf_event__diag_field_msi_tvalid = {ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
    assign asf_event__valid_msi_tdata      = 1'b0;
    assign asf_event__type_msi_tdata       = {ASF_EVENT_TYPE_WIDTH{1'b0}};
    assign asf_event__count_msi_tdata      = {ASF_EVENT_COUNT_WIDTH{1'b0}};
    assign asf_event__node_id_msi_tdata    = {ASF_NODE_ID_WIDTH{1'b0}};
    assign asf_event__diag_field_msi_tdata = {ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};

  end
endgenerate

  hls_bridge_hdr2log
  #(
  .NUM_HLS_PORTS                               (NUM_HLS_PORTS),
  .KMAX_DTI_SUPPORT                            (KMAX_DTI_SUPPORT),
  .HLS_PORT_DATA_WIDTH_ARR                     (HLS_PORT_DATA_WIDTH_ARR),
  .KMAX_DATAPATH_WD                            (KMAX_DATAPATH_WD)
  )
  i_cdns_hls_bridge_hdr2log
  (
   .core_clk                            (core_clk),
   .core_rst_n                          (core_rst_n),
   .hdr2log_rx_hls_tvalid                      (hdr2log_s_tvalid    ),
   .hdr2log_rx_hls_tvalid_chk                  (hdr2log_s_tvalid_chk),
   .hdr2log_rx_hls_tready                      (hdr2log_s_tready    ),
   .hdr2log_rx_hls_tready_chk                  (hdr2log_s_tready_chk),
   .hdr2log_rx_hls_tlast                       (hdr2log_s_tlast     ),
   .hdr2log_rx_hls_tlast_chk                   (hdr2log_s_tlast_chk ),
   .hdr2log_rx_hls_tdata                       (hdr2log_s_tdata     ),
   .hdr2log_rx_hls_tdata_chk                   (hdr2log_s_tdata_chk ),
   .hdr2log_rx_hls_tuser                       (hdr2log_s_tuser     ),
   .hdr2log_rx_hls_tuser_chk                   (hdr2log_s_tuser_chk ),

   .hdr2log_rx_dti_tvalid                      (hdr2log_tx_dti_tvalid    ),
   .hdr2log_rx_dti_tvalid_chk                  (hdr2log_tx_dti_tvalid_chk),
   .hdr2log_rx_dti_tready                      (hdr2log_tx_dti_tready    ),
   .hdr2log_rx_dti_tready_chk                  (hdr2log_tx_dti_tready_chk),
   .hdr2log_rx_dti_tlast                       (hdr2log_tx_dti_tlast     ),
   .hdr2log_rx_dti_tlast_chk                   (hdr2log_tx_dti_tlast_chk ),
   .hdr2log_rx_dti_tdata                       (hdr2log_tx_dti_tdata     ),
   .hdr2log_rx_dti_tdata_chk                   (hdr2log_tx_dti_tdata_chk ),
   .hdr2log_rx_dti_tuser                       (hdr2log_tx_dti_tuser),
   .hdr2log_rx_dti_tuser_chk                   (hdr2log_tx_dti_tuser_chk),

   .hdr2log_tx_tvalid                          (hdr2log_m_tvalid    ),
   .hdr2log_tx_tvalid_chk                      (hdr2log_m_tvalid_chk),
   .hdr2log_tx_tready                          (hdr2log_m_tready    ),
   .hdr2log_tx_tready_chk                      (hdr2log_m_tready_chk),
   .hdr2log_tx_tlast                           (hdr2log_m_tlast     ),
   .hdr2log_tx_tlast_chk                       (hdr2log_m_tlast_chk ),
   .hdr2log_tx_tdata                           (hdr2log_m_tdata     ),
   .hdr2log_tx_tdata_chk                       (hdr2log_m_tdata_chk ),
   .hdr2log_tx_tuser                           (hdr2log_m_tuser     ),
   .hdr2log_tx_tuser_chk                       (hdr2log_m_tuser_chk )
  );


  //---------------------------------------------------------------------------------------------------------------------
  // AXI5 Interconnect
  //---------------------------------------------------------------------------------------------------------------------
  localparam  AXIL_S_RANGE_WIDTH                                        = AXIL_ADDR_WIDTH < 2 ? 1 : $clog2(AXIL_ADDR_WIDTH + 1);
  localparam  AXIL_S_ADDR_WIDTH_WIDTH                                   = (AXIL_ADDR_WIDTH < 2) ? 1 : $clog2(AXIL_ADDR_WIDTH);

   wire  [31:0]                                                          axil_address_width_min1_i32;
   wire  [AXIL_S_ADDR_WIDTH_WIDTH-1:0]                                   axil_address_width_min1;

   wire  [1*INTERNAL_AXIL_M_IF_NUMBER*AXIL_ADDR_WIDTH-1:0]               axil_address_map_bases; // S_IF_COUNT*M_IF_COUT*AXIL_ADDR_WIDTH
   wire  [1*INTERNAL_AXIL_M_IF_NUMBER*AXIL_S_RANGE_WIDTH-1:0]            axil_address_map_ranges;
   wire  [1*INTERNAL_AXIL_M_IF_NUMBER*AXIL_ADDR_WIDTH-1:0]               axil_address_remap_bases;
   wire  [INTERNAL_AXIL_M_IF_NUMBER*AXIL_S_ADDR_WIDTH_WIDTH-1:0]         axil_m_address_widths_min1;

   assign axil_address_width_min1_i32  = AXIL_ADDR_WIDTH - 1;
   assign axil_address_width_min1      = axil_address_width_min1_i32 [AXIL_S_ADDR_WIDTH_WIDTH-1:0];


  //------------------------------------------------------------------------------
  // Address maps
  //------------------------------------------------------------------------------
   assign axil_address_map_bases = {
      26'h2000000,  // AXI-Bridge
      26'h1F20000,  // DTI
      26'h1F00000   // HLS-BRIDGE
   };

  //------------------------------------------------------------------------------
  // Address range
  //------------------------------------------------------------------------------
  assign axil_address_map_ranges = {
      5'd25,         // AXI-Bridge - 1024k  - 0x1000000
      5'd12,         // DTI        -    4k  -    0x1000
      5'd16          // HLS-BRIDGE -   64k  -   0x10000
   };

  assign axil_address_remap_bases = {
      26'h0000000,   // AXI-Bridge
      26'h0000000,   // DTI
      26'h0000000    // HLS-BRIDGE
   };

  //------------------------------------------------------------------------------
  // Address width
  //------------------------------------------------------------------------------
   assign axil_m_address_widths_min1 = {
      5'd25,         // AXI-Bridge
      5'd12,         // DTI
      5'd16          // HLS-BRIDGE
   };

  //---------------------------------------------------------------------------------------------------------------------
  // AXI5 Interconnect wires
  //---------------------------------------------------------------------------------------------------------------------

  //Outputs
  assign axil_m_awvalid = internal_axil_m_awvalid [2];                                      //output wire
  assign axil_m_awaddr  = internal_axil_m_awaddr  [2*AXIL_ADDR_WIDTH  +: AXIL_ADDR_WIDTH];  //output wire [AXIL_ADDR_WIDTH-1:0]
  assign axil_m_awprot  = internal_axil_m_awprot  [2*AXIL_PROT_WIDTH  +: AXIL_PROT_WIDTH];  //output wire [AXIL_PROT_WIDTH-1:0]
  assign axil_m_awuser  = internal_axil_m_awuser  [2*AXIL_WUSER_WIDTH +: AXIL_WUSER_WIDTH]; //output wire [AXIL_AWUSER_WIDTH-1:0]
  assign axil_m_wvalid  = internal_axil_m_wvalid  [2];                                      //output wire
  assign axil_m_wdata   = internal_axil_m_wdata   [2*AXIL_DATA_WIDTH   +: AXIL_DATA_WIDTH]; //output wire [AXIL_DATA_WIDTH-1:0]
  assign axil_m_wstrb   = internal_axil_m_wstrb   [2*AXIL_STRB_WIDTH   +: AXIL_STRB_WIDTH]; //output wire [AXIL_DATA_WIDTH/8 -1:0]
//  assign axil_m_wuser   = internal_axil_m_wuser   [2*AXIL_WUSER_WIDTH  +: AXIL_WUSER_WIDTH];//output wire [AXIL_WUSER_WIDTH-1:0]
  assign axil_m_bready  = internal_axil_m_bready  [2];                                      //output wire
  assign axil_m_arvalid = internal_axil_m_arvalid [2];                                      //output wire
  assign axil_m_araddr  = internal_axil_m_araddr  [2*AXIL_ADDR_WIDTH  +: AXIL_ADDR_WIDTH];  //output wire [AXIL_ADDR_WIDTH-1:0]
  assign axil_m_arprot  = internal_axil_m_arprot  [2*AXIL_PROT_WIDTH  +: AXIL_PROT_WIDTH];  //output wire [AXIL_PROT_WIDTH-1:0]
  assign axil_m_aruser  = internal_axil_m_aruser  [2*AXIL_WUSER_WIDTH +: AXIL_WUSER_WIDTH]; //output wire [AXIL_ARUSER_WIDTH-1:0]
  assign axil_m_rready  = internal_axil_m_rready  [2];                                      //output wire

  //Inputs
  // Concatenate external signals (position [2]) with connected signals (positions [0:1])
  assign internal_axil_m_arready = {axil_m_arready, connected_internal_axil_m_arready};
  assign internal_axil_m_awready = {axil_m_awready, connected_internal_axil_m_awready};
  assign internal_axil_m_bresp   = {axil_m_bresp, connected_internal_axil_m_bresp};
  assign internal_axil_m_bvalid  = {axil_m_bvalid, connected_internal_axil_m_bvalid};
  assign internal_axil_m_rresp   = {axil_m_rresp, connected_internal_axil_m_rresp};
  assign internal_axil_m_rvalid  = {axil_m_rvalid, connected_internal_axil_m_rvalid};
  assign internal_axil_m_wready  = {axil_m_wready, connected_internal_axil_m_wready};
  assign internal_axil_m_rdata   = {axil_m_rdata, connected_internal_axil_m_rdata};

  //---------------------------------------------------------------------------------------------------------------------
  //ASF
  //---------------------------------------------------------------------------------------------------------------------
  //Outpust
  assign axil_m_awaddr_chk  = internal_axil_m_awaddr_par [2*AXIL_ADDR_WIDTH_CHK  +: AXIL_ADDR_WIDTH_CHK];  //output wire [AXIL_ADDR_WIDTH-1:0]
  assign axil_m_awuser_chk  = internal_axil_m_awuser_par [2*AXIL_WUSER_WIDTH_CHK +: AXIL_WUSER_WIDTH_CHK]; //output wire [AXIL_AWUSER_WIDTH-1:0]
  assign axil_m_wdata_chk   = internal_axil_m_wdata_par  [2*AXIL_DATA_WIDTH_CHK  +: AXIL_DATA_WIDTH_CHK];  //output wire [AXIL_DATA_WIDTH-1:0]
  assign axil_m_wstrb_chk   = internal_axil_m_wstrb_par  [2*AXIL_STRB_WIDTH_CHK  +: AXIL_STRB_WIDTH_CHK];  //output wire [AXIL_DATA_WIDTH/8 -1:0]
//  assign axil_m_wuser_chk   = internal_axil_m_wuser_par  [2*AXIL_WUSER_WIDTH_CHK +: AXIL_WUSER_WIDTH_CHK]; //output wire [AXIL_WUSER_WIDTH-1:0]
  assign axil_m_araddr_chk  = internal_axil_m_araddr_par [2*AXIL_ADDR_WIDTH_CHK  +: AXIL_ADDR_WIDTH_CHK];  //output wire [AXIL_ADDR_WIDTH-1:0]
  assign axil_m_arctl_chk0  = internal_axil_m_arctl_chk0 [2*AXIL_PROT_WIDTH_CHK  +: AXIL_PROT_WIDTH_CHK];  //output wire [AXIL_PROT_WIDTH-1:0]
  assign axil_m_aruser_chk  = internal_axil_m_aruser_par [2*AXIL_WUSER_WIDTH_CHK +: AXIL_WUSER_WIDTH_CHK]; //output wire [AXIL_ARUSER_WIDTH-1:0]

  assign axil_m_arvalid_chk = internal_axil_m_arvalid_par[2];
  assign axil_m_bready_chk  = internal_axil_m_bready_par [2];
  assign axil_m_wvalid_chk  = internal_axil_m_wvalid_par [2];
  assign axil_m_awctl_chk0  = internal_axil_m_awctl_chk0 [2];
  assign axil_m_awvalid_chk = internal_axil_m_awvalid_par[2];
  assign axil_m_rready_chk  = internal_axil_m_rready_par [2];

  //Inputs
  assign internal_axil_m_rresp_par   = {axil_m_rresp_chk, connected_internal_axil_m_rresp_par};
  assign internal_axil_m_bresp_par   = {axil_m_bresp_chk, connected_internal_axil_m_bresp_par};
  assign internal_axil_m_awready_par = {axil_m_awready_chk, connected_internal_axil_m_awready_par};
  assign internal_axil_m_wready_par  = {axil_m_wready_chk, connected_internal_axil_m_wready_par};
  assign internal_axil_m_bvalid_par  = {axil_m_bvalid_chk, connected_internal_axil_m_bvalid_par};
  assign internal_axil_m_arready_par = {axil_m_arready_chk, connected_internal_axil_m_arready_par};
  assign internal_axil_m_rvalid_par  = {axil_m_rvalid_chk, connected_internal_axil_m_rvalid_par};
  assign internal_axil_m_rdata_par   = {axil_m_rdata_chk, connected_internal_axil_m_rdata_par};
  //---------------------------------------------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------------------------------------------
  axi5_lite_interconnect_v3_dw32
  #(
    .CHECK_TYPE                              (ASF_SUPPORT_GE_2 ? 2 : 0), //tbd
    .S_IF_COUNT                              (1),
    .M_IF_COUNT                              (INTERNAL_AXIL_M_IF_NUMBER),
    .ID_WIDTH                                (1),
    .ADDR_WIDTH                              (AXIL_ADDR_WIDTH),
    .DATA_WIDTH                              (AXIL_DATA_WIDTH),
    .AWUSER_WIDTH                            (AXIL_AWUSER_WIDTH),
    .ARUSER_WIDTH                            (AXIL_ARUSER_WIDTH),
    .PROT_WIDTH                              (AXIL_PROT_WIDTH),
    .RESP_WIDTH                              (AXIL_RESP_WIDTH),
    .S_HAS_OUTSTANDING                       (0),
    .M_HAS_OUTSTANDING                       (0),
    .OUTSTANDING_MAX                         (1),
    .ADDRESS_MAP_SLOT_COUNT                  (1),
    .M_A_REGISTER_MODE                       ({INTERNAL_AXIL_M_IF_NUMBER{2'd1}}),
    .M_B_REGISTER_MODE                       ({INTERNAL_AXIL_M_IF_NUMBER{2'd1}}),
    .M_R_REGISTER_MODE                       ({INTERNAL_AXIL_M_IF_NUMBER{2'd1}}),
    .M_W_REGISTER_MODE                       ({INTERNAL_AXIL_M_IF_NUMBER{2'd1}})
)
  i_cdns_hls_bridge_axi_interconnect
  (
    //BSF_IF:Clock_and_resets_interface,clock,resetn,,Clock and Reset;
    //BSF:,,,,clock;
    .clock                                  (axil_clk),//input
    .m_clock                                ({axil_clk,axil_clk,axil_clk}),//input  [M_IF_COUNT - 1 : 0]
    //.m_clock                                ({core_clk,core_clk,axi_clk}),//input  [M_IF_COUNT - 1 : 0]
    .s_clock                                (axil_clk),//input  [S_IF_COUNT - 1 : 0]
    //BSF:,,,,reset;
    .resetn                                 (axil_rst_n),//input
    .m_resetn                               ({axil_rst_n,axil_rst_n,axil_rst_n}),//input  [M_IF_COUNT - 1 : 0]
    //.m_resetn                                ({core_rst_n,core_rst_n,axi_rst_n}),//input  [M_IF_COUNT - 1 : 0]
    .s_resetn                               (axil_rst_n),//input  [S_IF_COUNT - 1 : 0]
    //BSF_IF_END:Clock_and_resets_interface;

    // Configuration Interface
    //BSF_IF:cr_if,clock,resetn,ipio=0;
    .enable_check                            (ASF_SUPPORT_GE_2),// ASF
    .enable_if_master                        (3'b111),//input   [M_IF_COUNT - 1 : 0]
    .enable_if_slave                         (1'b1),//input   [S_IF_COUNT - 1 : 0]
    .address_width_min1                      (axil_address_width_min1),//input   [ADDR_WIDTH_WIDTH - 1 : 0]
    .address_map_bases                       (axil_address_map_bases),//input   [ADDRESS_MAP_WIDTH - 1 : 0]
    .address_map_ranges                      (axil_address_map_ranges),//input   [RANGE_MAP_WIDTH - 1 : 0]
    .address_remap_bases                     (axil_address_remap_bases),//input   [ADDRESS_MAP_WIDTH - 1 : 0]
    .m_address_widths_min1                   (axil_m_address_widths_min1),//input   [ADDRESS_WIDTHS_WIDTH - 1 : 0]
    .s_outstanding_reads_min1                (1'b0),//input   [S_IF_COUNT * OUTSTANDING_WIDTH - 1 : 0]
    .s_outstanding_writes_min1               (1'b0),//input   [S_IF_COUNT * OUTSTANDING_WIDTH - 1 : 0]
    .m_outstanding_reads_min1                ({INTERNAL_AXIL_M_IF_NUMBER{1'b0}}),//input   [M_IF_COUNT * OUTSTANDING_WIDTH - 1 : 0]
    .m_outstanding_writes_min1               ({INTERNAL_AXIL_M_IF_NUMBER{1'b0}}),//input   [M_IF_COUNT * OUTSTANDING_WIDTH - 1 : 0]
    .k_sync_reset                            (k_sync_reset),//input
    .k_sync_cell_stages                      (k_sync_cell_stages),//input

    .s_awready                               (axil_s_awready),//output  [axil_s_IF_COUNT - 1 : 0]
    .s_awvalid                               (axil_s_awvalid),//input   [axil_s_IF_COUNT - 1 : 0]
    .s_awid                                  (1'b0),//input   [axil_s_IF_COUNT * ID_WIDTH - 1 : 0]
    .s_awaddr                                (axil_s_awaddr),//input   [axil_s_IF_COUNT * ADDR_WIDTH - 1 : 0]
    .s_awprot                                (axil_s_awprot),//input   [axil_s_IF_COUNT * PROT_WIDTH - 1 : 0]
    .s_awuser                                (axil_s_awuser),//input   [axil_s_IF_COUNT * AWUSER_WIDTH - 1 : 0]

    .s_awreadychk                            (axil_s_awready_chk),//output  [S_IF_COUNT - 1 : 0]
    .s_awvalidchk                            (axil_s_awvalid_chk),//input   [S_IF_COUNT - 1 : 0]
    .s_awidchk                               (1'b1),//input   [axil_s_IF_COUNT * ID_CHKITY_WIDTH - 1 : 0]
    .s_awaddrchk                             (axil_s_awaddr_chk),//input   [axil_s_IF_COUNT * ADDR_CHKITY_WIDTH - 1 : 0]
    .s_awctlchk0                             (axil_s_awctl_chk0),//input   [S_IF_COUNT - 1 : 0]
    .s_awuserchk                             (axil_s_awuser_chk),//input   [axil_s_IF_COUNT * AWUSER_CHKITY_WIDTH - 1 : 0]

    .s_wready                                (axil_s_wready),//output  [axil_s_IF_COUNT - 1 : 0]
    .s_wvalid                                (axil_s_wvalid),//input   [axil_s_IF_COUNT - 1 : 0]
    .s_wdata                                 (axil_s_wdata),//input   [axil_s_IF_COUNT * DATA_WIDTH - 1 : 0]
    .s_wstrb                                 (axil_s_wstrb),//input   [axil_s_IF_COUNT * STRB_WIDTH - 1 : 0]

    .s_wreadychk                             (axil_s_wready_chk),//output  [S_IF_COUNT - 1 : 0]
    .s_wvalidchk                             (axil_s_wvalid_chk),//input   [S_IF_COUNT - 1 : 0]
    .s_wdatachk                              (axil_s_wdata_chk),//input   [axil_s_IF_COUNT * DATA_CHKITY_WIDTH - 1 : 0]
    .s_wstrbchk                              (axil_s_wstrb_chk),//input   [axil_s_IF_COUNT * STRB_CHKITY_WIDTH - 1 : 0]

    .s_bready                                (axil_s_bready),//input   [axil_s_IF_COUNT - 1 : 0]
    .s_bvalid                                (axil_s_bvalid),//output  [axil_s_IF_COUNT - 1 : 0]
    .s_bid                                   (),//output  [axil_s_IF_COUNT * ID_WIDTH - 1 : 0]
    .s_bresp                                 (axil_s_bresp),//output  [axil_s_IF_COUNT * RESP_WIDTH - 1 : 0]
//    .s_buser                               (axil_s_buser),//output  [axil_s_IF_COUNT * BUSER_WIDTH - 1 : 0]

    .s_breadychk                             (axil_s_bready_chk),//input   [S_IF_COUNT - 1 : 0]
    .s_bvalidchk                             (axil_s_bvalid_chk),//output  [S_IF_COUNT - 1 : 0]
    .s_bidchk                                (),//output  [axil_s_IF_COUNT * ID_CHKITY_WIDTH - 1 : 0]
    .s_brespchk                              (axil_s_bresp_chk),//output  [axil_s_IF_COUNT * RESP_CHKITY_WIDTH - 1 : 0]
//    .s_buserchk                            (axil_s_buser),//output  [axil_s_IF_COUNT * BUSER_CHKITY_WIDTH - 1 : 0]

    .s_arready                               (axil_s_arready),//output  [axil_s_IF_COUNT - 1 : 0]
    .s_arvalid                               (axil_s_arvalid),//input   [axil_s_IF_COUNT - 1 : 0]
    .s_arid                                  (1'b0),//input   [axil_s_IF_COUNT * ID_WIDTH - 1 : 0]
    .s_araddr                                (axil_s_araddr),//input   [axil_s_IF_COUNT * ADDR_WIDTH - 1 : 0]
    .s_arprot                                (axil_s_arprot),//input   [axil_s_IF_COUNT * PROT_WIDTH - 1 : 0]
    .s_aruser                                (axil_s_aruser),//input   [axil_s_IF_COUNT * ARUSER_WIDTH - 1 : 0]

    .s_arreadychk                            (axil_s_arready_chk),//output  [S_IF_COUNT - 1 : 0]
    .s_arvalidchk                            (axil_s_arvalid_chk),//input   [S_IF_COUNT - 1 : 0]
    .s_aridchk                               (1'b1),//input   [axil_s_IF_COUNT * ID_CHKITY_WIDTH - 1 : 0]
    .s_araddrchk                             (axil_s_araddr_chk),//input   [axil_s_IF_COUNT * ADDR_CHKITY_WIDTH - 1 : 0]
   // .s_arprotchk                             (axil_s_arctl_chk0),//input   [axil_s_IF_COUNT * ctl_chk0ITY_WIDTH - 1 : 0]
    .s_arctlchk0                             (axil_s_arctl_chk0),//input   [S_IF_COUNT - 1 : 0]
    .s_aruserchk                             (axil_s_aruser_chk),//input   [axil_s_IF_COUNT * ARUSER_CHKITY_WIDTH - 1 : 0]

    .s_rready                                (axil_s_rready),//input   [axil_s_IF_COUNT - 1 : 0]
    .s_rvalid                                (axil_s_rvalid),//output  [axil_s_IF_COUNT - 1 : 0]
    .s_rid                                   (),//output  [axil_s_IF_COUNT * ID_WIDTH - 1 : 0]
    .s_rdata                                 (axil_s_rdata),//output  [axil_s_IF_COUNT * DATA_WIDTH - 1 : 0]
    .s_rresp                                 (axil_s_rresp),//output  [axil_s_IF_COUNT * RESP_WIDTH - 1 : 0]
//    .s_ruser                               (axil_s_ruser),//output  [axil_s_IF_COUNT * RUSER_WIDTH - 1 : 0]

    .s_rreadychk                             (axil_s_rready_chk),//input   [S_IF_COUNT - 1 : 0]
    .s_rvalidchk                             (axil_s_rvalid_chk),//output  [S_IF_COUNT - 1 : 0]
    .s_ridchk                                (),//output  [axil_s_IF_COUNT * ID_CHKITY_WIDTH - 1 : 0]
    .s_rdatachk                              (axil_s_rdata_chk),//output  [axil_s_IF_COUNT * DATA_CHKITY_WIDTH - 1 : 0]
    .s_rrespchk                              (axil_s_rresp_chk),//output  [axil_s_IF_COUNT * RESP_CHKITY_WIDTH - 1 : 0]
//    .s_ruserchk                            (axil_s_ruser_chk),//output  [axil_s_IF_COUNT * RUSER_CHKITY_WIDTH - 1 : 0]
    // Master Interfaces
    .m_awready                               (internal_axil_m_awready),
    .m_awvalid                               (internal_axil_m_awvalid),//output  [M_IF_COUNT - 1 : 0]
    .m_awid                                  (),//output  [M_IF_COUNT * M_ID_WIDTH - 1 : 0]
    .m_awaddr                                (internal_axil_m_awaddr),//output  [M_IF_COUNT * ADDR_WIDTH - 1 : 0]
    .m_awprot                                (internal_axil_m_awprot),//output  [M_IF_COUNT * PROT_WIDTH - 1 : 0]
    .m_awuser                                (internal_axil_m_awuser),//output  [M_IF_COUNT * AWUSER_WIDTH - 1 : 0]

    .m_awreadychk                            (internal_axil_m_awready_par),//input   [M_IF_COUNT - 1 : 0]
    .m_awvalidchk                            (internal_axil_m_awvalid_par),//output  [M_IF_COUNT - 1 : 0]
    .m_awidchk                               (),//output  [M_IF_COUNT * M_ID_CHKITY_WIDTH - 1 : 0]
    .m_awaddrchk                             (internal_axil_m_awaddr_par),//output  [M_IF_COUNT * ADDR_CHKITY_WIDTH - 1 : 0]
    .m_awctlchk0                             (internal_axil_m_awctl_chk0),//output  [M_IF_COUNT - 1 : 0]
    .m_awuserchk                             (internal_axil_m_awuser_par),//output  [M_IF_COUNT * AWUSER_CHKITY_WIDTH - 1 : 0]

    .m_wready                                (internal_axil_m_wready),//input   [M_IF_COUNT - 1 : 0]
    .m_wvalid                                (internal_axil_m_wvalid),//output  [M_IF_COUNT - 1 : 0]
    .m_wdata                                 (internal_axil_m_wdata),//output  [M_IF_COUNT * DATA_WIDTH - 1 : 0]
    .m_wstrb                                 (internal_axil_m_wstrb),//output  [M_IF_COUNT * STRB_WIDTH - 1 : 0]
   // .m_wuser                               (internal_axil_m_wuser),//output  [M_IF_COUNT * WUSER_WIDTH - 1 : 0]

    .m_wreadychk                             (internal_axil_m_wready_par),//input   [M_IF_COUNT - 1 : 0]
    .m_wvalidchk                             (internal_axil_m_wvalid_par),//output  [M_IF_COUNT - 1 : 0]
    .m_wdatachk                              (internal_axil_m_wdata_par),//output  [M_IF_COUNT * DATA_CHKITY_WIDTH - 1 : 0]
    .m_wstrbchk                              (internal_axil_m_wstrb_par),//output  [M_IF_COUNT * STRB_CHKITY_WIDTH - 1 : 0]
  //  .m_wuserchk                            (internal_axil_m_wuser_par),//output  [M_IF_COUNT * WUSER_CHKITY_WIDTH - 1 : 0]

    .m_bready                                (internal_axil_m_bready),//output  [M_IF_COUNT - 1 : 0]
    .m_bvalid                                (internal_axil_m_bvalid),//input   [M_IF_COUNT - 1 : 0]
    .m_bid                                   ({INTERNAL_AXIL_M_IF_NUMBER{1'b0}}),//input   [M_IF_COUNT * M_ID_WIDTH - 1 : 0]
    .m_bresp                                 (internal_axil_m_bresp),//input   [M_IF_COUNT * RESP_WIDTH - 1 : 0]
  //  .m_buser                               ({axil_m_buser,2'b00}),//input   [M_IF_COUNT * BUSER_WIDTH - 1 : 0]

    .m_breadychk                             (internal_axil_m_bready_par),//output  [M_IF_COUNT - 1 : 0]
    .m_bvalidchk                             (internal_axil_m_bvalid_par),//input   [M_IF_COUNT - 1 : 0]
    .m_bidchk                                ({INTERNAL_AXIL_M_IF_NUMBER{1'b1}}),//input   [M_IF_COUNT * M_ID_CHKITY_WIDTH - 1 : 0]
    .m_brespchk                              (internal_axil_m_bresp_par),//input   [M_IF_COUNT * RESP_CHKITY_WIDTH - 1 : 0]
//    .m_buserchk                            ({axil_m_buser_chk,2'b00}),//input   [M_IF_COUNT * BUSER_CHKITY_WIDTH - 1 : 0]

    .m_arready                               (internal_axil_m_arready),//input   [M_IF_COUNT - 1 : 0]
    .m_arvalid                               (internal_axil_m_arvalid),//output  [M_IF_COUNT - 1 : 0]
    .m_arid                                  (),//output  [M_IF_COUNT * M_ID_WIDTH - 1 : 0]
    .m_araddr                                (internal_axil_m_araddr),//output  [M_IF_COUNT * ADDR_WIDTH - 1 : 0]
    .m_arprot                                (internal_axil_m_arprot),//output  [M_IF_COUNT * PROT_WIDTH - 1 : 0]
    .m_aruser                                (internal_axil_m_aruser),//output  [M_IF_COUNT * ARUSER_WIDTH - 1 : 0]

    .m_arreadychk                            (internal_axil_m_arready_par),//input   [M_IF_COUNT - 1 : 0]
    .m_arvalidchk                            (internal_axil_m_arvalid_par),//output  [M_IF_COUNT - 1 : 0]
    .m_aridchk                               (),//output  [M_IF_COUNT * M_ID_CHKITY_WIDTH - 1 : 0]
    .m_araddrchk                             (internal_axil_m_araddr_par),//output  [M_IF_COUNT * ADDR_CHKITY_WIDTH - 1 : 0]
    .m_arctlchk0                             (internal_axil_m_arctl_chk0),//output  [M_IF_COUNT - 1 : 0]
  //  .m_arprotchk                           (internal_axil_m_arctl_chk0),//output  [M_IF_COUNT * ctl_chk0ITY_WIDTH - 1 : 0]
    .m_aruserchk                             (internal_axil_m_aruser_par),//output  [M_IF_COUNT * ARUSER_CHKITY_WIDTH - 1 : 0]

    .m_rready                                (internal_axil_m_rready),//output  [M_IF_COUNT - 1 : 0]
    .m_rvalid                                (internal_axil_m_rvalid),//input   [M_IF_COUNT - 1 : 0]
    .m_rid                                   ({INTERNAL_AXIL_M_IF_NUMBER{1'b0}}),//input   [M_IF_COUNT * M_ID_WIDTH - 1 : 0]
    .m_rdata                                 (internal_axil_m_rdata),//input   [M_IF_COUNT * DATA_WIDTH - 1 : 0]
    .m_rresp                                 (internal_axil_m_rresp),//input   [M_IF_COUNT * RESP_WIDTH - 1 : 0]
    //.m_rresp                                 ({axil_m_rresp,internal_dti_axil_m_rresp_temp,internal_reg_axil_m_rresp_temp}),//input   [M_IF_COUNT * RESP_WIDTH - 1 : 0]
    //.m_ruser                               (internal_axil_m_ruser),//input   [M_IF_COUNT * RUSER_WIDTH - 1 : 0]
    //.m_ruser                               ({INTERNAL_AXIL_M_IF_NUMBER{1'b0}}),//input   [M_IF_COUNT * RUSER_WIDTH - 1 : 0]

    .m_rreadychk                             (internal_axil_m_rready_par),//output  [M_IF_COUNT - 1 : 0]
    .m_rvalidchk                             (internal_axil_m_rvalid_par),//input   [M_IF_COUNT - 1 : 0]
    .m_ridchk                                ({INTERNAL_AXIL_M_IF_NUMBER{1'b1}}),//input   [M_IF_COUNT * M_ID_CHKITY_WIDTH - 1 : 0]
    .m_rdatachk                              (internal_axil_m_rdata_par),//input   [M_IF_COUNT * DATA_CHKITY_WIDTH - 1 : 0]
    .m_rrespchk                              (internal_axil_m_rresp_par),//input   [M_IF_COUNT * RESP_CHKITY_WIDTH - 1 : 0]
    //.m_rdatachk                              ({axil_m_rdata_chk,internal_dti_axil_m_rdata_par,internal_reg_axil_m_rdata_para}),//input   [M_IF_COUNT * DATA_CHKITY_WIDTH - 1 : 0]
    //.m_rrespchk                              ({axil_m_rresp_chk,internal_dti_axil_m_rresp_par,internal_reg_axil_m_rresp_par}),//input   [M_IF_COUNT * RESP_CHKITY_WIDTH - 1 : 0]

    .s_busy                                  (),
    .m_busy                                  (),
    .check_error                             ()
  );

 localparam TDISP_PRESENT_FOR_REGS   = (TDISP_SUPPORT == 2) ? 1 : 0;
 localparam TDISP_BASE_ADDR_FOR_REGS = 32'h01F0_0000;

  hls_bridge_regs #(
  .TDISP_PRESENT                                    (TDISP_PRESENT_FOR_REGS)
  ,.TDISP_BASE_ADDR                                 (TDISP_BASE_ADDR_FOR_REGS)//01F0_0000
  //,.TDISP_BASE_ADDR                                 ('h01F0_0000) //01F0_0000
  ,.ASF_EI_ADDR_WIDTH                               (27)
  ,.CHECK_TYPE                                      (ASF_SUPPORT_GE_2 ? 2 : 0) //tbd
  ,.ASF_EI_CHECK_TYPE                               (ASF_SUPPORT_GE_2 ? 2 : 0) //tbd
  ,.CSR_ASF_PRESENT                                 (( ASF_SUPPORT_GE_3) ? 1 : 0)  //tbd
  )
  i_cdns_hls_bridge_regs (
  .clock                                             (axil_clk),//input
  .clock_gated                                       (axil_clk),//input
  .resetn                                            (axil_rst_n),//input
  .hard_resetn                                       (axil_rst_n),//input

  // Configuration
  // .enable_check                                      (1'b0),// ASF
  // .enable_ei                                         (1'b0),//input
  // .enable_ei_check                                   (1'b0),//input
  .enable_check                                      (ASF_SUPPORT_GE_2),// ASF
  .enable_ei                                         (ASF_SUPPORT_GE_2),//input
  .enable_ei_check                                   (ASF_SUPPORT_GE_2),//input
  .enable_tdisp                                      (tdisp_enable),
  .enable_tdisp_check                                (1'b0),//input
  .asf_error                                         (),//output

  // AXI5 Lite Interface
  .s_awready                                         (connected_internal_axil_m_awready[0]),//output
  .s_awvalid                                         (internal_axil_m_awvalid[0]),//input
  .s_awid                                            (1'b0),
  .s_awaddr                                          (internal_axil_m_awaddr [AXIL_ADDR_WIDTH_REGS-1:0]),//input   [15 : 0]
  .s_awprot                                          (internal_axil_m_awprot [AXIL_PROT_WIDTH-1:0]),//input   [ 2 : 0]
  .s_awuser                                          (internal_axil_m_awuser [AXIL_WUSER_WIDTH-1:0]),
  .s_awreadychk                                      (connected_internal_axil_m_awready_par[0]),  // todo
  .s_awvalidchk                                      (internal_axil_m_awvalid_par[0]),
  .s_awidchk                                         (1'b1),
  .s_awaddrchk                                       (internal_axil_m_awaddr_par [AXIL_ADDR_WIDTH_REGS/8-1:0]),
  .s_awctlchk0                                       (internal_axil_m_awctl_chk0[0]),
  .s_awuserchk                                       (internal_axil_m_awuser_par [AXIL_WUSER_WIDTH_CHK-1:0]),

  .s_wready                                          (connected_internal_axil_m_wready[0]),//output
  .s_wvalid                                          (internal_axil_m_wvalid[0]),//input
  .s_wdata                                           (internal_axil_m_wdata[AXIL_DATA_WIDTH-1:0]),//input   [31 : 0]
  .s_wstrb                                           (internal_axil_m_wstrb[AXIL_STRB_WIDTH-1:0]),//input   [ 3 : 0]

  .s_wreadychk                                       (connected_internal_axil_m_wready_par[0]),
  .s_wvalidchk                                       (internal_axil_m_wvalid_par[0]),//todo
  .s_wdatachk                                        (internal_axil_m_wdata_par[AXIL_DATA_WIDTH_CHK-1:0]), // todo after ic update: (internal_axil_m_wdata_par[AXIL_DATA_WIDTH_CHK-1:0]),
  .s_wstrbchk                                        (internal_axil_m_wstrb_par[AXIL_STRB_WIDTH_CHK-1:0]), // todo after ic update: (internal_axil_m_wstrb_par[0]),

  .s_bready                                          (internal_axil_m_bready[0]),//input
  .s_bvalid                                          (connected_internal_axil_m_bvalid[0]),//output
  .s_bid                                             (), // todo
  .s_bresp                                           (connected_internal_axil_m_bresp[AXIL_RESP_WIDTH-1:0]),//output  [ 1 : 0]
  .s_breadychk                                       (internal_axil_m_bready_par[0]),
  .s_bvalidchk                                       (connected_internal_axil_m_bvalid_par[0]),
  .s_bidchk                                          (), // todo
  .s_brespchk                                        (connected_internal_axil_m_bresp_par[AXIL_RESP_WIDTH_CHK-1:0]),

  .s_arready                                         (connected_internal_axil_m_arready[0]),//output
  .s_arvalid                                         (internal_axil_m_arvalid[0]),//input
  .s_arid                                            (1'b0),
  .s_araddr                                          (internal_axil_m_araddr [AXIL_ADDR_WIDTH_REGS-1:0]),//input   [15 : 0]
  .s_arprot                                          (internal_axil_m_arprot [AXIL_PROT_WIDTH-1:0]),//input   [ 2 : 0]
  .s_aruser                                          (internal_axil_m_aruser [AXIL_WUSER_WIDTH-1:0]),

  .s_arreadychk                                      (connected_internal_axil_m_arready_par[0]),
  .s_arvalidchk                                      (internal_axil_m_arvalid_par[0]),//todo
  .s_aridchk                                         (1'b1),
  //.s_araddrchk                                       ({~^internal_axil_m_araddr[15:8],~^internal_axil_m_araddr[7:0]}), // todo after ic update: (internal_axil_m_araddr_par[AXIL_ADDR_WIDTH_REGS/8-1:0]),
  //.s_arctlchk0                                       (1'b1),
  .s_araddrchk                                       (internal_axil_m_araddr_par[AXIL_ADDR_WIDTH_REGS/8-1:0]),
  .s_arctlchk0                                       (internal_axil_m_arctl_chk0[0]),

  .s_aruserchk                                       (internal_axil_m_aruser_par [AXIL_WUSER_WIDTH_CHK-1:0]),
  .s_rready                                          (internal_axil_m_rready[0]),//input
  .s_rvalid                                          (connected_internal_axil_m_rvalid[0]),//output
  .s_rid                                             (),
  .s_rdata                                           (connected_internal_axil_m_rdata[AXIL_DATA_WIDTH-1:0]),//output  [31 : 0]
  .s_rresp                                           (connected_internal_axil_m_rresp[AXIL_RESP_WIDTH-1:0]),//output  [ 1 : 0]

  .s_rreadychk                                       (internal_axil_m_rready_par[0]),
  .s_rvalidchk                                       (connected_internal_axil_m_rvalid_par[0]),
  .s_ridchk                                          (),
  .s_rdatachk                                        (connected_internal_axil_m_rdata_par[AXIL_DATA_WIDTH_CHK-1:0]),
  .s_rrespchk                                        (connected_internal_axil_m_rresp_par[AXIL_RESP_WIDTH_CHK-1:0]),

  //ASF
  .asf_csr_notify_ready                              (asf_csr_notify_ready),//input
  .asf_csr_notify_valid                              (asf_csr_notify_valid),//output
  .asf_csr_notify_addr                               (asf_csr_notify_addr),//output  [ADDR_WIDTH - 1 : 0]

  .asf_csr_notify_readychk                           (asf_csr_notify_readychk),//input
  .asf_csr_notify_validchk                           (asf_csr_notify_validchk),//output
  .asf_csr_notify_addrchk                            (asf_csr_notify_addrchk),//output  [ADDRCHK_WIDTH - 1 : 0]

  .asf_csr_injection_valid                           (asf_csr_injection_valid),//input
  .asf_csr_injection_addr                            (asf_csr_injection_addr),//input   [ASF_EI_ADDR_WIDTH - 1 : 0]
  .asf_csr_injection_index                           (asf_csr_injection_index),//input   [ASF_EI_INDEX_WIDTH - 1 : 0]

  .asf_csr_injection_validchk                        (asf_csr_injection_validchk),//input
  .asf_csr_injection_addrchk                         (asf_csr_injection_addrchk),//input   [ASF_EI_ADDRCHK_WIDTH - 1 : 0]
  .asf_csr_injection_indexchk                        (asf_csr_injection_indexchk),//input   [ASF_EI_INDEXCHK_WIDTH - 1 : 0]

  .tdisp_index                                       (16'd0),
  .tdisp_origin                                      (2'b00),// Common

  .tdisp_req_valid                                   (tdisp_req_valid),
  .tdisp_req_read                                    (tdisp_req_read),
  .tdisp_req_addr                                    (tdisp_req_register_address),
  .tdisp_req_field                                   (tdisp_req_field_address),
  .tdisp_req_value                                   (tdisp_req_value),

  // ASF
  .tdisp_req_validchk                                (tdisp_req_validchk),
  .tdisp_req_readchk                                 (tdisp_req_readchk),
  .tdisp_req_addrchk                                 (tdisp_req_addrchk),
  .tdisp_req_fieldchk                                (tdisp_req_fieldchk),
  .tdisp_req_valuechk                                (tdisp_req_valuechk),

  .tdisp_read_valid                                  (hls_bridge_tdisp_read_valid),
  .tdisp_read_addr                                   (hls_bridge_tdisp_read_register_address),
  .tdisp_read_field                                  (hls_bridge_tdisp_read_field_address),
  .tdisp_read_value                                  (hls_bridge_tdisp_read_value),
  // ASF
  .tdisp_read_validchk                               (hls_bridge_tdisp_read_validchk),
  .tdisp_read_addrchk                                (hls_bridge_tdisp_read_addrchk),
  .tdisp_read_fieldchk                               (hls_bridge_tdisp_read_fieldchk),
  .tdisp_read_valuechk                               (hls_bridge_tdisp_read_valuechk),

  .tdisp_notify_valid                                (hls_bridge_tdisp_notify_valid),
  .tdisp_notify_addr                                 (hls_bridge_tdisp_notify_register_address),
  .tdisp_notify_field                                (hls_bridge_tdisp_notify_field_address),
  .tdisp_notify_value                                (hls_bridge_tdisp_notify_value),
  .tdisp_notify_origin                               (hls_bridge_tdisp_notify_origin),
  .tdisp_notify_index                                (hls_bridge_tdisp_notify_index),

  //ASF
  .tdisp_notify_validchk                             (hls_bridge_tdisp_notify_validchk),
  .tdisp_notify_addrchk                              (hls_bridge_tdisp_notify_addrchk),
  .tdisp_notify_fieldchk                             (hls_bridge_tdisp_notify_fieldchk),
  .tdisp_notify_valuechk                             (hls_bridge_tdisp_notify_valuechk),
  .tdisp_notify_originchk                            (hls_bridge_tdisp_notify_originchk),
  .tdisp_notify_indexchk                             (hls_bridge_tdisp_notify_indexchk),

  // hls_bridge_cfg Register
  .hls_bridge_cfg_idg_en_o                                           (hls_bridge_cfg_idg_en_o                                          ),
  .hls_bridge_cfg_tc_en_o                                            (hls_bridge_cfg_tc_en_o                                           ),
  .hls_bridge_cfg_vc_en_o                                            (hls_bridge_cfg_vc_en_o                                           ),
  .hls_bridge_cfg_tfc_en_o                                           (hls_bridge_cfg_tfc_en_o                                          ),
  .hls_bridge_cfg_addr_window_en_o                                   (hls_bridge_cfg_addr_window_en_o                                  ),
  .hls_bridge_cfg_tfc_ro_chk_en_o                                    (hls_bridge_cfg_tfc_ro_chk_en_o                                   ),
  .hls_bridge_cfg_axi_force_en_o                                     (hls_bridge_cfg_axi_force_en_o                                    ),

  // hls_bridge_tlp_start_addr_lower Register
  .hls_bridge_tlp_start_addr_lower_hls_bridge_tlp_start_addr_lower_o (hls_bridge_tlp_start_addr_lower_hls_bridge_tlp_start_addr_lower_o),

  // hls_bridge_tlp_start_addr_upper Register
  .hls_bridge_tlp_start_addr_upper_hls_bridge_tlp_start_addr_upper_o (hls_bridge_tlp_start_addr_upper_hls_bridge_tlp_start_addr_upper_o),

  // hls_bridge_tlp_end_addr_lower Register
  .hls_bridge_tlp_end_addr_lower_hls_bridge_tlp_end_addr_lower_o     (hls_bridge_tlp_end_addr_lower_hls_bridge_tlp_end_addr_lower_o    ),

  // hls_bridge_tlp_end_addr_upper Register
  .hls_bridge_tlp_end_addr_upper_hls_bridge_tlp_end_addr_upper_o     (hls_bridge_tlp_end_addr_upper_hls_bridge_tlp_end_addr_upper_o    ),

  // hls_bridge_idg_port_map_1 Register
  .hls_bridge_idg_port_map_1_idg0_port1_en_o                         (hls_bridge_idg_port_map_1_idg0_port1_en_o                        ),
  .hls_bridge_idg_port_map_1_idg1_port1_en_o                         (hls_bridge_idg_port_map_1_idg1_port1_en_o                        ),
  .hls_bridge_idg_port_map_1_idg2_port1_en_o                         (hls_bridge_idg_port_map_1_idg2_port1_en_o                        ),
  .hls_bridge_idg_port_map_1_idg3_port1_en_o                         (hls_bridge_idg_port_map_1_idg3_port1_en_o                        ),
  .hls_bridge_idg_port_map_1_idg4_port1_en_o                         (hls_bridge_idg_port_map_1_idg4_port1_en_o                        ),
  .hls_bridge_idg_port_map_1_idg5_port1_en_o                         (hls_bridge_idg_port_map_1_idg5_port1_en_o                        ),
  .hls_bridge_idg_port_map_1_idg6_port1_en_o                         (hls_bridge_idg_port_map_1_idg6_port1_en_o                        ),
  .hls_bridge_idg_port_map_1_idg7_port1_en_o                         (hls_bridge_idg_port_map_1_idg7_port1_en_o                        ),

  // hls_bridge_tc_vc_port_map_1 Register
  .hls_bridge_tc_vc_port_map_1_tc0_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_tc0_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_tc1_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_tc1_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_tc2_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_tc2_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_tc3_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_tc3_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_tc4_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_tc4_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_tc5_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_tc5_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_tc6_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_tc6_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_tc7_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_tc7_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_vc0_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_vc0_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_vc1_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_vc1_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_vc2_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_vc2_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_vc3_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_vc3_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_vc4_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_vc4_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_vc5_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_vc5_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_vc6_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_vc6_axi_port1_en_o                   ),
  .hls_bridge_tc_vc_port_map_1_vc7_axi_port1_en_o                    (hls_bridge_tc_vc_port_map_1_vc7_axi_port1_en_o                   ),

  // hls_bridge_tf_port_map_value Register
  .hls_bridge_tf_port_map_value_hls_bridge_tf_port_map_value_o       (hls_bridge_tf_port_map_value_hls_bridge_tf_port_map_value_o      ),

  // hls_bridge_tf_port_map_mask Register
  .hls_bridge_tf_port_map_mask_hls_bridge_tf_port_map_mask_o         (hls_bridge_tf_port_map_mask_hls_bridge_tf_port_map_mask_o        ),

  // hls_bridge_msi_gic_cfg Register
  .hls_bridge_msi_gic_cfg_hls_bridge_msi_gic_use_seg_o               (hls_bridge_msi_gic_cfg_hls_bridge_msi_gic_use_seg_o              ),

  // hls_bridge_dbg_order Register
  .hls_bridge_dbg_order_dbg_dis_o_chk_dti_o                          (hls_bridge_dbg_order_dbg_dis_o_chk_dti_o                         ),
  .hls_bridge_dbg_order_dbg_dis_o_chk_msi_o                          (hls_bridge_dbg_order_dbg_dis_o_chk_msi_o                         ),
  .hls_bridge_dbg_order_dbg_dis_per_port_o_chk_o                     (hls_bridge_dbg_order_dbg_dis_per_port_o_chk_o                    ),

  // hls_bridge_axi_ib_p_pck_count Register
  .hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i_capture               (hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i_capture              ),
  .hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i                       (hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i                      ),
  .hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_o                       (hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_o                      ),

  // hls_bridge_axi_ib_np_pck_count Register
  .hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i_capture              (hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i_capture             ),
  .hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i                      (hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i                     ),
  .hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_o                      (hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_o                     ),

  // hls_bridge_axi_ib_c_pck_count Register
  .hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i_capture               (hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i_capture              ),
  .hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i                       (hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i                      ),
  .hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_o                       (hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_o                      ),

  // hls_bridge_axi_ob_p_pck_count Register
  .hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i_capture               (hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i_capture              ),
  .hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i                       (hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i                      ),
  .hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_o                       (hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_o                      ),

  // hls_bridge_axi_ob_np_pck_count Register
  .hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i_capture              (hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i_capture             ),
  .hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i                      (hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i                     ),
  .hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_o                      (hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_o                     ),

  // hls_bridge_axi_ob_c_pck_count Register
  .hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i_capture               (hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i_capture              ),
  .hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i                       (hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i                      ),
  .hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_o                       (hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_o                      ),

  // hls_bridge_msi_ib_p_pck_count Register
  .hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i_capture               (hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i_capture              ),
  .hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i                       (hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i                      ),
  .hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_o                       (hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_o                      ),

  // hls_bridge_dti_ib_p_pck_count Register
  .hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i_capture               (hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i_capture              ),
  .hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i                       (hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i                      ),
  .hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_o                       (hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_o                      ),

  // hls_bridge_dti_ib_np_pck_count Register
  .hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i_capture              (hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i_capture             ),
  .hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i                      (hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i                     ),
  .hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_o                      (hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_o                     ),

  // hls_bridge_dti_ob_c_pck_count Register
  .hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i_capture               (hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i_capture              ),
  .hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i                       (hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i                      ),
  .hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_o                       (hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_o                      ),

  // hls_bridge_dti_ob_p_pck_count Register
  .hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i_capture               (hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i_capture              ),
  .hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i                       (hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i                      ),
  .hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_o                       (hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_o                      )
  );

  hls_bridge_credit
  #(
  .KMAX_NUM_VCS                                           (KMAX_NUM_VCS),
  .KMAX_CRD_HEADER_WIDTH                                (CRD_IN_LMT_HEADER_WIDTH),
  .KMAX_CRD_PAYLOAD_WIDTH                               (CRD_IN_LMT_PAYLOAD_WIDTH),
  .KMAX_CRD_CNTL_WIDTH                                  (CRD_IN_LMT_CNTL_WIDTH)
  )
  i_cdns_hls_bridge_credit
  (
   .core_clk                                     (core_clk),
   .core_rst_n                                   (core_rst_n),
   .link_down_handling_in_progress                      (link_down_handling_in_progress),

   .crd_tx_lmt_posted_header                            (crd_m_lmt_posted_header    ),
   .crd_tx_lmt_posted_payload                           (crd_m_lmt_posted_payload   ),
   .crd_tx_lmt_posted_cntl                              (crd_m_lmt_posted_cntl      ),
   .crd_tx_lmt_nonposted_header                         (crd_m_lmt_nonposted_header ),
   .crd_tx_lmt_nonposted_payload                        (crd_m_lmt_nonposted_payload),
   .crd_tx_lmt_nonposted_cntl                           (crd_m_lmt_nonposted_cntl   ),
   .crd_rx_lmt_nonposted_header                         (crd_s_lmt_nonposted_header ),

   .crd_rx_lmt_nonposted_payload                        (crd_s_lmt_nonposted_payload),
   .crd_rx_lmt_nonposted_cntl                           (crd_s_lmt_nonposted_cntl   ),
   .crd_rx_lmt_posted_header                            (crd_s_lmt_posted_header    ),
   .crd_rx_lmt_posted_payload                           (crd_s_lmt_posted_payload   ),
   .crd_rx_lmt_posted_cntl                              (crd_s_lmt_posted_cntl      ),
   .crd_rx_dti_posted_header                            (crd_dti_lmt_posted_header ),
   .crd_rx_dti_posted_payload                           (crd_dti_lmt_posted_payload)
   //.crd_rx_dti_posted_header                            ({KMAX_NUM_VCS*CRD_IN_LMT_HEADER_WIDTH{1'b0}}),//input
   //.crd_rx_dti_posted_payload                           ({KMAX_NUM_VCS*CRD_IN_LMT_PAYLOAD_WIDTH{1'b0}})//input
  );


  hls_bridge_delivered
  #(
   .KMAX_DATAPATH_WD                       (KMAX_DATAPATH_WD),
   .NUM_HLS_PORTS                          (NUM_HLS_PORTS),
   .NUM_TLP_STREAMS                        (NUM_TLP_STREAMS),
   .KMAX_NUM_TLPS_PER_CLK                  (KMAX_NUM_TLPS_PER_CLK),
   .DC_TDATA_WIDTH                         (DC_TDATA_WIDTH),
   .LBB_SUPPORT                            (LBB_SUPPORT),
   .KMAX_DTI_SUPPORT                       (KMAX_DTI_SUPPORT),
   .KMAX_MSI_IF_SUPPORT                    (KMAX_MSI_IF_SUPPORT),
   .METADATA_IDG_WD                        (METADATA_IDG_WD),
   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   .ASF_SUPPORT                            (ASF_SUPPORT),
   .ASF_NODE_ID_BASE                       (ASF_NODE_ID_BASE),
   .ASF_ERR_INJ_SUPPORT                    (ASF_ERR_INJ_SUPPORT),
   .ASF_ERROR_INJ_DATA_WIDTH               (ASF_ERROR_INJ_DATA_WIDTH),
   .ASF_ERROR_INJ_USER_WIDTH               (ASF_ERROR_INJ_USER_WIDTH),
   .ASF_EVENT_TYPE_WIDTH                   (ASF_EVENT_TYPE_WIDTH),
   .ASF_EVENT_COUNT_WIDTH                  (ASF_EVENT_COUNT_WIDTH),
   .ASF_NODE_ID_WIDTH                      (ASF_NODE_ID_WIDTH),
   .ASF_EVENT_DIAG_FIELD_WIDTH             (ASF_EVENT_DIAG_FIELD_WIDTH)
  )
  i_cdns_hls_bridge_delivered
  (
   .core_clk                        (core_clk),
   .core_rst_n                      (core_rst_n),

   .i_tlp_route_to_axi                     (sb_tlp_route_to_axi),
   .i_tlp_route_to_msi                     (sb_tlp_route_to_msi),
   .i_tlp_route_to_dti                     (sb_tlp_route_to_dti),
   .i_tlp_stream_packed                    (sb_tlp_stream_packed),

   .sb_tx_axi_queue_empty                  (sb_ib_p_axi_queue_empty),
   .sb_tx_msi_queue_empty                  (sb_ib_p_msi_queue_empty),
   .sb_tx_dti_queue_empty                  (sb_ib_p_dti_queue_empty),

   .sb_tx_axi_stream_empty                 (sb_ib_p_axi_stream_empty),
   .sb_tx_dti_stream_empty                 (sb_ib_p_dti_stream_empty),
   .sb_tx_msi_stream_empty                 (sb_ib_p_msi_stream_empty),

   .dc_rx_tvalid                           (dc_s_tvalid    ),
   .dc_rx_tdata                            (dc_s_tdata     ),
   .dc_rx_tvalid_chk                       (dc_s_tvalid_chk),
   .dc_rx_tdata_chk                        (dc_s_tdata_chk ),

   //todo  --- full asf path from MSI
   .dc_rx_msi_tvalid                       (dc_tx_msi_valid),
   .dc_rx_msi_tdata                        (dc_tx_msi_data),
   //todo  --- full asf path from MSI
   .dc_rx_msi_tvalid_chk                   (dc_tx_msi_valid_chk),
   .dc_rx_msi_tdata_chk                    (dc_tx_msi_data_chk),

   .dc_rx_dti_tvalid                       (dc_dti_tvalid),//input
   .dc_rx_dti_tdata                        (dc_dti_tdata),//input
   //.dc_rx_dti_tvalid_chk                   (1'b1),//input
   .dc_rx_dti_tvalid_chk                   (dc_dti_tvalid_chk),//input
   .dc_rx_dti_tdata_chk                    (dc_dti_tdata_chk),//input

   .dc_tx_tvalid                           (dc_m_tvalid    ),
   .dc_tx_tdata                            (dc_m_tdata     ),
   .dc_tx_tvalid_chk                       (dc_m_tvalid_chk),
   .dc_tx_tdata_chk                        (dc_m_tdata_chk ),



   //---------------------------------------------------------------------------------
   // ASF err inj
   //---------------------------------------------------------------------------------
   .asf_error_inj__cmd_tvalid_i            (sub_block_error_inj__cmd_tvalid), // input
   .asf_error_inj__tdata_i                 (sub_block_error_inj__tdata),      // input [55:0]
   .asf_error_inj__tuser_i                 (sub_block_error_inj__tuser),      // input [7:0]

   .asf_event__valid_dc_tvalid             (asf_event__valid_dc_m_tvalid),
   .asf_event__type_dc_tvalid              (asf_event__type_dc_m_tvalid),
   .asf_event__count_dc_tvalid             (asf_event__count_dc_m_tvalid),
   .asf_event__node_id_dc_tvalid           (asf_event__node_id_dc_m_tvalid),
   .asf_event__diag_field_dc_tvalid        (asf_event__diag_field_dc_m_tvalid),

   .asf_event__valid_dc_tdata              (asf_event__valid_dc_m_tdata),
   .asf_event__type_dc_tdata               (asf_event__type_dc_m_tdata),
   .asf_event__count_dc_tdata              (asf_event__count_dc_m_tdata),
   .asf_event__node_id_dc_tdata            (asf_event__node_id_dc_m_tdata),
   .asf_event__diag_field_dc_tdata         (asf_event__diag_field_dc_m_tdata)
  );


  generate
  if (LBB_SUPPORT) begin : g_hls_bridge_qos
   hls_bridge_qos #(
     .NUM_HLS_PORTS                 (NUM_HLS_PORTS),
     .KMAX_MSI_IF_SUPPORT           (KMAX_MSI_IF_SUPPORT),
     .KMAX_DTI_SUPPORT              (KMAX_DTI_SUPPORT),
     .NUM_TLP_STREAMS               (NUM_TLP_STREAMS),
     .TLP_QOS_TDATA_WIDTH           (TLP_QOS_TDATA_WIDTH),
     .TLP_QOS_TDATA_CHK_WIDTH       (TLP_QOS_TDATA_CHK_WIDTH),
     .MSI_QOS_DATA_WIDTH            (MSI_QOS_DATA_WIDTH),
   //------------------------------------------------------------------------------
   //ASF
   //------------------------------------------------------------------------------
    .ASF_SUPPORT                            (ASF_SUPPORT),
    .ASF_NODE_ID_BASE                       (ASF_NODE_ID_BASE),
    .ASF_ERR_INJ_SUPPORT                    (ASF_ERR_INJ_SUPPORT),
    .ASF_ERROR_INJ_DATA_WIDTH               (ASF_ERROR_INJ_DATA_WIDTH),
    .ASF_ERROR_INJ_USER_WIDTH               (ASF_ERROR_INJ_USER_WIDTH),
    .ASF_EVENT_TYPE_WIDTH                   (ASF_EVENT_TYPE_WIDTH),
    .ASF_EVENT_COUNT_WIDTH                  (ASF_EVENT_COUNT_WIDTH),
    .ASF_NODE_ID_WIDTH                      (ASF_NODE_ID_WIDTH),
    .ASF_EVENT_DIAG_FIELD_WIDTH             (ASF_EVENT_DIAG_FIELD_WIDTH)
   )u_hls_bridge_qos (
     .core_clk                                 (core_clk),//input
     .core_rst_n                               (core_rst_n),//input

     .axi_qos_rx_tvalid                        (tlp_qos_rx_tvalid),//input wire [NUM_HLS_PORTS-1:0]
     .axi_qos_rx_tdata                         (tlp_qos_rx_tdata),//input wire [NUM_HLS_PORTS*TLP_QOS_TDATA_WIDTH-1:0]
     .axi_qos_rx_tvalid_chk                    (tlp_qos_rx_tvalid_chk),//input wire [NUM_HLS_PORTS-1:0]
     .axi_qos_rx_tdata_chk                     (tlp_qos_rx_tdata_chk),//input wire [NUM_HLS_PORTS*TLP_QOS_TDATA_CHK_WIDTH-1:0]

     .dti_qos_rx_tvalid                        (1'b0),
     .dti_qos_rx_tdata                         ({TLP_QOS_TDATA_WIDTH{1'b0}}),
     .dti_qos_rx_tvalid_chk                    (1'b0),
     .dti_qos_rx_tdata_chk                     ({TLP_QOS_TDATA_CHK_WIDTH{1'b1}}),

     .msi_qos_rx_data                          (qos_tx_msi_data),//output wire
     .msi_qos_rx_valid                         (qos_tx_msi_valid),//output wire
     .msi_qos_rx_data_chk                      (qos_tx_msi_data_chk),//output wire
     .msi_qos_rx_valid_chk                     (qos_tx_msi_valid_chk),//output wire

     .tlp_qos_tx_tvalid                        (tlp_qos_tx_tvalid),//output wire
     .tlp_qos_tx_tdata                         (tlp_qos_tx_tdata),//output wire [TLP_QOS_TDATA_WIDTH-1:0]
     .tlp_qos_tx_tvalid_chk                    (tlp_qos_tx_tvalid_chk),//output wire
     .tlp_qos_tx_tdata_chk                     (tlp_qos_tx_tdata_chk),//output wire [TLP_QOS_TDATA_CHK_WIDTH-1:0]

     .asf_error_inj__cmd_tvalid_i              (sub_block_error_inj__cmd_tvalid),         //input
     .asf_error_inj__tdata_i                   (sub_block_error_inj__tdata),              //input [ASF_ERROR_INJ_DATA_WIDTH-1:0]
     .asf_error_inj__tuser_i                   (sub_block_error_inj__tuser),              //input [ASF_ERROR_INJ_USER_WIDTH-1:0]
     .asf_event__valid_qos_tvalid              (asf_event__valid_qos_tvalid),             //output [DC_ASF_EVENT_VALID_WIDTH-1:0]
     .asf_event__type_qos_tvalid               (asf_event__type_qos_tvalid),              //output [DC_ASF_EVENT_TYPE_WIDTH-1:0]
     .asf_event__count_qos_tvalid              (asf_event__count_qos_tvalid),             //output [DC_ASF_EVENT_COUNT_WIDTH-1:0]
     .asf_event__node_id_qos_tvalid            (asf_event__node_id_qos_tvalid),           //output [DC_ASF_NODE_ID_WIDTH-1:0]
     .asf_event__diag_field_qos_tvalid         (asf_event__diag_field_qos_tvalid),        //output [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]
     .asf_event__valid_qos_tdata               (asf_event__valid_qos_tdata),              //output [DC_ASF_EVENT_VALID_WIDTH-1:0]
     .asf_event__type_qos_tdata                (asf_event__type_qos_tdata),               //output [DC_ASF_EVENT_TYPE_WIDTH-1:0]
     .asf_event__count_qos_tdata               (asf_event__count_qos_tdata),              //output [DC_ASF_EVENT_COUNT_WIDTH-1:0]
     .asf_event__node_id_qos_tdata             (asf_event__node_id_qos_tdata),            //output [DC_ASF_NODE_ID_WIDTH-1:0]
     .asf_event__diag_field_qos_tdata          (asf_event__diag_field_qos_tdata)          //output [DC_ASF_EVENT_DIAG_FIELD_WIDTH-1:0]
    );
  end // LBB_SUPPORT
  else begin : g_no_hls_bridge_qos
    assign tlp_qos_tx_tdata                  = {TLP_QOS_TDATA_WIDTH{1'b0}};
    assign tlp_qos_tx_tdata_chk              = {TLP_QOS_TDATA_CHK_WIDTH{1'b1}};
    assign tlp_qos_tx_tvalid                 = 1'b0;
    assign tlp_qos_tx_tvalid_chk             = 1'b1;
    assign asf_event__valid_qos_tvalid       = {QOS_ASF_EVENT_VALID_WIDTH{1'b0}};
    assign asf_event__type_qos_tvalid        = {QOS_ASF_EVENT_TYPE_WIDTH{1'b0}};
    assign asf_event__count_qos_tvalid       = {QOS_ASF_EVENT_COUNT_WIDTH{1'b0}};
    assign asf_event__node_id_qos_tvalid     = {QOS_ASF_NODE_ID_WIDTH{1'b0}};
    assign asf_event__diag_field_qos_tvalid  = {QOS_ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
    assign asf_event__valid_qos_tdata        = {QOS_ASF_EVENT_VALID_WIDTH{1'b0}};
    assign asf_event__type_qos_tdata         = {QOS_ASF_EVENT_TYPE_WIDTH{1'b0}};
    assign asf_event__count_qos_tdata        = {QOS_ASF_EVENT_COUNT_WIDTH{1'b0}};
    assign asf_event__node_id_qos_tdata      = {QOS_ASF_NODE_ID_WIDTH{1'b0}};
    assign asf_event__diag_field_qos_tdata   = {QOS_ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
  end
  endgenerate



  generate
    if (LTI_SUPPORT == 1) begin : i_cdns_hls_bridge_ctag_gen
    hls_bridge_ctag #(
      .NUM_HLS_PORTS                      (NUM_HLS_PORTS),
      .KMAX_MSI_IF_SUPPORT                (KMAX_MSI_IF_SUPPORT),
      .NUM_LTI_PORTS                      (NUM_LTI_PORTS),
      .MSI_LTIC_DATA_WIDTH                (MSI_LTIC_DATA_WIDTH),
      //---------------------------------------------------------------------------------
      // ASF err inj
      //---------------------------------------------------------------------------------
      .ASF_SUPPORT                        (ASF_SUPPORT),
      .ASF_NODE_ID_BASE                   (ASF_NODE_ID_BASE),
      .ASF_ERR_INJ_SUPPORT                (ASF_ERR_INJ_SUPPORT),
      .ASF_ERROR_INJ_DATA_WIDTH           (ASF_ERROR_INJ_DATA_WIDTH),
      .ASF_ERROR_INJ_USER_WIDTH           (ASF_ERROR_INJ_USER_WIDTH),
      .ASF_EVENT_TYPE_WIDTH               (ASF_EVENT_TYPE_WIDTH),
      .ASF_EVENT_COUNT_WIDTH              (ASF_EVENT_COUNT_WIDTH),
      .ASF_NODE_ID_WIDTH                  (ASF_NODE_ID_WIDTH),
      .ASF_EVENT_DIAG_FIELD_WIDTH         (ASF_EVENT_DIAG_FIELD_WIDTH)
    ) i_cdns_hsl_bridge_ctag (
      .core_clk                    (core_clk),
      .core_rst_n                  (core_rst_n),

      .lti_c_rx_msi_data                  (ltic_tx_msi_data),//input wire
      .lti_c_rx_msi_valid                 (ltic_tx_msi_valid),//input wire
      .lti_c_rx_msi_data_chk              (ltic_tx_msi_data_chk),//input wire
      .lti_c_rx_msi_valid_chk             (ltic_tx_msi_valid_chk),//input wire

      .lti_c_rx_tvalid                    (lti_c_rx_tvalid),//input [NUM_HLS_PORTS-1:0]
      .lti_c_rx_tdata                     (lti_c_rx_tdata),//input [NUM_HLS_PORTS*11-1:0]
      .lti_c_rx_tvalid_chk                (lti_c_rx_tvalid_chk),//input [NUM_HLS_PORTS-1:0]
      .lti_c_rx_tdata_chk                 (lti_c_rx_tdata_chk),//input [NUM_HLS_PORTS*2-1:0]

      .lti_c_tx_tvalid                    (lti_c_tx_tvalid),//output [NUM_HLS_PORTS-1:0]
      .lti_c_tx_tdata                     (lti_c_tx_tdata),//output [NUM_HLS_PORTS*11-1:0]
      .lti_c_tx_tvalid_chk                (lti_c_tx_tvalid_chk),//output [NUM_HLS_PORTS-1:0]
      .lti_c_tx_tdata_chk                 (lti_c_tx_tdata_chk),//output [NUM_HLS_PORTS*2-1:0]
      //---------------------------------------------------------------------------------
      // ASF err inj
      //---------------------------------------------------------------------------------
      .asf_error_inj__cmd_tvalid_i            (sub_block_error_inj__cmd_tvalid), // input
      .asf_error_inj__tdata_i                 (sub_block_error_inj__tdata),      // input [55:0]
      .asf_error_inj__tuser_i                 (sub_block_error_inj__tuser),      // input [7:0]

      .asf_event__valid_lti_c_tvalid          (asf_event__valid_lti_c_tx_tvalid),
      .asf_event__type_lti_c_tvalid           (asf_event__type_lti_c_tx_tvalid),
      .asf_event__count_lti_c_tvalid          (asf_event__count_lti_c_tx_tvalid),
      .asf_event__node_id_lti_c_tvalid        (asf_event__node_id_lti_c_tx_tvalid),
      .asf_event__diag_field_lti_c_tvalid     (asf_event__diag_field_lti_c_tx_tvalid),

      .asf_event__valid_lti_c_tdata           (asf_event__valid_lti_c_tx_tdata),
      .asf_event__type_lti_c_tdata            (asf_event__type_lti_c_tx_tdata),
      .asf_event__count_lti_c_tdata           (asf_event__count_lti_c_tx_tdata),
      .asf_event__node_id_lti_c_tdata         (asf_event__node_id_lti_c_tx_tdata),
      .asf_event__diag_field_lti_c_tdata      (asf_event__diag_field_lti_c_tx_tdata)
    );
    end
    else begin : no_lti_support
      assign lti_c_tx_tvalid     = 1'b0;
      assign lti_c_tx_tdata      = {LTI_C_TDATA_WIDTH{1'b0}};
      assign lti_c_tx_tvalid_chk = 1'b1;
      assign lti_c_tx_tdata_chk  = {LTI_C_TDATA_CHK_WIDTH{1'b1}};

      assign asf_event__valid_lti_c_tx_tvalid      = {CTAG_ASF_EVENT_VALID_WIDTH{1'b0}};
      assign asf_event__type_lti_c_tx_tvalid       = {CTAG_ASF_EVENT_TYPE_WIDTH{1'b0}};
      assign asf_event__count_lti_c_tx_tvalid      = {CTAG_ASF_EVENT_COUNT_WIDTH{1'b0}};
      assign asf_event__node_id_lti_c_tx_tvalid    = {CTAG_ASF_NODE_ID_WIDTH{1'b0}};
      assign asf_event__diag_field_lti_c_tx_tvalid = {CTAG_ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
      assign asf_event__valid_lti_c_tx_tdata      = {CTAG_ASF_EVENT_VALID_WIDTH{1'b0}};
      assign asf_event__type_lti_c_tx_tdata       = {CTAG_ASF_EVENT_TYPE_WIDTH{1'b0}};
      assign asf_event__count_lti_c_tx_tdata      = {CTAG_ASF_EVENT_COUNT_WIDTH{1'b0}};
      assign asf_event__node_id_lti_c_tx_tdata    = {CTAG_ASF_NODE_ID_WIDTH{1'b0}};
      assign asf_event__diag_field_lti_c_tx_tdata = {CTAG_ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
    end
  endgenerate
generate
    if (KMAX_DTI_SUPPORT == 1) begin : i_dti_hls_wrapper_gen

    dti_hls_wrapper #(
     .KMAX_DATAPATH_WD                              (KMAX_DATAPATH_WD), // = 512,
     .KMAX_NUM_TLPS_PER_CLK                         (KMAX_NUM_TLPS_PER_CLK), // = 4,
     .KMAX_RAM_READ_LATENCY                         (RAM_READ_LATENCY), // = 3,
     .HLS_DW_ALIGNMENT                              (HLS_DW_ALIGNMENT), // = 2,
//     .HLS_METADATA_WD                               (HLS_HAL_OB_PNP_CNTL_WD), // = 40,
     .HLS_RX_P_METADATA_WD                          (HLS_RX_PNP_METADATA_WD),
     .HLS_RX_NP_METADATA_WD                         (HLS_RX_PNP_METADATA_WD),
     .HLS_TX_P_METADATA_WD                          (HLS_TX_PNP_METADATA_WD),
     .HLS_TX_C_METADATA_WD                          (HLS_TX_C_METADATA_WD),
     .AXIL_ADDR_WIDTH                               (AXIL_ADDR_WIDTH_REGS), // = 12,
     .AXIL_DATA_WIDTH                               (AXIL_DATA_WIDTH     ), // = 32,
     .AXIL_RESP_WIDTH                               (AXIL_RESP_WIDTH     ), // = 2,
     .RAM_DATA_WIDTH                                (DTI_RAM_DATA_WIDTH),
     .KMAX_NUM_VCS                                  (KMAX_NUM_VCS),
     .KMAX_IDE_NUM_LINK_STREAMS                     (KMAX_IDE_NUM_LINK_STREAMS),
     .KMAX_IDE_NUM_SEL_STREAMS                      (KMAX_IDE_NUM_SEL_STREAMS),
     .CRD_IN_LMT_HEADER_WIDTH                       (CRD_IN_LMT_HEADER_WIDTH),
     .CRD_IN_LMT_PAYLOAD_WIDTH                      (CRD_IN_LMT_PAYLOAD_WIDTH),

     .TDISP_SUPPORT                                 (TDISP_SUPPORT),
     .ASF_ERROR_INJ_DATA_WIDTH                      (64),
     .ASF_DIAG_INFO_TDATA_WIDTH                     (32),
     .ASF_DIAG_INFO_TUSER_WIDTH                     (48),
     .ASF_SUPPORT                                   (ASF_SUPPORT),
     .ASF_ERR_INJ_SUPPORT                           (ASF_ERR_INJ_SUPPORT)
    ) i_dti_hls_wrapper (
     .k_flit_mode_support                           (k_flit_mode_support),//input wire
     .k_ohc_e_wd                                    (k_ohc_e_wd),//input wire [2:0]
     .k_ide_support                                 (k_ide_support),//input wire
     .k_tok_trans                                   (k_dti_tok_trans_min1),//input wire [TOK_TRANS_BIN_WIDTH-1:0]
     .k_tok_inv                                     (k_dti_tok_inv_min1),//input wire [TOK_INV_BIN_WIDTH-1:0]
     .k_ram_read_latency                            (k_dti_ram_read_latency),//input wire [RAM_READ_LATENCY_WIDTH-1:0]
     .k_ram_enable                                  (k_dti_ram_enable),//input wire
     .k_pcie_sec_link_streams                       ({(KMAX_IDE_NUM_LINK_STREAMS == 0) ? 1 : $clog2(KMAX_IDE_NUM_LINK_STREAMS+1){1'd0}}),
     .k_pcie_sec_selective_streams                  ({(KMAX_IDE_NUM_SEL_STREAMS == 0) ? 1 : $clog2(KMAX_IDE_NUM_SEL_STREAMS+1){1'd0}}),
     .k_ecrc_capability_support                     (k_ecrc_capability_support),//input wire
     .k_cxl_io_support                              (k_cxl_io_support),//input wire
     .k_pasid_support                               (k_pasid_supported),//input wire
     .k_hls_dw_alignment                            (k_hls_dw_alignment),//input wire [2:0]
     .k_sync_reset                                  (k_sync_reset),//input wire
     .k_sync_cell_stages                            (k_sync_cell_stages),//input wire

     .clk                                            (core_clk),//input wire
     .rst_n                                          (core_rst_n),//input wire

     .axil_clk                                       (axil_clk),//input wire
     .axil_rst_n                                     (axil_rst_n),//input wire
     .axi_clk                                        (axi_dti_clk),//input wire
     .axi_rst_n                                      (axi_dti_rst_n),//input wire

     .axi_qactive                                    (axi_dti_qactive),

     .axil_s_awready                                 (connected_internal_axil_m_awready[1]),//output wire
     .axil_s_awvalid                                 (internal_axil_m_awvalid[1]),//input wire
     //todo confrim width
     .axil_s_awaddr                                  (internal_axil_m_awaddr [AXIL_ADDR_WIDTH +: AXIL_ADDR_WIDTH_REGS]),//input wire [AXIL_ADDR_WIDTH-1:0]
     .axil_s_wready                                  (connected_internal_axil_m_wready [1]                             ),//output wire
     .axil_s_wvalid                                  (internal_axil_m_wvalid [1]                             ),//input wire
     .axil_s_wdata                                   (internal_axil_m_wdata  [AXIL_DATA_WIDTH   +: AXIL_DATA_WIDTH_REGS  ]),//input wire [AXIL_DATA_WIDTH-1:0]
     .axil_s_wstrb                                   (internal_axil_m_wstrb  [AXIL_DATA_WIDTH/8 +: AXIL_DATA_WIDTH_REGS/8]),//input wire [AXIL_STRB_WIDTH-1:0]
     .axil_s_bready                                  (internal_axil_m_bready [1]),//input wire
     .axil_s_bvalid                                  (connected_internal_axil_m_bvalid [1]),//output wire
     .axil_s_bresp                                   (connected_internal_axil_m_bresp  [AXIL_RESP_WIDTH +: AXIL_RESP_WIDTH]),//output wire [AXIL_RESP_WIDTH-1:0]
     .axil_s_arready                                 (connected_internal_axil_m_arready[1]),//output wire
     .axil_s_arvalid                                 (internal_axil_m_arvalid[1]),//input wire
     .axil_s_araddr                                  (internal_axil_m_araddr [AXIL_ADDR_WIDTH +: AXIL_ADDR_WIDTH_REGS]),//input wire [AXIL_ADDR_WIDTH-1:0]
     .axil_s_rready                                  (internal_axil_m_rready [1]),//input wire
     .axil_s_rvalid                                  (connected_internal_axil_m_rvalid [1]),//output wire
     .axil_s_rdata                                   (connected_internal_axil_m_rdata  [AXIL_DATA_WIDTH +: AXIL_DATA_WIDTH_REGS]),//output wire [AXIL_DATA_WIDTH-1:0]
     .axil_s_rresp                                   (connected_internal_axil_m_rresp  [AXIL_RESP_WIDTH +: AXIL_RESP_WIDTH]),//output wire [AXIL_RESP_WIDTH-1:0]
     //todo confrim width
     .axil_s_awaddr_chk                              (internal_axil_m_awaddr_par[AXIL_ADDR_WIDTH_CHK +: (AXIL_ADDR_WIDTH_REGS+7)/8]),//input wire [AXIL_ADDR_CHKITY_WIDTH-1:0]
     .axil_s_wdata_chk                               (internal_axil_m_wdata_par [AXIL_DATA_WIDTH_CHK +: (AXIL_DATA_WIDTH_REGS+7)/8]),//input wire [AXIL_DATA_CHKITY_WIDTH-1:0]
     .axil_s_wstrb_chk                               (internal_axil_m_wstrb_par [AXIL_STRB_WIDTH_CHK +: AXIL_STRB_WIDTH_CHK]),//input wire [AXIL_STRB_CHKITY_WIDTH-1:0]
     //.axil_s_awaddr_chk                              ({AXIL_ADDR_WIDTH_CHK{k_asf_odd_parity}}),//input wire [AXIL_ADDR_CHKITY_WIDTH-1:0]
     //.axil_s_wdata_chk                               ({AXIL_DATA_WIDTH_CHK{k_asf_odd_parity}}),//input wire [AXIL_DATA_CHKITY_WIDTH-1:0]
     //.axil_s_wstrb_chk                               ({AXIL_STRB_WIDTH{k_asf_odd_parity}}),//input wire [AXIL_STRB_CHKITY_WIDTH-1:0]
     .axil_s_bresp_chk                               (connected_internal_axil_m_bresp_par [AXIL_RESP_WIDTH_CHK +: AXIL_RESP_WIDTH_CHK]),//output wire [AXIL_RESP_CHKITY_WIDTH-1:0]
     .axil_s_rresp_chk                               (connected_internal_axil_m_rresp_par [AXIL_RESP_WIDTH_CHK +: AXIL_RESP_WIDTH_CHK]),//output wire [AXIL_RESP_CHKITY_WIDTH-1:0]
     //.axil_s_araddr_chk                              ({AXIL_ADDR_WIDTH_CHK{k_asf_odd_parity}}),//input wire [AXIL_ADDR_CHKITY_WIDTH-1:0]
     .axil_s_araddr_chk                              (internal_axil_m_araddr_par[AXIL_ADDR_WIDTH_CHK +: (AXIL_ADDR_WIDTH_REGS+7)/8]),//input wire [AXIL_ADDR_CHKITY_WIDTH-1:0]
     .axil_s_rdata_chk                               (connected_internal_axil_m_rdata_par [AXIL_DATA_WIDTH_CHK +: (AXIL_DATA_WIDTH_REGS+7)/8]),//output wire [AXIL_DATA_CHKITY_WIDTH-1:0]
     .axil_s_awvalid_chk                             (internal_axil_m_awvalid_par  [1]),
     .axil_s_wvalid_chk                              (internal_axil_m_wvalid_par   [1]),
     .axil_s_bready_chk                              (internal_axil_m_bready_par   [1]),
     .axil_s_arvalid_chk                             (internal_axil_m_arvalid_par  [1]),
     .axil_s_rready_chk                              (internal_axil_m_rready_par   [1]),
     //.axil_s_awvalid_chk                             (internal_dti_axil_m_awvalid_chk),
     //.axil_s_wvalid_chk                              (internal_dti_axil_m_wvalid_chk),
     //.axil_s_bready_chk                              (internal_dti_axil_m_bready_chk),
     //.axil_s_arvalid_chk                             (internal_dti_axil_m_arvalid_chk),
     //.axil_s_rready_chk                              (internal_dti_axil_m_rready_chk),
     //todo
     .axil_s_awready_chk                             (connected_internal_axil_m_awready_par[1]),
     .axil_s_wready_chk                              (connected_internal_axil_m_wready_par [1]),
     .axil_s_bvalid_chk                              (connected_internal_axil_m_bvalid_par [1]),
     .axil_s_arready_chk                             (connected_internal_axil_m_arready_par[1]),
     .axil_s_rvalid_chk                              (connected_internal_axil_m_rvalid_par [1]),
   //todo -------------------
     .axil_s_awid                                    (1'b0),
     .axil_s_awid_chk                                (1'b1),
     .axil_s_awprot                                  (internal_axil_m_awprot     [AXIL_PROT_WIDTH      +: AXIL_PROT_WIDTH]),
     .axil_s_awctl_chk0                              (internal_axil_m_awctl_chk0 [AXIL_PROT_WIDTH_CHK  +: AXIL_PROT_WIDTH_CHK]),
     .axil_s_awuser                                  (internal_axil_m_awuser     [AXIL_WUSER_WIDTH     +: AXIL_WUSER_WIDTH]),
     .axil_s_awuser_chk                              (internal_axil_m_awuser_par [AXIL_WUSER_WIDTH_CHK +: AXIL_WUSER_WIDTH_CHK]),
     .axil_s_bid                                     (),
     .axil_s_bid_chk                                 (),
     .axil_s_arid                                    (1'b0),
     .axil_s_arid_chk                                (1'b1),
     .axil_s_arprot                                  (internal_axil_m_arprot     [AXIL_PROT_WIDTH       +: AXIL_PROT_WIDTH]),
     .axil_s_arctl_chk0                              (internal_axil_m_arctl_chk0 [AXIL_PROT_WIDTH_CHK   +: AXIL_PROT_WIDTH_CHK]),
     .axil_s_aruser                                  (internal_axil_m_aruser     [AXIL_ARUSER_WIDTH     +: AXIL_ARUSER_WIDTH]),
     .axil_s_aruser_chk                              (internal_axil_m_aruser_par [AXIL_ARUSER_WIDTH_CHK +: AXIL_ARUSER_WIDTH_CHK]),
     .axil_s_rid                                     (),
     .axil_s_rid_chk                                 (),

     .interrupt                                      (dti_interrupt),

     .hls2rx_posted_valid                            (hls_ib_posted_dti_valid),    //input wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_posted_data                             (hls_ib_posted_dti_data),     //input wire [NUM_TLP_STREAMS*KMAX_DATAPATH_WD-1:0]
     .hls2rx_posted_cntl                             (hls_ib_posted_dti_cntl),     //input wire [NUM_TLP_STREAMS*HLS_CNTL_WD-1:0]
     .hls2rx_posted_crdgnt                           (hls_ib_posted_dti_crdgnt),   //output wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_posted_crdrtn                           (hls_ib_posted_dti_crdrtn),   //input wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_posted_activereq                        (hls_ib_posted_dti_activereq),//input wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_posted_activeack                        (hls_ib_posted_dti_activeack),//output wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_posted_deacthint                        (hls_ib_posted_dti_deacthint),//output wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_posted_data_chk                         (hls_ib_posted_dti_data_chk), //input wire [NUM_TLP_STREAMS*KMAX_DATAPATH_WD_CHK-1:0]
     .hls2rx_posted_cntl_chk                         (hls_ib_posted_dti_cntl_chk), //input wire [NUM_TLP_STREAMS*HLS_CNTL_CHK_WD-1:0]

     .hls2rx_nonposted_valid                         (hls_ib_nonposted_dti_valid),    //input wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_nonposted_data                          (hls_ib_nonposted_dti_data),     //input wire [NUM_TLP_STREAMS*KMAX_DATAPATH_WD-1:0]
     .hls2rx_nonposted_cntl                          (hls_ib_nonposted_dti_cntl),     //input wire [NUM_TLP_STREAMS*HLS_CNTL_WD-1:0]
     .hls2rx_nonposted_crdgnt                        (hls_ib_nonposted_dti_crdgnt),   //output wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_nonposted_crdrtn                        (hls_ib_nonposted_dti_crdrtn),   //input wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_nonposted_activereq                     (hls_ib_nonposted_dti_activereq),//input wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_nonposted_activeack                     (hls_ib_nonposted_dti_activeack),//output wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_nonposted_deacthint                     (hls_ib_nonposted_dti_deacthint),//output wire [NUM_TLP_STREAMS-1:0]
     .hls2rx_nonposted_data_chk                      (hls_ib_nonposted_dti_data_chk), //input wire [NUM_TLP_STREAMS*KMAX_DATAPATH_WD_CHK-1:0]
     .hls2rx_nonposted_cntl_chk                      (hls_ib_nonposted_dti_cntl_chk), //input wire [NUM_TLP_STREAMS*HLS_CNTL_CHK_WD-1:0]

     .hls2tx_posted_valid                            (hls_ob_posted_dti_valid),    //output wire
     .hls2tx_posted_data                             (hls_ob_posted_dti_data),     //output wire [KMAX_DATAPATH_WD-1:0]
     .hls2tx_posted_cntl                             (hls_ob_posted_dti_cntl),     //output wire [HLS_CNTL_WD-1:0]
     .hls2tx_posted_crdgnt                           (hls_ob_posted_dti_crdgnt),   //input wire
     .hls2tx_posted_crdrtn                           (hls_ob_posted_dti_crdrtn),   //output wire
     .hls2tx_posted_activereq                        (hls_ob_posted_dti_activereq),//output wire
     .hls2tx_posted_activeack                        (hls_ob_posted_dti_activeack),//input wire
     .hls2tx_posted_deacthint                        (hls_ob_posted_dti_deacthint),//input wire
     .hls2tx_posted_data_chk                         (hls_ob_posted_dti_data_chk), //output wire [KMAX_DATAPATH_WD_CHK-1:0]
     .hls2tx_posted_cntl_chk                         (hls_ob_posted_dti_cntl_chk), //output wire [HLS_CNTL_CHK_WD-1:0]

     .hls2tx_compl_valid                             (hls_ob_compl_dti_valid),    //output wire
     .hls2tx_compl_data                              (hls_ob_compl_dti_data),     //output wire [KMAX_DATAPATH_WD-1:0]
     .hls2tx_compl_cntl                              (hls_ob_compl_dti_cntl),     //output wire [HLS_CNTL_WD-1:0]
     .hls2tx_compl_crdgnt                            (hls_ob_compl_dti_crdgnt),   //input wire
     .hls2tx_compl_crdrtn                            (hls_ob_compl_dti_crdrtn),   //output wire
     .hls2tx_compl_activereq                         (hls_ob_compl_dti_activereq),//output wire
     .hls2tx_compl_activeack                         (hls_ob_compl_dti_activeack),//input wire
     .hls2tx_compl_deacthint                         (hls_ob_compl_dti_deacthint),//input wire
     .hls2tx_compl_data_chk                          (hls_ob_compl_dti_data_chk), //output wire [KMAX_DATAPATH_WD_CHK-1:0]
     .hls2tx_compl_cntl_chk                          (hls_ob_compl_dti_cntl_chk), //output wire [HLS_CNTL_CHK_WD-1:0]

     .hdr2log_tready                                 (hdr2log_tx_dti_tready),//input wire
     .hdr2log_tready_chk                             (hdr2log_tx_dti_tready_chk),//input wire
     .hdr2log_tvalid                                 (hdr2log_tx_dti_tvalid),//output wire
     .hdr2log_tvalid_chk                             (hdr2log_tx_dti_tvalid_chk),//output wire
     .hdr2log_tdata                                  (hdr2log_tx_dti_tdata),//output wire [KMAX_DATAPATH_WD-1:0]
     .hdr2log_tdata_chk                              (hdr2log_tx_dti_tdata_chk),//output wire [KMAX_DATAPATH_WD_CHK-1:0]
     .hdr2log_tlast                                  (hdr2log_tx_dti_tlast),//output wire
     .hdr2log_tlast_chk                              (hdr2log_tx_dti_tlast_chk),//output wire
     .hdr2log_tuser                                  (hdr2log_tx_dti_tuser),
     .hdr2log_tuser_chk                              (hdr2log_tx_dti_tuser_chk),

    //
     //.req_axi_s_clk                                  (),//output wire
    // if 0 then messages with page request should be routed to AXI, not to DTI
     .pri_supported                                  (hls_ib_posted_dti_pri_supported),//output wire
     //.axi_m_low_pwr_path_inactive                    (),//output wire
     //.axi_m_low_pwr_req_and_cpl_path_inactive        (),//output wire
     //.low_pwr_tx_posted_path_inactive_axi_s          (),//output wire
     //.low_pwr_tx_posted_path_inactive_axi_m          (),//output wire

     //.tick_1ms                                       (1'b0),//input wire

     .delivered_p_tvalid                             (dc_dti_tvalid),//output
     .delivered_p_tdata                              (dc_dti_tdata), //output     [15:0]
     .delivered_p_tvalid_chk                         (dc_dti_tvalid_chk),//output
     .delivered_p_tdata_chk                          (dc_dti_tdata_chk),//output     [1:0]

     .low_power_mode                                 (low_power_mode),
     .link_down_handling_in_progress                 (link_down_handling_in_progress),//input wire

     .misc_flit_mode                                 (misc_flit_mode),//input wire [1:0]
     .misc_10_bit_tag_completer_support              (misc_10_bit_tag_completer_support),//input wire
     .misc_14_bit_tag_completer_support              (misc_14_bit_tag_completer_support),//input wire
     .misc_captured_dest_segment                     (misc_captured_dest_segment),//input wire [7:0]
     .misc_segment_captured                          (misc_segment_captured),//input wire
     .misc_ecrc_generation_enable                    (misc_ecrc_generation_enable_per_pf[0]),//input wire [KMAX_NUM_PFS-1:0]
     .misc_read_completion_boundary                  (misc_read_completion_boundary),//input wire
     .misc_tc_vc_mapping                             (tc_vc_mapping),//input wire [4*NUM_TCS-1:0]
     .misc_ide_link_stream_control_reg               (misc_ide_link_stream_control_reg),
     .misc_ide_sel_stream_control_reg                (misc_ide_sel_stream_control_reg),
     .misc_ide_sel_stream_rid_assoc1_reg             (misc_ide_sel_stream_rid_assoc1_reg),
     .misc_ide_sel_stream_rid_assoc2_reg             (misc_ide_sel_stream_rid_assoc2_reg),

     .crd_used_tx_posted_header                      (crd_dti_lmt_posted_header),//output wire [KMAX_NUM_VCS*CRD_IN_LMT_USED_HEADER_WIDTH-1:0]
     .crd_used_tx_posted_payload                     (crd_dti_lmt_posted_payload),//output wire [KMAX_NUM_VCS*CRD_IN_LMT_USED_PAYLOAD_WIDTH-1:0]

     .tvalid_dti_dn                                  (tvalid_dti_dn),//output wire
     .tready_dti_dn                                  (tready_dti_dn),//input wire
     .tdata_dti_dn                                   (tdata_dti_dn),//output wire [DTI_TDATA_WIDTH-1:0]
     .tkeep_dti_dn                                   (tkeep_dti_dn),//output wire [DTI_TKEEP_WIDTH-1:0]
     .tlast_dti_dn                                   (tlast_dti_dn),//output wire
     .twakeup_dti_dn                                 (twakeup_dti_dn),

     .tready_dti_dn_chk                              (tready_dti_dn_chk),
     .tvalid_dti_dn_chk                              (tvalid_dti_dn_chk),
     .tdata_dti_dn_chk                               (tdata_dti_dn_chk),//output wire [DTI_TDATA_CHK_WIDTH-1:0]
     .tkeep_dti_dn_chk                               (tkeep_dti_dn_chk),//output wire [DTI_TKEEP_CHK_WIDTH-1:0]
     .tlast_dti_dn_chk                               (tlast_dti_dn_chk),
     .twakeup_dti_dn_chk                             (twakeup_dti_dn_chk),

     .tvalid_dti_up                                  (tvalid_dti_up),//input wire
     .tready_dti_up                                  (tready_dti_up),//output wire
     .tdata_dti_up                                   (tdata_dti_up),//input wire [DTI_TDATA_WIDTH-1:0]
     .tkeep_dti_up                                   (tkeep_dti_up),//input wire [DTI_TKEEP_WIDTH-1:0]
     .tlast_dti_up                                   (tlast_dti_up),//input wire
     .twakeup_dti_up                                 (twakeup_dti_up),

     .tready_dti_up_chk                              (tready_dti_up_chk),
     .tvalid_dti_up_chk                              (tvalid_dti_up_chk),
     .tdata_dti_up_chk                               (tdata_dti_up_chk),//input wire [DTI_TDATA_CHK_WIDTH-1:0]
     .tkeep_dti_up_chk                               (tkeep_dti_up_chk),//input wire [DTI_TKEEP_CHK_WIDTH-1:0]
     .tlast_dti_up_chk                               (tlast_dti_up_chk),
     .twakeup_dti_up_chk                             (twakeup_dti_up_chk),

     //   TBD error count on memmories
     .asf_ecc_corr_err                               (), //(asf_ecc_corr_err),//output wire
     .asf_ecc_uncorr_err                             (), //(asf_ecc_uncorr_err),//output wire
     .asf_addr_parity_err                            (), //(asf_addr_parity_err),//output wire
     .asf_addr_err                                   (), //(asf_addr_err),//output wire [TOK_TRANS_BIN_WIDTH-1:0]
     .asf_parity_err                                 (), //(asf_parity_err),//output wire [2:0]
     .asf_csr_err                                    (), //(asf_csr_err),//output wire

     .ram_used_bits                                  (ram_used_bits),
     .ram_write_valid                                (ram_write_valid),//output wire
     .ram_write_addr                                 (ram_write_addr),//output wire [tok_trans_bin_width-1:0]
     .ram_write_data                                 (ram_write_data),//output wire [dti_ram_data_width-1:0]
     .ram_read_valid                                 (ram_read_valid),//output wire
     .ram_read_addr                                  (ram_read_addr),//output wire [tok_trans_bin_width-1:0]
     .ram_read_data                                  (ram_read_data),//input wire [DTI_RAM_DATA_WIDTH-1:0]

     .asf_err_inj_tvalid                             (asf_error_inj__cmd_tvalid),
     .asf_err_inj_tvalid_chk                         (asf_error_inj__tvalidchk),
     .asf_err_inj_tdata                              ({asf_error_inj__tuser, asf_error_inj__tdata}),
     .asf_err_inj_tdata_chk                          ({asf_error_inj__tuserchk, asf_error_inj__tdatachk}),

     .asf_diag_info_tdata                            (asf_diag__info_dti_tdata_o     ),
     .asf_diag_info_tdata_chk                        (asf_diag__info_dti_tdatachk_o  ),
     .asf_diag_info_tuser                            (asf_diag__info_dti_tuser_o     ),
     .asf_diag_info_tuser_chk                        (asf_diag__info_dti_tuserchk_o  ),
     .asf_diag_info_tvalid                           (asf_diag__info_dti_tvalid_o    ),
     .asf_diag_info_tvalid_chk                       (asf_diag__info_dti_tvalidchk_o ),

     .tdisp_enable                                   (tdisp_enable),

     .tdisp_req_valid                                (tdisp_req_valid),
     .tdisp_req_read                                 (tdisp_req_read),
     .tdisp_req_addr                                 (tdisp_req_register_address),
     .tdisp_req_field                                (tdisp_req_field_address),
     .tdisp_req_value                                (tdisp_req_value),

     .tdisp_req_valid_chk                            (tdisp_req_validchk),
     .tdisp_req_read_chk                             (tdisp_req_readchk),
     .tdisp_req_addr_chk                             (tdisp_req_addrchk),
     .tdisp_req_field_chk                            (tdisp_req_fieldchk),
     .tdisp_req_value_chk                            (tdisp_req_valuechk),

     .tdisp_read_valid                               (dti_tdisp_read_valid    ),
     .tdisp_read_addr                                (dti_tdisp_read_register_address),
     .tdisp_read_field                               (dti_tdisp_read_field_address),
     .tdisp_read_value                               (dti_tdisp_read_value    ),

     .tdisp_read_valid_chk                           (dti_tdisp_read_validchk),
     .tdisp_read_addr_chk                            (dti_tdisp_read_addrchk ),
     .tdisp_read_field_chk                           (dti_tdisp_read_fieldchk),
     .tdisp_read_value_chk                           (dti_tdisp_read_valuechk),

     .tdisp_notify_valid                             (dti_tdisp_notify_valid  ),
     .tdisp_notify_addr                              (dti_tdisp_notify_register_address),
     .tdisp_notify_field                             (dti_tdisp_notify_field_address),
     .tdisp_notify_value                             (dti_tdisp_notify_value  ),
     .tdisp_notify_origin                            (dti_tdisp_notify_origin ),
     .tdisp_notify_index                             (dti_tdisp_notify_index  ),

     .tdisp_notify_valid_chk                         (dti_tdisp_notify_validchk ),
     .tdisp_notify_addr_chk                          (dti_tdisp_notify_addrchk  ),
     .tdisp_notify_field_chk                         (dti_tdisp_notify_fieldchk ),
     .tdisp_notify_value_chk                         (dti_tdisp_notify_valuechk ),
     .tdisp_notify_origin_chk                        (dti_tdisp_notify_originchk),
     .tdisp_notify_index_chk                         (dti_tdisp_notify_indexchk )

    );


    end
    else begin : gen_no_dti
    assign axi_dti_qactive            = 1'b0;
    assign dti_interrupt              = 1'b0;
    assign hdr2log_tx_dti_tvalid      = 1'b0;
    assign hdr2log_tx_dti_tvalid_chk  = 1'b0;
    assign hdr2log_tx_dti_tdata       = {KMAX_DATAPATH_WD{1'b0}};
    assign hdr2log_tx_dti_tdata_chk   = {KMAX_DATAPATH_WD/8{1'b0}};
    assign hdr2log_tx_dti_tlast       = 1'b0;
    assign hdr2log_tx_dti_tlast_chk   = 1'b0;
    assign hdr2log_tx_dti_tuser       = 26'd0;
    assign hdr2log_tx_dti_tuser_chk   = 4'h0;

    assign crd_dti_lmt_posted_header  = {CRD_IN_LMT_HEADER_WIDTH*KMAX_NUM_VCS{1'b0}};
    assign crd_dti_lmt_posted_payload = {CRD_IN_LMT_PAYLOAD_WIDTH*KMAX_NUM_VCS{1'b0}};

    assign dc_dti_tvalid     = 1'b0;
    assign dc_dti_tdata      = {DC_TDATA_WIDTH{1'b0}};
    assign dc_dti_tvalid_chk = 1'b0;
    assign dc_dti_tdata_chk  = {DC_TDATA_CHK_WIDTH{1'b0}};

    assign ram_used_bits     = 16'd0;
    assign ram_write_valid   = 1'b0;
    assign ram_write_addr    = {TOK_TRANS_BIN_WIDTH{1'b0}};
    assign ram_write_data    = {DTI_RAM_DATA_WIDTH{1'b0}};
    assign ram_read_valid    = 1'b0;
    assign ram_read_addr     = {TOK_TRANS_BIN_WIDTH{1'b0}};

    assign hls_ob_posted_dti_valid     = 1'b0;
    assign hls_ob_posted_dti_data      = {KMAX_DATAPATH_WD{1'b0}};
    assign hls_ob_posted_dti_cntl      = {HLS_HAL_OB_PNP_CNTL_WD{1'b0}};
    assign hls_ob_posted_dti_data_chk  = {KMAX_DATAPATH_WD_CHK{1'b1}};
    assign hls_ob_posted_dti_cntl_chk  = {HLS_HAL_OB_PNP_CNTL_CHK_WD{1'b1}};
    assign hls_ob_posted_dti_crdrtn    = 1'b0;
    assign hls_ob_posted_dti_activereq = 1'b0;

    assign hls_ib_posted_dti_crdgnt    = 1'b0;
    assign hls_ib_posted_dti_activeack = 1'b0;
    assign hls_ib_posted_dti_deacthint = 1'b0;
    assign hls_ib_posted_dti_pri_supported = 1'b0;

    assign hls_ib_nonposted_dti_crdgnt    = 1'b0;
    assign hls_ib_nonposted_dti_activeack = 1'b0;
    assign hls_ib_nonposted_dti_deacthint = 1'b0;

    assign asf_diag__info_dti_tdata_o     = 32'h0;
    assign asf_diag__info_dti_tdatachk_o  = 4'hf;
    assign asf_diag__info_dti_tvalid_o    = 1'h0;
    assign asf_diag__info_dti_tvalidchk_o = 1'h1;
    assign asf_diag__info_dti_tuser_o     = 48'h0;
    assign asf_diag__info_dti_tuserchk_o  = 6'h3f;

    assign hls_ob_compl_dti_valid     = 1'b0;
    assign hls_ob_compl_dti_data      = {KMAX_DATAPATH_WD{1'b0}};
    assign hls_ob_compl_dti_cntl      = {HLS_HAL_OB_PNP_CNTL_WD{1'b0}};
    assign hls_ob_compl_dti_data_chk  = {KMAX_DATAPATH_WD_CHK{1'b1}};
    assign hls_ob_compl_dti_cntl_chk  = {HLS_HAL_OB_PNP_CNTL_CHK_WD{1'b1}};
    assign hls_ob_compl_dti_crdrtn    = 1'b0;
    assign hls_ob_compl_dti_activereq = 1'b0;



    assign connected_internal_axil_m_awready [1]     = 1'b0;
    assign connected_internal_axil_m_awready_par [1] = 1'b1;
    assign connected_internal_axil_m_wready [1]      = 1'b0;
    assign connected_internal_axil_m_wready_par [1]  = 1'b1;
    assign connected_internal_axil_m_bvalid_par [1]  = 1'b1;
    assign connected_internal_axil_m_bvalid [1]      = 1'b0;
    assign connected_internal_axil_m_bresp  [AXIL_RESP_WIDTH +: AXIL_RESP_WIDTH] = {AXIL_RESP_WIDTH{1'b0}};
    assign connected_internal_axil_m_bresp_par [AXIL_RESP_WIDTH_CHK +: AXIL_RESP_WIDTH_CHK] = {AXIL_RESP_WIDTH_CHK{1'b1}};
    assign connected_internal_axil_m_arready [1]     = 1'b0;
    assign connected_internal_axil_m_arready_par [1] = 1'b1;
    assign connected_internal_axil_m_rvalid [1]      = 1'b0;
    assign connected_internal_axil_m_rvalid_par [1]  = 1'b1;
    assign connected_internal_axil_m_rdata  [AXIL_DATA_WIDTH +: AXIL_DATA_WIDTH_REGS] = {AXIL_DATA_WIDTH_REGS{1'b0}};
    assign connected_internal_axil_m_rdata_par [AXIL_DATA_WIDTH_CHK +: (AXIL_DATA_WIDTH_REGS+7)/8] = {AXIL_DATA_WIDTH_CHK{1'b1}};
    assign connected_internal_axil_m_rresp  [AXIL_RESP_WIDTH +: AXIL_RESP_WIDTH] = {AXIL_RESP_WIDTH{1'b0}};
    assign connected_internal_axil_m_rresp_par [AXIL_RESP_WIDTH_CHK +: AXIL_RESP_WIDTH_CHK] = {AXIL_RESP_WIDTH_CHK{1'b0}};

    assign tdata_dti_dn          = {DTI_TDATA_WIDTH{1'b0}};
    assign tdata_dti_dn_chk      = {DTI_TDATA_CHK_WIDTH{1'b1}};
    assign tkeep_dti_dn          = {DTI_TKEEP_WIDTH{1'b0}};
    assign tkeep_dti_dn_chk      = {DTI_TKEEP_CHK_WIDTH{1'b1}};
    assign tlast_dti_dn          = 1'b0;
    assign tlast_dti_dn_chk      = 1'b1;
    assign tready_dti_up         = 1'b0;
    assign tready_dti_up_chk     = 1'b1;
    assign tvalid_dti_dn         = 1'b0;
    assign tvalid_dti_dn_chk     = 1'b1;
    assign twakeup_dti_dn        = 1'b0;
    assign twakeup_dti_dn_chk    = 1'b1;



    assign dti_tdisp_read_valid              = 1'b0;
    assign dti_tdisp_read_register_address   = {TDISP_ADDR_WIDTH     {1'b0}};
    assign dti_tdisp_read_field_address      = {TDISP_FIELD_WIDTH    {1'b0}};
    assign dti_tdisp_read_value              = {TDISP_REXVALUE_WIDTH {1'b0}};

    assign dti_tdisp_read_validchk           = 1'b1;
    assign dti_tdisp_read_addrchk            = {TDISP_ADDRCHK_WIDTH     {1'b1}};
    assign dti_tdisp_read_fieldchk           = {TDISP_FIELDCHK_WIDTH    {1'b1}};
    assign dti_tdisp_read_valuechk           = {TDISP_REXVALUECHK_WIDTH {1'b1}};

    assign dti_tdisp_notify_valid            = 1'b0;
    assign dti_tdisp_notify_register_address = {TDISP_ADDR_WIDTH        {1'b0}};
    assign dti_tdisp_notify_field_address    = {TDISP_FIELD_WIDTH       {1'b0}};
    assign dti_tdisp_notify_value            = {TDISP_NOTIFYVALUE_WIDTH {1'b0}};
    assign dti_tdisp_notify_origin           = {TDISP_ORIGIN_WIDTH      {1'b0}};
    assign dti_tdisp_notify_index            = {TDISP_INDEX_WIDTH       {1'b0}};

    assign dti_tdisp_notify_validchk         = 1'b1;
    assign dti_tdisp_notify_addrchk          = {TDISP_ADDRCHK_WIDTH       {1'b1}};
    assign dti_tdisp_notify_fieldchk         = {TDISP_FIELDCHK_WIDTH      {1'b1}};
    assign dti_tdisp_notify_valuechk         = {TDISP_NOTIFYVALUECHK_WIDTH{1'b1}};
    assign dti_tdisp_notify_originchk        = {TDISP_ORIGINCHK_WIDTH     {1'b1}};
    assign dti_tdisp_notify_indexchk         = {TDISP_INDEXCHK_WIDTH      {1'b1}};

    end
 endgenerate

 hls_bridge_pck_count i_hls_bridge_pck_count (
   // valid i/f
   .core_clk                 (core_clk),             // input
   .core_rst_n               (core_rst_n),           // input
   .hls_ib_posted_axi_valid         (|hls_ib_posted_axi_valid),    // input
   .hls_ib_nonposted_axi_valid      (|hls_ib_nonposted_axi_valid), // input
   .hls_ib_compl_axi_valid          (|hls_ib_compl_axi_valid),     // input
   .hls_ob_posted_axi_valid         (|hls_ob_posted_axi_valid),    // input
   .hls_ob_nonposted_axi_valid      (|hls_ob_nonposted_axi_valid), // input
   .hls_ob_compl_axi_valid          (|hls_ob_compl_axi_valid),     // input
   .hls_ib_posted_msi_valid         (ib_posted_msi_valid),     // input
   .hls_ib_posted_dti_valid         (hls_ib_posted_dti_valid),     // input
   .hls_ib_nonposted_dti_valid      (hls_ib_nonposted_dti_valid),  // input
   .hls_ob_compl_dti_valid          (hls_ob_compl_dti_valid),      // input
   .hls_ob_posted_dti_valid         (hls_ob_posted_dti_valid),     // input
   // pkg_cnt_from_regs
   .hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_fr  (hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_o),  // input [31:0]
   .hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_fr (hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_o), // input [31:0]
   .hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_fr  (hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_o),  // input [31:0]
   .hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_fr  (hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_o),  // input [31:0]
   .hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_fr (hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_o), // input [31:0]
   .hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_fr  (hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_o),  // input [31:0]
   .hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_fr  (hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_o),  // input [15:0]
   .hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_fr  (hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_o),  // input [15:0]
   .hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_fr (hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_o), // input [15:0]
   .hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_fr  (hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_o),  // input [15:0]
   .hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_fr  (hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_o),  // input [15:0]
   // pkg_cnt_to_regs
   .hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_tr  (hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i),  // output [31:0]
   .hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_tr (hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i), // output [31:0]
   .hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_tr  (hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i),  // output [31:0]
   .hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_tr  (hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i),  // output [31:0]
   .hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_tr (hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i), // output [31:0]
   .hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_tr  (hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i),  // output [31:0]
   .hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_tr  (hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i),  // output [15:0]
   .hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_tr  (hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i),  // output [15:0]
   .hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_tr (hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i), // output [15:0]
   .hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_tr  (hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i),  // output [15:0]
   .hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_tr  (hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i),  // output [15:0]
   // captures to regs
   .hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i_capture  (hls_bridge_axi_ib_p_pck_count_dbg_pkg_cnt_i_capture),  // output
   .hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i_capture (hls_bridge_axi_ib_np_pck_count_dbg_pkg_cnt_i_capture), // output
   .hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i_capture  (hls_bridge_axi_ib_c_pck_count_dbg_pkg_cnt_i_capture),  // output
   .hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i_capture  (hls_bridge_axi_ob_p_pck_count_dbg_pkg_cnt_i_capture),  // output
   .hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i_capture (hls_bridge_axi_ob_np_pck_count_dbg_pkg_cnt_i_capture), // output
   .hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i_capture  (hls_bridge_axi_ob_c_pck_count_dbg_pkg_cnt_i_capture),  // output
   .hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i_capture  (hls_bridge_msi_ib_p_pck_count_dbg_pkg_cnt_i_capture),  // output
   .hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i_capture  (hls_bridge_dti_ib_p_pck_count_dbg_pkg_cnt_i_capture),  // output
   .hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i_capture (hls_bridge_dti_ib_np_pck_count_dbg_pkg_cnt_i_capture), // output
   .hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i_capture  (hls_bridge_dti_ob_c_pck_count_dbg_pkg_cnt_i_capture),  // output
   .hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i_capture  (hls_bridge_dti_ob_p_pck_count_dbg_pkg_cnt_i_capture)   // output
  );

  generate
    if (ASF_SUPPORT > 1) begin : i_asf_gen
      asf_errinj_sub_block_decode #(
       .ASF_SUPPORT                                   (ASF_SUPPORT),  // = 3,
       .NUM_SUB_BLOCKS                                (8'd1),  //
       .ASF_ERR_INJ_SUPPORT                           (ASF_ERR_INJ_SUPPORT)   // = 3,
      ) i_asf_errinj_sub_block_decode (
       .clk                             (axil_clk),                        // input
       .rst_n                           (axil_rst_n),                      // input
       .asf_error_inj__cmd_tvalid       (asf_error_inj__cmd_tvalid),       // input
       //.asf_error_inj__cmd_tready       (asf_error_inj__cmd_tready),       // output
       .asf_error_inj__cmd_tready       (),       // output
       .asf_error_inj__tdata            (asf_error_inj__tdata[55:0]),      // input [55:0]
       .asf_error_inj__tdatachk         (asf_error_inj__tdatachk[6:0]),    // input [6:0]
       .asf_error_inj__tuser            (asf_error_inj__tuser),            // input [7:0]
       .asf_error_inj__tuserchk         (asf_error_inj__tuserchk),         // input
       .asf_error_inj__tvalidchk        (asf_error_inj__tvalidchk),        // input
       .asf_error_inj__sub_block_id     (8'd16),                           // HLS Bridge offset
       .sub_block_error_inj__cmd_tvalid (sub_block_error_inj__cmd_tvalid), // output
       .sub_block_error_inj__tdata      (sub_block_error_inj__tdata),      // output [55:0]
       .sub_block_error_inj__tuser      (sub_block_error_inj__tuser),      // output [7:0]
       .asf_errinj_chk_err              (asf_errinj_chk_err)               // output
        );

      if (KMAX_MSI_IF_SUPPORT == 1) begin : axi_cdc_error_inj
       // module below contain async fifo, which can be full in case when
       // axi_msi_clk is off.
       asf_cmd_cdc i_asf_cmd_cdc (
        .src_clk                              (axil_clk),                              // input
        .src_rst_n                            (axil_rst_n),                            // input
        .dst_clk                              (axi_msi_clk),                       // input
        .dst_rst_n                            (axi_msi_rst_n),                     // input
        .k_sync_reset                         (k_sync_reset),                          // input
        .k_number_of_flop_stages_in_sync_cell (k_sync_cell_stages),                    // input
        .asf_error_inj__cmd_tvalid_i          (sub_block_error_inj__cmd_tvalid),       // input
        .asf_error_inj__tdata_i               (sub_block_error_inj__tdata),            // input [55:0]
        .asf_error_inj__tuser_i               (sub_block_error_inj__tuser),            // input [7:0]
        .asf_error_inj__cmd_tvalid_o          (sub_block_error_inj__cdc_cmd_tvalid_o), // output
        .asf_error_inj__tdata_o               (sub_block_error_inj__cdc_tdata_o),      // output [55:0]
        .asf_error_inj__tuser_o               (sub_block_error_inj__cdc_tuser_o),      // output [7:0]
        .read_en_i                            (1'b1)                                   // input
       );
       assign sub_block_error_inj__cdc_cmd_tvalid = sub_block_error_inj__cdc_cmd_tvalid_o;
       assign sub_block_error_inj__cdc_tdata      = sub_block_error_inj__cdc_tdata_o;
       assign sub_block_error_inj__cdc_tuser      = sub_block_error_inj__cdc_tuser_o;

       // The asf_cmd_cdc module above uses an async FIFO with depth=1 but does not
       // provide FIFO level status. Therefore, we use pulse synchronization to
       // track when the FIFO is read by the axi_msi_clk domain, allowing us to
       // safely de-assert qactive once the error injection is acknowledged.
       cdnsdru_pulsesync_v4 i_pulsesync_asf_err_inj_tvalid_ack_i (
           .k_sync_reset       (k_sync_reset)
          ,.k_sync_cell_stages (k_sync_cell_stages)
          ,.src_clk            (axi_msi_clk)
          ,.rst_n_src_clk      (axi_msi_rst_n)
          ,.dest_clk           (axil_clk)
          ,.rst_n_dest_clk     (axil_rst_n)
          ,.pulse_in           (sub_block_error_inj__cdc_cmd_tvalid_o)
          ,.pulse_out          (asf_err_inj_tvalid_ack)
       );
       assign axi_msi_err_inj_cntr_en = sub_block_error_inj__cmd_tvalid  || asf_err_inj_tvalid_ack;
       assign c_axi_msi_err_inj_cntr = (sub_block_error_inj__cmd_tvalid && !asf_err_inj_tvalid_ack)? 1'b1 :
                                       (!sub_block_error_inj__cmd_tvalid && asf_err_inj_tvalid_ack)? 1'b0 : r_axi_msi_err_inj_cntr;
       // Overflow in counter below won't work, as ASF waits for event before
       // issuing new one error injection so only 1 bit is sufficient (1 bit
       // fifo depth)
       always @(posedge axil_clk or negedge axil_rst_n) begin
         if (!axil_rst_n) begin
           r_axi_msi_err_inj_cntr <= 1'd0;
         end else begin
           if (axi_msi_err_inj_cntr_en)
             r_axi_msi_err_inj_cntr <= c_axi_msi_err_inj_cntr;
         end
       end


       assign axi_msi_err_inj_cntr_hist_en = r_axi_msi_err_inj_cntr || (r_axi_msi_err_inj_cntr_hist > 4'h0);
       assign c_axi_msi_err_inj_cntr_hist = r_axi_msi_err_inj_cntr ? ASF_ERR_INJ_QACTIVE_EXTENSION_CYCLES :
                                             (r_axi_msi_err_inj_cntr_hist > 4'h0) ? (r_axi_msi_err_inj_cntr_hist - 4'd1) :
                                                                                    r_axi_msi_err_inj_cntr_hist;
       always @(posedge axil_clk or negedge axil_rst_n) begin
         if (!axil_rst_n) begin
           r_axi_msi_err_inj_cntr_hist <= 4'd0;
         end else if (axi_msi_err_inj_cntr_hist_en)begin
           r_axi_msi_err_inj_cntr_hist <=  c_axi_msi_err_inj_cntr_hist;
         end
       end
       // Added hysteresis to make sure that event is synchronized back .
       assign axi_msi_qactive_err_inj = sub_block_error_inj__cmd_tvalid ||
                                        r_axi_msi_err_inj_cntr ||
                                       (r_axi_msi_err_inj_cntr_hist != 4'd0);

      end
      else begin :  no_axi_cdc_error_inj
       assign sub_block_error_inj__cdc_cmd_tvalid       = 1'b0;
       assign sub_block_error_inj__cdc_tdata            = 56'd0;
       assign sub_block_error_inj__cdc_tuser            = 8'd0;
       assign axi_msi_qactive_err_inj                   = 1'b0;
      end
      /* Checkers */

      // <mkdocs_chk_data> ID: 126 ; Checker Name: i_asf_csr_w_errinj_dap ; ASF Group: DAP
      // <mkdocs_chk_data> ID: 127 ; Checker Name: i_asf_csr_w_errinj_csr ; ASF Group: CSR
      asf_csr_w_errinj #(
  //     .ASF_EI_ADDR_WIDTH                             (16), // AXIL_ADDR_WIDTH
       .ASF_SUPPORT                                   (ASF_SUPPORT),   // = 3,
       .ASF_NODE_ID                                   (ASF_NODE_ID_BASE[15:0] +16'd126), // = 16 (HLS Bridge offset) + 126 (node ID),
       .CSR_ASF_NODE_ID                               (ASF_NODE_ID_BASE[15:0] +16'd126), // = 16 (HLS Bridge offset) + 126 (node ID),
       .DAP_ASF_NODE_ID                               (ASF_NODE_ID_BASE[15:0] +16'd127), // = 16 (HLS Bridge offset) + 127 (node ID),
       .ASF_ERR_INJ_SUPPORT                           (ASF_ERR_INJ_SUPPORT)    // = 1,
      ) i_asf_csr_w_errinj (
       .clk                             (core_clk),                 // input
       .rst_n                           (core_rst_n),               // input

       .asf_error_inj__cmd_tvalid_i     (sub_block_error_inj__cmd_tvalid), // input
       .asf_error_inj__tdata_i          (sub_block_error_inj__tdata),      // input [55:0]
       .asf_error_inj__tuser_i          (sub_block_error_inj__tuser),      // input [7:0]

       .asf_csr_injection_valid         (asf_csr_injection_valid),
       .asf_csr_injection_addr          (asf_csr_injection_addr),
       .asf_csr_injection_index         (asf_csr_injection_index),

       .asf_csr_injection_validchk      (asf_csr_injection_validchk),
       .asf_csr_injection_addrchk       (asf_csr_injection_addrchk),
       .asf_csr_injection_indexchk      (asf_csr_injection_indexchk),

       .asf_csr_notify_ready            (asf_csr_notify_ready),
       .asf_csr_notify_valid            (asf_csr_notify_valid),
       .asf_csr_notify_addr             (asf_csr_notify_addr),

       .asf_csr_notify_readychk         (asf_csr_notify_readychk),
       .asf_csr_notify_validchk         (asf_csr_notify_validchk),
       .asf_csr_notify_addrchk          (asf_csr_notify_addrchk),

       .asf_event__valid_o              (asf_event__valid_csr),
       .asf_event__type_o               (asf_event__type_csr),
       .asf_event__count_o              (asf_event__count_csr),
       .asf_event__node_id_o            (asf_event__node_id_csr),
       .asf_event__diag_field_o         (asf_event__diag_field_csr)
      );

      asf_event_collector #(
       .ASF_SUPPORT                                   (ASF_SUPPORT),  // = 3,
       .NUM_IN_PORTS                                  (
                                                       DC_ASF_EVENT_VALID_WIDTH    + /*asf_event__valid_dc_m_tvalid*/
                                                       DC_ASF_EVENT_VALID_WIDTH    + /*asf_event__valid_dc_m_tdata*/
                                                       CTAG_ASF_EVENT_VALID_WIDTH  + /*asf_event__valid_lti_c_tx_tvalid*/
                                                       CTAG_ASF_EVENT_VALID_WIDTH  + /*asf_event__valid_lti_c_tx_tdata*/
                                                       QOS_ASF_EVENT_VALID_WIDTH   + /*asf_event__valid_qos_tvalid*/
                                                       QOS_ASF_EVENT_VALID_WIDTH   + /*asf_event__valid_qos_tdata*/
                                                       1                           + /*asf_event__valid_msi_tvalid*/
                                                       1                           + /*asf_event__valid_csr*/
                                                       MAX_IB_P_NUM_OF_ASF_IF        +
                                                       MAX_IB_NP_NUM_OF_ASF_IF        +
                                                       MAX_IB_C_NUM_OF_ASF_IF        +
                                                       MAX_OB_P_NUM_OF_ASF_IF        +
                                                       MAX_OB_NP_NUM_OF_ASF_IF        +
                                                       MAX_OB_C_NUM_OF_ASF_IF        
                                                       )
      ) i_asf_event_collector_core_clk (
       .clk                             (core_clk),
       .rst_n                           (core_rst_n),
       .asf_event__tdata_o              (asf_event__tdata_o),
       .asf_event__tdatachk_o           (asf_event__tdatachk_o),
       .asf_event__tvalid_o             (asf_event__tvalid_o),
       .asf_event__tvalidchk_o          (asf_event__tvalidchk_o),
       .asf_event__tuser_o              (asf_event__tuser_o),
       .asf_event__tuserchk_o           (asf_event__tuserchk_o),
       .asf_event__tready_i             (1'b1),

       .asf_event__valid_i              (
                                         {
                                          asf_event__valid_dc_m_tvalid,
                                          asf_event__valid_dc_m_tdata,
                                          asf_event__valid_lti_c_tx_tvalid,
                                          asf_event__valid_lti_c_tx_tdata,
                                          asf_event__valid_msi_tvalid,
                                          asf_event__valid_csr,
                                          asf_event__valid_qos_tvalid,
                                          asf_event__valid_qos_tdata,
                                          asf_event__stored_ff_cntl_ib_p_valid,
                                          asf_event__msi_ib_p_valid,
                                          asf_event__stored_ff_cntl_ib_np_valid,
                                          asf_event__stored_ff_cntl_ib_c_valid,
                                          asf_event__hls_cntl_labeled_axi_ob_p_valid,
                                          asf_event__hls_cntl_labeled_dti_ob_p_valid,
                                          asf_event__hls_ob_gearbox_packer_data_ob_p_valid,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_p_valid,
                                          asf_event__hls_ob_gearbox_masker_data_ob_p_valid,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_p_valid,
                                          asf_event__hls_cntl_labeled_axi_ob_np_valid,
                                          asf_event__hls_ob_gearbox_packer_data_ob_np_valid,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_np_valid,
                                          asf_event__hls_ob_gearbox_masker_data_ob_np_valid,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_np_valid,
                                          asf_event__hls_cntl_labeled_axi_ob_c_valid,
                                          asf_event__hls_cntl_labeled_dti_ob_c_valid,
                                          asf_event__hls_ob_gearbox_packer_data_ob_c_valid,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_c_valid,
                                          asf_event__hls_ob_gearbox_masker_data_ob_c_valid,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_c_valid
                                          }
                                         ),
       .asf_event__type_i               (
                                         {
                                          asf_event__type_dc_m_tvalid,
                                          asf_event__type_dc_m_tdata,
                                          asf_event__type_lti_c_tx_tvalid,
                                          asf_event__type_lti_c_tx_tdata,
                                          asf_event__type_msi_tvalid,
                                          asf_event__type_csr,
                                          asf_event__type_qos_tvalid,
                                          asf_event__type_qos_tdata,
                                          asf_event__stored_ff_cntl_ib_p_type,
                                          asf_event__msi_ib_p_type,
                                          asf_event__stored_ff_cntl_ib_np_type,
                                          asf_event__stored_ff_cntl_ib_c_type,
                                          asf_event__hls_cntl_labeled_axi_ob_p_type,
                                          asf_event__hls_cntl_labeled_dti_ob_p_type,
                                          asf_event__hls_ob_gearbox_packer_data_ob_p_type,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_p_type,
                                          asf_event__hls_ob_gearbox_masker_data_ob_p_type,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_p_type,
                                          asf_event__hls_cntl_labeled_axi_ob_np_type,
                                          asf_event__hls_ob_gearbox_packer_data_ob_np_type,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_np_type,
                                          asf_event__hls_ob_gearbox_masker_data_ob_np_type,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_np_type,
                                          asf_event__hls_cntl_labeled_axi_ob_c_type,
                                          asf_event__hls_cntl_labeled_dti_ob_c_type,
                                          asf_event__hls_ob_gearbox_packer_data_ob_c_type,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_c_type,
                                          asf_event__hls_ob_gearbox_masker_data_ob_c_type,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_c_type
                                          }
                                         ),
       .asf_event__count_i              (
                                         {
                                          asf_event__count_dc_m_tvalid,
                                          asf_event__count_dc_m_tdata,
                                          asf_event__count_lti_c_tx_tvalid,
                                          asf_event__count_lti_c_tx_tdata,
                                          asf_event__count_msi_tvalid,
                                          asf_event__count_csr,
                                          asf_event__count_qos_tvalid,
                                          asf_event__count_qos_tdata,
                                          asf_event__stored_ff_cntl_ib_p_count,
                                          asf_event__msi_ib_p_count,
                                          asf_event__stored_ff_cntl_ib_np_count,
                                          asf_event__stored_ff_cntl_ib_c_count,
                                          asf_event__hls_cntl_labeled_axi_ob_p_count,
                                          asf_event__hls_cntl_labeled_dti_ob_p_count,
                                          asf_event__hls_ob_gearbox_packer_data_ob_p_count,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_p_count,
                                          asf_event__hls_ob_gearbox_masker_data_ob_p_count,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_p_count,
                                          asf_event__hls_cntl_labeled_axi_ob_np_count,
                                          asf_event__hls_ob_gearbox_packer_data_ob_np_count,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_np_count,
                                          asf_event__hls_ob_gearbox_masker_data_ob_np_count,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_np_count,
                                          asf_event__hls_cntl_labeled_axi_ob_c_count,
                                          asf_event__hls_cntl_labeled_dti_ob_c_count,
                                          asf_event__hls_ob_gearbox_packer_data_ob_c_count,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_c_count,
                                          asf_event__hls_ob_gearbox_masker_data_ob_c_count,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_c_count
                                          }
                                         ),
       .asf_event__node_id_i            (
                                         {
                                          asf_event__node_id_dc_m_tvalid,
                                          asf_event__node_id_dc_m_tdata,
                                          asf_event__node_id_lti_c_tx_tvalid,
                                          asf_event__node_id_lti_c_tx_tdata,
                                          asf_event__node_id_msi_tvalid,
                                          asf_event__node_id_csr,
                                          asf_event__node_id_qos_tvalid,
                                          asf_event__node_id_qos_tdata,
                                          asf_event__stored_ff_cntl_ib_p_node_id,
                                          asf_event__msi_ib_p_node_id,
                                          asf_event__stored_ff_cntl_ib_np_node_id,
                                          asf_event__stored_ff_cntl_ib_c_node_id,
                                          asf_event__hls_cntl_labeled_axi_ob_p_node_id,
                                          asf_event__hls_cntl_labeled_dti_ob_p_node_id,
                                          asf_event__hls_ob_gearbox_packer_data_ob_p_node_id,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_p_node_id,
                                          asf_event__hls_ob_gearbox_masker_data_ob_p_node_id,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_p_node_id,
                                          asf_event__hls_cntl_labeled_axi_ob_np_node_id,
                                          asf_event__hls_ob_gearbox_packer_data_ob_np_node_id,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_np_node_id,
                                          asf_event__hls_ob_gearbox_masker_data_ob_np_node_id,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_np_node_id,
                                          asf_event__hls_cntl_labeled_axi_ob_c_node_id,
                                          asf_event__hls_cntl_labeled_dti_ob_c_node_id,
                                          asf_event__hls_ob_gearbox_packer_data_ob_c_node_id,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_c_node_id,
                                          asf_event__hls_ob_gearbox_masker_data_ob_c_node_id,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_c_node_id
                                          }
                                         ),
       .asf_event__diag_field_i         (
                                         {
                                          asf_event__diag_field_dc_m_tvalid,
                                          asf_event__diag_field_dc_m_tdata,
                                          asf_event__diag_field_lti_c_tx_tvalid,
                                          asf_event__diag_field_lti_c_tx_tdata,
                                          asf_event__diag_field_msi_tvalid,
                                          asf_event__diag_field_csr,
                                          asf_event__diag_field_qos_tvalid,
                                          asf_event__diag_field_qos_tdata,
                                          asf_event__stored_ff_cntl_ib_p_diag_field,
                                          asf_event__msi_ib_p_diag_field,
                                          asf_event__stored_ff_cntl_ib_np_diag_field,
                                          asf_event__stored_ff_cntl_ib_c_diag_field,
                                          asf_event__hls_cntl_labeled_axi_ob_p_diag_field,
                                          asf_event__hls_cntl_labeled_dti_ob_p_diag_field,
                                          asf_event__hls_ob_gearbox_packer_data_ob_p_diag_field,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_p_diag_field,
                                          asf_event__hls_ob_gearbox_masker_data_ob_p_diag_field,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_p_diag_field,
                                          asf_event__hls_cntl_labeled_axi_ob_np_diag_field,
                                          asf_event__hls_ob_gearbox_packer_data_ob_np_diag_field,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_np_diag_field,
                                          asf_event__hls_ob_gearbox_masker_data_ob_np_diag_field,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_np_diag_field,
                                          asf_event__hls_cntl_labeled_axi_ob_c_diag_field,
                                          asf_event__hls_cntl_labeled_dti_ob_c_diag_field,
                                          asf_event__hls_ob_gearbox_packer_data_ob_c_diag_field,
                                          asf_event__hls_ob_gearbox_packer_cntl_ob_c_diag_field,
                                          asf_event__hls_ob_gearbox_masker_data_ob_c_diag_field,
                                          asf_event__hls_ob_gearbox_masker_cntl_ob_c_diag_field
                                          }
                                         )
      );

      wire asf_event_ready;
      assign asf_event_ready = asf_event__tvalid_o | asf_diag__synced_tvalid_o;

      asf_event_collector_w_diag_inputs #(
        .ASF_SUPPORT                           (ASF_SUPPORT), //1
        //.DIAG_PAR_CHK_ERR_NODE_ID              (), // 16'hFF00
        .NUM_IN_PORTS                               (  3                               +
                                                       MAX_IB_P_NUM_OF_ASF_ALIGNER_IF  +
                                                       MAX_IB_NP_NUM_OF_ASF_ALIGNER_IF +
                                                       MAX_IB_C_NUM_OF_ASF_ALIGNER_IF  +
                                                       MAX_OB_P_NUM_OF_ASF_ALIGNER_IF  +
                                                       MAX_OB_NP_NUM_OF_ASF_ALIGNER_IF +
                                                       MAX_OB_C_NUM_OF_ASF_ALIGNER_IF
          ),
        .ASF_ERR_INJ_SUPPORT                   (ASF_ERR_INJ_SUPPORT), // 1
        .ASF_DIAG_INFO_DATA_WIDTH              (32), // 32
        .ASF_DIAG_INFO_USER_WIDTH              (48) // 48
        //.ENABLE_CHECK                          (1), // 1
      ) i_asf_event_collector_w_diag_inputs (
         .clk                                  (core_clk),//input
         .rst_n                                (core_rst_n),//input

          // Output I/F
         .asf_diag__info_tdata_o               (asf_diag__info_tdata_o),//output  [ASF_DIAG_INFO_DATA_WIDTH-1:0]
         .asf_diag__info_tvalid_o              (asf_diag__info_tvalid_o),//output
         .asf_diag__info_tuser_o               (asf_diag__info_tuser_o),//output [ASF_DIAG_INFO_USER_WIDTH-1:0]
         .asf_diag__info_tready_i              (1'b1),//input
         // .asf_diag__info_tready_i              (asf_event_ready),//input
         .asf_diag__info_tdatachk_o            (asf_diag__info_tdatachk_o),//output [ASF_DIAG_DATA_CHK_WIDTH-1 :0]
         .asf_diag__info_tuserchk_o            (asf_diag__info_tuserchk_o),//output [ASF_DIAG_USER_CHK_WIDTH-1:0]
         .asf_diag__info_tvalidchk_o           (asf_diag__info_tvalidchk_o),//output

         // Input I/F
         .asf_diag__info_tdata_i               ({asf_event__tdata_o    ,
                                                 asf_diag__synced_tdata_o,
                                                 asf_diag__info_dti_tdata_o,
                                                 asf_event__aligner_axi_ib_p_tdata_o,
                                                 asf_event__aligner_dti_ib_p_tdata_o,
                                                 asf_event__gearbox_axi_ib_p_tdata_o,
                                                 asf_event__ob_main_aligner_ob_p_tdata_o,
                                                 asf_event__ob_gearbox_aligner_ob_p_tdata_o,
                                                 asf_event__aligner_axi_ib_np_tdata_o,
                                                 asf_event__aligner_dti_ib_np_tdata_o,
                                                 asf_event__gearbox_axi_ib_np_tdata_o,
                                                 asf_event__ob_main_aligner_ob_np_tdata_o,
                                                 asf_event__ob_gearbox_aligner_ob_np_tdata_o,
                                                 asf_event__aligner_axi_ib_c_tdata_o,
                                                 asf_event__gearbox_axi_ib_c_tdata_o,
                                                 asf_event__ob_main_aligner_ob_c_tdata_o,
                                                 asf_event__ob_gearbox_aligner_ob_c_tdata_o
                                                 }),
         .asf_diag__info_tdatachk_i            ({asf_event__tdatachk_o ,
                                                 asf_diag__synced_tdatachk_o,
                                                 asf_diag__info_dti_tdatachk_o,
                                                 asf_event__aligner_axi_ib_p_tdatachk_o,
                                                 asf_event__aligner_dti_ib_p_tdatachk_o,
                                                 asf_event__gearbox_axi_ib_p_tdatachk_o,
                                                 asf_event__ob_main_aligner_ob_p_tdatachk_o,
                                                 asf_event__ob_gearbox_aligner_ob_p_tdatachk_o,
                                                 asf_event__aligner_axi_ib_np_tdatachk_o,
                                                 asf_event__aligner_dti_ib_np_tdatachk_o,
                                                 asf_event__gearbox_axi_ib_np_tdatachk_o,
                                                 asf_event__ob_main_aligner_ob_np_tdatachk_o,
                                                 asf_event__ob_gearbox_aligner_ob_np_tdatachk_o,
                                                 asf_event__aligner_axi_ib_c_tdatachk_o,
                                                 asf_event__gearbox_axi_ib_c_tdatachk_o,
                                                 asf_event__ob_main_aligner_ob_c_tdatachk_o,
                                                 asf_event__ob_gearbox_aligner_ob_c_tdatachk_o
                                                }),
         .asf_diag__info_tvalid_i              ({asf_event__tvalid_o   ,
                                                 asf_diag__synced_tvalid_o,
                                                 asf_diag__info_dti_tvalid_o ,
                                                 asf_event__aligner_axi_ib_p_tvalid_o,
                                                 asf_event__aligner_dti_ib_p_tvalid_o,
                                                 asf_event__gearbox_axi_ib_p_tvalid_o,
                                                 asf_event__ob_main_aligner_ob_p_tvalid_o,
                                                 asf_event__ob_gearbox_aligner_ob_p_tvalid_o,
                                                 asf_event__aligner_axi_ib_np_tvalid_o,
                                                 asf_event__aligner_dti_ib_np_tvalid_o,
                                                 asf_event__gearbox_axi_ib_np_tvalid_o,
                                                 asf_event__ob_main_aligner_ob_np_tvalid_o,
                                                 asf_event__ob_gearbox_aligner_ob_np_tvalid_o,
                                                 asf_event__aligner_axi_ib_c_tvalid_o,
                                                 asf_event__gearbox_axi_ib_c_tvalid_o,
                                                 asf_event__ob_main_aligner_ob_c_tvalid_o,
                                                 asf_event__ob_gearbox_aligner_ob_c_tvalid_o
                                                }),
         .asf_diag__info_tvalidchk_i           ({asf_event__tvalidchk_o,
                                                 asf_diag__synced_tvalidchk_o,
                                                 asf_diag__info_dti_tvalidchk_o,
                                                 asf_event__aligner_axi_ib_p_tvalidchk_o,
                                                 asf_event__aligner_dti_ib_p_tvalidchk_o,
                                                 asf_event__gearbox_axi_ib_p_tvalidchk_o,
                                                 asf_event__ob_main_aligner_ob_p_tvalidchk_o,
                                                 asf_event__ob_gearbox_aligner_ob_p_tvalidchk_o,
                                                 asf_event__aligner_axi_ib_np_tvalidchk_o,
                                                 asf_event__aligner_dti_ib_np_tvalidchk_o,
                                                 asf_event__gearbox_axi_ib_np_tvalidchk_o,
                                                 asf_event__ob_main_aligner_ob_np_tvalidchk_o,
                                                 asf_event__ob_gearbox_aligner_ob_np_tvalidchk_o,
                                                 asf_event__aligner_axi_ib_c_tvalidchk_o,
                                                 asf_event__gearbox_axi_ib_c_tvalidchk_o,
                                                 asf_event__ob_main_aligner_ob_c_tvalidchk_o,
                                                 asf_event__ob_gearbox_aligner_ob_c_tvalidchk_o
                                                 }),
         .asf_diag__info_tready_o              (                         ),
         .asf_diag__info_tuser_i               ({asf_event__tuser_o    ,
                                                 asf_diag__synced_tuser_o,
                                                 asf_diag__info_dti_tuser_o,
                                                 asf_event__aligner_axi_ib_p_tuser_o,
                                                 asf_event__aligner_dti_ib_p_tuser_o,
                                                 asf_event__gearbox_axi_ib_p_tuser_o,
                                                 asf_event__ob_main_aligner_ob_p_tuser_o,
                                                 asf_event__ob_gearbox_aligner_ob_p_tuser_o,
                                                 asf_event__aligner_axi_ib_np_tuser_o,
                                                 asf_event__aligner_dti_ib_np_tuser_o,
                                                 asf_event__gearbox_axi_ib_np_tuser_o,
                                                 asf_event__ob_main_aligner_ob_np_tuser_o,
                                                 asf_event__ob_gearbox_aligner_ob_np_tuser_o,
                                                 asf_event__aligner_axi_ib_c_tuser_o,
                                                 asf_event__gearbox_axi_ib_c_tuser_o,
                                                 asf_event__ob_main_aligner_ob_c_tuser_o,
                                                 asf_event__ob_gearbox_aligner_ob_c_tuser_o
                                                 }),
         .asf_diag__info_tuserchk_i            ({asf_event__tuserchk_o ,
                                                 asf_diag__synced_tuserchk_o,
                                                 asf_diag__info_dti_tuserchk_o,
                                                 asf_event__aligner_axi_ib_p_tuserchk_o,
                                                 asf_event__aligner_dti_ib_p_tuserchk_o,
                                                 asf_event__gearbox_axi_ib_p_tuserchk_o,
                                                 asf_event__ob_main_aligner_ob_p_tuserchk_o,
                                                 asf_event__ob_gearbox_aligner_ob_p_tuserchk_o,
                                                 asf_event__aligner_axi_ib_np_tuserchk_o,
                                                 asf_event__aligner_dti_ib_np_tuserchk_o,
                                                 asf_event__gearbox_axi_ib_np_tuserchk_o,
                                                 asf_event__ob_main_aligner_ob_np_tuserchk_o,
                                                 asf_event__ob_gearbox_aligner_ob_np_tuserchk_o,
                                                 asf_event__aligner_axi_ib_c_tuserchk_o,
                                                 asf_event__gearbox_axi_ib_c_tuserchk_o,
                                                 asf_event__ob_main_aligner_ob_c_tuserchk_o,
                                                 asf_event__ob_gearbox_aligner_ob_c_tuserchk_o
                                                 })
      );

      if (KMAX_MSI_IF_SUPPORT == 1) begin : on_axi_asf_event_collectre
        asf_event_collector #(
         .ASF_SUPPORT                                   (ASF_SUPPORT),  // = 3,
         .NUM_IN_PORTS                                  (KMAX_MSI_IF_SUPPORT)
         ) i_asf_event_collector_axi_clk (
         .clk                             (axi_msi_clk),                 // input
         .rst_n                           (axi_msi_rst_n),               // input

         .asf_event__tdata_o              (asf_event__axi_tdata_o),
         .asf_event__tdatachk_o           (asf_event__axi_tdatachk_o),
         .asf_event__tvalid_o             (asf_event__axi_tvalid_o),
         .asf_event__tvalidchk_o          (asf_event__axi_tvalidchk_o),
         .asf_event__tuser_o              (asf_event__axi_tuser_o),
         .asf_event__tuserchk_o           (asf_event__axi_tuserchk_o),
         .asf_event__tready_i             (1'b1),

         .asf_event__valid_i              (asf_event__valid_msi_tdata),
         .asf_event__type_i               (asf_event__type_msi_tdata),
         .asf_event__count_i              (asf_event__count_msi_tdata),
         .asf_event__node_id_i            (asf_event__node_id_msi_tdata),
         .asf_event__diag_field_i         (asf_event__diag_field_msi_tdata)
        );

        asf_event_cdc i_asf_event_cdc (
         .src_clk                              (axi_msi_clk),                       // input
         .src_rst_n                            (axi_msi_rst_n),                     // input
         .dst_clk                              (core_clk),                             // input
         .dst_rst_n                            (core_rst_n),                            // input
         .k_sync_reset                         (k_sync_reset),                          // input
         .k_number_of_flop_stages_in_sync_cell ({1'b0,k_sync_cell_stages}),             // input

         .asf_event__tdata_i                   (asf_event__axi_tdata_o),
         .asf_event__tdatachk_i                (asf_event__axi_tdatachk_o),
         .asf_event__tvalid_i                  (asf_event__axi_tvalid_o),
         .asf_event__tvalidchk_i               (asf_event__axi_tvalidchk_o),
         .asf_event__tuser_i                   (asf_event__axi_tuser_o),
         .asf_event__tuserchk_i                (asf_event__axi_tuserchk_o),
         .asf_event__tready_o                  (),
         //.asf_event__tready_o                  (asf_event__tready_o),

         .asf_diag__info_tdata_o               (asf_diag__synced_tdata_o),
         .asf_diag__info_tdatachk_o            (asf_diag__synced_tdatachk_o),
         .asf_diag__info_tvalid_o              (asf_diag__synced_tvalid_o),
         .asf_diag__info_tvalidchk_o           (asf_diag__synced_tvalidchk_o),
         .asf_diag__info_tuser_o               (asf_diag__synced_tuser_o),
         .asf_diag__info_tuserchk_o            (asf_diag__synced_tuserchk_o),
         .asf_diag__info_tready_i              (1'b1)
        );
       end  // KMAX_MSI_IF_SUPPORT  - ON

       else begin : off_axi_asf_event_collectre
         assign asf_diag__synced_tdata_o     = 32'h0;
         assign asf_diag__synced_tdatachk_o  = 4'hf;
         assign asf_diag__synced_tready_o  = 4'hf;
         assign asf_diag__synced_tvalid_o    = 1'h0;
         assign asf_diag__synced_tvalidchk_o = 1'h1;
         assign asf_diag__synced_tuser_o     = 48'h0;
         assign asf_diag__synced_tuserchk_o  = 6'h3f;
       end  // KMAX_MSI_IF_SUPPORT  - OFF
    end  // ASF_SUPPORT - ON

    else begin : i_non_asf_gen
  //    assign asf_error_inj__cmd_tready                 = 1'b0;
      assign sub_block_error_inj__cmd_tvalid           = 1'b0;
      assign sub_block_error_inj__tdata                = 56'd0;
      assign sub_block_error_inj__tuser                = 8'd0;
      assign asf_errinj_chk_err                        = 1'b0;
      assign axi_msi_qactive_err_inj                   = 1'b0;
      assign sub_block_error_inj__cdc_cmd_tvalid_o     = 1'b0;
      assign sub_block_error_inj__cdc_tdata_o          = 56'd0;
      assign sub_block_error_inj__cdc_tuser_o          = 8'd0;
      assign sub_block_error_inj__cdc_cmd_tvalid       = 1'b0;
      assign sub_block_error_inj__cdc_tdata            = 56'd0;
      assign sub_block_error_inj__cdc_tuser            = 8'd0;
      assign asf_event__valid_o                        = 1'b0;
      assign asf_event__type_o                         = 4'd0;
      assign asf_event__count_o                        = 8'd0;
      assign asf_event__node_id_o                      = 16'd0;
      assign asf_event__diag_field_o                   = 28'd0;
      assign asf_event__tdata_o                        = 32'd0;
      assign asf_event__tdatachk_o                     = 4'd0;
      assign asf_event__tvalid_o                       = 1'b0;
      assign asf_event__tvalidchk_o                    = 1'b0;
      assign asf_event__tuser_o                        = 48'd0;
      assign asf_event__tuserchk_o                     = 6'd0;
      assign asf_csr_injection_valid                   = 1'b0;
      assign asf_csr_injection_addr                    = 27'd0;
      assign asf_csr_injection_index                   = 6'd0;
      assign asf_csr_injection_validchk                = 1'b0;
      assign asf_csr_injection_addrchk                 = 4'd0;
      assign asf_csr_injection_indexchk                = 1'b0;
      assign asf_csr_notify_ready                      = 1'b0;
//      assign asf_csr_notify_valid                      = 1'b0;
//      assign asf_csr_notify_addr                       = 27'd0;
      assign asf_csr_notify_readychk                   = 1'b0;
//      assign asf_csr_notify_validchk                   = 1'b0;
//      assign asf_csr_notify_addrchk                    = 4'd0;
      assign asf_event__valid_csr                      = 1'b0;
      assign asf_event__type_csr                       = 4'd0;
      assign asf_event__count_csr                      = 8'd0;
      assign asf_event__node_id_csr                    = 16'd0;
      assign asf_event__diag_field_csr                 = 28'd0;
//      assign asf_event__valid_dc_m_tvalid              = {DC_ASF_EVENT_VALID_WIDTH{1'b0}};
//      assign asf_event__type_dc_m_tvalid               = {DC_ASF_EVENT_TYPE_WIDTH{1'b0}} ;
//      assign asf_event__count_dc_m_tvalid              = {DC_ASF_EVENT_COUNT_WIDTH{1'b0}};
//      assign asf_event__node_id_dc_m_tvalid            = {DC_ASF_NODE_ID_WIDTH{1'b0}}    ;
//      assign asf_event__diag_field_dc_m_tvalid         = {DC_ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
//      assign asf_event__valid_dc_m_tdata               = {DC_ASF_EVENT_VALID_WIDTH{1'b0}};
//      assign asf_event__type_dc_m_tdata                = {DC_ASF_EVENT_TYPE_WIDTH{1'b0}} ;
//      assign asf_event__count_dc_m_tdata               = {DC_ASF_EVENT_COUNT_WIDTH{1'b0}};
//      assign asf_event__node_id_dc_m_tdata             = {DC_ASF_NODE_ID_WIDTH{1'b0}}    ;
//      assign asf_event__diag_field_dc_m_tdata          = {DC_ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
//      assign asf_event__valid_lti_c_tx_tvalid          = {CTAG_ASF_EVENT_VALID_WIDTH{1'b0}};
//      assign asf_event__type_lti_c_tx_tvalid           = {CTAG_ASF_EVENT_TYPE_WIDTH{1'b0}} ;
//      assign asf_event__count_lti_c_tx_tvalid          = {CTAG_ASF_EVENT_COUNT_WIDTH{1'b0}};
//      assign asf_event__node_id_lti_c_tx_tvalid        = {CTAG_ASF_NODE_ID_WIDTH{1'b0}}    ;
//      assign asf_event__diag_field_lti_c_tx_tvalid     = {CTAG_ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
//      assign asf_event__valid_lti_c_tx_tdata           = {CTAG_ASF_EVENT_VALID_WIDTH{1'b0}};
//      assign asf_event__type_lti_c_tx_tdata            = {CTAG_ASF_EVENT_TYPE_WIDTH{1'b0}} ;
//      assign asf_event__count_lti_c_tx_tdata           = {CTAG_ASF_EVENT_COUNT_WIDTH{1'b0}};
//      assign asf_event__node_id_lti_c_tx_tdata         = {CTAG_ASF_NODE_ID_WIDTH{1'b0}}    ;
//      assign asf_event__diag_field_lti_c_tx_tdata      = {CTAG_ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};

//      assign asf_event__aligner_ib_p_tdata_o       = 32'd0;
//      assign asf_event__aligner_ib_p_tdatachk_o    = 4'hf;
//      assign asf_event__aligner_ib_p_tvalid_o      = 'h0;
//      assign asf_event__aligner_ib_p_tvalidchk_o   = 'h1;
//      assign asf_event__aligner_ib_p_tuser_o       = 48'd0;
//      assign asf_event__aligner_ib_p_tuserchk_o    = 6'h3f;
//
//      assign asf_event__aligner2dti_ib_p_tdata_o       = 32'd0;
//      assign asf_event__aligner2dti_ib_p_tdatachk_o    = 4'hf;
//      assign asf_event__aligner2dti_ib_p_tvalid_o      = 'h0;
//      assign asf_event__aligner2dti_ib_p_tvalidchk_o   = 'h1;
//      assign asf_event__aligner2dti_ib_p_tuser_o       = 48'd0;
//      assign asf_event__aligner2dti_ib_p_tuserchk_o    = 6'h3f;
//
//      assign asf_event__stored_ff_cntl_ib_p_valid           = {ASF_EVENT_VALID_WIDTH     {1'b0}};
//      assign asf_event__stored_ff_cntl_ib_p_type            = {ASF_EVENT_TYPE_WIDTH      {1'b0}};
//      assign asf_event__stored_ff_cntl_ib_p_count           = {ASF_EVENT_COUNT_WIDTH     {1'b0}};
//      assign asf_event__stored_ff_cntl_ib_p_node_id         = {ASF_NODE_ID_WIDTH         {1'b0}};
//      assign asf_event__stored_ff_cntl_ib_p_diag_field      = {ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
//
//      assign asf_event__stored_ff_cntl_ib_np_valid          = {ASF_EVENT_VALID_WIDTH     {1'b0}};
//      assign asf_event__stored_ff_cntl_ib_np_type           = {ASF_EVENT_TYPE_WIDTH      {1'b0}};
//      assign asf_event__stored_ff_cntl_ib_np_count          = {ASF_EVENT_COUNT_WIDTH     {1'b0}};
//      assign asf_event__stored_ff_cntl_ib_np_node_id        = {ASF_NODE_ID_WIDTH         {1'b0}};
//      assign asf_event__stored_ff_cntl_ib_np_diag_field     = {ASF_EVENT_DIAG_FIELD_WIDTH{1'b0}};
//
//      assign asf_event__aligner_ib_np_tdata_o      = 32'd0;
//      assign asf_event__aligner_ib_np_tdatachk_o   = 4'hf;
//      assign asf_event__aligner_ib_np_tvalid_o     = 'h0;
//      assign asf_event__aligner_ib_np_tvalidchk_o  = 'h1;
//      assign asf_event__aligner_ib_np_tuser_o      = 48'd0;
//      assign asf_event__aligner_ib_np_tuserchk_o   = 6'h3f;
//
//      assign asf_event__aligner2dti_ib_np_tdata_o      = 32'd0;
//      assign asf_event__aligner2dti_ib_np_tdatachk_o   = 4'hf;
//      assign asf_event__aligner2dti_ib_np_tvalid_o     = 'h0;
//      assign asf_event__aligner2dti_ib_np_tvalidchk_o  = 'h1;
//      assign asf_event__aligner2dti_ib_np_tuser_o      = 48'd0;
//      assign asf_event__aligner2dti_ib_np_tuserchk_o   = 6'h3f;

//      assign asf_event__ob_main_aligner_ob_p_tdata_o                   = 32'd0;
//      assign asf_event__ob_main_aligner_ob_p_tdatachk_o                = 4'hf;
//      assign asf_event__ob_main_aligner_ob_p_tvalid_o                  = 'h0;
//      assign asf_event__ob_main_aligner_ob_p_tvalidchk_o               = 'h1;
//      assign asf_event__ob_main_aligner_ob_p_tuser_o                   = 48'd0;
//      assign asf_event__ob_main_aligner_ob_p_tuserchk_o                = 6'h3f;
//
//      assign asf_event__ob_main_aligner_ob_c_tdata_o                   = 32'd0;
//      assign asf_event__ob_main_aligner_ob_c_tdatachk_o                = 4'hf;
//      assign asf_event__ob_main_aligner_ob_c_tvalid_o                  = 'h0;
//      assign asf_event__ob_main_aligner_ob_c_tvalidchk_o               = 'h1;
//      assign asf_event__ob_main_aligner_ob_c_tuser_o                   = 48'd0;
//      assign asf_event__ob_main_aligner_ob_c_tuserchk_o                = 6'h3f;

//      assign asf_diag__info_tready_o                   = 1'b0;
      assign asf_diag__info_tdata_o                    = 32'd0;
      assign asf_diag__info_tdatachk_o                 = 4'd0;
      assign asf_diag__info_tvalid_o                   = 1'b0;
      assign asf_diag__info_tvalidchk_o                = 1'b0;
      assign asf_diag__info_tuser_o                    = 48'd0;
      assign asf_diag__info_tuserchk_o                 = 6'd0;

      //assign ram_read_addr         = {TOK_TRANS_BIN_WIDTH{1'b0}};
      //assign ram_read_valid        = 1'b0;
      //assign ram_write_addr        = {TOK_TRANS_BIN_WIDTH{1'b0}};
      //assign ram_write_data        = {DTI_RAM_DATA_WIDTH{1'b0}};
      //assign ram_write_valid       = 1'b0;
      //assign tdata_dti_dn          = {DTI_TDATA_WIDTH{1'b0}};
      //assign tdata_dti_dn_chk      = {DTI_TDATA_CHK_WIDTH{1'b0}};
      //assign tkeep_dti_dn          = {DTI_TKEEP_WIDTH{1'b0}};
      //assign tkeep_dti_dn_chk      = {DTI_TKEEP_CHK_WIDTH{1'b0}};
      //assign tlast_dti_dn          = 1'b0;
      //assign tlast_dti_dn_chk      = 1'b0;
      //assign tlp_qos_tx_tdata      = {TLP_QOS_TDATA_WIDTH{1'b01}};
      //assign tlp_qos_tx_tdata_chk  = {TLP_QOS_TDATA_CHK_WIDTH{1'b0}};
      //assign tlp_qos_tx_tvalid     = 1'b0;
      //assign tlp_qos_tx_tvalid_chk = 1'b0;
      //assign tready_dti_up         = 1'b0;
      //assign tready_dti_up_chk     = 1'b0;
      //assign tstrb_dti_dn          = {DTI_TKEEP_WIDTH{1'b0}};
      //assign tstrb_dti_dn_chk      = {DTI_TKEEP_CHK_WIDTH{1'b0}};
      //assign tvalid_dti_dn         = 1'b0;
      //assign tvalid_dti_dn_chk     = 1'b0;
    end
 endgenerate

  assign dti_pri_supported     = hls_ib_posted_dti_pri_supported;
 `ifdef ABV_ON
   `define AXI_ABV_ON
  `endif

  `ifdef AXI_ABV_ON
//    property axi_num_tlps_per_clk;
//      @(posedge core_clk) disable iff (!core_rst_n || NUM_HLS_PORTS!=2)
//        ((KMAX_DATAPATH_WD==128  && KMAX_NUM_TLPS_PER_CLK==2) &&  HLS_PORT_TLPS_PER_CLK_ARR0==1 ||
//         (KMAX_DATAPATH_WD==128  && KMAX_NUM_TLPS_PER_CLK==1) &&  HLS_PORT_TLPS_PER_CLK_ARR0==1 ||
//         (KMAX_DATAPATH_WD==256  && KMAX_NUM_TLPS_PER_CLK==2) &&  HLS_PORT_TLPS_PER_CLK_ARR0==1 ||
//         (KMAX_DATAPATH_WD==256  && KMAX_NUM_TLPS_PER_CLK==2) &&  HLS_PORT_TLPS_PER_CLK_ARR0==2 ||  //<- TODO
//         (KMAX_DATAPATH_WD==256  && KMAX_NUM_TLPS_PER_CLK==1) &&  HLS_PORT_TLPS_PER_CLK_ARR0==1 ||
//         (KMAX_DATAPATH_WD==512  && KMAX_NUM_TLPS_PER_CLK==4) &&  HLS_PORT_TLPS_PER_CLK_ARR0==2 ||
//         (KMAX_DATAPATH_WD==512  && KMAX_NUM_TLPS_PER_CLK==2) &&  HLS_PORT_TLPS_PER_CLK_ARR0==2 ||
//         (KMAX_DATAPATH_WD==512  && KMAX_NUM_TLPS_PER_CLK==1) &&  HLS_PORT_TLPS_PER_CLK_ARR0==1 ||
//         (KMAX_DATAPATH_WD==1024 && KMAX_NUM_TLPS_PER_CLK==4) &&  HLS_PORT_TLPS_PER_CLK_ARR0==4 ||
//         (KMAX_DATAPATH_WD==1024 && KMAX_NUM_TLPS_PER_CLK==2) &&  HLS_PORT_TLPS_PER_CLK_ARR0==2 ||
//         (KMAX_DATAPATH_WD==1024 && KMAX_NUM_TLPS_PER_CLK==1) &&  HLS_PORT_TLPS_PER_CLK_ARR0==1
//        );
//    endproperty

//    property axi_num_tlps_per_clk_temp_disable;
//      @(posedge core_clk) disable iff (!core_rst_n || NUM_HLS_PORTS!=2)
//        ((KMAX_DATAPATH_WD==256 && KMAX_NUM_TLPS_PER_CLK==2) |-> HLS_PORT_TLPS_PER_CLK_ARR0!=2);
//    endproperty

//    a_not_supported_axi_num_tlps_per_clk  : assert property (axi_num_tlps_per_clk);
//    a_axi_num_tlps_per_clk_temp_disable   : assert property (axi_num_tlps_per_clk_temp_disable);
  `endif

endmodule
