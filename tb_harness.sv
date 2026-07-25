`ifndef CDN_PCIE_HLS_BRIDGE_TB_HARNESS_SV
`define CDN_PCIE_HLS_BRIDGE_TB_HARNESS_SV

`include "uvm_macros.svh"

// Use a `define for the module name
`ifndef HLS_BRIDGE_DUT_MODULE_NAME
  `define HLS_BRIDGE_DUT_MODULE_NAME hls_bridge_top
`endif

interface cdn_pcie_hls_bridge_tb_harness #(
  //---------------------------------------------------------------------------
  // Harness params
  //---------------------------------------------------------------------------
  parameter                          IS_ACTIVE                   = 1,
  parameter string                   HARNESS_NAME                = "cdn_pcie_hls_bridge_tb_harness",
  parameter                          ASF_SUPPORT                 = 0,
  parameter                          KMAX_MSI_IF_SUPPORT         = 0,
  parameter                          LTI_SUPPORT                 = 0,
  parameter                          NUM_HLS_PORTS               = 2,
  parameter [NUM_HLS_PORTS*32-1 : 0] HLS_PORT_DATA_WIDTH_ARR     = {NUM_HLS_PORTS{32'h00000400}},
  parameter [NUM_HLS_PORTS*32-1 : 0] HLS_PORT_TLPS_PER_CLK_ARR   = {NUM_HLS_PORTS{32'h00000004}},
  parameter                          KMAX_DATAPATH_WD            = 1024,
  parameter                          KMAX_NUM_TLPS_PER_CLK       = 4,
  parameter                          KMIN_START_ALIGNMENT_IN_DWS = 1,
  parameter                          HLS_TX_PNP_METADATA_WD      = 40,
  parameter                          HLS_TX_C_METADATA_WD        = 40,
  parameter                          HLS_RX_PNP_METADATA_WD      = 112,
  parameter                          HLS_RX_C_METADATA_WD        = 40,
  parameter                          HLS_AXI_PKT_CNTL_WD         = 48,
  parameter                          HLS_AXI_OB_PNP_CNTL_WD      = 208,
  parameter                          HLS_AXI_OB_PNP_CNTL_CHK_WD  = 26,
  parameter                          HLS_AXI_OB_C_CNTL_WD        = 208,
  parameter                          HLS_AXI_OB_C_CNTL_CHK_WD    = 26,
  parameter                          HLS_AXI_IB_PNP_CNTL_WD      = 496,
  parameter                          HLS_AXI_IB_PNP_CNTL_CHK_WD  = 62,
  parameter                          HLS_AXI_IB_C_CNTL_WD        = 208,
  parameter                          HLS_AXI_IB_C_CNTL_CHK_WD    = 26,
  parameter                          HLS_PKT_CNTL_WD             = 48,
  parameter                          HLS_HAL_OB_PNP_CNTL_WD      = 208,
  parameter                          HLS_HAL_OB_PNP_CNTL_CHK_WD  = 26,
  parameter                          HLS_HAL_OB_C_CNTL_WD        = 208,
  parameter                          HLS_HAL_OB_C_CNTL_CHK_WD    = 26,
  parameter                          HLS_HAL_IB_PNP_CNTL_WD      = 496,
  parameter                          HLS_HAL_IB_PNP_CNTL_CHK_WD  = 62,
  parameter                          HLS_HAL_IB_C_CNTL_WD        = 208,
  parameter                          HLS_HAL_IB_C_CNTL_CHK_WD    = 26,
  parameter                          NUM_LTI_PORTS               = 4,
  parameter                          KMAX_NUM_PFS                = 16,
  parameter                          NUM_TCS                     = 8,
  parameter                          TOK_INV_BIN_WIDTH           = 4,
  parameter                          RAM_READ_LATENCY_WIDTH      = 2,
  parameter                          TOK_TRANS_BIN_WIDTH         = 8,
  parameter                          AXIL_DATA_WIDTH             = 32,
  parameter                          AXIL_ADDR_WIDTH             = 32,
  parameter                          AXIL_S_ARUSER_WIDTH         = 1,
  parameter                          AXIL_S_AWUSER_WIDTH         = 1,
  parameter                          AXIL_S_BUSER_WIDTH          = 1,
  parameter                          AXIL_S_RUSER_WIDTH          = 1,
  parameter                          AXIL_S_WUSER_WIDTH          = 1,
  parameter                          HDR2LOG_TUSER_WIDTH         = 26,
  parameter                          HDR2LOG_TUSER_CHK_WIDTH     = 4,
  parameter                          DELIVERED_P_TDATA_WIDTH     = 16,
  parameter                          DELIVERED_P_TDATA_CHK_WIDTH = 2,
 parameter                          TLP_QOS_TDATA_WIDTH         = 24,
  parameter                          TLP_QOS_TDATA_CHK_WIDTH     = 3,  
  parameter                          LTI_C_TDATA_WIDTH           = 16,
  parameter                          LTI_C_TDATA_CHK_WIDTH       = 2,
  parameter                          KMAX_MSI_TDATA_WIDTH        = 64,
  parameter                          KMAX_NUM_VCS                = 4,
  parameter                          CRD_IN_LMT_HEADER_WIDTH     = 9,
  parameter                          CRD_IN_LMT_PAYLOAD_WIDTH    = 13,
  parameter                          CRD_IN_LMT_CNTL_WIDTH       = 6,
  parameter                          KMAX_IDE_NUM_LINK_STREAMS   = 8,
  parameter                          KMAX_IDE_NUM_SEL_STREAMS    = 8
);

  //------------------------------------------------------------------------
  // Import packages
  //------------------------------------------------------------------------
  import uvm_pkg::*;
  import cdn_pcie_tl_utils_pkg::*;
  import cdn_pcie_hls_bridge_dut_if_pkg::*;
  
  //------------------------------------------------------------------------
  // Interfaces for connection to the DUT
  //------------------------------------------------------------------------
  //------------------------------------------------------------------------
  // Constants, parameters & localparams
  //------------------------------------------------------------------------
  const string harness_instance_path = $sformatf("%m");

  localparam LOCAL_KMAX_DATAPATH_CHK_WD            = (KMAX_DATAPATH_WD + 7) / 8                     ;
  localparam LOCAL_HLS_PKT_CNTL_CHK_WD             = (HLS_PKT_CNTL_WD + 7) / 8                      ;
  localparam LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD     = HLS_TX_PNP_METADATA_WD * KMAX_NUM_TLPS_PER_CLK ;
  localparam LOCAL_HLS_HAL_OB_PNP_USER_CNTL_CHK_WD = (LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD + 7) / 8    ;
  localparam LOCAL_HLS_HAL_OB_C_USER_CNTL_WD       = HLS_TX_C_METADATA_WD * KMAX_NUM_TLPS_PER_CLK   ;
  localparam LOCAL_HLS_HAL_OB_C_USER_CNTL_CHK_WD   = (LOCAL_HLS_HAL_OB_C_USER_CNTL_WD + 7) / 8      ;
  localparam LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD     = HLS_RX_PNP_METADATA_WD * KMAX_NUM_TLPS_PER_CLK ;
  localparam LOCAL_HLS_HAL_IB_PNP_USER_CNTL_CHK_WD = (LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD + 7) / 8    ;
  localparam LOCAL_HLS_HAL_IB_C_USER_CNTL_WD       = HLS_RX_C_METADATA_WD * KMAX_NUM_TLPS_PER_CLK   ;
  localparam LOCAL_HLS_HAL_IB_C_USER_CNTL_CHK_WD   = (LOCAL_HLS_HAL_IB_C_USER_CNTL_WD + 7) / 8      ;
  localparam CRD_DW_COUNTER_WD                     = 16;
 `ifndef HLS_BRIDGE_MODULE
  localparam CONTROLLER_TOP_TB                     = 1                                              ;
`else
  localparam CONTROLLER_TOP_TB                     = 0                                              ;
`endif  
  //------------------------------------------------------------------------
  // Wires / Local variables
  //------------------------------------------------------------------------
  wire [HLS_HAL_IB_PNP_CNTL_WD-1 : 0] tb_hls_ib_posted_hal_cntl            ;
  wire [KMAX_DATAPATH_WD-1       : 0] tb_hls_ib_posted_hal_data            ;
  wire [HLS_HAL_IB_PNP_CNTL_WD-1 : 0] tb_hls_ib_nonposted_hal_cntl         ;
  wire [KMAX_DATAPATH_WD-1       : 0] tb_hls_ib_nonposted_hal_data         ;
  wire [HLS_HAL_IB_C_CNTL_WD-1   : 0] tb_hls_ib_compl_hal_cntl             ;
  wire [KMAX_DATAPATH_WD-1       : 0] tb_hls_ib_compl_hal_data             ;
  bit  [NUM_HLS_PORTS-1:0]            tb_local_uvm_db_set_done_per_hls_port;
    
  //------------------------------------------------------------------------
  // Clock 
  //------------------------------------------------------------------------
  cdn_clock_if i_clk_if ();

  generate
    if(IS_ACTIVE) begin : active_tb_clk_if
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_clk = i_clk_if.core_clk;


