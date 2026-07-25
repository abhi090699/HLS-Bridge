`ifndef CDN_PCIE_HLS_BRIDGE_VSEQUENCER_SV
`define CDN_PCIE_HLS_BRIDGE_VSEQUENCER_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_vsequencer
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_vsequencer extends cdnpcie_sequencer implements I_cdn_pcie_hls_bridge_reset;

  //----------------------------------------------------------------------------
  // Handle to env
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_env p_env;
  
  //----------------------------------------------------------------------------
  // Scenarios & Configs Objects
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_scenario  p_scenario;

  cdn_pcie_strap_top_config     i_cfg;
  
  cdn_pcie_hpa_dev_top_config   dut_top_cfg;
  cdn_pcie_hpa_dev_top_config   remote_dev_top_cfg;

  cdn_hpa_pcie_dev_config       pcie_usp_dev_cfg;
  cdn_hpa_pcie_dev_config       pcie_dsp_dev_cfg;
  
  //----------------------------------------------------------------------------
  // UVC sequencer handles
  //----------------------------------------------------------------------------
  // Clock sequencer handles
  cdn_clock_sequencer    clk_sqr;

  // Reset sequencer handles
  cdn_reset_sequencer    core_rst_sqr;
  cdn_reset_sequencer    axi_msi_rst_sqr;
  cdn_reset_sequencer    axi_dti_rst_sqr;
  cdn_reset_sequencer    reg_axi_msi_rst_sqr;
  cdn_reset_sequencer    axil_rst_sqr;

  // CXS Sequencer handle
  cdnCxsUvmSequencer     hls_ob_posted_axi_sqr   [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdnCxsUvmSequencer     hls_ob_nonposted_axi_sqr[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdnCxsUvmSequencer     hls_ob_compl_axi_sqr    [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdnCxsUvmSequencer     hls_ib_posted_hal_sqr                                      ;
  cdnCxsUvmSequencer     hls_ib_nonposted_hal_sqr                                   ;
  cdnCxsUvmSequencer     hls_ib_compl_hal_sqr                                       ;

  // AXI Lite Master sequencer handle
  cdnAxiUvmSequencer     axi_lite_mst_sqr;
  
  // AXI Lite Slave sequencer handle
  cdnAxiUvmSequencer     axi_lite_slv_sqr;

  // HDR2LOG AXI Stream Master Sequencer handle
  cdnStreamUvmSequencer  hdr2log_mst_sqr[parameters_cfg_pkg::NUM_HLS_PORTS];
  
  // Delivered Count AXI Stream Master Sequencer handle
  cdnStreamUvmSequencer  dc_mst_sqr[parameters_cfg_pkg::NUM_HLS_PORTS];

  // QoS AXI Stream Master Sequencer handle
  
  cdnStreamUvmSequencer  qos_mst_sqr[parameters_cfg_pkg::NUM_HLS_PORTS];
 
  
  
  // LTI Completion AXI Stream TX Sequencer handle
  cdnStreamUvmSequencer  lti_c_tx_sqr[parameters_cfg_pkg::NUM_HLS_PORTS];

  // TLP sequencers handle
  cdn_hpa_pcie_tlp_vseqr hls_ob_tlp_sqr;
  cdn_hpa_pcie_tlp_vseqr hls_ib_tlp_sqr;
 
  //----------------------------------------------------------------------------
  // TLM Analysis Fifos
  //----------------------------------------------------------------------------
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) m_hls_ib_posted_axi_tlp_pkt_delivered_af [parameters_cfg_pkg::NUM_HLS_PORTS];
  
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) m_hls_ib_posted_qos_tlp_af[parameters_cfg_pkg::NUM_HLS_PORTS];
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) m_hls_ib_nonposted_qos_tlp_af[parameters_cfg_pkg::NUM_HLS_PORTS];
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) m_hls_ib_compl_qos_tlp_af[parameters_cfg_pkg::NUM_HLS_PORTS];
 
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) credit_ob_posted_axi_af;
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) credit_ob_posted_hal_af;
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) credit_ob_nonposted_axi_af;
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) credit_ob_nonposted_hal_af;
`ifdef DTI_TB_IN_PASSIVE_MODE
  uvm_tlm_analysis_fifo #(cdn_hpa_pcie_tlp) m_hls_ob_posted_hal_pkt_inv_af;
`endif
  
  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_vsequencer)

  //----------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this sequence class.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_vsequencer", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------------------------
  // Function: build_phase
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    foreach(m_hls_ib_posted_axi_tlp_pkt_delivered_af[loop_port]) begin
      m_hls_ib_posted_axi_tlp_pkt_delivered_af[loop_port] = new($sformatf("m_hls_ib_posted_axi_tlp_pkt_delivered_af[%0d]", loop_port), this);
    end
     

    foreach (m_hls_ib_posted_qos_tlp_af[i]) begin
	  m_hls_ib_posted_qos_tlp_af[i] = new($sformatf("m_hls_ib_posted_qos_tlp_af[%0d]", i), this);
    end

    foreach (m_hls_ib_nonposted_qos_tlp_af[i]) begin
 	 m_hls_ib_nonposted_qos_tlp_af[i] =new($sformatf("m_hls_ib_nonposted_qos_tlp_af[%0d]", i), this);
    end

    foreach (m_hls_ib_compl_qos_tlp_af[i]) begin
 	 m_hls_ib_compl_qos_tlp_af[i] = new($sformatf("m_hls_ib_compl_qos_tlp_af[%0d]", i), this);
    end
   
    
     credit_ob_posted_axi_af = new("credit_ob_posted_axi_af", this);
     credit_ob_posted_hal_af = new("credit_ob_posted_hal_af", this);
     credit_ob_nonposted_axi_af = new("credit_ob_nonposted_axi_af", this);
     credit_ob_nonposted_hal_af = new("credit_ob_nonposted_hal_af", this);
    
     
