`ifndef CDN_PCIE_HLS_BRIDGE_ENV_SV
`define CDN_PCIE_HLS_BRIDGE_ENV_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_env
// This class defines the verification environment for the CDN_PCIE_HLS_BRIDGE module.
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_env extends uvm_env implements I_cdn_pcie_hls_bridge_reset;

  //----------------------------------------------------------------------------
  // Components / UVCs
  //----------------------------------------------------------------------------
  //--- Clock Environment--------------------------------------------------------
  cdn_clock_env            m_clk_env;

  //--- Reset Environment--------------------------------------------------------
  cdn_reset_env            m_core_rst_env;
  cdn_reset_env            m_axi_dti_rst_env;
  cdn_reset_env            m_axi_msi_rst_env;
  cdn_reset_env            m_axil_rst_env;

  //--- CXS Environments---------------------------------------------
  // HAL Side
  cdn_hls_env              m_hls_ob_posted_hal_env;
  cdn_hls_env              m_hls_ob_nonposted_hal_env;
  cdn_hls_env              m_hls_ob_compl_hal_env;
  cdn_hls_env              m_hls_ib_posted_hal_env;
  cdn_hls_env              m_hls_ib_nonposted_hal_env;
  cdn_hls_env              m_hls_ib_compl_hal_env;

  // AXI Side
  cdn_hls_env              m_hls_ob_posted_axi_env    [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_env              m_hls_ob_nonposted_axi_env [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_env              m_hls_ob_compl_axi_env     [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_env              m_hls_ib_posted_axi_env    [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_env              m_hls_ib_nonposted_axi_env [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_env              m_hls_ib_compl_axi_env     [parameters_cfg_pkg::NUM_HLS_PORTS];
 
  //--- HDR2LOG Master Environment----------------------------------------------
  cdn_axi_stream_vip_env   m_hdr2log_mst_env[parameters_cfg_pkg::NUM_HLS_PORTS];
  
  //--- HDR2LOG Slave Environment-----------------------------------------------
  cdn_axi_stream_vip_env   m_hdr2log_slv_env;
  
  //--- MSI Slave Environment-----------------------------------------------
  cdn_axi_stream_vip_env   m_axis_msi_slv_env;
  
  //--- Delivered Count Master Environment--------------------------------------
  cdn_axi_stream_vip_env   m_dc_mst_env[parameters_cfg_pkg::NUM_HLS_PORTS];
  
  //--- Delivered Count Slave Environment---------------------------------------
  cdn_axi_stream_vip_env   m_dc_slv_env;

  //--- QoS Master Environment --------------------------------------
  cdn_axi_stream_vip_env  m_qos_mst_env[parameters_cfg_pkg::NUM_HLS_PORTS];

  //--- QoS Slave Environment --------------------------------------
  cdn_axi_stream_vip_env  m_qos_slv_env;
  
  //--- LTI Completion TX Environment-------------------------------------------
  cdn_axi_stream_vip_env   m_lti_c_tx_env[parameters_cfg_pkg::NUM_HLS_PORTS];
  
  //--- LTI Completion RX Environment-------------------------------------------
  cdn_axi_stream_vip_env   m_lti_c_rx_env;
  
  //--- AXI Lite Master Environment---------------------------------------------
  cdn_axi_env              m_axi_lite_mst_env;
  
  //--- AXI Lite Slave Environment----------------------------------------------
  cdn_axi_env              m_axi_lite_slv_env;

  //--- Trans(CIF Router + Tag Manager) Wrapper environment --------------------
  cdn_pcie_hpa_trans_env   m_hls_ob_trans_env;
  cdn_pcie_hpa_trans_env   m_hls_ib_trans_env;

`ifdef DTI_TB_IN_PASSIVE_MODE
  //--- DTI environments -------------------------------------------------------
  cdn_pcie_dti_env         dti_env;
  cdn_pcie_dti_ats_env     dti_ats_env;
`endif

  //--- Top Register Model ---------------------------------
  cdnpcie_reg_rdb          top_regmodel;
  
  //--- HLS Bridge Register Model --------------------------
  hls_bridge_reg_model     hls_bridge_regmodel;

`ifdef DTI_TB_IN_PASSIVE_MODE
  //--- DTI Register Models --------------------------------
  dti_ats_reg_model        dti_regs_model;
`endif

  //--- Register Adapter (bus2reg, reg2bus) ----------------
  cdn_reg_adapter          m_reg2axil_adapter;
  
  //--- Register Predictor ---------------------------------
  uvm_reg_predictor#(denaliCdn_axiTransaction) m_axil_reg_predictor;

  //--- HLS Bridge Vsequencer---------------------------------------------------
  cdn_pcie_hls_bridge_vsequencer    m_vseqr;
  
  //--- HLS Bridge Main Monitor ------------------------------------------------
  cdn_pcie_hls_bridge_monitor       m_env_mon;
  
  //--- HLS Bridge Main Monitor ------------------------------------------------
  cdn_pcie_hls_bridge_reset_manager m_reset_manager;
  
  //--- HLS Bridge AXI-Lite Slv Callback Monitor -------------------------------
  cdn_pcie_hls_bridge_axi_slv_cb_monitor m_axil_slv_cb_mon;

  //----------------------------------------------------------------------------
  // Top level / UVCs config objects
  //----------------------------------------------------------------------------
  //--- Strap Top Config -------------------------------------------------------
  cdn_pcie_strap_top_config      i_cfg;

  //--- Strap kproxy -----------------------------------------------------------
  cdn_pcie_strap_kval_proxy      m_kproxy_strap;
  
  //--- Link Config -------------------------------------------------------------
  cdn_hpa_pcie_link_config       m_link_config;

  //--- Dev Top Config for DUT Side ---------------------------------------------
  cdn_pcie_hpa_dev_top_config    m_dev_top_config;

  //--- Dev Top Config for Remote Side ------------------------------------------
  cdn_pcie_hpa_dev_top_config    m_remote_dev_top_config;

  //--- HPA Config Info Object -------------------------------------------------
  cdn_hpa_pcie_cfg_info_t        l_cfg_info_ob;
  cdn_hpa_pcie_cfg_info_t        l_cfg_info_ib;
  
  //--- HLS Bridge Environment Config Object -----------------------------------
  cdn_pcie_hls_bridge_env_config m_env_cfg;
  
  //--- HLS Bridge Register Config Object --------------------------------------
  cdn_pcie_hls_bridge_config     m_hls_bridge_config;

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_env)

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_env", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Function: build_phase
  // Builds the VE and creates all of the VE components
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    
    //-- Fetching configs and updating them ------------------------------------
    build_cfgs();
    
    //-- If coverage is enabled then override monitor with coverage monitor ----
`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
    if (m_env_cfg.coverage_enable) begin
      set_type_override_by_type(cdn_pcie_hls_bridge_monitor::get_type(), cdn_pcie_hls_bridge_cov_monitor::get_type());
    end
`endif

    //-- Building clock environments -------------------------------------------
    build_clk_env();

    //-- Building reset environments -------------------------------------------
    build_rst_env();
   
    //-- Building CXS environments ---------------------------------------------
    build_cxs_env();

    //-- Building HDR2LOG environments -----------------------------------------
    build_hdr2log_env();
    
    //-- Building MSI environment ----------------------------------------------
    build_msi_env();
    
    //-- Building Delivered Count environments ---------------------------------
    build_dc_env();

    //-- Building QoS environments --------------------------------- 
    if(m_env_cfg.m_qos_support)
      build_qos_env();
 
    //-- Building LTI Completion environments ----------------------------------
    build_lti_c_env();

    //-- Building AXI Lite environments ----------------------------------------
    build_axi_lite_env();

`ifdef DTI_TB_IN_PASSIVE_MODE
    //-- Building DTI environment ----------------------------------------------
    build_dti_env();
`endif

    //-- Building register model and related components ------------------------
    build_reg();
    
    //-- Building other required miscellaneous components ---------------------- 
    build_misc_comp();

  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Function: connect_phase
  // Connect all of the VE pointers between components and connect TLMs ports.
  //----------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    m_reset_manager.m_reset_env = m_core_rst_env;
    m_reset_manager.m_axil_reset_env = m_axil_rst_env;
    m_reset_manager.discover_and_register_components(this);
    if(m_env_cfg.is_active()) begin
      m_reset_manager.register_component(m_vseqr);
    end

    //- RegModel connections ------------------------------------------------
    if(m_env_cfg.is_active()) begin
      hls_bridge_regmodel.default_map.set_sequencer(m_axi_lite_mst_env.act_agent.sequencer, m_reg2axil_adapter);
      hls_bridge_regmodel.default_map.set_auto_predict(1);
      hls_bridge_regmodel.default_map.set_check_on_read(1);
      m_axil_reg_predictor.map     = hls_bridge_regmodel.default_map;
      m_axil_reg_predictor.adapter = m_reg2axil_adapter;
      m_axi_lite_mst_env.psv_agent.monitor.EndedResponseCbPort.connect(m_axil_reg_predictor.bus_in);

`ifdef DTI_TB_IN_PASSIVE_MODE
      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
        dti_regs_model.default_map.set_sequencer(m_axi_lite_mst_env.act_agent.sequencer, m_reg2axil_adapter);
        dti_regs_model.default_map.set_auto_predict(1'b1);
        dti_regs_model.default_map.set_check_on_read(1'b0);
      end
`endif
    end
    
    //---OB/IB CIF Router and Tag Manager connections --------------------------
    if(m_env_cfg.is_active()) begin
      connect_hls_ob_trans_env();
      connect_hls_ib_trans_env();
    end
    
    //---Vsequencer connections ------------------------------------------------
    if(m_env_cfg.is_active()) begin
      
      //----Point to Env Handle-------------------------------------------------
      m_vseqr.p_env = this;

      //--- Clock sequencer connections ----------------------------------------
      m_vseqr.clk_sqr = m_clk_env.agent.sequencer;
      
      //---Reset sequencer connections -----------------------------------------
      m_vseqr.core_rst_sqr        = m_core_rst_env.agents[0].sequencer;
      m_vseqr.axi_msi_rst_sqr     = m_axi_msi_rst_env.agents[0].sequencer;
      m_vseqr.axi_dti_rst_sqr     = m_axi_dti_rst_env.agents[0].sequencer;
      m_vseqr.axil_rst_sqr        = m_axil_rst_env.agents[0].sequencer;
      
      //- CXS OB sequencer connections -----------------------------------
      foreach(m_hls_ob_posted_axi_env[loop_port]) begin
        m_vseqr.hls_ob_posted_axi_sqr[loop_port]    = m_hls_ob_posted_axi_env[loop_port].cxs_env.act_agent.sequencer;
      end
      foreach(m_hls_ob_nonposted_axi_env[loop_port]) begin
        m_vseqr.hls_ob_nonposted_axi_sqr[loop_port] = m_hls_ob_nonposted_axi_env[loop_port].cxs_env.act_agent.sequencer;
      end
      foreach(m_hls_ob_compl_axi_env[loop_port]) begin
        m_vseqr.hls_ob_compl_axi_sqr[loop_port]     = m_hls_ob_compl_axi_env[loop_port].cxs_env.act_agent.sequencer;
      end
      
      //- CXS IB sequencer connections -----------------------------------
      m_vseqr.hls_ib_posted_hal_sqr    = m_hls_ib_posted_hal_env.cxs_env.act_agent.sequencer;
      m_vseqr.hls_ib_nonposted_hal_sqr = m_hls_ib_nonposted_hal_env.cxs_env.act_agent.sequencer;
      m_vseqr.hls_ib_compl_hal_sqr     = m_hls_ib_compl_hal_env.cxs_env.act_agent.sequencer;

      //- AXIL master sequencer connections -----------------------------------
      m_vseqr.axi_lite_mst_sqr    = m_axi_lite_mst_env.act_agent.sequencer;
      
      //- AXIL slave sequencer connections ------------------------------------
      m_vseqr.axi_lite_slv_sqr    = m_axi_lite_slv_env.act_agent.sequencer;

      //- HDR2LOG AXI Stream Master sequencer connections ---------------------
      foreach(m_hdr2log_mst_env[loop_port]) begin
        m_vseqr.hdr2log_mst_sqr[loop_port] = m_hdr2log_mst_env[loop_port].act_agent.sequencer;
      end
    
      //- Delivered Count AXI Stream Master sequencer connections ---------------------
      foreach(m_dc_mst_env[loop_port]) begin
        m_vseqr.dc_mst_sqr[loop_port] = m_dc_mst_env[loop_port].act_agent.sequencer;
      end
       
     
      //- LTI Completion AXI Stream TX sequencer connections --------------------------
      foreach(m_lti_c_tx_env[loop_port]) begin
        m_vseqr.lti_c_tx_sqr[loop_port] = m_lti_c_tx_env[loop_port].act_agent.sequencer;
      end

      //- HLS Bridge Monitor Posted Axi to Vseqr for Pkt Delivered Count Connections --
      foreach(m_env_mon.m_hls_ib_posted_axi_tlp_pkt_delivered_ap[loop_port]) begin
        m_env_mon.m_hls_ib_posted_axi_tlp_pkt_delivered_ap[loop_port].connect(m_vseqr.m_hls_ib_posted_axi_tlp_pkt_delivered_af[loop_port].analysis_export);
      end
    end

    if (m_env_cfg.m_qos_support) begin 
     foreach(m_qos_mst_env[loop_port]) begin
        m_vseqr.qos_mst_sqr[loop_port] =m_qos_mst_env[loop_port].act_agent.sequencer;
      end

    // HLSB Monitor to  Vsequencer Connection
    foreach(m_qos_mst_env[loop_port]) begin
  	 m_env_mon.m_hls_ib_posted_qos_ap[loop_port].connect( m_vseqr.m_hls_ib_posted_qos_tlp_af[loop_port].analysis_export);
    end
    foreach(m_qos_mst_env[loop_port]) begin
  	m_env_mon.m_hls_ib_nonposted_qos_ap[loop_port].connect(m_vseqr.m_hls_ib_nonposted_qos_tlp_af[loop_port].analysis_export);
    end
    foreach(m_qos_mst_env[loop_port]) begin
 	 m_env_mon.m_hls_ib_compl_qos_ap[loop_port].connect(m_vseqr.m_hls_ib_compl_qos_tlp_af[loop_port].analysis_export);
    end
  end
         
`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
	m_env_mon.credit_ob_posted_axi_ap.connect(m_vseqr.credit_ob_posted_axi_af.analysis_export);
	m_env_mon.credit_ob_posted_hal_ap.connect(m_vseqr.credit_ob_posted_hal_af.analysis_export);
	
	m_env_mon.credit_ob_nonposted_axi_ap.connect(m_vseqr.credit_ob_nonposted_axi_af.analysis_export);
	m_env_mon.credit_ob_nonposted_hal_ap.connect(m_vseqr.credit_ob_nonposted_hal_af.analysis_export);
`endif
	
    //-- HLS OB HAL to HLS Bridge Monitor Connections -------------------------
    m_hls_ob_posted_hal_env.cxs_env.psv_agent.monitor.PktEndedRxCbPort.connect(m_env_mon.m_hls_ob_posted_hal_pkt_ended_af.analysis_export);
    m_hls_ob_nonposted_hal_env.cxs_env.psv_agent.monitor.PktEndedRxCbPort.connect(m_env_mon.m_hls_ob_nonposted_hal_pkt_ended_af.analysis_export);
    m_hls_ob_compl_hal_env.cxs_env.psv_agent.monitor.PktEndedRxCbPort.connect(m_env_mon.m_hls_ob_compl_hal_pkt_ended_af.analysis_export);
    
    //-- HLS IB HAL to HLS Bridge Monitor Connections -------------------------
    m_hls_ib_posted_hal_env.cxs_env.psv_agent.monitor.PktEndedCbPort.connect(m_env_mon.m_hls_ib_posted_hal_pkt_ended_af.analysis_export);
    m_hls_ib_nonposted_hal_env.cxs_env.psv_agent.monitor.PktEndedCbPort.connect(m_env_mon.m_hls_ib_nonposted_hal_pkt_ended_af.analysis_export);
    m_hls_ib_compl_hal_env.cxs_env.psv_agent.monitor.PktEndedCbPort.connect(m_env_mon.m_hls_ib_compl_hal_pkt_ended_af.analysis_export);

`ifdef DTI_TB_IN_PASSIVE_MODE
    //-- DTI IB to HLS Bridge Monitor Connections -------------------------
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      dti_env.hls_env.cxs_tx_p_env.psv_agent.monitor.PktEndedCbPort.connect(m_env_mon.m_hls_ib_posted_dti_pkt_ended_af.analysis_export);
      dti_env.hls_env.cxs_tx_np_env.psv_agent.monitor.PktEndedCbPort.connect(m_env_mon.m_hls_ib_nonposted_dti_pkt_ended_af.analysis_export);
      dti_env.hls_env.cxs_rx_cpl_env.psv_agent.monitor.PktStartedRxCbPort.connect(m_env_mon.m_hls_ob_compl_dti_pkt_started_af.analysis_export);
      dti_env.hls_env.cxs_rx_cpl_env.psv_agent.monitor.PktEndedRxCbPort.connect(m_env_mon.m_hls_ob_compl_dti_pkt_ended_af.analysis_export);
      dti_env.hls_env.cxs_rx_p_env.psv_agent.monitor.PktStartedRxCbPort.connect(m_env_mon.m_hls_ob_posted_dti_pkt_started_af.analysis_export);
      dti_env.hls_env.cxs_rx_p_env.psv_agent.monitor.PktEndedRxCbPort.connect(m_env_mon.m_hls_ob_posted_dti_pkt_ended_af.analysis_export);
      if (m_vseqr)
        m_env_mon.hls_ob_posted_hal_pkt_inv_ap.connect(m_vseqr.m_hls_ob_posted_hal_pkt_inv_af.analysis_export);
    end
`endif

    //-- HLS OB AXI to HLS Bridge Monitor Connections -------------------------
    foreach(m_hls_ob_posted_axi_env[loop_port]) begin
      m_hls_ob_posted_axi_env[loop_port].cxs_env.psv_agent.monitor.PktStartedCbPort.connect(m_env_mon.m_hls_ob_posted_axi_pkt_started_af[loop_port].analysis_export);
      m_hls_ob_posted_axi_env[loop_port].cxs_env.psv_agent.monitor.PktEndedCbPort.connect(m_env_mon.m_hls_ob_posted_axi_pkt_ended_af[loop_port].analysis_export);
    end
    foreach(m_hls_ob_nonposted_axi_env[loop_port]) begin
      m_hls_ob_nonposted_axi_env[loop_port].cxs_env.psv_agent.monitor.PktStartedCbPort.connect(m_env_mon.m_hls_ob_nonposted_axi_pkt_started_af[loop_port].analysis_export);
      m_hls_ob_nonposted_axi_env[loop_port].cxs_env.psv_agent.monitor.PktEndedCbPort.connect(m_env_mon.m_hls_ob_nonposted_axi_pkt_ended_af[loop_port].analysis_export);
    end
    foreach(m_hls_ob_compl_axi_env[loop_port]) begin
      m_hls_ob_compl_axi_env[loop_port].cxs_env.psv_agent.monitor.PktStartedCbPort.connect(m_env_mon.m_hls_ob_compl_axi_pkt_started_af[loop_port].analysis_export);
      m_hls_ob_compl_axi_env[loop_port].cxs_env.psv_agent.monitor.PktEndedCbPort.connect(m_env_mon.m_hls_ob_compl_axi_pkt_ended_af[loop_port].analysis_export);
    end

    //-- HLS IB AXI to HLS Bridge Monitor Connections -------------------------
    foreach(m_hls_ib_posted_axi_env[loop_port]) begin
      m_hls_ib_posted_axi_env[loop_port].cxs_env.psv_agent.monitor.PktEndedRxCbPort.connect(m_env_mon.m_hls_ib_posted_axi_pkt_ended_af[loop_port].analysis_export);
    end
    foreach(m_hls_ib_nonposted_axi_env[loop_port]) begin
      m_hls_ib_nonposted_axi_env[loop_port].cxs_env.psv_agent.monitor.PktEndedRxCbPort.connect(m_env_mon.m_hls_ib_nonposted_axi_pkt_ended_af[loop_port].analysis_export);
    end
    foreach(m_hls_ib_compl_axi_env[loop_port]) begin
      m_hls_ib_compl_axi_env[loop_port].cxs_env.psv_agent.monitor.PktEndedRxCbPort.connect(m_env_mon.m_hls_ib_compl_axi_pkt_ended_af[loop_port].analysis_export);
    end 

    //-- HDR2LOG to HLS Bridge Monitor Connections ----------------------------
    m_hdr2log_slv_env.psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_hdr2log_slv_ended_af.analysis_export);
    foreach(m_hdr2log_mst_env[loop_port]) begin
      m_hdr2log_mst_env[loop_port].psv_agent.monitor.StartedCbPort.connect(m_env_mon.m_hdr2log_mst_started_af[loop_port].analysis_export);
      m_hdr2log_mst_env[loop_port].psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_hdr2log_mst_ended_af[loop_port].analysis_export);
    end

`ifdef DTI_TB_IN_PASSIVE_MODE
      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
        dti_env.hdr2log_env.hdr2log_psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_hdr2log_dti_ended_af.analysis_export);
      end
`endif

    //-- LTI CTAG to HLS Bridge Monitor Connections ----------------------------
    m_lti_c_rx_env.psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_lti_ctag_rx_ended_af.analysis_export);
    foreach(m_lti_c_tx_env[loop_port]) begin 
      m_lti_c_tx_env[loop_port].psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_lti_ctag_tx_ended_af[loop_port].analysis_export);
    end
    
    //-- MSI to HLS Bridge Monitor Connections ----------------------------
    m_axis_msi_slv_env.psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_axis_msi_slv_ended_af.analysis_export);

    //-- Delivered Count to HLS Bridge Monitor Connections ----------------------------
    m_dc_slv_env.psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_dc_slv_ended_af.analysis_export);
    foreach(m_dc_mst_env[loop_port]) begin
      m_dc_mst_env[loop_port].psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_dc_mst_ended_af[loop_port].analysis_export);
    end

    //--- QoS to HLS Bridge Monitor Connections ----------------------------
    if (m_env_cfg.m_qos_support) begin  
      m_qos_slv_env.psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_qos_slv_ended_af.analysis_export);
    end
   