`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE

      assign `HLS_BRIDGE_DUT_MODULE_NAME.core_clk = i_misc_if.clk_gate ? 1 : i_clk_if.core_clk;

      cdn_pcie_hls_bridge_qactive_clk_gater #(
        .SYNC_STAGES(4)
      ) msi_qactive_clk_gater (
        .clk_in (i_clk_if.axi_clk)                            ,
        .rst_n  (`HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_rst_n)   ,
        .en     (`HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_qactive) ,
        .chk_en (1'b1)                                        ,
        .chk_clk(i_clk_if.core_clk)                           ,
        .clk_out(`HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_clk)
      );

      cdn_pcie_hls_bridge_qactive_clk_gater #(
        .SYNC_STAGES(4)
      ) dti_qactive_clk_gater (
        .clk_in (i_clk_if.axi_clk)                            ,
        .rst_n  (`HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_rst_n)   ,
        .en     (`HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_qactive) ,
        .chk_en (1'b0)                                        ,        // Totyo: Already verified at DTI level.
        .chk_clk(1'b0)                                        ,
        .clk_out(`HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk)
      );
`else // !`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
      assign `HLS_BRIDGE_DUT_MODULE_NAME.core_clk        = i_clk_if.core_clk    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_clk     = i_clk_if.axi_clk     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk     = i_clk_if.axi_clk     ;
`endif // !`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE

    end
    else begin : passive_tb_clk_if
      assign i_clk_if.core_clk    = `HLS_BRIDGE_DUT_MODULE_NAME.core_clk    ;
      assign i_clk_if.axi_clk     = `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_clk ; // TODO domethin by verif
//      assign i_clk_if.axi_clk     = `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk ;
      assign i_clk_if.sig_clock_0 = `HLS_BRIDGE_DUT_MODULE_NAME.axil_clk    ;
    end
  endgenerate


  //------------------------------------------------------------------------
  // Resets 
  //------------------------------------------------------------------------
  cdn_reset_if i_core_rst_if       ( i_clk_if.core_clk        );
  cdn_reset_if i_axi_msi_rst_if    ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_clk     );
  cdn_reset_if i_axi_dti_rst_if    ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk     );
  cdn_reset_if i_axil_rst_if       ( `HLS_BRIDGE_DUT_MODULE_NAME.axil_clk        );

  generate
    if(IS_ACTIVE) begin : active_tb_rst_if
      assign `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n        = i_core_rst_if.sig_reset        ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_rst_n     = i_axi_msi_rst_if.sig_reset         ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_rst_n     = i_axi_dti_rst_if.sig_reset  ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_rst_n        = i_axil_rst_if.sig_reset        ;
    end
    else begin : passive_tb_rst_if
      always @(*) begin //TODO Check if it could done in any other way.
        i_core_rst_if.driver_cb.sig_reset        <= `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n        ;
        i_axi_msi_rst_if.driver_cb.sig_reset     <= `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_rst_n         ;
        i_axi_dti_rst_if.driver_cb.sig_reset     <= `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_rst_n  ;
        i_axil_rst_if.driver_cb.sig_reset        <= `HLS_BRIDGE_DUT_MODULE_NAME.axil_rst_n        ;
      end
    end
  endgenerate

  //------------------------------------------------------------------------
  // Resets Coverage Interface.
  //------------------------------------------------------------------------
  cdn_pcie_rst_cov_if #(
    .NUMBER_OF_EVENTS( 1 )
  ) i_core_rst_cov_if (
    .clk  ( i_clk_if.core_clk   ),
    .rst_n( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
  );


  cdn_pcie_rst_cov_if #(
    .NUMBER_OF_EVENTS( 1 )
  ) i_axi_msi_rst_cov_if (
    .clk  ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_clk   ),
    .rst_n( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_rst_n )
  );

  cdn_pcie_rst_cov_if #(
    .NUMBER_OF_EVENTS( 1 )
  ) i_axi_dti_rst_cov_if (
    .clk  ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk   ),
    .rst_n( `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_rst_n )
  );

 

  cdn_pcie_rst_cov_if #(
    .NUMBER_OF_EVENTS( 1 )
  ) i_axil_rst_cov_if (
    .clk  ( `HLS_BRIDGE_DUT_MODULE_NAME.axil_clk   ),
    .rst_n( `HLS_BRIDGE_DUT_MODULE_NAME.axil_rst_n )
  );


  //------------------------------------------------------------------------
  // Global constant-wire (K-Wires).
  //------------------------------------------------------------------------
  cdn_pcie_hls_bridge_dut_k_if #(
    .TOK_INV_BIN_WIDTH                  ( TOK_INV_BIN_WIDTH                                       ),
    .RAM_READ_LATENCY_WIDTH             ( RAM_READ_LATENCY_WIDTH                                  ),
    .TOK_TRANS_BIN_WIDTH                ( TOK_TRANS_BIN_WIDTH                                     ),
    .NUM_HLS_PORTS                      ( parameters_cfg_pkg::NUM_HLS_PORTS                       ),
    .KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH( parameters_cfg_pkg::KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH )
  ) i_k_if (
    .clk  ( i_clk_if.core_clk   ),
    .rst_n( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
  );

  generate
    if(IS_ACTIVE) begin : active_tb_dut_k_if
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment              = i_k_if.k_hls_dw_alignment              ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_cxl_io_support                = i_k_if.k_cxl_io_support                ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_cxl_pbr_flit_support          = i_k_if.k_cxl_pbr_flit_support          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_sync_reset                    = i_k_if.k_sync_reset                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_sync_cell_stages              = i_k_if.k_sync_cell_stages              ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_flit_mode_support             = i_k_if.k_flit_mode_support             ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_ide_support                   = i_k_if.k_ide_support                   ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_pasid_supported               = i_k_if.k_pasid_supported               ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_dti_tok_inv_min1              = i_k_if.k_dti_tok_inv_min1              ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_dti_tok_trans_min1            = i_k_if.k_dti_tok_trans_min1            ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_dti_ram_read_latency          = i_k_if.k_dti_ram_read_latency          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_dti_ram_enable                = i_k_if.k_dti_ram_enable                ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_vendor_prefix_local_support   = i_k_if.k_vendor_prefix_local_support   ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_ecrc_capability_support       = i_k_if.k_ecrc_capability_support       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_ohc_e_wd                      = i_k_if.k_ohc_e_wd                      ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.k_axi_m_outstanding_writes_min1 = i_k_if.k_axi_m_outstanding_writes_min1 ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.strap_port_type                 = i_k_if.strap_port_type                 ;
    end
    else begin : passive_tb_dut_k_if
      always_comb i_k_if.k_hls_dw_alignment              = `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment              ;
      always_comb i_k_if.k_cxl_io_support                = `HLS_BRIDGE_DUT_MODULE_NAME.k_cxl_io_support                ;
      always_comb i_k_if.k_cxl_pbr_flit_support          = `HLS_BRIDGE_DUT_MODULE_NAME.k_cxl_pbr_flit_support          ;
      always_comb i_k_if.k_sync_reset                    = `HLS_BRIDGE_DUT_MODULE_NAME.k_sync_reset                    ;
      always_comb i_k_if.k_sync_cell_stages              = `HLS_BRIDGE_DUT_MODULE_NAME.k_sync_cell_stages              ;
      always_comb i_k_if.k_flit_mode_support             = `HLS_BRIDGE_DUT_MODULE_NAME.k_flit_mode_support             ;
      always_comb i_k_if.k_ide_support                   = `HLS_BRIDGE_DUT_MODULE_NAME.k_ide_support                   ;
      always_comb i_k_if.k_pasid_supported               = `HLS_BRIDGE_DUT_MODULE_NAME.k_pasid_supported               ;
      always_comb i_k_if.k_dti_tok_inv_min1              = `HLS_BRIDGE_DUT_MODULE_NAME.k_dti_tok_inv_min1              ;
      always_comb i_k_if.k_dti_tok_trans_min1            = `HLS_BRIDGE_DUT_MODULE_NAME.k_dti_tok_trans_min1            ;
      always_comb i_k_if.k_dti_ram_read_latency          = `HLS_BRIDGE_DUT_MODULE_NAME.k_dti_ram_read_latency          ;
      always_comb i_k_if.k_dti_ram_enable                = `HLS_BRIDGE_DUT_MODULE_NAME.k_dti_ram_enable                ;
      always_comb i_k_if.k_vendor_prefix_local_support   = `HLS_BRIDGE_DUT_MODULE_NAME.k_vendor_prefix_local_support   ;
      always_comb i_k_if.k_ecrc_capability_support       = `HLS_BRIDGE_DUT_MODULE_NAME.k_ecrc_capability_support       ;
      always_comb i_k_if.k_ohc_e_wd                      = `HLS_BRIDGE_DUT_MODULE_NAME.k_ohc_e_wd                      ;
      always_comb i_k_if.k_axi_m_outstanding_writes_min1 = `HLS_BRIDGE_DUT_MODULE_NAME.k_axi_m_outstanding_writes_min1 ;
      always_comb i_k_if.strap_port_type                 = `HLS_BRIDGE_DUT_MODULE_NAME.strap_port_type                 ;
    end
  endgenerate
 
    
  //------------------------------------------------------------------------------
  // HLS TX(OB) Posted I/F to HAL
  //------------------------------------------------------------------------------
  hlsInterface #(
    .DATA_WIDTH_TX          ( KMAX_DATAPATH_WD                      ),
    .DATA_WIDTH_RX          ( KMAX_DATAPATH_WD                      ),
    .CNTL_WIDTH_TX          ( HLS_PKT_CNTL_WD                       ),
    .CNTL_WIDTH_RX          ( HLS_PKT_CNTL_WD                       ),
    .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD     ),
    .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD     ),
    .DATA_CHK_WIDTH_TX      ( LOCAL_KMAX_DATAPATH_CHK_WD            ),
    .DATA_CHK_WIDTH_RX      ( LOCAL_KMAX_DATAPATH_CHK_WD            ),
    .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_PKT_CNTL_CHK_WD             ),
    .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_PKT_CNTL_CHK_WD             ),
    .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_HAL_OB_PNP_USER_CNTL_CHK_WD ),
    .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_HAL_OB_PNP_USER_CNTL_CHK_WD )
  ) i_hls_ob_posted_hal_if (
    .HLS_CLK               ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
    .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
    .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
  );
  
  generate
    if(IS_ACTIVE) begin : active_tb_hls_ob_posted_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_TX_PNP_METADATA_WD      )
      ) i_hls_ob_posted_hal_cntl_bus_converter_wrapper (
        .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                              ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                            ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                         ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                           ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                 ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_data                                                       ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_valid                                                      ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_cntl_chk                                                   ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_data_chk                                                   ),
        .cntl_o             ( /*--Assigned below------------------------------------------------------------------------------------*/ ),
        .data_o             ( /*--Assigned below------------------------------------------------------------------------------------*/ ),
        .user_o             ( /*--Assigned below------------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ )
      );

      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_crdgnt    = i_hls_ob_posted_hal_if.HLS_CRDGNT_RX                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_activeack = i_hls_ob_posted_hal_if.HLS_ACTIVE_ACK_RX                ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_deacthint = i_hls_ob_posted_hal_if.HLS_DEACT_HINT_RX                ;
      assign i_hls_ob_posted_hal_if.HLS_VALID_RX                     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_valid     ;
      assign i_hls_ob_posted_hal_if.HLS_CRDRTN_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_crdrtn    ;
      assign i_hls_ob_posted_hal_if.HLS_ACTIVE_REQ_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_activereq ;
      assign i_hls_ob_posted_hal_if.HLS_DATA_RX                      = i_hls_ob_posted_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ob_posted_hal_if.HLS_CNTL_RX                      = i_hls_ob_posted_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ob_posted_hal_if.HLS_USER_CNTL_RX                 = i_hls_ob_posted_hal_cntl_bus_converter_wrapper.user_o   ;
    end
    else begin : passive_tb_hls_ob_posted_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_TX_PNP_METADATA_WD      )
      ) i_hls_ob_posted_hal_cntl_bus_converter_wrapper (
        .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                              ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                            ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                         ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                           ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                 ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_data                                                       ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_valid                                                      ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_cntl_chk                                                   ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_data_chk                                                   ),
        .cntl_o             ( /*--Assigned below------------------------------------------------------------------------------------*/ ),
        .data_o             ( /*--Assigned below------------------------------------------------------------------------------------*/ ),
        .user_o             ( /*--Assigned below------------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ )
      );

      assign i_hls_ob_posted_hal_if.HLS_CRDGNT_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_crdgnt    ;
      assign i_hls_ob_posted_hal_if.HLS_ACTIVE_ACK_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_activeack ;
      assign i_hls_ob_posted_hal_if.HLS_DEACT_HINT_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_deacthint ;
      assign i_hls_ob_posted_hal_if.HLS_VALID_RX                     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_valid     ; 
      assign i_hls_ob_posted_hal_if.HLS_CRDRTN_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_crdrtn    ; 
      assign i_hls_ob_posted_hal_if.HLS_ACTIVE_REQ_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_activereq ;
      assign i_hls_ob_posted_hal_if.HLS_DATA_RX                      = i_hls_ob_posted_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ob_posted_hal_if.HLS_CNTL_RX                      = i_hls_ob_posted_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ob_posted_hal_if.HLS_USER_CNTL_RX                 = i_hls_ob_posted_hal_cntl_bus_converter_wrapper.user_o   ;
    end
  endgenerate
  

  //------------------------------------------------------------------------------
  // HLS TX(OB) NonPosted I/F to HAL
  //------------------------------------------------------------------------------
  hlsInterface #(
    .DATA_WIDTH_TX          ( KMAX_DATAPATH_WD                      ),
    .DATA_WIDTH_RX          ( KMAX_DATAPATH_WD                      ),
    .CNTL_WIDTH_TX          ( HLS_PKT_CNTL_WD                       ),
    .CNTL_WIDTH_RX          ( HLS_PKT_CNTL_WD                       ),
    .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD     ),
    .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD     ),
    .DATA_CHK_WIDTH_TX      ( LOCAL_KMAX_DATAPATH_CHK_WD            ),
    .DATA_CHK_WIDTH_RX      ( LOCAL_KMAX_DATAPATH_CHK_WD            ),
    .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_PKT_CNTL_CHK_WD             ),
    .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_PKT_CNTL_CHK_WD             ),
    .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_HAL_OB_PNP_USER_CNTL_CHK_WD ),
    .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_HAL_OB_PNP_USER_CNTL_CHK_WD )
  ) i_hls_ob_nonposted_hal_if (
    .HLS_CLK               ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
    .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
    .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )

  );
  
  generate
    if(IS_ACTIVE) begin : active_tb_hls_ob_nonposted_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_TX_PNP_METADATA_WD      )
      ) i_hls_ob_nonposted_hal_cntl_bus_converter_wrapper (
        .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                 ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                               ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                            ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                              ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                 ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_data                                                       ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_valid                                                      ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_cntl_chk                                                   ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_data_chk                                                   ),
        .cntl_o             ( /*--Assigned below---------------------------------------------------------------------------------------*/ ),
        .data_o             ( /*--Assigned below---------------------------------------------------------------------------------------*/ ),
        .user_o             ( /*--Assigned below---------------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ )
      );

      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_crdgnt    = i_hls_ob_nonposted_hal_if.HLS_CRDGNT_RX                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_activeack = i_hls_ob_nonposted_hal_if.HLS_ACTIVE_ACK_RX                ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_deacthint = i_hls_ob_nonposted_hal_if.HLS_DEACT_HINT_RX                ;
      assign i_hls_ob_nonposted_hal_if.HLS_VALID_RX                     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_valid     ;
      assign i_hls_ob_nonposted_hal_if.HLS_CRDRTN_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_crdrtn    ;
      assign i_hls_ob_nonposted_hal_if.HLS_ACTIVE_REQ_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_activereq ;
      assign i_hls_ob_nonposted_hal_if.HLS_DATA_RX                      = i_hls_ob_nonposted_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ob_nonposted_hal_if.HLS_CNTL_RX                      = i_hls_ob_nonposted_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ob_nonposted_hal_if.HLS_USER_CNTL_RX                 = i_hls_ob_nonposted_hal_cntl_bus_converter_wrapper.user_o   ;
    end
    else begin : passive_tb_hls_ob_nonposted_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_TX_PNP_METADATA_WD      )
      ) i_hls_ob_nonposted_hal_cntl_bus_converter_wrapper (
        .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                 ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                               ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                            ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                              ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                 ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_data                                                       ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_OB_PNP_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_valid                                                      ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_cntl_chk                                                   ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_data_chk                                                   ),
        .cntl_o             ( /*--Assigned below---------------------------------------------------------------------------------------*/ ),
        .data_o             ( /*--Assigned below---------------------------------------------------------------------------------------*/ ),
        .user_o             ( /*--Assigned below---------------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ )
      );

      assign i_hls_ob_nonposted_hal_if.HLS_CRDGNT_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_crdgnt    ;
      assign i_hls_ob_nonposted_hal_if.HLS_ACTIVE_ACK_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_activeack ;
      assign i_hls_ob_nonposted_hal_if.HLS_DEACT_HINT_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_deacthint ;
      assign i_hls_ob_nonposted_hal_if.HLS_VALID_RX                     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_valid     ; 
      assign i_hls_ob_nonposted_hal_if.HLS_CRDRTN_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_crdrtn    ; 
      assign i_hls_ob_nonposted_hal_if.HLS_ACTIVE_REQ_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_activereq ;
      assign i_hls_ob_nonposted_hal_if.HLS_DATA_RX                      = i_hls_ob_nonposted_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ob_nonposted_hal_if.HLS_CNTL_RX                      = i_hls_ob_nonposted_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ob_nonposted_hal_if.HLS_USER_CNTL_RX                 = i_hls_ob_nonposted_hal_cntl_bus_converter_wrapper.user_o   ;
    end
  endgenerate

  
  //------------------------------------------------------------------------------
  // HLS TX(OB) Completion I/F to HAL
  //------------------------------------------------------------------------------
  hlsInterface #(
    .DATA_WIDTH_TX          ( KMAX_DATAPATH_WD                    ),
    .DATA_WIDTH_RX          ( KMAX_DATAPATH_WD                    ),
    .CNTL_WIDTH_TX          ( HLS_PKT_CNTL_WD                     ),
    .CNTL_WIDTH_RX          ( HLS_PKT_CNTL_WD                     ),
    .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_HAL_OB_C_USER_CNTL_WD     ),
    .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_HAL_OB_C_USER_CNTL_WD     ),
    .DATA_CHK_WIDTH_TX      ( LOCAL_KMAX_DATAPATH_CHK_WD          ),
    .DATA_CHK_WIDTH_RX      ( LOCAL_KMAX_DATAPATH_CHK_WD          ),
    .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_PKT_CNTL_CHK_WD           ),
    .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_PKT_CNTL_CHK_WD           ),
    .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_HAL_OB_C_USER_CNTL_CHK_WD ),
    .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_HAL_OB_C_USER_CNTL_CHK_WD )
  ) i_hls_ob_compl_hal_if (
    .HLS_CLK               ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
    .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
    .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
  );
  
  generate
    if(IS_ACTIVE) begin : active_tb_hls_ob_compl_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_TX_C_METADATA_WD        )
      ) i_hls_ob_compl_hal_cntl_bus_converter_wrapper (
        .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                           ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                         ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                      ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                        ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_cntl[0 +: HLS_PKT_CNTL_WD]                               ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_data                                                     ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_OB_C_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_valid                                                    ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_cntl_chk                                                 ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_data_chk                                                 ),
        .cntl_o             ( /*--Assigned below---------------------------------------------------------------------------------*/ ),
        .data_o             ( /*--Assigned below---------------------------------------------------------------------------------*/ ),
        .user_o             ( /*--Assigned below---------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ )
      );

      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_crdgnt    = i_hls_ob_compl_hal_if.HLS_CRDGNT_RX                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_activeack = i_hls_ob_compl_hal_if.HLS_ACTIVE_ACK_RX                ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_deacthint = i_hls_ob_compl_hal_if.HLS_DEACT_HINT_RX                ;
      assign i_hls_ob_compl_hal_if.HLS_VALID_RX                     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_valid     ;
      assign i_hls_ob_compl_hal_if.HLS_CRDRTN_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_crdrtn    ;
      assign i_hls_ob_compl_hal_if.HLS_ACTIVE_REQ_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_activereq ;
      assign i_hls_ob_compl_hal_if.HLS_DATA_RX                      = i_hls_ob_compl_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ob_compl_hal_if.HLS_CNTL_RX                      = i_hls_ob_compl_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ob_compl_hal_if.HLS_USER_CNTL_RX                 = i_hls_ob_compl_hal_cntl_bus_converter_wrapper.user_o   ;
    end
    else begin : passive_tb_hls_ob_compl_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_TX_C_METADATA_WD        )
      ) i_hls_ob_compl_hal_cntl_bus_converter_wrapper (
        .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                           ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                         ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                      ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                        ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_cntl[0 +: HLS_PKT_CNTL_WD]                               ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_data                                                     ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_OB_C_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_valid                                                    ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_cntl_chk                                                 ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_data_chk                                                 ),
        .cntl_o             ( /*--Assigned below---------------------------------------------------------------------------------*/ ),
        .data_o             ( /*--Assigned below---------------------------------------------------------------------------------*/ ),
        .user_o             ( /*--Assigned below---------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ )
      );

      assign i_hls_ob_compl_hal_if.HLS_CRDGNT_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_crdgnt    ;
      assign i_hls_ob_compl_hal_if.HLS_ACTIVE_ACK_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_activeack ;
      assign i_hls_ob_compl_hal_if.HLS_DEACT_HINT_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_deacthint ;
      assign i_hls_ob_compl_hal_if.HLS_VALID_RX                     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_valid     ; 
      assign i_hls_ob_compl_hal_if.HLS_CRDRTN_RX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_crdrtn    ; 
      assign i_hls_ob_compl_hal_if.HLS_ACTIVE_REQ_RX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_activereq ;
      assign i_hls_ob_compl_hal_if.HLS_DATA_RX                      = i_hls_ob_compl_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ob_compl_hal_if.HLS_CNTL_RX                      = i_hls_ob_compl_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ob_compl_hal_if.HLS_USER_CNTL_RX                 = i_hls_ob_compl_hal_cntl_bus_converter_wrapper.user_o   ;
    end
  endgenerate


  //------------------------------------------------------------------------------
  // HLS RX(IB) Posted I/F from HAL
  //------------------------------------------------------------------------------
  hlsInterface #(
    .DATA_WIDTH_TX          ( KMAX_DATAPATH_WD                      ),
    .DATA_WIDTH_RX          ( KMAX_DATAPATH_WD                      ),
    .CNTL_WIDTH_TX          ( HLS_PKT_CNTL_WD                       ),
    .CNTL_WIDTH_RX          ( HLS_PKT_CNTL_WD                       ),
    .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD     ),
    .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD     ),
    .DATA_CHK_WIDTH_TX      ( LOCAL_KMAX_DATAPATH_CHK_WD            ),
    .DATA_CHK_WIDTH_RX      ( LOCAL_KMAX_DATAPATH_CHK_WD            ),
    .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_PKT_CNTL_CHK_WD             ),
    .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_PKT_CNTL_CHK_WD             ),
    .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_HAL_IB_PNP_USER_CNTL_CHK_WD ),
    .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_HAL_IB_PNP_USER_CNTL_CHK_WD )
  ) i_hls_ib_posted_hal_if (
    .HLS_CLK               ( i_clk_if.core_clk   ),
    .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
    .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
    .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
  );
    
  generate
    if(IS_ACTIVE) begin : active_tb_hls_ib_posted_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 1                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_RX_PNP_METADATA_WD      )
      ) i_hls_ib_posted_hal_cntl_bus_converter_wrapper (
        .clk                ( i_clk_if.core_clk                                                                                ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                              ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                                           ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                             ),
        .cntl_i             ( i_hls_ib_posted_hal_if.HLS_CNTL_TX                                                                                         ),
        .data_i             ( i_hls_ib_posted_hal_if.HLS_DATA_TX                                                                                         ),
        .user_i             ( i_hls_ib_posted_hal_if.HLS_USER_CNTL_TX                                                                                    ),
        .valid_i            ( i_hls_ib_posted_hal_if.HLS_VALID_TX                                                                                        ),
        .full_cntl_parity_i ( /*--Not required by transmitter-----------------------------------------------------------------------------------------*/ ),
        .data_parity_i      ( /*--Not required by transmitter-----------------------------------------------------------------------------------------*/ ),
        .cntl_o             ( tb_hls_ib_posted_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                                                            ),
        .data_o             ( tb_hls_ib_posted_hal_data                                                                                                  ),
        .user_o             ( tb_hls_ib_posted_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD]                                            ),
        .cntl_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_cntl_chk[0 +: LOCAL_HLS_PKT_CNTL_CHK_WD]                                     ),
        .data_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_data_chk                                                                     ),
        .user_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_cntl_chk[LOCAL_HLS_PKT_CNTL_CHK_WD +: LOCAL_HLS_HAL_IB_PNP_USER_CNTL_CHK_WD] )
      );

      assign i_hls_ib_posted_hal_if.HLS_CRDGNT_TX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_crdgnt    ;
      assign i_hls_ib_posted_hal_if.HLS_ACTIVE_ACK_TX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_activeack ;
      assign i_hls_ib_posted_hal_if.HLS_DEACT_HINT_TX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_deacthint ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_valid     = i_hls_ib_posted_hal_if.HLS_VALID_TX                     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_crdrtn    = i_hls_ib_posted_hal_if.HLS_CRDRTN_TX                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_activereq = i_hls_ib_posted_hal_if.HLS_ACTIVE_REQ_TX                ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_cntl      = tb_hls_ib_posted_hal_cntl                               ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_data      = tb_hls_ib_posted_hal_data                               ;
    end
    else begin : passive_tb_hls_ib_posted_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_RX_PNP_METADATA_WD      )
      ) i_hls_ib_posted_hal_cntl_bus_converter_wrapper (
        .clk                ( i_clk_if.core_clk                                                              ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                            ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                         ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                           ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                 ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_data                                                       ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_valid                                                      ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_cntl_chk                                                   ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_data_chk                                                   ),
        .cntl_o             ( /*- Assigned Below -----------------------------------------------------------------------------------*/ ),
        .data_o             ( /*- Assigned Below -----------------------------------------------------------------------------------*/ ),
        .user_o             ( /*- Assigned Below -----------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------*/ )
      );

      assign i_hls_ib_posted_hal_if.HLS_CRDGNT_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_crdgnt    ;
      assign i_hls_ib_posted_hal_if.HLS_ACTIVE_ACK_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_activeack ;
      assign i_hls_ib_posted_hal_if.HLS_DEACT_HINT_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_deacthint ;
      assign i_hls_ib_posted_hal_if.HLS_VALID_TX      = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_valid     ; 
      assign i_hls_ib_posted_hal_if.HLS_CRDRTN_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_crdrtn    ; 
      assign i_hls_ib_posted_hal_if.HLS_ACTIVE_REQ_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_activereq ;
      assign i_hls_ib_posted_hal_if.HLS_DATA_TX       = i_hls_ib_posted_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ib_posted_hal_if.HLS_CNTL_TX       = i_hls_ib_posted_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ib_posted_hal_if.HLS_USER_CNTL_TX  = i_hls_ib_posted_hal_cntl_bus_converter_wrapper.user_o   ;
    end
  endgenerate
  

  //------------------------------------------------------------------------------
  // HLS RX(IB) NonPosted I/F from HAL
  //------------------------------------------------------------------------------
  hlsInterface #(
    .DATA_WIDTH_TX          ( KMAX_DATAPATH_WD                      ),
    .DATA_WIDTH_RX          ( KMAX_DATAPATH_WD                      ),
    .CNTL_WIDTH_TX          ( HLS_PKT_CNTL_WD                       ),
    .CNTL_WIDTH_RX          ( HLS_PKT_CNTL_WD                       ),
    .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD     ),
    .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD     ),
    .DATA_CHK_WIDTH_TX      ( LOCAL_KMAX_DATAPATH_CHK_WD            ),
    .DATA_CHK_WIDTH_RX      ( LOCAL_KMAX_DATAPATH_CHK_WD            ),
    .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_PKT_CNTL_CHK_WD             ),
    .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_PKT_CNTL_CHK_WD             ),
    .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_HAL_IB_PNP_USER_CNTL_CHK_WD ),
    .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_HAL_IB_PNP_USER_CNTL_CHK_WD )
  ) i_hls_ib_nonposted_hal_if (
    .HLS_CLK               ( i_clk_if.core_clk   ),
    .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
    .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
    .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
  );
    
  generate
    if(IS_ACTIVE) begin : active_tb_hls_ib_nonposted_hal_if

      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 1                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_RX_PNP_METADATA_WD      )
      ) i_hls_ib_nonposted_hal_cntl_bus_converter_wrapper (
        .clk                ( i_clk_if.core_clk                                                                                   ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                 ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                                              ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                ),
        .cntl_i             ( i_hls_ib_nonposted_hal_if.HLS_CNTL_TX                                                                                         ),
        .data_i             ( i_hls_ib_nonposted_hal_if.HLS_DATA_TX                                                                                         ),
        .user_i             ( i_hls_ib_nonposted_hal_if.HLS_USER_CNTL_TX                                                                                    ),
        .valid_i            ( i_hls_ib_nonposted_hal_if.HLS_VALID_TX                                                                                        ),
        .full_cntl_parity_i ( /*--Not required by transmitter--------------------------------------------------------------------------------------------*/ ),
        .data_parity_i      ( /*--Not required by transmitter--------------------------------------------------------------------------------------------*/ ),
        .cntl_o             ( tb_hls_ib_nonposted_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                                                            ),
        .data_o             ( tb_hls_ib_nonposted_hal_data                                                                                                  ),
        .user_o             ( tb_hls_ib_nonposted_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD]                                            ),
        .cntl_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_cntl_chk[0 +: LOCAL_HLS_PKT_CNTL_CHK_WD]                                     ),
        .data_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_data_chk                                                                     ),
        .user_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_cntl_chk[LOCAL_HLS_PKT_CNTL_CHK_WD +: LOCAL_HLS_HAL_IB_PNP_USER_CNTL_CHK_WD] )
      );

      assign i_hls_ib_nonposted_hal_if.HLS_CRDGNT_TX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_crdgnt    ;
      assign i_hls_ib_nonposted_hal_if.HLS_ACTIVE_ACK_TX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_activeack ;
      assign i_hls_ib_nonposted_hal_if.HLS_DEACT_HINT_TX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_deacthint ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_valid     = i_hls_ib_nonposted_hal_if.HLS_VALID_TX                     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_crdrtn    = i_hls_ib_nonposted_hal_if.HLS_CRDRTN_TX                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_activereq = i_hls_ib_nonposted_hal_if.HLS_ACTIVE_REQ_TX                ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_cntl      = tb_hls_ib_nonposted_hal_cntl                               ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_data      = tb_hls_ib_nonposted_hal_data                               ;
    end
    else begin : passive_tb_hls_ib_nonposted_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_RX_PNP_METADATA_WD      )
      ) i_hls_ib_nonposted_hal_cntl_bus_converter_wrapper (
        .clk                ( i_clk_if.core_clk                                                                 ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                               ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                            ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                              ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                 ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_data                                                       ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_IB_PNP_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_valid                                                      ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_cntl_chk                                                   ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_data_chk                                                   ),
        .cntl_o             ( /*- Assigned Below --------------------------------------------------------------------------------------*/ ),
        .data_o             ( /*- Assigned Below --------------------------------------------------------------------------------------*/ ),
        .user_o             ( /*- Assigned Below --------------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------*/ )
      );

      assign i_hls_ib_nonposted_hal_if.HLS_CRDGNT_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_crdgnt    ;
      assign i_hls_ib_nonposted_hal_if.HLS_ACTIVE_ACK_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_activeack ;
      assign i_hls_ib_nonposted_hal_if.HLS_DEACT_HINT_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_deacthint ;
      assign i_hls_ib_nonposted_hal_if.HLS_VALID_TX      = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_valid     ; 
      assign i_hls_ib_nonposted_hal_if.HLS_CRDRTN_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_crdrtn    ; 
      assign i_hls_ib_nonposted_hal_if.HLS_ACTIVE_REQ_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_activereq ;
      assign i_hls_ib_nonposted_hal_if.HLS_DATA_TX       = i_hls_ib_nonposted_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ib_nonposted_hal_if.HLS_CNTL_TX       = i_hls_ib_nonposted_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ib_nonposted_hal_if.HLS_USER_CNTL_TX  = i_hls_ib_nonposted_hal_cntl_bus_converter_wrapper.user_o   ;
    end
  endgenerate


  //------------------------------------------------------------------------------
  // HLS RX(IB) Compl I/F from HAL
  //------------------------------------------------------------------------------
  hlsInterface #(
    .DATA_WIDTH_TX          ( KMAX_DATAPATH_WD                    ),
    .DATA_WIDTH_RX          ( KMAX_DATAPATH_WD                    ),
    .CNTL_WIDTH_TX          ( HLS_PKT_CNTL_WD                     ),
    .CNTL_WIDTH_RX          ( HLS_PKT_CNTL_WD                     ),
    .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_HAL_IB_C_USER_CNTL_WD     ),
    .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_HAL_IB_C_USER_CNTL_WD     ),
    .DATA_CHK_WIDTH_TX      ( LOCAL_KMAX_DATAPATH_CHK_WD          ),
    .DATA_CHK_WIDTH_RX      ( LOCAL_KMAX_DATAPATH_CHK_WD          ),
    .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_PKT_CNTL_CHK_WD           ),
    .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_PKT_CNTL_CHK_WD           ),
    .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_HAL_IB_C_USER_CNTL_CHK_WD ),
    .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_HAL_IB_C_USER_CNTL_CHK_WD )
  ) i_hls_ib_compl_hal_if (
    .HLS_CLK               ( i_clk_if.core_clk   ),
    .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
    .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
    .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
    .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
    .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
    .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
    .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
    .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
    .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
    .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
    .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
    .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
    .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
    .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
  );
    
  generate
    if(IS_ACTIVE) begin : active_tb_hls_ib_compl_hal_if

      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 1                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_RX_C_METADATA_WD        )
      ) i_hls_ib_compl_hal_cntl_bus_converter_wrapper (
        .clk                ( i_clk_if.core_clk                                                                             ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                           ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                                        ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                          ),
        .cntl_i             ( i_hls_ib_compl_hal_if.HLS_CNTL_TX                                                                                       ),
        .data_i             ( i_hls_ib_compl_hal_if.HLS_DATA_TX                                                                                       ),
        .user_i             ( i_hls_ib_compl_hal_if.HLS_USER_CNTL_TX                                                                                  ),
        .valid_i            ( i_hls_ib_compl_hal_if.HLS_VALID_TX                                                                                      ),
        .full_cntl_parity_i ( /*--Not required by transmitter--------------------------------------------------------------------------------------*/ ),
        .data_parity_i      ( /*--Not required by transmitter--------------------------------------------------------------------------------------*/ ),
        .cntl_o             ( tb_hls_ib_compl_hal_cntl[0 +: HLS_PKT_CNTL_WD]                                                                          ),
        .data_o             ( tb_hls_ib_compl_hal_data                                                                                                ),
        .user_o             ( tb_hls_ib_compl_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_IB_C_USER_CNTL_WD]                                            ),
        .cntl_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_cntl_chk[0 +: LOCAL_HLS_PKT_CNTL_CHK_WD]                                   ),
        .data_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_data_chk                                                                   ),
        .user_parity_o      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_cntl_chk[LOCAL_HLS_PKT_CNTL_CHK_WD +: LOCAL_HLS_HAL_IB_C_USER_CNTL_CHK_WD] )
      );

      assign i_hls_ib_compl_hal_if.HLS_CRDGNT_TX                    = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_crdgnt    ;
      assign i_hls_ib_compl_hal_if.HLS_ACTIVE_ACK_TX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_activeack ;
      assign i_hls_ib_compl_hal_if.HLS_DEACT_HINT_TX                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_deacthint ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_valid     = i_hls_ib_compl_hal_if.HLS_VALID_TX                     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_crdrtn    = i_hls_ib_compl_hal_if.HLS_CRDRTN_TX                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_activereq = i_hls_ib_compl_hal_if.HLS_ACTIVE_REQ_TX                ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_cntl      = tb_hls_ib_compl_hal_cntl                               ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_data      = tb_hls_ib_compl_hal_data                               ;
    end
    else begin : passive_tb_hls_ib_compl_hal_if
      
      //--- Control Bus Converter wrapper -------------------------------
      cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
        .ACTIVE                     ( 0                           ),
        .ASF_SUPPORT                ( ASF_SUPPORT                 ),
        .KMAX_DATAPATH_WD           ( KMAX_DATAPATH_WD            ),
        .KMAX_NUM_TLPS_PER_CLK      ( KMAX_NUM_TLPS_PER_CLK       ),
        .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS ),
        .HLS_PKT_CNTL_WD            ( HLS_PKT_CNTL_WD             ),
        .HLS_METADATA_WD            ( HLS_RX_C_METADATA_WD        )
      ) i_hls_ib_compl_hal_cntl_bus_converter_wrapper (
        .clk                ( i_clk_if.core_clk                                                           ),
        .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                         ),
        .k_datapath_wd      ( KMAX_DATAPATH_WD                                                                                      ),
        .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                        ),
        .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_cntl[0 +: HLS_PKT_CNTL_WD]                               ),
        .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_data                                                     ),
        .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_cntl[HLS_PKT_CNTL_WD +: LOCAL_HLS_HAL_IB_C_USER_CNTL_WD] ),
        .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_valid                                                    ),
        .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_cntl_chk                                                 ),
        .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_data_chk                                                 ),
        .cntl_o             ( /*- Assigned Below --------------------------------------------------------------------------------*/ ),
        .data_o             ( /*- Assigned Below --------------------------------------------------------------------------------*/ ),
        .user_o             ( /*- Assigned Below --------------------------------------------------------------------------------*/ ),
        .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ ),
        .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ ),
        .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------*/ )
      );

      assign i_hls_ib_compl_hal_if.HLS_CRDGNT_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_crdgnt    ;
      assign i_hls_ib_compl_hal_if.HLS_ACTIVE_ACK_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_activeack ;
      assign i_hls_ib_compl_hal_if.HLS_DEACT_HINT_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_deacthint ;
      assign i_hls_ib_compl_hal_if.HLS_VALID_TX      = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_valid     ; 
      assign i_hls_ib_compl_hal_if.HLS_CRDRTN_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_crdrtn    ; 
      assign i_hls_ib_compl_hal_if.HLS_ACTIVE_REQ_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_activereq ;
      assign i_hls_ib_compl_hal_if.HLS_DATA_TX       = i_hls_ib_compl_hal_cntl_bus_converter_wrapper.data_o   ;
      assign i_hls_ib_compl_hal_if.HLS_CNTL_TX       = i_hls_ib_compl_hal_cntl_bus_converter_wrapper.cntl_o   ;
      assign i_hls_ib_compl_hal_if.HLS_USER_CNTL_TX  = i_hls_ib_compl_hal_cntl_bus_converter_wrapper.user_o   ;
    end
  endgenerate


  generate
    for (genvar loop_port = 0; loop_port < NUM_HLS_PORTS; loop_port++) begin : GEN_NUM_HLS_PORTS

      //------------------------------------------------------------------------------
      // Local Parameters
      //------------------------------------------------------------------------------
      localparam LOCAL_HLS_AXI_KMAX_DATAPATH_WD        = HLS_PORT_DATA_WIDTH_ARR[loop_port*32 +: 32]                            ;
      localparam LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    = (LOCAL_HLS_AXI_KMAX_DATAPATH_WD + 7) / 8                               ;
      localparam LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK   = HLS_PORT_TLPS_PER_CLK_ARR[loop_port*32 +: 32]                          ;
      localparam LOCAL_HLS_AXI_PKT_CNTL_WD             = HLS_AXI_PKT_CNTL_WD                                                    ; // For now the Design Supports same widths for all the ports.
      localparam LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         = (LOCAL_HLS_AXI_PKT_CNTL_WD + 7) / 8                                    ;
      localparam LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD     = HLS_TX_PNP_METADATA_WD * HLS_PORT_TLPS_PER_CLK_ARR[loop_port*32 +: 32] ;
      localparam LOCAL_HLS_AXI_OB_C_USER_CNTL_WD       = HLS_TX_C_METADATA_WD * HLS_PORT_TLPS_PER_CLK_ARR[loop_port*32 +: 32]   ;
      localparam LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD     = HLS_RX_PNP_METADATA_WD * HLS_PORT_TLPS_PER_CLK_ARR[loop_port*32 +: 32] ;
      localparam LOCAL_HLS_AXI_IB_C_USER_CNTL_WD       = HLS_RX_C_METADATA_WD * HLS_PORT_TLPS_PER_CLK_ARR[loop_port*32 +: 32]   ;
      localparam LOCAL_HLS_AXI_OB_PNP_USER_CNTL_CHK_WD = (LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD + 7) / 8                            ;
      localparam LOCAL_HLS_AXI_OB_C_USER_CNTL_CHK_WD   = (LOCAL_HLS_AXI_OB_C_USER_CNTL_WD + 7) / 8                              ;
      localparam LOCAL_HLS_AXI_IB_PNP_USER_CNTL_CHK_WD = (LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD + 7) / 8                            ;
      localparam LOCAL_HLS_AXI_IB_C_USER_CNTL_CHK_WD   = (LOCAL_HLS_AXI_IB_C_USER_CNTL_WD + 7) / 8                              ;
      localparam LOCAL_HLS_AXI_OB_PNP_CNTL_WD          = HLS_AXI_OB_PNP_CNTL_WD                                                 ; // For now the Design Supports same width for all the ports.
      localparam LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD      = HLS_AXI_OB_PNP_CNTL_CHK_WD                                             ; // For now the Design Supports same width for all the ports.
      localparam LOCAL_HLS_AXI_OB_C_CNTL_WD            = HLS_AXI_OB_C_CNTL_WD                                                   ; // For now the Design Supports same width for all the ports.
      localparam LOCAL_HLS_AXI_OB_C_CNTL_CHK_WD        = HLS_AXI_OB_C_CNTL_CHK_WD                                               ; // For now the Design Supports same width for all the ports.
      localparam LOCAL_HLS_AXI_IB_PNP_CNTL_WD          = HLS_AXI_IB_PNP_CNTL_WD                                                 ; // For now the Design Supports same width for all the ports.
      localparam LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD      = HLS_AXI_IB_PNP_CNTL_CHK_WD                                             ; // For now the Design Supports same width for all the ports.
      localparam LOCAL_HLS_AXI_IB_C_CNTL_WD            = HLS_AXI_IB_C_CNTL_WD                                                   ; // For now the Design Supports same width for all the ports.
      localparam LOCAL_HLS_AXI_IB_C_CNTL_CHK_WD        = HLS_AXI_IB_C_CNTL_CHK_WD                                               ; // For now the Design Supports same width for all the ports.

      wire [LOCAL_HLS_AXI_KMAX_DATAPATH_WD-1     : 0] tb_hls_ob_posted_axi_data        ;
      wire [LOCAL_HLS_AXI_OB_PNP_CNTL_WD-1       : 0] tb_hls_ob_posted_axi_cntl        ;
      wire [LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD-1 : 0] tb_hls_ob_posted_axi_data_chk    ;
      wire [LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD-1   : 0] tb_hls_ob_posted_axi_cntl_chk    ;
      wire [LOCAL_HLS_AXI_KMAX_DATAPATH_WD-1     : 0] tb_hls_ob_nonposted_axi_data     ;
      wire [LOCAL_HLS_AXI_OB_PNP_CNTL_WD-1       : 0] tb_hls_ob_nonposted_axi_cntl     ;
      wire [LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD-1 : 0] tb_hls_ob_nonposted_axi_data_chk ;
      wire [LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD-1   : 0] tb_hls_ob_nonposted_axi_cntl_chk ;
      wire [LOCAL_HLS_AXI_KMAX_DATAPATH_WD-1     : 0] tb_hls_ob_compl_axi_data         ;
      wire [LOCAL_HLS_AXI_OB_C_CNTL_WD-1         : 0] tb_hls_ob_compl_axi_cntl         ;
      wire [LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD-1 : 0] tb_hls_ob_compl_axi_data_chk     ;
      wire [LOCAL_HLS_AXI_OB_C_CNTL_CHK_WD-1     : 0] tb_hls_ob_compl_axi_cntl_chk     ;

      //------------------------------------------------------------------------------
      // HLS RX(OB) Posted I/F from AXI
      //------------------------------------------------------------------------------
      hlsInterface #(
        .DATA_WIDTH_TX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD        ),
        .DATA_WIDTH_RX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD        ),
        .CNTL_WIDTH_TX          ( LOCAL_HLS_AXI_PKT_CNTL_WD             ),
        .CNTL_WIDTH_RX          ( LOCAL_HLS_AXI_PKT_CNTL_WD             ),
        .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD     ),
        .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD     ),
        .DATA_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    ),
        .DATA_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    ),
        .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         ),
        .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         ),
        .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_AXI_OB_PNP_USER_CNTL_CHK_WD ),
        .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_AXI_OB_PNP_USER_CNTL_CHK_WD )
      ) i_hls_ob_posted_axi_if (
        .HLS_CLK               ( i_clk_if.core_clk   ),
        .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
        .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
        .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
      );
        
      if(IS_ACTIVE) begin : active_tb_hls_ob_posted_axi_if

        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 1                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_TX_PNP_METADATA_WD              )
        ) i_hls_ob_posted_axi_cntl_bus_converter_wrapper (
          .clk                ( i_clk_if.core_clk                                                           ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                         ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                        ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                        ),
          .cntl_i             ( i_hls_ob_posted_axi_if.HLS_CNTL_TX                                                                    ),
          .data_i             ( i_hls_ob_posted_axi_if.HLS_DATA_TX                                                                    ),
          .user_i             ( i_hls_ob_posted_axi_if.HLS_USER_CNTL_TX                                                               ),
          .valid_i            ( i_hls_ob_posted_axi_if.HLS_VALID_TX                                                                   ),
          .full_cntl_parity_i ( /*--Not required by transmitter--------------------------------------------------------------------*/ ),
          .data_parity_i      ( /*--Not required by transmitter--------------------------------------------------------------------*/ ),
          .cntl_o             ( tb_hls_ob_posted_axi_cntl[0 +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                             ),
          .data_o             ( tb_hls_ob_posted_axi_data                                                                             ),
          .user_o             ( tb_hls_ob_posted_axi_cntl[LOCAL_HLS_AXI_PKT_CNTL_WD +: LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD]             ),
          .cntl_parity_o      ( tb_hls_ob_posted_axi_cntl_chk[0 +: LOCAL_HLS_AXI_PKT_CNTL_CHK_WD]                                     ),
          .data_parity_o      ( tb_hls_ob_posted_axi_data_chk                                                                         ),
          .user_parity_o      ( tb_hls_ob_posted_axi_cntl_chk[LOCAL_HLS_AXI_PKT_CNTL_CHK_WD +: LOCAL_HLS_AXI_OB_PNP_USER_CNTL_CHK_WD] )
        );

        assign i_hls_ob_posted_axi_if.HLS_CRDGNT_TX                                                                                                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_crdgnt[loop_port]    ;
        assign i_hls_ob_posted_axi_if.HLS_ACTIVE_ACK_TX                                                                                                       = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_activeack[loop_port] ;
        assign i_hls_ob_posted_axi_if.HLS_DEACT_HINT_TX                                                                                                       = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_deacthint[loop_port] ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_valid[loop_port]                                                                                 = i_hls_ob_posted_axi_if.HLS_VALID_TX                                ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_crdrtn[loop_port]                                                                                = i_hls_ob_posted_axi_if.HLS_CRDRTN_TX                               ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_activereq[loop_port]                                                                             = i_hls_ob_posted_axi_if.HLS_ACTIVE_REQ_TX                           ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_cntl[(loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_WD) +: LOCAL_HLS_AXI_OB_PNP_CNTL_WD]                 = tb_hls_ob_posted_axi_cntl                                          ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD) +: LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD]     = tb_hls_ob_posted_axi_cntl_chk                                      ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]             = tb_hls_ob_posted_axi_data                                          ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD] = tb_hls_ob_posted_axi_data_chk                                      ;
      end
      else begin : passive_tb_hls_ob_posted_axi_if
        
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_TX_PNP_METADATA_WD              )
        ) i_hls_ob_posted_axi_cntl_bus_converter_wrapper (
          .clk                ( i_clk_if.core_clk                                                                                                                       ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                     ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                                    ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                                    ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_cntl[(loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                       ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                                ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_cntl[((loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_valid[loop_port]                                                                                                    ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD) +: LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                    ),
          .cntl_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign i_hls_ob_posted_axi_if.HLS_CRDGNT_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_crdgnt[loop_port]    ;
        assign i_hls_ob_posted_axi_if.HLS_ACTIVE_ACK_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_activeack[loop_port] ;
        assign i_hls_ob_posted_axi_if.HLS_DEACT_HINT_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_deacthint[loop_port] ;
        assign i_hls_ob_posted_axi_if.HLS_VALID_TX      = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_valid[loop_port]     ; 
        assign i_hls_ob_posted_axi_if.HLS_CRDRTN_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_crdrtn[loop_port]    ; 
        assign i_hls_ob_posted_axi_if.HLS_ACTIVE_REQ_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_axi_activereq[loop_port] ;
        assign i_hls_ob_posted_axi_if.HLS_DATA_TX       = i_hls_ob_posted_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ob_posted_axi_if.HLS_CNTL_TX       = i_hls_ob_posted_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ob_posted_axi_if.HLS_USER_CNTL_TX  = i_hls_ob_posted_axi_cntl_bus_converter_wrapper.user_o              ;
      end
      

      //------------------------------------------------------------------------------
      // HLS RX(OB) NonPosted I/F from AXI
      //------------------------------------------------------------------------------
      hlsInterface #(
        .DATA_WIDTH_TX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD        ),
        .DATA_WIDTH_RX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD        ),
        .CNTL_WIDTH_TX          ( LOCAL_HLS_AXI_PKT_CNTL_WD             ),
        .CNTL_WIDTH_RX          ( LOCAL_HLS_AXI_PKT_CNTL_WD             ),
        .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD     ),
        .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD     ),
        .DATA_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    ),
        .DATA_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    ),
        .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         ),
        .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         ),
        .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_AXI_OB_PNP_USER_CNTL_CHK_WD ),
        .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_AXI_OB_PNP_USER_CNTL_CHK_WD )
      ) i_hls_ob_nonposted_axi_if (
        .HLS_CLK               ( i_clk_if.core_clk   ),
        .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
        .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
        .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
      );
        
      if(IS_ACTIVE) begin : active_tb_hls_ob_nonposted_axi_if

        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 1                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_TX_PNP_METADATA_WD              )
        ) i_hls_ob_nonposted_axi_cntl_bus_converter_wrapper (
          .clk                ( i_clk_if.core_clk                                                              ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                            ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                           ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                           ),
          .cntl_i             ( i_hls_ob_nonposted_axi_if.HLS_CNTL_TX                                                                    ),
          .data_i             ( i_hls_ob_nonposted_axi_if.HLS_DATA_TX                                                                    ),
          .user_i             ( i_hls_ob_nonposted_axi_if.HLS_USER_CNTL_TX                                                               ),
          .valid_i            ( i_hls_ob_nonposted_axi_if.HLS_VALID_TX                                                                   ),
          .full_cntl_parity_i ( /*--Not required by transmitter-----------------------------------------------------------------------*/ ),
          .data_parity_i      ( /*--Not required by transmitter-----------------------------------------------------------------------*/ ),
          .cntl_o             ( tb_hls_ob_nonposted_axi_cntl[0 +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                             ),
          .data_o             ( tb_hls_ob_nonposted_axi_data                                                                             ),
          .user_o             ( tb_hls_ob_nonposted_axi_cntl[LOCAL_HLS_AXI_PKT_CNTL_WD +: LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD]             ),
          .cntl_parity_o      ( tb_hls_ob_nonposted_axi_cntl_chk[0 +: LOCAL_HLS_AXI_PKT_CNTL_CHK_WD]                                     ),
          .data_parity_o      ( tb_hls_ob_nonposted_axi_data_chk                                                                         ),
          .user_parity_o      ( tb_hls_ob_nonposted_axi_cntl_chk[LOCAL_HLS_AXI_PKT_CNTL_CHK_WD +: LOCAL_HLS_AXI_OB_PNP_USER_CNTL_CHK_WD] )
        );

        assign i_hls_ob_nonposted_axi_if.HLS_CRDGNT_TX                                                                                                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_crdgnt[loop_port]    ;
        assign i_hls_ob_nonposted_axi_if.HLS_ACTIVE_ACK_TX                                                                                                       = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_activeack[loop_port] ;
        assign i_hls_ob_nonposted_axi_if.HLS_DEACT_HINT_TX                                                                                                       = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_deacthint[loop_port] ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_valid[loop_port]                                                                                 = i_hls_ob_nonposted_axi_if.HLS_VALID_TX                                ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_crdrtn[loop_port]                                                                                = i_hls_ob_nonposted_axi_if.HLS_CRDRTN_TX                               ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_activereq[loop_port]                                                                             = i_hls_ob_nonposted_axi_if.HLS_ACTIVE_REQ_TX                           ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_cntl[(loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_WD) +: LOCAL_HLS_AXI_OB_PNP_CNTL_WD]                 = tb_hls_ob_nonposted_axi_cntl                                          ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD) +: LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD]     = tb_hls_ob_nonposted_axi_cntl_chk                                      ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]             = tb_hls_ob_nonposted_axi_data                                          ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD] = tb_hls_ob_nonposted_axi_data_chk                                      ;
      end
      else begin : passive_tb_hls_ob_nonposted_axi_if
        
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_TX_PNP_METADATA_WD              )
        ) i_hls_ob_nonposted_axi_cntl_bus_converter_wrapper (
          .clk                ( i_clk_if.core_clk                                                                                                                          ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                        ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                                       ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                                       ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_cntl[(loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                       ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                                ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_cntl[((loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_OB_PNP_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_valid[loop_port]                                                                                                    ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD) +: LOCAL_HLS_AXI_OB_PNP_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                    ),
          .cntl_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign i_hls_ob_nonposted_axi_if.HLS_CRDGNT_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_crdgnt[loop_port]    ;
        assign i_hls_ob_nonposted_axi_if.HLS_ACTIVE_ACK_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_activeack[loop_port] ;
        assign i_hls_ob_nonposted_axi_if.HLS_DEACT_HINT_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_deacthint[loop_port] ;
        assign i_hls_ob_nonposted_axi_if.HLS_VALID_TX      = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_valid[loop_port]     ; 
        assign i_hls_ob_nonposted_axi_if.HLS_CRDRTN_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_crdrtn[loop_port]    ; 
        assign i_hls_ob_nonposted_axi_if.HLS_ACTIVE_REQ_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_axi_activereq[loop_port] ;
        assign i_hls_ob_nonposted_axi_if.HLS_DATA_TX       = i_hls_ob_nonposted_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ob_nonposted_axi_if.HLS_CNTL_TX       = i_hls_ob_nonposted_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ob_nonposted_axi_if.HLS_USER_CNTL_TX  = i_hls_ob_nonposted_axi_cntl_bus_converter_wrapper.user_o              ;
      end
 //------------------------------------------------------------------------------
      // HLS RX(OB) Compl I/F from AXI
      //------------------------------------------------------------------------------
      hlsInterface #(
        .DATA_WIDTH_TX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
        .DATA_WIDTH_RX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
        .CNTL_WIDTH_TX          ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
        .CNTL_WIDTH_RX          ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
        .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_AXI_OB_C_USER_CNTL_WD     ),
        .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_AXI_OB_C_USER_CNTL_WD     ),
        .DATA_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD  ),
        .DATA_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD  ),
        .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD       ),
        .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD       ),
        .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_AXI_OB_C_USER_CNTL_CHK_WD ),
        .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_AXI_OB_C_USER_CNTL_CHK_WD )
      ) i_hls_ob_compl_axi_if (
        .HLS_CLK               ( i_clk_if.core_clk   ),
        .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
        .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
        .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
      );
        
      if(IS_ACTIVE) begin : active_tb_hls_ob_compl_axi_if

        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 1                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_TX_C_METADATA_WD                )
        ) i_hls_ob_compl_axi_cntl_bus_converter_wrapper (
          .clk                ( i_clk_if.core_clk                                                        ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                      ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                     ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                     ),
          .cntl_i             ( i_hls_ob_compl_axi_if.HLS_CNTL_TX                                                                  ),
          .data_i             ( i_hls_ob_compl_axi_if.HLS_DATA_TX                                                                  ),
          .user_i             ( i_hls_ob_compl_axi_if.HLS_USER_CNTL_TX                                                             ),
          .valid_i            ( i_hls_ob_compl_axi_if.HLS_VALID_TX                                                                 ),
          .full_cntl_parity_i ( /*--Not required by transmitter-----------------------------------------------------------------*/ ),
          .data_parity_i      ( /*--Not required by transmitter-----------------------------------------------------------------*/ ),
          .cntl_o             ( tb_hls_ob_compl_axi_cntl[0 +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                           ),
          .data_o             ( tb_hls_ob_compl_axi_data                                                                           ),
          .user_o             ( tb_hls_ob_compl_axi_cntl[LOCAL_HLS_AXI_PKT_CNTL_WD +: LOCAL_HLS_AXI_OB_C_USER_CNTL_WD]             ),
          .cntl_parity_o      ( tb_hls_ob_compl_axi_cntl_chk[0 +: LOCAL_HLS_AXI_PKT_CNTL_CHK_WD]                                   ),
          .data_parity_o      ( tb_hls_ob_compl_axi_data_chk                                                                       ),
          .user_parity_o      ( tb_hls_ob_compl_axi_cntl_chk[LOCAL_HLS_AXI_PKT_CNTL_CHK_WD +: LOCAL_HLS_AXI_OB_C_USER_CNTL_CHK_WD] )
        );

        assign i_hls_ob_compl_axi_if.HLS_CRDGNT_TX                                                                                                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_crdgnt[loop_port]    ;
        assign i_hls_ob_compl_axi_if.HLS_ACTIVE_ACK_TX                                                                                                       = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_activeack[loop_port] ;
        assign i_hls_ob_compl_axi_if.HLS_DEACT_HINT_TX                                                                                                       = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_deacthint[loop_port] ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_valid[loop_port]                                                                                 = i_hls_ob_compl_axi_if.HLS_VALID_TX                                ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_crdrtn[loop_port]                                                                                = i_hls_ob_compl_axi_if.HLS_CRDRTN_TX                               ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_activereq[loop_port]                                                                             = i_hls_ob_compl_axi_if.HLS_ACTIVE_REQ_TX                           ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_cntl[(loop_port * LOCAL_HLS_AXI_OB_C_CNTL_WD) +: LOCAL_HLS_AXI_OB_C_CNTL_WD]                     = tb_hls_ob_compl_axi_cntl                                          ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_OB_C_CNTL_CHK_WD) +: LOCAL_HLS_AXI_OB_C_CNTL_CHK_WD]         = tb_hls_ob_compl_axi_cntl_chk                                      ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]             = tb_hls_ob_compl_axi_data                                          ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD] = tb_hls_ob_compl_axi_data_chk                                      ;
      end
      else begin : passive_tb_hls_ob_compl_axi_if
        
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_TX_C_METADATA_WD                )
        ) i_hls_ob_compl_axi_cntl_bus_converter_wrapper (
          .clk                ( i_clk_if.core_clk                                                                                                                  ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                               ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                               ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_cntl[(loop_port * LOCAL_HLS_AXI_OB_C_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                     ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                            ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_cntl[((loop_port * LOCAL_HLS_AXI_OB_C_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_OB_C_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_valid[loop_port]                                                                                                ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_OB_C_CNTL_CHK_WD) +: LOCAL_HLS_AXI_OB_C_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                ),
          .cntl_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign i_hls_ob_compl_axi_if.HLS_CRDGNT_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_crdgnt[loop_port]    ;
        assign i_hls_ob_compl_axi_if.HLS_ACTIVE_ACK_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_activeack[loop_port] ;
        assign i_hls_ob_compl_axi_if.HLS_DEACT_HINT_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_deacthint[loop_port] ;
        assign i_hls_ob_compl_axi_if.HLS_VALID_TX      = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_valid[loop_port]     ; 
        assign i_hls_ob_compl_axi_if.HLS_CRDRTN_TX     = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_crdrtn[loop_port]    ; 
        assign i_hls_ob_compl_axi_if.HLS_ACTIVE_REQ_TX = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_axi_activereq[loop_port] ;
        assign i_hls_ob_compl_axi_if.HLS_DATA_TX       = i_hls_ob_compl_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ob_compl_axi_if.HLS_CNTL_TX       = i_hls_ob_compl_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ob_compl_axi_if.HLS_USER_CNTL_TX  = i_hls_ob_compl_axi_cntl_bus_converter_wrapper.user_o              ;
      end


      //------------------------------------------------------------------------------
      // HLS TX(IB) Posted I/F to AXI
      //------------------------------------------------------------------------------
      hlsInterface #(
        .DATA_WIDTH_TX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD        ),
        .DATA_WIDTH_RX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD        ),
        .CNTL_WIDTH_TX          ( LOCAL_HLS_AXI_PKT_CNTL_WD             ),
        .CNTL_WIDTH_RX          ( LOCAL_HLS_AXI_PKT_CNTL_WD             ),
        .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD     ),
        .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD     ),
        .DATA_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    ),
        .DATA_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    ),
        .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         ),
        .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         ),
        .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_AXI_IB_PNP_USER_CNTL_CHK_WD ),
        .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_AXI_IB_PNP_USER_CNTL_CHK_WD )
      ) i_hls_ib_posted_axi_if (
        .HLS_CLK               ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
        .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
        .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
        .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
      );
      
      if(IS_ACTIVE) begin : active_tb_hls_ib_posted_axi_if
      
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_RX_PNP_METADATA_WD              )
        ) i_hls_ib_posted_axi_cntl_bus_converter_wrapper (
          .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                                                                       ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                     ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                                    ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                                    ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_cntl[(loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                       ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                                ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_cntl[((loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_valid[loop_port]                                                                                                    ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD) +: LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                    ),
          .cntl_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_crdgnt[loop_port]    = i_hls_ib_posted_axi_if.HLS_CRDGNT_RX                               ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_activeack[loop_port] = i_hls_ib_posted_axi_if.HLS_ACTIVE_ACK_RX                           ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_deacthint[loop_port] = i_hls_ib_posted_axi_if.HLS_DEACT_HINT_RX                           ;
        assign i_hls_ib_posted_axi_if.HLS_VALID_RX                                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_valid[loop_port]     ;
        assign i_hls_ib_posted_axi_if.HLS_CRDRTN_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_crdrtn[loop_port]    ;
        assign i_hls_ib_posted_axi_if.HLS_ACTIVE_REQ_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_activereq[loop_port] ;
        assign i_hls_ib_posted_axi_if.HLS_DATA_RX                                 = i_hls_ib_posted_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ib_posted_axi_if.HLS_CNTL_RX                                 = i_hls_ib_posted_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ib_posted_axi_if.HLS_USER_CNTL_RX                            = i_hls_ib_posted_axi_cntl_bus_converter_wrapper.user_o              ;
      end
      else begin : passive_tb_hls_ib_posted_axi_if
      
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_RX_PNP_METADATA_WD              )
        ) i_hls_ib_posted_axi_cntl_bus_converter_wrapper (
          .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                                                                       ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                     ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                                    ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                                    ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_cntl[(loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                       ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                                ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_cntl[((loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_valid[loop_port]                                                                                                    ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD) +: LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                    ),
          .cntl_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below --------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ---------------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign i_hls_ib_posted_axi_if.HLS_CRDGNT_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_crdgnt[loop_port]    ;
        assign i_hls_ib_posted_axi_if.HLS_ACTIVE_ACK_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_activeack[loop_port] ;
        assign i_hls_ib_posted_axi_if.HLS_DEACT_HINT_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_deacthint[loop_port] ;
        assign i_hls_ib_posted_axi_if.HLS_VALID_RX                                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_valid[loop_port]     ; 
        assign i_hls_ib_posted_axi_if.HLS_CRDRTN_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_crdrtn[loop_port]    ; 
        assign i_hls_ib_posted_axi_if.HLS_ACTIVE_REQ_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_axi_activereq[loop_port] ;
        assign i_hls_ib_posted_axi_if.HLS_DATA_RX                                 = i_hls_ib_posted_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ib_posted_axi_if.HLS_CNTL_RX                                 = i_hls_ib_posted_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ib_posted_axi_if.HLS_USER_CNTL_RX                            = i_hls_ib_posted_axi_cntl_bus_converter_wrapper.user_o              ;
      end


      //------------------------------------------------------------------------------
      // HLS TX(IB) NonPosted I/F to AXI
      //------------------------------------------------------------------------------
      hlsInterface #(
        .DATA_WIDTH_TX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD        ),
        .DATA_WIDTH_RX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD        ),
        .CNTL_WIDTH_TX          ( LOCAL_HLS_AXI_PKT_CNTL_WD             ),
        .CNTL_WIDTH_RX          ( LOCAL_HLS_AXI_PKT_CNTL_WD             ),
        .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD     ),
        .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD     ),
        .DATA_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    ),
        .DATA_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD    ),
        .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         ),
        .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD         ),
        .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_AXI_IB_PNP_USER_CNTL_CHK_WD ),
        .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_AXI_IB_PNP_USER_CNTL_CHK_WD )
      ) i_hls_ib_nonposted_axi_if (
        .HLS_CLK               ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
        .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
        .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
        .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
      );
      
      if(IS_ACTIVE) begin : active_tb_hls_ib_nonposted_axi_if
      
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_RX_PNP_METADATA_WD              )
        ) i_hls_ib_nonposted_axi_cntl_bus_converter_wrapper (
          .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                                                                          ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                        ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                                       ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                                       ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_cntl[(loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                       ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                                ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_cntl[((loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_valid[loop_port]                                                                                                    ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD) +: LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                    ),
          .cntl_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_crdgnt[loop_port]    = i_hls_ib_nonposted_axi_if.HLS_CRDGNT_RX                               ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_activeack[loop_port] = i_hls_ib_nonposted_axi_if.HLS_ACTIVE_ACK_RX                           ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_deacthint[loop_port] = i_hls_ib_nonposted_axi_if.HLS_DEACT_HINT_RX                           ;
        assign i_hls_ib_nonposted_axi_if.HLS_VALID_RX                                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_valid[loop_port]     ;
        assign i_hls_ib_nonposted_axi_if.HLS_CRDRTN_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_crdrtn[loop_port]    ;
        assign i_hls_ib_nonposted_axi_if.HLS_ACTIVE_REQ_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_activereq[loop_port] ;
        assign i_hls_ib_nonposted_axi_if.HLS_DATA_RX                                 = i_hls_ib_nonposted_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ib_nonposted_axi_if.HLS_CNTL_RX                                 = i_hls_ib_nonposted_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ib_nonposted_axi_if.HLS_USER_CNTL_RX                            = i_hls_ib_nonposted_axi_cntl_bus_converter_wrapper.user_o              ;
      end
      else begin : passive_tb_hls_ib_nonposted_axi_if
      
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_RX_PNP_METADATA_WD              )
        ) i_hls_ib_nonposted_axi_cntl_bus_converter_wrapper (
          .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                                                                          ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                        ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                                       ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                                       ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_cntl[(loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                       ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                                ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_cntl[((loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_IB_PNP_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_valid[loop_port]                                                                                                    ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD) +: LOCAL_HLS_AXI_IB_PNP_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                    ),
          .cntl_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below -----------------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ------------------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign i_hls_ib_nonposted_axi_if.HLS_CRDGNT_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_crdgnt[loop_port]    ;
        assign i_hls_ib_nonposted_axi_if.HLS_ACTIVE_ACK_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_activeack[loop_port] ;
        assign i_hls_ib_nonposted_axi_if.HLS_DEACT_HINT_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_deacthint[loop_port] ;
        assign i_hls_ib_nonposted_axi_if.HLS_VALID_RX                                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_valid[loop_port]     ; 
        assign i_hls_ib_nonposted_axi_if.HLS_CRDRTN_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_crdrtn[loop_port]    ; 
        assign i_hls_ib_nonposted_axi_if.HLS_ACTIVE_REQ_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_activereq[loop_port] ;
        assign i_hls_ib_nonposted_axi_if.HLS_DATA_RX                                 = i_hls_ib_nonposted_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ib_nonposted_axi_if.HLS_CNTL_RX                                 = i_hls_ib_nonposted_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ib_nonposted_axi_if.HLS_USER_CNTL_RX                            = i_hls_ib_nonposted_axi_cntl_bus_converter_wrapper.user_o              ;
      end


      //------------------------------------------------------------------------------
      // HLS TX(IB) Compl I/F to AXI
      //------------------------------------------------------------------------------
      hlsInterface #(
        .DATA_WIDTH_TX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
        .DATA_WIDTH_RX          ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
        .CNTL_WIDTH_TX          ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
        .CNTL_WIDTH_RX          ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
        .USER_CNTL_WIDTH_TX     ( LOCAL_HLS_AXI_IB_C_USER_CNTL_WD     ),
        .USER_CNTL_WIDTH_RX     ( LOCAL_HLS_AXI_IB_C_USER_CNTL_WD     ),
        .DATA_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD  ),
        .DATA_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD  ),
        .CNTL_CHK_WIDTH_TX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD       ),
        .CNTL_CHK_WIDTH_RX      ( LOCAL_HLS_AXI_PKT_CNTL_CHK_WD       ),
        .USER_CNTL_CHK_WIDTH_TX ( LOCAL_HLS_AXI_IB_C_USER_CNTL_CHK_WD ),
        .USER_CNTL_CHK_WIDTH_RX ( LOCAL_HLS_AXI_IB_C_USER_CNTL_CHK_WD )
      ) i_hls_ib_compl_axi_if (
        .HLS_CLK               ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
        .HLS_RESETn            ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
        .HLS_DATA_TX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_TX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_TX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_TX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_TX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_TX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_TX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_TX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_TX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_TX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_TX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_TX       ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_CHK_TX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_TX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_TX ( /*-----------------------------------------*/ ),
        .HLS_DATA_RX           ( /*-----------------------------------------*/ ),
        .HLS_CNTL_RX           ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_RX      ( /*-----------------------------------------*/ ),
        .HLS_VALID_RX          ( /*-----------------------------------------*/ ),
        .HLS_LAST_RX           ( /*-----------------------------------------*/ ),
        .HLS_PRCL_TYPE_RX      ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_RX         ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_RX         ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_RX     ( /*-----------------------------------------*/ ),
        .HLS_DEACT_HINT_RX     ( /*-----------------------------------------*/ ),
        .HLS_DATA_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_CNTL_CHK_RX       ( /*-----------------------------------------*/ ),
        .HLS_USER_CNTL_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_VALID_CHK_RX      ( /*-----------------------------------------*/ ),
        .HLS_LAST_CHK_RX       ( /*-----------------------------------------*/ ), 
        .HLS_PRCL_TYPE_CHK_RX  ( /*-----------------------------------------*/ ),
        .HLS_CRDGNT_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_CRDRTN_CHK_RX     ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_REQ_CHK_RX ( /*-----------------------------------------*/ ),
        .HLS_ACTIVE_ACK_CHK_RX ( /*-----------------------------------------*/ )
      );
      
      if(IS_ACTIVE) begin : active_tb_hls_ib_compl_axi_if
      
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_RX_C_METADATA_WD                )
        ) i_hls_ib_compl_axi_cntl_bus_converter_wrapper (
          .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                                                                  ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                               ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                               ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_cntl[(loop_port * LOCAL_HLS_AXI_IB_C_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                     ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                            ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_cntl[((loop_port * LOCAL_HLS_AXI_IB_C_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_IB_C_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_valid[loop_port]                                                                                                ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_IB_C_CNTL_CHK_WD) +: LOCAL_HLS_AXI_IB_C_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                ),
          .cntl_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_crdgnt[loop_port]    = i_hls_ib_compl_axi_if.HLS_CRDGNT_RX                               ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_activeack[loop_port] = i_hls_ib_compl_axi_if.HLS_ACTIVE_ACK_RX                           ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_deacthint[loop_port] = i_hls_ib_compl_axi_if.HLS_DEACT_HINT_RX                           ;
        assign i_hls_ib_compl_axi_if.HLS_VALID_RX                                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_valid[loop_port]     ;
        assign i_hls_ib_compl_axi_if.HLS_CRDRTN_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_crdrtn[loop_port]    ;
        assign i_hls_ib_compl_axi_if.HLS_ACTIVE_REQ_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_activereq[loop_port] ;
        assign i_hls_ib_compl_axi_if.HLS_DATA_RX                                 = i_hls_ib_compl_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ib_compl_axi_if.HLS_CNTL_RX                                 = i_hls_ib_compl_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ib_compl_axi_if.HLS_USER_CNTL_RX                            = i_hls_ib_compl_axi_cntl_bus_converter_wrapper.user_o              ;
      end
      else begin : passive_tb_hls_ib_compl_axi_if
      
        //--- Control Bus Converter wrapper -------------------------------
        cdn_pcie_hls_bridge_cxs_bus_converter_wrapper_if #(
          .ACTIVE                     ( 0                                   ),
          .ASF_SUPPORT                ( ASF_SUPPORT                         ),
          .KMAX_DATAPATH_WD           ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD      ),
          .KMAX_NUM_TLPS_PER_CLK      ( LOCAL_HLS_AXI_KMAX_NUM_TLPS_PER_CLK ),
          .KMIN_START_ALIGNMENT_IN_DWS( KMIN_START_ALIGNMENT_IN_DWS         ),
          .HLS_PKT_CNTL_WD            ( LOCAL_HLS_AXI_PKT_CNTL_WD           ),
          .HLS_METADATA_WD            ( HLS_RX_C_METADATA_WD                )
        ) i_hls_ib_compl_axi_cntl_bus_converter_wrapper (
          .clk                ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                                                                  ),
          .rst_n              ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                                                ),
          .k_datapath_wd      ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD                                                                                                                               ),
          .k_dw_alignment     ( `HLS_BRIDGE_DUT_MODULE_NAME.k_hls_dw_alignment                                                                                                               ),
          .cntl_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_cntl[(loop_port * LOCAL_HLS_AXI_IB_C_CNTL_WD) +: LOCAL_HLS_AXI_PKT_CNTL_WD]                                     ),
          .data_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_data[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]                            ),
          .user_i             ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_cntl[((loop_port * LOCAL_HLS_AXI_IB_C_CNTL_WD) + LOCAL_HLS_AXI_PKT_CNTL_WD) +: LOCAL_HLS_AXI_IB_C_USER_CNTL_WD] ),
          .valid_i            ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_valid[loop_port]                                                                                                ),
          .full_cntl_parity_i ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_cntl_chk[(loop_port * LOCAL_HLS_AXI_IB_C_CNTL_CHK_WD) +: LOCAL_HLS_AXI_IB_C_CNTL_CHK_WD]                        ),
          .data_parity_i      ( `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_data_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD]                ),
          .cntl_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_o             ( /*- Assigned Below ---------------------------------------------------------------------------------------------------------------------------------------*/ ),
          .cntl_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ ),
          .data_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ ),
          .user_parity_o      ( /*--Not required for receiver ----------------------------------------------------------------------------------------------------------------------------*/ )
        );

        assign i_hls_ib_compl_axi_if.HLS_CRDGNT_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_crdgnt[loop_port]    ;
        assign i_hls_ib_compl_axi_if.HLS_ACTIVE_ACK_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_activeack[loop_port] ;
        assign i_hls_ib_compl_axi_if.HLS_DEACT_HINT_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_deacthint[loop_port] ;
        assign i_hls_ib_compl_axi_if.HLS_VALID_RX                                = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_valid[loop_port]     ; 
        assign i_hls_ib_compl_axi_if.HLS_CRDRTN_RX                               = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_crdrtn[loop_port]    ; 
        assign i_hls_ib_compl_axi_if.HLS_ACTIVE_REQ_RX                           = `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_activereq[loop_port] ;
        assign i_hls_ib_compl_axi_if.HLS_DATA_RX                                 = i_hls_ib_compl_axi_cntl_bus_converter_wrapper.data_o              ;
        assign i_hls_ib_compl_axi_if.HLS_CNTL_RX                                 = i_hls_ib_compl_axi_cntl_bus_converter_wrapper.cntl_o              ;
        assign i_hls_ib_compl_axi_if.HLS_USER_CNTL_RX                            = i_hls_ib_compl_axi_cntl_bus_converter_wrapper.user_o              ;
      end


      //------------------------------------------------------------------------------
      // AXI Stream Header to Log Master Interface
      //------------------------------------------------------------------------------
      cdnStream5Interface #(
        .DATA_WIDTH (LOCAL_HLS_AXI_KMAX_DATAPATH_WD),
        .USER_WIDTH (HDR2LOG_TUSER_WIDTH)
      ) i_hdr2log_mst_if (
        .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
        .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
      );

      if(IS_ACTIVE) begin : active_tb_hdr2log_mst_if

