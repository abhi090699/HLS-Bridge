`ifndef CDN_PCIE_HLS_BRIDGE_HLS_IB_POSTED_ORDER_CHECKER_SV
`define CDN_PCIE_HLS_BRIDGE_HLS_IB_POSTED_ORDER_CHECKER_SV

//-----------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_hls_ib_posted_order_checker
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
  // Variable: m_ro_stall_timeout_ns
  // Timeout in nanoseconds used by two stall watchdogs:
  //   1. RO packet stall: an RO packet was allowed to bypass predecessors but
  //      was not DC-acknowledged within this time.
  //   2. STRICT packet stall: a STRICT packet's predecessors were all
  //      DC-acknowledged but the packet itself was not delivered within this
  //      time (DUT is holding it without cause).
  // Configurable via uvm_config_db or directly by the test.
  // Default: 10000 ns.
  //----------------------------------------------------------------------------
  int unsigned m_ro_stall_timeout_ns = 10000;
  
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
  // Queue to store all the inbound posted packets received from Core in order.
  // Each entry carries an .ro flag to distinguish strict vs relaxed packets.
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_ib_port_tr_delivered_s ib_p_exp_q[$];

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

    // Allow test to override RO stall timeout
    void'(uvm_config_db#(int unsigned)::get(this, "", "ro_stall_timeout_ns", m_ro_stall_timeout_ns));
    
    //-- Create analysis fifo ------------------
    m_in_exp_p_pkt_ended_af = new("m_in_exp_p_pkt_ended_af", this);
    foreach(m_in_act_p_axi_cxs_pkt_ended_af[loop_port])
      m_in_act_p_axi_cxs_pkt_ended_af[loop_port] = new($sformatf("m_in_act_p_axi_cxs_pkt_ended_af[%0d]", loop_port), this);
    m_in_act_p_dti_cxs_pkt_ended_af = new("m_in_act_p_dti_cxs_pkt_ended_af", this);
    m_in_act_p_msi_pkt_ended_af = new("m_in_act_p_msi_pkt_ended_af", this);
    foreach(m_in_axi_delivered_count_pkt_ended_af[loop_port])
      m_in_axi_delivered_count_pkt_ended_af[loop_port] = new($sformatf("m_in_axi_delivered_count_pkt_ended_af[%0d]", loop_port), this);
    m_in_dti_delivered_count_pkt_ended_af = new("m_in_dti_delivered_count_pkt_ended_af", this);
    
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

    //---- Analysis FIFO Flush ------------------
    m_in_exp_p_pkt_ended_af.flush();
    foreach(m_in_act_p_axi_cxs_pkt_ended_af[loop_port])
      m_in_act_p_axi_cxs_pkt_ended_af[loop_port].flush();
    m_in_act_p_dti_cxs_pkt_ended_af.flush();
    m_in_act_p_msi_pkt_ended_af.flush();
    foreach(m_in_axi_delivered_count_pkt_ended_af[loop_port])
      m_in_axi_delivered_count_pkt_ended_af[loop_port].flush();
    m_in_dti_delivered_count_pkt_ended_af.flush();

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
    
    forever begin
      // -- Get pkt ---------------------------------------
      m_in_exp_p_pkt_ended_af.get(port_tr);

      if (port_tr.dest_port == ROUTE_TO_AXI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value())
        continue;

      if (port_tr.dest_port == ROUTE_TO_DTI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value())
        continue;

      if (port_tr.dest_port == ROUTE_TO_MSI && hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_msi.get_mirrored_value())
        continue;

      // -- Push it in the queue --------------------------
      ib_p_exp_q.push_back(port_tr);

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

    forever begin
      // -- Get pkt ------------------------------------------------------
      m_in_act_p_axi_cxs_pkt_ended_af[port_num].get(cxs_pkt);

      l_hls_ib_p_np_meta_s = {<<byte{cxs_pkt.UserControl}};

      `uvm_info(get_type_name(), $sformatf("[RO_ORDER] AXI port %0d pkt received: ro=%0b idgroup=%0d",
                port_num, l_hls_ib_p_np_meta_s.ro, l_hls_ib_p_np_meta_s.idgroup), UVM_DEBUG)

      // -- Check the ordering as soon as actual packet is received ------
      check_p_p_ordering(.msg_id(l_msg_id), .route_to(ROUTE_TO_AXI), .hls_port_num(port_num),
                         .data_bytes(cxs_pkt.DataPerPktRx), .id_group(l_hls_ib_p_np_meta_s.idgroup));
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

      // -- Check the ordering as soon as actual packet is received ------
      check_p_p_ordering(.msg_id(l_msg_id), .route_to(ROUTE_TO_DTI), .hls_port_num(0),
                         .data_bytes(cxs_pkt.DataPerPktRx), .id_group(l_hls_ib_p_np_meta_s.idgroup));
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

      // -- Check the ordering as soon as actual packet is received ------
      foreach(ib_p_exp_q[i]) begin
        if(ib_p_exp_q[i].dest_port == ROUTE_TO_MSI &&
           compare_pkt_data_bytes(.lhs(ib_p_exp_q[i].data_bytes), .rhs(msi_pkt.PacketData))) begin
          id_group = ib_p_exp_q[i].id_group;
          break;
        end
      end
      check_p_p_ordering(.msg_id(l_msg_id), .route_to(ROUTE_TO_MSI), .hls_port_num(0),
                         .data_bytes(msi_pkt.PacketData), .id_group(id_group));

      //--- Removing the MSI Pkt Delivered from queue. --------------
      foreach(ib_p_exp_q[i]) begin
        if(ib_p_exp_q[i].dest_port == ROUTE_TO_MSI &&
           compare_pkt_data_bytes(.lhs(ib_p_exp_q[i].data_bytes), .rhs(msi_pkt.PacketData))) begin
          id_group = ib_p_exp_q[i].id_group;
          ib_p_exp_q.delete(i);
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

      if (!hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_per_port_o_chk.get_mirrored_value()) begin
        `uvm_info(get_type_name(), $sformatf("handle_delivered_count() for AXI for stream %0d, dc_val %0d", id_group, dc_val), UVM_DEBUG)
        handle_delivered_count(.dc_val(dc_val), .intf_name(ROUTE_TO_AXI), .port_num(port_num), .id_group(id_group));
      end

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

      if (!hls_bridge_regmodel.hls_bridge_regs_memory_map_wrapper_hls_bridge_regs.hls_bridge_dbg_order.dbg_dis_o_chk_dti.get_mirrored_value()) begin
        `uvm_info(get_type_name(), $sformatf("handle_delivered_count() for DTI for stream %0d, dc_val %0d", id_group, dc_val), UVM_DEBUG)
        handle_delivered_count(.dc_val(dc_val), .intf_name(ROUTE_TO_DTI), .port_num(0), .id_group(id_group));
      end

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
        ib_p_exp_q.delete(i);
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

    // --- After removing DC entries, check for STRICT packets now unblocked ---
    // If a STRICT packet's predecessors are all gone but the DUT has not yet
    // delivered it, the stall watchdog in check_strict_stall_after_dc will
    // catch it after m_ro_stall_timeout_ns ns.
    check_strict_stall_after_dc(.id_group(id_group));

  endtask : handle_delivered_count

  //----------------------------------------------------------------------------
  // Task: check_strict_stall_after_dc
  //
  // Called by handle_delivered_count() after DC entries are removed.
  // Scans ib_p_exp_q for STRICT (ro==0) packets on the given id_group that
  // now have NO same-id_group predecessor at a different output still in the
  // queue (i.e. all their blocking predecessors have been DC-acknowledged).
  // For each such packet a stall-timeout watchdog is spawned: if the STRICT
  // packet entry is still present in ib_p_exp_q after m_ro_stall_timeout_ns
  // nanoseconds, the DUT is holding it even though it is free to forward it.
  //----------------------------------------------------------------------------
  task check_strict_stall_after_dc(bit[2:0] id_group);
    if (!checks_enable)
      return;

    foreach (ib_p_exp_q[i]) begin
      // Only care about STRICT packets on this id_group
      if (ib_p_exp_q[i].id_group != id_group || ib_p_exp_q[i].ro != 0)
        continue;

      begin : strict_predecessor_check
        bit l_has_blocking_predecessor = 0;

        // Check whether any same-id_group entry ahead of this one in the queue
        // is at a different output (i.e. still an unacknowledged predecessor)
        for (int j = 0; j < i; j++) begin
          if (ib_p_exp_q[j].id_group != id_group)
            continue;
          if (ib_p_exp_q[j].dest_port == ib_p_exp_q[i].dest_port &&
              ib_p_exp_q[j].hls_port_num == ib_p_exp_q[i].hls_port_num)
            continue;
          // A predecessor still in queue at a different output → still blocked
          l_has_blocking_predecessor = 1;
          break;
        end

        if (!l_has_blocking_predecessor) begin
          // All predecessors DC-acknowledged — DUT must now deliver this packet.
          // Spawn a stall watchdog.
          automatic cdn_pcie_hls_bridge_ib_port_tr_delivered_s l_snap      = ib_p_exp_q[i];
          automatic int unsigned                               l_timeout_ns = m_ro_stall_timeout_ns;
          fork
            begin : strict_stall_watchdog
              #(l_timeout_ns * 1ns);
              foreach (ib_p_exp_q[k]) begin
                if (ib_p_exp_q[k].dest_port    == l_snap.dest_port    &&
                    ib_p_exp_q[k].hls_port_num == l_snap.hls_port_num &&
                    ib_p_exp_q[k].id_group     == l_snap.id_group      &&
                    ib_p_exp_q[k].ro           == l_snap.ro            &&
                    compare_pkt_data_bytes(.lhs(ib_p_exp_q[k].data_bytes), .rhs(l_snap.data_bytes))) begin
                  `uvm_error({component_msg_id, "_STRICT_STALL"},
                    $sformatf("[RO_ORDER] DUT stall detected: STRICT packet (idg=%0d dst=%0s port=%0d) was not delivered within %0d ns after all same-id_group predecessors were DC-acknowledged.",
                              l_snap.id_group, l_snap.dest_port.name(), l_snap.hls_port_num, l_timeout_ns))
                  disable strict_stall_watchdog;
                end
              end
            end : strict_stall_watchdog
          join_none
        end
      end : strict_predecessor_check
    end

  endtask : check_strict_stall_after_dc

  //----------------------------------------------------------------------------
  // Task: check_p_p_ordering
  //
  // Implements PCIe posted ordering rules scoped per id_group:
  //
  //   STRICT packet (ro==0 in ib_p_exp_q):
  //     Must NOT pass any same-id_group predecessor at a different dest/port
  //     still present in ib_p_exp_q (not yet DC-acknowledged).
  //     → uvm_error on any such predecessor.
  //
  //   RELAXED (RO) packet (ro==1 in ib_p_exp_q):
  //     MAY bypass any same-id_group predecessor (strict or RO) that is still
  //     in ib_p_exp_q.  This is legal per PCIe RO ordering rules.
  //     Coverage is sampled for each bypassed predecessor.
  //     → A stall-timeout watchdog is spawned: if the RO entry is still in
  //       ib_p_exp_q after m_ro_stall_timeout_ns nanoseconds, a DUT-stall
  //       error is raised (the DUT should have forwarded it already).
  //
  // Note: the packet entry in ib_p_exp_q is NOT removed here.
  //   AXI/DTI entries are removed by handle_delivered_count() on DC receipt.
  //   MSI entries are removed directly in process_act_p_msi_pkt_ended().
  //----------------------------------------------------------------------------
  task check_p_p_ordering(string msg_id = "",
                           cdn_pcie_hls_bridge_inbound_route_to_e route_to,
                           int unsigned hls_port_num,
                           bit [7:0] data_bytes[],
                           bit [2:0] id_group);
    string l_msg_id          = {msg_id, "[check_p_p_ordering]"};
    int    l_pkt_idx         = -1;
    bit    l_is_ro           = 0;
    bit    l_has_predecessor = 0;

    // --- Locate arriving packet in expected queue --------------------------
    foreach (ib_p_exp_q[i]) begin
      if (ib_p_exp_q[i].dest_port    == route_to     &&
          ib_p_exp_q[i].hls_port_num == hls_port_num &&
          ib_p_exp_q[i].id_group     == id_group      &&
          compare_pkt_data_bytes(.lhs(ib_p_exp_q[i].data_bytes), .rhs(data_bytes))) begin
        l_pkt_idx = i;
        l_is_ro   = ib_p_exp_q[i].ro;
        break;
      end
    end

    if (l_pkt_idx < 0) begin
      `uvm_info(l_msg_id,
        $sformatf("[RO_ORDER] Arrived pkt not found in exp_q (route=%0s port=%0d idg=%0d) - scoreboard handles",
                  route_to.name(), hls_port_num, id_group), UVM_DEBUG)
      return;
    end

    // --- Check all predecessors (entries before l_pkt_idx in queue) --------
    for (int j = 0; j < l_pkt_idx; j++) begin
      // Only consider same id_group, different output
      if (ib_p_exp_q[j].id_group != id_group)
        continue;
      if (ib_p_exp_q[j].dest_port == route_to && ib_p_exp_q[j].hls_port_num == hls_port_num)
        continue;

      // A predecessor on the same id_group at a different output exists
      l_has_predecessor = 1;

      if (!checks_enable)
        continue;

      if (!l_is_ro) begin
        // STRICT packet bypassing a predecessor → ordering violation
        print_row(.msg_id(l_msg_id), .msg("Current STRICT Packet:"),   .row(ib_p_exp_q[l_pkt_idx]));
        print_row(.msg_id(l_msg_id), .msg("Undelivered predecessor:"), .row(ib_p_exp_q[j]));
        `uvm_error({component_msg_id, "_ERR"},
          $sformatf("STRICT packet delivered to %0s port %0d before predecessor on same id_group %0d. See debug prints above.",
                    route_to.name(), hls_port_num, id_group))
      end else begin
        // RELAXED (RO) packet bypassing a predecessor → legal, log + coverage
        `uvm_info(l_msg_id,
          $sformatf("[RO_ORDER] RO pkt (idg=%0d dst=%0s port=%0d) legally bypassing predecessor (dst=%0s port=%0d ro=%0b)",
                    id_group, route_to.name(), hls_port_num,
                    ib_p_exp_q[j].dest_port.name(), ib_p_exp_q[j].hls_port_num, ib_p_exp_q[j].ro), UVM_DEBUG)
        if (coverage_enable)
          cg_disable_p_p_order_check_h.sample(.route_to(route_to), .hls_port_num(hls_port_num));
      end
    end // for predecessors

    // --- Spawn stall-timeout watchdog for RO packets that bypassed ---------
    // If the RO packet entry is still in ib_p_exp_q after m_ro_stall_timeout_ns
    // nanoseconds, the DUT is stalling a packet it was free to forward.
    if (l_is_ro && l_has_predecessor && checks_enable) begin
      automatic cdn_pcie_hls_bridge_ib_port_tr_delivered_s l_snap       = ib_p_exp_q[l_pkt_idx];
      automatic int unsigned                               l_timeout_ns  = m_ro_stall_timeout_ns;
      fork
        begin : ro_stall_watchdog
          #(l_timeout_ns * 1ns);
          foreach (ib_p_exp_q[k]) begin
            if (ib_p_exp_q[k].dest_port    == l_snap.dest_port    &&
                ib_p_exp_q[k].hls_port_num == l_snap.hls_port_num &&
                ib_p_exp_q[k].id_group     == l_snap.id_group      &&
                ib_p_exp_q[k].ro           == l_snap.ro            &&
                compare_pkt_data_bytes(.lhs(ib_p_exp_q[k].data_bytes), .rhs(l_snap.data_bytes))) begin
              `uvm_error({component_msg_id, "_RO_STALL"},
                $sformatf("[RO_ORDER] DUT stall detected: RO packet (idg=%0d dst=%0s port=%0d) was allowed to bypass predecessors but was not DC-acknowledged within %0d ns.",
                          l_snap.id_group, l_snap.dest_port.name(), l_snap.hls_port_num, l_timeout_ns))
              disable ro_stall_watchdog;
            end
          end
        end : ro_stall_watchdog
      join_none
    end

  endtask : check_p_p_ordering

  //---------------------------------------------------------------------------
  // Method: print_row
  // This method displays a single the array records passed as argument in a tabular format.
  //---------------------------------------------------------------------------
  function void print_row(string msg_id = "", string msg, cdn_pcie_hls_bridge_ib_port_tr_delivered_s row);
  	string l_row;
        string l_order_str;
 
	l_order_str = row.ro ? "RELAXED" : "STRICT";
 
  	l_row   =         "\n+------------------+--------------+----------+--------------------+----------+\n";
  	l_row   = {l_row,   "| Destination Port | HLS Port Num | ID Group | Data Bytes(1st DW) | Ordering |\n"};
  	l_row   = {l_row,   "+------------------+--------------+----------+--------------------+----------+\n"};
  	l_row   = {l_row, $sformatf("| %16s | %12d | %8d | %18h | %8s |\n",
                               row.dest_port.name(), row.hls_port_num, row.id_group,
                               {row.data_bytes[3], row.data_bytes[2], row.data_bytes[1], row.data_bytes[0]},
                               l_order_str)};
  	l_row   = {l_row,   "+------------------+--------------+----------+--------------------+----------+"};
 
  	`uvm_info(msg_id, {msg, l_row}, UVM_DEBUG)
   endfunction : print_row
 

  //---------------------------------------------------------------------------
  // Method: print_table
  // This method displays all the array records of ib_p_exp_q passed as argument in a tabular format.
  //---------------------------------------------------------------------------
  function void print_table(string msg_id = "", string msg = "", cdn_pcie_hls_bridge_ib_port_tr_delivered_s arg_table[$]);
  	string l_table;
  	string l_order_str;
 
  	l_table   =         "\n+------------------+--------------+----------+--------------------+----------+\n";
  	l_table   = {l_table, "| Destination Port | HLS Port Num | ID Group | Data Bytes(1st DW) | Ordering |\n"};
  	l_table   = {l_table, "+------------------+--------------+----------+--------------------+----------+\n"};
 	 foreach (arg_table[i]) begin
   	    l_order_str = arg_table[i].ro ? "RELAXED" : "STRICT";
    	    l_table = {l_table, $sformatf("| %16s | %12d | %8d | %18h | %8s |\n",
                                   arg_table[i].dest_port.name(), arg_table[i].hls_port_num, arg_table[i].id_group,
                                   {arg_table[i].data_bytes[3], arg_table[i].data_bytes[2], arg_table[i].data_bytes[1], arg_table[i].data_bytes[0]},
                                   l_order_str)};
  	end
 	l_table   = {l_table, "+------------------+--------------+----------+--------------------+----------+"};
 
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