`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      dti_env.delivered_p_env.delivered_p_psv_agent.monitor.EndedCbPort.connect(m_env_mon.m_dc_dti_ended_af.analysis_export);
    end
`endif

    //-- AXI-Lite Monitor to HLS Bridge Monitor Connections ----------------------------
    m_axi_lite_slv_env.psv_agent.monitor.EndedResponseCbPort.connect(m_env_mon.m_axi_slv_pkt_ended_af.analysis_export);
    m_axi_lite_mst_env.psv_agent.monitor.EndedResponseCbPort.connect(m_env_mon.m_axi_mst_pkt_ended_af.analysis_export);
    
    //-- AXI-Lite Monitor to HLS Bridge AXI Slv Callback Monitor Connections -----------
    if(m_env_cfg.is_active()) begin
      m_axi_lite_slv_env.act_agent.monitor.BeforeSendResponseCbPort.connect(m_axil_slv_cb_mon.before_send_response_cbport_export);
    end

    //-- HLS Bridge Monitor to HLS OB Merge Predictor Connections ---------
    foreach(m_env_mon.hls_ob_posted_axi_pkt_started_ap[loop_port]) begin
      m_env_mon.hls_ob_posted_axi_pkt_started_ap[loop_port].connect(m_env_mon.m_hls_ob_posted_merge_predictor.m_in_cxs_pkt_started_af[loop_port].analysis_export);
    end
    foreach(m_env_mon.hls_ob_posted_axi_pkt_ended_ap[loop_port]) begin
      m_env_mon.hls_ob_posted_axi_pkt_ended_ap[loop_port].connect(m_env_mon.m_hls_ob_posted_merge_predictor.m_in_cxs_pkt_ended_af[loop_port].analysis_export);
    end
    foreach(m_env_mon.hls_ob_nonposted_axi_pkt_started_ap[loop_port]) begin
      m_env_mon.hls_ob_nonposted_axi_pkt_started_ap[loop_port].connect(m_env_mon.m_hls_ob_nonposted_merge_predictor.m_in_cxs_pkt_started_af[loop_port].analysis_export);
    end
    foreach(m_env_mon.hls_ob_nonposted_axi_pkt_ended_ap[loop_port]) begin
      m_env_mon.hls_ob_nonposted_axi_pkt_ended_ap[loop_port].connect(m_env_mon.m_hls_ob_nonposted_merge_predictor.m_in_cxs_pkt_ended_af[loop_port].analysis_export);
    end
    foreach(m_env_mon.hls_ob_compl_axi_pkt_started_ap[loop_port]) begin
      m_env_mon.hls_ob_compl_axi_pkt_started_ap[loop_port].connect(m_env_mon.m_hls_ob_compl_merge_predictor.m_in_cxs_pkt_started_af[loop_port].analysis_export);
    end
    foreach(m_env_mon.hls_ob_compl_axi_pkt_ended_ap[loop_port]) begin
      m_env_mon.hls_ob_compl_axi_pkt_ended_ap[loop_port].connect(m_env_mon.m_hls_ob_compl_merge_predictor.m_in_cxs_pkt_ended_af[loop_port].analysis_export);
    end

    //-- HLS OB Merge Predictor to HLS Bridge Monitor Connections --------------
    m_env_mon.m_hls_ob_posted_merge_predictor.m_out_predicted_cxs_pkt_ap.connect(m_env_mon.m_predicted_hls_ob_posted_axi_af.analysis_export);
    m_env_mon.m_hls_ob_nonposted_merge_predictor.m_out_predicted_cxs_pkt_ap.connect(m_env_mon.m_predicted_hls_ob_nonposted_axi_af.analysis_export);
    m_env_mon.m_hls_ob_compl_merge_predictor.m_out_predicted_cxs_pkt_ap.connect(m_env_mon.m_predicted_hls_ob_compl_axi_af.analysis_export);
    
    //-- HLS Bridge Monitor to LTI Completion Predictor Connections ---------
    foreach(m_env_mon.lti_ctag_tx_stream_pkt_ended_ap[loop_port]) begin
      m_env_mon.lti_ctag_tx_stream_pkt_ended_ap[loop_port].connect(m_env_mon.m_lti_ctag_predictor.m_in_lti_ctag_stream_pkt_ended_af[loop_port].analysis_export);
    end

    //-- LTI Completion Predictor to HLS Bridge Monitor Connections --------
    m_env_mon.m_lti_ctag_predictor.m_out_lti_ctag_stream_pkt_ap.connect(m_env_mon.m_predicted_lti_ctag_tx_af.analysis_export);

    //-- HLS Bridge Monitor to IB Posted Order Checker Connections --------
    m_env_mon.hls_ib_posted_port_tr_ap.connect(m_env_mon.m_hls_ib_posted_order_checker.m_in_exp_p_pkt_ended_af.analysis_export);
    foreach(m_env_mon.axi_ib_posted_pkt_ended_ap[loop_port])
      m_env_mon.axi_ib_posted_pkt_ended_ap[loop_port].connect(m_env_mon.m_hls_ib_posted_order_checker.m_in_act_p_axi_cxs_pkt_ended_af[loop_port].analysis_export);
    m_env_mon.dti_ib_posted_pkt_ended_ap.connect(m_env_mon.m_hls_ib_posted_order_checker.m_in_act_p_dti_cxs_pkt_ended_af.analysis_export);
    m_env_mon.msi_ib_posted_pkt_ended_ap.connect(m_env_mon.m_hls_ib_posted_order_checker.m_in_act_p_msi_pkt_ended_af.analysis_export);
    foreach(m_env_mon.axi_delivered_count_pkt_ended_ap[loop_port])
      m_env_mon.axi_delivered_count_pkt_ended_ap[loop_port].connect(m_env_mon.m_hls_ib_posted_order_checker.m_in_axi_delivered_count_pkt_ended_af[loop_port].analysis_export);
    m_env_mon.dti_delivered_count_pkt_ended_ap.connect(m_env_mon.m_hls_ib_posted_order_checker.m_in_dti_delivered_count_pkt_ended_af.analysis_export);

    //-- Coverage Collector Connections --------------------------------------
    if (m_env_cfg.coverage_enable) begin
