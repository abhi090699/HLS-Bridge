`ifndef CDN_HPA_PCIE_LINK_CONFIG_SV
`define CDN_HPA_PCIE_LINK_CONFIG_SV
//-----------------------------------------------------------------------------
// Description:
// This file contains configuration of a link 
//-----------------------------------------------------------------------------
class cdn_hpa_pcie_link_config extends uvm_component;
  
  //------------------------------------------------------------------------
  // Physical member variables 
  //------------------------------------------------------------------------
  cdn_pcie_scenario scenario;

  cdn_hpa_pcie_dev_config usp_dev_config;
  cdn_hpa_pcie_dev_config dsp_dev_config;

  cdn_pcie_hpa_dev_top_config usp_dev_top_config;
  cdn_pcie_hpa_dev_top_config dsp_dev_top_config;

  cdn_pcie_strap_top_config   i_cfg;
  
  //------------------------------------------------------------------------
  // Field : hls_bridge_config
  // HLS Bridge Configuration
  //------------------------------------------------------------------------
  cdn_pcie_hls_bridge_config hls_bridge_config;
  
  //---------------------------------------------------------------------------
  // Field: ide_cfg
  // Used to encapsulate all the IDE related variables
  //---------------------------------------------------------------------------
  rand bit dut_mode_for_flit_err_inj;

  //------------------------------------------------------------------------
  // CONTROL KNOBS
  //------------------------------------------------------------------------

  bit is_dut_dut_tb; 
  int num_tlps_pipelined;

  //------------------------------------------------------------------------
  // CONSTRAINT BLOCKS.
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // STATUS MEMBER VARIABLES
  //------------------------------------------------------------------------

  // cpl_abort_transactionID used to expect error for particular ReqID and tag combination
  // [31:24]=Busnum [23:19]=DevNum, [18:16]=FunNum, [15:14]=TagScale, [13:0]CplTag 
  bit [31:0] cpl_abort_transactionID_q[$];

  //---------------------------------------------------------------------------
  // Field: enumeration_done
  // This Field is to indicate enumeration is done
  //---------------------------------------------------------------------------
  bit enumeration_done;

  //---------------------------------------------------------------------------
  // Field: bypass_enum_iteration_en
  // This Field is used to indicate in which L0 state enumeration and traffic 
  // will be bypassed
  //---------------------------------------------------------------------------
  int bypass_enum_iteration;
  bit bypass_enum_iteration_en;
  
  //---------------------------------------------------------------------------
  // Field: dsp_enumeration_done 
  // This Field is to indicate DSP enumeration  is done
  //---------------------------------------------------------------------------
  bit dsp_enumeration_done;

  //---------------------------------------------------------------------------
  // Field: usp_enumeration_done
  // This Field is to indicate USP enumeration is done
  //---------------------------------------------------------------------------
  bit usp_enumeration_done;

  //---------------------------------------------------------------------------
  // Field: dsp_req_id_programmed
  // This Field is to indicate DSP req ID programming is done
  //---------------------------------------------------------------------------
  bit dsp_req_id_programmed;

  //---------------------------------------------------------------------------
  // Field: usp_sriov_cap_programmed
  // This Field is to indicate USP SRIOV programming  is done
  //---------------------------------------------------------------------------
  bit usp_sriov_cap_programmed;

  //---------------------------------------------------------------------------
  // Field: dsp_vc_init
  // This Field is to indicate DSP VC init is done
  //---------------------------------------------------------------------------
  bit dsp_vc_init[8];

  //---------------------------------------------------------------------------
  // Field: usp_vc_init
  // This Field is to indicate usp_vc_init is done
  //---------------------------------------------------------------------------
  bit usp_vc_init[8];

  //---------------------------------------------------------------------------
  // Field: m_ob_tlps_formed 
  //---------------------------------------------------------------------------
  int m_ob_tlps_formed;

  //---------------------------------------------------------------------------
  // Field: m_ib_tlps_formed 
  //---------------------------------------------------------------------------
  int m_ib_tlps_formed;

  //---------------------------------------------------------------------------
  // Field: perf 
  // Used to encapsulate all the performance related variables
  //---------------------------------------------------------------------------
  cdn_pcie_perf_obj perf[string];

  //---------------------------------------------------------------------------
  // Field: vip_b2b_mode
  // This Field is to indicate if the setup is running vip b2b mode
  //---------------------------------------------------------------------------
  bit vip_b2b_mode; 

  //---------------------------------------------------------------------------
  // Field: dont_kill_sub_seq
  // This Field is to indicate to not kill sub seq
  //---------------------------------------------------------------------------
  bit dont_kill_sub_seq;

  //---------------------------------------------------------------------------
  // Field: m_dut_mode
  // This Field is to indicate if dut is EP or RP
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_config_pkg::cdn_dut_mode_e m_dut_mode; 

  //---------------------------------------------------------------------------
  // Field: m_cfg_tlp_tag
  // This Field is to store and seperte cpl for cfg tlps
  //---------------------------------------------------------------------------
  bit [13:0]        is_cfg_tlp_for_tag[int]; 

  //---------------------------------------------------------------------------
  // Field: ls_lw_sema
  // This Field is to syncronize sequence in DUT B2B mode
  //---------------------------------------------------------------------------
  semaphore lane_margining_sema;


  //---------------------------------------------------------------------------
  // Field: is_pl_link_down_done
  // This Field is to flagged when pl_link_down is set
  // This signal is used for message block reset 
  //---------------------------------------------------------------------------
  bit is_pl_link_down_done;


  //---------------------------------------------------------------------------
  // Field: ls_lw_sema
  // This Field is to syncronize sequence in DUT B2B mode
  //---------------------------------------------------------------------------
  semaphore ls_lw_sema;
  semaphore comp_sema;
  semaphore lpk_sema;
  semaphore ht_sema;
  semaphore iorecal_sema;
  semaphore l0p_sema;
  semaphore pl_cv_sema;
  semaphore phytestmode_sema;
  semaphore ln_dis_sema;
  semaphore cust_m2p_sema;
  int loopback_cnt; 
  int pl_cv_cnt; 
  int pl_cv_curr_test_step_cnt;
  int dl_cv_curr_test_step_cnt; 
  int comp_cnt;
  int phytestmode_cnt;
  int lane_dis_cnt;
  int g6_speed_timeout_cnt;
  int cust_m2p_cnt;
  bit [3:0]     cpcs_rx2tx_lpbk_speed;

  //---------------------------------------------------------------------------
  // Field: seq_type
  // This Field is to make decision to select nonD0 Functions or not
  //---------------------------------------------------------------------------
  //tlp_seq_type seq_type;
   bit all_traffic;
   bit tlp_specific_traffic;


  //---------------------------------------------------------------------------
  // Field: dsp_dev_vseq_done
  // This Field is to indicate USP sequence is completed
  //---------------------------------------------------------------------------
  bit dsp_dev_vseq_done; 

  //---------------------------------------------------------------------------
  // Field: dsp_dev_vseq_done
  // This Field is to indicate DSP sequence is completed
  //---------------------------------------------------------------------------
  bit usp_dev_vseq_done; 

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  `uvm_component_utils_begin(cdn_hpa_pcie_link_config)
  `uvm_object_utils_end

  //------------------------------------------------------------------------
  // CHECKER FIELDS FOR COVERAGE OF CHECKERS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // BACK POINTERS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // METHODS
  //------------------------------------------------------------------------
  //pick random configuration, or selected
  extern function cdn_hpa_pcie_dev_config pick_srcCfg(ref int sel, input pick_fns_in_d0=0);
  extern function cdn_hpa_pcie_dev_config pick_dstPfCfg(ref int sel,  input string a_type="PF", input pick_fns_in_d0=0, input sel_other_end_device=0, input pick_disabled_vf=0);
  extern function cdn_hpa_pcie_dev_config pick_dstVfCfg(ref int pf_sel, ref int vf_sel, input pick_fns_in_d0=0, input sel_other_end_device=0, input pick_disabled_vf=0);
  extern function cdn_hpa_pcie_dev_config pick_dstRndCfg(ref int pf_sel,  ref int vf_sel, input pick_fns_in_d0=0, input sel_other_end_device=0, input pick_disabled_vf=0);
  extern function void pick_rnd_link_dev_cfg(input string direction = "IB", ref cdn_hpa_pcie_dev_config dev_cfg,ref cdn_hpa_pcie_link_config link_cfg, input pick_fns_in_d0=0, input pick_disabled_vf=0);
  extern function automatic void pick_link_dev_cfg(input string direction = "IB", ref cdn_hpa_pcie_dev_config dev_cfg,ref cdn_hpa_pcie_link_config link_cfg, input int pf, int vf, int dest_pf, int dest_vf, bit is_vf);
  extern function automatic void report_perf_metrics(cdn_pcie_perf_obj perf);
  extern function integer get_exp_perf(CDN_PCIE_PERF_SETTING perf_type);
  extern function bit is_perf_type(CDN_PCIE_PERF_SETTING perf_type);
  extern function bit[1:0] get_core_clk_ns();
  extern function bit[15:0] get_completer_id (int pf_num, int vf_num);


  //------------------------------------------------------------------------
  // DEFINE TASKS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Task: main_phase
  // The main_phase task for this class will be started automatically during
  // the run phase.
  //------------------------------------------------------------------------
  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);
  endtask : main_phase

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

    // Create when perfromance mode is selected
    perf["ob_p"]   = new("ob_p");
    perf["ob_np"]  = new("ob_np");
    perf["ob_cpl"] = new("ob_cpl");
    perf["ib_p"]   = new("ib_p");
    perf["ib_np"]  = new("ib_np");
    perf["ib_cpl"] = new("ib_cpl");

    //used in pl link down cases to reduce test time and error caused due to traffic post link down
    //BYPASS_ENUM value passed in cmd line indicates the linkup iteration at which we want to skip enumeration
    if($value$plusargs("BYPASS_ENUM=%0d",bypass_enum_iteration))begin 
      if(bypass_enum_iteration==1)
        bypass_enum_iteration_en=1;
      `uvm_info(get_full_name(),$psprintf("bypass_enum_iteration=%0d bypass_enum_iteration_en=%0d",bypass_enum_iteration,bypass_enum_iteration_en),UVM_LOW) 
    end

  endfunction : new

  function void pre_randomize();
    if(i_cfg == null) i_cfg = cdn_pcie_strap_top_config::type_id::create("i_cfg");
  endfunction

  function void post_randomize();
  endfunction

  //------------------------------------------------------------------------
  // Function: build_phase
  //------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ls_lw_sema = new(1);
    comp_sema = new(1); 
    lpk_sema  = new(1);
    ht_sema = new(1); 
    iorecal_sema = new(1);  
   l0p_sema = new(1);
   pl_cv_sema = new(1);
    lane_margining_sema = new(1);
    phytestmode_sema  = new(1); 
    ln_dis_sema  = new(1); 
    cust_m2p_sema  = new(1); 
    if (!uvm_config_db#(cdn_pcie_scenario)::get(this, "", "scenario", scenario)) begin
      `uvm_info(get_type_name(), $sformatf("scenario is not present. full random scenario is chosen"),UVM_LOW)
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
  //------------------------------------------------------------------------
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase

  //------------------------------------------------------------------------
  // Function: reset_cfg 
  // This function resets semaphore on reset
  //------------------------------------------------------------------------
  function void reset_cfg();
      ls_lw_sema = null;
      //comp_sema  = null;
      //lpk_sema   = null; 
      ht_sema    = null; 
      iorecal_sema = null; 

      ls_lw_sema = new(1);
      //comp_sema = new(1); 
      //lpk_sema  = new(1);
      ht_sema = new(1); 
      iorecal_sema = new(1);  
      lane_margining_sema = null;
      lane_margining_sema = new(1);
      //is_cfg_tlp_for_tag.delete();
      usp_dev_vseq_done=0;
      dsp_dev_vseq_done=0;
  endfunction


  function bit[3:0] max_link_speed();
       max_link_speed = ((usp_dev_top_config.m_max_link_speed < dsp_dev_top_config.m_max_link_speed) ? usp_dev_top_config.m_max_link_speed : dsp_dev_top_config.m_max_link_speed);
       `uvm_info(get_full_name(),$psprintf("Max Link Speed : Gen%0d",max_link_speed),UVM_DEBUG) 
  endfunction 

endclass


function cdn_hpa_pcie_dev_config cdn_hpa_pcie_link_config::pick_srcCfg (ref int sel, input pick_fns_in_d0=0);
  int sel_array[$];
  int sel_idx;
  cdn_pcie_hpa_dev_top_config vip_top_config;

  if(m_dut_mode == CDN_HPA_PCIE_RP)
    vip_top_config = usp_dev_top_config;  
  else
    vip_top_config = dsp_dev_top_config;  

  if(!is_dut_dut_tb) begin
    if(sel=="") begin
      if(vip_top_config.pf_config.num()==0) return (null);
      if(vip_top_config.pf_config.first(sel)) begin
        do begin
         if(!pick_fns_in_d0 || (vip_top_config.pf_config[sel].power_state ==0) && (vip_top_config.pf_config[sel].m_flr_in_progress ==0) ) begin
          sel_array.push_back(sel);
          `uvm_info(get_type_name(), $psprintf("pick_srcCfg(): save to list: %0d", sel),UVM_FULL)
         end 
        end while (vip_top_config.pf_config.next(sel));
      end
      assert(std::randomize(sel_idx) with {(sel_idx >=0) && (sel_idx<sel_array.size());});
      sel = sel_array[sel_idx];
      return (vip_top_config.pf_config[sel_array[sel_idx]]);
    end

  end
  else begin
    if(sel=="") begin
      if(vip_top_config.pf_config.num()==0) return (null);
      if(vip_top_config.pf_config.first(sel)) begin
          if(!pick_fns_in_d0 || (vip_top_config.pf_config[sel].power_state ==0) && (vip_top_config.pf_config[sel].m_flr_in_progress ==0)) begin
          sel_array.push_back(sel);
          `uvm_info(get_type_name(), $psprintf("pick_srcCfg(): save to list: %0d", sel),UVM_FULL)
         end
         return (vip_top_config.pf_config[sel_array[sel]]);
      end
    end
  end

  if(vip_top_config.pf_config.exists(sel)) begin
    return vip_top_config.pf_config[sel];
  end

  return null;
endfunction: pick_srcCfg

/**
 Pick a destination config randomly,
 param-a_type: PF -> from PF configs
             : WITH_VF -> PF configs having VFs enabled and numVF>=1
 */
function cdn_hpa_pcie_dev_config cdn_hpa_pcie_link_config::pick_dstPfCfg (ref int sel, input string a_type="PF", input pick_fns_in_d0=0, input sel_other_end_device=0, input pick_disabled_vf=0);
  int sel_array[$];
  int sel_idx;
  cdn_pcie_hpa_dev_top_config dev_top_config;

  if(m_dut_mode == CDN_HPA_PCIE_RP)
    dev_top_config = dsp_dev_top_config;  
  else
    dev_top_config = usp_dev_top_config;  

  if(sel_other_end_device) begin
   if(m_dut_mode == CDN_HPA_PCIE_RP)
    dev_top_config = usp_dev_top_config;  
   else
    dev_top_config = dsp_dev_top_config;  
  end

  
  if(!is_dut_dut_tb) begin
    if(sel=="") begin
      if(dev_top_config.pf_config.num()==0) begin
        `uvm_error(get_type_name(), $psprintf("pick_dstPfCfg(): dev_top_config.pf_config is empty and trying to select one from it"));
        return (null);
      end
      if(dev_top_config.pf_config.first(sel)) begin
        do begin
          bit skip = 1;
          if(a_type == "WITH_VF") begin
            //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): dev_top_config.pf_config[%0d].m_vf_en %0d", sel, dev_top_config.pf_config[sel].m_vf_en),UVM_FULL)
            //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): pick_disabled_vf %0d", pick_disabled_vf),UVM_FULL)
            //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): dev_top_config.pf_config[%0d].m_NumVFs %0d", sel, dev_top_config.pf_config[sel].m_NumVFs),UVM_FULL)
            if((dev_top_config.pf_config[sel].m_vf_en || pick_disabled_vf) && dev_top_config.pf_config[sel].m_NumVFs > 0) begin
              //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): pick_fns_in_d0 %0d", pick_fns_in_d0),UVM_FULL)
              if(!pick_fns_in_d0)
                skip = 0;
              else begin
                for(int vf_n=0; vf_n<dev_top_config.pf_config[sel].m_NumVFs; vf_n++) begin
                  //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): dev_top_config.vf_config[%0d][%0d].power_state %0d", sel,vf_n, dev_top_config.vf_config[sel][vf_n].power_state),UVM_FULL)
                  //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): dev_top_config.vf_config[%0d][%0d].m_flr_in_progress %0d", sel,vf_n, dev_top_config.vf_config[sel][vf_n].m_flr_in_progress),UVM_FULL)
                  if((dev_top_config.vf_config[sel][vf_n].power_state ==0) && (dev_top_config.vf_config[sel][vf_n].m_flr_in_progress ==0) && (dev_top_config.m_is_pf_disabled_by_lm[dev_top_config.pf_config[sel].m_pf_num]==0 || dev_top_config.pf_disable_done==0))
                    skip = 0;
                end
              end
            end
          end
          else if( a_type == "PF") begin
            //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): pick_fns_in_d0 %0d", pick_fns_in_d0),UVM_FULL)
            //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): dev_top_config.pf_config[%0d].power_state %0d", sel, dev_top_config.pf_config[sel].power_state),UVM_FULL)
            //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): dev_top_config.pf_config[%0d].m_flr_in_progress %0d", sel, dev_top_config.pf_config[sel].m_flr_in_progress),UVM_FULL)
            //`uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): dev_top_config.pf_config[%0d].m_pf_num %0d", sel, dev_top_config.pf_config[sel].m_pf_num),UVM_FULL)
            if((!pick_fns_in_d0 || (dev_top_config.pf_config[sel].power_state ==0 && dev_top_config.pf_config[sel].m_flr_in_progress ==0)) && (dev_top_config.m_is_pf_disabled_by_lm[dev_top_config.pf_config[sel].m_pf_num]==0 || dev_top_config.pf_disable_done==0))
              skip = 0;
          end
          if(!skip) begin
            `uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): save to list: %0d", sel),UVM_FULL)
            sel_array.push_back(sel);
          end
        end while (dev_top_config.pf_config.next(sel));
      end // if (dev_top_config.pf_config.first(sel))

      if(sel_array.size() != 0)begin
        assert(std::randomize(sel_idx) with {(sel_idx >=0) && (sel_idx<sel_array.size());});
        sel = sel_array[sel_idx];
        `uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): selected config from the list: %0d", sel),UVM_FULL)
        return (dev_top_config.pf_config[sel_array[sel_idx]]);
      end // if (sel_array.size() != 0)
      else begin
        `uvm_error(get_type_name(), $psprintf("pick_dstPfCfg(): No active dstCfg to select, returning null"));
        return (null);
      end
    end // if (sel=="")
  end
  else begin
    if(sel=="") begin
      if(dev_top_config.pf_config.first(sel)) begin
        bit skip = 1;
        if(a_type == "WITH_VF") begin
          if((dev_top_config.pf_config[sel].m_vf_en || pick_disabled_vf) && dev_top_config.pf_config[sel].m_NumVFs >0) begin
            if(!pick_fns_in_d0) 
              skip = 0;
            else begin
              for(int vf_n=0; vf_n<dev_top_config.pf_config[sel].m_NumVFs; vf_n++) begin
                if((dev_top_config.vf_config[sel][vf_n].power_state ==0) && (dev_top_config.vf_config[sel][vf_n].m_flr_in_progress ==0))
                  skip = 0;
              end
            end
          end
        end
        else if( a_type == "PF") begin
          `uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): save to list:%0d pf_num=%0d, pick_fns_in_d0=%0d , power_state=%0d pf_disable_done=%0d", sel,dev_top_config.pf_config[sel].m_pf_num,pick_fns_in_d0,dev_top_config.pf_config[sel].power_state,dev_top_config.pf_disable_done),UVM_FULL)
          if(!pick_fns_in_d0 || (dev_top_config.pf_config[sel].power_state ==0) && (dev_top_config.pf_config[sel].m_flr_in_progress ==0) && (dev_top_config.m_is_pf_disabled_by_lm[dev_top_config.pf_config[sel].m_pf_num]==0 || dev_top_config.pf_disable_done==0))
            skip = 0;
        end
        if(!skip) begin
          `uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): save to list: %0d", sel),UVM_FULL)
          sel_array.push_back(sel);
        end
      end // if (dev_top_config.pf_config.first(sel))
      `uvm_info(get_type_name(), $psprintf("pick_dstPfCfg(): selected config from the list: %0d", sel),UVM_FULL)
      return (dev_top_config.pf_config[sel_array[sel]]);
    end // if (sel_array.size() != 0)
    else begin
      `uvm_error(get_type_name(), $psprintf("pick_dstPfCfg(): No active dstCfg to select, returning null"));
      return (null);
    end
  end // if (sel=="")
   
  if(dev_top_config.pf_config.exists(sel)) begin
    return dev_top_config.pf_config[sel];
  end
   
  return null;
endfunction: pick_dstPfCfg

function cdn_hpa_pcie_dev_config cdn_hpa_pcie_link_config::pick_dstVfCfg (ref int pf_sel, ref int vf_sel, input pick_fns_in_d0=0, input sel_other_end_device=0, input pick_disabled_vf=0);
   int sel_array[$];
   int sel_idx;
   bit skip;
   cdn_hpa_pcie_dev_config pf_cfg;
   cdn_pcie_hpa_dev_top_config dev_top_config;

  if(m_dut_mode == CDN_HPA_PCIE_RP)
    dev_top_config = dsp_dev_top_config;  
  else
    dev_top_config = usp_dev_top_config;  

  if(sel_other_end_device) begin
   if(m_dut_mode == CDN_HPA_PCIE_RP)
    dev_top_config = usp_dev_top_config;  
   else
    dev_top_config = dsp_dev_top_config;  
  end

   if(pf_sel=="") begin
      if(dev_top_config.pf_config.num()==0) begin
        `uvm_error(get_type_name(), $psprintf("pick_dstVfCfg(): dev_top_config.pf_config is empty and trying to select one from it"));
        return (null);
      end else begin
       //NOTE: if pick_fns_in_d0==1, then we are selcting PF in D0. Which is inline with PCIe spec. As PF can't be in non-D0 untill all VFs are put in non-D0
       pf_cfg = pick_dstPfCfg(pf_sel,.a_type("WITH_VF"), .pick_fns_in_d0(pick_fns_in_d0),.sel_other_end_device(sel_other_end_device), .pick_disabled_vf(pick_disabled_vf));
      end

      if(pf_cfg != null)begin
        if(pick_fns_in_d0 == 0) begin //{
         if(!is_dut_dut_tb) assert(std::randomize(sel_idx) with {(sel_idx >=0) && (sel_idx<pf_cfg.m_NumVFs);});
        end else begin //} {
         for(int vf_n=0; vf_n < pf_cfg.m_NumVFs; vf_n++) begin //{
           skip=1;
           if((dev_top_config.vf_config[pf_sel][vf_n].power_state ==0) && (dev_top_config.vf_config[pf_sel][vf_n].m_flr_in_progress ==0) && (dev_top_config.m_is_pf_disabled_by_lm[dev_top_config.pf_config[pf_sel].m_pf_num]==0 || dev_top_config.pf_disable_done==0) )begin //{
            skip =0;
           end //}
	         if(!skip) begin
                   `uvm_info(get_type_name(), $psprintf("pick_dstVfCfg(): save to list: %0d", vf_n),UVM_FULL)
                   sel_array.push_back(vf_n);
	         end
         end //}

         if(!is_dut_dut_tb) begin
           if(sel_array.size() != 0)begin
              assert(std::randomize(sel_idx) with {(sel_idx >=0) && (sel_idx<sel_array.size());});
           end // if (sel_array.size() != 0)
           else begin
             `uvm_error(get_type_name(), $psprintf("pick_dstVfCfg(): No active dstCfg to select, returning null"));
             return (null);
           end
         end
        end //}
	       //sel_idx = 0;//SRIOV: Temp to always return VF0
	       vf_sel = sel_array[sel_idx];
          `uvm_info(get_type_name(), $psprintf("pick_dstVfCfg(): selected config from the list:PF_%0d VF_%0d",pf_sel, vf_sel),UVM_FULL)
         return (dev_top_config.vf_config[pf_sel][vf_sel]);
      end else begin
        `uvm_error(get_type_name(), $psprintf("pick_dstVfCfg(): No active pf config to select, returning null"));
        return (null);
      end
   end // if (sel=="")
   
   if(dev_top_config.pf_config.exists(pf_sel)) begin
     if(dev_top_config.vf_config[pf_sel].exists(vf_sel))
      return dev_top_config.vf_config[pf_sel][vf_sel];
   end
   
   return null;