`ifdef DTI_TB_IN_PASSIVE_MODE
    m_hls_ob_posted_hal_pkt_inv_af = new("m_hls_ob_posted_hal_pkt_inv_af", this);
`endif
  endfunction : build_phase
  
  //---------------------------------------------------------------------------
  // Method: main_phase
  //---------------------------------------------------------------------------
  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask : main_phase
  
  //---------------------------------------------------------------------------
  // Method: stop_sequences
  // This method overrides the UVM Inbuild base method to stop sequences of
  // all the sub sequencers.
  //---------------------------------------------------------------------------
  virtual function void stop_sequences();    
    //-- Stopping CXS & TLP Sequences -----------------------------------------
    stop_cxs_sequences();  

    //-- Stopping all sub Sequencers ------------------------------------------
    if(axi_lite_mst_sqr != null) axi_lite_mst_sqr.stop_sequences();
    if(axi_lite_slv_sqr != null) axi_lite_slv_sqr.stop_sequences();
    foreach(hdr2log_mst_sqr[i])
      if(hdr2log_mst_sqr[i] != null) hdr2log_mst_sqr[i].stop_sequences();
    foreach(dc_mst_sqr[i])
      if(dc_mst_sqr[i] != null) dc_mst_sqr[i].stop_sequences();
       
    foreach(qos_mst_sqr[i])
       if(qos_mst_sqr[i] != null) qos_mst_sqr[i].stop_sequences();
       
    foreach(lti_c_tx_sqr[i])
      if(lti_c_tx_sqr[i] != null) lti_c_tx_sqr[i].stop_sequences();
    
    //-- Stopping THIS Sequencer ----------------------------------------------
    super.stop_sequences();
  endfunction : stop_sequences
  
  //---------------------------------------------------------------------------
  // Method: stop_cxs_sequences
  // This method stops in the CXS Sequences, TLP Sequence, reset & kill
  // CIF Router/Tag Manager,
  //---------------------------------------------------------------------------
  virtual function void stop_cxs_sequences();
    //-- CIF Router and Tag Manager Reset ----------------
    p_env.m_hls_ob_trans_env.cif_router.reset();
    p_env.m_hls_ib_trans_env.cif_router.reset();

    p_env.m_hls_ob_trans_env.tag_manager.reset();
    p_env.m_hls_ib_trans_env.tag_manager.reset();

    if(i_cfg.k_np_records_table_size > 256) begin
      p_env.m_hls_ob_trans_env.tag_manager_10_bit.reset();
      p_env.m_hls_ib_trans_env.tag_manager_10_bit.reset();
    end

    if(i_cfg.k_np_records_table_size > 1024) begin
      p_env.m_hls_ob_trans_env.tag_manager_14_bit.reset();
      p_env.m_hls_ib_trans_env.tag_manager_14_bit.reset();
    end
    
    p_env.m_hls_ob_trans_env.uio_p_tag_manager.reset();
    p_env.m_hls_ib_trans_env.uio_p_tag_manager.reset();

    //-- CIF Router and Tag Manager Kill Seq -------------
    p_env.m_hls_ob_trans_env.cif_router.kill_seq();
    p_env.m_hls_ib_trans_env.cif_router.kill_seq();
    
    p_env.m_hls_ob_trans_env.tag_manager.kill_seq();
    p_env.m_hls_ib_trans_env.tag_manager.kill_seq();
    
    if(i_cfg.k_np_records_table_size > 256) begin
      p_env.m_hls_ob_trans_env.tag_manager_10_bit.kill_seq();
      p_env.m_hls_ib_trans_env.tag_manager_10_bit.kill_seq();
    end
    
    if(i_cfg.k_np_records_table_size > 1024) begin
      p_env.m_hls_ob_trans_env.tag_manager_14_bit.kill_seq();
      p_env.m_hls_ib_trans_env.tag_manager_14_bit.kill_seq();
    end
    
    p_env.m_hls_ob_trans_env.uio_p_tag_manager.kill_seq();
    p_env.m_hls_ib_trans_env.uio_p_tag_manager.kill_seq();

    //-- Stopping all CXS Sequencers ------------------------------------------
    foreach(hls_ob_posted_axi_sqr[i]) begin
      if(hls_ob_posted_axi_sqr[i] != null) hls_ob_posted_axi_sqr[i].stop_sequences();
    end
    foreach(hls_ob_nonposted_axi_sqr[i]) begin
      if(hls_ob_nonposted_axi_sqr[i] != null) hls_ob_nonposted_axi_sqr[i].stop_sequences();
    end
    foreach(hls_ob_compl_axi_sqr[i]) begin
      if(hls_ob_compl_axi_sqr[i] != null) hls_ob_compl_axi_sqr[i].stop_sequences();
    end
    if(hls_ib_posted_hal_sqr != null) hls_ib_posted_hal_sqr.stop_sequences();
    if(hls_ib_nonposted_hal_sqr != null) hls_ib_nonposted_hal_sqr.stop_sequences();
    if(hls_ib_compl_hal_sqr != null) hls_ib_compl_hal_sqr.stop_sequences();
    if(hls_ob_tlp_sqr != null) hls_ob_tlp_sqr.stop_sequences();
    if(hls_ib_tlp_sqr != null) hls_ib_tlp_sqr.stop_sequences();

  endfunction : stop_cxs_sequences 

  //----------------------------------------------------------------------------
  // Function: perform_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_RESET", $sformatf("Started resetting cdn_pcie_hls_bridge_vsequencer(%0s) component.....", get_full_name()), UVM_DEBUG)
    foreach(m_hls_ib_posted_axi_tlp_pkt_delivered_af[loop_port]) begin
      m_hls_ib_posted_axi_tlp_pkt_delivered_af[loop_port].flush();
    end