`ifndef HLS_BRIDGE_TB_IN_PASSIVE_MODE
      m_hdr2log_slv_env.psv_agent.monitor.DefaultCbPort.connect(m_env_mon.m_hdr2log_slv_stream_cov_collector.callback_trans_in);
      foreach(m_hdr2log_mst_env[loop_port]) begin
        m_hdr2log_mst_env[loop_port].psv_agent.monitor.DefaultCbPort.connect(m_env_mon.m_hdr2log_mst_stream_cov_collector[loop_port].callback_trans_in);
      end
      
      m_axis_msi_slv_env.psv_agent.monitor.DefaultCbPort.connect(m_env_mon.m_axis_msi_slv_stream_cov_collector.callback_trans_in);
      
      m_dc_slv_env.psv_agent.monitor.DefaultCbPort.connect(m_env_mon.m_dc_slv_stream_cov_collector.callback_trans_in);
      foreach(m_dc_mst_env[loop_port]) begin
        m_dc_mst_env[loop_port].psv_agent.monitor.DefaultCbPort.connect(m_env_mon.m_dc_mst_stream_cov_collector[loop_port].callback_trans_in);
      end

      m_lti_c_rx_env.psv_agent.monitor.DefaultCbPort.connect(m_env_mon.m_lti_c_rx_stream_cov_collector.callback_trans_in);
      foreach(m_lti_c_tx_env[loop_port]) begin
        m_lti_c_tx_env[loop_port].psv_agent.monitor.DefaultCbPort.connect(m_env_mon.m_lti_c_tx_stream_cov_collector[loop_port].callback_trans_in);
      end
`endif // HLS_BRIDGE_TB_IN_PASSIVE_MODE
    end
  endfunction : connect_phase

  //----------------------------------------------------------------------------
  // Function: end_of_elaboration
  //----------------------------------------------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

