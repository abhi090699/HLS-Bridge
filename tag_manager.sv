
`ifndef CDN_PCIE_HPA_TAG_MANAGER_SV 
`define CDN_PCIE_HPA_TAG_MANAGER_SV

//-----------------------------------------------------------------------------
// Class: cdn_pcie_hpa_tag_manager 
// Description: Since HPA TLP is used to generate the TLPs, for NP Packets 
// we need a mechanism to track the generated tags along with the respective 
// CPLs. 
// 1) Tag manager generates the TAGs
// 2) Release a TAG when a CPL is rcvd.(For now From VIP, In top level from HLS
// 3) Block the TLP generation when Tags are not available
//    (So that sequence does not require to track)
// 4) TAG generation options - this is static per simulation 
//   a) Sequential increment 
//   b) Sequential decrement
//   c) Random Tags
//   d) Least recent used tags and complete the exiting tags and reuse option
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
class cdn_pcie_hpa_tag_manager extends cdnpcie_component;

  //------------------------------------------------------------------------
  // CONTROL KNOBS
  //------------------------------------------------------------------------
  cdn_pcie_strap_top_config   m_pcie_strap_cfg;
  cdn_pcie_hpa_dev_top_config m_pcie_dev_top_cfg;
  cdn_pcie_hpa_dev_top_config m_pcie_vip_top_cfg;
  cdn_hpa_pcie_dev_config     dev_cfg;
  int  max_tags = 32;
  int  m_available_tags[$];
  int  m_possible_tags[$];
  int  m_flred_tags[$];
  int  m_consumed_tags[$];
  int  m_discarded_tags[$];
  int  m_released_tag[int];
  int  m_released_tag_by_flr[int];
  int  m_released_tag_by_cpl_TO[int];
  int  tag_indx_to_be_deleted[$];
  int  rnd_tag_sel;
  bit  tag_exhausted;

  bit asscending_order;
  bit random_tags;

  bit tag_manager_8_bit;
  bit tag_manager_10_bit;
  bit tag_manager_14_bit;
  bit uio_tag_manager_bit;
  bit link_side;

  int m_tagM_timeout = 1;
  
  int m_time_10us   = 10;
  int m_time_100us  = 100;
  int m_time_1000us = 1000;
  int unsigned m_lut_item_update_latency = 0;

  int hls_ib_compl_received_count;

  int np_tlp_count;
  int np_tlp_freq = 20;

  semaphore cxs2tlp_np_seq_in_progress;

  //-----------------------------------------------------------------------------
  // Field: m_num_hls_ports 
  // Number of HLS Ports. 
  //-----------------------------------------------------------------------------
  int unsigned m_num_hls_ports = 1;
  
  //-----------------------------------------------------------------------------
  // Field: m_enable_pkt_gaps
  // Flag to Enable pkt gaps in a CXS Flit. 
  //-----------------------------------------------------------------------------
  bit m_enable_pkt_gaps = 0;

  // LUT with tag as the key
  cdn_pcie_hpa_compl_wrapper  compl_lut_obj;
  cdn_hpa_pcie_cfg_info_t     m_cfg_info; 
  //cdn_pcie_hpa_compl_lut_item compl_lut[int];
  cdn_hpa_pcie_tlp            np_req_q[$];

  lut_item_lite_t             m_tl2hls_cpl_item[bit[13:0]];

  cdnpcie_sequencer           dev_seqr;
  //------------------------------------------------------------------------
  // TLM Ports.
  //------------------------------------------------------------------------
  `uvm_analysis_imp_decl(_ob_np_req_cbport)
  uvm_analysis_imp_ob_np_req_cbport #(cdn_hpa_pcie_tlp, cdn_pcie_hpa_tag_manager) ob_np_req_cbport_export;

  `uvm_analysis_imp_decl(_ib_compl_cbport)
  uvm_analysis_imp_ib_compl_cbport #(cdn_hpa_pcie_tlp, cdn_pcie_hpa_tag_manager) ib_compl_cbport_export;

  `uvm_analysis_imp_decl(_tl2hls_compl_cbport)
  uvm_analysis_imp_tl2hls_compl_cbport #(cdn_hpa_pcie_tlp, cdn_pcie_hpa_tag_manager) tl2hls_compl_cbport_export;

  `uvm_analysis_imp_decl(_tl2hls_np_cbport)
  uvm_analysis_imp_tl2hls_np_cbport #(cdn_hpa_pcie_tlp, cdn_pcie_hpa_tag_manager) tl2hls_np_cbport_export;

  uvm_analysis_port #(cdn_hpa_pcie_tlp) ib_exp_compl_to_flr_req_ap;
  
  uvm_analysis_port #(cdn_hpa_pcie_tlp) dpc_ib_compl_req_ap;


  //------------------------------------------------------------------------
  // STATUS MEMBER VARIABLES
  //------------------------------------------------------------------------
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  //------------------------------------------------------------------------
  // EVENTS
  //------------------------------------------------------------------------
  uvm_event_pool      event_pool;
  uvm_event           flr_received;
  uvm_event           linkdown_received;
  uvm_event           tag_discarded;
  bit                 reset_in_progress;


  //------------------------------------------------------------------------
  // COMPONENTS
  //------------------------------------------------------------------------
  cdnCxsUvmSequencer      m_ob_np_cxs_sqr[][];
  cdn_hpa_pcie_tlp_vseqr  m_ob_np_tlp_sqr[];

  cdn_pcie_hpa_tlp2cxs_seq tlp2cxs_np_seq[];
  cdn_pcie_tl_sequences_pkg::cdn_hpa_pcie_tlp_queue_t tlp_q;

  //---------------------------------------------------------------------------
  // Field: misc_if
  // Points the misc if of HLS module TB
  //---------------------------------------------------------------------------
  virtual cdn_pcie_hpa_misc_if   misc_if;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hpa_tag_manager)

  //------------------------------------------------------------------------
  // CHECKER FIELDS FOR COVERAGE OF CHECKERS
  //------------------------------------------------------------------------
  //TODO:: aditya2 vplan item - 2.11.2 - add coverage for completion timeout here
  //TODO:: aditya2 vplan item - 2.11.8 - Tag reuse post compeltion timeout 
  `cg__generic_seen_(normal_tag_reuse)
  `cg__generic_seen_(flred_tag_reuse)
  `cg__generic_seen_(cpl_timeout_tag_reuse)
  //------------------------------------------------------------------------
  // BACK POINTERS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // METHODS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // DEFINE TASKS
  //------------------------------------------------------------------------

  // This function returns 1 if tags are avialble
  virtual function bit is_tags_availabe();
  endfunction

  // This function returns no of tags avialble
  virtual function int num_tags_availabe();
  endfunction

  //------------------------------------------------------------------------
  // Task: main_phase
  // The main_phase task for this class will be started automatically during
  // the run phase.
  //------------------------------------------------------------------------
  virtual task main_phase(uvm_phase phase);

    super.main_phase(phase);

    //Create the event pool here since this method returns the unique instance
    event_pool = uvm_event_pool::get_global_pool();

    asscending_order = 1;
    random_tags      = 0;

    flr_received      = event_pool.get("flr_received");
    linkdown_received = event_pool.get("linkdown_received");
    tag_discarded     = event_pool.get("tag_discarded");

    cxs2tlp_np_seq_in_progress = new(1);

    reset_tag_pool();

    fork 
      begin
        if(is_active == UVM_ACTIVE)
          generate_tag();
        else	
          process_tag();
      end
      begin
        if(link_side==0)
          monitor_flr();
      end
      begin
        completion_tag_discard();
      end
      begin
        if(link_side==0) dpc_rp_extension_cpl_monitor();
      end
    join_none  

  endtask : main_phase

  //------------------------------------------------------------------------
  // Task: start_bg_seqs 
  // Start all the CXS sequneces on the corrsponding CXS sequeners
  //------------------------------------------------------------------------
  virtual task start_bg_seqs();
    reset_in_progress = 0;
    for (int i = 0; i< m_pcie_strap_cfg.k_num_cifs; i++) begin
      fork
        automatic int unsigned idx = i;
        tlp2cxs_np_seq[idx] = cdn_pcie_hpa_tlp2cxs_seq::type_id::create($sformatf("tlp2cxs_np_seq[%1d]", idx));
        tlp2cxs_np_seq[idx].m_num_hls_ports = m_num_hls_ports;
        tlp2cxs_np_seq[idx].p_cxs_sqr       = new[m_num_hls_ports];

        for (int j = 0; j < m_num_hls_ports; j++) begin 
          automatic int unsigned idx_hls_port = j;
          if(!$cast(tlp2cxs_np_seq[idx].p_cxs_sqr[idx_hls_port], m_ob_np_cxs_sqr[idx][idx_hls_port]))
            `uvm_fatal(get_type_name(), "Cast failed !!")
        end

        if(!$cast(tlp2cxs_np_seq[idx].p_tlp_sqr, m_ob_np_tlp_sqr[idx]))
          `uvm_fatal(get_type_name(), "Cast failed !!")

        tlp2cxs_np_seq[idx].m_pcie_dev_top_cfg = m_pcie_dev_top_cfg; 
        tlp2cxs_np_seq[idx].misc_if = misc_if; 

        if(m_pcie_dev_top_cfg.scenario != null) begin
          tlp2cxs_np_seq[idx].m_pkt_err_en = m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror;
          if(m_pcie_strap_cfg.k_hls_dw_alignment == 2)
            tlp2cxs_np_seq[idx].m_pkt_gap_en = m_enable_pkt_gaps;
        end

        if(m_pcie_dev_top_cfg.hls_rx)
          tlp2cxs_np_seq[idx].m_num_tlps_per_clk = m_pcie_strap_cfg.k_rx_num_tlps_per_clk;
        else
          tlp2cxs_np_seq[idx].m_num_tlps_per_clk = m_pcie_strap_cfg.k_tx_num_tlps_per_clk;

        tlp2cxs_np_seq[idx].start(dev_seqr, null, -1); // Not required any sequencer
      join_none
    end
  endtask : start_bg_seqs 

  //------------------------------------------------------------------------
  // Task: kill_seq  
  // kill all the bg seqs in reset 
  //------------------------------------------------------------------------
  virtual function void kill_seq();

    if(is_active == UVM_ACTIVE) begin
      for (int i = 0; i< m_pcie_strap_cfg.k_num_cifs; i++) begin
        `uvm_info(get_full_name(), $psprintf("RESET_AWARE: Killing sub sequences for CIF %0d", i), UVM_DEBUG)
        m_ob_np_tlp_sqr[i].stop_sequences();
        for (int j = 0; j < m_num_hls_ports; j++) begin 
          automatic int unsigned idx_hls_port = j;
          m_ob_np_cxs_sqr[i][idx_hls_port].stop_sequences();
        end
        tlp2cxs_np_seq[i].kill();
      end
    end
  endfunction


  virtual function void reset_tag_pool();
    bit [13:0] init_tag;
    bit [13:0] temp_tag; 

    m_available_tags = {};
    m_flred_tags = {};
    m_possible_tags  = {};
    m_consumed_tags = {};
    m_discarded_tags = {};
    m_released_tag.delete();
    m_released_tag_by_cpl_TO.delete();
    m_released_tag_by_flr.delete();
    tag_indx_to_be_deleted = {};

    if(tag_manager_8_bit || uio_tag_manager_bit) begin
      init_tag = 0;
    end else if (tag_manager_10_bit) begin
      init_tag = 256;
    end else if (tag_manager_14_bit) begin
      init_tag = 1024;
    end

    for (int i= init_tag; i < max_tags ; i++) begin
      if(asscending_order) begin
        if(m_pcie_dev_top_cfg.scenario != null) begin
          m_available_tags.push_back(i);
        end
        else
          m_available_tags.push_back(i); 
      end  
      else begin
        if(m_pcie_dev_top_cfg.scenario != null) begin
          m_available_tags.push_back(max_tags-i-1); 
        end
        else
          m_available_tags.push_back(max_tags-i-1);
      end
      m_consumed_tags = {};
    end  
    tag_exhausted = 0;
  endfunction

  //----------------------------------------------------------------------------
  // Function: reset
  //----------------------------------------------------------------------------
  function void reset();
    reset_in_progress=1;
    fork 
      begin
      if(!(misc_if.immediate_link_down && ~misc_if.dpc_triggered))
        wait(misc_if.link_down_handling_in_progress==0);         
        reset_tag_pool();  
        np_req_q = {};
        compl_lut_obj.tag_corrupted_q = {};
        foreach (compl_lut_obj.compl_lut[tag])
          compl_lut_obj.compl_lut.delete(tag);

        if(cxs2tlp_np_seq_in_progress.try_get()) begin
          cxs2tlp_np_seq_in_progress.put();
        end
        else begin
          cxs2tlp_np_seq_in_progress.put();
        end
      end
    //post_link_down_reset();
    join_none

  endfunction : reset

  function set_reset_in_progress();
    reset_in_progress=1;
  endfunction

  virtual task post_link_down_reset();
    wait(misc_if.link_down_handling_in_progress==0);
    reset_in_progress=0;    
  endtask

  //----------------------------------------------------------------------------
  // Function: wait_tags_empty 
  // This function will be called in dev_vseq at the end of traffic
  // to make sure there are no OB NP traffic still waiting for completion
  //----------------------------------------------------------------------------
  virtual task wait_tags_empty();
    `uvm_info(get_full_name(),$psprintf("wait_tags_empty :: waiting for consumed tags to be empty: m_consumed_tags = %0p ", m_consumed_tags),UVM_LOW)
    fork
      begin
        while(m_consumed_tags.size() != 0) begin
          `uvm_info(get_full_name(),$psprintf("wait_tags_empty :: waiting for consumed tags to be empty: m_consumed_tags = %0p ", m_consumed_tags),UVM_LOW)
          hpa_timer.wait_for_time(m_time_10us, "wait_consumed_tags_empty", "us");
        end
        `uvm_info(get_full_name(),$psprintf("wait_tags_empty :: consumed tags are empty: m_consumed_tags = %0p ", m_consumed_tags),UVM_LOW)
      end
      
      begin
        hpa_timer.wait_for_time(m_time_1000us, "consumed_tags_empty_timeout", "us");
        if(m_consumed_tags.size() != 0) 
          `uvm_warning(get_full_name(),$psprintf("wait_tags_empty :: consumed tags are not empty: m_consumed_tags = %0p ", m_consumed_tags))
      end
    join_any
  endtask : wait_tags_empty 

  //------------------------------------------------------------------------
  // Task: check_phase
  // Extend the check function so that the status of the monitor is checked.
  //------------------------------------------------------------------------
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
  endfunction : check_phase


  //------------------------------------------------------------------------
  // UTILITY METHODS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------
  virtual task generate_tag();
    cdn_hpa_pcie_tlp np_req;

    forever begin
      wait(reset_in_progress==0);
      fork begin // fork_guard
        fork
          begin
            //if(misc_if.immediate_link_down==0) 
        `uvm_info(get_full_name(),$psprintf("DEBUG 1"),UVM_LOW)
            if(!(misc_if.immediate_link_down && ~misc_if.dpc_triggered))
              wait(misc_if.link_down_handling_in_progress==0);
        `uvm_info(get_full_name(),$psprintf("DEBUG 2"),UVM_LOW)
            hpa_timer.wait_for_time(2, "sync_seqstart_post-linkdown", "ns"); // to synchronize reset of np_req_q
        `uvm_info(get_full_name(),$psprintf("DEBUG 3"),UVM_LOW)
            wait(np_req_q.size() >0);
        `uvm_info(get_full_name(),$psprintf("DEBUG 4"),UVM_LOW)
            np_req = np_req_q.pop_front();
        `uvm_info(get_full_name(),$psprintf("DEBUG 5"),UVM_LOW)
  
            gen_req(np_req, m_ob_np_tlp_sqr, tlp2cxs_np_seq);
        `uvm_info(get_full_name(),$psprintf("DEBUG 6"),UVM_LOW)
          end
          begin
        `uvm_info(get_full_name(),$psprintf("DEBUG 7"),UVM_LOW)
            wait(reset_in_progress==1);
        `uvm_info(get_full_name(),$psprintf("DEBUG 8"),UVM_LOW)
            // To ensure item_done is done before killing start_item and finish_item theread in gen_req()
            //hpa_timer.wait_for_delay_1ps();
            cxs2tlp_np_seq_in_progress.get();
            cxs2tlp_np_seq_in_progress.put();
            //wait(tlp2cxs_np_seq[curr_tlp_cif].job.status != null);
            //if (tlp2cxs_np_seq[curr_tlp_cif].job.status != process::FINISHED )
            //  tlp2cxs_np_seq[curr_tlp_cif].job.kill();
        `uvm_info(get_full_name(),$psprintf("DEBUG 9 "),UVM_LOW)
          end
        join_any
        disable fork;
      end join
    end
  endtask : generate_tag

  
  virtual task gen_req(cdn_hpa_pcie_tlp req, cdn_hpa_pcie_tlp_vseqr tlp_sqr[], cdn_pcie_hpa_tlp2cxs_seq tlp2cxs_seq[]);
    int curr_tlp_cif;
    int qi[$];
    int indx[$];
    int tag_idx_count;
    // reg [7:0]  temp_payload[4];
    int unique_id;
    bit [13:0] l_tag;

    fork // Dummy fork to disable one of the below threads
      begin
        fork 
          begin

            // Identify the dev_cfg corresponding to req
            // If ext_tag_en & non_10_bit_tag_mgr then pick any value of tag [0:max_np_record_value]
            // If !ext_tag_en & non_10_bit_tag_mgr then pick [0:31]
            // if 10_bit_tag_en & 10_bit_mgr : any value [256:max_np_record_value]
            dev_cfg = m_pcie_dev_top_cfg.get_pf_vf_dev_cfg_from_req_id(req.m_tlp_requester_id);
            foreach(req.vip_userdata.m_error_injects[i]) begin
              if(req.vip_userdata.m_error_injects[i] == CDN_HPA_PCIE_TLP_ACS_SOURCE_VALIDATION_ERR) dev_cfg = m_pcie_dev_top_cfg.pf_config[0];
            end
            `uvm_info("DBG_TAG_MGR",$psprintf("For req(req_id=%0h), decoded PF=%0h VF=%0h ext_tag_en=%0d",req.m_tlp_requester_id,dev_cfg.m_pf_num, dev_cfg.m_vf_num,dev_cfg.m_ext_tag_en),UVM_HIGH);
            m_possible_tags = {};

            //`uvm_info(get_full_name(), $psprintf(" non_tag_manager_10_bit=%0d dev_cfg.m_ext_tag_en=%0d max_tags=%0d Availble tags %p",non_tag_manager_10_bit, dev_cfg.m_ext_tag_en,max_tags, m_available_tags), UVM_DEBUG)
            //`uvm_info(get_full_name(), $psprintf("possible tags %p", m_possible_tags), UVM_DEBUG)
            do begin
              wait(m_available_tags.size > 0);
              if((tag_manager_8_bit) && (!dev_cfg.m_ext_tag_en)) begin
                m_possible_tags = m_available_tags.find(item) with (item <32);
              end else begin
                m_possible_tags = m_available_tags.find(item) with (item < max_tags);
              end
		          if(m_pcie_strap_cfg.scenario != null) begin
					      if(!m_pcie_strap_cfg.scenario.m_is_perf_mode) // If not perfromance mode
                    hpa_timer.wait_for_delay_1ps();
	            end		 
					    else begin // If no scenario like HLS TB
                  hpa_timer.wait_for_delay_1ps();
					    end

              //deleting corrupted tags from the possible tag queue
              //so that they are not used in any of the requests.
              if((m_possible_tags.size() > 0) && (compl_lut_obj.tag_corrupted_q.size() > 0)) begin
                foreach(m_possible_tags[i])
                begin
                  qi = compl_lut_obj.tag_corrupted_q.find_index(x) with (x == m_possible_tags[i]);
                  if(qi.size() > 0) begin
                    tag_indx_to_be_deleted.push_back(i);
                  end
                end

                //foreach(tag_indx_to_be_deleted[i]) begin
                //  m_possible_tags.delete(tag_indx_to_be_deleted[i]);
                //end

                tag_idx_count = tag_indx_to_be_deleted.size()-1;
                for(int tag_idx=tag_idx_count; tag_idx>=0; tag_idx--)
                  m_possible_tags.delete(tag_indx_to_be_deleted[tag_idx]);
                tag_indx_to_be_deleted = {};
              end

            end while ((m_possible_tags.size==0) || (m_possible_tags.size <= m_pcie_dev_top_cfg.discard_the_cpl_to_tags_in_ob.size));
            //l_tag = m_possible_tags.pop_front(); 
            //Randomize and pick any random tag
            if(m_pcie_dev_top_cfg.scenario!=null) begin
              if(m_pcie_dev_top_cfg.scenario.m_enable_ob_tag_already_used_err) begin
                assert(std::randomize(rnd_tag_sel) with {rnd_tag_sel inside {[0:m_consumed_tags.size()-1]};});
                l_tag = m_consumed_tags[rnd_tag_sel];
              end
              else begin
                assert(std::randomize(rnd_tag_sel) with {rnd_tag_sel inside {[0:m_possible_tags.size()-1]};
                                                         if(m_pcie_dev_top_cfg.discard_the_cpl_to_tags_in_ob.size !=0) {
                                                         !(m_possible_tags[rnd_tag_sel] inside {m_pcie_dev_top_cfg.discard_the_cpl_to_tags_in_ob});}
                                                        });
                l_tag = m_possible_tags[rnd_tag_sel];
                if(m_pcie_vip_top_cfg.drop_active_bfm_tx_cpl_tlps) begin
                 m_pcie_dev_top_cfg.discard_the_cpl_to_tags_in_ob.push_back(l_tag);
                 `uvm_info("DEBUG_DISC_TAG",$psprintf("drop_active_bfm_tx_cpl_tlps=1. Hence addding tag='h%0h['d%0d] to queue discard_the_cpl_to_tags_in_ob",l_tag,l_tag),UVM_LOW)
                end
                if(m_flred_tags.size()) begin
                  assert(std::randomize(rnd_tag_sel) with {rnd_tag_sel inside {[0:m_flred_tags.size()-1]};});
                  l_tag = m_flred_tags[rnd_tag_sel];
                  `uvm_info(get_full_name(), $psprintf("l_tag %d", l_tag), UVM_DEBUG)
                  `uvm_info(get_full_name(), $psprintf("FLRed tags %p", m_flred_tags), UVM_DEBUG)
                  indx = m_flred_tags.find_index(item) with (item == l_tag);
                  m_flred_tags.delete(indx[0]);
                end
                //Delete the tag from available queue
                // CDN_HPA_PCIE_TLP_TYPE_UIOMWr can use the same tag for multiple transactions
                // Only for IB, TODO enable for OB after PCIE-21893 will be resolved
                if (!(req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr && link_side)) begin
                  indx = m_available_tags.find_index(item) with (item == l_tag);
                  m_available_tags.delete(indx[0]);
                end
              end
            end
            else begin
              assert(std::randomize(rnd_tag_sel) with {rnd_tag_sel inside {[0:m_possible_tags.size()-1]};
                                                       if(m_pcie_dev_top_cfg.discard_the_cpl_to_tags_in_ob.size !=0) {
                                                       !(m_possible_tags[rnd_tag_sel] inside {m_pcie_dev_top_cfg.discard_the_cpl_to_tags_in_ob});}
                                                         });
              l_tag = m_possible_tags[rnd_tag_sel];
              if(m_pcie_vip_top_cfg.drop_active_bfm_tx_cpl_tlps) begin
               m_pcie_dev_top_cfg.discard_the_cpl_to_tags_in_ob.push_back(l_tag);
               `uvm_info("DEBUG_DISC_TAG",$psprintf("drop_active_bfm_tx_cpl_tlps=1. Hence addding tag=%0h to queue discard_the_cpl_to_tags_in_ob",l_tag),UVM_LOW)
              end
              if(m_flred_tags.size()) begin
                assert(std::randomize(rnd_tag_sel) with {rnd_tag_sel inside {[0:m_flred_tags.size()-1]};});
                l_tag = m_flred_tags[rnd_tag_sel];
                `uvm_info(get_full_name(), $psprintf("l_tag %d", l_tag), UVM_DEBUG)
                `uvm_info(get_full_name(), $psprintf("FLRed tags %p", m_flred_tags), UVM_DEBUG)
                indx = m_flred_tags.find_index(item) with (item == l_tag);
                m_flred_tags.delete(indx[0]);
              end
              //Delete the tag from available queue
              // CDN_HPA_PCIE_TLP_TYPE_UIOMWr can use the same tag for multiple transactions
              // Only for IB, TODO enable for OB after PCIE-21893 will be resolved
              if (!(req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr && link_side)) begin
                indx = m_available_tags.find_index(item) with (item == l_tag);
                m_available_tags.delete(indx[0]);
              end
            end

            `uvm_info(get_full_name(), $psprintf("Available tags %p", m_available_tags), UVM_DEBUG)
            `uvm_info(get_full_name(), $psprintf("possible tags %p", m_possible_tags), UVM_DEBUG)
            `uvm_info(get_full_name(), $psprintf("discard_the_cpl_to_tags_in_ob tags %p",  m_pcie_dev_top_cfg.discard_the_cpl_to_tags_in_ob), UVM_DEBUG)
            if(m_available_tags.size==0)
                tag_exhausted = 1;
          end
          begin
            //hpa_timer.wait_for_time(m_time_1000us, "tag_manager_timeout", "us");
            hpa_timer.wait_for_time(m_tagM_timeout, "tag_manager_timeout", "ms");
            `uvm_fatal(get_full_name(), $sformatf("Tag Manager timeout failed (%0d us)!!!", m_tagM_timeout))
          end
          begin
            forever begin
              hpa_timer.wait_for_time(m_time_100us, "wait_for_tags_available", "us");
              `uvm_info(get_full_name(), "Tag Manager: No tags available for sending",UVM_NONE)
            end
          end
        join_any
        disable fork;
      end  
    join
          
    qi = m_discarded_tags.find_index(x) with (x == l_tag);
    if(qi.size() > 0)
    begin
      m_discarded_tags.delete(qi[0]);
      `uvm_info(get_full_name(), $psprintf("discarded tags %p", m_discarded_tags), UVM_DEBUG)
    end
    if (!(req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr && link_side && l_tag inside {m_consumed_tags})) begin
      m_consumed_tags.push_back(l_tag);
    end
    `uvm_info(get_full_name(), $psprintf("consumed tags %p", m_consumed_tags), UVM_DEBUG)

    if(m_released_tag_by_cpl_TO.exists(l_tag)) begin
      //sample cpl TO tag roll over
      cg__generic_seen_cpl_timeout_tag_reuse.sample(1);
    end
    if(m_released_tag_by_flr.exists(l_tag)) begin
      //sample flred tag roll over
      cg__generic_seen_flred_tag_reuse.sample(1);
    end
    if(m_released_tag.exists(l_tag)) begin
      //sample normal tag roll over
      cg__generic_seen_normal_tag_reuse.sample(1);
    end

    if(m_pcie_dev_top_cfg.scenario.is_ucie_mode && m_pcie_dev_top_cfg.is_dut_dut_tb) begin
      if(unique_id != 0 && dev_cfg.map_unique_id_to_tag[unique_id] == dev_cfg.exp_cpl_np_tag)
      begin
        `uvm_info(get_name(),$psprintf("tag = %0d, unique_id = %0d", dev_cfg.exp_cpl_np_tag, unique_id),UVM_HIGH)
      end
      else
      begin
        foreach(dev_cfg.map_unique_id_to_tag[i])
        begin
          `uvm_info(get_name(),$psprintf("dev_cfg.map_unique_id_to_tag[%0d]= 'h%0h", i,dev_cfg.map_unique_id_to_tag[i]),UVM_HIGH)
          if(dev_cfg.map_unique_id_to_tag[i] == dev_cfg.exp_cpl_np_tag)
          begin
            unique_id = i;
            `uvm_info(get_name(),$psprintf("tag = %0d, unique_id = %0d", dev_cfg.exp_cpl_np_tag, unique_id),UVM_HIGH);
            break;
          end
        end
      end
    end

    // Assign the tag to NP request
    {req.m_tlp_14_bit_tagscale, req.m_tlp_tagscale, req.m_tlp_tag}  = l_tag;
    {req.m_tlp_t9, req.m_tlp_t8 } = req.m_tlp_tagscale; 

    // As tag value is changed need to update the byte array also
    // so call pack_bytes
    void'(req.pack_bytes(req.m_data));
    //`uvm_info(get_name(),$psprintf("DEBUG_PTH %p", req.m_data),UVM_HIGH)

    //Recompute ECRC post tag update
    `ifdef HPA_ARCH2
      req.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
    `endif
    if(m_pcie_dev_top_cfg.scenario.is_ucie_mode && m_pcie_dev_top_cfg.is_dut_dut_tb) begin
    /*if(req.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgWr0, CDN_HPA_PCIE_TLP_TYPE_CfgWr1})
    begin
    temp_payload[0] = req.m_tlp_payload[3];
    temp_payload[1] = req.m_tlp_payload[2];
    temp_payload[2] = req.m_tlp_payload[1];
    temp_payload[3] = req.m_tlp_payload[0];
    foreach(temp_payload[i]) req.m_tlp_payload[i] = temp_payload[i];
    end*/

      `uvm_info("DBG_TAG_MGR",$psprintf("After tag modification to 'h%0h['d%0d], NP req is %0s",l_tag,l_tag,req.sprint()),UVM_HIGH)
      dev_cfg.exp_cpl_np_tag  = l_tag;
      dev_cfg.map_unique_id_to_tag[unique_id] = l_tag;

    end
    
    req.m_cfg_info   = m_cfg_info;

    generate_compl_lut_item(req);

    curr_tlp_cif = m_pcie_dev_top_cfg.tc_to_cif(req.m_tlp_tc); 

    cxs2tlp_np_seq_in_progress.get();
    tlp2cxs_seq[curr_tlp_cif].start_item(req, -1, tlp_sqr[curr_tlp_cif]);
    // No randomization as it is conversion sequnce
    tlp2cxs_seq[curr_tlp_cif].finish_item(req);
    cxs2tlp_np_seq_in_progress.put();

  endtask : gen_req


  //------------------------------------------------------------------------
  // Method: process_tag 
  // This method is used in AXI Bridge mode to update the available tags in passive mode
  //------------------------------------------------------------------------
  virtual task process_tag();
    int np_indx[$];
    cdn_hpa_pcie_tlp np_req;

    forever begin
      wait(np_req_q.size() >0);
      np_req = np_req_q.pop_front();
      `uvm_info("process_tag", $sformatf("np_req = %0s", np_req.sprint()), UVM_LOW)
      //Delete the tag from available queue
      np_indx = m_available_tags.find_index(item) with (item == {np_req.m_tlp_14_bit_tagscale,np_req.m_tlp_tagscale, np_req.m_tlp_tag});
      m_available_tags.delete(np_indx[0]);
      m_consumed_tags.push_back({np_req.m_tlp_14_bit_tagscale,np_req.m_tlp_tagscale, np_req.m_tlp_tag});
      `uvm_info("process_tag", $sformatf("m_consumed_tags = %0p", m_consumed_tags), UVM_LOW)
      generate_compl_lut_item(np_req);
      // TODO - Do we need to consider discarded tags in passive mode
    end			
  endtask
	
  //------------------------------------------------------------------------
  // Method: dpc_rp_extension_cpl_monitor
  // The below process monitors the DPC event and forms the dummy completions
  // based on DPC RP Extension and DPC Compl Control and send to score board
  //------------------------------------------------------------------------
  virtual task dpc_rp_extension_cpl_monitor();
    cdn_pcie_hpa_compl_lut_item item[$];
    cdn_pcie_hpa_compl_lut_item discard_item;
    int sent_pkt_count;
    int pipeline_pkt_count;
    bit[13:0] discarded_tag;
    
    if(m_pcie_dev_top_cfg.pf_config[0].dpc_rp_extension == 0) begin
      return;
    end
    fork
      begin
        forever begin
          wait(!misc_if.dpc_triggered);
          for(int i=0; i<KMAX_NUM_TLPS_PER_CLK; i++) begin
            //if(misc_if.hls_header_splitter_ready && misc_if.hls_header_splitter_valid && misc_if.hls_inpipeline_packet[i]) sent_pkt_count++;
            if(misc_if.hls_header_splitter_ready && misc_if.hls_header_splitter_valid && misc_if.hls_inpipeline_packet[i]) begin 
              sent_pkt_count++;
              `uvm_info(get_name(),$psprintf("DPC Completions - Tag Manager : sent_pkt_count = %0d", sent_pkt_count), UVM_LOW)
            end
          end
          @(negedge misc_if.core_clk);
        end
      end
     begin
        forever begin
          wait(misc_if.dpc_triggered);
          @(posedge misc_if.discard_for_dpc);
          @(negedge misc_if.core_clk);
          discarded_tag = {misc_if.dpc_disard_header[55:50],misc_if.dpc_disard_header[63:56]}; 
          `uvm_info(get_type_name(), $psprintf("discarded_tag=%h, misc_if.dpc_disard_header[63:50]=%h", discarded_tag,misc_if.dpc_disard_header[63:50]), UVM_DEBUG)
          `uvm_info(get_name(),$psprintf("Generating UR CPL for DPC discarded request"), UVM_LOW)
          discard_item = compl_lut_obj.compl_lut[discarded_tag];
          if(discard_item != null) begin
            `uvm_info(get_name(),$psprintf("DPC discarded requests when DPC Triggered are %0s", discard_item.sprint()), UVM_LOW)
            generate_compl_for_dpc_outstanding_req(discard_item, 0); 
          end
        end
      end
      begin
        forever begin
          wait(misc_if.dpc_triggered);
          repeat(2) @(posedge misc_if.core_clk);
          item = {};
          pipeline_pkt_count = sent_pkt_count - hls_ib_compl_received_count;

          foreach(compl_lut_obj.compl_lut[i]) item.push_back(compl_lut_obj.compl_lut[i]);
          item.sort( x ) with (x.time_in_tag_m); 
          `uvm_info(get_name(),$psprintf("DPC Completions - Tag Manager : sent_pkt_count = %0d, pipeline_pkt_count = %0d, hls_ib_compl_received_count = %0d, item.size() = %0d", sent_pkt_count, pipeline_pkt_count, hls_ib_compl_received_count, item.size()), UVM_LOW)
          foreach(item[i]) begin
            `uvm_info(get_name(),$psprintf("Out stadnding requests when DPC Triggered are %0s", item[i].sprint()), UVM_LOW)
            `uvm_info(get_name(),$psprintf("Generating CPL for this Request"), UVM_LOW)
            `uvm_info(get_name(),$psprintf("DPC Completions - Tag Manager : pipeline_pkt_count = %0d", pipeline_pkt_count), UVM_LOW)
            generate_compl_for_dpc_outstanding_req(item[i], pipeline_pkt_count);
            if(pipeline_pkt_count > 0) pipeline_pkt_count--;
          end
          wait(!misc_if.dpc_triggered);
          sent_pkt_count = 0;
          hls_ib_compl_received_count = 0;
          foreach (compl_lut_obj.compl_lut[tag])
            compl_lut_obj.compl_lut.delete(tag);        
        end  
      end
    join
      
  endtask

  virtual task generate_compl_for_dpc_outstanding_req(input cdn_pcie_hpa_compl_lut_item item, int pipeline_pkt_count);
    cdn_hpa_pcie_tlp     pcie_cpl_trans;
    cdn_pcie_hpa_pf_vf_s m_pf_vf;
    bit [6:0]            lower_addr;
    bit [13:0]           l_tag;

    l_tag = {item.pcie_np_req.m_tlp_14_bit_tagscale, item.pcie_np_req.m_tlp_t9, item.pcie_np_req.m_tlp_t8, item.pcie_np_req.m_tlp_tag};

    hpa_timer.wait_for_time(2, "generate_compl_for_dpc_outstanding_req", "ps");

    pcie_cpl_trans = new("pcie_cpl_trans");
    
    pcie_cpl_trans.m_tlp_req_type                  = CDN_HPA_PCIE_TRANS_COMPLETION;
    pcie_cpl_trans.m_tlp_trans_type                = CDN_HPA_PCIE_TRANS_CPL_TYPE;
    pcie_cpl_trans.m_hdr_type                      = (item.pcie_np_req.m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_MRdLk_32 || item.pcie_np_req.m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)?'hb:'ha;                          
    pcie_cpl_trans.m_hdr_fmt                       = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
    pcie_cpl_trans.m_tlp_type                      = CDN_HPA_PCIE_TLP_TYPE_Cpl;
    pcie_cpl_trans.m_tlp_14_bit_tagscale           = item.pcie_np_req.m_tlp_14_bit_tagscale;
    pcie_cpl_trans.m_tlp_t9                        = item.pcie_np_req.m_tlp_t9;
    pcie_cpl_trans.m_tlp_tc                        = item.pcie_np_req.m_tlp_tc;
    pcie_cpl_trans.m_tlp_t8                        = item.pcie_np_req.m_tlp_t8;
    pcie_cpl_trans.m_tlp_attr1                     = ((item.pcie_np_req.m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) ? 0 : ((pipeline_pkt_count == 0) ? m_pcie_dev_top_cfg.pf_config[0].m_ido_cpl_en : item.pcie_np_req.m_tlp_attr1));
    pcie_cpl_trans.m_tlp_ln                        = 0;
    pcie_cpl_trans.m_tlp_th                        = 0;
    pcie_cpl_trans.m_tlp_td                        = ((pipeline_pkt_count == 0) ? item.pcie_np_req.m_tlp_td : 0);
    pcie_cpl_trans.m_tlp_ep                        = 0;
    pcie_cpl_trans.m_tlp_attr0                     = (item.pcie_np_req.m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)? {item.pcie_np_req.m_tlp_attr0[1],1'b0} : item.pcie_np_req.m_tlp_attr0;
    pcie_cpl_trans.m_tlp_at_type                   = CDN_HPA_PCIE_AT_Untranslated;
    pcie_cpl_trans.m_tlp_length                    = 0;
    pcie_cpl_trans.m_tlp_completer_id              = ((pipeline_pkt_count == 0) ? item.m_tlp_requester_id : 0); //TODO: suvikram Need to check why Outstanding TLPs have no Completer ID in case of DPC.

    pcie_cpl_trans.m_tlp_cpl_bcm                   = 0;
    //DMWr
    pcie_cpl_trans.m_tlp_cpl_byte_cnt              = ((item.pcie_np_req.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_DMWr_32, CDN_HPA_PCIE_TLP_TYPE_DMWr_64}) ? 4 : item.pcie_np_req.get_cpl_len_in_bytes()); //As per info in JIRA PCIE-13074
    
    pcie_cpl_trans.m_tlp_requester_id              = item.m_tlp_requester_id;
    pcie_cpl_trans.m_tlp_tag                       = item.m_req_tag;

    `uvm_info(get_full_name(), $sformatf("After DPC CPL tag= %0h , pcie_cpl_trans.m_tlp_at_type= %0p, item.pcie_np_req.m_tlp_type=%0p item.pcie_np_req.m_tlp_addr[6:0]=%0h",
                                                pcie_cpl_trans.m_tlp_tag, pcie_cpl_trans.m_tlp_at_type,item.pcie_np_req.m_tlp_type,item.pcie_np_req.m_tlp_addr[6:0]), UVM_LOW)

    //Lower Address calculation:
    if(item.pcie_np_req.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32, CDN_HPA_PCIE_TLP_TYPE_MRd_64,
                                           CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64} || 
     ((item.pcie_np_req.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_IORd, CDN_HPA_PCIE_TLP_TYPE_IOWr,
                                           CDN_HPA_PCIE_TLP_TYPE_DMWr_32, CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
                                           CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32, CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
                                           CDN_HPA_PCIE_TLP_TYPE_Swap_32, CDN_HPA_PCIE_TLP_TYPE_Swap_64,
                                           CDN_HPA_PCIE_TLP_TYPE_Cas_32, CDN_HPA_PCIE_TLP_TYPE_Cas_64}) && (pipeline_pkt_count != 0)))begin
      lower_addr[6:2] = (item.pcie_np_req.m_tlp_at_type inside {CDN_HPA_PCIE_AT_Translation_Request, CDN_HPA_PCIE_AT_Translated}) ? 5'b0 : item.pcie_np_req.m_tlp_addr[6:2];
      if((item.pcie_np_req.m_tlp_th == 1) && (!item.pcie_np_req.is_flit_mode))begin //If TH bit set FBE and LBE are assumed to be 'hFF
        lower_addr[1:0] =  2'b00 ;
      end else begin
        lower_addr[1:0] = (item.pcie_np_req.m_tlp_first_dw_be[0] == 1'b1) ? 2'b00 :
                          (item.pcie_np_req.m_tlp_first_dw_be[1] == 1'b1) ? 2'b01 :
                          (item.pcie_np_req.m_tlp_first_dw_be[2] == 1'b1) ? 2'b10 :
                          (item.pcie_np_req.m_tlp_first_dw_be[3] == 1'b1) ? 2'b11 : 2'b00 ;
      end
    end else begin
      lower_addr = 0;
    end
    pcie_cpl_trans.m_tlp_cpl_lower_addr        = lower_addr;

    pcie_cpl_trans.is_cxl_pbr_mode = item.pcie_np_req.is_cxl_pbr_mode;
    if(pcie_cpl_trans.is_cxl_pbr_mode) begin
      pcie_cpl_trans.m_tlp_pbr_tlp_header = {2'b11, m_pcie_dev_top_cfg.cxl_pth_rsvd, m_pcie_dev_top_cfg.cxl_pth_hie, m_pcie_dev_top_cfg.cxl_pth_dsar, m_pcie_dev_top_cfg.cxl_pth_pif, m_pcie_dev_top_cfg.cxl_pth_dpid_towards_AL, m_pcie_dev_top_cfg.cxl_pth_spid};
      pcie_cpl_trans.m_tlp_pth_rsvd       = pcie_cpl_trans.m_tlp_pbr_tlp_header[29:27];
      pcie_cpl_trans.m_tlp_pth_hie        = pcie_cpl_trans.m_tlp_pbr_tlp_header[26];
      pcie_cpl_trans.m_tlp_pth_dsar       = pcie_cpl_trans.m_tlp_pbr_tlp_header[25];
      pcie_cpl_trans.m_tlp_pth_pif        = pcie_cpl_trans.m_tlp_pbr_tlp_header[24];
      pcie_cpl_trans.m_tlp_pth_spid       = pcie_cpl_trans.m_tlp_pbr_tlp_header[23:12];
      pcie_cpl_trans.m_tlp_pth_dpid       = pcie_cpl_trans.m_tlp_pbr_tlp_header[11:0];
    end

    // Update MetaData
    m_pf_vf = m_pcie_dev_top_cfg.get_pf_vf_from_req_id(pcie_cpl_trans.m_tlp_requester_id);
`ifdef HAS_UIO
    pcie_cpl_trans.hls_ib_cpl_meta_s.hls_bridge_pkt_route_info = 4'b0010; // TODO: Fix the pkt routing info here for DPC Completions. Also update for UIO Completions as well.
`endif
    pcie_cpl_trans.hls_ib_cpl_meta_s.cpl_err_code  = ((pipeline_pkt_count == 0) ? 4'b0111 : 4'b0010);
    pcie_cpl_trans.m_tlp_cpl_status                = (m_pcie_dev_top_cfg.pf_config[0].dpc_cmpl_control ? CDN_HPA_PCIE_CPL_UR : CDN_HPA_PCIE_CPL_ABORT);
    pcie_cpl_trans.hls_ib_cpl_meta_s.cpl_complete  = 1;       // Last Completion as FLRed 
    pcie_cpl_trans.hls_ib_cpl_meta_s.pf            = m_pf_vf.pf;                           // PF from the Req_id 
    pcie_cpl_trans.hls_ib_cpl_meta_s.vf            = m_pf_vf.is_vf_valid ? m_pf_vf.vf : 0; // VF from the Req_id
    pcie_cpl_trans.hls_ib_cpl_meta_s.vf_or_pf      = m_pf_vf.is_vf_valid;                  // is_vf_valid from the Req_id 

    //Populate Prefix info, Only IDE and Local prefixes are copied for OB UR/CA.
    if(pipeline_pkt_count == 0) begin
      pcie_cpl_trans.m_max_no_of_prefixes      = item.pcie_np_req.m_max_no_of_prefixes;
      pcie_cpl_trans.is_ide_tlp                = item.pcie_np_req.is_ide_tlp;
      pcie_cpl_trans.m_ide_prefix_present      = item.pcie_np_req.m_ide_prefix_present;     
      pcie_cpl_trans.m_ide_hdr_fmt_prefix      = CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;     
      pcie_cpl_trans.m_ide_hdr_type_prefix     = 5'b10010;     
      pcie_cpl_trans.m_pr_sent_counter         = 0; //l_tlp.m_pr_sent_counter;     
      pcie_cpl_trans.m_stream_id               = item.pcie_np_req.m_stream_id;     
      pcie_cpl_trans.m_sub_stream              = 2; //As per ECN-IDE, sub_stream: P-0, NP-1 and CPL-2.     
      pcie_cpl_trans.m_ide_p                   = 0; //l_tlp.m_ide_p;     
      pcie_cpl_trans.m_ide_m                   = 1; //l_tlp.m_ide_m;     
      pcie_cpl_trans.m_ide_k                   = 0; //l_tlp.m_ide_k;     
      pcie_cpl_trans.m_ide_t                   = item.pcie_np_req.m_ide_t;     
      pcie_cpl_trans.m_ide_tlp_prefix          = {pcie_cpl_trans.m_ide_hdr_fmt_prefix, pcie_cpl_trans.m_ide_hdr_type_prefix, 
                                                           pcie_cpl_trans.m_pr_sent_counter, pcie_cpl_trans.m_stream_id, 
                                                           pcie_cpl_trans.m_sub_stream, pcie_cpl_trans.m_ide_p, 
                                                           pcie_cpl_trans.m_ide_m, pcie_cpl_trans.m_ide_k, pcie_cpl_trans.m_ide_t};
    end

    //Copy Local Prefix to UR/CA Completion
    if (item.pcie_np_req.m_max_no_of_local_prefixes>0) begin
      pcie_cpl_trans.m_tlp_local_prefix      = new[item.pcie_np_req.m_max_no_of_local_prefixes];
      pcie_cpl_trans.m_hdr_type_local_prefix = new[item.pcie_np_req.m_max_no_of_local_prefixes];
      foreach (item.pcie_np_req.m_tlp_local_prefix[l_prfx]) begin
        pcie_cpl_trans.m_tlp_local_prefix[l_prfx]      = item.pcie_np_req.m_tlp_local_prefix[l_prfx];
        pcie_cpl_trans.m_hdr_type_local_prefix[l_prfx] = item.pcie_np_req.m_hdr_type_local_prefix[l_prfx];
        `uvm_info(get_type_name(), $psprintf("item.pcie_np_req.m_tlp_local_prefix[%0d]=%h", l_prfx, item.pcie_np_req.m_tlp_local_prefix[l_prfx]), UVM_DEBUG)
        `uvm_info(get_type_name(), $psprintf("pcie_cpl_trans.m_tlp_local_prefix[%0d]=%h", l_prfx, pcie_cpl_trans.m_tlp_local_prefix[l_prfx]), UVM_DEBUG)
      end
    end

    `ifdef HPA_ARCH2
      pcie_cpl_trans.hls_ib_cpl_meta_s.generated_tlp = 1'b1;
      populate_fields_for_flit_mode_cpl(pcie_cpl_trans,item.pcie_np_req);
    `endif

    //Flit Mode Fields Update
    if(pcie_cpl_trans.is_flit_mode) begin
      pcie_cpl_trans.m_ts = item.pcie_np_req.m_ts;
      pcie_cpl_trans.m_ohc_hdr.ohc_a_present     = 1;
      if(pipeline_pkt_count == 0) begin
        //TS Field of Header
        pcie_cpl_trans.m_ts = item.pcie_np_req.m_ts;
        
        //OHC_A5 for CPL
        pcie_cpl_trans.m_destination_segment       = (!item.pcie_np_req.hls_ob_meta_s.req_seg_in_tlp_is_valid ? (m_pcie_dev_top_cfg.enable_segmentation ? m_pcie_dev_top_cfg.requester_segment : 0) : (item.pcie_np_req.m_requester_segment_valid ? item.pcie_np_req.m_requester_segment : 0));
        pcie_cpl_trans.m_completer_segment         = (m_pcie_dev_top_cfg.enable_segmentation ? m_pcie_dev_top_cfg.requester_segment : 0);
        pcie_cpl_trans.m_destination_segment_valid = item.pcie_np_req.m_requester_segment_valid;
        
        //OHC_C 
        if(item.pcie_np_req.m_ide_prefix_present) begin
          pcie_cpl_trans.m_ohc_hdr.ohc_c_present = 1;
          pcie_cpl_trans.m_requester_segment_valid = 0; // It is a reserve bit for IDE TLP Completions, Check spec OHC-C at page 163 and 2nd point 3rd sub-point
        end else begin
          pcie_cpl_trans.m_ohc_hdr.ohc_c_present = 0;
          pcie_cpl_trans.m_ohc_c = 0;
        end

      end else begin

        pcie_cpl_trans.m_ts = CDN_HPA_PCIE_NO_TRAILER;
        
        pcie_cpl_trans.m_destination_segment       = 0; //(item.pcie_np_req.m_requester_segment_valid ? item.pcie_np_req.m_requester_segment : 0);
        pcie_cpl_trans.m_completer_segment         = 0; //(m_pcie_dev_top_cfg.enable_segmentation ? m_pcie_dev_top_cfg.requester_segment : 0);
        pcie_cpl_trans.m_destination_segment_valid = 0; //item.pcie_np_req.m_requester_segment_valid;
        
        pcie_cpl_trans.m_ohc_hdr.ohc_c_present = 0;
      end
      
      pcie_cpl_trans.m_ohc_hdr.ohc_b_present = 0;

      if(item.pcie_np_req.m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER) begin
        pcie_cpl_trans.update_ts_payload();
        `uvm_info(get_full_name(),$sformatf("item.pcie_np_req.m_ide_prefix_present=%0b, pcie_cpl_trans.is_flit_mode=%0b, pcie_cpl_trans.m_ts=%0s",
                                             item.pcie_np_req.m_ide_prefix_present, pcie_cpl_trans.is_flit_mode, pcie_cpl_trans.m_ts.name),UVM_DEBUG)
      end
    end

    case (parameters_cfg_pkg::HPA_ARCH)
      "HPA_ARCH_1_0" : begin
                         pcie_cpl_trans.pack_prefix=0;
                         pcie_cpl_trans.pack_ecrc  =0;
                       end
      "HPA_ARCH_2_0" : begin
                         if(pcie_cpl_trans.m_tlp_td || (item.pcie_np_req.is_flit_mode && (item.pcie_np_req.m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER)))
                           pcie_cpl_trans.ecrc_val = 0;
                         pcie_cpl_trans.pack_prefix=1;
                         pcie_cpl_trans.pack_ecrc  =1;
                         pcie_cpl_trans.pack_ecrc_local  =1;
                         pcie_cpl_trans.hpa_generation = hpa_generation_2;
                         pcie_cpl_trans.pcie_6_1_support = 1;
                         pcie_cpl_trans.is_flit_mode = item.pcie_np_req.is_flit_mode;
                         if(pcie_cpl_trans.is_flit_mode) begin
                           if(pcie_cpl_trans.m_ohc_hdr.ohc_a_present) begin
                             pcie_cpl_trans.m_ohc_a = {pcie_cpl_trans.m_destination_segment,
                                                       pcie_cpl_trans.m_completer_segment,
                                                       pcie_cpl_trans.m_destination_segment_valid,
                                                       pcie_cpl_trans.m_ohc_a5_byte_2_3_rsvd,
                                                       pcie_cpl_trans.m_tlp_cpl_lower_addr[1:0],
                                                       pcie_cpl_trans.m_tlp_cpl_status};
                           end
                           if(pcie_cpl_trans.m_ohc_hdr.ohc_c_present) begin
                             pcie_cpl_trans.m_ohc_c = {pcie_cpl_trans.m_requester_segment,
                                                       pcie_cpl_trans.m_pr_sent_counter,
                                                       pcie_cpl_trans.m_stream_id,
                                                       pcie_cpl_trans.m_sub_stream,
                                                       pcie_cpl_trans.m_requester_segment_valid,
                                                       pcie_cpl_trans.m_ohc_c_byte_3_field_2_rsvd,
                                                       pcie_cpl_trans.m_ide_k,
                                                       pcie_cpl_trans.m_ide_t};
                           end
                         end
                       end
    endcase

    `uvm_info(get_full_name(), $sformatf("Writing exp DPC CPL to SCB. CPL TLP: %0s", pcie_cpl_trans.sprint()), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("Writing exp DPC CPL Metadata to SCB. CPL TLP: %0p", pcie_cpl_trans.hls_ib_cpl_meta_s), UVM_LOW)
    // Send to DPC COMPL score board 
    dpc_ib_compl_req_ap.write(pcie_cpl_trans);

  endtask : generate_compl_for_dpc_outstanding_req


  //------------------------------------------------------------------------
  // Method: monitor_flr
  // The below process monitors the FLR event and forms the dummy completions
  // and send to score board
  //------------------------------------------------------------------------
  virtual task monitor_flr();
    cdn_pcie_flr_tr flr_tr;
    cdn_hpa_pcie_tlp_requester_id_s req_id_s;
    cdn_hpa_pcie_tlp_requester_id_s req_id_s_vf;
    uvm_object      obj;
    cdn_pcie_hpa_compl_lut_item item[$];
    cdn_pcie_hpa_compl_lut_item item_vf[$];
    int unsigned vf_offset;

    forever begin
      flr_received.wait_trigger_data(obj);
      //$display("Received FLR");
      if(!$cast(flr_tr, obj))
        `uvm_fatal(get_full_name, "Cast failed")
      item = {};
      foreach (m_pcie_dev_top_cfg.pf_config[i])
        `uvm_info(get_full_name, $sformatf("AKSDEBUG: pf_config %0s ", m_pcie_dev_top_cfg.pf_config[i].sprint()), UVM_DEBUG)
      req_id_s = m_pcie_dev_top_cfg.get_req_id_for_pf_vf(flr_tr.flr_received_ipfivf[7:0], flr_tr.flr_received_ipfivf[23:8], flr_tr.flr_received_ipfivf[24]); 

      hpa_timer.wait_for_time(5, "generate_compl_for_flr_req", "ps");
      item = compl_lut_obj.compl_lut.find(x) with (x.m_tlp_requester_id == req_id_s);

      // If more then 1 TLP is received 1TLP is sent first
      // CPLs are generated in the order of received outstanding requests
      item.sort( x ) with (x.time_in_tag_m); 
      foreach(item[i]) begin
        //$display("Any out standing ??");
        //item[i].print();
        //`uvm_info(get_name(),$psprintf("Out stadnding requests when FLR recevied are %0p", qv.print()), UVM_LOW)
        `uvm_info(get_name(),$psprintf("Out stadnding requests when FLR recevied are %0s", item[i].sprint()), UVM_LOW)
        `uvm_info(get_name(),$psprintf("Generating FLRed CPL for PF req_id= %0p", req_id_s), UVM_LOW)
        generate_compl_for_flr_req(item[i]);
      end
      if((flr_tr.flr_received_ipfivf[24]==0) && (m_pcie_dev_top_cfg.pf_config[flr_tr.flr_received_ipfivf[7:0]].m_vf_en)) begin
        vf_offset = m_pcie_dev_top_cfg.pf_config[flr_tr.flr_received_ipfivf[7:0]].m_first_vf_Offset;
        `uvm_info(get_name(),$psprintf("VF_offset = %0h", vf_offset), UVM_LOW)
        req_id_s_vf.bus_num = req_id_s.bus_num;
        req_id_s_vf.device_num = req_id_s.device_num;

        for (int vfn=0; vfn<m_pcie_dev_top_cfg.pf_config[flr_tr.flr_received_ipfivf[7:0]].m_NumVFs; vfn++) begin
          if(m_pcie_strap_cfg.strap_ari_enable)
            {req_id_s_vf.device_num,req_id_s_vf.function_num} = {req_id_s.device_num,req_id_s.function_num}+vf_offset+vfn;
          else
            req_id_s_vf.function_num = req_id_s.function_num+vf_offset+vfn;
          item_vf = compl_lut_obj.compl_lut.find(x) with (x.m_tlp_requester_id == req_id_s_vf);
          item_vf.sort( x ) with (x.time_in_tag_m); 
          foreach(item_vf[i]) begin
            `uvm_info(get_name(),$psprintf("Out stadnding requests when FLR recevied are %0s", item_vf[i].sprint()), UVM_LOW)
            `uvm_info(get_name(),$psprintf("Generating FLRed CPL for VF req_id= %0p", req_id_s_vf), UVM_LOW)
            generate_compl_for_flr_req(item_vf[i]);
          end
        end
      end
    end  
      
  endtask

  //------------------------------------------------------------------------
  // Method: release_tag
  // Release the tag when received an FLR or when the last completion recived
  //------------------------------------------------------------------------
  virtual function void release_tag(bit [13:0] tag);
    int qi[$];

    //Remove the entry from the LUT item
    `uvm_info(get_full_name(), $psprintf("DEBUG:: Deleting TAG %0h",tag), UVM_LOW)
    compl_lut_obj.compl_lut.delete(tag);
    // Release the tag
    qi = m_consumed_tags.find_index(x) with (x == tag);
    if(qi.size() > 0)
    begin
      m_consumed_tags.delete(qi[0]);
      // Resusing the released tag first
      m_available_tags.push_front(tag);
      tag_exhausted = 0;
    end

  endfunction

  //------------------------------------------------------------------------
  // Method: completion_tag_discard
  // The below process releases tags for ob requests whose completions are 
  // discarded 
  //------------------------------------------------------------------------
  virtual task completion_tag_discard();
    uvm_object      obj;
    cdn_pcie_hpa_compl_lut_item item;
    `uvm_info(get_full_name, $psprintf("completion_tag_discard called"), UVM_DEBUG)
    forever begin
      tag_discarded.wait_trigger_data(obj);
      if(!$cast(item, obj))
        `uvm_fatal(get_full_name, "Cast failed")
      //if(tag)
      `uvm_info(get_full_name, $psprintf("tag_discarded completion_tag_discard triggered for tag = %0d", item.m_req_tag), UVM_DEBUG)
      //if(tag_manager_8_bit && item.m_req_tag < 256) begin
        m_discarded_tags.push_back(item.m_req_tag);
        release_tag(item.m_req_tag);
      //end
      //if(tag_manager_10_bit && item.m_req_tag > 256) begin
      //  m_discarded_tags.push_back(item.m_req_tag);
      //  release_tag(item.m_req_tag);
      //end
    end
  endtask

  //------------------------------------------------------------------------
  // Method: wait_for_no_outstanding_reqs 
  //------------------------------------------------------------------------
  virtual task wait_for_no_outstanding_reqs ();
    wait(m_consumed_tags.size() == 0)    ;
  endtask


  //------------------------------------------------------------------------
  // Method: get_num_ob_outstanding_reqs 
  // Returns number of IB outstadning requests waiting for cpls
  //------------------------------------------------------------------------
  virtual function int get_num_ob_outstanding_reqs();
    int cnsmd_tgs;
    cnsmd_tgs=m_consumed_tags.size();
    return(cnsmd_tgs);
  endfunction

  //------------------------------------------------------------------------
  // Method: get_num_ob_outstanding_reqs 
  // Returns number of IB outstadning requests waiting for cpls
  //------------------------------------------------------------------------
  virtual function int get_num_ob_available_tags();
   int avl_tgs;
   avl_tgs=m_available_tags.size();
    return(avl_tgs);

  endfunction

  //------------------------------------------------------------------------
  // Method: generate_compl_for_flr_req 
  // The below process generates the dummy compeltions for outstanding requ
  // terminated due to FLR
  //------------------------------------------------------------------------
  virtual task generate_compl_for_flr_req(ref cdn_pcie_hpa_compl_lut_item item);
    cdn_hpa_pcie_tlp     pcie_cpl_trans;
    cdn_pcie_hpa_pf_vf_s m_pf_vf;
    bit [6:0]            lower_addr;
    bit [13:0]            l_tag;

    l_tag = {item.pcie_np_req.m_tlp_14_bit_tagscale, item.pcie_np_req.m_tlp_t9, item.pcie_np_req.m_tlp_t8, item.pcie_np_req.m_tlp_tag};

    //If packet input to tl2hls but did not reach to client and FLR initiated, It is unpredictable whether packet will
    //reach to client. For this, HLS module is creating the FLRed cpl for this scenario
    `uvm_info(get_full_name(), $sformatf("m_tl2hls_cpl_item[%0h].pkt_reach_to_hls: %0d", l_tag, m_tl2hls_cpl_item[l_tag].pkt_reach_to_hls), UVM_DEBUG)
    `uvm_info(get_full_name(), $sformatf("m_tl2hls_cpl_item[%0h].pkt_reach_to_client: %0d", l_tag, m_tl2hls_cpl_item[l_tag].pkt_reach_to_client), UVM_DEBUG)
    hpa_timer.wait_for_time(2, "generate_compl_for_flr_req", "ps");
    if(m_tl2hls_cpl_item[l_tag].pkt_reach_to_hls != m_tl2hls_cpl_item[l_tag].pkt_reach_to_client) begin
      `uvm_info(get_full_name(), $sformatf("Not Pushing the FLRed completion for tag: %0h", l_tag), UVM_DEBUG)
      return;
    end

    pcie_cpl_trans = new("pcie_cpl_trans");
    
    // Based on the Implementation only descriptor fields are valid
    // Descriptor -> RID, Tag, TC, Attributes
    // TODO : But RTL is generating valid lower address and byte count 
    // Length  - I suppose length is required to update
    // Completer ID is not required to update 

    pcie_cpl_trans.m_tlp_req_type                  = CDN_HPA_PCIE_TRANS_COMPLETION;
    pcie_cpl_trans.m_tlp_trans_type                = CDN_HPA_PCIE_TRANS_CPL_TYPE;
    pcie_cpl_trans.m_hdr_type                      = 5'b01010;
    pcie_cpl_trans.m_tlp_14_bit_tagscale           = item.pcie_np_req.m_tlp_14_bit_tagscale;
    pcie_cpl_trans.m_tlp_t9                        = item.pcie_np_req.m_tlp_t9;
    pcie_cpl_trans.m_tlp_tc                        = item.pcie_np_req.m_tlp_tc;
    pcie_cpl_trans.m_tlp_t8                        = item.pcie_np_req.m_tlp_t8;
    pcie_cpl_trans.m_tlp_attr1                     = item.pcie_np_req.m_tlp_attr1;
    pcie_cpl_trans.m_tlp_th                        = 0;
    pcie_cpl_trans.m_tlp_td                        = 0;
    pcie_cpl_trans.m_tlp_ep                        = 0;
    pcie_cpl_trans.m_tlp_attr0                     = item.pcie_np_req.m_tlp_attr0;
    `ifdef HPA_ARCH2
      pcie_cpl_trans.m_tlp_at_type                   = CDN_HPA_PCIE_AT_Untranslated;
    `else
      pcie_cpl_trans.m_tlp_at_type                   = item.pcie_np_req.m_tlp_at_type; //CDN_HPA_PCIE_AT_Untranslated;
    `endif

    pcie_cpl_trans.m_tlp_completer_id.bus_num      = 0;  // m_pcie_vip_top_cfg.pf_config[0].m_req_id.bus_num; // VIP RP bus num 0  // !!!!! TODO !!!!! Confirm once
    pcie_cpl_trans.m_tlp_completer_id.device_num   = 0;  // m_pcie_vip_top_cfg.pf_config[0].m_req_id.device_num; // VIP RP Device num
    pcie_cpl_trans.m_tlp_completer_id.function_num = 0;  // As RP always have one function

    pcie_cpl_trans.m_tlp_cpl_bcm                   = 0;
    pcie_cpl_trans.m_tlp_requester_id.bus_num      = item.m_tlp_requester_id.bus_num;
    pcie_cpl_trans.m_tlp_requester_id.device_num   = item.m_tlp_requester_id.device_num;
    pcie_cpl_trans.m_tlp_requester_id.function_num = item.m_tlp_requester_id.function_num;
    pcie_cpl_trans.m_tlp_tag                       = item.m_req_tag;

    `uvm_info(get_full_name(), $sformatf("FLRed CPL tag= %0h , pcie_cpl_trans.m_tlp_at_type= %0p, item.pcie_np_req.m_tlp_type=%0p item.pcie_np_req.m_tlp_addr[6:0]=%0h", pcie_cpl_trans.m_tlp_tag, pcie_cpl_trans.m_tlp_at_type,item.pcie_np_req.m_tlp_type,item.pcie_np_req.m_tlp_addr[6:0]), UVM_LOW)

    pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
    pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_Cpl;
    pcie_cpl_trans.m_tlp_req_type              = CDN_HPA_PCIE_TRANS_COMPLETION;
    pcie_cpl_trans.m_tlp_cpl_byte_cnt          = 4;

    //Lower Address calculation:
    lower_addr[6:2] = item.pcie_np_req.m_tlp_addr[6:2];
    if((item.pcie_np_req.m_tlp_th == 1) && (!item.pcie_np_req.is_flit_mode))begin //If TH bit set FBE and LBE are assumed to be 'hFF
      lower_addr[1:0] =  2'b00 ;
    end else begin
      lower_addr[1:0] = (item.pcie_np_req.m_tlp_first_dw_be[0] == 1'b1) ? 2'b00 :
                        (item.pcie_np_req.m_tlp_first_dw_be[1] == 1'b1) ? 2'b01 :
                        (item.pcie_np_req.m_tlp_first_dw_be[2] == 1'b1) ? 2'b10 :
                        (item.pcie_np_req.m_tlp_first_dw_be[3] == 1'b1) ? 2'b11 : 2'b00 ;
    end
    pcie_cpl_trans.m_tlp_cpl_lower_addr        = lower_addr;
    pcie_cpl_trans.m_tlp_length                = 0;

    //DMWr
    if (item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32 ||
         item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64
       ) begin
      pcie_cpl_trans.m_tlp_ln                    = 0;
      `ifdef HPA_ARCH2
        pcie_cpl_trans.m_tlp_cpl_byte_cnt          = 4; //As per info in JIRA PCIE-13074
      `else
        pcie_cpl_trans.m_tlp_cpl_byte_cnt          = 0; //As per info in JIRA PCIE-10988
      `endif
    end  
    //MemRd
    else if (item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32 ||
             item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64 ) begin
      shortint unsigned            byte_count;
      shortint unsigned            req_length;

      req_length = (item.pcie_np_req.m_tlp_length == 0) ? 1024 : item.pcie_np_req.m_tlp_length;
      //If we receive the completion and FLR same time
      if($time == m_tl2hls_cpl_item[l_tag].l_receive_time) begin
        byte_count = m_tl2hls_cpl_item[l_tag].l_prev_byte_count;
      end
      else begin
        //If no completion is received for this tag yet, take byte count as the first completion byte count
        //Else remaining byte count
        if(m_tl2hls_cpl_item[l_tag].first_cpl)
          byte_count = m_tl2hls_cpl_item[l_tag].l_byte_count;
        else begin
          if(m_tl2hls_cpl_item[l_tag].m_req_length_bytes)
            byte_count = m_tl2hls_cpl_item[l_tag].m_req_length_bytes;
        end
      end
      //if(m_received_cpl_tag.exists({pcie_cpl_trans.m_tlp_t9, pcie_cpl_trans.m_tlp_t8, pcie_cpl_trans.m_tlp_tag})) begin
      //  byte_count = compl_lut_obj.compl_lut[{pcie_cpl_trans.m_tlp_t9, pcie_cpl_trans.m_tlp_t8, pcie_cpl_trans.m_tlp_tag}].m_req_length_bytes - (4 - $countones(item.pcie_np_req.m_tlp_last_dw_be));
      //end
      //else if(item.pcie_np_req.m_tlp_at_type == CDN_HPA_PCIE_AT_Translated)begin
      //  byte_count = req_length*4 - (4 - (item.pcie_np_req.m_tlp_first_dw_be[0] ? 4 : 
      //                                    item.pcie_np_req.m_tlp_first_dw_be[1] ? 3 : 
      //                                    item.pcie_np_req.m_tlp_first_dw_be[2] ? 2 : 
      //                                    item.pcie_np_req.m_tlp_first_dw_be[3] ? 1 : 0));
      //end
      //else begin
      //  if(req_length==1)
      //    byte_count = req_length*4 - (4 - (item.pcie_np_req.m_tlp_first_dw_be[0] ? 4 : 
      //                                      item.pcie_np_req.m_tlp_first_dw_be[1] ? 3 : 
      //                                      item.pcie_np_req.m_tlp_first_dw_be[2] ? 2 : 
      //                                      item.pcie_np_req.m_tlp_first_dw_be[3] ? 1 : 0));
      //  else
      //    byte_count = req_length*4 - (8 - $countones(item.pcie_np_req.m_tlp_first_dw_be) - $countones(item.pcie_np_req.m_tlp_last_dw_be));
      //end
      //else begin
      //  if(item.pcie_np_req.m_tlp_th == 1) begin //If TH bit set FBE and LBE are assumed to be 'hFF
      //    byte_count = req_length*4;
      //  end else if (item.pcie_np_req.m_tlp_first_dw_be == 4'h0) begin
      //    byte_count = 1;
      //  end else if (item.pcie_np_req.m_tlp_last_dw_be == 4'h0) begin
      //        if(item.pcie_np_req.m_tlp_first_dw_be inside {4'b1??1})
      //          byte_count = req_length*4;
      //        else if(item.pcie_np_req.m_tlp_first_dw_be inside {4'b01?1,4'b1?10})
      //          byte_count = (req_length*4) - 1;
      //        else  
      //          byte_count = $countones(item.pcie_np_req.m_tlp_first_dw_be);
      //  end else if (item.pcie_np_req.m_tlp_first_dw_be inside {4'b???1})begin
      //           byte_count = (item.pcie_np_req.m_tlp_last_dw_be inside {4'b1???}) ? (req_length*4) : (item.pcie_np_req.m_tlp_last_dw_be inside {4'b01??}) ? (req_length*4)-1 : (item.pcie_np_req.m_tlp_last_dw_be inside {4'b001?}) ? (req_length*4)-2:               (item.pcie_np_req.m_tlp_last_dw_be inside {4'b0001}) ? (req_length*4)-3 : 4;
      //  
      //  end else if (item.pcie_np_req.m_tlp_first_dw_be inside {4'b??10})begin
      //           byte_count = (item.pcie_np_req.m_tlp_last_dw_be inside {4'b1???}) ? (req_length*4)-1 : (item.pcie_np_req.m_tlp_last_dw_be inside {4'b01??}) ? (req_length*4)-2 : (item.pcie_np_req.m_tlp_last_dw_be inside {4'b001?}) ? (req_length*4)-3:             (item.pcie_np_req.m_tlp_last_dw_be inside {4'b0001}) ? (req_length*4)-4 : 4;
      //  
      //  end else if (item.pcie_np_req.m_tlp_first_dw_be inside {4'b?100})begin
      //           byte_count = (item.pcie_np_req.m_tlp_last_dw_be inside {4'b1???}) ? (req_length*4)-2 : (item.pcie_np_req.m_tlp_last_dw_be inside {4'b01??}) ? (req_length*4)-3 : (item.pcie_np_req.m_tlp_last_dw_be inside {4'b001?}) ? (req_length*4)-4:             (item.pcie_np_req.m_tlp_last_dw_be inside {4'b0001}) ? (req_length*4)-5 : 4;

      //  end else if (item.pcie_np_req.m_tlp_first_dw_be inside {4'b1000})begin
      //           byte_count = (item.pcie_np_req.m_tlp_last_dw_be inside {4'b1???}) ? (req_length*4)-3 : (item.pcie_np_req.m_tlp_last_dw_be inside {4'b01??}) ? (req_length*4)-4 : (item.pcie_np_req.m_tlp_last_dw_be inside {4'b001?}) ? (req_length*4)-5:             (item.pcie_np_req.m_tlp_last_dw_be inside {4'b0001}) ? (req_length*4)-6 : 4;

      //  end else begin
      //    byte_count = req_length*4 -
      //      (8 - $countones(item.pcie_np_req.m_tlp_first_dw_be) - $countones(item.pcie_np_req.m_tlp_last_dw_be));
      //  end
      //end
      							       
      pcie_cpl_trans.m_tlp_cpl_byte_cnt          = byte_count;
      pcie_cpl_trans.m_tlp_ln                    = item.pcie_np_req.m_tlp_ln;
	     
    end	      
    // Atomic Cpl
    else if ( item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32 ||
              item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64 ||
              item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32 ||
              item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64 ||
              item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32 ||
              item.pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64 ) begin
      
      bit is_cas;

      pcie_cpl_trans.m_tlp_ln                    = item.pcie_np_req.m_tlp_ln;

      is_cas = (item.pcie_np_req.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64});

      pcie_cpl_trans.m_tlp_cpl_lower_addr = item.pcie_np_req.m_tlp_addr[6:0];
      pcie_cpl_trans.m_tlp_cpl_byte_cnt   = is_cas ? $ceil(item.pcie_np_req.m_tlp_length / 2.0)*4 :
                                                     item.pcie_np_req.m_tlp_length*4              ;

    end
    
    // For FLR CPL packet PTH is generated from the pbr_pth_for_generated_tlps_towards_AL Register Field 
    pcie_cpl_trans.is_cxl_pbr_mode = item.pcie_np_req.is_cxl_pbr_mode;
    if(pcie_cpl_trans.is_cxl_pbr_mode) begin
      pcie_cpl_trans.m_tlp_pbr_tlp_header = {2'b11, m_pcie_dev_top_cfg.cxl_pth_rsvd, m_pcie_dev_top_cfg.cxl_pth_hie, m_pcie_dev_top_cfg.cxl_pth_dsar, m_pcie_dev_top_cfg.cxl_pth_pif, m_pcie_dev_top_cfg.cxl_pth_dpid_towards_AL, m_pcie_dev_top_cfg.cxl_pth_spid};
      pcie_cpl_trans.m_tlp_pth_rsvd       = pcie_cpl_trans.m_tlp_pbr_tlp_header[29:27];
      pcie_cpl_trans.m_tlp_pth_hie        = pcie_cpl_trans.m_tlp_pbr_tlp_header[26];
      pcie_cpl_trans.m_tlp_pth_dsar       = pcie_cpl_trans.m_tlp_pbr_tlp_header[25];
      pcie_cpl_trans.m_tlp_pth_pif        = pcie_cpl_trans.m_tlp_pbr_tlp_header[24];
      pcie_cpl_trans.m_tlp_pth_spid       = pcie_cpl_trans.m_tlp_pbr_tlp_header[23:12];
      pcie_cpl_trans.m_tlp_pth_dpid       = pcie_cpl_trans.m_tlp_pbr_tlp_header[11:0];
    end

    // Update MetaData
    m_pf_vf= m_pcie_dev_top_cfg.get_pf_vf_from_req_id(pcie_cpl_trans.m_tlp_requester_id);
    pcie_cpl_trans.hls_ib_cpl_meta_s.cpl_err_code  = 4'b1001; // FLR is terminated for request  // TODO: CPL comparison fix for below
    pcie_cpl_trans.hls_ib_cpl_meta_s.cpl_complete  = 1;       // Last Completion as FLRed 
    pcie_cpl_trans.hls_ib_cpl_meta_s.pf            = m_pf_vf.pf;                           // PF from the Req_id 
    pcie_cpl_trans.hls_ib_cpl_meta_s.vf            = m_pf_vf.is_vf_valid ? m_pf_vf.vf : 0; // VF from the Req_id
    pcie_cpl_trans.hls_ib_cpl_meta_s.vf_or_pf      = m_pf_vf.is_vf_valid;                  // is_vf_valid from the Req_id 

`ifdef HPA_ARCH2
    pcie_cpl_trans.hls_ib_cpl_meta_s.generated_tlp = 1'b1;
    populate_fields_for_flit_mode_cpl(pcie_cpl_trans,item.pcie_np_req);
`endif
    if(pcie_cpl_trans.is_flit_mode) begin
      pcie_cpl_trans.m_ohc_a = 0;
      pcie_cpl_trans.m_destination_segment = 0;
      pcie_cpl_trans.m_destination_segment_valid = 0;
      pcie_cpl_trans.m_completer_segment = 0;
      if(pcie_cpl_trans.m_tlp_cpl_lower_addr[1:0]!= 2'b00) begin
        pcie_cpl_trans.m_ohc_hdr.ohc_a_present = 1;
        pcie_cpl_trans.m_ohc_a[4:3] = pcie_cpl_trans.m_tlp_cpl_lower_addr;
        pcie_cpl_trans.m_ohc_a[2:0] = CDN_HPA_PCIE_CPL_SC;
      end
      else begin
        pcie_cpl_trans.m_ohc_hdr.ohc_a_present = 0;
        pcie_cpl_trans.m_ohc_a = 0;
      end
      pcie_cpl_trans.m_ohc_hdr.ohc_b_present = 0;
      pcie_cpl_trans.m_ohc_hdr.ohc_c_present = 0;
    end
    `uvm_info(get_full_name(), $sformatf("Writing exp FLRed CPL to SCB. CPL TLP: %0s", pcie_cpl_trans.sprint()), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("Writing exp FLRed CPL Metadata to SCB. CPL TLP: %0p", pcie_cpl_trans.hls_ib_cpl_meta_s), UVM_LOW)
    // Send to FLR dummy COMPL score board 
    ib_exp_compl_to_flr_req_ap.write(pcie_cpl_trans);

    // Release the tag from tag pool
    //release_tag(item.m_req_tag);

  endtask : generate_compl_for_flr_req

  virtual function void populate_fields_for_flit_mode_cpl (ref cdn_hpa_pcie_tlp pcie_cpl_trans, ref cdn_hpa_pcie_tlp pcie_np_req);
    bit send_ohc_a;

    if(m_pcie_dev_top_cfg.flit_mode_negotiated) begin //{
     pcie_cpl_trans.hpa_generation = hpa_generation_2;
      pcie_cpl_trans.pcie_6_1_support= m_pcie_dev_top_cfg.pcie_6_1_support;
     pcie_cpl_trans.is_flit_mode = 1;
     pcie_cpl_trans.m_ts = CDN_HPA_PCIE_NO_TRAILER;

     // When the Segment Captured bit is Clear, Completers must set the Completer Segment field to 00h in any
     // OHC-A5 that is included in a Completion.

     // When the Segment Captured bit is Set, Completers must set the Completer Segment field in any OHC-A5 that is
     // included in a Completion to the Segment value that was captured as described in § Section 2.2.6.2 .
     //  - If the Completion associated with the first Configuration Write Request includes OHC-A5, the
     //    Completer Segment field must be set to the value captured from that Request.
     if(!m_pcie_dev_top_cfg.captured_segment_number) begin
       pcie_cpl_trans.m_completer_segment = 8'h00;
     end else begin
       pcie_cpl_trans.m_completer_segment = m_pcie_dev_top_cfg.requester_segment;
     end

     // Completers must clear the DSV bit and set the Destination Segment field to 00h in any OHC-A5 that is included
     // with a Completion associated with a Configuration Request.

     // For a NP Memory Request received without a Requester Segment field, Completers must clear the DSV bit and
     // set the Destination Segment field to 00h in any OHC-A5 that is included with the associated Completion(s).
     if((pcie_np_req.m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) || !pcie_np_req.m_requester_segment_valid) begin
       pcie_cpl_trans.m_destination_segment_valid = 1'b0;
       pcie_cpl_trans.m_destination_segment = 8'h00;
     end

     // For a NP Memory Request received with a Requester Segment field, Completers must set the DSV bit and set
     // the Destination Segment field to the value of the received Requester Segment in any OHC-A5 that is included
     // with the associated Completion(s).
     if(pcie_np_req.m_requester_segment_valid) begin
       pcie_cpl_trans.m_destination_segment = pcie_np_req.m_requester_segment;
       pcie_cpl_trans.m_destination_segment_valid = 1'b1; 
     end

     // When the Segment Captured bit is set and a NP Memory Request is received with a Requester Segment value
     // not matching the Completer's captured Segment value, all Completions associated with the Request must
     // include OHC-A5.

     // Completers must not include OHC-A5 with a Completion when all of the following are true:
     //   - Completion Status is successful.
     //   - Lower Address[1:0] equal to 00b.
     //   - The Completer's Segment Captured bit is Clear.

     // Completers are permitted to not include OHC-A5 with a Completion when all of the following are true:
     //   - Completion Status is successful.
     //   - Lower Address[1:0] equal to 00b.
     //   - The Completer's Segment Captured bit is Set.
     //   - The associated Request either did not include a Requester Segment field or included a Requester
     //     Segment field matching the Completer's captured Segment value.
     if(m_pcie_dev_top_cfg.captured_segment_number &&
        (pcie_np_req.m_requester_segment_valid && 
        (pcie_np_req.m_requester_segment != m_pcie_dev_top_cfg.requester_segment)) ||
        (pcie_cpl_trans.m_tlp_cpl_lower_addr[1:0] != 2'b00) ||
        (pcie_cpl_trans.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC)
       ) begin
       send_ohc_a = 1;
     end else if (!m_pcie_dev_top_cfg.captured_segment_number &&
         pcie_cpl_trans.m_tlp_cpl_lower_addr[1:0] == 2'b00 &&
         pcie_cpl_trans.m_tlp_cpl_status == CDN_HPA_PCIE_CPL_SC 
       )begin
       send_ohc_a = 0;
     end else begin
       assert(std::randomize(send_ohc_a));
     end

     if(send_ohc_a) begin 
       pcie_cpl_trans.m_ohc_hdr.ohc_a_present = 1'b1; 
       pcie_cpl_trans.m_ohc_a = { pcie_cpl_trans.m_destination_segment,
                                  pcie_cpl_trans.m_completer_segment,
                                  pcie_cpl_trans.m_destination_segment_valid,
                                  pcie_cpl_trans.m_ohc_a5_byte_2_3_rsvd,
                                  pcie_cpl_trans.m_tlp_cpl_lower_addr[1:0],
                                  pcie_cpl_trans.m_tlp_cpl_status
                                 };
     end else begin
      pcie_cpl_trans.m_ohc_hdr.ohc_a_present = 1'b0;
      pcie_cpl_trans.m_ohc_a = 32'h0;
     end
     //TODO for OHC-C(IDE Prefix in flit mode)

    end else begin //Non flit mode }{
     pcie_cpl_trans.hpa_generation = hpa_generation_2;
     pcie_cpl_trans.is_flit_mode = 0;
    end //}

  endfunction : populate_fields_for_flit_mode_cpl 

  //------------------------------------------------------------------------
  // Method: generate_compl_lut_item
  // Generate the LUT item and store in NP request
  //------------------------------------------------------------------------
  virtual task generate_compl_lut_item(cdn_hpa_pcie_tlp tlp);

    cdn_pcie_hpa_compl_lut_item lut_item;
    cdn_pcie_vip_userdata  l_vip_user_data;

    lut_item = new();

    //tlp.get_cfg_from_tlp(m_cfg_info);
    np_tlp_count = np_tlp_count + 1;

    lut_item.m_req_tag          = {tlp.m_tlp_14_bit_tagscale,tlp.m_tlp_tagscale,tlp.m_tlp_tag};
    if(tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32 || tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64) begin
      lut_item.m_req_length_bytes = 0; //request length
      lut_item.m_req_tlp_length   = 4; //byte count
    end
    else if (tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr && compl_lut_obj.compl_lut.exists(lut_item.m_req_tag)) begin
      `uvm_info(get_type_name(), $sformatf("Received CDN_HPA_PCIE_TLP_TYPE_UIOMWr for tag 0x%0h with m_req_length_bytes %0h, m_req_tlp_length %0h while previous request has m_req_length_bytes %0h, m_req_tlp_length %0h",
                                           lut_item.m_req_tag, tlp.get_length_in_bytes(1), tlp.get_cpl_len_in_bytes(), compl_lut_obj.compl_lut[lut_item.m_req_tag].m_req_length_bytes, compl_lut_obj.compl_lut[lut_item.m_req_tag].m_req_tlp_length), UVM_DEBUG)
      lut_item.m_req_length_bytes = tlp.get_length_in_bytes(1) + compl_lut_obj.compl_lut[lut_item.m_req_tag].m_req_length_bytes; //request length
      lut_item.m_req_tlp_length   = tlp.get_cpl_len_in_bytes() + compl_lut_obj.compl_lut[lut_item.m_req_tag].m_req_tlp_length; //byte count
    end
    else begin
      lut_item.m_req_length_bytes = tlp.get_length_in_bytes(1); //request length
      lut_item.m_req_tlp_length   = tlp.get_cpl_len_in_bytes(); //byte count
    end
    lut_item.addr               = tlp.m_tlp_addr;
    if(is_active == UVM_ACTIVE) begin 
      lut_item.vip_userdata     = tlp.vip_userdata;
      `uvm_info("generate_compl_lut_item", $psprintf("tlp.vip_userdata=%0s", tlp.vip_userdata.sprint()), UVM_DEBUG)
    end
    // TODO: AXI Team has to update to inject the CPL related IB errors from PCIe VIP
    else begin	
      l_vip_user_data           = new("l_vip_user_data");
      l_vip_user_data.has_err   = 0;
        lut_item.vip_userdata     = l_vip_user_data;
    end	
    if(tlp.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd0, CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr0, CDN_HPA_PCIE_TLP_TYPE_CfgWr1}) begin
      lut_item.m_tlp_ext_reg_num    = tlp.m_tlp_ext_reg_num; 
      lut_item.m_tlp_reg_num    = tlp.m_tlp_reg_num; 
    end
    lut_item.m_tlp_type         = tlp.m_tlp_type; 
    lut_item.m_req_tlp_fbe      = tlp.m_tlp_first_dw_be;
    lut_item.m_req_tlp_lbe      = tlp.m_tlp_last_dw_be;
    lut_item.m_req_tlp_at_type  = tlp.m_tlp_at_type;
    if (!tlp.is_flit_mode) 
      lut_item.m_tlp_th           = tlp.m_tlp_th;
    lut_item.m_tlp_tc           = tlp.m_tlp_tc;
    lut_item.m_tlp_ep           = tlp.m_tlp_ep;
    lut_item.m_req_pasid_prefix_present  = tlp.m_pasid_prefix_present;
    lut_item.m_req_pasid_exec_value  = tlp.m_pasid_exec_value;
    lut_item.m_tlp_requester_id  = tlp.m_tlp_requester_id;
    lut_item.pcie_np_req         = tlp;
    lut_item.m_tlp_attr0         = tlp.m_tlp_attr0;
    lut_item.attr_ido            = tlp.m_tlp_attr1;
    lut_item.time_in_tag_m       = $time;
    lut_item.m_is_atomic_op      = tlp.is_atomic_op();
    lut_item.m_is_mem_rd_op      = tlp.is_memrd_op();
    lut_item.uio_cpl_diff_status = tlp.uio_cpl_diff_status;

    //IDE Prefix fields, which should be compared for cpl
    if(tlp.m_ohc_hdr.ohc_c_present && tlp.is_flit_mode) begin
      lut_item.m_stream_id         = tlp.m_ohc_c[15:8];
      lut_item.m_ide_t             = tlp.m_ohc_c[0];
      lut_item.m_ide_prefix_present  = tlp.m_ide_prefix_present;
    end
    else if(!tlp.is_flit_mode) begin
      lut_item.m_stream_id         = tlp.m_stream_id;
      lut_item.m_ide_t             = tlp.m_ide_t;
      lut_item.m_ide_prefix_present  = tlp.m_ide_prefix_present;
    end

    //This is required for FLR case
    m_tl2hls_cpl_item[lut_item.m_req_tag].l_byte_count = lut_item.m_req_tlp_length;
    m_tl2hls_cpl_item[lut_item.m_req_tag].l_receive_time = $time;
    if (tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr) begin
      m_tl2hls_cpl_item[lut_item.m_req_tag].m_req_length_bytes += lut_item.m_req_length_bytes;
    end
    else begin
      m_tl2hls_cpl_item[lut_item.m_req_tag].m_req_length_bytes = lut_item.m_req_length_bytes;
    end
    m_tl2hls_cpl_item[lut_item.m_req_tag].lbe = lut_item.m_req_tlp_lbe;
    m_tl2hls_cpl_item[lut_item.m_req_tag].fbe = lut_item.m_req_tlp_fbe;

    //`uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager tlp = %0s",tlp.sprint()), UVM_DEBUG)
    //It is required for Module level FLR case, If FLRed completion is received and at the same time link side completion was pushed into the cxs queue.
    //there is no way to flush out that packet. In that case, we are delaying the packet with reused tag to predict unexp completion gracefully.
    repeat(m_lut_item_update_latency)
      @(posedge misc_if.core_clk);
    `uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager tlp = %0s",tlp.sprint()), UVM_DEBUG)
    compl_lut_obj.compl_lut[lut_item.m_req_tag] = lut_item;
    //`uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager request tlp = %0s",tlp.sprint()), UVM_DEBUG)
    //`uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager compl_lut_obj.compl_lut = %0p",compl_lut_obj.compl_lut), UVM_DEBUG)
    //foreach (compl_lut_obj.compl_lut[i]) begin
    //  `uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager compl_lut_obj.compl_lut[%0s] = %0s",i,compl_lut_obj.compl_lut[i].sprint()), UVM_DEBUG)
    //end
    `uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager lut_item = %0s",lut_item.sprint()), UVM_DEBUG)
    //`uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager compl_lut_obj.compl_lut[%0d].m_req_tag = %0d", lut_item.m_req_tag, compl_lut_obj.compl_lut[lut_item.m_req_tag].m_req_tag), UVM_DEBUG)
    //`uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager compl_lut_obj.compl_lut[%d].vip_userdata = %0s",lut_item.m_req_tag, compl_lut_obj.compl_lut[lut_item.m_req_tag].vip_userdata.sprint()), UVM_DEBUG)
    //if(tlp.vip_userdata == null)
    //  `uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager vip_userdata is null"), UVM_DEBUG)
    //else
    //  `uvm_info(get_type_name(), $psprintf("DEBUG::COMPL_LUT_ITEM::tag_manager vip_userdata = %0s",tlp.vip_userdata.sprint()), UVM_DEBUG)

  endtask : generate_compl_lut_item

  //-----------------------------------------------------------------------------
  // Method: write_ib_compl_cbport 
  // This function gets triggered by import port
  //-----------------------------------------------------------------------------
  virtual function void write_ib_compl_cbport(cdn_hpa_pcie_tlp packet);
    cdn_hpa_pcie_tlp cpl;
    bit [13:0] l_tag;
    int qi[$], qv[$];
    int qd[$];
    bit errored_completion = 0;

    `uvm_info(get_type_name(), $sformatf("received completion at ib_compl_cbport"), UVM_DEBUG)
    if(!$cast(cpl, packet))
      `uvm_fatal(get_full_name(), "Cast Failed!!!")
    if(!cpl.is_cpl())
      `uvm_fatal(get_full_name(), "The recived TLP on the Completion Interface is not a Completion type TLP")
    l_tag = {cpl.m_tlp_14_bit_tagscale, cpl.m_tlp_t9, cpl.m_tlp_t8, cpl.m_tlp_tag};
    `uvm_info(get_type_name(), $sformatf("received completion with tag= %0d",l_tag), UVM_DEBUG)

    qv = m_consumed_tags.find(x) with (x == l_tag);
    if(qv.size() == 0) begin
      qd = m_discarded_tags.find(x) with (x == l_tag);
      if((qd.size() == 0) && (m_pcie_strap_cfg.strap_port_type inside {0,1}))
        `uvm_error(get_type_name(), $sformatf("IB completion Tag is not available in the consumed tags.. UnExpected Completion for Tag : %0d (dec)",l_tag))
    end
    else
    begin
      qi = m_consumed_tags.find_index(x) with (x == l_tag);
      if(cpl.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl}) begin
        compl_lut_obj.compl_lut[l_tag].m_req_length_bytes = 0;
      end
      else begin // CDN_HPA_PCIE_TLP_TYPE_CplD, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD, UIORdCpl, UIOWrCpl
        if(compl_lut_obj.compl_lut[l_tag].m_req_tlp_at_type == 1 /*TR*/) begin
          if(cpl.m_tlp_cpl_byte_cnt > cpl.m_tlp_length*4) //(Byte_cnt > length*4) => additional completion will come, else final completion
            compl_lut_obj.compl_lut[l_tag].m_req_length_bytes = compl_lut_obj.compl_lut[l_tag].m_req_length_bytes - cpl.get_length_in_bytes();
          else
            compl_lut_obj.compl_lut[l_tag].m_req_length_bytes = 0; //Make it as final completion
        end else begin
          compl_lut_obj.compl_lut[l_tag].m_req_length_bytes = compl_lut_obj.compl_lut[l_tag].m_req_length_bytes - cpl.get_length_in_bytes(); 
        end
      end
      //Required for the sync. If packet received at the same time when FLR initiated.
      //It is unpredicatable that packet will drop or not.
      //We are creating the FLRed completion for that packet while checking the drop packet.
      m_tl2hls_cpl_item[l_tag].pkt_reach_to_client++;

      `uvm_info(get_type_name(), $sformatf("received completion = %0s,  compl_lut_obj.compl_lut[%0d]=%0s", cpl.sprint(), l_tag, compl_lut_obj.compl_lut[l_tag].sprint()), UVM_DEBUG)
      `uvm_info(get_type_name(), $sformatf("received completion with status= %0p, compl_lut_obj.compl_lut[l_tag].m_req_length_bytes =%0d, cpl.hls_ib_cpl_meta_s.cpl_err_code =%0b",cpl.m_tlp_cpl_status, compl_lut_obj.compl_lut[l_tag].m_req_length_bytes, cpl.hls_ib_cpl_meta_s.cpl_err_code), UVM_DEBUG)
      if((cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_TLP_POISONED) || //poisoned error 
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_BYTE_CNT_MIS) || //completion with no data or byte count mismatch 
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_ATTR_MIS) || //tag is same but TC/request ID/attr is not same as request 
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_INVALID_TAG) || //tag is invalid 
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_LOW_ADDR_MIS) || //error in start address 
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_TO) || //terminated by completion timeout 
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_FLR) || //terminated by FLR that targeted function generating this request 
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == 4'b1010) || //terminated with RCB violation/unexpected RRS
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_UR_ERR) || //completion with UR status
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_CA) || //completion with CA status
         (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_CRS_MRS))   //completion with RRS(CRS/MRS) status - expected
      begin // errored completion
        `uvm_info(get_type_name(), $sformatf("DEBUG_ERR::has_err = 1 Errored completion cpl.hls_ib_cpl_meta_s.cpl_err_code =%0b",cpl.hls_ib_cpl_meta_s.cpl_err_code), UVM_NONE)
        // wait for all completions (with or without errors) for UIO
        if (!(cpl.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl})) begin
          errored_completion = 1;
        end
      end
      if(cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_TO) m_pcie_dev_top_cfg.dut_incurred_cpl_timeout=1; 
      else  m_pcie_dev_top_cfg.dut_incurred_cpl_timeout=0;
      // Track the last Completion
      if(compl_lut_obj.compl_lut[l_tag].m_req_length_bytes == 0 || cpl.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC || 
         (errored_completion == 1) || (cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_TO)/*cpl.hls_ib_cpl_meta_s.cpl_err_code == 4'b1001*/) begin // FLRed Cpl 
        //$display("Recevied a FLR completion %0d", cpl.hls_ib_cpl_meta_s.cpl_err_code);
        `uvm_info(get_type_name(), $sformatf("in received completion with status= %0p, compl_lut_obj.compl_lut[l_tag].m_req_length_bytes =%0d, cpl.hls_ib_cpl_meta_s.cpl_err_code =%0b",cpl.m_tlp_cpl_status, compl_lut_obj.compl_lut[l_tag].m_req_length_bytes, cpl.hls_ib_cpl_meta_s.cpl_err_code), UVM_DEBUG)

        //Linkside tag manager will not have this metadata field
        if(cpl.hls_ib_cpl_meta_s.cpl_complete || link_side || ((compl_lut_obj.compl_lut[l_tag].m_req_length_bytes == 0) && (m_pcie_strap_cfg.strap_port_type inside {2,3})) || ($test$plusargs("PXC"))) begin
          hls_ib_compl_received_count++;
          if (cpl.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl && link_side) begin
            if (compl_lut_obj.compl_lut[l_tag].m_req_length_bytes == 0 || (cpl.hls_ib_cpl_meta_s.cpl_err_code !=0)) begin
              // Remove the entry from the LUT item
              compl_lut_obj.compl_lut.delete(l_tag);
              // Release the tag
              m_consumed_tags.delete(qi[0]);
              // // Resusing the released tag first
              // m_available_tags.push_front(l_tag);
            end
          end
          else begin
            // Remove the entry from the LUT item
            compl_lut_obj.compl_lut.delete(l_tag);
            // Release the tag
            m_consumed_tags.delete(qi[0]);
            // Resusing the released tag first
            m_available_tags.push_front(l_tag);
          end
          tag_exhausted = 0;
          //m_available_tags.insert(l_tag, l_tag);
          `uvm_info(get_full_name(), $psprintf("Inserted Cpl space of tag=%0h",l_tag), UVM_DEBUG)
          `uvm_info(get_full_name(), $psprintf("DBG_AFTER_CPL_RX_TAG_MANAGER: Availble tags %p", m_available_tags), UVM_DEBUG)
          `uvm_info(get_full_name(), $psprintf("DBG_AFTER_CPL_RX_TAG_MANAGER: consumed %p", m_consumed_tags), UVM_DEBUG)
          //This is required for FLR case
          m_tl2hls_cpl_item.delete({cpl.m_tlp_14_bit_tagscale, cpl.m_tlp_t9, cpl.m_tlp_t8, cpl.m_tlp_tag});
          if(cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_FLR) begin
            m_released_tag_by_flr[l_tag] = l_tag;
            m_flred_tags.push_back(l_tag);
          end
          if(cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_TO)
            m_released_tag_by_cpl_TO[l_tag] = l_tag;
          if(cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_SC)
            m_released_tag[l_tag] = l_tag;
        end
      end
    end

  endfunction

  //-----------------------------------------------------------------------------
  // Method:  write_tl2hls_compl_cbport
  // This function gets triggered by import port and update the cpl byte count 
  // for FLR expected packet
  //-----------------------------------------------------------------------------
  virtual function void write_tl2hls_compl_cbport(cdn_hpa_pcie_tlp cpl_req);
    bit [13:0] l_tag;

    //This is required for FLR case
    l_tag = {cpl_req.m_tlp_14_bit_tagscale, cpl_req.m_tlp_t9, cpl_req.m_tlp_t8, cpl_req.m_tlp_tag};
    `uvm_info(get_full_name(), $psprintf("write_tl2hls_compl_cbport: m_tl2hls_cpl_item[%0h] %p", l_tag, m_tl2hls_cpl_item[l_tag]), UVM_DEBUG)
    m_tl2hls_cpl_item[l_tag].l_prev_byte_count = cpl_req.m_tlp_cpl_byte_cnt;
    m_tl2hls_cpl_item[l_tag].l_receive_time    = $time;
    m_tl2hls_cpl_item[l_tag].pkt_reach_to_hls++;

    if(cpl_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl) begin
      m_tl2hls_cpl_item[l_tag].l_byte_count = 0;
    end
    else begin // CDN_HPA_PCIE_TLP_TYPE_cpl_reqD
      if(m_tl2hls_cpl_item[l_tag].m_np_req_tlp_at_type == 1 /*CDN_HPA_PCIE_AT_Translation_Request*/) begin
        if(cpl_req.m_tlp_cpl_byte_cnt > cpl_req.m_tlp_length*4) //(Byte_cnt > length*4) => additional completion will come, else final completion
          m_tl2hls_cpl_item[l_tag].m_req_length_bytes  = m_tl2hls_cpl_item[l_tag].m_req_length_bytes - cpl_req.get_length_in_bytes();
        else
          m_tl2hls_cpl_item[l_tag].m_req_length_bytes = 0; //Make it as final completion
      end else begin
        //m_tl2hls_cpl_item[l_tag].m_req_length_bytes  = m_tl2hls_cpl_item[l_tag].m_req_length_bytes - cpl_req.get_length_in_bytes();
        ////if((m_tl2hls_cpl_item[l_tag].m_req_length_bytes < 'd128) && (m_tl2hls_cpl_item[l_tag].m_req_length_bytes > 'd0))
        //  m_tl2hls_cpl_item[l_tag].m_req_length_bytes = m_tl2hls_cpl_item[l_tag].m_req_length_bytes- (m_tl2hls_cpl_item[l_tag].lbe[3] ? 0 :
        //                                                                                              m_tl2hls_cpl_item[l_tag].lbe[2] ? 1 :
        //                                                                                              m_tl2hls_cpl_item[l_tag].lbe[1] ? 2 :
        //                                                                                              m_tl2hls_cpl_item[l_tag].lbe[0] ? 3 : 0);
        m_tl2hls_cpl_item[l_tag].m_req_length_bytes = (cpl_req.m_tlp_cpl_lower_addr[1:0] == 2'b00) ?
                                                      cpl_req.m_tlp_cpl_byte_cnt - cpl_req.m_tlp_length*4 :
                                                      cpl_req.m_tlp_cpl_byte_cnt - cpl_req.m_tlp_length*4 + (4 - $countones(m_tl2hls_cpl_item[l_tag].fbe));
      end
      m_tl2hls_cpl_item[l_tag].first_cpl=0;
    end
    
    `uvm_info(get_full_name(), $psprintf("write_tl2hls_compl_cbport: m_tl2hls_cpl_item[%0h] %p", l_tag, m_tl2hls_cpl_item[l_tag]), UVM_DEBUG)
    
  endfunction : write_tl2hls_compl_cbport

  //-----------------------------------------------------------------------------
  // Method:  write_tl2hls_compl_cbport
  // This function gets triggered by import port for tl2hls nonposted dropped packet
  // in case of FLR and Release the tag from tl2hls tag manager
  //-----------------------------------------------------------------------------
  virtual function void write_tl2hls_np_cbport(cdn_hpa_pcie_tlp np_req);
    bit [13:0] l_tag;

    //This is required for
    l_tag = {np_req.m_tlp_14_bit_tagscale, np_req.m_tlp_t9, np_req.m_tlp_t8, np_req.m_tlp_tag};
    release_tag(l_tag);
    `uvm_info(get_full_name(),$sformatf("Releasing m_tlp_tag='h%0h ",l_tag),UVM_DEBUG)
    
  endfunction : write_tl2hls_np_cbport

  virtual function void write_ob_np_req_cbport(cdn_hpa_pcie_tlp np_req);

    //if(!(np_req.is_np_req()))
    //  `uvm_fatal(get_full_name(), "Posted request is requesting for TAG!!!")

    np_req_q.push_back(np_req);

  endfunction

  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  // Should new the TLM Analysis ports and the coverage groups.
  //------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);

    ib_compl_cbport_export = new("ib_compl_cbport_export", this);
    ob_np_req_cbport_export = new("ob_np_req_cbport_export", this);

    ib_exp_compl_to_flr_req_ap = new("ib_exp_compl_to_flr_req_ap", this);
    
    dpc_ib_compl_req_ap = new("dpc_ib_compl_req_ap", this);

    tl2hls_compl_cbport_export = new("tl2hls_compl_cbport_export", this);

    tl2hls_np_cbport_export = new("tl2hls_np_cbport_export", this);

    cg__generic_seen_normal_tag_reuse = new("cg__generic_seen_normal_tag_reuse");
    cg__generic_seen_flred_tag_reuse = new("cg__generic_seen_flred_tag_reuse");
    cg__generic_seen_cpl_timeout_tag_reuse = new("cg__generic_seen_cpl_timeout_tag_reuse");

  endfunction : new

  //------------------------------------------------------------------------
  // Function: build_phase
  //------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(cdn_pcie_strap_top_config)::get(this, "", "i_cfg", m_pcie_strap_cfg)) begin
      `uvm_fatal(get_type_name(), "Cannot get strap config object from UVM config DB")
    end

    if(is_active == UVM_ACTIVE) begin
      m_ob_np_tlp_sqr = new[m_pcie_strap_cfg.k_num_cifs];
      m_ob_np_cxs_sqr = new[m_pcie_strap_cfg.k_num_cifs];
      for (int i = 0; i < m_pcie_strap_cfg.k_num_cifs; i++) begin
        m_ob_np_cxs_sqr[i] = new[m_num_hls_ports];
      end
      tlp2cxs_np_seq  = new[m_pcie_strap_cfg.k_num_cifs];

      //foreach (m_ob_np_tlp_sqr[i]) begin
      for (int i = 0; i< m_pcie_strap_cfg.k_num_cifs; i++) begin
        m_ob_np_tlp_sqr[i] = cdn_hpa_pcie_tlp_vseqr::type_id::create($sformatf("m_ob_np_tlp_sqr[%1d]", i), this);
     end
    end
    compl_lut_obj = cdn_pcie_hpa_compl_wrapper::type_id::create("compl_lut_obj", this);

    if(!uvm_config_db#(virtual cdn_pcie_hpa_misc_if)::get(this, "", "hpa_misc_if", misc_if))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".misc_if"})

  endfunction: build_phase

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TODO :::
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TODO :::
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TODO :::
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TODO :::
    //if((m_consumed_tags.size !=0)) begin
    //   `uvm_error("TAG_MANAGER",$psprintf("consumed tag queue is not empty (completions pending for  =%0d tags)", m_consumed_tags.size()))
    //end
  endfunction : report_phase

  //------------------------------------------------------------------------
  // Function: connect_phase
  // Extend the connect method to connect up the virtual interfaces
  // and ports.
  //------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

  endfunction : connect_phase
  
  //------------------------------------------------------------------------
  // Function: end_of_elaboration_phase
  //------------------------------------------------------------------------
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

  endfunction : end_of_elaboration_phase

endclass : cdn_pcie_hpa_tag_manager 

`endif

//----------------------------------------------------------------------------
// End of file
//-------------------------------------------------
