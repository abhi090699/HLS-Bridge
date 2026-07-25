//-----------------------------------------------------------------------------
`ifndef CDN_PCIE_HPA_CIF_TLP_ROUTER_SV
`define CDN_PCIE_HPA_CIF_TLP_ROUTER_SV

class cdn_pcie_hpa_cif_tlp_router extends cdnpcie_driver#(cdn_hpa_pcie_tlp);

  //------------------------------------------------------------------------
  // CONTROL KNOBS
  //------------------------------------------------------------------------
  //cdn_pcie_hpa_dev_cfg dev_cfg;
  cdn_pcie_hpa_compl_wrapper     EI_compl_lut_obj;

  //---------------------------------------------------------------------------
  // Field: cdn_pcie_hpa_tlp2cxs_seq_h
  // This is a handler to tlp to cxs conversion sequence
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_tlp2cxs_seq    cdn_pcie_hpa_tlp2cxs_seq_h [];

  //---------------------------------------------------------------------------
  // Field: tlp2cxs_compl_seq
  // This is a handler to tlp to cxs conversion sequence
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_tlp2cxs_seq    tlp2cxs_compl_seq [];

  //---------------------------------------------------------------------------
  // Field: tlp2cxs_cfg2ib_compl_seq
  // This is a handler to tlp to cxs conversion sequence
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_tlp2cxs_seq    tlp2cxs_cfg2ib_compl_seq;

  //---------------------------------------------------------------------------
  // Field: tlp2cxs_intrpt2ib_seq
  // This is a handler to tlp to cxs conversion sequence
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_tlp2cxs_seq    tlp2cxs_intrpt2ib_seq;

  //---------------------------------------------------------------------------
  // Field: rand_intx_seq
  // This is a handler to tlp to intx sequence
  //---------------------------------------------------------------------------
  //cdn_pcie_hpa_intx_seq       rand_intx_seq [];

  //---------------------------------------------------------------------------
  // Field: rand_intx_seq
  // This is a handler to tlp to intx sequence
  //---------------------------------------------------------------------------
  cdn_pcie_intx_sequence_lib      rand_intx_seq [];


  //---------------------------------------------------------------------------
  // Field: rand_msi_msix_seq
  // This is a handler to tlp to msi/msix sequence
  //---------------------------------------------------------------------------
  //cdn_pcie_hpa_msi_msix_seq   rand_msi_msix_seq;

  //------------------------------------------------------------------------
  // field: rand_msi_msix_seq
  //  This is handle for msi msix sequence
  //------------------------------------------------------------------------
  cdn_pcie_msi_msix_sequence_lib rand_msi_msix_seq;

  // LUT with tag as the key
  cdn_pcie_hpa_compl_wrapper  compl_lut_obj;
  cdn_pcie_hpa_compl_wrapper  compl_lut_obj_10_bit;
  cdn_pcie_hpa_compl_wrapper  compl_lut_obj_14_bit;
  cdn_pcie_hpa_compl_wrapper  compl_lut_obj_p_uio;
  bit                         is_cpl_split_disabled;
  int unsigned                m_num_tlps_per_clk;
  bit                         is_uio_out_of_order_cpl_disabled;

  cdn_hpa_pcie_tlp            cpl_trans_q[$];

  // For Intx pkts
  cdn_hpa_pcie_tlp            hpa_pkt_intx_a_q[$];
  cdn_hpa_pcie_tlp            hpa_pkt_intx_b_q[$];
  cdn_hpa_pcie_tlp            hpa_pkt_intx_c_q[$];
  cdn_hpa_pcie_tlp            hpa_pkt_intx_d_q[$];

  // For MSI/MSIX pkts
  cdn_hpa_pcie_tlp            hpa_pkt_msi_msix_q[$];
  cdn_hpa_pcie_tlp            cpl_timeout_drop_tlp_q[$];

  typedef enum bit [1:0] {WAIT, DRIVE, DELAY, STOP} interrupt_state;
  interrupt_state intr_state;
  interrupt_state msi_msix_state;

  bit [1:0]                   intr_a=0;
  bit [1:0]                   intr_b=1;
  bit [1:0]                   intr_c=2;
  bit [1:0]                   intr_d=3;
  bit                         send_sc_cpl;
  cdn_hpa_pcie_tlp            m_rrs_retry_cfg_schedule[bit[13:0]];

  int                         intx_pin_delay;
  int                         msi_msix_pin_delay;

  //---------------------------------------------------------------------------
  // Field: same_assert_msg_ob
  // Flag to segregate duplicate INTx assert messages
  //---------------------------------------------------------------------------
  bit [3:0] same_assert_msg_ob;
  bit [3:0] stop_intx;
  bit       link_side;


  rand shortint unsigned      np_cpl_length;
  rand shortint unsigned      p_cpl_length;
  rand shortint unsigned      cpl_trans_num;
  rand shortint unsigned      cpl_trans_id;
  rand bit [7:0]              cpl_payload[];
  rand cdn_hpa_pcie_cpl_status_type_t temp_cpl_status;
  bit                         pri_intx_msg;
  bit                         pri_msi_msix_msg;
  bit                         pri_cpl_delay;
  int                         cpl_delay;
  bit [7:0]                   m_num_dut_pf;
  bit                         k_msi_en;
  bit                         m_msi_en;
  bit [31:0]                  msi_mask;
  bit                         msix_en;
  bit                         msix_mask;
  bit 			                  reset_in_progress;
  bit                         puresuite_test;
  int unsigned                num_of_timeout_pkt;
  bit [13:0]                  m_flred_cpl_q[$];
  bit                         stream_id_found;
  rand bit                    expect_end_error;
  
  //-----------------------------------------------------------------------------
  // Field: m_num_hls_ports 
  // Number of HLS Ports. 
  //-----------------------------------------------------------------------------
  int unsigned                m_num_hls_ports = 1;

  //-----------------------------------------------------------------------------
  // Field: m_enable_pkt_gaps
  // Flag to Enable pkt gaps in a CXS Flit. 
  //-----------------------------------------------------------------------------
  bit m_enable_pkt_gaps = 0;

  //---------------------------------------------------------------------------
  // Field: is_hls_module_tb
  // Flag which is set to 1 if running hls_module_tb simulations.
  //---------------------------------------------------------------------------
  bit is_hls_module_tb = 0;
  
  //---------------------------------------------------------------------------
  // Field: m_pcie_dev_cfg
  // This is a handler to function level config
  // Holds all the PCIe device capability info
  // Holds the info about BARs
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_dev_config                    m_pcie_dev_cfg;

  //---------------------------------------------------------------------------
  // Field: m_pcie_dev_top_cfg
  // This is a handler to device level config
  // Holds all the function config handles
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_dev_top_config m_pcie_dev_top_cfg;

  //---------------------------------------------------------------------------
  // Field: m_ide_cfg
  // This is a handler to device level config
  // Holds all the function config handles
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_ide_config m_ide_cfg;

  //---------------------------------------------------------------------------
  // Field: m_pcie_link_cfg
  // This is a handle to link level config
  // Holds configurations of upstream and downstream devices
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_link_config    m_pcie_link_cfg;

  //---------------------------------------------------------------------------
  // Field: m_pcie_strap_cfg
  // This is a handle to strap config
  //---------------------------------------------------------------------------
  cdn_pcie_strap_top_config   m_pcie_strap_cfg;

  //---------------------------------------------------------------------------
  // Field: m_dut_mode
  // Points the DUT mode
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_config_pkg::cdn_dut_mode_e    m_dut_mode;

  //---------------------------------------------------------------------------
  // Field: misc_if
  // Points the misc if of HLS module TB
  //---------------------------------------------------------------------------
  //`ifndef HLS_MODULE_MODE
  virtual cdn_pcie_hpa_misc_if   misc_if;
  //`endif

  //------------------------------------------------------------------------
  // TLM Ports.
  //------------------------------------------------------------------------
  // Analysis port to send the Expected item to the score board
  //---------------------------------------------------------------------------
  // Field: ob_np_req_ap
  // Routes the NP TLPs to tag manager
  //---------------------------------------------------------------------------
  uvm_analysis_port #(cdn_hpa_pcie_tlp) ob_np_req_ap;

  //---------------------------------------------------------------------------
  // Field: ob_uio_p_req_ap
  // Routes the P TLPs to tag manager
  //---------------------------------------------------------------------------
  uvm_analysis_port #(cdn_hpa_pcie_tlp) ob_uio_p_req_ap;

  //---------------------------------------------------------------------------
  // Field: ob_10_bit_tag_np_req_ap
  // Routes the NP TLPs to 10 bit tag manager if supports
  //---------------------------------------------------------------------------
  uvm_analysis_port #(cdn_hpa_pcie_tlp) ob_10_bit_tag_np_req_ap;

  //---------------------------------------------------------------------------
  // Field: ob_10_bit_tag_p_req_ap
  // Routes the P TLPs to 10 bit tag manager if supports
  //---------------------------------------------------------------------------
  uvm_analysis_port #(cdn_hpa_pcie_tlp) ob_10_bit_tag_p_req_ap;

  //---------------------------------------------------------------------------
  // Field: ob_14_bit_tag_np_req_ap
  // Routes the NP TLPs to 14 bit tag manager if supports
  //---------------------------------------------------------------------------
  uvm_analysis_port #(cdn_hpa_pcie_tlp) ob_14_bit_tag_np_req_ap;
  
  //---------------------------------------------------------------------------
  // Field: ob_14_bit_tag_p_req_ap
  // Routes the P TLPs to 14 bit tag manager if supports
  //---------------------------------------------------------------------------
  uvm_analysis_port #(cdn_hpa_pcie_tlp) ob_14_bit_tag_p_req_ap;

  //---------------------------------------------------------------------------
  // Field:  ib_exp_compl_to_TO_req_ap
  // Received cpl TO through AP
  //---------------------------------------------------------------------------
  uvm_analysis_port #(cdn_hpa_pcie_tlp) ib_exp_compl_to_TO_req_ap;
  uvm_analysis_port #(cdn_hpa_pcie_tlp) ib_exp_p_compl_to_TO_req_ap;


  //---------------------------------------------------------------------------
  // Field:  lti_ib_compl_af
  // Implementation of the lti_completion
  //---------------------------------------------------------------------------