endfunction: pick_dstVfCfg

function cdn_hpa_pcie_dev_config cdn_hpa_pcie_link_config::pick_dstRndCfg (ref int pf_sel, ref int vf_sel, input pick_fns_in_d0=0, input sel_other_end_device=0, input pick_disabled_vf=0);
  cdn_hpa_pcie_dev_config dev_cfg;
  bit pf_vf_sel,vf_sel_possible;
  cdn_pcie_hpa_dev_top_config dev_top_config;

  if(m_dut_mode == CDN_HPA_PCIE_RP)
    dev_top_config = dsp_dev_top_config;  
  else
    dev_top_config = usp_dev_top_config;  

  if(sel_other_end_device) begin
   if(m_dut_mode == CDN_HPA_PCIE_RP)
    dev_top_config = usp_dev_top_config;  
   else
    dev_top_config = dsp_dev_top_config;  
  end
  //`uvm_info(get_type_name(), $psprintf("pick_dstRndCfg:: sel_other_end_device=%0b",sel_other_end_device),UVM_FULL)

  assert(std::randomize(pf_vf_sel));

  //If no SRIOV support or no VFs mapped to any PF, we should not select VF cfgs
  if(pick_fns_in_d0 == 1) begin //{
    //If all VFs are in non-D0 and pick_fns_in_d0=1, then we should not select VF cfgs
    foreach(dev_top_config.pf_config[i]) begin 
      if(dev_top_config.pf_config[i].m_vf_en || pick_disabled_vf) begin
        for(int vf_n=0; vf_n<dev_top_config.pf_config[i].m_NumVFs; vf_n++) begin
          if((dev_top_config.vf_config[i][vf_n].power_state ==0) && (dev_top_config.vf_config[i][vf_n].m_flr_in_progress ==0) && (dev_top_config.m_is_pf_disabled_by_lm[dev_top_config.pf_config[i].m_pf_num]==0 || dev_top_config.pf_disable_done==0)) begin
            vf_sel_possible = 1;
            break;
          end
        end
      end
    end
  end else begin //} {
    //If no VFs existed in all available PFs, we should not select VF cfgs
    foreach(dev_top_config.pf_config[i]) begin  
      //`uvm_info(get_type_name(), $psprintf("pick_dstRndCfg:: dev_top_config.pf_config[%0d].m_NumVFs=%0d",i,dev_top_config.pf_config[i].m_NumVFs),UVM_FULL)
      if(dev_top_config.pf_config[i].m_NumVFs > 0 && (dev_top_config.pf_config[i].m_vf_en || pick_disabled_vf)) begin
        vf_sel_possible = 1;
        break;
      end
    end
  end
  //`uvm_info(get_type_name(), $psprintf("pick_dstRndCfg:: vf_sel_possible=%0d",vf_sel_possible),UVM_FULL)


  if(!vf_sel_possible) 
    pf_vf_sel = 0; //No VFs available, so go with PF selection

  //pf_vf_sel = 1; //SRIOV: To force picking PF(0)/VF(1)
  //`uvm_info(get_type_name(), $psprintf("pick_dstRndCfg:: pf_vf_sel=%0d",pf_vf_sel),UVM_FULL)
  //`uvm_info(get_type_name(), $psprintf("pick_dstRndCfg:: pick_disabled_vf=%0d",pick_disabled_vf),UVM_FULL)

  if(pf_vf_sel == 1) begin //VF sel
    dev_cfg = pick_dstVfCfg(pf_sel,vf_sel, .pick_fns_in_d0(pick_fns_in_d0),.sel_other_end_device(sel_other_end_device), .pick_disabled_vf(pick_disabled_vf));
    if(dev_cfg == null) begin
      `uvm_info(get_type_name(),$psprintf("pick_dstRndCfg(): No VFs available. SO try picking Pf config"),UVM_FULL)
      dev_cfg = pick_dstPfCfg(pf_sel, .pick_fns_in_d0(pick_fns_in_d0),.sel_other_end_device(sel_other_end_device), .pick_disabled_vf(pick_disabled_vf));
      vf_sel = -1;
    end
    `uvm_info(get_type_name(), $psprintf("pick_dstRndCfg(): selected %0s config from the list:PF_%0d VF_%0d",((pf_vf_sel==1)? "VF" : "PF"),pf_sel, vf_sel),UVM_FULL)
    return dev_cfg;
  end else begin //PF Sel
    dev_cfg = pick_dstPfCfg(pf_sel, .pick_fns_in_d0(pick_fns_in_d0),.sel_other_end_device(sel_other_end_device),.pick_disabled_vf(pick_disabled_vf));
    vf_sel = -1;
    `uvm_info(get_type_name(), $psprintf("pick_dstRndCfg(): selected %0s config from the list:PF_%0d",((pf_vf_sel==1)? "VF" : "PF"),pf_sel),UVM_FULL)
    return dev_cfg;
  end
  return null;
endfunction: pick_dstRndCfg

function void cdn_hpa_pcie_link_config::pick_rnd_link_dev_cfg (input string direction = "IB", //IB : Inbound ; OB: Outbound
                                                               ref cdn_hpa_pcie_dev_config dev_cfg,
                                                               ref cdn_hpa_pcie_link_config link_cfg, input pick_fns_in_d0 = 0, input pick_disabled_vf = 0);
   int pf_sel,vf_sel;
   int pf_sel1,vf_sel1;
   //int all_traffic;

   //void'($value$plusargs("ALL_TRAFFIC=%0d", all_traffic));
   $cast(link_cfg,this);
   if($value$plusargs("ALL_TRAFFIC=%0d", all_traffic))begin
   //If passed from The runcommand: It will pick that value
   //If not passed then else it will take from the default passed from dev_vseq
   end
   if(!$value$plusargs("TLP_SPECIFIC_TRAFFIC=%0d", tlp_specific_traffic)) tlp_specific_traffic=0;
  
   if (all_traffic == 1 || tlp_specific_traffic) begin
       //dev_cfg = cdn_hpa_pcie_dev_config::type_id::create("dev_cfg",this);
       if(direction == "IB") begin
         //DUT Receievs Packet. So pick the BFM's corresponding dev_cfg (Srccfg)
         dev_cfg = pick_srcCfg(pf_sel, .pick_fns_in_d0(pick_fns_in_d0)); 
       end 
       else if (direction == "OB") begin
         //DUT Receievs Packet. So pick the DUT's corresponding dev_cfg (dstcfg)
         if(!is_dut_dut_tb) begin
           if(m_dut_mode == EP) begin
             dev_cfg = pick_dstRndCfg(pf_sel,vf_sel, .pick_fns_in_d0(pick_fns_in_d0),.pick_disabled_vf(pick_disabled_vf)); 
           end
           else begin
             dev_cfg = pick_dstPfCfg(pf_sel,"PF", .pick_fns_in_d0(pick_fns_in_d0),.pick_disabled_vf(pick_disabled_vf)); 
           end
         end
         else begin
           dev_cfg = pick_dstPfCfg(pf_sel,"PF", .pick_fns_in_d0(pick_fns_in_d0),.pick_disabled_vf(pick_disabled_vf)); 
         end
       end else begin
         `uvm_fatal(get_full_name(),"Direction is not properly feeded");
       end

       $cast(link_cfg,this);
       if(m_dut_mode == EP) begin
          if(direction == "IB") begin
            link_cfg.usp_dev_config = pick_dstRndCfg(pf_sel1,vf_sel1, .pick_fns_in_d0(pick_fns_in_d0),.pick_disabled_vf(pick_disabled_vf)); 
            link_cfg.dsp_dev_config = dev_cfg; 
          end else if (direction == "OB") begin
            link_cfg.usp_dev_config = dev_cfg; 
            if(!is_dut_dut_tb) link_cfg.dsp_dev_config = pick_srcCfg(pf_sel1, .pick_fns_in_d0(pick_fns_in_d0)); 
            else link_cfg.dsp_dev_config =  pick_dstPfCfg(pf_sel1,"PF", .pick_fns_in_d0(pick_fns_in_d0),.sel_other_end_device(1),.pick_disabled_vf(pick_disabled_vf));
	        end else begin
            `uvm_fatal(get_full_name(),"Direction is not properly feeded");
	        end
       end else begin //dut_mode == RP
          if(direction == "IB") begin
            link_cfg.usp_dev_config = dev_cfg; 
            link_cfg.dsp_dev_config = pick_dstPfCfg(pf_sel1, "PF", .pick_fns_in_d0(pick_fns_in_d0), .pick_disabled_vf(pick_disabled_vf)); 
          end else if (direction == "OB") begin
            if(!is_dut_dut_tb) link_cfg.usp_dev_config = pick_srcCfg(pf_sel1, .pick_fns_in_d0(pick_fns_in_d0)); 
            else link_cfg.usp_dev_config = pick_dstRndCfg(pf_sel1,vf_sel1, .pick_fns_in_d0(pick_fns_in_d0),.sel_other_end_device(1),.pick_disabled_vf(pick_disabled_vf));
            link_cfg.dsp_dev_config = dev_cfg; 
	        end else begin
            `uvm_fatal(get_full_name(),"Direction is not properly feeded");
	        end
       end
   end  
   else begin
     if(m_dut_mode == EP) begin
       if(direction == "IB") begin
         dev_cfg = this.dsp_dev_config; 
       end
       else begin
         dev_cfg = this.usp_dev_config; 
       end
     end
     else begin
       if(direction == "IB") begin
         dev_cfg = this.usp_dev_config; 
       end
       else begin
         dev_cfg = this.dsp_dev_config; 
       end
     end
   end