`ifdef VIPSR_46884732_WORKAROUND
        assign i_hdr2log_mst_if.tready                                                                                                     = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready[loop_port] ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid[loop_port]                                                                     = i_hdr2log_mst_if.tvalid                                 ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tlast[loop_port]                                                                      = i_hdr2log_mst_if.tlast                                  ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tdata[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD] = i_hdr2log_mst_if.tdata                                  ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tuser[(loop_port * HDR2LOG_TUSER_WIDTH) +: HDR2LOG_TUSER_WIDTH]                       = i_hdr2log_mst_if.tuser                                  ;

        cdn_pcie_hls_bridge_stream_parity_wrapper #(
          .ACTIVE      ( 1'b1                           ),
          .MASTER      ( 1'b1                           ),
          .ASF_SUPPORT ( ASF_SUPPORT                    ),
          .TDATA_WIDTH ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD ),
          .TUSER_WIDTH ( HDR2LOG_TUSER_WIDTH            )
        ) i_hdr2log_mst_stream_parity_wrapper (
          .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                                             ),
          .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                           ),
          .tvalid       ( i_hdr2log_mst_if.tvalid                                                                                                                 ),
          .tready       ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready[loop_port]                                                                                 ),
          .tdata        ( i_hdr2log_mst_if.tdata                                                                                                                  ),
          .tlast        ( i_hdr2log_mst_if.tlast                                                                                                                  ),
          .tuser        ( i_hdr2log_mst_if.tuser                                                                                                                  ),
          .twakeup      ( '0                                                                                                                                      ),
          .tvalidchk_i  ( /* -- Not required by transmitter ---------------------------------------------------------------------------------------------------*/ ),
          .treadychk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready_chk[loop_port]                                                                             ),
          .tdatachk_i   ( /* -- Not required by transmitter ---------------------------------------------------------------------------------------------------*/ ),
          .tlastchk_i   ( /* -- Not required by transmitter ---------------------------------------------------------------------------------------------------*/ ),
          .tuserchk_i   ( /* -- Not required by transmitter ---------------------------------------------------------------------------------------------------*/ ),
          .twakeupchk_i ( /* -- Not required by transmitter ---------------------------------------------------------------------------------------------------*/ ),
          .tvalidchk_o  ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid_chk[loop_port]                                                                             ),
          .treadychk_o  ( /* -- Not required by transmitter ---------------------------------------------------------------------------------------------------*/ ),
          .tdatachk_o   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tdata_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD] ),
          .tlastchk_o   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tlast_chk[loop_port]                                                                              ),
          .tuserchk_o   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tuser_chk[(loop_port * HDR2LOG_TUSER_CHK_WIDTH) +: HDR2LOG_TUSER_CHK_WIDTH]                       ),
          .twakeupchk_o ( /* -- Not present in the design -----------------------------------------------------------------------------------------------------*/ )
        );
`else
        assign i_hdr2log_mst_if.tready                                                                                                                 = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready[loop_port]     ;
        assign i_hdr2log_mst_if.treadychk                                                                                                              = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready_chk[loop_port] ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid[loop_port]                                                                                 = i_hdr2log_mst_if.tvalid                                     ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid_chk[loop_port]                                                                             = i_hdr2log_mst_if.tvalidchk                                  ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tlast[loop_port]                                                                                  = i_hdr2log_mst_if.tlast                                      ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tlast_chk[loop_port]                                                                              = i_hdr2log_mst_if.tlastchk                                   ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tdata[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]             = i_hdr2log_mst_if.tdata                                      ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tdata_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD] = i_hdr2log_mst_if.tdatachk                                   ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tuser[(loop_port * HDR2LOG_TUSER_WIDTH) +: HDR2LOG_TUSER_WIDTH]                                   = i_hdr2log_mst_if.tuser                                      ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tuser_chk[(loop_port * HDR2LOG_TUSER_CHK_WIDTH) +: HDR2LOG_TUSER_CHK_WIDTH]                       = i_hdr2log_mst_if.tuserchk                                   ;
