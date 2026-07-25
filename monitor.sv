`ifndef CDN_PCIE_HLS_BRIDGE_MONITOR_SV
`define CDN_PCIE_HLS_BRIDGE_MONITOR_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_monitor
// This class defines the module level monitor
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_monitor extends uvm_component implements I_cdn_pcie_hls_bridge_reset;

  //----------------------------------------------------------------------------
  // TLM Analysis Fifos
  //----------------------------------------------------------------------------
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_posted_hal_pkt_ended_af                                          ;                                               
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_nonposted_hal_pkt_ended_af                                       ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_compl_hal_pkt_ended_af                                           ;
  
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ib_posted_hal_pkt_ended_af                                          ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ib_nonposted_hal_pkt_ended_af                                       ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ib_compl_hal_pkt_ended_af                                           ;

`ifdef DTI_TB_IN_PASSIVE_MODE
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ib_posted_dti_pkt_ended_af                                          ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ib_nonposted_dti_pkt_ended_af                                       ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_posted_dti_pkt_started_af                                        ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_compl_dti_pkt_started_af                                         ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_posted_dti_pkt_ended_af                                          ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_compl_dti_pkt_ended_af                                           ;
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_hdr2log_dti_ended_af                                                    ;
`endif
 
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_posted_axi_pkt_started_af    [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_posted_axi_pkt_ended_af      [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_predicted_hls_ob_posted_axi_af                                          ;
  
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_nonposted_axi_pkt_started_af [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_nonposted_axi_pkt_ended_af   [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_predicted_hls_ob_nonposted_axi_af                                       ;
  
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_compl_axi_pkt_started_af     [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ob_compl_axi_pkt_ended_af       [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_predicted_hls_ob_compl_axi_af                                           ;
  
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ib_posted_axi_pkt_ended_af      [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ib_nonposted_axi_pkt_ended_af   [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)      m_hls_ib_compl_axi_pkt_ended_af       [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_hdr2log_slv_ended_af                                                    ;
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_hdr2log_mst_started_af              [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_hdr2log_mst_ended_af                [parameters_cfg_pkg::NUM_HLS_PORTS] ;

  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_lti_ctag_rx_ended_af                                                    ;
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_lti_ctag_tx_ended_af                [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_predicted_lti_ctag_tx_af                                                ;
  
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_axis_msi_slv_ended_af                                                   ;
  
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_dc_slv_ended_af                                                         ;
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_dc_mst_ended_af                     [parameters_cfg_pkg::NUM_HLS_PORTS] ;
`ifdef DTI_TB_IN_PASSIVE_MODE
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_dc_dti_ended_af                                                         ;
`endif

  uvm_tlm_analysis_fifo #(denaliCdn_axiTransaction)  m_axi_mst_pkt_ended_af                                                    ;
  uvm_tlm_analysis_fifo #(denaliCdn_axiTransaction)  m_axi_slv_pkt_ended_af                                                    ;


  uvm_tlm_analysis_fifo #(denaliStreamTransaction)   m_qos_mst_ended_af[parameters_cfg_pkg::NUM_HLS_PORTS]		       ;
  
  // QOS TX checker
  uvm_tlm_analysis_fifo #(denaliStreamTransaction) m_qos_slv_ended_af; 
  int unsigned m_qos_expected_count [int];
  int unsigned m_qos_observed_count [int];

  // QOS analysis ports -- written whenever  IB TLP is seen
  uvm_analysis_port #(cdn_hpa_pcie_tlp) m_hls_ib_posted_qos_ap   [];
  uvm_analysis_port #(cdn_hpa_pcie_tlp) m_hls_ib_nonposted_qos_ap[];
  uvm_analysis_port #(cdn_hpa_pcie_tlp) m_hls_ib_compl_qos_ap    [];

  //----------------------------------------------------------------------------
  // Analysis Ports
  //----------------------------------------------------------------------------
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ob_np_req_ap                                                                                                           ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ob_uio_p_req_ap                                                                                                        ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ob_compl_req_ap                                                                                                        ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ob_10bit_compl_req_ap                                                                                                  ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ob_14bit_compl_req_ap                                                                                                  ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ob_uio_p_compl_req_ap                                                                                                  ;
  
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ib_np_req_ap                                                                                                           ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ib_uio_p_req_ap                                                                                                        ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ib_compl_req_ap                                                                                                        ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ib_10bit_compl_req_ap                                                                                                  ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ib_14bit_compl_req_ap                                                                                                  ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           ib_uio_p_compl_req_ap                                                                                                  ;

  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_posted_axi_pkt_started_ap         [parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT]    ;
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_posted_axi_pkt_ended_ap           [parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT]    ;
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_nonposted_axi_pkt_started_ap      [parameters_cfg_pkg::NUM_HLS_PORTS]                                           ;
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_nonposted_axi_pkt_ended_ap        [parameters_cfg_pkg::NUM_HLS_PORTS]                                           ;
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_compl_axi_pkt_started_ap          [parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT]    ;
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_compl_axi_pkt_ended_ap            [parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT]    ;

`ifdef DTI_TB_IN_PASSIVE_MODE
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_posted_dti_pkt_started_ap                                                                                       ;
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_posted_dti_pkt_ended_ap                                                                                         ;
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_compl_dti_pkt_started_ap                                                                                        ;
  uvm_analysis_port     #(denaliCxsTransaction)                       hls_ob_compl_dti_pkt_ended_ap                                                                                          ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           hls_ob_posted_hal_pkt_inv_ap                                                                                           ;
`endif

  uvm_analysis_port     #(cdn_pcie_hls_bridge_ib_port_tr_delivered_s) hls_ib_posted_port_tr_ap                                                                                               ; 
  uvm_analysis_port     #(denaliCxsTransaction)                       axi_ib_posted_pkt_ended_ap               [parameters_cfg_pkg::NUM_HLS_PORTS]                                           ;
  uvm_analysis_port     #(denaliCxsTransaction)                       dti_ib_posted_pkt_ended_ap                                                                                             ;  
  uvm_analysis_port     #(denaliStreamTransaction)                    msi_ib_posted_pkt_ended_ap                                                                                             ; 
  uvm_analysis_port     #(denaliStreamTransaction)                    axi_delivered_count_pkt_ended_ap         [parameters_cfg_pkg::NUM_HLS_PORTS]                                           ;
  uvm_analysis_port     #(denaliStreamTransaction)                    dti_delivered_count_pkt_ended_ap                                                                                       ;

  uvm_analysis_port     #(denaliStreamTransaction)                    lti_ctag_tx_stream_pkt_ended_ap          [parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT] ;

  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           m_hls_ib_posted_axi_tlp_pkt_delivered_ap [parameters_cfg_pkg::NUM_HLS_PORTS]                                           ;

  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           credit_ob_posted_axi_ap                                                                                                ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           credit_ob_posted_hal_ap                                                                                                ;

  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           credit_ob_nonposted_axi_ap                                                                                             ;
  uvm_analysis_port     #(cdn_hpa_pcie_tlp)                           credit_ob_nonposted_hal_ap                                                                                             ;
  
  //----------------------------------------------------------------------------
  // Components
  //----------------------------------------------------------------------------
  //--- Order checking is per TC. -------------
  cdn_pcie_hls_bridge_hls_ib_posted_order_checker           m_hls_ib_posted_order_checker                                         ;
  
  cdn_pcie_hls_bridge_hls_ob_merge_predictor                m_hls_ob_posted_merge_predictor                                       ;
  cdn_pcie_hls_bridge_hls_ob_merge_predictor                m_hls_ob_nonposted_merge_predictor                                    ;
  cdn_pcie_hls_bridge_hls_ob_merge_predictor                m_hls_ob_compl_merge_predictor                                        ;
  
  cdn_pcie_hls_bridge_lti_c_predictor                       m_lti_ctag_predictor                                                  ;

  cdn_pcie_tl_cxs_scoreboard                                m_hls_ob_posted_cxs_scoreboard                                        ;
  cdn_pcie_tl_cxs_scoreboard                                m_hls_ob_nonposted_cxs_scoreboard                                     ;
  cdn_pcie_tl_cxs_scoreboard                                m_hls_ob_compl_cxs_scoreboard                                         ;
  cdn_pcie_tl_cxs_scoreboard                                m_hls_ib_posted_cxs_scoreboard    [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  cdn_pcie_tl_cxs_scoreboard                                m_hls_ib_nonposted_cxs_scoreboard [parameters_cfg_pkg::NUM_HLS_PORTS] ;
  cdn_pcie_tl_cxs_scoreboard                                m_hls_ib_compl_cxs_scoreboard     [parameters_cfg_pkg::NUM_HLS_PORTS] ;

`ifdef DTI_TB_IN_PASSIVE_MODE
  cdn_pcie_tl_cxs_scoreboard                                m_hls_ib_posted_dti_scoreboard                                        ;
  cdn_pcie_tl_cxs_scoreboard                                m_hls_ib_nonposted_dti_scoreboard                                     ;
`endif
 
  cdn_pcie_tl_generic_scoreboard#(denaliCdn_axiTransaction) m_axi_reg_access_scoreboard                                           ; 
  
  cdn_pcie_tl_generic_scoreboard#(denaliStreamTransaction)  m_hdr2log_stream_scoreboard                                           ;
  cdn_pcie_tl_generic_scoreboard#(denaliStreamTransaction)  m_lti_ctag_stream_scoreboard                                          ;
  cdn_pcie_tl_generic_scoreboard#(denaliStreamTransaction)  m_dc_stream_scoreboard                                                ;
  cdn_pcie_tl_generic_scoreboard#(denaliStreamTransaction)  m_msi_stream_scoreboard                                               ;
  
  cdn_hpa_pcie_cfg_info_t        m_rp_ob_tlp_cov_cfg_info  ;
  cdn_pcie_hpa_tlp_cov_collector m_rp_ob_tlp_cov_collector ;
  
  cdn_hpa_pcie_cfg_info_t        m_rp_ib_tlp_cov_cfg_info  ;
  cdn_pcie_hpa_tlp_cov_collector m_rp_ib_tlp_cov_collector ;
  
  cdn_hpa_pcie_cfg_info_t        m_ep_ob_tlp_cov_cfg_info  ;
  cdn_pcie_hpa_tlp_cov_collector m_ep_ob_tlp_cov_collector ;
  
  cdn_hpa_pcie_cfg_info_t        m_ep_ib_tlp_cov_cfg_info  ;
  cdn_pcie_hpa_tlp_cov_collector m_ep_ib_tlp_cov_collector ;

`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
  cdn_pcie_axi_stream_cov_collector_cfg m_hdr2log_mst_stream_cov_collector_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_pcie_axi_stream_cov_collector#(.TDATA_WIDTH(parameters_cfg_pkg::HLS_PORT_DATA_WIDTH_ARR[(0 * 32) +: 32]), .TUSER_WIDTH(parameters_cfg_pkg::TB_HDR2LOG_TUSER_WIDTH)) m_hdr2log_mst_stream_cov_collector[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_pcie_axi_stream_cov_collector_cfg m_hdr2log_slv_stream_cov_collector_cfg;
  cdn_pcie_axi_stream_cov_collector#(.TDATA_WIDTH(parameters_cfg_pkg::KMAX_DATAPATH_WD), .TUSER_WIDTH(parameters_cfg_pkg::TB_HDR2LOG_TUSER_WIDTH)) m_hdr2log_slv_stream_cov_collector;
  
  cdn_pcie_axi_stream_cov_collector_cfg m_axis_msi_slv_stream_cov_collector_cfg;
  cdn_pcie_axi_stream_cov_collector#(.TDATA_WIDTH(parameters_cfg_pkg::KMAX_MSI_TDATA_WIDTH)) m_axis_msi_slv_stream_cov_collector;
  
  cdn_pcie_axi_stream_cov_collector_cfg m_dc_mst_stream_cov_collector_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_pcie_axi_stream_cov_collector#(.TDATA_WIDTH(parameters_cfg_pkg::DELIVERED_P_TDATA_WIDTH)) m_dc_mst_stream_cov_collector[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_pcie_axi_stream_cov_collector_cfg m_dc_slv_stream_cov_collector_cfg;
  cdn_pcie_axi_stream_cov_collector#(.TDATA_WIDTH(parameters_cfg_pkg::DELIVERED_P_TDATA_WIDTH)) m_dc_slv_stream_cov_collector;

  cdn_pcie_axi_stream_cov_collector_cfg m_lti_c_tx_stream_cov_collector_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_pcie_axi_stream_cov_collector#(.TDATA_WIDTH(parameters_cfg_pkg::LTI_C_TDATA_WIDTH)) m_lti_c_tx_stream_cov_collector[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_pcie_axi_stream_cov_collector_cfg m_lti_c_rx_stream_cov_collector_cfg;
  cdn_pcie_axi_stream_cov_collector#(.TDATA_WIDTH(parameters_cfg_pkg::LTI_C_TDATA_WIDTH)) m_lti_c_rx_stream_cov_collector;
`endif

  //----------------------------------------------------------------------------
  // Config objects
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  // Variable: hls_bridge_regmodel
  // HLS Bridge Register Model Handle
  //----------------------------------------------------------------------------
  hls_bridge_reg_model hls_bridge_regmodel;
  
  //--- HLS Bridge Environment Config Object -----------------------------------
  cdn_pcie_hls_bridge_env_config m_env_cfg;

  //--- Remote Dev Cfg (needed for tracking PR Group index) --------------------
  cdn_pcie_hpa_dev_top_config    m_remote_dev_top_config;

  //----------------------------------------------------------------------------
  // Member variables
  //----------------------------------------------------------------------------
  cdn_pcie_hpa_compl_wrapper           m_ob_compl_lut_obj                                                ;
  cdn_pcie_hpa_compl_wrapper           m_ob_compl_lut_obj_10_bit                                         ;
  cdn_pcie_hpa_compl_wrapper           m_ob_compl_lut_obj_14_bit                                         ;
  cdn_pcie_hpa_compl_wrapper           m_ob_uio_p_compl_lut_obj                                          ;
  
  cdn_pcie_hpa_compl_wrapper           m_ib_compl_lut_obj                                                ;
  cdn_pcie_hpa_compl_wrapper           m_ib_compl_lut_obj_10_bit                                         ;
  cdn_pcie_hpa_compl_wrapper           m_ib_compl_lut_obj_14_bit                                         ;
  cdn_pcie_hpa_compl_wrapper           m_ib_uio_p_compl_lut_obj                                          ;

  bit [31 : 0]                         m_hdr2log_ports_active_in_cycle                                   ;
  time                                 m_hdr2log_last_cycle_time                                         ;
  
  int unsigned                         m_total_num_pkts_sent                                             ;
  int unsigned                         m_total_expected_lti_count [2][parameters_cfg_pkg::NUM_LTI_PORTS] ;
  int unsigned                         m_total_received_lti_count [2][parameters_cfg_pkg::NUM_LTI_PORTS] ;
  int unsigned                         m_total_expected_delivered_count [parameters_cfg_pkg::NUM_TLP_STREAMS];
  int unsigned                         m_total_received_delivered_count [parameters_cfg_pkg::NUM_TLP_STREAMS];

  cdn_pcie_hls_bridge_msi_lti_c_info_s m_exp_msi_lti_c_tracker_q[$]                                      ;

  bit [31 : 0]                         m_dc_ports_active_in_cycle;
  time                                 m_dc_last_cycle_time;
  bit [31 : 0]                         m_ob_p_ports_active;
  bit [31 : 0]                         m_ob_np_ports_active;
  bit [31 : 0]                         m_ob_compl_ports_active;

  // queues for credit limit prediction
  bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD-1 : 0]  crd_m_p_header_q  [parameters_cfg_pkg::KMAX_NUM_VCS-1 : 0][$];
  bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD-1 : 0] crd_m_p_payload_q [parameters_cfg_pkg::KMAX_NUM_VCS-1 : 0][$];
  bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD-1 : 0]  crd_m_np_header_q  [parameters_cfg_pkg::KMAX_NUM_VCS-1 : 0][$];
  bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD-1 : 0] crd_m_np_payload_q [parameters_cfg_pkg::KMAX_NUM_VCS-1 : 0][$];
  //queues for crd_used signals
  bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1:0] crd_used_p_header_q [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][$];
  bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1:0] crd_used_p_payload_q [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][$];
  //arrays to store crd_lmt signals
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] current_s_credits_p_header;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] current_s_credits_p_payload;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0]  current_m_credits_p_header;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] current_m_credits_p_payload;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] current_s_credits_np_header;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] current_s_credits_np_payload;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0]  current_m_credits_np_header;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] current_m_credits_np_payload;