endfunction: pick_rnd_link_dev_cfg 

function automatic void cdn_hpa_pcie_link_config::pick_link_dev_cfg (input string direction = "IB", ref cdn_hpa_pcie_dev_config dev_cfg,ref cdn_hpa_pcie_link_config link_cfg, input int pf,  int vf, int dest_pf, int dest_vf, bit is_vf);

  cdn_pcie_hpa_dev_top_config vip_top_config;
  cdn_pcie_hpa_dev_top_config dev_top_config;

  if(m_dut_mode == CDN_HPA_PCIE_RP)
  begin
    vip_top_config = usp_dev_top_config;  
    dev_top_config = dsp_dev_top_config;  
  end
  else
  begin
    vip_top_config = dsp_dev_top_config;  
    dev_top_config = usp_dev_top_config;  
  end

  `uvm_info(get_type_name(), $psprintf("direction = %0s, pf = %0d, vf = %0d, dest_pf = %0d, dest_vf = %0d, m_dut_mode = %0s", direction, pf, vf, dest_pf, dest_vf, m_dut_mode.name),UVM_LOW)
  if(direction == "IB") begin
    //DUT Receives Packet. So pick the BFM's corresponding dev_cfg (Srccfg)
    dev_cfg = vip_top_config.pf_config[pf]; 
  end else if (direction == "OB") begin
    //DUT sends packet. So pick the DUT's corresponding dev_cfg (Srccfg)
    if(m_dut_mode == EP) begin
      if(is_vf)
        dev_cfg = dev_top_config.vf_config[pf][vf]; 
      else
        dev_cfg = dev_top_config.pf_config[pf]; 
    end else begin
      dev_cfg = dev_top_config.pf_config[pf]; 
    end
  end else begin
    `uvm_fatal(get_full_name(),"Direction is not properly feeded");
  end

  $cast(link_cfg,this);
  if(m_dut_mode == EP) begin
    if(direction == "IB") begin
      if(is_vf)
        link_cfg.usp_dev_config = dev_top_config.vf_config[dest_pf][dest_vf]; 
      else
        link_cfg.usp_dev_config = dev_top_config.pf_config[dest_pf]; 
      link_cfg.dsp_dev_config = dev_cfg; 
    end else if (direction == "OB") begin
      link_cfg.usp_dev_config = dev_cfg; 
      link_cfg.dsp_dev_config = vip_top_config.pf_config[dest_pf]; 
    end else begin
      `uvm_fatal(get_full_name(),"Direction is not properly feeded");
    end
  end else begin //dut_mode == RP
    if(direction == "IB") begin
      link_cfg.usp_dev_config = dev_cfg; 
      link_cfg.dsp_dev_config = dev_top_config.pf_config[dest_pf]; 
    end else if (direction == "OB") begin
      link_cfg.usp_dev_config = vip_top_config.pf_config[dest_pf]; 
      link_cfg.dsp_dev_config = dev_cfg; 
    end else begin
      `uvm_fatal(get_full_name(),"Direction is not properly feeded");
    end
  end