`endif
      end
      else begin : passive_tb_hdr2log_mst_if
        assign i_hdr2log_mst_if.tready     = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready[loop_port]                                                                                 ;
        assign i_hdr2log_mst_if.treadychk  = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready_chk[loop_port]                                                                             ;
        assign i_hdr2log_mst_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid[loop_port]                                                                                 ;
        assign i_hdr2log_mst_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid_chk[loop_port]                                                                             ;
        assign i_hdr2log_mst_if.tlast      = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tlast[loop_port]                                                                                  ;
        assign i_hdr2log_mst_if.tlastchk   = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tlast_chk[loop_port]                                                                              ;
        assign i_hdr2log_mst_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tdata[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]             ;
        assign i_hdr2log_mst_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tdata_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_CHK_WD] ;
        assign i_hdr2log_mst_if.tuser      = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tuser[(loop_port * HDR2LOG_TUSER_WIDTH) +: HDR2LOG_TUSER_WIDTH]                                   ;
        assign i_hdr2log_mst_if.tuserchk   = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tuser_chk[(loop_port * HDR2LOG_TUSER_CHK_WIDTH) +: HDR2LOG_TUSER_CHK_WIDTH]                       ;
        
        // Unused signal Tied off to keep the VIP Happy 
        assign i_hdr2log_mst_if.tkeep      = '1                                                                                                                                      ;
        assign i_hdr2log_mst_if.tkeepchk   = '1                                                                                                                                      ;
        assign i_hdr2log_mst_if.tstrb      = '1                                                                                                                                      ;
        assign i_hdr2log_mst_if.tstrbchk   = '1                                                                                                                                      ;
        assign i_hdr2log_mst_if.twakeup    = '1                                                                                                                                      ;
        assign i_hdr2log_mst_if.twakeupchk = '0                                                                                                                                      ;
        assign i_hdr2log_mst_if.tid        = '0                                                                                                                                      ;
        assign i_hdr2log_mst_if.tidchk     = '1                                                                                                                                      ;
        assign i_hdr2log_mst_if.tdest      = '0                                                                                                                                      ;
        assign i_hdr2log_mst_if.tdestchk   = '1                                                                                                                                      ;

`ifdef VIPSR_46884732_WORKAROUND
        cdn_pcie_hls_bridge_stream_parity_wrapper #(
          .ACTIVE      ( 1'b0                           ),
          .MASTER      ( 1'b1                           ),
          .ASF_SUPPORT ( ASF_SUPPORT                    ),
          .TDATA_WIDTH ( LOCAL_HLS_AXI_KMAX_DATAPATH_WD ),
          .TUSER_WIDTH ( HDR2LOG_TUSER_WIDTH            )
        ) i_hdr2log_mst_stream_parity_wrapper (
          .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                                             ),
          .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                                           ),
          .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid[loop_port]                                                                                 ),
          .tready       ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready[loop_port]                                                                                 ),
          .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tdata[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]             ),
          .tlast        ( i_hdr2log_mst_if.tlast                                                                                                                  ),
          .tuser        ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tuser[(loop_port * HDR2LOG_TUSER_WIDTH) +: HDR2LOG_TUSER_WIDTH]                                   ),
          .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid_chk[loop_port]                                                                             ),
          .treadychk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tready_chk[loop_port]                                                                             ),
          .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tdata_chk[(loop_port * LOCAL_HLS_AXI_KMAX_DATAPATH_WD) +: LOCAL_HLS_AXI_KMAX_DATAPATH_WD]         ),
          .tlastchk_i   ( i_hdr2log_mst_if.tlastchk                                                                                                               ),
          .tuserchk_i   ( i_hdr2log_mst_if.tuserchk                                                                                                               ),
          .twakeupchk_i ( i_hdr2log_mst_if.twakeupchk                                                                                                             ),
          .tvalidchk_o  ( /* -- Not required by receiver ------------------------------------------------------------------------------------------------------*/ ),
          .treadychk_o  ( /* -- Not required by receiver ------------------------------------------------------------------------------------------------------*/ ),
          .tdatachk_o   ( /* -- Not required by receiver ------------------------------------------------------------------------------------------------------*/ ),
          .tlastchk_o   ( /* -- Not required by receiver ------------------------------------------------------------------------------------------------------*/ ),
          .tuserchk_o   ( /* -- Not required by receiver ------------------------------------------------------------------------------------------------------*/ ),
          .twakeupchk_o ( /* -- Not required by receiver ------------------------------------------------------------------------------------------------------*/ )
        );
`endif
      end


      //------------------------------------------------------------------------------
      // AXI Stream Delivered count Master Interface
      //------------------------------------------------------------------------------
      cdnStream5Interface #(
        .DATA_WIDTH (DELIVERED_P_TDATA_WIDTH)
      ) i_dc_mst_if (
        .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
        .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
      );

      if(IS_ACTIVE) begin : active_tb_dc_mst_if

`ifdef VIPSR_46884732_WORKAROUND
        assign `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tvalid[loop_port]                                                       = i_dc_mst_if.tvalid ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tdata[(loop_port * DELIVERED_P_TDATA_WIDTH) +: DELIVERED_P_TDATA_WIDTH] = i_dc_mst_if.tdata  ;
        
        assign i_dc_mst_if.tready                                                                                       = 1                  ;
        assign i_dc_mst_if.treadychk                                                                                    = 0                  ;

        cdn_pcie_hls_bridge_stream_parity_wrapper #(
          .ACTIVE      ( 1'b1                    ),
          .MASTER      ( 1'b1                    ),
          .ASF_SUPPORT ( ASF_SUPPORT             ),
          .TDATA_WIDTH ( DELIVERED_P_TDATA_WIDTH )
        ) i_dc_mst_stream_parity_wrapper (
          .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                          ),
          .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                        ),
          .tvalid       ( i_dc_mst_if.tvalid                                                                                                   ),
          .tready       ( i_dc_mst_if.tready                                                                                                   ),
          .tdata        ( i_dc_mst_if.tdata                                                                                                    ),
          .tlast        ( '0                                                                                                                   ),
          .tuser        ( '0                                                                                                                   ),
          .twakeup      ( '0                                                                                                                   ),
          .tvalidchk_i  ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .treadychk_i  ( i_dc_mst_if.treadychk                                                                                                ),
          .tdatachk_i   ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .tlastchk_i   ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .tuserchk_i   ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .twakeupchk_i ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .tvalidchk_o  ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tvalid_chk[loop_port]                                                               ),
          .treadychk_o  ( /* -- Not present in the design ----------------------------------------------------------------------------------*/ ),
          .tdatachk_o   ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tdata_chk[(loop_port * DELIVERED_P_TDATA_CHK_WIDTH) +: DELIVERED_P_TDATA_CHK_WIDTH] ),
          .tlastchk_o   ( /* -- Not present in the design ----------------------------------------------------------------------------------*/ ),
          .tuserchk_o   ( /* -- Not present in the design ----------------------------------------------------------------------------------*/ ),
          .twakeupchk_o ( /* -- Not present in the design ----------------------------------------------------------------------------------*/ )
        );
`else
        assign `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tvalid[loop_port]                                                                   = i_dc_mst_if.tvalid    ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tvalid_chk[loop_port]                                                               = i_dc_mst_if.tvalidchk ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tdata[(loop_port * DELIVERED_P_TDATA_WIDTH) +: DELIVERED_P_TDATA_WIDTH]             = i_dc_mst_if.tdata     ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tdata_chk[(loop_port * DELIVERED_P_TDATA_CHK_WIDTH) +: DELIVERED_P_TDATA_CHK_WIDTH] = i_dc_mst_if.tdatachk  ;

        assign i_dc_mst_if.tready                                                                                                   = 1                     ;
        assign i_dc_mst_if.treadychk                                                                                                = 0                     ;
`endif
      end
      else begin : passive_tb_dc_mst_if
        assign i_dc_mst_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tvalid[loop_port]                                                                   ;
        assign i_dc_mst_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tvalid_chk[loop_port]                                                               ;
        assign i_dc_mst_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tdata[(loop_port * DELIVERED_P_TDATA_WIDTH) +: DELIVERED_P_TDATA_WIDTH]             ;
        assign i_dc_mst_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tdata_chk[(loop_port * DELIVERED_P_TDATA_CHK_WIDTH) +: DELIVERED_P_TDATA_CHK_WIDTH] ;
        
        // Unused signal Tied off to keep the VIP Happy 
        assign i_dc_mst_if.tkeep      = '1                                                                                                                   ;
        assign i_dc_mst_if.tkeepchk   = '1                                                                                                                   ;
        assign i_dc_mst_if.tlast      = '1                                                                                                                   ;
        assign i_dc_mst_if.tlastchk   = '0                                                                                                                   ;
        assign i_dc_mst_if.tstrb      = '1                                                                                                                   ;
        assign i_dc_mst_if.tstrbchk   = '1                                                                                                                   ;
        assign i_dc_mst_if.twakeup    = '1                                                                                                                   ;
        assign i_dc_mst_if.twakeupchk = '0                                                                                                                   ;
        assign i_dc_mst_if.tid        = '0                                                                                                                   ;
        assign i_dc_mst_if.tidchk     = '1                                                                                                                   ;
        assign i_dc_mst_if.tdest      = '0                                                                                                                   ;
        assign i_dc_mst_if.tdestchk   = '1                                                                                                                   ;
        assign i_dc_mst_if.tuser      = '1                                                                                                                   ;
        assign i_dc_mst_if.tuserchk   = '1                                                                                                                   ;
        assign i_dc_mst_if.tready     = '1                                                                                                                   ;
        assign i_dc_mst_if.treadychk  = '0                                                                                                                   ;

`ifdef VIPSR_46884732_WORKAROUND
        cdn_pcie_hls_bridge_stream_parity_wrapper #(
          .ACTIVE      ( 1'b0                    ),
          .MASTER      ( 1'b1                    ),
          .ASF_SUPPORT ( ASF_SUPPORT             ),
          .TDATA_WIDTH ( DELIVERED_P_TDATA_WIDTH )
        ) i_dc_mst_stream_parity_wrapper (
          .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                          ),
          .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                        ),
          .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tvalid[loop_port]                                                                   ),
          .tready       ( i_dc_mst_if.tready                                                                                                   ),
          .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tdata[(loop_port * DELIVERED_P_TDATA_WIDTH) +: DELIVERED_P_TDATA_WIDTH]             ),
          .tlast        ( i_dc_mst_if.tlast                                                                                                    ),
          .tuser        ( i_dc_mst_if.tuser                                                                                                    ),
          .twakeup      ( i_dc_mst_if.twakeup                                                                                                  ),
          .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tvalid_chk[loop_port]                                                               ),
          .treadychk_i  ( i_dc_mst_if.treadychk                                                                                                ),
          .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_s_tdata_chk[(loop_port * DELIVERED_P_TDATA_CHK_WIDTH) +: DELIVERED_P_TDATA_CHK_WIDTH] ),
          .tlastchk_i   ( i_dc_mst_if.tlastchk                                                                                                 ),
          .tuserchk_i   ( i_dc_mst_if.tuserchk                                                                                                 ),
          .twakeupchk_i ( i_dc_mst_if.twakeupchk                                                                                               ),
          .tvalidchk_o  ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .treadychk_o  ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .tdatachk_o   ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .tlastchk_o   ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .tuserchk_o   ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .twakeupchk_o ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ )
        );
`endif
      end
      //------------------------------------------------------------------------------
      // AXI Stream QOS RX Master Interface
      //------------------------------------------------------------------------------
      cdnStream5Interface #(
        .DATA_WIDTH (TLP_QOS_TDATA_WIDTH)
      ) i_qos_mst_if (
        .aclk    ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
        .aresetn ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
      );

      if(IS_ACTIVE) begin : active_tb_qos_mst_if

`ifdef VIPSR_46884732_WORKAROUND
       assign `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tvalid[loop_port]= i_qos_mst_if.tvalid;
       assign `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tdata[(loop_port * TLP_QOS_TDATA_WIDTH) +: TLP_QOS_TDATA_WIDTH] = i_qos_mst_if.tdata; 
       assign i_qos_mst_if.tready    = 1;
       assign i_qos_mst_if.treadychk = 0;

        cdn_pcie_hls_bridge_stream_parity_wrapper #(
          .ACTIVE      ( 1'b1                ),
          .MASTER      ( 1'b1                ),
          .ASF_SUPPORT ( ASF_SUPPORT         ),
          .TDATA_WIDTH ( TLP_QOS_TDATA_WIDTH )
        ) i_qos_mst_stream_parity_wrapper (
          .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                             ),
          .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                           ),
          .tvalid       ( i_qos_mst_if.tvalid                                                                                              ),
          .tready       ( i_qos_mst_if.tready                                                                                              ),
          .tdata        ( i_qos_mst_if.tdata                                                                                               ),
          .tlast        ( '0                                                                                                                ),
          .tuser        ( '0                                                                                                                ),
          .twakeup      ( '0                                                                                                                ),
          .tvalidchk_i  ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .treadychk_i  ( i_qos_mst_if.treadychk                                                                                           ),
          .tdatachk_i   ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .tlastchk_i   ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .tuserchk_i   ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .twakeupchk_i ( /* -- Not required by transmitter --------------------------------------------------------------------------------*/ ),
          .tvalidchk_o  ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tvalid_chk[loop_port]                                                    ),
          .treadychk_o  ( /* -- Not present in the design ----------------------------------------------------------------------------------*/ ),
          .tdatachk_o   ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tdata_chk[(loop_port * TLP_QOS_TDATA_CHK_WIDTH) +: TLP_QOS_TDATA_CHK_WIDTH] ),
          .tlastchk_o   ( /* -- Not present in the design ----------------------------------------------------------------------------------*/ ),
          .tuserchk_o   ( /* -- Not present in the design ----------------------------------------------------------------------------------*/ ),
          .twakeupchk_o ( /* -- Not present in the design ----------------------------------------------------------------------------------*/ )
        );

`else
       assign `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tvalid[loop_port]= i_qos_mst_if.tvalid;
       assign `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tvalid_chk[loop_port] = i_qos_mst_if.tvalidchk;
       assign `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tdata[(loop_port * TLP_QOS_TDATA_WIDTH) +: TLP_QOS_TDATA_WIDTH]= i_qos_mst_if.tdata;  
       assign `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tdata_chk[(loop_port * TLP_QOS_TDATA_CHK_WIDTH) +: TLP_QOS_TDATA_CHK_WIDTH]= i_qos_mst_if.tdatachk;
       assign i_qos_mst_if.tready    = 1;
       assign i_qos_mst_if.treadychk = 0;
`endif

      end
      else begin : passive_tb_qos_mst_if

      assign i_qos_mst_if.tvalid    = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tvalid[loop_port];
      assign i_qos_mst_if.tvalidchk = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tvalid_chk[loop_port];
      assign i_qos_mst_if.tdata     = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tdata[(loop_port * TLP_QOS_TDATA_WIDTH) +: TLP_QOS_TDATA_WIDTH];  // pad to 24
      assign i_qos_mst_if.tdatachk  = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tdata_chk[(loop_port * TLP_QOS_TDATA_CHK_WIDTH) +: TLP_QOS_TDATA_CHK_WIDTH]; 
        // Unused signals Tied off to keep the VIP Happy
        assign i_qos_mst_if.tkeep      = '1 ;
        assign i_qos_mst_if.tkeepchk   = '1 ;
        assign i_qos_mst_if.tlast      = '1 ;
        assign i_qos_mst_if.tlastchk   = '0 ;
        assign i_qos_mst_if.tstrb      = '1 ;
        assign i_qos_mst_if.tstrbchk   = '1 ;
        assign i_qos_mst_if.twakeup    = '1 ;
        assign i_qos_mst_if.twakeupchk = '0 ;
        assign i_qos_mst_if.tid        = '0 ;
        assign i_qos_mst_if.tidchk     = '1 ;
        assign i_qos_mst_if.tdest      = '0 ;
        assign i_qos_mst_if.tdestchk   = '1 ;
        assign i_qos_mst_if.tuser      = '1 ;
        assign i_qos_mst_if.tuserchk   = '1 ;
        assign i_qos_mst_if.tready     = '1 ;
        assign i_qos_mst_if.treadychk  = '0 ;

`ifdef VIPSR_46884732_WORKAROUND
        cdn_pcie_hls_bridge_stream_parity_wrapper #(
          .ACTIVE      ( 1'b0                ),
          .MASTER      ( 1'b1                ),
          .ASF_SUPPORT ( ASF_SUPPORT         ),
          .TDATA_WIDTH ( TLP_QOS_TDATA_WIDTH )
        ) i_qos_mst_stream_parity_wrapper (
          .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                             ),
          .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                           ),
          .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tvalid[loop_port]                                                        ),
          .tready       ( i_qos_mst_if.tready                                                                                              ),
          .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tdata[(loop_port * TLP_QOS_TDATA_WIDTH) +: TLP_QOS_TDATA_WIDTH]    ),
          .tlast        ( i_qos_mst_if.tlast                                                                                               ),
          .tuser        ( i_qos_mst_if.tuser                                                                                               ),
          .twakeup      ( i_qos_mst_if.twakeup                                                                                             ),
          .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tvalid_chk[loop_port]                                                    ),
          .treadychk_i  ( i_qos_mst_if.treadychk                                                                                           ),
          .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_rx_tdata_chk[(loop_port * TLP_QOS_TDATA_CHK_WIDTH) +: TLP_QOS_TDATA_CHK_WIDTH] ),
          .tlastchk_i   ( i_qos_mst_if.tlastchk                                                                                            ),
          .tuserchk_i   ( i_qos_mst_if.tuserchk                                                                                            ),
          .twakeupchk_i ( i_qos_mst_if.twakeupchk                                                                                          ),
          .tvalidchk_o  ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .treadychk_o  ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .tdatachk_o   ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .tlastchk_o   ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .tuserchk_o   ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ ),
          .twakeupchk_o ( /* -- Not required by receiver -----------------------------------------------------------------------------------*/ )
        );
`endif

      end

      


      //------------------------------------------------------------------------------
      // AXI Stream LTI Completion TX Interface
      //------------------------------------------------------------------------------
      cdnStream5Interface #(
        .DATA_WIDTH (LTI_C_TDATA_WIDTH)
      ) i_lti_c_tx_if (
        .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
        .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
      );

      if(IS_ACTIVE) begin : active_tb_lti_c_tx_if
`ifdef VIPSR_46884732_WORKAROUND
        assign `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tvalid[loop_port]                                           = i_lti_c_tx_if.tvalid ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tdata[(loop_port * LTI_C_TDATA_WIDTH) +: LTI_C_TDATA_WIDTH] = i_lti_c_tx_if.tdata  ;
        
        assign i_lti_c_tx_if.tready                                                                             = 1                    ;
        assign i_lti_c_tx_if.treadychk                                                                          = 0                    ;

        cdn_pcie_hls_bridge_stream_parity_wrapper #(
          .ACTIVE      ( 1'b1              ),
          .MASTER      ( 1'b1              ),
          .ASF_SUPPORT ( ASF_SUPPORT       ),
          .TDATA_WIDTH ( LTI_C_TDATA_WIDTH )
        ) i_lti_c_tx_stream_parity_wrapper (
          .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                          ),
          .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                        ),
          .tvalid       ( i_lti_c_tx_if.tvalid                                                                                                 ),
          .tready       ( i_lti_c_tx_if.tready                                                                                                 ),
          .tdata        ( i_lti_c_tx_if.tdata                                                                                                  ),
          .tlast        ( '0                                                                                                                   ),
          .tuser        ( '0                                                                                                                   ),
          .twakeup      ( '0                                                                                                                   ),
          .tvalidchk_i  ( /* -- Not required by active master ------------------------------------------------------------------------------*/ ),
          .treadychk_i  ( i_lti_c_tx_if.treadychk                                                                                              ),
          .tdatachk_i   ( /* -- Not required by active master ------------------------------------------------------------------------------*/ ),
          .tlastchk_i   ( /* -- Not required by active master ------------------------------------------------------------------------------*/ ),
          .tuserchk_i   ( /* -- Not required by active master ------------------------------------------------------------------------------*/ ),
          .twakeupchk_i ( /* -- Not required by active master ------------------------------------------------------------------------------*/ ),
          .tvalidchk_o  ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tvalid_chk[loop_port]                                                           ),
          .treadychk_o  ( /* -- Not required by active master ------------------------------------------------------------------------------*/ ),
          .tdatachk_o   ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tdata_chk[(loop_port * LTI_C_TDATA_CHK_WIDTH) +: LTI_C_TDATA_CHK_WIDTH]         ),
          .tlastchk_o   ( /* -- Not required by active master ------------------------------------------------------------------------------*/ ),
          .tuserchk_o   ( /* -- Not required by active master ------------------------------------------------------------------------------*/ ),
          .twakeupchk_o ( /* -- Not required by active master ------------------------------------------------------------------------------*/ )
        );
`else
        assign `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tvalid[loop_port]                                                       = i_lti_c_tx_if.tvalid    ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tvalid_chk[loop_port]                                                   = i_lti_c_tx_if.tvalidchk ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tdata[(loop_port * LTI_C_TDATA_WIDTH) +: LTI_C_TDATA_WIDTH]             = i_lti_c_tx_if.tdata     ;
        assign `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tdata_chk[(loop_port * LTI_C_TDATA_CHK_WIDTH) +: LTI_C_TDATA_CHK_WIDTH] = i_lti_c_tx_if.tdatachk  ;
        
        assign i_lti_c_tx_if.tready                                                                                         = 1                       ;
        assign i_lti_c_tx_if.treadychk                                                                                      = 0                       ;