// Totyo: Threre should probably be qactive UVC, but things are changing too quickly to commit to one.
`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
  virtual cdn_pcie_hls_bridge_qactive_clk_gater msi_clk_gater_vif                                        ;
  virtual cdn_pcie_hls_bridge_qactive_clk_gater dti_clk_gater_vif                                        ;
`endif

  // Packet type tracking
  int prev_pkt_type = -1;      // 0=DTI, 1=MSI, 2=UIO_NONPOSTED, 3=UIO_POSTED
  int prev2_pkt_type = -1;
  int curr_pkt_type;
  bit prev_was_uio_np;
  bit first_pkt = 1;
  int uio_posted_streak = 0;
  bit saw_dti_after_2_uio_posted;

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_monitor)

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Function: build_phase
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //--- Fetch the register model --------------------------------------------
    if (!uvm_config_db#(hls_bridge_reg_model)::get(this, "", "hls_bridge_regmodel", hls_bridge_regmodel)) begin
      `uvm_fatal(get_type_name(), "Unable to read hls_bridge_regmodel object from ConfigDB.");
    end
    
    //---Fetch the env config object----------------------------------------------
    if(!uvm_config_db#(cdn_pcie_hls_bridge_env_config)::get(this, "", "env_cfg", m_env_cfg)) begin
     `uvm_fatal(get_type_name(),"Could not find cdn_pcie_hls_bridge_env_config(env_cfg) in ConfigDB database.");
    end

`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
    if(!uvm_config_db #(cdn_pcie_hpa_dev_top_config)::get(this, "", "remote_dev_top_cfg", m_remote_dev_top_config)) begin
      `uvm_fatal(get_type_name(), "Could not find cdn_pcie_hpa_dev_top_config(remote_dev_top_cfg) in ConfigDB database.")
    end
`endif

`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
    if(!uvm_config_db #(virtual cdn_pcie_hls_bridge_qactive_clk_gater#(.SYNC_STAGES(4)))::get(this, "", "msi_clk_gater_vif", msi_clk_gater_vif)) begin
      `uvm_fatal(get_type_name(), "Could not find msi_clk_gater_vif in ConfigDB database.")
    end
    if(!uvm_config_db #(virtual cdn_pcie_hls_bridge_qactive_clk_gater#(.SYNC_STAGES(4)))::get(this, "", "dti_clk_gater_vif", dti_clk_gater_vif)) begin
      `uvm_fatal(get_type_name(), "Could not find dti_clk_gater_vif in ConfigDB database.")
    end
`endif

    //-- Analysis Fifo's creations ---------------------------------------------
    m_hls_ob_posted_hal_pkt_ended_af    = new("m_hls_ob_posted_hal_pkt_ended_af"   , this);
    m_hls_ob_nonposted_hal_pkt_ended_af = new("m_hls_ob_nonposted_hal_pkt_ended_af", this);
    m_hls_ob_compl_hal_pkt_ended_af     = new("m_hls_ob_compl_hal_pkt_ended_af"    , this);
    
    m_hls_ib_posted_hal_pkt_ended_af    = new("m_hls_ib_posted_hal_pkt_ended_af"   , this);
    m_hls_ib_nonposted_hal_pkt_ended_af = new("m_hls_ib_nonposted_hal_pkt_ended_af", this);
    m_hls_ib_compl_hal_pkt_ended_af     = new("m_hls_ib_compl_hal_pkt_ended_af"    , this);
    
`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      m_hls_ib_posted_dti_pkt_ended_af    = new("m_hls_ib_posted_dti_pkt_ended_af"   , this);
      m_hls_ib_nonposted_dti_pkt_ended_af = new("m_hls_ib_nonposted_dti_pkt_ended_af", this);
      m_hls_ob_posted_dti_pkt_started_af  = new("m_hls_ob_posted_dti_pkt_started_af" , this);
      m_hls_ob_posted_dti_pkt_ended_af    = new("m_hls_ob_posted_dti_pkt_ended_af"   , this);
      m_hls_ob_compl_dti_pkt_started_af   = new("m_hls_ob_compl_dti_pkt_started_af"  , this);
      m_hls_ob_compl_dti_pkt_ended_af     = new("m_hls_ob_compl_dti_pkt_ended_af"    , this);
      m_hdr2log_dti_ended_af              = new("m_hdr2log_dti_ended_af"             , this);
      m_dc_dti_ended_af                   = new("m_dc_dti_ended_af"                  , this);
    end
`endif
    
    m_hdr2log_slv_ended_af              = new("m_hdr2log_slv_ended_af"             , this);    
    
    m_lti_ctag_rx_ended_af              = new("m_lti_ctag_rx_ended_af"             , this);     
    
    m_axis_msi_slv_ended_af             = new("m_axis_msi_slv_ended_af"            , this);       
    
    m_dc_slv_ended_af                   = new("m_dc_slv_ended_af"                  , this);    
    
    m_axi_mst_pkt_ended_af              = new("m_axi_mst_pkt_ended_af"             , this);
    m_axi_slv_pkt_ended_af              = new("m_axi_slv_pkt_ended_af"             , this);

    
    foreach (m_qos_mst_ended_af[i]) begin
  	m_qos_mst_ended_af[i] = new($sformatf("m_qos_mst_ended_af[%0d]", i), this);
    end
    // QOS TX FIFO and count arrays
    m_qos_slv_ended_af = new("m_qos_slv_ended_af", this);
    for (int g = 0; g < (parameters_cfg_pkg::NUM_TLP_STREAMS * 4); g++) begin
      m_qos_expected_count[g] = 0;
      m_qos_observed_count[g] = 0;
    end  
     

    foreach(m_hls_ob_posted_axi_pkt_started_af[loop_port]) begin
      m_hls_ob_posted_axi_pkt_started_af[loop_port] = new($sformatf("m_hls_ob_posted_axi_pkt_started_af[%0d]", loop_port), this);
    end
    foreach(m_hls_ob_posted_axi_pkt_ended_af[loop_port]) begin
      m_hls_ob_posted_axi_pkt_ended_af[loop_port] = new($sformatf("m_hls_ob_posted_axi_pkt_ended_af[%0d]", loop_port), this);
    end
    m_predicted_hls_ob_posted_axi_af = new("m_predicted_hls_ob_posted_axi_af", this);
    
    foreach(m_hls_ob_nonposted_axi_pkt_ended_af[loop_port]) begin
      m_hls_ob_nonposted_axi_pkt_ended_af[loop_port] = new($sformatf("m_hls_ob_nonposted_axi_pkt_ended_af[%0d]", loop_port), this);
    end
    foreach(m_hls_ob_nonposted_axi_pkt_started_af[loop_port]) begin
      m_hls_ob_nonposted_axi_pkt_started_af[loop_port] = new($sformatf("m_hls_ob_nonposted_axi_pkt_started_af[%0d]", loop_port), this);
    end
    m_predicted_hls_ob_nonposted_axi_af = new("m_predicted_hls_ob_nonposted_axi_af", this);
    
    foreach(m_hls_ob_compl_axi_pkt_ended_af[loop_port]) begin
      m_hls_ob_compl_axi_pkt_ended_af[loop_port] = new($sformatf("m_hls_ob_compl_axi_pkt_ended_af[%0d]", loop_port), this);
    end
    foreach(m_hls_ob_compl_axi_pkt_started_af[loop_port]) begin
      m_hls_ob_compl_axi_pkt_started_af[loop_port] = new($sformatf("m_hls_ob_compl_axi_pkt_started_af[%0d]", loop_port), this);
    end
    m_predicted_hls_ob_compl_axi_af = new("m_predicted_hls_ob_compl_axi_af", this);
    
    foreach(m_hls_ib_posted_axi_pkt_ended_af[loop_port]) begin
      m_hls_ib_posted_axi_pkt_ended_af[loop_port] = new($sformatf("m_hls_ib_posted_axi_pkt_ended_af[%0d]", loop_port), this);
    end
    
    foreach(m_hls_ib_nonposted_axi_pkt_ended_af[loop_port]) begin
      m_hls_ib_nonposted_axi_pkt_ended_af[loop_port] = new($sformatf("m_hls_ib_nonposted_axi_pkt_ended_af[%0d]", loop_port), this);
    end
    
    foreach(m_hls_ib_compl_axi_pkt_ended_af[loop_port]) begin
      m_hls_ib_compl_axi_pkt_ended_af[loop_port] = new($sformatf("m_hls_ib_compl_axi_pkt_ended_af[%0d]", loop_port), this);
    end
    
    foreach(m_hdr2log_mst_started_af[loop_port]) begin
      m_hdr2log_mst_started_af[loop_port] = new($sformatf("m_hdr2log_mst_started_af[%0d]", loop_port), this);
    end
    foreach(m_hdr2log_mst_ended_af[loop_port]) begin
      m_hdr2log_mst_ended_af[loop_port] = new($sformatf("m_hdr2log_mst_ended_af[%0d]", loop_port), this);
    end

    foreach(m_lti_ctag_tx_ended_af[loop_port]) begin
      m_lti_ctag_tx_ended_af[loop_port] = new($sformatf("m_lti_ctag_tx_ended_af[%0d]", loop_port), this);
    end
    m_predicted_lti_ctag_tx_af = new("m_predicted_lti_ctag_tx_af", this);
    
    foreach(m_dc_mst_ended_af[loop_port]) begin
      m_dc_mst_ended_af[loop_port] = new($sformatf("m_dc_mst_ended_af[%0d]", loop_port), this);
    end
    
    // Components Creation ------------------------------------------------------
    m_hls_ib_posted_order_checker = cdn_pcie_hls_bridge_hls_ib_posted_order_checker::type_id::create("m_hls_ib_posted_order_checker", this);
    
    m_hls_ob_posted_merge_predictor    = cdn_pcie_hls_bridge_hls_ob_merge_predictor::type_id::create("m_hls_ob_posted_merge_predictor",    this);
    m_hls_ob_nonposted_merge_predictor = cdn_pcie_hls_bridge_hls_ob_merge_predictor::type_id::create("m_hls_ob_nonposted_merge_predictor", this);
    m_hls_ob_compl_merge_predictor     = cdn_pcie_hls_bridge_hls_ob_merge_predictor::type_id::create("m_hls_ob_compl_merge_predictor",     this);
    
    m_lti_ctag_predictor = cdn_pcie_hls_bridge_lti_c_predictor::type_id::create("m_lti_ctag_predictor", this);
    
    // -- For outbound direction the order in which the DUT sends the Packet doesn't matter in AXI + DTI hence enabling out of order scoreboarding for P/CPL in case of single port - PCIE-20784. ------
    m_hls_ob_posted_cxs_scoreboard = cdn_pcie_tl_cxs_scoreboard::type_id::create("m_hls_ob_posted_cxs_scoreboard", this);
    m_hls_ob_posted_cxs_scoreboard.m_user_control_data_compare_en = 1;
    m_hls_ob_posted_cxs_scoreboard.m_end_err_compare_en           = 1;
    if((parameters_cfg_pkg::KMAX_DTI_SUPPORT && parameters_cfg_pkg::NUM_HLS_PORTS == 1) || parameters_cfg_pkg::NUM_HLS_PORTS > 1)
      m_hls_ob_posted_cxs_scoreboard.m_en_out_of_order_scb        = 1;
    
    m_hls_ob_nonposted_cxs_scoreboard = cdn_pcie_tl_cxs_scoreboard::type_id::create("m_hls_ob_nonposted_cxs_scoreboard", this);
    m_hls_ob_nonposted_cxs_scoreboard.m_user_control_data_compare_en = 1;
    m_hls_ob_nonposted_cxs_scoreboard.m_end_err_compare_en           = 1;
    if((parameters_cfg_pkg::KMAX_DTI_SUPPORT && parameters_cfg_pkg::NUM_HLS_PORTS == 1) || parameters_cfg_pkg::NUM_HLS_PORTS > 1)
      m_hls_ob_nonposted_cxs_scoreboard.m_en_out_of_order_scb        = 1;

    m_hls_ob_compl_cxs_scoreboard = cdn_pcie_tl_cxs_scoreboard::type_id::create("m_hls_ob_compl_cxs_scoreboard", this);
    m_hls_ob_compl_cxs_scoreboard.m_user_control_data_compare_en = 1;
    m_hls_ob_compl_cxs_scoreboard.m_end_err_compare_en           = 1;
    if((parameters_cfg_pkg::KMAX_DTI_SUPPORT && parameters_cfg_pkg::NUM_HLS_PORTS == 1) || parameters_cfg_pkg::NUM_HLS_PORTS > 1)
      m_hls_ob_compl_cxs_scoreboard.m_en_out_of_order_scb        = 1;
    
`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      m_hls_ib_posted_dti_scoreboard = cdn_pcie_tl_cxs_scoreboard::type_id::create("m_hls_ib_posted_dti_scoreboard", this);
      m_hls_ib_posted_dti_scoreboard.m_user_control_data_compare_en = 1;
      m_hls_ib_posted_dti_scoreboard.m_end_err_compare_en           = 1;

      m_hls_ib_nonposted_dti_scoreboard = cdn_pcie_tl_cxs_scoreboard::type_id::create("m_hls_ib_nonposted_dti_scoreboard", this);
      m_hls_ib_nonposted_dti_scoreboard.m_user_control_data_compare_en = 1;
      m_hls_ib_nonposted_dti_scoreboard.m_end_err_compare_en           = 1;
    end
`endif

    foreach(m_hls_ib_posted_cxs_scoreboard[loop_port]) begin
      m_hls_ib_posted_cxs_scoreboard[loop_port] = cdn_pcie_tl_cxs_scoreboard::type_id::create($sformatf("m_hls_ib_posted_cxs_scoreboard[%0d]", loop_port), this);
      m_hls_ib_posted_cxs_scoreboard[loop_port].m_user_control_data_compare_en = 1;
      m_hls_ib_posted_cxs_scoreboard[loop_port].m_end_err_compare_en           = 1;
    end
    
    foreach(m_hls_ib_nonposted_cxs_scoreboard[loop_port]) begin
      m_hls_ib_nonposted_cxs_scoreboard[loop_port] = cdn_pcie_tl_cxs_scoreboard::type_id::create($sformatf("m_hls_ib_nonposted_cxs_scoreboard[%0d]", loop_port), this);
      m_hls_ib_nonposted_cxs_scoreboard[loop_port].m_user_control_data_compare_en = 1;
      m_hls_ib_nonposted_cxs_scoreboard[loop_port].m_end_err_compare_en           = 1;
    end
    
    foreach(m_hls_ib_compl_cxs_scoreboard[loop_port]) begin
      m_hls_ib_compl_cxs_scoreboard[loop_port] = cdn_pcie_tl_cxs_scoreboard::type_id::create($sformatf("m_hls_ib_compl_cxs_scoreboard[%0d]", loop_port), this);
      m_hls_ib_compl_cxs_scoreboard[loop_port].m_user_control_data_compare_en = 1;
      m_hls_ib_compl_cxs_scoreboard[loop_port].m_end_err_compare_en           = 1;
    end
    
    m_axi_reg_access_scoreboard  = cdn_pcie_tl_generic_scoreboard#(denaliCdn_axiTransaction)::type_id::create("m_axi_reg_access_scoreboard", this);
    
    m_hdr2log_stream_scoreboard  = cdn_pcie_tl_generic_scoreboard#(denaliStreamTransaction)::type_id::create("m_hdr2log_stream_scoreboard" , this);
    m_hdr2log_stream_scoreboard.m_check_expected_present_when_received = 1;
    m_lti_ctag_stream_scoreboard = cdn_pcie_tl_generic_scoreboard#(denaliStreamTransaction)::type_id::create("m_lti_ctag_stream_scoreboard", this);
    m_lti_ctag_stream_scoreboard.m_check_expected_present_when_received = 1;
    m_msi_stream_scoreboard      = cdn_pcie_tl_generic_scoreboard#(denaliStreamTransaction)::type_id::create("m_msi_stream_scoreboard"     , this);
    m_msi_stream_scoreboard.m_check_expected_present_when_received = 1;
    m_dc_stream_scoreboard       = cdn_pcie_tl_generic_scoreboard#(denaliStreamTransaction)::type_id::create("m_dc_stream_scoreboard"      , this);
    m_dc_stream_scoreboard.m_en_out_of_order_scb = 1;
    m_dc_stream_scoreboard.m_check_expected_present_when_received = 1;
    
    //-- Analysis Ports Creation ----------------------------------------
    ob_np_req_ap            = new("ob_np_req_ap"         , this);
    ob_uio_p_req_ap         = new("ob_uio_p_req_ap"      , this);
    ob_compl_req_ap         = new("ob_compl_req_ap"      , this);
    ob_10bit_compl_req_ap   = new("ob_10bit_compl_req_ap", this);
    ob_14bit_compl_req_ap   = new("ob_14bit_compl_req_ap", this);
    ob_uio_p_compl_req_ap   = new("ob_uio_p_compl_req_ap", this);
    
    ib_np_req_ap            = new("ib_np_req_ap"         , this);
    ib_uio_p_req_ap         = new("ib_uio_p_req_ap"      , this);
    ib_compl_req_ap         = new("ib_compl_req_ap"      , this);
    ib_10bit_compl_req_ap   = new("ib_10bit_compl_req_ap", this);
    ib_14bit_compl_req_ap   = new("ib_14bit_compl_req_ap", this);
    ib_uio_p_compl_req_ap   = new("ib_uio_p_compl_req_ap", this);
    
    foreach(hls_ob_posted_axi_pkt_started_ap[loop_port]) begin
      hls_ob_posted_axi_pkt_started_ap[loop_port] = new($sformatf("hls_ob_posted_axi_pkt_started_ap[%0d]", loop_port), this);
    end
    foreach(hls_ob_posted_axi_pkt_ended_ap[loop_port]) begin
      hls_ob_posted_axi_pkt_ended_ap[loop_port] = new($sformatf("hls_ob_posted_axi_pkt_ended_ap[%0d]", loop_port), this);
    end
    foreach(hls_ob_nonposted_axi_pkt_started_ap[loop_port]) begin
      hls_ob_nonposted_axi_pkt_started_ap[loop_port] = new($sformatf("hls_ob_nonposted_axi_pkt_started_ap[%0d]", loop_port), this);
    end
    foreach(hls_ob_nonposted_axi_pkt_ended_ap[loop_port]) begin
      hls_ob_nonposted_axi_pkt_ended_ap[loop_port] = new($sformatf("hls_ob_nonposted_axi_pkt_ended_ap[%0d]", loop_port), this);
    end
    foreach(hls_ob_compl_axi_pkt_started_ap[loop_port]) begin
      hls_ob_compl_axi_pkt_started_ap[loop_port] = new($sformatf("hls_ob_compl_axi_pkt_started_ap[%0d]", loop_port), this);
    end
    foreach(hls_ob_compl_axi_pkt_ended_ap[loop_port]) begin
      hls_ob_compl_axi_pkt_ended_ap[loop_port] = new($sformatf("hls_ob_compl_axi_pkt_ended_ap[%0d]", loop_port), this);
    end
    
    hls_ib_posted_port_tr_ap   = new("hls_ib_posted_port_tr_ap", this);
    foreach(axi_ib_posted_pkt_ended_ap[loop_port]) begin
      axi_ib_posted_pkt_ended_ap[loop_port] = new($sformatf("axi_ib_posted_pkt_ended_ap[%0d]", loop_port), this);
    end
    dti_ib_posted_pkt_ended_ap = new("dti_ib_posted_pkt_ended_ap", this);
    msi_ib_posted_pkt_ended_ap = new("msi_ib_posted_pkt_ended_ap", this);
    foreach(axi_delivered_count_pkt_ended_ap[loop_port]) begin
      axi_delivered_count_pkt_ended_ap[loop_port] = new($sformatf("axi_delivered_count_pkt_ended_ap[%0d]", loop_port), this);
    end
    dti_delivered_count_pkt_ended_ap = new("dti_delivered_count_pkt_ended_ap", this);
    
    foreach(lti_ctag_tx_stream_pkt_ended_ap[loop_port]) begin
      lti_ctag_tx_stream_pkt_ended_ap[loop_port] = new($sformatf("lti_ctag_tx_stream_pkt_ended_ap[%0d]", loop_port), this);
    end
    
    foreach(m_hls_ib_posted_axi_tlp_pkt_delivered_ap[loop_port]) begin
      m_hls_ib_posted_axi_tlp_pkt_delivered_ap[loop_port] = new($sformatf("m_hls_ib_posted_axi_tlp_pkt_delivered_ap[%0d]", loop_port), this);
    end

     credit_ob_posted_axi_ap = new("credit_ob_posted_axi_ap", this);
     credit_ob_posted_hal_ap = new("credit_ob_posted_hal_ap", this);

     credit_ob_nonposted_axi_ap = new("credit_ob_nonposted_axi_ap", this);
     credit_ob_nonposted_hal_ap = new("credit_ob_nonposted_hal_ap", this);
     
     
  `ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      hls_ob_posted_dti_pkt_started_ap = hls_ob_posted_axi_pkt_started_ap [parameters_cfg_pkg::NUM_HLS_PORTS];
      hls_ob_posted_dti_pkt_ended_ap   = hls_ob_posted_axi_pkt_ended_ap   [parameters_cfg_pkg::NUM_HLS_PORTS];
      hls_ob_compl_dti_pkt_started_ap  = hls_ob_compl_axi_pkt_started_ap  [parameters_cfg_pkg::NUM_HLS_PORTS];
      hls_ob_compl_dti_pkt_ended_ap    = hls_ob_compl_axi_pkt_ended_ap    [parameters_cfg_pkg::NUM_HLS_PORTS];
      hls_ob_posted_hal_pkt_inv_ap     = new("hls_ob_posted_hal_pkt_inv_ap", this);
    end
  `endif

    // QOS analysis ports
    m_hls_ib_posted_qos_ap    = new[parameters_cfg_pkg::NUM_HLS_PORTS];
    m_hls_ib_nonposted_qos_ap = new[parameters_cfg_pkg::NUM_HLS_PORTS];
    m_hls_ib_compl_qos_ap     = new[parameters_cfg_pkg::NUM_HLS_PORTS];
    foreach (m_hls_ib_posted_qos_ap[i]) begin
      m_hls_ib_posted_qos_ap[i]    = new($sformatf("m_hls_ib_posted_qos_ap[%0d]",    i), this);
      m_hls_ib_nonposted_qos_ap[i] = new($sformatf("m_hls_ib_nonposted_qos_ap[%0d]", i), this);
      m_hls_ib_compl_qos_ap[i]     = new($sformatf("m_hls_ib_compl_qos_ap[%0d]",     i), this);
    end
    
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Function: end_of_elaboration_phase
  //----------------------------------------------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase

  //----------------------------------------------------------------------------
  // Task: main_phase
  //----------------------------------------------------------------------------
  virtual task main_phase(uvm_phase phase);
    string l_msg_id = {"[", get_type_name(), "]", "[main_phase]"};
    super.main_phase(phase);
    
    `uvm_info(l_msg_id, "Starting HLS Bridge Monitor Main Phase...", UVM_LOW);
    
    fork
      cover_if(.msg_id(l_msg_id)); 
      cover_parameters();
      cover_hls_port_data_width_arr();
      cover_hls_port_tlps_per_clk_arr();
      process_hls_ob_posted_hal_pkt_ended(.msg_id(l_msg_id));
      process_hls_ob_nonposted_hal_pkt_ended(.msg_id(l_msg_id));
      process_hls_ob_compl_hal_pkt_ended(.msg_id(l_msg_id));
      process_hls_ib_posted_hal_pkt_ended(.msg_id(l_msg_id));
      process_hls_ib_nonposted_hal_pkt_ended(.msg_id(l_msg_id));
      process_hls_ib_compl_hal_pkt_ended(.msg_id(l_msg_id));
      process_hdr2log_slv_ended(.msg_id(l_msg_id));
      process_lti_ctag_rx_ended(.msg_id(l_msg_id));      
      process_axis_msi_slv_ended(.msg_id(l_msg_id));
      process_dc_slv_ended(.msg_id(l_msg_id));
      process_axi_mst_pkt_ended(.msg_id(l_msg_id));
      process_axi_slv_pkt_ended(.msg_id(l_msg_id));
      send_predicted_hls_ob_posted_axi_pkt(.msg_id(l_msg_id));
      send_predicted_hls_ob_nonposted_axi_pkt(.msg_id(l_msg_id));
      send_predicted_hls_ob_compl_axi_pkt(.msg_id(l_msg_id));
      send_predicted_lti_ctag_tx_pkt(.msg_id(l_msg_id));
      process_set_posted_crd_lmt_initial_values();
      process_set_nonposted_crd_lmt_initial_values();
      posted_crd_lmt_prediction(l_msg_id);
      nonposted_crd_lmt_prediction(l_msg_id);
      cover_backpressure_scenario(m_env_cfg.en_backpressure_ib, m_env_cfg.en_backpressure_ob);
      if(m_env_cfg.m_qos_support) 
      	process_tlp_qos_tx(.msg_id(l_msg_id)); 

`ifdef DTI_TB_IN_PASSIVE_MODE
      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT)
        process_hls_ib_nonposted_dti_pkt_ended(.msg_id(l_msg_id));

      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT)
        process_hls_ib_posted_dti_pkt_ended(.msg_id(l_msg_id));

      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT)
        process_hls_ob_compl_dti_pkt_started(.msg_id(l_msg_id));

      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT)
        process_hls_ob_compl_dti_pkt_ended(.msg_id(l_msg_id));

      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT)
        process_hls_ob_posted_dti_pkt_started(.msg_id(l_msg_id));

      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT)
        process_hls_ob_posted_dti_pkt_ended(.msg_id(l_msg_id));

      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT)
        process_hdr2log_dti_ended(.msg_id(l_msg_id));
      
      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT)
        process_dc_dti_ended(.msg_id(l_msg_id));
`endif

      for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
        automatic int unsigned l_hls_port = loop_port;
        fork
          process_hls_ob_posted_axi_pkt_started(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hls_ob_posted_axi_pkt_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hls_ob_nonposted_axi_pkt_started(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hls_ob_nonposted_axi_pkt_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hls_ob_compl_axi_pkt_started(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hls_ob_compl_axi_pkt_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hls_ib_posted_axi_pkt_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hls_ib_nonposted_axi_pkt_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hls_ib_compl_axi_pkt_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hdr2log_mst_started(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_hdr2log_mst_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));
          process_lti_ctag_tx_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));          
          process_dc_mst_ended(.msg_id(l_msg_id), .hls_port_num(l_hls_port));	    
        join_none
      end
    join
    
    `uvm_info(l_msg_id, "Ending HLS Bridge Monitor Main Phase...", UVM_LOW);
  endtask : main_phase

  //----------------------------------------------------------------------------
  // Function: check_phase
  //----------------------------------------------------------------------------
  virtual function void check_phase(uvm_phase phase);
    string l_msg_id = {"[", get_type_name(), "]", "[check_phase]"};
    
    super.check_phase(phase);
   
    foreach(m_total_expected_lti_count[loop_ctag, loop_lti_port]) begin
      if(m_total_expected_lti_count[loop_ctag][loop_lti_port] != m_total_received_lti_count[loop_ctag][loop_lti_port]) begin
        `uvm_error({l_msg_id, "[LTI_COUNT_CHECK_ERROR]"}, $sformatf("Total Number of Expected LTI Count doesn't match the Received LTI Count for CTag: %0d PortID: %0d. Expected Count: %0d Received Count: %0d", loop_ctag, loop_lti_port, m_total_expected_lti_count[loop_ctag][loop_lti_port], m_total_received_lti_count[loop_ctag][loop_lti_port]));
      end
    end

    foreach (m_total_expected_delivered_count[stream]) begin
      if(m_total_expected_delivered_count[stream] != m_total_received_delivered_count[stream]) begin
        `uvm_error({l_msg_id, "[DELIVERED_COUNT_CHECK_ERROR]"}, $sformatf("Total Number of Expected Delivered Count doesn't match the Received Delivered Count on stream %0d. Expected Count: %0d Received Count: %0d", stream, m_total_expected_delivered_count[stream], m_total_received_delivered_count[stream]));
      end
    end

    if(m_env_cfg.m_qos_support) begin 
       foreach (m_qos_expected_count[g]) begin
          if(m_qos_expected_count[g] == 0) continue;
             if(m_qos_observed_count[g] == 0)
               `uvm_error({l_msg_id, "[QOS_TX_NEVER_FIRED]"}, $sformatf("group=%0d expected=0x%0h DUT TX never fired",g, m_qos_expected_count[g]))
	     else if(m_qos_observed_count[g] != m_qos_expected_count[g])
 		 `uvm_error({l_msg_id, "[QOS_COUNT_CHECK_ERROR]"},$sformatf("group=%0d expected=0x%0h observed=0x%0h",g, m_qos_expected_count[g], m_qos_observed_count[g])) 
   	 end
    end
      
  endfunction : check_phase

  //----------------------------------------------------------------------------
  // Task: process_set_posted_crd_lmt_initial_values
  //----------------------------------------------------------------------------
   virtual task process_set_posted_crd_lmt_initial_values();     
      //Remembers the initial crd_s_lmt values	       
      for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
   bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] credits_header;
   bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] credits_payload;
   
   do begin	      
      m_env_cfg.m_crd_lmt_posted_if_api.get_crd_s_lmt_header(vc, credits_header);
      m_env_cfg.m_crd_lmt_posted_if_api.get_crd_s_lmt_payload(vc, credits_payload);
      
      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
   end
   while(credits_header == 0 && credits_payload == 0);
   
   m_env_cfg.initial_crd_lmt_posted_header[vc] = credits_header;
   m_env_cfg.initial_crd_lmt_posted_payload[vc] = credits_payload;
      end        
   endtask : process_set_posted_crd_lmt_initial_values
   
  //----------------------------------------------------------------------------
  // Task: process_set_nonposted_crd_lmt_initial_values
  //----------------------------------------------------------------------------
   virtual task process_set_nonposted_crd_lmt_initial_values();     
      //Remembers the initial crd_s_lmt values	       
      for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
   bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] credits_header;
   bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] credits_payload;
   
   do begin	      
      m_env_cfg.m_crd_lmt_nonposted_if_api.get_crd_s_lmt_header(vc, credits_header);
      m_env_cfg.m_crd_lmt_nonposted_if_api.get_crd_s_lmt_payload(vc, credits_payload);
      
      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
   end
   while(credits_header == 0 && credits_payload == 0);
   
   m_env_cfg.initial_crd_lmt_nonposted_header[vc] = credits_header;
   m_env_cfg.initial_crd_lmt_nonposted_payload[vc] = credits_payload;
      end        
   endtask : process_set_nonposted_crd_lmt_initial_values
   
  //----------------------------------------------------------------------------
  // Task: posted_crd_lmt_prediction
  //----------------------------------------------------------------------------
  virtual task posted_crd_lmt_prediction(string msg_id = "");      
    string l_msg_id = {msg_id, "[posted_crd_lmt_prediction]"};

    bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] new_credits_header;
    bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] new_credits_payload;
    bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] new_credits_used_header;
    bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] new_credits_used_payload;
    
    //crd_used_wait = 1 - current tlp is still not decremented by crd_used signals
    //crd_used_wait = 0 - new crd_used signals are stored in the queue
    integer crd_used_wait_h [parameters_cfg_pkg::KMAX_NUM_VCS-1:0];
    integer crd_used_wait_p [parameters_cfg_pkg::KMAX_NUM_VCS-1:0];

    //repeating_* = 1 - the first element in the tlp queue has already been read. If a new crd_m_lmt signal comes, the old one should be popped out.
    //repeating_*_crd = 1 - the first element in the tlp queue has already been read and a crd_used signal has been deducted after the reading. (if swapped should return the credit)
    integer repeating_h;
    integer repeating_p;
    integer repeating_h_crd;
    integer repeating_p_crd;

    bit l_reset_in_progress;

    fork begin  : header_credits   
      forever begin

        //Whenever the crd_s_lmt values change, compare them with values stored in the queue
        for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
          m_env_cfg.m_crd_lmt_posted_if_api.get_crd_s_lmt_header(vc, new_credits_header);	  

          if(current_s_credits_p_header[vc] != new_credits_header && /*new_credits_header != 0 &&*/ !l_reset_in_progress && crd_m_p_header_q[vc].size() > 0) begin		 
            bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] header_prediction;
            header_prediction = crd_m_p_header_q[vc].pop_front();

            if(repeating_h[vc] == 0 && crd_used_wait_h[vc] == 0 && header_prediction == current_s_credits_p_header[vc]) begin
              header_prediction--;
              repeating_h_crd[vc] = 1;
            end

            if (repeating_h_crd[vc] == 1 && new_credits_header != header_prediction) begin		     
              header_prediction--;
            end

            if(repeating_h[vc] && crd_used_wait_h[vc] && crd_used_p_header_q[vc].size() > 0 && new_credits_header != header_prediction) begin 
              header_prediction -= crd_used_p_header_q[vc].pop_front();
              repeating_h_crd[vc] = 1;
              if(new_credits_header != header_prediction) crd_used_p_header_q[vc].push_front(1);		   	  
            end

            if(repeating_h[vc] && crd_used_wait_h[vc] == 0) repeating_h_crd[vc] = 1;
            if(new_credits_header != header_prediction) repeating_h_crd[vc] = 0;		  
            if(crd_used_wait_h[vc] == 0) crd_used_p_header_q[vc].push_front(1);

            while(new_credits_header != header_prediction && crd_m_p_header_q[vc].size() > 0) begin
              header_prediction = crd_m_p_header_q[vc].pop_front();

              if(crd_used_p_header_q[vc].size() > 0 && new_credits_header != header_prediction) begin
                header_prediction -= crd_used_p_header_q[vc].pop_front();
                if(new_credits_header != header_prediction) crd_used_p_header_q[vc].push_front(1);
              end
            end

            if(crd_used_p_header_q[vc].size() > 0 && new_credits_header != header_prediction) begin
              header_prediction -= crd_used_p_header_q[vc].pop_front();
              if(new_credits_header != header_prediction) crd_used_p_header_q[vc].push_front(1);		   		     
            end

            if(new_credits_header != header_prediction) begin
              header_prediction = current_m_credits_p_header[vc];

              if(crd_used_wait_h[vc] && new_credits_header != header_prediction) begin
                header_prediction = header_prediction - 1;
              end
            end

            if(new_credits_header != header_prediction)
              `uvm_error({l_msg_id, "[POSTED CREDIT LMT CHECK]"}, $sformatf("POSTED CREDIT PREDICTION MISMATCH ON VC %0d, expected header: %0h, current header: %0h;", vc, header_prediction, new_credits_header))

            crd_m_p_header_q[vc].push_front(header_prediction);

            repeating_h[vc] = 1;
            if(crd_used_wait_h[vc] == 0 || crd_used_p_header_q[vc].size() > 0) repeating_h_crd[vc] = 1;

            crd_used_wait_h[vc] = 1;
            current_s_credits_p_header[vc] = new_credits_header;
          end 
        end

        if (parameters_cfg_pkg::KMAX_DTI_SUPPORT == 0)
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));

        //Subtracts the crd_used signals from the values in the queues (extra crd_used signals are stored in a queue for future TLPs)
        for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin		  
          m_env_cfg.m_crd_lmt_posted_if_api.get_crd_used_header(vc, new_credits_used_header);
          
          if(new_credits_used_header > 0 && !l_reset_in_progress) begin
            if (crd_used_wait_h[vc] == 1) begin
              new_credits_header = crd_m_p_header_q[vc].pop_front() - new_credits_used_header;
                
              crd_m_p_header_q[vc].push_front(new_credits_header);
              crd_used_wait_h[vc] = 0;		  
            end
            else begin
              crd_used_p_header_q[vc].push_back(new_credits_used_header);		 
            end
          end	    
        end
        
        //Stores new crd_m_lmt values in queues
        for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
          m_env_cfg.m_crd_lmt_posted_if_api.get_crd_m_lmt_header(vc, new_credits_header);
        
          if(current_m_credits_p_header[vc] != new_credits_header/* && new_credits_header != 0*/ && !l_reset_in_progress) begin
            current_m_credits_p_header[vc] = new_credits_header;

            if(repeating_h[vc]) begin
              void'(crd_m_p_header_q[vc].pop_front());
              if(crd_used_wait_h[vc] == 0) crd_used_p_header_q[vc].push_front(1);		  
            end
          
            if(crd_used_p_header_q[vc].size() > 0) begin
              new_credits_header -= crd_used_p_header_q[vc].pop_front();		  
              crd_used_wait_h[vc] = 0;
            end
            else if(crd_m_p_header_q[vc].size() == 0) begin		 
              crd_used_wait_h[vc] = 1;
            end		  
          
            crd_m_p_header_q[vc].push_back(new_credits_header);
            repeating_h_crd[vc] = 0;		  
            repeating_h[vc] = 0;
          end 		   
        end

        if (parameters_cfg_pkg::KMAX_DTI_SUPPORT == 1)
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
      end
    end : header_credits
   begin : payload_credits
    forever begin

      //Whenever the crd_s_lmt values change, compare them with values stored in the queue
      for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
        m_env_cfg.m_crd_lmt_posted_if_api.get_crd_s_lmt_payload(vc, new_credits_payload); 
        if(current_s_credits_p_payload[vc] != new_credits_payload/* && new_credits_payload != 0*/ && !l_reset_in_progress && crd_m_p_payload_q[vc].size() > 0) begin		 
          bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] payload_prediction;
          payload_prediction = crd_m_p_payload_q[vc].pop_front();

          if(repeating_p[vc] == 0 && crd_used_wait_p[vc] == 0 && payload_prediction == current_s_credits_p_payload[vc]) begin
            payload_prediction--;
            repeating_p_crd[vc] = 1;
          end

          if (repeating_p_crd[vc] == 1 && new_credits_payload != payload_prediction) payload_prediction--;

          if(repeating_p[vc] && crd_used_wait_p[vc] && crd_used_p_payload_q[vc].size() > 0 && new_credits_payload != payload_prediction) begin 
            payload_prediction -= crd_used_p_payload_q[vc].pop_front();
            repeating_p_crd[vc] = 1;
            if(new_credits_payload != payload_prediction) crd_used_p_payload_q[vc].push_front(1);		  
          end

          if(repeating_p[vc] && crd_used_wait_p[vc] == 0) repeating_p_crd[vc] = 1;
          if(new_credits_payload != payload_prediction) repeating_p_crd[vc] = 0;		  
          if(crd_used_wait_p[vc] == 0) crd_used_p_payload_q[vc].push_front(1);
      
          while(new_credits_payload != payload_prediction && crd_m_p_payload_q[vc].size() > 0) begin
            payload_prediction = crd_m_p_payload_q[vc].pop_front();
            if(crd_used_p_payload_q[vc].size() > 0 && new_credits_payload != payload_prediction) begin
              payload_prediction -= crd_used_p_payload_q[vc].pop_front();
              if(new_credits_payload != payload_prediction) crd_used_p_payload_q[vc].push_front(1);
            end
          end

          if(crd_used_p_payload_q[vc].size() > 0 && new_credits_payload != payload_prediction) begin
            payload_prediction -= crd_used_p_payload_q[vc].pop_front();
            if(new_credits_payload != payload_prediction) crd_used_p_payload_q[vc].push_front(1);		     		     
          end

          if(new_credits_payload != payload_prediction) begin
            payload_prediction = current_m_credits_p_payload[vc];		     
            if(crd_used_wait_p[vc] && new_credits_payload != payload_prediction) payload_prediction = payload_prediction - 1;		     		     
          end

          if(new_credits_payload != payload_prediction)
            `uvm_error({l_msg_id, "[POSTED CREDIT LMT CHECK]"}, $sformatf("POSTED CREDIT PREDICTION MISMATCH ON VC %0d, expected payload: %0h, current payload: %0h;", vc, payload_prediction, new_credits_payload))

          crd_m_p_payload_q[vc].push_front(payload_prediction);		
          repeating_p[vc] = 1;
          if(crd_used_wait_p[vc] == 0 || crd_used_p_payload_q[vc].size > 0) repeating_p_crd[vc] = 1;

          crd_used_wait_p[vc] = 1;
          current_s_credits_p_payload[vc] = new_credits_payload;
        end 
      end

      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT == 0)
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));

      //Subtracts the crd_used signals from the values in the queues (extra crd_used signals are stored in a queue for future TLPs)
      for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin		  
        m_env_cfg.m_crd_lmt_posted_if_api.get_crd_used_payload(vc, new_credits_used_payload);
         
        if(new_credits_used_payload > 0 && !l_reset_in_progress) begin
          if (crd_used_wait_p[vc] == 1) begin
            new_credits_payload = crd_m_p_payload_q[vc].pop_front() - new_credits_used_payload;
        
            crd_m_p_payload_q[vc].push_front(new_credits_payload);
            crd_used_wait_p[vc] = 0;		  
          end
          else begin
            crd_used_p_payload_q[vc].push_back(new_credits_used_payload);
          end
        end	    
      end

      //Stores new crd_m_lmt values in queues
      for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
        m_env_cfg.m_crd_lmt_posted_if_api.get_crd_m_lmt_payload(vc, new_credits_payload);
       
        if(current_m_credits_p_payload[vc] != new_credits_payload/* && new_credits_payload != 0*/ && !l_reset_in_progress) begin
          current_m_credits_p_payload[vc] = new_credits_payload;

          if (repeating_p[vc]) begin
            void'(crd_m_p_payload_q[vc].pop_front());
            if(crd_used_wait_p[vc] == 0) crd_used_p_payload_q[vc].push_front(1);	
          end
      
          if(crd_used_p_payload_q[vc].size() > 0) begin
            new_credits_payload -= crd_used_p_payload_q[vc].pop_front();		
            crd_used_wait_p[vc] = 0;
          end
          else if(crd_m_p_payload_q[vc].size() == 0) begin		  
            crd_used_wait_p[vc] = 1;
          end		  
      
          crd_m_p_payload_q[vc].push_back(new_credits_payload);
          repeating_p_crd[vc] = 0;		  
          repeating_p[vc] = 0;
        end
      end

      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT == 1)
        m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
    end 
    end : payload_credits
    begin
      forever begin
        m_env_cfg.m_crd_lmt_posted_if_api.wait_rst_act();
        l_reset_in_progress = 1;
        m_env_cfg.m_crd_lmt_posted_if_api.wait_rst_dis();
        l_reset_in_progress = 0;
      end
    end
    join_none  
  endtask : posted_crd_lmt_prediction
   
  //----------------------------------------------------------------------------
  // Task: nonposted_crd_lmt_prediction
  //----------------------------------------------------------------------------  
  virtual task nonposted_crd_lmt_prediction(string msg_id = "");      
    string l_msg_id = {msg_id, "[nonposted_crd_lmt_prediction]"};

    bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] 	new_credits_header;
    bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] new_credits_payload;

    bit l_reset_in_progress;
     
    fork begin
      forever begin
        //Stores new crd_m_lmt values in queues
        for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
          m_env_cfg.m_crd_lmt_nonposted_if_api.get_crd_m_lmt_header(vc, new_credits_header);

          if(current_m_credits_np_header[vc] != new_credits_header && !l_reset_in_progress) begin
            current_m_credits_np_header[vc] = new_credits_header;	       
            crd_m_np_header_q[vc].push_back(new_credits_header);
          end 		   
        end	 	 
        
        //Whenever the crd_s_lmt values change, compare them with values stored in the queue
        for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin		  
          m_env_cfg.m_crd_lmt_nonposted_if_api.get_crd_s_lmt_header(vc, new_credits_header);

          if (!l_reset_in_progress) begin
            if(current_s_credits_np_header[vc] != new_credits_header) begin
              bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] header_prediction = crd_m_np_header_q[vc].pop_front();
          
              if(new_credits_header != header_prediction) 
                `uvm_error({l_msg_id, "[NONPOSTED CREDIT LMT CHECK]"}, $sformatf("NONPOSTED CREDIT PREDICTION MISMATCH ON VC %0d, expected header: %0h, current header: %0h", vc, header_prediction, new_credits_header))	      
            end 
            current_s_credits_np_header[vc] = new_credits_header;
          end
        end	 
        m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
      end 
    end // fork begin
    begin
      forever begin
        //Stores new crd_m_lmt values in queues
        for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
          m_env_cfg.m_crd_lmt_nonposted_if_api.get_crd_m_lmt_payload(vc, new_credits_payload);
      
          if(current_m_credits_np_payload[vc] != new_credits_payload && !l_reset_in_progress) begin
            current_m_credits_np_payload[vc] = new_credits_payload;	       
          
            crd_m_np_payload_q[vc].push_back(new_credits_payload);
          end 		   
        end
         
        //Whenever the crd_s_lmt values change, compare them with values stored in the queue
        for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin		  
          m_env_cfg.m_crd_lmt_nonposted_if_api.get_crd_s_lmt_payload(vc, new_credits_payload);

          if (!l_reset_in_progress) begin
            if(current_s_credits_np_payload[vc] != new_credits_payload) begin
              bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] payload_prediction = crd_m_np_payload_q[vc].pop_front();
            
              if(new_credits_payload != payload_prediction) 
                `uvm_error({l_msg_id, "[NONPOSTED CREDIT LMT CHECK]"}, $sformatf("NONPOSTED CREDIT PREDICTION MISMATCH ON VC %0d, expected payload: %0h, current payload: %0h", vc, payload_prediction, new_credits_payload))     
            end 
            current_s_credits_np_payload[vc] = new_credits_payload;
          end
        end
        m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
      end 
    end
    begin
      forever begin
        m_env_cfg.m_crd_lmt_nonposted_if_api.wait_rst_act();
        l_reset_in_progress = 1;
        m_env_cfg.m_crd_lmt_nonposted_if_api.wait_rst_dis();
        l_reset_in_progress = 0;
      end
    end
    join_none
   endtask : nonposted_crd_lmt_prediction


// Per-tag state held in simple associative arrays
    bit [11:0] last_lower_addr_map [bit[13:0]];  // tag -> last lower_addr
    int        cpl_seen_map        [bit[13:0]];  // tag -> completions seen count
//==========================================================================
// Task for tracking OB UIO split completions
//==========================================================================
virtual task track_split_ob_completion(cdn_hpa_pcie_tlp tlp_pkt);

  bit [13:0] current_tag;
  bit [11:0] current_lower_addr;
  int        curr_len_dw;

  bit is_uio_rdcpld;
  bit is_uio_rdcpl;
  bit is_uio_wrcpl;

  bit meta_is_split;
  bit meta_is_random_order;

  // Extract fields
  current_tag        = tlp_pkt.m_tlp_tag;
  current_lower_addr = tlp_pkt.m_tlp_cpl_lower_addr;
  curr_len_dw        = tlp_pkt.m_tlp_length;

  // Type decode
  is_uio_rdcpld = (tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD);
  is_uio_rdcpl  = (tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCpl);
  is_uio_wrcpl  = (tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl);

  // First fragment for this tag
  if (!cpl_seen_map.exists(current_tag)) begin
    cpl_seen_map[current_tag]        = 0;
    last_lower_addr_map[current_tag] = current_lower_addr;
  end

  // To check whether split is happening or not 
   meta_is_split = (cpl_seen_map[current_tag] > 0);

  meta_is_random_order = 1'b0;
  if (meta_is_split) begin
    if (current_lower_addr < last_lower_addr_map[current_tag])
      meta_is_random_order = 1'b1;
  end
  

   //- Calling Coverage callbacks -------------------------------------------

  if (meta_is_split && meta_is_random_order) begin
    if (is_uio_rdcpl)
    cover_ob_uio_rdcpl_split_random_order  ();
    else if (is_uio_rdcpld)
      cover_ob_uio_rdcpld_split_random_order();
    else if (is_uio_wrcpl)
      cover_ob_uio_wrcpl_split_random_order();
  end

  // Update state
  last_lower_addr_map[current_tag] = current_lower_addr;
  cpl_seen_map[current_tag]++;

endtask
//==========================================================================
// Task for tracking IB UIO split completions
//==========================================================================

virtual task track_split_ib_completion(cdn_hpa_pcie_tlp tlp_pkt);

  bit [13:0] current_tag;
  bit [11:0] current_lower_addr;
  int        curr_len_dw;

  bit is_uio_rdcpld;
  bit is_uio_rdcpl;
  bit is_uio_wrcpl;

  bit meta_is_split;
  bit meta_is_random_order;

  // Extract fields
  current_tag        = tlp_pkt.m_tlp_tag;
  current_lower_addr = tlp_pkt.m_tlp_cpl_lower_addr;
  curr_len_dw        = tlp_pkt.m_tlp_length;

  // Type decode
  is_uio_rdcpld = (tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD);
  is_uio_rdcpl  = (tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCpl);
  is_uio_wrcpl  = (tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl);

  // First fragment for this tag
  if (!cpl_seen_map.exists(current_tag)) begin
    cpl_seen_map[current_tag]        = 0;
    last_lower_addr_map[current_tag] = current_lower_addr;
  end

// To check whether split is happening or not 
   meta_is_split = (cpl_seen_map[current_tag] > 0);

  meta_is_random_order = 1'b0;
  if (meta_is_split) begin
    if (current_lower_addr < last_lower_addr_map[current_tag])
      meta_is_random_order = 1'b1;
  end
  

 //- Calling Coverage callbacks -------------------------------------------
 
  if (meta_is_split && meta_is_random_order) begin
    if (is_uio_rdcpl)
      cover_ib_uio_rdcpl_split_random_order();
    else if (is_uio_rdcpld)
      cover_ib_uio_rdcpld_split_random_order();
    else if (is_uio_wrcpl)
      cover_ib_uio_wrcpl_split_random_order();
  end

  // Update state
  last_lower_addr_map[current_tag] = current_lower_addr;
  cpl_seen_map[current_tag]++;

endtask

//==========================================================================
// Classify Inbound Packet Type
//==========================================================================
function int classify_ib_packet(
  cdn_hpa_pcie_tlp tlp_pkt, 
  cdn_pcie_hls_bridge_inbound_route_to_e route_to
);
    bit [1:0]  l_strap_port_type;

  m_env_cfg.m_k_if_api.get_strap_port_type(l_strap_port_type); 

   // DTI packets
          if(route_to == ROUTE_TO_DTI)
    return 0;
 
  // MSI packets
 if (tlp_pkt.m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) begin
    if (parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 1 && 
        l_strap_port_type == 2'b01 && 
        tlp_pkt.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32, CDN_HPA_PCIE_TLP_TYPE_MWr_64} &&
        tlp_pkt.hls_ib_p_np_meta_s.hls_bridge_pkt_route_info == 2'b10 &&
        route_to == ROUTE_TO_MSI) begin
      return 1;
    end
  end 
     
  // UIO packets
  if (route_to == ROUTE_TO_AXI) begin
    if (tlp_pkt.m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) return 2; // UIO_NONPOSTED
    if (tlp_pkt.m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) return 3;     // UIO_POSTED
  end
  
  return -1; // Unknown
endfunction

//==========================================================================
// Track Packet Sequence
//==========================================================================
virtual function void track_ib_packet_sequence(
  cdn_hpa_pcie_tlp                       tlp_pkt,
  cdn_pcie_hls_bridge_inbound_route_to_e route_to,
  string                                 pkt_direction
);
  
  // Classify current packet
  curr_pkt_type = classify_ib_packet(tlp_pkt, route_to);
  
  // Coverage sampling (skip first packet)
  if (!first_pkt) begin
    cover_ib_packet_ordering();
  end
// Track consecutive UIO POSTED packets
if (curr_pkt_type == 3) begin
  uio_posted_streak++;
end else begin
  uio_posted_streak = 0;
end

// Detect DTI immediately after multiple UIO POSTED
if (uio_posted_streak >= 2 && curr_pkt_type == 0) begin
  saw_dti_after_2_uio_posted = 1;
end
  
  // Update state for next packet
  prev2_pkt_type = prev_pkt_type;
  prev_pkt_type = curr_pkt_type;
  prev_was_uio_np = (curr_pkt_type == 2);
  first_pkt = 0;
endfunction

//==========================================================================
// Coverage Function - All DTI Scenarios
//==========================================================================
virtual function void cover_ib_packet_ordering();
  bit curr_is_dti = (curr_pkt_type == 0);
  bit l_any_dbg_dis_order_chk;
  
  //1) DTI after UIO non-posted (always active, regardless of order checking)
  cover_dti_after_uio_nonposted(curr_is_dti, prev_was_uio_np);
  
  //2) DTI bypass 2-packet scenarios (only when order checking ENABLED)
  if (l_any_dbg_dis_order_chk==0 && prev_pkt_type >= 0) begin
    cover_dti_bypass_2pkt_scenarios(prev_pkt_type, curr_pkt_type);
  end
  // 3) DTI after multiple posted UIOs
     cover_dti_after_multiple_posted_uio(uio_posted_streak,curr_is_dti);
  
  // 4)To Cover MSI,DTI,UIO in all possible order
  if (prev2_pkt_type >= 0 && prev_pkt_type >= 0) begin
    cover_ib_packet_3seq(prev2_pkt_type, prev_pkt_type, curr_pkt_type);
  end
endfunction
  //----------------------------------------------------------------------------
  // Analysis port methods
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  // Task: process_hls_ob_posted_hal_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_posted_hal_pkt_ended(string msg_id = "");
    string l_msg_id = {msg_id, "[process_hls_ob_posted_hal_pkt_ended]"};
    denaliCxsTransaction hls_ob_posted_hal_cxs_pkt;
    cdn_hpa_pcie_tlp     hls_ob_posted_hal_tlp_pkt;
    bit                  l_link_down_handling_in_progress;
    
    forever begin
      m_hls_ob_posted_hal_pkt_ended_af.get(hls_ob_posted_hal_cxs_pkt);
      m_env_cfg.m_misc_if_api.get_link_down_handling_in_progress(.value(l_link_down_handling_in_progress));
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_posted_hal_cxs_pkt), .str("Received OB Posted"));

      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b1), .cxs_pkt(hls_ob_posted_hal_cxs_pkt), .tlp_pkt(hls_ob_posted_hal_tlp_pkt));
     
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b0), .cxs_pkt(hls_ob_posted_hal_cxs_pkt), .tlp_pkt(hls_ob_posted_hal_tlp_pkt));

      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ob_posted_hal_tlp_pkt), .str("Received OB Posted"));
      
      //- Push packet to scoreboard --------------------------------------------
      m_hls_ob_posted_cxs_scoreboard.write_received_tr(hls_ob_posted_hal_cxs_pkt);

      //- Send packet to vseq for credit calculations 
      credit_ob_posted_hal_ap.write(hls_ob_posted_hal_tlp_pkt);
       
`ifdef DTI_TB_IN_PASSIVE_MODE
      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT && hls_ob_posted_hal_tlp_pkt.m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
        hls_ob_posted_hal_pkt_inv_ap.write(hls_ob_posted_hal_tlp_pkt);
      end

 `ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
      //- Free up PRG index
      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT && hls_ob_posted_hal_tlp_pkt.m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PR_Group_Response) begin
        m_remote_dev_top_config.prg_index_available_q.push_back(hls_ob_posted_hal_tlp_pkt.m_prGroupIndex);
      end
 `endif //  `ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