endfunction: pick_link_dev_cfg 

// TODO - Vamsi optimize
function bit[1:0] cdn_hpa_pcie_link_config :: get_core_clk_ns();
  cdn_pcie_hpa_dev_top_config dev_top_config;

  if(m_dut_mode == CDN_HPA_PCIE_RP)
  begin
    dev_top_config = dsp_dev_top_config;  
  end
  else
  begin
    dev_top_config = usp_dev_top_config;  
  end

 `ifdef UCIE
    //TODO with PHY clk frequency will change
    return 1;
 `endif

  // PIPE 64 -Gen1- 62.5MHz, Gen2 - 125, Gen3- 250, Gen4-500, Gen5-1G, Gen6-1G
  // PIPE 32 -Gen1- 62.5, Gen2 - 125, Gen3- 250, Gen4-500, Gen5-1G
  // PIPE 16 -Gen1- 125, Gen2 - 250, Gen3- 500, Gen4-1G 
  case({dev_top_config.i_cfg.k_pipe_width_ext, dev_top_config.i_cfg.k_pcie_rate_max})  
    5'b00_011 : return 1;
    5'b00_010 : return 2;
    5'b00_001 : return 4;
    5'b00_000 : return 8;

    5'b01_100 : return 1;
    5'b01_011 : return 2;
    5'b01_010 : return 4;
    5'b01_001 : return 8;
    5'b01_000 : return 16;

    5'b10_101 : return 1;
    5'b10_100 : return 1;  
    5'b10_011 : return 2;
    5'b10_010 : return 4;
    5'b10_001 : return 8;
    5'b10_000 : return 16;
  endcase 
