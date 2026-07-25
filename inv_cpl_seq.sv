`ifndef CDN_PCIE_HLS_BRIDGE_INV_CPL_SEQ_SV
 `define CDN_PCIE_HLS_BRIDGE_INV_CPL_SEQ_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_inv_cpl_seq
// This class overrides the TLP sequence randomization
// in order to generate proper Invalidate Compeletion.
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_inv_cpl_seq extends cdn_pcie_hls_bridge_tlp_seq;

  //----------------------------------------------------------------------------
  // Common random configuration
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  constraint c_num_of_tlps {
    m_number_of_tlps inside  {[1:8]};
  }

  //----------------------------------------------------------------------------
  // Helper variables
  //----------------------------------------------------------------------------
  bit [4:0]  m_tlp_itag;
  bit [31:0] m_tlp_itag_vector ;
  cdn_hpa_pcie_tlp_requester_id_s m_tlp_requester_id;
  cdn_hpa_pcie_tlp_requester_id_s m_tlp_completer_id;
  bit [7:0]  m_stream_id;
  bit [3:0]  m_sub_stream;
  bit        m_ide_t;
  bit        m_ide_prefix_present;

 //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_inv_cpl_seq)
  `uvm_declare_p_sequencer(cdn_hpa_pcie_tlp_vseqr)

  //----------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this sequence class.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_inv_cpl_seq");
    super.new(name);
  endfunction : new

  //------------------------------------------------------------------------
  // Extend or override base methods
  //------------------------------------------------------------------------
  function void pre_randomize();
    super.pre_randomize();
  endfunction : pre_randomize

  function void post_randomize();
    super.post_randomize();
  endfunction : post_randomize

  //---------------------------------------------------------------------------
  // Task: body
  // Executes the sequence's intent.
  //---------------------------------------------------------------------------
  virtual task body();
  for (int loop_tlp = 0; loop_tlp < m_number_of_tlps; loop_tlp++) begin
      m_top_vsqr.p_env.m_env_cfg.m_misc_if_api.wait_unpause_traffic();

      if (!(std::randomize(l_flit_mode_local_prefix_possible) with {l_flit_mode_local_prefix_possible dist {0:=40, 1:=60};})) begin
        `uvm_fatal(get_type_name(), "randomization of l_flit_mode_local_prefix_possible failed")
      end
      
      create_item(.tlp_number(loop_tlp));
      start_item(.item(m_tlp), .sequencer(p_sequencer));
      randomize_item(.tlp_number(loop_tlp));
      finish_item(m_tlp);
    end

  endtask : body

  //----------------------------------------------------------------------------
  // Function: create_item
  // Overrides TL TLP sequence create_item task to modify constraints.
  //----------------------------------------------------------------------------
  virtual function void create_item(int tlp_number = 0);
    cdn_hpa_pcie_link_config               l_pcie_link_cfg;
    cdn_hpa_pcie_dev_config                l_pcie_dev_cfg;

    `uvm_info(get_type_name(), $sformatf("Creating TLP%0d", tlp_number), UVM_DEBUG)

    m_tlp = cdn_hpa_pcie_tlp::type_id::create($sformatf("tlp%0d", tlp_number));

    p_sequencer.m_pcie_link_cfg.pick_link_dev_cfg(.direction("IB"), .dev_cfg(l_pcie_dev_cfg), .link_cfg(l_pcie_link_cfg), .pf(0), .vf(0), .dest_pf(0), .dest_vf(0), .is_vf(0));
    m_tlp.m_pcie_dev_top_cfg  = m_top_vsqr.remote_dev_top_cfg;

    m_tlp.m_pcie_dev_cfg          = l_pcie_dev_cfg;
    m_tlp.m_pcie_link_cfg         = l_pcie_link_cfg;
    m_tlp.pack_ecrc               = m_tlp_seq_pack_ecrc;
    m_tlp.pack_prefix             = m_tlp_seq_pack_prefix;
    m_tlp.m_hls_bypass_constraint = 1;
    m_tlp.hpa_generation          = hpa_generation_2;
    m_tlp.is_flit_mode            = (m_top_vsqr.p_scenario.m_misc_flit_mode == 2'b10);
  endfunction : create_item

  //----------------------------------------------------------------------------
  // Function: randomize_item
  // Overrides TL TLP sequence randomization call to match intent.
  //----------------------------------------------------------------------------
 virtual function void randomize_item(int tlp_number);
    if(m_top_vsqr.p_scenario.m_sanity_test) begin
      c_small_length_tlps.constraint_mode(1);
      c_global_tlp_no_prefix.constraint_mode(1);
      c_global_tlp_fm_local_tlp_prefix_not_present.constraint_mode(1);
    end
    m_tlp.c_default_dsp_msg_rules.constraint_mode(0);
    m_tlp.c_use_user_stream_id.constraint_mode(0);

    // FIX: disabling c_valid_ide_pmkt_bits before randomize so the solver
    // does not conflict with m_ide_t=0 when tdisp_en=1 and tee_lim=1.
    // We post-assign m_ide_t from the captured INV_REQ after randomize.
    m_tlp.c_valid_ide_pmkt_bits.constraint_mode(0);

    if(!m_tlp.randomize() with {
      m_tlp.m_tlp_type         == CDN_HPA_PCIE_TLP_TYPE_Msg;
      m_tlp.m_tlp_msg_code     == CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete;
      m_tlp.m_inv_cpl_cnt      == (m_number_of_tlps == 'd8 ? 3'b0 : m_number_of_tlps);
      m_tlp.m_tlp_itag_vector  == local::m_tlp_itag_vector;
      m_tlp.m_tlp_requester_id == local::m_tlp_requester_id;
      m_tlp.m_tlp_completer_id == local::m_tlp_completer_id;
      m_tlp.m_stream_id        == local::m_stream_id;
      m_tlp.m_sub_stream       == local::m_sub_stream;
      m_tlp.use_user_defined_stream_id == 1;
      m_tlp.m_ide_prefix_possible == local::m_ide_prefix_present;
      m_tlp.m_ide_prefix_present  == local::m_ide_prefix_present;
      m_tlp.m_ide_t ==local::m_ide_t;

    }) begin
      `uvm_fatal(get_type_name(), "TLP randomization target to INV CPL failed...")
    end

    
    

    // Re-enable for any subsequent use of this TLP object
    m_tlp.c_valid_ide_pmkt_bits.constraint_mode(1);

    `uvm_info("", $sformatf("DEGUB: Randomized INV CPL TLP:\n %0s", m_tlp.sprint()), UVM_LOW)
  endfunction : randomize_item
endclass : cdn_pcie_hls_bridge_inv_cpl_seq

`endif // CDN_PCIE_HLS_BRIDGE_INV_CPL_SEQ_SV
`ifndef CDN_PCIE_HLS_BRIDGE_INVALIDATION_SEQ_SV
 `define CDN_PCIE_HLS_BRIDGE_INVALIDATION_SEQ_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_invalidation_seq