`endif //  `ifdef DTI_TB_IN_PASSIVE_MODE

      //- Send Received outbound P Req to CIF Router for Compl Generation if linkdown is not in progress -----
      if(hls_ob_posted_hal_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr && l_link_down_handling_in_progress == 0)
        ob_uio_p_req_ap.write(hls_ob_posted_hal_tlp_pkt);

      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ob_hal_metadata(.msg_id(l_msg_id), .fc_type(2'b00), .metadata(hls_ob_posted_hal_tlp_pkt.hls_ob_meta_s));
      cover_hpa_tlp(.msg_id(l_msg_id), .strap_is_rp(m_env_cfg.i_cfg.strap_is_rp), .is_ib_dir(1'b0), .tlp_pkt(hls_ob_posted_hal_tlp_pkt));
    end
  endtask : process_hls_ob_posted_hal_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_nonposted_hal_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_nonposted_hal_pkt_ended(string msg_id = "");
    string l_msg_id = {msg_id, "[process_hls_ob_nonposted_hal_pkt_ended]"};
    denaliCxsTransaction hls_ob_nonposted_hal_cxs_pkt;
    cdn_hpa_pcie_tlp     hls_ob_nonposted_hal_tlp_pkt;
    bit                  l_link_down_handling_in_progress;
    
    forever begin
      m_hls_ob_nonposted_hal_pkt_ended_af.get(hls_ob_nonposted_hal_cxs_pkt);
      m_env_cfg.m_misc_if_api.get_link_down_handling_in_progress(.value(l_link_down_handling_in_progress));
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_nonposted_hal_cxs_pkt), .str("Received OB NonPosted"));
      
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b1), .cxs_pkt(hls_ob_nonposted_hal_cxs_pkt), .tlp_pkt(hls_ob_nonposted_hal_tlp_pkt));
     
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b0), .cxs_pkt(hls_ob_nonposted_hal_cxs_pkt), .tlp_pkt(hls_ob_nonposted_hal_tlp_pkt));
      
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ob_nonposted_hal_tlp_pkt), .str("Received OB NonPosted"));

      //- Push packet to scoreboard --------------------------------------------
      m_hls_ob_nonposted_cxs_scoreboard.write_received_tr(hls_ob_nonposted_hal_cxs_pkt);

      //- Send packet to vseq for credit calculations 
      credit_ob_nonposted_hal_ap.write(hls_ob_nonposted_hal_tlp_pkt);
      
      //- Send Received outbound NP Req to CIF Router for Compl Generation if linkdown is not in progress ----- 
      if(l_link_down_handling_in_progress == 0)
        ob_np_req_ap.write(hls_ob_nonposted_hal_tlp_pkt);
      
      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ob_hal_metadata(.msg_id(l_msg_id), .fc_type(2'b01), .metadata(hls_ob_nonposted_hal_tlp_pkt.hls_ob_meta_s));
      cover_hpa_tlp(.msg_id(l_msg_id), .strap_is_rp(m_env_cfg.i_cfg.strap_is_rp), .is_ib_dir(1'b0), .tlp_pkt(hls_ob_nonposted_hal_tlp_pkt));
    end
  endtask : process_hls_ob_nonposted_hal_pkt_ended
  //----------------------------------------------------------------------------
  // Task: process_hls_ob_compl_hal_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_compl_hal_pkt_ended(string msg_id = "");
    string l_msg_id = {msg_id, "[process_hls_ob_compl_hal_pkt_ended]"};
    denaliCxsTransaction hls_ob_compl_hal_cxs_pkt;
    cdn_hpa_pcie_tlp     hls_ob_compl_hal_tlp_pkt;
    
    forever begin
      m_hls_ob_compl_hal_pkt_ended_af.get(hls_ob_compl_hal_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_compl_hal_cxs_pkt), .str("Received OB Completion"));
      
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b1), .cxs_pkt(hls_ob_compl_hal_cxs_pkt), .tlp_pkt(hls_ob_compl_hal_tlp_pkt));
      
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b0), .cxs_pkt(hls_ob_compl_hal_cxs_pkt), .tlp_pkt(hls_ob_compl_hal_tlp_pkt));
      
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ob_compl_hal_tlp_pkt), .str("Received OB Completion"));

      //- Push packet to scoreboard --------------------------------------------
      m_hls_ob_compl_cxs_scoreboard.write_received_tr(hls_ob_compl_hal_cxs_pkt);
      
    //calling the split_completion task based on hls_ob_compl_hal_tlp_pkt

      if (hls_ob_compl_hal_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl ||
          hls_ob_compl_hal_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCpl ||
          hls_ob_compl_hal_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD) 
      begin
           track_split_ob_completion(hls_ob_compl_hal_tlp_pkt);
      end 

      //- Send Received Outbound Compl to Tag Manager to release the tag ------- 
      if(hls_ob_compl_hal_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl) begin
        ob_uio_p_compl_req_ap.write(hls_ob_compl_hal_tlp_pkt);
      end
      else begin
        if(hls_ob_compl_hal_tlp_pkt.m_tlp_14_bit_tagscale) begin
          ob_14bit_compl_req_ap.write(hls_ob_compl_hal_tlp_pkt);
        end
        else if(hls_ob_compl_hal_tlp_pkt.m_tlp_tagscale) begin
          ob_10bit_compl_req_ap.write(hls_ob_compl_hal_tlp_pkt);
        end
        else begin
          ob_compl_req_ap.write(hls_ob_compl_hal_tlp_pkt);
        end
      end
      
      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ob_hal_metadata(.msg_id(l_msg_id), .fc_type(2'b10), .metadata(hls_ob_compl_hal_tlp_pkt.hls_ob_meta_s));
      cover_hpa_tlp(.msg_id(l_msg_id), .strap_is_rp(m_env_cfg.i_cfg.strap_is_rp), .is_ib_dir(1'b0), .tlp_pkt(hls_ob_compl_hal_tlp_pkt));
    end
  endtask : process_hls_ob_compl_hal_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_hls_ib_posted_hal_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ib_posted_hal_pkt_ended(string msg_id = "");
    string                                 l_msg_id = {msg_id, "[process_hls_ib_posted_hal_pkt_ended]"} ;
    denaliCxsTransaction                   hls_ib_posted_hal_cxs_pkt                                    ;
    cdn_hpa_pcie_tlp                       hls_ib_posted_hal_tlp_pkt                                    ;
    denaliStreamTransaction                hls_ib_posted_hal_msi_stream_pkt                             ;
    cdn_pcie_hls_bridge_inbound_route_to_e l_route_to                                                   ;
    int                                    l_hls_port_num                                               ;
    denaliStreamTransaction                msi_lti_c_stream_pkt;
    denaliStreamTransaction                msi_dc_stream_pkt;
    bit                                    l_any_dbg_dis_order_chk;
    int                                    l_stream;
    
    forever begin
      m_hls_ib_posted_hal_pkt_ended_af.get(hls_ib_posted_hal_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ib_posted_hal_cxs_pkt), .str("Expected IB Posted"));
      
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b0), .cxs_pkt(hls_ib_posted_hal_cxs_pkt), .tlp_pkt(hls_ib_posted_hal_tlp_pkt));
      
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b1), .cxs_pkt(hls_ib_posted_hal_cxs_pkt), .tlp_pkt(hls_ib_posted_hal_tlp_pkt));
           
      //- Repacking TX To RX --------------------------------------------------- 
      repack_cxs_tx2rx(.msg_id(l_msg_id), .cxs_pkt(hls_ib_posted_hal_cxs_pkt));
     
       
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ib_posted_hal_tlp_pkt), .str("Expected IB Posted"));
      
      //- Predict where the inbound pkt should be routed to. -------------------
      predict_ib_pkt_routing(.msg_id(l_msg_id), .tlp_pkt(hls_ib_posted_hal_tlp_pkt), .route_to(l_route_to), .hls_port_num(l_hls_port_num));

      //- Push packet to scoreboard --------------------------------------------
      if(l_route_to == ROUTE_TO_MSI) begin

        //-- Check if any order checking disabled ----------------------------------
        l_any_dbg_dis_order_chk = hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value() || hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value() || hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_msi.get_mirrored_value();

        //-- Convert TLP to AXI Stream Pkt -------------------------------------
        convert_tlp2msistream(.msg_id(l_msg_id), .tlp_pkt(hls_ib_posted_hal_tlp_pkt), .msi_stream_pkt(hls_ib_posted_hal_msi_stream_pkt));
        
        print_axi_stream(.msg_id(l_msg_id), .stream_pkt(hls_ib_posted_hal_msi_stream_pkt), .str("Expected MSI"));

        m_msi_stream_scoreboard.write_expected_tr(hls_ib_posted_hal_msi_stream_pkt);

        //-- Generate Delivered Count pkt for MSI -----------------------
        //-- Once MSI is delivered on AXIS MSI Interface the design generates a delivered count with count = 1 --
        generate_msi_dc(.msi_stream_pkt(hls_ib_posted_hal_msi_stream_pkt), .msi_dc_stream_pkt(msi_dc_stream_pkt), .idgroup(hls_ib_posted_hal_tlp_pkt.hls_ib_p_np_meta_s.idgroup));
        
        //- Incrementing expected delivered counter --------------------------------------
        m_total_expected_delivered_count[msi_dc_stream_pkt.PacketData[1][3:1]] += {msi_dc_stream_pkt.PacketData[1][0], msi_dc_stream_pkt.PacketData[0][7:0]};
        `uvm_info(get_type_name(), $sformatf("[HLSB DC] m_total_expected_delivered_count = %p", m_total_expected_delivered_count), UVM_DEBUG)
        
        //- Push packet to scoreboard --------------------------------------------
        //- If order checking is disabled, do not send the delivered count to the scoreboard.This is because the RTL simply adds the delivered count value, making prediction difficult.
        //- It's not possible to predict when the delivered count module will process the MSI Delivered Count value which is generated internally in the design.
        //- Therefore, instead of checking each individual packet, it should be sufficient to verify that the received and expected delivered counts match at the end of the test.
        if(l_any_dbg_dis_order_chk == 0 && parameters_cfg_pkg::NUM_HLS_PORTS == 1) begin
          m_dc_stream_scoreboard.write_expected_tr(msi_dc_stream_pkt); 
        end

        cover_msi_ports_active_cycle_combinations(m_ob_p_ports_active | m_ob_np_ports_active | m_ob_compl_ports_active);
        m_ob_p_ports_active = 0;
        m_ob_np_ports_active = 0;
        m_ob_compl_ports_active = 0;

        l_stream = int'(hls_ib_posted_hal_tlp_pkt.hls_ib_p_np_meta_s.idgroup[2:0]);

`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
        msi_clk_gater_vif.unfinished_packets++;