`ifdef DTI_TB_IN_PASSIVE_MODE
    m_hls_ob_posted_hal_pkt_inv_af.flush();
`endif
    `uvm_info("PERFORM_RESET", $sformatf("Completed resetting cdn_pcie_hls_bridge_vsequencer(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_reset
  
  //----------------------------------------------------------------------------
  // Function: perform_axil_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_axil_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Started axil resetting cdn_pcie_hls_bridge_vsequencer(%0s) component.....", get_full_name()), UVM_DEBUG)
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Completed axil resetting cdn_pcie_hls_bridge_vsequencer(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_axil_reset
  
  //----------------------------------------------------------------------------
  // Function:    is_quiet
  // Description: Function which returns 1 when all the fifos have become empty.
  //----------------------------------------------------------------------------
  virtual function bit is_quiet();
    bit l_is_quiet = 1;

    foreach(m_hls_ib_posted_axi_tlp_pkt_delivered_af[loop_port]) begin
      l_is_quiet &= m_hls_ib_posted_axi_tlp_pkt_delivered_af[loop_port].is_empty();
    end
    
    return l_is_quiet;
  endfunction : is_quiet

endclass : cdn_pcie_hls_bridge_vsequencer

`endif // CDN_PCIE_HLS_BRIDGE_VSEQUENCER_