`ifdef HAS_ARM
  uvm_tlm_analysis_fifo #(bit [parameters_cfg_pkg::LTI_C_TDATA_WIDTH-1:0]) lti_ib_compl_af;
`endif

  // Implementation of the analysis port for the in the dut_input direction.
 `uvm_analysis_imp_decl(_ib_np_req_port)
  uvm_analysis_imp_ib_np_req_port#(cdn_hpa_pcie_tlp, cdn_pcie_hpa_cif_tlp_router) ib_np_req_export;
 `uvm_analysis_imp_decl(_ib_p_req_port)
  uvm_analysis_imp_ib_p_req_port#(cdn_hpa_pcie_tlp, cdn_pcie_hpa_cif_tlp_router) ib_p_req_export;

  // Implementation of the analysis port for the out the dut_output direction
 `uvm_analysis_imp_decl(_ib_compl_cbport)
  uvm_analysis_imp_ib_compl_cbport #(cdn_hpa_pcie_tlp, cdn_pcie_hpa_cif_tlp_router) ib_compl_cbport_export;



  //------------------------------------------------------------------------
  // STATUS MEMBER VARIABLES
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // EVENTS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // COMPONENTS
  //------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Field: m_ob_p_tlp_sqr
  // back pointer to tlp sequencers
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_vseqr       m_ob_p_tlp_sqr[];

  //---------------------------------------------------------------------------
  // Field: m_ob_cpl_tlp_sqr
  // back pointer to tlp sequencers
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_vseqr       m_ob_cpl_tlp_sqr[];

  //---------------------------------------------------------------------------
  // Field: m_ob_cpl_tlp_sqr
  // back pointer to tlp sequencers
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_vseqr       m_cfg2ib_cpl_tlp_sqr;

  //---------------------------------------------------------------------------
  // Field: m_intrpt2ib_cpl_tlp_sqr
  // back pointer to tlp sequencers
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_vseqr       m_intrpt2ib_cpl_tlp_sqr;

  //---------------------------------------------------------------------------
  // Field: m_ob_p_cxs_sqr
  // back pointer to CXS sequencers
  //---------------------------------------------------------------------------
  cdnCxsUvmSequencer           m_ob_p_cxs_sqr[][];

  //---------------------------------------------------------------------------
  // Field: m_ob_compl_cxs_sqr
  // back pointer to CXS sequencers
  //---------------------------------------------------------------------------
  cdnCxsUvmSequencer           m_ob_compl_cxs_sqr[][];

  //---------------------------------------------------------------------------
  // Field: m_cfg2ib_compl_cxs_sqr
  // back pointer to CXS sequencers
  //---------------------------------------------------------------------------
  cdnCxsUvmSequencer           m_cfg2ib_compl_cxs_sqr;

  //---------------------------------------------------------------------------
  // Field: m_intrpt2ib_cxs_sqr
  // back pointer to CXS sequencers
  //---------------------------------------------------------------------------
  cdnCxsUvmSequencer           m_intrpt2ib_cxs_sqr;

  //---------------------------------------------------------------------------
  // Field: m_ob_p_intx_sqr
  // back pointer to intx sequencers
  //---------------------------------------------------------------------------
  cdn_pcie_intx_sequencer      m_ob_p_intx_sqr[];

  //---------------------------------------------------------------------------
  // Field: m_ob_p_msi_msix_sqr
  // back pointer to msx/msix sequencers
  //---------------------------------------------------------------------------
  cdn_pcie_msi_msix_sequencer  m_ob_p_msi_msix_sqr[];

  //---------------------------------------------------------------------------
  // Field: dev_seqr
  // back pointer to device sequencers
  //---------------------------------------------------------------------------
  cdnpcie_sequencer            dev_seqr;

  //---------------------------------------------------------------------------
  // Field:  m_cpl_timeout_tag_q
  // storage element for exp timed out cpl tag
  //---------------------------------------------------------------------------
  bit[13:0] m_cpl_timeout_tag_q[bit[13:0]];

  //------------------------------------------------------------------------
  // Field : Timers
  // Used to wait for certain time duration
  //------------------------------------------------------------------------
  int m_time_1ns   = 1;
  int m_time_10ns  = 10;
  int m_time_100ns = 100;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
 `uvm_component_utils_begin(cdn_pcie_hpa_cif_tlp_router)
 `uvm_component_utils_end

  //------------------------------------------------------------------------
  // CHECKER FIELDS FOR COVERAGE OF CHECKERS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // BACK POINTERS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // METHODS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // DEFINE TASKS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Task: main_phase
  // The main_phase task for this class will be started automatically during
  // the main phase.
  //------------------------------------------------------------------------
  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);

    //extract ide config
    m_ide_cfg = m_pcie_dev_top_cfg.ide_cfg;

    //TODO check if require at Module TB, Since there is no such ports for MSI/INTX.
   `ifndef HLS_MODULE_MODE
      configure_interrupts_seq();
      fork // INTx
        drive_intx_task(intr_a, hpa_pkt_intx_a_q);
        drive_intx_task(intr_b, hpa_pkt_intx_b_q);
        drive_intx_task(intr_c, hpa_pkt_intx_c_q);
        drive_intx_task(intr_d, hpa_pkt_intx_d_q);
      join_none
      fork // MSI/MSIX
        drive_msi_msix_task(hpa_pkt_msi_msix_q);
      join_none
   `endif
    fork
      begin
        tlp_router();
      end
      begin
        if(link_side==1) monitor_flr_completion();
      end
    join_none

    fork
      detect_traffic();
    join_none

   `ifdef HAS_ARM
    if (parameters_cfg_pkg::LTI_SUPPORT && m_pcie_dev_top_cfg.i_cfg.strap_is_rp) begin
      fork
        lti_c_task();
      join_none
    end
   `endif

  endtask : main_phase

  //------------------------------------------------------------------------
  // Task: drive_intx_task
  // Driving INTx pin toggling
  //------------------------------------------------------------------------
  task automatic drive_intx_task(ref bit [1:0] interrupt, ref cdn_hpa_pcie_tlp hpa_pkt_intx_q[$]);
    cdn_pcie_hpa_pf_vf_s        pf_vf_s;
    cdn_pcie_hpa_pf_vf_s        pf_vf_s1;
    automatic bit [1:0] intr = interrupt;
    wait(reset_in_progress==0);
    while (reset_in_progress==0) begin
      begin
        case (intr_state)
          WAIT  : begin
            wait(hpa_pkt_intx_q.size() > 0 && reset_in_progress==0); //stop[interrupt]
            if(!m_pcie_dev_top_cfg.intx_pin_b2b) begin
              if (!std::randomize(intx_pin_delay) with {intx_pin_delay dist {0:=25,[1:2]:=25,[3:4]:=25,5:=25};}) `uvm_fatal(get_full_name(), "randomization failure");
             `ifndef HLS_MODULE_MODE
                repeat(intx_pin_delay)
                  @(posedge misc_if.core_clk);
             `else
                hpa_timer.wait_for_time(m_time_100ns, "drive_intx_task_wait", "ns");
             `endif
            end
            wait(!same_assert_msg_ob[intr] && reset_in_progress==0); //stop[interrupt]
            if(reset_in_progress==1)
              intr_state = STOP;
            else
              intr_state = DRIVE;
          end
          DRIVE : begin
            pf_vf_s1 = m_pcie_dev_top_cfg.get_pf_vf_from_req_id(hpa_pkt_intx_q[0].m_tlp_requester_id_tb);
            rand_intx_seq[intr].pin_number = hpa_pkt_intx_q[0].get_intx_pin_no;
            rand_intx_seq[intr].is_high = hpa_pkt_intx_q[0].get_assert_or_deassert;
            rand_intx_seq[intr].funtion_no = pf_vf_s1.pf;
            rand_intx_seq[intr].m_pcie_dev_cfg = m_pcie_dev_top_cfg.pf_config[pf_vf_s1.pf];
            rand_intx_seq[intr].tlp = hpa_pkt_intx_q.pop_front();       
        
            `uvm_info(get_name(),$psprintf("Pushing the INTX TLP %0s",rand_intx_seq[intr].tlp.sprint()),UVM_LOW)            
            rand_intx_seq[intr].start(m_ob_p_intx_sqr[0], null, -1); // Not required any sequencer
            //hpa_pkt_intx_q.delete(0);
            same_assert_msg_ob[intr] = 1;
            if(reset_in_progress==1)
              intr_state = STOP;
            else
              intr_state = DELAY;
          end
          DELAY : begin
           `ifndef HLS_MODULE_MODE
              @(negedge misc_if.core_clk iff misc_if.int_ack[intr] == 1);
           `else
              hpa_timer.wait_for_time(m_time_100ns, "drive_intx_task_delay", "ns");
           `endif
            same_assert_msg_ob[intr] = 0;
            if(reset_in_progress==1)
              intr_state = STOP;
            else
              intr_state = WAIT;
          end //delay
          STOP  : begin
           `uvm_info(get_full_name(), $sformatf("STOP ... intr %d",intr), UVM_LOW)
            same_assert_msg_ob[intr] = 1;
          end
        endcase
      end
    end
  endtask

  //------------------------------------------------------------------------
  // Task: drive_msi_msix_task
  // Driving msi/msix pin toggling
  //------------------------------------------------------------------------
  task automatic drive_msi_msix_task(ref cdn_hpa_pcie_tlp hpa_pkt_msi_msix_q[$]);
    cdn_pcie_hpa_pf_vf_s        pf_vf_s;
    cdn_pcie_hpa_pf_vf_s        pf_vf_s1;
    wait(reset_in_progress==0);
    while (reset_in_progress==0)  begin
      begin
        case (msi_msix_state)
          WAIT  : begin
            //`uvm_info(get_name(),$psprintf("msi_msix_state WAIT start hpa_pkt_msi_msix_q %d",hpa_pkt_msi_msix_q.size()),UVM_LOW)
            wait(hpa_pkt_msi_msix_q.size() > 0 && reset_in_progress==0); //stop[interrupt]
            if(!m_pcie_dev_top_cfg.msi_msix_pin_b2b) begin
              if (!std::randomize(msi_msix_pin_delay) with {msi_msix_pin_delay dist {0:=25,[1:2]:=25,[3:4]:=25,5:=25};}) `uvm_fatal(get_full_name(), "randomization failure");
             `ifndef HLS_MODULE_MODE
                repeat(msi_msix_pin_delay)
                  @(posedge misc_if.core_clk);
             `else
                hpa_timer.wait_for_time(m_time_100ns, "drive_msi_msix_task_wait", "ns");
             `endif
            end
            wait(reset_in_progress==0); //stop[interrupt]
            if(reset_in_progress==1)
              msi_msix_state = STOP;
            else
              msi_msix_state = DRIVE;
           `uvm_info(get_name(),$psprintf("msi_msix_state WAIT end hpa_pkt_msi_msix_q %d",hpa_pkt_msi_msix_q.size()),UVM_LOW)
          end
          DRIVE : begin // (DRIVE and DELAY both)
           `uvm_info(get_name(),$psprintf("msi_msix_state DRIVE end hpa_pkt_msi_msix_q %d",hpa_pkt_msi_msix_q.size()),UVM_LOW)
            rand_msi_msix_seq.tlp = hpa_pkt_msi_msix_q.pop_front();         //Assigning received tlp in cif router to the sequence tlp
            pf_vf_s1 = m_pcie_dev_top_cfg.get_pf_vf_from_req_id(rand_msi_msix_seq.tlp.m_tlp_requester_id);
            begin
              if(pf_vf_s1.is_vf_valid)
                rand_msi_msix_seq.m_pcie_dev_cfg = m_pcie_dev_top_cfg.vf_config[pf_vf_s1.pf][pf_vf_s1.vf];
              else
                rand_msi_msix_seq.m_pcie_dev_cfg = m_pcie_dev_top_cfg.pf_config[pf_vf_s1.pf];
            end
            rand_msi_msix_seq.pfnum = pf_vf_s1.pf;
            rand_msi_msix_seq.vfnum = pf_vf_s1.vf;
            rand_msi_msix_seq.is_vf = pf_vf_s1.is_vf_valid;
            rand_msi_msix_seq.requestor_id = {pf_vf_s1.is_vf_valid,pf_vf_s1.vf,pf_vf_s1.pf}; 
           `uvm_info(get_name(),$psprintf("Pushing the MSI/MSIX TLP %0s",rand_msi_msix_seq.tlp.sprint()),UVM_LOW)
            fork
              begin
             `uvm_info(get_name(),$psprintf("3m_pasid_prefix_present = %d, m_pasid_pri_value = %d,m_pasid_attr = %d, m_cap_ats_en =%d, pf_vf_s1.pf = %d,pf_vf_s1.vf= %d",rand_msi_msix_seq.tlp.m_pasid_prefix_present, rand_msi_msix_seq.tlp.m_pasid_pri_value,m_pcie_link_cfg.usp_dev_config.m_pasid_attr,m_pcie_dev_cfg.m_cap_ats_en, pf_vf_s1.pf, pf_vf_s1.vf),UVM_LOW)              
                `uvm_info(get_name(),$psprintf("Pushing the MSI/MSIX TLP %0s",rand_msi_msix_seq.tlp.sprint()),UVM_LOW)
                rand_msi_msix_seq.start(m_ob_p_msi_msix_sqr[0], null, -1); // Not required any sequencer
                //hpa_pkt_msi_msix_q.delete(0);
               m_pcie_dev_top_cfg.m_posted_tlp_sent++;
               `uvm_info("DEBUG_POSTED sent [MSI(x)_TLP]", $psprintf("m_posted_tlp_sent = %0d",m_pcie_dev_top_cfg.m_posted_tlp_sent),UVM_DEBUG);
              end
              begin
               `uvm_info(get_name(),$psprintf("msi_msix_state DRIVE Start hpa_pkt_msi_msix_q %d",hpa_pkt_msi_msix_q.size()),UVM_LOW)
               `uvm_info(get_name(),$psprintf("msi_msix_state DELAY misc_if.int_msg_done %d",misc_if.int_msg_done),UVM_LOW)
               `ifndef HLS_MODULE_MODE
                  @(negedge misc_if.core_clk iff misc_if.int_msg_done inside {1,2,3,4,5,6,7,8,9});
               `else
                  hpa_timer.wait_for_time(m_time_100ns, "drive_msi_msix_task_drive", "ns");
               `endif
               `uvm_info(get_name(),$psprintf("msi_msix_state DRIVE End hpa_pkt_msi_msix_q %d",hpa_pkt_msi_msix_q.size()),UVM_LOW)
              end
            join
            if(reset_in_progress==1)
              msi_msix_state = STOP;
            else
              msi_msix_state = WAIT;
          end //delay
          STOP  : begin
           `uvm_info(get_name(),$psprintf("msi_msix_state  STOP hpa_pkt_msi_msix_q %d",hpa_pkt_msi_msix_q.size()),UVM_LOW)
          end
        endcase
      end
    end
  endtask
  
  //------------------------------------------------------------------------
  // Task: lti_c_task
  // Driving LTI completion pins
  //------------------------------------------------------------------------
  `ifdef HAS_ARM
  task automatic lti_c_task();
    bit [parameters_cfg_pkg::LTI_C_TDATA_WIDTH-1:0] cdata;
    int                                             dly;
    bit [parameters_cfg_pkg::LTI_C_TDATA_WIDTH-1:0] cmpl_q[$];

    drive_lti_c_task(0, 0);

    fork
      // Thread 1 - pick completions from AP
      forever begin
        if (reset_in_progress==0) begin
          lti_ib_compl_af.get(cdata);
          cmpl_q.push_back(cdata);
        end
      end
      forever begin
        wait(reset_in_progress==0); 
        if (cmpl_q.size() > 0) begin
          if (misc_if.hot_reset_in == 1'b1)
            dly = $urandom_range(1, 5);
          else
            dly = $urandom_range(5, 100);
          repeat(dly)
            @(posedge misc_if.core_clk);
          cdata = cmpl_q[0];
          cmpl_q.delete(0);
          for(int ii = cmpl_q.size()-1; ii > 0; ii--) begin
            if (cmpl_q[ii][10:8] == cdata[10:8]) begin // Match LTI port ID and CTAG
              cdata[7:0]++;
              cmpl_q.delete(ii);
            end
            if (cdata[7:0] == 255) break; // Check if max 2^8 count is reached
          end
          drive_lti_c_task(1, cdata);
          @(posedge misc_if.core_clk);
          drive_lti_c_task(0, 0);
        end // if (lti_cmpl_q.size() > 0)
        else
          @(posedge misc_if.core_clk);            
      end // forever begin
    join_none

  endtask // drive_lti_c_task

  task automatic drive_lti_c_task(bit vld, bit [parameters_cfg_pkg::LTI_C_TDATA_WIDTH-1:0] cdata);
    bit [parameters_cfg_pkg::LTI_C_TDATA_WIDTH-1:0] cdata_inact;

    if (vld) begin
      misc_if.lti_c_tvalid <= 1'b1;
      misc_if.lti_c_tvalid_chk <= 1'b0;
      misc_if.lti_c_tdata <= cdata;
      misc_if.lti_c_tdata_chk[0] <= (($countones(cdata[7:0])+1) % 2);
      misc_if.lti_c_tdata_chk[1] <= (($countones(cdata[15:8])+1) % 2);
    end
    else begin
      void'(std::randomize(cdata_inact) with {cdata_inact dist {cdata:=1,0:=1,[1:(1<<parameters_cfg_pkg::LTI_C_TDATA_WIDTH)-1]:=1};});
      misc_if.lti_c_tvalid <= 1'b0;
      misc_if.lti_c_tvalid_chk <= 1'b1;
      misc_if.lti_c_tdata <= cdata_inact;
      misc_if.lti_c_tdata_chk[0] = (($countones(cdata_inact[7:0])+1) % 2);
      misc_if.lti_c_tdata_chk[1] = (($countones(cdata_inact[15:8])+1) % 2);
    end
  endtask // drive_lti_c_task

  `endif

  //------------------------------------------------------------------------
  // Task: kill_seq
  // kill all the bg sequnences in reset
  //------------------------------------------------------------------------
  virtual function void kill_seq();

    for (int i = 0; i< m_pcie_strap_cfg.k_num_cifs; i++) begin
      automatic int unsigned idx = i;
     `uvm_info(get_full_name(), $psprintf("Killing sub sequences for CIF %0d", i), UVM_DEBUG)
      m_ob_p_tlp_sqr[idx].stop_sequences();
      m_ob_cpl_tlp_sqr[idx].stop_sequences();
      tlp2cxs_compl_seq[idx].kill();
      cdn_pcie_hpa_tlp2cxs_seq_h[idx].kill();
      for (int j = 0; j < m_num_hls_ports; j++) begin 
        automatic int unsigned idx_hls_port = j;
        m_ob_p_cxs_sqr[idx][idx_hls_port].stop_sequences();
        m_ob_compl_cxs_sqr[idx][idx_hls_port].stop_sequences();
      end
    end
    if(tlp2cxs_cfg2ib_compl_seq)
      tlp2cxs_cfg2ib_compl_seq.kill();
    if(m_cfg2ib_cpl_tlp_sqr)
      m_cfg2ib_cpl_tlp_sqr.stop_sequences();
    if(m_cfg2ib_compl_cxs_sqr)
      m_cfg2ib_compl_cxs_sqr.stop_sequences();
    if(tlp2cxs_intrpt2ib_seq)
      tlp2cxs_intrpt2ib_seq.kill();
    if(m_intrpt2ib_cpl_tlp_sqr)
      m_intrpt2ib_cpl_tlp_sqr.stop_sequences();
    if(m_intrpt2ib_cxs_sqr)
      m_intrpt2ib_cxs_sqr.stop_sequences();
    for (int i = 0; i< m_pcie_strap_cfg.k_num_cifs; i++) begin
      automatic int unsigned idx = i;
      m_ob_p_intx_sqr[idx].stop_sequences();
      stop_intx[idx] = 1;
    end
    for (int i = 0; i< m_pcie_strap_cfg.k_num_cifs; i++) begin
      automatic int unsigned idx = i;
      m_ob_p_msi_msix_sqr[idx].stop_sequences();
    end
  endfunction

  //------------------------------------------------------------------------
  // Task: start_bg_seqs
  // Start all the CXS sequneces on the corrsponding CXS sequeners
  //------------------------------------------------------------------------
  virtual task start_bg_seqs();
    reset_in_progress = 0;
    fork
      begin : cpl_thread
        send_cpl_to_cxs();
      end
      begin : reset_flag
        wait(reset_in_progress==1);
        disable cpl_thread;
      end
    join_none

   `uvm_info(get_full_name(), $psprintf("start_bg_seqs "), UVM_DEBUG);
    for (int i = 0; i< m_pcie_strap_cfg.k_num_cifs; i++) begin
      fork
        automatic int unsigned idx = i;
        tlp2cxs_compl_seq[idx] = cdn_pcie_hpa_tlp2cxs_seq::type_id::create($sformatf("tlp2cxs_compl_seq[%1d]", idx));
        tlp2cxs_compl_seq[idx].m_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
        tlp2cxs_compl_seq[idx].misc_if            = misc_if;
        tlp2cxs_compl_seq[idx].m_num_hls_ports    = m_num_hls_ports;
        tlp2cxs_compl_seq[idx].p_cxs_sqr          = new[m_num_hls_ports];

        if(m_pcie_dev_top_cfg.scenario != null) begin
          tlp2cxs_compl_seq[idx].m_pkt_err_en = m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror;
          if(m_pcie_strap_cfg.k_hls_dw_alignment == 2)
            tlp2cxs_compl_seq[idx].m_pkt_gap_en = m_enable_pkt_gaps;
        end

        if(!$cast(tlp2cxs_compl_seq[idx].p_tlp_sqr, m_ob_cpl_tlp_sqr[idx]))
         `uvm_fatal(get_type_name(), "Cast failed !!")

        for (int j = 0; j < m_num_hls_ports; j++) begin 
          automatic int unsigned idx_hls_port = j;
          if(!$cast(tlp2cxs_compl_seq[idx].p_cxs_sqr[idx_hls_port], m_ob_compl_cxs_sqr[idx][idx_hls_port]))
            `uvm_fatal(get_type_name(), "Cast failed !!")
        end

        if(m_pcie_dev_top_cfg.hls_rx)
          tlp2cxs_compl_seq[idx].m_num_tlps_per_clk = m_pcie_strap_cfg.k_rx_num_tlps_per_clk;
        else
          tlp2cxs_compl_seq[idx].m_num_tlps_per_clk = m_pcie_strap_cfg.k_tx_num_tlps_per_clk;
        tlp2cxs_compl_seq[idx].start(dev_seqr, null, -1); // Not required any sequencer

        cdn_pcie_hpa_tlp2cxs_seq_h[idx] = cdn_pcie_hpa_tlp2cxs_seq::type_id::create($sformatf("cdn_pcie_hpa_tlp2cxs_seq_h[%1d]", idx));
        cdn_pcie_hpa_tlp2cxs_seq_h[idx].m_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
        cdn_pcie_hpa_tlp2cxs_seq_h[idx].misc_if            = misc_if;
        cdn_pcie_hpa_tlp2cxs_seq_h[idx].m_num_hls_ports    = m_num_hls_ports;
        cdn_pcie_hpa_tlp2cxs_seq_h[idx].p_cxs_sqr          = new[m_num_hls_ports];
        
        if(m_pcie_dev_top_cfg.scenario != null) begin
          cdn_pcie_hpa_tlp2cxs_seq_h[idx].m_pkt_err_en = m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror;
          if(m_pcie_strap_cfg.k_hls_dw_alignment == 2)
            cdn_pcie_hpa_tlp2cxs_seq_h[idx].m_pkt_gap_en = m_enable_pkt_gaps;
        end

        if(!$cast(cdn_pcie_hpa_tlp2cxs_seq_h[idx].p_tlp_sqr, m_ob_p_tlp_sqr[idx]))
         `uvm_fatal(get_type_name(), "Cast failed !!")
        
        for (int j = 0; j < m_num_hls_ports; j++) begin 
          automatic int unsigned idx_hls_port = j;
          if(!$cast(cdn_pcie_hpa_tlp2cxs_seq_h[idx].p_cxs_sqr[idx_hls_port], m_ob_p_cxs_sqr[idx][idx_hls_port]))
            `uvm_fatal(get_type_name(), "Cast failed !!")
        end

        if(m_pcie_dev_top_cfg.hls_rx)
          cdn_pcie_hpa_tlp2cxs_seq_h[idx].m_num_tlps_per_clk = m_pcie_strap_cfg.k_rx_num_tlps_per_clk;
        else
          cdn_pcie_hpa_tlp2cxs_seq_h[idx].m_num_tlps_per_clk = m_pcie_strap_cfg.k_tx_num_tlps_per_clk;
        cdn_pcie_hpa_tlp2cxs_seq_h[idx].start(dev_seqr, null, -1); // Not required any sequencer

       `ifndef HLS_MODULE_MODE
         // if(!$cast(rand_intx_seq[0].intx_seqr, m_ob_p_intx_sqr[0])) `uvm_fatal(get_type_name(), "Cast failed !!");
         // if(!$cast(rand_intx_seq[1].intx_seqr, m_ob_p_intx_sqr[0])) `uvm_fatal(get_type_name(), "Cast failed !!");
         // if(!$cast(rand_intx_seq[2].intx_seqr, m_ob_p_intx_sqr[0])) `uvm_fatal(get_type_name(), "Cast failed !!");
         // if(!$cast(rand_intx_seq[3].intx_seqr, m_ob_p_intx_sqr[0])) `uvm_fatal(get_type_name(), "Cast failed !!");
         // if(!$cast(msi_msix_seqr, m_ob_p_msi_msix_sqr[0])) `uvm_fatal(get_type_name(), "Cast failed !!");
       `endif
      join_none
    end

    if(link_side) begin
      fork
        begin
          tlp2cxs_cfg2ib_compl_seq = cdn_pcie_hpa_tlp2cxs_seq::type_id::create($sformatf("tlp2cxs_cfg2ib_compl_seq"));
          `uvm_info(get_full_name(), $psprintf("tlp2cxs_cfg2ib_compl_seq Created"), UVM_DEBUG);
          tlp2cxs_cfg2ib_compl_seq.m_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
          tlp2cxs_cfg2ib_compl_seq.misc_if            = misc_if;
          tlp2cxs_cfg2ib_compl_seq.m_num_hls_ports    = 1;

          if(m_pcie_dev_top_cfg.scenario != null) begin
            tlp2cxs_cfg2ib_compl_seq.m_pkt_err_en = m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror;
            if(m_pcie_strap_cfg.k_hls_dw_alignment == 2)
              tlp2cxs_cfg2ib_compl_seq.m_pkt_gap_en = m_enable_pkt_gaps;
          end

          `uvm_info(get_full_name(), $psprintf("tlp2cxs_cfg2ib_compl_seq before m_cfg2ib_cpl_tlp_sqr casting"), UVM_DEBUG);
          if(!$cast(tlp2cxs_cfg2ib_compl_seq.p_tlp_sqr, m_cfg2ib_cpl_tlp_sqr))
           `uvm_fatal(get_type_name(), "Cast failed !!")

          `uvm_info(get_full_name(), $psprintf("tlp2cxs_cfg2ib_compl_seq before m_cfg2ib_compl_cxs_sqr casting"), UVM_DEBUG);
          if(!$cast(tlp2cxs_cfg2ib_compl_seq.p_cxs_sqr[0], m_cfg2ib_compl_cxs_sqr))
           `uvm_fatal(get_type_name(), "Cast failed !!")

          tlp2cxs_cfg2ib_compl_seq.m_num_tlps_per_clk = 1; //As of now DUT supports only 1 Tlp per clock
          `uvm_info(get_full_name(), $psprintf("tlp2cxs_cfg2ib_compl_seq before starting "), UVM_DEBUG);
          tlp2cxs_cfg2ib_compl_seq.start(dev_seqr, null, -1); // Not required any sequencer
        end
        begin
          tlp2cxs_intrpt2ib_seq = cdn_pcie_hpa_tlp2cxs_seq::type_id::create($sformatf("tlp2cxs_intrpt2ib_seq"));
          `uvm_info(get_full_name(), $psprintf("tlp2cxs_intrpt2ib_seq Created"), UVM_DEBUG);
          tlp2cxs_intrpt2ib_seq.m_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
          tlp2cxs_intrpt2ib_seq.misc_if            = misc_if;
          tlp2cxs_intrpt2ib_seq.m_num_hls_ports    = 1;

          if(m_pcie_dev_top_cfg.scenario != null) begin
            tlp2cxs_intrpt2ib_seq.m_pkt_err_en = m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror;
            if(m_pcie_strap_cfg.k_hls_dw_alignment == 2)
              tlp2cxs_intrpt2ib_seq.m_pkt_gap_en = m_enable_pkt_gaps;
          end

          `uvm_info(get_full_name(), $psprintf("tlp2cxs_intrpt2ib_seq before m_intrpt2ib_cpl_tlp_sqr casting"), UVM_DEBUG);
          if(!$cast(tlp2cxs_intrpt2ib_seq.p_tlp_sqr, m_intrpt2ib_cpl_tlp_sqr))
           `uvm_fatal(get_type_name(), "Cast failed !!")

          `uvm_info(get_full_name(), $psprintf("tlp2cxs_intrpt2ib_seq before m_intrpt2ib_cxs_sqr casting"), UVM_DEBUG);
          if(!$cast(tlp2cxs_intrpt2ib_seq.p_cxs_sqr[0], m_intrpt2ib_cxs_sqr))
           `uvm_fatal(get_type_name(), "Cast failed !!")

          tlp2cxs_intrpt2ib_seq.m_num_tlps_per_clk = 1; //As of now DUT supports only 1 Tlp per clock
          `uvm_info(get_full_name(), $psprintf("tlp2cxs_intrpt2ib_seq before starting "), UVM_DEBUG);
          tlp2cxs_intrpt2ib_seq.start(dev_seqr, null, -1); // Not required any sequencer
        end
      join_none
    end

   `uvm_info(get_full_name(), $psprintf("start_bg_seqs completed "), UVM_DEBUG);

  endtask : start_bg_seqs

  //-----------------------------------------------------------------------------
  // Function: configure_interrupts_seq
  // This method sets the intx habdles
  //-----------------------------------------------------------------------------
  virtual function void configure_interrupts_seq();
    for (int i = 0; i< 4; i++) begin
      automatic int unsigned idx = i;
      rand_intx_seq[idx] = cdn_pcie_intx_sequence_lib::type_id::create($sformatf("rand_intx_seq[%1d]", idx));
      rand_intx_seq[idx].m_pcie_link_cfg= m_pcie_link_cfg;
      rand_intx_seq[idx].m_pcie_dev_top_cfg= m_pcie_dev_top_cfg;
    end
    rand_msi_msix_seq = cdn_pcie_msi_msix_sequence_lib::type_id::create("rand_msi_msix_seq");
    rand_msi_msix_seq.m_pcie_link_cfg= m_pcie_link_cfg;
    rand_msi_msix_seq.m_pcie_dev_top_cfg= m_pcie_dev_top_cfg;
  endfunction

  //-----------------------------------------------------------------------------
  // Function: send_cpl_to_cxs
  // Pop the genearted completions from cpl q and send to cxs sequencer
  //-----------------------------------------------------------------------------
  virtual task send_cpl_to_cxs();

    cdn_pcie_tl_sequences_pkg::cdn_hpa_pcie_tlp_queue_t tlp_q;
    cdn_hpa_pcie_tlp cpl_timeout_pkt;

    bit [31:0] init_cpl_q_size;
    bit [31:0] current_cpl_q_size;
    bit [7:0] cpl_tag;
    int curr_tlp_cif;
    bit [6:0] cpl_lower_address_arr[bit[9:0]];
    bit ob_error_test;

    cpl_timeout_pkt = new();
    EI_compl_lut_obj=new("EI_compl_lut_obj");

    forever begin
      if(m_pcie_strap_cfg.scenario) begin
        if(m_pcie_strap_cfg.scenario.m_is_perf_mode)
          hpa_timer.wait_for_time(m_time_1ns, "send_cpl_to_cxs_perf_mode_delay", "ns");
        else
          hpa_timer.wait_for_time(m_time_10ns, "send_cpl_to_cxs_normal_mode_delay", "ns");
      end	
      else begin
        hpa_timer.wait_for_time(m_time_10ns, "send_cpl_to_cxs_normal_mode_delay", "ns");
      end		
      //`ifndef HLS_MODULE_MODE
      if (cpl_trans_q.size() != 0 && !misc_if.link_down_handling_in_progress) begin
        hpa_timer.wait_for_hash_zero_delay();
        misc_if.ob_cpl_traffic_detected = 1;
        misc_if.ob_cpl_traffic_cnt = misc_if.ob_cpl_traffic_cnt + 1;
        //`else
        //  if (cpl_trans_q.size() != 0) begin
        //`endif
        if (!randomize(cpl_trans_num) with {
          cpl_trans_num > 0;
          cpl_trans_num <= 1; // !!!!! TODO for sanity we push Completiom for every TLP !!!!!!!!!!!!!!!!!!!!
        })
       `uvm_error(get_type_name(), "[main_phase] cpl_trans_num randomization fail")
        if (cpl_trans_num <= cpl_trans_q.size()) begin
          //np2cpl_seq = new("cdn_pcie_cxs_np2cpl_seq",cpl_trans_num);
          for (int i = 0; i < cpl_trans_num; ++i) begin
            if (!randomize(cpl_trans_id) with {
              cpl_trans_id <= (cpl_trans_q.size() - 1);
            })
           `uvm_error(get_type_name(), "[main_phase] cpl_trans_id randomization fail")
            //TODO Making cpl_trans_id=0 as we get completion timeout from active bfm (When B2B IB NP tlps are Tx)
            cpl_trans_id= 0;
            foreach (cpl_trans_q[ii]) begin
              if ((cpl_trans_q[ii].m_tlp_14_bit_tagscale  == cpl_trans_q[cpl_trans_id].m_tlp_14_bit_tagscale) &&
                  (cpl_trans_q[ii].m_tlp_t9  == cpl_trans_q[cpl_trans_id].m_tlp_t9) &&
                  (cpl_trans_q[ii].m_tlp_t8  == cpl_trans_q[cpl_trans_id].m_tlp_t8) &&
                  (cpl_trans_q[ii].m_tlp_tag == cpl_trans_q[cpl_trans_id].m_tlp_tag)) begin
               `ifndef HLS_MODULE_MODE
                  if(m_pcie_strap_cfg.scenario) begin
                    if(m_pcie_strap_cfg.scenario.m_is_perf_mode) begin
                      // In Perfromance mode do nothing
                    end	
                    else begin
                      if (!std::randomize(pri_cpl_delay) with {pri_cpl_delay dist {0:=80,1:=20};}) `uvm_fatal(get_full_name(), "randomization failure");
                      if(pri_cpl_delay) begin
                        if (!std::randomize(cpl_delay) with {cpl_delay dist {[80:89]:=30,[90:99]:=30,100:=30};}) `uvm_fatal(get_full_name(), "randomization failure");
                        repeat(cpl_delay) begin
                          if(misc_if.link_down_handling_in_progress || misc_if.pl_link_down_reset) begin
                            wait(reset_in_progress==1);
                            break; end
                          else
                            @(posedge misc_if.core_clk);
                        end
                      end
                      else begin
                        if (!std::randomize(cpl_delay) with {cpl_delay dist {[0:10]:=40,[11:20]:=50,[21:80]:=10};}) `uvm_fatal(get_full_name(), "randomization failure");
                        if(cpl_delay != 0) begin
                          repeat(cpl_delay) begin
                            if(misc_if.link_down_handling_in_progress || misc_if.pl_link_down_reset)begin
                              wait(reset_in_progress==1);
                              break;  end
                            else
                              @(posedge misc_if.core_clk);
                          end
                        end
                      end
                    end
                  end	
               `endif

                //link only
                //outbound request lut object
               `ifdef HLS_MODULE_MODE
                  if(link_side) begin
                    if(cpl_trans_q[ii].m_tlp_14_bit_tagscale) begin
                      cpl_trans_q[ii].compl_lut_obj = compl_lut_obj_14_bit;
                      cpl_trans_q[ii].compl_lut_obj_8bit = compl_lut_obj;
                      cpl_trans_q[ii].compl_lut_obj_10bit = compl_lut_obj_10_bit;
                      cpl_trans_q[ii].compl_lut_obj_14bit = compl_lut_obj_14_bit;
                    end
                    else if(cpl_trans_q[ii].m_tlp_t9 || cpl_trans_q[ii].m_tlp_t8) begin
                      cpl_trans_q[ii].compl_lut_obj = compl_lut_obj_10_bit;
                      cpl_trans_q[ii].compl_lut_obj_8bit = compl_lut_obj;
                      cpl_trans_q[ii].compl_lut_obj_10bit = compl_lut_obj_10_bit;
                      cpl_trans_q[ii].compl_lut_obj_14bit = compl_lut_obj_14_bit;
                    end
                    else begin
                      cpl_trans_q[ii].compl_lut_obj = compl_lut_obj;
                      cpl_trans_q[ii].compl_lut_obj_8bit = compl_lut_obj;
                      cpl_trans_q[ii].compl_lut_obj_10bit = compl_lut_obj_10_bit;
                      cpl_trans_q[ii].compl_lut_obj_14bit = compl_lut_obj_14_bit;
                    end
                    if (cpl_trans_q[ii].m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl) begin
                      cpl_trans_q[ii].compl_lut_obj = compl_lut_obj_p_uio;
                    end
                    cpl_trans_q[ii].m_pcie_dev_cfg = m_pcie_dev_cfg;
                    cpl_trans_q[ii].m_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
                    cpl_trans_q[ii].lut_item = EI_compl_lut_obj.complD_lut_manager(cpl_trans_q[ii]);
                    if (cpl_trans_q[ii].lut_item == null)
                     `uvm_info(get_type_name(), $psprintf("cpl_trans_q[ii].lut_item is null"), UVM_DEBUG)
                    else if (cpl_trans_q[ii].lut_item.vip_userdata == null)
                     `uvm_info(get_type_name(), $psprintf("cpl_trans_q[ii].lut_item.vip_userdata is null"), UVM_DEBUG)
                    if(m_pcie_dev_top_cfg.scenario != null)
                      ob_error_test = m_pcie_dev_top_cfg.scenario.m_enable_ob_err;
                    if(!ob_error_test && !cpl_trans_q[ii].np_req_tlp.hlsob2cfg_tlp) begin
                      if ((cpl_trans_q[ii].lut_item != null) && (cpl_trans_q[ii].lut_item.vip_userdata != null)) begin
                        `uvm_info(get_type_name(), $psprintf("I am in VIP Userdata condition"), UVM_DEBUG)
                        cpl_trans_q[ii].m_cpl_part = cpl_trans_q[ii].lut_item.cpl_type;
                        // As per JIRA-10988, Timeout CPL will have the lower address of the NP req.
                        if(cpl_trans_q[ii].lut_item.cpl_type == FIRST_CPL) begin
                          cpl_lower_address_arr[cpl_trans_q[ii].m_tlp_tag] = cpl_trans_q[ii].m_tlp_cpl_lower_addr;
                        end
                        if(cpl_trans_q[ii].lut_item.cpl_type == LAST_CPL || cpl_trans_q[ii].lut_item.cpl_type == FIRST_LAST_CPL) begin
                          cpl_trans_q[ii].inject_error(cpl_trans_q[ii].lut_item.vip_userdata); //error injection
                          `uvm_info(get_type_name(), $psprintf("cpl_trans_q[ii].m_tlp_cpl_status=%0s KMAX_SBSA_SUPPORT=%0b", cpl_trans_q[ii].m_tlp_cpl_status.name(), KMAX_SBSA_SUPPORT), UVM_DEBUG)
                          if ((cpl_trans_q[ii].m_tlp_cpl_status == CDN_HPA_PCIE_CPL_CRS) && (parameters_cfg_pkg::KMAX_SBSA_SUPPORT==1)) begin
                             if (!std::randomize(send_sc_cpl) with {send_sc_cpl dist {0:=80,1:=30};}) `uvm_fatal(get_full_name(), "randomization failure");
                             if(send_sc_cpl && m_rrs_retry_cfg_schedule.exists({cpl_trans_q[ii].m_tlp_14_bit_tagscale,cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8,cpl_trans_q[ii].m_tlp_tag})) begin
                               cpl_trans_q[ii].m_tlp_cpl_status = CDN_HPA_PCIE_CPL_SC;
                             end
                             cpl_trans_q[ii].m_tlp_completer_id.bus_num = cpl_trans_q[ii].np_req_tlp.m_tlp_completer_id.bus_num;
                             cpl_trans_q[ii].m_tlp_completer_id.device_num = cpl_trans_q[ii].np_req_tlp.m_tlp_completer_id.device_num;
                             cpl_trans_q[ii].m_tlp_completer_id.function_num = cpl_trans_q[ii].np_req_tlp.m_tlp_completer_id.function_num;
                          end
                          cpl_trans_q[ii].pack_ecrc_local = 1;
                          void'(cpl_trans_q[ii].pack_bytes(cpl_trans_q[ii].m_data));
                          if((cpl_trans_q[ii].lut_item.vip_userdata.m_error_injects == '{CDN_HPA_PCIE_TLP_CPL_INVALID_REQ_TAG_UNEXP_ERR}) && (cpl_trans_q[ii].error_inject_success)) begin
                            //cpl_timeout_pkt = generate_exp_cpl_timeout_packet(cpl_trans_q[ii], cpl_trans_q[ii].m_tlp_cpl_lower_addr);
                            //ib_exp_compl_to_TO_req_ap.write(cpl_timeout_pkt);
                            void'(generate_exp_cpl_timeout_packet(cpl_trans_q[ii], cpl_trans_q[ii].m_tlp_cpl_lower_addr, 1'b1));
                          end
                        end
                        if ((m_pcie_dev_top_cfg.scenario != null) && (cpl_trans_q[ii].np_req_tlp.m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request)) begin 	 	 
                          if(cpl_trans_q[ii].lut_item.cpl_type == LAST_CPL || cpl_trans_q[ii].lut_item.cpl_type == FIRST_LAST_CPL) begin
                            if (m_pcie_dev_top_cfg.scenario.m_ide_cpl_for_non_ide_req && (!cpl_trans_q[ii].np_req_tlp.m_ide_prefix_present)) begin
                              cpl_trans_q[ii].m_ide_prefix_present = 1;
                              cpl_trans_q[ii].m_ts = CDN_HPA_PCIE_NO_TRAILER;
                              cpl_trans_q[ii].np_req_tlp.m_stream_id = $urandom_range(20,50);
                              populate_ide_fields(cpl_trans_q[ii], cpl_trans_q[ii].np_req_tlp);
                              cpl_trans_q[ii].pack_ecrc_local = 1;
                              void'(cpl_trans_q[ii].pack_bytes(cpl_trans_q[ii].m_data));
                            end
                            else if (m_pcie_dev_top_cfg.scenario.m_non_ide_cpl_for_ide_req && (cpl_trans_q[ii].np_req_tlp.m_ide_prefix_present)) begin
                              cpl_trans_q[ii].m_ide_prefix_present = 0;
                              cpl_trans_q[ii].pack_ecrc_local = 1;
                              void'(cpl_trans_q[ii].pack_bytes(cpl_trans_q[ii].m_data));
                            end
                          end
                        end
                      end
                    end
                   `uvm_info(get_type_name(), $psprintf("m_pcie_dev_top_cfg.m_bad_stream_id_q.size()=%0d", m_pcie_dev_top_cfg.m_bad_stream_id_q.size()), UVM_DEBUG)
                    if(cpl_trans_q[ii].error_discard_packet) begin
                      //m_pcie_link_cfg.ib_cpl_trans_timeout_q[{cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8,cpl_trans_q[ii].m_tlp_tag}]= cpl_trans_q[ii];
                      `uvm_info(get_type_name(), $psprintf("discard cpl tlp =%0s", cpl_trans_q[ii].sprint()), UVM_DEBUG)
                      `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: skipping tag =%0h", {cpl_trans_q[ii].m_tlp_14_bit_tagscale,cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8,cpl_trans_q[ii].m_tlp_tag}), UVM_DEBUG)
                      //Generate expected CPL TO
                      if(cpl_trans_q[ii].lut_item.cpl_type == FIRST_LAST_CPL) begin
                        //cpl_timeout_pkt = generate_exp_cpl_timeout_packet(cpl_trans_q[ii], cpl_trans_q[ii].m_tlp_cpl_lower_addr);
                        void'(generate_exp_cpl_timeout_packet(cpl_trans_q[ii], cpl_trans_q[ii].m_tlp_cpl_lower_addr,1'b1));
                      end
                      else if(cpl_trans_q[ii].lut_item.cpl_type == LAST_CPL)begin
                        //cpl_timeout_pkt = generate_exp_cpl_timeout_packet(cpl_trans_q[ii], cpl_lower_address_arr[cpl_trans_q[ii].m_tlp_tag]);
                        void'(generate_exp_cpl_timeout_packet(cpl_trans_q[ii], cpl_lower_address_arr[cpl_trans_q[ii].m_tlp_tag],1'b1));
                      end
                      // Send to CPL TO score board
                      //ib_exp_compl_to_TO_req_ap.write(cpl_timeout_pkt);
                    end
                    else if ((cpl_trans_q[ii].lut_item != null) && m_pcie_dev_top_cfg.m_bad_stream_id_q.size()) begin
                      foreach (m_pcie_dev_top_cfg.m_bad_stream_id_q[item]) begin
                        `uvm_info(get_type_name(), $psprintf("m_bad_stream_id_q=%0h  cpl_trans_q[ii].m_stream_id=%0h", m_pcie_dev_top_cfg.m_bad_stream_id_q[item], cpl_trans_q[ii].m_stream_id), UVM_DEBUG)
                        if(m_pcie_dev_top_cfg.m_bad_stream_id_q[item] == cpl_trans_q[ii].m_stream_id) begin
                          stream_id_found = 1;
                          break;
                        end
                        else begin
                          stream_id_found = 0;
                        end
                      end
                      if(stream_id_found) begin
                        if (!m_cpl_timeout_tag_q.exists({cpl_trans_q[ii].m_tlp_14_bit_tagscale,cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8,cpl_trans_q[ii].m_tlp_tag})) begin
                          `uvm_info(get_type_name(),$psprintf("Dropping packet due to insecure stream =%0h =%0s",cpl_trans_q[ii].m_stream_id , cpl_trans_q[ii].sprint()),UVM_LOW)
                          void'(generate_exp_cpl_timeout_packet(cpl_trans_q[ii], cpl_lower_address_arr[cpl_trans_q[ii].m_tlp_tag], 1'b1));
                          m_cpl_timeout_tag_q[{cpl_trans_q[ii].m_tlp_14_bit_tagscale,cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8,cpl_trans_q[ii].m_tlp_tag}] = {cpl_trans_q[ii].m_tlp_14_bit_tagscale,cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8,cpl_trans_q[ii].m_tlp_tag};
                        end
                        if (cpl_trans_q[ii].lut_item.cpl_type inside {FIRST_LAST_CPL,LAST_CPL}) begin
                          m_cpl_timeout_tag_q.delete({cpl_trans_q[ii].m_tlp_14_bit_tagscale,cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8,cpl_trans_q[ii].m_tlp_tag});
                        end
                      end
                      else begin
                        tlp_q.push_back(cpl_trans_q[ii]); // Pushed to tlp queue
                      end
                    end
                    else begin
                      tlp_q.push_back(cpl_trans_q[ii]); // Pushed to tlp queue
                    end
                  end
                  else begin
                    tlp_q.push_back(cpl_trans_q[ii]); // Pushed to tlp queue
                  end
               `else
                  if(misc_if.link_down_test) begin
                    if(cpl_trans_q[ii] != null)
                      tlp_q.push_back(cpl_trans_q[ii]); // Pushed to tlp queue
                  end
                  else
                    tlp_q.push_back(cpl_trans_q[ii]); // Pushed to tlp queue
               `endif
                if(misc_if.link_down_test) begin
                  if(cpl_trans_q[ii] != null) begin
                   `uvm_info(get_full_name(),$psprintf("DBG_CIF_ROUTER: Generated completion for tag='h%0h tagscale=%0h is %0s",cpl_trans_q[ii].m_tlp_tag,{cpl_trans_q[ii].m_tlp_14_bit_tagscale, cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8},cpl_trans_q[ii].sprint()),UVM_DEBUG)
                   `uvm_info(get_full_name(),$psprintf("DBG_CIF_ROUTER:cpl_trans_q[ii].m_data= %0p",cpl_trans_q[ii].m_data),UVM_DEBUG)
                    cpl_trans_q.delete(ii);
                  end
                end
                else begin
                 `uvm_info(get_full_name(),$psprintf("DBG_CIF_ROUTER: Generated completion for tag='h%0h tagscale=%0h is %0s",cpl_trans_q[ii].m_tlp_tag,{cpl_trans_q[ii].m_tlp_14_bit_tagscale, cpl_trans_q[ii].m_tlp_t9,cpl_trans_q[ii].m_tlp_t8},cpl_trans_q[ii].sprint()),UVM_DEBUG)
                 `uvm_info(get_full_name(),$psprintf("DBG_CIF_ROUTER:cpl_trans_q[ii].m_data= %0p",cpl_trans_q[ii].m_data),UVM_DEBUG)
                  cpl_trans_q.delete(ii);
                end
                break;
              end //}
            end //}
          end //}
          if(!misc_if.link_down_handling_in_progress && !misc_if.dpc_triggered) begin
            foreach(tlp_q[i]) begin
              curr_tlp_cif = m_pcie_dev_top_cfg.tc_to_cif(tlp_q[i].m_tlp_tc);
             `uvm_info(get_type_name(), $psprintf("DEBUG_CIF_ROUTER_CPL: curr_tlp CPL TC =%0d and CIF=%0d" , tlp_q[i].m_tlp_tc, curr_tlp_cif), UVM_DEBUG)
              if(!tlp_q[i].np_req_tlp.hlsob2cfg_tlp) begin
                tlp2cxs_compl_seq[curr_tlp_cif].start_item(tlp_q[i], -1, m_ob_cpl_tlp_sqr[curr_tlp_cif]);
                // No randomization as it is conversion sequnce
                tlp2cxs_compl_seq[curr_tlp_cif].finish_item(tlp_q[i]);
              end
              else begin
                tlp2cxs_cfg2ib_compl_seq.start_item(tlp_q[i], -1, m_cfg2ib_cpl_tlp_sqr);
                // No randomization as it is conversion sequnce
                tlp2cxs_cfg2ib_compl_seq.finish_item(tlp_q[i]);
              end
            end
          end
          tlp_q.delete();
        end //}
      end //}
    end //}
  endtask

  function cdn_hpa_pcie_tlp generate_exp_cpl_timeout_packet(cdn_hpa_pcie_tlp cpl_trans, bit [6:0] cpl_lower_address, bit unexp_err=0);
    cdn_hpa_pcie_tlp l_cpl_trans;
    cdn_pcie_hpa_pf_vf_s m_pf_vf;
    bit [6:0] lower_addr;

    num_of_timeout_pkt++;
    //$cast(l_cpl_trans, cpl_trans);
    l_cpl_trans = new("l_cpl_trans");
    l_cpl_trans.np_req_tlp = new("l_np_req_tlp");
    l_cpl_trans.copy(cpl_trans);
    l_cpl_trans.np_req_tlp.copy(cpl_trans.np_req_tlp);
    foreach (l_cpl_trans.m_tlp_payload[i]) begin
      l_cpl_trans.m_tlp_payload[i] = 'd0;
    end

    //Mask Prefixes related Stuff
    l_cpl_trans.m_ide_prefix_present   = 0;
    l_cpl_trans.m_ide_hdr_type_prefix  = 0;
    l_cpl_trans.m_ide_hdr_fmt_prefix   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
    l_cpl_trans.m_ide_tlp_prefix       = 0;
    l_cpl_trans.m_stream_id            = 0;
    l_cpl_trans.m_sub_stream           = 0;
    l_cpl_trans.m_pr_sent_counter      = 0;
    l_cpl_trans.m_ide_m                = 0;
    l_cpl_trans.m_ide_p                = 0;
    l_cpl_trans.m_ide_k                = 0;
    l_cpl_trans.m_ide_t                = 0;
    //l_cpl_trans.m_pasid_prefix_present
    //l_cpl_trans.m_pasid_pri_value
    //l_cpl_trans.m_pasid_exec_value
    //l_cpl_trans.m_pasid_value
    //l_cpl_trans.m_ext_tph_prefix_present
    //l_cpl_trans.m_tlp_st_tag
    //l_cpl_trans.m_tlp_ph
    //l_cpl_trans.m_hv
    //l_cpl_trans.m_ama_value
    //l_cpl_trans.m_ama_valid

    l_cpl_trans.m_tlp_payload = '{};
    l_cpl_trans.m_tlp_length = l_cpl_trans.np_req_tlp.m_tlp_length;    // For UIOMRd send UIORdCpl, for UIOMWr send UIOWrCpl, else standard Cpl
    if(l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd) begin
      l_cpl_trans.m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIORdCpl;
      l_cpl_trans.m_hdr_type              = 5'b01101;
      l_cpl_trans.m_hdr_fmt  = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
    end
    else if(l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr) begin
      l_cpl_trans.m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl;
      l_cpl_trans.m_hdr_type              = 5'b01100;
      l_cpl_trans.m_hdr_fmt  = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
    end
    else begin
      l_cpl_trans.m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Cpl;
      l_cpl_trans.m_hdr_fmt  = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
     l_cpl_trans.m_hdr_type              = 5'b01010;
    end
    l_cpl_trans.m_tlp_completer_id = 'd0;

    //Internally generated tlp, ecrc not copied and no logic to generate in DUT
    l_cpl_trans.m_tlp_td = 'd0;
    l_cpl_trans.ecrc_val = 'd0;
    if(l_cpl_trans.is_flit_mode) begin
    l_cpl_trans.m_ts = CDN_HPA_PCIE_NO_TRAILER;
      l_cpl_trans.m_ts_payload.delete();
    end
    
    if(l_cpl_trans.m_tlp_local_prefix.size() > 0) begin
      l_cpl_trans.m_local_prefix_possible    = 0;
      l_cpl_trans.m_max_no_of_local_prefixes = 0;
      l_cpl_trans.m_tlp_local_prefix.delete();
      l_cpl_trans.m_tlp_local_prefix_data.delete();
      l_cpl_trans.m_hdr_fmt_local_prefix.delete();
      l_cpl_trans.m_hdr_type_local_prefix.delete();
    end
    
    if(unexp_err) begin
     `ifndef HPA_ARCH2
        l_cpl_trans.m_tlp_at_type = l_cpl_trans.np_req_tlp.m_tlp_at_type;
     `endif
      l_cpl_trans.m_tlp_attr1 = l_cpl_trans.np_req_tlp.m_tlp_attr1;
      l_cpl_trans.m_tlp_attr0 = l_cpl_trans.np_req_tlp.m_tlp_attr0;
      l_cpl_trans.m_tlp_14_bit_tagscale    = l_cpl_trans.np_req_tlp.m_tlp_14_bit_tagscale;
      l_cpl_trans.m_tlp_t9    = l_cpl_trans.np_req_tlp.m_tlp_t9;
      l_cpl_trans.m_tlp_t8    = l_cpl_trans.np_req_tlp.m_tlp_t8;
      l_cpl_trans.m_tlp_tag   = l_cpl_trans.np_req_tlp.m_tlp_tag;
    end
    if(l_cpl_trans.np_req_tlp.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMRd,CDN_HPA_PCIE_TLP_TYPE_UIOMWr})begin
      l_cpl_trans.m_tlp_attr1 = 0;
      l_cpl_trans.m_tlp_attr0 = 0;
      l_cpl_trans.m_tlp_cpl_cdl = misc_if.neg_cxl_mode ? l_cpl_trans.m_tlp_cpl_cdl : 0; //The CDL[1:0] field is assigned for use by [CXL]; this field must be treated as Reserved for use cases not covered
//by [CXL]. 
      end

    if(l_cpl_trans.np_req_tlp.m_tlp_type ==CDN_HPA_PCIE_TLP_TYPE_CfgRd0 ||
      l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd1 ||
      l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr0 ||
      l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr1 ) begin
      lower_addr[6:2] = l_cpl_trans.np_req_tlp.m_tlp_reg_num[6:2];
    end
    else if(l_cpl_trans.np_req_tlp.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32, CDN_HPA_PCIE_TLP_TYPE_MRd_64, CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64}) begin
      lower_addr[6:2] = l_cpl_trans.np_req_tlp.m_tlp_addr[6:2];
    end
    else
      lower_addr[6:2] =0;

      l_cpl_trans.m_completer_segment =0;
      //l_cpl_trans.m_tlp_cpl_cdl =0;//The CDL[1:0] field is assigned for use by [CXL]; this field must be treated as Reserved for use cases not covered
//by [CXL].

    `uvm_info(get_type_name(), $psprintf("l_cpl_trans =%0s" , l_cpl_trans.sprint()), UVM_DEBUG)
    `uvm_info(get_type_name(), $psprintf("l_cpl_trans.np_req_tlp =%0s" , l_cpl_trans.np_req_tlp.sprint()), UVM_DEBUG)

    if(l_cpl_trans.np_req_tlp.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32, CDN_HPA_PCIE_TLP_TYPE_MRd_64, CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64}) begin
    if((l_cpl_trans.np_req_tlp.m_tlp_th == 1) && (!l_cpl_trans.is_flit_mode)) begin //If TH bit set FBE and LBE are assumed to be 'hFF
      lower_addr[1:0] =  2'b00 ;
    end else begin
      lower_addr[1:0] = (l_cpl_trans.np_req_tlp.m_tlp_first_dw_be[0] == 1'b1) ? 2'b00 :
                        (l_cpl_trans.np_req_tlp.m_tlp_first_dw_be[1] == 1'b1) ? 2'b01 :
                        (l_cpl_trans.np_req_tlp.m_tlp_first_dw_be[2] == 1'b1) ? 2'b10 :
                        (l_cpl_trans.np_req_tlp.m_tlp_first_dw_be[3] == 1'b1) ? 2'b11 : 2'b00 ;
    end
    end
    else begin 
      l_cpl_trans.m_tlp_cpl_lower_addr=0;
      end

    if((parameters_cfg_pkg::KMAX_SBSA_SUPPORT==1) && 
       (l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd0 ||
        l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd1 ||
        l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr0 ||
        l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr1 )) begin
      l_cpl_trans.m_tlp_cpl_lower_addr = 0;
    end
    else begin
      l_cpl_trans.m_tlp_cpl_lower_addr = lower_addr;
    end
    l_cpl_trans.m_tlp_ep             = 0;

    if(l_cpl_trans.is_flit_mode) begin
      l_cpl_trans.m_ohc_a = 0;
      l_cpl_trans.m_destination_segment = 0;
      l_cpl_trans.m_destination_segment_valid = 0;
      if(l_cpl_trans.m_tlp_cpl_lower_addr[1:0]!= 2'b00) begin
        l_cpl_trans.m_ohc_hdr.ohc_a_present = 1;
        l_cpl_trans.m_ohc_a[4:3] = l_cpl_trans.m_tlp_cpl_lower_addr;
        l_cpl_trans.m_ohc_a[2:0] = CDN_HPA_PCIE_CPL_SC;
      end
      else begin
        l_cpl_trans.m_ohc_hdr.ohc_a_present = 0;
        l_cpl_trans.m_ohc_a = 0;
      end
      l_cpl_trans.m_ohc_hdr.ohc_b_present = 0;
      l_cpl_trans.m_ohc_hdr.ohc_c_present = 0;
    end
    //For All NonPosted write will have byte_count=0
   `ifndef HPA_ARCH2
      if (l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32 ||
        l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64 ||
        l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr0  ||
        l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr1  ||
      l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IOWr ||
      l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd ||
      l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr) begin
        l_cpl_trans.m_tlp_cpl_byte_cnt = 0;
      end
      if (l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd0 ||
      l_cpl_trans.np_req_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd1 ) begin
        l_cpl_trans.m_tlp_cpl_byte_cnt = 4;
      end
   `endif
    
    // For CPL Timeout packet PTH is generated from the pbr_pth_for_generated_tlps_towards_AL Register Field
    if(l_cpl_trans.is_cxl_pbr_mode) begin
      if(m_dut_mode == RP) begin // For m_dut_mode = RP the tlp_router would behave as EP and hence we are taking the value from the usp_dev_top_config.
        l_cpl_trans.m_tlp_pbr_tlp_header = {2'b11, m_pcie_link_cfg.usp_dev_top_config.cxl_pth_rsvd, m_pcie_link_cfg.usp_dev_top_config.cxl_pth_hie, m_pcie_link_cfg.usp_dev_top_config.cxl_pth_dsar, m_pcie_link_cfg.usp_dev_top_config.cxl_pth_pif, m_pcie_link_cfg.usp_dev_top_config.cxl_pth_dpid_towards_AL, m_pcie_link_cfg.usp_dev_top_config.cxl_pth_spid};
      end
      else begin
        l_cpl_trans.m_tlp_pbr_tlp_header = {2'b11, m_pcie_link_cfg.dsp_dev_top_config.cxl_pth_rsvd, m_pcie_link_cfg.dsp_dev_top_config.cxl_pth_hie, m_pcie_link_cfg.dsp_dev_top_config.cxl_pth_dsar, m_pcie_link_cfg.dsp_dev_top_config.cxl_pth_pif, m_pcie_link_cfg.dsp_dev_top_config.cxl_pth_dpid_towards_AL, m_pcie_link_cfg.dsp_dev_top_config.cxl_pth_spid};
      end

      l_cpl_trans.m_tlp_pth_rsvd       = l_cpl_trans.m_tlp_pbr_tlp_header[29:27];
      l_cpl_trans.m_tlp_pth_hie        = l_cpl_trans.m_tlp_pbr_tlp_header[26];
      l_cpl_trans.m_tlp_pth_dsar       = l_cpl_trans.m_tlp_pbr_tlp_header[25];
      l_cpl_trans.m_tlp_pth_pif        = l_cpl_trans.m_tlp_pbr_tlp_header[24];
      l_cpl_trans.m_tlp_pth_spid       = l_cpl_trans.m_tlp_pbr_tlp_header[23:12];
      l_cpl_trans.m_tlp_pth_dpid       = l_cpl_trans.m_tlp_pbr_tlp_header[11:0];
    end
    
    //Generate metadata for packet
    l_cpl_trans.is_ib_pkt=1;
    l_cpl_trans.m_pcie_dev_top_cfg=m_pcie_link_cfg.usp_dev_top_config;
    m_pf_vf=l_cpl_trans.m_pcie_dev_top_cfg.get_pf_vf_from_req_id(l_cpl_trans.m_tlp_requester_id);
    if(m_pf_vf.is_pf_valid)
      l_cpl_trans.hls_ib_cpl_meta_s.pf = m_pf_vf.pf;
    l_cpl_trans.hls_ib_cpl_meta_s.vf = m_pf_vf.is_vf_valid ? m_pf_vf.vf : 0;
    l_cpl_trans.hls_ib_cpl_meta_s.vf_or_pf = m_pf_vf.is_vf_valid;
    l_cpl_trans.hls_ib_cpl_meta_s.cpl_err_code = CDN_HPA_PCIE_CPL_TO;
    l_cpl_trans.hls_ib_cpl_meta_s.cpl_complete = 1'b1;
   `ifdef HPA_ARCH2
      l_cpl_trans.hls_ib_cpl_meta_s.generated_tlp = 1'b1;
   `endif
    l_cpl_trans.m_ohc_hdr.ohc_a_present = 0;
    l_cpl_trans.m_ohc_a = 0;
   `uvm_info(get_type_name(), $psprintf("Generated CPL TIMEOUT Packet =%0s", l_cpl_trans.sprint()), UVM_DEBUG)
   `uvm_info(get_type_name(), $psprintf("Generated CPL TIMEOUT Metadata Packet =%0p", l_cpl_trans.hls_ib_cpl_meta_s), UVM_DEBUG)
    l_cpl_trans.m_compare_byte_cnt = 0; //As per JIRA PCIE-21809, do not compare bytecount
    if(m_pcie_dev_top_cfg.i_cfg.strap_port_type inside {0,1}) begin
      if(l_cpl_trans.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl)
        ib_exp_p_compl_to_TO_req_ap.write(l_cpl_trans);
      // Send to CPL TO score board
      else
      ib_exp_compl_to_TO_req_ap.write(l_cpl_trans);
    end
    else begin
      cpl_timeout_drop_tlp_q.push_back(l_cpl_trans);
    end

  endfunction : generate_exp_cpl_timeout_packet

  //-----------------------------------------------------------------------------
  // Function: tlp_router
  // Decodes the TLPs and routes to CXS sequencer or tag manager
  //-----------------------------------------------------------------------------
  virtual task tlp_router();
    // TODO: wait for reset
    // Provide an option to push max tlps per clock
    // Provide an option to randomize TLP with in max TLPs clock
    // Provide an option for burst of TLPs per clock
    // Add the TLP IPG Delay here
    cdn_hpa_pcie_tlp_pkg::cdn_hpa_pcie_tlp pcie_tlp;
    cdn_pcie_hpa_pf_vf_s        pf_vf_s;
    cdn_pcie_hpa_pf_vf_s        pf_vf_s2;
    bit                         bar_msi_msix_en;
    bit                         tag_pool_sel_10_or_14_bit;
    int unsigned                uio_np_tag_pool_sel_bit;
    cdn_pcie_hpa_pf_vf_s        pf_vf_s1;
    bit                         xmit_to_intrpt;

    forever begin
      wait(reset_in_progress==0);
      fork
        begin
          automatic int curr_tlp_cif;
         `uvm_info(get_full_name(), $sformatf("bfm_driver() Get TLP from sequencer... "), UVM_HIGH)

          seq_item_port.get_next_item(req);
          wait(misc_if.link_down_handling_in_progress==0);
          hpa_timer.wait_for_hash_zero_delay();
         `uvm_info(get_full_name(), $psprintf("tlp_router(): misc_if.ob_traffic_detected=%0d misc_if.ob_traffic_cnt=%0d" , misc_if.ob_traffic_detected, misc_if.ob_traffic_cnt), UVM_DEBUG)
         `uvm_info(get_full_name(), $sformatf("bfm_driver() Got TLP from sequencer... %0s", req.sprint()), UVM_HIGH)
          pcie_tlp = cdn_hpa_pcie_tlp_pkg::cdn_hpa_pcie_tlp::type_id::create("pcie_tlp");
          //if (!std::randomize(pri_msi_msix_msg) with {pri_msi_msix_msg dist {0:=80,1:=20};}) `uvm_fatal(get_full_name(), "randomization failure");
         `uvm_info(get_full_name(), $psprintf("DEBUG_CIF_ROUTER_POSTED: pri_msi_msix_msg =%0d bar_msi_msix_en=%0d" , req.pri_msi_msix_msg,bar_msi_msix_en), UVM_DEBUG)

          if(req.m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) begin
            misc_if.ob_p_traffic_detected = 1;
            misc_if.ob_p_traffic_cnt = misc_if.ob_p_traffic_cnt + 1;
            if(req.isIntxPkt && (req.m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)) begin
              pf_vf_s1 = m_pcie_dev_top_cfg.get_pf_vf_from_req_id(req.m_tlp_requester_id_tb);
              if(m_pcie_dev_top_cfg.intx_pin_or_hls && !pf_vf_s1.is_vf_valid) begin // Added for PCIE-8491
                if(req.m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A,CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A}) begin
                  hpa_pkt_intx_a_q.push_back(req);
                end
                if(req.m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B,CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B}) begin
                  hpa_pkt_intx_b_q.push_back(req);
                end
                if(req.m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C,CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C}) begin
                  hpa_pkt_intx_c_q.push_back(req);
                end
                if(req.m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D,CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D}) begin
                  hpa_pkt_intx_d_q.push_back(req);
                end
              end else begin
                pcie_tlp.copy(req);
                curr_tlp_cif = m_pcie_dev_top_cfg.tc_to_cif(pcie_tlp.m_tlp_tc);
                cdn_pcie_hpa_tlp2cxs_seq_h[curr_tlp_cif].start_item(pcie_tlp, -1, m_ob_p_tlp_sqr[curr_tlp_cif]);
                // No randomization as it is conversion sequnce
                cdn_pcie_hpa_tlp2cxs_seq_h[curr_tlp_cif].finish_item(pcie_tlp);
              end
            end
            else if(/*req.isMsiMsixPkt &&*/ (req.pri_msi_msix_msg && req.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64}) && ((req.m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (m_pcie_strap_cfg.k_msi_enable !=0 || m_pcie_strap_cfg.k_msix_enable !=0))) begin
             `uvm_info(get_name(),$psprintf("1m_pasid_prefix_present = %d, m_pasid_pri_value = %d , m_pasid_attr = %d",req.m_pasid_prefix_present, req.m_pasid_pri_value,m_pcie_link_cfg.usp_dev_config.m_pasid_attr),UVM_LOW)              
              hpa_pkt_msi_msix_q.push_back(req);
             `uvm_info(get_name(),$psprintf("2m_pasid_prefix_present = %d, m_pasid_pri_value = %d,m_pasid_attr = %d",req.m_pasid_prefix_present, req.m_pasid_pri_value,m_pcie_link_cfg.usp_dev_config.m_pasid_attr),UVM_LOW)              
             `uvm_info(get_name(),$psprintf("hpa_pkt_msi_msix_q size %d",hpa_pkt_msi_msix_q.size()),UVM_LOW)
            end
            // UIO Write uses a tag for generating Completion UIOWrCpl TLP
            // Flit mode is required for UIO command
            else if (req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr) begin
              pcie_tlp.copy(req);
              `uvm_info(get_full_name(),$psprintf("pcie_tlp.m_data=%0p", pcie_tlp.m_data),UVM_DEBUG)
              `uvm_info(get_name(),$psprintf("pf_vf_s.pf %d",pf_vf_s.pf),UVM_LOW)
              `uvm_info(get_name(),$psprintf("pf_vf_s.vf %d",pf_vf_s.vf),UVM_LOW)
              `uvm_info(get_name(),$psprintf("pf_vf_s.is_vf_valid %d",pf_vf_s.is_vf_valid),UVM_LOW)
              pf_vf_s = m_pcie_dev_top_cfg.get_pf_vf_from_req_id(pcie_tlp.m_tlp_requester_id, 1);
              foreach(pcie_tlp.vip_userdata.m_error_injects[i]) begin
                if(pcie_tlp.vip_userdata.m_error_injects[i] == CDN_HPA_PCIE_TLP_ACS_SOURCE_VALIDATION_ERR) pf_vf_s.pf = 0;
              end
              `uvm_info(get_name(),$psprintf("pf_vf_s.pf %d",pf_vf_s.pf),UVM_LOW)
              `uvm_info(get_name(),$psprintf("pf_vf_s.vf %d",pf_vf_s.vf),UVM_LOW)
              `uvm_info(get_name(),$psprintf("pf_vf_s.is_vf_valid %d",pf_vf_s.is_vf_valid),UVM_LOW)
              `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the UIO P TLP to UIO tag manager pool.Packet is %0s", pcie_tlp.sprint()), UVM_LOW)
              ob_uio_p_req_ap.write(pcie_tlp);
            end
            else begin
              pcie_tlp.copy(req);
              curr_tlp_cif = m_pcie_dev_top_cfg.tc_to_cif(pcie_tlp.m_tlp_tc);
              if(!link_side) begin
                cdn_pcie_hpa_tlp2cxs_seq_h[curr_tlp_cif].start_item(pcie_tlp, -1, m_ob_p_tlp_sqr[curr_tlp_cif]);
                `uvm_info(get_full_name(), $psprintf("waiting for finish item complete"), UVM_DEBUG)
                // No randomization as it is conversion sequnce
                cdn_pcie_hpa_tlp2cxs_seq_h[curr_tlp_cif].finish_item(pcie_tlp);
                `uvm_info(get_full_name(), $psprintf("wait for finish item complete over"), UVM_DEBUG)
              end
              else begin
                `ifdef HPA_ARCH2
                  if (!std::randomize(xmit_to_intrpt) with {xmit_to_intrpt dist {0:=10, 1:=5};}) `uvm_fatal(get_full_name(), "randomization failure");
                  if(xmit_to_intrpt && misc_if.l_send_interrupt2ib && (pcie_tlp.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64})) begin
                    pcie_tlp.cfg2hls_tlp = 1;
                    tlp2cxs_intrpt2ib_seq.start_item(pcie_tlp, -1, m_intrpt2ib_cpl_tlp_sqr);
                    // No randomization as it is conversion sequnce
                    tlp2cxs_intrpt2ib_seq.finish_item(pcie_tlp);
                  end
                  else begin
                    cdn_pcie_hpa_tlp2cxs_seq_h[curr_tlp_cif].start_item(pcie_tlp, -1, m_ob_p_tlp_sqr[curr_tlp_cif]);
                    `uvm_info(get_full_name(), $psprintf("waiting for finish item complete"), UVM_DEBUG)
                    // No randomization as it is conversion sequnce
                    cdn_pcie_hpa_tlp2cxs_seq_h[curr_tlp_cif].finish_item(pcie_tlp);
                    `uvm_info(get_full_name(), $psprintf("wait for finish item complete over"), UVM_DEBUG)
                  end
                `else 
                  cdn_pcie_hpa_tlp2cxs_seq_h[curr_tlp_cif].start_item(pcie_tlp, -1, m_ob_p_tlp_sqr[curr_tlp_cif]);
                  `uvm_info(get_full_name(), $psprintf("waiting for finish item complete"), UVM_DEBUG)
                  // No randomization as it is conversion sequnce
                  cdn_pcie_hpa_tlp2cxs_seq_h[curr_tlp_cif].finish_item(pcie_tlp);
                  `uvm_info(get_full_name(), $psprintf("wait for finish item complete over"), UVM_DEBUG)
                `endif
              end
            end
            //Posted driving on CIF - Need to checl for INTX and MSIX - TODO
           `uvm_info(get_full_name(), $psprintf("DEBUG_CIF_ROUTER_POSTED: curr_tlp Posted TC =%0d and CIF=%0d" , pcie_tlp.m_tlp_tc, curr_tlp_cif), UVM_DEBUG)
          end
          else begin
            misc_if.ob_np_traffic_detected = 1;
            misc_if.ob_np_traffic_cnt = misc_if.ob_np_traffic_cnt + 1;
            pcie_tlp.copy(req);
            `uvm_info(get_full_name(),$psprintf("req.m_data=%0p", req.m_data),UVM_DEBUG)
            `uvm_info(get_full_name(),$psprintf("pcie_tlp.m_data=%0p", pcie_tlp.m_data),UVM_DEBUG)
            `uvm_info(get_name(),$psprintf("pf_vf_s.pf %d",pf_vf_s.pf),UVM_LOW)
            `uvm_info(get_name(),$psprintf("pf_vf_s.vf %d",pf_vf_s.vf),UVM_LOW)
            `uvm_info(get_name(),$psprintf("pf_vf_s.is_vf_valid %d",pf_vf_s.is_vf_valid),UVM_LOW)
            pf_vf_s = m_pcie_dev_top_cfg.get_pf_vf_from_req_id(pcie_tlp.m_tlp_requester_id, 1);
            foreach(pcie_tlp.vip_userdata.m_error_injects[i]) begin
              if(pcie_tlp.vip_userdata.m_error_injects[i] == CDN_HPA_PCIE_TLP_ACS_SOURCE_VALIDATION_ERR) pf_vf_s.pf = 0;
            end
            `uvm_info(get_name(),$psprintf("pf_vf_s.pf %d",pf_vf_s.pf),UVM_LOW)
            `uvm_info(get_name(),$psprintf("pf_vf_s.vf %d",pf_vf_s.vf),UVM_LOW)
            `uvm_info(get_name(),$psprintf("pf_vf_s.is_vf_valid %d",pf_vf_s.is_vf_valid),UVM_LOW)
            
            // For UIO TLPs any [13:0] tag value is valid hence randomly choosing the tag manager for UIO NP Request.
            if(pcie_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd) begin
              if(!std::randomize(uio_np_tag_pool_sel_bit) with { // 0 -> 8bit tag pool, 1 -> 10bit tag pool, 2 -> 14bit tag pool
                (m_pcie_dev_top_cfg.i_cfg.k_np_records_table_size > 1024) -> (uio_np_tag_pool_sel_bit inside {0, 1, 2});
                (m_pcie_dev_top_cfg.i_cfg.k_np_records_table_size > 256 && m_pcie_dev_top_cfg.i_cfg.k_np_records_table_size <= 1024) -> (uio_np_tag_pool_sel_bit inside {0, 1});
                (m_pcie_dev_top_cfg.i_cfg.k_np_records_table_size <= 256) -> (uio_np_tag_pool_sel_bit inside {0});
              }) begin
                `uvm_fatal(get_full_name(), "Randomization failed for uio_np_tag_pool_sel_bit....")
              end
              
              if(uio_np_tag_pool_sel_bit == 0) begin
                `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the UIO NP TLP to non_10_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()), UVM_LOW)
                ob_np_req_ap.write(pcie_tlp);
              end
              else if(uio_np_tag_pool_sel_bit == 1) begin
                `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 10_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()), UVM_LOW)
                ob_10_bit_tag_np_req_ap.write(pcie_tlp);
              end
              else if(uio_np_tag_pool_sel_bit == 2) begin
                `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 14_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()), UVM_LOW)
                ob_14_bit_tag_np_req_ap.write(pcie_tlp);
              end
            end
            // For Non-UIO NP Request scenarios
            else begin
              if(!pf_vf_s.is_vf_valid) begin
                `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: PF_%0d  m_10_bit_tag_req_en=%0d 10_bit_tag_init_done=%0d m_14_bit_tag_req_en=%0d  14_bit_tag_init_done=%0d",pf_vf_s.pf,m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_10_bit_tag_req_en,m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_10_bit_tag_done,m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_14_bit_tag_req_en,m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_14_bit_tag_done),UVM_LOW);
                //if(((m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_10_bit_tag_req_en == 0) && (m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_14_bit_tag_req_en == 0)) ||
                //  (m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_10_bit_tag_req_en && !m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_10_bit_tag_done) ||
                //  (m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_14_bit_tag_req_en && !m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_14_bit_tag_done)) begin
                if(((m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_10_bit_tag_req_en == 0) || (m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_10_bit_tag_req_en && !m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_10_bit_tag_done)) &&
                   ((m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_14_bit_tag_req_en == 0) || (m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_14_bit_tag_req_en && !m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_14_bit_tag_done))) begin
                  `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to non_10_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                  ob_np_req_ap.write(pcie_tlp); // NP request is passed to the non 10 bit tag pool
                end else if ((m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_10_bit_tag_req_en && m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_10_bit_tag_done) &&
                             (m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_14_bit_tag_req_en && m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_14_bit_tag_done))begin
                  //If both 10 bit and 14 bit tag is enabled, it means gen6 device and other end has both 10bi tand 14 bit support.
                  //So, randomly pick from 10-bit or 14-bit pool
                  assert(std::randomize(tag_pool_sel_10_or_14_bit)); //0: 10 bit pool, 1: 14 bit pool
                  //if(tag_pool_sel_10_or_14_bit) begin
                  if(tag_pool_sel_10_or_14_bit && pcie_tlp.is_flit_mode) begin
                   `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 14_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                   ob_14_bit_tag_np_req_ap.write(pcie_tlp); // NP request is passed to the 10 bit tag pool
                  end else begin
                   `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 10_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                   ob_10_bit_tag_np_req_ap.write(pcie_tlp); // NP request is passed to the 10 bit tag pool
                  end
                end else if (m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_10_bit_tag_req_en && m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_10_bit_tag_done)begin
                  `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 10_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                  ob_10_bit_tag_np_req_ap.write(pcie_tlp); // NP request is passed to the 10 bit tag pool
                end else if (m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].m_14_bit_tag_req_en && m_pcie_dev_top_cfg.pf_config[pf_vf_s.pf].dev_init_for_14_bit_tag_done)begin
                  if(pcie_tlp.is_flit_mode) begin
                    `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 14_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                    ob_14_bit_tag_np_req_ap.write(pcie_tlp); // NP request is passed to the 10 bit tag pool
                  end
                  else begin
                    `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 8_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                    ob_np_req_ap.write(pcie_tlp); // NP request is passed to the 8 bit tag pool
                  end
                end else begin
                 `uvm_error(get_full_name(),"Unable to route the NP req to corresponding tag manager[based on dev_cfg 10/14 bit tag enables]")
                end
              end else begin
                `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: PF_%0d VF_%0d m_10_bit_tag_req_en=%0d 10_bit_tag_init_done=%0d m_14_bit_tag_req_en=%0d 14_bit_tag_init_done=%0d",pf_vf_s.pf,pf_vf_s.vf,m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_10_bit_tag_req_en,m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_10_bit_tag_done,m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_14_bit_tag_req_en, m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_14_bit_tag_done),UVM_LOW);
                //if(((m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_10_bit_tag_req_en == 0) & (m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_14_bit_tag_req_en == 0)) ||
                //    (m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_10_bit_tag_req_en && !m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_10_bit_tag_done) ||
                //    (m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_14_bit_tag_req_en && !m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_14_bit_tag_done)) begin
                if(((m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_10_bit_tag_req_en == 0) || (m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_10_bit_tag_req_en && !m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_10_bit_tag_done)) &&
                   ((m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_14_bit_tag_req_en == 0) || (m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_14_bit_tag_req_en && !m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_14_bit_tag_done))) begin
                  `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to non_10_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                  ob_np_req_ap.write(pcie_tlp); // NP request is passed to the non 10 bit tag pool
                end else if ((m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_10_bit_tag_req_en && m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_10_bit_tag_done) &&
                             (m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_14_bit_tag_req_en && m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_14_bit_tag_done))begin
                  //If both 10 bit and 14 bit tag is enabled, it means gen6 device and other end has both 10bi tand 14 bit support.
                  //So, randomly pick from 10-bit or 14-bit pool
                  assert(std::randomize(tag_pool_sel_10_or_14_bit)); //0: 10 bit pool, 1: 14 bit pool
                  if(tag_pool_sel_10_or_14_bit && pcie_tlp.is_flit_mode) begin
                   `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 14_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                   ob_14_bit_tag_np_req_ap.write(pcie_tlp); // NP request is passed to the 10 bit tag pool
                  end else begin
                   `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 10_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                   ob_10_bit_tag_np_req_ap.write(pcie_tlp); // NP request is passed to the 10 bit tag pool
                  end
                end else if (m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_10_bit_tag_req_en && m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_10_bit_tag_done) begin
                  `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 10_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                  ob_10_bit_tag_np_req_ap.write(pcie_tlp); // NP request is passed to the 10 bit tag pool
                end else if (m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].m_14_bit_tag_req_en && m_pcie_dev_top_cfg.vf_config[pf_vf_s.pf][pf_vf_s.vf].dev_init_for_14_bit_tag_done) begin
                  if(pcie_tlp.is_flit_mode) begin
                    `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 14_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                    ob_14_bit_tag_np_req_ap.write(pcie_tlp); // NP request is passed to the 10 bit tag pool
                  end
                  else begin
                    `uvm_info(get_name(),$psprintf("DBG_TAG_MANAGER: Pushing the NP TLP to 8_bit tag manager pool.Packet is %0s",pcie_tlp.sprint()),UVM_LOW)
                    ob_np_req_ap.write(pcie_tlp); // NP request is passed to the 8 bit tag pool
                  end
                end else begin
                 `uvm_error(get_full_name(),"Unable to route the NP req to corresponding tag manager[based on dev_cfg 10/14 bit tag enables]")
                end
              end
            end
          end
          seq_item_port.item_done();
         `uvm_info(get_full_name(), $sformatf("bfm_driver() TLP driving  ... done"), UVM_HIGH)
        end
        begin
          wait(reset_in_progress==1);
          hpa_timer.wait_for_delay_1ps();
        end
      join_any
      disable fork;
    end

  endtask
 //-----------------------------------------------------------------------------
  // Function: detect_traffic
  // Detect traffic
  //-----------------------------------------------------------------------------
  virtual task detect_traffic();
    // TODO: wait for reset

    forever begin
      wait(reset_in_progress==0);
      fork
        begin
          //`uvm_info(get_full_name(), $sformatf("detect_traffic() Waiting for link_down_handling_in_progress = 1... "), UVM_HIGH)
          wait(misc_if.link_down_handling_in_progress==1);
          misc_if.ob_traffic_detected = 0;
          misc_if.ob_traffic_cnt = 0;
          misc_if.ob_p_traffic_detected = 0;
          misc_if.ob_p_traffic_cnt = 0;
          misc_if.ob_np_traffic_detected = 0;
          misc_if.ob_np_traffic_cnt = 0;
          misc_if.ob_cpl_traffic_detected = 0;
          misc_if.ob_cpl_traffic_cnt = 0;
          @(posedge misc_if.core_clk);
          //`uvm_info(get_full_name(), $psprintf("detect_traffic(): misc_if.ob_traffic_detected=%0d misc_if.ob_traffic_cnt=%0d" , misc_if.ob_traffic_detected, misc_if.ob_traffic_cnt), UVM_DEBUG)
          //`uvm_info(get_full_name(), $sformatf("detect_traffic() Done for link_down_handling_in_progress = 1..."), UVM_HIGH)
        end
        begin
          repeat(2)
            @(posedge misc_if.core_clk);
        end
      join_any
      disable fork;
    end

  endtask


  //-----------------------------------------------------------------------------
  // Function: pick_dev_cfg_for_ib_addr
  // Below API can be used when DUT is EP. It will return dev_cfg corresponding to the bar hit of incoming address
  //-----------------------------------------------------------------------------
  function  cdn_hpa_pcie_dev_config pick_dev_cfg_for_ib_addr (input bit [63:0] ib_addr, input string pkt_type="MEM") ;//Pkt_type = MEM/IO
    bit [63:0] start_addr;
    bit [63:0] end_addr;
    bit success_hit;

    if((pkt_type=="MEM") && m_pcie_strap_cfg.k_cxl_support) begin
      start_addr = m_pcie_dev_top_cfg.m_cxl_io_rcrb_bar + 2**12;
      end_addr = m_pcie_dev_top_cfg.m_cxl_io_rcrb_bar + 2**13;
      if(ib_addr >= start_addr && ib_addr <= end_addr) begin
       `uvm_info(get_full_name(),$psprintf("DEBUG_CXL_RCRB_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF0",pkt_type,ib_addr),UVM_DEBUG)
        success_hit = 1;
        return m_pcie_dev_top_cfg.pf_config[0];
      end
    end

    //Search all available PFs first
    foreach(m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
      foreach(m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
       `uvm_info(get_full_name(),$sformatf("m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[%0d].bars[%0d]= %0s",i, j, m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].sprint()),UVM_DEBUG)
        if(((pkt_type=="MEM") && (m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable) &&
          ((m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32) ||
            (m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH) ||
            (m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_PREFETCH) ||
            (m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32_PREFETCH) ||
  				  (m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32) ||
            // PS test doesn't differentiate MSI BAR and memory BAR and consider for NP requtests.
            (puresuite_test && (m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MSI_OR_MSIX_BAR_32
            ||m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MSI_OR_MSIX_BAR_64 ))
          )
        ) ||
        ((pkt_type=="IO")  && (m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable) &&
        (m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == IO_BAR))
        ) begin //{
          start_addr = m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr;
          end_addr = m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr+ (2**(m_pcie_dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].get_decoded_bar_aperture())) -1;
         `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: ib_addr=%0h start_addr=%0h and end_addr= %0h", ib_addr, start_addr, end_addr ),UVM_LOW)

          if(ib_addr >= start_addr && ib_addr <= end_addr) begin
           `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF_%0d",pkt_type,ib_addr,i),UVM_LOW)
            success_hit = 1;
            return m_pcie_dev_top_cfg.pf_config[i];
          end
        end //}
      end //}
    end //}

    //Search all available VFs
    foreach(m_pcie_dev_top_cfg.vf_config[i,j]) begin //{
      if(m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) begin //{
        foreach(m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) begin //{
          if((pkt_type=="MEM") && (m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
            ((m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
              (m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_NON_PREFETCH) ||
              (m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_PREFETCH) ||
              (m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH) ||
              // PS test doesn't differentiate MSI BAR and memory BAR and consider for NP requtests.
              (puresuite_test && (m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MSI_OR_MSIX_BAR_32
              || m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MSI_OR_MSIX_BAR_64 ))
            )
          ) begin //{
            start_addr = m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr;
            end_addr = m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr+ (2**(m_pcie_dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].get_decoded_bar_aperture())) -1;

            if(ib_addr >= start_addr && ib_addr <= end_addr) begin
             `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF_%0d VF_%0d",pkt_type,ib_addr,i,j),UVM_LOW)
              success_hit = 1;
              return m_pcie_dev_top_cfg.vf_config[i][j];
            end
          end //}
        end //}
      end //}
    end //}


    if(!success_hit) begin
     `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: pkt_type=%0s with Inbound address (%0h) doesnot hit any PF/VF",pkt_type,ib_addr),UVM_LOW)
    end

  endfunction: pick_dev_cfg_for_ib_addr

  //-----------------------------------------------------------------------------
  // Function: pick_dev_cfg_for_ob_addr
  // Below API can be used when DUT is EP. It will return dev_cfg corresponding to the bar hit of incoming address
  //-----------------------------------------------------------------------------
  function  cdn_hpa_pcie_dev_config pick_dev_cfg_for_ob_addr (input bit [63:0] ib_addr, input string pkt_type="MEM") ;//Pkt_type = MEM/IO
    bit [63:0] start_addr;
    bit [63:0] end_addr;
    bit success_hit;

    if((pkt_type=="MEM") && m_pcie_strap_cfg.k_cxl_support) begin
      start_addr = m_pcie_dev_top_cfg.m_cxl_io_rcrb_bar + 2**12;
      end_addr = m_pcie_dev_top_cfg.m_cxl_io_rcrb_bar + 2**13;
      if(ib_addr >= start_addr && ib_addr <= end_addr) begin
       `uvm_info(get_full_name(),$psprintf("DEBUG_CXL_RCRB_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF0",pkt_type,ib_addr),UVM_DEBUG)
        success_hit = 1;
        return m_pcie_dev_top_cfg.pf_config[0];
      end
    end

    //Search all available PFs first
    foreach(m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i]) begin //{
      foreach(m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j]) begin //{
       `uvm_info(get_full_name(),$sformatf("m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[%0d].bars[%0d]= %0s",i, j, m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].sprint()),UVM_DEBUG)
        if(((pkt_type=="MEM") && (m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_enable) &&
          ((m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32) ||
            (m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH) ||
            (m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_PREFETCH) ||
            (m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32_PREFETCH) ||
            // PS test doesn't differentiate MSI BAR and memory BAR and consider for NP requtests.
            (puresuite_test && (m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_type == MSI_OR_MSIX_BAR_32
            ||m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_type == MSI_OR_MSIX_BAR_64 ))
          )
        ) ||
        ((pkt_type=="IO")  && (m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_enable) &&
        (m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].bar_type == IO_BAR))
        ) begin //{
          start_addr = m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].start_addr;
          end_addr = m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].start_addr+ (2**(m_pcie_dev_top_cfg.m_rp_dev_bar_info.m_pf[i].bars[j].get_decoded_bar_aperture())) -1;
         `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: ib_addr=%0h start_addr=%0h and end_addr= %0h", ib_addr, start_addr, end_addr ),UVM_LOW)

          if(ib_addr >= start_addr && ib_addr <= end_addr) begin
           `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF_%0d",pkt_type,ib_addr,i),UVM_LOW)
            success_hit = 1;
            return m_pcie_dev_top_cfg.pf_config[i];
          end
        end //}
      end //}
    end //}

    if(!success_hit) begin
     `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: pkt_type=%0s with Inbound address (%0h) doesnot hit any PF/VF",pkt_type,ib_addr),UVM_LOW)
    end

  endfunction: pick_dev_cfg_for_ob_addr

  virtual function void populate_cxl_mld_cpl (ref cdn_hpa_pcie_tlp pcie_cpl_trans, ref cdn_hpa_pcie_tlp pcie_np_req); 
    // CXL MLD support
    pcie_cpl_trans.hpa_generation = hpa_generation_2;
    if (m_pcie_dev_top_cfg.cxl_ldid_prefix   && pcie_np_req.m_tlp_local_prefix.size()>0) begin
      pcie_cpl_trans.m_local_prefix_possible    = pcie_np_req.m_local_prefix_possible;
      pcie_cpl_trans.m_max_no_of_local_prefixes = pcie_np_req.m_local_prefix_possible;
      pcie_cpl_trans.m_hdr_fmt_local_prefix     = new[(pcie_np_req.m_hdr_fmt_local_prefix.size)];//CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
      pcie_cpl_trans.m_hdr_type_local_prefix    = new[(pcie_np_req.m_hdr_type_local_prefix.size)];//CDN_HPA_PCIE_TLP_TYPE_TLP_PREFIX;
      pcie_cpl_trans.m_tlp_local_prefix_data    = new[(pcie_np_req.m_tlp_local_prefix_data.size)];//CDN_HPA_PCIE_TLP_data_TLP_PREFIX;
      pcie_cpl_trans.m_tlp_local_prefix         = new[(pcie_np_req.m_tlp_local_prefix.size)];//CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
      foreach( pcie_np_req.m_tlp_local_prefix[i]) begin 
        pcie_cpl_trans.m_hdr_fmt_local_prefix[i] = pcie_np_req.m_hdr_fmt_local_prefix[i];//CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
        pcie_cpl_trans.m_hdr_type_local_prefix[i] = pcie_np_req.m_hdr_type_local_prefix[i];//CDN_HPA_PCIE_TLP_TYPE_TLP_PREFIX;
        pcie_cpl_trans.m_tlp_local_prefix_data[i] = pcie_np_req.m_tlp_local_prefix_data[i];//CDN_HPA_PCIE_TLP_data_TLP_PREFIX;
        pcie_cpl_trans.m_tlp_local_prefix[i] = pcie_np_req.m_tlp_local_prefix[i];//CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
      end
      `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: populate_cxl_mld_cpl pcie_cpl_trans=%s and pcie_np_req=%s", pcie_cpl_trans.sprint(),pcie_np_req.sprint()), UVM_DEBUG)
    end
  endfunction: populate_cxl_mld_cpl

  virtual function void populate_fields_for_flit_mode_cpl (ref cdn_hpa_pcie_tlp pcie_cpl_trans, ref cdn_hpa_pcie_tlp pcie_np_req);
    bit send_ohc_a;

    if(m_pcie_dev_top_cfg.flit_mode_negotiated) begin //{
      pcie_cpl_trans.hpa_generation = hpa_generation_2;
      pcie_cpl_trans.is_flit_mode = 1;
      pcie_cpl_trans.pcie_6_1_support= m_pcie_dev_top_cfg.pcie_6_1_support;
      pcie_cpl_trans.m_ts = pcie_cpl_trans.m_tlp_td==1 ? CDN_HPA_PCIE_1DW_ECRC_TRAILER : CDN_HPA_PCIE_NO_TRAILER;

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
      // As per errata B28, requester must accept any segment in destination segment field of completion.
      if(pcie_np_req.m_requester_segment_valid) begin
        pcie_cpl_trans.m_destination_segment = pcie_np_req.m_requester_segment; //$urandom_range(1,255);//pcie_np_req.m_requester_segment;
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
     end
     else begin
       if(pcie_cpl_trans.pcie_6_1_support && $urandom()) pcie_cpl_trans.m_ohc_hdr.ohc_a_present = 1'b1;  //OHC_A can still present but all zeros except completer_segment because it is matched with base_segment of RID register when captured_segment is set 
       else pcie_cpl_trans.m_ohc_hdr.ohc_a_present = 1'b0;
       pcie_cpl_trans.m_ohc_a = { 8'b0,
                                  pcie_cpl_trans.m_completer_segment,
                                  16'b0
                                };
     end
     //for OHC-C(IDE Prefix in flit mode)

    end
    else begin //Non flit mode }{
      if(pcie_cpl_trans.m_ide_prefix_present)
        pcie_cpl_trans.hpa_generation = hpa_generation_2;
      else
        pcie_cpl_trans.hpa_generation = hpa_generation_1;
      pcie_cpl_trans.is_flit_mode = 0;
    end //}

  endfunction : populate_fields_for_flit_mode_cpl

  virtual function void populate_ide_fields(ref cdn_hpa_pcie_tlp cpl_tlp, ref cdn_hpa_pcie_tlp pcie_np_req);
    cpl_tlp.hpa_generation = hpa_generation_2;
    cpl_tlp.m_ide_prefix_present = 1;
    cpl_tlp.m_ide_hdr_fmt_prefix = CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
    cpl_tlp.m_ide_hdr_type_prefix = 5'b10010;
    cpl_tlp.m_stream_id = pcie_np_req.m_stream_id; //As per ECN-IDE, Stream-ID and T bit should in CPL should match with NP Req.
    cpl_tlp.m_sub_stream = 2; //As per ECN-IDE, sub_stream: P-0, NP-1 and CPL-2.
    cpl_tlp.m_ide_t = pcie_np_req.m_ide_t; //As per ECN-IDE, Stream-ID and T bit should in CPL should match with NP Req.
    cpl_tlp.m_ide_m = 1;

    if(cpl_tlp.m_tlp_payload.size() > 0) begin
      if(m_ide_cfg.link_ide_pcrc_enable[cpl_tlp.m_stream_id]) begin
        cpl_tlp.m_ide_p = 1;
      end
      if(m_ide_cfg.m_ide_selective_stream_config[cpl_tlp.m_stream_id] != null) begin
        if(m_ide_cfg.m_ide_selective_stream_config[cpl_tlp.m_stream_id].m_pcrc_enable) cpl_tlp.m_ide_p = 1;
      end
    end
    else begin
      cpl_tlp.m_ide_p = 0;
    end

    //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: before cpl ide_mac_tlp_idx[%0h][%0d] = %0d"   ,cpl_tlp.m_stream_id,cpl_tlp.m_sub_stream,/*cpl_tlp.m_pcie_dev_top_cfg.*/m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]),UVM_DEBUG);
    //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: before cpl ob_ide_tlp_count[%0h][%0d] = %0d"  ,cpl_tlp.m_stream_id,cpl_tlp.m_sub_stream,/*cpl_tlp.m_pcie_dev_top_cfg.*/m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]),UVM_DEBUG);
    //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: before cpl ob_ide_tlp_payload[%0h][%0d] = %0d",cpl_tlp.m_stream_id,cpl_tlp.m_sub_stream,/*cpl_tlp.m_pcie_dev_top_cfg.*/m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]),UVM_DEBUG);
    if(m_ide_cfg.m_aggr_supp) begin
      if(m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] == 0) begin
        if(m_pcie_dev_top_cfg.i_cfg.strap_is_rp) begin
          case(cpl_tlp.m_sub_stream)
            4'h0 : m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = $urandom_range(1,(32'h1 << m_ide_cfg.dsp_link_ide_tx_pr_aggr_mode[cpl_tlp.m_stream_id] ));
            4'h1 : m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = $urandom_range(1,(32'h1 << m_ide_cfg.dsp_link_ide_tx_npr_aggr_mode[cpl_tlp.m_stream_id]));
            4'h2 : m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = $urandom_range(1,(32'h1 << m_ide_cfg.dsp_link_ide_tx_cpl_aggr_mode[cpl_tlp.m_stream_id]));
          endcase
        end
        else begin
          case(cpl_tlp.m_sub_stream)
            4'h0 : m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = $urandom_range(1,(32'h1 << m_ide_cfg.usp_link_ide_tx_pr_aggr_mode[cpl_tlp.m_stream_id] ));
            4'h1 : m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = $urandom_range(1,(32'h1 << m_ide_cfg.usp_link_ide_tx_npr_aggr_mode[cpl_tlp.m_stream_id]));
            4'h2 : m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = $urandom_range(1,(32'h1 << m_ide_cfg.usp_link_ide_tx_cpl_aggr_mode[cpl_tlp.m_stream_id]));
          endcase
        end
      end

      cpl_tlp.m_ide_m = 0;
      cpl_tlp.m_ide_p = 0;
      m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]++;
      m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] += (cpl_tlp.m_tlp_payload.size()/4);

      //complete aggregate if it is the last completion with data or if it is completion without data
      if(cpl_tlp.m_tlp_cpl_byte_cnt <= ((cpl_tlp.m_tlp_length) * 4) || (cpl_tlp.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl)) begin
        cpl_tlp.m_ide_m = 1;
        if(cpl_tlp.m_tlp_payload.size() > 0) begin
          if(m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] > 0) begin
            if(m_ide_cfg.link_ide_pcrc_enable[cpl_tlp.m_stream_id]) begin
              cpl_tlp.m_ide_p = 1;
            end
            if(m_ide_cfg.m_ide_selective_stream_config[cpl_tlp.m_stream_id] != null) begin
              if(m_ide_cfg.m_ide_selective_stream_config[cpl_tlp.m_stream_id].m_pcrc_enable) cpl_tlp.m_ide_p = 1;
            end
          end
        end else begin
          cpl_tlp.m_ide_p = 0;
        end
        //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: cpl_tlp last tlp or completion without payload"), UVM_DEBUG);
        m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = 0;
        m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = 0;
      end
      else if(m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] == m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]) begin
        cpl_tlp.m_ide_m = 1;
        if(m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] > 0) begin
          if(m_ide_cfg.link_ide_pcrc_enable[cpl_tlp.m_stream_id]) begin
            cpl_tlp.m_ide_p = 1;
          end
          if(m_ide_cfg.m_ide_selective_stream_config[cpl_tlp.m_stream_id] != null) begin
            if(m_ide_cfg.m_ide_selective_stream_config[cpl_tlp.m_stream_id].m_pcrc_enable) cpl_tlp.m_ide_p = 1;
          end
        end
        m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = 0;
        m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = 0;
        //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: cpl_tlp count reached aggregation limit "), UVM_DEBUG);
      end
      else if(m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] < m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]) begin
        if(m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] > 192) begin //soumitm :: TODO :: make the limit smarter
          cpl_tlp.m_ide_m = 1;
          if(m_ide_cfg.link_ide_pcrc_enable[cpl_tlp.m_stream_id]) begin
            cpl_tlp.m_ide_p = 1;
          end
          if(m_ide_cfg.m_ide_selective_stream_config[cpl_tlp.m_stream_id] != null) begin
            if(m_ide_cfg.m_ide_selective_stream_config[cpl_tlp.m_stream_id].m_pcrc_enable) cpl_tlp.m_ide_p = 1;
          end
          m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = 0;
          m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = 0;
          //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: cpl_tlp payload reached aggregation limit "), UVM_DEBUG);
        end
      end
    end
    //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: cpl ide_mac_tlp_idx[%0h][%0d] = %0d"   ,cpl_tlp.m_stream_id,cpl_tlp.m_sub_stream,/*cpl_tlp.m_pcie_dev_top_cfg.*/m_ide_cfg.ide_mac_tlp_idx[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]),UVM_DEBUG);
    //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: cpl ob_ide_tlp_count[%0h][%0d] = %0d"  ,cpl_tlp.m_stream_id,cpl_tlp.m_sub_stream,/*cpl_tlp.m_pcie_dev_top_cfg.*/m_ide_cfg.ob_ide_tlp_count[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]),UVM_DEBUG);
    //`uvm_info(get_full_name(),$psprintf("[DEBUG_AGGR] :: debug :: cpl ob_ide_tlp_payload[%0h][%0d] = %0d",cpl_tlp.m_stream_id,cpl_tlp.m_sub_stream,/*cpl_tlp.m_pcie_dev_top_cfg.*/m_ide_cfg.ob_ide_tlp_payload[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream]),UVM_DEBUG);
    cpl_tlp.m_ide_tlp_prefix = {cpl_tlp.m_ide_hdr_fmt_prefix, cpl_tlp.m_ide_hdr_type_prefix, cpl_tlp.m_pr_sent_counter, cpl_tlp.m_stream_id,
    cpl_tlp.m_sub_stream, cpl_tlp.m_ide_p, cpl_tlp.m_ide_m, cpl_tlp.m_ide_k, cpl_tlp.m_ide_t};
    m_ide_cfg.is_aggregation_complete[cpl_tlp.m_stream_id][cpl_tlp.m_sub_stream] = cpl_tlp.m_ide_m;

    if(cpl_tlp.is_flit_mode) begin
      cpl_tlp.m_ohc_hdr.ohc_c_present = 1;
      cpl_tlp.recalc_ide_prefix();
      cpl_tlp.m_ts = (cpl_tlp.m_ide_p ? CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER : CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER);
    end
  endfunction : populate_ide_fields

  //-----------------------------------------------------------------------------
  // Function: write_ib_np_req_port
  // Implement the TLM Analysis port write_ib_np_req_port() method.
  //-----------------------------------------------------------------------------
  virtual function void write_ib_np_req_port(cdn_hpa_pcie_tlp  pcie_np_req);
    // !!!! TODO Clone the NP request and cast it as we may recive new np requests !!!!!
    cdn_hpa_pcie_tlp        pcie_cpl_trans;
    cdn_hpa_pcie_tlp        pcie_cpl_trans_copy;
    cdn_hpa_pcie_dev_config np_req_hit_dev_cfg;
    string                  tlp_trans_type;
    bit                     send_ur_cpl;
    bit                     send_cpld_with_all_zeros;
    shortint unsigned       max_cpl_length;
    shortint unsigned       cpl_rcb;
    bit[1:0]                cpl_status;

    pcie_cpl_trans = new();
    pcie_cpl_trans_copy = new();
    pcie_cpl_trans_copy.np_req_tlp = new();

    assert(std::randomize(send_cpld_with_all_zeros) with {
                          send_cpld_with_all_zeros dist {0:=70 , 1:=30};
                          });

    if(!$cast(pcie_cpl_trans.np_req_tlp, pcie_np_req.clone()))
     `uvm_fatal("get_full_name", "Cast failed!!")

    if(m_dut_mode == EP) begin
     `uvm_info(get_full_name(),"m_dut_mode is EP for Completion",UVM_LOW)
      tlp_trans_type = ((pcie_np_req.m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_IOWr) ||
                        (pcie_np_req.m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_IORd)) ? "IO" : "MEM";

     if(pcie_np_req.m_tlp_trans_type  == CDN_HPA_PCIE_TRANS_CFG_TYPE) begin
       np_req_hit_dev_cfg = m_pcie_dev_top_cfg.pf_config[0]; //RP has 1 function
     end
     else begin
       `ifdef HLS_MODULE_MODE
          if(pcie_np_req.is_ib_pkt==0)
            np_req_hit_dev_cfg = pick_dev_cfg_for_ob_addr(pcie_np_req.m_tlp_addr,tlp_trans_type);
          else
            np_req_hit_dev_cfg = pick_dev_cfg_for_ib_addr(pcie_np_req.m_tlp_addr,tlp_trans_type);
       `else
          np_req_hit_dev_cfg = pick_dev_cfg_for_ib_addr(pcie_np_req.m_tlp_addr,tlp_trans_type);
       `endif
     end
    end
    else begin
     `uvm_info(get_full_name(),"m_dut_mode is RP for Completion",UVM_LOW)
      np_req_hit_dev_cfg = m_pcie_dev_top_cfg.pf_config[0]; //RP has 1 function
    end

    if(np_req_hit_dev_cfg == null) begin
     `ifdef HLS_MODULE_MODE
       `uvm_info(get_full_name(), $psprintf("Null handle returned for dev_cfg corresp to IB_address of Np pkt %0s",pcie_np_req.sprint()),UVM_DEBUG)
        np_req_hit_dev_cfg = m_pcie_dev_top_cfg.pf_config[0];
        //return;
        //if(pcie_np_req.vip_userdata.m_error_injects[0] == CDN_HPA_PCIE_TLP_MEM_TX_BAR_UR_ERR)
        //  return;
        //else
        //`uvm_error(get_full_name(), $psprintf("Null handle returned for dev_cfg corresp to IB_address of Np pkt %0s",pcie_np_req.sprint()))
     `else
       // CXL-2370 
       if (m_pcie_dev_top_cfg.scenario.cxl_io_bar_check_disable_ep && m_pcie_dev_top_cfg.force_bar_chk_rp) begin
         `uvm_info(get_full_name(),"m_dut_mode is RP for Completion",UVM_LOW)
          np_req_hit_dev_cfg = m_pcie_dev_top_cfg.pf_config[0]; //RP has 1 function
          //np_req_hit_dev_cfg.m_pf_num,np_req_hit_dev_cfg.m_vf_num, pcie_np_req.m_tlp_addr),UVM_LOW)
       end
       `uvm_error(get_full_name(), $psprintf("Null handle returned for dev_cfg corresp to IB_address of Np pkt %0s",pcie_np_req.sprint()))
     `endif
    end
    else begin
     `uvm_info("DEBUG_CPL_GEN", $psprintf("Dev cfg [PF=%0h VF=%0h]returned corresp to IB_address of Np pkt(Address=%0h)",
      np_req_hit_dev_cfg.m_pf_num,np_req_hit_dev_cfg.m_vf_num, pcie_np_req.m_tlp_addr),UVM_LOW)
    end

    //cpl_rcb = ((np_req_hit_dev_cfg.m_rcb == 1) ? 128 : 64);
    cpl_rcb = 128;
     `uvm_info("DEBUG_CPL_GEN", $psprintf("np_req_hit_dev_cfg.m_rcb=%0b",np_req_hit_dev_cfg.m_rcb), UVM_LOW)
    pcie_cpl_trans.cfg2hls_tlp                   = pcie_np_req.hlsob2cfg_tlp;
    //pcie_cpl_trans.m_pcie_dev_cfg = m_dut_pcie_dev_cfg; // TODO
    pcie_cpl_trans.m_tlp_req_type                  = CDN_HPA_PCIE_TRANS_COMPLETION;
    pcie_cpl_trans.m_tlp_trans_type                = CDN_HPA_PCIE_TRANS_CPL_TYPE;
    pcie_cpl_trans.m_hdr_type                      = 5'b01010;
    pcie_cpl_trans.m_tlp_14_bit_tagscale           = pcie_np_req.m_tlp_14_bit_tagscale;
    pcie_cpl_trans.m_tlp_t9                        = pcie_np_req.m_tlp_t9;
    pcie_cpl_trans.m_tlp_tc                        = pcie_np_req.m_tlp_tc;
    pcie_cpl_trans.m_tlp_t8                        = pcie_np_req.m_tlp_t8;
    pcie_cpl_trans.m_tlp_attr1                     = (pcie_np_req.m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) ? 0: (np_req_hit_dev_cfg.m_ido_cpl_en & m_pcie_dev_top_cfg.id_based_order_init_done); //For Trans completion IDO is reserved
    pcie_cpl_trans.m_tlp_th                        = 0;
   `ifdef HPA_ARCH2
      //pcie_cpl_trans.m_tlp_td                    = (np_req_hit_dev_cfg.m_ecrc_gen_en && (pcie_np_req.m_ide_prefix_present==0)) ? (m_pcie_dev_top_cfg.m_tl_to_pack_ecrc  ? 0 : 1) : 0;
      pcie_cpl_trans.m_tlp_td                      = (np_req_hit_dev_cfg.m_ecrc_gen_en && (pcie_np_req.m_ide_prefix_present==0)) ? m_pcie_dev_top_cfg.ecrc_init_done : 0;
      //pcie_cpl_trans.pack_ecrc = 1;
   `else
      pcie_cpl_trans.m_tlp_td                      = 0;
   `endif
    pcie_cpl_trans.m_tlp_attr0                     = pcie_np_req.m_tlp_attr0;
    pcie_cpl_trans.m_tlp_at_type                   = CDN_HPA_PCIE_AT_Untranslated;
    pcie_cpl_trans.hpa_generation                  = pcie_np_req.hpa_generation;
    
    if(pcie_np_req.m_tlp_local_prefix.size() > 0) begin
      pcie_cpl_trans.m_local_prefix_possible    = pcie_np_req.m_local_prefix_possible;
      pcie_cpl_trans.m_max_no_of_local_prefixes = pcie_np_req.m_max_no_of_local_prefixes;
      pcie_cpl_trans.m_tlp_local_prefix         = new[pcie_np_req.m_tlp_local_prefix.size()];
      pcie_cpl_trans.m_tlp_local_prefix_data    = new[pcie_np_req.m_tlp_local_prefix_data.size()];
      pcie_cpl_trans.m_hdr_fmt_local_prefix     = new[pcie_np_req.m_hdr_fmt_local_prefix.size()];
      pcie_cpl_trans.m_hdr_type_local_prefix    = new[pcie_np_req.m_hdr_type_local_prefix.size()];
      foreach(pcie_np_req.m_tlp_local_prefix[i]) begin
        pcie_cpl_trans.m_tlp_local_prefix[i] = pcie_np_req.m_tlp_local_prefix[i];
      end
      foreach(pcie_np_req.m_tlp_local_prefix_data[i]) begin
        pcie_cpl_trans.m_tlp_local_prefix_data[i] = pcie_np_req.m_tlp_local_prefix_data[i];
      end
      foreach(pcie_np_req.m_hdr_fmt_local_prefix[i]) begin
        pcie_cpl_trans.m_hdr_fmt_local_prefix[i] = pcie_np_req.m_hdr_fmt_local_prefix[i];
      end
      foreach(pcie_np_req.m_hdr_type_local_prefix[i]) begin
        pcie_cpl_trans.m_hdr_type_local_prefix[i] = pcie_np_req.m_hdr_type_local_prefix[i];
      end
    end

    // TODO : Need to chnage the device config class memebers to generic
    //if(m_dut_mode == EP) begin
    if((np_req_hit_dev_cfg.m_req_id.bus_num != pcie_np_req.m_tlp_completer_id.bus_num) && (pcie_np_req.m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE)) begin
      pcie_cpl_trans.m_tlp_completer_id.bus_num      = pcie_np_req.m_tlp_completer_id.bus_num;
      pcie_cpl_trans.m_tlp_completer_id.device_num   = pcie_np_req.m_tlp_completer_id.device_num;
      pcie_cpl_trans.m_tlp_completer_id.function_num = pcie_np_req.m_tlp_completer_id.function_num;
    end
    else begin
      pcie_cpl_trans.m_tlp_completer_id.bus_num      = np_req_hit_dev_cfg.m_req_id.bus_num;
      pcie_cpl_trans.m_tlp_completer_id.device_num   = np_req_hit_dev_cfg.m_req_id.device_num;
      pcie_cpl_trans.m_tlp_completer_id.function_num = np_req_hit_dev_cfg.m_req_id.function_num;
    end
    //end else begin
    // pcie_cpl_trans.m_tlp_completer_id.bus_num      = m_pcie_dev_cfg.m_req_id.bus_num;
    // pcie_cpl_trans.m_tlp_completer_id.device_num   = m_pcie_dev_cfg.m_req_id.device_num;
    // pcie_cpl_trans.m_tlp_completer_id.function_num = m_pcie_dev_cfg.m_req_id.function_num;
    //end
    pcie_cpl_trans.m_tlp_cpl_bcm                   = 0;
    pcie_cpl_trans.m_tlp_requester_id.bus_num      = pcie_np_req.m_tlp_requester_id.bus_num;
    pcie_cpl_trans.m_tlp_requester_id.device_num   = pcie_np_req.m_tlp_requester_id.device_num;
    pcie_cpl_trans.m_tlp_requester_id.function_num = pcie_np_req.m_tlp_requester_id.function_num;
    pcie_cpl_trans.m_tlp_tag                       = pcie_np_req.m_tlp_tag;
    
    //CXL PBR PTH; Swapping DPID, SPID
    pcie_cpl_trans.m_tlp_pth_hie                   = pcie_np_req.m_tlp_pth_hie;
    pcie_cpl_trans.m_tlp_pth_dsar                  = pcie_np_req.m_tlp_pth_dsar;
    pcie_cpl_trans.m_tlp_pth_pif                   = pcie_np_req.m_tlp_pth_pif;
    pcie_cpl_trans.m_tlp_pth_spid                  = pcie_np_req.m_tlp_pth_dpid;
    pcie_cpl_trans.m_tlp_pth_dpid                  = pcie_np_req.m_tlp_pth_spid;
    pcie_cpl_trans.m_tlp_pth_rsvd                  = pcie_np_req.m_tlp_pth_rsvd;
    pcie_cpl_trans.is_cxl_pbr_mode                 = pcie_np_req.is_cxl_pbr_mode;
    //Set to 0 for mismatch in IDE branch at HLS mod
    pcie_cpl_trans.m_tlp_pbr_tlp_header            = pcie_cpl_trans.is_cxl_pbr_mode ? {2'b11, pcie_cpl_trans.m_tlp_pth_rsvd, pcie_cpl_trans.m_tlp_pth_hie, pcie_cpl_trans.m_tlp_pth_dsar, pcie_cpl_trans.m_tlp_pth_pif, pcie_cpl_trans.m_tlp_pth_spid, pcie_cpl_trans.m_tlp_pth_dpid} : 32'b0;

    if(!randomize(expect_end_error) with {expect_end_error dist {0:=80, 1:=20};}) begin
       `uvm_error(get_type_name(), "expect_end_error randomization fail")
    end
    pcie_cpl_trans.m_expect_enderror               = $urandom_range(0,1);

    if(puresuite_test) begin
      temp_cpl_status = CDN_HPA_PCIE_CPL_SC;
      pcie_cpl_trans.m_tlp_ep = 0;
    end
    else begin
      if(m_pcie_strap_cfg.scenario && (m_pcie_strap_cfg.scenario.m_enable_ob_ca_status) && (m_pcie_dev_top_cfg.is_dut_config) && (m_pcie_dev_top_cfg.stop_scen_ca_ur_cpl==0)) begin//TODO: multiple b2b cpl errors
        if (!randomize(temp_cpl_status) with {
          temp_cpl_status dist {CDN_HPA_PCIE_CPL_SC:=80,CDN_HPA_PCIE_CPL_ABORT:=5, CDN_HPA_PCIE_CPL_UR:=5};
        })
       `uvm_error(get_type_name(), "[generate_cpl_trans] cpl_status randomization fail")
	     `uvm_info(get_name(),$psprintf("OB_CA_UR_CPL Scenario %s shdw_hdr_log=%p, shdw_prefix_log=%p",temp_cpl_status.name(),m_pcie_dev_top_cfg.shdw_hdr_log,m_pcie_dev_top_cfg.shdw_prefix_log),UVM_LOW)
       if(temp_cpl_status==CDN_HPA_PCIE_CPL_ABORT || temp_cpl_status==CDN_HPA_PCIE_CPL_UR)begin
         //m_pcie_dev_top_cfg.shdw_ca_ur_pf_vf = m_pcie_dev_top_cfg.get_pf_vf_from_req_id(pcie_np_req.m_tlp_requester_id);
	       m_pcie_dev_top_cfg.shdw_ca_ur_pf_vf.pf = np_req_hit_dev_cfg.m_pf_num;
	       m_pcie_dev_top_cfg.shdw_ca_ur_pf_vf.vf = np_req_hit_dev_cfg.m_vf_num;
         m_pcie_dev_top_cfg.shdw_hdr_log[0][31:24]={pcie_np_req.m_tlp_length[7:0]};
         m_pcie_dev_top_cfg.shdw_hdr_log[0][23:16]={pcie_np_req.m_tlp_td,pcie_np_req.m_tlp_ep,pcie_np_req.m_tlp_attr0,pcie_np_req.m_tlp_at_type,pcie_np_req.m_tlp_length[9:8]};
         m_pcie_dev_top_cfg.shdw_hdr_log[0][15:8] ={pcie_np_req.m_tlp_t9,pcie_np_req.m_tlp_tc,pcie_np_req.m_tlp_t8,pcie_np_req.m_tlp_attr1,pcie_np_req.m_tlp_ln,pcie_np_req.m_tlp_th};
         m_pcie_dev_top_cfg.shdw_hdr_log[0][7:0]  ={pcie_np_req.m_hdr_fmt,pcie_np_req.m_tlp_type};
         
	       m_pcie_dev_top_cfg.shdw_hdr_log[1][31:24]={pcie_np_req.m_tlp_last_dw_be,pcie_np_req.m_tlp_first_dw_be};
	       m_pcie_dev_top_cfg.shdw_hdr_log[1][23:16]={pcie_np_req.m_tlp_tag};
         m_pcie_dev_top_cfg.shdw_hdr_log[1][15:8] ={pcie_np_req.m_tlp_requester_id.device_num,pcie_np_req.m_tlp_requester_id.function_num};
         m_pcie_dev_top_cfg.shdw_hdr_log[1][7:0]  ={pcie_np_req.m_tlp_requester_id.bus_num};
	       if(pcie_np_req.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_DMWr_64,CDN_HPA_PCIE_TLP_TYPE_MRd_64,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
                                             CDN_HPA_PCIE_TLP_TYPE_Swap_64,CDN_HPA_PCIE_TLP_TYPE_Cas_64,CDN_HPA_PCIE_TLP_TYPE_UIOMRd}) begin
 	         m_pcie_dev_top_cfg.shdw_hdr_log[2][31:0]={pcie_np_req.m_tlp_addr[63:32]};
 	         m_pcie_dev_top_cfg.shdw_hdr_log[3][31:2]={pcie_np_req.m_tlp_addr[31:2]};
 	         m_pcie_dev_top_cfg.shdw_hdr_log[3][1:0]={pcie_np_req.m_tlp_ph[1:0]};
	       end
	       else begin
 	         m_pcie_dev_top_cfg.shdw_hdr_log[2][31:24]={pcie_np_req.m_tlp_addr[7:0]};
 	         m_pcie_dev_top_cfg.shdw_hdr_log[2][23:16]={pcie_np_req.m_tlp_addr[15:8]};
 	         m_pcie_dev_top_cfg.shdw_hdr_log[2][15:8]={pcie_np_req.m_tlp_addr[23:16]};
 	         m_pcie_dev_top_cfg.shdw_hdr_log[2][7:2]={pcie_np_req.m_tlp_addr[31:26]};
 	         m_pcie_dev_top_cfg.shdw_hdr_log[2][1:0]={pcie_np_req.m_tlp_ph[1:0]};
	       end
         foreach(pcie_np_req.m_tlp_prefix[i])begin
	        m_pcie_dev_top_cfg.shdw_prefix_log[i]=pcie_np_req.m_tlp_prefix[i];
	       end
          
         if(temp_cpl_status==CDN_HPA_PCIE_CPL_ABORT)begin
	         `uvm_info(get_name(),$psprintf("OB_CA_UR_CPL Scenario %s shdw_hdr_log=%p, shdw_prefix_log=%p",temp_cpl_status.name(),m_pcie_dev_top_cfg.shdw_hdr_log,m_pcie_dev_top_cfg.shdw_prefix_log),UVM_LOW)
           -> m_pcie_dev_top_cfg.ob_hls_sent_ca_cpl;
           //->  dev_seqr.m_pcie_dev_top_cfg.ob_hls_sent_ca_cpl;
	       end
         if(temp_cpl_status==CDN_HPA_PCIE_CPL_UR)begin
           -> m_pcie_dev_top_cfg.ob_hls_sent_ur_cpl;
           //->  dev_seqr.m_pcie_dev_top_cfg.ob_hls_sent_ur_cpl;
      	 end
       end
      end
      else begin
        temp_cpl_status = CDN_HPA_PCIE_CPL_SC;
      end
      //OB poison CPL error injection, to avoid multiple error, inject only with SC CPL
      // EP for UIO is Reserved - randomize it to check if DUT ignore that bit
      if(m_pcie_strap_cfg.scenario && (m_pcie_strap_cfg.scenario.m_enable_ob_poison_err) && (temp_cpl_status == CDN_HPA_PCIE_CPL_SC) && (m_pcie_dev_top_cfg.is_dut_config)) begin
        pcie_cpl_trans.m_tlp_ep = $urandom();
      end
      else begin
        pcie_cpl_trans.m_tlp_ep = 0;
      end
    end

    // IOWr and CfgWr Cpl
    if ( pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IOWr   ||
         pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr0 ||
         pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr1 ||
         pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32 ||
         pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64
    ) begin

      // As we are randoming in the sequencer it expectes sequncer.. Either chnage the TLP are do not randomize here

      //if (!pcie_cpl_trans.randomize() with {np_req_tlp == pcie_np_req; m_hdr_fmt == CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
      //     m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl; m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION;
      //    }) begin
      //  `uvm_error(get_type_name(), "Completion Randomization fail")
      //end
      pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
      pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_Cpl;
      pcie_cpl_trans.m_tlp_req_type              = CDN_HPA_PCIE_TRANS_COMPLETION;
      pcie_cpl_trans.m_tlp_cpl_byte_cnt          = 4;
      pcie_cpl_trans.m_tlp_cpl_lower_addr        = 0;
      pcie_cpl_trans.m_tlp_ln                    = 0;
      pcie_cpl_trans.m_tlp_length                = 0;
      if(pcie_cpl_trans.m_expect_enderror && m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror && !is_hls_module_tb) begin
        pcie_cpl_trans.m_tlp_cpl_status            = CDN_HPA_PCIE_CPL_SC;
      end
      else begin
        pcie_cpl_trans.m_tlp_cpl_status            = temp_cpl_status;
      end

      populate_fields_for_flit_mode_cpl(pcie_cpl_trans,pcie_np_req);
      if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans,pcie_np_req);
      populate_cxl_mld_cpl(pcie_cpl_trans,pcie_np_req);
      void'(pcie_cpl_trans.pack_bytes(pcie_cpl_trans.m_data));
      pcie_cpl_trans.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
     `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans.m_data), UVM_DEBUG)
      cpl_trans_q.push_back(pcie_cpl_trans);
      if(pcie_cpl_trans.m_expect_enderror && m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror && !is_hls_module_tb) begin
        `uvm_info(get_type_name(), $psprintf("Create 2 copy"), UVM_DEBUG)
        pcie_cpl_trans_copy.copy(pcie_cpl_trans);
        pcie_cpl_trans_copy.np_req_tlp.copy(pcie_cpl_trans.np_req_tlp);
        pcie_cpl_trans_copy.m_expect_enderror = 0;
        pcie_cpl_trans_copy.m_tlp_cpl_status = temp_cpl_status;
        if (pcie_cpl_trans_copy.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC) begin
          populate_fields_for_flit_mode_cpl(pcie_cpl_trans_copy,pcie_np_req);
          if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans_copy,pcie_np_req);
          populate_cxl_mld_cpl(pcie_cpl_trans_copy,pcie_np_req);
          void'(pcie_cpl_trans_copy.pack_bytes(pcie_cpl_trans_copy.m_data));
          pcie_cpl_trans_copy.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
          `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans_copy.m_data), UVM_DEBUG)
        end
        cpl_trans_q.push_back(pcie_cpl_trans_copy);
      end
    end
    // IORd and CfgRd Cpl
    else if ( pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IORd   ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd0 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd1 ) begin

      //if (!pcie_cpl_trans.randomize() with {np_req_tlp == pcie_np_req; m_hdr_fmt == CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA;
      //     m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplD; m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION;
      //    }) begin
      //  `uvm_error(get_type_name(), "Completion Randomization fail")
      //end

      pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA;
      pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_CplD;
      pcie_cpl_trans.m_tlp_req_type              = CDN_HPA_PCIE_TRANS_COMPLETION;
      pcie_cpl_trans.m_tlp_cpl_byte_cnt          = 4;
      pcie_cpl_trans.m_tlp_cpl_lower_addr        = 0;
      pcie_cpl_trans.m_tlp_ln                    = pcie_np_req.m_tlp_ln;
      if(pcie_cpl_trans.m_expect_enderror && m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror && !is_hls_module_tb) begin
        pcie_cpl_trans.m_tlp_cpl_status          = CDN_HPA_PCIE_CPL_SC;
      end
      else begin
        pcie_cpl_trans.m_tlp_cpl_status          = temp_cpl_status;
      end

      if(pcie_cpl_trans.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC)
      begin
        pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
        pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_Cpl;
        pcie_cpl_trans.m_tlp_length                = 0;
      end
      else
      begin
        pcie_cpl_trans.m_tlp_length     = 1;
        // data
        cpl_payload                     = new[4];
        if (!randomize(cpl_payload)) begin
         `uvm_error(get_type_name(), "cpl_payload randomization fail")
        end

        if(send_cpld_with_all_zeros) begin
          foreach(cpl_payload[i]) cpl_payload[i]=8'h0; //Making all payload as zeros
        end

        // Only required for Puresuite tests
        if(puresuite_test && m_pcie_dev_top_cfg.memory_written) begin
          for(int unsigned i=0; i<4; i++)
            cpl_payload[i] = m_pcie_dev_top_cfg.ib_mwr_data[{pcie_np_req.m_tlp_addr[63:2],2'b00}+i];
          m_pcie_dev_top_cfg.memory_written = 0;
        end

        pcie_cpl_trans.m_tlp_payload            = cpl_payload;
        pcie_cpl_trans.m_tlp_cpl_byte_cnt          = 4;
        pcie_cpl_trans.m_tlp_cpl_lower_addr        = 0;
      end

      populate_fields_for_flit_mode_cpl(pcie_cpl_trans,pcie_np_req);
      if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans,pcie_np_req);
      populate_cxl_mld_cpl(pcie_cpl_trans,pcie_np_req);
      void'(pcie_cpl_trans.pack_bytes(pcie_cpl_trans.m_data));
      pcie_cpl_trans.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
     `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans.m_data), UVM_DEBUG)
     `uvm_info(get_type_name(), $psprintf("tag =%0h, pcie_cpl=%p", {pcie_cpl_trans.m_tlp_14_bit_tagscale, pcie_cpl_trans.m_tlp_t9, pcie_cpl_trans.m_tlp_t8, pcie_cpl_trans.m_tlp_tag}, pcie_cpl_trans.sprint()), UVM_DEBUG)
      cpl_trans_q.push_back(pcie_cpl_trans);
      if(pcie_cpl_trans.m_expect_enderror && m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror && !is_hls_module_tb) begin
        `uvm_info(get_type_name(), $psprintf("Create 2 copy"), UVM_DEBUG)
        pcie_cpl_trans_copy.copy(pcie_cpl_trans);
        pcie_cpl_trans_copy.np_req_tlp.copy(pcie_cpl_trans.np_req_tlp);
        pcie_cpl_trans_copy.m_expect_enderror = 0;
        pcie_cpl_trans_copy.m_tlp_cpl_status       = temp_cpl_status;
        if (pcie_cpl_trans_copy.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC) begin
          pcie_cpl_trans_copy.m_hdr_fmt    = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
          pcie_cpl_trans_copy.m_tlp_type   = CDN_HPA_PCIE_TLP_TYPE_Cpl;
          pcie_cpl_trans_copy.m_tlp_length = 0;
          populate_fields_for_flit_mode_cpl(pcie_cpl_trans_copy,pcie_np_req);
          if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans_copy,pcie_np_req);
          populate_cxl_mld_cpl(pcie_cpl_trans_copy,pcie_np_req);
          void'(pcie_cpl_trans_copy.pack_bytes(pcie_cpl_trans_copy.m_data));
          pcie_cpl_trans_copy.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
         `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans_copy.m_data), UVM_DEBUG)
         `uvm_info(get_type_name(), $psprintf("tag =%0h, pcie_cpl=%p", {pcie_cpl_trans_copy.m_tlp_14_bit_tagscale, pcie_cpl_trans_copy.m_tlp_t9, pcie_cpl_trans_copy.m_tlp_t8, pcie_cpl_trans_copy.m_tlp_tag}, pcie_cpl_trans_copy.sprint()), UVM_DEBUG)          
        end
        cpl_trans_q.push_back(pcie_cpl_trans_copy);
      end
    end
    // MRd Cpl
    else if ( pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64 ) begin //{
      shortint unsigned            byte_count;
      bit [6:0]                    lower_addr;
      shortint unsigned            req_length;
      bit                          is_cpl_complete;

      //if (!pcie_cpl_trans.randomize() with {np_req_tlp == pcie_np_req; m_hdr_fmt == CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA;
      //     m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplD; m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION;
      //    }) begin
      //  `uvm_error(get_type_name(), "Completion Randomization fail")
      //end

      pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA;
      pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_CplD;
      pcie_cpl_trans.m_tlp_req_type              = CDN_HPA_PCIE_TRANS_COMPLETION;
      pcie_cpl_trans.m_tlp_ln                    = pcie_np_req.m_tlp_ln;
      //pcie_cpl_trans.m_tlp_cpl_status            = CDN_HPA_PCIE_CPL_SC; //Ankur::randomize
      pcie_cpl_trans.m_expect_enderror           = 0;

      req_length = (pcie_np_req.m_tlp_length == 0) ? 1024 : pcie_np_req.m_tlp_length;
      if(pcie_np_req.m_tlp_th == 1) begin //If TH bit set FBE and LBE are assumed to be 'hFF
        byte_count = req_length*4;
      end else if (pcie_np_req.m_tlp_first_dw_be == 4'h0) begin
        byte_count = 1;
      end else if (pcie_np_req.m_tlp_last_dw_be == 4'h0) begin
        if(pcie_np_req.m_tlp_first_dw_be inside {4'b1??1})
          byte_count = req_length*4;
        else if(pcie_np_req.m_tlp_first_dw_be inside {4'b01?1,4'b1?10})
          byte_count = (req_length*4) - 1;
        else
          byte_count = $countones(pcie_np_req.m_tlp_first_dw_be);

      end else if (pcie_np_req.m_tlp_first_dw_be inside {4'b???1})begin
        byte_count = (pcie_np_req.m_tlp_last_dw_be inside {4'b1???}) ? (req_length*4) : (pcie_np_req.m_tlp_last_dw_be inside {4'b01??}) ? (req_length*4)-1 : (pcie_np_req.m_tlp_last_dw_be inside {4'b001?}) ? (req_length*4)-2:               (pcie_np_req.m_tlp_last_dw_be inside {4'b0001}) ? (req_length*4)-3 : 4;

      end else if (pcie_np_req.m_tlp_first_dw_be inside {4'b??10})begin
        byte_count = (pcie_np_req.m_tlp_last_dw_be inside {4'b1???}) ? (req_length*4)-1 : (pcie_np_req.m_tlp_last_dw_be inside {4'b01??}) ? (req_length*4)-2 : (pcie_np_req.m_tlp_last_dw_be inside {4'b001?}) ? (req_length*4)-3:               (pcie_np_req.m_tlp_last_dw_be inside {4'b0001}) ? (req_length*4)-4 : 4;

      end else if (pcie_np_req.m_tlp_first_dw_be inside {4'b?100})begin
        byte_count = (pcie_np_req.m_tlp_last_dw_be inside {4'b1???}) ? (req_length*4)-2 : (pcie_np_req.m_tlp_last_dw_be inside {4'b01??}) ? (req_length*4)-3 : (pcie_np_req.m_tlp_last_dw_be inside {4'b001?}) ? (req_length*4)-4:               (pcie_np_req.m_tlp_last_dw_be inside {4'b0001}) ? (req_length*4)-5 : 4;

      end else if (pcie_np_req.m_tlp_first_dw_be inside {4'b1000})begin
        byte_count = (pcie_np_req.m_tlp_last_dw_be inside {4'b1???}) ? (req_length*4)-3 : (pcie_np_req.m_tlp_last_dw_be inside {4'b01??}) ? (req_length*4)-4 : (pcie_np_req.m_tlp_last_dw_be inside {4'b001?}) ? (req_length*4)-5:               (pcie_np_req.m_tlp_last_dw_be inside {4'b0001}) ? (req_length*4)-6 : 4;

      end else begin
        byte_count = req_length*4 -
        (8 - $countones(pcie_np_req.m_tlp_first_dw_be) - $countones(pcie_np_req.m_tlp_last_dw_be));
      end
      lower_addr[6:2] = pcie_np_req.m_tlp_addr[6:2];
      if(pcie_np_req.m_tlp_th == 1) begin //If TH bit set FBE and LBE are assumed to be 'hFF
        lower_addr[1:0] =  2'b00 ;
      end else begin
        lower_addr[1:0] = (pcie_np_req.m_tlp_first_dw_be[0] == 1'b1) ? 2'b00 :
                          (pcie_np_req.m_tlp_first_dw_be[1] == 1'b1) ? 2'b01 :
                          (pcie_np_req.m_tlp_first_dw_be[2] == 1'b1) ? 2'b10 :
                          (pcie_np_req.m_tlp_first_dw_be[3] == 1'b1) ? 2'b11 :
                                                                       2'b00 ;
        //if(pcie_np_req.m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) begin//{
        //  lower_addr=128 - pcie_np_req.m_tlp_length*4;
        //end//}
      end

      max_cpl_length = req_length > m_pcie_dev_cfg.m_max_payload_size_dw ? m_pcie_dev_cfg.m_max_payload_size_dw : req_length;

      //TODO VIPSR#46543408 : VIP team not accepting this as issue. VIP wrongly throws below error, when split completions are sent for TR req (From CIF router)
      //TL_TLP_CPLRCB_MRd32_3 [PCISIG].  Malformed TLP - When RCB==128, LowerAddress(0x38) + Payload(40) does not align at RCB boundary         in Completion for the request 32-bit MRd.
      //Workaround: Never split completion for a Translation request. Also this is not a limitation to DUT verification as this is for OB completion
      //Captured in JIRA- PCIE-12242
      if (!randomize(np_cpl_length) with {
        if (is_cpl_split_disabled == 1) {
          np_cpl_length == max_cpl_length;
        } else {
          if(pcie_np_req.m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)
          {
            np_cpl_length[0] == 0; //length should be multiple of 2DW, 8 bytes are required.
            np_cpl_length == req_length;
          }

          np_cpl_length > 0;
          np_cpl_length <= req_length;
          np_cpl_length <= max_cpl_length;
          ((np_cpl_length < req_length) || (np_cpl_length < max_cpl_length )) ->
          ({pcie_np_req.m_tlp_addr[63:2],2'b00} + np_cpl_length*4) % cpl_rcb == 0;
        }
      })
     `uvm_error(get_type_name(), "[generate_cpl_trans] np_cpl_length randomization fail")

      if(pcie_np_req.m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) begin//{
        lower_addr= (cpl_rcb ? 128: 64) - pcie_np_req.m_tlp_length*4;
      end//}
      
      if(np_cpl_length*4>=byte_count) begin // If Last split completion then only CA/UR
        pcie_cpl_trans.m_tlp_cpl_status            = temp_cpl_status; //Ankur::randomize
	    if((temp_cpl_status != CDN_HPA_PCIE_CPL_SC) && (!m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror))
        m_pcie_dev_top_cfg.stop_scen_ca_ur_cpl =1;// Stop after firsttime Temp TODO: Multiple cpls required
      end
      else begin
        pcie_cpl_trans.m_tlp_cpl_status            = CDN_HPA_PCIE_CPL_SC; //Ankur::randomize
      end
      
      if(pcie_cpl_trans.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC)
      begin
        pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
        pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_Cpl;
        pcie_cpl_trans.m_tlp_length                = 0;
        pcie_cpl_trans.m_tlp_cpl_byte_cnt          = (byte_count == 4096) ? 0 : byte_count[11:0];
        pcie_cpl_trans.m_tlp_cpl_lower_addr        = lower_addr;

        populate_fields_for_flit_mode_cpl(pcie_cpl_trans,pcie_np_req);
        if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans,pcie_np_req);
        populate_cxl_mld_cpl(pcie_cpl_trans,pcie_np_req);
        void'(pcie_cpl_trans.pack_bytes(pcie_cpl_trans.m_data));
        pcie_cpl_trans.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
       `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans.m_data), UVM_DEBUG)
        cpl_trans_q.push_back(pcie_cpl_trans);
        if(pcie_cpl_trans.m_expect_enderror && m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror && !is_hls_module_tb) begin
          `uvm_info(get_type_name(), $psprintf("Create 2 copy"), UVM_DEBUG)
          pcie_cpl_trans_copy.copy(pcie_cpl_trans);
          pcie_cpl_trans_copy.np_req_tlp.copy(pcie_cpl_trans.np_req_tlp);
          pcie_cpl_trans_copy.m_expect_enderror = 0;
          cpl_trans_q.push_back(pcie_cpl_trans_copy);
        end
      end
      else
      begin
        while (req_length > 0) begin //{
          cdn_hpa_pcie_tlp pcie_cpl_part;
          pcie_cpl_trans.m_tlp_length       = (np_cpl_length == 1024) ? 0 : np_cpl_length[9:0];
          pcie_cpl_trans.m_tlp_cpl_byte_cnt = (byte_count == 4096) ? 0 : byte_count[11:0];

          pcie_cpl_trans.m_tlp_cpl_lower_addr            = lower_addr;
          // data
          cpl_payload                                    = new[np_cpl_length*4];
          if (!randomize(cpl_payload)) begin
           `uvm_error(get_type_name(), "[generate_cpl_trans] cpl_payload randomization fail")
          end

          if(send_cpld_with_all_zeros) begin
            foreach(cpl_payload[i]) cpl_payload[i]=8'h0; //Making all payload as zeros
          end

          // Only required for Puresuite tests
          if(puresuite_test && m_pcie_dev_top_cfg.memory_written) begin
            for(int unsigned i=0; i<np_cpl_length*4; i++)
              cpl_payload[i] = m_pcie_dev_top_cfg.ib_mwr_data[{pcie_np_req.m_tlp_addr[63:2],2'b00}+i];
            m_pcie_dev_top_cfg.memory_written = 0;
          end

          pcie_cpl_trans.m_tlp_payload                   = cpl_payload;

          populate_fields_for_flit_mode_cpl(pcie_cpl_trans,pcie_np_req);
          if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans,pcie_np_req);
          populate_cxl_mld_cpl(pcie_cpl_trans,pcie_np_req);
          void'(pcie_cpl_trans.pack_bytes(pcie_cpl_trans.m_data));
          //`uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans.m_data), UVM_DEBUG)

          assert($cast(pcie_cpl_part, pcie_cpl_trans.clone()));
          assert($cast(pcie_cpl_part.np_req_tlp, pcie_cpl_trans.np_req_tlp));
          //`uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM 2: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
          //pcie_cpl_part.m_pcie_dev_cfg = m_dut_pcie_dev_cfg;
         `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
          //pcie_cpl_part.pack_ecrc=1;
          pcie_cpl_part.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
         `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
         `uvm_info(get_type_name(), $psprintf("tag =%0h, pcie_cpl_part=%s", {pcie_cpl_part.m_tlp_14_bit_tagscale, pcie_cpl_part.m_tlp_t9, pcie_cpl_part.m_tlp_t8, pcie_cpl_part.m_tlp_tag}, pcie_cpl_part.sprint()), UVM_DEBUG)

          cpl_trans_q.push_back(pcie_cpl_part);

          req_length = req_length - np_cpl_length;

          byte_count = (lower_addr[1:0] == 2'b00) ?
          byte_count - np_cpl_length*4 :
          byte_count - np_cpl_length*4 + (4 - $countones(pcie_np_req.m_tlp_first_dw_be));

          lower_addr[5:0] = 6'b000000;
          if (cpl_rcb == 128) begin
            lower_addr[6] = 1'b0;
          end else begin
            if ((np_cpl_length*4) % 64 == 0) begin
              lower_addr[6] = (((np_cpl_length*4)/64) % 2 == 0) ?
              lower_addr[6] :
              ~lower_addr[6];
            end
            else begin
              lower_addr[6] = (((np_cpl_length*4)/64) % 2 == 0) ?
              ~lower_addr[6] :
              lower_addr[6];
            end
          end

          if(pcie_np_req.m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) begin//{
            byte_count = req_length*4; //only two completions for AT requests
            lower_addr = 0;
            np_cpl_length = req_length;
          end//}
          else
          begin //{
            if (req_length != 0 && ((req_length*4) > cpl_rcb) ) begin
              if (!randomize(np_cpl_length) with {
                if (is_cpl_split_disabled == 1) {
                  np_cpl_length == max_cpl_length;
                }
                else {
                  np_cpl_length > 0;
                  np_cpl_length <= req_length;
                  np_cpl_length <= max_cpl_length;
                  ((np_cpl_length < req_length) || (np_cpl_length < max_cpl_length) ) ->
                  (np_cpl_length*4) % cpl_rcb == 0;
                }
              })
             `uvm_error(get_type_name(), "[generate_cpl_trans] np_cpl_length randomization fail")
            end
            else begin // Last completion is not required to be RCB aligned
              np_cpl_length = req_length;
            end
          end //}
        end //}
      end
    end //}
    else if ( pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd) begin //{
      shortint unsigned            byte_count;
      bit [11:0]                   lower_addr;
      shortint unsigned            req_length;
      bit                          is_cpl_complete;
      cdn_hpa_pcie_tlp             uio_cpl_trans_q[$];

      pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA;
      pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_UIORdCplD;
      pcie_cpl_trans.m_hdr_type                  = 5'b01000;
      pcie_cpl_trans.m_tlp_req_type              = CDN_HPA_PCIE_TRANS_COMPLETION;
      pcie_cpl_trans.m_tlp_attr0                 = 0; // For UIO Completions, ATTR[2:0] is reserved. 
      pcie_cpl_trans.m_tlp_attr1                 = 0; 
      pcie_cpl_trans.m_tlp_cpl_cdl               = misc_if.neg_cxl_mode ? pcie_cpl_trans.m_tlp_cpl_cdl : 0; //The CDL[1:0] field is assigned for use by [CXL]; this field must be treated as Reserved for use cases not covered
      pcie_cpl_trans.m_tlp_ln                    = pcie_np_req.m_tlp_ln;
      //pcie_cpl_trans.m_tlp_cpl_status            = CDN_HPA_PCIE_CPL_SC; //Ankur::randomize
      pcie_cpl_trans.m_expect_enderror           = 0;

      req_length = (pcie_np_req.m_tlp_length == 0) ? 1024 : pcie_np_req.m_tlp_length;
      byte_count = req_length*4;
      lower_addr[11:2] = pcie_np_req.m_tlp_addr[11:2];
      // lower address[1:0] is reserved for UIO
      lower_addr[1:0] =  2'b00;

      max_cpl_length = req_length > m_pcie_dev_cfg.m_max_payload_size_dw ? m_pcie_dev_cfg.m_max_payload_size_dw : req_length;
      //pcie_cpl_trans.m_tlp_cpl_cdl = ((m_pcie_dev_cfg.m_max_payload_size_bytes==128) ? 2'b00 : (m_pcie_dev_cfg.m_max_payload_size_bytes==256) ? 2'b01 :2'b10);


      //TODO VIPSR#46543408 : VIP team not accepting this as issue. VIP wrongly throws below error, when split completions are sent for TR req (From CIF router)
      //TL_TLP_CPLRCB_MRd32_3 [PCISIG].  Malformed TLP - When RCB==128, LowerAddress(0x38) + Payload(40) does not align at RCB boundary         in Completion for the request 32-bit MRd.
      //Workaround: Never split completion for a Translation request. Also this is not a limitation to DUT verification as this is for OB completion
      //Captured in JIRA- PCIE-12242
      if (!randomize(np_cpl_length) with {
        if (is_cpl_split_disabled == 1) {
          np_cpl_length == max_cpl_length;
        } else {
          np_cpl_length > 0;
          np_cpl_length <= req_length;
          np_cpl_length <= max_cpl_length;
          ((np_cpl_length < req_length) || (np_cpl_length < max_cpl_length )) ->
          ({pcie_np_req.m_tlp_addr[63:2],2'b00} + np_cpl_length*4) % cpl_rcb == 0;
        }
      })
      `uvm_error(get_type_name(), "[generate_cpl_trans] np_cpl_length randomization fail")
      
      if(np_cpl_length*4>=byte_count) begin // If Last split completion then only CA/UR
        pcie_cpl_trans.m_tlp_cpl_status            = temp_cpl_status; //Ankur::randomize
        if((temp_cpl_status != CDN_HPA_PCIE_CPL_SC) && (!m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror))
          m_pcie_dev_top_cfg.stop_scen_ca_ur_cpl =1;// Stop after firsttime Temp TODO: Multiple cpls required
      end
      else begin
        pcie_cpl_trans.m_tlp_cpl_status            = CDN_HPA_PCIE_CPL_SC; //Ankur::randomize
      end

      while (req_length > 0) begin //{
        cdn_hpa_pcie_tlp pcie_cpl_part;
        pcie_cpl_trans.m_tlp_length       = (np_cpl_length == 1024) ? 0 : np_cpl_length[9:0];
        pcie_cpl_trans.m_tlp_cpl_byte_cnt = 0; //(byte_count == 4096) ? 0 : byte_count[11:0];

        pcie_cpl_trans.m_tlp_cpl_lower_addr = lower_addr;
       
        if(pcie_cpl_trans.m_tlp_cpl_status == CDN_HPA_PCIE_CPL_SC) begin
          // data
          cpl_payload = new[np_cpl_length*4];
          if (!randomize(cpl_payload)) begin
           `uvm_error(get_type_name(), "[generate_cpl_trans] cpl_payload randomization fail")
          end

          if(send_cpld_with_all_zeros) begin
            foreach(cpl_payload[i]) cpl_payload[i]=8'h0; //Making all payload as zeros
          end

          // Only required for Puresuite tests
          if(puresuite_test && m_pcie_dev_top_cfg.memory_written) begin
            for(int unsigned i=0; i<np_cpl_length*4; i++)
              cpl_payload[i] = m_pcie_dev_top_cfg.ib_mwr_data[{pcie_np_req.m_tlp_addr[63:2],2'b00}+i];
            m_pcie_dev_top_cfg.memory_written = 0;
          end

          pcie_cpl_trans.m_tlp_payload = cpl_payload;
        end

        // TODO: add error injection
        if(pcie_cpl_trans.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC) begin
          pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
          pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_UIORdCpl;
          pcie_cpl_trans.m_hdr_type                  = 5'b01101;
          pcie_cpl_trans.m_tlp_cpl_lower_addr        = 0;
        end

        populate_fields_for_flit_mode_cpl(pcie_cpl_trans,pcie_np_req);
        if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans,pcie_np_req);
        populate_cxl_mld_cpl(pcie_cpl_trans,pcie_np_req);
        void'(pcie_cpl_trans.pack_bytes(pcie_cpl_trans.m_data));
        //`uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans.m_data), UVM_DEBUG)

        assert($cast(pcie_cpl_part, pcie_cpl_trans.clone()));
        assert($cast(pcie_cpl_part.np_req_tlp, pcie_cpl_trans.np_req_tlp));
        //`uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM 2: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
        //pcie_cpl_part.m_pcie_dev_cfg = m_dut_pcie_dev_cfg;
       `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
        //pcie_cpl_part.pack_ecrc=1;
        pcie_cpl_part.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
       `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
       `uvm_info(get_type_name(), $psprintf("tag =%0h, pcie_cpl_part=%s", {pcie_cpl_part.m_tlp_14_bit_tagscale, pcie_cpl_part.m_tlp_t9, pcie_cpl_part.m_tlp_t8, pcie_cpl_part.m_tlp_tag}, pcie_cpl_part.sprint()), UVM_DEBUG)

        

        
        uio_cpl_trans_q.push_back(pcie_cpl_part);
        if(pcie_np_req.uio_cpl_diff_status)begin
         assert(std::randomize(cpl_status) with {cpl_status dist {/*CDN_HPA_PCIE_CPL_SC*/0:=1,/*CDN_HPA_PCIE_CPL_UR*/1:=5,/*CDN_HPA_PCIE_CPL_ABORT*/2:=5};});
         case(cpl_status) 
         0: pcie_cpl_trans.m_tlp_cpl_status = CDN_HPA_PCIE_CPL_SC;
         1: pcie_cpl_trans.m_tlp_cpl_status = CDN_HPA_PCIE_CPL_UR;
         2: pcie_cpl_trans.m_tlp_cpl_status = CDN_HPA_PCIE_CPL_ABORT;
         endcase
        end
      

        req_length -= np_cpl_length;

        byte_count -= np_cpl_length*4;

        lower_addr += np_cpl_length*4;

        if (req_length != 0 && ((req_length*4) > cpl_rcb) ) begin
          if (!randomize(np_cpl_length) with {
            if (is_cpl_split_disabled == 1) {
              np_cpl_length == max_cpl_length;
            }
            else {
              np_cpl_length > 0;
              np_cpl_length <= req_length;
              np_cpl_length <= max_cpl_length;
              ((np_cpl_length < req_length) || (np_cpl_length < max_cpl_length) ) ->
              (np_cpl_length*4) % cpl_rcb == 0;
            }
          })
         `uvm_error(get_type_name(), "[generate_cpl_trans] np_cpl_length randomization fail")
        end
        else begin // Last completion is not required to be RCB aligned
          np_cpl_length = req_length;
        end
      end //}

      // UIO Read Completions for a single UIO Read Req are permitted to be returned in any address order
      if ( is_uio_out_of_order_cpl_disabled == 0) begin
        if (uio_cpl_trans_q.size() > 1) begin
          `uvm_info(get_type_name(), $sformatf("%p packets ordering shuffle for tag 0x%0h", uio_cpl_trans_q[0].m_tlp_type, {uio_cpl_trans_q[$].m_tlp_14_bit_tagscale, uio_cpl_trans_q[$].m_tlp_t9, uio_cpl_trans_q[$].m_tlp_t8, uio_cpl_trans_q[$].m_tlp_tag}), UVM_HIGH)
          uio_cpl_trans_q.shuffle();
        end
      end
      foreach (uio_cpl_trans_q[i]) begin
        cpl_trans_q.push_back(uio_cpl_trans_q[i]);
      end
    end //}
    // Atomic Cpl
    else if ( pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32 ||
              pcie_np_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64 ) begin

      bit is_cas;

      //if (!pcie_cpl_trans.randomize() with {np_req_tlp == pcie_np_req; m_hdr_fmt == CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA;
      //     m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplD; m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION;
      //    }) begin
      //  `uvm_error(get_type_name(), "Completion Randomization fail")
      //end

      pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA;
      pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_CplD;
      pcie_cpl_trans.m_tlp_req_type              = CDN_HPA_PCIE_TRANS_COMPLETION;
      pcie_cpl_trans.m_tlp_ln                    = pcie_np_req.m_tlp_ln;
      //pcie_cpl_trans.m_tlp_cpl_status            = CDN_HPA_PCIE_CPL_SC; //Ankur::Randomize

      if(pcie_cpl_trans.m_expect_enderror && m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror && !is_hls_module_tb) begin
        pcie_cpl_trans.m_tlp_cpl_status            = CDN_HPA_PCIE_CPL_SC; 
      end
      else begin
        pcie_cpl_trans.m_tlp_cpl_status            = temp_cpl_status;
      end

      is_cas = (pcie_np_req.m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64});


      pcie_cpl_trans.m_tlp_length       = is_cas ? $ceil(pcie_np_req.m_tlp_length / 2.0) : pcie_np_req.m_tlp_length              ;
      // data
      cpl_payload                       = new[pcie_cpl_trans.m_tlp_length*4];
      if (!randomize(cpl_payload)) begin
       `uvm_error(get_type_name(), "[generate_cpl_trans] cpl_payload randomization fail")
      end

      if(send_cpld_with_all_zeros) begin
        foreach(cpl_payload[i]) cpl_payload[i]=8'h0; //Making all payload as zeros
      end

      pcie_cpl_trans.m_tlp_payload      = cpl_payload;

      pcie_cpl_trans.m_tlp_cpl_lower_addr = 0;
      pcie_cpl_trans.m_tlp_cpl_byte_cnt   = is_cas ? $ceil(pcie_np_req.m_tlp_length / 2.0)*4 : pcie_np_req.m_tlp_length*4              ;

      if(pcie_cpl_trans.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC)
      begin
        pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
        pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_Cpl;
        pcie_cpl_trans.m_tlp_length                = 0;
      end

      populate_fields_for_flit_mode_cpl(pcie_cpl_trans,pcie_np_req);
      if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans,pcie_np_req);
      populate_cxl_mld_cpl(pcie_cpl_trans,pcie_np_req);
      void'(pcie_cpl_trans.pack_bytes(pcie_cpl_trans.m_data));
      pcie_cpl_trans.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
     `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans.m_data), UVM_DEBUG)
     `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: pcie_cpl_trans=%s", pcie_cpl_trans.sprint()), UVM_DEBUG)

      cpl_trans_q.push_back(pcie_cpl_trans);
      if(pcie_cpl_trans.m_expect_enderror && m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror && !is_hls_module_tb) begin
        `uvm_info(get_type_name(), $psprintf("Create 2 copy"), UVM_DEBUG)
        pcie_cpl_trans_copy.copy(pcie_cpl_trans);
        pcie_cpl_trans_copy.np_req_tlp.copy(pcie_cpl_trans.np_req_tlp);
        pcie_cpl_trans_copy.m_expect_enderror = 0;
        pcie_cpl_trans_copy.m_tlp_cpl_status  = temp_cpl_status;
        if(pcie_cpl_trans_copy.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC) begin
          pcie_cpl_trans_copy.m_hdr_fmt    = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
          pcie_cpl_trans_copy.m_tlp_type   = CDN_HPA_PCIE_TLP_TYPE_Cpl;
          pcie_cpl_trans_copy.m_tlp_length = 0;
          populate_fields_for_flit_mode_cpl(pcie_cpl_trans_copy,pcie_np_req);
          if(pcie_np_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans_copy,pcie_np_req);
          populate_cxl_mld_cpl(pcie_cpl_trans_copy,pcie_np_req);
          void'(pcie_cpl_trans_copy.pack_bytes(pcie_cpl_trans_copy.m_data));
          pcie_cpl_trans_copy.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
         `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans_copy.m_data), UVM_DEBUG)
         `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: pcie_cpl_trans_copy=%s", pcie_cpl_trans_copy.sprint()), UVM_DEBUG)
        end
        cpl_trans_q.push_back(pcie_cpl_trans_copy);
      end
    end

  endfunction : write_ib_np_req_port

  //-----------------------------------------------------------------------------
  // Function: write_ib_p_req_port
  // Implement the TLM Analysis port write_ib_p_req_port() method.
  //-----------------------------------------------------------------------------
  virtual function void write_ib_p_req_port(cdn_hpa_pcie_tlp pcie_p_req);
    // !!!! TODO Clone the P request and cast it as we may recive new p requests !!!!!
    cdn_hpa_pcie_tlp        pcie_cpl_trans;
    cdn_hpa_pcie_dev_config p_req_hit_dev_cfg;
    string                  tlp_trans_type;
    shortint unsigned       max_cpl_length;
    shortint unsigned       cpl_wcb;
    bit[1:0]                cpl_status;

    pcie_cpl_trans = new();

    if(!$cast(pcie_cpl_trans.np_req_tlp, pcie_p_req.clone()))
     `uvm_fatal("get_full_name", "Cast failed!!")

    if(m_dut_mode == EP) begin
     `uvm_info(get_full_name(),"m_dut_mode is EP for Completion",UVM_LOW)
      tlp_trans_type = "MEM";

      `ifdef HLS_MODULE_MODE
        if(pcie_p_req.is_ib_pkt==0)
          p_req_hit_dev_cfg = pick_dev_cfg_for_ob_addr(pcie_p_req.m_tlp_addr,tlp_trans_type);
        else
          p_req_hit_dev_cfg = pick_dev_cfg_for_ib_addr(pcie_p_req.m_tlp_addr,tlp_trans_type);
      `else
        p_req_hit_dev_cfg = pick_dev_cfg_for_ib_addr(pcie_p_req.m_tlp_addr,tlp_trans_type);
      `endif
    end
    else begin
     `uvm_info(get_full_name(),"m_dut_mode is RP for Completion",UVM_LOW)
      p_req_hit_dev_cfg = m_pcie_dev_top_cfg.pf_config[0]; //RP has 1 function
    end

    if(p_req_hit_dev_cfg == null) begin
     `ifdef HLS_MODULE_MODE
       `uvm_info(get_full_name(), $psprintf("Null handle returned for dev_cfg corresp to IB_address of P pkt %0s",pcie_p_req.sprint()),UVM_DEBUG)
        p_req_hit_dev_cfg = m_pcie_dev_top_cfg.pf_config[0];
        //return;
        //if(pcie_p_req.vip_userdata.m_error_injects[0] == CDN_HPA_PCIE_TLP_MEM_TX_BAR_UR_ERR)
        //  return;
        //else
        //`uvm_error(get_full_name(), $psprintf("Null handle returned for dev_cfg corresp to IB_address of P pkt %0s",pcie_p_req.sprint()))
     `else
       // CXL-2370
       if (m_pcie_dev_top_cfg.scenario.cxl_io_bar_check_disable_ep && m_pcie_dev_top_cfg.force_bar_chk_rp) begin
         `uvm_info(get_full_name(),"m_dut_mode is RP for Completion",UVM_LOW)
          p_req_hit_dev_cfg = m_pcie_dev_top_cfg.pf_config[0]; //RP has 1 function
          //p_req_hit_dev_cfg.m_pf_num,p_req_hit_dev_cfg.m_vf_num, pcie_p_req.m_tlp_addr),UVM_LOW)
       end
       `uvm_error(get_full_name(), $psprintf("Null handle returned for dev_cfg corresp to IB_address of P pkt %0s",pcie_p_req.sprint()))
     `endif
    end
    else begin
     `uvm_info("DEBUG_CPL_GEN", $psprintf("Dev cfg [PF=%0h VF=%0h]returned corresp to IB_address of P pkt(Address=%0h)",
      p_req_hit_dev_cfg.m_pf_num,p_req_hit_dev_cfg.m_vf_num, pcie_p_req.m_tlp_addr),UVM_LOW)
    end

    cpl_wcb = 64;
    pcie_cpl_trans.cfg2hls_tlp                     = pcie_p_req.hlsob2cfg_tlp;
    //pcie_cpl_trans.m_pcie_dev_cfg = m_dut_pcie_dev_cfg; // TODO
    pcie_cpl_trans.m_tlp_req_type                  = CDN_HPA_PCIE_TRANS_COMPLETION;
    pcie_cpl_trans.m_tlp_trans_type                = CDN_HPA_PCIE_TRANS_CPL_TYPE;
    pcie_cpl_trans.m_tlp_14_bit_tagscale           = pcie_p_req.m_tlp_14_bit_tagscale;
    pcie_cpl_trans.m_tlp_t9                        = pcie_p_req.m_tlp_t9;
    pcie_cpl_trans.m_tlp_tc                        = pcie_p_req.m_tlp_tc;
    pcie_cpl_trans.m_tlp_t8                        = pcie_p_req.m_tlp_t8;
    pcie_cpl_trans.m_tlp_attr1                     = 0;
    pcie_cpl_trans.m_tlp_th                        = 0;
   `ifdef HPA_ARCH2
      //pcie_cpl_trans.m_tlp_td                    = (p_req_hit_dev_cfg.m_ecrc_gen_en && (pcie_p_req.m_ide_prefix_present==0)) ? (m_pcie_dev_top_cfg.m_tl_to_pack_ecrc  ? 0 : 1) : 0;
      pcie_cpl_trans.m_tlp_td                      = (p_req_hit_dev_cfg.m_ecrc_gen_en && (pcie_p_req.m_ide_prefix_present==0)) ? m_pcie_dev_top_cfg.ecrc_init_done : 0;
      //pcie_cpl_trans.pack_ecrc = 1;
   `else
      pcie_cpl_trans.m_tlp_td                      = 0;
   `endif
    pcie_cpl_trans.m_tlp_attr0                     = pcie_p_req.m_tlp_attr0;
    pcie_cpl_trans.m_tlp_at_type                   = CDN_HPA_PCIE_AT_Untranslated;
    pcie_cpl_trans.hpa_generation                  = pcie_p_req.hpa_generation;

    if(pcie_p_req.m_tlp_local_prefix.size() > 0) begin
      pcie_cpl_trans.m_local_prefix_possible    = pcie_p_req.m_local_prefix_possible;
      pcie_cpl_trans.m_max_no_of_local_prefixes = pcie_p_req.m_max_no_of_local_prefixes;
      pcie_cpl_trans.m_tlp_local_prefix         = new[pcie_p_req.m_tlp_local_prefix.size()];
      pcie_cpl_trans.m_tlp_local_prefix_data    = new[pcie_p_req.m_tlp_local_prefix_data.size()];
      pcie_cpl_trans.m_hdr_fmt_local_prefix     = new[pcie_p_req.m_hdr_fmt_local_prefix.size()];
      pcie_cpl_trans.m_hdr_type_local_prefix    = new[pcie_p_req.m_hdr_type_local_prefix.size()];
      foreach(pcie_p_req.m_tlp_local_prefix[i]) begin
        pcie_cpl_trans.m_tlp_local_prefix[i] = pcie_p_req.m_tlp_local_prefix[i];
      end
      foreach(pcie_p_req.m_tlp_local_prefix_data[i]) begin
        pcie_cpl_trans.m_tlp_local_prefix_data[i] = pcie_p_req.m_tlp_local_prefix_data[i];
      end
      foreach(pcie_p_req.m_hdr_fmt_local_prefix[i]) begin
        pcie_cpl_trans.m_hdr_fmt_local_prefix[i] = pcie_p_req.m_hdr_fmt_local_prefix[i];
      end
      foreach(pcie_p_req.m_hdr_type_local_prefix[i]) begin
        pcie_cpl_trans.m_hdr_type_local_prefix[i] = pcie_p_req.m_hdr_type_local_prefix[i];
      end
    end

    // TODO : Need to chnage the device config class memebers to generic
    //if(m_dut_mode == EP) begin
      pcie_cpl_trans.m_tlp_completer_id.bus_num      = p_req_hit_dev_cfg.m_req_id.bus_num;
      pcie_cpl_trans.m_tlp_completer_id.device_num   = p_req_hit_dev_cfg.m_req_id.device_num;
      pcie_cpl_trans.m_tlp_completer_id.function_num = p_req_hit_dev_cfg.m_req_id.function_num;
    //end else begin
    // pcie_cpl_trans.m_tlp_completer_id.bus_num      = m_pcie_dev_cfg.m_req_id.bus_num;
    // pcie_cpl_trans.m_tlp_completer_id.device_num   = m_pcie_dev_cfg.m_req_id.device_num;
    // pcie_cpl_trans.m_tlp_completer_id.function_num = m_pcie_dev_cfg.m_req_id.function_num;
    //end
    pcie_cpl_trans.m_tlp_cpl_bcm                   = 0;
    pcie_cpl_trans.m_tlp_requester_id.bus_num      = pcie_p_req.m_tlp_requester_id.bus_num;
    pcie_cpl_trans.m_tlp_requester_id.device_num   = pcie_p_req.m_tlp_requester_id.device_num;
    pcie_cpl_trans.m_tlp_requester_id.function_num = pcie_p_req.m_tlp_requester_id.function_num;
    pcie_cpl_trans.m_tlp_tag                       = pcie_p_req.m_tlp_tag;

    //CXL PBR PTH; Swapping DPID, SPID
    pcie_cpl_trans.m_tlp_pth_hie                   = pcie_p_req.m_tlp_pth_hie;
    pcie_cpl_trans.m_tlp_pth_dsar                  = pcie_p_req.m_tlp_pth_dsar;
    pcie_cpl_trans.m_tlp_pth_pif                   = pcie_p_req.m_tlp_pth_pif;
    pcie_cpl_trans.m_tlp_pth_spid                  = pcie_p_req.m_tlp_pth_dpid;
    pcie_cpl_trans.m_tlp_pth_dpid                  = pcie_p_req.m_tlp_pth_spid;
    pcie_cpl_trans.m_tlp_pth_rsvd                  = pcie_p_req.m_tlp_pth_rsvd;
    pcie_cpl_trans.is_cxl_pbr_mode                 = pcie_p_req.is_cxl_pbr_mode;
    //Set to 0 for mismatch in IDE branch at HLS mod
    pcie_cpl_trans.m_tlp_pbr_tlp_header            = pcie_cpl_trans.is_cxl_pbr_mode ? {2'b11, pcie_cpl_trans.m_tlp_pth_rsvd, pcie_cpl_trans.m_tlp_pth_hie, pcie_cpl_trans.m_tlp_pth_dsar, pcie_cpl_trans.m_tlp_pth_pif, pcie_cpl_trans.m_tlp_pth_spid, pcie_cpl_trans.m_tlp_pth_dpid} : 32'b0;

    if(!randomize(expect_end_error) with {expect_end_error dist {0:=80, 1:=20};}) begin
       `uvm_error(get_type_name(), "expect_end_error randomization fail")
    end
    pcie_cpl_trans.m_expect_enderror               = $urandom_range(0,1);

    if(puresuite_test) begin
      temp_cpl_status = CDN_HPA_PCIE_CPL_SC;
      pcie_cpl_trans.m_tlp_ep = 0;
    end
    else begin

      // TODO: add error injection
      temp_cpl_status = CDN_HPA_PCIE_CPL_SC;

      //OB poison CPL error injection, to avoid multiple error, inject only with SC CPL
      if(m_pcie_strap_cfg.scenario && (m_pcie_strap_cfg.scenario.m_enable_ob_poison_err) && (temp_cpl_status == CDN_HPA_PCIE_CPL_SC) && (m_pcie_dev_top_cfg.is_dut_config)) begin
        pcie_cpl_trans.m_tlp_ep = $urandom();
      end
      else begin
        pcie_cpl_trans.m_tlp_ep = 0;
      end
    end

    // UIOMWr Cpl
    if ( pcie_p_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr ) begin
      shortint unsigned req_length;
      shortint unsigned byte_count;
      cdn_hpa_pcie_tlp  uio_cpl_trans_q[$];

      pcie_cpl_trans.m_hdr_fmt                   = CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA;
      pcie_cpl_trans.m_tlp_type                  = CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl;
      pcie_cpl_trans.m_hdr_type                  = 5'b01100;
      pcie_cpl_trans.m_tlp_req_type              = CDN_HPA_PCIE_TRANS_COMPLETION;
      //pcie_cpl_trans.m_tlp_cpl_byte_cnt          = 4;
      pcie_cpl_trans.m_tlp_cpl_lower_addr        = 0;
      pcie_cpl_trans.m_tlp_ln                    = 0;
      pcie_cpl_trans.m_tlp_attr0                 = 0; // For UIO Completions, ATTR[2:0] is reserved. 
      pcie_cpl_trans.m_tlp_cpl_cdl               = misc_if.neg_cxl_mode ? pcie_cpl_trans.m_tlp_cpl_cdl : 0; // For UIO Completions, CDL[1:0] is assigned by CXL else reserved. 
      //pcie_cpl_trans.m_tlp_cpl_cdl = ((m_pcie_dev_cfg.m_max_payload_size_bytes==128) ? 2'b00 : (m_pcie_dev_cfg.m_max_payload_size_bytes==256) ? 2'b01 :2'b10);
      if(pcie_cpl_trans.m_expect_enderror && m_pcie_dev_top_cfg.scenario.m_enable_ob_enderror && !is_hls_module_tb) begin
        pcie_cpl_trans.m_tlp_cpl_status            = CDN_HPA_PCIE_CPL_SC;
      end
      else begin
        pcie_cpl_trans.m_tlp_cpl_status            = temp_cpl_status;
      end

      req_length = (pcie_p_req.m_tlp_length == 0) ? 1024 : pcie_p_req.m_tlp_length;

      byte_count = req_length*4;

      max_cpl_length = req_length > m_pcie_dev_cfg.m_max_payload_size_dw ? m_pcie_dev_cfg.m_max_payload_size_dw : req_length;

      if (!randomize(p_cpl_length) with {
        if (is_cpl_split_disabled == 1) {
          p_cpl_length == max_cpl_length;
        }
        else {
          p_cpl_length > 0;
          p_cpl_length <= req_length;
          p_cpl_length <= max_cpl_length;
          ((p_cpl_length < req_length) || (p_cpl_length < max_cpl_length )) ->
          ({pcie_p_req.m_tlp_addr[63:2],2'b00} + p_cpl_length*4) % cpl_wcb == 0;
        }
      })
        `uvm_error(get_type_name(), "[generate_cpl_trans] p_cpl_length randomization fail")

      while (req_length > 0) begin //{
        cdn_hpa_pcie_tlp pcie_cpl_part;
        pcie_cpl_trans.m_tlp_length       = (p_cpl_length == 1024) ? 0 : p_cpl_length[9:0];
        //pcie_cpl_trans.m_tlp_cpl_byte_cnt = (byte_count == 4096) ? 0 : byte_count[11:0];

        populate_fields_for_flit_mode_cpl(pcie_cpl_trans,pcie_p_req);
        if(pcie_p_req.m_ide_prefix_present) populate_ide_fields(pcie_cpl_trans,pcie_p_req);
        populate_cxl_mld_cpl(pcie_cpl_trans,pcie_p_req);
        void'(pcie_cpl_trans.pack_bytes(pcie_cpl_trans.m_data));
        //`uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_trans.m_data), UVM_DEBUG)

        // TODO: add UIOWrCpl with errors
        if(pcie_cpl_trans.m_tlp_cpl_status != CDN_HPA_PCIE_CPL_SC) begin
        end

        assert($cast(pcie_cpl_part, pcie_cpl_trans.clone()));
        assert($cast(pcie_cpl_part.np_req_tlp, pcie_cpl_trans.np_req_tlp));
        //`uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM 2: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
        //pcie_cpl_part.m_pcie_dev_cfg = m_dut_pcie_dev_cfg;
       `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
        //pcie_cpl_part.pack_ecrc=1;
        pcie_cpl_part.update_ecrc_value(m_pcie_dev_top_cfg.m_tl_to_pack_ecrc);
       `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%p", pcie_cpl_part.m_data), UVM_DEBUG)
       `uvm_info(get_type_name(), $psprintf("tag =%0h, pcie_cpl_part=%s", {pcie_cpl_part.m_tlp_14_bit_tagscale, pcie_cpl_part.m_tlp_t9, pcie_cpl_part.m_tlp_t8, pcie_cpl_part.m_tlp_tag}, pcie_cpl_part.sprint()), UVM_DEBUG)

        uio_cpl_trans_q.push_back(pcie_cpl_part);
        if(pcie_p_req.uio_cpl_diff_status)begin
         assert(std::randomize(cpl_status) with {cpl_status dist {/*CDN_HPA_PCIE_CPL_SC*/0:=1,/*CDN_HPA_PCIE_CPL_UR*/1:=5,/*CDN_HPA_PCIE_CPL_ABORT*/2:=5};});
         case(cpl_status) 
         0: pcie_cpl_trans.m_tlp_cpl_status = CDN_HPA_PCIE_CPL_SC;
         1: pcie_cpl_trans.m_tlp_cpl_status = CDN_HPA_PCIE_CPL_UR;
         2: pcie_cpl_trans.m_tlp_cpl_status = CDN_HPA_PCIE_CPL_ABORT;
         endcase
        end

        req_length = req_length - p_cpl_length;

        byte_count = byte_count - p_cpl_length*4;

        if (req_length != 0 && ((req_length*4) > cpl_wcb) ) begin
          if (!randomize(p_cpl_length) with {
            if (is_cpl_split_disabled == 1) {
              p_cpl_length == max_cpl_length;
            }
            else {
              p_cpl_length > 0;
              p_cpl_length <= req_length;
              p_cpl_length <= max_cpl_length;
              ((p_cpl_length < req_length) || (p_cpl_length < max_cpl_length) ) ->
              (p_cpl_length*4) % cpl_wcb == 0;
            }
          })
         `uvm_error(get_type_name(), "[generate_cpl_trans] p_cpl_length randomization fail")
        end
        else begin // Last completion is not required to be WCB aligned
          p_cpl_length = req_length;
        end
      end //}

      // UIO Write Completions for a single UIO Write Req are permitted to be returned in any address order
      if (is_uio_out_of_order_cpl_disabled == 0) begin
        if (uio_cpl_trans_q.size() > 1) begin
          `uvm_info(get_type_name(), $sformatf("%p packets ordering shuffle for tag 0x%0h", uio_cpl_trans_q[0].m_tlp_type, {uio_cpl_trans_q[$].m_tlp_14_bit_tagscale, uio_cpl_trans_q[$].m_tlp_t9, uio_cpl_trans_q[$].m_tlp_t8, uio_cpl_trans_q[$].m_tlp_tag}), UVM_HIGH)
          uio_cpl_trans_q.shuffle();
        end
      end
      foreach (uio_cpl_trans_q[i]) begin
        cpl_trans_q.push_back(uio_cpl_trans_q[i]);
      end
    end // if ( pcie_p_req.m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr )
  endfunction : write_ib_p_req_port

  task monitor_flr_completion();
    cdn_pcie_flr_tr flr_tr;
    uvm_object      obj;
    cdn_hpa_pcie_tlp_requester_id_s req_id_s;
    cdn_hpa_pcie_tlp_requester_id_s req_id_s_vf;
    int unsigned item_count;
    int unsigned flred_item_count;
    //Clear the cpl_trans_q after receiveing flred completion to eliminate unexpected error.
    forever begin
      wait(m_flred_cpl_q.size()>0);
      hpa_timer.wait_for_time(10, "monitor_flr_completion", "ps");
      flred_item_count = m_flred_cpl_q.size();
     `uvm_info(get_type_name(), $psprintf("monitor_flr_completion: m_flred_cpl_q size=%0d", flred_item_count), UVM_DEBUG)
      for( int flred_idx=flred_item_count-1; flred_idx>=0; flred_idx--) begin
       `uvm_info(get_type_name(), $psprintf("monitor_flr_completion: m_flred_cpl_q[%0d]=%h, cpl_trans_q.size()=%0d", flred_idx, m_flred_cpl_q[flred_idx], cpl_trans_q.size()), UVM_DEBUG)
        //foreach(cpl_trans_q[item]) begin
        item_count = cpl_trans_q.size();
        for(int item=item_count-1; item >=0; item--) begin
         `uvm_info(get_type_name(), $psprintf("monitor_flr_completion: cpl_trans_q[%0d]=%h", item, {cpl_trans_q[item].m_tlp_14_bit_tagscale, cpl_trans_q[item].m_tlp_t9, cpl_trans_q[item].m_tlp_t8, cpl_trans_q[item].m_tlp_tag}), UVM_DEBUG)
          if ({cpl_trans_q[item].m_tlp_14_bit_tagscale,cpl_trans_q[item].m_tlp_t9, cpl_trans_q[item].m_tlp_t8, cpl_trans_q[item].m_tlp_tag} == m_flred_cpl_q[flred_idx]) begin
           `uvm_info(get_type_name(), $psprintf("monitor_flr_completion: deleting cpl_trans_q[%0d]=%h", item, {cpl_trans_q[item].m_tlp_14_bit_tagscale,cpl_trans_q[item].m_tlp_t9, cpl_trans_q[item].m_tlp_t8, cpl_trans_q[item].m_tlp_tag}), UVM_DEBUG)
            cpl_trans_q.delete(item);
          end
        end
        m_flred_cpl_q.delete(flred_idx);
      end
    end
  endtask : monitor_flr_completion

  //-----------------------------------------------------------------------------
  // Method: write_ib_compl_cbport
  // This function gets triggered by import port
  //-----------------------------------------------------------------------------
  virtual function void write_ib_compl_cbport(cdn_hpa_pcie_tlp packet);
    cdn_hpa_pcie_tlp cpl;
    if(!$cast(cpl, packet))
     `uvm_fatal(get_full_name(), "Cast Failed!!!")

    if(!cpl.is_cpl())
     `uvm_fatal(get_full_name(), "The recived TLP on the Completion Interface is not a Completion type TLP")

    //`uvm_info(get_type_name(), $psprintf("write_ib_compl_cbport: received cpl for tag=%h", {cpl.m_tlp_t9, cpl.m_tlp_t8, cpl.m_tlp_tag}), UVM_DEBUG)
    if(cpl.hls_ib_cpl_meta_s.cpl_err_code == CDN_HPA_PCIE_CPL_FLR) begin
     `uvm_info(get_type_name(), $psprintf("write_ib_compl_cbport: received FLRed cpl for tag=%h", {cpl.m_tlp_14_bit_tagscale,cpl.m_tlp_t9, cpl.m_tlp_t8, cpl.m_tlp_tag}), UVM_DEBUG)
      m_flred_cpl_q.push_back({cpl.m_tlp_14_bit_tagscale,cpl.m_tlp_t9, cpl.m_tlp_t8, cpl.m_tlp_tag});
    end
  endfunction : write_ib_compl_cbport

  //----------------------------------------------------------------------------
  // Function: reset
  // Resets the local varibles during reset
  //----------------------------------------------------------------------------
  function void reset();
    reset_in_progress=1;
    cpl_trans_q = {};
    EI_compl_lut_obj.reset();
  endfunction : reset

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

  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  // Should new the TLM Analysis ports and the coverage groups.
  //------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);

    ib_np_req_export = new("ib_np_req_export", this);
    ib_p_req_export = new("ib_p_req_export", this);
    ib_compl_cbport_export = new("ib_compl_cbport_export", this);
   `ifdef HAS_ARM
    lti_ib_compl_af = new("lti_ib_compl_af", this);
   `endif

    ob_np_req_ap              = new("ob_np_req_ap"             , this);
    ob_uio_p_req_ap           = new("ob_uio_p_req_ap"          , this);
    ob_10_bit_tag_np_req_ap   = new("ob_10_bit_tag_np_req_ap"  , this);
    ob_10_bit_tag_p_req_ap    = new("ob_10_bit_tag_p_req_ap"   , this);
    ob_14_bit_tag_np_req_ap   = new("ob_14_bit_tag_np_req_ap"  , this);
    ob_14_bit_tag_p_req_ap    = new("ob_14_bit_tag_p_req_ap"   , this);
    ib_exp_compl_to_TO_req_ap = new("ib_exp_compl_to_TO_req_ap", this);
    ib_exp_p_compl_to_TO_req_ap = new("ib_exp_p_compl_to_TO_req_ap", this);

  endfunction : new

  //------------------------------------------------------------------------
  // Function: build_phase
  // Extend build_phase to attach the virtual interface for the
  // misc_signals_if and build the host and device module level monitors.
  // Also sets the pointer to the p_regs (register model).
  // Include support for transaction recording if enabled.
  //------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(cdn_pcie_strap_top_config)::get(this, "", "i_cfg", m_pcie_strap_cfg)) begin
     `uvm_fatal(get_type_name(), "Cannot get strap config object from UVM config DB")
    end

    //`ifndef HLS_MODULE_MODE
    if(!uvm_config_db#(virtual cdn_pcie_hpa_misc_if)::get(this, "", "hpa_misc_if", misc_if))
     `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".misc_if"})
      //`endif

   `ifndef HLS_MODULE_MODE
      if(!uvm_config_db#(bit)::get(this, "*", "puresuite_test", puresuite_test))
       `uvm_fatal(get_full_name(), "PS get Failed")
   `endif

    cdn_pcie_hpa_tlp2cxs_seq_h = new[m_pcie_strap_cfg.k_num_cifs];
    tlp2cxs_compl_seq          = new[m_pcie_strap_cfg.k_num_cifs];
    m_ob_p_tlp_sqr             = new[m_pcie_strap_cfg.k_num_cifs];
    m_ob_cpl_tlp_sqr           = new[m_pcie_strap_cfg.k_num_cifs];
    m_ob_p_cxs_sqr             = new[m_pcie_strap_cfg.k_num_cifs];
    m_ob_compl_cxs_sqr         = new[m_pcie_strap_cfg.k_num_cifs];
    for (int i = 0; i < m_pcie_strap_cfg.k_num_cifs; i++) begin
      m_ob_p_cxs_sqr[i]        = new[m_num_hls_ports];
      m_ob_compl_cxs_sqr[i]    = new[m_num_hls_ports];
    end
    m_ob_p_intx_sqr            = new[m_pcie_strap_cfg.k_num_cifs*4];
    m_ob_p_msi_msix_sqr        = new[m_pcie_strap_cfg.k_num_cifs];
    rand_intx_seq              = new[m_pcie_strap_cfg.k_num_cifs*4];
    tlp2cxs_cfg2ib_compl_seq   = new();
    tlp2cxs_intrpt2ib_seq   = new();
    //m_cfg2ib_compl_cxs_sqr     = new($sformatf("m_cfg2ib_compl_cxs_sqr"));

    for (int i = 0; i<m_pcie_strap_cfg.k_num_cifs; i++) begin
      m_ob_p_tlp_sqr[i] = cdn_hpa_pcie_tlp_vseqr::type_id::create($sformatf("m_ob_p_tlp_sqr[%1d]", i), this);
      m_ob_cpl_tlp_sqr[i] = cdn_hpa_pcie_tlp_vseqr::type_id::create($sformatf("m_ob_cpl_tlp_sqr[%1d]", i), this);
    end
    m_cfg2ib_cpl_tlp_sqr = cdn_hpa_pcie_tlp_vseqr::type_id::create($sformatf("m_cfg2ib_cpl_tlp_sqr"), this);

    m_intrpt2ib_cpl_tlp_sqr = cdn_hpa_pcie_tlp_vseqr::type_id::create($sformatf("m_intrpt2ib_cpl_tlp_sqr"), this);

    for (int i = 0; i<m_pcie_strap_cfg.k_num_cifs; i++) begin
      m_ob_p_msi_msix_sqr[i] = cdn_pcie_msi_msix_sequencer::type_id::create($sformatf("m_ob_p_msi_msix_sqr[%1d]", i), this);
    end

    for (int i = 0; i<4; i++) begin
      m_ob_p_intx_sqr[i] = cdn_pcie_intx_sequencer::type_id::create($sformatf("m_ob_p_intx_sqr[%1d]", i), this);
    end
  endfunction: build_phase

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
  // Extend the end_of_elaboration_phase method to enable required
  // callbacks in CDNS VIPs on a per-instance basis
  //------------------------------------------------------------------------
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase

endclass : cdn_pcie_hpa_cif_tlp_router

`endif

//---------------------------