`endif
      end
      else begin : passive_tb_lti_c_tx_if
        assign i_lti_c_tx_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tvalid[loop_port]                                                       ;
        assign i_lti_c_tx_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tvalid_chk[loop_port]                                                   ;
        assign i_lti_c_tx_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tdata[(loop_port * LTI_C_TDATA_WIDTH) +: LTI_C_TDATA_WIDTH]             ;
        assign i_lti_c_tx_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tdata_chk[(loop_port * LTI_C_TDATA_CHK_WIDTH) +: LTI_C_TDATA_CHK_WIDTH] ;
        
        // Unused signal Tied off to keep the VIP Happy 
        assign i_lti_c_tx_if.tkeep      = '1                                                                                                           ;
        assign i_lti_c_tx_if.tkeepchk   = '1                                                                                                           ;
        assign i_lti_c_tx_if.tlast      = '1                                                                                                           ;
        assign i_lti_c_tx_if.tlastchk   = '0                                                                                                           ;
        assign i_lti_c_tx_if.tstrb      = '1                                                                                                           ;
        assign i_lti_c_tx_if.tstrbchk   = '1                                                                                                           ;
        assign i_lti_c_tx_if.twakeup    = '1                                                                                                           ;
        assign i_lti_c_tx_if.twakeupchk = '0                                                                                                           ;
        assign i_lti_c_tx_if.tid        = '0                                                                                                           ;
        assign i_lti_c_tx_if.tidchk     = '1                                                                                                           ;
        assign i_lti_c_tx_if.tdest      = '0                                                                                                           ;
        assign i_lti_c_tx_if.tdestchk   = '1                                                                                                           ;
        assign i_lti_c_tx_if.tuser      = '1                                                                                                           ;
        assign i_lti_c_tx_if.tuserchk   = '1                                                                                                           ;
        assign i_lti_c_tx_if.tready     = '1                                                                                                           ;
        assign i_lti_c_tx_if.treadychk  = '0                                                                                                           ;

`ifdef VIPSR_46884732_WORKAROUND
        cdn_pcie_hls_bridge_stream_parity_wrapper #(
          .ACTIVE      ( 1'b0              ),
          .MASTER      ( 1'b1              ),
          .ASF_SUPPORT ( ASF_SUPPORT       ),
          .TDATA_WIDTH ( LTI_C_TDATA_WIDTH )
        ) i_lti_c_tx_stream_parity_wrapper (
          .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                                                                          ),
          .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                                                                        ),
          .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tvalid[loop_port]                                                               ),
          .tready       ( i_lti_c_tx_if.tready                                                                                                 ),
          .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tdata[(loop_port * LTI_C_TDATA_WIDTH) +: LTI_C_TDATA_WIDTH]                     ),
          .tlast        ( i_lti_c_tx_if.tlast                                                                                                  ),
          .tuser        ( i_lti_c_tx_if.tuser                                                                                                  ),
          .twakeup      ( i_lti_c_tx_if.twakeup                                                                                                ),
          .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tvalid_chk[loop_port]                                                           ),
          .treadychk_i  ( i_lti_c_tx_if.treadychk                                                                                              ),
          .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_rx_tdata_chk[(loop_port * LTI_C_TDATA_CHK_WIDTH) +: LTI_C_TDATA_CHK_WIDTH]         ),
          .tlastchk_i   ( i_lti_c_tx_if.tlastchk                                                                                               ),
          .tuserchk_i   ( i_lti_c_tx_if.tuserchk                                                                                               ),
          .twakeupchk_i ( i_lti_c_tx_if.twakeupchk                                                                                             ),
          .tvalidchk_o  ( /* -- Not required by passive instance ---------------------------------------------------------------------------*/ ),
          .treadychk_o  ( /* -- Not required by passive instance ---------------------------------------------------------------------------*/ ),
          .tdatachk_o   ( /* -- Not required by passive instance ---------------------------------------------------------------------------*/ ),
          .tlastchk_o   ( /* -- Not required by passive instance ---------------------------------------------------------------------------*/ ),
          .tuserchk_o   ( /* -- Not required by passive instance ---------------------------------------------------------------------------*/ ),
          .twakeupchk_o ( /* -- Not required by passive instance ---------------------------------------------------------------------------*/ )
        );
`endif
      end
     

      initial begin : SET_CONFIG_DB_PER_HLS_PORT_LOCALLY
        string scope;

        $sformat(scope, "%0s", if_get_harness_instance_path());
       
        uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, $sformatf("local_hls_ob_posted_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), i_hls_ob_posted_axi_if.passive.i_hlsInterfaceLinkCtrl);
        uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, $sformatf("local_hls_ob_nonposted_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), i_hls_ob_nonposted_axi_if.passive.i_hlsInterfaceLinkCtrl);
        uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, $sformatf("local_hls_ob_compl_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), i_hls_ob_compl_axi_if.passive.i_hlsInterfaceLinkCtrl);
        uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, $sformatf("local_hls_ib_posted_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), i_hls_ib_posted_axi_if.passive.i_hlsInterfaceLinkCtrl);
        uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, $sformatf("local_hls_ib_nonposted_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), i_hls_ib_nonposted_axi_if.passive.i_hlsInterfaceLinkCtrl);
        uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, $sformatf("local_hls_ib_compl_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), i_hls_ib_compl_axi_if.passive.i_hlsInterfaceLinkCtrl);
        uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(LOCAL_HLS_AXI_KMAX_DATAPATH_WD), .USER_WIDTH(HDR2LOG_TUSER_WIDTH)))::set(null, scope, $sformatf("local_hdr2log_mst_stream_vif[%0d]", loop_port), i_hdr2log_mst_if);
        uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(DELIVERED_P_TDATA_WIDTH)))::set(null, scope, $sformatf("local_dc_mst_stream_vif[%0d]", loop_port), i_dc_mst_if);
	uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(TLP_QOS_TDATA_WIDTH)))::set(null, scope,$sformatf("local_qos_mst_stream_vif[%0d]", loop_port),i_qos_mst_if);
        uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(LTI_C_TDATA_WIDTH)))::set(null, scope, $sformatf("local_lti_c_tx_stream_vif[%0d]", loop_port), i_lti_c_tx_if);

        tb_local_uvm_db_set_done_per_hls_port[loop_port] = 1'b1;
      end

    end : GEN_NUM_HLS_PORTS
  endgenerate


  //------------------------------------------------------------------------------
  // AXI Lite Master Interface
  // Used to access HLS Bridge/DTI/AXI Bridge Registers and connected with
  // DUT AXIL Slave Interface(AXI Bridge registers are not present in design 
  // hence the information is passed to the AXI Bridge module.)
  //------------------------------------------------------------------------------
  cdnAxi5LiteInterface #(
    .ADDR_WIDTH            ( AXIL_ADDR_WIDTH     ),
    .READ_DATA_WIDTH       ( AXIL_DATA_WIDTH     ),
    .WRITE_DATA_WIDTH      ( AXIL_DATA_WIDTH     ),
    .READ_ADDR_USER_WIDTH  ( AXIL_S_ARUSER_WIDTH ),
    .WRITE_ADDR_USER_WIDTH ( AXIL_S_AWUSER_WIDTH ),
    .RESP_USER_WIDTH       ( AXIL_S_BUSER_WIDTH  ),
    .READ_USER_WIDTH       ( AXIL_S_RUSER_WIDTH  ),
    .WRITE_USER_WIDTH      ( AXIL_S_WUSER_WIDTH  ),
    .BRESP_WIDTH           ( AXIL_DATA_WIDTH / 8 ),
    .RRESP_WIDTH           ( AXIL_DATA_WIDTH / 8 )
  ) i_axi5_lite_mst_if (
    .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.axil_clk   ),
    .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.axil_rst_n )
  );
   
  generate
    if(IS_ACTIVE) begin : active_tb_axi5_lite_mst_if
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awvalid     = i_axi5_lite_mst_if.awvalid         ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awvalid_chk = i_axi5_lite_mst_if.awvalidchk      ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awaddr      = i_axi5_lite_mst_if.awaddr          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awaddr_chk  = i_axi5_lite_mst_if.awaddrchk       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awprot      = i_axi5_lite_mst_if.awprot          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awctl_chk0  = i_axi5_lite_mst_if.awctlchk0       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awuser      = i_axi5_lite_mst_if.awuser          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awuser_chk  = i_axi5_lite_mst_if.awuserchk       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wvalid      = i_axi5_lite_mst_if.wvalid          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wvalid_chk  = i_axi5_lite_mst_if.wvalidchk       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wdata       = i_axi5_lite_mst_if.wdata           ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wdata_chk   = i_axi5_lite_mst_if.wdatachk        ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wstrb       = i_axi5_lite_mst_if.wstrb           ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wstrb_chk   = i_axi5_lite_mst_if.wstrbchk        ;
      // assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wuser       = i_axi5_lite_mst_if.wuser           ;
      // assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wuser_chk   = i_axi5_lite_mst_if.wuserchk        ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bready      = i_axi5_lite_mst_if.bready          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bready_chk  = i_axi5_lite_mst_if.breadychk       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arvalid     = i_axi5_lite_mst_if.arvalid         ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arvalid_chk = i_axi5_lite_mst_if.arvalidchk      ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_araddr      = i_axi5_lite_mst_if.araddr          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_araddr_chk  = i_axi5_lite_mst_if.araddrchk       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arprot      = i_axi5_lite_mst_if.arprot          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arctl_chk0  = i_axi5_lite_mst_if.arctlchk0       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_aruser      = i_axi5_lite_mst_if.aruser          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_aruser_chk  = i_axi5_lite_mst_if.aruserchk       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rready      = i_axi5_lite_mst_if.rready          ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rready_chk  = i_axi5_lite_mst_if.rreadychk       ;
 
      assign i_axi5_lite_mst_if.awready          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awready    ;
      assign i_axi5_lite_mst_if.awreadychk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awready_chk;   
      assign i_axi5_lite_mst_if.wready           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wready     ;
      assign i_axi5_lite_mst_if.wreadychk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wready_chk ;
      assign i_axi5_lite_mst_if.bvalid           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bvalid     ;
      assign i_axi5_lite_mst_if.bvalidchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bvalid_chk ;
      assign i_axi5_lite_mst_if.bresp            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bresp      ;
      assign i_axi5_lite_mst_if.brespchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bresp_chk  ;
      // assign i_axi5_lite_mst_if.buser            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_buser      ;
      // assign i_axi5_lite_mst_if.buserchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_buser_chk  ;
      assign i_axi5_lite_mst_if.arready          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arready    ;
      assign i_axi5_lite_mst_if.arreadychk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arready_chk;
      assign i_axi5_lite_mst_if.rvalid           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rvalid     ;
      assign i_axi5_lite_mst_if.rvalidchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rvalid_chk ;
      assign i_axi5_lite_mst_if.rdata            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rdata      ;
      assign i_axi5_lite_mst_if.rdatachk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rdata_chk  ;
      assign i_axi5_lite_mst_if.rresp            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rresp      ;
      assign i_axi5_lite_mst_if.rrespchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rresp_chk  ;
      // assign i_axi5_lite_mst_if.ruser            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_ruser      ;
      // assign i_axi5_lite_mst_if.ruserchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_ruser_chk  ;
      
      //TODO:: Check if buser,ruser,wuser are removed now.
      assign i_axi5_lite_mst_if.bid      = '0;
      assign i_axi5_lite_mst_if.bidchk   = '1;
      assign i_axi5_lite_mst_if.buser    = '0;
      assign i_axi5_lite_mst_if.buserchk = '1;
      assign i_axi5_lite_mst_if.ruser    = '0;
      assign i_axi5_lite_mst_if.ruserchk = '1;
      assign i_axi5_lite_mst_if.rid      = '0;
      assign i_axi5_lite_mst_if.ridchk   = '1;
    end
    else begin : passive_tb_axi5_lite_mst_if
      assign i_axi5_lite_mst_if.awvalid          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awvalid    ;  
      assign i_axi5_lite_mst_if.awvalidchk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awvalid_chk;  
      assign i_axi5_lite_mst_if.awaddr           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awaddr     ;  
      assign i_axi5_lite_mst_if.awaddrchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awaddr_chk ;  
      assign i_axi5_lite_mst_if.awprot           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awprot     ;  
      assign i_axi5_lite_mst_if.awuser           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awuser     ;  
      assign i_axi5_lite_mst_if.awuserchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awuser_chk ; 
      assign i_axi5_lite_mst_if.awctlchk0        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awctl_chk0 ;
      assign i_axi5_lite_mst_if.wvalid           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wvalid     ;  
      assign i_axi5_lite_mst_if.wvalidchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wvalid_chk ;  
      assign i_axi5_lite_mst_if.wdata            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wdata      ;  
      assign i_axi5_lite_mst_if.wdatachk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wdata_chk  ;  
      assign i_axi5_lite_mst_if.wstrb            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wstrb      ;  
      assign i_axi5_lite_mst_if.wstrbchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wstrb_chk  ;  
      assign i_axi5_lite_mst_if.wuser            = '0;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wuser      ;  
      assign i_axi5_lite_mst_if.wuserchk         = '1;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wuser_chk  ;  
      assign i_axi5_lite_mst_if.bready           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bready     ;  
      assign i_axi5_lite_mst_if.breadychk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bready_chk ;  
      assign i_axi5_lite_mst_if.arvalid          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arvalid    ;  
      assign i_axi5_lite_mst_if.arvalidchk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arvalid_chk;  
      assign i_axi5_lite_mst_if.araddr           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_araddr     ; 
      assign i_axi5_lite_mst_if.araddrchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_araddr_chk ;  
      assign i_axi5_lite_mst_if.arprot           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arprot     ; 
      assign i_axi5_lite_mst_if.arctlchk0        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arctl_chk0 ; 
      assign i_axi5_lite_mst_if.aruser           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_aruser     ;  
      assign i_axi5_lite_mst_if.aruserchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_aruser_chk ; 
      assign i_axi5_lite_mst_if.rready           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rready     ;  
      assign i_axi5_lite_mst_if.rreadychk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rready_chk ;  
      assign i_axi5_lite_mst_if.awready          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awready    ;
      assign i_axi5_lite_mst_if.awreadychk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_awready_chk;      
      assign i_axi5_lite_mst_if.wready           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wready     ;
      assign i_axi5_lite_mst_if.wreadychk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_wready_chk ;
      assign i_axi5_lite_mst_if.bvalid           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bvalid     ;
      assign i_axi5_lite_mst_if.bvalidchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bvalid_chk ;
      assign i_axi5_lite_mst_if.bresp            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bresp      ;
      assign i_axi5_lite_mst_if.brespchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_bresp_chk  ;
      assign i_axi5_lite_mst_if.buser            = '0;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_s_buser      ;
      assign i_axi5_lite_mst_if.buserchk         = '1;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_s_buser_chk  ;
      assign i_axi5_lite_mst_if.arready          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arready    ;
      assign i_axi5_lite_mst_if.arreadychk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_arready_chk;
      assign i_axi5_lite_mst_if.rvalid           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rvalid     ;
      assign i_axi5_lite_mst_if.rvalidchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rvalid_chk ;
      assign i_axi5_lite_mst_if.rdata            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rdata      ;
      assign i_axi5_lite_mst_if.rdatachk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rdata_chk  ;
      assign i_axi5_lite_mst_if.rresp            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rresp      ;
      assign i_axi5_lite_mst_if.rrespchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_s_rresp_chk  ;
      assign i_axi5_lite_mst_if.ruser            = '0;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_s_ruser      ;
      assign i_axi5_lite_mst_if.ruserchk         = '1;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_s_ruser_chk  ;
    
      // Tied off unused VIP Signals
      assign i_axi5_lite_mst_if.bid     = '0;
      assign i_axi5_lite_mst_if.bidchk  = '1;
      assign i_axi5_lite_mst_if.arid    = '0;
      assign i_axi5_lite_mst_if.aridchk = '1;
      assign i_axi5_lite_mst_if.awid    = '0;
      assign i_axi5_lite_mst_if.awidchk = '1;
      assign i_axi5_lite_mst_if.rid     = '0;
      assign i_axi5_lite_mst_if.ridchk  = '1;
    end
  endgenerate
  
  //------------------------------------------------------------------------------
  // AXI Lite Slave Interface
  // Connected with DUT's AXIL Master Interface which will be connected to the
  // AXI Bridge at the TOP to access AXI Bridge Registers.
  //------------------------------------------------------------------------------
  cdnAxi5LiteInterface #(
    .ADDR_WIDTH            ( AXIL_ADDR_WIDTH     ),
    .READ_DATA_WIDTH       ( AXIL_DATA_WIDTH     ),
    .WRITE_DATA_WIDTH      ( AXIL_DATA_WIDTH     ),
    .READ_ADDR_USER_WIDTH  ( AXIL_S_ARUSER_WIDTH ),
    .WRITE_ADDR_USER_WIDTH ( AXIL_S_AWUSER_WIDTH ),
    .RESP_USER_WIDTH       ( AXIL_S_BUSER_WIDTH  ),
    .READ_USER_WIDTH       ( AXIL_S_RUSER_WIDTH  ),
    .WRITE_USER_WIDTH      ( AXIL_S_WUSER_WIDTH  ),
    .BRESP_WIDTH           ( AXIL_DATA_WIDTH / 8 ),
    .RRESP_WIDTH           ( AXIL_DATA_WIDTH / 8 )
  ) i_axi5_lite_slv_if (
    .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.axil_clk   ),
    .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.axil_rst_n )
  );

  generate
    if(IS_ACTIVE) begin : active_tb_axi5_lite_slv_if
      assign i_axi5_lite_slv_if.awvalid       =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awvalid    ;
      assign i_axi5_lite_slv_if.awvalidchk    =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awvalid_chk;
      assign i_axi5_lite_slv_if.awaddr        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awaddr     ;
      assign i_axi5_lite_slv_if.awaddrchk     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awaddr_chk ;
      assign i_axi5_lite_slv_if.awprot        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awprot     ;
      assign i_axi5_lite_slv_if.awctlchk0     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awctl_chk0 ;
      assign i_axi5_lite_slv_if.awuser        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awuser     ;
      assign i_axi5_lite_slv_if.awuserchk     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awuser_chk ;
      assign i_axi5_lite_slv_if.awid          =  '0                                            ;      
      assign i_axi5_lite_slv_if.wvalid        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wvalid     ;
      assign i_axi5_lite_slv_if.wvalidchk     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wvalid_chk ;
      assign i_axi5_lite_slv_if.wdata         =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wdata      ;
      assign i_axi5_lite_slv_if.wdatachk      =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wdata_chk  ;
      assign i_axi5_lite_slv_if.wstrb         =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wstrb      ;
      assign i_axi5_lite_slv_if.wstrbchk      =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wstrb_chk  ;
      // assign i_axi5_lite_slv_if.wuser         =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wuser      ;
      // assign i_axi5_lite_slv_if.wuserchk      =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wuser_chk  ;
      assign i_axi5_lite_slv_if.bready        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bready     ;
      assign i_axi5_lite_slv_if.breadychk     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bready_chk ;
      assign i_axi5_lite_slv_if.arvalid       =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arvalid    ;
      assign i_axi5_lite_slv_if.arvalidchk    =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arvalid_chk;
      assign i_axi5_lite_slv_if.araddr        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_araddr     ;
      assign i_axi5_lite_slv_if.araddrchk     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_araddr_chk ;
      assign i_axi5_lite_slv_if.arprot        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arprot     ;
      assign i_axi5_lite_slv_if.arctlchk0     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arctl_chk0 ;
      assign i_axi5_lite_slv_if.aruser        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_aruser     ;
      assign i_axi5_lite_slv_if.aruserchk     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_aruser_chk ;
      assign i_axi5_lite_slv_if.arid          =  '0                                            ;            
      assign i_axi5_lite_slv_if.rready        =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rready     ;
      assign i_axi5_lite_slv_if.rreadychk     =  `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rready_chk ;
 
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awready     = i_axi5_lite_slv_if.awready       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awready_chk = i_axi5_lite_slv_if.awreadychk    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wready      = i_axi5_lite_slv_if.wready        ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wready_chk  = i_axi5_lite_slv_if.wreadychk     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bvalid      = i_axi5_lite_slv_if.bvalid        ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bvalid_chk  = i_axi5_lite_slv_if.bvalidchk     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bresp       = i_axi5_lite_slv_if.bresp         ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bresp_chk   = i_axi5_lite_slv_if.brespchk      ;
      // assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_buser       = i_axi5_lite_slv_if.buser         ;
      // assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_buser_chk   = i_axi5_lite_slv_if.buserchk      ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arready     = i_axi5_lite_slv_if.arready       ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arready_chk = i_axi5_lite_slv_if.arreadychk    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rvalid      = i_axi5_lite_slv_if.rvalid        ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rvalid_chk  = i_axi5_lite_slv_if.rvalidchk     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rdata       = i_axi5_lite_slv_if.rdata         ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rdata_chk   = i_axi5_lite_slv_if.rdatachk      ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rresp       = i_axi5_lite_slv_if.rresp         ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rresp_chk   = i_axi5_lite_slv_if.rrespchk      ;
      // assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_ruser       = i_axi5_lite_slv_if.ruser         ;
      // assign `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_ruser_chk   = i_axi5_lite_slv_if.ruserchk      ;
      
      //TODO:: Check if buser,ruser,wuser are removed now.
      assign i_axi5_lite_slv_if.wuser    = '0;
      assign i_axi5_lite_slv_if.wuserchk = '1;
      
      // Tied off unused VIP Signals
      assign i_axi5_lite_slv_if.arid    = '0;
      assign i_axi5_lite_slv_if.aridchk = '1;
      assign i_axi5_lite_slv_if.awid    = '0;
      assign i_axi5_lite_slv_if.awidchk = '1;
    end
    else begin : passive_tb_axi5_lite_slv_if
      assign i_axi5_lite_slv_if.awvalid          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awvalid    ;  
      assign i_axi5_lite_slv_if.awvalidchk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awvalid_chk;  
      assign i_axi5_lite_slv_if.awaddr           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awaddr     ;  
      assign i_axi5_lite_slv_if.awaddrchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awaddr_chk ;  
      assign i_axi5_lite_slv_if.awprot           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awprot     ; 
      assign i_axi5_lite_slv_if.awctlchk0        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awctl_chk0 ;
      assign i_axi5_lite_slv_if.awuser           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awuser     ;  
      assign i_axi5_lite_slv_if.awuserchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awuser_chk ; 
      assign i_axi5_lite_slv_if.awid             = '0                                            ;      
      assign i_axi5_lite_slv_if.wvalid           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wvalid     ;  
      assign i_axi5_lite_slv_if.wvalidchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wvalid_chk ;  
      assign i_axi5_lite_slv_if.wdata            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wdata      ;  
      assign i_axi5_lite_slv_if.wdatachk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wdata_chk  ;  
      assign i_axi5_lite_slv_if.wstrb            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wstrb      ;  
      assign i_axi5_lite_slv_if.wstrbchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wstrb_chk  ;  
      assign i_axi5_lite_slv_if.wuser            = '0;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wuser      ;  
      assign i_axi5_lite_slv_if.wuserchk         = '1;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wuser_chk  ;  
      assign i_axi5_lite_slv_if.bready           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bready     ;  
      assign i_axi5_lite_slv_if.breadychk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bready_chk ;  
      assign i_axi5_lite_slv_if.arvalid          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arvalid    ;  
      assign i_axi5_lite_slv_if.arvalidchk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arvalid_chk;  
      assign i_axi5_lite_slv_if.araddr           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_araddr     ; 
      assign i_axi5_lite_slv_if.araddrchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_araddr_chk ;  
      assign i_axi5_lite_slv_if.arprot           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arprot     ; 
      assign i_axi5_lite_slv_if.arctlchk0        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arctl_chk0 ; 
      assign i_axi5_lite_slv_if.aruser           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_aruser     ;  
      assign i_axi5_lite_slv_if.aruserchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_aruser_chk ; 
      assign i_axi5_lite_slv_if.arid             = '0                                            ;      
      assign i_axi5_lite_slv_if.rready           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rready     ;  
      assign i_axi5_lite_slv_if.rreadychk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rready_chk ;  
      assign i_axi5_lite_slv_if.awready          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awready    ;
      assign i_axi5_lite_slv_if.awreadychk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_awready_chk;
      assign i_axi5_lite_slv_if.wready           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wready     ;
      assign i_axi5_lite_slv_if.wreadychk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_wready_chk ;
      assign i_axi5_lite_slv_if.bvalid           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bvalid     ;
      assign i_axi5_lite_slv_if.bvalidchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bvalid_chk ;
      assign i_axi5_lite_slv_if.bresp            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bresp      ;
      assign i_axi5_lite_slv_if.brespchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_bresp_chk  ;
      assign i_axi5_lite_slv_if.buser            = '0;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_m_buser      ;
      assign i_axi5_lite_slv_if.buserchk         = '1;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_m_buser_chk  ;
      assign i_axi5_lite_slv_if.arready          = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arready    ;
      assign i_axi5_lite_slv_if.arreadychk       = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_arready_chk;
      assign i_axi5_lite_slv_if.rvalid           = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rvalid     ;
      assign i_axi5_lite_slv_if.rvalidchk        = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rvalid_chk ;
      assign i_axi5_lite_slv_if.rdata            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rdata      ;
      assign i_axi5_lite_slv_if.rdatachk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rdata_chk  ;
      assign i_axi5_lite_slv_if.rresp            = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rresp      ;
      assign i_axi5_lite_slv_if.rrespchk         = `HLS_BRIDGE_DUT_MODULE_NAME.axil_m_rresp_chk  ;
      assign i_axi5_lite_slv_if.ruser            = '0;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_m_ruser      ;
      assign i_axi5_lite_slv_if.ruserchk         = '1;//`HLS_BRIDGE_DUT_MODULE_NAME.axil_m_ruser_chk  ;
      
      // Tied off unused VIP Signals
      assign i_axi5_lite_slv_if.arid    = '0;
      assign i_axi5_lite_slv_if.aridchk = '1;
      assign i_axi5_lite_slv_if.awid    = '0;
      assign i_axi5_lite_slv_if.awidchk = '1;
    end
  endgenerate
  
  //------------------------------------------------------------------------------
  // AXI Stream Header to Log Slave Interface
  //------------------------------------------------------------------------------
  cdnStream5Interface #(
    .DATA_WIDTH (KMAX_DATAPATH_WD),
    .USER_WIDTH (HDR2LOG_TUSER_WIDTH)
  ) i_hdr2log_slv_if (
    .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
  );

  if(IS_ACTIVE) begin : active_tb_hdr2log_slv_if
    assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tready     = i_hdr2log_slv_if.tready                          ;
`ifndef VIPSR_46884732_WORKAROUND
    assign `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tready_chk = i_hdr2log_slv_if.treadychk                       ;
`endif
    assign i_hdr2log_slv_if.tvalid                          = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid     ;
    assign i_hdr2log_slv_if.tvalidchk                       = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid_chk ;
    assign i_hdr2log_slv_if.tlast                           = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tlast      ;
    assign i_hdr2log_slv_if.tlastchk                        = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tlast_chk  ;
    assign i_hdr2log_slv_if.tdata                           = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tdata      ;
    assign i_hdr2log_slv_if.tdatachk                        = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tdata_chk  ;
    assign i_hdr2log_slv_if.tuser                           = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tuser      ;
    assign i_hdr2log_slv_if.tuserchk                        = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tuser_chk  ;
    
    // Unused signal Tied off to keep the VIP Happy 
    assign i_hdr2log_slv_if.tkeep                           = '1                                               ;
    assign i_hdr2log_slv_if.tkeepchk                        = '1                                               ;
    assign i_hdr2log_slv_if.tstrb                           = '1                                               ;
    assign i_hdr2log_slv_if.tstrbchk                        = '1                                               ;
    assign i_hdr2log_slv_if.twakeup                         = '1                                               ;
    assign i_hdr2log_slv_if.twakeupchk                      = '0                                               ;
    assign i_hdr2log_slv_if.tid                             = '0                                               ;
    assign i_hdr2log_slv_if.tidchk                          = '1                                               ;
    assign i_hdr2log_slv_if.tdest                           = '0                                               ;
    assign i_hdr2log_slv_if.tdestchk                        = '1                                               ;

`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b1                ),
      .MASTER      ( 1'b0                ),
      .ASF_SUPPORT ( ASF_SUPPORT         ),
      .TDATA_WIDTH ( KMAX_DATAPATH_WD    ),
      .TUSER_WIDTH ( HDR2LOG_TUSER_WIDTH )
    ) i_hdr2log_slv_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk      ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n    ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid     ),
      .tready       ( i_hdr2log_slv_if.tready                          ),
      .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tdata      ),
      .tlast        ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tlast      ),
      .tuser        ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tuser      ),
      .twakeup      ( i_hdr2log_slv_if.twakeup                         ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid_chk ),
      .treadychk_i  ( /* -- Not required by active slave ---------- */ ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tdata_chk  ),
      .tlastchk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tlast_chk  ),
      .tuserchk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tuser_chk  ),
      .twakeupchk_i ( i_hdr2log_slv_if.twakeupchk                      ),
      .tvalidchk_o  ( /* -- Not required by active slave ---------- */ ),
      .treadychk_o  ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tready_chk ),
      .tdatachk_o   ( /* -- Not required by active slave ---------- */ ),
      .tlastchk_o   ( /* -- Not required by active slave ---------- */ ),
      .tuserchk_o   ( /* -- Not required by active slave ---------- */ ),
      .twakeupchk_o ( /* -- Not required by active slave ---------- */ )
    );
