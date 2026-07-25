`ifndef CDN_PCIE_HLS_BRIDGE_VSEQ_SV
 `define CDN_PCIE_HLS_BRIDGE_VSEQ_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_vseq
// This sequence is the main virtual sequence which runs multiple subsequences
// ,configures the DUT and start the traffic.
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_vseq extends cdn_pcie_hls_bridge_base_seq;
   
  //----------------------------------------------------------------------------
  // Common random configuration
  //----------------------------------------------------------------------------
`ifdef DTI_TB_IN_PASSIVE_MODE
  cdn_pcie_dti_misc_trans m_dti_misc_trans;
`endif

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Helper variables
  //----------------------------------------------------------------------------
  bit [$clog2(parameters_cfg_pkg::NUM_LTI_PORTS*2)-1 : 0] lti_counter_pool[parameters_cfg_pkg::NUM_HLS_PORTS][$];

  uvm_event low_power_mode_starting_ib_e;
  uvm_event low_power_mode_starting_ob_e;
  uvm_event low_power_mode_done_e;
   
  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_vseq)
  `uvm_declare_p_sequencer(cdn_pcie_hls_bridge_vsequencer)

  //----------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this sequence class.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_vseq");
    super.new(name);

    low_power_mode_starting_ib_e = new();
    low_power_mode_starting_ob_e = new();
    low_power_mode_done_e = new();
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
    
    //--- Post linkdown we don't need to do the device configuration again.
    if(p_sequencer.p_scenario.m_num_link_downs_done == 0) begin
      //--- Configuring the Design ----------------------------------------------
      do_device_config(.msg_id(l_msg_id));
    end
     
    //--- Activating CXS VIP --------------------------------------------------
    p_sequencer.p_env.set_cxs_vips_active_req(.value(1));
    
    //--- Test Specific Configuration(Can be overriden in the extended test) --
    do_user_config_pre_traffic(.msg_id(l_msg_id));

    //--- Start TLP Router/Tag Manger background sequences --------------------
    do_start_trans_env(.msg_id(l_msg_id));

    //--- Fork background thread ----------------------------------------------
    fork
      do_hard_reset(.msg_id(l_msg_id));
      do_link_down();
      do_low_power();
    join_none
     
    //--- Random traffic sequence ---------------------------------------------
    do_traffic(.msg_id(l_msg_id));
     
    //--- End of Test Conditions management -----------------------------------
    do_eot(.msg_id(l_msg_id));
    
    //--- Trigger m_vseq_completed event do end the test ----------------------
    m_env_cfg.vseq_completed_e.trigger();

  endtask : body

  //---------------------------------------------------------------------------
  // Task: post_body
  // Executes the requirements after sequence's body ends.
  //---------------------------------------------------------------------------
  virtual task post_body();
   int    dbg_pkt_count_reset_time;
    int    write_dbg_pkt_count;
    bit [31:0]    write_data ;
    uvm_status_e  l_status;

        dbg_pkt_count_reset_time = $urandom_range(500, 1000);
        write_dbg_pkt_count = $urandom_range(0, 1);

        if(write_dbg_pkt_count) begin
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(dbg_pkt_count_reset_time));

          //writing to debug count register
          reg_write("hls_bridge_axi_ib_c_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_axi_ib_c_pck_count"),.value(write_data));
        `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_axi_ib_c_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_axi_ib_c_pck_count' not cleared after writing 1 !!"))
          end
         //-------------------------------
          reg_write("hls_bridge_axi_ib_np_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_axi_ib_np_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_axi_ib_np_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_axi_ib_np_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_axi_ib_p_pck_count", 32'hffffffff);


          reg_read(.register_name("hls_bridge_axi_ib_p_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_axi_ib_p_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_axi_ib_p_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_axi_ob_c_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_axi_ob_c_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_axi_ob_c_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_axi_ob_c_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_axi_ob_np_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_axi_ob_np_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_axi_ob_np_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_axi_ob_np_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_axi_ob_p_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_axi_ob_p_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_axi_ob_p_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_axi_ob_p_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_dti_ob_c_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_dti_ob_c_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_dti_ob_c_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_dti_ob_c_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_dti_ib_np_pck_count", 32'hffffffff);

           reg_read(.register_name("hls_bridge_dti_ib_np_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_dti_ib_np_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_dti_ib_np_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_dti_ib_p_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_dti_ib_p_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_dti_ib_p_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_dti_ib_p_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_dti_ob_p_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_dti_ob_p_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_dti_ob_p_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_dti_ob_p_pck_count' not cleared after writing 1 !!"))
          end

          //------------------------------
          reg_write("hls_bridge_msi_ib_p_pck_count", 32'hffffffff);

          reg_read(.register_name("hls_bridge_msi_ib_p_pck_count"),.value(write_data));
          `uvm_info("REG_READ",$sformatf("Reading after clear Register= hls_bridge_msi_ib_p_pck_count, Data read= %h",write_data),UVM_LOW)

          if(write_data != 0) begin
            `uvm_error(get_type_name(), $sformatf("Register 'hls_bridge_msi_ib_p_pck_count' not cleared after writing 1 !!"))
          end
        end

    `uvm_info("VSEQ_END", $sformatf("Ending %0s ...", get_type_name()), UVM_HIGH)
  endtask : post_body

  //------------------------------------------------------------------------
  // Helper functions and tasks
  // Where possible use vsequences instead of helper functions
  //------------------------------------------------------------------------
  //-----------------------------------------------------------------------------
  // Task: set_initial_values_crd_lmt
  // Sets the initial values of the crd_lmt interface
  //-----------------------------------------------------------------------------
  virtual task set_initial_values_crd_lmt();     
    for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin
      p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.set_crd_m_lmt_header(vc, p_sequencer.p_scenario.crd_lmt_posted_header[vc]);
      p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.set_crd_m_lmt_payload(vc, p_sequencer.p_scenario.crd_lmt_posted_payload[vc]);   
      p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.set_crd_m_lmt_cntl(vc, p_sequencer.p_scenario.crd_lmt_posted_cntl[vc]);
      
      p_sequencer.p_env.m_env_cfg.m_crd_lmt_nonposted_if_api.set_crd_m_lmt_header(vc, p_sequencer.p_scenario.crd_lmt_nonposted_header[vc]);
      p_sequencer.p_env.m_env_cfg.m_crd_lmt_nonposted_if_api.set_crd_m_lmt_payload(vc, p_sequencer.p_scenario.crd_lmt_nonposted_payload[vc]);
      p_sequencer.p_env.m_env_cfg.m_crd_lmt_nonposted_if_api.set_crd_m_lmt_cntl(vc, p_sequencer.p_scenario.crd_lmt_nonposted_cntl[vc]);

      // Remember the initial values in the env_cfg for later checking
      p_sequencer.p_env.m_env_cfg.initial_crd_lmt_posted_header[vc]  = p_sequencer.p_scenario.crd_lmt_posted_header[vc];
      p_sequencer.p_env.m_env_cfg.initial_crd_lmt_posted_payload[vc] = p_sequencer.p_scenario.crd_lmt_posted_payload[vc];	  
      p_sequencer.p_env.m_env_cfg.initial_crd_lmt_posted_cntl[vc]    = p_sequencer.p_scenario.crd_lmt_posted_cntl[vc];

      p_sequencer.p_env.m_env_cfg.initial_crd_lmt_nonposted_header[vc]  = p_sequencer.p_scenario.crd_lmt_nonposted_header[vc];
      p_sequencer.p_env.m_env_cfg.initial_crd_lmt_nonposted_payload[vc] = p_sequencer.p_scenario.crd_lmt_nonposted_payload[vc];
      p_sequencer.p_env.m_env_cfg.initial_crd_lmt_nonposted_cntl[vc]    = p_sequencer.p_scenario.crd_lmt_nonposted_cntl[vc];
    end   
  endtask : set_initial_values_crd_lmt

  //-----------------------------------------------------------------------------
  // Task: crd_m_lmt_calculation
  // Calculates the headers/payloads of incoming TLPs and 
  // modifies the crd_m_lmt signals accordingly
  //-----------------------------------------------------------------------------  
  virtual task crd_m_lmt_calculation();
    fork 
      begin
        m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
        forever begin
          bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1  : 0] current_credits_header ;
          bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] current_credits_payload;

          bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD - 1 : 0] current_credits_header_nonposted;
          bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD - 1 : 0] current_credits_payload_nonposted;
	  bit [parameters_cfg_pkg::KMAX_NUM_VCS - 1 : 0] 	  vc;
	   
	  bit [parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD - 1 : 0] crd_cntl;

          int posted_header_change  [parameters_cfg_pkg::KMAX_NUM_VCS] = '{default:0};
          int posted_payload_change [parameters_cfg_pkg::KMAX_NUM_VCS] = '{default:0};

          int nonposted_header_change  [parameters_cfg_pkg::KMAX_NUM_VCS] = '{default:0};
          int nonposted_payload_change [parameters_cfg_pkg::KMAX_NUM_VCS] = '{default:0};

          cdn_hpa_pcie_tlp tlp; 

          for (int i = 0; i < p_sequencer.credit_ob_posted_axi_af.used(); i++) begin
            p_sequencer.credit_ob_posted_axi_af.get(tlp);
            vc = tlp.m_tlp_vc;
            p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.get_crd_m_lmt_cntl(vc, crd_cntl);
            if(crd_cntl != 3) begin
              posted_header_change[vc] = posted_header_change[vc] - 1;
              posted_payload_change[vc] = posted_payload_change[vc] - tlp.get_data_credit_units();
            end
          end

          for (int i = 0; i < p_sequencer.credit_ob_nonposted_axi_af.used(); i++) begin
            p_sequencer.credit_ob_nonposted_axi_af.get(tlp);
            vc = tlp.m_tlp_vc;
	     p_sequencer.p_env.m_env_cfg.m_crd_lmt_nonposted_if_api.get_crd_m_lmt_cntl(vc, crd_cntl);
	     if(crd_cntl != 3) begin
            nonposted_header_change[vc] = nonposted_header_change[vc] - 1;
            nonposted_payload_change[vc] = nonposted_payload_change[vc] - tlp.get_data_credit_units();
	     end
          end

          for (int i = 0; i < p_sequencer.credit_ob_posted_hal_af.used(); i++) begin
            p_sequencer.credit_ob_posted_hal_af.get(tlp);
            vc = tlp.m_tlp_vc;
	     p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.get_crd_m_lmt_cntl(vc, crd_cntl);
	     if(crd_cntl != 3) begin
            posted_header_change[vc] = posted_header_change[vc] + 1;
            posted_payload_change[vc] = posted_payload_change[vc] + tlp.get_data_credit_units();
	     end
          end

          for (int i = 0; i < p_sequencer.credit_ob_nonposted_hal_af.used(); i++) begin
            p_sequencer.credit_ob_nonposted_hal_af.get(tlp);
            vc = tlp.m_tlp_vc;
	     p_sequencer.p_env.m_env_cfg.m_crd_lmt_nonposted_if_api.get_crd_m_lmt_cntl(vc, crd_cntl);
	     if(crd_cntl != 3) begin
            nonposted_header_change[vc] = nonposted_header_change[vc] + 1;
            nonposted_payload_change[vc] = nonposted_payload_change[vc] + tlp.get_data_credit_units();
	     end
          end 

          for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin	 
            p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.get_crd_m_lmt_header(vc, current_credits_header);
	     p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.get_crd_m_lmt_payload(vc, current_credits_payload);
	     p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.get_crd_m_lmt_header(vc, current_credits_header_nonposted);
	     p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.get_crd_m_lmt_payload(vc, current_credits_payload_nonposted);
	     fork
		 begin
		    if(parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 1) begin
		       if(posted_header_change[vc] != 0)
		         `uvm_info("ASDADA0", $sformatf("VC: %0h, CHANGE: %0h > CURRENT: %0h, NEXT CHANGE: %0h", vc, posted_header_change[vc], current_credits_header, posted_header_change[vc + 1]), UVM_MEDIUM)
		       if(posted_header_change[vc] > current_credits_header && posted_header_change[vc] < 12'hFFF ) begin  //in cases when we have shared credits and need some from the next vc
			  `uvm_info("ASDADA", $sformatf("CHANGE: %0h > CURRENT: %0h, NEXT CHANGE: %0h", posted_header_change[vc], current_credits_header, posted_header_change[vc + 1]), UVM_MEDIUM)
			  posted_header_change[vc + 1] += posted_header_change[vc] - current_credits_header;
			  
			  posted_header_change[vc] = current_credits_header;	
			  `uvm_info("ASDADA2", $sformatf("CHANGE: %0h > CURRENT: %0h, NEXT CHANGE: %0h", posted_header_change[vc], current_credits_header, posted_header_change[vc + 1]), UVM_MEDIUM)
		       end
		    end
		 end
		 begin
		    if(parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 1) begin
		       if(posted_payload_change[vc] > current_credits_payload && posted_payload_change[vc]  < 12'hFFF) begin
			  posted_payload_change[vc + 1] += posted_payload_change[vc] - current_credits_payload;
			  posted_payload_change[vc] = current_credits_payload;		 
		       end
		    end
		 end
		 begin
		    if(parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 1) begin
		       if(nonposted_header_change[vc] > current_credits_header_nonposted && nonposted_header_change[vc]  < 12'hFFF) begin
			  nonposted_header_change[vc + 1] += nonposted_header_change[vc] - current_credits_header_nonposted;
			  nonposted_header_change[vc] = current_credits_header_nonposted;		 
		       end
		    end
		 end
		 begin
		    if(parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 1) begin
		       if(nonposted_payload_change[vc] > current_credits_payload_nonposted && nonposted_payload_change[vc]  < 12'hFFF) begin
			  nonposted_payload_change[vc + 1] += nonposted_payload_change[vc] - current_credits_payload_nonposted;
			  nonposted_payload_change[vc] = current_credits_payload_nonposted;		 
		       end
		    end
		 end
	      join
       p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.set_crd_m_lmt_header(vc, current_credits_header - posted_header_change[vc]);
	                     
              p_sequencer.p_env.m_env_cfg.m_crd_lmt_posted_if_api.set_crd_m_lmt_payload(vc, current_credits_payload - posted_payload_change[vc]);
	          
              p_sequencer.p_env.m_env_cfg.m_crd_lmt_nonposted_if_api.set_crd_m_lmt_header(vc, current_credits_header_nonposted - nonposted_header_change[vc]);
	                     
              p_sequencer.p_env.m_env_cfg.m_crd_lmt_nonposted_if_api.set_crd_m_lmt_payload(vc, current_credits_payload_nonposted - nonposted_payload_change[vc]);
          end
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
        end
      end
    join_none
  endtask : crd_m_lmt_calculation
  
  //-----------------------------------------------------------------------------
  // Task : do_device_config
  // Method used to configure the device(k-wire, straps, cfg setting,
  // lm settings, DUT registers etc).
  //-----------------------------------------------------------------------------
  virtual task do_device_config(string msg_id = "");
    string l_msg_id = {msg_id, "[do_device_config]"};
    bit[2:0] l_dti_tc;
    
    `uvm_info(l_msg_id, "Starting do_device_config to configure the DUT...", UVM_HIGH)

    // misc_if setting for DTI is needed for register and misc_if settings
    `ifdef DTI_TB_IN_PASSIVE_MODE
    if(parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      m_dti_misc_trans = cdn_pcie_dti_misc_trans::type_id::create("m_dti_misc_trans");
      m_dti_misc_trans.set_strap_config(p_sequencer.i_cfg);

      if(!m_dti_misc_trans.randomize() with {
        foreach(m_dti_misc_trans.tc_mapped_arr[tc]) {
          m_dti_misc_trans.tc_mapped_arr[tc] == (p_sequencer.dut_top_cfg.tc_vc_map[tc] == 9'h1FF);
          m_dti_misc_trans.tc_to_vc_mapping_arr[tc] == ((p_sequencer.dut_top_cfg.tc_vc_map[tc] == 9'h1FF) ? 0 : p_sequencer.dut_top_cfg.tc_vc_map[tc]);
          m_dti_misc_trans.misc_segment_captured == (m_scenario.m_misc_flit_mode == 2'b10 ? p_sequencer.dut_top_cfg.captured_segment_number : 1'b0);
          m_dti_misc_trans.misc_captured_dest_segment == (m_scenario.m_misc_flit_mode == 2'b10 ? p_sequencer.dut_top_cfg.destination_segment : 0);
        }
        })
        `uvm_fatal(l_msg_id, "Randomization of m_dti_misc_trans failed...")

      if (!(std::randomize(l_dti_tc) with {
        int'(m_dti_misc_trans.misc_tc_to_vc_mapping[(l_dti_tc*4) +: 3]) < parameters_cfg_pkg::KMAX_NUM_VCS;
        m_dti_misc_trans.misc_tc_to_vc_mapping[l_dti_tc*4 + 3] == 1'b0;
        l_dti_tc dist {[0:7] := 1};
        })) begin
        `uvm_error(get_type_name(), "Randomization failure for l_dti_tc")
      end
      m_scenario.m_dti_inv_tc = l_dti_tc;
    end
    `endif

    do_dut_register_config(.msg_id(l_msg_id));
    do_misc_config(.msg_id(l_msg_id));

    `uvm_info(l_msg_id, "Finished DUT Configuration...", UVM_HIGH)
  endtask : do_device_config
  
  //-----------------------------------------------------------------------------
  // Task : do_misc_config
  // Method used to set the miscellaneous signals of DUT/lm settings.
  //-----------------------------------------------------------------------------
  virtual task do_misc_config(string msg_id = "");
    string       l_msg_id = {msg_id, "[do_misc_config]"};
    int unsigned l_rand_bar_sel;
    
    `uvm_info(l_msg_id, "Starting do_misc_config to configure the miscellaneous signals...", UVM_HIGH)
    
    if(parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT) begin // Assigning MSI Bar Address if MSI Support is Present && strap_is_rp.
      m_scenario.m_msi_pf = $urandom_range((p_sequencer.dut_top_cfg.m_ep_dev_bar_info.msi_bar.size() - 1), 0);
    end
    else begin // Assigning any bar address if MSI Support is disabled.
      l_rand_bar_sel     = $urandom_range((p_sequencer.dut_top_cfg.pf_config[0].m_fun_bar_info.bars.size() - 1), 0);
    end

    m_env_cfg.m_misc_if_api.set_misc_flit_mode(m_scenario.m_misc_flit_mode)                                           ;
    m_env_cfg.m_misc_if_api.set_misc_pbr_negotiated(m_scenario.m_cxl_pbr_mode_sel)                                    ;
    m_env_cfg.m_misc_if_api.set_misc_tag_management(m_scenario.m_misc_tag_management)                                 ;
    m_env_cfg.m_misc_if_api.set_misc_10_bit_comp_supp(p_sequencer.dut_top_cfg.pf_config[0].m_10_bit_tag_completer_cap);
    m_env_cfg.m_misc_if_api.set_misc_14_bit_comp_supp(p_sequencer.dut_top_cfg.pf_config[0].m_14_bit_tag_compl_supp)   ;
    m_env_cfg.m_misc_if_api.set_lm_segment_num(m_scenario.m_lm_segment_num)                                           ;
    m_env_cfg.m_misc_if_api.set_misc_hls_bridge_route_en(m_scenario.m_hls_bridge_route_en)                            ;

    `uvm_info(get_type_name(), $sformatf("Setting HLS_BRIDGE_ROUTE_EN: %p", m_scenario.m_hls_bridge_route_en), UVM_DEBUG)

`ifdef DTI_TB_IN_PASSIVE_MODE
    if(parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      bit [3:0] misc_tc_to_vc_mapping[8];

      m_env_cfg.m_misc_if_api.set_misc_segment_captured(m_dti_misc_trans.misc_segment_captured);
      m_env_cfg.m_misc_if_api.set_misc_ecrc_generation_enable_per_pf({7'b0, m_dti_misc_trans.misc_ecrc_generation_enable});
      m_env_cfg.m_misc_if_api.set_misc_read_completion_boundary(m_dti_misc_trans.misc_read_completion_boundary);
      m_env_cfg.m_misc_if_api.set_misc_captured_dest_segment(m_dti_misc_trans.misc_captured_dest_segment);

      foreach (p_sequencer.dut_top_cfg.tc_vc_map[tc]) begin
        if(p_sequencer.dut_top_cfg.tc_vc_map[tc] != 9'h1FF) begin // enabled tc
          misc_tc_to_vc_mapping[tc][3] = 0;
          misc_tc_to_vc_mapping[tc][2:0] = p_sequencer.dut_top_cfg.tc_vc_map[tc];
        end
        else begin // disabled tc
          misc_tc_to_vc_mapping[tc][3] = 1;
          misc_tc_to_vc_mapping[tc][2:0] = 0;
        end
      end
      m_env_cfg.m_misc_if_api.set_tc_vc_mapping({<<4{misc_tc_to_vc_mapping}});

      if (parameters_cfg_pkg::KMAX_IDE_NUM_LINK_STREAMS > 0) begin
        bit [11:0] ide_link_stream_control_reg [8];
        int str_idx=0;
        foreach (p_sequencer.remote_dev_top_cfg.ide_cfg.link_stream_id_tc_map[tc]) begin
          // Enable only remote config with remote's stream IDs.
          // DUT config is enabled separately below with its own stream IDs.
          p_sequencer.remote_dev_top_cfg.ide_cfg.enable_link_stream(p_sequencer.remote_dev_top_cfg.ide_cfg.link_stream_id_tc_map[tc]);
          // HLS bridge module does not run the key-exchange protocol; set SECURE
          // state immediately so find_stream_id_mapped_to_tc returns valid stream IDs.
          p_sequencer.remote_dev_top_cfg.ide_cfg.link_ide_str_state[p_sequencer.remote_dev_top_cfg.ide_cfg.link_stream_id_tc_map[tc]] = 'h2;

          ide_link_stream_control_reg[str_idx][0] = p_sequencer.remote_dev_top_cfg.ide_cfg.link_ide_str_enable[p_sequencer.remote_dev_top_cfg.ide_cfg.link_stream_id_tc_map[tc]]; // ide link stream enabled
          ide_link_stream_control_reg[str_idx][3:1] = tc; // tc
          ide_link_stream_control_reg[str_idx][11:4] = p_sequencer.remote_dev_top_cfg.ide_cfg.link_stream_id_tc_map[tc]; // stream id
          `uvm_info(get_type_name(), $sformatf("ide_link_stream_control_reg settings for STREAM INDEX %0d: stream_id %0h, tc %0h, enable %0h",
                                                str_idx, p_sequencer.remote_dev_top_cfg.ide_cfg.link_stream_id_tc_map[tc], tc,
                                                p_sequencer.remote_dev_top_cfg.ide_cfg.link_ide_str_enable[p_sequencer.remote_dev_top_cfg.ide_cfg.link_stream_id_tc_map[tc]]), UVM_DEBUG)
          str_idx++;
        end
        m_env_cfg.m_misc_if_api.set_misc_ide_link_stream_control_reg({<<12{ide_link_stream_control_reg}});
        
        foreach (p_sequencer.dut_top_cfg.ide_cfg.link_stream_id_tc_map[tc]) begin
          // Enable only DUT config with DUT's own stream IDs.
          // Remote config is enabled above with its own stream IDs.
          p_sequencer.dut_top_cfg.ide_cfg.enable_link_stream(p_sequencer.dut_top_cfg.ide_cfg.link_stream_id_tc_map[tc]);
          p_sequencer.dut_top_cfg.ide_cfg.link_ide_str_state[p_sequencer.dut_top_cfg.ide_cfg.link_stream_id_tc_map[tc]] = 'h2;
        end
      end // if (parameters_cfg_pkg::KMAX_IDE_NUM_LINK_STREAMS > 0)

      if (parameters_cfg_pkg::KMAX_IDE_NUM_SEL_STREAMS > 0) begin
        bit [13:0] ide_sel_stream_control_reg [8];
        bit [15:0] ide_sel_stream_rid_assoc1_reg [8];
        bit [24:0] ide_sel_stream_rid_assoc2_reg [8];
        int str_idx=0;
        foreach (p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id]) begin
          p_sequencer.dut_top_cfg.ide_cfg.enable_sel_stream(sel_stream_id);
          p_sequencer.dut_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_selective_ide_stream_state = 'h2;
          p_sequencer.remote_dev_top_cfg.ide_cfg.enable_sel_stream(sel_stream_id);
          p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_selective_ide_stream_state = 'h2;

          ide_sel_stream_control_reg[str_idx][0] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_selective_ide_stream_enable; // ide sel stream enabled
          ide_sel_stream_control_reg[str_idx][3:1] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_mapped_tc; // tc
          ide_sel_stream_control_reg[str_idx][4] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_default_stream; // Default Stream
          ide_sel_stream_control_reg[str_idx][5] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_tee_lim_stream; // TEE-Limited Stream
          ide_sel_stream_control_reg[str_idx][13:6] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_stream_ID; // stream_id
          ide_sel_stream_rid_assoc1_reg[str_idx] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_RID_limit;
          ide_sel_stream_rid_assoc2_reg[str_idx][0] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_RID_valid;
          ide_sel_stream_rid_assoc2_reg[str_idx][16:1] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_RID_base;
          ide_sel_stream_rid_assoc2_reg[str_idx][24:17] = p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_segment_base;
          `uvm_info(get_type_name(), $sformatf("ide_sel_stream_control_reg settings for STREAM INDEX %0d: stream_id %0h, tee-limited stream %0h, default stream %0h, tc %0h, enable %0h",
                                                str_idx, p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_stream_ID,
                                                p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_tee_lim_stream, p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_default_stream,
                                                p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_mapped_tc, p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_selective_ide_stream_enable), UVM_DEBUG)
          `uvm_info(get_type_name(), $sformatf("ide_sel_stream_rid_assoc1_reg settings for STREAM INDEX %0d: RID limit %0h",
                                                str_idx, p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_RID_limit), UVM_DEBUG)
          `uvm_info(get_type_name(), $sformatf("ide_sel_stream_rid_assoc2_reg settings for STREAM INDEX %0d: segment base %0h, RID base %0h, RID valid %0h",
                                                str_idx, p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_segment_base,
                                                p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_RID_base, p_sequencer.remote_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[sel_stream_id].m_RID_valid), UVM_DEBUG)
          str_idx++;
        end
        m_env_cfg.m_misc_if_api.set_misc_ide_sel_stream_control_reg({<<14{ide_sel_stream_control_reg}});
        m_env_cfg.m_misc_if_api.set_misc_ide_sel_stream_rid_assoc1_reg({<<16{ide_sel_stream_rid_assoc1_reg}});
        m_env_cfg.m_misc_if_api.set_misc_ide_sel_stream_rid_assoc2_reg({<<25{ide_sel_stream_rid_assoc2_reg}});
      end // if (parameters_cfg_pkg::KMAX_IDE_NUM_SEL_STREAMS > 0)
    end // if(parameters_cfg_pkg::KMAX_DTI_SUPPORT)
`endif

    `uvm_info(l_msg_id, "Finished configuring the miscellaneous signals...", UVM_HIGH)
  endtask : do_misc_config
  
  //-----------------------------------------------------------------------------
  // Task : do_dut_register_config
  // Method used to configure the DUT Registers.
  //-----------------------------------------------------------------------------
  virtual task do_dut_register_config(string msg_id = "");
    string l_msg_id = {msg_id, "[do_dut_register_config]"};
    cdn_pcie_hls_bridge_dev_init_seq dev_init_seq;
`ifdef DTI_TB_IN_PASSIVE_MODE
    cdn_pcie_hls_bridge_dti_init_seq dti_init_seq;
`endif

    `uvm_info(l_msg_id, "Starting do_dut_register_config to configure the design registers...", UVM_HIGH)
    
    dev_init_seq = cdn_pcie_hls_bridge_dev_init_seq::type_id::create("dev_init_seq");
    if(!dev_init_seq.randomize()) begin
      `uvm_fatal(l_msg_id, $sformatf("Could not randomize %0s sequence.", dev_init_seq.get_type_name()))
    end
    dev_init_seq.start(p_sequencer);

`ifdef DTI_TB_IN_PASSIVE_MODE
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      dti_init_seq = cdn_pcie_hls_bridge_dti_init_seq::type_id::create("dti_init_seq");
      dti_init_seq.start(p_sequencer);
    end
`endif

    `uvm_info(l_msg_id, "Finished configuring the design registers...", UVM_HIGH)
  endtask : do_dut_register_config

  //----------------------------------------------------------------------------
  // Task: do_user_config_pre_traffic
  //----------------------------------------------------------------------------
  virtual task do_user_config_pre_traffic(string msg_id="");
    // User can override configurations from here through extended testcase
  endtask : do_user_config_pre_traffic
  
  //---------------------------------------------------------------------------
  // Task: do_start_trans_env
  // Start the background sequences of CIF Router/Tag Manager.
  //---------------------------------------------------------------------------
  virtual task do_start_trans_env(string msg_id = "");
    string l_msg_id = {msg_id, "[do_start_trans_env]"};
    
    `uvm_info(l_msg_id, "Starting background sequences of OB/IB CIF Router/Tag Manager...", UVM_HIGH)
    
    p_sequencer.p_env.m_hls_ob_trans_env.cif_router.start_bg_seqs();
    p_sequencer.p_env.m_hls_ib_trans_env.cif_router.start_bg_seqs();
    
    p_sequencer.p_env.m_hls_ob_trans_env.tag_manager.start_bg_seqs();
    p_sequencer.p_env.m_hls_ib_trans_env.tag_manager.start_bg_seqs();
    
    if(p_sequencer.i_cfg.k_np_records_table_size > 256) begin
      p_sequencer.p_env.m_hls_ob_trans_env.tag_manager_10_bit.start_bg_seqs();
      p_sequencer.p_env.m_hls_ib_trans_env.tag_manager_10_bit.start_bg_seqs();
    end
    
    if(p_sequencer.i_cfg.k_np_records_table_size > 1024) begin
      p_sequencer.p_env.m_hls_ob_trans_env.tag_manager_14_bit.start_bg_seqs();
      p_sequencer.p_env.m_hls_ib_trans_env.tag_manager_14_bit.start_bg_seqs();
    end
      
    p_sequencer.p_env.m_hls_ob_trans_env.uio_p_tag_manager.start_bg_seqs();
    p_sequencer.p_env.m_hls_ib_trans_env.uio_p_tag_manager.start_bg_seqs();
   
    // Wait for background sequences to start.
    m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(5));

    // Setting this bit to 1 in order to avoid null pointer for translation request LUT Items.
    p_sequencer.p_env.m_hls_ob_trans_env.cif_router.EI_compl_lut_obj.check_at_first_last_cpl = 1;
    p_sequencer.p_env.m_hls_ib_trans_env.cif_router.EI_compl_lut_obj.check_at_first_last_cpl = 1;
  endtask : do_start_trans_env

  //---------------------------------------------------------------------------
  // Task: do_hard_reset
  // Triggers HARD Reset.
  //---------------------------------------------------------------------------
  virtual task do_hard_reset(string msg_id = "");
    string l_msg_id = {msg_id, "[do_hard_reset]"};
    int num_of_pkt_trigger = 0;
    `uvm_info(l_msg_id, "Forking do_hard_reset task thread...", UVM_LOW)
    
    if (m_scenario.m_num_hard_resets_done < m_scenario.m_num_hard_resets) begin
      // --- Wait for some pkts to send before starting the reset. ------------
      if(m_scenario.m_traffic_type inside {ALL_TRAFFIC}) begin
        // max = number of tlps * number_of_bursts * direction * type (P/NP/COMPL)
        num_of_pkt_trigger = $urandom_range((m_scenario.m_number_of_tlps * (m_scenario.m_num_hard_resets_done+1) * 2 * 3), num_of_pkt_trigger);
        wait(p_sequencer.p_env.m_env_mon.m_total_num_pkts_sent >= num_of_pkt_trigger);
      end
      else begin
        wait(p_sequencer.p_env.m_env_mon.m_total_num_pkts_sent >= $urandom_range(m_scenario.m_number_of_tlps, 1));
      end

      // --- Trigger HARD Reset. ----------------------------------------------
      m_scenario.m_num_hard_resets_done++;
      `uvm_info(l_msg_id, "Triggering Hard Reset...", UVM_LOW)
      m_env_cfg.hard_reset_triggered_e.trigger();
    end
    
    `uvm_info(l_msg_id, "Ending do_hard_reset task thread...", UVM_LOW)
  endtask : do_hard_reset

  //---------------------------------------------------------------------------
  // Task: do_link_down
  // Triggers Link Down.
  //---------------------------------------------------------------------------
  virtual task do_link_down(string msg_id = "");
    string l_msg_id = {msg_id, "[do_link_down]"};
    int num_of_pkt_trigger = 0;
    `uvm_info(l_msg_id, "Forking do_link_down task thread...", UVM_LOW)
    
    if (m_scenario.m_num_link_downs_done < m_scenario.m_num_link_downs) begin
      // --- Wait for some pkts to send before starting linkdown. ------------
      if(m_scenario.m_traffic_type inside {ALL_TRAFFIC}) begin
        // max = number of tlps * number_of_bursts * direction * type (P/NP/COMPL)
        num_of_pkt_trigger = $urandom_range((m_scenario.m_number_of_tlps * (m_scenario.m_num_link_downs_done+1) * 2 * 3), num_of_pkt_trigger);
        wait(p_sequencer.p_env.m_env_mon.m_total_num_pkts_sent >= num_of_pkt_trigger);
      end
      else begin
        wait(p_sequencer.p_env.m_env_mon.m_total_num_pkts_sent >= $urandom_range(m_scenario.m_number_of_tlps, 1));
      end

      // --- Trigger Link Down. ----------------------------------------------
      m_scenario.m_num_link_downs_done++;
      `uvm_info(l_msg_id, "Triggering Linkdown...", UVM_LOW)
      m_env_cfg.link_down_triggered_e.trigger();
    end
    
    `uvm_info(l_msg_id, "Ending do_link_down task thread...", UVM_LOW)
  endtask : do_link_down

  //---------------------------------------------------------------------------
  // Task: do_low_power
  // Triggers Low Power Mode.
  //---------------------------------------------------------------------------
  virtual task do_low_power(string msg_id = "");
    string l_msg_id = {msg_id, "[do_low_power]"};
    int l_is_quiet_counter;
    bit l_dti_wakeup;
 
    `uvm_info(l_msg_id, "Starting do_low_power task thread...", UVM_LOW)

    forever begin

      if (m_scenario.m_traffic_type == IB_TRAFFIC_ONLY) begin
        low_power_mode_starting_ib_e.wait_trigger();
      end
      else if (m_scenario.m_traffic_type == OB_TRAFFIC_ONLY) begin
        low_power_mode_starting_ob_e.wait_trigger();
      end
      else begin
        fork
          low_power_mode_starting_ib_e.wait_trigger();
          low_power_mode_starting_ob_e.wait_trigger();
        join
      end

      `uvm_info(l_msg_id, "Triggering Low Power Mode...", UVM_LOW)

      while(l_is_quiet_counter <= 20) begin
        //--- Wait for scoreboards/monitors to be quiet. -------------------------------
        while(!(p_sequencer.p_env.m_env_mon.is_quiet() && p_sequencer.is_quiet())) begin
          l_is_quiet_counter = 0;
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(10));
        end
        //--- Wait for N Quiet Cycles before exiting the do_eot thread. ----------------
        //--- Totyo: increasing the counter, while reducing the delay, to avoid
        //--- a corner case where the quiet checks always happen between packets.
        l_is_quiet_counter++;
        m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(150));
      end

      m_env_cfg.stop_cxs_driver = 1;
      p_sequencer.p_env.set_cxs_vips_deacthint(.value(1));

      //--- Wait for CXS VIPs to reach STOP State. -----
      fork begin
        fork
          begin
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ob_posted_hal_env));
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ob_nonposted_hal_env));
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ob_compl_hal_env));
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ib_posted_hal_env));
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ib_nonposted_hal_env));
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ib_compl_hal_env));
            foreach(p_sequencer.p_env.m_hls_ob_posted_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ob_posted_axi_env[loop_port]));
            foreach(p_sequencer.p_env.m_hls_ob_nonposted_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ob_nonposted_axi_env[loop_port]));
            foreach(p_sequencer.p_env.m_hls_ob_compl_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ob_compl_axi_env[loop_port]));
            foreach(p_sequencer.p_env.m_hls_ib_posted_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ib_posted_axi_env[loop_port]));
            foreach(p_sequencer.p_env.m_hls_ib_nonposted_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ib_nonposted_axi_env[loop_port]));
            foreach(p_sequencer.p_env.m_hls_ib_compl_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ib_compl_axi_env[loop_port]));
          end
          begin
            m_env_cfg.m_hpa_timer.wait_for_time(100, "Max Delay time for CXS VIP to reach STOP State.", "us");
            `uvm_fatal(l_msg_id, "CXS VIPs have not reached the STOP state...")
          end
        join_any
        disable fork;
      end join

      //--- Adding buffer time before starting low power mode ---------------
      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles($urandom_range(1000, 500)));

      //--- Deassert deacthint for the receiver CXS VIPs ----------------------------
      p_sequencer.p_env.set_cxs_vips_deacthint(.value(0));

      //--- Resume CXS Driver -------------------------------------------------------
      m_env_cfg.stop_cxs_driver = 0;

      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles($urandom_range(500, 250)));

      // set low power mode signal
      m_env_cfg.m_misc_if_api.set_low_power_mode(.value(1));

      // enable clock gating
      m_env_cfg.m_misc_if_api.clk_gate_en(1);

      // random time before starting next transaction while clock is disabled
      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles($urandom_range(2000, 1000)));

      fork begin
        fork begin
          fork
            begin
              bit [5:0] hls_active_req;

              // wait for active req on IB/OB HAL
              while(|hls_active_req == 1'b0) begin
                m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(5));
                m_env_cfg.m_misc_if_api.get_hls_active_req(hls_active_req);
              end

              m_env_cfg.m_misc_if_api.clk_gate_en(0);

              m_env_cfg.m_misc_if_api.set_low_power_mode(.value(0));
            end
            begin
              #4us;
              `uvm_fatal(get_type_name(), $sformatf("[Low Power] clock gating timeout"))
            end
          join_any
          disable fork;
        end join
      end join_none

      // randomly starts DTI first
    `ifdef DTI_TB_IN_PASSIVE_MODE
      if (!std::randomize(l_dti_wakeup)) `uvm_error(get_type_name(), "Randomization of l_dti_wakeup failed")
      if (l_dti_wakeup == 0 && parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
        do_ats_inv_req_seq("DTI traffic after low power");
        m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles($urandom_range(100, 50)));
      end
    `endif // DTI_TB_IN_PASSIVE_MODE

      //--- Trigger Low Power Mode Done ---------------------------------------------------
      low_power_mode_done_e.trigger();

      `uvm_info(get_type_name(), $sformatf("Low Power Mode done"), UVM_DEBUG)

    end

    `uvm_info(l_msg_id, "Ending do_low_power task thread...", UVM_LOW)
  endtask : do_low_power

  //---------------------------------------------------------------------------
  // Task: do_traffic
  // Execute stimulus sequence to generate random TLP traffic on the different
  // interfaces
  //---------------------------------------------------------------------------
  virtual task do_traffic(string msg_id = "");
    string l_msg_id = {msg_id, "[do_traffic]"};
    int    dbg_pkt_count_reset_time;
    int    write_dbg_pkt_count;
    bit [31:0]    write_data ;
    uvm_status_e  l_status;


    //--- Set the initial values for the credits limit interface --------------
    set_initial_values_crd_lmt();
     
`ifdef DTI_TB_IN_PASSIVE_MODE
    // This might look like the wrong place to assign this,
    // but it is also where it is set in the DTI environment.
    if(parameters_cfg_pkg::KMAX_DTI_SUPPORT)
      p_sequencer.p_env.dti_ats_env.tcu_env.tcu_generator.force_auto_trans_fault = m_scenario.m_force_ats_trans_fault;
`endif

    //--- Starting background sequence for Delivered Count Generation ---------
    do_dc_stream_seq(l_msg_id);

   p_sequencer.p_env.m_env_cfg.m_qos_support = m_scenario.m_qos_support;
   if(m_scenario.m_qos_support)
  	 do_qos_stream_seq(l_msg_id); 
  

    //--- Background task for calculating credit limit 
    crd_m_lmt_calculation();
     
    //--- Driving Traffic Thread ----------------------------------------------
    fork
       begin : ob_traffic_thread
          if(m_scenario.m_traffic_type inside {OB_TRAFFIC_ONLY, BOTH_OB_IB_TRAFFIC, ALL_TRAFFIC}) begin
             do_ob_tlp_seq(l_msg_id);	   
          end
       end
       begin : ib_traffic_thread
          if(m_scenario.m_traffic_type inside {IB_TRAFFIC_ONLY, BOTH_OB_IB_TRAFFIC, ALL_TRAFFIC}) begin
             do_ib_tlp_seq(l_msg_id);
          end
       end
       begin : hdr2log_traffic_thread
          if(m_scenario.m_traffic_type inside {HDR2LOG_TRAFFIC_ONLY, ALL_TRAFFIC}) begin
             do_hdr2log_stream_seq(l_msg_id);
          end
       end
       begin : lti_ctag_traffic_thread
          if(m_scenario.m_traffic_type inside {LTI_CTAG_TRAFFIC_ONLY, ALL_TRAFFIC} && parameters_cfg_pkg::LTI_SUPPORT) begin
             do_lti_ctag_stream_seq(l_msg_id);
          end
       end
       begin : axi_reg_access_traffic_thread
          if(m_scenario.m_traffic_type inside {AXI_REG_ACCESS_TRAFFIC_ONLY, ALL_TRAFFIC}) begin
             do_axi_reg_access_seq(l_msg_id);
          end
       end
`ifdef DTI_TB_IN_PASSIVE_MODE
      begin : ats_inv_req_thread
        if(parameters_cfg_pkg::KMAX_DTI_SUPPORT && m_scenario.m_num_ats_inv_reqs) begin
          do_ats_inv_req_seq(l_msg_id);
        end
      end
`endif

    join
    
    //--- Adding some buffer when packet count is less. --------------------
    m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(10));

    //  do_cxs_startptr_coverage_scenarios(.msg_id(l_msg_id));
     
  endtask : do_traffic

  //---------------------------------------------------------------------------
  // Task: do_eot
  // Task to do end of test management.
  //---------------------------------------------------------------------------
  virtual task do_eot(string msg_id = "");
    string       l_msg_id = {msg_id, "[do_eot]"};
    bit          random_assert_deacthint;
    int unsigned l_is_quiet_counter;
    
    `uvm_info(l_msg_id, "Starting do_eot task...", UVM_HIGH)

    if(!std::randomize(random_assert_deacthint)) begin
      `uvm_fatal(l_msg_id, "Randomization of random_assert_deacthint failed...")
    end

    //--- Wait for scoreboards and queues to be empty. -----
    fork begin
      fork
        begin
          while(l_is_quiet_counter <= (m_scenario.m_backpressure_scenario ? 400 : 50)) begin
            //--- Wait for scoreboards/monitors to be quiet. -------------------------------
            while(!(p_sequencer.p_env.m_env_mon.is_quiet() && p_sequencer.is_quiet())) begin
              l_is_quiet_counter = 0;
              m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(10));
            end
            //--- Wait for N Quiet Cycles before exiting the do_eot thread. ----------------
            //--- Totyo: increasing the counter, while reducing the delay, to avoid
            //--- a corner case where the quiet checks always happen between packets.
            l_is_quiet_counter++;
            m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(150));
          end
        end
        begin
          m_env_cfg.m_hpa_timer.wait_for_time(
  `ifdef FUNC_COV
    m_scenario.m_backpressure_scenario ? 8000 : 3000,  // doubled for FUNC_COV
  `else
    m_scenario.m_backpressure_scenario ? 6000 : 1500,
  `endif
  "Max Delay time for vseq to timeout.", "us");
     void'(p_sequencer.p_env.m_env_mon.is_balanced());
          `uvm_fatal(l_msg_id, "Either scoreboards or compl_lut_obj are not empty...")
        end
      join_any
      disable fork;
    end join

    //--- Asserting deacthint so that the DUT deassert CXS reach STOP State(PCIE-19531) -----
    if(random_assert_deacthint) begin
      p_sequencer.p_env.set_cxs_vips_deacthint(.value(1));
    end

    //--- Wait for CXS VIPs to reach STOP State. -----
    fork begin
      fork
        begin
          if(random_assert_deacthint) begin
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ob_posted_hal_env));
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ob_nonposted_hal_env));
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ob_compl_hal_env));
          end
          p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ib_posted_hal_env));
          p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ib_nonposted_hal_env));
          p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ib_compl_hal_env));
          foreach(p_sequencer.p_env.m_hls_ob_posted_axi_env[loop_port])
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ob_posted_axi_env[loop_port]));
          foreach(p_sequencer.p_env.m_hls_ob_nonposted_axi_env[loop_port])
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ob_nonposted_axi_env[loop_port]));
          foreach(p_sequencer.p_env.m_hls_ob_compl_axi_env[loop_port])
            p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(p_sequencer.p_env.m_hls_ob_compl_axi_env[loop_port]));
          if(random_assert_deacthint) begin
            foreach(p_sequencer.p_env.m_hls_ib_posted_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ib_posted_axi_env[loop_port]));
            foreach(p_sequencer.p_env.m_hls_ib_nonposted_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ib_nonposted_axi_env[loop_port]));
            foreach(p_sequencer.p_env.m_hls_ib_compl_axi_env[loop_port])
              p_sequencer.p_env.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(p_sequencer.p_env.m_hls_ib_compl_axi_env[loop_port]));
          end
        end
        begin
          m_env_cfg.m_hpa_timer.wait_for_time(100, "Max Delay time for CXS VIP to reach STOP State.", "us");
          `uvm_fatal(l_msg_id, "CXS VIPs have not reached the STOP state...")
        end
      join_any
      disable fork;
    end join

    //--- Deasserting deacthint after all the CXS VIPs reach STOP State -----
    if(random_assert_deacthint) begin
      p_sequencer.p_env.set_cxs_vips_deacthint(.value(0));
    end

    //--- Checking if any pkts were sent in the test at all -----
    if(p_sequencer.p_env.m_env_mon.m_total_num_pkts_sent == 0) begin
      `uvm_fatal(l_msg_id, "No Packets were sent in the test...")
    end

    read_all_registers(); //calling the task to read all register of hls_bridge_reg_model

    `uvm_info(l_msg_id, "Ending do_eot task...", UVM_HIGH)
  endtask : do_eot
  
  //---------------------------------------------------------------------------
  // Task: do_dc_stream_seq
  // Task to start the Delivered Count Sequence.
  //---------------------------------------------------------------------------
  virtual task do_dc_stream_seq(string msg_id = "");
    string l_msg_id = {msg_id, "[do_dc_stream_seq]"};
    
    for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
      automatic int unsigned l_hls_port = loop_port;
      fork
        begin
          cdn_pcie_hls_bridge_dc_stream_seq l_dc_stream_seq;
          
          `uvm_info(l_msg_id, $sformatf("Starting Delivered Count Generation Background Sequence for Port %0d...", l_hls_port), UVM_HIGH)
          
          `uvm_create_on(l_dc_stream_seq, p_sequencer.dc_mst_sqr[l_hls_port])
          l_dc_stream_seq.hls_port_num       = l_hls_port;
          l_dc_stream_seq.m_top_vsqr         = p_sequencer;
          l_dc_stream_seq.databus_size_bytes = (parameters_cfg_pkg::DELIVERED_P_TDATA_WIDTH / 8);

          if (!l_dc_stream_seq.randomize()) begin
            `uvm_fatal(l_msg_id, $sformatf("Delivered Count Stream sequence randomization failed for Port %0d.", l_hls_port))
          end
          `uvm_send(l_dc_stream_seq)
          
          `uvm_info(l_msg_id, $sformatf("Ending Delivered Count Generation Background Sequence for Port %0d...", l_hls_port), UVM_HIGH)
        end
      join_none
    end
  endtask : do_dc_stream_seq

  //---------------------------------------------------------------------------
  // Task: do_qos_stream_seq
  // Task to start the QoS Sequence.
  //---------------------------------------------------------------------------

 
  virtual task do_qos_stream_seq(string msg_id = "");
     string l_msg_id = {msg_id, "[do_qos_stream_seq]"};

     for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
        automatic int unsigned l_hls_port = loop_port;
         fork
           begin
              cdn_pcie_hls_bridge_qos_stream_seq l_qos_stream_seq;
              `uvm_create_on(l_qos_stream_seq, p_sequencer.qos_mst_sqr[l_hls_port])
              l_qos_stream_seq.hls_port_num       = l_hls_port;
              l_qos_stream_seq.m_top_vsqr         = p_sequencer;
              l_qos_stream_seq.databus_size_bytes = 3;
	     if (!l_qos_stream_seq.randomize()) begin
         	 `uvm_fatal(l_msg_id, "QOS seq randomization failed")
             end
	  `uvm_send(l_qos_stream_seq)
           end
        join_none
    end
  endtask 


  //---------------------------------------------------------------------------
  // Task: do_ob_tlp_seq
  // Task to start the OB TLP Traffic Sequence.
  //---------------------------------------------------------------------------
  virtual task do_ob_tlp_seq(string msg_id = "");
    string l_msg_id = {msg_id, "[do_ob_tlp_seq]"};
    cdn_pcie_hls_bridge_tlp_seq l_hls_ob_tlp_seq;
    bit low_power_done;
    
    `uvm_info(l_msg_id, "Starting OB TLP Traffic...", UVM_HIGH)
    
    for (int loop_burst = 0; loop_burst < m_scenario.m_number_of_tlp_bursts; loop_burst++) begin

      `uvm_create_on(l_hls_ob_tlp_seq, p_sequencer.hls_ob_tlp_sqr)
       
      l_hls_ob_tlp_seq.m_top_vsqr            = p_sequencer;
      l_hls_ob_tlp_seq.m_tlp_seq_pack_prefix = 1;
      l_hls_ob_tlp_seq.m_tlp_seq_pack_ecrc   = p_sequencer.i_cfg.k_ecrc_capability_support; //TODO Check with Anil ECRC Pack issue.
      l_hls_ob_tlp_seq.large_length_tlps = 0;
      l_hls_ob_tlp_seq.mid_length_tlps = 0;
      l_hls_ob_tlp_seq.min_length_tlps = 0;
      l_hls_ob_tlp_seq.mix_length_tlps = 0;
      
      randcase
        1  : l_hls_ob_tlp_seq.large_length_tlps = 1;
        3  : l_hls_ob_tlp_seq.mid_length_tlps = 1;
        5  : l_hls_ob_tlp_seq.min_length_tlps = 1;
        10 : l_hls_ob_tlp_seq.mix_length_tlps = 1;
      endcase

      if (!l_hls_ob_tlp_seq.randomize()) begin
        `uvm_fatal(l_msg_id, "OB TLP sequence randomization failed.")
      end

      `uvm_send(l_hls_ob_tlp_seq)

      //-- Random delay between 2 consecutive bursts. --------------------
      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles($urandom_range(20, 0)));

      if (m_scenario.m_low_power_mode && low_power_done == 0) begin
        low_power_mode_starting_ob_e.trigger();
        low_power_mode_done_e.wait_trigger();
        low_power_done = 1;
      end

    end

    `uvm_info(l_msg_id, "Ending OB TLP Traffic...", UVM_HIGH)
  endtask : do_ob_tlp_seq

  //---------------------------------------------------------------------------
  // Task: do_ib_tlp_seq
  // Task to start the IB TLP Traffic Sequence.
  //---------------------------------------------------------------------------
  virtual task do_ib_tlp_seq(string msg_id = "");
    string l_msg_id = {msg_id, "[do_ib_tlp_seq]"};
    cdn_pcie_hls_bridge_tlp_seq l_hls_ib_tlp_seq;
    bit low_power_done;
    int prev_m_prGroupIndex[$];

    `uvm_info(l_msg_id, "Starting IB TLP Traffic...", UVM_HIGH)
    
    for (int loop_burst = 0; loop_burst < m_scenario.m_number_of_tlp_bursts; loop_burst++) begin
      `uvm_create_on(l_hls_ib_tlp_seq, p_sequencer.hls_ib_tlp_sqr)
      
      l_hls_ib_tlp_seq.m_top_vsqr            = p_sequencer;
      l_hls_ib_tlp_seq.is_ib_seq             = 1;
      l_hls_ib_tlp_seq.m_tlp_seq_pack_prefix = 1;
      l_hls_ib_tlp_seq.m_tlp_seq_pack_ecrc   = p_sequencer.i_cfg.k_ecrc_capability_support;
      l_hls_ib_tlp_seq.prev_m_prGroupIndex   = prev_m_prGroupIndex;
      l_hls_ib_tlp_seq.large_length_tlps = 0;
      l_hls_ib_tlp_seq.mid_length_tlps = 0;
      l_hls_ib_tlp_seq.min_length_tlps = 0;
      l_hls_ib_tlp_seq.mix_length_tlps = 0;
      
      randcase
        1  : l_hls_ib_tlp_seq.large_length_tlps = 1;
        3  : l_hls_ib_tlp_seq.mid_length_tlps = 1;
        5  : l_hls_ib_tlp_seq.min_length_tlps = 1;
        10 : l_hls_ib_tlp_seq.mix_length_tlps = 1;
      endcase

      if (!l_hls_ib_tlp_seq.randomize()) begin
        `uvm_fatal(l_msg_id, "IB TLP sequence randomization failed.")
      end

      `uvm_send(l_hls_ib_tlp_seq)

      prev_m_prGroupIndex = l_hls_ib_tlp_seq.prev_m_prGroupIndex;
    
      //-- Random delay between 2 consecutive bursts. --------------------
      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles($urandom_range(20, 0)));

      if (m_scenario.m_low_power_mode && low_power_done == 0) begin
        low_power_mode_starting_ib_e.trigger();
        low_power_mode_done_e.wait_trigger();
        low_power_done = 1;
      end
    end
    
    `uvm_info(l_msg_id, "Ending IB TLP Traffic...", UVM_HIGH)
  endtask : do_ib_tlp_seq

  //---------------------------------------------------------------------------
  // Task: do_hdr2log_stream_seq
  // Task to start the HDR2LOG Stream Traffic Sequence.
  //---------------------------------------------------------------------------
  virtual task do_hdr2log_stream_seq(string msg_id = "");
    string l_msg_id = {msg_id, "[do_hdr2log_stream_seq]"};
    
    for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
      automatic int unsigned l_hls_port = loop_port;
      fork
        begin
          cdn_pcie_hls_bridge_hdr2log_stream_seq l_hdr2log_stream_seq;
	  int unsigned l_port_bytes;
          int unsigned l_axi_size_128;
          int unsigned l_wide_bus;
          int unsigned l_rx2tx_ratio;
          int unsigned l_max_beats;
          int unsigned l_max_bytes;

          `uvm_info(l_msg_id, $sformatf("Starting HDR2LOG Stream Traffic for Port %0d...", l_hls_port), UVM_HIGH)
          `uvm_create_on(l_hdr2log_stream_seq, p_sequencer.hdr2log_mst_sqr[l_hls_port])
          l_hdr2log_stream_seq.databus_size_bytes = (parameters_cfg_pkg::HLS_PORT_DATA_WIDTH_ARR[l_hls_port*32 +: 32] / 8);
	  l_port_bytes   = (parameters_cfg_pkg::HLS_PORT_DATA_WIDTH_ARR[l_hls_port*32 +: 32]) / 8;
          l_axi_size_128 = (parameters_cfg_pkg::HLS_PORT_DATA_WIDTH_ARR[l_hls_port*32 +: 32] == 128);
          l_wide_bus     = (parameters_cfg_pkg::KMAX_DATAPATH_WD > 512);
          l_rx2tx_ratio  = (l_axi_size_128 && l_wide_bus);
          l_max_beats    = l_rx2tx_ratio ? 3 : 2;
          l_max_bytes    = ((l_port_bytes * l_max_beats) < (11 * 4)) ? (l_port_bytes * l_max_beats) : (11 * 4); 
          
          for (int loop_tlp = 0; loop_tlp < m_scenario.m_number_of_tlps; loop_tlp++) begin
            m_env_cfg.m_misc_if_api.wait_unpause_traffic();
              l_hdr2log_stream_seq.number_of_bytes_to_transfer = $urandom_range(l_max_bytes, (3 * 4)); // Max header size is 14 DW, Minimum header size is 3 DW.
            
            if (!l_hdr2log_stream_seq.randomize()) begin
              `uvm_fatal(l_msg_id, $sformatf("HDR2LOG Stream sequence randomization failed for Port %0d. TLP Number %0d", l_hls_port, loop_tlp))
            end

            `uvm_send(l_hdr2log_stream_seq)

            wait_random_clk_cycles(.max_clk_cycles(20));
          end
          
          `uvm_info(l_msg_id, $sformatf("Ending HDR2LOG Stream Traffic for Port %0d...", l_hls_port), UVM_HIGH)
        end
      join_none
    end
    wait fork;

  endtask : do_hdr2log_stream_seq

  //---------------------------------------------------------------------------
  // Task: do_lti_ctag_stream_seq
  // Task to start the LTI Completion Tag Traffic Sequence.
  //---------------------------------------------------------------------------
  virtual task do_lti_ctag_stream_seq(string msg_id = "");
    string l_msg_id = {msg_id, "[do_lti_ctag_stream_seq]"};
    
    for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
      automatic int unsigned l_hls_port = loop_port;
      fork
        begin
          cdn_pcie_hls_bridge_lti_ctag_stream_seq l_lti_ctag_stream_seq;
          int unsigned                            l_wait_clk_cycles;
          
          `uvm_info(l_msg_id, $sformatf("Starting LTI CTag Stream Traffic for Port %0d...", l_hls_port), UVM_HIGH)
         
          //--- Initializes LTI Counter Pool for each port -------------------------------
          init_lti_counter_pool(.hls_port_num(l_hls_port));

          `uvm_create_on(l_lti_ctag_stream_seq, p_sequencer.lti_c_tx_sqr[l_hls_port])
          l_lti_ctag_stream_seq.databus_size_bytes          = (parameters_cfg_pkg::LTI_C_TDATA_WIDTH / 8);
          l_lti_ctag_stream_seq.number_of_bytes_to_transfer = (parameters_cfg_pkg::LTI_C_TDATA_WIDTH / 8);
          
          for (int loop_tlp = 0; loop_tlp < m_scenario.m_number_of_tlps; loop_tlp++) begin
            m_env_cfg.m_misc_if_api.wait_unpause_traffic();

            //--- Pick target LTI Counter from the shuffle counter queue.
            //--- As PCIE-20198 after a LTI Completion for a particular {PORT-ID, CTAG} then it can come only come after min (NUM_LTI_PORTS * 2) delay.
            l_lti_ctag_stream_seq.target_lti_counter = generate_target_lti_counter_val(.hls_port_num(l_hls_port));

            if (!l_lti_ctag_stream_seq.randomize()) begin
              `uvm_fatal(l_msg_id, $sformatf("LTI CTag Stream sequence randomization failed for Port %0d. TLP Number %0d", l_hls_port, loop_tlp))
            end
            `uvm_send(l_lti_ctag_stream_seq)

            //-- Wait for random clk cycles before driving another transaction. 
            if($urandom_range(1, 0)) begin
              l_wait_clk_cycles = $urandom_range(20, 1);
              repeat(l_wait_clk_cycles) begin
                m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
                void'(generate_target_lti_counter_val(.hls_port_num(l_hls_port)));
              end
            end
          end
          
          `uvm_info(l_msg_id, $sformatf("Ending LTI CTag Stream Traffic for Port %0d...", l_hls_port), UVM_HIGH)
        end
      join_none
    end
    wait fork;

  endtask : do_lti_ctag_stream_seq

  //---------------------------------------------------------------------------
  // Task: do_axi_reg_access_seq
  // Task to start the axi reg traffic seq for access AXI Bridge Registers
  //---------------------------------------------------------------------------
  virtual task do_axi_reg_access_seq(string msg_id = "");
    string l_msg_id = {msg_id, "[do_axi_reg_access_seq]"};

    cdn_pcie_hls_bridge_axi_reg_access_seq l_hls_axi_reg_access_seq;

    `uvm_info(l_msg_id, "Starting AXI Register Traffic...", UVM_LOW)
    
    `uvm_create_on(l_hls_axi_reg_access_seq, p_sequencer.axi_lite_mst_sqr)

    for (int loop_tlp = 0; loop_tlp < m_scenario.m_number_of_tlps; loop_tlp++) begin
      m_env_cfg.m_misc_if_api.wait_unpause_traffic();
      
      if (!l_hls_axi_reg_access_seq.randomize()) begin
        `uvm_fatal(l_msg_id, "AXI REG sequence randomization failed.")
      end
      `uvm_send(l_hls_axi_reg_access_seq)

      // Totyo: The first item should be a valid one to get at
      // least one packet pass, and keep the monitor happy.
      l_hls_axi_reg_access_seq.ignore_address_ranges = m_scenario.m_unmapped_reg_access;

      wait_random_clk_cycles(.max_clk_cycles(20));      
    end
    
    `uvm_info(l_msg_id, "Ending AXI Register Traffic...", UVM_LOW)
  endtask : do_axi_reg_access_seq

