`ifndef CDN_PCIE_HLS_BRIDGE_HLS_IB_POSTED_ORDER_CHECKER_SV
`define CDN_PCIE_HLS_BRIDGE_HLS_IB_POSTED_ORDER_CHECKER_SV

//-----------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_hls_ib_posted_order_checker
// Checks inbound posted-posted ordering across AXI/DTI/MSI sinks, and reports
// strict- vs relaxed-order packet timeouts when packets are lost or delayed.
//-----------------------------------------------------------------------------
class cdn_pcie_hls_bridge_hls_ib_posted_order_checker extends uvm_component implements I_cdn_pcie_hls_bridge_reset;
  //---------------------------------------------------------------------------
  // Member Variables
  //---------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  // Variable: checks_enable
  // This member variable enables the protocol checks.
  //----------------------------------------------------------------------------
  bit checks_enable = 1;
  
  //----------------------------------------------------------------------------
  // Variable: coverage_enable
  // This member variable enables the protocol coverage.
  //----------------------------------------------------------------------------
  bit coverage_enable = 1;

  //---------------------------------------------------------------------------
  // Field: component_msg_id
  // Msg ID for all messages
  //---------------------------------------------------------------------------
  string component_msg_id = "HLS_BRIDGE_IB_POSTED_ORDER_CHECKER";
  
  //----------------------------------------------------------------------------
  // Variable: hls_bridge_regmodel
  // HLS Bridge Register Model Handle
  //----------------------------------------------------------------------------
  hls_bridge_reg_model hls_bridge_regmodel;

  //----------------------------------------------------------------------------
  // Config objects
  //--- HLS Bridge Environment Config Object -----------------------------------
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_env_config m_env_cfg;
  
  //---------------------------------------------------------------------------
  // Local Variables
  //---------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  // Variable: ib_p_exp_q
  // Queue to store all the inbound posted packets received from Core in
  // order.
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_ib_port_tr_delivered_s ib_p_exp_q[$];

  //----------------------------------------------------------------------------
  // Variable: ib_p_exp_timeout_q
  // Lockstep metadata for ib_p_exp_q: enqueue time, relaxed vs strict, and
  // whether a timeout has already been reported for that entry.
  //----------------------------------------------------------------------------
  typedef struct {
    time start_time;
    bit  is_relaxed;
    bit  timeout_reported;
  } ib_p_exp_timeout_s;
  ib_p_exp_timeout_s ib_p_exp_timeout_q[$];

  //----------------------------------------------------------------------------
  // Variable: m_exp_is_relaxed_mb
  // Carries the relaxed-order flag for each expected packet written through
  // m_in_exp_p_pkt_ended_af so timeout detection can use the correct budget.
  //----------------------------------------------------------------------------
  mailbox #(bit) m_exp_is_relaxed_mb;

  //----------------------------------------------------------------------------
  // Variable: ib_p_q_changed
  // Event triggered whenever ib_p_exp_q is updated (push/delete/reset).
  //----------------------------------------------------------------------------
  event ib_p_q_changed;

  //----------------------------------------------------------------------------
  // Variable: strict_order_pkt_timeout_us
  // Timeout (us) for a strict-ordered inbound posted packet to be predicted
  // or delivered. Override with +IB_POSTED_STRICT_ORDER_TIMEOUT_US=<us>.
  //----------------------------------------------------------------------------
  int unsigned strict_order_pkt_timeout_us = 10;

  //----------------------------------------------------------------------------
  // Variable: relaxed_order_pkt_timeout_us
  // Timeout (us) for a relaxed-ordered inbound posted packet to be predicted
  // or delivered. Override with +IB_POSTED_RELAXED_ORDER_TIMEOUT_US=<us>.
  //----------------------------------------------------------------------------
  int unsigned relaxed_order_pkt_timeout_us = 10;

  //---------------------------------------------------------------------------
  // Coverage Instances.
  //---------------------------------------------------------------------------
  cg_disable_p_p_order_check cg_disable_p_p_order_check_h; 
  
  //---------------------------------------------------------------------------
  // TLM Analysis FIFOs
  //---------------------------------------------------------------------------
  uvm_tlm_analysis_fifo #(cdn_pcie_hls_bridge_ib_port_tr_delivered_s) m_in_exp_p_pkt_ended_af;
  
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)                       m_in_act_p_axi_cxs_pkt_ended_af [parameters_cfg_pkg::NUM_HLS_PORTS];
  uvm_tlm_analysis_fifo #(denaliCxsTransaction)                       m_in_act_p_dti_cxs_pkt_ended_af;
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)                    m_in_act_p_msi_pkt_ended_af;
  
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)                    m_in_dti_delivered_count_pkt_ended_af;
  uvm_tlm_analysis_fifo #(denaliStreamTransaction)                    m_in_axi_delivered_count_pkt_ended_af [parameters_cfg_pkg::NUM_HLS_PORTS];

  `uvm_component_utils(cdn_pcie_hls_bridge_hls_ib_posted_order_checker)
  
  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name and parent handle.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_hls_ib_posted_order_checker", uvm_component parent = null);
    super.new(name, parent);
    m_exp_is_relaxed_mb = new(0);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: build_phase
  //---------------------------------------------------------------------------
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
    
    //-- Create analysis fifo ------------------
    m_in_exp_p_pkt_ended_af = new("m_in_exp_p_pkt_ended_af", this);
    foreach(m_in_act_p_axi_cxs_pkt_ended_af[loop_port])
      m_in_act_p_axi_cxs_pkt_ended_af[loop_port] = new($sformatf("m_in_act_p_axi_cxs_pkt_ended_af[%0d]", loop_port), this);
    m_in_act_p_dti_cxs_pkt_ended_af = new("m_in_act_p_dti_cxs_pkt_ended_af", this);
    m_in_act_p_msi_pkt_ended_af = new("m_in_act_p_msi_pkt_ended_af", this);
    foreach(m_in_axi_delivered_count_pkt_ended_af[loop_port])
      m_in_axi_delivered_count_pkt_ended_af[loop_port] = new($sformatf("m_in_axi_delivered_count_pkt_ended_af[%0d]", loop_port), this);
    m_in_dti_delivered_count_pkt_ended_af = new("m_in_dti_delivered_count_pkt_ended_af", this);

    begin
      uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
      string arg_str;
      if (clp.get_arg_value("+IB_POSTED_STRICT_ORDER_TIMEOUT_US=", arg_str))
        strict_order_pkt_timeout_us = arg_str.atoi();
      if (clp.get_arg_value("+IB_POSTED_RELAXED_ORDER_TIMEOUT_US=", arg_str))
        relaxed_order_pkt_timeout_us = arg_str.atoi();
    end
    void'(uvm_config_db#(int unsigned)::get(this, "", "strict_order_pkt_timeout_us", strict_order_pkt_timeout_us));
    void'(uvm_config_db#(int unsigned)::get(this, "", "relaxed_order_pkt_timeout_us", relaxed_order_pkt_timeout_us));
    
    //-- Coverage creation --------------------
    cg_disable_p_p_order_check_h = new(.cg_name("cg_disable_p_p_order_check_h"));
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Task: main_phase
  //----------------------------------------------------------------------------
  virtual task main_phase(uvm_phase phase);
    string l_msg_id = {"[", component_msg_id, "]", "[main_phase]"};
    super.main_phase(phase);
    
    `uvm_info(l_msg_id, "Starting HLS Bridge IB Posted Order Checker Main Phase...", UVM_LOW);
    `uvm_info(l_msg_id, $sformatf("Posted packet timeout budgets: strict=%0d us, relaxed=%0d us", strict_order_pkt_timeout_us, relaxed_order_pkt_timeout_us), UVM_LOW);
    
    fork
      for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
        automatic int unsigned l_port = loop_port;
        fork
          process_act_p_axi_pkt_ended(.msg_id(l_msg_id), .port_num(l_port));
          process_axi_delivered_count_pkt_ended(.msg_id(l_msg_id), .port_num(l_port));
        join_none
      end
      process_exp_p_pkt_ended(.msg_id(l_msg_id));
      process_act_p_dti_pkt_ended(.msg_id(l_msg_id));
      process_act_p_msi_pkt_ended(.msg_id(l_msg_id));
      process_dti_delivered_count_pkt_ended(.msg_id(l_msg_id));
      process_undelivered_pkt_timeout(.msg_id(l_msg_id));
    join

    `uvm_info(l_msg_id, "Ending HLS Bridge IB Posted Order Checker Main Phase...", UVM_LOW);
  endtask : main_phase

  //----------------------------------------------------------------------------
  // Function: check_phase
  //----------------------------------------------------------------------------
  virtual function void check_phase(uvm_phase phase);
    string l_msg_id = {"[", component_msg_id, "]", "[check_phase]"};
    super.check_phase(phase);

    // -- Check whether queues are empty at the end of the test -----------
    if(!is_balanced() && checks_enable == 1)
      `uvm_error({component_msg_id, "_ERROR"}, "Component queues are not empty at the end of the test.")
  endfunction : check_phase
 
  //----------------------------------------------------------------------------
  // Function: perform_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_RESET", $sformatf("Started resetting cdn_pcie_hls_bridge_hls_ib_posted_order_checker(%0s) component.....", get_full_name()), UVM_DEBUG)
    
    //---- local Variables Clear -----------------
    ib_p_exp_q = {};
    ib_p_exp_timeout_q = {};
    //---- Analysis FIFO Flush ------------------
    m_in_exp_p_pkt_ended_af.flush();
    foreach(m_in_act_p_axi_cxs_pkt_ended_af[loop_port])
      m_in_act_p_axi_cxs_pkt_ended_af[loop_port].flush();
    m_in_act_p_dti_cxs_pkt_ended_af.flush();
    m_in_act_p_msi_pkt_ended_af.flush();
    foreach(m_in_axi_delivered_count_pkt_ended_af[loop_port])
      m_in_axi_delivered_count_pkt_ended_af[loop_port].flush();
    m_in_dti_delivered_count_pkt_ended_af.flush();
    begin
      bit dummy_relaxed;
      while (m_exp_is_relaxed_mb.try_get(dummy_relaxed));
    end
    ->> ib_p_q_changed;

    `uvm_info("PERFORM_RESET", $sformatf("Completed resetting cdn_pcie_hls_bridge_hls_ib_posted_order_checker(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_reset

  //----------------------------------------------------------------------------
  // Function: perform_axil_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_axil_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Started axil resetting cdn_pcie_hls_bridge_hls_ib_posted_order_checker(%0s) component.....", get_full_name()), UVM_DEBUG)
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Completed axil resetting cdn_pcie_hls_bridge_hls_ib_posted_order_checker(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_axil_reset

  //----------------------------------------------------------------------------
  // Task: process_exp_p_pkt_ended
  //----------------------------------------------------------------------------
  task process_exp_p_pkt_ended(string msg_id = "");
    string                                     l_msg_id = {msg_id, "[process_exp_p_pkt_ended]"} ;
    cdn_pcie_hls_bridge_ib_port_tr_delivered_s port_tr                                          ;
    bit                                        is_relaxed                                       ;
    ib_p_exp_timeout_s                         timeout_info                                     ;
    
    forever begin
      // -- Get pkt ---------------------------------------
      m_in_exp_p_pkt_ended_af.get(port_tr);
      m_exp_is_relaxed_mb.get(is_relaxed);

      if (port_tr.dest_port == ROUTE_TO_AXI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value())
        continue;

      if (port_tr.dest_port == ROUTE_TO_DTI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value())
        continue;

      if (port_tr.dest_port == ROUTE_TO_MSI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_msi.get_mirrored_value())
        continue;

      // -- Push it in the queue --------------------------
      timeout_info.start_time        = $time;
      timeout_info.is_relaxed        = is_relaxed;
      timeout_info.timeout_reported  = 0;
      ib_p_exp_q.push_back(port_tr);
      ib_p_exp_timeout_q.push_back(timeout_info);
      ->> ib_p_q_changed;

      print_table(.msg_id(l_msg_id), .msg(""), .arg_table(ib_p_exp_q));
    end
  endtask : process_exp_p_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_act_p_dti_pkt_ended
  //----------------------------------------------------------------------------
  task process_act_p_axi_pkt_ended(string msg_id = "", int unsigned port_num);
    string               l_msg_id = {msg_id, $sformatf("[process_act_p_axi_pkt_ended[%0d]]", port_num)} ;
    denaliCxsTransaction cxs_pkt;
    cdn_pcie_hls_ib_p_np_metadata_s l_hls_ib_p_np_meta_s;
    bit disable_ordering;
    cdn_pcie_hls_bridge_route_en_s l_route_en;

    forever begin
      // -- Get pkt ------------------------------------------------------
      m_in_act_p_axi_cxs_pkt_ended_af[port_num].get(cxs_pkt);

      l_hls_ib_p_np_meta_s = {<<byte{cxs_pkt.UserControl}};
      
      m_env_cfg.m_misc_if_api.get_misc_hls_bridge_route_en(l_route_en);

      // Wait for the expected packet to be queued. Relaxed-order uses its own
      // timeout budget so RO/TC/VC traffic does not share the strict-order wait.
      disable_ordering = l_hls_ib_p_np_meta_s.ro || l_route_en.ro_en || l_route_en.vc_en || l_route_en.tc_en;

      `uvm_info(get_type_name(), $sformatf("AXI ordering_disabled %0h", disable_ordering), UVM_LOW)
      `uvm_info(get_type_name(), $sformatf("HLS bridge route en: l_hls_ib_p_np_meta_s.ro %p", l_hls_ib_p_np_meta_s.ro), UVM_LOW)
      `uvm_info(get_type_name(), $sformatf("HLS bridge route en: l_route_en %p", l_route_en), UVM_LOW)

      wait_for_exp_pkt(.msg_id(l_msg_id), .route_to(ROUTE_TO_AXI), .hls_port_num(port_num), .data_bytes(cxs_pkt.DataPerPktRx), .id_group(l_hls_ib_p_np_meta_s.idgroup), .is_relaxed(disable_ordering));

      // -- Check the ordering as soon as actual packet is received ------
      check_p_p_ordering(.msg_id(l_msg_id), .route_to(ROUTE_TO_AXI), .hls_port_num(port_num), .data_bytes(cxs_pkt.DataPerPktRx), .disable_checking(disable_ordering), .id_group(l_hls_ib_p_np_meta_s.idgroup));
    end

  endtask : process_act_p_axi_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_act_p_dti_pkt_ended
  //----------------------------------------------------------------------------
  task process_act_p_dti_pkt_ended(string msg_id = "");
    string               l_msg_id = {msg_id, "[process_act_p_dti_pkt_ended]"} ;
    denaliCxsTransaction cxs_pkt;
    cdn_pcie_hls_ib_p_np_metadata_s l_hls_ib_p_np_meta_s;

    forever begin
      // -- Get pkt ------------------------------------------------------
      m_in_act_p_dti_cxs_pkt_ended_af.get(cxs_pkt);

      l_hls_ib_p_np_meta_s = {<<byte{cxs_pkt.UserControl}};

      wait_for_exp_pkt(.msg_id(l_msg_id), .route_to(ROUTE_TO_DTI), .hls_port_num(0), .data_bytes(cxs_pkt.DataPerPktRx), .id_group(l_hls_ib_p_np_meta_s.idgroup), .is_relaxed(1'b0));

      // -- Check the ordering as soon as actual packet is received ------
      check_p_p_ordering(.msg_id(l_msg_id), .route_to(ROUTE_TO_DTI), .hls_port_num(0), .data_bytes(cxs_pkt.DataPerPktRx), .disable_checking(1'b0), .id_group(l_hls_ib_p_np_meta_s.idgroup));
    end

  endtask : process_act_p_dti_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_act_p_msi_pkt_ended
  //----------------------------------------------------------------------------
  task process_act_p_msi_pkt_ended(string msg_id = "");
    string                  l_msg_id = {msg_id, "[process_act_p_msi_pkt_ended]"} ;
    denaliStreamTransaction msi_pkt;
    int id_group;

    forever begin
      // -- Get pkt ---------------------------------------
      m_in_act_p_msi_pkt_ended_af.get(msi_pkt);

      wait_for_exp_pkt(.msg_id(l_msg_id), .route_to(ROUTE_TO_MSI), .hls_port_num(0), .data_bytes(msi_pkt.PacketData), .id_group(3'h0), .is_relaxed(1'b0), .match_any_id_group(1'b1));

      // -- Check the ordering as soon as actual packet is received ------
      foreach(ib_p_exp_q[i]) begin
        if(ib_p_exp_q[i].dest_port == ROUTE_TO_MSI && compare_pkt_data_bytes(.lhs(ib_p_exp_q[i].data_bytes), .rhs(msi_pkt.PacketData))) begin
          id_group = ib_p_exp_q[i].id_group;
          break;
        end
      end
      check_p_p_ordering(.msg_id(l_msg_id), .route_to(ROUTE_TO_MSI), .hls_port_num(0), .data_bytes(msi_pkt.PacketData), .disable_checking(1'b0), .id_group(id_group));

      //--- Removing the MSI Pkt Delivered from queue. --------------
      foreach(ib_p_exp_q[i]) begin
        if(ib_p_exp_q[i].dest_port == ROUTE_TO_MSI && compare_pkt_data_bytes(.lhs(ib_p_exp_q[i].data_bytes), .rhs(msi_pkt.PacketData))) begin
          id_group = ib_p_exp_q[i].id_group;
          delete_exp_entry(i);
          break;
        end
      end

      print_table(.msg_id(l_msg_id), .msg(""), .arg_table(ib_p_exp_q));
    end
  endtask : process_act_p_msi_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_axi_delivered_count_pkt_ended
  //----------------------------------------------------------------------------
  task process_axi_delivered_count_pkt_ended(string msg_id = "", int unsigned port_num);
    string                  l_msg_id = {msg_id, $sformatf("[process_axi_delivered_count_pkt_ended[%0d]]", port_num)} ;
    denaliStreamTransaction dc_stream_pkt                                                                            ;
    bit [8:0]               dc_val                                                                                   ;
    bit [2:0]               id_group;

    forever begin
      // -- Get pkt ---------------------------------------
      m_in_axi_delivered_count_pkt_ended_af[port_num].get(dc_stream_pkt);

      //--- Crave out the count value ---------------------
      dc_val = {dc_stream_pkt.PacketData[1][0], dc_stream_pkt.PacketData[0][7:0]};

      id_group = dc_stream_pkt.PacketData[1][3:1];

      if (!hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value())
        handle_delivered_count(.dc_val(dc_val), .intf_name(ROUTE_TO_AXI), .port_num(port_num), .id_group(id_group));

      print_table(.msg_id(l_msg_id), .msg(""), .arg_table(ib_p_exp_q));
    end
  endtask : process_axi_delivered_count_pkt_ended

  //----------------------------------------------------------------------------
  // Task: process_dti_delivered_count_pkt_ended
  //----------------------------------------------------------------------------
  task process_dti_delivered_count_pkt_ended(string msg_id = "");
    string                  l_msg_id = {msg_id, "[process_dti_delivered_count_pkt_ended]"} ;
    denaliStreamTransaction dc_stream_pkt                                                  ;
    bit [8:0]               dc_val                                                         ;
    bit [2:0]               id_group;

    forever begin
      // -- Get pkt ---------------------------------------
      m_in_dti_delivered_count_pkt_ended_af.get(dc_stream_pkt);

      //--- Crave out the count value ---------------------
      dc_val = {dc_stream_pkt.PacketData[1][0], dc_stream_pkt.PacketData[0][7:0]};

      id_group = dc_stream_pkt.PacketData[1][3:1];

      if (!hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value())
        handle_delivered_count(.dc_val(dc_val), .intf_name(ROUTE_TO_DTI), .port_num(0), .id_group(id_group));

      print_table(.msg_id(l_msg_id), .msg(""), .arg_table(ib_p_exp_q));
    end
  endtask : process_dti_delivered_count_pkt_ended

  //----------------------------------------------------------------------------
  // Task: handle_delivered_count
  //----------------------------------------------------------------------------
  task handle_delivered_count(string msg_id = "", bit[8:0] dc_val, cdn_pcie_hls_bridge_inbound_route_to_e intf_name, int unsigned port_num, bit[2:0] id_group);
    bit [8:0]    exp_delivered_count ;
    int unsigned i = 0               ;

    while(i < ib_p_exp_q.size()) begin
      if(exp_delivered_count == dc_val)
        break;

      if(ib_p_exp_q[i].dest_port == intf_name && ib_p_exp_q[i].hls_port_num == port_num && ib_p_exp_q[i].id_group == id_group) begin
        delete_exp_entry(i);
        exp_delivered_count++;
        i = 0;
      end
      else begin
        i++;
        continue;
      end
    end

    // foreach(ib_p_exp_q[i,j]) begin
    //   if(exp_delivered_count == dc_val)
    //     break;

    //   if(ib_p_exp_q[i][j].dest_port == intf_name && ib_p_exp_q[i][j].hls_port_num == port_num) begin
    //     ib_p_exp_q[i].delete(j);
    //     exp_delivered_count++;
    //     // i = 0;
    //   end
    // end

    if (checks_enable == 1 && exp_delivered_count != dc_val) begin
      `uvm_error({component_msg_id, "_ERROR"}, $sformatf("Got Delivered Count: %0d from intf: %0s, port_num: %0d, id_group %0d but only %0d matching packets found", dc_val, intf_name.name(), port_num, id_group, exp_delivered_count))
    end

  endtask : handle_delivered_count

  //----------------------------------------------------------------------------
  // Function: push_exp_is_relaxed
  // Called by the monitor in lockstep with hls_ib_posted_port_tr_ap.write()
  // so timeout detection knows whether the expected packet is relaxed-order.
  //----------------------------------------------------------------------------
  virtual function void push_exp_is_relaxed(bit is_relaxed);
    if (!m_exp_is_relaxed_mb.try_put(is_relaxed))
      `uvm_error({component_msg_id, "_ERROR"}, "Failed to queue relaxed-order timeout metadata for an expected inbound posted packet.")
  endfunction : push_exp_is_relaxed

  //----------------------------------------------------------------------------
  // Function: delete_exp_entry
  // Deletes index i from the expected packet queue and its timeout metadata.
  //----------------------------------------------------------------------------
  virtual function void delete_exp_entry(int unsigned idx);
    if (idx < ib_p_exp_q.size())
      ib_p_exp_q.delete(idx);
    if (idx < ib_p_exp_timeout_q.size())
      ib_p_exp_timeout_q.delete(idx);
    ->> ib_p_q_changed;
  endfunction : delete_exp_entry

  //----------------------------------------------------------------------------
  // Function: is_exp_pkt_present
  // Returns 1 when a matching expected posted packet is in ib_p_exp_q.
  //----------------------------------------------------------------------------
  virtual function bit is_exp_pkt_present(cdn_pcie_hls_bridge_inbound_route_to_e route_to, int unsigned hls_port_num, bit [7:0] data_bytes[], bit[2:0] id_group, bit match_any_id_group = 0);
    foreach(ib_p_exp_q[i]) begin
      if (ib_p_exp_q[i].dest_port == route_to &&
          ib_p_exp_q[i].hls_port_num == hls_port_num &&
          (match_any_id_group || ib_p_exp_q[i].id_group == id_group) &&
          compare_pkt_data_bytes(.lhs(ib_p_exp_q[i].data_bytes), .rhs(data_bytes)))
        return 1;
    end
    return 0;
  endfunction : is_exp_pkt_present

  //----------------------------------------------------------------------------
  // Function: get_pkt_timeout_us
  // Selects the strict or relaxed timeout budget.
  //----------------------------------------------------------------------------
  virtual function int unsigned get_pkt_timeout_us(bit is_relaxed);
    return (is_relaxed ? relaxed_order_pkt_timeout_us : strict_order_pkt_timeout_us);
  endfunction : get_pkt_timeout_us

  //----------------------------------------------------------------------------
  // Task: wait_for_exp_pkt
  // Waits until the matching expected packet is queued, or until the
  // strict/relaxed timeout expires. Improves debug visibility when the
  // actual packet arrives but the expected entry is missing (lost or late).
  //----------------------------------------------------------------------------
  virtual task wait_for_exp_pkt(string msg_id = "", cdn_pcie_hls_bridge_inbound_route_to_e route_to, int unsigned hls_port_num, bit [7:0] data_bytes[], bit[2:0] id_group, bit is_relaxed, bit match_any_id_group = 0);
    string       l_msg_id    = {msg_id, "[wait_for_exp_pkt]"};
    string       order_s     = is_relaxed ? "Relaxed" : "Strict";
    int unsigned timeout_us  = get_pkt_timeout_us(is_relaxed);
    bit          timed_out   = 0;
    bit          found       = 0;

    found = is_exp_pkt_present(.route_to(route_to), .hls_port_num(hls_port_num), .data_bytes(data_bytes), .id_group(id_group), .match_any_id_group(match_any_id_group));
    if (found)
      return;

    if ((route_to == ROUTE_TO_AXI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value()) ||
        (route_to == ROUTE_TO_DTI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value()) ||
        (route_to == ROUTE_TO_MSI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_msi.get_mirrored_value()))
      return;

    if (timeout_us == 0)
      return;

    fork begin : wait_exp_pkt_guard
      fork
        begin
          while (!is_exp_pkt_present(.route_to(route_to), .hls_port_num(hls_port_num), .data_bytes(data_bytes), .id_group(id_group), .match_any_id_group(match_any_id_group)))
            @(ib_p_q_changed);
          found = 1;
        end
        begin
          m_env_cfg.m_hpa_timer.wait_for_time(timeout_us, {order_s, "-order IB posted packet timeout"}, "us");
          timed_out = 1;
        end
      join_any
      disable fork;
    end join

    found = is_exp_pkt_present(.route_to(route_to), .hls_port_num(hls_port_num), .data_bytes(data_bytes), .id_group(id_group), .match_any_id_group(match_any_id_group));

    if (timed_out && !found && checks_enable == 1) begin
      `uvm_error({component_msg_id, "_TIMEOUT"}, $sformatf("%0s-order inbound posted packet timeout after %0d us waiting for expected entry. Packet may be lost or excessively delayed. dest=%0s hls_port=%0d id_group=%0d", order_s, timeout_us, route_to.name(), hls_port_num, id_group))
      print_table(.msg_id(l_msg_id), .msg("Expected posted queue at timeout:"), .arg_table(ib_p_exp_q));
    end
  endtask : wait_for_exp_pkt

  //----------------------------------------------------------------------------
  // Task: process_undelivered_pkt_timeout
  // Watches expected posted packets that remain in ib_p_exp_q too long
  // (never delivered / DC never observed).
  //----------------------------------------------------------------------------
  virtual task process_undelivered_pkt_timeout(string msg_id = "");
    string l_msg_id = {msg_id, "[process_undelivered_pkt_timeout]"};
    forever begin
      m_env_cfg.m_misc_if_api.wait_cb();
      check_undelivered_pkt_timeouts(.msg_id(l_msg_id));
    end
  endtask : process_undelivered_pkt_timeout

  //----------------------------------------------------------------------------
  // Function: check_undelivered_pkt_timeouts
  // Reports one timeout per expected entry when its age exceeds the
  // strict- or relaxed-order budget.
  //----------------------------------------------------------------------------
  virtual function void check_undelivered_pkt_timeouts(string msg_id = "");
    time         age;
    int unsigned timeout_us;
    string       order_s;

    if (ib_p_exp_q.size() != ib_p_exp_timeout_q.size()) begin
      if (checks_enable == 1)
        `uvm_error({component_msg_id, "_ERROR"}, $sformatf("Expected posted queue and timeout metadata are out of sync (exp=%0d timeout=%0d).", ib_p_exp_q.size(), ib_p_exp_timeout_q.size()))
      return;
    end

    foreach (ib_p_exp_timeout_q[i]) begin
      if (ib_p_exp_timeout_q[i].timeout_reported)
        continue;

      timeout_us = get_pkt_timeout_us(ib_p_exp_timeout_q[i].is_relaxed);
      if (timeout_us == 0)
        continue;

      age = $time - ib_p_exp_timeout_q[i].start_time;
      if (age >= (timeout_us * 1us)) begin
        ib_p_exp_timeout_q[i].timeout_reported = 1;
        order_s = ib_p_exp_timeout_q[i].is_relaxed ? "Relaxed" : "Strict";
        if (checks_enable == 1) begin
          print_row(.msg_id(msg_id), .msg($sformatf("%0s-order inbound posted packet timed out after %0t (budget %0d us). Packet may be lost or excessively delayed:", order_s, age, timeout_us)), .row(ib_p_exp_q[i]));
          `uvm_error({component_msg_id, "_TIMEOUT"}, $sformatf("%0s-order inbound posted packet timeout after %0t. dest=%0s hls_port=%0d id_group=%0d. Packet may be lost or excessively delayed.", order_s, age, ib_p_exp_q[i].dest_port.name(), ib_p_exp_q[i].hls_port_num, ib_p_exp_q[i].id_group))
        end
      end
    end
  endfunction : check_undelivered_pkt_timeouts

  //----------------------------------------------------------------------------
  // Task: check_p_p_ordering
  //----------------------------------------------------------------------------
  task check_p_p_ordering(string msg_id = "", cdn_pcie_hls_bridge_inbound_route_to_e route_to, int unsigned hls_port_num, bit [7:0] data_bytes[], bit disable_checking, bit[2:0] id_group);
    string l_msg_id = {msg_id, "[check_p_p_ordering]"};

    // --- Order Checking -------------------------------------------------------
    foreach(ib_p_exp_q[i]) begin
      if(ib_p_exp_q[i].dest_port == route_to && ib_p_exp_q[i].hls_port_num == hls_port_num && ib_p_exp_q[i].id_group == id_group && compare_pkt_data_bytes(.lhs(ib_p_exp_q[i].data_bytes), .rhs(data_bytes))) begin
        for(int j = 0; j < i; j++) begin
          if(checks_enable == 1 && ib_p_exp_q[j].id_group == id_group && (ib_p_exp_q[j].dest_port != route_to || ib_p_exp_q[j].hls_port_num != hls_port_num)) begin
            if(disable_checking == 1) begin
              `uvm_info(l_msg_id, $sformatf("Order check is disabled for Packet which is %0s Interface...", route_to.name()), UVM_DEBUG);
              if(coverage_enable == 1)
                cg_disable_p_p_order_check_h.sample(.route_to(route_to), .hls_port_num(hls_port_num));
            end
            else begin
              print_row(.msg_id(l_msg_id), .msg("Current Packet:"), .row(ib_p_exp_q[i]));
              print_row(.msg_id(l_msg_id), .msg("Packet before the current packet that is not delivered:"), .row(ib_p_exp_q[j]));
              `uvm_error({component_msg_id, "_ERR"}, $sformatf("Packet is %0s Interface before the previous Posted pkts were delivered. Check debug prints before this error.", route_to.name()))
            end
          end
        end
        break;
      end
    end
  endtask : check_p_p_ordering

  //---------------------------------------------------------------------------
  // Method: print_row
  // This method displays a single the array records passed as argument in a tabular format.
  //---------------------------------------------------------------------------
  function void print_row(string msg_id = "", string msg, cdn_pcie_hls_bridge_ib_port_tr_delivered_s row);
    string l_row;
    
    l_row   =         "\n+------------------+--------------+------- --+--------------------+\n";
    l_row   = {l_row,   "| Destination Port | HLS Port Num | ID Group | Data Bytes(1st DW) |\n"};
    l_row   = {l_row,   "+------------------+--------------+----------+--------------------+\n"};
    l_row   = {l_row, $sformatf("| %16s | %12d | %8d | %18h |\n", row.dest_port.name(), row.hls_port_num, row.id_group, {row.data_bytes[3], row.data_bytes[2], row.data_bytes[1], row.data_bytes[0]})};
    l_row   = {l_row,   "+------------------+--------------+--------------------+"};
    
    `uvm_info(msg_id, {msg, l_row}, UVM_DEBUG)
  endfunction : print_row

  //---------------------------------------------------------------------------
  // Method: print_table
  // This method displays all the array records of ib_p_exp_q passed as argument in a tabular format.
  //---------------------------------------------------------------------------
  function void print_table(string msg_id = "", string msg = "", cdn_pcie_hls_bridge_ib_port_tr_delivered_s arg_table[$]);
    string l_table;
    
    l_table   =         "\n+------------------+--------------+----------+--------------------+\n";
    l_table   = {l_table, "| Destination Port | HLS Port Num | ID Group | Data Bytes(1st DW) |\n"};
    l_table   = {l_table, "+------------------+--------------+----------+--------------------+\n"};
    foreach (arg_table[i]) begin
      l_table = {l_table, $sformatf("| %16s | %12d | %8d | %18h |\n", arg_table[i].dest_port.name(), arg_table[i].hls_port_num, arg_table[i].id_group, {arg_table[i].data_bytes[3], arg_table[i].data_bytes[2], arg_table[i].data_bytes[1], arg_table[i].data_bytes[0]})};
    end
    l_table   = {l_table, "+------------------+--------------+-----------+--------------------+"};
    
    `uvm_info(msg_id, {msg, l_table}, UVM_DEBUG)
  endfunction : print_table

  //---------------------------------------------------------------------------
  // Method: compare_pkt_data_bytes
  // This method return 1 if the pkt bytes of lhs and rhs matches.
  //---------------------------------------------------------------------------
  function bit compare_pkt_data_bytes(bit [7:0] lhs[], bit [7:0] rhs[]);
    bit match = 1;
    if(lhs.size() != rhs.size())
      return 0;    
    
    foreach(lhs[i]) begin
      match &= (lhs[i] == rhs[i]);
    end
    return match;
  endfunction : compare_pkt_data_bytes
  
  //----------------------------------------------------------------------------
  // Task: is_balanced
  //----------------------------------------------------------------------------
  function bit is_balanced();
    string l_msg_id = "is_balanced";

    if (is_empty() == 0) begin
      print_table(.msg_id(l_msg_id), .msg($sformatf("%0s Queues not empty. Remaining items are:", component_msg_id)), .arg_table(ib_p_exp_q));
      return 0;
    end

    return 1;
  endfunction : is_balanced

  //----------------------------------------------------------------------------
  // Task: is_empty
  //----------------------------------------------------------------------------
  function bit is_empty();
    return (ib_p_exp_q.size() == 0);
  endfunction : is_empty

endclass : cdn_pcie_hls_bridge_hls_ib_posted_order_checker

`endif // CDN_PCIE_HLS_BRIDGE_HLS_IB_POSTED_ORDER_CHECKER_SV
`ifndef CDN_PCIE_HLS_BRIDGE_CXS_DRIVER_SV
`define CDN_PCIE_HLS_BRIDGE_CXS_DRIVER_SV

//-----------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_cxs_driver
// This class represents CXS Driver.
//-----------------------------------------------------------------------------
class cdn_pcie_hls_bridge_cxs_driver extends cdnCxsUvmDriver;

  //---------------------------------------------------------------------------
  // Field: sending_transaction
  // This flag indicates that the driver is currently sending a transaction.
  //---------------------------------------------------------------------------
  bit sending_transaction = 1'b0;
  
  //----------------------------------------------------------------------------
  // Variable: m_env_cfg
  // HLS Bridge Environment Config Object
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_env_config m_env_cfg;

  //---------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_component_param_utils_begin(cdn_pcie_hls_bridge_cxs_driver)
    `uvm_field_int(sending_transaction, UVM_DEFAULT)
  `uvm_component_utils_end 
  
  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name and parent handle.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_cxs_driver", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction : new 

  //-----------------------------------------------------------------------------
  // Method: build_phase
  // Reads the configuration object from the database.
  //-----------------------------------------------------------------------------
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    sending_transaction = 0;
    uvm_config_db#(int)::set(this, "", "sending_transaction", sending_transaction);

    //---Fetch the env config object----------------------------------------------
    if(!uvm_config_db#(cdn_pcie_hls_bridge_env_config)::get(this, "", "env_cfg", m_env_cfg)) begin
     `uvm_fatal(get_type_name(),"Could not find cdn_pcie_hls_bridge_env_config(env_cfg) in ConfigDB database.");
    end
  endfunction : build_phase

  //---------------------------------------------------------------------------
  // Task : mainLoop
  // Overriding the task specified in the base class for added functionality.
  //---------------------------------------------------------------------------
  virtual task mainLoop();
    uvm_sequence_item item;
    denaliCxsTransaction tr;
    
    forever begin
      
      //--- Wait for Driver to Start --------
      wait(m_env_cfg.stop_cxs_driver == 1'b0);
      
      // Get the next transaction from the sequencer. If there are no transactions available, wait here. 
      seq_item_port.get_next_item(item);
      
      // Set sending transaction bit to 1.
      sending_transaction = 1'b1;
      uvm_config_db#(int)::set(this, "", "sending_transaction", sending_transaction);

      // Cast the uvm_sequence_items to denaliCxsTransaction
      if(!$cast(tr, item) || (tr == null)) begin
        `uvm_fatal("DRIVER", "Casting failed or item returned null");
      end

      // Drive item to the VIP
      driveTransaction(tr);  
      
      // Call sequencer item_done
      seq_item_port.item_done();
      
      // Set sending transaction bit to 0.
      sending_transaction = 1'b0;
      uvm_config_db#(int)::set(this, "", "sending_transaction", sending_transaction);
    end
  endtask : mainLoop

endclass : cdn_pcie_hls_bridge_cxs_driver

`endif // CDN_PCIE_HLS_BRIDGE_CXS_DRIVER_SV