`endif
      end
`ifdef DTI_TB_IN_PASSIVE_MODE
      else if(l_route_to == ROUTE_TO_DTI) begin
        m_hls_ib_posted_dti_scoreboard.write_expected_tr(hls_ib_posted_hal_cxs_pkt);
        `uvm_info({l_msg_id, "[QOS_POSTED_DTI]"},$sformatf("Posted TLP to QOS AP via DTI: stream=%0d", hls_ib_posted_hal_tlp_pkt.hls_ib_p_np_meta_s.idgroup[2:0]),UVM_DEBUG)
        m_hls_ib_posted_qos_ap[0].write(hls_ib_posted_hal_tlp_pkt);
        m_qos_expected_count[2 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream]++;
        `uvm_info("QOS_EXP_DTI",$sformatf("POSTED DTI: stream=%0d group=%0d expected=%0d",l_stream,2 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream,
        m_qos_expected_count[2 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream]),UVM_DEBUG)
      end
`endif
      else if(l_route_to == ROUTE_TO_AXI) begin
        m_hls_ib_posted_cxs_scoreboard[l_hls_port_num].write_expected_tr(hls_ib_posted_hal_cxs_pkt);
        m_hls_ib_posted_qos_ap[l_hls_port_num].write(hls_ib_posted_hal_tlp_pkt);
        m_qos_expected_count[2 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream]++;
        `uvm_info("QOS_EXP_AXI",$sformatf("POSTED: port=%0d stream=%0d group=%0d expected=%0d",l_hls_port_num, l_stream,2 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream,m_qos_expected_count[2 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream]),UVM_DEBUG)
      end 

      //--- Send the IB Packet to the Posted Order Checker Component ------
      //--- Do not check UIO Posted Write in case of ordering
      if (hls_ib_posted_hal_tlp_pkt.m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_UIOMWr)
        send_to_ib_posted_order_checker(.route_to(l_route_to), .hls_port_num(l_hls_port_num), .cxs_pkt(hls_ib_posted_hal_cxs_pkt), .msi_pkt(hls_ib_posted_hal_msi_stream_pkt), .id_group(hls_ib_posted_hal_tlp_pkt.hls_ib_p_np_meta_s.idgroup)); 

      //-Tracking IB packet sequence
      track_ib_packet_sequence(hls_ib_posted_hal_tlp_pkt, l_route_to, "POSTED");

      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ib_p_np_hal_metadata(.msg_id(l_msg_id), .fc_type(2'b00), .metadata(hls_ib_posted_hal_tlp_pkt.hls_ib_p_np_meta_s));
      
      // - Increment Total Pkt Sent Counter ------------------------------------
      m_total_num_pkts_sent++;
    end
  endtask : process_hls_ib_posted_hal_pkt_ended
//----------------------------------------------------------------------------
  // Task: process_hls_ib_nonposted_hal_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ib_nonposted_hal_pkt_ended(string msg_id = "");
    string                                 l_msg_id = {msg_id, "[process_hls_ib_nonposted_hal_pkt_ended]"} ;
    denaliCxsTransaction                   hls_ib_nonposted_hal_cxs_pkt                                    ;
    cdn_hpa_pcie_tlp                       hls_ib_nonposted_hal_tlp_pkt                                    ;
    cdn_pcie_hls_bridge_inbound_route_to_e l_route_to                                                      ;
    int                                    l_hls_port_num                                                  ;
    
    forever begin
      m_hls_ib_nonposted_hal_pkt_ended_af.get(hls_ib_nonposted_hal_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ib_nonposted_hal_cxs_pkt), .str("Expected IB NonPosted"));
      
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b0), .cxs_pkt(hls_ib_nonposted_hal_cxs_pkt), .tlp_pkt(hls_ib_nonposted_hal_tlp_pkt));
      
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b1), .cxs_pkt(hls_ib_nonposted_hal_cxs_pkt), .tlp_pkt(hls_ib_nonposted_hal_tlp_pkt));
      
      //- Repacking TX To RX --------------------------------------------------- 
      repack_cxs_tx2rx(.msg_id(l_msg_id), .cxs_pkt(hls_ib_nonposted_hal_cxs_pkt));
      
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ib_nonposted_hal_tlp_pkt), .str("Expected IB NonPosted"));

      //- Predict where the inbound pkt should be routed to. -------------------
      predict_ib_pkt_routing(.msg_id(l_msg_id), .tlp_pkt(hls_ib_nonposted_hal_tlp_pkt), .route_to(l_route_to), .hls_port_num(l_hls_port_num));
      
      //- Push packet to scoreboard --------------------------------------------
      if(l_route_to == ROUTE_TO_AXI) begin
       	 m_hls_ib_nonposted_cxs_scoreboard[l_hls_port_num].write_expected_tr(hls_ib_nonposted_hal_cxs_pkt);
        `uvm_info({l_msg_id, "[QOS_NONPOSTED]"},$sformatf("NonPosted TLP to QOS AP via AXI: port=%0d stream=%0d",l_hls_port_num,hls_ib_nonposted_hal_tlp_pkt.hls_ib_p_np_meta_s.idgroup[2:0]), UVM_DEBUG)
	 m_hls_ib_nonposted_qos_ap[l_hls_port_num].write(hls_ib_nonposted_hal_tlp_pkt);
	 begin
 		 int l_stream = int'(hls_ib_nonposted_hal_tlp_pkt.hls_ib_p_np_meta_s.idgroup[2:0]);
 		 m_qos_expected_count[0 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream]++;
  		 `uvm_info("QOS_EXP_AXI",$sformatf("NONPOSTED AXI: port=%0d stream=%0d group=%0d expected=%0d", l_hls_port_num, l_stream, 0 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream,m_qos_expected_count[0 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream]),UVM_DEBUG)
	 end
      end
`ifdef DTI_TB_IN_PASSIVE_MODE
      else if(l_route_to == ROUTE_TO_DTI) begin
        m_hls_ib_nonposted_dti_scoreboard.write_expected_tr(hls_ib_nonposted_hal_cxs_pkt);	
        `uvm_info({l_msg_id, "[QOS_NONPOSTED_DTI]"},$sformatf("NonPosted TLP to QOS AP via DTI: stream=%0d",hls_ib_nonposted_hal_tlp_pkt.hls_ib_p_np_meta_s.idgroup[2:0]), UVM_DEBUG)
	m_hls_ib_nonposted_qos_ap[0].write(hls_ib_nonposted_hal_tlp_pkt);
	begin
  		int l_stream = int'(hls_ib_nonposted_hal_tlp_pkt.hls_ib_p_np_meta_s.idgroup[2:0]);
  		m_qos_expected_count[0 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream]++;
  		`uvm_info("QOS_EXP_DTI",$sformatf("NONPOSTED DTI: stream=%0d group=%0d expected=%0d",l_stream,0 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream, m_qos_expected_count[0 * parameters_cfg_pkg::NUM_TLP_STREAMS + l_stream]), UVM_DEBUG)
	end
      end
`endif
      //-Tracking IB packet sequence
      track_ib_packet_sequence(hls_ib_nonposted_hal_tlp_pkt, l_route_to, "NONPOSTED");

      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ib_p_np_hal_metadata(.msg_id(l_msg_id), .fc_type(2'b01), .metadata(hls_ib_nonposted_hal_tlp_pkt.hls_ib_p_np_meta_s));
      
      // - Increment Total Pkt Sent Counter ------------------------------------
      m_total_num_pkts_sent++;
    end
  endtask : process_hls_ib_nonposted_hal_pkt_ended
 
  //----------------------------------------------------------------------------
  // Task: process_hls_ib_compl_hal_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ib_compl_hal_pkt_ended(string msg_id = "");
    string                                 l_msg_id = {msg_id, "[process_hls_ib_compl_hal_pkt_ended]"} ;
    denaliCxsTransaction                   hls_ib_compl_hal_cxs_pkt                                    ;
    cdn_hpa_pcie_tlp                       hls_ib_compl_hal_tlp_pkt                                    ;
    cdn_pcie_hls_bridge_inbound_route_to_e l_route_to                                                  ;
    int                                    l_hls_port_num                                              ;
    
    forever begin
      m_hls_ib_compl_hal_pkt_ended_af.get(hls_ib_compl_hal_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ib_compl_hal_cxs_pkt), .str("Expected IB Completion"));
      
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b0), .cxs_pkt(hls_ib_compl_hal_cxs_pkt), .tlp_pkt(hls_ib_compl_hal_tlp_pkt));
      
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b1), .cxs_pkt(hls_ib_compl_hal_cxs_pkt), .tlp_pkt(hls_ib_compl_hal_tlp_pkt));
      
      //- Repacking TX To RX --------------------------------------------------- 
      repack_cxs_tx2rx(.msg_id(l_msg_id), .cxs_pkt(hls_ib_compl_hal_cxs_pkt));
      
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ib_compl_hal_tlp_pkt), .str("Expected IB Completion"));
     
      //- Predict where the inbound pkt should be routed to. -------------------
      predict_ib_pkt_routing(.msg_id(l_msg_id), .tlp_pkt(hls_ib_compl_hal_tlp_pkt), .route_to(l_route_to), .hls_port_num(l_hls_port_num));

      //- Push packet to scoreboard --------------------------------------------
      if(l_route_to == ROUTE_TO_AXI) begin
        m_hls_ib_compl_cxs_scoreboard[l_hls_port_num].write_expected_tr(hls_ib_compl_hal_cxs_pkt);
	`uvm_info({l_msg_id, "[QOS_COMPL]"}, $sformatf("Completion TLP to QOS AP via AXI: port=%0d stream=%0d",l_hls_port_num, l_hls_port_num[2:0]), UVM_DEBUG)
       m_hls_ib_compl_qos_ap[l_hls_port_num].write(hls_ib_compl_hal_tlp_pkt);
	begin
  		int l_group = 1 * parameters_cfg_pkg::NUM_TLP_STREAMS + int'(l_hls_port_num[2:0]);
  	        m_qos_expected_count[l_group]++;
		`uvm_info("QOS_EXP",$sformatf("COMPL AXI: port=%0d group=%0d expected=%0d",l_hls_port_num, l_group,m_qos_expected_count[l_group]),UVM_DEBUG)
	end
      end
      

      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ib_cpl_hal_metadata(.msg_id(l_msg_id), .metadata(hls_ib_compl_hal_tlp_pkt.hls_ib_cpl_meta_s));
      
      // - Increment Total Pkt Sent Counter ------------------------------------
      m_total_num_pkts_sent++;
    end
  endtask : process_hls_ib_compl_hal_pkt_ended

`ifdef DTI_TB_IN_PASSIVE_MODE
  //----------------------------------------------------------------------------
  // Task: process_hls_ib_nonposted_dti_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ib_nonposted_dti_pkt_ended(string msg_id = "");
    string               l_msg_id = {msg_id, "[process_hls_ib_nonposted_dti_pkt_ended]"} ;
    denaliCxsTransaction hls_ib_nonposted_dti_cxs_pkt                                    ;
    cdn_hpa_pcie_tlp     hls_ib_nonposted_dti_tlp_pkt                                    ;

    forever begin
      m_hls_ib_nonposted_dti_pkt_ended_af.get(hls_ib_nonposted_dti_cxs_pkt);

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ib_nonposted_dti_cxs_pkt), .str("Received IB NonPosted DTI"));

      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b0), .cxs_pkt(hls_ib_nonposted_dti_cxs_pkt), .tlp_pkt(hls_ib_nonposted_dti_tlp_pkt));
      hls_ib_nonposted_dti_tlp_pkt.is_ib_pkt = 1;

      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b1), .cxs_pkt(hls_ib_nonposted_dti_cxs_pkt), .tlp_pkt(hls_ib_nonposted_dti_tlp_pkt));

      //- Print Converted TLP -------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ib_nonposted_dti_tlp_pkt), .str("Received IB NonPosted DTI"));
 
      //- Repacking Tx to Rx--------------------------------------------------

      repack_cxs_tx2rx(.msg_id(l_msg_id), .cxs_pkt(hls_ib_nonposted_dti_cxs_pkt));

      //- Push packet to scoreboard -------------------------------------------
      m_hls_ib_nonposted_dti_scoreboard.write_received_tr(hls_ib_nonposted_dti_cxs_pkt);

      //- Calling Coverage callbacks -------------------------------------------
      // TODO: Add later
/* -----\/----- EXCLUDED -----\/-----
      cover_hls_ib_p_np_dti_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b01), .metadata(hls_ib_nonposted_dti_tlp_pkt.hls_ib_p_np_meta_s));
 -----/\----- EXCLUDED -----/\----- */
      cover_hpa_tlp(.msg_id(l_msg_id), .strap_is_rp(m_env_cfg.i_cfg.strap_is_rp), .is_ib_dir(1'b1), .tlp_pkt(hls_ib_nonposted_dti_tlp_pkt));
    end
  endtask : process_hls_ib_nonposted_dti_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_hls_ib_posted_dti_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ib_posted_dti_pkt_ended(string msg_id = "");
    string               l_msg_id = {msg_id, "[process_hls_ib_posted_dti_pkt_ended]"} ;
    denaliCxsTransaction hls_ib_posted_dti_cxs_pkt                                    ;
    cdn_hpa_pcie_tlp     hls_ib_posted_dti_tlp_pkt                                    ;

    forever begin
      m_hls_ib_posted_dti_pkt_ended_af.get(hls_ib_posted_dti_cxs_pkt);

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ib_posted_dti_cxs_pkt), .str("Received IB Posted DTI"));

      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b0), .cxs_pkt(hls_ib_posted_dti_cxs_pkt), .tlp_pkt(hls_ib_posted_dti_tlp_pkt));
      hls_ib_posted_dti_tlp_pkt.is_ib_pkt = 1;

      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b1), .cxs_pkt(hls_ib_posted_dti_cxs_pkt), .tlp_pkt(hls_ib_posted_dti_tlp_pkt));
 
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ib_posted_dti_tlp_pkt), .str("Received IB Posted DTI"));
 
      //- Repacking Tx to Rx --------------------------------------------------
      repack_cxs_tx2rx(.msg_id(l_msg_id), .cxs_pkt(hls_ib_posted_dti_cxs_pkt));

      //- Push packet to scoreboard --------------------------------------------
      m_hls_ib_posted_dti_scoreboard.write_received_tr(hls_ib_posted_dti_cxs_pkt);

      //- Send to IB Posted Order Checker --------------------------------------
      dti_ib_posted_pkt_ended_ap.write(hls_ib_posted_dti_cxs_pkt);
      
      //- Calling Coverage callbacks -------------------------------------------
      // TODO: Add later
/* -----\/----- EXCLUDED -----\/-----
      cover_hls_ib_p_np_dti_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b01), .metadata(hls_ib_posted_dti_tlp_pkt.hls_ib_p_np_meta_s));
 -----/\----- EXCLUDED -----/\----- */
      cover_hpa_tlp(.msg_id(l_msg_id), .strap_is_rp(m_env_cfg.i_cfg.strap_is_rp), .is_ib_dir(1'b1), .tlp_pkt(hls_ib_posted_dti_tlp_pkt));
    end
  endtask : process_hls_ib_posted_dti_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_compl_dti_pkt_started
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_compl_dti_pkt_started(string msg_id = "");
    string               l_msg_id = {msg_id, "[process_hls_ob_compl_dti_pkt_started]"} ;
    denaliCxsTransaction hls_ob_compl_dti_cxs_pkt                                      ;
    int unsigned         hls_port_num = parameters_cfg_pkg::NUM_HLS_PORTS              ; // Making DTI Port as NUM_HLS_PORTS + 1.

    forever begin
      // - Get the packet ------------------------------------------------------
      m_hls_ob_compl_dti_pkt_started_af.get(hls_ob_compl_dti_cxs_pkt);

      // Needed for the merge predictor to work properly
      hls_ob_compl_dti_cxs_pkt.PktStartTime = hls_ob_compl_dti_cxs_pkt.PktStartTimeRx;
      hls_ob_compl_dti_cxs_pkt.PktEndTime   = hls_ob_compl_dti_cxs_pkt.PktEndTimeRx;

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_compl_dti_cxs_pkt), .str("Expected OB Completion DTI Started before sending to predictor"));

      // - Send to HLS OB Merge Predictor --------------------------------------
      hls_ob_compl_dti_pkt_started_ap.write(hls_ob_compl_dti_cxs_pkt);
    end
  endtask : process_hls_ob_compl_dti_pkt_started

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_compl_dti_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_compl_dti_pkt_ended(string msg_id = "");
    string               l_msg_id = {msg_id, "[process_hls_ob_compl_dti_pkt_ended]"} ;
    denaliCxsTransaction hls_ob_compl_dti_cxs_pkt                                    ;
    cdn_hpa_pcie_tlp     hls_ob_compl_dti_tlp_pkt                                    ;

    forever begin
      m_hls_ob_compl_dti_pkt_ended_af.get(hls_ob_compl_dti_cxs_pkt);

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_compl_dti_cxs_pkt), .str("Expected OB Completion DTI Ended before sending to Predictor"));

      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b1), .cxs_pkt(hls_ob_compl_dti_cxs_pkt), .tlp_pkt(hls_ob_compl_dti_tlp_pkt));

      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b0), .cxs_pkt(hls_ob_compl_dti_cxs_pkt), .tlp_pkt(hls_ob_compl_dti_tlp_pkt));
      
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ob_compl_dti_tlp_pkt), .str("Expected OB Completion DTI"));

      repack_cxs_rx2tx(msg_id, hls_ob_compl_dti_cxs_pkt);

      // - Send to HLS OB Merge Predictor --------------------------------------
      hls_ob_compl_dti_pkt_ended_ap.write(hls_ob_compl_dti_cxs_pkt);

      //- Calling Coverage callbacks -------------------------------------------
/// TODO: Add later      cover_hls_ob_dti_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b10), .metadata(hls_ob_compl_dti_tlp_pkt.hls_ob_meta_s));
    end
  endtask : process_hls_ob_compl_dti_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_posted_dti_pkt_started
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_posted_dti_pkt_started(string msg_id = "");
    string               l_msg_id = {msg_id, "[process_hls_ob_posted_dti_pkt_started]"} ;
    denaliCxsTransaction hls_ob_posted_dti_cxs_pkt                                      ;
    int unsigned         hls_port_num = parameters_cfg_pkg::NUM_HLS_PORTS               ; // Making DTI Port as NUM_HLS_PORTS + 1

    forever begin
      // - Get the packet ------------------------------------------------------
      m_hls_ob_posted_dti_pkt_started_af.get(hls_ob_posted_dti_cxs_pkt);

      // Needed for the merge predictor to work properly
      hls_ob_posted_dti_cxs_pkt.PktStartTime = hls_ob_posted_dti_cxs_pkt.PktStartTimeRx;
      hls_ob_posted_dti_cxs_pkt.PktEndTime   = hls_ob_posted_dti_cxs_pkt.PktEndTimeRx;

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_posted_dti_cxs_pkt), .str("Expected OB Posted DTI Started before sending to predictor"));

      // - Send to HLS OB Merge Predictor --------------------------------------
      hls_ob_posted_dti_pkt_started_ap.write(hls_ob_posted_dti_cxs_pkt);
    end
  endtask : process_hls_ob_posted_dti_pkt_started

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_posted_dti_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_posted_dti_pkt_ended(string msg_id = "");
    string               l_msg_id = {msg_id, "[process_hls_ob_posted_dti_pkt_ended]"} ;
    denaliCxsTransaction hls_ob_posted_dti_cxs_pkt                                    ;
    cdn_hpa_pcie_tlp     hls_ob_posted_dti_tlp_pkt                                    ;

    forever begin
      m_hls_ob_posted_dti_pkt_ended_af.get(hls_ob_posted_dti_cxs_pkt);

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_posted_dti_cxs_pkt), .str("Expected OB Posted DTI Ended before sending to Predictor"));

      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b1), .cxs_pkt(hls_ob_posted_dti_cxs_pkt), .tlp_pkt(hls_ob_posted_dti_tlp_pkt));

      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b0), .cxs_pkt(hls_ob_posted_dti_cxs_pkt), .tlp_pkt(hls_ob_posted_dti_tlp_pkt));

      if (hls_ob_posted_dti_tlp_pkt.hls_ob_meta_s.axib_port_num != 0)
        `uvm_error(get_type_name(), $sformatf("DTI module reported wrong axib_port_num in OB metadata: expected 'h0, received 'h%0h", hls_ob_posted_dti_tlp_pkt.hls_ob_meta_s.axib_port_num))
      
      // //- Creating expected metadata ------------------------------------------
      // update_ob_metadata(.msg_id(l_msg_id), .axib_port_num(4'b0000), .cxs_pkt(hls_ob_posted_dti_cxs_pkt), .tlp_pkt(hls_ob_posted_dti_tlp_pkt));

      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ob_posted_dti_tlp_pkt), .str("Expected OB Posted DTI"));

      repack_cxs_rx2tx(msg_id, hls_ob_posted_dti_cxs_pkt);

      // - Send to HLS OB Merge Predictor --------------------------------------
      hls_ob_posted_dti_pkt_ended_ap.write(hls_ob_posted_dti_cxs_pkt);

      //- Calling Coverage callbacks -------------------------------------------