`endif
  end
  else begin : passive_tb_hdr2log_slv_if
    assign i_hdr2log_slv_if.tready     = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tready     ;
    assign i_hdr2log_slv_if.treadychk  = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tready_chk ;
    assign i_hdr2log_slv_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid     ;
    assign i_hdr2log_slv_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid_chk ;
    assign i_hdr2log_slv_if.tlast      = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tlast      ;
    assign i_hdr2log_slv_if.tlastchk   = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tlast_chk  ;
    assign i_hdr2log_slv_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tdata      ;
    assign i_hdr2log_slv_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tdata_chk  ;
    assign i_hdr2log_slv_if.tuser      = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tuser      ;
    assign i_hdr2log_slv_if.tuserchk   = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tuser_chk  ;
    
    // Unused signal Tied off to keep the VIP Happy 
    assign i_hdr2log_slv_if.tkeep      = '1                                               ;
    assign i_hdr2log_slv_if.tkeepchk   = '1                                               ;
    assign i_hdr2log_slv_if.tstrb      = '1                                               ;
    assign i_hdr2log_slv_if.tstrbchk   = '1                                               ;
    assign i_hdr2log_slv_if.twakeup    = '1                                               ;
    assign i_hdr2log_slv_if.twakeupchk = '0                                               ;
    assign i_hdr2log_slv_if.tid        = '0                                               ;
    assign i_hdr2log_slv_if.tidchk     = '1                                               ;
    assign i_hdr2log_slv_if.tdest      = '0                                               ;
    assign i_hdr2log_slv_if.tdestchk   = '1                                               ;

`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b0                ),
      .MASTER      ( 1'b0                ),
      .ASF_SUPPORT ( ASF_SUPPORT         ),
      .TDATA_WIDTH ( KMAX_DATAPATH_WD    ),
      .TUSER_WIDTH ( HDR2LOG_TUSER_WIDTH )
    ) i_hdr2log_slv_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk       ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n     ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid      ),
      .tready       ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tready      ),
      .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tdata       ),
      .tstrb        ( i_hdr2log_slv_if.tstrb                            ),
      .tkeep        ( i_hdr2log_slv_if.tkeep                            ),
      .tlast        ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tlast       ),
      .tid          ( i_hdr2log_slv_if.tid                              ),
      .tdest        ( i_hdr2log_slv_if.tdest                            ),
      .tuser        ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tuser       ),
      .twakeup      ( i_hdr2log_slv_if.twakeup                          ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid_chk  ),
      .treadychk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tready_chk  ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tdata_chk   ),
      .tstrbchk_i   ( i_hdr2log_slv_if.tstrbchk                         ),
      .tkeepchk_i   ( i_hdr2log_slv_if.tkeepchk                         ),
      .tlastchk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tlast_chk   ),
      .tidchk_i     ( i_hdr2log_slv_if.tidchk                           ),
      .tdestchk_i   ( i_hdr2log_slv_if.tdestchk                         ),
      .tuserchk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tuser_chk   ),
      .twakeupchk_i ( i_hdr2log_slv_if.twakeupchk                       ),
      .tvalidchk_o  ( /* -- Not required by passive instance ------- */ ),
      .treadychk_o  ( /* -- Not required by passive instance ------- */ ),
      .tdatachk_o   ( /* -- Not required by passive instance ------- */ ),
      .tstrbchk_o   ( /* -- Not required by passive instance ------- */ ),
      .tkeepchk_o   ( /* -- Not required by passive instance ------- */ ),
      .tlastchk_o   ( /* -- Not required by passive instance ------- */ ),
      .tidchk_o     ( /* -- Not required by passive instance ------- */ ),
      .tdestchk_o   ( /* -- Not required by passive instance ------- */ ),
      .tuserchk_o   ( /* -- Not required by passive instance ------- */ ),
      .twakeupchk_o ( /* -- Not required by passive instance ------- */ )
    );
`endif
  end
  
 //------------------------------------------------------------------------------
  // AXI Stream Delivered MSI RX Interface
  //------------------------------------------------------------------------------
  cdnStream5Interface #(
    .DATA_WIDTH (KMAX_MSI_TDATA_WIDTH)
  ) i_axis_msi_slv_if (
    .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_clk   ),
    .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_rst_n )
  );

  if(IS_ACTIVE) begin : active_tb_axis_msi_slv_if
    assign i_axis_msi_slv_if.tvalid                          = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid      ;
    assign i_axis_msi_slv_if.tvalidchk                       = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid_chk  ;
    assign `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tready     = i_axis_msi_slv_if.tready                           ;
`ifndef VIPSR_46884732_WORKAROUND
    assign `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tready_chk = i_axis_msi_slv_if.treadychk                        ;
`endif
    assign i_axis_msi_slv_if.twakeup                         = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_twakeup     ;
    assign i_axis_msi_slv_if.twakeupchk                      = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_twakeup_chk ;
    assign i_axis_msi_slv_if.tdata                           = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tdata       ;
    assign i_axis_msi_slv_if.tdatachk                        = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tdata_chk   ;

    // Unused signal Tied off to keep the VIP Happy 
    assign i_axis_msi_slv_if.tkeep                           = '1                                                 ;
    assign i_axis_msi_slv_if.tkeepchk                        = '1                                                 ;
    assign i_axis_msi_slv_if.tlast                           = '1                                                 ;
    assign i_axis_msi_slv_if.tlastchk                        = '0                                                 ;
    assign i_axis_msi_slv_if.tstrb                           = '1                                                 ;
    assign i_axis_msi_slv_if.tstrbchk                        = '1                                                 ;
    assign i_axis_msi_slv_if.tid                             = '0                                                 ;
    assign i_axis_msi_slv_if.tidchk                          = '1                                                 ;
    assign i_axis_msi_slv_if.tdest                           = '0                                                 ;
    assign i_axis_msi_slv_if.tdestchk                        = '1                                                 ;
    assign i_axis_msi_slv_if.tuser                           = '1                                                 ;
    assign i_axis_msi_slv_if.tuserchk                        = '1                                                 ;
    
`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b1                 ),
      .MASTER      ( 1'b0                 ),
      .ASF_SUPPORT ( ASF_SUPPORT          ),
      .TDATA_WIDTH ( KMAX_MSI_TDATA_WIDTH )
    ) i_axis_msi_slv_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_clk               ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_rst_n             ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid     ),
      .tready       ( i_axis_msi_slv_if.tready                          ),
      .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tdata      ),
      .tlast        ( i_axis_msi_slv_if.tlast                           ),
      .tuser        ( i_axis_msi_slv_if.tuser                           ),
      .twakeup      ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_twakeup    ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid_chk ),
      .treadychk_i  ( /* -- Not required by active slave ----------- */ ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tdata_chk  ),
      .tlastchk_i   ( i_axis_msi_slv_if.tlastchk                        ),
      .tuserchk_i   ( i_axis_msi_slv_if.tuserchk                        ),
      .twakeupchk_i ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_twakeup_chk),
      .tvalidchk_o  ( /* -- Not required by active slave ----------- */ ),
      .treadychk_o  ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tready_chk ),
      .tdatachk_o   ( /* -- Not required by active slave ----------- */ ),
      .tlastchk_o   ( /* -- Not required by active slave ----------- */ ),
      .tuserchk_o   ( /* -- Not required by active slave ----------- */ ),
      .twakeupchk_o ( /* -- Not required by active slave ----------- */ )
    );
`endif
  end
  else begin : passive_tb_axis_msi_slv_if
    assign i_axis_msi_slv_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid      ;
    assign i_axis_msi_slv_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid_chk  ;
    assign i_axis_msi_slv_if.tready     = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tready      ;
    assign i_axis_msi_slv_if.treadychk  = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tready_chk  ;
    assign i_axis_msi_slv_if.twakeup    = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_twakeup     ;
    assign i_axis_msi_slv_if.twakeupchk = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_twakeup_chk ;
    assign i_axis_msi_slv_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tdata       ;
    assign i_axis_msi_slv_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tdata_chk   ;
    
    // Unused signal Tied off to keep the VIP Happy 
    assign i_axis_msi_slv_if.tkeep      = '1                                                 ;
    assign i_axis_msi_slv_if.tkeepchk   = '1                                                 ;
    assign i_axis_msi_slv_if.tlast      = '1                                                 ;
    assign i_axis_msi_slv_if.tlastchk   = '0                                                 ;
    assign i_axis_msi_slv_if.tstrb      = '1                                                 ;
    assign i_axis_msi_slv_if.tstrbchk   = '1                                                 ;
    assign i_axis_msi_slv_if.tid        = '0                                                 ;
    assign i_axis_msi_slv_if.tidchk     = '1                                                 ;
    assign i_axis_msi_slv_if.tdest      = '0                                                 ;
    assign i_axis_msi_slv_if.tdestchk   = '1                                                 ;
    assign i_axis_msi_slv_if.tuser      = '1                                                 ;
    assign i_axis_msi_slv_if.tuserchk   = '1                                                 ;

`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b0                ),
      .MASTER      ( 1'b0                ),
      .ASF_SUPPORT ( ASF_SUPPORT         ),
      .TDATA_WIDTH ( KMAX_MSI_TDATA_WIDTH)
    ) i_axis_msi_slv_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_clk               ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_msi_rst_n             ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid     ),
      .tready       ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tready     ),
      .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tdata      ),
      .tlast        ( i_axis_msi_slv_if.tlast                           ),
      .tuser        ( i_axis_msi_slv_if.tuser                           ),
      .twakeup      ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_twakeup    ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid_chk ),
      .treadychk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tready_chk ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tdata_chk  ),
      .tlastchk_i   ( i_axis_msi_slv_if.tlastchk                        ),
      .tuserchk_i   ( i_axis_msi_slv_if.tuserchk                        ),
      .twakeupchk_i ( `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_twakeup_chk),
      .tvalidchk_o  ( /* -- Not required by passive instance ------- */ ),
      .treadychk_o  ( /* -- Not required by passive instance ------- */ ),
      .tdatachk_o   ( /* -- Not required by passive instance ------- */ ),
      .tlastchk_o   ( /* -- Not required by passive instance ------- */ ),
      .tuserchk_o   ( /* -- Not required by passive instance ------- */ ),
      .twakeupchk_o ( /* -- Not required by passive instance ------- */ )
    );
`endif
  end
  

  //------------------------------------------------------------------------------
  // AXI Stream Delivered Count Slave Interface
  //------------------------------------------------------------------------------
  cdnStream5Interface #(
    .DATA_WIDTH (DELIVERED_P_TDATA_WIDTH)
  ) i_dc_slv_if (
    .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
  );

  if(IS_ACTIVE) begin : active_tb_dc_slv_if
    assign i_dc_slv_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tvalid     ;
    assign i_dc_slv_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tvalid_chk ;
    assign i_dc_slv_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tdata      ;
    assign i_dc_slv_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tdata_chk  ;
    
    // Unused signal Tied off to keep the VIP Happy 
    assign i_dc_slv_if.tkeep      = '1                                          ;
    assign i_dc_slv_if.tkeepchk   = '1                                          ;
    assign i_dc_slv_if.tlast      = '1                                          ;
    assign i_dc_slv_if.tlastchk   = '0                                          ;
    assign i_dc_slv_if.tstrb      = '1                                          ;
    assign i_dc_slv_if.tstrbchk   = '1                                          ;
    assign i_dc_slv_if.twakeup    = '1                                          ;
    assign i_dc_slv_if.twakeupchk = '0                                          ;
    assign i_dc_slv_if.tid        = '0                                          ;
    assign i_dc_slv_if.tidchk     = '1                                          ;
    assign i_dc_slv_if.tdest      = '0                                          ;
    assign i_dc_slv_if.tdestchk   = '1                                          ;
    assign i_dc_slv_if.tuser      = '1                                          ;
    assign i_dc_slv_if.tuserchk   = '1                                          ;
    assign i_dc_slv_if.tready     = '1                                          ;
    assign i_dc_slv_if.treadychk  = '0                                          ;

`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b1                    ),
      .MASTER      ( 1'b0                    ),
      .ASF_SUPPORT ( ASF_SUPPORT             ),
      .TDATA_WIDTH ( DELIVERED_P_TDATA_WIDTH )
    ) i_dc_slv_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tvalid       ),
      .tready       ( i_dc_slv_if.tready                            ),
      .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tdata        ),
      .tlast        ( i_dc_slv_if.tlast                             ),
      .tuser        ( i_dc_slv_if.tuser                             ),
      .twakeup      ( i_dc_slv_if.twakeup                           ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tvalid_chk   ),
      .treadychk_i  ( /* -- Not required by active slave ------- */ ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tdata_chk    ),
      .tlastchk_i   ( i_dc_slv_if.tlastchk                          ),
      .tuserchk_i   ( i_dc_slv_if.tuserchk                          ),
      .twakeupchk_i ( i_dc_slv_if.twakeupchk                        ),
      .tvalidchk_o  ( /* -- Not required by active slave ------- */ ),
      .treadychk_o  ( /* -- Not required by active slave ------- */ ),
      .tdatachk_o   ( /* -- Not required by active slave ------- */ ),
      .tlastchk_o   ( /* -- Not required by active slave ------- */ ),
      .tuserchk_o   ( /* -- Not required by active slave ------- */ ),
      .twakeupchk_o ( /* -- Not required by active slave ------- */ )
    );
`endif
  end
  else begin : passive_tb_dc_slv_if
    assign i_dc_slv_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tvalid     ;
    assign i_dc_slv_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tvalid_chk ;
    assign i_dc_slv_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tdata      ;
    assign i_dc_slv_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tdata_chk  ;
    
    // Unused signal Tied off to keep the VIP Happy 
    assign i_dc_slv_if.tkeep      = '1                                          ;
    assign i_dc_slv_if.tkeepchk   = '1                                          ;
    assign i_dc_slv_if.tlast      = '1                                          ;
    assign i_dc_slv_if.tlastchk   = '0                                          ;
    assign i_dc_slv_if.tstrb      = '1                                          ;
    assign i_dc_slv_if.tstrbchk   = '1                                          ;
    assign i_dc_slv_if.twakeup    = '1                                          ;
    assign i_dc_slv_if.twakeupchk = '0                                          ;
    assign i_dc_slv_if.tid        = '0                                          ;
    assign i_dc_slv_if.tidchk     = '1                                          ;
    assign i_dc_slv_if.tdest      = '0                                          ;
    assign i_dc_slv_if.tdestchk   = '1                                          ;
    assign i_dc_slv_if.tuser      = '1                                          ;
    assign i_dc_slv_if.tuserchk   = '1                                          ;
    assign i_dc_slv_if.tready     = '1                                          ;
    assign i_dc_slv_if.treadychk  = '0                                          ;

`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b0                    ),
      .MASTER      ( 1'b0                    ),
      .ASF_SUPPORT ( ASF_SUPPORT             ),
      .TDATA_WIDTH ( DELIVERED_P_TDATA_WIDTH )
    ) i_dc_slv_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tvalid       ),
      .tready       ( i_dc_slv_if.tready                            ),
      .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tdata        ),
      .tlast        ( i_dc_slv_if.tlast                             ),
      .tuser        ( i_dc_slv_if.tuser                             ),
      .twakeup      ( i_dc_slv_if.twakeup                           ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tvalid_chk   ),
      .treadychk_i  ( i_dc_slv_if.treadychk                         ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.dc_m_tdata_chk    ),
      .tlastchk_i   ( i_dc_slv_if.tlastchk                          ),
      .tuserchk_i   ( i_dc_slv_if.tuserchk                          ),
      .twakeupchk_i ( i_dc_slv_if.twakeupchk                        ),
      .tvalidchk_o  ( /* -- Not required by passive instance --- */ ),
      .treadychk_o  ( /* -- Not required by passive instance --- */ ),
      .tdatachk_o   ( /* -- Not required by passive instance --- */ ),
      .tlastchk_o   ( /* -- Not required by passive instance --- */ ),
      .tuserchk_o   ( /* -- Not required by passive instance --- */ ),
      .twakeupchk_o ( /* -- Not required by passive instance --- */ )
    );
`endif
  end
  //------------------------------------------------------------------------------
  // AXI Stream QOS TX Slave Interface
  //------------------------------------------------------------------------------
  cdnStream5Interface #(
    .DATA_WIDTH (TLP_QOS_TDATA_WIDTH)
  ) i_qos_slv_if (
    .aclk    ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .aresetn ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
  );
 
  if(IS_ACTIVE) begin : active_tb_qos_slv_if
    assign i_qos_slv_if.tvalid    = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tvalid     ;
    assign i_qos_slv_if.tvalidchk = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tvalid_chk ;
    assign i_qos_slv_if.tdata     = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tdata      ;
    assign i_qos_slv_if.tdatachk  = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tdata_chk  ;
    assign i_qos_slv_if.tkeep      = '1 ;
    assign i_qos_slv_if.tkeepchk   = '1 ;
    assign i_qos_slv_if.tlast      = '1 ;
    assign i_qos_slv_if.tlastchk   = '0 ;
    assign i_qos_slv_if.tstrb      = '1 ;
    assign i_qos_slv_if.tstrbchk   = '1 ;
    assign i_qos_slv_if.twakeup    = '1 ;
    assign i_qos_slv_if.twakeupchk = '0 ;
    assign i_qos_slv_if.tid        = '0 ;
    assign i_qos_slv_if.tidchk     = '1 ;
    assign i_qos_slv_if.tdest      = '0 ;
    assign i_qos_slv_if.tdestchk   = '1 ;
    assign i_qos_slv_if.tuser      = '1 ;
    assign i_qos_slv_if.tuserchk   = '1 ;
    assign i_qos_slv_if.tready     = '1 ;
    assign i_qos_slv_if.treadychk  = '0 ;
 
`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b1                ),
      .MASTER      ( 1'b0                ),
      .ASF_SUPPORT ( ASF_SUPPORT         ),
      .TDATA_WIDTH ( TLP_QOS_TDATA_WIDTH )
    ) i_qos_slv_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                          ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                        ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tvalid                 ),
      .tready       ( i_qos_slv_if.tready                                            ),
      .tdata        (  `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tdata          ),
      .tlast        ( i_qos_slv_if.tlast                                             ),
      .tuser        ( i_qos_slv_if.tuser                                             ),
      .twakeup      ( i_qos_slv_if.twakeup                                           ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tvalid_chk             ),
      .treadychk_i  ( i_qos_slv_if.treadychk                                         ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tdata_chk              ),
      .tlastchk_i   ( i_qos_slv_if.tlastchk                                          ),
      .tuserchk_i   ( i_qos_slv_if.tuserchk                                          ),
      .twakeupchk_i ( i_qos_slv_if.twakeupchk                                        ),
      .tvalidchk_o  ( /* -- Not required by receiver ------------------------------- */ ),
      .treadychk_o  ( /* -- Not required by receiver ------------------------------- */ ),
      .tdatachk_o   ( /* -- Not required by receiver ------------------------------- */ ),
      .tlastchk_o   ( /* -- Not required by receiver ------------------------------- */ ),
      .tuserchk_o   ( /* -- Not required by receiver ------------------------------- */ ),
      .twakeupchk_o ( /* -- Not required by receiver ------------------------------- */ )
    );