endfunction

function bit cdn_hpa_pcie_link_config :: is_perf_type(CDN_PCIE_PERF_SETTING perf_type);
  if(scenario!=null && scenario.m_is_perf_mode==1 && scenario.m_perf_setting == perf_type)begin
    return 1;
  end
  else begin
    return 0;
  end
endfunction

function integer cdn_hpa_pcie_link_config :: get_exp_perf(CDN_PCIE_PERF_SETTING perf_type);
  case(perf_type)  
    OB_POSTED_PERF_MODE : return 80 ; 
    OB_NONPOSTED_PERF_MODE : return 80 ; 
    OB_CPL_PERF_MODE : return 80 ; 
    IB_POSTED_PERF_MODE : return 80 ; 
    IB_NONPOSTED_PERF_MODE : return 80 ; 
    IB_CPL_PERF_MODE : return 80 ; 
    OB_MIXED_PERF_MODE : return 80 ;
    IB_MIXED_PERF_MODE : return 80 ;
    OB_IB_MIXED_PERF_MODE : return 80 ;
  endcase 
endfunction

  //------------------------------------------------------------------------
  // Function: report_perf_metrics
  // Report performance for OB and IB at HLS client interface
  //------------------------------------------------------------------------

function automatic void cdn_hpa_pcie_link_config::report_perf_metrics(cdn_pcie_perf_obj perf);
  integer fptr,line;
  string filename;
  int rnd;
  cdn_pcie_hpa_dev_top_config dev_top_config;
  integer l_total_bytes;
  real    additional_clk_cycles;
  real    exp_data_bytes_per_pkt;
  real    exp_header_bytes_per_pkt;
  real    exp_ohc_bytes_per_pkt;
  real    exp_trailer_bytes_per_pkt;
  real    exp_total_bytes_per_pkt;
  integer fpointer;


  if(m_dut_mode == CDN_HPA_PCIE_RP)
  begin
    dev_top_config = dsp_dev_top_config;  
  end
  else
  begin
    dev_top_config = usp_dev_top_config;  
  end
  perf.total_bytes_overhead_bits = real'(real'(perf.m_total_hdr_bytes + perf.m_total_payload_bytes + perf.m_pl_dl_overhead)*8);

  if(dev_top_config.i_cfg.k_pcie_rate_max >= 3) 
  perf.m_pl_encoding_bytes = real'(real'(real'(perf.total_bytes_overhead_bits/128)*2)/8); // 1 byte overhead for every cycle (TODO: consider lanes)
  if(dev_top_config.i_cfg.k_pcie_rate_max <= 2)
  perf.m_pl_encoding_bytes = real'(real'(real'(perf.total_bytes_overhead_bits/8)*2)/8);

  perf.m_core_clk_period_in_ns = get_core_clk_ns();
  perf.m_total_num_cycles = real'(real'(perf.m_perf_end_time - perf.m_perf_start_time)/(real'(perf.m_core_clk_period_in_ns)));
  //perf.m_valid_low_cycles= real'(perf.m_total_num_cycles/16);
  
  if(dev_top_config.i_cfg.k_pipe_width_ext == 0)
  perf.m_pipe_width = 16;
  if(dev_top_config.i_cfg.k_pipe_width_ext == 1)
  perf.m_pipe_width = 32;
  if(dev_top_config.i_cfg.k_pipe_width_ext == 2)
  perf.m_pipe_width = 64;

  perf.m_peak_throughput =  real'(((perf.m_pipe_width/8)*(2**dev_top_config.i_cfg.strap_lane_count_in)) * perf.m_total_num_cycles);           ///real'(64* perf.m_total_num_cycles) - real'((perf.m_valid_low_cycles)* real'(4*16)); //(k_pipe_width_ext/8 x strap_lane_count) // in bytes
  l_total_bytes = real'(perf.m_total_hdr_bytes + perf.m_total_payload_bytes + perf.m_pl_dl_overhead +  perf.m_pl_encoding_bytes);
  perf.m_actual_bandwidth= real'(l_total_bytes /(real'(perf.m_perf_end_time - perf.m_perf_start_time)));
  perf.m_performance     = real'(real'(l_total_bytes /(real'(perf.m_peak_throughput/*- m_hdr_total_bytes*/)))*100);
  //m_ib_bw        = real'(m_ib_total_bytes/total_ib_num_cycles
  //max_ib_bw = <>;
  

 `ifdef UCIE
  if ((scenario.m_perf_setting == IB_CPL_PERF_MODE) || (scenario.m_perf_setting == OB_CPL_PERF_MODE )) begin
    exp_data_bytes_per_pkt     = dev_top_config.pf_config[0].m_max_rd_req_size_bytes;
    exp_header_bytes_per_pkt   = 12;
  end
  else if ((scenario.m_perf_setting == IB_POSTED_PERF_MODE) || (scenario.m_perf_setting == OB_POSTED_PERF_MODE )) begin
    exp_data_bytes_per_pkt     = dev_top_config.pf_config[0].m_max_payload_size_bytes;
    exp_header_bytes_per_pkt   = 16;
  end
  else begin
    exp_data_bytes_per_pkt     = 0;
    exp_header_bytes_per_pkt   = 0;
  end
  exp_ohc_bytes_per_pkt        = (perf.m_total_ohc_bytes == 0) ? 'd0 : (perf.m_total_ohc_bytes/perf.m_perf_tlp_count);
  exp_trailer_bytes_per_pkt    = (perf.m_total_trailer_bytes == 0) ? 'd0 : (perf.m_total_trailer_bytes/perf.m_perf_tlp_count);

  exp_total_bytes_per_pkt      = exp_data_bytes_per_pkt + exp_header_bytes_per_pkt + exp_ohc_bytes_per_pkt + exp_trailer_bytes_per_pkt;
  perf.m_total_num_cycles      = real'(real'(perf.m_perf_end_time - perf.m_perf_start_time)/(real'(perf.m_core_clk_period_in_ns)));
 `uvm_info(get_full_name(),$psprintf("DEBUG_PERF: exp_data_bytes_per_pkt:%0d exp_header_bytes_per_pkt:%0d. exp_total_bytes_per_pkt:%0d", 
                                      exp_data_bytes_per_pkt, exp_header_bytes_per_pkt , exp_total_bytes_per_pkt
                                    ),UVM_LOW)
  //---
  // Adding extra cycles to 
  // sample 1 packet - for considering actual start time
  //-----
  perf.m_total_tlp_bytes       = real'( perf.m_total_hdr_bytes + perf.m_total_payload_bytes + perf.m_total_ohc_bytes + perf.m_total_trailer_bytes ); 
  additional_clk_cycles        =  int'( real'( perf.m_total_tlp_bytes / perf.m_perf_tlp_count)/((parameters_cfg_pkg::KMAX_DATAPATH_WD)/8))+1;
  perf.m_total_num_cycles      = real'( perf.m_total_num_cycles + additional_clk_cycles); 
  perf.m_peak_throughput       = real'( real'((parameters_cfg_pkg::KMAX_DATAPATH_WD)/8) * perf.m_total_num_cycles);
  perf.m_total_flits_count     = real'( perf.m_total_tlp_bytes / 236 ); 
  perf.m_total_flit_overhead   = real'( 20 * perf.m_total_flits_count);
  l_total_bytes                = real'( perf.m_total_tlp_bytes + perf.m_total_flit_overhead);
  if (perf.m_flit_mode) begin
    perf.m_theortical_bandwidth  = real'( real'(exp_data_bytes_per_pkt / exp_total_bytes_per_pkt)*
                                           real'(236.0/256.0)*(parameters_cfg_pkg::KMAX_DATAPATH_WD)/8 
                                        );
  end
  else begin
    perf.m_theortical_bandwidth  = real'( real'(exp_data_bytes_per_pkt / exp_total_bytes_per_pkt)*
                                           real'(62.0/68.0)*(parameters_cfg_pkg::KMAX_DATAPATH_WD)/8 
                                        );
  end
  perf.m_actual_bandwidth      = real'( perf.m_total_payload_bytes / perf.m_total_num_cycles);
  perf.m_performance           = real'( real'(perf.m_actual_bandwidth/perf.m_theortical_bandwidth)*100);
 `uvm_info(get_full_name(),$psprintf("DEBUG_PERF: UCIe Performance metrics reported!. \
                                      \n Total_bytes::%f Throughput:%0.2f Performance:%0.2f Additional_clk_cycles::%0.2f",
                                      l_total_bytes, perf.m_peak_throughput, perf.m_performance, additional_clk_cycles 
                                    ),UVM_HIGH)
  //---------------------------------------------------------------------------
 `endif

 `uvm_info(get_full_name(), $sformatf("Performance Metrics for \n%s", perf.sprint(uvm_default_table_printer)),  UVM_LOW)
 `uvm_info(get_full_name(), $psprintf("DEBUG_PERF: Performance metrics reported "),UVM_LOW)
    
 `ifdef UCIE
  //---------------------------------------------------------------------------
  fpointer = $fopen("perf_data.csv", "a+");
  if(!fpointer) `uvm_info(get_name(),"perf data file is not opened for append",UVM_LOW)
  $fdisplay(fpointer, "%9s, %6s, %3d bytes, %9d, %6d bytes, %11.0f, %7.0f ns, %9.2f GBps, %7.2f GBps, %10.2f%%", 
                      scenario.m_perf_setting, scenario.m_perf_setting, perf.m_total_flit_overhead, perf.m_perf_tlp_count, 
                      exp_data_bytes_per_pkt, perf.m_total_payload_bytes, perf.m_total_num_cycles, perf.m_theortical_bandwidth, 
                      perf.m_actual_bandwidth, perf.m_performance
  );
  $fclose(fpointer);
  if(perf.m_performance < real'(98.0) || perf.m_performance > real'(100.0)) begin
    $display("---------------------------------------------------------------- \n",
             "%s performance check failed. \n", scenario.m_perf_setting,
             "Expected BW : %3.2f GBps \n", perf.m_theortical_bandwidth,
             "Actual BW   : %3.2f GBps \n", perf.m_actual_bandwidth,
             "Performance : %3.2f%% \n", perf.m_performance,
             "Threshold   : between 98.0%% & 100.0%% \n",
             "----------------------------------------------------------------");
      `uvm_error("DEBUG_PERF",$sformatf("[%f] [CALCULATE_PERFORMANCE] [ERROR] - Performance Check Failure", $time))
  end
  //---------------------------------------------------------------------------
 `endif

  //-----------------
  // Perf Reporting
  //----------------------
  rnd = $urandom();
  filename=$psprintf("Replace_this_path_to_current_scratch/perf_rnd%0d.txt",rnd);//
 `uvm_info(get_full_name(),$psprintf("file_name = %0s ",filename),UVM_LOW) 

  fptr = $fopen(filename,"ab");
  line = $ftell(fptr);
  if(line > 0) begin //{
     //perf_modes();
        if(scenario.m_perf_setting == IB_NONPOSTED_PERF_MODE)begin
          $fdisplay(fptr, "|  %0d   |    %0d   |   %0d      |   %0d   |   %0d   |      %0.2f        |    %0.2f    |    --     |    %0.2f   |    --     |    --     |    --     |    --     |    --     |    --     |     --     |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == IB_POSTED_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d  |    %0d   |   %0d      |  %0d    |  %0d    |      %0.2f        |    %0.2f    |    --     |     --     |    %0.2f   |    --     |    --     |    --     |    --     |    --     |     --    |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+------------+-----------+-----------+-----------+-----------+-----------+-----------+");
         end

         else if(scenario.m_perf_setting == IB_CPL_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d  |    %0d   |   %0d      |   %0d   |   %0d   |      %0.2f        |    %0.2f    |    --     |     --     |    --     |    --     |    --     |   %0.2f   |    --     |    --     |     --     |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == OB_NONPOSTED_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d  |    %0d   |   %0d      |   %0d   |   %0d   |      %0.2f        |    %0.2f    |   %0.2f   |     --     |    --     |    --     |    --     |     --    |    --     |    --     |     --     |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.m_neg_link_width, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == OB_POSTED_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d  |    %0d   |   %0d      |  %0d    |   %0d   |      %0.2f        |    %0.2f    |    --     |     --     |    --     |   %0.2f   |    --     |    --     |    --     |    --     |     --     |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == OB_CPL_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d  |    %0d   |   %0d      |   %0d   |   %0d   |      %0.2f        |    %0.2f    |    --     |     --     |    --     |   --      |    %0.2f  |    --     |    --     |    --     |     --     |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max,dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end 

  end //}
  else begin //{
         $fdisplay(fptr, "==========================================================================================================");
         $fdisplay(fptr, "PCIe Performance Test Suite Results");
         $fdisplay(fptr, "==========================================================================================================");
         $fdisplay(fptr, "");

         $fdisplay(fptr, "Performance Metrics Combinations");
         $fdisplay(fptr, "* EP and RP modes");
        `ifndef UCIE
         $fdisplay(fptr, "* Possible Link Speeds (GenSpeed)");
         $fdisplay(fptr, "* Write Payload Sizes (WPS)");
         $fdisplay(fptr, "* Read Completion Payload Sizes (RCPS)");
         $fdisplay(fptr, "* Total Byte count used in Writes/Reads is %0f:", perf.m_total_payload_bytes);
         $fdisplay(fptr, "* Theoritical Maximum BW is calculated witht he following formula: ");
         $fdisplay(fptr, "* For Gen1/2: (2 ** pipe_rate) * 250 * link_width * (real'(pkt_size) / real'(pkt_size + hdr_ovrhead))");
         $fdisplay(fptr, "* For Gen3 and above: (2 ** pipe_rate) * 246 * link_width * (real'(pkt_size) / real'(pkt_size + hdr_ovrhead))");
         $fdisplay(fptr, "* Percentage = (Measured BW) / (Theoritical Maximum BW) * 100");
        `else
         $fdisplay(fptr, "* Write Payload Sizes           (WPS)");
         $fdisplay(fptr, "* Read Completion Payload Sizes (RCPS)");
         $fdisplay(fptr, "* Total Byte count used in Writes/Reads is %0d ",  perf.m_total_payload_bytes);
         $fdisplay(fptr, "");
         $fdisplay(fptr, "* Theoritical Maximum BW is calculated with the following formula: Expecting in FDI Interface");
         $fdisplay(fptr, "");
         $fdisplay(fptr, "* total_num_perf_cycles                    = ( performance_end_time - performance_start_time)/(core_clk_period_in_ns)");
         $fdisplay(fptr, "* Theortical_bandwidth  (ucie format = 3)  = ( ( Expected_data_bytes_per_pkt/ Total_bytes_per_packet) * (236/256) * ((parameters_cfg_pkg::KMAX_DATAPATH_WD)/8) ) / time_priode ");
         $fdisplay(fptr, "* Theortical_bandwidth  (ucie format = 2)  = ( ( Expected_data_bytes_per_pkt/ Total_bytes_per_packet) * (62/68) * ((parameters_cfg_pkg::KMAX_DATAPATH_WD)/8) ) / time_priode ");
         $fdisplay(fptr, "");
         $fdisplay(fptr, "* actual_bandwidth                         = l_total_bytes / total_num_perf_cycles");
         $fdisplay(fptr, "");
         $fdisplay(fptr, "* Performance Percentage                   = (actual_bandwidth / Theortical_bandwidth ) * 100");
        `endif
         $fdisplay(fptr, "");

         $fdisplay(fptr, "Performance Metrics Data Paths");
         $fdisplay(fptr, "+=======================+================================================================================+");
         $fdisplay(fptr, "| Data Path             | Details                                                                        |");
         $fdisplay(fptr, "+=======================+================================================================================+");
         $fdisplay(fptr, "| Outbound Request Path | AXI to PCIe Outbound Memory Writes                                             |");
         $fdisplay(fptr, "+-----------------------+--------------------------------------------------------------------------------+");
         $fdisplay(fptr, "| Inbound Completion    | AXI to PCIe Outbound Memory Reads resulting in PCIe to AXI Inbound completions |");
         $fdisplay(fptr, "+-----------------------+--------------------------------------------------------------------------------+");
         $fdisplay(fptr, "| Inbound Request Path  | PCIe to AXI Inbound Memory Writes                                              |");
         $fdisplay(fptr, "+-----------------------+--------------------------------------------------------------------------------+");
         $fdisplay(fptr, "| Outbound Completion   | PCIe to AXI Inbound Memory Reads resulting in AXI to PCIe outbound completions |");
         $fdisplay(fptr, "+-----------------------+--------------------------------------------------------------------------------+");
         $fdisplay(fptr, "");
          
         $fdisplay(fptr, "NOTES:");
         $fdisplay(fptr, "* Inbound completion path has less performance in some cases, due to known verification environment issue.");
         $fdisplay(fptr, "");


         $fdisplay(fptr, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Performance Metrics >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
         $fdisplay(fptr, "+=======+==========+============+=========+=========+===================+=============+===========+============+===========+===========+===========+===========+===========+==========+=============+");
         $fdisplay(fptr, "| IS_RC | GenSpeed | Link_Width |   WPS   |   RCPS  |Total_payload_bytes| Performance | OB NP BW  |  IB NP BW  |  IB P BW  |  OB P BW  |   OB CPL  |   IB CPL  |  OB Mixed | IB Mixed | OB & IB Mixed");
         $fdisplay(fptr, "+=======+==========+============+=========+=========+===================+=============+===========+============+===========+===========+===========+===========+===========+===========+=============+");
         //perf_modes();       
         if(scenario.m_perf_setting == IB_NONPOSTED_PERF_MODE)begin
           $fdisplay(fptr, "|  %0d    |    %0d     |   %0d        |  %0d   |  %0d   |      %0.2f        |    %0.2f       |   --     |    %0.2f   |    --     |   --     |   --     |   --     |   --     |   --     |   --    |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == IB_POSTED_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d    |    %0d     |   %0d        |  %0d   |  %0d   |      %0.2f        |    %0.2f       |   --     |    --     |    %0.2f   |   --     |   --     |   --     |   --     |   --     |   --    |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == IB_CPL_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d    |    %0d     |   %0d        |  %0d   |  %0d   |      %0.2f        |    %0.2f       |   --     |    --     |    --     |   --     |   --     |   %0.2f   |   --     |   --     |   --    |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == OB_NONPOSTED_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d    |    %0d     |   %0d        |  %0d   |  %0d   |      %0.2f       |    %0.2f       |   %0.2f   |    --     |    --     |   --     |   --     |    --    |   --     |   --     |   --    |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == OB_POSTED_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d    |    %0d     |   %0d        |  %0d   |  %0d   |      %0.2f        |    %0.2f       |   --     |    --     |    --     |   %0.2f   |   --     |    --     |   --     |   --     |   --    |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end

         else if(scenario.m_perf_setting == OB_CPL_PERF_MODE) begin 
           $fdisplay(fptr, "|  %0d    |    %0d     |   %0d        |  %0d   |  %0d   |      %0.2f        |    %0.2f       |   --     |    --     |    --     |   --      |   %0.2f  |    --     |   --     |   --     |   --    |",m_dut_mode, dev_top_config.i_cfg.strap_pcie_rate_max, dev_top_config.i_cfg.strap_lane_count_in, dev_top_config.pf_config[0].m_max_payload_size_dw, dev_top_config.pf_config[0].m_max_rd_req_size_dw, perf.m_total_payload_bytes, perf.m_performance, perf.m_actual_bandwidth);
           $fdisplay(fptr, "+-------+----------+------------+---------+---------+-------------------+-------------+-----------+------------+-----------+-----------+-----------+-----------+-----------+-----------+------------+");
         end 
	 
	 if(perf.m_performance<get_exp_perf(scenario.m_perf_setting)) begin
	   `uvm_error(get_type_name(), $psprintf("%s: Performance less than Expectd. Actual:%0d, Expected:%0d",scenario.m_perf_setting.name,perf.m_performance,get_exp_perf(scenario.m_perf_setting)));
	 end
         else begin 
	   if(perf.m_performance>100) begin 
	     `uvm_error(get_type_name(), $psprintf("%s: Actual Performance is More than 100. Check Performance Calculations. Actual Performance in percentage:%0d ",scenario.m_perf_setting.name,perf.m_performance));
	   end
	 end

  end //}

endfunction: report_perf_metrics 

  function bit[15:0] cdn_hpa_pcie_link_config::get_completer_id (int pf_num, int vf_num);
    int k_sriov_stride,offset = 1;
    int func_num;
    bit[15:0] completer_id;

    if(vf_num == -1)
      completer_id = usp_dev_top_config.pf_config[pf_num].m_req_id;
    else
      completer_id = usp_dev_top_config.vf_config[pf_num][vf_num].m_req_id;
    //bit[7:0] pf_bus_num = usp_dev_top_config.pf_config[pf_num].m_req_id.bus_num;
    //bit[2:0] pf_func_num = usp_dev_top_config.pf_config[pf_num].m_req_id.function_num; 
    //bit[4:0] pf_device_num = usp_dev_top_config.pf_config[pf_num].m_req_id.device_num; 
    //
    //if(m_dut_mode == EP || is_dut_dut_tb) begin 
    //  k_sriov_stride = usp_dev_top_config.pf_config[pf_num].m_vf_stride;
    //  offset = usp_dev_top_config.pf_config[pf_num].m_first_vf_Offset;
    //end else begin
    //  k_sriov_stride = 0;
    //  offset =0;
    //end    

    //if(vf_num !=-1) begin
    //  func_num = pf_func_num +offset+(k_sriov_stride * vf_num); 
    //  //func_num = (vf_num == 'h0)? pf_num+offset : (pf_num+offset+(k_sriov_stride * (vf_num+1))); 
    //end else begin
    //  func_num = pf_func_num;
    //end
    //
    ////TODO Take care of situation where device_no !=0 but with VFs (ie., non-ARI) and VFs > 255
    //if(usp_dev_top_config.pf_config[pf_num].m_cap_ari_supp)
    //  completer_id = {pf_bus_num,func_num[7:0]};
    //else
    //begin
    //  if(func_num > 7)
    //    `uvm_error(get_full_name(), "function number is not correct")
    //  completer_id = {pf_bus_num, pf_device_num,func_num[2:0]};
    //end

    return  completer_id;   
  endfunction : get_completer_id


`endif
