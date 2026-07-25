`ifndef CDN_PCIE_HLS_BRIDGE_AXI_REG_ACCESS_SEQ_SV
`define CDN_PCIE_HLS_BRIDGE_AXI_REG_ACCESS_SEQ_SV

//-----------------------------------------------------------------------------
// Sequence: cdn_pcie_hls_bridge_axi_reg_access_seq
// Description: This class contains definition of AXI register access sequence class.
//-----------------------------------------------------------------------------
class cdn_pcie_hls_bridge_axi_reg_access_seq extends cdn_axi_base_seq;

  //----------------------------------------------------------------------------
  // Helper variables
  //----------------------------------------------------------------------------
  bit ignore_address_ranges = 0;

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_axi_reg_access_seq)

  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor set default name
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_axi_reg_access_seq");
    super.new(name);
  endfunction : new

  //---------------------------------------------------------------------------
  // Task: body
  // This task sends AXI Register Access transaction
  //---------------------------------------------------------------------------
  virtual task body(); 
    fork
      // Send request
      begin 
        req = cdn_axi_base_trans::type_id::create("axi_trans");
        start_item(req);
        
        if (!req.randomize() with {
          if (ignore_address_ranges) {
            !(req.StartAddress inside {['h1f0_0000 : 'h1f0_FFFF], ['h1f2_0000 : 'h1f2_0FFF], ['h200_0000 : 'h3FF_FFFF]});
          }
          else {
            req.StartAddress inside {['h200_0000 : 'h200_1FFF], ['h202_0000 : 'h203_FFFF] , ['h300_0000 : ('h300_0000 + ('h2_0000 * parameters_cfg_pkg::NUM_AXI_PORTS) - 1)] };
          }
          }) begin
          `uvm_error(get_full_name(), "Cannot randomize AXI base transaction")
        end
        
        finish_item(req);
      end
      // Wait for response
      begin
        get_response(rsp);
      end
    join
  endtask : body
endclass : cdn_pcie_hls_bridge_axi_reg_access_seq

`endif // CDN_PCIE_HLS_BRIDGE_AXI_REG_ACCESS_SEQ_SV
`ifndef CDN_PCIE_HLS_BRIDGE_BASE_SEQ_SV
 `define CDN_PCIE_HLS_BRIDGE_BASE_SEQ_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_base_seq
//
// This sequence sets the base for all the extended test virtual sequences.
// Common functions and behavior should be part of this sequence.
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_base_seq extends uvm_sequence;

  //----------------------------------------------------------------------------
  // Common configuration
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_env_config  m_env_cfg;
  cdn_pcie_hls_bridge_scenario    m_scenario;

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Helper variables
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_base_seq)
  `uvm_declare_p_sequencer(cdn_pcie_hls_bridge_vsequencer)

  //----------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this sequence class.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_base_seq");
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
  // Task: pre_start
  // Executes the tasks required immediately after calling start method.
  //---------------------------------------------------------------------------
  virtual task pre_start();
    m_env_cfg  = p_sequencer.p_env.m_env_cfg;
    m_scenario = p_sequencer.p_scenario;
  endtask : pre_start 
  
  //---------------------------------------------------------------------------
  // Task: pre_body
  // Executes the requirements before sequence's body starts.
  //---------------------------------------------------------------------------
  virtual task pre_body();
    `uvm_info("SEQ_START", $sformatf("Starting %0s ...", get_type_name()), UVM_LOW)
  endtask : pre_body
  
  //---------------------------------------------------------------------------
  // Task: body
  // Executes the sequence's intent.
  //---------------------------------------------------------------------------
  virtual task body();
  endtask : body

  //---------------------------------------------------------------------------
  // Task: post_body
  // Executes the requirements after sequence's body ends.
  //---------------------------------------------------------------------------
  virtual task post_body();
    `uvm_info("SEQ_END", $sformatf("Ending %0s ...", get_type_name()), UVM_LOW)
  endtask : post_body

  //------------------------------------------------------------------------
  // Helper functions and tasks
  //------------------------------------------------------------------------
  
  //---------------------------------------------------------------------------
  // Task : reg_write
  // Task to write the value in specific register
  //---------------------------------------------------------------------------
  virtual task reg_write(string register_name, bit [31:0] value);
    uvm_reg       l_reg;  
    uvm_status_e  l_status;

    l_reg = p_sequencer.p_env.hls_bridge_regmodel.get_reg_by_name(register_name);
    
    if (l_reg == null)
      `uvm_error(get_type_name(), $sformatf("%0s register name not available.", register_name))

    l_reg.write(l_status, value);

    if (l_status != UVM_IS_OK) begin
      `uvm_error(get_type_name(), $sformatf("Error occured when writing %0s register.", register_name))
    end
  endtask : reg_write
  
  //---------------------------------------------------------------------------
  // Task : reg_read
  // Task to read the value of a specific uvm_reg register
  //---------------------------------------------------------------------------
  virtual task reg_read(string register_name, output bit [31:0] value);
    uvm_reg       l_reg;  
    uvm_status_e  l_status;
    bit [31:0]    l_value;

    l_reg = p_sequencer.p_env.hls_bridge_regmodel.get_reg_by_name(register_name);
    
    if (l_reg == null)
      `uvm_error(get_type_name(), $sformatf("%0s register name not available.", register_name))
    
    l_reg.read(l_status, l_value);

    if (l_status != UVM_IS_OK) begin
      `uvm_error(get_type_name(), $sformatf("Error occured when reading %0s register.", register_name))
    end

    value = l_value;

  endtask : reg_read
 
  //---------------------------------------------------------------------------
  // Task : wait_random_clk_cycles
  // Task used to wait randomly for max N clk cycles
  //---------------------------------------------------------------------------
  virtual task wait_random_clk_cycles(int unsigned max_clk_cycles = 20);
    int unsigned clk_cycles = $urandom_range(max_clk_cycles, 1);
    if ($urandom_range(1, 0)) begin
      m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(clk_cycles));
    end
  endtask : wait_random_clk_cycles

endclass : cdn_pcie_hls_bridge_base_seq

`endif // CDN_PCIE_HLS_BRIDGE_BASE_SEQ_SV
`ifndef CDN_PCIE_HLS_BRIDGE_DEV_INIT_SEQ_SV
`define CDN_PCIE_HLS_BRIDGE_DEV_INIT_SEQ_SV

//-----------------------------------------------------------------------------
// Sequence: cdn_pcie_hls_bridge_dev_init_seq
// This sequence configures the HLS Bridge Registers.
//-----------------------------------------------------------------------------
class cdn_pcie_hls_bridge_dev_init_seq extends cdn_pcie_hls_bridge_base_seq;
  
  `uvm_object_utils(cdn_pcie_hls_bridge_dev_init_seq)
  
  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_dev_init_seq");
    super.new(name);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: body
  // This task is responsible for DUT configuration
  //---------------------------------------------------------------------------
  task body();
    bit [31:0] write_data;
    
    //-- Configuring hls_bridge_cfg register -----------------------
    write_data     = 0;
    write_data[31] = m_env_cfg.m_hls_bridge_config.axi0_force_en;
    write_data[16] = m_env_cfg.m_hls_bridge_config.tfc_ro_chk_en;
    write_data[5]  = m_env_cfg.m_hls_bridge_config.addr_window_en; 
    write_data[3]  = m_env_cfg.m_hls_bridge_config.tfc_en;
    write_data[2]  = m_env_cfg.m_hls_bridge_config.vc_en;
    write_data[1]  = m_env_cfg.m_hls_bridge_config.tc_en;
    write_data[0]  = m_env_cfg.m_hls_bridge_config.idg_en;
    reg_write(.register_name("hls_bridge_cfg"), .value(write_data));

    //-- Configuring hls_bridge_tc_vc_port_map_1 register ----------
    write_data = 0;
    write_data = m_env_cfg.m_hls_bridge_config.format_hls_bridge_tc_vc_port_map_1_reg();
    reg_write(.register_name("hls_bridge_tc_vc_port_map_1"), .value(write_data));

    //-- Configuring hls_bridge_idg_port_map_1 register ------------
    write_data = 0;
    write_data = m_env_cfg.m_hls_bridge_config.format_hls_bridge_idg_port_map_1_reg();
    reg_write(.register_name("hls_bridge_idg_port_map_1"), .value(write_data));

    //-- Configuring hls_bridge_tf_port_map_value register ---------
    write_data       = 0;
    write_data[24:0] = m_env_cfg.m_hls_bridge_config.hls_bridge_tf_port_map_value;
    reg_write(.register_name("hls_bridge_tf_port_map_value"), .value(write_data));

    //-- Configuring hls_bridge_tf_port_map_mask register ----------
    write_data       = 0;
    write_data[24:0] = m_env_cfg.m_hls_bridge_config.hls_bridge_tf_port_map_mask;
    reg_write(.register_name("hls_bridge_tf_port_map_mask"), .value(write_data));

    //-- Configuring hls_bridge_tlp_start_addr_lower register ----------
    write_data = 0;
    write_data = m_env_cfg.m_hls_bridge_config.hls_bridge_tlp_start_addr[31:0];
    reg_write(.register_name("hls_bridge_tlp_start_addr_lower"), .value(write_data));

    //-- Configuring hls_bridge_tlp_start_addr_upper register ----------
    write_data = 0;
    write_data = m_env_cfg.m_hls_bridge_config.hls_bridge_tlp_start_addr[63:32];
    reg_write(.register_name("hls_bridge_tlp_start_addr_upper"), .value(write_data));

    //-- Configuring hls_bridge_tlp_end_addr_lower register ----------
    write_data = 0;
    write_data = m_env_cfg.m_hls_bridge_config.hls_bridge_tlp_end_addr[31:0];
    reg_write(.register_name("hls_bridge_tlp_end_addr_lower"), .value(write_data));

    //-- Configuring hls_bridge_tlp_end_addr_upper register ----------
    write_data = 0;
    write_data = m_env_cfg.m_hls_bridge_config.hls_bridge_tlp_end_addr[63:32];
    reg_write(.register_name("hls_bridge_tlp_end_addr_upper"), .value(write_data));

    //-- Configuring hls_bridge_msi_gic_cfg register ----------
    write_data    = 0;
    write_data[0] = m_env_cfg.m_hls_bridge_config.hls_bridge_msi_gic_use_seg;
    reg_write(.register_name("hls_bridge_msi_gic_cfg"), .value(write_data));
    
    //-- Configuring hls_bridge_dbg_order register ----------
    write_data    = 0;
    write_data[8] = m_env_cfg.m_hls_bridge_config.dbg_dis_per_port_o_chk;
    write_data[1] = m_env_cfg.m_hls_bridge_config.dbg_dis_o_chk_msi;
    write_data[0] = m_env_cfg.m_hls_bridge_config.dbg_dis_o_chk_dti;
    reg_write(.register_name("hls_bridge_dbg_order"), .value(write_data));

    m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(10)); // Additional wait time so that the register values sink in.
  endtask : body

endclass : cdn_pcie_hls_bridge_dev_init_seq

`ifndef CDN_PCIE_HLS_BRIDGE_DC_STREAM_SEQ_SV
`define CDN_PCIE_HLS_BRIDGE_DC_STREAM_SEQ_SV

//-----------------------------------------------------------------------------
// Sequence: cdn_pcie_hls_bridge_dc_stream_seq
// This class represents sequence which is used to drive Delivered Count on
// AXI Stream Interface.It gets the posted pkt from the HLS IB Posted AXI Side
// and drive delivered count after random cycles. It is extended from
// cdn_axi_stream_vip_base_seq. 
//-----------------------------------------------------------------------------
class cdn_pcie_hls_bridge_dc_stream_seq extends cdn_axi_stream_vip_base_seq;
  //----------------------------------------------------------------------------
  // Helper variables
  //----------------------------------------------------------------------------
  int unsigned                     hls_port_num;
  
  cdn_pcie_hls_bridge_vsequencer   m_top_vsqr; 

  cdn_hpa_pcie_tlp                 delivered_tlp_q[$];

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_dc_stream_seq)
  
  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_dc_stream_seq");
    super.new(name);
  endfunction : new

  //-----------------------------------------------------------------------------
  // Task: body
  //-----------------------------------------------------------------------------
  virtual task body();
    
    `uvm_info(get_type_name(), $psprintf("%s starting Stream Traffic...", get_sequence_path()), UVM_LOW)
    fork
      get_ib_posted_pkt();
      send_delivered_count();
    join
    `uvm_info(get_type_name(), $psprintf("%s ending Stream Traffic...", get_sequence_path()), UVM_LOW)
  endtask : body

  //-----------------------------------------------------------------------------
  // Task:        get_ib_posted_pkt
  // Description: Get the pkt from the TLM Port and push it into the delivered
  // queue.
  //-----------------------------------------------------------------------------
  virtual task get_ib_posted_pkt();
    cdn_hpa_pcie_tlp tlp_pkt;
    forever begin
      //- Fetch IB Posted pkt on AXI Side from the monitor --------------------------
      m_top_vsqr.m_hls_ib_posted_axi_tlp_pkt_delivered_af[hls_port_num].get(tlp_pkt);

      //-- Push it to delivered queue -----------------------------------------------
      delivered_tlp_q.push_back(tlp_pkt);
    end
  endtask : get_ib_posted_pkt

  //-----------------------------------------------------------------------------
  // Task:        send_delivered_count
  // Description: Randomly drive the delivered count for a particular port
  // after looking at the TLP Received in the queue.
  //-----------------------------------------------------------------------------
  virtual task send_delivered_count();
    bit [8:0] l_rand_delivered_count;
    int unsigned l_wait_clk_cycles;
    bit [2:0] l_id_group;

    forever begin
      //--- Wait for TLP Queue to have pkt -------------------------------------
      wait(delivered_tlp_q.size() > 0);

      //--- Wait Random Clk cycles before driving Delivered Count --------------
      l_wait_clk_cycles = $urandom_range(50, 0);  
      repeat(l_wait_clk_cycles)
        m_top_vsqr.p_env.m_env_cfg.m_misc_if_api.wait_cb();

      //--- Get IDG ID Group
      l_id_group = (parameters_cfg_pkg::LBB_SUPPORT ? delivered_tlp_q[0].hls_ib_p_np_meta_s.idgroup : 0);

      //--- Get the random Delivered Count value based on the delivered queue size -------
      l_rand_delivered_count = delivered_tlp_q.sum() with (int'(item.hls_ib_p_np_meta_s.idgroup == l_id_group));

      `uvm_info(get_type_name(), $sformatf("Processing %0d posted pkts(Delivered Count) from the delivered_tlp_q of size: %0d on Port: %0d.", l_rand_delivered_count, delivered_tlp_q.size(), hls_port_num), UVM_DEBUG)

      //--- Deleting pkts from the queue which are delivered -------
      for(int i=delivered_tlp_q.size()-1; i>=0 ; i--)
        if (delivered_tlp_q[i].hls_ib_p_np_meta_s.idgroup == l_id_group)
          delivered_tlp_q.delete(i);
      
      //--- Drive the random delivered count on the Stream VIP ------------
      fork
        begin
          stream_trans = denaliStreamTransaction::type_id::create("stream_trans");
          start_item(.item(stream_trans), .sequencer(p_sequencer));
          
          if (!stream_trans.randomize() with {
            stream_trans.StreamKind   == DENALI_STREAM_KIND_BYTE;
            stream_trans.DataBusSize  == databus_size_bytes;
            stream_trans.Length       == 1;
            stream_trans.ChannelDelay == 'd0;
            stream_trans.TransfersChannelDelay.size() == stream_trans.Length;
            foreach(stream_trans.TransfersChannelDelay[i]) {
              stream_trans.TransfersChannelDelay[i] == 0;
            }
            stream_trans.PacketData[1][7:4] == 0;
            stream_trans.PacketData[1][3:1] == l_id_group;
            stream_trans.PacketData[1][0]   == l_rand_delivered_count[8];
            stream_trans.PacketData[0][7:0] == l_rand_delivered_count[7:0];
          }) begin
            `uvm_fatal(get_type_name(), "Stream Transaction Randomization failed...")
          end

          finish_item(stream_trans);
        end
        begin
          get_response(stream_trans);
        end
      join

    end
  endtask : send_delivered_count

endclass : cdn_pcie_hls_bridge_dc_stream_seq

`endif // CDN_PCIE_HLS_BRIDGE_DC_STREAM_SEQ_SV