`ifdef DTI_TB_IN_PASSIVE_MODE
  //---------------------------------------------------------------------------
  // Task: do_ats_inv_req_seq
  // Task to send invalidation TLPs from the TCU agent inside the DTI ATS env
  //---------------------------------------------------------------------------
  virtual task do_ats_inv_req_seq(string msg_id = "");
    string l_msg_id = {msg_id, "[do_ats_inv_req_seq]"};
    cdn_pcie_hls_bridge_invalidation_seq invalidation_seq;

    `uvm_info(l_msg_id, "Starting ATS Invalidation Traffic...", UVM_LOW)

    invalidation_seq = cdn_pcie_hls_bridge_invalidation_seq::type_id::create("invalidation_seq");
    invalidation_seq.start(p_sequencer);

    `uvm_info(l_msg_id, "Ending ATS Invalidation Traffic...", UVM_LOW)
  endtask : do_ats_inv_req_seq
`endif

  //---------------------------------------------------------------------------
  // Task: init_lti_counter_pool
  // Helper task which initializes the lti counter pool and shuffles the
  // queue.
  //---------------------------------------------------------------------------
  function void init_lti_counter_pool(int unsigned hls_port_num);
    for(int i = 0; i < (parameters_cfg_pkg::NUM_LTI_PORTS * 2); i++) begin
      lti_counter_pool[hls_port_num].push_back(i);
    end
    lti_counter_pool[hls_port_num].shuffle();
  endfunction : init_lti_counter_pool
  
  //---------------------------------------------------------------------------
  // Task: generate_target_lti_counter_val
  // Helper task which gets a counter value from the pool if available else
  // reinitializes the pool.
  //---------------------------------------------------------------------------
  function bit [$clog2(parameters_cfg_pkg::NUM_LTI_PORTS * 2) - 1 : 0] generate_target_lti_counter_val(int unsigned hls_port_num);
    if (lti_counter_pool[hls_port_num].size() == 0)
      init_lti_counter_pool(.hls_port_num(hls_port_num));

    return lti_counter_pool[hls_port_num].pop_front();
  endfunction : generate_target_lti_counter_val

  //---------------------------------------------------------------------------
  // Task : read_all_registers
  // Task used to read all registers of a reg_model in one go
  //---------------------------------------------------------------------------
  task read_all_registers();
    uvm_reg       l_reg[$];  
    bit [31:0]    l_value ;
    string        name    ;

    p_sequencer.p_env.hls_bridge_regmodel.get_registers(l_reg);
    
    foreach(l_reg[i])begin
      name=l_reg[i].get_name();
      reg_read(.register_name(name),.value(l_value));
      `uvm_info("REG_READ",$sformatf("Register= %s, Data read= %h",l_reg[i].get_name(),l_value),UVM_LOW)  
    end
    
  endtask : read_all_registers

endclass