/// TODO: Add later      cover_hls_ob_dti_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b10), .metadata(hls_ob_posted_dti_tlp_pkt.hls_ob_meta_s));
    end
  endtask : process_hls_ob_posted_dti_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_hdr2log_dti_ended
  //----------------------------------------------------------------------------
  virtual task process_hdr2log_dti_ended(string msg_id = "");
    string                   l_msg_id = {msg_id, "[process_hdr2log_dti_ended]"} ;
    denaliStreamTransaction  hdr2log_dti_stream_pkt                                                           ;

    forever begin
      // -- Get the pkt from Stream VIP Callback ----------------------
      m_hdr2log_dti_ended_af.get(hdr2log_dti_stream_pkt);

      //- Print AXI Stream packet ----------------------------------------------
      // print_axi_stream(.msg_id(l_msg_id), .stream_pkt(hdr2log_dti_stream_pkt), .str("Expected HDR2LOG"));

      //-- Masking Unwanted fields since these are not present in the interface --
      hdr2log_dti_stream_pkt.TstrbArray.delete();
      hdr2log_dti_stream_pkt.TkeepArray.delete();
      hdr2log_dti_stream_pkt.Id   = 0;
      hdr2log_dti_stream_pkt.Dest = 0;

      //- Push packet to scoreboard --------------------------------------------
      // As per PCIE-19839 the order of hdr2log pkts doesn't matter.
      m_hdr2log_stream_scoreboard.write_expected_tr(hdr2log_dti_stream_pkt);

      // - Increment Total Pkt Sent Counter ------------------------------------
      m_total_num_pkts_sent++;
    end

  endtask : process_hdr2log_dti_ended

  //----------------------------------------------------------------------------
  // Task: process_dc_dti_ended
  //----------------------------------------------------------------------------
  virtual task process_dc_dti_ended(string msg_id = "");
    string                   l_msg_id = {msg_id, "[process_dc_dti_ended]"};
    denaliStreamTransaction  dc_dti_stream_pkt                            ;
    bit                      l_any_dbg_dis_order_chk                      ;

    forever begin
      m_dc_dti_ended_af.get(dc_dti_stream_pkt);
      
      //-- Check if any order checking disabled ----------------------------------
      l_any_dbg_dis_order_chk = hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value() || hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value() || hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_msi.get_mirrored_value();
      
      //- Print AXI Stream packet ------------------------------------------------
      print_axi_stream(.msg_id(l_msg_id), .stream_pkt(dc_dti_stream_pkt), .str("Expected Delivered Count DTI"));
      
      //-- Masking Unwanted fields since these are not present in the interface --
      dc_dti_stream_pkt.TuserArray.delete();
      dc_dti_stream_pkt.TstrbArray.delete();
      dc_dti_stream_pkt.TkeepArray.delete();
      dc_dti_stream_pkt.Id   = 0;
      dc_dti_stream_pkt.Dest = 0;
      
      //- Incrementing expected delivered counter --------------------------------------
      m_total_expected_delivered_count[dc_dti_stream_pkt.PacketData[1][3:1]] += {dc_dti_stream_pkt.PacketData[1][0], dc_dti_stream_pkt.PacketData[0][7:0]};
      `uvm_info(get_type_name(), $sformatf("[HLSB DC] m_total_expected_delivered_count = %p", m_total_expected_delivered_count), UVM_DEBUG)

      //- Push packet to scoreboard ----------------------------------------------
      //- If order checking is disabled, do not send the delivered count to the scoreboard.This is because the RTL simply adds the delivered count value, making prediction difficult.
      //- It's not possible to predict when the delivered count module will process the MSI Delivered Count value which is generated internally in the design.
      //- Therefore, instead of checking each individual packet, it should be sufficient to verify that the received and expected delivered counts match at the end of the test.
      if(l_any_dbg_dis_order_chk == 0 && parameters_cfg_pkg::NUM_HLS_PORTS == 1) begin
        m_dc_stream_scoreboard.write_expected_tr(dc_dti_stream_pkt);
      end

      //-- Send the delivered count to the IB Posted Order Checker. ---------- 
      dti_delivered_count_pkt_ended_ap.write(dc_dti_stream_pkt);
    end
  endtask : process_dc_dti_ended

`endif //  `ifdef DTI_TB_IN_PASSIVE_MODE

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_posted_axi_pkt_started (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_posted_axi_pkt_started(string msg_id = "", int unsigned hls_port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_hls_ob_posted_axi_pkt_started[%0d]]", hls_port_num)} ;
    denaliCxsTransaction hls_ob_posted_axi_cxs_pkt                                                                    ;
    forever begin
      // - Get the packet ------------------------------------------------------ 
      m_hls_ob_posted_axi_pkt_started_af[hls_port_num].get(hls_ob_posted_axi_cxs_pkt);
       
      //- Print CXS packet -----------------------------------------------------
      // print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_posted_axi_cxs_pkt), .str("Expected OB Posted Started Before Sending to Predictor"));
      
      // - Send to HLS OB Merge Predictor -------------------------------------- 
      hls_ob_posted_axi_pkt_started_ap[hls_port_num].write(hls_ob_posted_axi_cxs_pkt);

      m_ob_p_ports_active[hls_port_num] = 1;
    end
  endtask : process_hls_ob_posted_axi_pkt_started

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_posted_axi_pkt_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_posted_axi_pkt_ended(string msg_id = "", int unsigned hls_port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_hls_ob_posted_axi_pkt_ended[%0d]]", hls_port_num)} ;
    denaliCxsTransaction hls_ob_posted_axi_cxs_pkt                                                                  ;
    cdn_hpa_pcie_tlp     hls_ob_posted_axi_tlp_pkt                                                                  ;
    
    forever begin
      m_hls_ob_posted_axi_pkt_ended_af[hls_port_num].get(hls_ob_posted_axi_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_posted_axi_cxs_pkt), .str("Expected OB Posted Ended Before Sending to Predictor"));
      
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b0), .cxs_pkt(hls_ob_posted_axi_cxs_pkt), .tlp_pkt(hls_ob_posted_axi_tlp_pkt));

      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b0), .cxs_pkt(hls_ob_posted_axi_cxs_pkt), .tlp_pkt(hls_ob_posted_axi_tlp_pkt));

      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ob_axi_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b00), .metadata(hls_ob_posted_axi_tlp_pkt.hls_ob_meta_s));
      
      //- Creating expected metadata ------------------------------------------
      update_ob_metadata(.msg_id(l_msg_id), .axib_port_num(hls_port_num + 1), .cxs_pkt(hls_ob_posted_axi_cxs_pkt), .tlp_pkt(hls_ob_posted_axi_tlp_pkt));
      
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ob_posted_axi_tlp_pkt), .str("Expected OB Posted"));
   
      // - Send to HLS OB Merge Predictor -------------------------------------- 
      hls_ob_posted_axi_pkt_ended_ap[hls_port_num].write(hls_ob_posted_axi_cxs_pkt);

      //- Send packet to vseq for credit calculations
      credit_ob_posted_axi_ap.write(hls_ob_posted_axi_tlp_pkt);

      // - Increment Total Pkt Sent Counter ------------------------------------
      m_total_num_pkts_sent++;

      m_ob_p_ports_active[hls_port_num] = 0;
    end
  endtask : process_hls_ob_posted_axi_pkt_ended
 
  //----------------------------------------------------------------------------
  // Task: send_predicted_hls_ob_posted_axi_pkt
  //----------------------------------------------------------------------------
  virtual task send_predicted_hls_ob_posted_axi_pkt(string msg_id = "");
    string               l_msg_id = {msg_id, "[send_predicted_hls_ob_posted_axi_pkt]"} ;
    denaliCxsTransaction hls_ob_posted_axi_cxs_pkt                                     ;

    forever begin
      //- Get pkt from the hls ob merge predictor ------------------------------
      m_predicted_hls_ob_posted_axi_af.get(hls_ob_posted_axi_cxs_pkt);
      
      //- Repacking TX To RX --------------------------------------------------- 
      repack_cxs_tx2rx(.msg_id(l_msg_id), .cxs_pkt(hls_ob_posted_axi_cxs_pkt));

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_posted_axi_cxs_pkt), .str("Expected OB Posted"));
      
      //- Push packet to scoreboard --------------------------------------------
      m_hls_ob_posted_cxs_scoreboard.write_expected_tr(hls_ob_posted_axi_cxs_pkt);
    end
  endtask : send_predicted_hls_ob_posted_axi_pkt

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_nonposted_axi_pkt_started (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_nonposted_axi_pkt_started(string msg_id = "", int unsigned hls_port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_hls_ob_nonposted_axi_pkt_started[%0d]]", hls_port_num)} ;
    denaliCxsTransaction hls_ob_nonposted_axi_cxs_pkt                                                                    ;
    forever begin
      // - Get the packet ------------------------------------------------------ 
      m_hls_ob_nonposted_axi_pkt_started_af[hls_port_num].get(hls_ob_nonposted_axi_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      // print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_nonposted_axi_cxs_pkt), .str("Expected OB NonPosted Started Before sending to Predictor"));
      
      // - Send to HLS OB Merge Predictor -------------------------------------- 
      hls_ob_nonposted_axi_pkt_started_ap[hls_port_num].write(hls_ob_nonposted_axi_cxs_pkt);

      m_ob_np_ports_active[hls_port_num] = 1;
    end
  endtask : process_hls_ob_nonposted_axi_pkt_started

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_nonposted_axi_pkt_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_nonposted_axi_pkt_ended(string msg_id = "", int unsigned hls_port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_hls_ob_nonposted_axi_pkt_ended[%0d]]", hls_port_num)} ;
    denaliCxsTransaction hls_ob_nonposted_axi_cxs_pkt                                                                  ;
    cdn_hpa_pcie_tlp     hls_ob_nonposted_axi_tlp_pkt                                                                  ;
    
    forever begin
      m_hls_ob_nonposted_axi_pkt_ended_af[hls_port_num].get(hls_ob_nonposted_axi_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_nonposted_axi_cxs_pkt), .str("Expected OB NonPosted Ended before sending to predictor."));
      
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b0), .cxs_pkt(hls_ob_nonposted_axi_cxs_pkt), .tlp_pkt(hls_ob_nonposted_axi_tlp_pkt));
      
      //- Convert Userctrl To Metadata -----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b0), .cxs_pkt(hls_ob_nonposted_axi_cxs_pkt), .tlp_pkt(hls_ob_nonposted_axi_tlp_pkt));
      
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ob_nonposted_axi_tlp_pkt), .str("Expected OB NonPosted"));
    
      // - Send to HLS OB Merge Predictor -------------------------------------- 
      hls_ob_nonposted_axi_pkt_ended_ap[hls_port_num].write(hls_ob_nonposted_axi_cxs_pkt);

      //- Send packet to vseq for credit calculations --------------------------
      credit_ob_nonposted_axi_ap.write(hls_ob_nonposted_axi_tlp_pkt);
      
      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ob_axi_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b01), .metadata(hls_ob_nonposted_axi_tlp_pkt.hls_ob_meta_s));
      
      //- Increment Total Pkt Sent Counter -------------------------------------
      m_total_num_pkts_sent++;

      m_ob_np_ports_active[hls_port_num] = 0;
    end
  endtask : process_hls_ob_nonposted_axi_pkt_ended

  //----------------------------------------------------------------------------
  // Task: send_predicted_hls_ob_nonposted_axi_pkt
  //----------------------------------------------------------------------------
  virtual task send_predicted_hls_ob_nonposted_axi_pkt(string msg_id = "");
    string               l_msg_id = {msg_id, "[send_predicted_hls_ob_nonposted_axi_pkt]"} ;
    denaliCxsTransaction hls_ob_nonposted_axi_cxs_pkt                                     ;

    forever begin
      //- Get pkt from the hls ob merge predictor ------------------------------
      m_predicted_hls_ob_nonposted_axi_af.get(hls_ob_nonposted_axi_cxs_pkt);
      
      //- Repacking TX To RX --------------------------------------------------- 
      repack_cxs_tx2rx(.msg_id(l_msg_id), .cxs_pkt(hls_ob_nonposted_axi_cxs_pkt));

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_nonposted_axi_cxs_pkt), .str("Expected OB NonPosted"));
      
      //- Push packet to scoreboard --------------------------------------------
      m_hls_ob_nonposted_cxs_scoreboard.write_expected_tr(hls_ob_nonposted_axi_cxs_pkt);
    end
  endtask : send_predicted_hls_ob_nonposted_axi_pkt

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_compl_axi_pkt_started (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_compl_axi_pkt_started(string msg_id = "", int unsigned hls_port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_hls_ob_compl_axi_pkt_started[%0d]]", hls_port_num)} ;
    denaliCxsTransaction hls_ob_compl_axi_cxs_pkt                                                                    ;
    forever begin
      // - Get the packet ------------------------------------------------------ 
      m_hls_ob_compl_axi_pkt_started_af[hls_port_num].get(hls_ob_compl_axi_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      // print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_compl_axi_cxs_pkt), .str("Expected OB Completion Started before sending to predictor"));
      
      // - Send to HLS OB Merge Predictor -------------------------------------- 
      hls_ob_compl_axi_pkt_started_ap[hls_port_num].write(hls_ob_compl_axi_cxs_pkt);

      m_ob_compl_ports_active[hls_port_num] = 1;
    end
  endtask : process_hls_ob_compl_axi_pkt_started

  //----------------------------------------------------------------------------
  // Task: process_hls_ob_compl_axi_pkt_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ob_compl_axi_pkt_ended(string msg_id = "", int unsigned hls_port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_hls_ob_compl_axi_pkt_ended[%0d]]", hls_port_num)} ;
    denaliCxsTransaction hls_ob_compl_axi_cxs_pkt                                                                  ;
    cdn_hpa_pcie_tlp     hls_ob_compl_axi_tlp_pkt                                                                  ;
    
    forever begin
      m_hls_ob_compl_axi_pkt_ended_af[hls_port_num].get(hls_ob_compl_axi_cxs_pkt);
     
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_compl_axi_cxs_pkt), .str("Expected OB Completion Ended before sending to Predictor"));
      
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b0), .cxs_pkt(hls_ob_compl_axi_cxs_pkt), .tlp_pkt(hls_ob_compl_axi_tlp_pkt));
      
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b0), .cxs_pkt(hls_ob_compl_axi_cxs_pkt), .tlp_pkt(hls_ob_compl_axi_tlp_pkt));

      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ob_compl_axi_tlp_pkt), .str("Expected OB Completion"));
      
      // - Send to HLS OB Merge Predictor -------------------------------------- 
      hls_ob_compl_axi_pkt_ended_ap[hls_port_num].write(hls_ob_compl_axi_cxs_pkt);
    
      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ob_axi_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b10), .metadata(hls_ob_compl_axi_tlp_pkt.hls_ob_meta_s));
      
      // - Increment Total Pkt Sent Counter ------------------------------------
      m_total_num_pkts_sent++;

      m_ob_compl_ports_active[hls_port_num] = 0;
    end
  endtask : process_hls_ob_compl_axi_pkt_ended

  //----------------------------------------------------------------------------
  // Task: send_predicted_hls_ob_compl_axi_pkt
  //----------------------------------------------------------------------------
  virtual task send_predicted_hls_ob_compl_axi_pkt(string msg_id = "");
    string               l_msg_id = {msg_id, "[send_predicted_hls_ob_compl_axi_pkt]"} ;
    denaliCxsTransaction hls_ob_compl_axi_cxs_pkt                                     ;

    forever begin
      //- Get pkt from the hls ob merge predictor ------------------------------
      m_predicted_hls_ob_compl_axi_af.get(hls_ob_compl_axi_cxs_pkt);
      
      //- Repacking TX To RX --------------------------------------------------- 
      repack_cxs_tx2rx(.msg_id(l_msg_id), .cxs_pkt(hls_ob_compl_axi_cxs_pkt));

      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ob_compl_axi_cxs_pkt), .str("Expected OB Completion"));
      
      //- Push packet to scoreboard --------------------------------------------
      m_hls_ob_compl_cxs_scoreboard.write_expected_tr(hls_ob_compl_axi_cxs_pkt);
    end
  endtask : send_predicted_hls_ob_compl_axi_pkt

  //----------------------------------------------------------------------------
  // Task: process_hls_ib_posted_axi_pkt_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ib_posted_axi_pkt_ended(string msg_id = "", int unsigned hls_port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_hls_ib_posted_axi_pkt_ended[%0d]]", hls_port_num)} ;
    denaliCxsTransaction hls_ib_posted_axi_cxs_pkt                                                                  ;
    cdn_hpa_pcie_tlp     hls_ib_posted_axi_tlp_pkt                                                                  ;
    bit                  l_link_down_handling_in_progress                                                           ;
    
    forever begin
      m_hls_ib_posted_axi_pkt_ended_af[hls_port_num].get(hls_ib_posted_axi_cxs_pkt);
      m_env_cfg.m_misc_if_api.get_link_down_handling_in_progress(.value(l_link_down_handling_in_progress));
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ib_posted_axi_cxs_pkt), .str("Received IB Posted"));
     
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b1), .cxs_pkt(hls_ib_posted_axi_cxs_pkt), .tlp_pkt(hls_ib_posted_axi_tlp_pkt));
      
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b1), .cxs_pkt(hls_ib_posted_axi_cxs_pkt), .tlp_pkt(hls_ib_posted_axi_tlp_pkt));
      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ib_posted_axi_tlp_pkt), .str("Received IB Posted"));   
      //- Push packet to scoreboard --------------------------------------------
      m_hls_ib_posted_cxs_scoreboard[hls_port_num].write_received_tr(hls_ib_posted_axi_cxs_pkt);
      
      //- Sending to vSeq to Generate the Posted Delivered Count ---------------
      //- UIOMWr is not incrementing posted delivery count
      if (hls_ib_posted_axi_tlp_pkt.m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_UIOMWr)
        m_hls_ib_posted_axi_tlp_pkt_delivered_ap[hls_port_num].write(hls_ib_posted_axi_tlp_pkt);

      //-- Send to IB Posted Order Checker -----------------------
      axi_ib_posted_pkt_ended_ap[hls_port_num].write(hls_ib_posted_axi_cxs_pkt);
      
      //- Send Received inbound P Req to CIF Router for Compl Generation if linkdown is not in progress -----
      if(hls_ib_posted_axi_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr && l_link_down_handling_in_progress == 0)
        ib_uio_p_req_ap.write(hls_ib_posted_axi_tlp_pkt);

      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ib_p_np_axi_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b00), .metadata(hls_ib_posted_axi_tlp_pkt.hls_ib_p_np_meta_s));
      cover_hpa_tlp(.msg_id(l_msg_id), .strap_is_rp(m_env_cfg.i_cfg.strap_is_rp), .is_ib_dir(1'b1), .tlp_pkt(hls_ib_posted_axi_tlp_pkt));
    end
  endtask : process_hls_ib_posted_axi_pkt_ended
  
  //----------------------------------------------------------------------------
  // Task: process_hls_ib_nonposted_axi_pkt_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ib_nonposted_axi_pkt_ended(string msg_id = "", int unsigned hls_port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_hls_ib_nonposted_axi_pkt_ended[%0d]]", hls_port_num)} ;
    denaliCxsTransaction hls_ib_nonposted_axi_cxs_pkt                                                                  ;
    cdn_hpa_pcie_tlp     hls_ib_nonposted_axi_tlp_pkt                                                                  ;
    bit                  l_link_down_handling_in_progress                                                              ;
    
    forever begin
      m_hls_ib_nonposted_axi_pkt_ended_af[hls_port_num].get(hls_ib_nonposted_axi_cxs_pkt);
      m_env_cfg.m_misc_if_api.get_link_down_handling_in_progress(.value(l_link_down_handling_in_progress));
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ib_nonposted_axi_cxs_pkt), .str("Received IB NonPosted"));
   
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b1), .cxs_pkt(hls_ib_nonposted_axi_cxs_pkt), .tlp_pkt(hls_ib_nonposted_axi_tlp_pkt));
      hls_ib_nonposted_axi_tlp_pkt.is_ib_pkt = 1;
      
      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b1), .cxs_pkt(hls_ib_nonposted_axi_cxs_pkt), .tlp_pkt(hls_ib_nonposted_axi_tlp_pkt));

      //- Print Converted TLP -------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ib_nonposted_axi_tlp_pkt), .str("Received IB NonPosted"));
      
      //- Push packet to scoreboard -------------------------------------------
      m_hls_ib_nonposted_cxs_scoreboard[hls_port_num].write_received_tr(hls_ib_nonposted_axi_cxs_pkt);
      
      //- Send Received inbound NP Req to CIF Router for Compl Generation if linkdown is not in progress ----- 
      if(l_link_down_handling_in_progress == 0)
        ib_np_req_ap.write(hls_ib_nonposted_axi_tlp_pkt);
      
      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ib_p_np_axi_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .fc_type(2'b01), .metadata(hls_ib_nonposted_axi_tlp_pkt.hls_ib_p_np_meta_s));
      cover_hpa_tlp(.msg_id(l_msg_id), .strap_is_rp(m_env_cfg.i_cfg.strap_is_rp), .is_ib_dir(1'b1), .tlp_pkt(hls_ib_nonposted_axi_tlp_pkt));
    end
  endtask : process_hls_ib_nonposted_axi_pkt_ended 
  
  //----------------------------------------------------------------------------
  // Task: process_hls_ib_compl_axi_pkt_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hls_ib_compl_axi_pkt_ended(string msg_id = "", int unsigned hls_port_num);
    string l_msg_id = {msg_id, $sformatf("[process_hls_ib_compl_axi_pkt_ended[%0d]]", hls_port_num)};
    denaliCxsTransaction hls_ib_compl_axi_cxs_pkt;
    cdn_hpa_pcie_tlp     hls_ib_compl_axi_tlp_pkt;
    
    forever begin  
      m_hls_ib_compl_axi_pkt_ended_af[hls_port_num].get(hls_ib_compl_axi_cxs_pkt);
      
      //- Print CXS packet -----------------------------------------------------
      print_cxs(.msg_id(l_msg_id), .cxs_pkt(hls_ib_compl_axi_cxs_pkt), .str("Received IB Completion"));
    
      //- Convert CXS To TLP ---------------------------------------------------
      convert_cxs2tlp(.msg_id(l_msg_id), .is_rx(1'b1), .cxs_pkt(hls_ib_compl_axi_cxs_pkt), .tlp_pkt(hls_ib_compl_axi_tlp_pkt));
      hls_ib_compl_axi_tlp_pkt.is_ib_pkt = 1;

      //- Convert Userctrl To Metadata ----------------------------------------
      convert_userctrl2metadata(.msg_id(l_msg_id), .is_ib(1'b1), .cxs_pkt(hls_ib_compl_axi_cxs_pkt), .tlp_pkt(hls_ib_compl_axi_tlp_pkt));

      //- Print Converted TLP --------------------------------------------------
      // print_tlp(.msg_id(l_msg_id), .tlp_pkt(hls_ib_compl_axi_tlp_pkt), .str("Received IB Completion"));

      //- Push packet to scoreboard --------------------------------------------
      m_hls_ib_compl_cxs_scoreboard[hls_port_num].write_received_tr(hls_ib_compl_axi_cxs_pkt);
      if (hls_ib_compl_axi_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl ||
          hls_ib_compl_axi_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCpl ||
          hls_ib_compl_axi_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD) 
      begin
           track_split_ib_completion(hls_ib_compl_axi_tlp_pkt);
      end 
 
      
      //- Send Received inbound Compl to Tag Manager to release the tag -------- 
      if(hls_ib_compl_axi_tlp_pkt.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl) begin
        ib_uio_p_compl_req_ap.write(hls_ib_compl_axi_tlp_pkt);
      end
      else begin
        if (hls_ib_compl_axi_tlp_pkt.m_tlp_14_bit_tagscale) begin
          ib_14bit_compl_req_ap.write(hls_ib_compl_axi_tlp_pkt);
        end
        else if(hls_ib_compl_axi_tlp_pkt.m_tlp_tagscale) begin
          ib_10bit_compl_req_ap.write(hls_ib_compl_axi_tlp_pkt);
        end
        else begin
          ib_compl_req_ap.write(hls_ib_compl_axi_tlp_pkt);
        end
      end

      //- Calling Coverage callbacks -------------------------------------------
      cover_hls_ib_cpl_axi_metadata(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .metadata(hls_ib_compl_axi_tlp_pkt.hls_ib_cpl_meta_s));
      cover_hpa_tlp(.msg_id(l_msg_id), .strap_is_rp(m_env_cfg.i_cfg.strap_is_rp), .is_ib_dir(1'b1), .tlp_pkt(hls_ib_compl_axi_tlp_pkt));
    end
  endtask : process_hls_ib_compl_axi_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_hdr2log_mst_started (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hdr2log_mst_started(string msg_id = "", int unsigned hls_port_num);
    string                  l_msg_id = {msg_id, $sformatf("[process_hdr2log_mst_started[%0d]]", hls_port_num)} ;
    denaliStreamTransaction hdr2log_mst_stream_pkt                                                             ;
    
    forever begin
      // -- Get the pkt from Stream VIP Callback ----------------------
      m_hdr2log_mst_started_af[hls_port_num].get(hdr2log_mst_stream_pkt);
      
      //- Print AXI Stream packet ----------------------------------------------
      // print_axi_stream(.msg_id(l_msg_id), .stream_pkt(hdr2log_mst_stream_pkt), .str("Expected HDR2LOG Started"));

      if (m_hdr2log_last_cycle_time != -1 && m_hdr2log_last_cycle_time != $time) begin
        cover_hdr2log_ports_active_cycle_combinations(.ports_active_in_cycle(m_hdr2log_ports_active_in_cycle));
        m_hdr2log_ports_active_in_cycle = 0;
      end
      m_hdr2log_last_cycle_time                     = $time ;
      m_hdr2log_ports_active_in_cycle[hls_port_num] = 1     ;

    end
  endtask : process_hdr2log_mst_started

  //----------------------------------------------------------------------------
  // Task: process_hdr2log_mst_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_hdr2log_mst_ended(string msg_id = "", int unsigned hls_port_num);
    string                   l_msg_id = {msg_id, $sformatf("[process_hdr2log_mst_ended[%0d]]", hls_port_num)} ;
    denaliStreamTransaction  hdr2log_mst_stream_pkt                                                           ;
    int unsigned             curr_byte_arr_size                                                               ;
    int unsigned             new_byte_arr_size                                                                ;
    int unsigned             tuser_beat_bytes                                                                 ;
    
    forever begin
      // -- Get the pkt from Stream VIP Callback ----------------------
      m_hdr2log_mst_ended_af[hls_port_num].get(hdr2log_mst_stream_pkt);
            
      //- Print AXI Stream packet ----------------------------------------------
       print_axi_stream(.msg_id(l_msg_id), .stream_pkt(hdr2log_mst_stream_pkt), .str("Expected HDR2LOG"));
      
      //-- As per PCIE-19170 in case of 2 Ports if 1 sends data of 512bits and the core is side 1024 bits so the DUT will add 0s for the remaining 512 bits.
     curr_byte_arr_size = hdr2log_mst_stream_pkt.PacketData.size();
     new_byte_arr_size  = ((curr_byte_arr_size + (parameters_cfg_pkg::KMAX_DATAPATH_WD/8) - 1)   
                          / (parameters_cfg_pkg::KMAX_DATAPATH_WD/8))                             
                          * (parameters_cfg_pkg::KMAX_DATAPATH_WD/8);         
      hdr2log_mst_stream_pkt.PacketData = new[new_byte_arr_size](hdr2log_mst_stream_pkt.PacketData);
      foreach(hdr2log_mst_stream_pkt.PacketData[i]) begin
        if(i >= curr_byte_arr_size) begin
          hdr2log_mst_stream_pkt.PacketData[i] = 0;
        end
      end

      if (hdr2log_mst_stream_pkt.Length > 1 && (parameters_cfg_pkg::HLS_PORT_DATA_WIDTH_ARR[hls_port_num*32 +: 32] < parameters_cfg_pkg::KMAX_DATAPATH_WD) && (parameters_cfg_pkg::HLS_PORT_DATA_WIDTH_ARR[hls_port_num*32 +: 32] < 512)) begin
  	int unsigned l_total_tuser_bytes;
  	int unsigned l_last_beat_offset;
 	l_total_tuser_bytes = hdr2log_mst_stream_pkt.TuserArray.size();
        tuser_beat_bytes     = l_total_tuser_bytes / hdr2log_mst_stream_pkt.Length;
        l_last_beat_offset   = l_total_tuser_bytes - tuser_beat_bytes;
 
  	for (int i = 0; i < tuser_beat_bytes; i++) begin
   	   hdr2log_mst_stream_pkt.TuserArray[i] = hdr2log_mst_stream_pkt.TuserArray[l_last_beat_offset + i];
 	 end
 	 hdr2log_mst_stream_pkt.TuserArray = new[tuser_beat_bytes](hdr2log_mst_stream_pkt.TuserArray);
 	 hdr2log_mst_stream_pkt.Length     = 1;
	end
  
      //-- Masking Unwanted fields since these are not present in the interface --
      hdr2log_mst_stream_pkt.TstrbArray.delete();
      hdr2log_mst_stream_pkt.TkeepArray.delete();
      hdr2log_mst_stream_pkt.Id   = 0;
      hdr2log_mst_stream_pkt.Dest = 0;

      //- Push packet to scoreboard --------------------------------------------
      // As per PCIE-19839 the order of hdr2log pkts doesn't matter.
      m_hdr2log_stream_scoreboard.write_expected_tr(hdr2log_mst_stream_pkt);
      
      // - Increment Total Pkt Sent Counter ------------------------------------
      m_total_num_pkts_sent++;
    end

  endtask : process_hdr2log_mst_ended

  //----------------------------------------------------------------------------
  // Task: process_hdr2log_slv_ended
  //----------------------------------------------------------------------------
  virtual task process_hdr2log_slv_ended(string msg_id = "");
    string l_msg_id = {msg_id, "[process_hdr2log_slv_ended]"};
    denaliStreamTransaction  hdr2log_slv_stream_pkt     ;
    
    forever begin
      m_hdr2log_slv_ended_af.get(hdr2log_slv_stream_pkt);
      
      //- Print AXI Stream packet ------------------------------------------------
      print_axi_stream(.msg_id(l_msg_id), .stream_pkt(hdr2log_slv_stream_pkt), .str("Received HDR2LOG"));
     
      //-- Masking Unwanted fields since these are not present in the interface --
      hdr2log_slv_stream_pkt.TstrbArray.delete();
      hdr2log_slv_stream_pkt.TkeepArray.delete();
      hdr2log_slv_stream_pkt.Id   = 0;
      hdr2log_slv_stream_pkt.Dest = 0;
    
      //- Push packet to scoreboard --------------------------------------------
      m_hdr2log_stream_scoreboard.write_received_tr(hdr2log_slv_stream_pkt);
    end
  endtask : process_hdr2log_slv_ended

  //----------------------------------------------------------------------------
  // Task: process_lti_ctag_tx_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_lti_ctag_tx_ended(string msg_id = "", int unsigned hls_port_num);
    string                    l_msg_id = {msg_id, $sformatf("[process_lti_ctag_tx_ended[%0d]]", hls_port_num)} ;
    denaliStreamTransaction   lti_ctag_tx_stream_pkt                                                           ;
    
      forever begin
      // -- Get the pkt from Stream Callback ----------------------       
      m_lti_ctag_tx_ended_af[hls_port_num].get(lti_ctag_tx_stream_pkt);
  
      //- Print AXI Stream packet ----------------------------------------------
      print_axi_stream(.msg_id(l_msg_id), .stream_pkt(lti_ctag_tx_stream_pkt), .str("Expected LTI CTAG Before Sending to Predictor"));
     
      //- Incrementing expected lti counter --------------------------------------
      m_total_expected_lti_count[lti_ctag_tx_stream_pkt.PacketData[1][0]][lti_ctag_tx_stream_pkt.PacketData[1][2:1]] += lti_ctag_tx_stream_pkt.PacketData[0][7:0];  

      //- Sending to LTI CTag Predictor --------------------------------------------
      // packets with couter == 0 are ignored by DUT
      if ({lti_ctag_tx_stream_pkt.PacketData[1][7:0],lti_ctag_tx_stream_pkt.PacketData[0][7:0]} > 0) begin
        lti_ctag_tx_stream_pkt_ended_ap[hls_port_num].write(lti_ctag_tx_stream_pkt);
      end

      //- Calling Coverage callbacks -------------------------------------------      
      cover_lti_ctag_tx_stream(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .lti_data(lti_ctag_tx_stream_pkt.PacketData));      
      
      // - Increment Total Pkt Sent Counter ------------------------------------
      m_total_num_pkts_sent++;
    end
  endtask : process_lti_ctag_tx_ended

  //----------------------------------------------------------------------------
  // Task: process_lti_ctag_rx_ended
  //----------------------------------------------------------------------------
  virtual task process_lti_ctag_rx_ended(string msg_id = "");
    string l_msg_id = {msg_id, "[process_lti_ctag_rx_ended]"};
    denaliStreamTransaction  lti_ctag_rx_stream_pkt;
    
    forever begin     
      //--Get the pkt from Stream Callback------------------------------------
      m_lti_ctag_rx_ended_af.get(lti_ctag_rx_stream_pkt); 
            
      //- Print AXI Stream packet ------------------------------------------------
      print_axi_stream(.msg_id(l_msg_id), .stream_pkt(lti_ctag_rx_stream_pkt), .str("Received LTI CTAG"));
      
      if (parameters_cfg_pkg::LTI_SUPPORT == 0)
        `uvm_error(l_msg_id, "Pkts can only be received on LTI Interface if LTI_SUPPORT = 1.")
      
      if (lti_ctag_rx_stream_pkt.PacketData[1][2:1] > (parameters_cfg_pkg::NUM_LTI_PORTS - 1))
        `uvm_error(l_msg_id, $sformatf("Received a pkt on lti_ctag_tx interface with LTI-PortID: %0d greater than the max supported LTI-PortID: %0d", lti_ctag_rx_stream_pkt.PacketData[1][2:1], (parameters_cfg_pkg::NUM_LTI_PORTS-1)));
      
      //-- Masking Unwanted fields since these are not present in the interface --
      lti_ctag_rx_stream_pkt.TuserArray.delete();
      lti_ctag_rx_stream_pkt.TstrbArray.delete();
      lti_ctag_rx_stream_pkt.TkeepArray.delete();
      lti_ctag_rx_stream_pkt.Id   = 0;
      lti_ctag_rx_stream_pkt.Dest = 0;

      //- Incrementing received lti counter --------------------------------------
      m_total_received_lti_count[lti_ctag_rx_stream_pkt.PacketData[1][0]][lti_ctag_rx_stream_pkt.PacketData[1][2:1]] += lti_ctag_rx_stream_pkt.PacketData[0][7:0];  
      
      //- Checking if there is any unexpected lti completion received for a particular CTag, PortID. -----------------------
      if (m_total_received_lti_count[lti_ctag_rx_stream_pkt.PacketData[1][0]][lti_ctag_rx_stream_pkt.PacketData[1][2:1]] > m_total_expected_lti_count[lti_ctag_rx_stream_pkt.PacketData[1][0]][lti_ctag_rx_stream_pkt.PacketData[1][2:1]]) begin
        `uvm_error(l_msg_id, $sformatf("Number of Received LTI Count is greater than the Number of Expected LTI Count for CTag: %0d PortID: %0d. Expected Count: %0d Received Count: %0d", lti_ctag_rx_stream_pkt.PacketData[1][0], lti_ctag_rx_stream_pkt.PacketData[1][2:1], m_total_expected_lti_count[lti_ctag_rx_stream_pkt.PacketData[1][0]][lti_ctag_rx_stream_pkt.PacketData[1][2:1]], m_total_received_lti_count[lti_ctag_rx_stream_pkt.PacketData[1][0]][lti_ctag_rx_stream_pkt.PacketData[1][2:1]]));
      end

      //-- For internally generated LTI Completion in case of MSI Packets it is difficult to predict due to the time at which the DUT processes this packet
      //-- whereas when the TB does it. Hence excluding the scoreboarding for this case. Only checking that the count of each ctag and portID
      //-- Combination at the end of test should be enough. 
      if(parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 0 ) begin
        //- Push packet to scoreboard ----------------------------------------------
        m_lti_ctag_stream_scoreboard.write_received_tr(lti_ctag_rx_stream_pkt); 
      end

      //- Calling Coverage callbacks -------------------------------------------      
      cover_lti_ctag_rx_stream(.msg_id(l_msg_id), .lti_data(lti_ctag_rx_stream_pkt.PacketData));       
    end
  endtask : process_lti_ctag_rx_ended

  //----------------------------------------------------------------------------
  // Task: send_predicted_lti_ctag_tx_pkt
  //----------------------------------------------------------------------------
  virtual task send_predicted_lti_ctag_tx_pkt(string msg_id = "");
    string                    l_msg_id = {msg_id, "[send_predicted_lti_ctag_tx_pkt]"} ;
    denaliStreamTransaction   lti_ctag_tx_stream_pkt                                  ;
    
      forever begin
      // -- Get the pkt from LTI Predictor -------------------------------------       
      m_predicted_lti_ctag_tx_af.get(lti_ctag_tx_stream_pkt);
  
      //- Print AXI Stream packet ----------------------------------------------
      print_axi_stream(.msg_id(l_msg_id), .stream_pkt(lti_ctag_tx_stream_pkt), .str("Expected LTI CTAG"));
     
      //-- For internally generated LTI Completion in case of MSI Packets it is difficult to predict due to the time at which the DUT processes this packet
      //-- whereas when the TB does it. Hence excluding the scoreboarding for this case. Only checking that the count of each ctag and portID
      //-- Combination at the end of test should be enough. 
      if(parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 0) begin
        //- Push packet to scoreboard --------------------------------------------
        m_lti_ctag_stream_scoreboard.write_expected_tr(lti_ctag_tx_stream_pkt);
      end
    end
  endtask : send_predicted_lti_ctag_tx_pkt

  //----------------------------------------------------------------------------
  // Task: process_axis_msi_slv_ended
  //----------------------------------------------------------------------------
  virtual task process_axis_msi_slv_ended(string msg_id = "");
    string                   l_msg_id = {msg_id, "[process_axis_msi_slv_ended]"}     ;
    bit [1:0]                l_strap_port_type                                       ;
    denaliStreamTransaction  msi_lti_c_stream_pkt;
    denaliStreamTransaction  msi_stream_pkt;
    
    forever begin     
      //--Get the pkt from Stream Callback------------------------------------
      m_axis_msi_slv_ended_af.get(msi_stream_pkt); 
      m_env_cfg.m_k_if_api.get_strap_port_type(l_strap_port_type); 
      
      //- Print AXI Stream packet ------------------------------------------------
      print_axi_stream(.msg_id(l_msg_id), .stream_pkt(msi_stream_pkt), .str("Received MSI"));
      
      if (parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 0 || l_strap_port_type != 2'b01)
        `uvm_error(l_msg_id, "Pkts can only be received on MSI Interface if KMAX_MSI_IF_SUPPORT = 1 && DUT is RP.")

      //-- Masking Unwanted fields since these are not present in the interface --
      msi_stream_pkt.TstrbArray.delete();
      msi_stream_pkt.TuserArray.delete();
      msi_stream_pkt.TkeepArray.delete();
      msi_stream_pkt.Id   = 0;
      msi_stream_pkt.Dest = 0;
      
      //- Push packet to scoreboard --------------------------------------------
      m_msi_stream_scoreboard.write_received_tr(msi_stream_pkt);
`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
      msi_clk_gater_vif.unfinished_packets--;
`endif

      //-- Send to IB Posted Order Checker -------------------------------------
      msi_ib_posted_pkt_ended_ap.write(msi_stream_pkt);

      //-- DUT sends the MSI Packet in the same order as it received on the IB Posted HAL Interface ---
      //-- Generate LTI Completion if bypass_axi_atu = 1 && LTI is present ----------------------------
      if(parameters_cfg_pkg::LTI_SUPPORT == 1 && m_exp_msi_lti_c_tracker_q[0].bypass_axi_atu) begin
        
        //-- Generate LTI Completion for MSI -----------------------
        generate_msi_lti_compl(.lrctag(m_exp_msi_lti_c_tracker_q[0].lrctag), .lti_port_num(m_exp_msi_lti_c_tracker_q[0].lti_port_num), .count(1), .msi_lti_c_stream_pkt(msi_lti_c_stream_pkt));
        
        //-- Print packet -----------------------------------------
        print_axi_stream(.msg_id(l_msg_id), .stream_pkt(msi_lti_c_stream_pkt), .str("Expected LTI CTAG for MSI Before Sending to Predictor"));
        
        //- Incrementing expected lti counter --------------------------------------
        m_total_expected_lti_count[msi_lti_c_stream_pkt.PacketData[1][0]][msi_lti_c_stream_pkt.PacketData[1][2:1]] += msi_lti_c_stream_pkt.PacketData[0][7:0];  
        
        //- Sending to LTI CTag Predictor --------------------------------------------
        lti_ctag_tx_stream_pkt_ended_ap[parameters_cfg_pkg::NUM_HLS_PORTS].write(msi_lti_c_stream_pkt);
      end
      void'(m_exp_msi_lti_c_tracker_q.pop_front());

      //- Calling Coverage callbacks -------------------------------------------      
    end
  endtask : process_axis_msi_slv_ended

  //----------------------------------------------------------------------------
  // Task: process_dc_mst_ended (Per Port)
  //----------------------------------------------------------------------------
  virtual task process_dc_mst_ended(string msg_id = "", int unsigned hls_port_num);
    string                   l_msg_id = {msg_id, $sformatf("[process_dc_mst_ended[%0d]]", hls_port_num)} ;
    denaliStreamTransaction  dc_mst_stream_pkt                                                           ;
    bit                      l_any_dbg_dis_order_chk                                                     ;
    
    forever begin
      // -- Get the pkt from Stream VIP Callback ----------------------
      m_dc_mst_ended_af[hls_port_num].get(dc_mst_stream_pkt);
      
      //-- Check if any order checking disabled ----------------------------------
      l_any_dbg_dis_order_chk = hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value() || hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value() || hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_msi.get_mirrored_value();
            
      //- Print AXI Stream packet --------------------------------------
      print_axi_stream(.msg_id(l_msg_id), .stream_pkt(dc_mst_stream_pkt), .str("Expected Delivered Count"));
     
      //-- Masking Unwanted fields since these are not present in the interface --
      dc_mst_stream_pkt.TuserArray.delete();
      dc_mst_stream_pkt.TstrbArray.delete();
      dc_mst_stream_pkt.TkeepArray.delete();
      dc_mst_stream_pkt.Id   = 0;
      dc_mst_stream_pkt.Dest = 0;
      
      //- Incrementing expected delivered counter --------------------------------------
      m_total_expected_delivered_count[dc_mst_stream_pkt.PacketData[1][3:1]] += {dc_mst_stream_pkt.PacketData[1][0], dc_mst_stream_pkt.PacketData[0][7:0]};
      `uvm_info(get_type_name(), $sformatf("[HLSB DC] m_total_expected_delivered_count = %p", m_total_expected_delivered_count), UVM_DEBUG)
      
      //- Push packet to scoreboard ----------------------------------------------
      //- If order checking is disabled, do not send the delivered count to the scoreboard.This is because the RTL simply adds the delivered count value, making prediction difficult.
      //- It's not possible to predict when the delivered count module will process the MSI Delivered Count value which is generated internally in the design.
      //- Therefore, instead of checking each individual packet, it should be sufficient to verify that the received and expected delivered counts match at the end of the test.
      if(l_any_dbg_dis_order_chk == 0 && parameters_cfg_pkg::NUM_HLS_PORTS == 1) begin
        m_dc_stream_scoreboard.write_expected_tr(dc_mst_stream_pkt);
      end

      //-- Send the delivered count to the IB Posted Order Checker. ---------- 
      axi_delivered_count_pkt_ended_ap[hls_port_num].write(dc_mst_stream_pkt);

      //- Calling Coverage callbacks -------------------------------------------      
      cover_dc_tdata_mst(.hls_port_num(hls_port_num), .dc_data(dc_mst_stream_pkt.PacketData[0]));

      // Coverage for each active port
      if (m_dc_last_cycle_time != -1 && m_dc_last_cycle_time != $time) begin
        cover_dc_ports_active_cycle_combinations(m_dc_ports_active_in_cycle);
        m_dc_ports_active_in_cycle = 0;
      end
      m_dc_last_cycle_time                 = $time;
      m_dc_ports_active_in_cycle[hls_port_num] = 1; 
    end

  endtask : process_dc_mst_ended

  //----------------------------------------------------------------------------
  // Task: process_dc_slv_ended
  //----------------------------------------------------------------------------
  virtual task process_dc_slv_ended(string msg_id = "");
    string                   l_msg_id = {msg_id, "[process_dc_slv_ended]"};
    denaliStreamTransaction  dc_slv_stream_pkt                            ;
    bit                      l_any_dbg_dis_order_chk                      ;
    bit[2:0]                 l_stream;

    forever begin
      m_dc_slv_ended_af.get(dc_slv_stream_pkt);
      
      //-- Check if any order checking disabled ----------------------------------
      l_any_dbg_dis_order_chk = hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value() || hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value() || hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_msi.get_mirrored_value();
      
      //- Print AXI Stream packet ------------------------------------------------
      print_axi_stream(.msg_id(l_msg_id), .stream_pkt(dc_slv_stream_pkt), .str("Received Delivered Count"));
      
      //-- Masking Unwanted fields since these are not present in the interface --
      dc_slv_stream_pkt.TuserArray.delete();
      dc_slv_stream_pkt.TstrbArray.delete();
      dc_slv_stream_pkt.TkeepArray.delete();
      dc_slv_stream_pkt.Id   = 0;
      dc_slv_stream_pkt.Dest = 0;

      l_stream = dc_slv_stream_pkt.PacketData[1][3:1];
      
      //- Incrementing received delivered counter --------------------------------------
      m_total_received_delivered_count[l_stream] += {dc_slv_stream_pkt.PacketData[1][0], dc_slv_stream_pkt.PacketData[0][7:0]};
      `uvm_info(get_type_name(), $sformatf("[HLSB DC] m_total_received_delivered_count = %p", m_total_received_delivered_count), UVM_DEBUG)
      
      //- Checking if there is any unexpected Delivered Count received. -----------------------
      if(m_total_received_delivered_count[l_stream] > m_total_expected_delivered_count[l_stream]) begin
        `uvm_error(l_msg_id, $sformatf("Number of Received Delivered Count is greater than the Number of Expected Delivered Count on stream %0d. Expected Count: %0d Received Count: %0d", l_stream, m_total_expected_delivered_count[l_stream], m_total_received_delivered_count[l_stream]));
      end

      //- Push packet to scoreboard ----------------------------------------------
      //- If order checking is disabled, do not send the delivered count to the scoreboard.This is because the RTL simply adds the delivered count value, making prediction difficult.
      //- It's not possible to predict when the delivered count module will process the MSI Delivered Count value which is generated internally in the design.
      //- Therefore, instead of checking each individual packet, it should be sufficient to verify that the received and expected delivered counts match at the end of the test.
      if(l_any_dbg_dis_order_chk == 0 && parameters_cfg_pkg::NUM_HLS_PORTS == 1) begin
        m_dc_stream_scoreboard.write_received_tr(dc_slv_stream_pkt);
      end

      //- Calling Coverage callbacks -------------------------------------------      
      cover_dc_tdata_slv(.dc_data(dc_slv_stream_pkt.PacketData[0]));
    end

  endtask : process_dc_slv_ended

  //----------------------------------------------------------------------------
  // Task: process_m_axi_mst_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_axi_mst_pkt_ended(string msg_id = "");
    string l_msg_id = {msg_id, "[process_axi_mst_pkt_ended]"};
    denaliCdn_axiTransaction axi_lite_mst_pkt;
    
    forever begin
      m_axi_mst_pkt_ended_af.get(axi_lite_mst_pkt);
      
      //- Print AXI Lite packet -----------------------------------------------------
      if (axi_lite_mst_pkt.Type==DENALI_CDN_AXI_TR_Write)
        print_axi_lite_pkt(.msg_id(l_msg_id), .axi_lite_pkt(axi_lite_mst_pkt), .str("Expected"));
        
      else if (axi_lite_mst_pkt.Type==DENALI_CDN_AXI_TR_Read)
        print_axi_lite_pkt(.msg_id(l_msg_id), .axi_lite_pkt(axi_lite_mst_pkt), .str("Received"));
      
      //- Push packet to scoreboard --------------------------------------------
      if(axi_lite_mst_pkt.StartAddress >= 'h2000000) begin // Base Address for AXI Bridge is 'h2000000
        axi_lite_mst_pkt.StartAddress = axi_lite_mst_pkt.StartAddress - 'h2000000;
        if(parameters_cfg_pkg::ASF_SUPPORT >= 2) begin // If ASF Support is present then need to regenerate the Address Check. 
          foreach(axi_lite_mst_pkt.AddrCheck[i]) begin
            if(i < (HLS_BRIDGE_AXIL_ADDR_PARITY_WIDTH)) begin
              axi_lite_mst_pkt.AddrCheck[i] = ~(^axi_lite_mst_pkt.StartAddress[i*8 +: 8]);
            end
            else begin
              axi_lite_mst_pkt.AddrCheck[i] = 0;
            end
          end
        end
        if (axi_lite_mst_pkt.Type==DENALI_CDN_AXI_TR_Write)
          m_axi_reg_access_scoreboard.write_expected_tr(axi_lite_mst_pkt);
        else if (axi_lite_mst_pkt.Type==DENALI_CDN_AXI_TR_Read)
          m_axi_reg_access_scoreboard.write_received_tr(axi_lite_mst_pkt);
      
        // - Increment Total Pkt Sent Counter ------------------------------------
        m_total_num_pkts_sent++;

        // - Calling coverage callbacks -----------------------------------
        cover_axi_mst_resp(axi_lite_mst_pkt);
      end
    end
  endtask : process_axi_mst_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_m_axi_slv_pkt_ended
  //----------------------------------------------------------------------------
  virtual task process_axi_slv_pkt_ended(string msg_id = "");
    string l_msg_id = {msg_id, "[process_axi_slv_pkt_ended]"};
    denaliCdn_axiTransaction axi_lite_slv_pkt;
    
    forever begin
      m_axi_slv_pkt_ended_af.get(axi_lite_slv_pkt);
      
      if (axi_lite_slv_pkt.Type==DENALI_CDN_AXI_TR_Write) begin
        //- Print AXI Lite packet -----------------------------------------------------
        print_axi_lite_pkt(.msg_id(l_msg_id), .axi_lite_pkt(axi_lite_slv_pkt), .str("Received"));
        
        //- Push packet to scoreboard --------------------------------------------
        m_axi_reg_access_scoreboard.write_received_tr(axi_lite_slv_pkt);
      end
      else if (axi_lite_slv_pkt.Type==DENALI_CDN_AXI_TR_Read) begin
        //- Print AXI Lite packet -----------------------------------------------------
        print_axi_lite_pkt(.msg_id(l_msg_id), .axi_lite_pkt(axi_lite_slv_pkt), .str("Expected"));
        
        //- Push packet to scoreboard --------------------------------------------
        m_axi_reg_access_scoreboard.write_expected_tr(axi_lite_slv_pkt);
      end

      // - Calling coverage callbacks -----------------------------------
      cover_axi_slv_resp(axi_lite_slv_pkt);      

    end
  endtask : process_axi_slv_pkt_ended
  
  //----------------------------------------------------------------------------
  // Function: perform_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_RESET", $sformatf("Started resetting cdn_pcie_hls_bridge_monitor(%0s) component.....", get_full_name()), UVM_DEBUG)
    
    //-- Scoreboards Reset -----------------------------
    m_hls_ob_posted_cxs_scoreboard.m_reset_ev.trigger(); 
    m_hls_ob_nonposted_cxs_scoreboard.m_reset_ev.trigger(); 
    m_hls_ob_compl_cxs_scoreboard.m_reset_ev.trigger(); 

`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      m_hls_ib_posted_dti_scoreboard.m_reset_ev.trigger();
      m_hls_ib_nonposted_dti_scoreboard.m_reset_ev.trigger();
    end
`endif

    foreach(m_hls_ib_posted_cxs_scoreboard[loop_port])
      m_hls_ib_posted_cxs_scoreboard[loop_port].m_reset_ev.trigger(); 
    foreach(m_hls_ib_nonposted_cxs_scoreboard[loop_port])
      m_hls_ib_nonposted_cxs_scoreboard[loop_port].m_reset_ev.trigger(); 
    foreach(m_hls_ib_compl_cxs_scoreboard[loop_port])
      m_hls_ib_compl_cxs_scoreboard[loop_port].m_reset_ev.trigger(); 
    
    m_hdr2log_stream_scoreboard.m_reset_ev.trigger();
    m_lti_ctag_stream_scoreboard.m_reset_ev.trigger();
    m_dc_stream_scoreboard.m_reset_ev.trigger();
    m_msi_stream_scoreboard.m_reset_ev.trigger();

    //-- TLM FIFOs Reset ------------------------------
    m_hls_ob_posted_hal_pkt_ended_af.flush();
    m_hls_ob_nonposted_hal_pkt_ended_af.flush();
    m_hls_ob_compl_hal_pkt_ended_af.flush();
    
    m_hls_ib_posted_hal_pkt_ended_af.flush();
    m_hls_ib_nonposted_hal_pkt_ended_af.flush();
    m_hls_ib_compl_hal_pkt_ended_af.flush();

`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      m_hls_ib_posted_dti_pkt_ended_af.flush();
      m_hls_ib_nonposted_dti_pkt_ended_af.flush();
      m_hls_ob_posted_dti_pkt_started_af.flush();
      m_hls_ob_posted_dti_pkt_ended_af.flush();
      m_hls_ob_compl_dti_pkt_started_af.flush();
      m_hls_ob_compl_dti_pkt_ended_af.flush();
      m_hdr2log_dti_ended_af.flush();
      m_dc_dti_ended_af.flush();
    end
`endif

    foreach(m_hls_ob_posted_axi_pkt_started_af[loop_port])
      m_hls_ob_posted_axi_pkt_started_af[loop_port].flush();
    foreach(m_hls_ob_posted_axi_pkt_ended_af[loop_port])
      m_hls_ob_posted_axi_pkt_ended_af[loop_port].flush();
    m_predicted_hls_ob_posted_axi_af.flush();
    
    foreach(m_hls_ob_nonposted_axi_pkt_started_af[loop_port])
      m_hls_ob_nonposted_axi_pkt_started_af[loop_port].flush();
    foreach(m_hls_ob_nonposted_axi_pkt_ended_af[loop_port])
      m_hls_ob_nonposted_axi_pkt_ended_af[loop_port].flush();
    m_predicted_hls_ob_nonposted_axi_af.flush();
  
    foreach(m_hls_ob_compl_axi_pkt_started_af[loop_port])
      m_hls_ob_compl_axi_pkt_started_af[loop_port].flush();
    foreach(m_hls_ob_compl_axi_pkt_ended_af[loop_port])
      m_hls_ob_compl_axi_pkt_ended_af[loop_port].flush();
    m_predicted_hls_ob_compl_axi_af.flush();

    foreach(m_hls_ib_posted_axi_pkt_ended_af[loop_port]) 
      m_hls_ib_posted_axi_pkt_ended_af[loop_port].flush();
    foreach(m_hls_ib_nonposted_axi_pkt_ended_af[loop_port])
      m_hls_ib_nonposted_axi_pkt_ended_af[loop_port].flush();
    foreach(m_hls_ib_compl_axi_pkt_ended_af[loop_port])
      m_hls_ib_compl_axi_pkt_ended_af[loop_port].flush();
 
    m_hdr2log_slv_ended_af.flush();
    foreach(m_hdr2log_mst_started_af[loop_port])
      m_hdr2log_mst_started_af[loop_port].flush();
    foreach(m_hdr2log_mst_ended_af[loop_port])
      m_hdr2log_mst_ended_af[loop_port].flush();

    m_lti_ctag_rx_ended_af.flush();
    foreach(m_lti_ctag_tx_ended_af[loop_port])
      m_lti_ctag_tx_ended_af[loop_port].flush();
    m_predicted_lti_ctag_tx_af.flush();

    m_axis_msi_slv_ended_af.flush();
    
    m_dc_slv_ended_af.flush();
    foreach(m_dc_mst_ended_af[loop_port])
      m_dc_mst_ended_af[loop_port].flush();
    
    m_axi_mst_pkt_ended_af.flush();
    m_axi_slv_pkt_ended_af.flush();
    if(m_env_cfg.m_qos_support) begin 
       m_qos_slv_ended_af.flush();
       foreach (m_qos_expected_count[g]) m_qos_expected_count[g] = 0;
       foreach (m_qos_observed_count[g]) m_qos_observed_count[g] = 0;
       foreach (m_qos_mst_ended_af[i])   m_qos_mst_ended_af[i].flush();
    end      
    //-- Local Variables Reset ------------------------------
    m_hdr2log_ports_active_in_cycle = 32'b0;
    m_hdr2log_last_cycle_time = -1;
    m_total_num_pkts_sent = 0;
    foreach(m_total_expected_lti_count[loop_ctag, loop_lti_port])
      m_total_expected_lti_count[loop_ctag][loop_lti_port] = 0;
    foreach(m_total_received_lti_count[loop_ctag, loop_lti_port])
      m_total_received_lti_count[loop_ctag][loop_lti_port] = 0;
    foreach(m_total_expected_delivered_count[i])
      m_total_expected_delivered_count[i] = 0;
    foreach(m_total_received_delivered_count[i])
      m_total_received_delivered_count[i] = 0;
    m_exp_msi_lti_c_tracker_q.delete();

    m_ob_p_ports_active = 0;
    m_ob_np_ports_active = 0;
    m_ob_compl_ports_active = 0;
    m_dc_ports_active_in_cycle = 0;

    if (is_linkdown == 0) begin
      credit_lmt_p_reset();
      credit_lmt_np_reset();
    end

    `uvm_info("PERFORM_RESET", $sformatf("Completed resetting cdn_pcie_hls_bridge_monitor(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_reset

  //----------------------------------------------------------------------------
  // Function: perform_axil_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_axil_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Started axil resetting cdn_pcie_hls_bridge_monitor(%0s) component.....", get_full_name()), UVM_DEBUG)
    m_axi_reg_access_scoreboard.m_reset_ev.trigger();
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Completed axil resetting cdn_pcie_hls_bridge_monitor(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_axil_reset

  // Reset P credits values during a reset
  virtual task credit_lmt_p_reset();
    for (int vc=0; vc<parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
      crd_m_p_header_q[vc] = {};
      crd_m_p_payload_q[vc] = {};
      crd_used_p_header_q[vc] = {};
      crd_used_p_payload_q[vc] = {};
      current_s_credits_p_header[vc] = 0;
      current_s_credits_p_payload[vc] = 0;
      current_m_credits_p_header[vc] = 0;
      current_m_credits_p_payload[vc] = 0;
    end
  endtask : credit_lmt_p_reset

  // Reset NP credits values during a reset
  virtual task credit_lmt_np_reset();
    for (int vc=0; vc<parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
      crd_m_np_header_q[vc] = {};
      crd_m_np_payload_q[vc] = {};
      current_s_credits_np_header[vc] = 0;
      current_s_credits_np_payload[vc] = 0;
      current_m_credits_np_header[vc] = 0;
      current_m_credits_np_payload[vc] = 0;
    end
  endtask : credit_lmt_np_reset

  //----------------------------------------------------------------------------
  // Helper methods
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  // Function: print_tlp
  //----------------------------------------------------------------------------
  function void print_tlp(string msg_id = "", cdn_hpa_pcie_tlp tlp_pkt, string str = "Expected");
    `uvm_info(msg_id, $sformatf("%0s TLP:\n %0s", str, tlp_pkt.sprint()), UVM_DEBUG)
  endfunction : print_tlp

  //----------------------------------------------------------------------------
  // Function: print_cxs
  //----------------------------------------------------------------------------
  function void print_cxs(string msg_id = "", denaliCxsTransaction cxs_pkt, string str = "Expected");
    `uvm_info(msg_id, $sformatf("%0s CXS:\n %0s", str, cxs_pkt.sprint()), UVM_DEBUG)
  endfunction : print_cxs
 
  //----------------------------------------------------------------------------
  // Function: print_axi_stream
  //----------------------------------------------------------------------------
  function void print_axi_stream(string msg_id = "", denaliStreamTransaction stream_pkt, string str = "Expected");
    `uvm_info(msg_id, $sformatf("%0s STREAM:\n %0s", str, stream_pkt.sprint()), UVM_DEBUG)
  endfunction : print_axi_stream

 //----------------------------------------------------------------------------
  // Function: print_axi_lite_pkt
  //----------------------------------------------------------------------------
  function void print_axi_lite_pkt(string msg_id = "", denaliCdn_axiTransaction axi_lite_pkt, string str = "Expected");
    `uvm_info(msg_id, $sformatf("%0s AXI LITE PKT:\n %0s", str, axi_lite_pkt.sprint()), UVM_DEBUG)
  endfunction : print_axi_lite_pkt

//----------------------------------------------------------------------------
  // Task: convert_cxs2tlp
  //----------------------------------------------------------------------------
  task convert_cxs2tlp(string msg_id = "", bit is_rx, denaliCxsTransaction cxs_pkt, ref cdn_hpa_pcie_tlp tlp_pkt);
    string l_msg_id = {msg_id, "[convert_cxs2tlp]"};
    darray_of_ubytes_t  tlp_data_stream;
    bit [1:0]           l_misc_flit_mode;
    bit                 l_misc_pbr_negotiated;

    m_env_cfg.m_misc_if_api.get_misc_flit_mode(l_misc_flit_mode);
    m_env_cfg.m_misc_if_api.get_misc_pbr_negotiated(l_misc_pbr_negotiated);
    
    //- Retrieve the data stream ----------------------------------
    if (is_rx)
      tlp_data_stream = darray_of_ubytes_t'(cxs_pkt.DataPerPktRx);
    else
      tlp_data_stream = darray_of_ubytes_t'(cxs_pkt.DataPerPktTx);

    //- Create the tlp object -------------------------------------
    tlp_pkt = cdn_hpa_pcie_tlp::type_id::create("tlp_pkt");
    tlp_pkt.hpa_generation     = hpa_generation_2;
    tlp_pkt.is_flit_mode       = (l_misc_flit_mode == 2'b10);
    tlp_pkt.is_cxl_pbr_mode    = l_misc_pbr_negotiated;
    tlp_pkt.pcie_6_1_support   = 1;
    tlp_pkt.unpack_prefix      = 1;
    tlp_pkt.unpack_ecrc        = 1;
    tlp_pkt.unpack_ide_trailer = 0;
    tlp_pkt.pack_prefix        = 1;
    tlp_pkt.pack_ecrc          = 1;
    tlp_pkt.pack_ecrc_local    = 1;

    //- Unpack TLP from data stream -------------------------------
    if (!tlp_pkt.unpack_bytes(tlp_data_stream))
      `uvm_fatal(l_msg_id, "Unpack of TLP Bytes failed.")

    // workaround m_tph_presend is not unpacked
    tlp_pkt.m_tph_present = tlp_pkt.m_tlp_th;
    
    //- Packing data stream to m_data -----------------------------
    tlp_pkt.m_data = new[tlp_data_stream.size()](tlp_data_stream);

  endtask : convert_cxs2tlp
  
  //----------------------------------------------------------------------------
  // Task: convert_tlp2msistream
  // Converts the TLP Pkt into a MSI Stream Transaction.
  //----------------------------------------------------------------------------
  task convert_tlp2msistream(string msg_id = "", cdn_hpa_pcie_tlp tlp_pkt, ref denaliStreamTransaction msi_stream_pkt);
    bit [8:0]                           l_lm_segment_num;
    bit [1:0]                            l_misc_flit_mode;
    cdn_pcie_hls_bridge_msi_lti_c_info_s l_msi_lti_info;

    m_env_cfg.m_misc_if_api.get_lm_segment_num(l_lm_segment_num);
    m_env_cfg.m_misc_if_api.get_misc_flit_mode(l_misc_flit_mode);

    //- Create the Stream object -------------------------------------
    msi_stream_pkt = denaliStreamTransaction::type_id::create("msi_stream_pkt");
    msi_stream_pkt.Type          = DENALI_STREAM_TR_Packet;
    msi_stream_pkt.Id            = 0;
    msi_stream_pkt.Dest          = 0;
    msi_stream_pkt.Length        = 1;
    msi_stream_pkt.PacketData    = new[parameters_cfg_pkg::KMAX_MSI_TDATA_WIDTH / 8];

    /*
    There is bit(hls_bridge_msi_gic_use_seg) in register(hls_bridge_msi_gic_cfg) that configurate data payload for GIC: - PCIE-20243
    1'b1                       - GIC payload will be :
                                   2DW of TLP payload data from begining.

    1'b0 && segment_num_valid - GIC payload will be:
                                  tlp_payload_1st_dw [31:0]
                                  tlp_payload_2nd_dw[15:0]
                                  lm_segment_num[7:0]
                                  tlp_payload_2nd_dw[31:24] 
    */
    // --- Packing as per PCIE-20553. -----------------------------
    for (int i = 0; i < 4; i++)
      msi_stream_pkt.PacketData[i] = tlp_pkt.m_tlp_payload[i];
    msi_stream_pkt.PacketData[4] = tlp_pkt.m_tlp_requester_id[7:0];
    msi_stream_pkt.PacketData[5] = tlp_pkt.m_tlp_requester_id[15:8];
    if(m_env_cfg.m_hls_bridge_config.hls_bridge_msi_gic_use_seg == 1'b0) begin
      msi_stream_pkt.PacketData[6] = (l_lm_segment_num[8] ? l_lm_segment_num[7:0] : 0);
    end
    else begin
      if(l_misc_flit_mode == 2'b10) begin // Flit mode
        msi_stream_pkt.PacketData[6] = ((tlp_pkt.m_ohc_hdr.ohc_c_present == 1 && tlp_pkt.m_requester_segment_valid == 1) ? tlp_pkt.m_requester_segment : (l_lm_segment_num[8] ? l_lm_segment_num[7:0] : 0));  
      end
      else begin // Non-Flit Mode
        msi_stream_pkt.PacketData[6] = (l_lm_segment_num[8] ? l_lm_segment_num[7:0] : 0);
      end
    end
    msi_stream_pkt.PacketData[7] = 8'h0;

    //--- Pushing to the MSI Queue which is used for generating LTI Completions -----
    l_msi_lti_info.bypass_axi_atu = tlp_pkt.hls_ib_p_np_meta_s.bypass_axi_atu;
    l_msi_lti_info.lrctag         = tlp_pkt.hls_ib_p_np_meta_s.lrctag;
    l_msi_lti_info.lti_port_num   = tlp_pkt.hls_ib_p_np_meta_s.lti_port_num;  
    m_exp_msi_lti_c_tracker_q.push_back(l_msi_lti_info);

  endtask : convert_tlp2msistream

  //----------------------------------------------------------------------------
  // Function:    convert_userctrl2metadata
  // Description: Unpacking user cntl bytes to meta data.
  //----------------------------------------------------------------------------
  task convert_userctrl2metadata(string msg_id = "", bit is_ib, denaliCxsTransaction cxs_pkt, ref cdn_hpa_pcie_tlp tlp_pkt);
    string l_msg_id = {msg_id, "[convert_userctrl2metadata]"};
    
    if(is_ib) begin //IB Metadata Unpacking
      if(tlp_pkt.m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) begin // IB Completion
        tlp_pkt.hls_ib_cpl_meta_s = {<<byte{cxs_pkt.UserControl}};
      end
      else begin // IB P/NP Metadata Unpacking
        tlp_pkt.hls_ib_p_np_meta_s = {<<byte{cxs_pkt.UserControl}};
      end
    end
    else begin //OB Metadata Unpacking
      tlp_pkt.hls_ob_meta_s = {<<byte{cxs_pkt.UserControl}};
    end

  endtask : convert_userctrl2metadata
  
  //----------------------------------------------------------------------------
  // Function:    update_ob_metadata
  // Description: Updates the metadata fields to match the DUT Expectation and
  // pack them in the User Cntl.
  //----------------------------------------------------------------------------
  task update_ob_metadata(string msg_id = "", bit [3:0] axib_port_num, ref denaliCxsTransaction cxs_pkt, ref cdn_hpa_pcie_tlp tlp_pkt);
    string l_msg_id = {msg_id, "[update_ob_metadata]"};
    
    //--- Updating AXIB_PORT_NUM metadata field --------
    tlp_pkt.hls_ob_meta_s.axib_port_num = axib_port_num;
    
    //--- Packing updated metadata in UserCntl ---------
    cxs_pkt.UserControl = {>>{tlp_pkt.hls_ob_meta_s}};
    cxs_pkt.UserControl.reverse();

    `uvm_info(l_msg_id, $sformatf("Updated OB metadata: %p",tlp_pkt.hls_ob_meta_s), UVM_DEBUG);
  endtask : update_ob_metadata
  
  //----------------------------------------------------------------------------
  // Function:    repack_cxs_tx2rx
  // Description: Repacking TX To RX since scoreboard do comparison of RX and not TX
  //----------------------------------------------------------------------------
  function void repack_cxs_tx2rx(string msg_id = "", ref denaliCxsTransaction cxs_pkt);
    denaliCxsTransaction l_cxs_pkt;

    l_cxs_pkt                 = denaliCxsTransaction::type_id::create("l_cxs_pkt", this) ;
    l_cxs_pkt.UserControl     = new[cxs_pkt.UserControl.size()](cxs_pkt.UserControl)     ;
    l_cxs_pkt.DataPerPktRx    = new[cxs_pkt.DataPerPktTx.size()](cxs_pkt.DataPerPktTx)   ;
    l_cxs_pkt.CurPktLengthRx  = cxs_pkt.CurPktLengthTx                                   ;
    l_cxs_pkt.CurStartedPktRx = cxs_pkt.CurStartedPktTx                                  ;
    l_cxs_pkt.CurEndedPktRx   = cxs_pkt.CurEndedPktTx                                    ;
    l_cxs_pkt.CurEndErrRx     = cxs_pkt.CurEndErrTx                                      ;
    l_cxs_pkt.CurStartPtrRx   = cxs_pkt.CurStartPtrTx                                    ;
    l_cxs_pkt.CurEndPtrRx     = cxs_pkt.CurEndPtrTx                                      ;
    l_cxs_pkt.PktStartTimeRx  = cxs_pkt.PktStartTime                                     ;
    l_cxs_pkt.PktEndTimeRx    = cxs_pkt.PktEndTime                                       ;
    
    cxs_pkt.copy(l_cxs_pkt);

  endfunction : repack_cxs_tx2rx
  
  //----------------------------------------------------------------------------
  // Function:    repack_cxs_rx2tx
  // Description: Repacking RX To TX since the merge predictor uses TX items.
  //----------------------------------------------------------------------------
  function void repack_cxs_rx2tx(string msg_id = "", ref denaliCxsTransaction cxs_pkt);
    denaliCxsTransaction l_cxs_pkt;

    l_cxs_pkt                 = denaliCxsTransaction::type_id::create("l_cxs_pkt", this) ;
    l_cxs_pkt.UserControl     = new[cxs_pkt.UserControl.size()](cxs_pkt.UserControl)     ;
    l_cxs_pkt.DataPerPktTx    = new[cxs_pkt.DataPerPktRx.size()](cxs_pkt.DataPerPktRx)   ;
    l_cxs_pkt.CurPktLengthTx  = cxs_pkt.CurPktLengthRx                                   ;
    l_cxs_pkt.CurStartedPktTx = cxs_pkt.CurStartedPktRx                                  ;
    l_cxs_pkt.CurEndedPktTx   = cxs_pkt.CurEndedPktRx                                    ;
    l_cxs_pkt.CurEndErrTx     = cxs_pkt.CurEndErrRx                                      ;
    l_cxs_pkt.CurStartPtrTx   = cxs_pkt.CurStartPtrRx                                    ;
    l_cxs_pkt.CurEndPtrTx     = cxs_pkt.CurEndPtrRx                                      ;
    l_cxs_pkt.PktStartTime    = cxs_pkt.PktStartTimeRx                                   ;
    l_cxs_pkt.PktEndTime      = cxs_pkt.PktEndTimeRx                                     ;

    cxs_pkt.copy(l_cxs_pkt);

  endfunction : repack_cxs_rx2tx
  
  //----------------------------------------------------------------------------
  // Function:    predict_ib_pkt_routing
  // Description: Returns where the inbound pkt should be routed to based 
  // on the enabled configuration.
  //----------------------------------------------------------------------------
  task predict_ib_pkt_routing(string msg_id = "", cdn_hpa_pcie_tlp tlp_pkt, ref cdn_pcie_hls_bridge_inbound_route_to_e route_to , ref int hls_port_num);
    string       l_msg_id = {msg_id, "[predict_ib_pkt_routing]"};
    bit [1 : 0]  l_strap_port_type;

      bit [1:0] pkt_route_info;
      bit [2:0] port_info;

      if (tlp_pkt.m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) begin
        pkt_route_info = tlp_pkt.hls_ib_cpl_meta_s.hls_bridge_pkt_route_info;
        port_info = tlp_pkt.hls_ib_cpl_meta_s.hls_bridge_port_info;
      end
      else begin
        pkt_route_info = tlp_pkt.hls_ib_p_np_meta_s.hls_bridge_pkt_route_info;
        port_info = tlp_pkt.hls_ib_p_np_meta_s.hls_bridge_port_info;
      end

      hls_port_num = port_info;
      case (pkt_route_info)
        2'b00: route_to = ROUTE_TO_AXI;
        2'b01: route_to = ROUTE_TO_AXI; // UIO
        2'b10: route_to = ROUTE_TO_MSI;
        2'b11: route_to = ROUTE_TO_DTI;
      endcase

    `uvm_info(l_msg_id, $sformatf("Predicted %0s TLP %0s Port %0d.", tlp_pkt.m_tlp_req_type.name(), route_to.name(), hls_port_num), UVM_DEBUG);

    //- Coverage Callback---------------------------------------
    cover_inbound_routing_msi(.msg_id(l_msg_id), .route_to(route_to));
    cover_inbound_routing_dti(.msg_id(l_msg_id), .route_to(route_to));
    
  endtask : predict_ib_pkt_routing

  //----------------------------------------------------------------------------
  // Function:    predict_ib_hls_port_num
  // Description: Returns the hls port number to which the inbound TLP Received 
  // on the HAL Interface should be routed to based on the enabled scheme.
  //----------------------------------------------------------------------------
  task predict_ib_hls_port_num(string msg_id = "", cdn_hpa_pcie_tlp tlp_pkt, ref int hls_port_num);
    string                                                                  l_msg_id = {msg_id, "[predict_ib_hls_port_num]"};
    bit    [parameters_cfg_pkg::NUM_HLS_PORTS*32-1 : 0]                     l_misc_tag_management                           ;
    bit    [13 : 0]                                                         l_tag_range                                     ;
    bit    [13 : 0]                                                         l_tag_offset                                    ;
    bit    [13 : 0]                                                         l_tlp_tag                                       ;
    cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e l_splitting_scheme_chosen                       ;
    bit                                                                     l_no_splitting_scheme_chosen                    ;
    bit                                                                     l_is_tlp_msg_type                               ;
    bit                                                                     l_is_tlp_ro_bit_set                             ;
    bit    [5 : 0]                                                          l_multiple_arb_en                               ;
    m_env_cfg.m_misc_if_api.get_misc_tag_management(l_misc_tag_management);
    hls_port_num                 = -1;
    l_splitting_scheme_chosen    = cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e'(RANDOM_SPLITTING_SCHEME);
    l_no_splitting_scheme_chosen = 0;
    l_is_tlp_msg_type            = 0;
    l_is_tlp_ro_bit_set          = 0;
    l_multiple_arb_en            = {m_env_cfg.m_hls_bridge_config.axi0_force_en, m_env_cfg.m_hls_bridge_config.idg_en, m_env_cfg.m_hls_bridge_config.vc_en, m_env_cfg.m_hls_bridge_config.tc_en, m_env_cfg.m_hls_bridge_config.tfc_en, m_env_cfg.m_hls_bridge_config.addr_window_en};

    //- If single port always route to Port#0. --------------
    if (parameters_cfg_pkg::NUM_HLS_PORTS == 1) begin
      hls_port_num = 0;
      `uvm_info(l_msg_id, $sformatf("[SINGLE-PORT] %0s TLP routed to Port#0.", tlp_pkt.m_tlp_req_type.name()), UVM_DEBUG);
    end
    //- If multi-port route based on Enabled Scheme. --------------
    else begin
      if (tlp_pkt.m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) begin // IB Completion
        
        l_tlp_tag = {tlp_pkt.m_tlp_14_bit_tagscale, tlp_pkt.m_tlp_tagscale, tlp_pkt.m_tlp_tag};
        
        //- Find the Port Index where the tag for incoming TLP is allocated to. --------------
        for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
          l_tag_offset = l_misc_tag_management[loop_port*32 +: 14];
          l_tag_range  = l_misc_tag_management[(loop_port*32 + 16) +: 14];
          if (l_tlp_tag inside {[l_tag_offset : ((l_tag_offset + l_tag_range) - 1)]}) begin
            hls_port_num = loop_port;
            cover_hls_ib_cpl_splitting_scheme(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .tag_scheme_chosen(1'b1));
            `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][TAG BASED ROUTING] %0s TLP routed to Port#%0d.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
            break;
          end
        end
        if (hls_port_num == -1) begin // If TLP is not routed using tag based scheme then route the TLP to Port#0 by default.
          hls_port_num = 0;
          cover_hls_ib_cpl_splitting_scheme(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .tag_scheme_chosen(1'b0));
          `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][DEFAULT ROUTING] %0s TLP routed to default Port#%0d as it is not routed using any enabled scheme.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
        end
      end
      else begin // IB Posted / Non-Posted
        if (m_env_cfg.m_hls_bridge_config.axi0_force_en) begin // If Force Routing to AXI Port#0 is enabled.
          hls_port_num              = 0           ;
          l_splitting_scheme_chosen = cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e'(FORCE_PORT_0);
          `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][FORCE PORT#0 ROUTING] %0s TLP routed to Port#%0d.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
        end
      
        if (m_env_cfg.m_hls_bridge_config.idg_en && hls_port_num == -1) begin // If IDG Based Scheme is enable && port was not decided from the previously enabled schemes.
          for(int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
            if(tlp_pkt.hls_ib_p_np_meta_s.idgroup inside {m_env_cfg.m_hls_bridge_config.m_idg_allocation_per_port[loop_port]}) begin
              hls_port_num              = loop_port;
              l_splitting_scheme_chosen = cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e'(IDG_BASED);
              `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][IDG BASED ROUTING] %0s TLP routed to Port#%0d.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
              break;
            end
          end
        end

        if (m_env_cfg.m_hls_bridge_config.vc_en && hls_port_num == -1) begin // If VC Based Scheme is enabled && port was not decided from the previously enabled schemes.
          for(int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
            if(tlp_pkt.hls_ib_p_np_meta_s.vc inside {m_env_cfg.m_hls_bridge_config.m_vc_allocation_per_port[loop_port]}) begin
              hls_port_num              = loop_port;
              l_splitting_scheme_chosen = cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e'(VC_BASED);
              `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][VC BASED ROUTING] %0s TLP routed to Port#%0d.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
              break;
            end
          end
        end
        
        if (m_env_cfg.m_hls_bridge_config.tc_en && hls_port_num == -1) begin // If TC Based Scheme is enabled && port was not decided from the previously enabled schemes.
          for(int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
            if(tlp_pkt.hls_ib_p_np_meta_s.tc inside {m_env_cfg.m_hls_bridge_config.m_tc_allocation_per_port[loop_port]}) begin
              hls_port_num              = loop_port;
              l_splitting_scheme_chosen = cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e'(TC_BASED);
              `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][TC BASED ROUTING] %0s TLP routed to Port#%0d.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
              break;
            end
          end
        end

        if (m_env_cfg.m_hls_bridge_config.tfc_en && hls_port_num == -1) begin // If Target Function Scheme is enabled && port was not decided from the previously enabled schemes.
          if (((tlp_pkt.hls_ib_p_np_meta_s.pf & m_env_cfg.m_hls_bridge_config.hls_bridge_tf_port_map_mask[24:17]) == m_env_cfg.m_hls_bridge_config.hls_bridge_tf_port_map_value[24:17]) &&
              ((tlp_pkt.hls_ib_p_np_meta_s.vf & m_env_cfg.m_hls_bridge_config.hls_bridge_tf_port_map_mask[16:1]) == m_env_cfg.m_hls_bridge_config.hls_bridge_tf_port_map_value[16:1]) &&
              ((tlp_pkt.hls_ib_p_np_meta_s.vf_or_pf & m_env_cfg.m_hls_bridge_config.hls_bridge_tf_port_map_mask[0]) == m_env_cfg.m_hls_bridge_config.hls_bridge_tf_port_map_value[0])) begin
            l_splitting_scheme_chosen = cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e'(TARGET_FUNCTION_BASED);
            if (m_env_cfg.m_hls_bridge_config.tfc_ro_chk_en) begin // RO chk_en == 1
              if (tlp_pkt.hls_ib_p_np_meta_s.ro == 1) begin // RO TLP
                l_is_tlp_ro_bit_set = 1;
                if (tlp_pkt.m_tlp_trans_type !== CDN_HPA_PCIE_TRANS_MSG_TYPE) begin // TLP not message
                  hls_port_num = 1; // Will work only for 2 Ports
                  `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][TARGET-FUNCTION BASED ROUTING] %0s TLP routed to Port#%0d since the TLP is not of message type, has RO bit = 1 and TF RO checking is enabled.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
                end
                else begin // TLP is message
                  hls_port_num      = 0;
                  l_is_tlp_msg_type = 1;
                  `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][TARGET-FUNCTION BASED ROUTING] %0s TLP routed to Port#%0d since the TLP is of message type, has RO bit = 1 and TF RO checking is enabled.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
                end
              end
              else begin
                `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][TARGET-FUNCTION BASED ROUTING] %0s TLP has RO bit = 0 and TF RO Checking is enabled hence moving to the next enable scheme.", tlp_pkt.m_tlp_req_type.name()), UVM_DEBUG);
                cover_hls_ib_p_np_target_function_to_next_available_scheme(.msg_id(l_msg_id),.next_available_scheme(1'b1)); 
              end  
            end
            else begin // RO chk_en == 0
              hls_port_num = 1; // Will work only for 2 Ports
              `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][TARGET-FUNCTION BASED ROUTING] %0s TLP routed to Port#%0d since TF RO Checking is disabled.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
            end
          end
        end

        if (m_env_cfg.m_hls_bridge_config.addr_window_en && hls_port_num == -1) begin // If Address based Scheme is enabled && port was not decided from the previously enabled schemes. 
          if (tlp_pkt.m_tlp_addr inside {[m_env_cfg.m_hls_bridge_config.hls_bridge_tlp_start_addr : m_env_cfg.m_hls_bridge_config.hls_bridge_tlp_end_addr]} && tlp_pkt.hls_ib_p_np_meta_s.ro == 1) begin // Address falls in range and RO TLP.
            l_splitting_scheme_chosen = cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e'(ADDRESS_BASED);
            l_is_tlp_ro_bit_set       = 1            ;
            if (tlp_pkt.m_tlp_trans_type !== CDN_HPA_PCIE_TRANS_MSG_TYPE) begin // TLP not message
              hls_port_num = 1; // Will work only for 2 Ports
              `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][ADDRESS BASED ROUTING] %0s TLP routed to Port#%0d since the TLP is not of message type.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
            end
            else begin
              hls_port_num      = 0;
              l_is_tlp_msg_type = 1;
              `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][ADDRESS BASED ROUTING] %0s TLP routed to Port#%0d since the TLP is of message type.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
            end
          end
          else begin
            `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][ADDRESS BASED ROUTING] %0s TLP has RO bit = 0 and TF RO Checking is enabled hence moving to the next enable scheme.", tlp_pkt.m_tlp_req_type.name()), UVM_DEBUG);
            cover_hls_ib_p_np_address_based_to_next_available_scheme(.msg_id(l_msg_id),.route_to_port0(1'b1));
          end  
        end
        if (hls_port_num == -1) begin // If TLP is not routed using any of the enabled scheme then route the TLP to Port#0 by default.
          hls_port_num                 = 0;
          l_no_splitting_scheme_chosen = 1;
          `uvm_info(l_msg_id, $sformatf("[MULTI-PORT][DEFAULT ROUTING] %0s TLP routed to default Port#%0d as it is not routed using any enabled scheme.", tlp_pkt.m_tlp_req_type.name(), hls_port_num), UVM_DEBUG);
        end
        cover_hls_ib_p_np_splitting_scheme(.msg_id(l_msg_id), .hls_port_num(hls_port_num), .ib_p_np_splitting_scheme(l_splitting_scheme_chosen), .no_splitting_scheme_chosen(l_no_splitting_scheme_chosen), .is_tlp_msg_type(l_is_tlp_msg_type), .is_tlp_ro_bit_set(l_is_tlp_ro_bit_set), .is_tlp_ro_chk_en(m_env_cfg.m_hls_bridge_config.tfc_ro_chk_en));
        cover_hls_ib_multiple_arb_enabled(.msg_id(l_msg_id), .arb_en(l_multiple_arb_en));         
      end
    end
    
  endtask : predict_ib_hls_port_num
  
  //----------------------------------------------------------------------------
  // Function:    send_to_ib_posted_order_checker
  // Description: This virtual task prepares a transaction record based on the
  // input parameters and sends it to the Inbound Posted Order Checker Component
  //----------------------------------------------------------------------------
  virtual task send_to_ib_posted_order_checker(cdn_pcie_hls_bridge_inbound_route_to_e route_to, int unsigned hls_port_num, denaliCxsTransaction cxs_pkt, denaliStreamTransaction msi_pkt, bit[2:0] id_group);
    cdn_pcie_hls_bridge_ib_port_tr_delivered_s port_tr;
    
    port_tr.dest_port    = route_to;
    port_tr.id_group     = id_group;
    if (route_to == ROUTE_TO_AXI) begin
      port_tr.hls_port_num = hls_port_num;
    end
    else begin
      port_tr.hls_port_num = 0;
    end
    if(route_to == cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_inbound_route_to_e'(ROUTE_TO_MSI))
      port_tr.data_bytes = new[msi_pkt.PacketData.size()](msi_pkt.PacketData);
    else
      port_tr.data_bytes = new[cxs_pkt.DataPerPktRx.size()](cxs_pkt.DataPerPktRx);

    hls_ib_posted_port_tr_ap.write(port_tr); 

  endtask : send_to_ib_posted_order_checker

  //----------------------------------------------------------------------------
  // Function:    process_tlp_qos_tx
  // Description:This task decodes count/type/stream, accumulates observed count,
  //             and writes to m_tlp_qos_tx_af.
  //----------------------------------------------------------------------------

  virtual task process_tlp_qos_tx(string msg_id = "");
    string              l_msg_id = {msg_id, "[process_tlp_qos_tx]"};
    denaliStreamTransaction l_stream_trans;
    bit [23:0]          l_count_data;          
    int                 l_group_idx;

    forever begin
 	 m_qos_slv_ended_af.get(l_stream_trans);
 	 //Unpacking data
 	 l_count_data[23:16] = l_stream_trans.PacketData[2][7:0];
  	 l_count_data[15:8]  = l_stream_trans.PacketData[1][7:0];
  	 l_count_data[7:0]   = l_stream_trans.PacketData[0][7:0];
 
         case ({l_count_data[13], l_count_data[14]})
            2'b11: l_group_idx = 0 * parameters_cfg_pkg::NUM_TLP_STREAMS + int'(3'(l_count_data[17:15]));
            2'b01: l_group_idx = 1 * parameters_cfg_pkg::NUM_TLP_STREAMS + int'(3'(l_count_data[17:15]));
            2'b10: l_group_idx = 2 * parameters_cfg_pkg::NUM_TLP_STREAMS + int'(3'(l_count_data[17:15]));
            2'b00: l_group_idx = 3 * parameters_cfg_pkg::NUM_TLP_STREAMS + int'(3'(l_count_data[17:15]));
            default: l_group_idx = 0;
         endcase
	`uvm_info("QOS_TX",$sformatf("TX DUT: tdata=0x%06h count=0x%0h qos_type=%0b tlp_type=%0b stream=%0d group=%0d expected=%0d observed_before=%0d",
              l_count_data, l_count_data[12:0],
              l_count_data[13],
              l_count_data[14],
              l_count_data[17:15],
              l_group_idx,
              m_qos_expected_count[l_group_idx],
              m_qos_observed_count[l_group_idx]), UVM_DEBUG)
 
    m_qos_observed_count[l_group_idx] += int'(l_count_data[12:0]);
 
    if (m_qos_observed_count[l_group_idx] > m_qos_expected_count[l_group_idx])
      `uvm_error({l_msg_id, "[QOS_MIDTEST_ERR]"},
         $sformatf("group=%0d stream=%0d tlp_type=%0b qos_type=%0b observed=0x%0h > expected=0x%0h",
                l_group_idx, l_count_data[17:15], l_count_data[14], l_count_data[13],
                m_qos_observed_count[l_group_idx], m_qos_expected_count[l_group_idx]))
  end
     
  endtask : process_tlp_qos_tx


  //----------------------------------------------------------------------------
  // Function:    generate_msi_lti_compl
  // Description: This virtual task generates the lti completion transaction for
  // the MSI Packet received on the MSI Interface.
  //----------------------------------------------------------------------------
  virtual task generate_msi_lti_compl(bit lrctag, bit [$clog2(parameters_cfg_pkg::NUM_LTI_PORTS)-1 : 0] lti_port_num, bit [7:0] count, ref denaliStreamTransaction msi_lti_c_stream_pkt);
    msi_lti_c_stream_pkt = denaliStreamTransaction::type_id::create("msi_lti_c_stream_pkt", this);
    msi_lti_c_stream_pkt.PacketData = new[parameters_cfg_pkg::LTI_C_TDATA_WIDTH/8];
    msi_lti_c_stream_pkt.PacketData[0][7:0] = count;
    msi_lti_c_stream_pkt.PacketData[1][7:0] = 8'b0;
    msi_lti_c_stream_pkt.PacketData[1][0]   = lrctag;
    msi_lti_c_stream_pkt.PacketData[1][2:1] = lti_port_num;
  endtask : generate_msi_lti_compl

  //----------------------------------------------------------------------------
  // Function:    generate_msi_dc
  // Description: This virtual task generates the lti delivered count transaction for
  // the MSI Packet received on the MSI Interface.
  //----------------------------------------------------------------------------
  virtual task generate_msi_dc(denaliStreamTransaction msi_stream_pkt, ref denaliStreamTransaction msi_dc_stream_pkt, input bit[2:0] idgroup);
    msi_dc_stream_pkt = denaliStreamTransaction::type_id::create("msi_dc_stream_pkt", this);
    msi_dc_stream_pkt.Type   = DENALI_STREAM_TR_Packet;
    msi_dc_stream_pkt.Length = 1;
    msi_dc_stream_pkt.PacketData = new[parameters_cfg_pkg::DELIVERED_P_TDATA_WIDTH/8];
    foreach(msi_dc_stream_pkt.PacketData[i])
      msi_dc_stream_pkt.PacketData[i][7:0] = 8'h0;
    msi_dc_stream_pkt.PacketData[1][3:1] = idgroup;
    msi_dc_stream_pkt.PacketData[0][7:0] = 'h1;

    //-- Masking Unwanted fields since these are not present in the interface --
    msi_dc_stream_pkt.TuserArray.delete();
    msi_dc_stream_pkt.TstrbArray.delete();
    msi_dc_stream_pkt.TkeepArray.delete();
    msi_dc_stream_pkt.Id   = 0;
    msi_dc_stream_pkt.Dest = 0;
  endtask : generate_msi_dc

  //----------------------------------------------------------------------------
  // Function:    is_quiet
  // Description: Function which returns 1 when all the monitoring components
  // have become empty.
  //----------------------------------------------------------------------------
  virtual function bit is_quiet();
    bit l_is_quiet = 1;

    //---- Check that scoreboards are empty --------------------
    l_is_quiet &= m_hls_ob_posted_cxs_scoreboard.is_empty();
    l_is_quiet &= m_hls_ob_nonposted_cxs_scoreboard.is_empty();
    l_is_quiet &= m_hls_ob_compl_cxs_scoreboard.is_empty();

`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      l_is_quiet &= m_hls_ib_posted_dti_scoreboard.is_empty();
      l_is_quiet &= m_hls_ib_nonposted_dti_scoreboard.is_empty();
    end
`endif

    foreach(m_hls_ib_posted_cxs_scoreboard[loop_port]) begin
      l_is_quiet &= m_hls_ib_posted_cxs_scoreboard[loop_port].is_empty();
    end
    foreach(m_hls_ib_nonposted_cxs_scoreboard[loop_port]) begin
      l_is_quiet &= m_hls_ib_nonposted_cxs_scoreboard[loop_port].is_empty();
    end
    foreach(m_hls_ib_compl_cxs_scoreboard[loop_port]) begin
      l_is_quiet &= m_hls_ib_compl_cxs_scoreboard[loop_port].is_empty();
    end
    l_is_quiet &= m_axi_reg_access_scoreboard.is_empty();
    l_is_quiet &= m_hdr2log_stream_scoreboard.is_empty();
    l_is_quiet &= m_lti_ctag_stream_scoreboard.is_empty();
    l_is_quiet &= m_dc_stream_scoreboard.is_empty();
    l_is_quiet &= m_msi_stream_scoreboard.is_empty();
    
    // -- Miscellaneous components -------------------------
    l_is_quiet &= m_hls_ob_posted_merge_predictor.is_empty();
    l_is_quiet &= m_hls_ob_nonposted_merge_predictor.is_empty();
    l_is_quiet &= m_hls_ob_compl_merge_predictor.is_empty();
    l_is_quiet &= m_hls_ib_posted_order_checker.is_empty();
    l_is_quiet &= m_lti_ctag_predictor.is_empty();
    
    //---- Check that completion luts are empty ----------------
    if(m_ob_compl_lut_obj != null) begin
      l_is_quiet &= (m_ob_compl_lut_obj.compl_lut.num() == 0);
    end
    if(m_ob_compl_lut_obj_10_bit != null) begin
      l_is_quiet &= (m_ob_compl_lut_obj_10_bit.compl_lut.num() == 0);
    end
    if(m_ob_compl_lut_obj_14_bit != null) begin
      l_is_quiet &= (m_ob_compl_lut_obj_14_bit.compl_lut.num() == 0);
    end
    if(m_ob_uio_p_compl_lut_obj != null) begin
      l_is_quiet &= (m_ob_uio_p_compl_lut_obj.compl_lut.num() == 0);
    end
    if(m_ib_compl_lut_obj != null) begin
      l_is_quiet &= (m_ib_compl_lut_obj.compl_lut.num() == 0);
    end
    if(m_ib_compl_lut_obj_10_bit != null) begin
      l_is_quiet &= (m_ib_compl_lut_obj_10_bit.compl_lut.num() == 0);
    end
    if(m_ib_compl_lut_obj_14_bit != null) begin
      l_is_quiet &= (m_ib_compl_lut_obj_14_bit.compl_lut.num() == 0);
    end
    if(m_ib_uio_p_compl_lut_obj != null) begin
      l_is_quiet &= (m_ib_uio_p_compl_lut_obj.compl_lut.num() == 0);
    end
if(m_env_cfg.m_qos_support) begin
	l_is_quiet &= (m_qos_slv_ended_af.used() == 0);
/*foreach (m_qos_mst_ended_af[loop_port])
  l_is_quiet &= (m_qos_mst_ended_af[loop_port].used() == 0); */

       end 
    return l_is_quiet;
  endfunction : is_quiet
  
  //----------------------------------------------------------------------------
  // Function:    check_balanced
  // Description: Helper function to check if a component is balanced and raise a fatal error.
  //----------------------------------------------------------------------------
  function void check_balanced(string component_name, bit is_balanced);
    if (!is_balanced) begin
      `uvm_fatal("COMPONENT_UNBALANCED", $sformatf("%0s is not balanced/empty.", component_name));
    end
  endfunction : check_balanced
  
  //----------------------------------------------------------------------------
  // Function:    is_balanced
  // Description: Function which will print all the monitoring components which are not balanced.
  //----------------------------------------------------------------------------
  virtual function void is_balanced();

    // -- Scoreboard components -------------------------
    check_balanced("m_hls_ob_posted_cxs_scoreboard", m_hls_ob_posted_cxs_scoreboard.is_balanced());
    check_balanced("m_hls_ob_nonposted_cxs_scoreboard", m_hls_ob_nonposted_cxs_scoreboard.is_balanced());
    check_balanced("m_hls_ob_compl_cxs_scoreboard", m_hls_ob_compl_cxs_scoreboard.is_balanced());

`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      check_balanced("m_hls_ib_posted_dti_scoreboard", m_hls_ib_posted_dti_scoreboard.is_balanced());
      check_balanced("m_hls_ib_nonposted_dti_scoreboard", m_hls_ib_nonposted_dti_scoreboard.is_balanced());
    end
`endif

    foreach(m_hls_ib_posted_cxs_scoreboard[loop_port]) begin
      check_balanced($sformatf("m_hls_ib_posted_cxs_scoreboard[%0d]", loop_port), m_hls_ib_posted_cxs_scoreboard[loop_port].is_balanced());
    end
    foreach(m_hls_ib_nonposted_cxs_scoreboard[loop_port]) begin
      check_balanced($sformatf("m_hls_ib_nonposted_cxs_scoreboard[%0d]", loop_port), m_hls_ib_nonposted_cxs_scoreboard[loop_port].is_balanced());
    end
    foreach(m_hls_ib_compl_cxs_scoreboard[loop_port]) begin
      check_balanced($sformatf("m_hls_ib_compl_cxs_scoreboard[%0d]", loop_port), m_hls_ib_compl_cxs_scoreboard[loop_port].is_balanced());
    end
    
    check_balanced("m_axi_reg_access_scoreboard", m_axi_reg_access_scoreboard.is_balanced());
    check_balanced("m_hdr2log_stream_scoreboard", m_hdr2log_stream_scoreboard.is_balanced());
    check_balanced("m_lti_ctag_stream_scoreboard", m_lti_ctag_stream_scoreboard.is_balanced());
    check_balanced("m_dc_stream_scoreboard", m_dc_stream_scoreboard.is_balanced());
    check_balanced("m_msi_stream_scoreboard", m_msi_stream_scoreboard.is_balanced());
    
    // -- Predictor components -------------------------
    check_balanced("m_hls_ob_posted_merge_predictor", m_hls_ob_posted_merge_predictor.is_balanced());
    check_balanced("m_hls_ob_nonposted_merge_predictor", m_hls_ob_nonposted_merge_predictor.is_balanced());
    check_balanced("m_hls_ob_compl_merge_predictor", m_hls_ob_compl_merge_predictor.is_balanced());
    check_balanced("m_hls_ib_posted_order_checker", m_hls_ib_posted_order_checker.is_balanced());
    check_balanced("m_lti_ctag_predictor", m_lti_ctag_predictor.is_balanced());
    
    // -- Miscellaneous components ---------------------
    if(m_ob_compl_lut_obj != null) begin
      foreach(m_ob_compl_lut_obj.compl_lut[i]) begin
        `uvm_info(get_full_name(), $sformatf("m_ob_compl_lut_obj.compl_lut[%0d] left = %0s", i, m_ob_compl_lut_obj.compl_lut[i].sprint()), UVM_MEDIUM);
        check_balanced($sformatf("m_ob_compl_lut_obj.compl_lut[%0d]", i), 0);
      end
    end
    if(m_ob_compl_lut_obj_10_bit != null) begin
      foreach(m_ob_compl_lut_obj_10_bit.compl_lut[i]) begin
        `uvm_info(get_full_name(), $sformatf("m_ob_compl_lut_obj_10_bit.compl_lut[%0d] left = %0s", i, m_ob_compl_lut_obj_10_bit.compl_lut[i].sprint()), UVM_MEDIUM);
        check_balanced($sformatf("m_ob_compl_lut_obj_10_bit.compl_lut[%0d]", i), 0);
      end
    end
    if(m_ob_compl_lut_obj_14_bit != null) begin
      foreach(m_ob_compl_lut_obj_14_bit.compl_lut[i]) begin
        `uvm_info(get_full_name(), $sformatf("m_ob_compl_lut_obj_14_bit.compl_lut[%0d] left = %0s", i, m_ob_compl_lut_obj_14_bit.compl_lut[i].sprint()), UVM_MEDIUM);
        check_balanced($sformatf("m_ob_compl_lut_obj_14_bit.compl_lut[%0d]", i), 0);
      end
    end
    if(m_ob_uio_p_compl_lut_obj != null) begin
      foreach(m_ob_uio_p_compl_lut_obj.compl_lut[i]) begin
        `uvm_info(get_full_name(), $sformatf("m_ob_uio_p_compl_lut_obj.compl_lut[%0d] left = %0s", i, m_ob_uio_p_compl_lut_obj.compl_lut[i].sprint()), UVM_MEDIUM);
        check_balanced($sformatf("m_ob_uio_p_compl_lut_obj.compl_lut[%0d]", i), 0);
      end
    end
    if(m_ib_compl_lut_obj != null) begin
      foreach(m_ib_compl_lut_obj.compl_lut[i]) begin
        `uvm_info(get_full_name(), $sformatf("m_ib_compl_lut_obj.compl_lut[%0d] left = %0s", i, m_ib_compl_lut_obj.compl_lut[i].sprint()), UVM_MEDIUM);
        check_balanced($sformatf("m_ib_compl_lut_obj.compl_lut[%0d]", i), 0);
      end
    end
    if(m_ib_compl_lut_obj_10_bit != null) begin
      foreach(m_ib_compl_lut_obj_10_bit.compl_lut[i]) begin
        `uvm_info(get_full_name(), $sformatf("m_ib_compl_lut_obj_10_bit.compl_lut[%0d] left = %0s", i, m_ib_compl_lut_obj_10_bit.compl_lut[i].sprint()), UVM_MEDIUM);
        check_balanced($sformatf("m_ib_compl_lut_obj_10_bit.compl_lut[%0d]", i), 0);
      end
    end
    if(m_ib_compl_lut_obj_14_bit != null) begin
      foreach(m_ib_compl_lut_obj_14_bit.compl_lut[i]) begin
        `uvm_info(get_full_name(), $sformatf("m_ib_compl_lut_obj_14_bit.compl_lut[%0d] left = %0s", i, m_ib_compl_lut_obj_14_bit.compl_lut[i].sprint()), UVM_MEDIUM);
        check_balanced($sformatf("m_ib_compl_lut_obj_14_bit.compl_lut[%0d]", i), 0);
      end
    end
    if(m_ib_uio_p_compl_lut_obj != null) begin
      foreach(m_ib_uio_p_compl_lut_obj.compl_lut[i]) begin
        `uvm_info(get_full_name(), $sformatf("m_ib_uio_p_compl_lut_obj.compl_lut[%0d] left = %0s", i, m_ib_uio_p_compl_lut_obj.compl_lut[i].sprint()), UVM_MEDIUM);
        check_balanced($sformatf("m_ib_uio_p_compl_lut_obj.compl_lut[%0d]", i), 0);
      end
    end
  endfunction : is_balanced

  //----------------------------------------------------------------------------
  // Coverage callbacks
  // Callbacks to be used for coverage collection. These virtual task
  // implementation is overriden in the cdn_pcie_hls_bridge_cov_monitor.
  //----------------------------------------------------------------------------
  virtual task cover_if(string msg_id = "");
  endtask : cover_if

  virtual task cover_hpa_tlp(string msg_id = "", bit strap_is_rp, bit is_ib_dir, cdn_hpa_pcie_tlp tlp_pkt);
  endtask : cover_hpa_tlp
  
  virtual task cover_hls_ob_hal_metadata(string msg_id = "", bit [1:0] fc_type, cdn_pcie_ob_metadata_s metadata);
  endtask : cover_hls_ob_hal_metadata
  
  virtual task cover_hls_ob_axi_metadata(string msg_id = "", int unsigned hls_port_num, bit [1:0] fc_type, cdn_pcie_ob_metadata_s metadata);
  endtask : cover_hls_ob_axi_metadata
  
  virtual task cover_hls_ib_p_np_hal_metadata(string msg_id = "", bit [1:0] fc_type, cdn_pcie_hls_ib_p_np_metadata_s metadata);
  endtask : cover_hls_ib_p_np_hal_metadata
  
  virtual task cover_hls_ib_p_np_axi_metadata(string msg_id = "", int unsigned hls_port_num, bit [1:0] fc_type, cdn_pcie_hls_ib_p_np_metadata_s metadata);
  endtask : cover_hls_ib_p_np_axi_metadata

  virtual task cover_hls_ib_cpl_hal_metadata(string msg_id = "", cdn_pcie_hls_ib_cpl_metadata_s metadata);
  endtask : cover_hls_ib_cpl_hal_metadata
  
  virtual task cover_hls_ib_cpl_axi_metadata(string msg_id = "", int unsigned hls_port_num, cdn_pcie_hls_ib_cpl_metadata_s metadata);
  endtask : cover_hls_ib_cpl_axi_metadata
  
  virtual task cover_hls_ib_p_np_splitting_scheme(string msg_id = "", int unsigned hls_port_num, cdn_pcie_hpa_config_pkg::cdn_pcie_hls_bridge_inbound_splitting_scheme_e ib_p_np_splitting_scheme, bit no_splitting_scheme_chosen, bit is_tlp_msg_type, bit is_tlp_ro_bit_set, bit is_tlp_ro_chk_en);
  endtask : cover_hls_ib_p_np_splitting_scheme
  
  virtual task cover_hls_ib_cpl_splitting_scheme(string msg_id = "", int unsigned hls_port_num, bit tag_scheme_chosen);
  endtask : cover_hls_ib_cpl_splitting_scheme

  virtual task cover_hls_ib_p_np_target_function_to_next_available_scheme(string msg_id = "", bit next_available_scheme);
  endtask : cover_hls_ib_p_np_target_function_to_next_available_scheme

  virtual task cover_hls_ib_p_np_address_based_to_next_available_scheme(string msg_id = "", bit route_to_port0);
  endtask : cover_hls_ib_p_np_address_based_to_next_available_scheme

  virtual task cover_hls_ib_multiple_arb_enabled(string msg_id = "", bit [5:0] arb_en);
  endtask : cover_hls_ib_multiple_arb_enabled

  virtual task cover_hdr2log_ports_active_cycle_combinations(string msg_id = "", bit [31:0] ports_active_in_cycle);
  endtask : cover_hdr2log_ports_active_cycle_combinations

  virtual task cover_lti_ctag_tx_stream(string msg_id = "", int unsigned hls_port_num, bit [7:0] lti_data[]);
  endtask : cover_lti_ctag_tx_stream

  virtual task cover_lti_ctag_rx_stream(string msg_id = "", bit [7:0] lti_data[]);
  endtask : cover_lti_ctag_rx_stream

  virtual task cover_parameters();
  endtask : cover_parameters

  virtual task cover_hls_port_data_width_arr();  
  endtask : cover_hls_port_data_width_arr

  virtual task cover_hls_port_tlps_per_clk_arr();  
  endtask : cover_hls_port_tlps_per_clk_arr

  virtual task cover_dc_tdata_slv(bit [parameters_cfg_pkg::DELIVERED_P_TDATA_WIDTH*parameters_cfg_pkg::NUM_HLS_PORTS-1:0] dc_data );
  endtask : cover_dc_tdata_slv

  virtual task cover_dc_tdata_mst(int unsigned hls_port_num, bit [parameters_cfg_pkg::DELIVERED_P_TDATA_WIDTH*parameters_cfg_pkg::NUM_HLS_PORTS-1:0] dc_data);
  endtask : cover_dc_tdata_mst

  virtual task cover_axi_mst_resp(denaliCdn_axiTransaction packet);
  endtask : cover_axi_mst_resp

  virtual task cover_axi_slv_resp(denaliCdn_axiTransaction packet);
  endtask : cover_axi_slv_resp
  
  virtual task cover_dc_ports_active_cycle_combinations(bit [31:0] ports_active_in_cycle);
  endtask : cover_dc_ports_active_cycle_combinations

  virtual task cover_inbound_routing_msi(string msg_id = "", cdn_pcie_hls_bridge_inbound_route_to_e route_to);
  endtask : cover_inbound_routing_msi
  
  virtual task cover_inbound_routing_dti(string msg_id = "", cdn_pcie_hls_bridge_inbound_route_to_e route_to);
  endtask : cover_inbound_routing_dti

  virtual task cover_ib_uio_rdcpl_split_random_order();
  endtask : cover_ib_uio_rdcpl_split_random_order

  virtual task cover_ib_uio_rdcpld_split_random_order();
  endtask : cover_ib_uio_rdcpld_split_random_order

  virtual task cover_ib_uio_wrcpl_split_random_order();
  endtask : cover_ib_uio_wrcpl_split_random_order 

   virtual task cover_ob_uio_rdcpl_split_random_order();
  endtask : cover_ob_uio_rdcpl_split_random_order

  virtual task cover_ob_uio_rdcpld_split_random_order();
  endtask : cover_ob_uio_rdcpld_split_random_order

  virtual task cover_ob_uio_wrcpl_split_random_order();
  endtask : cover_ob_uio_wrcpl_split_random_order

  virtual function void cover_dti_after_uio_nonposted(bit curr_is_dti, bit prev_was_uio_nonposted);
  endfunction : cover_dti_after_uio_nonposted
   
  virtual function void cover_ib_packet_3seq(int prev2_pkt_type,int prev_pkt_type,int curr_pkt_type);
  endfunction: cover_ib_packet_3seq

  virtual function void cover_dti_bypass_2pkt_scenarios(int prev_type, int curr_type);
  endfunction : cover_dti_bypass_2pkt_scenarios

  virtual function void cover_dti_after_multiple_posted_uio(int uio_posted_streak,bit curr_is_dti );
  endfunction:cover_dti_after_multiple_posted_uio

  virtual task cover_msi_ports_active_cycle_combinations(bit [31:0] ports_active_in_cycle);
  endtask : cover_msi_ports_active_cycle_combinations

  virtual function void cover_backpressure_scenario(bit ib_en, bit ob_en);
  endfunction : cover_backpressure_scenario

endclass : cdn_pcie_hls_bridge_monitor


`endif // CDN_PCIE_HLS_BRIDGE_MONITOR_SV
