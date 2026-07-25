`ifndef CDN_PCIE_HLS_BRIDGE_HLS_OB_MERGE_PREDICTOR_SV
`define CDN_PCIE_HLS_BRIDGE_HLS_OB_MERGE_PREDICTOR_SV

//-----------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_hls_ob_merge_predictor
//-----------------------------------------------------------------------------
class cdn_pcie_hls_bridge_hls_ob_merge_predictor extends uvm_component implements I_cdn_pcie_hls_bridge_reset;
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

  //----------------------------------------------------------------------------
  // Variable: m_env_cfg
  // HLS Bridge Environment Config Object
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_env_config m_env_cfg;
  
  //---------------------------------------------------------------------------
  // Local Variables
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Variable: sorted_queue
  // Queue which stores the predicted packet based on port_idx and start_time.
  //---------------------------------------------------------------------------
  cdn_pcie_hls_bridge_cxs_port_tr_s sorted_queue[$];
  
  //---------------------------------------------------------------------------
  // Variable: port_pkt_start_counter
  // Array per port which increments whenever a packet starts on a port.
  // Required for order checking when multiple packets start in a single cycle
  // on a port.
  //---------------------------------------------------------------------------
  int unsigned port_pkt_start_counter[parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT];
  
  //---------------------------------------------------------------------------
  // Variable: last_cycle_time
  // Last clk cycle time used for coverage.
  //---------------------------------------------------------------------------
  time last_cycle_time = -1;

  //---------------------------------------------------------------------------
  // Variable: ports_active_in_cycle
  // Bitmask used to store the number of ports active in a cycle. Used for coverage.
  //---------------------------------------------------------------------------
  bit [31: 0] ports_active_in_cycle;

  //---------------------------------------------------------------------------
  // Variable: last_predicted_port
  // Port number of the last predicted packet. Used for coverage.
  //---------------------------------------------------------------------------
  int last_predicted_port;
  
  //---------------------------------------------------------------------------
  // Coverage Instances.
  //---------------------------------------------------------------------------
  cg_ports_active_in_cycle_combinations cg_ports_active_in_cycle_combinations_h ;
  cg_predicted_pkt_port_transition      cg_predicted_pkt_port_transition_h      ;
  
  //---------------------------------------------------------------------------
  // TLM Analysis FIFOs
  //---------------------------------------------------------------------------
  uvm_tlm_analysis_fifo #(denaliCxsTransaction) m_in_cxs_pkt_started_af [parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT] ;
  uvm_tlm_analysis_fifo #(denaliCxsTransaction) m_in_cxs_pkt_ended_af   [parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT] ;
  
  uvm_analysis_port     #(denaliCxsTransaction) m_out_predicted_cxs_pkt_ap ;

  `uvm_component_utils(cdn_pcie_hls_bridge_hls_ob_merge_predictor)
  
  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name and parent handle.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_hls_ob_merge_predictor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: build_phase
  //---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   
    //---Fetch the env config object----------------------------------------------
    if(!uvm_config_db#(cdn_pcie_hls_bridge_env_config)::get(this, "", "env_cfg", m_env_cfg)) begin
     `uvm_fatal(get_type_name(),"Could not find cdn_pcie_hls_bridge_env_config(env_cfg) in ConfigDB database.");
    end

    //-- Create analysis fifo ------------------
    foreach(m_in_cxs_pkt_started_af[loop_port]) begin
      m_in_cxs_pkt_started_af[loop_port] = new($sformatf("m_in_cxs_pkt_started_af[%0d]", loop_port), this);
    end
    foreach(m_in_cxs_pkt_ended_af[loop_port]) begin
      m_in_cxs_pkt_ended_af[loop_port] = new($sformatf("m_in_cxs_pkt_ended_af[%0d]", loop_port), this);
    end

    //-- Create analysis ports ----------------
    m_out_predicted_cxs_pkt_ap = new("m_out_predicted_cxs_pkt_ap", this);

    //-- Coverage creation --------------------
    cg_ports_active_in_cycle_combinations_h = new(.cg_name("cg_ports_active_in_cycle_combinations_h"), .num_ports(parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT));
    cg_predicted_pkt_port_transition_h      = new(.cg_name("cg_predicted_pkt_port_transition_h")     , .num_ports(parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT));
  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Task: main_phase
  //----------------------------------------------------------------------------
  virtual task main_phase(uvm_phase phase);
    string l_msg_id = {"[", get_type_name(), "]", "[main_phase]"};
    super.main_phase(phase);
    
    `uvm_info(l_msg_id, "Starting HLS Bridge HLS OB Merge Predictor Main Phase...", UVM_LOW);

    fork
      for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS + parameters_cfg_pkg::KMAX_DTI_SUPPORT; loop_port++) begin
        automatic int unsigned l_port = loop_port;
        fork
          process_cxs_pkt_started(.msg_id(l_msg_id), .port_num(l_port));
          process_cxs_pkt_ended  (.msg_id(l_msg_id), .port_num(l_port));
        join_none
      end
    join

    `uvm_info(l_msg_id, "Ending HLS Bridge HLS OB Merge Predictor Main Phase...", UVM_LOW);
  endtask : main_phase

  //----------------------------------------------------------------------------
  // Function: check_phase
  //----------------------------------------------------------------------------
  virtual function void check_phase(uvm_phase phase);
    string l_msg_id = {"[", get_type_name(), "]", "[check_phase]"};
    super.check_phase(phase);

    // -- Check whether sorted queue are empty at the end of the test -----------
    if(!is_balanced() && checks_enable == 1)
      `uvm_error("PRED_CHECK", $sformatf("[%0s]:: Predictor sorted_queue is not empty at the end of the test.", get_name()))

  endfunction : check_phase

  //----------------------------------------------------------------------------
  // Task: process_cxs_pkt_started (Per Port)
  //----------------------------------------------------------------------------
  task process_cxs_pkt_started(string msg_id = "", int unsigned port_num);
    string                            l_msg_id = {msg_id, $sformatf("[process_cxs_pkt_started[%0d]]", port_num)} ;
    denaliCxsTransaction              cxs_pkt                                                                    ;
    cdn_pcie_hls_bridge_cxs_port_tr_s port_tr                                                                    ;
    
    forever begin
      // -- Get pkt ---------------------------------------
      m_in_cxs_pkt_started_af[port_num].get(cxs_pkt);

      // -- Coverage related updates ----------------------
      if (last_cycle_time != -1 && last_cycle_time != cxs_pkt.PktStartTime) begin
        if (coverage_enable)
          cg_ports_active_in_cycle_combinations_h.sample(.ports_active_in_cycle(ports_active_in_cycle));
        
        ports_active_in_cycle = 0;
      end
      
      last_cycle_time                 = cxs_pkt.PktStartTime ;
      ports_active_in_cycle[port_num] = 1                    ;
    end

  endtask : process_cxs_pkt_started 
  
  //----------------------------------------------------------------------------
  // Task: process_cxs_pkt_ended (Per Port)
  //----------------------------------------------------------------------------
  task process_cxs_pkt_ended(string msg_id = "", int unsigned port_num);
    string                            l_msg_id = {msg_id, $sformatf("[process_cxs_pkt_ended[%0d]]", port_num)} ;
    denaliCxsTransaction              cxs_pkt                                                                  ;
    cdn_pcie_hls_bridge_cxs_port_tr_s port_tr                                                                  ;
    
    forever begin
      // -- Get pkt ---------------------------------------
      m_in_cxs_pkt_ended_af[port_num].get(cxs_pkt);

      // -- Waiting for end of current simulation time for cases where the packet start and end in the same cycle 
      // -- in those cases there are chances the process_cxs_pkt_ended starts before process_cxs_pkt_started.
      m_env_cfg.m_hpa_timer.wait_for_hash_zero_delay();

      // -- Create Port Tr --------------------------------
      port_tr.port_idx     = port_num ;
      port_tr.tr           = cxs_pkt  ;
      port_tr.is_available = 1        ;
      
      // -- Push to the queue -----------------------------
      sorted_queue.push_back(port_tr);
 
      // -- Print Transaction Queues ----------------------
      print_table(.msg_id(l_msg_id));

      // -- Sending predicted transactions ----------------
      send_available_tr(.msg_id(l_msg_id));
    end

  endtask : process_cxs_pkt_ended

  //----------------------------------------------------------------------------
  // Task:       send_available_tr
  // Decription: send out all the transactions available in the queue
  // using the analysis port.
  //----------------------------------------------------------------------------
  task send_available_tr(string msg_id = "");
    string                            l_msg_id = {msg_id, "[send_available_tr]"} ;
    cdn_pcie_hls_bridge_cxs_port_tr_s port_tr                                    ;

    // -- Loop through all the tr in the queue and send them. --------      
    while(sorted_queue.size() > 0) begin
      port_tr = sorted_queue.pop_front();

      // -- Send out all the predicted transaction through analysis port. --------      
      m_out_predicted_cxs_pkt_ap.write(port_tr.tr);

      // -- Sample coverage and set the last predicted port ---------------------
      if(coverage_enable)
        cg_predicted_pkt_port_transition_h.sample(.from_port(last_predicted_port), .to_port(port_tr.port_idx));
      last_predicted_port  = port_tr.port_idx;

      `uvm_info(l_msg_id, $sformatf("Predicted OB Packet from Port: %0d with StartTime: %0t", port_tr.port_idx, port_tr.tr.PktStartTime), UVM_HIGH)
    end
  endtask : send_available_tr


  // // -- TODO: Can this code be used for multiport ordering ? Need to
  // // -- review, once there is a confirmation from design that ordering needs to be
  // // -- maintained for outbound in multiport.
  // //----------------------------------------------------------------------------
  // // Task: process_cxs_pkt_started (Per Port)
  // //----------------------------------------------------------------------------
  // task process_cxs_pkt_started(string msg_id = "", int unsigned port_num);
  //   string                            l_msg_id = {msg_id, $sformatf("[process_cxs_pkt_started[%0d]]", port_num)} ;
  //   denaliCxsTransaction              cxs_pkt                                                                    ;
  //   cdn_pcie_hls_bridge_cxs_port_tr_s port_tr                                                                    ;
    
  //   forever begin
  //     // -- Get pkt ---------------------------------------
  //     m_in_cxs_pkt_started_af[port_num].get(cxs_pkt);

  //     // -- Coverage related updates ----------------------
  //     if (last_cycle_time != -1 && last_cycle_time != cxs_pkt.PktStartTime) begin
  //       if (coverage_enable)
  //         cg_ports_active_in_cycle_combinations_h.sample(.ports_active_in_cycle(ports_active_in_cycle));
        
  //       ports_active_in_cycle = 0;
  //     end
      
  //     last_cycle_time                 = cxs_pkt.PktStartTime ;
  //     ports_active_in_cycle[port_num] = 1                    ;

  //     // -- Create Port Tr --------------------------------
  //     port_tr.port_idx     = port_num                           ;
  //     port_tr.tr           = cxs_pkt                            ;
  //     port_tr.order_id     = port_pkt_start_counter[port_num]++ ; 
  //     port_tr.is_available = 0                                  ;

  //     // -- Handle started pkt ----------------------------
  //     post_process_cxs_pkt_started(.msg_id(l_msg_id) , .port_tr(port_tr));
  //   end

  // endtask : process_cxs_pkt_started

  // //----------------------------------------------------------------------------
  // // Task: process_cxs_pkt_ended (Per Port)
  // //----------------------------------------------------------------------------
  // task process_cxs_pkt_ended(string msg_id = "", int unsigned port_num);
  //   string                            l_msg_id = {msg_id, $sformatf("[process_cxs_pkt_ended[%0d]]", port_num)} ;
  //   denaliCxsTransaction              cxs_pkt                                                                  ;
  //   cdn_pcie_hls_bridge_cxs_port_tr_s port_tr                                                                  ;
    
  //   forever begin
  //     // -- Get pkt ---------------------------------------
  //     m_in_cxs_pkt_ended_af[port_num].get(cxs_pkt);

  //     // -- Waiting for an extra cycle for cases where the packet start and end in the same cycle 
  //     // in those cases there are chances the process_cxs_pkt_ended starts before process_cxs_pkt_started.
  //     m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));

  //     // -- Create Port Tr --------------------------------
  //     port_tr.port_idx     = port_num ;
  //     port_tr.tr           = cxs_pkt  ;
  //     port_tr.is_available = 1        ;
      
  //     // -- Handle ended pkt ------------------------------
  //     post_process_cxs_pkt_ended(.msg_id(l_msg_id), .port_tr(port_tr));
  //   end

  // endtask : process_cxs_pkt_ended

  // //----------------------------------------------------------------------------
  // // Task: post_process_cxs_pkt_started
  // //----------------------------------------------------------------------------
  // task post_process_cxs_pkt_started(string msg_id = "", cdn_pcie_hls_bridge_cxs_port_tr_s port_tr);
  //   string       l_msg_id         = {msg_id, "[post_process_started_pkt]"} ;
  //   int unsigned sorted_queue_idx = 0                                      ;

  //   // -- Find the index in the sorted queue based on 3 scenarios:
  //   // 1. Start_time of current packet is less than start_time of packet in queue.
  //   // 2. Start time of current packet is same as the packet in the queue however port is of lower idx.
  //   // 3. Start time, port idx of current packet is same as the packet in the queue however order_id = packet in queue order_id + 1.
  //   // 4. DTI going first if packets arrived in the same time
  //   foreach(sorted_queue[i]) begin
  //     if((port_tr.tr.PktStartTime < sorted_queue[i].tr.PktStartTime) ||
  //        (port_tr.tr.PktStartTime == sorted_queue[i].tr.PktStartTime && port_tr.port_idx < sorted_queue[i].port_idx) ||
  //        (port_tr.tr.PktStartTime == sorted_queue[i].tr.PktStartTime && port_tr.port_idx == sorted_queue[i].port_idx && port_tr.order_id < sorted_queue[i].order_id) ||
  //        (port_tr.tr.PktStartTime == sorted_queue[i].tr.PktStartTime && parameters_cfg_pkg::KMAX_DTI_SUPPORT && port_tr.port_idx == parameters_cfg_pkg::NUM_HLS_PORTS))
  //       break;
  //     sorted_queue_idx++;
  //   end
    
  //   // -- Insert the pkt inside the sorted_queue on the found out index --------
  //   sorted_queue.insert(sorted_queue_idx, port_tr);
    
  //   // -- Print Transaction Queues ---------------
  //   print_table(.msg_id(l_msg_id)); 

  // endtask : post_process_cxs_pkt_started
 
  
  // //----------------------------------------------------------------------------
  // // Task: post_process_cxs_pkt_ended
  // //----------------------------------------------------------------------------
  // task post_process_cxs_pkt_ended(string msg_id = "", cdn_pcie_hls_bridge_cxs_port_tr_s port_tr);
  //   string l_msg_id = {msg_id, "[post_process_cxs_pkt_ended]"} ;
  //   bit is_tr_found = 0                                        ;

  //   foreach(sorted_queue[i]) begin
  //     if(port_tr.tr.PktStartTime == sorted_queue[i].tr.PktStartTime && port_tr.port_idx == sorted_queue[i].port_idx && sorted_queue[i].is_available == 1'b0) begin
  //       sorted_queue[i].tr           = port_tr.tr           ;
  //       sorted_queue[i].is_available = port_tr.is_available ;
  //       is_tr_found                  = 1                    ;
  //       break;
  //     end
  //   end
    
  //   if(!is_tr_found && checks_enable) begin
  //     print_table(.msg_id(l_msg_id));
  //     `uvm_info("PRED_CHECK_DEBUG", $sformatf("Ended Packet StartTime: %0t, PortID: %0d", port_tr.tr.PktStartTime, port_tr.port_idx), UVM_LOW)
  //     `uvm_error("PRED_CHECK", $sformatf("[%0s]:: Received a transaction on ended callback port without a prior start.", get_name()));
  //   end
    
  //   // -- Print Transaction Queues ---------------
  //   print_table(.msg_id(l_msg_id)); 

  //   // -- Calling this method to send the available transactions. ------------
  //   send_available_tr(.msg_id(l_msg_id));
    
  // endtask : post_process_cxs_pkt_ended
  
  // //----------------------------------------------------------------------------
  // // Task:       send_available_tr
  // // Decription: send out all the available transaction using the analysis
  // // port.
  // //----------------------------------------------------------------------------
  // task send_available_tr(string msg_id = "");
  //   string                            l_msg_id = {msg_id, "[send_available_tr]"} ;
  //   cdn_pcie_hls_bridge_cxs_port_tr_s port_tr                                    ;
  //   int unsigned                      next_to_send                               ;

  //   next_to_send = 0;
    
  //   // -- Loop through all the tr in the queue and send all those which are availabe to send. --------      
  //   while(next_to_send < sorted_queue.size()) begin
  //     port_tr = sorted_queue[next_to_send];

  //     if(sorted_queue[next_to_send].is_available == 0)
  //       break;

  //     // -- Send out all the predicted transaction through analysis port. --------      
  //     m_out_predicted_cxs_pkt_ap.write(port_tr.tr);

  //     // -- Sample coverage and set the last predicted port ---------------------
  //     if(coverage_enable)
  //       cg_predicted_pkt_port_transition_h.sample(.from_port(last_predicted_port), .to_port(port_tr.port_idx));
  //     last_predicted_port  = port_tr.port_idx;

  //     // -- Delete the sent out item from the sorted queue ----------------------
  //     sorted_queue.delete(0);
  //     next_to_send = 0;
  //     `uvm_info(l_msg_id, $sformatf("Predicted packet from port %0d with start_time = %0t", port_tr.port_idx, port_tr.tr.PktStartTime), UVM_HIGH)
  //   end
  // endtask : send_available_tr

  //----------------------------------------------------------------------------
  // Function: perform_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_RESET", $sformatf("Started resetting cdn_pcie_hls_bridge_hls_ob_merge_predictor(%0s) component.....", get_full_name()), UVM_DEBUG)
    
    //---- local Variables Clear -----------------
    sorted_queue.delete();
    foreach(port_pkt_start_counter[loop_port])
      port_pkt_start_counter[loop_port] = 0;
    last_cycle_time = -1;
    ports_active_in_cycle = 32'b0;
    last_predicted_port = 0;
    
    //---- Analysis FIFO Flush ------------------
    foreach(m_in_cxs_pkt_started_af[loop_port])
      m_in_cxs_pkt_started_af[loop_port].flush();
    foreach(m_in_cxs_pkt_ended_af[loop_port])
      m_in_cxs_pkt_ended_af[loop_port].flush();
    
    `uvm_info("PERFORM_RESET", $sformatf("Completed resetting cdn_pcie_hls_bridge_hls_ob_merge_predictor(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_reset

  //----------------------------------------------------------------------------
  // Function: perform_axil_reset
  // Implementing the I_cdn_pcie_hls_bridge_reset method to reset this component.
  //----------------------------------------------------------------------------
  virtual task perform_axil_reset(bit is_linkdown = 0);
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Started axil resetting cdn_pcie_hls_bridge_hls_ob_merge_predictor(%0s) component.....", get_full_name()), UVM_DEBUG)
    `uvm_info("PERFORM_AXIL_RESET", $sformatf("Completed axil resetting cdn_pcie_hls_bridge_hls_ob_merge_predictor(%0s) component.....", get_full_name()), UVM_DEBUG)
  endtask : perform_axil_reset

  //---------------------------------------------------------------------------
  // Method: print_table
  // This method displays all the array records in a tabular format.
  //---------------------------------------------------------------------------
  function void print_table(string msg_id = "");
    string l_msg_id = {msg_id, "[print_table]"} ;
    string l_table;
    
    l_table   =         "\n+-------------------+---------+----------+---------------------+----------------------+\n";
    l_table   = {l_table, "| Packet Start Time | Port ID | Order ID | Packet Data(1st DW) | Is Available to Send |\n"};
    l_table   = {l_table, "+-------------------+---------+----------+---------------------+----------------------+\n"};
    foreach (sorted_queue[i]) begin
      l_table = {l_table, $sformatf("| %17t | %7d | %8d | %19h | %20d |\n", sorted_queue[i].tr.PktStartTime, sorted_queue[i].port_idx, sorted_queue[i].order_id, {sorted_queue[i].tr.DataPerPktTx[3], sorted_queue[i].tr.DataPerPktTx[2], sorted_queue[i].tr.DataPerPktTx[1], sorted_queue[i].tr.DataPerPktTx[0]}, sorted_queue[i].is_available)};
    end
    l_table   = {l_table, "+-------------------+---------+----------+---------------------+----------------------+"};
    
    `uvm_info(l_msg_id, l_table, UVM_DEBUG)
  endfunction : print_table
  
  //----------------------------------------------------------------------------
  // Task: is_balanced
  //----------------------------------------------------------------------------
  function bit is_balanced();
    string l_msg_id = "is_balanced";

    if(sorted_queue.size() != 0) begin
      foreach(sorted_queue[i]) begin
        `uvm_info(l_msg_id, $sformatf("OB Merge Predictor Queues not empty. Remaining items are:\n%s", sorted_queue[i].tr.sprint()), UVM_LOW)
      end
      return 0;
    end
    
    return 1;
  endfunction : is_balanced

  //----------------------------------------------------------------------------
  // Task: is_empty
  //----------------------------------------------------------------------------
  function bit is_empty();
    return (sorted_queue.size() == 0);
  endfunction : is_empty
 
endclass : cdn_pcie_hls_bridge_hls_ob_merge_predictor

`endif // CDN_PCIE_HLS_BRIDGE_HLS_OB_MERGE_PREDICTOR_