`endif
  end
  else begin : passive_tb_qos_slv_if
    assign i_qos_slv_if.tvalid    = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tvalid     ;
    assign i_qos_slv_if.tvalidchk = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tvalid_chk ;
    assign i_qos_slv_if.tdata     =  `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tdata ;
    assign i_qos_slv_if.tdatachk  = `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tdata_chk  ;
    assign i_qos_slv_if.tkeep      = '1 ;
    assign i_qos_slv_if.tkeepchk   = '1 ;
    assign i_qos_slv_if.tlast      = '1 ;
    assign i_qos_slv_if.tlastchk   = '0 ;
    assign i_qos_slv_if.tstrb      = '1 ;
    assign i_qos_slv_if.tstrbchk   = '1 ;
    assign i_qos_slv_if.twakeup    = '1 ;
    assign i_qos_slv_if.twakeupchk = '0 ;
    assign i_qos_slv_if.tid        = '0 ;
    assign i_qos_slv_if.tidchk     = '1 ;
    assign i_qos_slv_if.tdest      = '0 ;
    assign i_qos_slv_if.tdestchk   = '1 ;
    assign i_qos_slv_if.tuser      = '1 ;
    assign i_qos_slv_if.tuserchk   = '1 ;
    assign i_qos_slv_if.tready     = '1 ;
    assign i_qos_slv_if.treadychk  = '0 ;
 
`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b0                ),
      .MASTER      ( 1'b0                ),
      .ASF_SUPPORT ( ASF_SUPPORT         ),
      .TDATA_WIDTH ( TLP_QOS_TDATA_WIDTH )
    ) i_qos_slv_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk                          ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n                        ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tvalid                 ),
      .tready       ( i_qos_slv_if.tready                                            ),
      .tdata        (  `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tdata          ),
      .tlast        ( i_qos_slv_if.tlast                                             ),
      .tuser        ( i_qos_slv_if.tuser                                             ),
      .twakeup      ( i_qos_slv_if.twakeup                                           ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tvalid_chk             ),
      .treadychk_i  ( i_qos_slv_if.treadychk                                         ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.tlp_qos_tx_tdata_chk              ),
      .tlastchk_i   ( i_qos_slv_if.tlastchk                                          ),
      .tuserchk_i   ( i_qos_slv_if.tuserchk                                          ),
      .twakeupchk_i ( i_qos_slv_if.twakeupchk                                        ),
      .tvalidchk_o  ( /* -- Not required by receiver ------------------------------- */ ),
      .treadychk_o  ( /* -- Not required by receiver ------------------------------- */ ),
      .tdatachk_o   ( /* -- Not required by receiver ------------------------------- */ ),
      .tlastchk_o   ( /* -- Not required by receiver ------------------------------- */ ),
      .tuserchk_o   ( /* -- Not required by receiver ------------------------------- */ ),
      .twakeupchk_o ( /* -- Not required by receiver ------------------------------- */ )
    );
`endif
  end

  //------------------------------------------------------------------------------
  // Master/Slave Credit Limit interface
  //------------------------------------------------------------------------------
  cdn_pcie_hls_bridge_crd_lmt_if #(
    .INTERFACE_NAME           ( "crd_lmt_posted_if"      ),
    .KMAX_NUM_VCS             ( KMAX_NUM_VCS             ),
    .CRD_IN_LMT_HEADER_WIDTH  ( CRD_IN_LMT_HEADER_WIDTH  ),
    .CRD_IN_LMT_PAYLOAD_WIDTH ( CRD_IN_LMT_PAYLOAD_WIDTH ),
    .CRD_IN_LMT_CNTL_WIDTH    ( CRD_IN_LMT_CNTL_WIDTH    )
  ) i_crd_lmt_posted_if (
    .clk   ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .rst_n ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
  );
  
  if(IS_ACTIVE) begin : active_tb_crd_s_lmt_posted_if
    assign i_crd_lmt_posted_if.crd_s_lmt_header  = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_posted_header  ;
    assign i_crd_lmt_posted_if.crd_s_lmt_payload = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_posted_payload ;
    assign i_crd_lmt_posted_if.crd_s_lmt_cntl    = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_posted_cntl    ;
    assign i_crd_lmt_posted_if.crd_used_header   = `HLS_BRIDGE_DUT_MODULE_NAME.crd_dti_lmt_posted_header;
    assign i_crd_lmt_posted_if.crd_used_payload  = `HLS_BRIDGE_DUT_MODULE_NAME.crd_dti_lmt_posted_payload;
     
  end
  else begin : passive_tb_crd_s_lmt_posted_if
    assign i_crd_lmt_posted_if.crd_s_lmt_header  = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_posted_header  ;
    assign i_crd_lmt_posted_if.crd_s_lmt_payload = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_posted_payload ;
    assign i_crd_lmt_posted_if.crd_s_lmt_cntl    = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_posted_cntl    ;
    assign i_crd_lmt_posted_if.crd_used_header   = `HLS_BRIDGE_DUT_MODULE_NAME.crd_dti_lmt_posted_header;
    assign i_crd_lmt_posted_if.crd_used_payload  = `HLS_BRIDGE_DUT_MODULE_NAME.crd_dti_lmt_posted_payload;
  end

  if(IS_ACTIVE) begin : active_tb_crd_m_lmt_posted_if
    assign `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_posted_header  = i_crd_lmt_posted_if.crd_m_lmt_header  ;
    assign `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_posted_payload = i_crd_lmt_posted_if.crd_m_lmt_payload ;
    assign `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_posted_cntl    = i_crd_lmt_posted_if.crd_m_lmt_cntl    ;
    assign  i_crd_lmt_posted_if.crd_used_header = `HLS_BRIDGE_DUT_MODULE_NAME.crd_dti_lmt_posted_header ;
    assign  i_crd_lmt_posted_if.crd_used_payload = `HLS_BRIDGE_DUT_MODULE_NAME.crd_dti_lmt_posted_payload;
  end
   
  else begin : passive_tb_crd_m_lmt_posted_if
    assign i_crd_lmt_posted_if.crd_m_lmt_header  = `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_posted_header  ;
    assign i_crd_lmt_posted_if.crd_m_lmt_payload = `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_posted_payload ;
    assign i_crd_lmt_posted_if.crd_m_lmt_cntl    = `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_posted_cntl    ;
    assign i_crd_lmt_posted_if.crd_used_header   = `HLS_BRIDGE_DUT_MODULE_NAME.crd_dti_lmt_posted_header;
    assign i_crd_lmt_posted_if.crd_used_payload = `HLS_BRIDGE_DUT_MODULE_NAME.crd_dti_lmt_posted_payload;
  end

  cdn_pcie_hls_bridge_crd_lmt_if #(
    .INTERFACE_NAME           ( "crd_lmt_nonposted_if"   ),
    .KMAX_NUM_VCS             ( KMAX_NUM_VCS             ),
    .CRD_IN_LMT_HEADER_WIDTH  ( CRD_IN_LMT_HEADER_WIDTH  ),
    .CRD_IN_LMT_PAYLOAD_WIDTH ( CRD_IN_LMT_PAYLOAD_WIDTH ),
    .CRD_IN_LMT_CNTL_WIDTH    ( CRD_IN_LMT_CNTL_WIDTH    )
  ) i_crd_lmt_nonposted_if (
    .clk   ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .rst_n ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
  );
  
  if(IS_ACTIVE) begin : active_tb_crd_s_lmt_nonposted_if
    assign i_crd_lmt_nonposted_if.crd_s_lmt_header  = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_nonposted_header  ;
    assign i_crd_lmt_nonposted_if.crd_s_lmt_payload = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_nonposted_payload ;
    assign i_crd_lmt_nonposted_if.crd_s_lmt_cntl    = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_nonposted_cntl    ;
  end
  else begin : passive_tb_crd_s_lmt_nonposted_if
    assign i_crd_lmt_nonposted_if.crd_s_lmt_header  = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_nonposted_header  ;
    assign i_crd_lmt_nonposted_if.crd_s_lmt_payload = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_nonposted_payload ;
    assign i_crd_lmt_nonposted_if.crd_s_lmt_cntl    = `HLS_BRIDGE_DUT_MODULE_NAME.crd_m_lmt_nonposted_cntl    ;
  end

  if(IS_ACTIVE) begin : active_tb_crd_m_lmt_nonposted_if
    assign `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_nonposted_header  = i_crd_lmt_nonposted_if.crd_m_lmt_header  ;
    assign `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_nonposted_payload = i_crd_lmt_nonposted_if.crd_m_lmt_payload ;
    assign `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_nonposted_cntl    = i_crd_lmt_nonposted_if.crd_m_lmt_cntl    ;
  end
  else begin : passive_tb_crd_m_lmt_nonposted_if
    assign i_crd_lmt_nonposted_if.crd_m_lmt_header  = `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_nonposted_header  ;
    assign i_crd_lmt_nonposted_if.crd_m_lmt_payload = `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_nonposted_payload ;
    assign i_crd_lmt_nonposted_if.crd_m_lmt_cntl    = `HLS_BRIDGE_DUT_MODULE_NAME.crd_s_lmt_nonposted_cntl    ;
  end


  //-------------------------------------
  // DTI Enable
  //-------------------------------------
  if (parameters_cfg_pkg::KMAX_DTI_SUPPORT&& !CONTROLLER_TOP_TB) begin : GEN_DTI_SUPPORT
    //-------------------------------------
    // AXI Stream DTI Downstream interface
    //-------------------------------------
    cdnStream5Interface #(
      .DATA_WIDTH (parameters_cfg_pkg::KMAX_DTI_TDATA_WIDTH)
    ) i_dti_dn_if (
      .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk   ),
      .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_rst_n )
    );
    
    if (IS_ACTIVE) begin : active_tb_dti_dn_if
      // Temporary tie-off, until SMMU is fixed.
      assign i_dti_dn_if.tvalid                            = `HLS_BRIDGE_DUT_MODULE_NAME.tvalid_dti_dn;
      assign i_dti_dn_if.tvalidchk                         = `HLS_BRIDGE_DUT_MODULE_NAME.tvalid_dti_dn_chk;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tready_dti_dn     = i_dti_dn_if.tready;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tready_dti_dn_chk = i_dti_dn_if.treadychk;
      assign i_dti_dn_if.tlast                             = `HLS_BRIDGE_DUT_MODULE_NAME.tlast_dti_dn;
      assign i_dti_dn_if.tlastchk                          = `HLS_BRIDGE_DUT_MODULE_NAME.tlast_dti_dn_chk;
      assign i_dti_dn_if.tdata                             = `HLS_BRIDGE_DUT_MODULE_NAME.tdata_dti_dn;
      assign i_dti_dn_if.tdatachk                          = `HLS_BRIDGE_DUT_MODULE_NAME.tdata_dti_dn_chk;
      assign i_dti_dn_if.tkeep                             = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_dn;
      assign i_dti_dn_if.tkeepchk                          = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_dn_chk;
      assign i_dti_dn_if.tstrb                             = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_dn;      // TODO ???
      assign i_dti_dn_if.tstrbchk                          = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_dn_chk;  // TODO ???
      assign i_dti_dn_if.twakeup                           = `HLS_BRIDGE_DUT_MODULE_NAME.twakeup_dti_dn;
      assign i_dti_dn_if.twakeupchk                        = `HLS_BRIDGE_DUT_MODULE_NAME.twakeup_dti_dn_chk;

      // Unused signal Tied off to keep the VIP Happy
      assign i_dti_dn_if.tdest      = '0;
      assign i_dti_dn_if.tdestchk   = '1;
      assign i_dti_dn_if.tid        = '0;
      assign i_dti_dn_if.tidchk     = '1;
      assign i_dti_dn_if.tuser      = '1;
      assign i_dti_dn_if.tuserchk   = '1;
    end
    else begin : passive_tb_dti_dn_if
      assign i_dti_dn_if.aclk                              = `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk;
      assign i_dti_dn_if.aresetn                           = `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_rst_n;
      assign i_dti_dn_if.tvalid                            = `HLS_BRIDGE_DUT_MODULE_NAME.tvalid_dti_dn;
      assign i_dti_dn_if.tvalidchk                         = `HLS_BRIDGE_DUT_MODULE_NAME.tvalid_dti_dn_chk;
      assign i_dti_dn_if.tready                            = `HLS_BRIDGE_DUT_MODULE_NAME.tready_dti_dn;
      assign i_dti_dn_if.treadychk                         = `HLS_BRIDGE_DUT_MODULE_NAME.tready_dti_dn_chk;
      assign i_dti_dn_if.tlast                             = `HLS_BRIDGE_DUT_MODULE_NAME.tlast_dti_dn;
      assign i_dti_dn_if.tlastchk                          = `HLS_BRIDGE_DUT_MODULE_NAME.tlast_dti_dn_chk;
      assign i_dti_dn_if.tdata                             = `HLS_BRIDGE_DUT_MODULE_NAME.tdata_dti_dn;
      assign i_dti_dn_if.tdatachk                          = `HLS_BRIDGE_DUT_MODULE_NAME.tdata_dti_dn_chk;
      assign i_dti_dn_if.tkeep                             = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_dn;
      assign i_dti_dn_if.tkeepchk                          = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_dn_chk;
      assign i_dti_dn_if.tstrb                             = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_dn;
      assign i_dti_dn_if.tstrbchk                          = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_dn_chk;
      assign i_dti_dn_if.twakeup                           = `HLS_BRIDGE_DUT_MODULE_NAME.twakeup_dti_dn;
      assign i_dti_dn_if.twakeupchk                        = `HLS_BRIDGE_DUT_MODULE_NAME.twakeup_dti_dn_chk;

      // Unused signal Tied off to keep the VIP Happy
      assign i_dti_dn_if.tdest      = '0;
      assign i_dti_dn_if.tdestchk   = '1;
      assign i_dti_dn_if.tid        = '0;
      assign i_dti_dn_if.tidchk     = '1;
      assign i_dti_dn_if.tuser      = '1;
      assign i_dti_dn_if.tuserchk   = '1;
    end

    //------------------------------------
    // AXI Stream DTI Upstream interface
    //------------------------------------
    cdnStream5Interface #(
      .DATA_WIDTH (parameters_cfg_pkg::KMAX_DTI_TDATA_WIDTH)
    ) i_dti_up_if (
      .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk   ),
      .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_rst_n )
    );
    
    if (IS_ACTIVE) begin : active_tb_dti_up_if
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tvalid_dti_up     = i_dti_up_if.tvalid;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tvalid_dti_up_chk = i_dti_up_if.tvalidchk;
      assign i_dti_up_if.tready                            = `HLS_BRIDGE_DUT_MODULE_NAME.tready_dti_up;
      assign i_dti_up_if.treadychk                         = `HLS_BRIDGE_DUT_MODULE_NAME.tready_dti_up_chk;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tlast_dti_up      = i_dti_up_if.tlast;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tlast_dti_up_chk  = i_dti_up_if.tlastchk;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tdata_dti_up      = i_dti_up_if.tdata;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tdata_dti_up_chk  = i_dti_up_if.tdatachk;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_up      = i_dti_up_if.tkeep;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_up_chk  = i_dti_up_if.tkeepchk;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.twakeup_dti_up    = i_dti_up_if.twakeup;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.twakeup_dti_up_chk= i_dti_up_if.twakeupchk;
    end else begin : passive_tb_dti_up_if
      assign i_dti_up_if.aclk                             = `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_clk;
      assign i_dti_up_if.aresetn                          = `HLS_BRIDGE_DUT_MODULE_NAME.axi_dti_rst_n;
      assign i_dti_up_if.tvalid                           = `HLS_BRIDGE_DUT_MODULE_NAME.tvalid_dti_up;
      assign i_dti_up_if.tvalidchk                        = `HLS_BRIDGE_DUT_MODULE_NAME.tvalid_dti_up_chk;
      assign i_dti_up_if.tready                           = `HLS_BRIDGE_DUT_MODULE_NAME.tready_dti_up;
      assign i_dti_up_if.treadychk                        = `HLS_BRIDGE_DUT_MODULE_NAME.tready_dti_up_chk;
      assign i_dti_up_if.tlast                            = `HLS_BRIDGE_DUT_MODULE_NAME.tlast_dti_up;
      assign i_dti_up_if.tlastchk                         = `HLS_BRIDGE_DUT_MODULE_NAME.tlast_dti_up_chk;
      assign i_dti_up_if.tdata                            = `HLS_BRIDGE_DUT_MODULE_NAME.tdata_dti_up;
      assign i_dti_up_if.tdatachk                         = `HLS_BRIDGE_DUT_MODULE_NAME.tdata_dti_up_chk;
      assign i_dti_up_if.tkeep                            = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_up;
      assign i_dti_up_if.tkeepchk                         = `HLS_BRIDGE_DUT_MODULE_NAME.tkeep_dti_up_chk;
      assign i_dti_up_if.twakeup                          = `HLS_BRIDGE_DUT_MODULE_NAME.twakeup_dti_up;
      assign i_dti_up_if.twakeupchk                       = `HLS_BRIDGE_DUT_MODULE_NAME.twakeup_dti_up_chk;

      // Unused signal Tied off to keep the VIP Happy
      assign i_dti_up_if.tdest      = '0;
      assign i_dti_up_if.tdestchk   = '1;
      assign i_dti_up_if.tid        = '0;
      assign i_dti_up_if.tidchk     = '1;
      assign i_dti_up_if.tuser      = '1;
      assign i_dti_up_if.tuserchk   = '1;
    end // block: passive_tb_dti_up_if

    cdn_pcie_dti_interrupt_if i_dti_interrupt_i (
      .axil_clk     ( `HLS_BRIDGE_DUT_MODULE_NAME.axil_clk   ),
      .axil_rst_n   ( `HLS_BRIDGE_DUT_MODULE_NAME.axil_rst_n )
    );

    assign i_dti_interrupt_i.interrupt = `HLS_BRIDGE_DUT_MODULE_NAME.dti_interrupt;

  end : GEN_DTI_SUPPORT

    
  //------------------------------------------------------------------------------
  // AXI Stream LTI Completion RX Interface
  //------------------------------------------------------------------------------
  cdnStream5Interface #(
    .DATA_WIDTH (LTI_C_TDATA_WIDTH)
  ) i_lti_c_rx_if (
    .aclk       ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .aresetn    ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )
  );

  if(IS_ACTIVE) begin : active_tb_lti_c_rx_if
    assign i_lti_c_rx_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tvalid     ;
    assign i_lti_c_rx_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tvalid_chk ;
    assign i_lti_c_rx_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tdata      ;
    assign i_lti_c_rx_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tdata_chk  ;
    
    // Unused signal Tied off to keep the VIP Happy 
    assign i_lti_c_rx_if.tkeep      = '1                                              ;
    assign i_lti_c_rx_if.tkeepchk   = '1                                              ;
    assign i_lti_c_rx_if.tlast      = '1                                              ;
    assign i_lti_c_rx_if.tlastchk   = '0                                              ;
    assign i_lti_c_rx_if.tstrb      = '1                                              ;
    assign i_lti_c_rx_if.tstrbchk   = '1                                              ;
    assign i_lti_c_rx_if.twakeup    = '1                                              ;
    assign i_lti_c_rx_if.twakeupchk = '0                                              ;
    assign i_lti_c_rx_if.tid        = '0                                              ;
    assign i_lti_c_rx_if.tidchk     = '1                                              ;
    assign i_lti_c_rx_if.tdest      = '0                                              ;
    assign i_lti_c_rx_if.tdestchk   = '1                                              ;
    assign i_lti_c_rx_if.tuser      = '1                                              ;
    assign i_lti_c_rx_if.tuserchk   = '1                                              ;

  end
  else begin : passive_tb_lti_c_rx_if
    assign i_lti_c_rx_if.tvalid     = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tvalid     ;
    assign i_lti_c_rx_if.tvalidchk  = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tvalid_chk ;
    assign i_lti_c_rx_if.tdata      = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tdata      ;
    assign i_lti_c_rx_if.tdatachk   = `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tdata_chk  ;
    
    // Unused signal Tied off to keep the VIP Happy 
    assign i_lti_c_rx_if.tkeep      = '1                                              ;
    assign i_lti_c_rx_if.tkeepchk   = '1                                              ;
    assign i_lti_c_rx_if.tlast      = '1                                              ;
    assign i_lti_c_rx_if.tlastchk   = '0                                              ;
    assign i_lti_c_rx_if.tstrb      = '1                                              ;
    assign i_lti_c_rx_if.tstrbchk   = '1                                              ;
    assign i_lti_c_rx_if.twakeup    = '1                                              ;
    assign i_lti_c_rx_if.twakeupchk = '0                                              ;
    assign i_lti_c_rx_if.tid        = '0                                              ;
    assign i_lti_c_rx_if.tidchk     = '1                                              ;
    assign i_lti_c_rx_if.tdest      = '0                                              ;
    assign i_lti_c_rx_if.tdestchk   = '1                                              ;
    assign i_lti_c_rx_if.tuser      = '1                                              ;
    assign i_lti_c_rx_if.tuserchk   = '1                                              ;
    assign i_lti_c_rx_if.tready     = '1                                              ;
    assign i_lti_c_rx_if.treadychk  = '0                                              ;

`ifdef VIPSR_46884732_WORKAROUND
    cdn_pcie_hls_bridge_stream_parity_wrapper #(
      .ACTIVE      ( 1'b0              ),
      .MASTER      ( 1'b0              ),
      .ASF_SUPPORT ( ASF_SUPPORT       ),
      .TDATA_WIDTH ( LTI_C_TDATA_WIDTH )
    ) i_lti_c_rx_stream_parity_wrapper (
      .clk          ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk     ),
      .rst_n        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n   ),
      .tvalid       ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tvalid     ),
      .tready       ( i_lti_c_rx_if.tready                            ),
      .tdata        ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tdata      ),
      .tlast        ( i_lti_c_rx_if.tlast                             ),
      .tuser        ( i_lti_c_rx_if.tuser                             ),
      .twakeup      ( i_lti_c_rx_if.twakeup                           ),
      .tvalidchk_i  ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tvalid_chk ),
      .treadychk_i  ( i_lti_c_rx_if.treadychk                         ),
      .tdatachk_i   ( `HLS_BRIDGE_DUT_MODULE_NAME.lti_c_tx_tdata_chk  ),
      .tlastchk_i   ( i_lti_c_rx_if.tlastchk                          ),
      .tuserchk_i   ( i_lti_c_rx_if.tuserchk                          ),
      .twakeupchk_i ( i_lti_c_rx_if.twakeupchk                        ),
      .tvalidchk_o  ( /* -- Not required by passive instance ----- */ ),
      .treadychk_o  ( /* -- Not required by passive instance ----- */ ),
      .tdatachk_o   ( /* -- Not required by passive instance ----- */ ),
      .tlastchk_o   ( /* -- Not required by passive instance ----- */ ),
      .tuserchk_o   ( /* -- Not required by passive instance ----- */ ),
      .twakeupchk_o ( /* -- Not required by passive instance ----- */ )
    );
`endif
  end
  

  //------------------------------------------------------------------------------
  //  Misc Inputs, Configuration and control ports
  //------------------------------------------------------------------------------
  cdn_pcie_hls_bridge_dut_misc_if #(
    .NUM_HLS_PORTS ( NUM_HLS_PORTS ),
    .KMAX_NUM_PFS  ( KMAX_NUM_PFS  ),
    .NUM_TCS       ( NUM_TCS ),
    .NUM_LTI_PORTS ( NUM_LTI_PORTS ),
    .IDE_NUM_LINK_STREAMS ( KMAX_IDE_NUM_LINK_STREAMS ),
    .IDE_NUM_SEL_STREAMS  ( KMAX_IDE_NUM_SEL_STREAMS  )
  ) i_misc_if (
    .clk  ( i_clk_if.core_clk   ),
    .rst_n( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n )        
  );

  //------------------------------------
  // Top Level Misc_if
  // Requried by the cif router.
  //------------------------------------
  cdn_pcie_hpa_misc_if  i_top_misc_if();

  generate
    if(IS_ACTIVE) begin : active_tb_misc_if
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_flit_mode                     = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_flit_mode                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_mld_negotiated                = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_mld_negotiated               ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_pbr_negotiated                = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_pbr_negotiated               ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_10_bit_tag_completer_support  = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_10_bit_tag_completer_support ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_14_bit_tag_completer_support  = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_14_bit_tag_completer_support ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_captured_dest_segment         = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_captured_dest_segment        ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_segment_captured              = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_segment_captured             ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_ecrc_generation_enable_per_pf = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_ecrc_generation_enable_per_pf;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_read_completion_boundary      = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_read_completion_boundary     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tc_vc_mapping                      = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.tc_vc_mapping                     ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_tag_management                = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_tag_management               ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_ide_link_stream_control_reg   = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_ide_link_stream_control_reg;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_ide_sel_stream_control_reg    = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_ide_sel_stream_control_reg;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_ide_sel_stream_rid_assoc1_reg = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_ide_sel_stream_rid_assoc1_reg;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_ide_sel_stream_rid_assoc2_reg = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_ide_sel_stream_rid_assoc2_reg;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.lm_segment_num                     = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.lm_segment_num                    ;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.link_down_handling_in_progress     = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.link_down_handling_in_progress    ;
      `ifdef HPA2_IDE_GEN7
      assign `HLS_BRIDGE_DUT_MODULE_NAME.misc_hls_bridge_route_en           = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.misc_hls_bridge_route_en          ;
      `endif // HPA2_IDE_GEN7
      assign `HLS_BRIDGE_DUT_MODULE_NAME.low_power_mode                     = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) ? 0 : i_misc_if.low_power_mode                    ;      
      assign i_misc_if.lp_hls_active_req                                = (~`HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n) || ~i_misc_if.low_power_mode ? 0 :
                                                                           {`HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_posted_hal_activereq, `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_nonposted_hal_activereq,
                                                                            `HLS_BRIDGE_DUT_MODULE_NAME.hls_ob_compl_hal_activereq, `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_hal_activereq,
                                                                            `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_hal_activereq, `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_hal_activereq};

      assign i_top_misc_if.core_clk                                         = `HLS_BRIDGE_DUT_MODULE_NAME.core_clk;
      assign i_top_misc_if.link_down_handling_in_progress                   = `HLS_BRIDGE_DUT_MODULE_NAME.link_down_handling_in_progress;
      assign i_top_misc_if.immediate_link_down                              = 0;
    end 
    else begin : passive_tb_misc_if
      assign i_misc_if.misc_flit_mode                     = `HLS_BRIDGE_DUT_MODULE_NAME.misc_flit_mode                    ;
      assign i_misc_if.misc_mld_negotiated                = `HLS_BRIDGE_DUT_MODULE_NAME.misc_mld_negotiated               ;
      assign i_misc_if.misc_pbr_negotiated                = `HLS_BRIDGE_DUT_MODULE_NAME.misc_pbr_negotiated               ;
      assign i_misc_if.misc_10_bit_tag_completer_support  = `HLS_BRIDGE_DUT_MODULE_NAME.misc_10_bit_tag_completer_support ;
      assign i_misc_if.misc_14_bit_tag_completer_support  = `HLS_BRIDGE_DUT_MODULE_NAME.misc_14_bit_tag_completer_support ;
      assign i_misc_if.misc_captured_dest_segment         = `HLS_BRIDGE_DUT_MODULE_NAME.misc_captured_dest_segment        ;
      assign i_misc_if.misc_segment_captured              = `HLS_BRIDGE_DUT_MODULE_NAME.misc_segment_captured             ;
      assign i_misc_if.misc_ecrc_generation_enable_per_pf = `HLS_BRIDGE_DUT_MODULE_NAME.misc_ecrc_generation_enable_per_pf;
      assign i_misc_if.misc_read_completion_boundary      = `HLS_BRIDGE_DUT_MODULE_NAME.misc_read_completion_boundary     ;
      assign i_misc_if.tc_vc_mapping                      = `HLS_BRIDGE_DUT_MODULE_NAME.tc_vc_mapping                     ;
      assign i_misc_if.misc_tag_management                = `HLS_BRIDGE_DUT_MODULE_NAME.misc_tag_management               ;
      assign i_misc_if.lm_segment_num                     = `HLS_BRIDGE_DUT_MODULE_NAME.lm_segment_num                    ;
      assign i_misc_if.link_down_handling_in_progress     = `HLS_BRIDGE_DUT_MODULE_NAME.link_down_handling_in_progress    ;
      `ifdef HPA2_IDE_GEN7
      assign i_misc_if.misc_hls_bridge_route_en           = `HLS_BRIDGE_DUT_MODULE_NAME.misc_hls_bridge_route_en          ;
      `endif // HPA2_IDE_GEN7
      assign i_misc_if.low_power_mode                     = `HLS_BRIDGE_DUT_MODULE_NAME.low_power_mode                    ;
      assign i_top_misc_if.core_clk                       = i_clk_if.core_clk                          ;
      assign i_top_misc_if.link_down_handling_in_progress = `HLS_BRIDGE_DUT_MODULE_NAME.link_down_handling_in_progress    ;
      assign i_top_misc_if.immediate_link_down            = 0                                                             ;
    end
  endgenerate

  //------------------------------------------------------------------------------
  // TDISP Interface
  //------------------------------------------------------------------------------
  generate
    if(IS_ACTIVE) begin : active_tb_tdisp_if
      assign `HLS_BRIDGE_DUT_MODULE_NAME.tdisp_enable = 0; //TODO Drive from TDISP Interface and rest of the signals as well for TDISP.
    end
  endgenerate

  //------------------------------------------------------------------------------
  // ASF error inj Interface
  //------------------------------------------------------------------------------
  generate
    if(IS_ACTIVE) begin : active_tb_asf_error_inj_if
      assign `HLS_BRIDGE_DUT_MODULE_NAME.asf_error_inj__cmd_tvalid = 0;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.asf_error_inj__tdata = 0;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.asf_error_inj__tdatachk = 7'b111_1111;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.asf_error_inj__tuser = 0;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.asf_error_inj__tuserchk = 1;
      assign `HLS_BRIDGE_DUT_MODULE_NAME.asf_error_inj__tvalidchk = 1;
    end
  endgenerate

  //------------------------------------------------------------------------------
  // Miscellaneous Utility Interface
  //------------------------------------------------------------------------------
  calc_clk_period_if i_calc_core_clk_period_if (
    .clk        ( `HLS_BRIDGE_DUT_MODULE_NAME.core_clk   ),
    .rst_n      ( `HLS_BRIDGE_DUT_MODULE_NAME.core_rst_n ),
    .clk_period ( i_misc_if.core_clk_period              )
  );

  //------------------------------------------------------------------------
  // API methods
  //------------------------------------------------------------------------
  // Function: if_get_harness_instance_path
  // Get the path of the harness.
  function string if_get_harness_instance_path();
    return(harness_instance_path);
  endfunction : if_get_harness_instance_path
  
  //------------------------------------------------------------------------
  // Register harness with UVM TB
  //------------------------------------------------------------------------
  //------------------------------------------------------------------------
  // Task: set_vifs
  // Argument path is the hierarchical path to the env. This function will set the cfg & interfaces with config db.
  //------------------------------------------------------------------------
  task set_vifs(string env_path);
    string scope;
    string value;
    
    virtual hlsInterfaceLinkCtrl                                                                                      local_hls_ob_posted_axi_if_hlsInterfaceLinkCtrl;
    virtual hlsInterfaceLinkCtrl                                                                                      local_hls_ob_nonposted_axi_if_hlsInterfaceLinkCtrl;
    virtual hlsInterfaceLinkCtrl                                                                                      local_hls_ob_compl_axi_if_hlsInterfaceLinkCtrl;
    virtual hlsInterfaceLinkCtrl                                                                                      local_hls_ib_posted_axi_if_hlsInterfaceLinkCtrl;
    virtual hlsInterfaceLinkCtrl                                                                                      local_hls_ib_nonposted_axi_if_hlsInterfaceLinkCtrl;
    virtual hlsInterfaceLinkCtrl                                                                                      local_hls_ib_compl_axi_if_hlsInterfaceLinkCtrl;
    virtual cdnStream5Interface #(.DATA_WIDTH(HLS_PORT_DATA_WIDTH_ARR[0*32 +: 32]), .USER_WIDTH(HDR2LOG_TUSER_WIDTH)) local_hdr2log_mst_stream_vif;
    virtual cdnStream5Interface #(.DATA_WIDTH(DELIVERED_P_TDATA_WIDTH))                                               local_dc_mst_stream_vif;
    virtual cdnStream5Interface #(.DATA_WIDTH(LTI_C_TDATA_WIDTH))                                                     local_lti_c_tx_stream_vif;
    
    // Clock interface
    $sformat(scope, "%0s.m_clk_env.agent*", env_path);
    uvm_config_db#(virtual cdn_clock_if)::set(null, scope, "clock_if", i_clk_if);
    
    // Reset Interface
    $sformat(scope,"%0s.m_core_rst_env.agents*",env_path);
    uvm_config_db#(virtual cdn_reset_if)::set(null, scope, "reset_if", i_core_rst_if);

    $sformat(scope,"%0s.m_axi_msi_rst_env.agents*",env_path);
    uvm_config_db#(virtual cdn_reset_if)::set(null, scope, "reset_if", i_axi_msi_rst_if);

    $sformat(scope,"%0s.m_axi_dti_rst_env.agents*",env_path);
    uvm_config_db#(virtual cdn_reset_if)::set(null, scope, "reset_if", i_axi_dti_rst_if);
    
    $sformat(scope,"%0s.m_axil_rst_env.agents*",env_path);
    uvm_config_db#(virtual cdn_reset_if)::set(null, scope, "reset_if", i_axil_rst_if);

    // K Interface
    $sformat(scope, "%0s*", env_path);
    uvm_config_db#(cdn_pcie_hls_bridge_dut_k_if_api_base#(
      .TOK_INV_BIN_WIDTH                  ( TOK_INV_BIN_WIDTH                                       ),
      .RAM_READ_LATENCY_WIDTH             ( RAM_READ_LATENCY_WIDTH                                  ),
      .TOK_TRANS_BIN_WIDTH                ( TOK_TRANS_BIN_WIDTH                                     ),
      .NUM_HLS_PORTS                      ( parameters_cfg_pkg::NUM_HLS_PORTS                       ),
      .KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH( parameters_cfg_pkg::KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH )
    ))::set(null, scope, "k_if_api", i_k_if.api);

    // HLS OB Posted HAL Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_hls_ob_posted_hal_env.cxs_env.act_agent", env_path);
      $sformat(value, "%0s.i_hls_ob_posted_hal_if.active", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_hls_ob_posted_hal_env.cxs_env.psv_agent", env_path);
    $sformat(value, "%0s.i_hls_ob_posted_hal_if.passive", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    
    // HLS OB NonPosted HAL Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_hls_ob_nonposted_hal_env.cxs_env.act_agent", env_path);
      $sformat(value, "%0s.i_hls_ob_nonposted_hal_if.active", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_hls_ob_nonposted_hal_env.cxs_env.psv_agent", env_path);
    $sformat(value, "%0s.i_hls_ob_nonposted_hal_if.passive", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);

    // HLS OB Compl HAL Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_hls_ob_compl_hal_env.cxs_env.act_agent", env_path);
      $sformat(value, "%0s.i_hls_ob_compl_hal_if.active", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_hls_ob_compl_hal_env.cxs_env.psv_agent", env_path);
    $sformat(value, "%0s.i_hls_ob_compl_hal_if.passive", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);
 
    // HLS IB Posted HAL Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_hls_ib_posted_hal_env.cxs_env.act_agent", env_path);
      $sformat(value, "%0s.i_hls_ib_posted_hal_if.active", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_hls_ib_posted_hal_env.cxs_env.psv_agent", env_path);
    $sformat(value, "%0s.i_hls_ib_posted_hal_if.passive", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    
    // HLS IB NonPosted HAL Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_hls_ib_nonposted_hal_env.cxs_env.act_agent", env_path);
      $sformat(value, "%0s.i_hls_ib_nonposted_hal_if.active", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_hls_ib_nonposted_hal_env.cxs_env.psv_agent", env_path);
    $sformat(value, "%0s.i_hls_ib_nonposted_hal_if.passive", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);
   
    // HLS IB Compl HAL Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_hls_ib_compl_hal_env.cxs_env.act_agent", env_path);
      $sformat(value, "%0s.i_hls_ib_compl_hal_if.active", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_hls_ib_compl_hal_env.cxs_env.psv_agent", env_path);
    $sformat(value, "%0s.i_hls_ib_compl_hal_if.passive", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);

    for (int loop_port = 0; loop_port < NUM_HLS_PORTS; loop_port++) begin
      
      // HLS OB Posted AXI Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_hls_ob_posted_axi_env[%0d].cxs_env.act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ob_posted_axi_if.active", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_hls_ob_posted_axi_env[%0d].cxs_env.psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ob_posted_axi_if.passive", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value); 
      
      // HLS OB NonPosted AXI Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_hls_ob_nonposted_axi_env[%0d].cxs_env.act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ob_nonposted_axi_if.active", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_hls_ob_nonposted_axi_env[%0d].cxs_env.psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ob_nonposted_axi_if.passive", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);

      // HLS OB Compl AXI Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_hls_ob_compl_axi_env[%0d].cxs_env.act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ob_compl_axi_if.active", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_hls_ob_compl_axi_env[%0d].cxs_env.psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ob_compl_axi_if.passive", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);

      // HLS IB Posted AXI Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_hls_ib_posted_axi_env[%0d].cxs_env.act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ib_posted_axi_if.active", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_hls_ib_posted_axi_env[%0d].cxs_env.psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ib_posted_axi_if.passive", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);

      // HLS IB NonPosted AXI Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_hls_ib_nonposted_axi_env[%0d].cxs_env.act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ib_nonposted_axi_if.active", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_hls_ib_nonposted_axi_env[%0d].cxs_env.psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ib_nonposted_axi_if.passive", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);

      // HLS IB Compl AXI Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_hls_ib_compl_axi_env[%0d].cxs_env.act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ib_compl_axi_if.active", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_hls_ib_compl_axi_env[%0d].cxs_env.psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hls_ib_compl_axi_if.passive", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);

      // AXI Stream Hdr2Log Master Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_hdr2log_mst_env[%0d].act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hdr2log_mst_if.activeMaster", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_hdr2log_mst_env[%0d].psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_hdr2log_mst_if.passiveSlave", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
   
      // AXI Stream Delivered Count Master Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_dc_mst_env[%0d].act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_dc_mst_if.activeMaster", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_dc_mst_env[%0d].psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_dc_mst_if.passiveSlave", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);

       // AXI Stream QoS Master Interface
      if (IS_ACTIVE) begin
        $sformat(scope, "%0s.m_qos_mst_env[%0d].act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_qos_mst_if.activeMaster",if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end

      $sformat(scope, "%0s.m_qos_mst_env[%0d].psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_qos_mst_if.passiveSlave",if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);

      // AXI Stream LTI Completion TX Interface
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_lti_c_tx_env[%0d].act_agent", env_path, loop_port);
        $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_lti_c_tx_if.activeMaster", if_get_harness_instance_path(), loop_port);
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
      $sformat(scope, "%0s.m_lti_c_tx_env[%0d].psv_agent", env_path, loop_port);
      $sformat(value, "%0s.GEN_NUM_HLS_PORTS[%0d].i_lti_c_tx_if.passiveSlave", if_get_harness_instance_path(), loop_port);
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end

    // AXI Lite Master Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_axi_lite_mst_env.act_agent", env_path);
      $sformat(value, "%0s.i_axi5_lite_mst_if.activeMaster", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_axi_lite_mst_env.psv_agent", env_path);
    $sformat(value, "%0s.i_axi5_lite_mst_if.passiveSlave", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    
    // AXI Lite Slave Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_axi_lite_slv_env.act_agent", env_path);
      $sformat(value, "%0s.i_axi5_lite_slv_if.activeSlave", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_axi_lite_slv_env.psv_agent", env_path);
    $sformat(value, "%0s.i_axi5_lite_slv_if.passiveMaster", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value); 
    
    // AXI Stream Hdr2Log Slave Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_hdr2log_slv_env.act_agent", env_path);
      $sformat(value, "%0s.i_hdr2log_slv_if.activeSlave", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_hdr2log_slv_env.psv_agent", env_path);
    $sformat(value, "%0s.i_hdr2log_slv_if.passiveMaster", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);

    // AXI Stream MSI Slave Interface
    if(!CONTROLLER_TOP_TB) begin
      if(IS_ACTIVE) begin
        $sformat(scope, "%0s.m_axis_msi_slv_env.act_agent", env_path);
        $sformat(value, "%0s.i_axis_msi_slv_if.activeSlave", if_get_harness_instance_path());
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      end
    $sformat(scope, "%0s.m_axis_msi_slv_env.psv_agent", env_path);
    $sformat(value, "%0s.i_axis_msi_slv_if.passiveMaster", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end

    // AXI Stream Delivered Count Slave Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_dc_slv_env.act_agent", env_path);
      $sformat(value, "%0s.i_dc_slv_if.activeSlave", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_dc_slv_env.psv_agent", env_path);
    $sformat(value, "%0s.i_dc_slv_if.passiveMaster", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);

    // AXI Stream QoS Slave Interface
    if (IS_ACTIVE) begin
      $sformat(scope, "%0s.m_qos_slv_env.act_agent", env_path);
      $sformat(value, "%0s.i_qos_slv_if.activeSlave",if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
 
    $sformat(scope, "%0s.m_qos_slv_env.psv_agent", env_path);
    $sformat(value, "%0s.i_qos_slv_if.passiveMaster",if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);

    // Credit Limit Master/Slave Interface
    $sformat(scope, "%0s*", env_path);
    uvm_config_db#(cdn_pcie_hls_bridge_crd_lmt_if_api_base#(
      .INTERFACE_NAME           ( "crd_lmt_posted_if"      ),
      .KMAX_NUM_VCS             ( KMAX_NUM_VCS             ),
      .CRD_IN_LMT_HEADER_WIDTH  ( CRD_IN_LMT_HEADER_WIDTH  ),
      .CRD_IN_LMT_PAYLOAD_WIDTH ( CRD_IN_LMT_PAYLOAD_WIDTH ),
      .CRD_IN_LMT_CNTL_WIDTH    ( CRD_IN_LMT_CNTL_WIDTH    )
    ))::set(null, scope, "crd_lmt_posted_if_api", i_crd_lmt_posted_if.api);

    $sformat(scope, "%0s*", env_path);
    uvm_config_db#(cdn_pcie_hls_bridge_crd_lmt_if_api_base#(
      .INTERFACE_NAME           ( "crd_lmt_nonposted_if"   ),
      .KMAX_NUM_VCS             ( KMAX_NUM_VCS             ),
      .CRD_IN_LMT_HEADER_WIDTH  ( CRD_IN_LMT_HEADER_WIDTH  ),
      .CRD_IN_LMT_PAYLOAD_WIDTH ( CRD_IN_LMT_PAYLOAD_WIDTH ),
      .CRD_IN_LMT_CNTL_WIDTH    ( CRD_IN_LMT_CNTL_WIDTH    )
    ))::set(null, scope, "crd_lmt_nonposted_if_api", i_crd_lmt_nonposted_if.api);
   
    // AXI Stream LTI Completion RX Interface
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_lti_c_rx_env.act_agent", env_path);
      $sformat(value, "%0s.i_lti_c_rx_if.activeSlave", if_get_harness_instance_path());
      uvm_config_db#(string)::set(null, scope, "hdlPath", value);
    end
    $sformat(scope, "%0s.m_lti_c_rx_env.psv_agent", env_path);
    $sformat(value, "%0s.i_lti_c_rx_if.passiveMaster", if_get_harness_instance_path());
    uvm_config_db#(string)::set(null, scope, "hdlPath", value);

`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT && !CONTROLLER_TOP_TB) begin
      GEN_DTI_SET_VIFS.set_vifs_for_dti(env_path);
    end