// This sequence starts the Invalidation sequence from the SMMU moodel
// in the DTI ATS Env, and geneates a CPL for each REQ that comes out.
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_invalidation_seq extends cdn_pcie_hls_bridge_base_seq;

  //----------------------------------------------------------------------------
  // Common random configuration
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Helper variables
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_invalidation_seq)
  `uvm_declare_p_sequencer(cdn_pcie_hls_bridge_vsequencer)

  //----------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this sequence class.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_invalidation_seq");
    super.new(name);
  endfunction : new

  //------------------------------------------------------------------------
  // Extend or override base methods
  //------------------------------------------------------------------------
  function void pre_randomize();
    super.pre_randomize();
  endfunction : pre_randomize

  function void post_randomize();
    super.post_randomize();
  endfunction : post_randomize

  //---------------------------------------------------------------------------
  // Task: pre_body
  // Executes the requirements before sequence's body starts.
  //---------------------------------------------------------------------------
  virtual task pre_body();
    `uvm_info("VSEQ_START", $sformatf("Starting %0s ...", get_type_name()), UVM_HIGH)
  endtask : pre_body

  //---------------------------------------------------------------------------
  // Task: body
  // Executes the sequence's intent.
  //---------------------------------------------------------------------------
  virtual task body();
    string l_msg_id = $sformatf("[%0s][body]", get_name());

    cdn_pcie_dti_ats_inv_req_seq    ats_inv_req_seq;
    cdn_pcie_hls_bridge_inv_cpl_seq hls_inv_cpl_seq;
    cdn_hpa_pcie_tlp                hls_inv_req_tlp;

    `uvm_info(l_msg_id, "Starting ATS Invalidation Traffic...", UVM_LOW)

    p_sequencer.p_env.m_env_mon.dti_clk_gater_vif.upstream_clk_req = 1'b1;

    // REQ:
    // This sequence starts already forked. No need for fork/join.
    ats_inv_req_seq = cdn_pcie_dti_ats_inv_req_seq::type_id::create("ats_inv_req_seq");
    ats_inv_req_seq.dti_cfg                 = m_env_cfg.m_dti_cfg;
    ats_inv_req_seq.itag_manager_proxy      = p_sequencer.p_env.dti_env.itag_manager_proxy;
    ats_inv_req_seq.amount_of_msgs          = m_scenario.m_num_ats_inv_reqs;
    ats_inv_req_seq.tcu_generator           = p_sequencer.p_env.dti_env.dti_ats_env.tcu_env.tcu_generator;

    if (m_scenario.m_dti_interrupt_scenario) begin
      ats_inv_req_seq.force_fixed_inv_op_type = 1'b1;
      ats_inv_req_seq.operation = 'h30;
    end else begin
      ats_inv_req_seq.force_fixed_inv_op_type = 1'b0;
    end
    ats_inv_req_seq.start(null);

    // wait a few clock cycles for command to send
    m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(10));

    // CPL:
    for (int cpl = 0; cpl < m_scenario.m_num_ats_inv_reqs; cpl++) begin

      if (m_scenario.m_dti_interrupt_scenario) // Packet would be dropped
        break;

      p_sequencer.m_hls_ob_posted_hal_pkt_inv_af.get(hls_inv_req_tlp);

      `uvm_info(l_msg_id, $sformatf("DEGUB: Got INV REQ TLP:\n %0s", hls_inv_req_tlp.sprint()), UVM_LOW)

      `uvm_create_on(hls_inv_cpl_seq, p_sequencer.hls_ib_tlp_sqr)

      hls_inv_cpl_seq.m_top_vsqr            = p_sequencer;
      hls_inv_cpl_seq.is_ib_seq             = 1;
      hls_inv_cpl_seq.m_tlp_seq_pack_prefix = 1;
      hls_inv_cpl_seq.m_tlp_seq_pack_ecrc   = p_sequencer.i_cfg.k_ecrc_capability_support;
      hls_inv_cpl_seq.m_tlp_itag_vector     = 1 << hls_inv_req_tlp.m_tlp_itag;
      hls_inv_cpl_seq.m_tlp_requester_id    = hls_inv_req_tlp.m_tlp_completer_id;
      hls_inv_cpl_seq.m_tlp_completer_id    = hls_inv_req_tlp.m_tlp_requester_id;
      hls_inv_cpl_seq.m_stream_id           = hls_inv_req_tlp.m_stream_id;
      hls_inv_cpl_seq.m_ide_t               = hls_inv_req_tlp.m_ide_t;
      hls_inv_cpl_seq.m_sub_stream          = hls_inv_req_tlp.m_sub_stream;
      hls_inv_cpl_seq.m_ide_prefix_present  = hls_inv_req_tlp.m_ide_prefix_present;

      if (!hls_inv_cpl_seq.randomize()) begin
        `uvm_fatal(l_msg_id, "IB INV CPL sequence randomization failed.")
      end

      `uvm_send(hls_inv_cpl_seq)

    end

    p_sequencer.p_env.m_env_mon.dti_clk_gater_vif.upstream_clk_req = 1'b0;

    `uvm_info(l_msg_id, "Ending ATS Invvalidation Traffic...", UVM_LOW)

  endtask : body

  //---------------------------------------------------------------------------
  // Task: post_body
  // Executes the requirements after sequence's body ends.
  //---------------------------------------------------------------------------
  virtual task post_body();
    `uvm_info("VSEQ_END", $sformatf("Ending %0s ...", get_type_name()), UVM_HIGH)
  endtask : post_body

endclass : cdn_pcie_hls_bridge_invalidation_seq

`endif // CDN_PCIE_HLS_BRIDGE_INVALIDATION_SEQ_SV