`ifdef DTI_TB_IN_PASSIVE_MODE
    // TODO : Temporary disable this ASF check. Remove later.
  if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      dti_env.asf_env.asf_model.is_disabled = 1;

    dti_ats_env = dti_env.dti_ats_env;
    uvm_config_db#(cdn_pcie_dti_ats_env)::set(null, "*", "cif_router_dti_ats_env", dti_ats_env);
    end
`endif

    //- HLS OB Posted HAL callbacks -------------------------------------------
    void'(m_hls_ob_posted_hal_env.cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEndedRx));
    // Only disabling this check for OB traffic as we can have gaps in the OB Traffic between packets however for IB Traffic DUT will always tightly pack the packets there can't be any gaps allowed.
    void'(m_hls_ob_posted_hal_env.cxs_env.do_demote_cxs_error("DENALI_CXS_ERR043_PKT_NOT_TIGHTLY_PACKED_IN_FLIT")); 
    
    //- HLS OB NonPosted HAL callbacks -------------------------------------------
    void'(m_hls_ob_nonposted_hal_env.cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEndedRx));
    void'(m_hls_ob_nonposted_hal_env.cxs_env.do_demote_cxs_error("DENALI_CXS_ERR043_PKT_NOT_TIGHTLY_PACKED_IN_FLIT"));
    
    //- HLS OB Completion HAL callbacks -------------------------------------------
    void'(m_hls_ob_compl_hal_env.cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEndedRx));
    void'(m_hls_ob_compl_hal_env.cxs_env.do_demote_cxs_error("DENALI_CXS_ERR043_PKT_NOT_TIGHTLY_PACKED_IN_FLIT"));

    //- HLS IB Posted HAL callbacks & Register Configuration ----------------------
    void'(m_hls_ib_posted_hal_env.cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEnded));
    if(m_env_cfg.is_active()) begin
      // Used by the CXS Sequence since we are not using the get_response because it doesn't allow back 2 back TLPs in a flit. - VIPAMBA-3776
      void'(m_hls_ib_posted_hal_env.cxs_env.act_agent.setCallback(DENALI_CXS_CB_DataQueueExit));
      m_hls_ib_posted_hal_env.cxs_env.act_agent.driver.disableRspPortWrite = 1;
      configure_cxs_vip_reg(m_hls_ib_posted_hal_env);
    end

    //- HLS IB NonPosted HAL callbacks & Register Configuration ------------------
    void'(m_hls_ib_nonposted_hal_env.cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEnded));
    if(m_env_cfg.is_active()) begin
      void'(m_hls_ib_nonposted_hal_env.cxs_env.act_agent.setCallback(DENALI_CXS_CB_DataQueueExit));
      m_hls_ib_nonposted_hal_env.cxs_env.act_agent.driver.disableRspPortWrite = 1;
      configure_cxs_vip_reg(m_hls_ib_nonposted_hal_env);
    end
  
    //- HLS IB Completion HAL callbacks & Register Configuration -----------------
    void'(m_hls_ib_compl_hal_env.cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEnded));
    if(m_env_cfg.is_active()) begin
      void'(m_hls_ib_compl_hal_env.cxs_env.act_agent.setCallback(DENALI_CXS_CB_DataQueueExit));
      m_hls_ib_compl_hal_env.cxs_env.act_agent.driver.disableRspPortWrite = 1;
      configure_cxs_vip_reg(m_hls_ib_compl_hal_env);
    end

    //- HLS OB Posted AXI(Per Port) callbacks & Register Configuration -----------
    foreach(m_hls_ob_posted_axi_env[loop_port]) begin
      void'(m_hls_ob_posted_axi_env[loop_port].cxs_env.do_demote_cxs_error("DENALI_CXS_ERR043_PKT_NOT_TIGHTLY_PACKED_IN_FLIT")); 
      void'(m_hls_ob_posted_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktStarted));
      void'(m_hls_ob_posted_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEnded));
      void'(m_hls_ob_posted_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_FlitEnded));
      if(m_env_cfg.is_active()) begin
        // Used by the CXS Sequence since we are not using the get_response because it doesn't allow back 2 back TLPs in a flit. - VIPAMBA-3776
        void'(m_hls_ob_posted_axi_env[loop_port].cxs_env.act_agent.setCallback(DENALI_CXS_CB_DataQueueExit));
        m_hls_ob_posted_axi_env[loop_port].cxs_env.act_agent.driver.disableRspPortWrite = 1;
        configure_cxs_vip_reg(m_hls_ob_posted_axi_env[loop_port]);
      end
    end

    //- HLS OB NonPosted AXI(Per Port) callbacks & Register Configuration---------
    foreach(m_hls_ob_nonposted_axi_env[loop_port]) begin
      void'(m_hls_ob_nonposted_axi_env[loop_port].cxs_env.do_demote_cxs_error("DENALI_CXS_ERR043_PKT_NOT_TIGHTLY_PACKED_IN_FLIT"));
      void'(m_hls_ob_nonposted_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktStarted));
      void'(m_hls_ob_nonposted_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEnded));
      void'(m_hls_ob_nonposted_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_FlitEnded));
      if(m_env_cfg.is_active()) begin
        void'(m_hls_ob_nonposted_axi_env[loop_port].cxs_env.act_agent.setCallback(DENALI_CXS_CB_DataQueueExit));
        m_hls_ob_nonposted_axi_env[loop_port].cxs_env.act_agent.driver.disableRspPortWrite = 1;
        configure_cxs_vip_reg(m_hls_ob_nonposted_axi_env[loop_port]);
      end
    end

    //- HLS OB Completion AXI(Per Port) callbacks & Register Configuration -------
    foreach(m_hls_ob_compl_axi_env[loop_port]) begin
      void'(m_hls_ob_compl_axi_env[loop_port].cxs_env.do_demote_cxs_error("DENALI_CXS_ERR043_PKT_NOT_TIGHTLY_PACKED_IN_FLIT"));
      void'(m_hls_ob_compl_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktStarted));
      void'(m_hls_ob_compl_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEnded));
      void'(m_hls_ob_compl_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_FlitEnded));
      if(m_env_cfg.is_active()) begin
        void'(m_hls_ob_compl_axi_env[loop_port].cxs_env.act_agent.setCallback(DENALI_CXS_CB_DataQueueExit));
        m_hls_ob_compl_axi_env[loop_port].cxs_env.act_agent.driver.disableRspPortWrite = 1;
        configure_cxs_vip_reg(m_hls_ob_compl_axi_env[loop_port]);
      end
    end

    //- HLS IB Posted AXI(Per Port) callbacks -------------------------------------------
    foreach(m_hls_ib_posted_axi_env[loop_port]) begin
      void'(m_hls_ib_posted_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEndedRx));
    end
    
    //- HLS IB NonPosted AXI(Per Port) callbacks -------------------------------------------
    foreach(m_hls_ib_nonposted_axi_env[loop_port]) begin
      void'(m_hls_ib_nonposted_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEndedRx));
    end
    
    //- HLS IB Completion AXI(Per Port) callbacks ------------------------------------------
    foreach(m_hls_ib_compl_axi_env[loop_port]) begin
      void'(m_hls_ib_compl_axi_env[loop_port].cxs_env.psv_agent.setCallback(DENALI_CXS_CB_PktEndedRx));
    end

    //- HDR2LOG callbacks ------------------------------------------------------------------
    void'(m_hdr2log_slv_env.psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    foreach(m_hdr2log_mst_env[loop_port]) begin
      void'(m_hdr2log_mst_env[loop_port].psv_agent.setCallback(DENALI_STREAM_CB_Started));
      void'(m_hdr2log_mst_env[loop_port].psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    end

    //- MSI callbacks ----------------------------------------------------------------------
    void'(m_axis_msi_slv_env.psv_agent.setCallback(DENALI_STREAM_CB_Ended));

    //- Delivered Count callbacks ----------------------------------------------------------
    void'(m_dc_slv_env.psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    foreach(m_dc_mst_env[loop_port]) begin
      void'(m_dc_mst_env[loop_port].psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    end

    //--- QoS callbacks ----------------------------------------------------------
    if (m_env_cfg.m_qos_support) begin 
      void'(m_qos_slv_env.psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    end

    //-AXI INTERCONNECT callbacks ------------------------------------------------------------------
    if(m_env_cfg.is_active()) begin
      void'(m_axi_lite_slv_env.act_agent.setCallback(DENALI_CDN_AXI_CB_BeforeSendResponse));
    end
    void'(m_axi_lite_slv_env.psv_agent.setCallback(DENALI_CDN_AXI_CB_EndedResponse));
    void'(m_axi_lite_mst_env.psv_agent.setCallback(DENALI_CDN_AXI_CB_EndedResponse));
 
    //- Delivered Count callbacks ----------------------------------------------------------
    void'(m_dc_slv_env.psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    foreach(m_dc_mst_env[loop_port]) begin
      void'(m_dc_mst_env[loop_port].psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    end
    
    //- LTI Completions callbacks ----------------------------------------------------------
    void'(m_lti_c_rx_env.psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    foreach(m_lti_c_tx_env[loop_port]) begin
      void'(m_lti_c_tx_env[loop_port].psv_agent.setCallback(DENALI_STREAM_CB_Ended));
    end
    
    //- MSI callbacks ----------------------------------------------------------
    void'(m_axis_msi_slv_env.psv_agent.setCallback(DENALI_STREAM_CB_Ended));
  endfunction : end_of_elaboration_phase
  
  //-------------------------------------------------------------------------------
  // Function: build_cfgs
  // This method retrieves the configs and assign bar information to dev_top_configs
  // needed by CIF Router for Completion Generation.
  //------------------------------------------------------------------------------
  function void build_cfgs();
    //---Fetch the env config object----------------------------------------------
    if(!uvm_config_db#(cdn_pcie_hls_bridge_env_config)::get(this, "", "env_cfg", m_env_cfg)) begin
     `uvm_fatal(get_type_name(),"Could not find cdn_pcie_hls_bridge_env_config(env_cfg) in ConfigDB database.");
    end
    
    //--- Fetch all interface APIs ----------------------------------------------
    m_env_cfg.get_ifs_api();

    //-- Setting coverage enable bit for all the subcomponents within this environment.
    uvm_config_int::set(this, "*", "has_coverage", m_env_cfg.coverage_enable);
    uvm_config_int::set(this, "*psv_agent.monitor", "coverageEnable", m_env_cfg.coverage_enable);

    //-- Fetch hls_bridge_config for register configuration ------------------
    if(!uvm_config_db#(cdn_pcie_hls_bridge_config)::get(this, "", "hls_bridge_config", m_hls_bridge_config)) begin
      `uvm_fatal(get_type_name(),"Could not find cdn_pcie_hls_bridge_config(hls_bridge_config) in ConfigDB database.");
    end

    //--- Fetch strap config------------------------------------------------------
    if(!uvm_config_db#(cdn_pcie_strap_top_config)::get(this, "", "i_cfg", i_cfg)) begin
      `uvm_fatal(get_type_name(),"Could not find cdn_pcie_strap_top_config(i_cfg) in ConfigDB database.");
    end
    
    //--- Fetch Link config-------------------------------------------------------
    if(!uvm_config_db #(cdn_hpa_pcie_link_config)::get(this, "", "link_cfg", m_link_config)) begin
      `uvm_fatal(get_type_name(), "Could not find cdn_hpa_pcie_link_config(link_cfg) in ConfigDB database.")
    end
    
    //--- Fetch DUT Dev Top config------------------------------------------------
    if(!uvm_config_db #(cdn_pcie_hpa_dev_top_config)::get(this, "", "dev_top_cfg", m_dev_top_config)) begin
      `uvm_fatal(get_type_name(), "Could not find cdn_pcie_hpa_dev_top_config(dev_top_cfg) in ConfigDB database.")
    end

    //--- Fetch Remote Dev Top config---------------------------------------------
`ifdef HLS_BRIDGE_TB_IN_PASSIVE_MODE
    if(!uvm_config_db #(cdn_pcie_hpa_dev_top_config)::get(this, "", "vip_top_cfg", m_remote_dev_top_config)) begin
      `uvm_fatal(get_type_name(), "Could not find cdn_pcie_hpa_dev_top_config(vip_top_cfg) in ConfigDB database.")
    end
`else
    if(!uvm_config_db #(cdn_pcie_hpa_dev_top_config)::get(this, "", "remote_dev_top_cfg", m_remote_dev_top_config)) begin
      `uvm_fatal(get_type_name(), "Could not find cdn_pcie_hpa_dev_top_config(remote_dev_top_cfg) in ConfigDB database.")
    end
`endif

  endfunction : build_cfgs

  //----------------------------------------------------------------------------
  // Function: build_clk_env
  // This method creates the clock environment along with the config.
  //----------------------------------------------------------------------------
  function void build_clk_env();
    
    //---Clock env--------------------------------------------------------------
    m_env_cfg.set_clk_cfg();
    m_clk_env = cdn_clock_env::type_id::create("m_clk_env", this);

  endfunction : build_clk_env

  //----------------------------------------------------------------------------
  // Function: build_rst_env
  // This method creates all the reset environments along with the configs.
  //----------------------------------------------------------------------------
  function void build_rst_env();
    //---Core reset env------------------------------------------------------------
    m_env_cfg.set_core_rst_cfg();
    m_core_rst_env = cdn_reset_env::type_id::create("m_core_rst_env", this);

    //---AXI MSI reset env-------------------------------------------------------------
    m_env_cfg.set_axi_msi_rst_cfg();
    m_axi_msi_rst_env = cdn_reset_env::type_id::create("m_axi_msi_rst_env", this);

    //---AXI DTI reset env-------------------------------------------------------------
    m_env_cfg.set_axi_dti_rst_cfg();
    m_axi_dti_rst_env = cdn_reset_env::type_id::create("m_axi_dti_rst_env", this);

    //---AXIL reset env------------------------------------------------------------
    m_env_cfg.set_axil_rst_cfg();
    m_axil_rst_env = cdn_reset_env::type_id::create("m_axil_rst_env", this);

  endfunction : build_rst_env
  
  //----------------------------------------------------------------------------
  // Function: build_cxs_env
  // This method creates all the CXS environments along with the configs for
  // both OB/IB Direction.
  //----------------------------------------------------------------------------
  function void build_cxs_env();
    //---HLS OB Posted HAL Env-----------------------------------------------------
    m_env_cfg.set_hls_ob_posted_hal_cfg();
    m_hls_ob_posted_hal_env = cdn_hls_env::type_id::create("m_hls_ob_posted_hal_env", this);
    
    //---HLS OB NonPosted HAL Env--------------------------------------------------
    m_env_cfg.set_hls_ob_nonposted_hal_cfg();
    m_hls_ob_nonposted_hal_env = cdn_hls_env::type_id::create("m_hls_ob_nonposted_hal_env", this); 
    
    //---HLS OB Compl HAL Env------------------------------------------------------
    m_env_cfg.set_hls_ob_compl_hal_cfg();
    m_hls_ob_compl_hal_env = cdn_hls_env::type_id::create("m_hls_ob_compl_hal_env", this); 
    
    //---HLS IB Posted HAL Env-----------------------------------------------------
    m_env_cfg.set_hls_ib_posted_hal_cfg();
    m_hls_ib_posted_hal_env = cdn_hls_env::type_id::create("m_hls_ib_posted_hal_env", this);
    
    //---HLS IB NonPosted HAL Env--------------------------------------------------
    m_env_cfg.set_hls_ib_nonposted_hal_cfg();
    m_hls_ib_nonposted_hal_env = cdn_hls_env::type_id::create("m_hls_ib_nonposted_hal_env", this);
    
    //---HLS IB Compl HAL Env------------------------------------------------------
    m_env_cfg.set_hls_ib_compl_hal_cfg();
    m_hls_ib_compl_hal_env = cdn_hls_env::type_id::create("m_hls_ib_compl_hal_env", this);
    
    //---HLS OB Posted AXI Env(Per Port)-------------------------------------------
    m_env_cfg.set_hls_ob_posted_axi_cfg();
    foreach(m_hls_ob_posted_axi_env[loop_port]) begin
      m_hls_ob_posted_axi_env[loop_port] = cdn_hls_env::type_id::create($sformatf("m_hls_ob_posted_axi_env[%0d]", loop_port), this);
    end
    
    //---HLS OB NonPosted AXI Env(Per Port)-------------------------------------------
    m_env_cfg.set_hls_ob_nonposted_axi_cfg();
    foreach(m_hls_ob_nonposted_axi_env[loop_port]) begin
      m_hls_ob_nonposted_axi_env[loop_port] = cdn_hls_env::type_id::create($sformatf("m_hls_ob_nonposted_axi_env[%0d]", loop_port), this);
    end
   
    //---HLS OB Compl AXI Env(Per Port)-----------------------------------------------
    m_env_cfg.set_hls_ob_compl_axi_cfg();
    foreach(m_hls_ob_compl_axi_env[loop_port]) begin
      m_hls_ob_compl_axi_env[loop_port] = cdn_hls_env::type_id::create($sformatf("m_hls_ob_compl_axi_env[%0d]", loop_port), this);
    end

    //---HLS IB Posted AXI Env(Per Port)----------------------------------------------
    m_env_cfg.set_hls_ib_posted_axi_cfg();
    foreach(m_hls_ib_posted_axi_env[loop_port]) begin
      m_hls_ib_posted_axi_env[loop_port] = cdn_hls_env::type_id::create($sformatf("m_hls_ib_posted_axi_env[%0d]", loop_port), this);
    end
    
    //---HLS IB NonPosted AXI Env(Per Port)-------------------------------------------
    m_env_cfg.set_hls_ib_nonposted_axi_cfg();
    foreach(m_hls_ib_nonposted_axi_env[loop_port]) begin
      m_hls_ib_nonposted_axi_env[loop_port] = cdn_hls_env::type_id::create($sformatf("m_hls_ib_nonposted_axi_env[%0d]", loop_port), this);
    end 
    
    //---HLS IB Compl AXI Env(Per Port)-----------------------------------------------
    m_env_cfg.set_hls_ib_compl_axi_cfg();
    foreach(m_hls_ib_compl_axi_env[loop_port]) begin
      m_hls_ib_compl_axi_env[loop_port] = cdn_hls_env::type_id::create($sformatf("m_hls_ib_compl_axi_env[%0d]", loop_port), this);
    end

  endfunction : build_cxs_env

  //----------------------------------------------------------------------------
  // Function: build_hdr2log_env
  // This method creates the hdr2log environments along with the configs.
  //----------------------------------------------------------------------------
  function void build_hdr2log_env();
    //---HDR2LOG Master env-------------------------------------------------------
    m_env_cfg.set_hdr2log_mst_cfg();
    foreach(m_hdr2log_mst_env[loop_port]) begin
      m_hdr2log_mst_env[loop_port] = cdn_axi_stream_vip_env::type_id::create($sformatf("m_hdr2log_mst_env[%0d]", loop_port), this);
    end
    
    //---HDR2LOG Slave env--------------------------------------------------------
    m_env_cfg.set_hdr2log_slv_cfg(); 
    m_hdr2log_slv_env = cdn_axi_stream_vip_env::type_id::create("m_hdr2log_slv_env", this);

  endfunction : build_hdr2log_env

  //----------------------------------------------------------------------------
  // Function: build_msi_env
  // This method creates the MSI Environments along with the configs.
  //----------------------------------------------------------------------------
  function void build_msi_env();
    
    //---MSI Slave env----------------------------------------------------------
    m_env_cfg.set_axis_msi_slv_cfg(); 
    m_axis_msi_slv_env = cdn_axi_stream_vip_env::type_id::create("m_axis_msi_slv_env", this);

  endfunction : build_msi_env

  //----------------------------------------------------------------------------
  // Function: build_dc_env
  // This method creates the Delivered Count environments along with the configs.
  //----------------------------------------------------------------------------
  function void build_dc_env();
    //---Delivered Count Master env-------------------------------------------------------
    m_env_cfg.set_dc_mst_cfg();
    foreach(m_dc_mst_env[loop_port]) begin
      m_dc_mst_env[loop_port] = cdn_axi_stream_vip_env::type_id::create($sformatf("m_dc_mst_env[%0d]", loop_port), this);
    end
    
    //---Delivered Count Slave env--------------------------------------------------------
    m_env_cfg.set_dc_slv_cfg(); 
    m_dc_slv_env = cdn_axi_stream_vip_env::type_id::create("m_dc_slv_env", this);

  endfunction : build_dc_env

  //----------------------------------------------------------------------------
  // Function: build_qos_env
  // This method creates the QoS environments along with the configs.
  //----------------------------------------------------------------------------
  function void build_qos_env();
    //QoS Master env 
    m_env_cfg.set_qos_mst_cfg();
    foreach(m_qos_mst_env[loop_port]) begin
      m_qos_mst_env[loop_port] =cdn_axi_stream_vip_env::type_id::create($sformatf("m_qos_mst_env[%0d]", loop_port), this);
    end

    //QoS Slave env
    m_env_cfg.set_qos_slv_cfg();
    m_qos_slv_env =cdn_axi_stream_vip_env::type_id::create("m_qos_slv_env", this);

  endfunction
  
  //----------------------------------------------------------------------------
  // Function: build_lti_c_env
  // This method creates the LTI Completion environments along with the configs.
  //----------------------------------------------------------------------------
  function void build_lti_c_env();
    //---LTI Completion TX env------------------------------------------------------------
    m_env_cfg.set_lti_c_tx_cfg();
    foreach(m_lti_c_tx_env[loop_port]) begin
      m_lti_c_tx_env[loop_port] = cdn_axi_stream_vip_env::type_id::create($sformatf("m_lti_c_tx_env[%0d]", loop_port), this);
    end
    
    //---LTI Completion RX env------------------------------------------------------------
    m_env_cfg.set_lti_c_rx_cfg(); 
    m_lti_c_rx_env = cdn_axi_stream_vip_env::type_id::create("m_lti_c_rx_env", this);

  endfunction : build_lti_c_env

  //----------------------------------------------------------------------------
  // Function: build_axi_lite_env
  // This method creates the AXI Lite environments along with the configs.
  //----------------------------------------------------------------------------
  function void build_axi_lite_env();
    //---AXI Lite Master env------------------------------------------------------
    m_env_cfg.set_axi_lite_mst_cfg();
    m_axi_lite_mst_env = cdn_axi_env::type_id::create("m_axi_lite_mst_env", this);
    //---- Passing is_active instead of configDB since it is not working. --------
    m_axi_lite_mst_env.is_active = m_env_cfg.m_is_active;

    //---AXI Lite Slave env-------------------------------------------------------
    m_env_cfg.set_axi_lite_slv_cfg();
    m_axi_lite_slv_env = cdn_axi_env::type_id::create("m_axi_lite_slv_env", this);
    //---- Passing is_active instead of configDB since it is not working. --------
    m_axi_lite_slv_env.is_active = m_env_cfg.m_is_active;

  endfunction : build_axi_lite_env

`ifdef DTI_TB_IN_PASSIVE_MODE
  //----------------------------------------------------------------------------
  // Function: build_dti_env
  //----------------------------------------------------------------------------
  function void build_dti_env();
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT == 0)
      return; 
   
    //--- Env connected to the SMMU Interface will always be active even though DTI TB is Passive ------------------
    uvm_config_db#(uvm_active_passive_enum)::set(this, "dti_env.dti_ats_env", "is_active", UVM_ACTIVE);

    m_env_cfg.set_dti_cfg();

    if (!m_env_cfg.m_dti_cfg.randomize() with {
      (m_vseqr) -> sup_pri == m_vseqr.p_scenario.m_sup_pri;
      (m_vseqr && m_vseqr.p_scenario.m_generate_max_translation_req_traffic) -> requested_version == CDN_PCIE_DTI_ATS_VERSION_V4;
      (m_vseqr && m_vseqr.p_scenario.m_generate_max_translation_req_traffic) -> number_of_req_trans_tokens == 'd4095;
    }) begin
      `uvm_fatal(get_type_name(), "Cannot randomize DTI config object.")
    end

    dti_env = cdn_pcie_dti_env::type_id::create("dti_env", this);
  endfunction : build_dti_env
`endif

  //----------------------------------------------------------------------------
  // Function: build_misc_comp
  // This method creates other miscellaneous comps like tag manager
  // , cif router, env monitor etc along with the configs.
  //----------------------------------------------------------------------------
  function void build_misc_comp();
    // --- OB Trans Env --------------------------------------------------------
    if(m_env_cfg.is_active()) begin
      l_cfg_info_ob.m_dut_mode      = i_cfg.strap_is_rp ? RP : EP;
      l_cfg_info_ob.m_port_type     = i_cfg.strap_is_rp ? CDN_HPA_PCIE_DSP : CDN_HPA_PCIE_USP;
      l_cfg_info_ob.m_link_cfg      = m_link_config;
      l_cfg_info_ob.m_tlp_dir       = CDN_HPA_PCIE_OUTBOUND;
      l_cfg_info_ob.hpa_tlp_cg_name = "pcie_tlp_cg";
      m_hls_ob_trans_env = cdn_pcie_hpa_trans_env::type_id::create("m_hls_ob_trans_env", this);
      m_hls_ob_trans_env.m_num_hls_ports   = parameters_cfg_pkg::NUM_HLS_PORTS;
      m_hls_ob_trans_env.m_enable_pkt_gaps = m_vseqr.p_scenario.m_enable_pkt_gaps; // For OB Traffic DUT can have packets which are not tightly packed.
    end

    // --- IB Trans Env --------------------------------------------------------
    if(m_env_cfg.is_active()) begin
      l_cfg_info_ib.m_dut_mode      = i_cfg.strap_is_rp ? EP : RP;
      l_cfg_info_ib.m_port_type     = i_cfg.strap_is_rp ? CDN_HPA_PCIE_USP : CDN_HPA_PCIE_DSP;
      l_cfg_info_ib.m_link_cfg      = m_link_config;
      l_cfg_info_ib.m_tlp_dir       = CDN_HPA_PCIE_OUTBOUND; // For remote side the direction will be outbound only, for DUT side it is inbound.
      l_cfg_info_ib.hpa_tlp_cg_name = "pcie_tlp_cg";
      m_hls_ib_trans_env = cdn_pcie_hpa_trans_env::type_id::create("m_hls_ib_trans_env", this);
      m_hls_ib_trans_env.m_num_hls_ports   = 1;
      m_hls_ib_trans_env.m_enable_pkt_gaps = 0; // For IB Traffic DUT Tightly packs the packet hence the gaps is always disabled.
    end

    //--- HLS Bridge Main Monitor ------------------------------------------------
    m_env_mon = cdn_pcie_hls_bridge_monitor::type_id::create("m_env_mon", this);
    
    //--- HLS Bridge Reset Manager ------------------------------------------------
    m_reset_manager = cdn_pcie_hls_bridge_reset_manager::type_id::create("m_reset_manager", this);
    
    //--- HLS Bridge AXI-Lite Slv Callback Monitor -------------------------------
    m_axil_slv_cb_mon = cdn_pcie_hls_bridge_axi_slv_cb_monitor::type_id::create("m_axil_slv_cb_mon", this);

    //--- Kproxy for TLP Cov Collector ------------------------------------------- 
    m_kproxy_strap = cdn_pcie_strap_kval_proxy::type_id::create("m_kproxy_strap", this);
    m_kproxy_strap.set_kvalues();
    m_kproxy_strap.set_kvalues_override(.l_ide_support(i_cfg.k_ide_supported), .l_flit_mode_supported(m_dev_top_config.flit_mode_negotiated), .l_flit_prefix_possible(1));
    m_kproxy_strap.bypass_dut_type_chk = 0; // This is for module level to cover all the spaces

    uvm_config_db#(cdn_pcie_strap_kval_proxy)::set(this, "m_env_mon*", "m_kproxy_strap", m_kproxy_strap);
  endfunction : build_misc_comp
  
  //----------------------------------------------------------------------------
  // Function: build_reg
  // This method creates reigster model and the related components
  //----------------------------------------------------------------------------
  function void build_reg();
    //--- Register Related Components---------------------------------------------
    m_reg2axil_adapter   = cdn_reg_adapter::type_id::create("m_reg2axil_adapter", this);
    m_axil_reg_predictor = uvm_reg_predictor#(denaliCdn_axiTransaction)::type_id::create("m_axil_reg_predictor", this);

    //--- Top Register Model -----------------------------------------------------
    if (m_env_cfg.is_active()) begin
      top_regmodel = cdnpcie_reg_rdb::type_id::create("top_regmodel", this);
      top_regmodel.build();
      top_regmodel.lock_model();
    end
    else begin
      if (!uvm_config_db#(cdnpcie_reg_rdb)::get(this, "", "reg_model", top_regmodel)) begin
        `uvm_fatal(get_type_name(), "Unable to read top reg_model object from ConfigDB.");
      end
    end
    
    //--- HLS Bridge Register Model----------------------------------------------
    hls_bridge_regmodel = top_regmodel.hls_bridge_model_h;
    if (m_env_cfg.coverage_enable) void'(hls_bridge_regmodel.set_coverage(UVM_CVR_ALL));
    uvm_config_db #(hls_bridge_reg_model)::set(this, "*", "hls_bridge_regmodel", hls_bridge_regmodel);

`ifdef DTI_TB_IN_PASSIVE_MODE
    //--- DTI Register Model ---------------------------------
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      dti_regs_model = top_regmodel.dti_ats_model_h;
      uvm_config_db #(dti_ats_reg_model)::set(this, "dti_env", "dti_regs_model", dti_regs_model);
      uvm_config_db #(T_dti_registers)::set(this, "dti_env", "dti_regs", dti_regs_model.HLS_Bridge_dti_ats.dti_registers);
    end
`endif

  endfunction : build_reg
  
  //----------------------------------------------------------------------------
  // Function: connect_hls_ob_trans_env
  // This method will add connections related to OB CIF Router and Tag Manager.
  //----------------------------------------------------------------------------
  function void connect_hls_ob_trans_env();
    m_hls_ob_trans_env.m_pcie_strap_cfg               = i_cfg;
    
    m_hls_ob_trans_env.cif_router.m_pcie_strap_cfg    = i_cfg;
    m_hls_ob_trans_env.cif_router.m_pcie_link_cfg     = m_link_config;
    m_hls_ob_trans_env.cif_router.m_pcie_dev_top_cfg  = m_dev_top_config; 
    m_hls_ob_trans_env.cif_router.m_pcie_dev_cfg      = m_dev_top_config.pf_config[0];
    m_hls_ob_trans_env.cif_router.m_dut_mode          = i_cfg.strap_is_rp ? RP : EP;
    m_hls_ob_trans_env.cif_router.m_num_dut_pf        = i_cfg.k_num_pfs;
    m_hls_ob_trans_env.cif_router.is_hls_module_tb    = 1;
    
    m_hls_ob_trans_env.cif_router.seq_item_port.connect(m_vseqr.hls_ob_tlp_sqr.seq_item_export);
    m_env_mon.ib_np_req_ap.connect(m_hls_ob_trans_env.cif_router.ib_np_req_export);
    m_env_mon.ib_uio_p_req_ap.connect(m_hls_ob_trans_env.cif_router.ib_p_req_export);
    
    if(!$cast(m_hls_ob_trans_env.cif_router.dev_seqr, m_vseqr)) begin
      `uvm_fatal(get_type_name(), "m_vseqr casting to m_hls_ob_trans_env.cif_router.dev_seqr failed!!")
    end
    for(int i = 0; i < parameters_cfg_pkg::NUM_HLS_PORTS; i++) begin
      if(!$cast(m_hls_ob_trans_env.cif_router.m_ob_p_cxs_sqr[0][i], m_hls_ob_posted_axi_env[i].cxs_env.act_agent.sequencer)) begin
        `uvm_fatal(get_type_name(), $sformatf("m_hls_ob_posted_axi_env[%0d].cxs_env.act_agent.sequencer casting failed!!", i))
      end
      if(!$cast(m_hls_ob_trans_env.cif_router.m_ob_compl_cxs_sqr[0][i], m_hls_ob_compl_axi_env[i].cxs_env.act_agent.sequencer)) begin
        `uvm_fatal(get_type_name(), $sformatf("m_hls_ob_compl_axi_env[%0d].cxs_env.act_agent.sequencer casting failed!!", i))
      end
    end

    m_hls_ob_trans_env.tag_manager.m_pcie_strap_cfg   = i_cfg;
    m_hls_ob_trans_env.tag_manager.m_pcie_dev_top_cfg = m_dev_top_config;
    m_hls_ob_trans_env.tag_manager.m_pcie_vip_top_cfg = m_dev_top_config;
    m_hls_ob_trans_env.tag_manager.m_cfg_info         = l_cfg_info_ob;
    
    if(!$cast(m_hls_ob_trans_env.tag_manager.dev_seqr, m_vseqr)) begin
      `uvm_fatal(get_type_name(), "m_hls_ob_trans_env.tag_manager.dev_seqr cast failed!!")
    end
    for(int i = 0; i < parameters_cfg_pkg::NUM_HLS_PORTS; i++) begin
      if(!$cast(m_hls_ob_trans_env.tag_manager.m_ob_np_cxs_sqr[0][i], m_hls_ob_nonposted_axi_env[i].cxs_env.act_agent.sequencer)) begin
        `uvm_fatal(get_type_name(), $sformatf("m_hls_ob_non_posted_axi_env[%0d].cxs_env.act_agent.sequencer cast failed!!", i))
      end
    end

    m_env_mon.ib_compl_req_ap.connect(m_hls_ob_trans_env.tag_manager.ib_compl_cbport_export);
    m_env_mon.m_ob_compl_lut_obj = m_hls_ob_trans_env.tag_manager.compl_lut_obj;

    if(i_cfg.k_np_records_table_size > 256) begin
      m_hls_ob_trans_env.tag_manager_10_bit.m_pcie_strap_cfg   = i_cfg;
      m_hls_ob_trans_env.tag_manager_10_bit.m_pcie_dev_top_cfg = m_dev_top_config;
      m_hls_ob_trans_env.tag_manager_10_bit.m_pcie_vip_top_cfg = m_dev_top_config;
      m_hls_ob_trans_env.tag_manager_10_bit.m_cfg_info         = l_cfg_info_ob;
      
      if(!$cast(m_hls_ob_trans_env.tag_manager_10_bit.dev_seqr, m_vseqr)) begin
        `uvm_fatal(get_full_name(), "tag_manager_10_bit.dev_seqr cast failed !!!!")
      end
      for(int i = 0; i < parameters_cfg_pkg::NUM_HLS_PORTS; i++) begin
        if(!$cast(m_hls_ob_trans_env.tag_manager_10_bit.m_ob_np_cxs_sqr[0][i], m_hls_ob_nonposted_axi_env[i].cxs_env.act_agent.sequencer)) begin
          `uvm_fatal(get_full_name(), $sformatf("m_hls_ob_non_posted_axi_env[%0d].cxs_env.act_agent.sequencer cast failed!!", i))
        end
      end
      m_env_mon.ib_10bit_compl_req_ap.connect(m_hls_ob_trans_env.tag_manager_10_bit.ib_compl_cbport_export);
      m_env_mon.m_ob_compl_lut_obj_10_bit = m_hls_ob_trans_env.tag_manager_10_bit.compl_lut_obj;
    end

    if(i_cfg.k_np_records_table_size > 1024) begin
      m_hls_ob_trans_env.tag_manager_14_bit.m_pcie_strap_cfg   = i_cfg;
      m_hls_ob_trans_env.tag_manager_14_bit.m_pcie_dev_top_cfg = m_dev_top_config;
      m_hls_ob_trans_env.tag_manager_14_bit.m_pcie_vip_top_cfg = m_dev_top_config;
      m_hls_ob_trans_env.tag_manager_14_bit.m_cfg_info         = l_cfg_info_ob;
      
      if(!$cast(m_hls_ob_trans_env.tag_manager_14_bit.dev_seqr, m_vseqr)) begin
        `uvm_fatal(get_type_name(), "tag_manager_14_bit.dev_seqr cast failed !!!!")
      end
      for(int i = 0; i < parameters_cfg_pkg::NUM_HLS_PORTS; i++) begin
        if(!$cast(m_hls_ob_trans_env.tag_manager_14_bit.m_ob_np_cxs_sqr[0][i], m_hls_ob_nonposted_axi_env[i].cxs_env.act_agent.sequencer)) begin
          `uvm_fatal(get_type_name(), $sformatf("m_hls_ob_non_posted_axi_env[%0d].cxs_env.act_agent.sequencer cast failed!!", i))
        end
      end

      m_env_mon.ib_14bit_compl_req_ap.connect(m_hls_ob_trans_env.tag_manager_14_bit.ib_compl_cbport_export);
      m_env_mon.m_ob_compl_lut_obj_14_bit = m_hls_ob_trans_env.tag_manager_14_bit.compl_lut_obj;
    end

    m_hls_ob_trans_env.uio_p_tag_manager.m_pcie_strap_cfg   = i_cfg;
    m_hls_ob_trans_env.uio_p_tag_manager.m_pcie_dev_top_cfg = m_dev_top_config;
    m_hls_ob_trans_env.uio_p_tag_manager.m_pcie_vip_top_cfg = m_dev_top_config;
    m_hls_ob_trans_env.uio_p_tag_manager.m_cfg_info         = l_cfg_info_ob;
    
    if(!$cast(m_hls_ob_trans_env.uio_p_tag_manager.dev_seqr, m_vseqr)) begin
      `uvm_fatal(get_type_name(), "uio_p_tag_manager.dev_seqr cast failed !!!!")
    end
    for(int i = 0; i < parameters_cfg_pkg::NUM_HLS_PORTS; i++) begin
      if(!$cast(m_hls_ob_trans_env.uio_p_tag_manager.m_ob_np_cxs_sqr[0][i], m_hls_ob_posted_axi_env[i].cxs_env.act_agent.sequencer)) begin
        `uvm_fatal(get_type_name(), $sformatf("m_hls_ob_posted_axi_env[%0d].cxs_env.act_agent.sequencer cast failed!!", i))
      end
    end

    m_env_mon.ib_uio_p_compl_req_ap.connect(m_hls_ob_trans_env.uio_p_tag_manager.ib_compl_cbport_export);
    m_env_mon.m_ob_uio_p_compl_lut_obj = m_hls_ob_trans_env.uio_p_tag_manager.compl_lut_obj;
  endfunction : connect_hls_ob_trans_env

  //----------------------------------------------------------------------------
  // Function: connect_hls_ib_trans_env
  // This method will add connections related to IB CIF Router and Tag Manager.
  //----------------------------------------------------------------------------
  function void connect_hls_ib_trans_env();
    m_hls_ib_trans_env.m_pcie_strap_cfg               = i_cfg;
    
    m_hls_ib_trans_env.cif_router.m_pcie_strap_cfg    = i_cfg;
    m_hls_ib_trans_env.cif_router.m_pcie_link_cfg     = m_link_config;
    m_hls_ib_trans_env.cif_router.m_pcie_dev_top_cfg  = m_remote_dev_top_config; 
    m_hls_ib_trans_env.cif_router.m_pcie_dev_cfg      = m_remote_dev_top_config.pf_config[0];
    m_hls_ib_trans_env.cif_router.m_dut_mode          = i_cfg.strap_is_rp ? EP : RP;
    m_hls_ib_trans_env.cif_router.m_num_dut_pf        = i_cfg.k_num_pfs;
    m_hls_ib_trans_env.cif_router.link_side           = 1;
    m_hls_ib_trans_env.cif_router.is_hls_module_tb    = 1;
    m_hls_ib_trans_env.cif_router.compl_lut_obj       = m_hls_ob_trans_env.tag_manager.compl_lut_obj;
    if(i_cfg.k_np_records_table_size > 256) begin
      m_hls_ib_trans_env.cif_router.compl_lut_obj_10_bit    = m_hls_ob_trans_env.tag_manager_10_bit.compl_lut_obj;
    end
    if(i_cfg.k_np_records_table_size > 1024) begin
      m_hls_ib_trans_env.cif_router.compl_lut_obj_14_bit    = m_hls_ob_trans_env.tag_manager_14_bit.compl_lut_obj;
    end
    
    m_hls_ib_trans_env.cif_router.seq_item_port.connect(m_vseqr.hls_ib_tlp_sqr.seq_item_export);
    m_env_mon.ob_np_req_ap.connect(m_hls_ib_trans_env.cif_router.ib_np_req_export);
    m_env_mon.ob_uio_p_req_ap.connect(m_hls_ib_trans_env.cif_router.ib_p_req_export);

    if(!$cast(m_hls_ib_trans_env.cif_router.dev_seqr, m_vseqr)) begin
      `uvm_fatal(get_type_name(), "m_vseqr casting to m_hls_ib_trans_env.cif_router.dev_seqr failed!!")
    end
    if(!$cast(m_hls_ib_trans_env.cif_router.m_ob_p_cxs_sqr[0][0], m_hls_ib_posted_hal_env.cxs_env.act_agent.sequencer)) begin
      `uvm_fatal(get_type_name(), "m_hls_ib_posted_hal_env.cxs_env.act_agent.sequencer casting failed!!")
    end
    if(!$cast(m_hls_ib_trans_env.cif_router.m_ob_compl_cxs_sqr[0][0], m_hls_ib_compl_hal_env.cxs_env.act_agent.sequencer)) begin
      `uvm_fatal(get_type_name(), "m_hls_ib_compl_hal_env.cxs_env.act_agent.sequencer casting failed!!")
    end

    m_hls_ib_trans_env.tag_manager.m_pcie_strap_cfg   = i_cfg;
    m_hls_ib_trans_env.tag_manager.m_pcie_dev_top_cfg = m_remote_dev_top_config;
    m_hls_ib_trans_env.tag_manager.m_pcie_vip_top_cfg = m_remote_dev_top_config;
    m_hls_ib_trans_env.tag_manager.m_cfg_info         = l_cfg_info_ib;
    m_hls_ib_trans_env.tag_manager.link_side          = 1'b1;
    
    if(!$cast(m_hls_ib_trans_env.tag_manager.dev_seqr, m_vseqr)) begin
      `uvm_fatal(get_type_name(), "m_hls_ib_trans_env.tag_manager.dev_seqr cast failed!!")
    end
    if(!$cast(m_hls_ib_trans_env.tag_manager.m_ob_np_cxs_sqr[0][0], m_hls_ib_nonposted_hal_env.cxs_env.act_agent.sequencer)) begin
      `uvm_fatal(get_type_name(), "m_hls_ib_non_posted_hal_env.cxs_env.act_agent.sequencer cast failed!!")
    end
    m_env_mon.ob_compl_req_ap.connect(m_hls_ib_trans_env.tag_manager.ib_compl_cbport_export);
    m_env_mon.m_ib_compl_lut_obj = m_hls_ib_trans_env.tag_manager.compl_lut_obj;

    if(i_cfg.k_np_records_table_size > 256) begin
      m_hls_ib_trans_env.tag_manager_10_bit.m_pcie_strap_cfg   = i_cfg;
      m_hls_ib_trans_env.tag_manager_10_bit.m_pcie_dev_top_cfg = m_remote_dev_top_config;
      m_hls_ib_trans_env.tag_manager_10_bit.m_pcie_vip_top_cfg = m_remote_dev_top_config;
      m_hls_ib_trans_env.tag_manager_10_bit.m_cfg_info         = l_cfg_info_ib;
      m_hls_ib_trans_env.tag_manager_10_bit.link_side          = 1'b1;
      
      if(!$cast(m_hls_ib_trans_env.tag_manager_10_bit.dev_seqr, m_vseqr)) begin
        `uvm_fatal(get_full_name(), "tag_manager_10_bit.dev_seqr cast failed !!!!")
      end
      if(!$cast(m_hls_ib_trans_env.tag_manager_10_bit.m_ob_np_cxs_sqr[0][0], m_hls_ib_nonposted_hal_env.cxs_env.act_agent.sequencer)) begin
        `uvm_fatal(get_full_name(), "m_hls_ib_non_posted_hal_env.cxs_env.act_agent.sequencer cast failed!!")
      end
      
      m_env_mon.ob_10bit_compl_req_ap.connect(m_hls_ib_trans_env.tag_manager_10_bit.ib_compl_cbport_export);
      m_env_mon.m_ib_compl_lut_obj_10_bit = m_hls_ib_trans_env.tag_manager_10_bit.compl_lut_obj;
    end
    
    if(i_cfg.k_np_records_table_size > 1024) begin
      m_hls_ib_trans_env.tag_manager_14_bit.m_pcie_strap_cfg   = i_cfg;
      m_hls_ib_trans_env.tag_manager_14_bit.m_pcie_dev_top_cfg = m_remote_dev_top_config;
      m_hls_ib_trans_env.tag_manager_14_bit.m_pcie_vip_top_cfg = m_remote_dev_top_config;
      m_hls_ib_trans_env.tag_manager_14_bit.m_cfg_info         = l_cfg_info_ib;
      m_hls_ib_trans_env.tag_manager_14_bit.link_side          = 1'b1;
      
      if(!$cast(m_hls_ib_trans_env.tag_manager_14_bit.dev_seqr, m_vseqr)) begin
        `uvm_fatal(get_type_name(), "tag_manager_14_bit.dev_seqr cast failed !!!!")
      end
      if(!$cast(m_hls_ib_trans_env.tag_manager_14_bit.m_ob_np_cxs_sqr[0][0], m_hls_ib_nonposted_hal_env.cxs_env.act_agent.sequencer)) begin
        `uvm_fatal(get_type_name(), "m_hls_ib_non_posted_hal_env.cxs_env.act_agent.sequencer cast failed!!")
      end
      
      m_env_mon.ob_14bit_compl_req_ap.connect(m_hls_ib_trans_env.tag_manager_14_bit.ib_compl_cbport_export);
      m_env_mon.m_ib_compl_lut_obj_14_bit = m_hls_ib_trans_env.tag_manager_14_bit.compl_lut_obj;
    end

    m_hls_ib_trans_env.uio_p_tag_manager.m_pcie_strap_cfg   = i_cfg;
    m_hls_ib_trans_env.uio_p_tag_manager.m_pcie_dev_top_cfg = m_remote_dev_top_config;
    m_hls_ib_trans_env.uio_p_tag_manager.m_pcie_vip_top_cfg = m_remote_dev_top_config;
    m_hls_ib_trans_env.uio_p_tag_manager.m_cfg_info         = l_cfg_info_ib;
    m_hls_ib_trans_env.uio_p_tag_manager.link_side          = 1'b1;
    
    if(!$cast(m_hls_ib_trans_env.uio_p_tag_manager.dev_seqr, m_vseqr)) begin
      `uvm_fatal(get_type_name(), "uio_p_tag_manager.dev_seqr cast failed !!!!")
    end
    if(!$cast(m_hls_ib_trans_env.uio_p_tag_manager.m_ob_np_cxs_sqr[0][0], m_hls_ib_posted_hal_env.cxs_env.act_agent.sequencer)) begin
      `uvm_fatal(get_full_name(), "m_hls_ib_posted_hal_env.cxs_env.act_agent.sequencer cast failed!!")
    end
    
    m_env_mon.ob_uio_p_compl_req_ap.connect(m_hls_ib_trans_env.uio_p_tag_manager.ib_compl_cbport_export);
    m_env_mon.m_ib_uio_p_compl_lut_obj = m_hls_ib_trans_env.uio_p_tag_manager.compl_lut_obj;
    m_hls_ib_trans_env.cif_router.compl_lut_obj_p_uio = m_hls_ob_trans_env.uio_p_tag_manager.compl_lut_obj;

  endfunction : connect_hls_ib_trans_env
  
  //----------------------------------------------------------------------------
  // Function: configure_cxs_vip_reg
  // This method is used for configuring CXS VIP via registers.
  //----------------------------------------------------------------------------
  function void configure_cxs_vip_reg(ref cdn_hls_env hls_env);
    hls_env.cxs_env.psv_agent.regInst.writeReg(DENALI_CXS_REG_NumOfCyclesBeforeStartRtnCredit, $urandom_range(10, 1));
    if(m_env_cfg.is_active()) begin
      hls_env.cxs_env.act_agent.regInst.writeReg( DENALI_CXS_REG_NumOfCyclesBeforeStartRtnCredit, $urandom_range(10, 1));
    end
  endfunction : configure_cxs_vip_reg

  //---------------------------------------------------------------------------
  // Task: wait_cxs_vip_reach_stop_state
  // Helper task which waits for CXS VIP to reach STOP FSM State.
  //---------------------------------------------------------------------------
  task wait_cxs_vip_reach_stop_state(bit is_rx = 0, ref cdn_hls_env hls_env);
    `uvm_info("CXS VIP", $sformatf("starting wait_cxs_vip_reach_stop_state for %s", hls_env.get_full_name()), UVM_DEBUG)
    if(is_rx) begin
      while(hls_env.cxs_env.psv_agent.regInst.readReg(DENALI_CXS_REG_RxLinkState) != 0)
        m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(5));
    end
    else begin
      while(hls_env.cxs_env.psv_agent.regInst.readReg(DENALI_CXS_REG_TxLinkState) != 0)
        m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(5));
    end
    `uvm_info("CXS VIP", $sformatf("end wait_cxs_vip_reach_stop_state for %s", hls_env.get_full_name()), UVM_DEBUG)
  endtask : wait_cxs_vip_reach_stop_state

  //---------------------------------------------------------------------------
  // Task: set_cxs_vips_deacthint
  // Helper task which sets the deacthint signal for all receiver side CXS VIPs.
  //---------------------------------------------------------------------------
  task set_cxs_vips_deacthint(bit value);
    m_hls_ob_posted_hal_env.cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_DeactHint, value);
    m_hls_ob_nonposted_hal_env.cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_DeactHint, value);
    m_hls_ob_compl_hal_env.cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_DeactHint, value);
    foreach(m_hls_ib_posted_axi_env[loop_port])
      m_hls_ib_posted_axi_env[loop_port].cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_DeactHint, value);
    foreach(m_hls_ib_nonposted_axi_env[loop_port])
      m_hls_ib_nonposted_axi_env[loop_port].cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_DeactHint, value);
    foreach(m_hls_ib_compl_axi_env[loop_port])
      m_hls_ib_compl_axi_env[loop_port].cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_DeactHint, value);
  endtask : set_cxs_vips_deacthint

  //---------------------------------------------------------------------------
  // Task: set_cxs_vips_active_req
  // Helper function to assert Active Requests for the CXS VIP.
  //---------------------------------------------------------------------------
  task set_cxs_vips_active_req(bit value);
    foreach(m_hls_ob_posted_axi_env[loop_port])
      m_hls_ob_posted_axi_env[loop_port].cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_AssertActReq, value);
    foreach(m_hls_ob_nonposted_axi_env[loop_port])
      m_hls_ob_nonposted_axi_env[loop_port].cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_AssertActReq, value);
    foreach(m_hls_ob_compl_axi_env[loop_port])
      m_hls_ob_compl_axi_env[loop_port].cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_AssertActReq, value);
    m_hls_ib_posted_hal_env.cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_AssertActReq, value);
    m_hls_ib_nonposted_hal_env.cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_AssertActReq, value);
    m_hls_ib_compl_hal_env.cxs_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_CXS_REG_AssertActReq, value);
  endtask : set_cxs_vips_active_req

  //---------------------------------------------------------------------------
  // Task: wait_cxs_vips_driver_sending_tr
  // Task which waits for the Transmitter CXS VIPs Driver to stop sending the transaction.
  //---------------------------------------------------------------------------
  task wait_cxs_vips_driver_sending_tr();
    bit any_cxs_vip_sending_transaction, temp_sending_transaction;
    do begin
      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
      any_cxs_vip_sending_transaction = 0;
      
      foreach(m_hls_ob_posted_axi_env[loop_port]) begin
        if(!uvm_config_db#(int)::get(this, $sformatf("m_hls_ob_posted_axi_env[%0d].cxs_env.act_agent.driver", loop_port), "sending_transaction", temp_sending_transaction)) begin
          `uvm_fatal(get_type_name(), $sformatf("Unabled to find sending_transaction for m_hls_ob_posted_axi_env[%0d].cxs_env.act_agent.driver", loop_port));
        end
        any_cxs_vip_sending_transaction |= temp_sending_transaction;
      end

      foreach(m_hls_ob_nonposted_axi_env[loop_port]) begin
        if(!uvm_config_db#(int)::get(this, $sformatf("m_hls_ob_nonposted_axi_env[%0d].cxs_env.act_agent.driver", loop_port), "sending_transaction", temp_sending_transaction)) begin
          `uvm_fatal(get_type_name(), $sformatf("Unabled to find sending_transaction for m_hls_ob_nonposted_axi_env[%0d].cxs_env.act_agent.driver", loop_port));
        end
        any_cxs_vip_sending_transaction |= temp_sending_transaction;
      end

      foreach(m_hls_ob_compl_axi_env[loop_port]) begin
        if(!uvm_config_db#(int)::get(this, $sformatf("m_hls_ob_compl_axi_env[%0d].cxs_env.act_agent.driver", loop_port), "sending_transaction", temp_sending_transaction)) begin
          `uvm_fatal(get_type_name(), $sformatf("Unabled to find sending_transaction for m_hls_ob_compl_axi_env[%0d].cxs_env.act_agent.driver", loop_port));
        end
        any_cxs_vip_sending_transaction |= temp_sending_transaction;
      end

      if(!uvm_config_db#(int)::get(this, "m_hls_ib_posted_hal_env.cxs_env.act_agent.driver", "sending_transaction", temp_sending_transaction)) begin
        `uvm_fatal(get_type_name(), "Unabled to find sending_transaction for m_hls_ib_posted_hal_env.cxs_env.act_agent.driver");
      end
      any_cxs_vip_sending_transaction |= temp_sending_transaction;
      
      if(!uvm_config_db#(int)::get(this, "m_hls_ib_nonposted_hal_env.cxs_env.act_agent.driver", "sending_transaction", temp_sending_transaction)) begin
        `uvm_fatal(get_type_name(), "Unabled to find sending_transaction for m_hls_ib_nonposted_hal_env.cxs_env.act_agent.driver");
      end
      any_cxs_vip_sending_transaction |= temp_sending_transaction;
      
      if(!uvm_config_db#(int)::get(this, "m_hls_ib_compl_hal_env.cxs_env.act_agent.driver", "sending_transaction", temp_sending_transaction)) begin
        `uvm_fatal(get_type_name(), "Unabled to find sending_transaction for m_hls_ib_compl_hal_env.cxs_env.act_agent.driver");
      end
      any_cxs_vip_sending_transaction |= temp_sending_transaction;
      
    end while (any_cxs_vip_sending_transaction == 1);
  endtask : wait_cxs_vips_driver_sending_tr

  //----------------------------------------------------------------------------
  // Function: perform_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_RESET", $sformatf("Started resetting of cdn_pcie_hls_bridge_env(%0s) component.....", get_full_name()), UVM_DEBUG)
    
    if(is_linkdown == 0) begin
      //-- Register Model Reset ----------------------------
      top_regmodel.reset();
      hls_bridge_regmodel.reset();
    end

    //-- Clear VIP Queues -------------------------------
    if (m_env_cfg.is_active()) begin
      foreach(m_hls_ob_posted_axi_env[loop_port])
        m_hls_ob_posted_axi_env[loop_port].cxs_env.act_agent.regInst.writeReg(DENALI_CXS_REG_ClearTransactionQueue, 1);
      foreach(m_hls_ob_nonposted_axi_env[loop_port])
        m_hls_ob_nonposted_axi_env[loop_port].cxs_env.act_agent.regInst.writeReg(DENALI_CXS_REG_ClearTransactionQueue, 1);
      foreach(m_hls_ob_compl_axi_env[loop_port])
        m_hls_ob_compl_axi_env[loop_port].cxs_env.act_agent.regInst.writeReg(DENALI_CXS_REG_ClearTransactionQueue, 1);
      
      m_hls_ib_posted_hal_env.cxs_env.act_agent.regInst.writeReg(DENALI_CXS_REG_ClearTransactionQueue, 1);
      m_hls_ib_nonposted_hal_env.cxs_env.act_agent.regInst.writeReg(DENALI_CXS_REG_ClearTransactionQueue, 1);
      m_hls_ib_compl_hal_env.cxs_env.act_agent.regInst.writeReg(DENALI_CXS_REG_ClearTransactionQueue, 1);

      foreach(m_hdr2log_mst_env[loop_port])
        m_hdr2log_mst_env[loop_port].act_agent.regInst.writeReg(DENALI_STREAM_REG_ClearTransactionQueue, 1);
      
      foreach(m_lti_c_tx_env[loop_port])
        m_lti_c_tx_env[loop_port].act_agent.regInst.writeReg(DENALI_STREAM_REG_ClearTransactionQueue, 1);

      foreach(m_dc_mst_env[loop_port])
        m_dc_mst_env[loop_port].act_agent.regInst.writeReg(DENALI_STREAM_REG_ClearTransactionQueue, 1);

      m_axi_lite_mst_env.act_agent.regInst.writeReg(DENALI_CDN_AXI_REG_ClearTransactionQueue, 1);  
      m_axi_lite_slv_env.act_agent.regInst.writeReg(DENALI_CDN_AXI_REG_ClearTransactionQueue, 1);  
    end

    //-- CXS Coverage Collector Reset -------------------
    foreach(m_hls_ob_posted_axi_env[loop_port])
      if (m_hls_ob_posted_axi_env[loop_port].cxs_env.psv_agent.m_has_cxs_cov_collector)
        m_hls_ob_posted_axi_env[loop_port].cxs_env.psv_agent.m_cxs_cov_collector.reset();
     
    foreach(m_hls_ob_nonposted_axi_env[loop_port])
      if (m_hls_ob_nonposted_axi_env[loop_port].cxs_env.psv_agent.m_has_cxs_cov_collector)
        m_hls_ob_nonposted_axi_env[loop_port].cxs_env.psv_agent.m_cxs_cov_collector.reset();   
     
    foreach(m_hls_ob_compl_axi_env[loop_port])
      if (m_hls_ob_compl_axi_env[loop_port].cxs_env.psv_agent.m_has_cxs_cov_collector)
        m_hls_ob_compl_axi_env[loop_port].cxs_env.psv_agent.m_cxs_cov_collector.reset();
    
    foreach(m_hls_ib_posted_axi_env[loop_port])
      if (m_hls_ib_posted_axi_env[loop_port].cxs_env.psv_agent.m_has_cxs_cov_collector)
        m_hls_ib_posted_axi_env[loop_port].cxs_env.psv_agent.m_cxs_cov_collector.reset();
     
    foreach(m_hls_ib_nonposted_axi_env[loop_port])
      if (m_hls_ib_nonposted_axi_env[loop_port].cxs_env.psv_agent.m_has_cxs_cov_collector)
        m_hls_ib_nonposted_axi_env[loop_port].cxs_env.psv_agent.m_cxs_cov_collector.reset();   
     
    foreach(m_hls_ib_compl_axi_env[loop_port])
      if (m_hls_ib_compl_axi_env[loop_port].cxs_env.psv_agent.m_has_cxs_cov_collector)
        m_hls_ib_compl_axi_env[loop_port].cxs_env.psv_agent.m_cxs_cov_collector.reset();   
 
    if (m_hls_ob_posted_hal_env.cxs_env.psv_agent.m_has_cxs_cov_collector)
      m_hls_ob_posted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector.reset();
    
    if (m_hls_ob_nonposted_hal_env.cxs_env.psv_agent.m_has_cxs_cov_collector)
      m_hls_ob_nonposted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector.reset();
    
    if (m_hls_ob_compl_hal_env.cxs_env.psv_agent.m_has_cxs_cov_collector)
      m_hls_ob_compl_hal_env.cxs_env.psv_agent.m_cxs_cov_collector.reset();   
    
    if (m_hls_ib_posted_hal_env.cxs_env.psv_agent.m_has_cxs_cov_collector)
      m_hls_ib_posted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector.reset();
    
    if (m_hls_ib_nonposted_hal_env.cxs_env.psv_agent.m_has_cxs_cov_collector)
      m_hls_ib_nonposted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector.reset();
    
    if (m_hls_ib_compl_hal_env.cxs_env.psv_agent.m_has_cxs_cov_collector)
      m_hls_ib_compl_hal_env.cxs_env.psv_agent.m_cxs_cov_collector.reset();
      
    `uvm_info("PERFORM_RESET", $sformatf("Completed resetting of cdn_pcie_hls_bridge_env(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_reset

  //----------------------------------------------------------------------------
  // Function: perform_axil_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_axil_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Started axil resetting cdn_pcie_hls_bridge_env(%0s) component.....", get_full_name()), UVM_DEBUG)
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Completed axil resetting cdn_pcie_hls_bridge_env(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_axil_reset

  //-----------------------------------------------------------------------------
  // Task : do_demote_axi_error
  // Enable TB to demote the axi vip errors
  //-----------------------------------------------------------------------------
  function void do_demote_axi_error(string error_to_demote);
    m_axi_lite_mst_env.psv_agent.monitor.set_report_severity_id_override(UVM_FATAL, error_to_demote, UVM_WARNING);
    if(m_env_cfg.is_active() == UVM_ACTIVE) begin
      m_axi_lite_mst_env.act_agent.monitor.set_report_severity_id_override(UVM_FATAL, error_to_demote, UVM_WARNING);
    end
  endfunction : do_demote_axi_error
 
endclass : cdn_pcie_hls_bridge_env

`endif // CDN_PCIE_HLS_BRIDGE_ENV_SV