`endif // DTI_TB_IN_PASSIVE_MODE

    // Misc Interface
    $sformat(scope, "%0s*", env_path);
    uvm_config_db#(cdn_pcie_hls_bridge_dut_misc_if_api_base#(
      .NUM_HLS_PORTS ( NUM_HLS_PORTS ),
      .KMAX_NUM_PFS  ( KMAX_NUM_PFS  ),
      .NUM_TCS       ( NUM_TCS       ),
      .NUM_LTI_PORTS ( NUM_LTI_PORTS ),
      .IDE_NUM_LINK_STREAMS ( KMAX_IDE_NUM_LINK_STREAMS ),
      .IDE_NUM_SEL_STREAMS  ( KMAX_IDE_NUM_SEL_STREAMS  )
    ))::set(null, scope, "misc_if_api", i_misc_if.api);
    
    // Top Misc Interface
    if (IS_ACTIVE) begin
      $sformat(scope, "%0s*", env_path);
      uvm_config_db#(virtual cdn_pcie_hpa_misc_if)::set(null, scope, "hpa_misc_if", i_top_misc_if);
    end

    // Coverage Related Interface Config DB Get/Sets
    for (int loop_port = 0; loop_port < NUM_HLS_PORTS; loop_port++) begin
      
      wait(tb_local_uvm_db_set_done_per_hls_port[loop_port] == 1'b1);

      // Local Config DB Gets
      $sformat(scope, "%0s", if_get_harness_instance_path());
      if (!uvm_config_db#(virtual hlsInterfaceLinkCtrl)::get(null, scope, $sformatf("local_hls_ob_posted_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), local_hls_ob_posted_axi_if_hlsInterfaceLinkCtrl))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_hls_ob_posted_axi_if_hlsInterfaceLinkCtrl for Port %0d from the ConfigDB database.", loop_port));
     
      if (!uvm_config_db#(virtual hlsInterfaceLinkCtrl)::get(null, scope, $sformatf("local_hls_ob_nonposted_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), local_hls_ob_nonposted_axi_if_hlsInterfaceLinkCtrl))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_hls_ob_nonposted_axi_if_hlsInterfaceLinkCtrl for Port %0d from the ConfigDB database.", loop_port));
      
      if (!uvm_config_db#(virtual hlsInterfaceLinkCtrl)::get(null, scope, $sformatf("local_hls_ob_compl_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), local_hls_ob_compl_axi_if_hlsInterfaceLinkCtrl))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_hls_ob_compl_axi_if_hlsInterfaceLinkCtrl for Port %0d from the ConfigDB database.", loop_port));
      
      if (!uvm_config_db#(virtual hlsInterfaceLinkCtrl)::get(null, scope, $sformatf("local_hls_ib_posted_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), local_hls_ib_posted_axi_if_hlsInterfaceLinkCtrl))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_hls_ib_posted_axi_if_hlsInterfaceLinkCtrl for Port %0d from the ConfigDB database.", loop_port));
      
      if (!uvm_config_db#(virtual hlsInterfaceLinkCtrl)::get(null, scope, $sformatf("local_hls_ib_nonposted_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), local_hls_ib_nonposted_axi_if_hlsInterfaceLinkCtrl))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_hls_ib_nonposted_axi_if_hlsInterfaceLinkCtrl for Port %0d from the ConfigDB database.", loop_port));
      
      if (!uvm_config_db#(virtual hlsInterfaceLinkCtrl)::get(null, scope, $sformatf("local_hls_ib_compl_axi_if_hlsInterfaceLinkCtrl[%0d]", loop_port), local_hls_ib_compl_axi_if_hlsInterfaceLinkCtrl))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_hls_ib_compl_axi_if_hlsInterfaceLinkCtrl for Port %0d from the ConfigDB database.", loop_port));

      if (!uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(HLS_PORT_DATA_WIDTH_ARR[0*32 +: 32]), .USER_WIDTH(HDR2LOG_TUSER_WIDTH)))::get(null, scope, $sformatf("local_hdr2log_mst_stream_vif[%0d]", loop_port), local_hdr2log_mst_stream_vif))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_hdr2log_mst_stream_vif for Port %0d from the ConfigDB database.", loop_port));
      
      if (!uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(DELIVERED_P_TDATA_WIDTH)))::get(null, scope, $sformatf("local_dc_mst_stream_vif[%0d]", loop_port), local_dc_mst_stream_vif))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_dc_mst_stream_vif for Port %0d from the ConfigDB database.", loop_port));
      
      if (!uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(LTI_C_TDATA_WIDTH)))::get(null, scope, $sformatf("local_lti_c_tx_stream_vif[%0d]", loop_port), local_lti_c_tx_stream_vif))
        `uvm_fatal("set_vifs", $sformatf("Unable to get local_lti_c_tx_stream_vif for Port %0d from the ConfigDB database.", loop_port));
      

      // Config DB Sets for specific components
      $sformat(scope, "%0s.m_hls_ob_posted_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", env_path, loop_port);
      uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif", local_hls_ob_posted_axi_if_hlsInterfaceLinkCtrl);
      
      $sformat(scope, "%0s.m_hls_ob_nonposted_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", env_path, loop_port);
      uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif", local_hls_ob_nonposted_axi_if_hlsInterfaceLinkCtrl);
      
      $sformat(scope, "%0s.m_hls_ob_compl_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", env_path, loop_port);
      uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif", local_hls_ob_compl_axi_if_hlsInterfaceLinkCtrl);
     
      $sformat(scope, "%0s.m_hls_ib_posted_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", env_path, loop_port);
      uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif", local_hls_ib_posted_axi_if_hlsInterfaceLinkCtrl);
      
      $sformat(scope, "%0s.m_hls_ib_nonposted_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", env_path, loop_port);
      uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif", local_hls_ib_nonposted_axi_if_hlsInterfaceLinkCtrl);
      
      $sformat(scope, "%0s.m_hls_ib_compl_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", env_path, loop_port);
      uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif", local_hls_ib_compl_axi_if_hlsInterfaceLinkCtrl);

      $sformat(scope, "%0s.m_env_mon.m_hdr2log_mst_stream_cov_collector[%0d]", env_path, loop_port);
      uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(HLS_PORT_DATA_WIDTH_ARR[0*32 +: 32]), .USER_WIDTH(HDR2LOG_TUSER_WIDTH)))::set(null, scope, "stream_vif", local_hdr2log_mst_stream_vif);
      
      $sformat(scope, "%0s.m_env_mon.m_dc_mst_stream_cov_collector[%0d]", env_path, loop_port);
      uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(DELIVERED_P_TDATA_WIDTH)))::set(null, scope, "stream_vif", local_dc_mst_stream_vif);
      
      $sformat(scope, "%0s.m_env_mon.m_lti_c_tx_stream_cov_collector[%0d]", env_path, loop_port);
      uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(LTI_C_TDATA_WIDTH)))::set(null, scope, "stream_vif", local_lti_c_tx_stream_vif);
    end
   
    $sformat(scope, "%0s.m_hls_ob_posted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", env_path);
    uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif",  i_hls_ob_posted_hal_if.passive.i_hlsInterfaceLinkCtrl);
    
    $sformat(scope, "%0s.m_hls_ob_nonposted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", env_path);
    uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif",  i_hls_ob_nonposted_hal_if.passive.i_hlsInterfaceLinkCtrl);
    
    $sformat(scope, "%0s.m_hls_ob_compl_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", env_path);
    uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif",  i_hls_ob_compl_hal_if.passive.i_hlsInterfaceLinkCtrl);
    
    $sformat(scope, "%0s.m_hls_ib_posted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", env_path);
    uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif",  i_hls_ib_posted_hal_if.passive.i_hlsInterfaceLinkCtrl);
    
    $sformat(scope, "%0s.m_hls_ib_nonposted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", env_path);
    uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif",  i_hls_ib_nonposted_hal_if.passive.i_hlsInterfaceLinkCtrl);
    
    $sformat(scope, "%0s.m_hls_ib_compl_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", env_path);
    uvm_config_db#(virtual hlsInterfaceLinkCtrl)::set(null, scope, "m_vif",  i_hls_ib_compl_hal_if.passive.i_hlsInterfaceLinkCtrl);

    $sformat(scope, "%0s.m_env_mon.m_hdr2log_slv_stream_cov_collector", env_path);
    uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(KMAX_DATAPATH_WD), .USER_WIDTH(HDR2LOG_TUSER_WIDTH)))::set(null, scope, "stream_vif", i_hdr2log_slv_if);
    
    $sformat(scope, "%0s.m_env_mon.m_axis_msi_slv_stream_cov_collector", env_path);
    uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(KMAX_MSI_TDATA_WIDTH)))::set(null, scope, "stream_vif", i_axis_msi_slv_if);
    
    $sformat(scope, "%0s.m_env_mon.m_dc_slv_stream_cov_collector", env_path);
    uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(DELIVERED_P_TDATA_WIDTH)))::set(null, scope, "stream_vif", i_dc_slv_if);
     
      
    $sformat(scope, "%0s.m_env_mon.m_lti_c_rx_stream_cov_collector", env_path);
    uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(LTI_C_TDATA_WIDTH)))::set(null, scope, "stream_vif", i_lti_c_rx_if);
  
`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
    if(IS_ACTIVE) begin
      $sformat(scope, "%0s.m_env_mon", env_path);
      uvm_config_db#(virtual cdn_pcie_hls_bridge_qactive_clk_gater#(.SYNC_STAGES(4)))::set(null, scope, "msi_clk_gater_vif", active_tb_clk_if.msi_qactive_clk_gater);
      uvm_config_db#(virtual cdn_pcie_hls_bridge_qactive_clk_gater#(.SYNC_STAGES(4)))::set(null, scope, "dti_clk_gater_vif", active_tb_clk_if.dti_qactive_clk_gater);
    end
`endif

  endtask : set_vifs

  generate
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT&& !CONTROLLER_TOP_TB) begin : GEN_DTI_SET_VIFS
      function void set_vifs_for_dti(string env_path);
        string scope;
        string value;
        // DTI DN Interface
        if(IS_ACTIVE) begin
          $sformat(scope, "%0s.dti_env.dti_ats_env.dn_act_agent", env_path);
          $sformat(value, "%0s.GEN_DTI_SUPPORT.i_dti_dn_if.activeSlave", if_get_harness_instance_path());
          uvm_config_db#(string)::set(null, scope, "hdlPath", value);
          $sformat(scope, "%0s.dti_env.dti_ats_env.dn_act_agent.driver", env_path);
          uvm_config_db#(virtual cdnStream5Interface#(.DATA_WIDTH(parameters_cfg_pkg::KMAX_DTI_TDATA_WIDTH)))::set(null, scope, "stream_vif", GEN_DTI_SUPPORT.i_dti_dn_if);
        end
        $sformat(scope, "%0s.dti_env.dti_ats_env.dn_psv_agent", env_path);
        $sformat(value, "%0s.GEN_DTI_SUPPORT.i_dti_dn_if.passiveMaster", if_get_harness_instance_path());
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);

        // DTI UP Interface
        if(IS_ACTIVE) begin
          $sformat(scope, "%0s.dti_env.dti_ats_env.up_act_agent", env_path);
          $sformat(value, "%0s.GEN_DTI_SUPPORT.i_dti_up_if.activeMaster", if_get_harness_instance_path());
          uvm_config_db#(string)::set(null, scope, "hdlPath", value);
        end
        $sformat(scope, "%0s.dti_env.dti_ats_env.up_psv_agent", env_path);
        $sformat(value, "%0s.GEN_DTI_SUPPORT.i_dti_up_if.passiveSlave", if_get_harness_instance_path());
        uvm_config_db#(string)::set(null, scope, "hdlPath", value);
      endfunction
    end else begin : GEN_DTI_SET_VIFS
      function void set_vifs_for_dti(string env_path);
        `uvm_fatal("set_vifs_for_dti", "DTI interfaces not instantiated in HLSB TB Harness. Attempted to call an empty function while !(KMAX_DTI_SUPPORT&& !CONTROLLER_TOP_TB).");
      endfunction
    end
  endgenerate

  if(CONTROLLER_TOP_TB) begin : gen_cg_top_hlsb
    logic outbound_axi_posted_valid         ; 
    logic outbound_axi_nonposted_valid      ; 
    logic outbound_axi_completion_valid     ;
    logic inbound_axi_posted_valid          ;     
    logic inbound_axi_nonposted_valid       ;
    logic inbound_axi_completion_valid      ;
    logic outbound_hal_posted_valid         ;
    logic outbound_hal_nonposted_valid      ;
    logic outbound_hal_completion_valid     ;
    logic inbound_hal_posted_valid          ;
    logic inbound_hal_nonposted_valid       ;
    logic inbound_hal_completion_valid      ;
    logic axi_bridge_enable_p               ;
    logic hls_bridge_enable_p               ;
    logic tdisp_support_p                   ;
    logic kmax_dti_support_p                ;
    logic kmax_msi_if_support_p             ;
    logic kmax_ide_support_p                ;
    logic dti_ide_tdisp_enable              ;
    logic dti_msi_axi_enable                ;
    logic hdr2log_hlsb_data                 ;
    logic link_down_done                    ;     
    logic dti_hdr2log_valid                    ;     
    logic axi_hdr2log_valid                    ;     
    logic hls_bridge_out_hdr2log_valid                    ; 
    logic hdr2log_full_mux_covered  ;
    logic dti_msi_axi_enable_dti;
    logic dti_msi_axi_enable_msi;
    logic dti_msi_axi_enable_axi;
    logic dti_msi_axi_full_mux_covered;


//Interface coverage variables
    assign outbound_axi_posted_valid     = GEN_NUM_HLS_PORTS[0].i_hls_ob_posted_axi_if.HLS_VALID_TX;
    assign outbound_axi_nonposted_valid  = GEN_NUM_HLS_PORTS[0].i_hls_ob_nonposted_axi_if.HLS_VALID_TX;
    assign outbound_axi_completion_valid = GEN_NUM_HLS_PORTS[0].i_hls_ob_compl_axi_if.HLS_VALID_TX;
    assign inbound_axi_posted_valid      = GEN_NUM_HLS_PORTS[0].i_hls_ib_posted_axi_if.HLS_VALID_RX;
    assign inbound_axi_nonposted_valid   = GEN_NUM_HLS_PORTS[0].i_hls_ib_nonposted_axi_if.HLS_VALID_RX;
    assign inbound_axi_completion_valid  = GEN_NUM_HLS_PORTS[0].i_hls_ib_compl_axi_if.HLS_VALID_RX;
    assign outbound_hal_posted_valid     = i_hls_ob_posted_hal_if.HLS_VALID_RX;
    assign outbound_hal_nonposted_valid  = i_hls_ob_nonposted_hal_if.HLS_VALID_RX;
    assign outbound_hal_completion_valid = i_hls_ob_compl_hal_if.HLS_VALID_RX;
    assign inbound_hal_posted_valid      = i_hls_ib_posted_hal_if.HLS_VALID_TX;
    assign inbound_hal_nonposted_valid   = i_hls_ib_nonposted_hal_if.HLS_VALID_TX;
    assign inbound_hal_completion_valid  = i_hls_ib_compl_hal_if.HLS_VALID_TX;
    
//Parameter coverage variables
    assign axi_bridge_enable_p           = parameters_cfg_pkg::AXI_BRIDGE_ENABLE;
    assign hls_bridge_enable_p           = parameters_cfg_pkg::HLS_BRIDGE_ENABLE;
    assign tdisp_support_p               = (parameters_cfg_pkg::KMAX_TDISP_SUPPORT > 0);
    assign kmax_dti_support_p            = parameters_cfg_pkg::KMAX_DTI_SUPPORT;
    assign kmax_msi_if_support_p         = parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT;
    assign kmax_ide_support_p            = parameters_cfg_pkg::KMAX_IDE_SUPPORT;


    assign dti_hdr2log_valid = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_tx_dti_tvalid;
    assign axi_hdr2log_valid =  `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_s_tvalid;
    assign hls_bridge_out_hdr2log_valid = `HLS_BRIDGE_DUT_MODULE_NAME.hdr2log_m_tvalid;

//DTI with IDE and TDISP
    assign dti_ide_tdisp_enable     = kmax_dti_support_p && kmax_ide_support_p && tdisp_support_p;

//MSI/AXI/DTI mixed traffic test
    assign dti_msi_axi_enable      = kmax_dti_support_p && kmax_msi_if_support_p && axi_bridge_enable_p;
    assign dti_msi_axi_enable_dti  = dti_msi_axi_enable && (`HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_posted_dti_valid || `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_dti_valid);
    assign dti_msi_axi_enable_msi  = dti_msi_axi_enable && `HLS_BRIDGE_DUT_MODULE_NAME.axis_msi_m_tvalid ;
    assign dti_msi_axi_enable_axi  = dti_msi_axi_enable && (`HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_valid || `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_nonposted_axi_valid || `HLS_BRIDGE_DUT_MODULE_NAME.hls_ib_compl_axi_valid);

//HDR2LOG
    assign hdr2log_hlsb_data               = i_hdr2log_slv_if.tvalid;

//Link_down
    assign link_down_done                  = i_top_misc_if.link_down_handling_in_progress ;

    covergroup top_hlsb_interface;
      outbound_axi_posted:      coverpoint outbound_axi_posted_valid;
      outbound_axi_nonposted:   coverpoint outbound_axi_nonposted_valid;
      outbound_axi_completion:  coverpoint outbound_axi_completion_valid;
      inbound_axi_posted:       coverpoint inbound_axi_posted_valid;
      inbound_axi_nonposted:    coverpoint inbound_axi_nonposted_valid;
      inbound_axi_completion:   coverpoint inbound_axi_completion_valid;

      outbound_hal_posted:      coverpoint outbound_hal_posted_valid;
      outbound_hal_nonposted:   coverpoint outbound_hal_nonposted_valid;
      outbound_hal_completion:  coverpoint outbound_hal_completion_valid;
      inbound_hal_posted:       coverpoint inbound_hal_posted_valid;
      inbound_hal_nonposted:    coverpoint inbound_hal_nonposted_valid;
      inbound_hal_completion:   coverpoint inbound_hal_completion_valid;
    endgroup

    covergroup top_hlsb_parameters;
      axi_bridge_enable:        coverpoint axi_bridge_enable_p;
      hls_bridge_enable:        coverpoint hls_bridge_enable_p;
      tdisp_support:            coverpoint tdisp_support_p;
      kmax_dti_support:         coverpoint kmax_dti_support_p;
      kmax_msi_if_support:      coverpoint kmax_msi_if_support_p;
      kmax_ide_support:         coverpoint kmax_ide_support_p;
    endgroup

    covergroup top_dti_ide_tdisp;
      dti_ide_tdisp:            coverpoint dti_ide_tdisp_enable; 
    endgroup

    covergroup top_msi_axi_dti_traffic;
      dti_traffic:            coverpoint dti_msi_axi_enable_dti;
    endgroup

    covergroup top_msi_axi_traffic;
      axi_traffic:            coverpoint dti_msi_axi_enable_axi;
    endgroup

    covergroup top_msi_traffic;
      msi_traffic:            coverpoint dti_msi_axi_enable_msi;
    endgroup


    covergroup top_hdr2log_dti_axi;
      hlsb_hdr2log_data:      coverpoint hdr2log_hlsb_data;
    endgroup

    covergroup top_linkdown_hlsb_dti;
      hlsb_dti_linkdown:      coverpoint link_down_done;
    endgroup

    covergroup top_dti_hdr2log_mux;
     dti_hdr2log_v : coverpoint  dti_hdr2log_valid ;
    endgroup

    covergroup top_axi_hdr2log_mux;
     axi_hdr2log_v : coverpoint  axi_hdr2log_valid ;
    endgroup

    covergroup top_hlsb_hdr2log_mux;
     hls_bridge_v  : coverpoint  hls_bridge_out_hdr2log_valid ;
    endgroup

    covergroup hdr2log_full_mux_cg;
      cp: coverpoint hdr2log_full_mux_covered { bins success = {1}; }
    endgroup

    covergroup dti_axi_msi_full_mux_cg;
      cp: coverpoint dti_msi_axi_full_mux_covered { bins success = {1}; }
    endgroup

    top_hlsb_interface  cg1   = new();
    top_hlsb_parameters cg2   = new();
    top_dti_ide_tdisp   cg3   = new();
    //top_msi_axi_dti     cg4   = new();
    top_hdr2log_dti_axi cg5   = new();
    top_linkdown_hlsb_dti cg6 = new();
    top_dti_hdr2log_mux cg7 = new();
    top_axi_hdr2log_mux cg8 = new();
    top_hlsb_hdr2log_mux cg9 = new();
    hdr2log_full_mux_cg cg10 = new();
    top_msi_axi_dti_traffic cg11 = new();
    top_msi_axi_traffic cg12 = new();
    top_msi_traffic cg13 = new();
    dti_axi_msi_full_mux_cg cg14 = new();


    always @(axi_bridge_enable_p, dti_ide_tdisp_enable, dti_msi_axi_enable, hdr2log_hlsb_data, hls_bridge_enable_p, inbound_axi_completion_valid, inbound_axi_nonposted_valid, inbound_axi_posted_valid, inbound_hal_completion_valid, inbound_hal_nonposted_valid, inbound_hal_posted_valid, kmax_dti_support_p, kmax_ide_support_p, kmax_msi_if_support_p, link_down_done, outbound_axi_completion_valid, outbound_axi_nonposted_valid, outbound_axi_posted_valid,
    outbound_hal_completion_valid, outbound_hal_nonposted_valid, outbound_hal_posted_valid, tdisp_support_p, dti_hdr2log_valid, axi_hdr2log_valid, hls_bridge_out_hdr2log_valid, dti_msi_axi_enable_msi, dti_msi_axi_enable_dti, dti_msi_axi_enable_axi) begin
      cg1.sample(); // Sample the current values
      cg2.sample(); // Sample the current values
      cg3.sample(); // Sample the current values
      //cg4.sample(); // Sample the current values
      cg5.sample(); // Sample the current values
      cg6.sample(); // Sample the current values
      cg7.sample();
      cg8.sample();
      cg9.sample();
      cg11.sample();
      cg12.sample();
      cg13.sample();

      hdr2log_full_mux_covered = (cg7.get_coverage() >=100.0) && (cg8.get_coverage() >= 100.0) && (cg9.get_coverage() >= 100.0); 
      cg10.sample();

      dti_msi_axi_full_mux_covered = (cg11.get_coverage() >=100.0) && (cg12.get_coverage() >= 100.0) && (cg13.get_coverage() >= 100.0); 
      cg14.sample();

    end


    
  end

endinterface : cdn_pcie_hls_bridge_tb_harness

`endif // CDN_PCIE_HLS_BRIDGE_TB_HARNESS_SV
