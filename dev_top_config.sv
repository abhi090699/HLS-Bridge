
//-----------------------------------------------------------------------------
`ifndef CDN_PCIE_HPA_DEV_TOP_CONFIG_SV
`define CDN_PCIE_HPA_DEV_TOP_CONFIG_SV

// For 32 bit BARs upper 32 bits must be zero
class cdn_cxl_io_32bit_rcrb_policy extends  uvm_mem_mam_policy;

  function new(string name="cdn_cxl_io_32bit_rcrb_policy");
    super.new();
  endfunction

  //alignement
  constraint align_8k_c { start_offset[12:0] == 0; }
  constraint align_64b_c { start_offset[63:32] == 0; }

endclass

class cdn_cxl_io_64bit_rcrb_policy extends  uvm_mem_mam_policy;

  function new(string name="cdn_cxl_io_64bit_rcrb_policy");
    super.new();
  endfunction

  //alignement
  constraint align_8k_c { start_offset[12:0] == 0; }
  constraint align_64b_c { start_offset[63:32] != 0; }

endclass
//------------------------------------------------------------------------
// Class: cdn_pcie_hpa_dev_top_config
// Base class for PCIe TLP
//------------------------------------------------------------------------
class cdn_pcie_hpa_dev_top_config extends cdnpcie_component;

  //------------------------------------------------------------------------
  // CONTROL KNOBS
  //------------------------------------------------------------------------

  bit is_dut_config; // 1: For DUT config  , 0: For VIP config
  string ide_spec_err_scen;
  string fm_dll_spec_err_scen;
  int loop_cnt_pf, loop_cnt_vf;

  int unsigned l_num_enabled_pfs;
  //-------------------------------------------------------------------------
  // pm_spec_scen: Used to run specific PM scenario 
  // {ASPM_L0S, ASPM_L1, PM_L1, PM_L2, ASPM_L1_1, ASPM_L1_2, PM_L1_1,PM_L1_2}
  //-------------------------------------------------------------------------
  string pm_spec_scen;
  string ps_pm_spec_scen;
  //------------------------------------------------------------------------
  // ALL DLLP Error injction flag
  rand bit  CDN_HPA_DLLP_INITFC_TYPE_CORRPT_ERR;
  rand bit  CDN_HPA_DLLP_INITFC_TYPE_CORRPT_GOOD_CRC_ERR;
  rand bit  CDN_HPA_DLLP_INITFC1_HDR_CORRPT_ERR;
  rand bit  CDN_HPA_DLLP_INITFC1_DATA_CORRPT_ERR;
  rand bit  CDN_HPA_DLLP_INITFC2_HDR_CORRPT_ERR;
  rand bit  CDN_HPA_DLLP_INITFC2_DATA_CORRPT_ERR;
  rand bit  CDN_HPA_DLLP_INITFC1_HDRSC_UNSUPP_ERR;
  rand bit  CDN_HPA_DLLP_INITFC1_DATASC_UNSUPP_ERR;
  rand bit  CDN_HPA_DLLP_INITFC2_HDRSC_UNSUPP_ERR;
  rand bit  CDN_HPA_DLLP_INITFC2_DATASC_UNSUPP_ERR;
  rand bit  CDN_HPA_DLLP_DISCARD_INITFC2_ERR;
  rand bit  CDN_HPA_DLLP_DISCARD_INITFC1_ERR;
  rand bit  CDN_HPA_DLLP_INITFC_LCRC;
  rand bit  CDN_HPA_DLLP_FC_LCRC_ERR;
  rand bit  CDN_HPA_DLLP_FEATURE_ACK_CORRPT_ERR;
  rand bit  CDN_HPA_DLLP_FEATURE_SUPP_CORRPT_ERR;
  rand bit  CDN_HPA_DLLP_FEATURE_ACK_CORRPT_GOOD_LCRC_ERR;
  rand bit  CDN_HPA_DLLP_FEATURE_SUPP_CORRPT_GOOD_LCRC_ERR;
  rand bit  CDN_HPA_DLLP_FEATURE_NON_ZERO_RSVD_ERR;
  rand bit  CDN_HPA_DLLP_FEATURE_CORRUPT_RSVD_FIELD_ERR;
  rand bit  CDN_HPA_DLLP_INITFC1_ORDER_ERR;
  rand bit  CDN_HPA_DLLP_INITFC2_ORDER_ERR;
  rand bit  CDN_HPA_DLLP_INITFC_DROP_32_MS;
  //PM DLLP Error control var
  rand bit  CDN_HPA_DLLP_PM_LCRC_ERR;
  rand bit  CDN_HPA_DLLP_PM_NON_ZERO_RSVD_ERR;
  rand bit  CDN_HPA_DLLP_PM_CORRUPT_RSVD_ERR;
  rand bit  CDN_HPA_DLLP_PME_TO_ACK_DROP_ERR;

  bit  replay_timeout_flag;
  bit  ptm_cxl_l1;
  rand bit  eptm_replay_scenario;
  rand bit  eptm_duplicate_scenario; 
  rand bit  m_disable_inv_context;
  bit  initfc1_timeout_flag;
  bit  initfc2_timeout_flag;
  bit test_52_12_start_corruption;
  bit [1:0] test_52_12_replay_num = 2'b11;
  bit test_52_15_start_corruption;
  bit test_52_15_nak_sent; 
  bit  ptc_52_14_flag;
  bit  ptc_52_14_start;   
  bit ptc_52_14_seq_corruption;
  bit ptc_52_14_seq_corruption2;  
  bit ptc_52_14_replay_timer;
  bit ptc_52_170_fef;
  bit ptc_52_170_initial_checker;
  bit ptc_52_170_aer_implemented_flag; 
  bit ptc_52_170_seq_corruption; 
  bit ptc_52_11_seq_corruption;
  bit ptc_52_11_replay_timer;
  int  INIT_FC_discard;
  int  tc_vc_mapping_done;
  bit[1:0] uio_tc_vc_mapping_done;
  bit[1:0] uio_tc_svc_mapping_done;
  int  vc_scheduled_posted_tlps[8];
  int  vc_scheduled_nonposted_tlps[8];
  int  vc_allowed_posted_tlps[8];
  int  vc_allowed_nonposted_tlps[8];
  bit  m_credit_throttle_enabled;
  int  num_tlps_allowed;
  int  num_pkts;
  bit  rx_nak_rcvd;
  bit  pr_grp_resp_failure;
  bit [2:0] last_usp_tx_snoop_sc;
  bit [9:0] last_usp_tx_snoop_lat;
  bit [2:0] last_usp_tx_no_snoop_sc;
  bit [9:0] last_usp_tx_no_snoop_lat;
  bit ltr_msg_trans_ob;
  bit ltr_msg_trans_ib;
  bit dl_rx_q_exit_disable;

  //coverage related bits - FC
  int unsigned  shared_credits_consumed_posted_hdr[8];
  int unsigned  shared_credits_consumed_nonposted_hdr[8];
  int unsigned  shared_credits_consumed_completion_hdr[8];
  int unsigned  shared_credits_consumed_posted_data[8];
  int unsigned  shared_credits_consumed_nonposted_data[8];
  int unsigned  shared_credits_consumed_completion_data[8];
  int unsigned  prev_shared_credits_consumed_posted_hdr[8];
  int unsigned  prev_shared_credits_consumed_nonposted_hdr[8];
  int unsigned  prev_shared_credits_consumed_completion_hdr[8];
  int unsigned  prev_shared_credits_consumed_posted_data[8];
  int unsigned  prev_shared_credits_consumed_nonposted_data[8];
  int unsigned  prev_shared_credits_consumed_completion_data[8];
  bit shared_credits_consumed_posted_preserved;
  bit shared_credits_consumed_nonposted_preserved;
  bit shared_credits_consumed_completion_preserved;
  bit shared_credits_consumed_posted_maintained_separately;
  bit shared_credits_consumed_completion_maintained_separately;
  int unsigned sum_shared_credits_consumed_ph;
  int unsigned sum_shared_credits_consumed_nph;
  int unsigned sum_shared_credits_consumed_cplh;
  int unsigned sum_shared_credits_consumed_pd;
  int unsigned sum_shared_credits_consumed_npd;
  int unsigned sum_shared_credits_consumed_cpld;
  int unsigned shared_cumulative_credits_required_ph;
  int unsigned shared_cumulative_credits_required_nph;
  int unsigned shared_cumulative_credits_required_cplh;
  int unsigned shared_cumulative_credits_required_pd;
  int unsigned shared_cumulative_credits_required_npd;
  int unsigned shared_cumulative_credits_required_cpld;
  bit shared_fc_limit_en_tx_gate_p;
  bit shared_fc_limit_en_tx_gate_cpl;
  bit shared_fc_limit_dis_tx_gate_p;
  bit shared_fc_limit_dis_tx_gate_cpl;
   

  int unsigned shared_credits_limit_fcph[8];
  int unsigned shared_credits_limit_fcpd[8];
  int unsigned shared_credits_limit_fcnph[8];
  int unsigned shared_credits_limit_fcnpd[8];
  int unsigned shared_credits_limit_fccplh[8];
  int unsigned shared_credits_limit_fccpld[8];
  bit shared_credits_limit_posted_preserved;
  bit shared_credits_limit_nonposted_preserved;
  bit shared_credits_limit_completion_preserved;
  int unsigned sum_shared_credits_limit_ph;
  int unsigned sum_shared_credits_limit_pd;
  int unsigned sum_shared_credits_limit_nph;
  int unsigned sum_shared_credits_limit_npd;
  int unsigned sum_shared_credits_limit_cplh;
  int unsigned sum_shared_credits_limit_cpld;
   

  int unsigned credit_limit_fcph[8];
  int unsigned credit_limit_fcpd[8];
  int unsigned credit_limit_fcnph[8];
  int unsigned credit_limit_fcnpd[8];
  int unsigned credit_limit_fccplh[8];
  int unsigned credit_limit_fccpld[8];
  bit zero_credit_limit_p;
  bit zero_credit_limit_np;
  bit zero_credit_limit_cpl;
   

  int unsigned shared_credits_consumed_curr_posted_hdr[8];
  int unsigned shared_credits_consumed_curr_nonposted_hdr[8];
  int unsigned shared_credits_consumed_curr_completion_hdr[8];
  int unsigned shared_credits_consumed_curr_posted_data[8];
  int unsigned shared_credits_consumed_curr_nonposted_data[8];
  int unsigned shared_credits_consumed_curr_completion_data[8];
  bit calculated_shared_credits_consumed_curr_p_tlp;
  bit calculated_shared_credits_consumed_curr_np_tlp;
  bit calculated_shared_credits_consumed_curr_cpl_tlp;
  bit calculated_shared_credits_consumed_curr_update_fc_p;
  bit calculated_shared_credits_consumed_curr_update_fc_np;
  bit calculated_shared_credits_consumed_curr_update_fc_cpl;
  
  int unsigned prev_shared_credits_consumed_curr_posted_hdr[8];
  int unsigned prev_shared_credits_consumed_curr_nonposted_hdr[8];
  int unsigned prev_shared_credits_consumed_curr_completion_hdr[8];
  int unsigned prev_shared_credits_consumed_curr_posted_data[8];
  int unsigned prev_shared_credits_consumed_curr_nonposted_data[8];
  int unsigned prev_shared_credits_consumed_curr_completion_data[8];
  bit shared_credits_consumed_curr_posted_preserved;
  bit shared_credits_consumed_curr_nonposted_preserved;
  bit shared_credits_consumed_curr_completion_preserved;
   
   
  int unsigned total_shared_credits_available_sum; 
  int unsigned total_shared_credits_available_vc[8];
  int unsigned total_shared_credits_available_posted[8];
  int unsigned total_shared_credits_available_nonposted[8];
  int unsigned total_shared_credits_available_completion[8];

  bit total_shared_credits_available_preserved;
  
  bit dedicated_crd_count_clr;
  bit shared_crd_count_not_clr; 
   
  bit vc_re_enabled_during_test;

  int unsigned shared_credits_allocated_posted_hdr[8];
  int unsigned shared_credits_allocated_nonposted_hdr[8];
  int unsigned shared_credits_allocated_completion_hdr[8];
  int unsigned shared_credits_allocated_posted_data[8];
  int unsigned shared_credits_allocated_nonposted_data[8];
  int unsigned shared_credits_allocated_completion_data[8];
  int unsigned sum_shared_credits_allocated_ph;
  int unsigned sum_shared_credits_allocated_pd;
  int unsigned sum_shared_credits_allocated_nph;
  int unsigned sum_shared_credits_allocated_npd; 
  int unsigned sum_shared_credits_allocated_cplh;
  int unsigned sum_shared_credits_allocated_cpld;

  int unsigned shared_credits_received_posted_hdr[8];
  int unsigned shared_credits_received_nonposted_hdr[8];
  int unsigned shared_credits_received_completion_hdr[8];
  int unsigned shared_credits_received_posted_data[8];
  int unsigned shared_credits_received_nonposted_data[8];
  int unsigned shared_credits_received_completion_data[8];
  int unsigned sum_shared_credits_received_ph;
  int unsigned sum_shared_credits_received_pd;
  int unsigned sum_shared_credits_received_nph; 
  int unsigned sum_shared_credits_received_npd; 
  int unsigned sum_shared_credits_received_cplh;
  int unsigned sum_shared_credits_received_cpld;

  bit flag_receiver_fc_overflow_merged;
  bit flag_receiver_fc_overflow_non_merged;

  int unsigned rcvd_pkt_time_p[8]; 
  int unsigned prev_rcvd_pkt_time_p[8];
  int unsigned rcvd_pkt_time_np[8]; 
  int unsigned prev_rcvd_pkt_time_np[8];
  int unsigned rcvd_pkt_time_cpl[8]; 
  int unsigned prev_rcvd_pkt_time_cpl[8];
 
  //random function disable only randomized in dev_top_cfg_random_policy esle nothing disabled
  bit [127:0] m_is_pf_disabled_by_lm;   // Assuming 32 PFs are enabled  
  bit  no_pf_in_non_D0 ;
  bit  pf_disable_done  ;

  // Added CXL Variables
  bit  [3:0] cxl_cfg_arb_weight_io;
  bit  [3:0] cxl_cfg_arb_weight_cache_mem;
  bit cxl_ldid_prefix;
  bit vdm_for_cxl;
  bit cxl_cfg_emd_enable; 
  //cxl_reg_window addr programming variables
  bit [63:0] cfg_window1_start_addr;
  bit [63:0] cfg_window2_start_addr;
  bit [63:0] cfg_window3_start_addr;
  
  bit [63:0] cfg_window1_end_addr;
  bit [63:0] cfg_window2_end_addr;
  bit [63:0] cfg_window3_end_addr;
  bit cfg_window_programming_done;
  // CXL SPECIFIC REG PROGRAMMING VARIABLES
   //---------------------------------------------------------------------------
  //reg_locator_programming_variables
  //---------------------------------------------------------------------------
  bit [31:0]       BAR0_ADDR                                     ;
  bit [31:0]       BAR1_ADDR                                     ;
  bit [31:0]       BAR2_ADDR                                     ;
  bit [31:0]       BAR3_ADDR                                     ;
  bit [31:0]       BAR4_ADDR                                     ;
  bit [31:0]       BAR5_ADDR                                     ;
  bit [35:0]       BAR_APERTURE                                  ;
  bit [5:0]        BAR_SIZE                                      ;
  rand bit [63:0]  PCR_REG_SIZE                                  ;
  rand bit [63:0]  ACL_REG_SIZE                                  ;
  rand bit [63:0]  CPMU_REG_SIZE                                 ;
  rand bit [63:0]  DEVICE_REG_SIZE                               ;
  rand bit [63:0]  VENDOR_REG_SIZE                               ;
  rand bit [31:0]  dvsec_reg_block0_offset_low                   ;
  rand bit [31:0]  dvsec_reg_block0_offset_high                  ;
  rand bit [31:0]  dvsec_reg_block1_offset_low                   ;
  rand bit [31:0]  dvsec_reg_block1_offset_high                  ;
  rand bit [31:0]  dvsec_reg_block2_offset_low                   ;
  rand bit [31:0]  dvsec_reg_block2_offset_high                  ;
  rand bit [19:0]  cxl_mmio_axi_id                               ;
  rand bit         cxl_mmio_axi_id_tracking_en                   ;

  // CXL -LM register related varilable for CXLREG_ERR_INTR_VECTOR Reg
  rand bit cxlreg_intr_vector_client_mmio_snoop_wr_timeout_err;
  rand bit cxlreg_intr_vector_client_mmio_snoop_rd_timeout_err;
  rand bit cxlreg_intr_vector_link_mmio_snoop_wr_timeout_err;
  rand bit cxlreg_intr_vector_link_mmio_snoop_rd_timeout_err;
  rand bit cxlreg_intr_vector_intrnl_ras_err;
  rand bit cxlreg_intr_vector_atomic_timeout_err;
  rand bit cxlreg_intr_vector_rloc_block1_err;
  rand bit cxlreg_intr_vector_rloc_block2_err;
  rand bit cxlreg_intr_vector_rloc_block3_err;
  rand bit cxlreg_intr_vector_ide_itrupt_err;

  // CXL -LM Interrupt Mask register related varilable for CCXLREG_ERR_INTR_VECTOR_EN Reg
  rand bit cxlreg_intr_vector_client_mmio_snoop_wr_timeout_mask;
  rand bit cxlreg_intr_vector_client_mmio_snoop_rd_timeout_mask;
  rand bit cxlreg_intr_vector_link_mmio_snoop_wr_timeout_mask;
  rand bit cxlreg_intr_vector_link_mmio_snoop_rd_timeout_mask;
  rand bit cxlreg_intr_vector_atomic_timeout_mask;
  rand bit cxlreg_intr_vector_intrnl_ras_mask;
  rand bit cxlreg_intr_vector_rloc_block_mask;
  rand bit cxlreg_intr_vector_ide_itrupt_mask;
  ////
  
  bit        is_bar32;
  
  //Used by PL sequences to initiate LW//LS change
  int  ob_tlp_count;
  int  ib_tlp_count;

  //Used by PM sequence
  int  ob_tlp_generated;

  bit m_error_seen;
  bit inject_error_in_next_packet;

  rand bit [1:0] rxst_err_type; 

  rand bit [1:0] m_num_tlp_per_half_flit;

  //to check whether msi_data is written into register or not
  bit m_msi_data_done;

  bit m_msi_inject_test_enable;

  // Payload value to be used for MSI injection testing
  bit [15:0] msi_inject_test_payload_q[$];
 
  //---------------------------------------------------------------------------
  // Field: reg_model
  // This field is handler pcie5 uvm reg
  //---------------------------------------------------------------------------
  cdnpcie_reg_rdb reg_model;

  int  m_posted_tlp_scheduled;
  int  m_posted_tlp_sent;
  int  m_posted_msg_tlp_scheduled;
  int  m_posted_msg_tlp_sent;
  int  m_posted_mem_tlp_scheduled;
  int  m_posted_mem_tlp_sent;
  int  m_nonposted_tlp_sent;
  int  ib_perf_tlp_count;
  int  m_fatal_err_msg_rcvd_cnt;
  int  m_non_fatal_err_msg_rcvd_cnt;
  int  m_correctable_err_msg_rcvd_cnt;
  bit unblock_wait_for_uncor_tests=0; 
  //Used by HLS Module TB for IB Traffic
  bit ib_traffic;

  bit m_en_ib_perf_monitor;
  int num_errors;
  int m_num_allowed_errors;
  bit[127:0] cfg_error_header_log[$];
  bit[127:0] cfg_error_prefix_log[$];
  bit[15:0] error_msg_req_id[$];
  bit m_en_ob_perf_monitor;

  rand bit m_tl_to_pack_ecrc=0;

  int unsigned unimpl_ptc_func;

  // cpl_abort_transactionID used to expect error for particular ReqID and tag combination
  // [31:24]=Busnum [23:19]=DevNum, [18:16]=FunNum, [15:14]=TagScale, [13:0]CplTag 
  bit [31:0] cpl_abort_transactionID_q[$];
  bit [31:0] cpl_ur_transactionID_q[$];
  //-----------------------------------------------------
  // Ack Nak Frequency timer mapping table
  //------------------------------------------
  rand bit ack_nak_program_en;
  rand  int ack_nak_latency[6:0];
  //--->H.2 Ack Latency Table in implementation document
  int ack_nak_lat_map_table[int/*gen*/][int/*link width*/][0:5/*$clog2(MPS) - 7*/] = '{
                                 0: '{
                                    1:{237,416,559,1071,2095,4143},
                                    2:{128,217,289,545,1057,2081},
                                    4:{73,118,154,282,538,1050},
                                    8:{67,107,86,150,278,534},
                                    12:{58,90,109,194,365,706},
                                    16:{48,72,86,150,278,534},
                                    32:{33,45,52,84,148,276}
                                    },
                                 1: '{
                                    1:{288,467,610,1122,2146,4194},
                                    2:{179,268,340,596,1108,2132},
                                    4:{124,169,205,333,589,1101},
                                    8:{118,158,137,201,329,585},
                                    12:{109,141,160,245,416,757},
                                    16:{99,123,137,201,329,585},
                                    32:{84,96,103,135,199,327}
                                    },
                                 2: '{
                                    1:{333,512,655,1167,2191,4239},
                                    2:{224,313,385,641,1153,2177},
                                    4:{169,214,250,378,634,1146},
                                    8:{163,203,182,246,374,630},
                                    12:{154,186,205,290,461,802},
                                    16:{144,168,182,246,374,630},
                                    32:{129,141,148,180,244,372}
                                    },
                                 3: '{
                                    1:{333,512,655,1167,2191,4239},
                                    2:{224,313,385,641,1153,2177},
                                    4:{169,214,250,378,634,1146},
                                    8:{163,203,182,246,374,630},
                                    12:{154,186,205,290,461,802},
                                    16:{144,168,182,246,374,630},
                                    32:{129,141,148,180,244,372}
                                    },
                                 4: '{
                                    1:{333,512,655,1167,2191,4239},
                                    2:{224,313,385,641,1153,2177},
                                    4:{169,214,250,378,634,1146},
                                    8:{163,203,182,246,374,630},
                                    12:{154,186,205,290,461,802},
                                    16:{144,168,182,246,374,630},
                                    32:{129,141,148,180,244,372}
                                    },

				 // TODO: Vamsi update the Gen6 specific
                                 5: '{
                                    1:{333,512,655,1167,2191,4239},
                                    2:{224,313,385,641,1153,2177},
                                    4:{169,214,250,378,634,1146},
                                    8:{163,203,182,246,374,630},
                                    12:{154,186,205,290,461,802},
                                    16:{144,168,182,246,374,630},
                                    32:{129,141,148,180,244,372}
                                    },

				 // TODO: REVISIT and update proper values for
				 // Gen7
                                 6: '{
                                    1:{333,512,655,1167,2191,4239},
                                    2:{224,313,385,641,1153,2177},
                                    4:{169,214,250,378,634,1146},
                                    8:{163,203,182,246,374,630},
                                    12:{154,186,205,290,461,802},
                                    16:{144,168,182,246,374,630},
                                    32:{129,141,148,180,244,372}
                                    }

                            };

  //MAX credit calculated for RTL k-wire
  //------------------------------------------------------
  rand int  max_fcph   [0:parameters_cfg_pkg::KMAX_NUM_CIFS-1];
  rand int  max_fcpd   [0:parameters_cfg_pkg::KMAX_NUM_CIFS-1];
  rand int  max_fcnph  [0:parameters_cfg_pkg::KMAX_NUM_CIFS-1];
  rand int  max_fcnpd  [0:parameters_cfg_pkg::KMAX_NUM_CIFS-1];
  rand int  max_fccplh [0:parameters_cfg_pkg::KMAX_NUM_CIFS-1];
  rand int  max_fccpld [0:parameters_cfg_pkg::KMAX_NUM_CIFS-1];
  rand logic [3:0] k_tl_rx_p_np_cpl_fifo_tlp_count;
  rand  bit dllp_fc_err_inj;

  bit ide_init_done;
  bit tdisp_init_done;
  bit cxl_mmio_snoop_test_done;

  bit       first_config_rcvd;

  //---------------------------------------------------------------------------
  // Field: disable_pm_l1_scenario
  // Use this field to disable the PM L1 scenario selection from PM sequence
  //---------------------------------------------------------------------------
  rand bit disable_pm_l1_scenario;

  //---------------------------------------------------------------------------
  // Field: disable_aspm_l0s
  // Use this field to disable the ASPM L0s
  //---------------------------------------------------------------------------
  rand bit disable_aspm_l0s;

  //---------------------------------------------------------------------------
  // Field: disable_aspm_l1
  // Use this field to disable the ASPM L1
  //---------------------------------------------------------------------------
  rand bit disable_aspm_l1;

  //---------------------------------------------------------------------------
  // Field: disable_pm_l2_scenario
  // Use this field to disable the PM L2 scenario from PM Sequence
  //---------------------------------------------------------------------------
  rand bit disable_pm_l2_scenario;

  //---------------------------------------------------------------------------
  // Field: disable_bus_master_mem_io_space_all_function
  // Use this field to disable programming of Bus Master Enable/IO Space
  // Enable/Mem Space Enable of all function
  //---------------------------------------------------------------------------
  rand bit disable_bus_master_mem_io_space_all_function;

  //---------------------------------------------------------------------------
  // Field: disable_PCIE_PL_NONFATAL_BLK_OS_UNK
  // Use this field to disable PCIE_PL_NONFATAL_BLK_OS_UNK error after eieos corruption is done
  //---------------------------------------------------------------------------
  bit disable_PCIE_PL_NONFATAL_BLK_OS_UNK;

  //---------------------------------------------------------------------------
  // Field: vc_disable_val
  // Use this field to disable VCs in DISABLE_VC_DURING_TEST
  //---------------------------------------------------------------------------
  rand bit vc_disable_val[];

  //---------------------------------------------------------------------------
  // Field: flag_vc_disable_val
  // Use this field to indicate that VC disable during test has happened
  //---------------------------------------------------------------------------
  bit flag_vc_disabled_during_test;

  //---------------------------------------------------------------------------
  // Field: m_soma_cpl_timeout_en
  // Use this field to control PCIE_REG_DEN_TLQ_CTRL_ST bit 31 disCplTOrange
  // When set to 1, the completion timeout range defined by the Completion
  // Timeout Mechanism through the configuration space is disabled, and the
  // SOMA parameters (ttoTLCpl and ttoTLCplRx) are used to control the
  // completion timeout.
  // This is particularly useful for controlling the BFM behaviors.
  //---------------------------------------------------------------------------
  rand bit m_soma_cpl_timeout_en;

  //---------------------------------------------------------------------------
  // Field: m_dlf_exchange_en
  // This field controls whether DL Feature will be exchanged between DUT and BFM.
  //---------------------------------------------------------------------------
  rand bit m_dlf_exchange_en;

  //---------------------------------------------------------------------------
  // Field: axi_reg_access_en
  // Use this field to used to enforce register access via AXI transactions
  //---------------------------------------------------------------------------
  bit axi_reg_access_en;

  //---------------------------------------------------------------------------
  // Field: inject_err_en
  // Use this field to enable error injection in HPA TLP (by default sparse error injection)
  //---------------------------------------------------------------------------
  bit inject_err_en;
  bit err_en_from_all_traffic =1;

  //---------------------------------------------------------------------------
  // Field: malform_credit_limit_p
  // Use this field to hold number of malform erros that can be injected in HPA TLP
  // based on credits available at DUT
  //---------------------------------------------------------------------------
  rand longint unsigned malform_credit_limit_p[];

  //---------------------------------------------------------------------------
  // Field: malform_credit_limit_np
  // Use this field to hold number of malform erros that can be injected in HPA TLP
  // based on credits available at DUT
  //---------------------------------------------------------------------------
  rand longint unsigned malform_credit_limit_np[];

  //---------------------------------------------------------------------------
  // Field: malform_credit_limit_cpl
  // Use this field to hold number of malform erros that can be injected in HPA TLP
  // based on credits available at DUT
  //---------------------------------------------------------------------------
  rand longint unsigned malform_credit_limit_cpl[];

  //---------------------------------------------------------------------------
  // Field: cxl_err_retrain_req
  // Use this field to indicate that a CXL injected error would lead to Retraing the Link
  // In case of Link Training a few TLP's can be dropped & NAK is expected to come
  //---------------------------------------------------------------------------
  bit cxl_err_retrain_req;

  //---------------------------------------------------------------------------
  // Field: freq_err
  // Use this field to pass number of errors to be injected randomly
  // Please make sure that this is within 10% of num_tlps
  // HPA TLP item chooses suitable errors randomly based on this number and TLP type
  //---------------------------------------------------------------------------
  rand int freq_err;
  //---------------------------------------------------------------------------
  // Field: mf_err_inj
  // Use this field to enable TLP ecrc error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit ecrc_err_inj;
  //---------------------------------------------------------------------------
  // Field: mf_err_inj
  // Use this field to enable TLP poisoned error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit poisoned_err_inj;
  //---------------------------------------------------------------------------
  // Field: mf_err_inj
  // Use this field to enable TLP malformed error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit mf_err_inj;
  //---------------------------------------------------------------------------
  // Field: ur_err_inj
  // Use this field to enable TLP unsupported error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit ur_err_inj;
  //---------------------------------------------------------------------------
  // Field: posted_rsvd_type_err_inj
  // Use this field to enable TLP unsupported error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit posted_rsvd_type_err_inj;
  //---------------------------------------------------------------------------
  // Field: nonposted_rsvd_type_err_inj
  // Use this field to enable TLP unsupported error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit nonposted_rsvd_type_err_inj;
  //---------------------------------------------------------------------------
  // Field: completion_rsvd_type_err_inj
  // Use this field to enable TLP unsupported error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit completion_rsvd_type_err_inj;
  //---------------------------------------------------------------------------
  // Field: none_rsvd_type_err_inj
  // Use this field to enable TLP unsupported error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit none_rsvd_type_err_inj;
  //---------------------------------------------------------------------------
  // Field: acs_err_inj
  // Use this field to enable TLP ACS error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit acs_err_inj;
  //---------------------------------------------------------------------------
  // Field: cfg_ur_err_inj
  // Use this field to enable TLP CFG UR error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit cfg_ur_err_inj;
  //---------------------------------------------------------------------------
  // Field: tlp_err_inj
  // Use this field to enable TLP error injection in TL layer
  //---------------------------------------------------------------------------
  rand  bit tlp_err_inj;
  //---------------------------------------------------------------------------
  // Field: uio_tlp_err_inj
  // Use this field to enable UIO TLP injection in TL layer.
  //---------------------------------------------------------------------------
  rand  bit uio_tlp_err_inj;
  //---------------------------------------------------------------------------
  // Field: cpl_err_inj
  // Use this field to enable CPL error injection in TL layer.
  // This has to be initiated from OB traffic
  //---------------------------------------------------------------------------
  rand  bit cpl_err_inj;
  //---------------------------------------------------------------------------
  // Field: dlp_err_inj
  // Use this field to enable TLP error injection in DL layer
  //---------------------------------------------------------------------------
  rand  bit dlp_err_inj;
  //---------------------------------------------------------------------------
  // Field: dllp_err_inj
  // Use this field to enable DLLP error injection in DL layer
  //---------------------------------------------------------------------------
  rand  bit dllp_err_inj;
  //---------------------------------------------------------------------------
  // Field: dll_flit_err_inj
  // Use this field to enable DLL FLIT error injection in DL layer
  //---------------------------------------------------------------------------
  rand  bit dll_flit_err_inj;
  //---------------------------------------------------------------------------
  // Field: seq_num_hd_ph_timeout_err
  // Use this field to enable Sequence Number handshake phase timeout error injection in DLL layer
  //---------------------------------------------------------------------------
  rand  bit seq_num_hd_ph_timeout_err;
  //---------------------------------------------------------------------------
  // Field: plp_err_inj
  // Use this field to enable TLP error injection in PL layer
  //---------------------------------------------------------------------------
  rand  bit plp_err_inj;
  //---------------------------------------------------------------------------
  // Field: enable_reporting
  // Use this field to enable error reporting
  //---------------------------------------------------------------------------
  bit enable_err_reporting;
  //---------------------------------------------------------------------------
  // Field: ide_err_inj
  // Use this field to enable IDE error injection in TL layer.
  // This has to be initiated from IB traffic
  //---------------------------------------------------------------------------
  rand  bit ide_err_inj;
  
  //---------------------------------------------------------------------------
  // Field: nop_dbg_flit_supp
  // Use this field is to support nop debug flit TX
  //---------------------------------------------------------------------------
  rand  bit nop_dbg_flit_supp;

  //---------------------------------------------------------------------------
  // Field: nop_vndr_flit_supp
  // Use this field is to support nop vendor flit TX
  //---------------------------------------------------------------------------
  rand  bit nop_vndr_flit_supp;

  //---------------------------------------------------------------------------
  // Field: nop_dbg_flit_en
  // Use this field is to enable nop debug flit TX
  //---------------------------------------------------------------------------
  rand  bit nop_dbg_flit_en;

  //---------------------------------------------------------------------------
  // Field: nop_vndr_flit_en
  // Use this field is to enable nop vendor flit TX
  //---------------------------------------------------------------------------
  rand  bit nop_vndr_flit_en;

  //---------------------------------------------------------------------------
  // Field: m_rx_last_nop_flit_counter
  // Use this field as a RX nop flit counter 
  //---------------------------------------------------------------------------
  bit [31:0] m_rx_last_nop_flit_counter;

  //---------------------------------------------------------------------------
  // Field: m_tx_last_nop_flit_counter
  // Use this field as a TX nop flit counter 
  //---------------------------------------------------------------------------
   bit [31:0] m_tx_last_nop_flit_counter;

 //---------------------------------------------------------------------------
  // Field: m_tx_last_nop_flit_counter
  // Use this field as a TX nop flit counter 
  //---------------------------------------------------------------------------
   bit [7:0] m_curr_tx_nop_dbg_flit [236];


   //---------------------------------------------------------------------------
  // Field:m_curr_rx_nop_dbg_flit_reg
  // Use this field as a RX nop flit counter 
  //---------------------------------------------------------------------------
   bit [7:0] m_curr_rx_nop_dbg_flit_reg [236];


   bit rx_nop_dbg_flit_reg_cleared=1;
   bit [15:0] hold_bfm_nop_debug_flit;


  //------------------------------------------------------------------------------------
  // Field: rx_nop_payload_exp_q
  // This Field is used for rx nop payload in a q
  //------------------------------------------------------------------------------------
  bit [7:0] rx_nop_payload_exp_q[$];

  //---------------------------------------------------------------------------
  // Field: hls_rx
  // Use this field to identify the HLS side for Module level TB
  //---------------------------------------------------------------------------
  bit hls_rx=0;

  //---------------------------------------------------------------------------
  // Field: timeout_150us,timeout_40us
  // These timeouts are used by speed change & link width seq right now.
  // But can be used by any sequence or component
  //---------------------------------------------------------------------------
  time timeout_150us=150;
  time timeout_100us=100;
  time timeout_80us=80;
  time timeout_60us=60;
  time timeout_40us=40;

  //---------------------------------------------------------------------------
  // Field: scenario
  // Used to bring the control knobs to scenariop files
  //---------------------------------------------------------------------------
  cdn_pcie_scenario scenario;
  bit  m_ptc_test_err_scen;
  rand CREDIT_DIST dut_credit_scenario[string];
  rand CREDIT_DIST bfm_credit_scenario[string];
  cdn_pcie_hpa_ide_config ide_cfg; 
  cdn_pcie_hpa_tdisp_config tdisp_cfg; 
  bit m_build_sel_stream;

  cdn_pcie_hpa_asf_config asf_cfg;

  rand bit [7:0] function_num[];
  rand bit rand_func;

  bit is_dev_rand_cfg = 1;
  rand bit apply_for_all_pfs;

  bit is_dut_dut_tb;

  //---------------------------------------------------------------------------
  // Field: reg_access_type
  // Used as a control knob in reg sync file
  //---------------------------------------------------------------------------
  bit       block_next_reg_access;
  bit       m_reg_access_type;
  bit [3:0] m_reg_byte_enable = 'hF;
  bit       m_reg_aliasing_test;
  bit       m_eot_mapped_to_std_reg_tests;
  bit       m_std_reg_tests_with_link;
  bit       m_std_reg_tests_with_axil;
  bit       m_std_reg_tests_with_apb;

  bit assign_seq_mem;
  rand bit m_override_ips_bar_size;

  // Intx Variables
  rand bit [3:0]  m_intr_pins;
  rand bit [3:0]  dis_intr;
  rand bit        intx_pin_or_hls;
  rand bit        intx_pin_b2b;
  rand bit        msi_msix_pin_b2b;
  rand bit        intx_ib_b2b;
  bit      [3:0]  intx_pin_assert;
  int unsigned    intx_cntr;  
  bit      [3:0]  intx_pin_ib_assert;
  bit      [3:0]  intx_pin_ib_deassert;
  int unsigned    intx_a_cntr;
  int unsigned    intx_b_cntr;
  int unsigned    intx_c_cntr;
  int unsigned    intx_d_cntr;
  rand bit [5:0]  tph_st_table_index;

  int func_num;
  rand int pf_func_num;
  rand int vf_func_num;

  //---------------------------------------------------------------------------
  // Field : m_msi_bar_32
  // This field controls MWr_32/MWr_64 for MSI/MSIX
  //---------------------------------------------------------------------------
  rand bit m_msi_bar_32;

  //---------------------------------------------------------------------------
  // Field : m_read_all_reg
  // This field controls Read all register at the end of test 
  //---------------------------------------------------------------------------
  rand bit m_read_all_reg;

  //---------------------------------------------------------------------------
  // Field : m_cfg_read_reg
  // This field controls Read all register at the end of test from link/client
  //---------------------------------------------------------------------------
  rand bit m_cfg_read_reg;

  //---------------------------------------------------------------------------
  // Field : m_num_link_down_by_2
  // This field controls the Number of link down reset in a single run
  // For divide by 2
  //---------------------------------------------------------------------------
  rand bit [4:0]  m_num_link_down_by_2;

  //---------------------------------------------------------------------------
  // Field : m_num_link_down_by_4
  // This field controls the Number of link down reset in a single run
  // For divide by 4
  //---------------------------------------------------------------------------
  rand bit [4:0]  m_num_link_down_by_4;

  //---------------------------------------------------------------------------
  // Field : m_num_link_down_by_8
  // This field controls the Number of link down reset in a single run
  // For divide by 8
  //---------------------------------------------------------------------------
  rand bit [4:0]  m_num_link_down_by_8;

  //---------------------------------------------------------------------------
  // Field : m_link_down_in_L0
  // This field controls the link down in L0 or non L0 state
  //---------------------------------------------------------------------------
  rand bit m_link_down_in_L0;


  //---------------------------------------------------------------------------
  //Field : m_pf_vf_map
  // This field controls the fine allocation of VFs to each PFs
  //---------------------------------------------------------------------------
  rand bit [15:0] m_pf_vf_map[parameters_cfg_pkg::KMAX_NUM_PFS];

  rand cdn_pcie_hpa_top_config_base_policy #(cdn_pcie_hpa_dev_top_config) pcy_q[$];


  cdn_pcie_strap_top_config                  i_cfg;
  rand cdn_hpa_pcie_port_type_t              m_port_type;

  rand cdn_hpa_pcie_tlp_requester_id_s       m_rp_req_id;
  rand cdn_hpa_pcie_tlp_requester_id_s       m_ep_req_id;
  rand cdn_hpa_pcie_tlp_requester_id_s       m_req_id;

  rand cdn_hpa_pcie_pri_sec_sub_bus_s        m_rp_pri_sec_sub_bus;
  rand cdn_hpa_pcie_pri_sec_sub_bus_s        m_usp_pri_sec_sub_bus;

  bit [2:0]                                  k_pcie_rate_max; //Get the strap gen speed. Temp this gets values from dev_env
  bit [2:0]                                  strap_pcie_rate_max; //Get the strap gen speed. Temp this gets values from dev_env
  bit [2:0]                                  k_max_read_request_size;
  bit [31:0]				     reg_val;
  rand bit [1:0]                             m_aspm_supp;
  rand bit [2:0]                             m_max_payload_size;
  rand bit                                   m_same_payload_size;
  rand bit                                   rx_mps_fixed;
  rand bit                                   mixed_mps_supported;
  rand bit                                   mixed_mps_en; // Global enable

//  rand bit [2:0]  m_max_rd_req_size;
//  rand int        m_max_rd_req_size_dw;
//  rand int        m_max_rd_req_size_bytes;


  //DL config
  rand bit                                   k_replay_ctrl_info_in_ram;
  rand bit [4:0]                             k_replay_buffer_data_ram_depth;
  rand bit [4:0]                             k_replay_buffer_ctrl_ram_depth;
  rand bit                                   k_ram_read_latency;

  bit[7:0]                                  compliance_enter_num;  //used for compliance pattern coverage
  rand bit[1:0]                             delay_sync_signal;
  bit                                       del_sync_signal_en;
  bit                                       enable_retimer_eq;

  bit                                       en_long_run_comp;
  rand bit                                  enable_ide;
  bit                                       non_ide_traffic_test;
  bit                                       non_cxl_ide_traffic_test;

  bit                                       enable_loopback;
  bit                                       en_loopback;
  bit                                       en_loopback_b4_linkup;
  bit                                       en_full_delay_sim;
  bit                                       lpk_comp_b4_linkup_count; 
  bit                                       disable_NLS_check; //To disable speed change test in compliance  
  bit                                       disable_NAK_check_cxl_mode; //To disable NAK check in CXL mode 
  bit                                       disable_NAK_check_cxl_mode_err_test; //To disable NAK check in CXL mode 
  bit                                       disable_NAK_check_cxl_mode_non_err_test; //To disable NAK check in CXL mode 
  
  rand bit                                  lpk_mst_sl; //loopback  master or slave selection for loopback entery before linkup
  //-----------------------------------------------------------------------
  // VIP DL Soma parameter
  //-----------------------------------------------------------------------
  rand bit                                   RelativeOrderOnlyInitDllps;
  rand int                                   DLretBuf;
  rand int                                   DlTxQueueDelay;
  rand int                                   DlRxQueueDelay;
  rand int                                   redundantInitFc2Dllps;
  rand int                                   redundantInitFc1Dllps;
  rand int                                   newTlpsAllowedAfterRxNak;
  rand int                                   DlIncrReplayNumWhenNakReplay;
  rand bit                                   useDefaultTxL0sAdjustment;
  rand bit                                   useDefaultRxL0sAdjustment;
  rand bit                                   dlMustSendInitFC2;
  rand int                                   maxSameFC;
  rand bit                                   collapseDLNakAckReplay;
  rand bit                                   dlSetLkRetrain; //it has to be 1.
  rand bit                                   collapseDLNakAckReplayTimeout;
  rand bit                                   txWholeInitFCGroup;

  //-----------------------------------------------------------------------
  //VIP DL register
  //-----------------------------------------------------------------------
  rand bit                                    enPCIPM_L1_2;
  rand bit                                    enPCIPM_L1_1;
  rand bit                                    enASPM_L1_2;
  rand bit                                    enASPM_L1_1;
  rand bit [1:0]                              powerOnScale;
  rand bit [4:0]                              powerOnValue;
  rand bit                                    GotoReset; //Need to check
  rand bit                                    retryNPReq;//need to check
  rand bit [31:0]                             Retry_Buffer_Size;
  rand bit                                    m_block_tlp;
  rand bit                                    m_block_dllp;
  rand bit                                    ignoreUserDllp;
  rand bit                                    ignorePME;
  rand bit                                    unreliableLink;
  rand bit                                    RejectL1SubState;
  rand bit [1:0]                              CLKREQ;
  //PCIE_REG_DEN_LINK_CTRL_2
  rand bit                                    m_bfm_assertClkreq;
  rand bit                                    m_bfm_clkreqL1;
  rand bit                                    m_bfm_clkreqL1Auto;
  rand bit                                    m_bfm_clkreqL2;
  rand bit                                    m_bfm_clkreqL2Auto;
  rand bit                                    randomTlpDllp;
  rand bit                                    ignoreBlkStpSdp;

  rand bit                                    m_bfm_noUpdateFC;
  rand bit                                    m_bfm_fastUpdateFC;
  rand bit[15:0]                              m_bfm_updateFC_timerVal[8][0:5];
  rand bit                                    m_bfm_disPclkOnL12Idle;
  //PCIE_REG_DEN_EQ_CTRL_ST
  rand bit                                    m_bfm_blockInitFC;
  //PCIE_REG_DEN_DLQ_DELAY
  rand bit [15:0]                             m_bfm_txDelay;
  rand bit [15:0]                             m_bfm_rxDelay;

  //------------------------------------------------------------------------
  //Disabling LM Register Programming
  //------------------------------------------------------------------------
  // disable all lm register programming (Generic IP Register Bank)
  rand bit                                    dis_all_lm_prog;
  // disable all cpcs lm register programming (CPCS IP Registers)
  rand bit                                    dis_cpcs_lm_prog;
  // disable all cxl lm register programming (CXL IP Registers)
  rand bit                                    dis_cxl_lm_prog;
  // disable all hls lm register programming (HLS IP Registers)
  rand bit                                    dis_hls_lm_prog;
  // disable all tl lm register programming (Transaction Layer IP Registers)
  rand bit                                    dis_tl_lm_prog;
  // disable all dl lm register programming (Data Link Layer IP Registers)
  rand bit                                    dis_dl_lm_prog;
  // disable all pl lm register programming (Physical Layer IP Registers)
  rand bit                                    dis_pl_lm_prog;
  // disable all cmn lm register programming (Common IP Registers)
  rand bit                                    dis_cmn_lm_prog;
  // disable all link down related fields in lm register programming
  rand bit                                    dis_linkdown_lm_prog;
  // disable all flr related fields in lm register programming
  rand bit                                    dis_flr_lm_prog;
  // disable all order check related fields in lm register programming
  rand bit                                    dis_order_check_lm_prog;
  // disable all errors related fields in lm register programming
  rand bit                                    dis_error_lm_prog;
  // disable all ur errors related fields in lm register programming
  rand bit                                    dis_ur_error_lm_prog;
  // disable all malformed erros related fields in lm register programming
  rand bit                                    dis_malformed_error_lm_prog;
  // disable all cpl related fields in lm register programming
  rand bit                                    dis_cpl_lm_prog;
  // disable all arbitration related fields in lm register programming
  rand bit                                    dis_arbitration_lm_prog;
  // disable all fc timeout related fields in lm register programming
  rand bit                                    dis_fc_timeout_lm_prog;
  // disable all credit update related fields in lm register programming
  rand bit                                    dis_credit_upd_lm_prog;
  // disable all idg map related fields in lm register programming
  rand bit                                    dis_idg_map_lm_prog;
  // disable all initfc delay related fields in lm register programming
  rand bit                                    dis_initfc_delay_lm_prog;
  // disable all replay timeout related fields in lm register programming
  rand bit                                    dis_replay_timeout_lm_prog;
  // disable all dl feature timeout related fields in lm register programming
  rand bit                                    dis_timeout_dl_feature_lm_prog;
  // disable all ltr_msg_ctrl_reg related fields in lm register programming
  rand bit                                    dis_ltr_msg_ctrl_lm_prog;

  //------------------------------------------------------------------------
  //DUT IP register, should be programmed through LM
  //------------------------------------------------------------------------

  //i_dl_fm_control regster
  //------------------------------------------------------------------------
  rand bit                                    m_def_nak_sch_type;
  rand bit                                    m_cont_with_sel_Nak;
  rand bit [6:0]                              m_Nak_ignore_window;
  rand bit                                    m_dllp_payload_int;

  //i_dl_control_0 regster
  //------------------------------------------------------------------------
  rand bit[15:0]                              m_replay_timeout_limit_val;
  rand bit[15:0]                              m_ack_nak_latency_timer_limit;

  //------------------------------------------------------------------------
  //i_dl_control_1 regster
  //------------------------------------------------------------------------
  rand bit[15:0]                              m_dl_feature_dllps_tx_timer;

  //------------------------------------------------------------------------
  //i_dl_status regster (Read Only)
  //------------------------------------------------------------------------
  bit                              replay_ram_uncorr_err;
  bit                              replay_ram_corr_err;
  bit                              replay_ctrl_ram_uncorr_err;
  bit                              replay_ctrl_ram_corr_err;
  bit                              e2e_parity_chk_fail_dl_tx;
  bit                              e2e_parity_chk_fail_dl_rx;

  //------------------------------------------------------------------------
  //i_dl_replay_ram_err_addr regster (Read Only)
  //------------------------------------------------------------------------
  bit [31:0]                       replay_ram_uncorr_corr_addr;

  //------------------------------------------------------------------------
  //i_dl_replay_ctrl_ram_err_addr regster (Read Only)
  //------------------------------------------------------------------------
  bit [31:0]                       replay_ctrl_ram_uncorr_corr_addr;

  //i_dl_feature_cap regster
  //------------------------------------------------------------------------
  bit                              m_local_scaled_flow_ctrl_sup;

  //------------------------------------------------------------------------
  //i_dl_feature_status regster
  //------------------------------------------------------------------------
  bit                              m_remote_scaled_flow_ctrl_sup;

  //------------------------------------------------------------------------
  //i_initfc_delay regster
  //------------------------------------------------------------------------
  rand bit [15:0]                   delay_between_two_initfcs;

  //------------------------------------------------------------------------
  //i_rx_dllp_cnt_g1 regster
  //------------------------------------------------------------------------
  bit [31:0]                        rx_dllp_count_in_gen1;

  //------------------------------------------------------------------------
  //i_rx_dllp_cnt_g2 regster
  //------------------------------------------------------------------------
  bit [31:0]                        rx_dllp_count_in_gen2;

  //------------------------------------------------------------------------
  //i_rx_dllp_cnt_g3 regster
  //------------------------------------------------------------------------
  bit [31:0]                        rx_dllp_count_in_gen3;

  //------------------------------------------------------------------------
  //i_rx_dllp_cnt_g4 regster
  //------------------------------------------------------------------------
  bit [31:0]                        rx_dllp_count_in_gen4;

  //------------------------------------------------------------------------
  //i_rx_dllp_cnt_g5 regster
  //------------------------------------------------------------------------
  bit [31:0]                        rx_dllp_count_in_gen5;

  //------------------------------------------------------------------------
  //i_rx_lcrc_err_cnt regster
  //------------------------------------------------------------------------
  bit [31:0]                        rx_lcrc_err_cnt;

  //------------------------------------------------------------------------
  //i_tx_dllp_cnt_g1 regster
  //------------------------------------------------------------------------
  bit [31:0]                        tx_dllp_count_in_gen1;

  //------------------------------------------------------------------------
  //i_tx_dllp_cnt_g2 regster
  //------------------------------------------------------------------------
  bit [31:0]                        tx_dllp_count_in_gen2;

  //------------------------------------------------------------------------
  //i_tx_dllp_cnt_g3 regster
  //------------------------------------------------------------------------
  bit [31:0]                        tx_dllp_count_in_gen3;

  //------------------------------------------------------------------------
  //i_tx_dllp_cnt_g4 regster
  //------------------------------------------------------------------------
  bit [31:0]                        tx_dllp_count_in_gen4;

  //------------------------------------------------------------------------
  //i_tx_dllp_cnt_g5 regster
  //------------------------------------------------------------------------
  bit [31:0]                        tx_dllp_count_in_gen5;

  //------------------------------------------------------------------------
  //i_dlcmsm_st regster
  //------------------------------------------------------------------------
  bit [3:0]                        dlcmsm_state_encoding;

  //------------------------------------------------------------------------
  //i_init_fc_state regster
  //------------------------------------------------------------------------
  bit [3:0]                        init_fc_st_vc0;
  bit [3:0]                        init_fc_st_vc1;
  bit [3:0]                        init_fc_st_vc2;
  bit [3:0]                        init_fc_st_vc3;
  bit [3:0]                        init_fc_st_vc4;
  bit [3:0]                        init_fc_st_vc5;
  bit [3:0]                        init_fc_st_vc6;
  bit [3:0]                        init_fc_st_vc7;

  //------------------------------------------------------------------------
  //i_pm_state regster
  //------------------------------------------------------------------------
  bit [4:0]                        pwr_mgmt_state;

  //------------------------------------------------------------------------
  //i_pcie_cap_list regster
  //------------------------------------------------------------------------
  bit                              flit_mode_supported;
  bit                              flit_mode_supported_temp;
  //------------------------------------------------------------------------
  //local_flit_mode_enable
  //------------------------------------------------------------------------
  rand bit                              local_flit_mode_enable;

  bit                              lm_write_flit_mode_support;    
  // APIS using array reduction -to get error control knobs

  cdn_hpa_pcie_dev_config pf_config[int];
  cdn_hpa_pcie_dev_config vf_config[int][int];

  //Field: m_ep_dev_bar_info
  bars_per_device                     m_ep_dev_bar_info;
  //Field: m_rp_dev_bar_info
  bars_per_device                     m_rp_dev_bar_info;

  // Vamsi Cross check  - post all the cheker implementation review the below
  // TODO: Do we really need check bits(HTBC/HTBCS) ? - Can we have the checks directly
  // on the register model read values
  // How do we do the cross coverae and transition coverage??
  // Can we have any checks between two registers ???
  // If these fileds are not used in the checks review and delete later

  //------------------------------------------------------------------------
  // Link Capabilities Register
  //------------------------------------------------------------------------
  //Field: m_max_link_speed
   rand bit [3:0]                    m_max_link_speed;

   cdn_hpa_link_speed_e         m_user_bfm_max_link_speed = GEN_0;
  //Field: m_max_link_width
   rand bit [5:0]                    m_max_link_width;
  //Field: m_dl_link_act_reporting_cap
   rand bit                          m_dl_link_act_reporting_cap; //dlActRepCap "for downstream port it is set to 0"
  //Field: m_link_bw_notification_cap
   rand bit                          m_link_bw_notification_cap; //dlActRepCap "for downstream port it is set to 0"
  //------------------------------------------------------------------------
  // Link Control Register
  //------------------------------------------------------------------------
  rand bit              m_ext_sync; //Make common across all PFs and across devices
  rand bit              m_rcb;
  rand bit              m_sris_clocking; //
  rand bit              m_flit_mode_disable; //

  rand bit [6:0]                    m_bfm_downgraded_rate;
  // HTBM
  //Not configured initially,Configured when Link Disable is required
  //Field: m_link_disable
  bit                   m_link_disable;
  // HTBM
  //Not configured initially,Configured while re-training link

  //Field: m_retrain_link
  bit                   m_retrain_link;   // VHTBM
  //Field: m_hw_auto_width_disable
  rand bit              m_hw_auto_width_disable;
  //Field: m_link_bw_mgmt_intr_en
  rand bit              m_link_bw_mgmt_intr_en;
  //Field: m_link_auto_bw_intr_en
  rand bit              m_link_auto_bw_intr_en;
  //Field: m_drs_sig_ctrl
  rand bit [1:0]        m_drs_sig_ctrl;

  //------------------------------------------------------------------------
  // Link Status Register
  //------------------------------------------------------------------------
  // HTBC
  //Field: m_curr_link_speed
  bit                  m_curr_link_speed;
  // HTBC
  //Field: m_neg_link_width
  bit                  m_neg_link_width;
  // HTBC
  //Field: m_link_training
  bit                  m_link_training;
  //Field: m_slt_clk_config
  bit                  m_slt_clk_config;
  // HTBC
  //Field: m_dl_link_active
  bit                  m_dl_link_active;
  // HTBC
  //Field: m_link_bw_mgmt_status
  bit                  m_link_bw_mgmt_status;
  // HTBC
  //Field: m_link_auto_bw_status
  bit                  m_link_auto_bw_status;

  bit                  malform_tlp_stat;

  //------------------------------------------------------------------------
  // Slot Capabilities Register : HWINIT
  //------------------------------------------------------------------------
  rand bit             m_atten_button_present;
  rand bit             m_pwr_ctrl_present;
  rand bit             m_mrl_sensor_present;
  rand bit             m_atten_indicator_present;
  rand bit             m_power_indicator_present;
  rand bit             m_hotplug_surprise;
  rand bit             m_hotplug_cap;
  rand bit[7:0]        m_slot_power_limit_val;
  rand bit[2:0]        m_slot_pwer_limit_scale;
  rand bit             m_electro_mechcl_intrlk_present;
  rand bit             m_no_command_completed_sup;
  rand bit             m_physical_slot_number;

  //------------------------------------------------------------------------
  // PCIE Config Space registers
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Slot Control Register
  //------------------------------------------------------------------------
  rand bit             m_attentn_button_pressd_en;
  rand bit             m_pwr_fault_detected_en;
  rand bit             m_mrl_sensor_changed_en;
  rand bit             m_presence_detect_changed_en;
  rand bit             m_command_completd_interrupt_en;
  rand bit             m_hot_plug_interrupt_en;
  rand bit[1:0]        m_attentn_indicator_ctrl;
  rand bit[1:0]        m_power_indicator_ctrl;
  rand bit             m_pwr_controller_ctrl;
  rand bit/*[1:0]*/    m_electro_mechcl_intrlk_ctrl;
  rand bit             m_dl_state_change_enable; //vip parameter :dlChgEn
  rand bit             m_auto_slot_power_limit_disable;
  rand bit             m_in_band_pd_disable;

  //------------------------------------------------------------------------
  // Slot Status Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Root Control Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Root Capabilities Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Root Status Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Link Capabilities 2 Register
  //------------------------------------------------------------------------
  // Field: m_supp_link_speeds_vector
  rand bit [4:0]       m_supp_link_speeds_vector;
  // Field: m_cross_link_supp
  rand bit             m_cross_link_supp;
  // Field: m_lower_skp_os_gen_supported_speeds_vector
  rand bit [6:0]       m_lower_skp_os_gen_supported_speeds_vector_supp;
  // Field: m_lower_skp_os_reception_supported_speeds_vector
  rand bit [6:0]       m_lower_skp_os_reception_supported_speeds_vector_supp;
  // Field: m_retimer_presence_detected_supp
  rand bit             m_retimer_presence_detected_supp;
  // Field: m_two_retimers_presence_detected_supp
  rand bit             m_two_retimers_presence_detected_supp;
  // Field: enable_vip_as_retimer
  rand bit             enable_vip_as_retimer;
  // Field: enable_vip_margin_par
  rand bit             enable_vip_margin_par;

  // Field: m_drs_supp
  rand bit  [2:0]      m_drs_supp;

  //------------------------------------------------------------------------
  // Flit Performance Measurement Control Register : i_flit_perf_measr_ctrl_reg
  //------------------------------------------------------------------------
  
  rand bit       flit_latency_measurement_enable;
  rand bit [2:0] flit_response_type;
  rand bit [4:0] track_num_flit;
  rand bit [2:0] delay_to_trigger_interrupt;

  //------------------------------------------------------------------------
  //------------------------------------------------------------------------
  // Link Control 2 Register
  //------------------------------------------------------------------------

  // Field: m_target_link_speed
  bit [3:0]       m_target_link_speed;
  // Field: m_enter_compliance
  bit             m_enter_compliance;
  // Field: m_hw_auto_speed_disable
  bit             m_hw_auto_speed_disable;
  // Field: m_selectable_deemph
  rand bit             m_selectable_deemph;
  // Field: m_transmit_margin
  rand bit  [2:0]      m_transmit_margin;
  // Field: m_enter_mod_compliance
  bit             m_enter_mod_compliance;
  // Field: m_compliance_sos
  rand bit             m_compliance_sos;
  // Field: m_compliance_preset_deemphasis
  rand bit  [3:0]      m_compliance_preset_deemphasis;

  //------------------------------------------------------------------------
  // Link Status 2 Register
  //------------------------------------------------------------------------
  // Field: m_current_deemp_level
  bit                  m_current_deemp_level;
  // Field: m_eq_8G_complete
  bit                  m_eq_8G_complete;
  // Field: m_eq_8G_ph1_complete
  bit                  m_eq_8G_ph1_complete;
  // Field: m_eq_8G_ph2_complete
  bit                  m_eq_8G_ph2_complete;
  // Field: m_eq_8G_ph3_complete
  bit                  m_eq_8G_ph3_complete;
  // Field: m_link_eq_req_8G
  bit                  m_link_eq_req_8G;
  // Field: m_ret_presence_det
  bit                  m_ret_presence_det;
  // Field: m_two_ret_presence_det
  bit                  m_two_ret_presence_det;
  // Field: m_crosslink_resolution
  bit [1:0]            m_crosslink_resolution; //not supported
  // Field: m_dsp_comp_presence
  bit [2:0]            m_dsp_comp_presence; //applicable only for rp
  // Field: m_drs_msg_received
  bit [2:0]            m_drs_msg_received; //applicable only for rp

  //------------------------------------------------------------------------
  // Slot Capabilities 2 Register
  //------------------------------------------------------------------------
  // HTBCRSVD
rand bit               m_in_band_pd_disable_supp;
  //------------------------------------------------------------------------
  // Slot Control 2 Register
  //------------------------------------------------------------------------
  // HTBCRSVD

  //------------------------------------------------------------------------
  // Slot Status 2 Register
  //------------------------------------------------------------------------
  // HTBCRSVD

  //------------------------------------------------------------------------
  // Secondary PCI Express Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_sec_pcie_ext_cap;

  // Applicable at link speed 8GT or higher
  // NOTE : check for any negetive testing ??
  rand bit   m_cap_secondary_ext_supp;

  //------------------------------------------------------------------------
  // Link Control 3 Register
  //------------------------------------------------------------------------
  bit          m_perform_eq;
  // HTBC
  bit          m_link_eq_req_intrpt_en;
  rand bit [6:0]    m_en_lower_skp_gen;

  //------------------------------------------------------------------------
  // Lane Error Status Register
  //------------------------------------------------------------------------
  // HTBCW1C - Need to check the error status
  bit [31:0]        m_lane_err_sts;

  //------------------------------------------------------------------------
  // Lane Equalization Control Register
  //------------------------------------------------------------------------
  // All the below fields are based on number of lanes
  rand bit [3:0] m_dsp_8gt_tx_preset[];
  rand bit [2:0] m_dsp_8gt_rx_preset_hint[];
  rand bit       m_lane_eq_rsvd0;
  rand bit [3:0] m_usp_8gt_tx_preset[];
  rand bit [2:0] m_usp_8gt_rx_preset_hint[];
  rand bit       m_lane_eq_rsvd1;

  bit  [3:0]     cov_dsp_8gt_tx_preset; //used for functional coverage
  bit  [2:0]     cov_dsp_8gt_rx_preset_hint; //used for functional coverage
  bit  [3:0]     cov_usp_8gt_tx_preset; //used for functional coverage
  bit  [2:0]     cov_usp_8gt_rx_preset_hint; //used for functional coverage

  //------------------------------------------------------------------------
  // Data Link Feature Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_dl_feature_ext_cap;

  // Data Link Feature Capabilities Register

  rand bit         m_local_dl_feature_supp;
  bit [2:0]        m_local_extended_vc_count;
  bit [2:0]        m_local_l0p_exit_latency;
  bit              l0p_neg_ongoing;

  rand bit [20:0]  m_dl_feature_rsvd0;

  // TODO check can we randomize some of the HwInit Register fileds throgh LM
  // HTBM
  rand bit         m_dl_feature_exchange_en;
  rand bit         m_local_immediate_readiness;

  //------------------------------------------------------------------------
  // Data Link Feature Status Register
  //------------------------------------------------------------------------
  bit [22:0]       m_remote_dl_feature_supp;
  bit              m_remote_dl_feature_supp_valid;
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Physical Layer 16.0 GT/s Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_pl_16gt_ext_cap;


  //------------------------------------------------------------------------
  // 16.0 GT/s Capabilities Register (All RSVD fields)
  //------------------------------------------------------------------------
  // HTBCRSVD

  //------------------------------------------------------------------------
  // 16.0 GT/s Control Register
  //------------------------------------------------------------------------
  // HTBCRSVD

  //------------------------------------------------------------------------
  // 16.0 GT/s Status Register
  //------------------------------------------------------------------------
  // HTBCS
  bit             m_eq_16gt_complete;
  bit             m_eq_16gt_phase1_success;
  bit             m_eq_16gt_phase2_success;
  bit             m_eq_16gt_phase3_success;
  // HTBCW1CS - TODO
  bit             m_link_eq_req_16gt;

  //------------------------------------------------------------------------
  // 16.0 GT/s Local Data Parity Mismatch Status Register
  //------------------------------------------------------------------------
  // HTBC - Write cover point based on number of lanes applicable [15:0] is max
  bit [31:0]     m_local_data_parity_mismatch_sts;

  //------------------------------------------------------------------------
  // 16.0 GT/s First Retimer Data Parity Mismatch Status Register
  //------------------------------------------------------------------------
  // HTBC - Write cover point based on number of lanes applicable [15:0] is max
  bit [31:0]     m_first_retimer_data_parity_mismatch_sts;

  //------------------------------------------------------------------------
  // 16.0 GT/s Second Retimer Data Parity Mismatch Status Register
  //------------------------------------------------------------------------
  // HTBC - Write cover point based on number of lanes applicable [15:0] is max
  bit [31:0]     m_second_retimer_data_parity_mismatch_sts;

  //------------------------------------------------------------------------
  // Physical Layer 16.0 GT/s Reserved
  //------------------------------------------------------------------------
  // HTBCRSVD

  //------------------------------------------------------------------------
  // 16.0 GT/s Lane Equalization Control Register
  //------------------------------------------------------------------------
  //Field: m_dsp_16gt_tx_preset
  rand bit [3:0] m_dsp_16gt_tx_preset[];
  //Field: m_usp_16gt_tx_preset
  rand bit [3:0] m_usp_16gt_tx_preset[];

  //Field: cov_dsp_16gt_tx_preset
  bit  [3:0]     cov_dsp_16gt_tx_preset; //used for functional coverage
  //Field: cov_usp_16gt_tx_preset
  bit  [3:0]     cov_usp_16gt_tx_preset; //used for functional coverage

  //------------------------------------------------------------------------
  // Physical Layer 32.0 GT/s Extended Capability
  //------------------------------------------------------------------------
  //Field: m_cap_pl_32gt_ext_cap
  cdn_pcie_reg_base      m_cap_pl_32gt_ext_cap;

  //------------------------------------------------------------------------
  // Physical Layer 32.0 GT/s Extended Capability Header
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // 32.0 GT/s Capabilities Register
  //------------------------------------------------------------------------
  // HTBC
  rand bit               m_eq_bypass_to_highest_rate_supp;
  rand bit               m_no_eq_need_supp;
  rand bit  [5:0]        m_32gt_cap_rsvd0;
  rand bit               m_modifed_ts_mode0_supp;
  rand bit               m_modifed_ts_mode1_supp_tsm;
  rand bit               m_modifed_ts_mode2_supp_apn;
  rand bit  [4:0]        m_modifed_ts_rsvd_mode_supp;
  rand bit  [15:0]       m_32gt_cap_rsvd1;

  //------------------------------------------------------------------------
  // 32.0 GT/s Control Register
  //------------------------------------------------------------------------
  // HTBCS
  rand bit               m_eq_bypass_to_highest_rate_disable;
  // HTBCS
  rand bit               m_noeq_needed_disable;
  // HTBCS
  rand bit  [5:0]        m_32gt_ctrl_rsvd0;
  // HTBCS
  rand bit  [2:0]        m_modified_tsusage_mode_sel;
  // HTBCS
  rand bit  [21:0]       m_32gt_ctrl_rsvd1;


  //------------------------------------------------------------------------
  // 32.0 GT/s Status Register
  //------------------------------------------------------------------------
  // HTBCS
  bit             m_eq_32gt_complete;
  bit             m_eq_32gt_phase1_success;
  bit             m_eq_32gt_phase2_success;
  bit             m_eq_32gt_phase3_success;
  // HTBCW1CS - TODO
  bit             m_link_eq_req_32gt;
  // HTBC
  bit             m_modified_ts_rsvd;
  bit [1:0]       m_rsvd_enhanced_link_behaviorr_ctrl;
  bit             m_tx_precoding_on;
  rand bit        m_tx_precoding_req;
  bit             m_no_eq_needed_rcvd;

 //------------------------------------------------------------------------
  // 32.0 GT/s Status Register
  //------------------------------------------------------------------------
  // HTBCS
  bit             m_eq_32gt_complete;
  bit             m_eq_32gt_phase1_success;
  bit             m_eq_32gt_phase2_success;
  bit             m_eq_32gt_phase3_success;
  // HTBCW1CS - TODO
  bit             m_link_eq_req_32gt;
  // HTBC
  bit             m_modified_ts_rsvd;
  bit [1:0]       m_rsvd_enhanced_link_behaviorr_ctrl;
  bit             m_tx_precoding_on;
  rand bit        m_tx_precoding_req;
  bit             m_no_eq_needed_rcvd;

  //------------------------------------------------------------------------
  // Received Modified TS Data 1 Register
  //------------------------------------------------------------------------
  // HTBC
  bit [2:0]   m_rx_modified_ts_use_mode;
  bit [12:0]  m_rx_modified_ts_info1;
  bit [12:0]  m_rx_modified_ts_vendor_id;


  //------------------------------------------------------------------------
  // Received Modified TS Data 2 Register
  //------------------------------------------------------------------------
  // HTBC
  bit [23:0]  m_rx_modified_ts_info2;
  bit [1:0]   m_rx_apn_sts;

  //------------------------------------------------------------------------
  // Transmitted Modified TS Data 1 Register
  //------------------------------------------------------------------------
  // HTBC
  bit [2:0]   m_tx_modified_ts_use_mode;
  bit [12:0]  m_tx_modified_ts_info1;
  bit [12:0]  m_tx_modified_ts_vendor_id;

  //------------------------------------------------------------------------
  // Transmitted Modified TS Data 2 Register
  //------------------------------------------------------------------------
  bit [23:0]  m_tx_modified_ts_info2;
  bit [1:0]   m_tx_apn_sts;

  //------------------------------------------------------------------------
  // 32.0 GT/s Lane Equalization Control Register
  //------------------------------------------------------------------------
  rand bit [3:0] m_dsp_32gt_tx_preset[];
  rand bit [3:0] m_usp_32gt_tx_preset[];

  rand bit [3:0] cov_dsp_32gt_tx_preset;  //used for functional coverage
  rand bit [3:0] cov_usp_32gt_tx_preset;  //used for functional coverage

  //------------------------------------------------------------------------
  // Physical Layer 64.0 GT/s Extended Capability
  //------------------------------------------------------------------------
  //Field: m_cap_pl_64gt_ext_cap
  cdn_pcie_reg_base      m_cap_pl_64gt_ext_cap;


  cdn_pcie_reg_base      m_cap_flit_log_ext_cap;

  cdn_pcie_reg_base      m_cap_flit_perf_measr_ext_cap;

  cdn_pcie_reg_base      m_cap_flit_err_inj_ext_cap;

  //------------------------------------------------------------------------
  // Physical Layer 64.0 GT/s Extended Capability Header
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // 64.0 GT/s Capabilities Register
  //------------------------------------------------------------------------


  //------------------------------------------------------------------------
  // 64.0 GT/s Control Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // 64.0 GT/s Status Register
  //------------------------------------------------------------------------
  // HTBCS
  bit             m_eq_64gt_complete;
  bit             m_eq_64gt_phase1_success;
  bit             m_eq_64gt_phase2_success;
  bit             m_eq_64gt_phase3_success;
  // HTBCW1CS - TODO
  bit             m_link_eq_req_64gt;
  // HTBC
  bit             m_64gt_tx_precoding_on;
  rand bit        m_64gt_tx_precoding_req;
  bit             m_64gt_no_eq_needed_rcvd;

  //------------------------------------------------------------------------
  // 64.0 GT/s Lane Equalization Control Register
  //------------------------------------------------------------------------
  rand bit [3:0] m_dsp_64gt_tx_preset[];
  rand bit [3:0] m_usp_64gt_tx_preset[];

  rand bit [3:0] cov_dsp_64gt_tx_preset;  //used for functional coverage
  rand bit [3:0] cov_usp_64gt_tx_preset;  //used for functional coverage

  `ifdef PCIE_GEN7
  //------------------------------------------------------------------------
  // Physical Layer 128.0 GT/s Extended Capability
  //------------------------------------------------------------------------
  //Field: m_cap_pl_128gt_ext_cap
  cdn_pcie_reg_base      m_cap_pl_128gt_ext_cap;

  //------------------------------------------------------------------------
  // Physical Layer 128.0 GT/s Extended Capability Header
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // 128.0 GT/s Capabilities Register
  //------------------------------------------------------------------------


  //------------------------------------------------------------------------
  // 128.0 GT/s Control Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // 128.0 GT/s Status Register
  //------------------------------------------------------------------------
  // HTBCS
  bit             m_eq_128gt_complete;
  bit             m_eq_128gt_phase1_success;
  bit             m_eq_128gt_phase2_success;
  bit             m_eq_128gt_phase3_success;
  // HTBCW1CS - TODO
  bit             m_link_eq_req_128gt;
  // HTBC
  bit             m_128gt_tx_precoding_on;
  rand bit        m_128gt_tx_precoding_req;
  bit             m_128gt_no_eq_needed_rcvd;

  //------------------------------------------------------------------------
  // 128.0 GT/s Lane Equalization Control Register
  //------------------------------------------------------------------------
  rand bit [3:0] m_dsp_128gt_tx_preset[];
  rand bit [3:0] m_usp_128gt_tx_preset[];

  rand bit [3:0] cov_dsp_128gt_tx_preset;  //used for functional coverage
  rand bit [3:0] cov_usp_128gt_tx_preset;  //used for functional coverage
  `endif

  //------------------------------------------------------------------------
  // Lane Margining at the Receiver Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_lane_mrgn_ext_cap;

  rand bit   m_cap_rx_lane_margining_supp;

  //------------------------------------------------------------------------
  // Lane Margining at the Receiver Extended Capability Header
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Margining Port Capabilities Register
  //------------------------------------------------------------------------
  //Field: m_margining_uses_driver_sw_cap
  rand bit              m_margining_uses_driver_sw_cap;

  //------------------------------------------------------------------------
  // Margining Port Status Register
  //------------------------------------------------------------------------
  //Field: m_margining_ready
  bit                   m_margining_ready;
  //Field: m_margining_sw_ready
  bit                   m_margining_sw_ready;

  //------------------------------------------------------------------------
  // Margining Lane Control Register
  //------------------------------------------------------------------------
  //The following fields are not randomized as these are configured in the
  //middle of simulation
  //Field: m_receiver_number
  bit [2:0]             m_receiver_number;
  //Field: m_margin_type
  bit [2:0]             m_margin_type;
  //Field: m_usage_model
  bit                   m_usage_model;
  //Field: m_margin_payload
  bit [7:0]             m_margin_payload;

  //------------------------------------------------------------------------
  // Margining Lane Status Register
  //------------------------------------------------------------------------
  //Field: m_receiver_number_status
  bit [2:0]             m_receiver_number_status;
  //Field: m_margin_type_status
  bit [2:0]             m_margin_type_status;
  //Field: m_usage_model_status
  bit                   m_usage_model_status;
  //Field: m_margin_payload_status
  bit [7:0]             m_margin_payload_status;

  //------------------------------------------------------------------------
  //NOTE : Capability not Supported by DUT
  // ACS Extended Capability Header
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_acs_ext_cap;

  rand bit   m_cap_acs_supp;

  rand bit is_acs_translation_blocking_en;

  //------------------------------------------------------------------------
  // Captured Data control register
  //------------------------------------------------------------------------
  
  rand bit [7:0] m_captured_data_control_reg;
  
  rand bit       m_captured_data_for_nfm;

  //------------------------------------------------------------------------
  // ACS Capability Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // ACS Control Register
  //------------------------------------------------------------------------


  //------------------------------------------------------------------------
  //  Common PCI and PCIe Capabilities
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Power Budgeting Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_pwr_budget_ext_cap;
  rand bit   m_cap_pwr_budget_supp;

  //------------------------------------------------------------------------
  // Power Budgeting Extended Capability Header
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Power Budgeting Data Select Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Power Budgeting Data Register
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Power Budgeting Capability Register : HWINIT register
  //------------------------------------------------------------------------
  rand bit m_system_allocated;

  //------------------------------------------------------------------------
  // Latency Tolerance Reporting (LTR) Extended Capability
  // NOTE : Applicable only in PF0
  // Error : Error testing with non PF0 functions
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_ltr_ext_cap;

  // Max Snoop Latency Register
  rand bit  [9:0] m_snoop_lat;
  rand bit  [2:0] m_snoop_sc;

  // Max No-Snoop Latency Register
  rand bit  [9:0] m_nosnoop_lat;
  rand bit  [2:0] m_nosnoop_sc;
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // L1 PM Substates Extended Capability
  // NOTE : Applicable only in PF0
  // Error : Error testing with non PF0 functions
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_l1_pm_ext_cap;


  //------------------------------------------------------------------------
  // L1 PM Substates Extended Capability Header
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // L1 PM Substates Capabilities Register
  //------------------------------------------------------------------------
   rand bit           m_pci_pm_l1_2_supp;
   rand bit           m_pci_pm_l1_1_supp;
   rand bit           m_aspm_l1_2_supp;
   rand bit           m_aspm_l1_1_supp;
   rand bit           m_cap_l1_pm_substate_supp;
   rand bit           m_link_activation_supp;
   rand bit [7:0]     m_port_comm_mode_restore_t;
   rand bit [1:0]     m_port_T_power_on_scale;
   rand bit [4:0]     m_port_T_power_on_value;

  //------------------------------------------------------------------------
  // L1 PM Substates Control 1 Register
  //------------------------------------------------------------------------
   rand bit           m_pci_pm_l1_2_en;
   rand bit           m_pci_pm_l1_1_en;
   rand bit           m_aspm_l1_2_en;
   rand bit           m_aspm_l1_1_en;
   rand bit           m_link_act_interrupt_en;
   rand bit           m_link_act_ctrl; //Not for initial update
   rand bit[7:0]      m_comm_mode_restore_t;
   rand bit[9:0]      m_ltr_l1_2_thd_val;
   rand bit[2:0]      m_ltr_l1_2_thd_scale;

  //------------------------------------------------------------------------
  // L1 PM Substates Control 2 Register
  //------------------------------------------------------------------------
    rand bit[1:0]         m_T_power_on_scale;
    rand bit[4:0]         m_T_power_on_val;
  //------------------------------------------------------------------------
  // L1 PM Substates Status Register
  //------------------------------------------------------------------------
    bit                  m_link_act_status;


   //PM LM Configuration
   //i_pm_cfg_0
   //Contains the timeout value (in units of 16 ns) for transitioning to the L0S power state. Setting this parameter to 0
   //permanently disables the transition to the L0S power state.
   rand bit [15:0]       user_aspm_l0s_timer; //(in units of 16 ns) Default: 'd375[6000ns] 0: Disables L0s entry

   //i_pm_cfg_1
   //Contains the timeout value (in units of 16 ns) for transitioning to the L1 power state. Setting this parameter to 0
   //permanently disables the transition to the L1 power state.
   rand bit [19:0]       user_aspm_l1_timer; //(in units of 16 ns) Default: 'd750[12000ns] 0: Disables L1 entry
   //0: Both Tx & Rx checked for idle . 1: Only Tx checked for idle
   rand bit              aspm_l1_entry_check_only_tx_idle; //Default 0
   //check RP mode L1 entry to wait for credit accumukation or not.
   rand bit             dis_rp_check_for_min_cred_for_l1_entry; //Default 1
   //01: Force entry to Recovery immediately on Recovery event.
   //10: Wait for outbound PM DLLPs to be stopped by Data Link Layer before entering Recovery.
   rand bit [1:0]       l1_entry_neg_Recovery_interrupt_mode; //Default 0

   //i_pm_cfg_2
   //Delay to re-enter L1 after no activity (in units of 16ns). Default 0
   rand bit [31:0]       user_delay_re_entry_l1;

   //i_pm_cfg_3
   //Time in microseconds between the Controller receiving a PME_TurnOff message TLP and the Controller sending a
   //PME_TO_Ack response to it. This field must be set to a non-zero value in order for the Controller to send a response.
   //Setting this field to 0 suppresses the Controller's response to PME_TurnOff message, so that the client may transmit
   //the PME_TO_Ack message through the master interface.
   //rand bit [15:0]       user_delay_to_send_pmetoack; //Default 0 (in units of 1us)

   //i_pm_cfg_4
   //Specifies the timeout delay for retransmission of PM_PME messages. The value is in units of microseconds.
   //The actual time elapsed has a +1 microseconds tolerance from the value programmed.
   rand bit [19:0]       user_timeout_to_re_tx_pme; //(in units of 1us) Default: 'd0[0 us]
   //When this bit is set, Controller will not automatically send a PME message, when PM Status bit in PMCSR register is set
   rand bit              disable_dut_tx_pme_on_pme_status_set; //default 0
   rand bit              block_pm_req_ack_for_pm_enter_l23; //default 0

   //i_pm_cfg_5
   //Normaly L1 substate entry process is initiated immedaitely after LTSSM enters L1. A delay in micro-seconds can be
   //given in this field to delay L1 substate entry process. This timeout has 0-1us margin of error. Power on reset value of this
   //register can be adjusted by modifying the localparam LP_DBG_CTRL_L1_SUBSTATE_ENTRY_DELAY
   rand bit [23:0]       user_delay_to_enter_l1_sub; //Default 0 (in units of 1us)
   rand bit              disable_ib_tlp_reg_access; //Default 0 : Only for debug mode, don't set in normal sims
   rand bit              disable_l1_exit_trigger_on_pend_tlps; //Default 0 : Only for debug mode, don't set in normal sims
   //This field enables power shutoff mechanism in L1.2 state. This field is ignored if L1.x is not enabled
   rand bit              enable_power_shutoff_in_l1_2;
   rand bit              pipe_rxeidetectdisable_txcommonmodedisable_mode;
   rand bit              disable_pipe6_l1_x_handshake_phy_wait_timeout;
   rand bit              enable_pm_l1_0_cso;
   rand bit              enable_aspm_l1_0_cso;

   //i_pm_cfg_6
   //This field enables a timeout mechanism while waiting for RX buffers and Outstanding Pkts before turning off power. Controller enters
   //L1 substate after timeout. A value of 0x0 disables this timeout mechanism. Controller do not select internal power shutoff if it enters
   //L1.x with this timeout. User can give timeout in micro-seconds using this register. This field is ignored if L1 substate is disabled.
   rand bit [23:0]      user_timeout_before_remove_pwr; //Default 0 (DIsable timeout)
   //Enable waiting for outstanding completions before entering L1.x
   rand bit             en_wait_for_cpl_for_tx_ob_req; //Default 0 (DIsable by default)
   //Enables waiting for RX path IDLE condition before entering L1.x
   rand bit             en_wait_for_rx_idle_bef_l1_x; //Default 0 (DIsable by default)
   //If this bit is set and CLKREQ_IN_N is 1(deasserted), Controller responds with ERROR response to APB requests.
   //L1-substate removes CORE_CLK. since the registers are implemented in core-clk, register access is not possible during L1-substate.
   //If client can supply a slow clock to core(CORE_CLK) during L1-substates, APB/mgmt access is possible in L1.x. set this bit if client
   //can supply slow clock to CORE_CLK when CLKREQ_IN_N is 1(deasserted). If this bit is set, Controller neither wake-up from L1 or generate error
   //response for APB access during L1.x.
   rand bit             client_supply_low_freq_coreclk; //Default 0
   //Setting this field make the state machine to consider LP_CTRL_POWER_RECOVER_ACK as Client system recovery Complete ACK instead of the Controller power stable ACK. This field is ignored if LP_CTRL_BYPASS_ENABLE unset. If this field is set, L1-substate machines expect that the client system finishes power up of the controller within power_on time in the L1-substate capability register and Controller will be waiting in recovery state for ACK. This ensure that the PHY PLL lock and client system initialization goes on in parallel.Default value of this register can be set with the localparam:RECOVER_ACK_AS_CLIENT_RECOVER. Setting this field gives the best system performance
   rand bit             power_recover_ack_mode; //Default 0
   rand bit             pl1sssel; //Default 1
   rand bit             l1ssexwocq; //Default 1
   rand bit             l1sscsorm; //Default 0
   rand bit             l1sscsore; //Default 0
   bit                  pipe_l1_substate_select;
   bit                  pipe_l1_substate_select_arg_passed=1;
   bit                  l1_cso_test;
   bit                  aspm_l1_cso_test;
   bit                  pm_l1_cso_test;

   //i_pm_cfg_7
   rand bit [7:0]        pm_clk_freq; //Default 'h25(37MHz) value can be from 2:60 (2-2Mhz to 60-60Mhz)
   //TL Outbound mux timeout limit, used in case of PCI-PM L1 entry to block the mux output .
   rand bit [15:0]       hls_ob_deactivate_timeout_for_l1_entry; //Default : 'h32[800ns]
   rand bit [15:0]        l2_entry_pkt_flush_timeout; //Default: 'h40 [1024ns]

   //i_pm_dbg_sts_0 - Just for coverage purpose
   bit timeout_before_l1_entry;
   bit [7:0] l1_sub_exit_reason;
   bit l1_entry_mode;

   //i_cfg_15
   rand bit disable_l1_entry_without_eios;
   rand bit Gen6_skip_parity_majority_voting_mode;

   // i_lpc_l0_idle_ctrl
   rand bit lpcl0idleen;
   rand bit [9:0] lpcl0idle_timeout_cnt;
   rand bit lpcl0idle_timeout_scale;
   rand bit axi_pdpsoclk_cgen;
   rand bit ide_coreclk_cgen;
   rand bit tlhal_pdpsoclk_cgen;
   bit clk_gating_en;

   // i_lpc_reg_idle_ctrl
   rand bit lpcregidleen;
   rand bit [9:0] lpcregidle_timeout_cnt;
   
   // Field : m_cxl_pcie_fall_back_mode
   // When strap to cxl mode provide non-cxl vendor ID based on the below
   rand bit m_cxl_pcie_fall_back_mode;

   // Field : m_cxl_pcie_vendor_id
   rand bit [15:0] m_cxl_pcie_vendor_id;
  
  //---------------------------------------------------------------------------------
  // Field : cxlio_ctrl_cpl_pbr_from_register
  // If 1 then use PTH DW from the cxlio_ctrl_pth_for_generated_tlps_towards_link register field.
  //--------------------------------------------------------------------------------
  rand bit cxlio_ctrl_cpl_pbr_from_register;
  
  //---------------------------------------------------------------------------------
  // Field : cxl_pth_rsvd
  // CXL PBR PTH Reserved bits
  //--------------------------------------------------------------------------------
  rand bit [2:0] cxl_pth_rsvd; 
  
  //---------------------------------------------------------------------------------
  // Field : cxl_pth_hie
  // CXL PBR PTH HIE(Hierarchical)
  //--------------------------------------------------------------------------------
  rand bit cxl_pth_hie;

  //---------------------------------------------------------------------------------
  // Field : cxl_pth_dsar
  // CXL PBR PTH DSAR(Downstream Acceptance Rules)
  //--------------------------------------------------------------------------------
  rand bit cxl_pth_dsar;

  //---------------------------------------------------------------------------------
  // Field : cxl_pth_pif
  // CXL PBR PTH PIF(PID Forward)
  //--------------------------------------------------------------------------------
  rand bit cxl_pth_pif;

  //---------------------------------------------------------------------------------
  // Field : cxl_pth_spid
  // CXL PBR PTH SPID(Source PBR ID)
  //--------------------------------------------------------------------------------
  rand bit [11:0] cxl_pth_spid;
  
  //---------------------------------------------------------------------------------
  // Field : cxl_pth_dpid
  // CXL PBR PTH DPID(Destination PBR ID)
  //--------------------------------------------------------------------------------
  rand bit [11:0] cxl_pth_dpid;
  
  //---------------------------------------------------------------------------------
  // Field : cxl_ldid
  // CXL LD-ID
  //--------------------------------------------------------------------------------
  rand bit [15:0] cxl_ldid;
  
  //---------------------------------------------------------------------------------
  // Field : aer_pth_logging
  // Logging of local prefix/PBR in prefix log portion of AER
  //--------------------------------------------------------------------------------
  rand bit aer_pth_logging;
  
  //---------------------------------------------------------------------------------
  // Field : pth_from_reg
  // Generate PTH from IP register or swap IDs from requests for int generated CPL
  //--------------------------------------------------------------------------------
  rand bit pth_from_reg;
  
  //---------------------------------------------------------------------------------
  // Field : pth_reg_val
  //--------------------------------------------------------------------------------
  bit [31:0] pth_reg_val;
  
  //---------------------------------------------------------------------------------
  // Field : mld_pth_reg_val
  //--------------------------------------------------------------------------------
  bit [31:0] mld_pth_reg_val;
  
  //---------------------------------------------------------------------------------
  // Field : cxl_pth_dpid_towards_AL
  // CXL PBR PTH DPID(Destination PBR ID) used for towards AL Register.
  //--------------------------------------------------------------------------------
  rand bit [11:0] cxl_pth_dpid_towards_AL;

  //---------------------------------------------------------------------------------
  // Field : m_ptm_req_mode
  // Randomize PTM request mode
  //--------------------------------------------------------------------------------
  rand bit  m_ptm_req_mode;

  //---------------------------------------------------------------------------------
  // Field : m_ptm_req_intveral_scale
  // Randomize PTM request Time intervel for single mode
  //--------------------------------------------------------------------------------
  rand bit [3:0]  m_ptm_req_intveral_scale;

  //--------------------------------------------------------------------------------
  // Field : m_ptm_req_intveral_s_mode
  // Randomize PTM request Time intervel for single mode
  //--------------------------------------------------------------------------------
  rand bit [3:0]  m_ptm_req_intveral_s_mode;

  //--------------------------------------------------------------------------------
  // Field : m_ptm_req_intveral_c_mode
  // Randomize PTM request Time intervel for continues mode
  //--------------------------------------------------------------------------------
  rand bit [3:0]  m_ptm_req_intveral_c_mode;


  //--------------------------------------------------------------------------------
  // Field : m_ptm_resp_mode
  // Randomize PTM response mode
  //--------------------------------------------------------------------------------
  rand bit   m_ptm_resp_mode;

  rand bit   m_eptm_cap;

  rand bit [1:0] m_eptm_context_invalidate;
  //--------------------------------------------------------------------------------
  // Field : m_ptm_resp_en
  //Randomize Enable for  RP DUT to respond PTM Req with PTM Response
  //--------------------------------------------------------------------------------
  rand bit   m_ptm_resp_en;

  //--------------------------------------------------------------------------------
  // Field : phy_tx_latency
  // Phy Transmit Latency
  //--------------------------------------------------------------------------------
  rand bit[9:0]   phy_tx_latency;

  //--------------------------------------------------------------------------------
  // Field : phy_rx_latency
  // Phy Receiver Latency
  //--------------------------------------------------------------------------------
  rand bit[9:0]   phy_rx_latency;


  // ptm tx/rx offset
  //--------------------------------------------------------------------------------
  rand bit[3:0]     m_ptm_tx_offset;
  rand bit[3:0]     m_ptm_rx_offset;

  //---------------------------------------------------------------------------
  // PTM Message Counters
  //---------------------------------------------------------------------------
  int num_ptm_msg_req_sent = 0;
  int num_ptm_msg_resp_rcvd = 0;
  int num_ptm_msg_respd_rcvd = 0;
  int num_ptm_msg_req_rcvd = 0;
  int num_ptm_msg_resp_sent = 0;
  int num_ptm_msg_respd_sent = 0;


  //------------------------------------------------------------------------
  // FRS  ARI Extended Capability
  // NOTE : Applicable only in RP and PF0
  // Error : Error testing with non PF0 functions
  //------------------------------------------------------------------------
  rand bit          m_ari_supp;
  // ARI Control Register
  rand bit          m_ari_mfvc_func_grp_en;
  rand bit          m_ari_acs_func_grp_en;


  //------------------------------------------------------------------------
  // NOTE : Capability not Supported by DUT
  // FRS Queueing Extended Capability
  // NOTE : Applicable only in RP
  // Error : Error testing with non PF0 functions
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_frs_ext_cap;

  rand bit   m_cap_frs_q_supp;


  //------------------------------------------------------------------------
  // NOTE : Capability not Supported by DUT
  // Flattening Portal Bridge (FPB) Capability
  // Error : Error testing in USP and DSP
  // Note :  Feature not supported by DUT
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_fpb_cap;
  rand bit   m_cap_fpb_supp;

  //------------------------------------------------------------------------
  // Additional PCI and PCIe Capabilities
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Virtual Channel Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_vc_ext_cap;
  rand bit               m_cap_vc_supp;
  rand int               num_vc_enabled;
  bit [2:0]              vc_id[]; //For coverage
  rand bit [7:0]         vc_tc_map[];
  rand bit [2:0]         credit_rollover_vc;
  bit [8:0]              tc_vc_map[8];
  rand bit               vc_enable_val[];
  rand bit               staggered_vc_init;
  bit [7:0]              tc_supported;
  bit [2:0]              m_unmapped_tc_list[$];
  bit [7:0]              m_p_rsvd_err_queue[$];
  bit [7:0]              m_np_rsvd_err_queue[$];
  bit [7:0]              m_cpl_rsvd_err_queue[$];
  bit [7:0]              m_none_rsvd_err_queue[$];

  //--------------------------------------------------------------------------------
  // Field : faultRazwi_violated_tlp
  // Description : Storing FaultRazwi violated TLPs key= requester_id and
  // value will be queue_of_tag on that requester_id to check for their CPL_SC
  //--------------------------------------------------------------------------------
  int faultRazwi_violated_tlp_tag[int][$];

  //rej_snoop_transaction (vc_res_cap_reg_0)
  rand bit               rej_snoop_transaction[];
  //TODO DUT & Reg model don't have Port vc cap2, port cap/ctrl/status reg. ALso, some fields in VC res cap/ctrl/status reg

  //------------------------------------------------------------------------
  // Note : Capability not supported by DUT
  // Multi-Function Virtual Channel Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_mfvc_ext_cap;
  rand bit   m_cap_multi_func_vc_supp;

  //------------------------------------------------------------------------
  // Device Serial Number Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_dev_serial_ext_cap;
  rand bit   m_cap_dev_serial_num_supp;

  //------------------------------------------------------------------------
  //Vendor-Specific Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_vsec_cap;

  //TODO : Did not get the k-wire
  rand bit   m_cap_vendor_spec_supp;

  //------------------------------------------------------------------------
  //Vendor-Specific Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_vsec_ext_cap;

  //------------------------------------------------------------------------
  // Note : Capability not supported by DUT
  //Designated Vendor-Specific Extended Capability (DVSEC)
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_dvsec_ext_cap;
  rand bit   m_cap_dvsec_supp;

  //------------------------------------------------------------------------
  // Note : Capability not supported by DUT
  //RCRB Header Extended Capability
  //------------------------------------------------------------------------
  rand bit   m_cap_rcrb_hdr_supp;

  //------------------------------------------------------------------------
  // Note : Capability not supported by DUT
  //Root Complex Link Declaration Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_rc_link_dec_ext_cap;
  rand bit   m_cap_rc_link_decl_supp;

  //------------------------------------------------------------------------
  // Note : Capability not supported by DUT
  //Root Complex Internal Link Control Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_rc_link_dec_ctrl_ext_cap;
  rand bit   m_cap_rc_int_link_ctrl_supp;

  //------------------------------------------------------------------------
  //Note : Capability not supported by DUT
  //Root Complex Event Collector Endpoint Association Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_rc_ec_ea_ext_cap;

  //------------------------------------------------------------------------
  //Note : Capability not supported by DUT
  //Multicast Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_multi_cast_ext_cap;
  rand bit   m_cap_multi_cast_supp;

  //------------------------------------------------------------------------
  //Dynamic Power Allocation Extended Capability (DPA Capability)
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_dpa_ext_cap;

  rand bit               m_cap_dpa_supp;
  //------------------------------------------------------------------------
  //DPA Capability Register
  //------------------------------------------------------------------------
  rand bit [4:0]         m_substate_max;
  rand bit [1:0]         m_trans_latency_unit;
  rand bit [1:0]         m_power_allocation_scale;
  rand bit [1:0]         m_trans_latency_val_0;
  rand bit [1:0]         m_trans_latency_val_1;

  //------------------------------------------------------------------------
  //DPA Latency Indicator Register
  //------------------------------------------------------------------------
  rand bit [31:0]        m_TLI_bits;

  //------------------------------------------------------------------------
  //DPA Control Register
  //------------------------------------------------------------------------

  rand bit[4:0]          m_substate_ctrl;

  //------------------------------------------------------------------------
  //DPA Status Register
  //------------------------------------------------------------------------
  bit[4:0]               m_substate_status;
  bit                    m_substate_ctrl_en;


  //------------------------------------------------------------------------
  //DPA Power Allocation Array
  //------------------------------------------------------------------------
  rand bit[3:0]          m_substate_powe_allocation[];

  //------------------------------------------------------------------------
  //Note : Capability not supported by DUT
  //DPC Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_dpc_ext_cap;
  rand bit               m_cap_dpc_supp;

  //------------------------------------------------------------------------
  // Precision Time Management Extended Capability
  // Error : Error testing with non PF0 functions
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_ptm_ext_cap;

  rand bit   m_cap_ptm_supp;
  //------------------------------------------------------------------------
  //Note: Feature not supported by DUT
  //Readiness Time Reporting Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_rtr_ext_cap;

  rand bit   m_cap_readiness_time_rpt_supp;

  //------------------------------------------------------------------------
  //Note: Feature not supported by DUT
  //Hierarchy ID Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_hier_id_ext_cap;

  rand bit   m_cap_hier_id_supp;

  //------------------------------------------------------------------------
  // Vital Product Data Capability (VPD Capability)
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_vpd_ext_cap;

  rand bit                  m_cap_vpd_supp;

  //VPD Address Register
  rand bit[14:0]            m_vpd_addr;
  rand bit                  m_vpd_F;

  //VPD Data Register
  rand bit[31:0]            m_vpd_data;

  //--------------------------------------------------------------------------------
  // Native PCIe Enclosure Management Extended Capability (NPEM Extended Capability)
  //--------------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_npeme_ext_cap;


  //NPME Capability Register
  rand bit m_cap_npeme_supp;
  rand bit m_npem_reset_cp;
  rand bit m_npem_ok_cp;
  rand bit m_npem_locate_cp;
  rand bit m_npem_fail_cp;
  rand bit m_npem_rebuild_cp;
  rand bit m_npem_pfa_cp;
  rand bit m_npem_hot_spare_cp;
  rand bit m_npem_in_a_critical_arry_cp;
  rand bit m_npem_in_a_failed_arry_cp;
  rand bit m_npem_invalid_device_type_cp;
  rand bit m_npem_disable_cp;

  //NPEM Control Register
  rand bit               m_npem_enable;
  rand bit               m_npem_initiate_reset;
  rand bit               m_npem_ok_control;
  rand bit               m_npem_locate_control;
  rand bit               m_npem_fail_control;
  rand bit               m_npem_rebuild_control;
  rand bit               m_npem_pfa_control;
  rand bit               m_npem_hot_spare_control;
  rand bit               m_npem_in_a_critical_arry_control;
  rand bit               m_npem_in_a_failed_arry_control;
  rand bit               m_npem_invlid_device_type_control;
  rand bit               m_npem_disable_control;
  rand bit               m_npem_enclouser_specific_control;

  rand bit 		 m_npem_interrupt_mask;

  //--------------------------------------------------------------------------------
  // IDE(Integrity and Data Encryption) Extended Capability
  //--------------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_ide_ext_cap;

  //--------------------------------------------------------------------------------
  // UCIE DVSEC Capability
  //--------------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_ucie_dvsec_cap;
  cdn_pcie_reg_base      m_cap_ucie_dvsec_msi_cap;


  //------------------------------------------------------------------------
  // Device3 Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_dev3_ext_cap;
  //TODO: need to implement registers and control variables

  //------------------------------------------------------------------------
  // Alternate Protocol Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_apn_ext_cap;
  rand bit               m_apn_ext_cap_supp;

  //Alternate Protocol Capabilities Register
  rand bit[7:0]          m_ap_count;
  rand bit               m_ap_sel_en_supp;

  //Alternate Protocol Control Register
  rand bit               m_ap_index_sel;
  rand bit               m_ap_negotiation_global_en;

  //Alternate Protocol Selective Enable Mask Register
  rand bit               m_ap_selective_en_mask;
  rand bit[30:0]         m_ap_selectve_en_mask_others;

  //------------------------------------------------------------------------
  //NOTE : Capability not Supported by DUT
  //Conventional PCI Advanced Features Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_af_cap;

  //------------------------------------------------------------------------
  //Note : Capability not Supported by DUT
  //SFI Extended Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_sfi_ext_cap;

  //------------------------------------------------------------------------
  //Note : Capability not Supported by DUT
  //Subsystem ID and Sybsystem Vendor ID Capability
  //------------------------------------------------------------------------
  cdn_pcie_reg_base      m_cap_ssid_ssvid_cap;

  // Below variable will be used to select a pf number after PFO to issue
  // register traffic on
  int pf_index;
  bit [15:0] vf_index;
  bit reg_linkedlist_done;
  // Number of VCs comes from the parameter

  //Credits
  //i_posted_cred_lim
  rand bit [31:0] m_fcph_vc[];
  rand bit [31:0] m_fcpd_vc[];
  rand bit [31:0] m_fcnph_vc[];
  rand bit [31:0] m_fcnpd_vc[];
  rand bit [31:0] m_fccplh_vc[];
  rand bit [31:0] m_fccpld_vc[];

  rand int       min_p_pld_credits[], min_np_pld_credits[],min_cpl_pld_credits[];
  rand bit [1:0] m_scaled_flow_ctrl_posted_hdr_scale[];
  rand bit [1:0] m_scaled_flow_ctrl_posted_data_scale[];
  rand bit [1:0] m_scaled_flow_ctrl_non_posted_hdr_scale[];
  rand bit [1:0] m_scaled_flow_ctrl_non_posted_data_scale[];
  rand bit [1:0] m_scaled_flow_ctrl_cpl_hdr_scale[];
  rand bit [1:0] m_scaled_flow_ctrl_cpl_data_scale[];

  rand bit [31:0] m_shared_fcph_vc[];
  rand bit [31:0] m_shared_fcpd_vc[];
  rand bit [31:0] m_shared_fcnph_vc[];
  rand bit [31:0] m_shared_fcnpd_vc[];
  rand bit [31:0] m_shared_fccplh_vc[];
  rand bit [31:0] m_shared_fccpld_vc[];
  rand int       min_shared_p_pld_credits[], min_shared_np_pld_credits[],min_shared_cpl_pld_credits[];
  rand bit [1:0] m_shared_scaled_flow_ctrl_posted_hdr_scale[];
  rand bit [1:0] m_shared_scaled_flow_ctrl_posted_data_scale[];
  rand bit [1:0] m_shared_scaled_flow_ctrl_non_posted_hdr_scale[];
  rand bit [1:0] m_shared_scaled_flow_ctrl_non_posted_data_scale[];
  rand bit [1:0] m_shared_scaled_flow_ctrl_cpl_hdr_scale[];
  rand bit [1:0] m_shared_scaled_flow_ctrl_cpl_data_scale[];

  //m_total_scaled* will be randomized first. This scale factor will be assigned to m_shared_scaled_factor* for all VCs.
  //Errata spec: All VCs should have same scaling factor for a FC type.
  //For DUT implementation (as per errata scaling of shared credit should be able to advertise the sum of all shared credits for that fc type. Our DUT needs (ded+shared) sum across all VCs to be advertised by randomuzed scaling factor.So, we have another constraint on this variable. This scaling will be > dedicated scale for that fc type
  //NOTE: m_total_scaled_flow_ctrl_cpl_* is meaningful for non-infinite/non-zero credits. Otherwise it will hole junk value in dev_top_cfg print. But m_shared_scaled_flow_ctrl_cpl* will be properly assigned for infinite/zero credits
  rand bit [1:0] m_total_scaled_flow_ctrl_posted_hdr_scale;
  rand bit [1:0] m_total_scaled_flow_ctrl_posted_data_scale;
  rand bit [1:0] m_total_scaled_flow_ctrl_non_posted_hdr_scale;
  rand bit [1:0] m_total_scaled_flow_ctrl_non_posted_data_scale;
  rand bit [1:0] m_total_scaled_flow_ctrl_cpl_hdr_scale;
  rand bit [1:0] m_total_scaled_flow_ctrl_cpl_data_scale;

  longint unsigned  m_shared_fcph_x_scale_vc_sum;
  longint unsigned  m_shared_fcpd_x_scale_vc_sum;
  longint unsigned  m_shared_fcnph_x_scale_vc_sum;
  longint unsigned  m_shared_fcnpd_x_scale_vc_sum;
  longint unsigned  m_shared_fccplh_x_scale_vc_sum;
  longint unsigned  m_shared_fccpld_x_scale_vc_sum;

  longint unsigned  m_shared_fcph_vc_sum;
  longint unsigned  m_shared_fcpd_vc_sum;
  longint unsigned  m_shared_fcnph_vc_sum;
  longint unsigned  m_shared_fcnpd_vc_sum;
  longint unsigned  m_shared_fccplh_vc_sum;
  longint unsigned  m_shared_fccpld_vc_sum;

  bit total_greater_outstand_ph;
  bit total_greater_outstand_pd;
  bit total_greater_outstand_nph;
  bit total_greater_outstand_npd;
  bit total_greater_outstand_cplh;
  bit total_greater_outstand_cpld;
  
  //------------------------------------------------------
  // credit calculated with scaling factor multiplied
  //------------------------------------------------------
  rand longint unsigned  m_fcph_x_scale_vc   [];
  rand longint unsigned  m_fcpd_x_scale_vc   [];
  rand longint unsigned  m_fcnph_x_scale_vc  [];
  rand longint unsigned  m_fcnpd_x_scale_vc  [];
  rand longint unsigned  m_fccplh_x_scale_vc [];
  rand longint unsigned  m_fccpld_x_scale_vc [];

  rand longint unsigned  m_shared_fcph_x_scale_vc   [];
  rand longint unsigned  m_shared_fcpd_x_scale_vc   [];
  rand longint unsigned  m_shared_fcnph_x_scale_vc  [];
  rand longint unsigned  m_shared_fcnpd_x_scale_vc  [];
  rand longint unsigned  m_shared_fccplh_x_scale_vc [];
  rand longint unsigned  m_shared_fccpld_x_scale_vc [];

  //Vc resource ctrl reg - Shared control fields
  /* =>When all elements in Shared_Flow_Control_Usage_Limit_Enable==1, then Shared_Flow_Control_Usage_Limit should contribute 100%
				-> If(4'b(Shared_Flow_Control_Usage_Limit_Enable.sum == k_num_vcs) && k_num_vcs !=1)  Shared_Flow_Control_Usage_Limit.sum==8;
	        	- when dedicated credits is zero for that VC, shared limit can't be zero for that vc (Ie.,Shared_Flow_Control_Usage_Limit can't be 3'b0)
     =>When k_num_vcs==1, Shared_Flow_Control_Usage_Limit_Enable[0]==0;*/
	rand bit[3:0] Shared_Flow_Control_Usage_Limit[];  //Size==k_num_vcs
	rand bit Shared_Flow_Control_Usage_Limit_Enable[]; //size==k_num_vcs

  /*When merge =1, then scaled flow header needs 10/0 for CPH/CPD
    When merge =1, shared credits for PH/PD can be zero value aswell when k_num_vcs>1 (ie., it will use other VCs shared pool)
    When merged, shared credits for PH/PD can't  be zero value when k_num_vc=1*/
  rand bit merge_p_cpl_hdr; //Use of [Merged] must be consistent across VCs. If one VC uses [Merged] shared credits, all VCs must also use [Merged] shared credits.
  rand bit merge_p_cpl_data; //Use of [Merged] must be consistent across VCs. If one VC uses [Merged] shared credits, all VCs must also use [Merged] shared credits.

  /* inf_zero_merged_shared_fc* & inf_zero_merged_dedicated_fc* will be randomized first to determine scaled factor,
     which in turn will used to determine actual credit allocation
  */
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_shared_fcph[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_shared_fcpd[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_shared_fcnph[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_shared_fcnpd[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_shared_fccplh[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_shared_fccpld[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_dedicated_fcph[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_dedicated_fcpd[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_dedicated_fcnph[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_dedicated_fcnpd[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_dedicated_fccplh[]; //size=k_num_vcs
  rand cdn_hpa_pcie_fm_shared_scale_encoding_t inf_zero_merged_dedicated_fccpld[]; //size=k_num_vcs

  /*When one FC type has infinite shared credit , it means all VCs shared credit for that FC type is infinite and all VCs dedicated credit for that FC is infinit
					-> if(Infinite_fm_ph==1) -> make all vcs shared and ded PH=infinite
						-> This infinite value can be given only for VIP
  */
  rand bit infinite_fm_ph;
  rand bit infinite_fm_pd;
  rand bit infinite_fm_nph;
  rand bit infinite_fm_npd;
  rand bit infinite_fm_cplh;
  rand bit infinite_fm_cpld;
  
  // For ECRC Calculations
  // In FM, symbol 0, bit 0 and symbol 6, bit 7 are Variant
  // In NFM, symbol 0, bit 0 and symbol 2, bit 6 are Variant 

  bit m_pack_ecrc_variant_fm;
  bit m_pack_ecrc_variant_nfm;

  bit  [2:0]   datapath_octa;
  int posted_fifo_depth[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int non_posted_fifo_depth[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int compl_fifo_depth[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int posted_fifo_tlp_cnt[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int non_posted_fifo_tlp_cnt[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int compl_fifo_tlp_cnt[parameters_cfg_pkg::KMAX_NUM_CIFS];

  int posted_hdr_credits_cif[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int posted_octawords_avail[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int posted_data_credits_cif[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int non_posted_octawords_avail[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int non_posted_hdr_credits_cif[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int non_posted_data_credits_cif[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int non_posted_hdr_credits__2times[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int non_posted_hdr_credits__3times[parameters_cfg_pkg::KMAX_NUM_CIFS];
  int non_posted_hdr_credits_int_calc[parameters_cfg_pkg::KMAX_NUM_CIFS];  
  int m_total_fcph_vc[];
  int m_total_fcpd_vc[];
  int m_total_fcnph_vc[];
  int m_total_fcnpd_vc[];
  int m_total_fcph_x_scale_vc[];
  int m_total_fcpd_x_scale_vc[];
  int m_total_fcnph_x_scale_vc[];
  int m_total_fcnpd_x_scale_vc[];

  bit vf_shares_same_queue;

  bit                          cfg_need_three_credits_for_each_tlp;
  bit [3:0]                    num_dws_prefix_support;
  bit [2:0]                    num_dws_prefix_count;
  int posted_hdr_credits__2times [parameters_cfg_pkg::KMAX_NUM_CIFS];
  int posted_hdr_credits__3times [parameters_cfg_pkg::KMAX_NUM_CIFS];

  //Equalization related variables
  //Gen3 - Dynamic Array to store Local PHY Preset and Coefficients
  //Index represents Preset Value (0 - 10)
  rand cdnpcie_hpa_eq_config gen3_preset_coeff_map[];
  //Gen3 - Full Swing Value. 1-Full Swing, 0-Reduced Swing
  rand bit gen3_full_swing; //get it from strap uvc

  //Gen4 - Dynamic Array to store Local PHY Preset and Coefficients
  //Index represents Preset Value (0 - 10)
  rand cdnpcie_hpa_eq_config gen4_preset_coeff_map[];
  //Gen4 - Full Swing Value. 1-Full Swing, 0-Reduced Swing
  rand bit gen4_full_swing; //get it from strap uvc

  //Gen5 - Dynamic Array to store Local PHY Preset and Coefficients
  //Index represents Preset Value (0 - 10)
  rand cdnpcie_hpa_eq_config gen5_preset_coeff_map[];
  //Gen5 - Full Swing Value. 1-Full Swing, 0-Reduced Swing
  rand bit gen5_full_swing; //get it from strap uvc

  //Gen6 - Dynamic Array to store Local PHY Preset and Coefficients
  //Index represents Preset Value (0 - 10)
  rand cdnpcie_hpa_gen6_eq_config gen6_preset_coeff_map[];
  rand cdnpcie_hpa_gen6_eq_config gen6_preset_coeff_map_new[];
  //Gen6 - Full Swing Value. 1-Full Swing, 0-Reduced Swing
  rand bit gen6_full_swing; //get it from strap uvc

`ifdef PCIE_GEN7
  //Gen7 - Dynamic Array to store Local PHY Preset and Coefficients
  //Index represents Preset Value (0 - 10)
  rand cdnpcie_hpa_gen6_eq_config gen7_preset_coeff_map[];
  rand cdnpcie_hpa_gen6_eq_config gen7_preset_coeff_map_new[];
  //Gen7 - Full Swing Value. 1-Full Swing, 0-Reduced Swing
  rand bit gen7_full_swing; //get it from strap uvc
`endif

  //Gen5 EQ Variables
  // DUT-Equalization bypass to highest data rate
  rand bit eq_bypass_to_highest_rate;
  //DUT-No Equalization needed
  rand bit no_eq_needed_support;
  rand bit no_eq_needed;

  // DEV3 CTRL Register for UIO
  rand bit       m_uio_req_256B_bound_dis;
  
  // TODO: Vamsi Noted to implement..
  // Arbiters programming through LM at TL/HLS ->
  //PL LM Registers
  //------------------------------------------------------------------------
  //Physical Layer Configuration Register 0
  //------------------------------------------------------------------------
  //Field: m_lm_transmitted_link_id
  rand bit [7:0]             m_lm_transmitted_link_id; //applicable only for rp
  //Field: m_lm_tx_swing
  rand bit                   m_lm_tx_swing;
  //Field: m_lm_sris_enable
  rand bit                   m_lm_sris_enable;
  // //Field: m_lm_en_var_core_clk
  // rand bit                   m_lm_var_core_clk_en;
  //Field: m_lm_master_lpk_enable
  bit                   m_lm_master_lpk_enable; //applicable only for rp
  //Field: m_lm_min_rx_elec_idle_delay
  rand bit [3:0]             m_min_rx_elec_idle_delay;
  //Field: m_lm_min_tx_elec_idle_delay
  rand bit [7:0]             m_min_tx_elec_idle_delay;
  //Field: m_lm_detect_quiet_min_delay
  rand bit [1:0]             m_det_quiet_min_delay_ctrl;

  //------------------------------------------------------------------------
  //Physical Layer Configuration Register 1
  //------------------------------------------------------------------------
  //Field: m_phy_err_reporting_mode
  rand bit                   m_phy_err_reporting_mode;
  //Field: m_dis_os_after_skip_framing_check
  rand bit                   m_dis_os_after_skip_framing_check;
  //Field: m_dis_illegal_os_after_EDS_framing_chk;
  rand bit                   m_dis_illegal_os_after_EDS_framing_chk;
  //Field: m_dis_sync_header_err_chk
  rand bit                   m_dis_sync_header_err_chk;
  //Field: m_dis_link_retraining_on_framing_err
  rand bit                   m_dis_link_retraining_on_framing_err;
  //Field: m_dis_sds_os_chk
  rand bit                   m_dis_sds_os_chk;
  //Field: m_gen3_blk_align_check_dis
  rand bit                   m_gen3_blk_align_check_dis;
  //Field: m_gen3_blk_align_check_window
  rand bit [1:0]             m_gen3_blk_align_check_window;
  //Field: m_ltssm_freeze
  rand bit                   m_ltssm_freeze;
  //Field: m_clk_cycle
  rand bit [8:7]             m_clk_cycle;
  //Field: m_dis_stp_err_report
  rand bit                   m_dis_stp_err_report;
  //Field: m_dis_err_os_rec_without_eds
  rand bit                   m_dis_err_os_rec_without_eds;
  //Field: m_dis_err_data_rec_after_eds
  rand bit                   m_dis_err_data_rec_after_eds;
  //Field: m_dis_recovery_rcvrlock_min_ts1_tx
  rand bit                   m_dis_recovery_rcvrlock_min_ts1_tx;
  //Field: m_dis_state_sym_cons_check
  rand bit                   m_dis_state_sym_cons_check;
  //Field: m_dis_rate_identy_cons_check
  rand bit                   m_dis_rate_identy_cons_check;
  //Field: m_dis_elecidle
  rand bit                   m_dis_elecidle;
  //Field: m_dis_ext_speed_chg_delay
  rand bit                   m_dis_ext_speed_chg_delay ;
  //Field: m_dis_fc_timeout_err
  rand bit                   m_dis_fc_timeout_err;
  //Field: m_dis_lo_tx_error
  rand bit                   m_dis_lo_tx_error;
  //Field: m_dis_empty_fifo_mode
  rand bit                   m_dis_empty_fifo_mode;

  //------------------------------------------------------------------------
  //Physical Layer Configuration Register 2
  //------------------------------------------------------------------------
  //Field: m_tx_fts_count_for_gen1
  rand bit [7:0]             m_tx_fts_count_for_gen1;
  //Field: m_tx_fts_count_for_gen2
  rand bit [7:0]             m_tx_fts_count_for_gen2;
  //Field: m_tx_fts_count_for_gen3
  rand bit [7:0]             m_tx_fts_count_for_gen3;
  //Field: m_tx_fts_count_for_gen4
  rand bit [7:0]             m_tx_fts_count_for_gen4;

  //------------------------------------------------------------------------
  //Physical Layer Configuration Register 3
  //------------------------------------------------------------------------
  //Field: m_tx_fts_count_for_gen5
  rand bit [7:0]             m_tx_fts_count_for_gen5;

  //------------------------------------------------------------------------
  //Physical Layer Configuration Register 4
  //------------------------------------------------------------------------
  // The following fields are typically configured in the middle of simulation
  // for link width change or speed change
  //Field: m_lm_target_lane_map
  bit [15:0]             m_lm_target_lane_map;
  //Field: m_lm_link_upconfigure_retrain_link
  rand bit                    m_lm_link_upconfigure_retrain_link;
  //Field: m_lm_ep_target_link_speed;
  bit  [2:0]             m_lm_ep_target_link_speed;
  //Field: m_lm_link_speed_change_retrain_link
  bit                    m_lm_link_speed_change_retrain_link;

  //------------------------------------------------------------------------
  //Physical Layer Configuration Register 5
  //------------------------------------------------------------------------
  //Field: m_lm_rand_link_upconfigure_cap
  rand bit                              m_lm_rand_link_upconfigure_cap;
  //Field: m_lm_force_disable_scrambling
  rand bit                         m_lm_force_disable_scrambling; //applicable only for Gen1/2
  //Field: m_lm_disable_gen3_lfsr_from_skp;
  rand bit                         m_lm_disable_gen3_lfsr_from_skp;
  //Field: m_lm_disable_elec_idle_infer_in_l0
  rand bit                         m_lm_disable_elec_idle_infer_in_l0;
  //Field: m_lm_en_link_lane_number_chk_for_lpk_link_disable
  rand bit                         m_lm_en_link_lane_number_chk_for_lpk_link_disable;
  //Field: m_lm_deskew_l0s_fts_chk
  rand bit                         m_lm_deskew_l0s_fts_chk;
  //Field: m_lm_disable_dc_bal
  rand bit                         m_lm_disable_dc_bal;
  //Field: m_lm_disable_pipe_tx_fifo_centering_empty
  rand bit                         m_lm_pipe_tx_fifo_centering_empty;
  //Field: m_lm_disable_pipe_rx_fifo_lat_red
  rand bit                         m_lm_pipe_rx_fifo_lat_red;
  //Field: m_lm_disable_pipe_tx_fifo_data_align
  rand bit                         m_lm_pipe_tx_fifo_data_align;
  //Field: m_lm_disable_gen12_raw_skp_decode
  rand bit                         m_lm_disable_gen12_raw_skp_decode;
  //Field: m_lm_hot_reset_level_trigger
  rand bit                         m_lm_hot_reset_level_trigger;
  //Field: m_lm_dis_pipe_rx_fifo_override
  rand bit                         m_lm_dis_pipe_rx_fifo_override;
  //Field: m_lm_pipe_tx_fifo
  rand bit                         m_lm_pipe_tx_fifo;
  //Field: m_lm_dis_lk_up_cfg_pipe_txvalid_align
  rand bit                         m_lm_dis_lk_upcfg_pipe_txvalid_align;
  //Field: m_lm_dis_80b120b_enh_ts_symbol_checks
  rand bit [6:0]                        m_lm_dis_80b120b_enh_ts_symbol_checks;
  //Field: m_lm_dis_128b130b_enh_ts_symbol_checks
  rand bit [6:0]                        m_lm_dis_128b130b_enh_ts_symbol_checks;

  //------------------------------------------------------------------------
  //Physical Layer Configuration Register 6
  //------------------------------------------------------------------------
  //Field: m_lm_rx_elec_idle_glitch_filter_disable
  rand bit [15:0]                  m_lm_rx_elec_idle_glitch_filter_disable;
  //Field: m_lm_rx_elec_idle_glitch_filter_cnt_in_core_clks
  rand bit [7:0]                   m_lm_rx_elec_idle_glitch_filter_cnt_in_core_clks;
  //Field: m_lm_rx_elec_idle_glitch_filter_cnt_in_pm_clks
  rand bit [7:0]                   m_lm_rx_elec_idle_glitch_filter_cnt_in_pm_clks;

  //m_lm_rand_active_lane for randomizing m_lm_rx_elec_idle_glitch_filter_disable
  rand bit                         m_lm_rand_active_lane;
  //------------------------------------------------------------------------
  //Physical Layer Configuration Register 7
  //------------------------------------------------------------------------
  //Field: m_gen1_deskew_mode
  rand bit [1:0]             m_gen1_deskew_mode;
  //Field: m_gen2_deskew_mode
  rand bit [1:0]             m_gen2_deskew_mode;
  //Field: m_gen345_deskew_mode
  rand bit                   m_gen345_deskew_mode;
  //Field: m_gen6_deskew_mode
  rand bit                   m_gen6_deskew_mode;
  `ifdef PCIE_GEN7
  //Field: m_gen7_deskew_mode
  rand bit                   m_gen7_deskew_mode;
  `endif
  //Field: m_gen1_sris_skew_limit
  rand bit [7:0]             m_gen1_sris_skew_limit;
  //Field: m_gen2_sris_skew_limit
  rand bit [7:0]             m_gen2_sris_skew_limit;

  //------------------------------------------------------------------------
  //Physical Layer Debug Status Register 0
  //------------------------------------------------------------------------
  //Field: m_lm_link_sts
  bit                         m_lm_link_sts;
  //Field: m_lm_neg_lane_cnt
  bit [2:0]                   m_lm_neg_lane_cnt;
  //Field: m_lm_neg_speed
  bit [2:0]                   m_lm_neg_speed;
  //Field: m_lm_rec_link_id
  bit [7:0]                   m_lm_rec_link_id;
  //Field: m_lm_ltssm_state
  bit [7:0]                   m_lm_ltssm_state;
  //Field: m_lm_remote_lw_upconfigure_cap_sts
  bit                         m_lm_remote_lw_upconfigure_cap_sts;

  //------------------------------------------------------------------------
  //Physical Layer Debug Status Register 1
  //------------------------------------------------------------------------
  //Field: m_lm_neg_lane_map
  bit [15:0]                  m_lm_neg_lane_map;
  //Field: m_lm_lane_rev_sts
  bit                         m_lm_lane_rev_sts;

  //------------------------------------------------------------------------
  //Physical Layer Debug Status Register 2
  //------------------------------------------------------------------------
  //Field: m_lm_rec_fts_count_gen1
  bit [7:0]                  m_lm_rec_fts_count_gen1;
  //Field: m_lm_rec_fts_count_gen2
  bit [7:0]                  m_lm_rec_fts_count_gen2;
  //Field: m_lm_rec_fts_count_gen3
  bit [7:0]                  m_lm_rec_fts_count_gen3;
  //Field: m_lm_rec_fts_count_gen4
  bit [7:0]                  m_lm_rec_fts_count_gen4;

  //------------------------------------------------------------------------
  //Physical Layer Debug Status Register 3
  //------------------------------------------------------------------------
  //Field: m_lm_rec_fts_count_gen5
  bit [7:0]                  m_lm_rec_fts_count_gen5;

  //------------------------------------------------------------------------
  //Physical Layer Debug Status Register 4
  //------------------------------------------------------------------------
  //Field: m_lm_tlp_phy_err_sts
  bit                        m_lm_tlp_phy_err_sts;
  //Field: m_lm_os_blk_after_skp_os
  bit                        m_lm_os_blk_after_skp_os;
  //Field: m_lm_illegal_os_after_eds
  bit                        m_lm_illegal_os_after_eds;
  //Field: m_lm_data_blk_after_eds
  bit                        m_lm_data_blk_after_eds;
  //Field: m_lm_os_blk_rec_without_eds
  bit                        m_lm_os_blk_rec_without_eds;
  //Field: m_lm_gen3_framing_err_det
  bit                        m_lm_gen3_framing_err_det;
  //Field: m_lm_os_blk_rec_after_sds
  bit                        m_lm_os_blk_rec_after_sds;
  //Field: m_lm_invalid_sync_header
  bit                        m_lm_invalid_sync_header;
  //Field: m_lm_loss_of_blk_alignment
  bit                        m_lm_loss_of_blk_alignment;

  //------------------------------------------------------------------------
  //Equalization Control Register 0
  //------------------------------------------------------------------------
  //Field: m_lm_rx_eq_in_progress_abort_dis
  rand bit                    m_lm_rx_eq_in_progress_abort_dis;
  //Field: m_lm_rx_eq_in_progress_abort_timer
  rand bit [1:0]              m_lm_rx_eq_in_progress_abort_timer;
  //Field: m_lm_dis_local_lf_fs_sample
  rand bit                    m_lm_dis_local_lf_fs_sample;

  //------------------------------------------------------------------------
  //Gen3 Equalization Control Register 0
  //------------------------------------------------------------------------
  //Field: supp_gen3_preset
  rand bit [10:0]             supp_gen3_presets;
  //Field: default_gen3_tx_preset
  rand bit [3:0]              default_gen3_tx_preset;
  //Field: default_gen3_rx_preset_hint
  rand bit [2:0]              default_gen3_rx_preset_hint;
  //Field: gen3_max_eval_convergence_count
  rand bit [2:0]              gen3_max_eval_convergence_count;
  //Field: gen3_req_eq_retrain_link
  bit                         gen3_req_eq_retrain_link;
  //Field: gen3_quiesce_guarantee
  rand bit                         gen3_quiesce_guarantee;
  //Field: gen3_max_eq_req_limit
  rand bit [3:0]              gen3_max_eq_req_limit;

  //------------------------------------------------------------------------
  //Gen3 Equalization Control Register 1
  //------------------------------------------------------------------------
  //Field: gen3_eq_debug_sts_lane_sel
  rand bit [3:0]              gen3_eq_debug_sts_lane_sel;

  //Field: gen3_eq_phase2_remote_tx_preset_en
  // bit[4] Gen3 EQ Phase2 Remote Tx Preset Enable, Used only in EP Mode
  rand bit                    gen3_eq_phase2_remote_tx_preset_en;

  //Field: gen3_eq_local_override_tx_preset_en
  //bit[6] Gen3 Local Override Tx Preset Enable, used in both EP and RP Mode
  rand bit                    gen3_eq_local_override_tx_preset_en;


  //Field: gen3_eq_phase2_remote_tx_preset
  // bit[11:8] Gen3 EQ Phase2 Remote Tx Preset, Used only in EP Mode.
  rand bit [3:0]              gen3_eq_phase2_remote_tx_preset;

  //Field: gen3_eq_local_override_tx_preset
  // bit[15:12] Gen3 Local Override Tx Preset, used in both EP and RP Mode.
  rand bit [3:0]              gen3_eq_local_override_tx_preset;

  //Field: g3_disable_max_eval_iteration
  rand bit                    g3_disable_max_eval_iteration;
  //------------------------------------------------------------------------
  //Gen3 Equalization Status Register 0
  //------------------------------------------------------------------------
  //Field: gen3_local_tx_preset
  bit [3:0]              gen3_local_tx_preset[16];
  //Field: gen3_local_tx_preset_valid
  bit                    gen3_local_tx_preset_valid[16];
  //Field: gen3_local_tx_preset_coeff
  bit [17:0]             gen3_local_tx_preset_coeff[16];

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen3_local_tx_preset;
  bit                    cov_gen3_local_tx_preset_valid;
  bit [17:0]             cov_gen3_local_tx_preset_coeff;

  //--------------------------------------------------------------------------------------------------------------------
  // ltssm_state value required from cdn_pcie_hpa_dev_base_seqr to debug register i_pl_32gts_status_register Field RELBC
  //--------------------------------------------------------------------------------------------------------------------
   bit [5:0] m_ltssm_state;
   bit [2:0] m_pipe_rate;
   bit reg_rst_n;

  //------------------------------------------------------------------------
  //Gen3 Equalization Status Register 1
  //------------------------------------------------------------------------
  //Field: gen3_remote_tx_preset
  bit [3:0]              gen3_remote_tx_preset[16];
  //Field: gen3_remote_tx_preset_valid
  bit                    gen3_remote_tx_preset_valid[16];
  //Field: gen3_remote_tx_preset_coeff
  bit [17:0]             gen3_remote_tx_preset_coeff[16];

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen3_remote_tx_preset;
  bit                    cov_gen3_remote_tx_preset_valid;
  bit [17:0]             cov_gen3_remote_tx_preset_coeff;


  //Field: m_dut_eq_feedback_failure_rate
  // Used to control phy eq feedback_dir_change ouput
  rand bit [3:0]  eq_feedback_failure_rate;
  //Field: delay_feeback_ch_dir_enable
  // Used to control value of feebackchangedir ouptput of phy during  rx_eq evaluation
  rand bit delay_feeback_ch_dir_enable;

  //Field: min_clk_wt_cnt
  // Min count value to delay(clock) the phy_status assertion during rx_eq eval
  int min_clk_wt_cnt = 2;

  //Field: max_clk_wt_cnt
  // Max count value to delay(in clock) the phy_status assertion during rx_eq eval
  int max_clk_wt_cnt = 10;

  //Field: eq_timeout_min_clk_wt_cnt
  // Min count value to delay(clock) the phy_status assertion during rx_eq eval
  int eq_timeout_min_clk_wt_cnt = 1;

  //Field: max_clk_wt_cnt
  // Max count value to delay(in clock) the phy_status assertion during rx_eq eval
  int eq_timeout_max_clk_wt_cnt = 25;

  //Field: ep_eq_bypass_phase23
  // used to enable RP BFM to bypass the equalization at EP DUT side
  rand bit ep_eq_bypass_phase23;


  //Field: speed_change_from_gen2
  // used to create gen5 to gen5 directed scenario
  rand bit speed_change_from_gen2;

  //------------------------------------------------------------------------
  //Gen4 Equalization Control Register 0
  //------------------------------------------------------------------------
  //Field: supp_gen4_preset
  rand bit [10:0]             supp_gen4_presets;
  //Field: default_gen4_tx_preset
  rand bit [3:0]              default_gen4_tx_preset;
  //Field: gen4_max_eval_convergence_count
  rand bit [2:0]              gen4_max_eval_convergence_count;
  //Field: gen4_req_eq_retrain_link
  bit                         gen4_req_eq_retrain_link;
  //Field: gen4_quiesce_guarantee
  rand bit                         gen4_quiesce_guarantee;
  //Field: gen3_max_eq_req_limit
  rand bit [3:0]              gen4_max_eq_req_limit;

  //------------------------------------------------------------------------
  //Gen4 Equalization Control Register 1
  //------------------------------------------------------------------------
  //Field: gen4_eq_debug_sts_lane_sel
  rand bit [3:0]              gen4_eq_debug_sts_lane_sel;

  //Field: gen4_eq_phase2_remote_tx_preset_en
  // bit[4] Gen4 EQ Phase2 Remote Tx Preset Enable, Used only in EP Mode
  rand bit                    gen4_eq_phase2_remote_tx_preset_en;

  //Field: gen4_ep_eqts2_en
  //bit[5]G4EPEQTS2EN : Gen4 EP 128b130b EQ TS2 Enable, used in EP Mode only
  rand bit                    gen4_ep_eqts2_en;

  //Field: gen4_eq_local_override_tx_preset_en
  //bit[6] Gen4 Local Override Tx Preset Enable, used in both EP and RP Mode
  rand bit                    gen4_eq_local_override_tx_preset_en;

  //Field: gen4_eq_phase2_remote_tx_preset
  // bit[11:8] Gen4 EQ Phase2 Remote Tx Preset, Used only in EP Mode.
  rand bit [3:0]              gen4_eq_phase2_remote_tx_preset;

  //Field: gen4_eq_local_override_tx_preset
  // bit[15:12] Gen4 Local Override Tx Preset, used in both EP and RP Mode.
  rand bit [3:0]              gen4_eq_local_override_tx_preset;

  //------------------------------------------------------------------------
  //Gen4 Equalization Status Register 0
  //------------------------------------------------------------------------
  //Field: gen4_local_tx_preset
  bit [3:0]              gen4_local_tx_preset;
  //Field: gen4_local_tx_preset_valid
  bit                    gen4_local_tx_preset_valid;
  //Field: gen4_local_tx_preset_coeff
  bit [17:0]             gen4_local_tx_preset_coeff;

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen4_local_tx_preset;
  bit                    cov_gen4_local_tx_preset_valid;
  bit [17:0]             cov_gen4_local_tx_preset_coeff;

  //------------------------------------------------------------------------
  //Gen4 Equalization Status Register 1
  //------------------------------------------------------------------------
  //Field: gen4_remote_tx_preset
  bit [3:0]              gen4_remote_tx_preset;
  //Field: gen4_remote_tx_preset_valid
  bit                    gen4_remote_tx_preset_valid;
  //Field: gen4_remote_tx_preset_coeff
  bit [17:0]             gen4_remote_tx_preset_coeff;

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen4_remote_tx_preset;
  bit                    cov_gen4_remote_tx_preset_valid;
  bit [17:0]             cov_gen4_remote_tx_preset_coeff;
  //------------------------------------------------------------------------
  //Gen5 Equalization Control Register 0
  //------------------------------------------------------------------------
  //Field: supp_gen5_preset
  rand bit [10:0]             supp_gen5_presets;
  //Field: default_gen5_tx_preset
  rand bit [3:0]              default_gen5_tx_preset;
  //Field: gen5_max_eval_convergence_count
  rand bit [2:0]              gen5_max_eval_convergence_count;
  //Field: gen5_req_eq_retrain_link
  bit                         gen5_req_eq_retrain_link;
  //Field: gen5_quiesce_guarantee
  rand bit                         gen5_quiesce_guarantee;
  //Field: gen5_max_eq_req_limit
  rand bit [3:0]              gen5_max_eq_req_limit;

  //------------------------------------------------------------------------
  //Gen5 Equalization Control Register 1
  //------------------------------------------------------------------------
  //Field: gen5_eq_debug_sts_lane_sel
  rand bit [3:0]              gen5_eq_debug_sts_lane_sel;

  //Field: gen5_eq_phase2_remote_tx_preset_en
  // bit[4] Gen5 EQ Phase2 Remote Tx Preset Enable, Used only in EP Mode
  rand bit                    gen5_eq_phase2_remote_tx_preset_en;

  //Field: gen5_ep_eqts2_en
  //bit[5]G5EPEQTS2EN : Gen5 EP 128b130b EQ TS2 Enable, used in EP Mode only
  rand bit                    gen5_ep_eqts2_en;

  //Field: gen5_eq_local_override_tx_preset_en
  //bit[6] Gen5 Local Override Tx Preset Enable, used in both EP and RP Mode
  rand bit                    gen5_eq_local_override_tx_preset_en;

  //Field: gen5_eq_phase2_remote_tx_preset
  // bit[11:8] Gen5 EQ Phase2 Remote Tx Preset, Used only in EP Mode.
  rand bit [3:0]              gen5_eq_phase2_remote_tx_preset;

  //Field: gen4_eq_local_override_tx_preset
  // bit[15:12] Gen4 Local Override Tx Preset, used in both EP and RP Mode.
  rand bit [3:0]              gen5_eq_local_override_tx_preset;

  //------------------------------------------------------------------------
  //Gen5 Equalization Status Register 0
  //------------------------------------------------------------------------
  //Field: gen5_local_tx_preset
  bit [3:0]              gen5_local_tx_preset;
  //Field: gen5_local_tx_preset_valid
  bit                    gen5_local_tx_preset_valid;
  //Field: gen5_local_tx_preset_coeff
  bit [17:0]             gen5_local_tx_preset_coeff;

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen5_local_tx_preset;
  bit                    cov_gen5_local_tx_preset_valid;
  bit [17:0]             cov_gen5_local_tx_preset_coeff;
  //------------------------------------------------------------------------
  //Gen5 Equalization Status Register 1
  //------------------------------------------------------------------------
  //Field: gen5_remote_tx_preset
  bit [3:0]              gen5_remote_tx_preset;
  //Field: gen5_remote_tx_preset_valid
  bit                    gen5_remote_tx_preset_valid;
  //Field: gen5_remote_tx_preset_coeff
  bit [17:0]             gen5_remote_tx_preset_coeff;

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen5_remote_tx_preset;
  bit                    cov_gen5_remote_tx_preset_valid;
  bit [17:0]             cov_gen5_remote_tx_preset_coeff;

  //------------------------------------------------------------------------
  //Gen6 Equalization Control Register 0
  //------------------------------------------------------------------------
  //Field: supp_gen6_preset
  rand bit [10:0]             supp_gen6_presets;
  //Field: default_gen6_tx_preset
  rand bit [3:0]              default_gen6_tx_preset;
  //Field: gen6_max_eval_convergence_count
  rand bit [2:0]              gen6_max_eval_convergence_count;
  //Field: gen6_req_eq_retrain_link
  bit                         gen6_req_eq_retrain_link;
  //Field: gen6_quiesce_guarantee
  rand bit                    gen6_quiesce_guarantee;
  //Field: gen6_max_eq_req_limit
  rand bit [3:0]              gen6_max_eq_req_limit;

  //------------------------------------------------------------------------
  //Gen6 Equalization Control Register 1
  //------------------------------------------------------------------------
  //Field: gen6_eq_debug_sts_lane_sel
  rand bit [3:0]              gen6_eq_debug_sts_lane_sel;

  //Field: gen6_eq_phase2_remote_tx_preset_en
  // bit[4] Gen6 EQ Phase2 Remote Tx Preset Enable, Used only in EP Mode
  rand bit                    gen6_eq_phase2_remote_tx_preset_en;

  //Field: gen6_ep_eqts2_en
  //bit[5]G6EPEQTS2EN : Gen6 EP 128b130b EQ TS2 Enable, used in EP Mode only
  rand bit                    gen6_ep_eqts2_en;

  //Field: gen6_eq_local_override_tx_preset_en
  //bit[6] Gen6 Local Override Tx Preset Enable, used in both EP and RP Mode
  rand bit                    gen6_eq_local_override_tx_preset_en;

  //Field: gen6_eq_phase2_remote_tx_preset
  // bit[11:8] Gen6 EQ Phase2 Remote Tx Preset, Used only in EP Mode.
  rand bit [3:0]              gen6_eq_phase2_remote_tx_preset;

  //Field: gen4_eq_local_override_tx_preset
  // bit[15:12] Gen4 Local Override Tx Preset, used in both EP and RP Mode.
  rand bit [3:0]              gen6_eq_local_override_tx_preset;
//------------------------------------------------------------------------
  //Gen6 Equalization Status Register 1
  //------------------------------------------------------------------------
  //Field: gen6_remote_tx_preset
  bit [3:0]              gen6_remote_tx_preset;
  //Field: gen6_remote_tx_preset_valid
  bit                    gen6_remote_tx_preset_valid;
  //Field: gen6_remote_tx_preset_coeff
  bit [23:0]             gen6_remote_tx_preset_coeff;

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen6_remote_tx_preset;
  bit                    cov_gen6_remote_tx_preset_valid;
  bit [23:0]             cov_gen6_remote_tx_preset_coeff;

  `ifdef PCIE_GEN7
  //------------------------------------------------------------------------
  //Gen7 Equalization Control Register 0
  //------------------------------------------------------------------------
  //Field: supp_gen7_preset
  rand bit [10:0]             supp_gen7_presets;
  //Field: default_gen7_tx_preset
  rand bit [3:0]              default_gen7_tx_preset;
  //Field: gen7_max_eval_convergence_count
  rand bit [2:0]              gen7_max_eval_convergence_count;
  //Field: gen7_req_eq_retrain_link
  bit                         gen7_req_eq_retrain_link;
  //Field: gen7_quiesce_guarantee
  rand bit                    gen7_quiesce_guarantee;
  //Field: gen7_max_eq_req_limit
  rand bit [3:0]              gen7_max_eq_req_limit;

  //------------------------------------------------------------------------
  //Gen7 Equalization Control Register 1
  //------------------------------------------------------------------------
  //Field: gen7_eq_debug_sts_lane_sel
  rand bit [3:0]              gen7_eq_debug_sts_lane_sel;

  //Field: gen7_eq_phase2_remote_tx_preset_en
  // bit[4] Gen7 EQ Phase2 Remote Tx Preset Enable, Used only in EP Mode
  rand bit                    gen7_eq_phase2_remote_tx_preset_en;

  //Field: gen7_ep_eqts2_en
  //bit[5]G7EPEQTS2EN : Gen7 EP 128b130b EQ TS2 Enable, used in EP Mode only
  rand bit                    gen7_ep_eqts2_en;

  //Field: gen7_eq_local_override_tx_preset_en
  //bit[6] Gen7 Local Override Tx Preset Enable, used in both EP and RP Mode
  rand bit                    gen7_eq_local_override_tx_preset_en;

  //Field: gen7_eq_phase2_remote_tx_preset
  // bit[11:8] Gen7 EQ Phase2 Remote Tx Preset, Used only in EP Mode.
  rand bit [3:0]              gen7_eq_phase2_remote_tx_preset;

  //Field: gen4_eq_local_override_tx_preset
  // bit[15:12] Gen4 Local Override Tx Preset, used in both EP and RP Mode.
  rand bit [3:0]              gen7_eq_local_override_tx_preset;

  //------------------------------------------------------------------------
  //Gen7 Equalization Status Register 0
  //------------------------------------------------------------------------
  //Field: gen7_local_tx_preset
  bit [3:0]              gen7_local_tx_preset;
  //Field: gen7_local_tx_preset_valid
  bit                    gen7_local_tx_preset_valid;
  //Field: gen7_local_tx_preset_coeff
  bit [23:0]             gen7_local_tx_preset_coeff;

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen7_local_tx_preset;
  bit                    cov_gen7_local_tx_preset_valid;
  bit [23:0]             cov_gen7_local_tx_preset_coeff;
  //------------------------------------------------------------------------
  //Gen7 Equalization Status Register 1
  //------------------------------------------------------------------------
  //Field: gen7_remote_tx_preset
  bit [3:0]              gen7_remote_tx_preset;
  //Field: gen7_remote_tx_preset_valid
  bit                    gen7_remote_tx_preset_valid;
  //Field: gen7_remote_tx_preset_coeff
  bit [23:0]             gen7_remote_tx_preset_coeff;

  //The below temp variables are used only for functional coverage purpose
  bit [3:0]              cov_gen7_remote_tx_preset;
  bit                    cov_gen7_remote_tx_preset_valid;
  bit [23:0]             cov_gen7_remote_tx_preset_coeff;
  `endif //PCIE_GEN7

  //below variable is used to create directed scenario which enables preset
  //feedback both on DUT and BFM and side
  rand bit               use_preset_scenario;

  //use_preset per lane. set by bfm in Eq.Ph2 for RP DUT
  //and Eq.Ph3 for EP DUT
  rand bit [15:0]        bfm_tx_use_preset;

  //Gen6  Error injection 
  rand bit              m_err_inj_en;
  rand bit              m_err_inj_os_tx;
  rand bit              m_err_inj_os_rx;
  rand bit  [4:0]       m_err_inj_num;
  rand bit  [7:0]       m_err_inj_num_space;
  rand bit              m_err_inj_ts0_os;
  rand bit              m_err_inj_ts1_os;
  rand bit              m_err_inj_ts2_os;
  rand bit              m_err_inj_skp_os;
  rand bit              m_err_inj_eieos_os;
  rand bit              m_err_inj_eios_os;
  rand bit              m_err_inj_sds_os;
  rand bit              m_err_inj_polling_state;
  rand bit              m_err_inj_config_state;
  rand bit              m_err_inj_l0_state;
  rand bit              m_err_inj_non_eq_rec_state;
  rand bit              m_err_inj_eq_ph0_1_state;
  rand bit              m_err_inj_eq_ph2_state;
  rand bit              m_err_inj_eq_ph3_state;

  rand bit   [15:0]     m_err_inj_sel_byte;
  rand bit   [15:0]     m_err_inj_lane_num;

  //Gen6  Error injection
  bit                   m_enable_flit_err_inj;
  bit                   m_enable_reg_based_flit_err_inj;
  
  rand bit [4:0] m_fei_num_inj;
  rand bit [7:0] m_fei_inj_space;
  rand bit [2:0] m_fei_cons_inj;
  rand bit [6:0] m_fei_err_offset;
  rand bit [7:0] m_fei_err_mag;
  bit       	 m_fei_en;
  rand bit 	 m_fei_tx;
  bit            m_fei_chk_en;
  bit 	   [1:0] m_fei_err_stat;
  
  // FEI Checker enable for FlitType 5/6 validation
  bit            m_fei_checker_en;

  //---------------------------------------------------------------------------
  // FLIT ERROR COUNTER CONFIGURATION
  //---------------------------------------------------------------------------
  rand bit       m_flit_err_cnt_en;           // FLERCTEN - Enable error counter
  rand bit       m_flit_err_cnt_intr_en;      // FLERCTINTEN - Enable interrupt
  rand bit [1:0] m_flit_err_events_to_count;  // EVTOCNT - Events to count
  rand bit [7:0] m_flit_err_trigger_event;    // TREVEC - Trigger event threshold

  //---------------------------------------------------------------------------
  // FBER MEASUREMENT CONFIGURATION
  //---------------------------------------------------------------------------
  rand bit       m_fber_en;                   // FBMSREN - Enable FBER measurement
  rand bit [1:0] m_fber_gran_per_lane_err;    // GRPERLNER - Granularity
  rand bit       m_fber_report_longest_burst; // REPLBFB - Report longest burst

  bit [1:0] m_err_inj_tx;
  bit [1:0] m_err_inj_rx;

  //------------------------------------------------------------------------
  //Eq Debug FIFO Ctrl Register
  //------------------------------------------------------------------------
  //Field: clear_all_capture
  bit                    clear_all_capture;
  //Field: capture_lane_sel
  bit [3:0]              capture_lane_sel;
  //Field: capture_eq_ph_sel
  bit [1:0]              capture_eq_ph_sel;
  //Field: capture_eq_speed_sel
  bit [2:0]              capture_eq_speed_sel;
  //Field: eq_debug_capture_beh
  bit                    eq_debug_capture_beh;

  //------------------------------------------------------------------------
  //Eq Debug FIFO Status 0 Register
  //------------------------------------------------------------------------
  //Field: eq_dbg_local_fs
  bit [5:0]              local_fs;
  //Field: eq_dbg_local_lf
  bit [5:0]              eq_dbg_local_lf;
  //Field: eq_dbg_remote_fs
  bit [5:0]              remote_fs;
  //Field: eq_dbg_remote_lf
  bit [5:0]              eq_dbg_remote_lf;

  //------------------------------------------------------------------------
  //Eq Debug FIFO Status 1 Register
  //------------------------------------------------------------------------
  //Field: eq_dbg_coeff
  bit [17:0]             eq_dbg_coeff;
  //Field: eq_dbg_local_lf
  bit [3:0]              eq_dbg_preset;
  //Field: eq_dbg_preset_valid
  bit                    eq_dbg_preset_valid;
  //Field: eq_dbg_coeff_rej
  bit                    eq_dbg_coeff_rej;
  //Field: eq_dbg_dir_feedback
  bit [5:0]              eq_dbg_dir_feedback;
  //Field: eq_dbg_dir_feedback
  bit [1:0]              eq_dbg_eq_phase;

  //------------------------------------------------------------------------
  //Lane Margining at Receiver Parameters 1 Register
  //------------------------------------------------------------------------
  //Field: m_VoltageSupported
  rand bit               m_VoltageSupported;
  //Field: m_IndUpDownVoltage
  rand bit               m_IndUpDownVoltage;
  //Field: m_IndLeftRightTiming
  rand bit               m_IndLeftRightTiming;
  //Field: m_SampleReportingMethod
  rand bit               m_SampleReportingMethod;
  //Field: m_IndErrorSampler
  rand bit               m_IndErrorSampler;
  //Field: m_NumVoltageSteps
  rand bit [6:0]         m_NumVoltageSteps;
  //Field: m_NumTimingSteps
  rand bit [5:0]         m_NumTimingSteps;
  //Field: m_MaxTimingOffset
  rand bit [5:0]         m_MaxTimingOffset;
  //Field: m_MaxVoltageOffset
  rand bit [5:0]         m_MaxVoltageOffset;

  //------------------------------------------------------------------------
  //Lane Margining at Receiver Parameters 2 Register
  //------------------------------------------------------------------------
  //Field: m_SamplingRateVoltage
  rand bit [5:0]              m_SamplingRateVoltage;
  //Field: m_SamplingRateTiming
  rand bit [5:0]              m_SamplingRateTiming;
  //Field: m_MaxLanes
  rand bit [4:0]              m_MaxLanes;

  //------------------------------------------------------------------------
  //Lane Margining at Receiver Local Control Register
  //------------------------------------------------------------------------
  //Field: m_MarginingSoftReset
  bit                    m_MarginingSoftReset;
  //Field: m_AcceptMarginingCmdNonGen4
  rand bit               m_AcceptMarginingCmdNonGen4;
  //Field: m_DisableMarginStatusUpdateSampleCount
  rand bit               m_DisableMarginStatusUpdateSampleCount;
  //Field: m_EnableStepMarginStatusUpdateClearLog
  rand bit               m_EnableStepMarginStatusUpdateClearLog;
  //Field: m_WriteAckWaitTimerCtrl
  rand bit [1:0]         m_WriteAckWaitTimerCtrl;

  //------------------------------------------------------------------------
  //Lane Margining at Receiver Error Status 1 Register
  //------------------------------------------------------------------------
  //Field: m_InvalidSwMarginingCmd
  bit [15:0]             m_InvalidSwMarginingCmd;
  //Field: m_InvalidSwMarginingCmdLaneNum
  bit [3:0]              m_InvalidSwMarginingCmdLaneNum;

  //------------------------------------------------------------------------
  //Lane Margining at Receiver Error Status 2 Register
  //------------------------------------------------------------------------
  //Field: m_InvalidPhyMarginingCmd
  bit [7:0]              m_InvalidPhyMarginingCmd;
  //Field: m_InvalidPhyMarginingCmdLaneNum
  bit [3:0]              m_InvalidPhyMarginingCmdLaneNum;
  //Field: m_WriteAckTimeoutLaneNum
  bit [3:0]              m_WriteAckTimeoutLaneNum;
  //Field: m_UexpectedPhyResponse
  bit [3:0]              m_UexpectedPhyResponse;

  //------------------------------------------------------------------------
  //LTSSM Timer Control 0
  //------------------------------------------------------------------------
  //Field: m_lm_ltssm_1ms_time_interval
  rand bit [11:0]             m_lm_ltssm_1ms_time_interval;
  //Field: m_lm_ltssm_2ms_time_interval
  rand bit [11:0]              m_lm_ltssm_2ms_time_interval;
  //Field: m_lm_disable_phy_ltssm_timers
  rand bit                    m_lm_disable_phy_ltssm_timers;
  //Field: m_lm_enable_fast_link_training
  rand bit                    m_lm_enable_fast_link_training;

  //------------------------------------------------------------------------
  //LTSSM Timer Control 1
  //------------------------------------------------------------------------
  //Field: m_lm_ltssm_4ms_time_interval
  rand bit [15:0]             m_lm_ltssm_4ms_time_interval;
  //Field: m_lm_ltssm_8ms_time_interval
  rand bit [15:0]             m_lm_ltssm_8ms_time_interval;

  //------------------------------------------------------------------------
  //LTSSM Timer Control 2
  //------------------------------------------------------------------------
  //Field: m_lm_ltssm_12ms_time_interval
  rand bit [15:0]             m_lm_ltssm_12ms_time_interval;
  //Field: m_lm_ltssm_24ms_time_interval
  rand bit [15:0]             m_lm_ltssm_24ms_time_interval;

  //------------------------------------------------------------------------
  //LTSSM Timer Control 3
  //------------------------------------------------------------------------
  //Field: m_lm_ltssm_32ms_time_interval
  rand bit [15:0]             m_lm_ltssm_32ms_time_interval;
  //Field: m_lm_ltssm_48ms_time_interval
  rand bit [15:0]             m_lm_ltssm_48ms_time_interval;
  //Field: m_lm_ltssm_96ms_time_interval
  rand bit [15:0]             m_lm_ltssm_96ms_time_interval;


  //------------------------------------------------------------------------
  //LTSSM Timer Control 4
  //------------------------------------------------------------------------
  //Field: m_lm_ltssm_64ms_time_interval
  rand bit [15:0]             m_lm_ltssm_64ms_time_interval;

  //------------------------------------------------------------------------
  //Gen3 NoEq Restore Lane[0-15] Register
  //------------------------------------------------------------------------
  //Field: m_lm_gen3_noeq_restore_prec[16]
  rand bit [5:0]             m_lm_gen3_noeq_restore_prec[16];
  //Field: m_lm_gen3_noeq_restore_c0[16]
  rand bit [5:0]             m_lm_gen3_noeq_restore_c0[16];
  //Field: m_lm_gen3_noeq_restore_postc[16]
  rand bit [5:0]             m_lm_gen3_noeq_restore_postc[16];

  //The following temp variables are used only for functional coverage purpose
  rand bit [5:0]             cov_gen3_noeq_restore_prec;
  rand bit [5:0]             cov_gen3_noeq_restore_c0;
  rand bit [5:0]             cov_gen3_noeq_restore_postc;

  //------------------------------------------------------------------------
  //Gen4 NoEq Restore Lane[0-15] Register
  //------------------------------------------------------------------------
  //Field: m_lm_gen4_noeq_restore_prec[16]
  rand bit [5:0]             m_lm_gen4_noeq_restore_prec[16];
  //Field: m_lm_gen4_noeq_restore_c0[16]
  rand bit [5:0]             m_lm_gen4_noeq_restore_c0[16];
  //Field: m_lm_gen4_noeq_restore_postc[16]
  rand bit [5:0]             m_lm_gen4_noeq_restore_postc[16];

  //The following temp variables are used only for functional coverage purpose
  rand bit [5:0]             cov_gen4_noeq_restore_prec;
  rand bit [5:0]             cov_gen4_noeq_restore_c0;
  rand bit [5:0]             cov_gen4_noeq_restore_postc;
  //------------------------------------------------------------------------
  //Gen5 NoEq Restore Lane[0-15] Register
  //------------------------------------------------------------------------
  //Field: m_lm_gen5_noeq_restore_prec[16]
  rand bit [5:0]             m_lm_gen5_noeq_restore_prec[16];
  //Field: m_lm_gen5_noeq_restore_c0[16]
  rand bit [5:0]             m_lm_gen5_noeq_restore_c0[16];
  //Field: m_lm_gen5_noeq_restore_postc[16]
  rand bit [5:0]             m_lm_gen5_noeq_restore_postc[16];
  //Field: m_lm_gen5_noeq_restore_precode_enable[16]
  bit                   m_lm_gen5_noeq_restore_precode_enable;

  //The following temp variables are used only for functional coverage purpose
  rand bit [5:0]             cov_gen5_noeq_restore_prec;
  rand bit [5:0]             cov_gen5_noeq_restore_c0;
  rand bit [5:0]             cov_gen5_noeq_restore_postc;
  //------------------------------------------------------------------------
  //Gen6 NoEq Restore Lane[0-15] Register
  //------------------------------------------------------------------------
  //Field: m_lm_gen6_noeq_restore_prec[16]
  rand bit [5:0]             m_lm_gen6_noeq_restore_prec[16];
  //Field: m_lm_gen6_noeq_restore_c0[16]
  rand bit [5:0]             m_lm_gen6_noeq_restore_c0[16];
  //Field: m_lm_gen6_noeq_restore_postc[16]
  rand bit [5:0]             m_lm_gen6_noeq_restore_postc[16];
  //Field: m_lm_gen6_noeq_restore_prec_2nd[16]
  rand bit [5:0]             m_lm_gen6_noeq_restore_prec_2nd[16];
  //Field: m_lm_gen6_noeq_restore_precode_enable[16]
  bit                        m_lm_gen6_noeq_restore_precode_enable;

  //The following temp variables are used only for functional coverage purpose
  rand bit [5:0]             cov_gen6_noeq_restore_prec;
  rand bit [5:0]             cov_gen6_noeq_restore_c0;
  rand bit [5:0]             cov_gen6_noeq_restore_postc;
  rand bit [5:0]             cov_gen6_noeq_restore_prec_2nd;
  `ifdef PCIE_GEN7
  //------------------------------------------------------------------------
  //Gen7 NoEq Restore Lane[0-15] Register
  //------------------------------------------------------------------------
  //Field: m_lm_gen7_noeq_restore_prec[16]
  rand bit [5:0]             m_lm_gen7_noeq_restore_prec[16];
  //Field: m_lm_gen7_noeq_restore_c0[16]
  rand bit [5:0]             m_lm_gen7_noeq_restore_c0[16];
  //Field: m_lm_gen7_noeq_restore_postc[16]
  rand bit [5:0]             m_lm_gen7_noeq_restore_postc[16];
  //Field: m_lm_gen7_noeq_restore_prec_2nd[16]
  rand bit [5:0]             m_lm_gen7_noeq_restore_prec_2nd[16];
  //Field: m_lm_gen7_noeq_restore_precode_enable[16]
  bit                        m_lm_gen7_noeq_restore_precode_enable;

  //The following temp variables are used only for functional coverage purpose
  rand bit [5:0]             cov_gen7_noeq_restore_prec;
  rand bit [5:0]             cov_gen7_noeq_restore_c0;
  rand bit [5:0]             cov_gen7_noeq_restore_postc;
  rand bit [5:0]             cov_gen7_noeq_restore_prec_2nd;
  `endif //PCIE_GEN7
  //PL - VIP Specific config variables
  //Field: m_bfm_lane_sym_skew[]
  //This field controls the lane skew (in symbols) from BFM side
  rand bit [3:0] m_bfm_lane_sym_skew [];
  //PL - VIP Specific config variables
  //Field: m_bfm_lane_sym_skew_running[]
  //This field controls the lane skew (in symbols) from BFM side running during simulation
  rand bit [3:0] m_bfm_lane_sym_skew_running [];
  //Field: enable_skew_insert_block
  //This field is used to enable the skew_insert_block residing between BFM and DUT RX
  //This is required and VIP doesn't support insertion of skew beyond 7 symbols
  rand bit       enable_skew_insert_block; //Enable skew insertion through skew insertion model
  //Field: max_skew_for_skew_insert_block[]
  //This field controls the max symbol skew inserted by skew insert block
  rand bit [4:0] max_skew_for_skew_insert_block[]; //Index represents lane
  //Field: max_skew_for_skew_insert_block_running[]
  //This field controls the max symbol skew inserted by skew insert block running during simulation
  rand bit [4:0] max_skew_for_skew_insert_block_running[]; //Index represents lane

  //Field: total_static_skew[]
  //This field keeps track of bfm_lane_sym_skew+skew_for_skew_insert_block
  rand bit [31:0] total_static_skew[]; //Index represents lane

  //Field: total_static_skew_running[]
  //This field keeps track of bfm_lane_sym_skew+skew_for_skew_insert_block changing during simulation
  rand bit [31:0] total_static_skew_running[]; //Index represents lane

  //Field: dis_static_skew_updates_on_rxelec_exit
  //This field controls whether static skew needs to be changed everytime when the link
  //enters rx_elecidle.
  //0 - By default, the static skews can be changed when RxElecIdle is set
  //1 - the static skews are not changed when RxElecIdle is set
  rand bit       dis_static_skew_updates_on_rxelec_exit;
  //Field: m_bfm_lane_reversal
  //This field controls lane reversal in bfm - lanes are reversed and so the lane numbers
  rand bit        m_bfm_lane_reversal;
  //Field: m_bfm_lane_reversal_initNum
  //This field controls lane reversal in bfm - lanes are not reversed and only lane numbers are driven in reverse manner
  rand bit        m_bfm_lane_reversal_initNum;
  //Field: m_bfm_lane_polarity_inversion
  //This field controls lane polarity inversion for each lane from bfm
  rand bit [15:0] m_bfm_lane_polarity_inversion;

  //------------------------------------------------------------------------
  //Disable Auto Speed Change : i_cfg_4[29:24]
  // auto_speed_change_dis[0] : Gen2
  // auto_speed_change_dis[1] : Gen3
  // auto_speed_change_dis[2] : Gen4
  // auto_speed_change_dis[3] : Gen5
  // auto_speed_change_dis[4] : Gen6
  // auto_speed_change_dis[5] : Gen7
  //------------------------------------------------------------------------
  rand bit [5:0] auto_speed_change_dis;


  //LM Registers : TL - Start
  //i_tl_ctrl
  rand bit [2:0]              max_dllps_space_per_clk; //0 : no limit
  rand bit                    dis_fc_update;  //1: If no updateFc, link retrain will happen
  rand bit                    en_ob_pkt_on_fce;

  //i_tl_rx_ctrl
  rand bit                    dis_order_chk_cpl;
  rand bit                    dis_order_chk_np;
  rand bit                    tl2hls_linkdown_reset_beh; //0: Delayed reset  1: Immediate reset(Packet truncation)
  rand bit                    fc_type_none_as_malformed; //0: Silent Discard 1: Malformed

  //i_tl_fc_timeout
  rand bit [31:0]             flow_ctrl_up_timeout_val; //Units of 16ns. default 20'd12800

  //i_tl_arb_wgt_ctrl_0
  rand bit [7:0]              cpl_weightage_p_np_cpl; //Power of 2 (0 to 10)
  rand bit [7:0]              np_weightage_p_np_cpl; //Power of 2 (0 to 10)
  rand bit [7:0]              p_weightage_p_np_cpl; //Power of 2 (0 to 10)
  rand bit [3:0]              np_weightage_np_loc_np; //Power of 2 (0 to 10)
  rand bit [3:0]              local_np_weightage_np_loc_np; //Power of 2 (0 to 10)

  //i_tl_arb_wgt_ctrl_1
  rand bit [7:0]              p_weightage_p_loc_p; //Power of 2 (0 to 10);
  rand bit [7:0]              loc_p_weightage_p_loc_p; //Power of 2 (0 to 10);
  rand bit [7:0]              cpl_weightage_cpl_loc_cpl; //Power of 2 (0 to 10);
  rand bit [7:0]              loc_cpl_weightage_cpl_loc_cpl; //Power of 2 (0 to 10);

  //i_tl_arb_wgt_ctrl_2
  rand bit [7:0]              cif0_weightage; //Power of 2 (0 to 10);
  rand bit [7:0]              cif1_weightage; //Power of 2 (0 to 10);
  rand bit [7:0]              cif2_weightage; //Power of 2 (0 to 10);
  rand bit [7:0]              cif3_weightage; //Power of 2 (0 to 10);

  //i_tl_arb_wgt_ctrl_3
  rand bit [7:0]              cif4_weightage; //Power of 2 (0 to 10);
  rand bit [7:0]              cif5_weightage; //Power of 2 (0 to 10);
  rand bit [7:0]              cif6_weightage; //Power of 2 (0 to 10);
  rand bit [7:0]              cif7_weightage; //Power of 2 (0 to 10);

  //i_tl_credit_upd_ctrl
  rand bit [5:0]              tlp_count_threshold_for_upfc_tx; //default: 0
  rand bit [9:0]              max_delays_of_clk_tx_upfc; //On TLP Rx max clks to send updatefc

  //i_tl_debug_sts - only for coverage purpose
  bit                         fce_due_to_illegal_space;
  bit                         fce_due_to_mismatch_scale_factor;
  bit                         fce_due_to_mismatch_less_mps;
  bit                         fce_cause_retrain_link;
  bit                         fce_due_to_remote_not_suff_credit;

  //i_tl_debug_rem_avl_spc_0/1/2 - AVailable P hdr & data creidts
  //Arrayed for 8VCs
  //Only for coverage
  bit [11:0]                  avail_p_hdr_fc[8];
  bit [15:0]                  avail_p_data_fc[8];
  bit [11:0]                  avail_np_hdr_fc[8];
  bit [15:0]                  avail_np_data_fc[8];
  bit [11:0]                  avail_cpl_hdr_fc[8];
  bit [15:0]                  avail_cpl_data_fc[8];

  //i_tl_debug_tx_cred_cons_0/1/2
  //Arrayed for 8VCs
  //Only for coverage
  bit [11:0]                  cons_p_hdr_fc[8];
  bit [15:0]                  cons_p_data_fc[8];
  bit [11:0]                  cons_np_hdr_fc[8];
  bit [15:0]                  cons_np_data_fc[8];
  bit [11:0]                  cons_cpl_hdr_fc[8];
  bit [15:0]                  cons_cpl_data_fc[8];

  //i_tl_debug_rx_cred_lim_0/1/2
  //Arrayed for 8VCs
  //Only for coverage
  bit [11:0]                  cred_limit_p_hdr_fc[8];
  bit [15:0]                  cred_limit_p_data_fc[8];
  bit [11:0]                  cred_limit_np_hdr_fc[8];
  bit [15:0]                  cred_limit_np_data_fc[8];
  bit [11:0]                  cred_limit_cpl_hdr_fc[8];
  bit [15:0]                  cred_limit_cpl_data_fc[8];

  //Only for coverage
  //Arrayed for 8VCs
  //i_tl_debug_remote_fc
  bit [1:0]                  p_hdr_scale[8];
  bit [1:0]                  p_data_scale[8];
  bit [1:0]                  np_hdr_scale[8];
  bit [1:0]                  np_data_scale[8];
  bit [1:0]                  cpl_hdr_scale[8];
  bit [1:0]                  cpl_data_scale[8];

  bit                        default_cred_init;
  rand bit                        all_vc_zero_shared_cred_dut;
  rand bit                        all_vc_zero_shared_cred_vip;
  //Bit[0]: PH   Bit[1]: PD   Bit[2]:NPH  Bit[3]:NPD  Bit[4]: CPLH Bit[5]: CPLD
  //Will determine which fc_type to be made with zero shared credit for all vc.
  //Meaningful only when all_vc_zero_shared_cred_dut/all_vc_zero_shared_cred_vip is one
  rand bit [5:0]             all_vc_zero_shared_cred_fc_type; 

  //Disabling zero credit randomization by default in multi vc case due to multiple VIPSRs 46746039, 46746153, 46740511, 46728922
  //Enabled by default as all these issues are fixed
  bit                        enable_zero_credit_randomization;

  //TODO: Disabling segmentation by default in FM due to VIPSR 46743736 [VIP don't support as of now]
  //Enable by default once all these issues are fixed
  bit                        enable_segmentation;

  //LM Registers : TL - End

  //LM Registers : HLS - Start
  //i_hal_ctrl
  // Host adaptation layer control0 register
  // bit[0] - Enable detection of invalid message code errors
  rand bit                   en_inv_msg_code;
  // bit[1] - Treat rx poisoned tlp as advisory non fatal
  rand bit                   treat_pois_tlp_as_adv_nonfatal; //def 0
  // bit[2] - Treat cpl targets a function in non-D0 as unexpected completion
  rand bit                   cpl_hit_nond0_fn_as_uc; //def 0
  // bit[3] - Treat cpl targets a function in FLR as unexpected completion. if not set, silently drop cpl
  rand bit                   drop_cpl_hit_fn_in_flr; //def: 0 (treat as UC and drop cpl)
  // bit[4] - Enable locked reads in IB path for legacy Softwares.
  rand bit                   en_mrdlk_ib;
  // bit[5] - Disable Checking of TLP crossing a BAR
  rand bit                   dis_chk_of_tlp_crossing_bar; //default: 0
  // bit[6] - Disable VDM Type0 Support
  rand bit                   dis_vdm_type0_supp; //default: 0
  // bit[8] - Disable outbound P-NP order checking
  rand bit                   dis_p_np_ob_order_chk;
  // bit[9] - Disable outbound P-CPL order checking
  rand bit                   dis_p_cpl_ob_order_chk;
  // bit[10] - Disable inbound P-NP order checking
  rand bit                   dis_p_np_ib_order_chk;
  // bit[11] - Disable inbound P-CPL order checking
  rand bit                   dis_p_cpl_ib_order_chk;
  // bit[12] - Disable inbound P-P order checking. Strict ordered P vs all Ps in different IDGs
  rand bit                   dis_p_p_ib_order_chk;
  // bit[13] - Use inbound HLS posted accept as the final posted accept for order-check - default:0
  // IF set to 1, controller do not use posted_delivered signal
  rand bit                   dis_post_delivered_signal_for_ord_chk; //Default 0
  // bit[14] - Disable outbound order check between Posted and local messages from pins
  rand bit                   dis_ob_order_chk; //default 0
  // bit[15] - Disable inbound order check while link_down_in_progress is asserted. default:1
  // Enabled quick clearing of buffers.
  rand bit                   dis_ib_order_chk_on_link_down; //default 1
  // bit[16] - Give preference to FLR-CPL, this might back-pressure normal completions
  rand bit                   pref_to_flr_cpl; //default 0
  // bit[17] - Discard BAD completions. If set unexpected and malformed completions are discarded. default:1
  // When bad completions are discarded (Default Behavior), no status is updated from bad completions. Unexpected and malformed completions are expected to be discarded. New correct completions are accepted from host. If host is not sending good completions, completion timeout will occur for pending np_requests. Malformed and unexpected completions are not forwarded to HLS interface. when bad completions are not discarded: Invalid_tag completions are still discarded for tag and pending_status update. Invalid tag completions are also not forwarded to HLS interface. For non-invalid tag bad completions, Tags are released upon receiving them. np_pending status is also updated. Completions with no invalid-tag-errors are forwarded to AL logic, AL logic can quickly generate error without waiting for completion timeout.
  rand bit                   dis_tag_release_on_bad_cpl; //default 0
  // bit[18] - Force BAR check in RP mode. if set, TLPs are marked UR if not hitting any BAR in RP mode.
  rand bit                   force_bar_chk_rp; //1 : if not hit in Bar, UR reported
  rand bit                   link_down_event_hal; //1 : Create link_down event in HAL
  // bit[19] - Create link_down event in HAL. This is used for debug purpose only. This simulates a condition similar to
  // HLS block receiving link-down event from PHY layer. all link-down mechanisms are activated when this field is set. Host has to clear this field to remove simulated LD condition.
  bit                        dbg_link_down_rst_hal;  //ONly for debug purpose
  // bit[20] - Treat unexpected MEM-RD-completions with Byte-count and low-address mismatch as malformed.
  rand bit                   cpl_bytecount_lower_add_mf;
  // bit[24] - Disable RCRB BAR for CXL. Valid only for CXL configurations.
  // bit[28]: Disable RCB violation checks for inbound completions.
  rand bit                   cpl_ib_dis_rcb_violation;
  // bit[29]: Disable low address checks for inbound completions.
  rand bit                   cpl_ib_dis_lower_addr_check;
  // bit[30]: Disable check on byte_count field and actual pending byte-count from request for inbound completions.
  rand bit                   cpl_ib_dis_byte_count_check;
  // bit[31]: Disable check on length field for inbound completions.
  rand bit                   cpl_ib_dis_length_check;

  // bit[0]: Enable DUT to send the Config0 packet to Client.
  rand bit                   send_cfg0_to_al;
  // bit[1]: Enable DUT to send the Config1 packet to Client.
  rand bit                   send_cfg1_to_al;
  // bit[2]: Enable DUT to Detect the invalid Segment number for RP inbound packets MSG or MEM.
  rand bit                   detect_invalid_seg_err;


  //i_hal_ctrl_hls
  rand bit                   discard_chk_bit_from_client; //default: 0
  rand bit                   en_l1_x_no_deact_hint_in_cif; //default: 0
  rand bit                   en_l1x_even_pend_tags_present; //default: 0
  rand bit                   not_send_end_err; //default: 0 useful when packet terminated due to LD reset in middle
  rand bit                   set_ld_in_progress; //default: 0
  rand bit                   stop_hls_if_when_vc_not_active; //default: 1
  rand bit                   stop_hls_if_on_link_down; //default: 1
  rand bit                   stop_ib_hls_if_on_entry_l1; //default: 1
  rand bit                   stop_ib_hls_if_rxpipeline_empty; //default:1

  //i_hal_ctrl_link_down_to
  rand bit [31:0]            timeout_to_rst_linkdown_in_progress; //default: 0 (Value in 1us)

  //i_hal_ctrl_dec_tlp_filter
  rand bit                   filter_ur_tlp; //default: 1
  rand bit                   filter_poison_uncorr_tlp; //default:
  rand bit                   filter_poison_adv_tlp; //default:
  rand bit                   filter_tlps_silent_discard; //default:
  rand bit                   filter_poisoned_cpls; //default:
  rand bit                   filter_acs_violation_tlp; //default:
  rand bit                   filter_unexp_cpls_val_tag; //default:
  rand bit                   filter_cpls_inv_tag; //default:
  rand bit                   filter_ide_msg; //default:
  rand bit                   filter_pm_pme_msg; //default:
  rand bit                   filter_drs_msg; //default:
  rand bit                   filter_ptm_msg; //default:
  rand bit                   filter_pmeturnoff_msg; //default:
  rand bit                   filter_pmact_nak_msg; //default:
  rand bit                   filter_ltr_msg; //default:
  rand bit                   filter_slot_pwr_msg; //default:
  rand bit                   filter_err_msg; //default:
  rand bit                   filter_intx_msg; //default:

  //lm_hal_sbsa_control
  rand bit                   ob_cfg_transaction_check;
  rand bit                   check_bme_for_ep_outbound;
  rand bit                   check_bme_for_rp_inbound;
  rand bit                   check_io_mem_space_en_for_outbound;
  rand bit                   check_mem_base_limit_en_for_outbound;
  rand bit                   consume_cfg_type0;
  rand bit                   en_rrs_retry;
  rand bit                   use_bus_num_from_cfg_space;//1: Setting this bit would select primary bus number from config space 0:LM space lm_hal_pri_bus_dev_fun
  rand bit                   m_rrs_visibility_en;

  //sbsa_ctrl_ib_msi_low_addr
  rand bit [31:0]            m_sbsa_ctrl_ib_msi_low_addr;

  //sbsa_ctrl_ib_msi_hi_addr
  rand bit [31:0]            m_sbsa_ctrl_ib_msi_hi_addr;

  //sbsa_ctrl_ib_msi_control
  rand bit                   m_sbsa_msi_addr_sel;              //Address selection bit, used to select the address for IB MSI message.
  rand bit                   m_sbsa_msi_global_en;             //Global enable bit for MSI msg generation, If set, generate MSI upon error.
  rand bit                   m_sbsa_msi_msg_gen_en_for_lae;    //Enable MSI msg generation for local AER errors.
  rand bit                   m_sbsa_msi_msg_gen_en_for_efod;   //Enable MSI msg generation for recieved errors from other device.
  rand bit                   m_sbsa_msi_msg_gen_en_for_poli;   //Enable MSI msg generation for posedge for local interrupt.
  rand bit                   m_sbsa_msi_msg_gen_for_first_err; //When set, only for the first error MSI is generated. Only after clearing root_error_status register new MSIs are generated. 
  rand bit [4:0]             m_sbsa_interrupt_message_number; //When set, only for the first error MSI is generated. Only after clearing root_error_status register new MSIs are generated. 

  bit                        m_local_interrupt_in_process;
  bit                        mix_traffic;

  //ucie msi bits
   bit                       ucie_intr_gen;
   rand bit [7:0]            msi_next_cap_CP1;
   rand bit                  msi_en_ME;
   rand bit [2:0]            msi_message_ctrl_prog_MME;
   rand bit                  msi_base_addr64_BA64;
   rand bit                  msi_per_vectror_mask_MC;


  //Each CIF can have IDG_0 to IDG_15
  //i_hal_ctrl_idg_map_ent_0[15]
  //i_hal_ctrl_idg_map_ent_1[15]
  //[CIF][IDG]
  //Two dimensional dynamic array looks to have some tool issue. So, Making CIF as fixed array
  rand bit [15:0]          id_start[8][];
  rand bit [15:0]          id_end[8][];
  rand bit [15:0]          id_stride[8][];
  rand bit [15:0]          idg_number[8][];

  //i_hal_captured_bus_device_no_0 : Only for coverage & chk
  bit [7:0]                captured_bus_no0; //default:
  bit [4:0]                captured_dev_no0; //default:
  bit [7:0]                captured_bus_no0_1; //default:
  bit [4:0]                captured_dev_no0_2; //default:

  //i_hal_captured_bus_device_no_1 : Only for coverage & chk
  bit [7:0]                captured_bus_no1; //default:
  bit [4:0]                captured_dev_no1; //default:
  bit [7:0]                captured_bus_no1_1; //default:
  bit [4:0]                captured_dev_no1_2; //default:

  //i_hal_captured_bus_device_no_2 : Only for coverage & chk
  bit [7:0]                captured_bus_no2; //default:
  bit [4:0]                captured_dev_no2; //default:
  bit [7:0]                captured_bus_no2_1; //default:
  bit [4:0]                captured_dev_no2_2; //default:

  //i_hal_captured_bus_device_no_3 : Only for coverage & chk
  bit [7:0]                captured_bus_no3; //default:
  bit [4:0]                captured_dev_no3; //default:
  bit [7:0]                captured_bus_no3_1; //default:
  bit [4:0]                captured_dev_no3_2; //default:

  //i_hal_bus_no_fil_tag_extr
  rand bit [15:0]           add_req_id_for_pcie_tag;
  rand bit [7:0]            add_bus_nos_for_vf_ext;

  //i_hal_ctrl_cpl_to_0
  /*Range A , SubRange 0 : 50us - 100us ( 4us Unit )
    Range A , SubRange 1 : 1ms - 10ms ( 512us Unit )
    Range B , SubRange 0 : 16ms - 55ms ( 2*1024us Unit )
    Range B , SubRange 1 : 65ms - 210ms ( 8*1024us Unit ) */
  rand bit [7:0]             cpl_timeout_rangea_sub0; //default:
  rand bit [7:0]             cpl_timeout_rangea_sub1; //default:
  rand bit [7:0]             cpl_timeout_rangeb_sub0; //default:
  rand bit [7:0]             cpl_timeout_rangeb_sub1; //default:

  //i_hal_ctrl_cpl_to_1
  /*Range C , SubRange 0 : 260ms - 900ms ( 32*1024us Unit )
    Range C , SubRange 1 : 1s - 3.5s ( 128*1024us Unit )
    Range D , SubRange 0 : 4s - 13s ( 512*1024us Unit )
    Range D , SubRange 1 : 17s - 64s ( 2*1024*1024us Unit )*/
  rand bit [7:0]             cpl_timeout_rangec_sub0; //default:
  rand bit [7:0]             cpl_timeout_rangec_sub1; //default:
  rand bit [7:0]             cpl_timeout_ranged_sub0; //default:
  rand bit [7:0]             cpl_timeout_ranged_sub1; //default:

  //i_hal_debug_aue_sts, i_hal_debug_0/1/2/3 are arryed for 8 CIFs
  //i_hal_debug_aue_sts
  bit                        host_bar_pgm_err[8]; //default:
  bit                        tag_used_beore_cpl_rx[8]; //default:
  bit                        tag_out_of_range[8]; //default:
  bit                        tlp_size_grt_mps_mrrs[8]; //default:
  bit                        pkts_with_wrong_tc_from_cif[8]; //default:
  bit                        pkts_incorr_credit_type_from_cif[8]; //default:

  //i_hal_debug_0
  bit                        act_req_deassert_but_hls_if_notin_stop[8]; //default:0
  bit                        act_req_deassert_but_hls_if_notin_run[8]; //default:0

  //i_hal_debug_1
  bit                        ob_np_blk[8];
  bit                        deact_req_set_but_hls_if_notin_stop[8]; //default:0
  bit                        deact_req_not_set_but_hls_if_notin_run[8]; //default:0

  //i_hal_debug_2
  bit [31:0]                 cpl_payload_space_avail[8]; //default:

  //i_hal_debug_3
  bit [15:0]                 cpl_hdr_space_avail[8]; //default:

  //i_hal_ctrl_cif
  rand bit                        en_cpl_buffer_space_for_ob_np[8];
  rand bit                        en_cpl_buffer_space_for_ob_np_flag[8];
  //LM Registers : HLS - End

  //i_shdw_ur_err/i_shdw_hdr_log_0/1/2/3 ==> functionality registers

  //i_root_port_req_id_reg
  rand bit [15:0]            rp_req_id; //default: 0

  //i_vendor_id_reg
  rand bit [15:0]            sub_system_vendor_id; //default: 0
  rand bit [15:0]            vendor_id; //default: 0

  //i_ip_cfg_reg0
  rand bit                   err_report_on_type1_cfg_access; //default: 1 no reporting,  0:will rep err
  rand bit                   send_crs_rsp_to_flr; //default: 0
  rand bit                   cpl_timeout_hdr_log_en; //default: 0
  rand bit                   capture_slot_pwr_limit_msg_to_reg; //default: 0
  rand bit                   msi_vector_count_mode_sel; //default: 0
  rand bit                   cpl_timeout_as_advisory_err; //default: 1 - Advisory, 0 -Non-fatal
  rand bit                   msi_pend_bits_up_on_pin_input; //default: 0
  rand bit                   ari_cap_bit_inpf0_or_lowest_pfwithvfs; //default: 1
  rand bit                   dis_send_set_slot_pwr_msg; //default: 0
  rand bit                   lcl_prfx_pbr_log_en; //default: 0
  rand bit [1:0]             app_logic_ca_ur_req_hdr_log_en; //default: 3
  rand bit                   enable_multi_function_logging_for_ide_error; //default: 0

  //i_ltr_msg_ctrl_reg
  rand bit [9:0]             delay_between_two_ltr_msg; //default: 250us //TODO need to take care of m_l0s_exit_lat and m_l1_exit_lat
  rand bit                   transmit_ltr_msg; //default: 0
  rand bit                   transmit_ltr_msg_ltr_en; //default: 1
  rand bit                   transmit_ltr_msg_fn_state; //default: 1
  rand bit                   no_snoop_req_bit; //default: 1
  rand bit                   snoop_req_bit; //default: 1


  //rand int                   k_num_vfs[]; //num_vfs per pf (Such that sum of all PF's VF's should be equal to strap k_num_vfs)
  //i_config_snoop_ctrl_reg
  rand bit [15:0]            m_lm_config_snoop_timeout_val;

  // TODO - Config snoop interface modes 
  bit snoop_rsp_delay_mode;
  bit snoop_rsp_active_mode;
  bit snoop_rsp_delay_mode_before;
  bit snoop_rsp_delay_mode_after;
  bit snoop_rdata_random_mode;
  bit snoop_rsp_dcd_err_mode;
  
  //mmio_snoop_interface_mode
  bit mmio_snoop_rsp_delay_mode  ; 
  bit mmio_snoop_rsp_active_mode ;
  bit mmio_snoop_rsp_delay_mode_before; 
  bit mmio_snoop_rsp_delay_mode_after;
  bit mmio_snoop_rdata_random_mode;
  bit mmio_snoop_rsp_dcd_err_mode;
  
  rand bit [23:0]   mmio_snp_timeout_axi_clk_num_cycles   ;
  // i_shdw_hdrlog
  bit [31:0]  shdw_hdr_log[3:0];          
  
  // i_shdw_hdrlog
  bit [31:0]  shdw_prefix_log[2:0];  

  //HDR2LOG
  bit [127:0] hdr2log_tdata_header[$];
  bit [127:0] hdr2log_tdata_prefix[$];
  bit [25:0]  hdr2log_tuser[$];

  bit [2047:0]  exp_dl_crc_err_flit[$];
  
  cdn_pcie_hpa_pf_vf_s        shdw_ca_ur_pf_vf;
  bit stop_scen_ca_ur_cpl; 
  //i_flr_ctrl_reg
  rand bit                   m_flr;
  rand bit [7:0]             m_flr_pfn;
  rand bit [15:0]            m_flr_vf_num;
  rand bit                   m_flr_is_vf;

  //BER enable control
  rand bit       bit_error_enable;
  //L0s PM register fields
  rand bit[15:0] m_bfm_tx_nfts_g1;
  rand bit[15:0] m_bfm_tx_nfts_g2;
  rand bit[15:0] m_bfm_tx_nfts_g3;
  rand bit[15:0] m_bfm_tx_nfts_g4;
  rand bit[15:0] m_bfm_tx_nfts_g5;

  rand bit[15:0] m_dut_tx_nfts_g1;
  rand bit[15:0] m_dut_tx_nfts_g2;
  rand bit[15:0] m_dut_tx_nfts_g3;
  rand bit[15:0] m_dut_tx_nfts_g4;
  rand bit[15:0] m_dut_tx_nfts_g5;

  //Global fields used elsewhere in TB
  cdn_hpa_pcie_tlp_requester_id_s    ib_req_bdf[int];

  //Queue for Invalidate Request packet
  uvm_sequence_item inv_req_q[$];
  uvm_sequence_item page_req_q[$];

  bit [4:0]  itag_q[$];
  bit [15:0] dest_id_q[$];
  
  bit [4:0]  itag_compl_q[$];
  bit [15:0] req_id_compl_q[$];
  
  bit [4:0] itag_available_q[$];
  bit[8:0]  prg_index_available_q[$];

  int inv_req_outstanding;
  int pr_req_outstanding;
  bit [63:0] ptm_master_time;
  bit [31:0] ptm_propagation_delay;

  event fts_tx_e;
  event skip_tx_e;
  event eios_tx_e;
  event eieos_tx_e;
  event sds_tx_e;
  event fts_rx_e;
  event skip_rx_e;
  event eios_rx_e;
  event eieos_rx_e;
  event sds_rx_e;

  event ack_nak_dllp_rx_e;
  event ack_dllp_tx_e;
  event ack_dllp_rx_e;

  event pm_act_st_req_l1_dllp_tx_e;
  event pm_req_ack_tx_e;
  event pm_act_st_nak_msg_tx_e;
  event pm_act_st_req_l1_dllp_rx_e;
  event pm_req_ack_rx_e;
  event pm_act_st_nak_msg_rx_e;
  event pm_any_tlp_tx_e;
  event pm_any_tlp_rx_e;
  event slot_pwr_lim_msg_rx_e;
  event drs_msg_tx_e;
  event captured_segment_number_e;
  bit drs_msg_tx_by_dut;
  bit[31:0] slot_pwr_limit_msg_payload_rx;

  event pme_turnoff_msg_rx_hls_e;
  event pme_turnoff_msg_rx_link_e;
  event pme_to_ack_msg_rx_hls_e;
  event pme_to_ack_msg_rx_link_e;
  event pm_pme_msg_rx_link_e;
  event pm_pme_msg_tx_link_e;

  event pm_enter_l23_dllp_tx_e;
  event pm_enter_l23_dllp_rx_e;

  event pm_enter_l1_dllp_tx_e;
  event pm_enter_l1_dllp_rx_e;

  event pause_traffic_e;
  event resume_traffic_e;

  event ptm_resp_msg_tx_e;
  event ptm_resp_msg_rx_e;
  event ptm_respd_msg_tx_e;
  event ptm_respd_msg_rx_e;
  event ptm_resp_respd_msg_tx_e;
  event ptm_resp_respd_msg_rx_e;
  event ptm_req_msg_tx_e;
  event ptm_req_msg_rx_e;
  event control_skip_rcvd;

  event ob_hls_sent_ur_cpl;
  event ob_hls_sent_ca_cpl;
  
  event init_fc1_dllp_rx_e;
  event init_fc2_dllp_rx_e;
  bit init_fc2_dllp_rx_by_dut;

  event send_uncorr_flit_err;
  bit standard_nak_rcvd;
  bit selective_nak_rcvd;
  bit replay_rcvd;
  bit [1:0] num_b2b_nop_flit_corrupted;
  event rsvd_uncorr_flit_err;
  bit [1:0]  send_uncorr_flit_err_triggered;
  bit [1:0]  send_ob_uncorr_flit_err_triggered;

  exit_type_t exit_process;
  bit wait_done_pm_vseq_for_traffic = 1;
  bit cxl_pm_scenario;

  bit force_single_num_pkt_ob;
  bit pm_retry_scenario; //Indicator to turnoff unexp Nak messages
  bit l2_from_d0_state; //INdicator to drop the packet from pushing to act_q in scb (Internally generated PME_TO_ACK msg)

  bit corrupt_or_drop_skp_sds_from_act_bfm; //FM_PM: Scenario not used: Indicator for Active BFM Tx to drop or corrupt the SKP/SDS used in RX_L0s_FTS [ACTIVE_VIP: PCIE_CB_PL_TX_start_packet]
  bit drop_pme_to_ack_at_active_bfm; //FM_PM: Working: Indicator to drop the PME_TO_ACK TLP at active VIP Tx callback [ACTIVE_VIP: PCIE_CB_TL_TX_packet]
  bit drop_updatefc_dllps_at_active_bfm; //FM_PM: Fixed and working optimized updateFc dropping now: Indicator to drop the UpdateFcs dllps at active VIP Tx callback [ACTIVE_VIP: PCIE_CB_DL_TX_queue_enter]
  bit drop_even_updatefc_cpl_dllps_at_active_bfm=1; //FM_PM: Working: Indicator to drop the UpdateFcs_CPL dllps at active VIP Tx callback, when drop_updatefc_dllps_at_active_bfm=1 [ACTIVE_VIP: PCIE_CB_DL_TX_queue_enter]
  bit drop_active_bfm_tx_cpl_tlps; //FM_PM: Working: indicator to drop CPL/CPLD tlps at active vip Tx callback [ACTIVE_VIP: PCIE_CB_TL_TX_packet]
  bit drop_pm_dllps_at_active_bfm; //FM_PM: Fixed cbreason, working: Indicator to drop the pm_act_st_req_l1/ Pm_req_ack dllps at active VIP Rx callback [ACTIVE_VIP: PCIE_CB_PL_RX_end_packet]
  bit drop_ack_nak_dllps_at_active_bfm; //FM_PM: Fixed via rxflitdelay reg pgm, working: Indicator to drop the Ack/Nak dllps at active VIP Tx callback [ACTIVE_VIP: PCIE_CB_DL_TX_queue_enter]
  bit lcrc_corruption_at_active_bfm_rx;
  bit convert_ack_to_nak_dllps_at_active_bfm;
 
  bit replay_scenario_at_active_bfm;
 
  bit pl_flit_replay_scenario_at_active_bfm;
  bit corrupt_eios_at_act_bfm; //FM_PM: Not working for EP dut.May need tuning for FM EIOS corruption:  Jira 15317, Indicator to corrupt the EIOS at active BFM Rx [ACTIVE_VIP: PCIE_CB_PL_RX_end_packet:NOt_used && PCIE_CB_PL_TX_start_packet]
  bit drop_any_tlp_at_active_bfm; //FM_PM: Fixed cbreason ,not working, vipsr46694619 :Indicator to drop any TLP at active VIP Rx callback [ACTIVE_VIP: PCIE_CB_PL_RX_end_packet].


  bit dut_incurred_cpl_timeout; //Indicator for cov_collector that DUT incurred cpl timeout

  //---------------------------------------------------------------------------
  // Field:
  // This Field is a control to enable/disbale ASPM checks
  //---------------------------------------------------------------------------
  bit enable_aspm_checks=1;

  //---------------------------------------------------------------------------
  // Field: previous_scen_in_progress
  // This Field is used to not have another pause and pm_scenario execution
  //---------------------------------------------------------------------------
  bit  previous_pm_scen_in_progress;

  //---------------------------------------------------------------------------
  // Field: more_pm_scen
  // This Field is populated using $value$plusargs. Makefile args
  //---------------------------------------------------------------------------
  bit                                    more_pm_scen;

  //---------------------------------------------------------------------------
  // Field: pm_scenario_speed
  // This Field is used to capture the speed at which pm scenario will be exercised
  // Keep this until JIRA-19033 is fixed
  //---------------------------------------------------------------------------
  int                                    pm_scenario_speed;

  //---------------------------------------------------------------------------
  // Field: pcie_6_1_support 
  // This Field is populated using $value$plusargs(PCIE_6_1_SUPPORT)
  // Once this field is set all TB will work based on PCIe_6.1 spec
  //---------------------------------------------------------------------------
  bit                                    pcie_6_1_support;

  //---------------------------------------------------------------------------
  // Field: num_low_power_entry
  // This Field is for deciding the number of times
  // traffic to be paused -> execute PM Scenario ->resumes traffic
  //---------------------------------------------------------------------------
  rand bit [3:0]                         num_low_power_entry ;

  //---------------------------------------------------------------------------
  // Field: burst_pause_per_tlps_count
  // This Field is for the tlp burst pause per tlp count
  //---------------------------------------------------------------------------
  rand bit [9:0]                         burst_pause_per_tlps_count;

  //---------------------------------------------------------------------------
  // Field: actual_no_of_pm_scen_executed
  // This Field is used to count the actual no. of pm scenario executed in this simulation
  //---------------------------------------------------------------------------
  int actual_num_of_pm_scen_executed;

  //---------------------------------------------------------------------------
  // Field: pf_vf_rid_for_pme_status
  // This Field is populated with RIds of corresponding PF/VF which is set/clear for PME_STATUS
  // when this field is 1, indicates PME_STATUS is set for corresponding PF_VF indicated by RID
  // when this field is 0, indicates PME_STATUS is clear for corresponding PF_VF indicated by RID
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_requester_id_s pf_vf_rid_for_pme_status[$];

  //---------------------------------------------------------------------------
  // Field: expect_pm_pme_from_rid_q 
  // This Field is populated with RIds of corresponding PF/VF which will send PM_PME
  // within 1us(+pme_st set and msg seen on link time) tolerance from time of queue population
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_requester_id_s expect_pm_pme_from_rid_q[$];

  //---------------------------------------------------------------------------
  // Field: is_req_ids_populated
  // This Field is used to tell req_ids/completer_ids are populated in auto-enumeration.
  //---------------------------------------------------------------------------
  bit  is_req_ids_populated=0;

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Field: default_sbsa_cntrl_is_set
  // This Field is used to tell whether lm_hal_sbsa_cntrl registered is programmed or set by default
  //---------------------------------------------------------------------------
  bit  default_sbsa_cntrl_is_set=0;

  // Field: device_num_captured
  // This Field is used to tell the device number is captured for manual enumeration.
  //---------------------------------------------------------------------------
  bit  device_num_captured=0;

  //---------------------------------------------------------------------------
  // Field: pm_l1_non_blocking_power_state_change
  //---------------------------------------------------------------------------
  bit  pm_l1_non_blocking_power_state_change=0;

  //---------------------------------------------------------------------------
  // Field: power_state_to_d0
  //---------------------------------------------------------------------------
  bit  power_state_to_d0=0;

  //---------------------------------------------------------------------------
  // Field: exp_power_state_change_ipfivf
  //  # [24]        : When set indicates VF else PF
  //  # [23 : 8]    : VF Offset wrt PF
  //  # [7 : 0]     : Associated PF Number  
  //---------------------------------------------------------------------------
  bit [24:0]  exp_power_state_change_ipfivf[$];

  //---------------------------------------------------------------------------
  // Field: power_state_change_register_write_ongoing
  // This field will be set when register write is happening to change power state
  //---------------------------------------------------------------------------
  bit power_state_change_register_write_ongoing;

  //---------------------------------------------------------------------------
  // Event: rx_l0s_entry_detected
  // This Field is used to inform rx_l0s_entry happened
  //---------------------------------------------------------------------------
  event rx_l0s_entry_detected;

  //---------------------------------------------------------------------------
  // Field: ensure_l0s_entered
  // This Field is used to inform checker to throw error if l0s not entered after TB timer expires.
  // Else, warning will be thrown, because as per spec its not mandatory to enter L0s at any cause for sure.
  // And race condition is seen on DUT behaviour, which sometimes enter L0s and sometimes not , when tl2dl/dl2pl valid happen
  // exactly on same clock when timer expires
  //---------------------------------------------------------------------------
  bit  ensure_l0s_entered;

  //---------------------------------------------------------------------------
  // Field: ensure_aspm_l1_entered
  // This Field is used to inform checker to throw error if aspm_l1 not entered after TB timer expires & other cdns satisfied.
  // Else, warning will be thrown, because as per spec its not mandatory to enter aspm_l1 at any cause for sure.
  // But, we are ensuring other way. ie., If DUT enters L1 but TB condition is not satisfied(Or TB timer is not satisfied) throw error without any control
  //---------------------------------------------------------------------------
  bit  ensure_aspm_l1_entered;

  //---------------------------------------------------------------------------
  // Field: rx_l0s_fts_timeout_scenario_in_progress 
  // This Field is used to inform checker that fts timeout scenario in progress
  //---------------------------------------------------------------------------
  bit  rx_l0s_fts_timeout_scenario_in_progress;

  //---------------------------------------------------------------------------
  // Field: l0s_timer_abt_to_expire
  // This Field is used to inform l0s_timer_abt_to_expire happened
  //---------------------------------------------------------------------------
  bit  l0s_timer_abt_to_expire;

  //---------------------------------------------------------------------------
  // Field: l1_timer_abt_to_expire
  // This Field is used to inform l1_timer_abt_to_expire happened
  //---------------------------------------------------------------------------
  bit  l1_timer_abt_to_expire;

  //---------------------------------------------------------------------------
  // Field: recovery_due_to_nfts_timeout
  // This Field is used to inform pm_cov_collector abt nfts timeout for coverage
  //---------------------------------------------------------------------------
  bit  recovery_due_to_nfts_timeout;

  //------------------------------------------------------------------------
  // Lane Margining  variables
  //------------------------------------------------------------------------
  // Control Variables
  // lane_margining setup variable
  //------------------------------------------------------------------------
  rand bit [5:0] lane_margining_error_count_limit;
  rand bit [5:0] lane_margining_error_count;
  rand bit [5:0] lane_margining_step_voltage_offset;
  rand bit [2:0] lane_margining_recovery_l0_margin_restore_timeout;
  rand bit [1:0] lane_margining_dependent_sample_recovery_lock_min_time;
  rand bit       lane_margining_status_mode;
  rand bit       lane_margining_dependent_err_count_update_mode;
  rand bit       lane_margining_dependent_sample_count_update_mode;
  rand bit       lane_margining_dependent_data_parity_err_count_mode;
  rand bit       lane_margining_disable_margining_in_recovery_ltssm;
  rand bit       lane_margining_dependent_data_parity_err_inj_en;
  rand bit       lane_margining_enabled;
  rand bit       lane_margining_rc_self_margin;
  rand bit       lane_margining_MVoltageSupported ;
  rand bit       lane_margining_MIndUpDownVoltage  ;
  rand bit       lane_margining_MIndLeftRightTiming ;
  rand bit       lane_margining_MSampleReportingMethod ;
  rand bit       lane_margining_MIndErrorSampler;
  rand bit [6:0] lane_margining_MNumVoltageSteps;
  rand bit [5:0] lane_margining_MNumTimingSteps ;
  rand bit [5:0] lane_margining_MMaxTimingOffset ;
  rand bit [5:0] lane_margining_MMaxVoltageOffset ;
  rand bit [5:0] lane_margining_MSamplingRateVoltage ;
  rand bit [5:0] lane_margining_MSamplingRateTiming ;
  bit            MIndErrorSampler;
  bit            independent_sampler_passed=1;

  rand bit [6:0] lane_margining_g5_MNumVoltageSteps;
  rand bit [5:0] lane_margining_g5_MNumTimingSteps ;
  rand bit [5:0] lane_margining_g5_MMaxTimingOffset ;
  rand bit [5:0] lane_margining_g5_MMaxVoltageOffset ;
  rand bit [5:0] lane_margining_g5_MSamplingRateVoltage ;
  rand bit [5:0] lane_margining_g5_MSamplingRateTiming ;
  
  rand bit [6:0] lane_margining_g6_MNumVoltageSteps;
  rand bit [5:0] lane_margining_g6_MNumTimingSteps ;
  rand bit [5:0] lane_margining_g6_MMaxTimingOffset ;
  rand bit [5:0] lane_margining_g6_MMaxVoltageOffset ;
  rand bit [5:0] lane_margining_g6_MSamplingRateVoltage ;
  rand bit [5:0] lane_margining_g6_MSamplingRateTiming ;

  `ifdef PCIE_GEN7
  rand bit [6:0] lane_margining_g7_MNumVoltageSteps;
  rand bit [5:0] lane_margining_g7_MNumTimingSteps ;
  rand bit [5:0] lane_margining_g7_MMaxTimingOffset ;
  rand bit [5:0] lane_margining_g7_MMaxVoltageOffset ;
  rand bit [5:0] lane_margining_g7_MSamplingRateVoltage ;
  rand bit [5:0] lane_margining_g7_MSamplingRateTiming ;
  `endif //PCIE_GEN7

  rand bit [4:0] lane_margining_MMaxLanes;
  rand bit       one_retimer_presence_detected;
  rand bit       two_retimer_presence_detected;
  rand bit       more_than_two_retimer_presence_detected;
  rand bit       margining_third_fourth_retimter;
  rand bit [2:0] m_lane_margin_receiver_num;
  rand bit [1:0] m_lane_margining_scheme;
  rand bit       lane_margining_enable_recovery;
  rand bit       m_ep_margin_cfg_wr_en;
  bit [1:0]      margin_scheme; 
  
  ///////////////////////////////////////////////////////////////
  // Field: cpcs_sds_error
  // Used to trigger cpcs_sds_error
  ///////////////////////////////////////////////////////////////
  uvm_event cpcs_sds_error;

  ///////////////////////////////////////////////////////////////
  // Field: gen6_sds_error
  // Used to trigger cpcs_sds_error
  ///////////////////////////////////////////////////////////////
  uvm_event gen6_sds_error;

  `ifdef PCIE_GEN7
  ///////////////////////////////////////////////////////////////
  // Field: gen7_sds_error
  // Used to trigger cpcs_sds_error
  ///////////////////////////////////////////////////////////////
  uvm_event gen7_sds_error;
  `endif

  ///////////////////////////////////////////////////////////////
  // Field: cpcs_skp_error
  // Used to trigger cpcs_skp_error
  ///////////////////////////////////////////////////////////////
  uvm_event cpcs_skp_error;

  ///////////////////////////////////////////////////////////////
  // Field: set_after_lock
  // Used to trigger shift_after_lock
  ///////////////////////////////////////////////////////////////
  uvm_event set_after_lock;

  bit[15:0] cpcs_lane_num_map;
  ///////////////////////////////////////////////////////////////
  // Field: eq_reg_rd_event
  // Used to trigger eq register which is used for eq checker
  ///////////////////////////////////////////////////////////////
  uvm_event eq_reg_rd_start;

  ///////////////////////////////////////////////////////////////
  // Field: eq_reg_rd_done
  // Used to tell eq reg read done event back to eq checker
  ///////////////////////////////////////////////////////////////
  uvm_event eq_reg_rd_done;


  ///////////////////////////////////////////////////////////////
  // Field: reg_type
  // Used to tell eq reg type whether local eq or remote eq reg
  ///////////////////////////////////////////////////////////////
  bit [2:0] reg_type;

  ///////////////////////////////////////////////////////////////
  // Field: enable_pl_eq_checks
  // Used to enable/disable pl equalization related checks
  // which is present in cdn_pcie_hpa_pl_cb file
  ///////////////////////////////////////////////////////////////
  bit enable_pl_eq_checks;


  ///////////////////////////////////////////////////////////////
  // Field: corr_err_sts_rd_data
  // Used to get correctable error sts reg rd data from isr seq
  ///////////////////////////////////////////////////////////////
  bit [31:0] corr_err_sts_rd_data;

  ///////////////////////////////////////////////////////////////
  // Field: corr_err_sts_rd
  // Used to tell correctable error status reg read done event to
  // error status reg checker in cdnpcie_hpa_pl_cb
  ///////////////////////////////////////////////////////////////
  // uvm_event corr_err_sts_rd;
  bit corr_err_sts_rd;

  //............................................
  // cdn_pcie_reg_base : queue that used to store
  // Config space linked list information
  //............................................
  cdn_pcie_reg_base reg_linklist_q [$];
  int m_num_req_ps_test;
  int m_num_res_ps_test;
  bit m_ps_reg_test_en;

  //////////////////////////////////////////////////////////
  // Field:en_dynamic_skew_insertion_deletion
  // Enables dynamic skew addition/deletion block in pl_cb
  //////////////////////////////////////////////////////////
  rand bit en_dynamic_skew_insertion_deletion;



  //Field: m_lm_ltssm_debug_freez
  bit   m_lm_ltssm_debug0_freeze_0;
  bit   m_lm_ltssm_debug1_freeze_0;
  bit   m_lm_ltssm_debug2_freeze_0;
  bit   m_lm_ltssm_debug3_freeze_0;

  //Field: m_lm_ltssm_debug_check_0
  bit   m_lm_ltssm_debug0_check_0;
  bit   m_lm_ltssm_debug1_check_0;
  bit   m_lm_ltssm_debug2_check_0;
  bit   m_lm_ltssm_debug3_check_0;

  //Field: m_lm_ltssm_debug_curr_state_0
  tb_ltssm_state_int_e  m_lm_ltssm_debug0_curr_state_0;
  tb_ltssm_state_int_e  m_lm_ltssm_debug1_curr_state_0;
  tb_ltssm_state_int_e  m_lm_ltssm_debug2_curr_state_0;
  tb_ltssm_state_int_e  m_lm_ltssm_debug3_curr_state_0;

  //Field: m_lm_ltssm_debug_prev_state_0
  tb_ltssm_state_int_e  m_lm_ltssm_debug0_prev_state_0;
  tb_ltssm_state_int_e  m_lm_ltssm_debug1_prev_state_0;
  tb_ltssm_state_int_e  m_lm_ltssm_debug2_prev_state_0;
  tb_ltssm_state_int_e  m_lm_ltssm_debug3_prev_state_0;

  //Field: m_lm_ltssm_debug_freeze_1
  bit   m_lm_ltssm_debug0_freeze_1;
  bit   m_lm_ltssm_debug1_freeze_1;
  bit   m_lm_ltssm_debug2_freeze_1;
  bit   m_lm_ltssm_debug3_freeze_1;

  //Field: m_lm_ltssm_debug_check_1
  bit   m_lm_ltssm_debug0_check_1;
  bit   m_lm_ltssm_debug1_check_1;
  bit   m_lm_ltssm_debug2_check_1;
  bit   m_lm_ltssm_debug3_check_1;

  //Field: m_lm_ltssm_debug_curr_state_1
  tb_ltssm_state_int_e  m_lm_ltssm_debug0_curr_state_1;
  tb_ltssm_state_int_e  m_lm_ltssm_debug1_curr_state_1;
  tb_ltssm_state_int_e  m_lm_ltssm_debug2_curr_state_1;
  tb_ltssm_state_int_e  m_lm_ltssm_debug3_curr_state_1;

  //Field: m_lm_ltssm_debug_prev_state_1
  tb_ltssm_state_int_e  m_lm_ltssm_debug0_prev_state_1;
  tb_ltssm_state_int_e  m_lm_ltssm_debug1_prev_state_1;
  tb_ltssm_state_int_e  m_lm_ltssm_debug2_prev_state_1;
  tb_ltssm_state_int_e  m_lm_ltssm_debug3_prev_state_1;


  //------------------------------------------------------------------------
  // CXL.IO 1.1 mode RCRB and Membarx changes
  //------------------------------------------------------------------------
  // field :  m_cxl_io_rcrb_bar
  bit [63:0] m_cxl_io_rcrb_bar;
  rand bit   m_cxl_io_32_bar;

  cdn_cxl_neg_mode_t m_cxl_negotiation;

  // TODO : for now First mem transaction is read
  /*rand*/ bit        m_cxl_first_mem_type;
//------------------------------------------------------------------------
  // CXL.IO 1.1 mode RCRB and Membarx changes
  //------------------------------------------------------------------------
  // field :  m_cxl_io_rcrb_bar
  bit [63:0] m_cxl_io_rcrb_bar;
  rand bit   m_cxl_io_32_bar;

  cdn_cxl_neg_mode_t m_cxl_negotiation;

  // TODO : for now First mem transaction is read
  /*rand*/ bit        m_cxl_first_mem_type;

  //------------------------------------------------------------------------
  // field : m_cxl_io_membar_en
  //------------------------------------------------------------------------
  rand bit        m_cxl_io_membar_en;
  //------------------------------------------------------------------------
  // field : m_cxl_io_membar_aperture
  //------------------------------------------------------------------------
  rand bit [5:0]  m_cxl_io_membar_aperture;
  //------------------------------------------------------------------------
  // field : m_cxl_io_bar_setup_i
  //------------------------------------------------------------------------
  bit [63:0]      m_cxl_io_bar_setup_i;
  //------------------------------------------------------------------------
  // field : m_cxl_io_membar
  //------------------------------------------------------------------------
  bit [63:0]      m_cxl_io_membar;


  // field : memory_map
  uvm_mem_mam memory_map;

  //------------------------------------------------------------------------
  // field: cpcs_config
  //------------------------------------------------------------------------
  rand cdnpcie_hpa_cpcs_config m_cpcs_config;
  //////////////////////////////////////////////////////////
  //Field : Disable_iorecal_check_timeout
  //For timeout scenario to disable checks
  //////////////////////////////////////////////////////////
  bit disable_iorecal_check_timeout;

  //////////////////////////////////////////////////////////
  //Field : clk_shutoff_period
  //period for clk shutting off clock period
  //////////////////////////////////////////////////////////
  rand bit [7:0] m_clk_shutoff_period;


  //////////////////////////////////////////////////////////
  //Field : iorecal_seq_qctive
  //To indicate iorecal sequence is active
  //////////////////////////////////////////////////////////
  bit iorecal_seq_active;


  //////////////////////////////////////////////////////////
  //Field : iorecal_disable in controller
  //(1: Disable, 0: Enable).
  //Bit[0] - Reserved
  //Bit[1] - Reserved
  //Bit[2] - Disable IOREACAL at GEN3.
  //Bit[3] - Disable IOREACAL at GEN4.
  //Bit[4] - Disable IOREACAL at GEN5.
  //Bit[5] - Disable IOREACAL at GEN6.
  //////////////////////////////////////////////////////////
  rand bit [5:0] iorecal_disable;

  //////////////////////////////////////////////////////////
  //Field : iorecal_request_mask in controller
  //(1: Disable, 0: Enable).
  //Bit[0] - Reserved
  //Bit[1] - Reserved
  //Bit[2] - Disable IOREACAL at GEN3.
  //Bit[3] - Disable IOREACAL at GEN4.
  //Bit[4] - Disable IOREACAL at GEN5.
  //Bit[5] - Disable IOREACAL at GEN6.
  //////////////////////////////////////////////////////////
  rand bit [5:0] iorecal_request_mask;

  
  //////////////////////////////////////////////////////////
  //Field : ib_mwr_data
  // This is required only for PureSuite.
  // This is to store data when an inbound MWr is received,
  // and when the data is being read by a follow-up MRd to
  // the same address, and in that case the data stored in
  // this array is being fed to the Outbound CPL.
  //////////////////////////////////////////////////////////
  bit [7:0] ib_mwr_data[longint];

  //////////////////////////////////////////////////////////
  //Field : memory_written
  // This is required only for PureSuite.
  // Flag to write and clear when data is being written and
  // read to/from the above sparse memory.
  //////////////////////////////////////////////////////////
  bit memory_written;

  //-------------------------------------------------------------------------------
  // Field : link_dis_wait_timeout
  // Used to specifiy the maximum wait time while expecting for desired state entry
  //  interms of 1us multiple ex:link_dis_wait_timeout =100 (100 * 1us)
  //-------------------------------------------------------------------------------
  rand int link_dis_wait_timeout;

  //-------------------------------------------------------------------------------
  // Field : link_dis_st_exit_time_min
  // Used to specifiy the min time, dut/vip allowed to stay in disable link state
  //  interms of 1us
  //-------------------------------------------------------------------------------
  rand int link_dis_st_exit_time_min;

  //-------------------------------------------------------------------------------
  // Field : link_dis_st_exit_time_max
  // Used to specifiy the min time, dut/vip allowed to stay in disable link state
  // interms of 1us
  //-------------------------------------------------------------------------------
  rand int link_dis_st_exit_time_max;


  //-------------------------------------------------------------------------
  // Field : mask_phy_status_eq_timeout
  // Used to mask the phystatus during equalization for EQ timeout scenraio
  //-------------------------------------------------------------------------
  rand bit mask_phy_status_eq_timeout;

  //-------------------------------------------------------------------------
  // Field : eq_timeout_speed
  // Used to mask the phystatus during equalization at random speed
  //-------------------------------------------------------------------------
  rand bit[2:0] eq_timeout_speed;

  //-------------------------------------------------------------------------
  // Field : pl_pipe_sync_hdr_err_en
  // Used to inject sync header error
  //-------------------------------------------------------------------------
  rand bit pl_pipe_sync_hdr_err_en;

  //-------------------------------------------------------------------------
  // Field : pl_rec_lock_eq_err_en
  // Used to enable eq co_efficients corruption in recovery lock state 
  //-------------------------------------------------------------------------
  rand bit pl_rec_lock_eq_err_en;

  //-------------------------------------------------------------------------
  // Field : pl_pipe_rxstart_blk_err_en
  // Used to inject rxstart block error
  //-------------------------------------------------------------------------
  rand bit pl_pipe_rxstart_blk_err_en;

  //-------------------------------------------------------------------------
  // Field : pl_pipe_rxvalid_err_en
  // Used to inject error pipe signals rxvalid/rxdatavalid
  //-------------------------------------------------------------------------
  rand bit pl_pipe_rxvalid_err_en;


  //-------------------------------------------------------------------------
  // Field : eq_timeout_by_invalid_ts1
  // Used to create EQ timeout scenraio by corrupting TS1 of DUT RX path
  //-------------------------------------------------------------------------
  rand bit eq_timeout_by_invalid_ts1;

  //-------------------------------------------------------------------------
  // Field : m_eq_timeout_during_bfm_adjustment
  // Used to create EQ timeout scenraio at dut side when BFM adjusts DUT
  // EQ parameters
  //-------------------------------------------------------------------------
  rand bit eq_timeout_during_bfm_adjustment;

  //-------------------------------------------------------------------------
  // Field : eq_reject_by_dut
  // Used to create EQ reject scenraio by DUT (corrupting TS1 of DUT RX path)0
  //-------------------------------------------------------------------------
  rand bit eq_reject_by_dut;

  //-------------------------------------------------------------------------
  // Field : eq_reject_by_bfm
  // Used to create EQ reject scenraio by BFM
  // (Setting Reject co_efficient bit of DUT RX TS1)
  //-------------------------------------------------------------------------
  rand bit eq_reject_by_bfm;

  //-------------------------------------------------------------------------
  // Field : eq_rej_err_max_time
  // Used to constraint max time EQ reject scenraio will be created
  //-------------------------------------------------------------------------
  rand int eq_rej_err_min_time;

  //-------------------------------------------------------------------------
  // Field : eq_rej_err_max_time
  // Used to constraint max time EQ reject scenraio will be created
  //-------------------------------------------------------------------------
  rand int eq_rej_err_max_time;

  //-------------------------------------------------------------------------
  // Field : eq_reject_preset_coefficients_corrupt_n
  // Used to select preset or co-efficients corruption for EQ reject scenraio
  // 0-co_efficients 1-preset
  //-------------------------------------------------------------------------
  rand bit eq_reject_preset_coefficients_corrupt_n;


  //-------------------------------------------------------------------------
  // Field : retimer_eq_extend
  // Used to create EQ Extended retimer scenario
  //-------------------------------------------------------------------------
  rand bit[1:0] retimer_eq_extend;

  //---------------------------------------------------------------------------
  // Field : eq_timeout_cnt
  // Used to limit the no of EQ timeout scenraio creation during the simulation
  //---------------------------------------------------------------------------
  rand bit[2:0] eq_timeout_cnt;

  //------------------------------------------------------------------------------
  // Field : pipe_interfcae_err_inj_cnt
  // Used to limit the no of times sync header error is injected in the simulation
  //------------------------------------------------------------------------------
  rand bit[31:0] pipe_interfcae_err_inj_cnt;

  //--------------------------------------------------------------------------------
  // Field: m_eq_ts1_preset_coefficients_mismatch
  // Used to generate TS1 with mismatch preset co-efficients during Equlaization
  //--------------------------------------------------------------------------------
  rand bit eq_ts1_preset_coefficients_mismatch;

  //--------------------------------------------------------------------------------
  // Field: m_eq_corrupt_consecutive_ts1
  // Used to corrupt syn6-9 of consecutive TS1 with during Equlaization
  //--------------------------------------------------------------------------------
  rand bit eq_corrupt_consecutive_ts1;

  //--------------------------------------------------------------------------------------
  // Field: m_eq_ts1_ec_not_next_phase
  // Used to corrupt TS1 recevied by DUT During Equlaization phase2/3 with EC != nextphase
  //--------------------------------------------------------------------------------------
  rand bit eq_ts1_ec_not_next_phase;

  //--------------------------------------------------------------------------------------
  // Field: enable_eq_debug_sts
  // Used to enable comparison of eq debug status registers
  //--------------------------------------------------------------------------------------
  rand bit enable_eq_debug_sts;

  //--------------------------------------------------------------------------------------
  // Field: enable_auto_speed_change
  // Enable auto speed change feature
  //--------------------------------------------------------------------------------------
  rand bit enable_auto_speed_change;

  //--------------------------------------------------------------------------------------
  // Field: eq_dbg_ctrl_lane_num
  // Used to select the lane which we enable eq status comaprison
  //--------------------------------------------------------------------------------------
  rand bit[3:0] eq_dbg_ctrl_lane_num;

  //--------------------------------------------------------------------------------------
  // Field: eq_dbg_ctrl_eq_phase_sel
  // Used to select the phase which eq info will be captured
  //--------------------------------------------------------------------------------------
  rand bit[1:0] eq_dbg_ctrl_eq_phase_sel;

  //--------------------------------------------------------------------------------------
  // Field: eq_dbg_ctrl_eq_speed_sel
  // Used to select the speed in which eq info will be captured
  //--------------------------------------------------------------------------------------
  rand bit[2:0] eq_dbg_ctrl_eq_speed_sel;

  //--------------------------------------------------------------------------------------
  // Field: eq_dbg_ctrl_eq_sts1_reg_behaviour
  // Used to select the eq status1 register capture behaviour
  //--------------------------------------------------------------------------------------
  rand bit eq_dbg_ctrl_eq_sts1_reg_behaviour;

  //--------------------------------------------------------------------------------------
  // Field: eq_dbg_lane_num_reversal
  // Used to select the lane(during lane reversal) which we enable eq status comaprison
  //--------------------------------------------------------------------------------------
  rand bit[3:0] eq_dbg_lane_num_reversal;

  //--------------------------------------------------------------------------------------
  // Field: ltssm_recovery_count_local_ctrl_reg
  // Used to control the local recovery transition counter events enable
  //--------------------------------------------------------------------------------------
  rand bit[31:0] ltssm_recovery_count_local_ctrl_reg;


  //---------------------------------------------------------------------------
  // Field: ob_uio_p_req_length_bytes[int]
  // Associative array to hold required cpld byte cnt based on OB UIO P req tags
  //---------------------------------------------------------------------------
  bit [12:0]                ob_uio_p_req_length_bytes[int];

  //---------------------------------------------------------------------------
  // Field: ob_uio_p_req_length_bytes[int]
  // Associative array to hold required cpld byte cnt based on OB NP req tags
  // TODO: add UIO NP (Group 3)
  //---------------------------------------------------------------------------
  bit [12:0]                ob_np_req_length_bytes[int];

  bit                       ob_req_IDO[int]; 
  int                       ob_req_type[int]; 
  //---------------------------------------------------------------------------
  // Field: pxc_tag_remap_h
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_pxc_tag_remapper pxc_tag_remap_h;
  //---------------------------------------------------------------------------
  // Field: ib_req_length_bytes[int]
  // Associative array to hold required cpld byte cnt based on IB NP req tags
  //---------------------------------------------------------------------------
  bit [12:0]                ib_req_length_bytes[int];
  //---------------------------------------------------------------------------
  // Field: ob_np_req_is_mrd_tr[int]
  // Associative array to hold all NP req with value 1: TR req ; 0: other NP req
  //---------------------------------------------------------------------------
  bit                       ob_np_req_is_mrd_tr[int];
  //---------------------------------------------------------------------------
  // Field: ib_np_req_is_mrd_tr[int]
  // Associative array to hold all NP req with value 1: TR req ; 0: other NP req
  //---------------------------------------------------------------------------
  bit                       ib_np_req_is_mrd_tr[int];


  //---------------------------------------------------------------------------
  //Field: ep_bfm_eqts2_en
  //bit[5]G5EPEQTS2EN : ENables EP BFM TO 128b130b EQ TS2 Enable, used in EP BFM
  //---------------------------------------------------------------------------
  rand bit                    ep_bfm_eqts2_en;

  //---------------------------------------------------------------------------
  //Field: enable_retry_rxeqeval
  //i_eq_ctrl_0.ENRTEQER(bit4) : to enable retry rxeqeval after feedback error
  //---------------------------------------------------------------------------
  rand bit                    enable_retry_rxeqeval;

  //---------------------------------------------------------------------------
  //Field: dis_max_speed_driver
  //disable bit for  max speed change driver
  //---------------------------------------------------------------------------
  rand bit                    dis_max_speed_driver;

  //---------------------------------------------------------------------------
  //Field: enable_bit_error
  //---------------------------------------------------------------------------
  bit enable_bit_error;

  //---------------------------------------------------------------------------
  //Field: enable_align_reset
  //--------------------------------------------------------------------------
  bit enable_align_reset;

  //---------------------------------------------------------------------------
  //Field: enable_ctc_reset
  //--------------------------------------------------------------------------
  bit enable_ctc_reset;

  //---------------------------------------------------------------------------
  //Field: enable_ctc_reset
  //--------------------------------------------------------------------------
  bit en_lane_disable;
   
  //--------------------------------------------------------------------------- 
  //Field: Loopback Lane Under Test 
  //--------------------------------------------------------------------------- 
  bit en_loopback_lut; 

  //---------------------------------------------------------------------------
  //Field: m_gen5_eios_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit  m_gen5_eios_corruption_en;

  //---------------------------------------------------------------------------
  //Field: m_gen6_sds_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit m_gen6_sds_os_corruption_en;

  //---------------------------------------------------------------------------
  //Field: m_gen6_skp_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit  m_gen6_skp_os_corruption_en;

  //---------------------------------------------------------------------------
  //Field: m_gen6_eieos_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit m_gen6_eieos_corruption_en;

  //---------------------------------------------------------------------------
  //Field: m_gen6_eios_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit  m_gen6_eios_corruption_en;

  `ifdef PCIE_GEN7
  //---------------------------------------------------------------------------
  //Field: m_gen7_sds_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit m_gen7_sds_os_corruption_en;

  //---------------------------------------------------------------------------
  //Field: m_gen7_skp_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit  m_gen7_skp_os_corruption_en;

  //---------------------------------------------------------------------------
  //Field: m_gen7_eieos_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit m_gen7_eieos_corruption_en;

  //---------------------------------------------------------------------------
  //Field: m_gen7_eios_os_corruption_en
  //--------------------------------------------------------------------------
  rand bit  m_gen7_eios_corruption_en;
  `endif

  //---------------------------- 
  // RAM error injection control 
  //---------------------------- 
 
  // Field: m_p_ram_err_injection_enable 
  // Bit0 errors enabled, Bit1 uncorrectable errors on 
  rand bit[1:0] m_p_ram_err_injection_enable; 

  // Field: m_np_ram_err_injection_enable
  // Bit0 errors enabled, Bit1 uncorrectable errors on
  rand bit[1:0] m_np_ram_err_injection_enable;

  // Field: m_cpl_ram_err_injection_enable
  // Bit0 errors enabled, Bit1 uncorrectable errors on
  rand bit[1:0] m_cpl_ram_err_injection_enable;
  
  // Field: m_replay_buffer_ram_err_injection_enable
  // Bit0 errors enabled, Bit1 uncorrectable errors on
  rand bit[1:0] m_replay_buffer_ram_err_injection_enable;

  // Field: m_replay_buffer_ctrl_ram_err_injection_enable
  // Bit0 errors enabled, Bit1 uncorrectable errors on
  rand bit[1:0] m_replay_buffer_ctrl_ram_err_injection_enable;

  // Field: m_nprt_ram_err_injection_enable 
  // Bit0 errors enabled, Bit1 uncorrectable errors on 
  rand bit[1:0] m_nprt_ram_err_injection_enable;

  // Field: m_bytecnt_ram_err_injection_enable 
  // Bit0 errors enabled, Bit1 uncorrectable errors on 
  rand bit[1:0] m_bytecnt_ram_err_injection_enable;

  // Field: m_axi_hls_tx_ram_err_injection_enable
  // Bit0 errors enabled, Bit1 uncorrectable errors on
  rand bit[1:0] m_axi_ram_err_injection_enable;

  // Field: m_dma_ram_err_injection_enable
  // Bit0 errors enabled, Bit1 uncorrectable errors on
  rand bit[1:0] m_dma_ram_err_injection_enable;

  //---------------------------------------------------------------------------
  //Field: flit_mode_negotiated 
  // Use this field to know if flit mode negotiated. 
  // TODO Gen6: Populate from init seq/other component using PL callback at Cfg.Complete state
  // Also, assign this varaible to tlp_vseqr handle (both tlp_vseqr/vip_tlp_vseqr)
  //--------------------------------------------------------------------------
  bit flit_mode_negotiated;

  bit [3:0] valid_context;
  bit ptm_flit_corr;
  bit ptm_resp;
  bit ptm_respd;
  bit vip_ptm_flit_corr;
  bit vip_ptm_dup;
  //---------------------------------------------------------------------------
  //Field: flit_err_count 
  // Use this field to know how many flit error to be injected. 
  //--------------------------------------------------------------------------
  rand int flit_err_count;

  //---------------------------------------------------------------------------
  //Field: flit_fc_err 
  // Use this field to know flit fc error injected. 
  //--------------------------------------------------------------------------
  bit flit_fc_err;

  //---------------------------------------------------------------------------
  //Field: local_flit_err_count 
  // Use this field to know how many flit error to be injected. 
  //--------------------------------------------------------------------------
  int local_flit_err_count;

  //---------------------------------------------------------------------------
  //Field: destination_segment 
  //Destination segment field used in FM 
  //---------------------------------------------------------------------------
  rand bit [7:0]                             destination_segment;

  //---------------------------------------------------------------------------
  //Field: requester_segment
  //Requester segment field used in FM 
  //---------------------------------------------------------------------------
  rand bit [7:0]                             requester_segment;

  //---------------------------------------------------------------------------
  //Field: reset_eieos
  //Reset EIEOS interval count
  //---------------------------------------------------------------------------
  rand bit                                   rst_eie_intvl_cnt;

  //---------------------------------------------------------------------------
  //Field: same_segment_in_both_devices
  //Both devices will have same segment if set
  //---------------------------------------------------------------------------
  rand bit                                   same_segment_in_both_devices;

  //---------------------------------------------------------------------------
  //Field: captured_segment_number 
  //Populate this bit once EP device receievd CFGWr with valid Destination segment & DSV=1
  //TODO Can we populate after completion received for the 1st cfgwr?? to be on safer side??
  //Only after this bit set, OB requests can go with Requester segment
  //---------------------------------------------------------------------------
  bit                                        captured_segment_number; 

  bit                                        send_sbsa_cfg_type_1;

  //---------------------------------------------------------------------------
  // L0p Configs
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  //Field: m_l0p_lm
  //Support L0p LM programming
  //---------------------------------------------------------------------------
  rand bit m_l0p_lm; 
  //Field: m_l0p_support
  //Support L0p feature
  //---------------------------------------------------------------------------
  rand bit m_l0p_support;
  //---------------------------------------------------------------------------
  //Field: m_l0p_enable
  //Enable L0p feature
  //---------------------------------------------------------------------------
  rand bit m_l0p_enable;
  //---------------------------------------------------------------------------
  //Field: m_l0p_priority
  //Set L0p Priority
  //---------------------------------------------------------------------------
  rand bit m_l0p_priority;
  //---------------------------------------------------------------------------
  //Field: m_l0p_request_lw
  //Set L0p Request Linkwidth
  //L0p LinkWidth      Desired LinkWidth
  //  0001                    x1
  //  0010                    x2
  //  0100                    x4
  //  1000                    x8
  //  0000                    x16
  //---------------------------------------------------------------------------
  rand bit[3:0] m_l0p_request_lw;
  
  //---------------------------------------------------------------------------
  //Field: m_l0p_rqst_to_interval
  //L0p LinkWidth      Desired LinkWidth
  // 3'b000 : 1us;
  // 3'b001 : 2us;
  // 3'b010 : 4us;
  // 3'b011 : 8us;
  // 3'b100 : 16us;
  // 3'b111 : Indefinite;
  //---------------------------------------------------------------------------
  rand bit[2:0] m_l0p_rqst_to_interval;


  //---------------------------------------------------------------------------
  //Field:l0p_aggregation_enable
  //---------------------------------------------------------------------------
  rand bit l0p_aggregation_enable;


  
  //---------------------------------------------------------------------------
  //Field:l0p_vip_8b10b_ts_os_truncated
  //---------------------------------------------------------------------------
  rand bit  l0p_vip_8b10b_ts_os_truncated;


  //---------------------------------------------------------------------------
  //Field:l0p_vip_response_min
  //---------------------------------------------------------------------------
  rand bit [15:0] l0p_vip_response_min;


  //---------------------------------------------------------------------------
  //Field:l0p_vip_response_max
  //---------------------------------------------------------------------------
  rand bit [15:0] l0p_vip_response_max;
  
  //---------------------------------------------------------------------------
  //Field:l0p_vip_response_max_8b_10b
  //---------------------------------------------------------------------------
  rand bit [15:0] l0p_vip_response_max_8b_10b;



  //---------------------------------------------------------------------------
  //Field: m_port_l0p_exit_latency
  //Configure Port L0p Exit Latency Value
  //Defined encodings are
  // 3'b000  Less than 1µs
  // 3'b001  1 µs to less than 2 µs
  // 3'b010  2 µs to less than 4 µs
  // 3'b011  4 µs to less than 8 µs
  // 3'b100  8 µs to less than 16 µs
  // 3'b101  16 µs to less than 32 µs
  // 3'b110  32 µs-64 µs
  // 3'b111  More than 64 µs
  //---------------------------------------------------------------------------
  rand bit [2:0] m_port_l0p_exit_latency;
  //---------------------------------------------------------------------------
  //Field: m_remote_l0p_exit_latency
  //Store Remote L0p Exit Latency Value
  //Defined encodings are
  // 3'b000  Less than 1µs
  // 3'b001  1 µs to less than 2 µs
  // 3'b010  2 µs to less than 4 µs
  // 3'b011  4 µs to less than 8 µs
  // 3'b100  8 µs to less than 16 µs
  // 3'b101  16 µs to less than 32 µs
  // 3'b110  32 µs-64 µs
  // 3'b111  More than 64 µs
  //---------------------------------------------------------------------------
  bit [2:0] m_remote_l0p_exit_latency;
  //---------------------------------------------------------------------------
  //Field: m_l0p_neg_bypass
  //DLLP negotiation bypass for L0p request. Debug Signal
  //---------------------------------------------------------------------------
  rand bit m_l0p_neg_bypass;
  //---------------------------------------------------------------------------
  //Field: m_l0p_req_timeout_interval
  //The time for which the Controller would wait post a 
  //L0p Link width resizing request for a response from 
  //the link partner before abandoning the request or 
  //issuing another request .The valid values are : 
  //  3'b000 : 1us 
  //  3'b001 : 2us 
  //  3'b010 : 4us 
  //  3'b011 : 8us 
  //  3'b100 : 16us 
  //  3'b111 : Indefinite 
  //---------------------------------------------------------------------------
  rand bit [2:0] m_l0p_req_timeout_interval;
  //---------------------------------------------------------------------------
  //Field: m_l0p_req_gap
  //The time for which the Controller would wait post a 
  //recent successful link width resizing before making 
  //another link width resizing request. 
  //The valid values are : 
  //  3'b000 : 1us 
  //  3'b001 : 2us 
  //  3'b010 : 4us 
  //  3'b011 : 8us 
  //  3'b100 : 16us 
  //  3'b111 : Reserved
  //---------------------------------------------------------------------------
  rand bit [2:0] m_l0p_req_gap;
  //---------------------------------------------------------------------------
  //Field: l0p_initial_lw
  //This field contains the Link Width determined 
  //during initial link training. Encodings are: 
  // 000 - x1 Link 
  // 001 - x2 Link 
  // 010 - x4 Link 
  // 011 - x8 Link 
  // 100 - x16 Link 
  //---------------------------------------------------------------------------
  bit [2:0] l0p_initial_lw;
  //---------------------------------------------------------------------------
  //Field: m_l0p_target_lw
  //Target Link Width - writes to this field initiate a directed L0p 
  //Link Width change to the indicated width. 
  //Encodings are :  
  //000 : x1 Link  
  //001 : x2 Link  
  //010 : x4 Link  
  //011 : x8 Link  
  //100 : x16 Link  
  //111 : Dynamic -- L0p Link Width is determined by the Ports with no architected software intervention 
  //---------------------------------------------------------------------------
  rand bit [2:0] m_l0p_target_lw;

  //---------------------------------------------------------------------------
  //Field: remote_l0p_supp
  //This bit indicates that the remote end of the Link supports L0p. 
  //---------------------------------------------------------------------------
  bit remote_l0p_supp;
  //---------------------------------------------------------------------------
  //Field: m_remote_l0p_exit_latency
  //This field indicates the remote Port's L0p Exit Latency. 
  //The value reported indicates the length of time the 
  //remote Port requires to complete widening a link using L0p. 
  //Defined encodings are: 
  //3'b000 : Less than 1us 
  //3'b001 : 1us to less than 2us 
  //3'b010 : 2us to less than 4us 
  //3'b011 : 4us to less than 8us 
  //3'b100 : 8us to less than 16us 
  //3'b101 : 16us to less than 32us 
  //3'b110 : 32us-64us 
  //3'b111 : More than 64us
  //---------------------------------------------------------------------------
  //rand bit [2:0] m_remote_l0p_exit_latency;
  //---------------------------------------------------------------------------
  //Field: l0p_neg_status
  //L0p Negotiation Status: Carries the latest status of the most recent 
  //L0p negotiation or the ongoing negotiation. Client can use this to determine 
  //if a negotiation is ongoing, whether the negotiation completed/was aborted 
  //or timed out. Encoding is as follows: 
  //3'b000: No L0p Negotiation has occurred, Link operating at Initial Link Width 
  //3'b001: L0p Request Completed. 
  //3'b010: L0p Negotiation in Progress.  
  //3'b011: L0p Request Aborted (Valid only if Request Initiated by Controller) 
  //3'b100: L0p Request Timed out  
  //3'b101: Local L0p Request Rejected by Remote End 
  //3'b110: Remote L0p Request Rejected by Controller 
  //---------------------------------------------------------------------------
  bit [2:0] l0p_neg_status; 

 //------------ //---------------------------------------------------------------------------
  //Field: l0p_powerdown_value
  //This bit indicates that powerdown vale during L0p state
  //---------------------------------------------------------------------------
  rand bit [1:0] l0p_powerdown_value; 

  //Field: L0pRequestDllpsToSend
  //This bit indicates Number of request DLLPs to send per negotiation by VIP
  //---------------------------------------------------------------------------
  rand bit [1:0] L0pRequestDllpsToSend; 
  
  //---------------------------------------------------------------------------
  //Field: l0p_powerdown_phystatus_wait
  //This bit indicates wait phystatus for phystatus during L0p powerdown change
  //   00: No timeout. Wait till phystatus response is received for P0 - (P0p/P1) transition.
  //   01: Wait for a maximum of 1us for P0->(P0p/P1) transition and 4us for (P0p/P1)->P0 transition.
  //   10: Wait for a maximum of 4us for P0->(P0p/P1) transition and 10us for (P0p/P1)->P0 transition.
  //   11: Wait for a maximum of 10us for P0->(P0p/P1) transition and 16us for (P0p/P1)->P0 transition.

  //---------------------------------------------------------------------------
  rand bit [1:0] l0p_powerdown_phystatus_wait; 

  
  //---------------------------------------------------------------------------
  //Field: captured_segment_number 
  //During substates exit, CORE CLK shutoff can happen at L1.2. While core_clk is restored
  //and reg_access happening exactly on the clk where reg_clk is restored from pm_clk tocore_clk
  //Getting unexpected bahaviour PCIE-13286
  //---------------------------------------------------------------------------
  bit                                        block_reg_access_as_subst_exit_in_prog;

  //---------------------------------------------------------------------------
  //Field:pm_scen_introduced_lane_err_status
  //To disable the EOT to check lane error status reg as EIOS is corrupted in some PM scen 
  //This is detected as Lane error status reg
  //---------------------------------------------------------------------------
  bit                                        pm_scen_introduced_lane_err_status;

  //---------------------------------------------------------------------------
  //Field:pm_scen_introduced_err_in_rp_mode
  //To disable the EOT to check root error status reg as replay is corrupted in some PM scen 
  //---------------------------------------------------------------------------
  bit                                        pm_scen_introduced_err_in_rp_mode;

  //---------------------------------------------------------------------------
  //Field: non_d0_np_req_in_progress
  //To demote the error(CPL UR Tx by DUT) for the Rx NP req while in non-D0. 
  //Promote it back once cpl is Tx by DUT
  //---------------------------------------------------------------------------
  int                                        non_d0_np_req_in_progress;

  //---------------------------------------------------------------------------
  //Field: dut_tx_err_msg 
  //event triggered whenever DUT Tx ERR_CORR/NF/F message (Sampled at Passive monitor CB)
  //---------------------------------------------------------------------------
  event dut_tx_err_msg;

  //---------------------------------------------------------------------------
  //Field: track_dut_tx_err_msg_cnt
  //Control signal to count the DUT ERR_CORR/NF/F message count. 
  //WHen this control bit is zero, count of each ERR message will be reset
  //---------------------------------------------------------------------------
  bit   track_dut_tx_err_msg_cnt;

  //---------------------------------------------------------------------------
  //Field: dut_tx_err_corr_msg_cnt
  //COunt of DUT Tx ERR_CORR message provided track_dut_tx_err_msg_cnt=1 
  //---------------------------------------------------------------------------
  int   dut_tx_err_corr_msg_cnt;

  //---------------------------------------------------------------------------
  //Field: dut_tx_err_non_fatal_msg_cnt 
  //Count of DUT Tx ERR_CORR message provided track_dut_tx_err_msg_cnt=1 
  //---------------------------------------------------------------------------
  int   dut_tx_err_non_fatal_msg_cnt;

  //---------------------------------------------------------------------------
  //Field: dut_tx_err_fatal_msg_cnt
  //Count of DUT Tx ERR_CORR message provided track_dut_tx_err_msg_cnt=1 
  //---------------------------------------------------------------------------
  int   dut_tx_err_fatal_msg_cnt;

  //---------------------------------------------------------------------------
  //Field: discard_the_cpl_to_tags_in_ob
  //Used in PM_L1_NON_D0_CPL_TIMEOUT scenario. When drop_active_bfm_tx_cpl_tlps=1, and a NP req is sent which will not Rx completion
  //This tag is stored in discard_the_cpl_to_tags_in_ob[$] and this tag will not be used further in the sim
  //as passive monitor will throw USER_TAG_2 error
  //---------------------------------------------------------------------------
  bit[13:0] discard_the_cpl_to_tags_in_ob[$];

  bit [7:0] m_bad_stream_id_q[$];

  //------------------------------------------

  bit user_def_perf_mon_test = 0;
  bit spd_change_from_gen2;
  bit en_lane_margin;
  bit en_ptm;
  bit no_pm_scen;
  bit enable_bme_mse_ioe_err; 
  rand int pf_num_in_non_d0; 
  bit user_bit_error_enable;
  bit user_strap_dut_gen_sel;
  bit COMP_TEST_EN; 
  bit COMP_b4_linkup_EN; 
  bit EN_FRAMING;
  bit bit_error_en_cmd_line;
  bit bad_dllp_stat;
 
  bit aspm_l1_enable;
  bit aspm_l0s_enable;
  bit aspm_disable;
  //---------------------------------------------------------------------------
  // Field: user_sync_hdr_bypass_en
  // User sync header enable bit,
  //---------------------------------------------------------------------------
  bit user_sync_hdr_bypass_en;

  //---------------------------------------------------------------------------
  // Field: user_sync_hdr_bypass_neg
  // User sync header neg bit,
  //---------------------------------------------------------------------------
  bit user_sync_hdr_bypass_neg;

  bit bypass_credit_check;

  //---------------------------------------------------------------------------
  // Field: eq_err_inj_type 
  // Enables different types of error injection during EQ
  // Encoding : 000 - No Error 
  //            001 - eq timeout by invalid ts1
  //            010 - eq timeout during bfm adjustment
  //            011 - eq reject by dut 
  //            100 - eq reject by bfm
  //            111 - corrupt co_efficient or preset to create req ep scenario 
  //---------------------------------------------------------------------------
  bit [2:0]eq_err_inj_type = 0;

  //---------------------------------------------------------------------------
  // Field: pipe_err_inj_type 
  // Enables different types of error injection on Pipe signals
  // Encoding : 000 - No Error 001 - Invalid Sync Hdr error
  //            010 - rxstart block error  011- rxvalid error
  //---------------------------------------------------------------------------
  bit [2:0]pipe_err_inj_type;


  //---------------------------------------------------------------------------
  // Field: pl_sris_en 
  // When set user can control sris enable field 
  // through pl_sris_en
  //---------------------------------------------------------------------------
  bit pl_sris_en;

  //---------------------------------------------------------------------------
  // Field: pl_dut_enhanced_link_ctrl_en 
  // When set user can control dut enhnaced link behaviour ctrl field 
  // through pl_dut_enhanced_link_ctrl 
  //---------------------------------------------------------------------------
  bit pl_dut_enhanced_link_ctrl_en;

  //---------------------------------------------------------------------------
  // Field: pl_dut_enhanced_link_ctrl 
  // used when pl_dut_enhanced_link_ctrl_en =1,
  // encoded as same as ts1 symbol5 bit[7:6]  
  //---------------------------------------------------------------------------
  bit [1:0]pl_dut_enhanced_link_ctrl;

  //---------------------------------------------------------------------------
  // Field: pl_vip_enhanced_link_ctrl_en 
  // When set user can control vip enhnaced link behaviour ctrl field 
  // through pl_vip_enhanced_link_ctrl 
  //---------------------------------------------------------------------------
  bit pl_vip_enhanced_link_ctrl_en;

  //---------------------------------------------------------------------------
  // Field: pl_vip_enhanced_link_ctrl 
  // used when pl_vip_enhanced_link_ctrl_en =1,
  // encoded as same as ts1 symbol5 bit[7:6]  
  //---------------------------------------------------------------------------
  bit [1:0]pl_vip_enhanced_link_ctrl;

  //---------------------------------------------------------------------------
  // Field: sbsa_exp_cpl_fields_q 
  // queue to hold exp completions, where actual pkts will be internally  generated by dut
  //---------------------------------------------------------------------------
  exp_cpl_fields_object sbsa_exp_cpl_fields_q[$];

  //---------------------------------------------------------------------------
  // Field:  exp_msi_fields_q
  // queue to hold exp completions, where actual pkts will be internally  generated by dut
  //---------------------------------------------------------------------------
  exp_msi_fields_object exp_msi_fields_q[$];

  //----------------------------------------------------------------------------
  //Field: PTC test
  //----------------------------------------------------------------------------
  string ptc_test_sel;
  string ptc_testcase;
  string ptc_cv_test_name; 
  string ptc_test_name;
  bit [2:0] ptc_52_10_flag;  
  bit [2:0] ptc_52_13_flag;  
  bit [7:0] ptc_52_21_flag;  
  bit PTC_TX_DEEMPHASIS_FLAG;
  bit PTC_RETIMER_PRESENT_FLAG;
  bit a_2_2_1_completed;
  bit a_2_2_2_completed;


  //Flag to indicate whether root error status is cleared.
  bit root_error_status_is_set;

  bit exec_permit;
  bit ecrc_init_done;
  bit local_prefix_ecrc_error = 0;
  bit id_based_order_init_done;
  bit msi_init_done;
  bit msi_addr_init_done;
  bit msi_data_init_done;
  bit sbsa_msi_control_init_done;

  bit acs_violation_test;
  int acs_violated_tag[string][$];
  //----------------------------------------------------------------------------
  // LTI related configurations
  //----------------------------------------------------------------------------
  bit lti_en;
   

  //LTI Control0 Register
  bit               lti_msg_address_reset;
  bit 		    rd_register;
  rand bit          lti_vdm_disable_wr_conversion;
  rand bit          lti_dti_disable_wr_conversion;
  rand bit          lti_disable_xlation_for_msg_conversion;
  rand bit          lti_msg_disable_sw_buffer_overflow;
  rand bit          lti_xlate_error_mark_internal_error;
  rand bit          lti_xlate_msi;
  rand bit          lti_link_down_fast_flush_mode;
  rand bit          lti_bypass;
  rand bit          lti_other_msg_disable_wr_conversion;
  rand bit          lti_enable_dmwr_nonsys_lrattr_error_legacy; // bit 9 of lti_control0 for LTI-C DMWr with ltratt nosys error will always be dropped. With this bit, this can be tested for LTI-A and LTI-B too.
  rand bit          lti_timeout_resp_type;
  rand bit          lti_xlate_error_faultabort_resp_type;
  rand bit          lti_xlate_error_faultrazwi_resp_type;
  rand bit          lti_xlate_unsupported_response_resp_type;
  rand bit          lti_dmwr_nonsys_lrattr_resp_type;

  //LTI Status0 Register - enable respective error injection
  string            lti_err_inj;
  rand bit          lti_msg_received_status;
  rand bit          lti_en_timeout;
  rand bit          lti_en_xlate_error_faultabort_status;
  rand bit          lti_en_xlate_error_faultrazwi_status;
  rand bit          lti_en_dmwr_nonsys_lrattr_status;
  rand bit          lti_en_msg_length_check_error;
  rand bit	    lti_en_hold_la_credit;
  rand bit          lti_en_xlate_unsupported_resp_status;
  bit [3:0]         lti_xlate_error_code;
  rand bit          lti_en_sw_buffer_overflow;

  //LTI Status0 Register Mask
  rand bit          lti_msg_received_status_mask;
  rand bit          lti_timeout_occurred_status_mask;
  rand bit          lti_xlate_error_faultabort_status_mask;
  rand bit          lti_xlate_error_faultrazwi_status_mask;
  rand bit          lti_dmwr_nonsys_lrattr_status_mask;
  rand bit          lti_msg_length_check_error_mask;
  rand bit          lti_xlate_unsupported_resp_status_mask;

  //LTI Status1 Register - enable respective error injection
  rand bit          lti_en_msi_xlate_timeout_occurred_status;
  rand bit          lti_en_msi_xlate_error_faultabort_status;
  rand bit          lti_en_msi_xlate_error_faultrazwi_status;
  rand bit          lti_en_msi_xlate_unsupported_resp_status;

  //LTI Status1 Register Mask
  rand bit          lti_msi_xlate_timeout_occurred_status_mask;
  rand bit          lti_msi_xlate_error_faultabort_status_mask;
  rand bit          lti_msi_xlate_error_faultrazwi_status_mask;
  rand bit          lti_msi_xlate_unsupported_resp_status_mask;
  
  //LTI Message Pins
  rand bit [31:0]   lti_msg_base_addr_lower;
  rand bit [31:0]   lti_msg_base_addr_upper;
  rand bit [31:0]   lti_msg_buffer_size;
  bit [31:0]        lti_msg_last_read_offset;
  bit [31:0]        lti_msg_last_write_offset;
  

  //LTI translation reponse arrays
  typedef bit unsigned [63-12:0] req_addr_idx;
  bit [63:0]        translated_addr [req_addr_idx];
  bit [2:0]         translated_response [req_addr_idx];
  //denaliLtiTransactionAttrT translated_lrattr [req_addr_idx];
  bit [51:0]        lti_err_addr [$];
  bit [51:0]        msi_ib_addr[$];
  bit [63:0]        lti_msi_physical_addr;
  bit               lti_no_snoop_addr [req_addr_idx];

  bit               force_lti_msg_wr_conversion; // temp, remove once randomization in policy is enabled
  bit               force_lti_msi_wr_conversion; // temp, remove once randomization in policy is enabled
  
  bit               local_err_sts_1_clear = 1;

  //LTI msg_length_check_error bit
  bit               m_msg_length_error = 0;
  bit               lti_lm_sts_0_clear = 1;

  //LTI errors
  bit               m_msg_received_status;
  bit  [3:0]        m_msg_received_count;
  bit  [3:0]        m_posted_delivered_count; 
  bit               m_fault_abort_error;
  bit               m_fault_razwi_error;
  bit               m_lti_ur_error;
  bit               m_lti_lr_attr_error;
  bit               m_msi_fault_abort_error;
  bit               m_msi_fault_razwi_error;
  bit               m_msi_lti_ur_error;

  // LTI init completed - workaroud for packets transmitted prior to configuration
  bit               lti_init_done;
  bit               lti_control_init_done;

  // LTI MSI base address pin. In case of LTI translation error, this address would be used to send out the MSI packet.
  rand bit [63:0]   msi_msg_ib_msi_addr;

  //cfg2tl rx MPS size in DW. If a message is sent from TL2HLS with size greater than this size, message length error will be reported.
  rand bit [10:0] cfg2tl_rx_max_payload_size_in_DW;
  
  bit               do_not_randomize_lti_metadata; // georgep -> Temporary toggle for LTI metadata randomization. This bit will be used in LTI related tests only, until the feature is stabilized.
  
  //TDISP
  int tdisp_reg_block;
  bit [1:0] tdisp_reg_attr;
  bit [1:0] tdisp_reg_origin;
  bit tdisp_attr_check;
  bit tdisp_dbg_check;
  bit tdisp_reg_access_check;
  bit tdi_state_change_check;
  bit error_status_check;
  bit ide_strm_state_check;
  bit ide_strm_lock_check;
  bit tdisp_access_nse;
  bit lm_access_via_vsec;
  bit tdi_state_change_when_flr;
  bit tdi_state_change_by_app;
  bit ide_reg_default_attr;
  bit rmeda_reg_default_attr;
  bit tdisp_reg_default_attr;
  bit rmeda_tdisp_en_1_to_0;
  bit rmeda_tdisp_en_w_prot_forever;
  bit msg2wr_reg_default_attr;

  bit [5:0] m_highest_common_speed;
  bit       is_cxl_dlco_error_test; //TODO Pass this on from some place for DLCO.

  bit       msi_inject_test_enable;

  //------------------------------------------------------------------------
  // LBB Signals
  //------------------------------------------------------------------------
  rand bit [2:0] p_round_robin_wgt[8];
  rand bit [2:0] np_round_robin_wgt[8];
  rand bit [2:0] cpl_round_robin_wgt[8];
  rand bit       arb_vc_pri_en;
  rand bit [3:0] no_of_streams_en;
  rand bit [7:0] stream_i_vc_mapping[8];

  `include "cdn_pcie_hpa_dev_top_cfg_cov.sv"

  //------------------------------------------------------------------------
  // CONSTRAINT BLOCKS.
  //------------------------------------------------------------------------
   constraint L0pRequestDllpsToSend_c {
     if(scenario != null) {
       if(i_cfg.scenario.is_cxl_30()) {
          L0pRequestDllpsToSend == 1; //#VIPSR 46925992
        }
      }
   }
   constraint ucie_msi_intr_c {
     if(ucie_intr_gen) {
       msi_next_cap_CP1 == 0; // CP1 Pointer to the next PCI Capability Structure. there are no capability in ucie after MSI
       msi_en_ME == 1; // Enable MSI feature
       msi_message_ctrl_prog_MME dist {0:=50,1:=50}; // no. of distinct messages that the Controller is programmed of generating to generate this Function (000 = 1, 001 = 2) 
       msi_base_addr64_BA64 dist {0:=50,1:=50}; // 1 :device is capable of generating 64-bit addresses for MSI messages
       msi_per_vectror_mask_MC dist {0:=50,1:=50}; // Per-Vector Masking Capable
     }
   }

  // change distrubution   
  constraint sbsa_ctrl_ib_msi_control_c {
    if (mix_traffic) { 
      m_sbsa_msi_addr_sel  == 0; //dist { 0:=70, 1:=30 }; // 0 - Use sbsa_ctrl_ib_msi_address for IB MSI and 1 - Use address form MSI capability.
    }
   }

  // LBB constraints    
  constraint m_no_of_streams_en_temp_c { no_of_streams_en == parameters_cfg_pkg::NUM_TLP_STREAMS; }
  constraint m_no_of_streams_en_c { no_of_streams_en inside {[1:8]}; }
  constraint m_arb_vc_pri_en_c { arb_vc_pri_en dist {0 := 70, 1 := 30}; }

  constraint m_p_round_robin_wgt_c { 
    foreach (p_round_robin_wgt[i]) {
      (!arb_vc_pri_en) ? p_round_robin_wgt[i] inside {[1:7]} : p_round_robin_wgt[i] == parameters_cfg_pkg::NUM_ARB_GRANTS_IN_CYCLE; //if arb_vc_pri_en is enabled, p_round_robin_wgt should be set to max to ensure p stream gets highest priority
    }
  }

  constraint m_np_round_robin_wgt_c { 
    foreach (np_round_robin_wgt[i]) {
      (!arb_vc_pri_en) ? np_round_robin_wgt[i] inside {[1:7]} : np_round_robin_wgt[i] == parameters_cfg_pkg::NUM_ARB_GRANTS_IN_CYCLE; //if arb_vc_pri_en is enabled, np_round_robin_wgt should be set to max to ensure np stream gets second highest priority
    }
  }

  constraint m_cpl_round_robin_wgt_c { 
    foreach (cpl_round_robin_wgt[i]) {
      (!arb_vc_pri_en) ? cpl_round_robin_wgt[i] inside {[1:7]} : cpl_round_robin_wgt[i] == parameters_cfg_pkg::NUM_ARB_GRANTS_IN_CYCLE; //if arb_vc_pri_en is enabled, cpl_round_robin_wgt should be set to max to ensure cpl stream gets third highest priority
    }
  }

  constraint m_stream_vc_mapping_c {  //solve num_vc_enabled before stream_i_vc_mapping;
    if(parameters_cfg_pkg::SW_IDE_EN){
      foreach(stream_i_vc_mapping[i]) {
        if(i!=0)
          $countones(stream_i_vc_mapping[i]) == 0;
      }
    }
    foreach(stream_i_vc_mapping[i]) {
      $countones(stream_i_vc_mapping[i]) <= num_vc_enabled;
      stream_i_vc_mapping[i] < 2**num_vc_enabled; //ensures only LSBs are filled
    }
    foreach (stream_i_vc_mapping[0][bit_idx]) {
      if (bit_idx < num_vc_enabled) {
        stream_i_vc_mapping[0][bit_idx] || 
        stream_i_vc_mapping[1][bit_idx] || 
        stream_i_vc_mapping[2][bit_idx] || 
        stream_i_vc_mapping[3][bit_idx] ||
        stream_i_vc_mapping[4][bit_idx] ||
        stream_i_vc_mapping[5][bit_idx] || 
        stream_i_vc_mapping[6][bit_idx] ||
        stream_i_vc_mapping[7][bit_idx] == 1; 
      }
      else {
        stream_i_vc_mapping[0][bit_idx] || 
        stream_i_vc_mapping[1][bit_idx] || 
        stream_i_vc_mapping[2][bit_idx] || 
        stream_i_vc_mapping[3][bit_idx] ||
        stream_i_vc_mapping[4][bit_idx] ||
        stream_i_vc_mapping[5][bit_idx] || 
        stream_i_vc_mapping[6][bit_idx] ||
        stream_i_vc_mapping[7][bit_idx] == 0; 
      }
    }
  }
     

  //------------------------------------------------------------------------
  // STATUS MEMBER VARIABLES
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  `uvm_component_utils_begin(cdn_pcie_hpa_dev_top_config)
	//`uvm_field_array_object(pf_config,UVM_ALL_ON)
	`uvm_field_int(pcie_6_1_support,UVM_ALL_ON)
	`uvm_field_int(default_cred_init,UVM_ALL_ON)
	`uvm_field_int(capture_slot_pwr_limit_msg_to_reg,UVM_ALL_ON)
	`uvm_field_int(all_vc_zero_shared_cred_dut,UVM_ALL_ON)
	`uvm_field_int(all_vc_zero_shared_cred_vip,UVM_ALL_ON)
	`uvm_field_int(all_vc_zero_shared_cred_fc_type,UVM_ALL_ON)
	`uvm_field_int(enable_zero_credit_randomization,UVM_ALL_ON)
	`uvm_field_int(enable_segmentation,UVM_ALL_ON)
	`uvm_field_int(m_lm_sris_enable,UVM_ALL_ON)
	`uvm_field_int(m_sris_clocking,UVM_ALL_ON)
	`uvm_field_int(m_enable_flit_err_inj,UVM_ALL_ON)
	`uvm_field_int(app_logic_ca_ur_req_hdr_log_en,UVM_ALL_ON)
	`uvm_field_int(enable_multi_function_logging_for_ide_error,UVM_ALL_ON)
	`uvm_field_int(m_enable_reg_based_flit_err_inj,UVM_ALL_ON)
	// FEI variables
	`uvm_field_int(m_fei_num_inj,UVM_ALL_ON)
	`uvm_field_int(m_fei_inj_space,UVM_ALL_ON)
	`uvm_field_int(m_fei_cons_inj,UVM_ALL_ON)
	`uvm_field_int(m_fei_err_offset,UVM_ALL_ON)
	`uvm_field_int(m_fei_err_mag,UVM_ALL_ON)
	`uvm_field_int(m_fei_en,UVM_ALL_ON)
	`uvm_field_int(m_fei_tx,UVM_ALL_ON)
	`uvm_field_int(m_fei_checker_en,UVM_ALL_ON)
	`uvm_field_int(m_fei_chk_en,UVM_ALL_ON)
	`uvm_field_int(m_fei_err_stat,UVM_ALL_ON)
	// Flit Error Counter variables
	`uvm_field_int(m_flit_err_cnt_en,UVM_ALL_ON)
	`uvm_field_int(m_flit_err_cnt_intr_en,UVM_ALL_ON)
	`uvm_field_int(m_flit_err_events_to_count,UVM_ALL_ON)
	`uvm_field_int(m_flit_err_trigger_event,UVM_ALL_ON)
	// FBER variables
	`uvm_field_int(m_fber_en,UVM_ALL_ON)
	`uvm_field_int(m_fber_gran_per_lane_err,UVM_ALL_ON)
	`uvm_field_int(m_fber_report_longest_burst,UVM_ALL_ON)
	`uvm_field_int(m_err_inj_tx,UVM_ALL_ON)
	`uvm_field_int(m_err_inj_rx,UVM_ALL_ON)
	`uvm_field_int(m_soma_cpl_timeout_en,UVM_ALL_ON)
	`uvm_field_int(m_dlf_exchange_en,UVM_ALL_ON)
	`uvm_field_int(m_local_dl_feature_supp,UVM_ALL_ON)
	`uvm_field_int(m_max_link_speed,UVM_ALL_ON)
	`uvm_field_enum(cdn_hpa_link_speed_e,m_user_bfm_max_link_speed,UVM_ALL_ON)
	`uvm_field_int(m_credit_throttle_enabled,UVM_ALL_ON)
	`uvm_field_int(m_slot_power_limit_val,UVM_ALL_ON)
	`uvm_field_int(m_slot_pwer_limit_scale,UVM_ALL_ON)
	`uvm_field_int(num_tlps_allowed,UVM_ALL_ON)
	`uvm_field_int(enable_ide,UVM_ALL_ON)
	`uvm_field_int(non_ide_traffic_test,UVM_ALL_ON)
	`uvm_field_int(inject_err_en,UVM_ALL_ON)
	`uvm_field_int(freq_err,UVM_ALL_ON)
	`uvm_field_int(mf_err_inj,UVM_ALL_ON)
	`uvm_field_int(acs_err_inj,UVM_ALL_ON)
	`uvm_field_int(ur_err_inj,UVM_ALL_ON)
	`uvm_field_int(posted_rsvd_type_err_inj,UVM_ALL_ON)
	`uvm_field_int(nonposted_rsvd_type_err_inj,UVM_ALL_ON)
	`uvm_field_int(completion_rsvd_type_err_inj,UVM_ALL_ON)
	`uvm_field_int(none_rsvd_type_err_inj,UVM_ALL_ON)
	`uvm_field_int(cfg_ur_err_inj,UVM_ALL_ON)
	`uvm_field_int(tlp_err_inj,UVM_ALL_ON)
	`uvm_field_int(uio_tlp_err_inj,UVM_ALL_ON)
	`uvm_field_int(cpl_err_inj,UVM_ALL_ON)
	`uvm_field_int(poisoned_err_inj,UVM_ALL_ON)
	`uvm_field_int(ecrc_err_inj,UVM_ALL_ON)
	`uvm_field_int(dlp_err_inj,UVM_ALL_ON)
	`uvm_field_int(ide_err_inj,UVM_ALL_ON)
	`uvm_field_int(dllp_err_inj,UVM_ALL_ON)
	`uvm_field_int(dll_flit_err_inj,UVM_ALL_ON)
	`uvm_field_int(plp_err_inj,UVM_ALL_ON)
	`uvm_field_int(m_num_allowed_errors,UVM_ALL_ON)
	`uvm_field_int(enable_err_reporting,UVM_ALL_ON)
	`uvm_field_int(cxl_err_retrain_req,UVM_ALL_ON)
	`uvm_field_int(m_rp_req_id,UVM_ALL_ON)
	`uvm_field_int(m_rp_req_id.bus_num,UVM_ALL_ON)
	`uvm_field_int(m_rp_req_id.device_num,UVM_ALL_ON)
	`uvm_field_int(m_ep_req_id,UVM_ALL_ON)
	`uvm_field_int(m_ep_req_id.bus_num,UVM_ALL_ON)
	`uvm_field_int(m_ep_req_id.device_num,UVM_ALL_ON)
	`uvm_field_int(m_rp_pri_sec_sub_bus,UVM_ALL_ON)
	`uvm_field_int(m_rp_pri_sec_sub_bus.pri_bus_num,UVM_ALL_ON)
	`uvm_field_int(m_rp_pri_sec_sub_bus.sec_bus_num,UVM_ALL_ON)
	`uvm_field_int(m_rp_pri_sec_sub_bus.sub_bus_num,UVM_ALL_ON)
	`uvm_field_int(m_usp_pri_sec_sub_bus,UVM_ALL_ON)
	`uvm_field_int(m_usp_pri_sec_sub_bus.pri_bus_num,UVM_ALL_ON)
	`uvm_field_int(m_usp_pri_sec_sub_bus.sec_bus_num,UVM_ALL_ON)
	`uvm_field_int(m_usp_pri_sec_sub_bus.sub_bus_num,UVM_ALL_ON)
	`uvm_field_int(m_max_payload_size,UVM_ALL_ON)
	`uvm_field_int(m_same_payload_size,UVM_ALL_ON)
	`uvm_field_int(m_cap_vc_supp,UVM_ALL_ON)
	`uvm_field_int(staggered_vc_init,UVM_ALL_ON)
	`uvm_field_int(num_vc_enabled,UVM_ALL_ON)
	//`uvm_field_array_int(k_num_vfs,UVM_ALL_ON)
	`uvm_field_array_int(vc_tc_map,UVM_ALL_ON)
	`uvm_field_array_int(vc_enable_val,UVM_ALL_ON)
  	`uvm_field_array_int(vc_disable_val,UVM_ALL_ON)
	`uvm_field_int(tc_supported,UVM_ALL_ON)
        `uvm_field_int(dis_intr,UVM_ALL_ON)
        `uvm_field_int(intx_pin_or_hls,UVM_ALL_ON)
        `uvm_field_int(tph_st_table_index,UVM_ALL_ON)
        `uvm_field_int(intx_pin_b2b,UVM_ALL_ON)
        `uvm_field_int(msi_msix_pin_b2b,UVM_ALL_ON)
        `uvm_field_int(intx_ib_b2b,UVM_ALL_ON)
	`uvm_field_queue_int(m_unmapped_tc_list,UVM_ALL_ON)
	`uvm_field_queue_int(m_p_rsvd_err_queue,UVM_ALL_ON)
	`uvm_field_queue_int(m_np_rsvd_err_queue,UVM_ALL_ON)
	`uvm_field_queue_int(m_cpl_rsvd_err_queue,UVM_ALL_ON)
	`uvm_field_queue_int(m_none_rsvd_err_queue,UVM_ALL_ON)
	`uvm_field_array_int(rej_snoop_transaction,UVM_ALL_ON)
	`uvm_field_int(max_dllps_space_per_clk,UVM_ALL_ON)
	`uvm_field_int(dis_fc_update,UVM_ALL_ON)
	`uvm_field_int(en_ob_pkt_on_fce,UVM_ALL_ON)
	`uvm_field_int(dis_order_chk_cpl,UVM_ALL_ON)
	`uvm_field_int(dis_order_chk_np,UVM_ALL_ON)
	`uvm_field_int(tl2hls_linkdown_reset_beh,UVM_ALL_ON)
	`uvm_field_int(fc_type_none_as_malformed,UVM_ALL_ON)
	`uvm_field_int(flow_ctrl_up_timeout_val,UVM_ALL_ON)
	`uvm_field_int(cpl_weightage_p_np_cpl,UVM_ALL_ON)
	`uvm_field_int(np_weightage_p_np_cpl,UVM_ALL_ON)
	`uvm_field_int(p_weightage_p_np_cpl,UVM_ALL_ON)
	`uvm_field_int(np_weightage_np_loc_np,UVM_ALL_ON)
	`uvm_field_int(local_np_weightage_np_loc_np,UVM_ALL_ON)
	`uvm_field_int(p_weightage_p_loc_p,UVM_ALL_ON)
	`uvm_field_int(loc_p_weightage_p_loc_p,UVM_ALL_ON)
	`uvm_field_int(cpl_weightage_cpl_loc_cpl,UVM_ALL_ON)
	`uvm_field_int(loc_cpl_weightage_cpl_loc_cpl,UVM_ALL_ON)
	`uvm_field_int(cif0_weightage,UVM_ALL_ON)
	`uvm_field_int(cif1_weightage,UVM_ALL_ON)
	`uvm_field_int(cif2_weightage,UVM_ALL_ON)
	`uvm_field_int(cif3_weightage,UVM_ALL_ON)
	`uvm_field_int(cif4_weightage,UVM_ALL_ON)
	`uvm_field_int(cif5_weightage,UVM_ALL_ON)
	`uvm_field_int(cif6_weightage,UVM_ALL_ON)
	`uvm_field_int(cif7_weightage,UVM_ALL_ON)
	`uvm_field_int(tlp_count_threshold_for_upfc_tx,UVM_ALL_ON)
	`uvm_field_int(max_delays_of_clk_tx_upfc,UVM_ALL_ON)
	`uvm_field_int(force_bar_chk_rp,UVM_ALL_ON)
	`uvm_field_int(link_down_event_hal,UVM_ALL_ON)
	`uvm_field_int(dis_tag_release_on_bad_cpl,UVM_ALL_ON)
	`uvm_field_int(pref_to_flr_cpl,UVM_ALL_ON)
	`uvm_field_int(dis_ib_order_chk_on_link_down,UVM_ALL_ON)
	`uvm_field_int(dis_ob_order_chk,UVM_ALL_ON)
	`uvm_field_int(dis_post_delivered_signal_for_ord_chk,UVM_ALL_ON)
	`uvm_field_int(dis_p_p_ib_order_chk,UVM_ALL_ON)
	`uvm_field_int(dis_p_cpl_ib_order_chk,UVM_ALL_ON)
	`uvm_field_int(dis_p_np_ib_order_chk,UVM_ALL_ON)
	`uvm_field_int(dis_p_cpl_ob_order_chk,UVM_ALL_ON)
	`uvm_field_int(dis_p_np_ob_order_chk,UVM_ALL_ON)
	`uvm_field_int(dis_chk_of_tlp_crossing_bar,UVM_ALL_ON)
	`uvm_field_int(dis_vdm_type0_supp,UVM_ALL_ON)
	`uvm_field_int(en_mrdlk_ib,UVM_ALL_ON)
	`uvm_field_int(drop_cpl_hit_fn_in_flr,UVM_ALL_ON)
	`uvm_field_int(cpl_hit_nond0_fn_as_uc,UVM_ALL_ON)
	`uvm_field_int(treat_pois_tlp_as_adv_nonfatal,UVM_ALL_ON)
	`uvm_field_int(en_inv_msg_code,UVM_ALL_ON)
	`uvm_field_int(en_l1_x_no_deact_hint_in_cif,UVM_ALL_ON)
	`uvm_field_int(en_l1x_even_pend_tags_present,UVM_ALL_ON)
	`uvm_field_int(not_send_end_err,UVM_ALL_ON)
	`uvm_field_int(set_ld_in_progress,UVM_ALL_ON)
	`uvm_field_int(stop_hls_if_when_vc_not_active,UVM_ALL_ON)
	`uvm_field_int(stop_hls_if_on_link_down,UVM_ALL_ON)
	`uvm_field_int(stop_ib_hls_if_on_entry_l1,UVM_ALL_ON)
	`uvm_field_int(stop_ib_hls_if_rxpipeline_empty,UVM_ALL_ON)
	`uvm_field_int(timeout_to_rst_linkdown_in_progress,UVM_ALL_ON)
	`uvm_field_int(filter_ur_tlp,UVM_ALL_ON)
	`uvm_field_int(filter_poison_uncorr_tlp,UVM_ALL_ON)
	`uvm_field_int(filter_poison_adv_tlp,UVM_ALL_ON)
	`uvm_field_int(filter_tlps_silent_discard,UVM_ALL_ON)
	`uvm_field_int(filter_poisoned_cpls,UVM_ALL_ON)
	`uvm_field_int(filter_acs_violation_tlp,UVM_ALL_ON)
	`uvm_field_int(filter_unexp_cpls_val_tag,UVM_ALL_ON)
	`uvm_field_int(filter_cpls_inv_tag,UVM_ALL_ON)
	`uvm_field_int(filter_ide_msg,UVM_ALL_ON)
	`uvm_field_int(filter_pm_pme_msg,UVM_ALL_ON)
	`uvm_field_int(filter_drs_msg,UVM_ALL_ON)
	`uvm_field_int(filter_ptm_msg,UVM_ALL_ON)
	`uvm_field_int(filter_pmeturnoff_msg,UVM_ALL_ON)
	`uvm_field_int(filter_pmact_nak_msg,UVM_ALL_ON)
	`uvm_field_int(filter_ltr_msg,UVM_ALL_ON)
	`uvm_field_int(filter_slot_pwr_msg,UVM_ALL_ON)
	`uvm_field_int(filter_err_msg,UVM_ALL_ON)
	`uvm_field_int(filter_intx_msg,UVM_ALL_ON)
        `uvm_field_int(ob_cfg_transaction_check,UVM_ALL_ON)
        `uvm_field_int(check_bme_for_ep_outbound,UVM_ALL_ON)
        `uvm_field_int(check_bme_for_rp_inbound,UVM_ALL_ON)
        `uvm_field_int(use_bus_num_from_cfg_space,UVM_ALL_ON)
        `uvm_field_int(check_io_mem_space_en_for_outbound,UVM_ALL_ON)
        `uvm_field_int(check_mem_base_limit_en_for_outbound,UVM_ALL_ON)
        `uvm_field_int(consume_cfg_type0,UVM_ALL_ON)
        `uvm_field_int(en_rrs_retry,UVM_ALL_ON)
        `uvm_field_int(m_rrs_visibility_en,UVM_ALL_ON)
        `uvm_field_int(m_sbsa_ctrl_ib_msi_low_addr,UVM_ALL_ON)
        `uvm_field_int(m_sbsa_ctrl_ib_msi_hi_addr,UVM_ALL_ON)
        `uvm_field_int(m_sbsa_msi_addr_sel,UVM_ALL_ON)
        `uvm_field_int(m_sbsa_msi_global_en,UVM_ALL_ON)
        `uvm_field_int(m_sbsa_msi_msg_gen_en_for_lae,UVM_ALL_ON)
        `uvm_field_int(m_sbsa_msi_msg_gen_en_for_efod,UVM_ALL_ON)
        `uvm_field_int(m_sbsa_msi_msg_gen_en_for_poli,UVM_ALL_ON)
        `uvm_field_int(m_sbsa_msi_msg_gen_for_first_err,UVM_ALL_ON)
        `uvm_field_int(m_pci_pm_l1_2_supp,UVM_ALL_ON)
        `uvm_field_int(m_pci_pm_l1_1_supp,UVM_ALL_ON)
        `uvm_field_int(m_aspm_l1_2_supp,UVM_ALL_ON)
        `uvm_field_int(m_aspm_l1_1_supp,UVM_ALL_ON)
        `uvm_field_int(m_cap_l1_pm_substate_supp,UVM_ALL_ON)
        `uvm_field_int(m_link_activation_supp,UVM_ALL_ON)
        `uvm_field_int(m_port_comm_mode_restore_t,UVM_ALL_ON)
        `uvm_field_int(m_port_T_power_on_scale,UVM_ALL_ON)
        `uvm_field_int(m_port_T_power_on_value,UVM_ALL_ON)
        `uvm_field_int(m_pci_pm_l1_2_en,UVM_ALL_ON)
        `uvm_field_int(m_pci_pm_l1_1_en,UVM_ALL_ON)
        `uvm_field_int(m_aspm_l1_2_en,UVM_ALL_ON)
        `uvm_field_int(m_aspm_l1_1_en,UVM_ALL_ON)
        `uvm_field_int(m_link_act_interrupt_en,UVM_ALL_ON)
        `uvm_field_int(m_link_act_ctrl,UVM_ALL_ON) //Not for initial update
        `uvm_field_int(m_comm_mode_restore_t,UVM_ALL_ON)
        `uvm_field_int(m_ltr_l1_2_thd_val,UVM_ALL_ON)
        `uvm_field_int(m_ltr_l1_2_thd_scale,UVM_ALL_ON)
        `uvm_field_int(m_T_power_on_scale,UVM_ALL_ON)
        `uvm_field_int(m_T_power_on_val,UVM_ALL_ON)
        `uvm_field_int(user_aspm_l0s_timer,UVM_ALL_ON)
        `uvm_field_int(user_aspm_l1_timer,UVM_ALL_ON)
        `uvm_field_int(aspm_l1_entry_check_only_tx_idle,UVM_ALL_ON)
        `uvm_field_int(user_delay_re_entry_l1,UVM_ALL_ON)
        `uvm_field_int(dis_rp_check_for_min_cred_for_l1_entry,UVM_ALL_ON)
        `uvm_field_int(l1_entry_neg_Recovery_interrupt_mode,UVM_ALL_ON)
        //`uvm_field_int(user_delay_to_send_pmetoack,UVM_ALL_ON)
        `uvm_field_int(user_timeout_to_re_tx_pme,UVM_ALL_ON)
        `uvm_field_int(disable_dut_tx_pme_on_pme_status_set,UVM_ALL_ON)
        `uvm_field_int(block_pm_req_ack_for_pm_enter_l23,UVM_ALL_ON)
        `uvm_field_int(user_delay_to_enter_l1_sub,UVM_ALL_ON)
        `uvm_field_int(disable_ib_tlp_reg_access,UVM_ALL_ON)
        `uvm_field_int(disable_l1_exit_trigger_on_pend_tlps,UVM_ALL_ON)
        `uvm_field_int(enable_power_shutoff_in_l1_2,UVM_ALL_ON)
        `uvm_field_int(pipe_rxeidetectdisable_txcommonmodedisable_mode,UVM_ALL_ON)
        `uvm_field_int(disable_pipe6_l1_x_handshake_phy_wait_timeout,UVM_ALL_ON)
        `uvm_field_int(enable_pm_l1_0_cso,UVM_ALL_ON)
        `uvm_field_int(enable_aspm_l1_0_cso,UVM_ALL_ON)
        `uvm_field_int(user_timeout_before_remove_pwr,UVM_ALL_ON)
        `uvm_field_int(en_wait_for_cpl_for_tx_ob_req,UVM_ALL_ON)
        `uvm_field_int(en_wait_for_rx_idle_bef_l1_x,UVM_ALL_ON)
        `uvm_field_int(client_supply_low_freq_coreclk,UVM_ALL_ON)
        `uvm_field_int(power_recover_ack_mode,UVM_ALL_ON)
        `uvm_field_int(pl1sssel,UVM_ALL_ON)
        `uvm_field_int(l1ssexwocq,UVM_ALL_ON)
        `uvm_field_int(l1sscsorm,UVM_ALL_ON)
        `uvm_field_int(l1sscsore,UVM_ALL_ON)
        `uvm_field_int(pm_clk_freq,UVM_ALL_ON)
        `uvm_field_int(hls_ob_deactivate_timeout_for_l1_entry,UVM_ALL_ON)
        `uvm_field_int(l2_entry_pkt_flush_timeout,UVM_ALL_ON)
	`uvm_field_array_int(m_scaled_flow_ctrl_posted_hdr_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_scaled_flow_ctrl_posted_data_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_scaled_flow_ctrl_non_posted_hdr_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_scaled_flow_ctrl_non_posted_data_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_scaled_flow_ctrl_cpl_hdr_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_scaled_flow_ctrl_cpl_data_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_fcph_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fcpd_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fcnph_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fcnpd_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fccplh_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fccpld_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fcph_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fcpd_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fcnph_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fcnpd_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fccplh_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_fccpld_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(min_p_pld_credits,UVM_ALL_ON)
	`uvm_field_array_int(min_np_pld_credits,UVM_ALL_ON)
	`uvm_field_array_int(min_cpl_pld_credits,UVM_ALL_ON)
	`uvm_field_int(infinite_fm_ph,UVM_ALL_ON)
	`uvm_field_int(infinite_fm_pd,UVM_ALL_ON)
	`uvm_field_int(infinite_fm_nph,UVM_ALL_ON)
	`uvm_field_int(infinite_fm_npd,UVM_ALL_ON)
	`uvm_field_int(infinite_fm_cplh,UVM_ALL_ON)
	`uvm_field_int(infinite_fm_cpld,UVM_ALL_ON)
	`uvm_field_int(m_shared_fcph_x_scale_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fcpd_x_scale_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fcnph_x_scale_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fcnpd_x_scale_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fccplh_x_scale_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fccpld_x_scale_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fcph_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fcpd_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fcnph_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fcnpd_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fccplh_vc_sum,UVM_ALL_ON)
	`uvm_field_int(m_shared_fccpld_vc_sum,UVM_ALL_ON)
	`uvm_field_int(total_greater_outstand_ph,UVM_ALL_ON)
	`uvm_field_int(total_greater_outstand_pd,UVM_ALL_ON)
	`uvm_field_int(total_greater_outstand_nph,UVM_ALL_ON)
	`uvm_field_int(total_greater_outstand_npd,UVM_ALL_ON)
	`uvm_field_int(total_greater_outstand_cplh,UVM_ALL_ON)
	`uvm_field_int(total_greater_outstand_cpld,UVM_ALL_ON)
	`uvm_field_int(m_total_scaled_flow_ctrl_posted_hdr_scale,UVM_ALL_ON)
	`uvm_field_int(m_total_scaled_flow_ctrl_posted_data_scale,UVM_ALL_ON)
	`uvm_field_int(m_total_scaled_flow_ctrl_non_posted_hdr_scale,UVM_ALL_ON)
	`uvm_field_int(m_total_scaled_flow_ctrl_non_posted_data_scale,UVM_ALL_ON)
	`uvm_field_int(m_total_scaled_flow_ctrl_cpl_hdr_scale,UVM_ALL_ON)
	`uvm_field_int(m_total_scaled_flow_ctrl_cpl_data_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_scaled_flow_ctrl_posted_hdr_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_scaled_flow_ctrl_posted_data_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_scaled_flow_ctrl_non_posted_hdr_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_scaled_flow_ctrl_non_posted_data_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_scaled_flow_ctrl_cpl_hdr_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_scaled_flow_ctrl_cpl_data_scale,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fcph_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fcpd_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fcnph_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fcnpd_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fccplh_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fccpld_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fcph_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fcpd_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fcnph_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fcnpd_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fccplh_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(m_shared_fccpld_x_scale_vc,UVM_ALL_ON)
	`uvm_field_array_int(min_shared_p_pld_credits,UVM_ALL_ON)
	`uvm_field_array_int(min_shared_np_pld_credits,UVM_ALL_ON)
	`uvm_field_array_int(min_shared_cpl_pld_credits,UVM_ALL_ON)
	`uvm_field_array_int(Shared_Flow_Control_Usage_Limit,UVM_ALL_ON)
	`uvm_field_array_int(Shared_Flow_Control_Usage_Limit_Enable,UVM_ALL_ON)
	`uvm_field_int(merge_p_cpl_hdr,UVM_ALL_ON)
	`uvm_field_int(merge_p_cpl_data,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_shared_fcph,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_shared_fcpd,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_shared_fcnph,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_shared_fcnpd,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_shared_fccplh,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_shared_fccpld,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_dedicated_fcph,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_dedicated_fcpd,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_dedicated_fcnph,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_dedicated_fcnpd,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_dedicated_fccplh,UVM_ALL_ON)
	`uvm_field_array_enum(cdn_hpa_pcie_fm_shared_scale_encoding_t,inf_zero_merged_dedicated_fccpld,UVM_ALL_ON)
	`uvm_field_array_int(malform_credit_limit_p,UVM_ALL_ON)
	`uvm_field_array_int(malform_credit_limit_np,UVM_ALL_ON)
	`uvm_field_array_int(malform_credit_limit_cpl,UVM_ALL_ON)
	`uvm_field_int(m_bfm_tx_nfts_g1,UVM_ALL_ON)
	`uvm_field_int(m_bfm_tx_nfts_g2,UVM_ALL_ON)
	`uvm_field_int(m_bfm_tx_nfts_g3,UVM_ALL_ON)
	`uvm_field_int(m_bfm_tx_nfts_g4,UVM_ALL_ON)
	`uvm_field_int(m_bfm_tx_nfts_g5,UVM_ALL_ON)
	`uvm_field_int(m_dut_tx_nfts_g1,UVM_ALL_ON)
	`uvm_field_int(m_dut_tx_nfts_g2,UVM_ALL_ON)
	`uvm_field_int(m_dut_tx_nfts_g3,UVM_ALL_ON)
	`uvm_field_int(m_dut_tx_nfts_g4,UVM_ALL_ON)
	`uvm_field_int(m_dut_tx_nfts_g5,UVM_ALL_ON)
	`uvm_field_int(m_ext_sync,UVM_ALL_ON)
	`uvm_field_int(eq_timeout_by_invalid_ts1,UVM_ALL_ON)
	`uvm_field_int(eq_timeout_during_bfm_adjustment,UVM_ALL_ON)
	`uvm_field_int(eq_reject_by_bfm,UVM_ALL_ON)
	`uvm_field_int(eq_reject_by_dut,UVM_ALL_ON)
	`uvm_field_int(dis_all_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_cpcs_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_cxl_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_hls_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_tl_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_dl_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_pl_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_cmn_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_linkdown_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_flr_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_order_check_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_error_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_ur_error_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_malformed_error_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_cpl_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_arbitration_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_fc_timeout_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_credit_upd_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_idg_map_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_initfc_delay_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_replay_timeout_lm_prog,UVM_ALL_ON)
	`uvm_field_int(dis_timeout_dl_feature_lm_prog,UVM_ALL_ON)
	`uvm_field_int(m_def_nak_sch_type,UVM_ALL_ON)
	`uvm_field_int(m_cont_with_sel_Nak,UVM_ALL_ON)
	`uvm_field_int(m_Nak_ignore_window,UVM_ALL_ON)
	`uvm_field_int(m_dllp_payload_int,UVM_ALL_ON)
	`uvm_field_int(m_replay_timeout_limit_val,UVM_ALL_ON)
	`uvm_field_int(m_ack_nak_latency_timer_limit,UVM_ALL_ON)
	`uvm_field_int(m_dl_feature_dllps_tx_timer,UVM_ALL_ON)
	`uvm_field_int(disable_aspm_l0s,UVM_ALL_ON)
	`uvm_field_int(disable_aspm_l1,UVM_ALL_ON)
	`uvm_field_int(disable_pm_l1_scenario,UVM_ALL_ON)
	`uvm_field_int(disable_pm_l2_scenario,UVM_ALL_ON)
        `uvm_field_int(burst_pause_per_tlps_count, UVM_ALL_ON)
        `uvm_field_int(num_low_power_entry, UVM_ALL_ON)
	`uvm_field_int(snoop_rsp_delay_mode       ,UVM_ALL_ON)
	`uvm_field_int(snoop_rsp_delay_mode_before,UVM_ALL_ON)
	`uvm_field_int(snoop_rsp_delay_mode_after ,UVM_ALL_ON)
	`uvm_field_int(snoop_rsp_active_mode      ,UVM_ALL_ON)
	`uvm_field_int(snoop_rdata_random_mode    ,UVM_ALL_ON)
	`uvm_field_int(snoop_rsp_dcd_err_mode,UVM_ALL_ON)
  `uvm_field_int(m_gen6_sds_os_corruption_en, UVM_ALL_ON)
  `uvm_field_int(m_gen6_skp_os_corruption_en, UVM_ALL_ON)
  `uvm_field_int(m_gen6_eieos_corruption_en, UVM_ALL_ON)
  `uvm_field_int(m_gen6_eios_corruption_en, UVM_ALL_ON)
  `ifdef PCIE_GEN7
  `uvm_field_int(m_gen7_sds_os_corruption_en, UVM_ALL_ON)
  `uvm_field_int(m_gen7_skp_os_corruption_en, UVM_ALL_ON)
  `uvm_field_int(m_gen7_eieos_corruption_en, UVM_ALL_ON)
  `uvm_field_int(m_gen7_eios_corruption_en, UVM_ALL_ON)
  `endif
  `uvm_field_int(m_gen5_eios_corruption_en, UVM_ALL_ON)
  `uvm_field_int(m_p_ram_err_injection_enable, UVM_ALL_ON)    
  `uvm_field_int(m_np_ram_err_injection_enable, UVM_ALL_ON)
  `uvm_field_int(m_cpl_ram_err_injection_enable, UVM_ALL_ON)
  `uvm_field_int(m_replay_buffer_ram_err_injection_enable, UVM_ALL_ON)
  `uvm_field_int(m_replay_buffer_ctrl_ram_err_injection_enable, UVM_ALL_ON)
  `uvm_field_int(m_nprt_ram_err_injection_enable, UVM_ALL_ON)
  `uvm_field_int(m_bytecnt_ram_err_injection_enable, UVM_ALL_ON)
  `uvm_field_int(m_axi_ram_err_injection_enable, UVM_ALL_ON)
  `uvm_field_int(m_dma_ram_err_injection_enable, UVM_ALL_ON)
  `uvm_field_int(same_segment_in_both_devices, UVM_ALL_ON)
  `uvm_field_int(flit_err_count, UVM_ALL_ON)
  `uvm_field_int(destination_segment, UVM_ALL_ON)
  `uvm_field_int(requester_segment, UVM_ALL_ON)  
  `uvm_field_int(captured_segment_number, UVM_ALL_ON)  
  `uvm_field_int(m_cxl_io_membar_en, UVM_ALL_ON)
  `uvm_field_int(m_cxl_io_membar_aperture, UVM_ALL_ON)
  `uvm_field_int(m_cxl_io_membar, UVM_ALL_ON)
  `uvm_field_int(m_cxl_io_bar_setup_i, UVM_ALL_ON)
  `uvm_field_int(is_dut_config, UVM_ALL_ON)
  `uvm_field_int(m_override_ips_bar_size, UVM_ALL_ON)
  `uvm_field_int(m_snoop_lat,UVM_ALL_ON)
  `uvm_field_int(m_snoop_sc,UVM_ALL_ON)
  `uvm_field_int(m_nosnoop_lat,UVM_ALL_ON)
  `uvm_field_int(m_nosnoop_sc,UVM_ALL_ON)
  `uvm_field_int(m_tl_to_pack_ecrc,UVM_ALL_ON)
  `uvm_field_int(send_sbsa_cfg_type_1,UVM_ALL_ON)
  `uvm_field_int(cxl_cfg_arb_weight_io,UVM_ALL_ON)
  `uvm_field_int(cxl_cfg_arb_weight_cache_mem,UVM_ALL_ON)
  `uvm_field_int(cxl_ldid_prefix,UVM_ALL_ON)
  `uvm_field_int(cxlreg_intr_vector_client_mmio_snoop_wr_timeout_err                                    , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_client_mmio_snoop_rd_timeout_err                                    , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_link_mmio_snoop_wr_timeout_err                                      , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_link_mmio_snoop_rd_timeout_err                                      , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_intrnl_ras_err                                                      , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_atomic_timeout_err                                                  , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_rloc_block1_err                                                     , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_rloc_block2_err                                                     , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_rloc_block3_err                                                     , UVM_ALL_ON) 
  `uvm_field_int(cxlreg_intr_vector_ide_itrupt_err                                                      , UVM_ALL_ON) 
  `uvm_field_int(PCR_REG_SIZE                                                                           , UVM_ALL_ON) 
  `uvm_field_int(ACL_REG_SIZE                                                                           , UVM_ALL_ON) 
  `uvm_field_int(CPMU_REG_SIZE                                                                          , UVM_ALL_ON) 
  `uvm_field_int(DEVICE_REG_SIZE                                                                        , UVM_ALL_ON) 
  `uvm_field_int(VENDOR_REG_SIZE                                                                        , UVM_ALL_ON) 
  `uvm_field_int(vdm_for_cxl,UVM_ALL_ON)
  `uvm_field_int(cxlio_ctrl_cpl_pbr_from_register,UVM_ALL_ON)
  `uvm_field_int(cxl_pth_rsvd,UVM_ALL_ON)
  `uvm_field_int(cxl_pth_hie,UVM_ALL_ON)
  `uvm_field_int(cxl_pth_dsar,UVM_ALL_ON)
  `uvm_field_int(cxl_pth_pif,UVM_ALL_ON)
  `uvm_field_int(cxl_pth_spid,UVM_ALL_ON)
  `uvm_field_int(cxl_pth_dpid,UVM_ALL_ON)
  `uvm_field_int(cxl_ldid,UVM_ALL_ON)
  `uvm_field_int(aer_pth_logging,UVM_ALL_ON)
  `uvm_field_int(vip_ptm_flit_corr,UVM_ALL_ON)
  `uvm_field_int(vip_ptm_dup,UVM_ALL_ON)
  `uvm_field_int(pth_from_reg,UVM_ALL_ON)
  `uvm_field_int(cxl_pth_dpid_towards_AL,UVM_ALL_ON)
  `uvm_field_enum(cdn_cxl_neg_mode_t, m_cxl_negotiation, UVM_ALL_ON)
  `uvm_field_int(m_is_pf_disabled_by_lm,UVM_ALL_ON)
  `uvm_field_int(power_state_to_d0,UVM_ALL_ON)
  `uvm_field_int(exec_permit,UVM_ALL_ON)
  `uvm_field_int(local_prefix_ecrc_error,UVM_ALL_ON)
  `uvm_field_int(vf_shares_same_queue,UVM_ALL_ON)
  `uvm_field_int(lti_msg_received_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_timeout_occurred_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_xlate_error_faultabort_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_xlate_error_faultrazwi_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_dmwr_nonsys_lrattr_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_enable_dmwr_nonsys_lrattr_error_legacy, UVM_ALL_ON)
  `uvm_field_int(lti_msg_length_check_error_mask,UVM_ALL_ON)
  `uvm_field_int(lti_xlate_unsupported_resp_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_msi_xlate_timeout_occurred_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_msi_xlate_error_faultabort_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_msi_xlate_error_faultrazwi_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_msi_xlate_unsupported_resp_status_mask,UVM_ALL_ON)
  `uvm_field_int(lti_vdm_disable_wr_conversion,UVM_ALL_ON)
  `uvm_field_int(lti_dti_disable_wr_conversion,UVM_ALL_ON)
  `uvm_field_int(lti_disable_xlation_for_msg_conversion,UVM_ALL_ON)
  `uvm_field_int(lti_msg_disable_sw_buffer_overflow,UVM_ALL_ON)
  `uvm_field_int(lti_xlate_error_mark_internal_error,UVM_ALL_ON)
  `uvm_field_int(lti_xlate_msi,UVM_ALL_ON)
  `uvm_field_int(lti_link_down_fast_flush_mode,UVM_ALL_ON)
  `uvm_field_int(lti_bypass,UVM_ALL_ON)
  `uvm_field_int(lti_en_hold_la_credit, UVM_ALL_ON)
  `uvm_field_int(lti_other_msg_disable_wr_conversion,UVM_ALL_ON)
  `uvm_field_int(lti_timeout_resp_type,UVM_ALL_ON)
  `uvm_field_int(lti_xlate_error_faultabort_resp_type,UVM_ALL_ON)
  `uvm_field_int(lti_xlate_error_faultrazwi_resp_type,UVM_ALL_ON)
  `uvm_field_int(lti_xlate_unsupported_response_resp_type,UVM_ALL_ON)
  `uvm_field_int(lti_en_timeout,UVM_ALL_ON)
  `uvm_field_int(lti_en_xlate_error_faultabort_status,UVM_ALL_ON)
  `uvm_field_int(lti_en_xlate_error_faultrazwi_status,UVM_ALL_ON)
  `uvm_field_int(lti_en_dmwr_nonsys_lrattr_status,UVM_ALL_ON)
  `uvm_field_int(lti_en_msg_length_check_error,UVM_ALL_ON)
  `uvm_field_int(lti_en_xlate_unsupported_resp_status,UVM_ALL_ON)
  `uvm_field_int(lti_en_msi_xlate_timeout_occurred_status,UVM_ALL_ON)
  `uvm_field_int(lti_en_msi_xlate_error_faultabort_status,UVM_ALL_ON)
  `uvm_field_int(lti_en_msi_xlate_error_faultrazwi_status,UVM_ALL_ON)
  `uvm_field_int(lti_en_msi_xlate_unsupported_resp_status,UVM_ALL_ON)
  `uvm_field_int(cfg2tl_rx_max_payload_size_in_DW,UVM_ALL_ON)
  `uvm_field_int(m_lm_config_snoop_timeout_val,UVM_ALL_ON)
  // Lane Margining Variable
  `uvm_field_int(more_than_two_retimer_presence_detected,UVM_ALL_ON)
  `uvm_field_int(margining_third_fourth_retimter,UVM_ALL_ON)
  // 
  `uvm_field_int(m_uio_req_256B_bound_dis,UVM_ALL_ON)

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
  // Task: check_phase
  // Extend the check function so that the status of the monitor is checked.
  //------------------------------------------------------------------------
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);

  endfunction : check_phase


  //------------------------------------------------------------------------
  // UTILITY METHODS
  //------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Function: copy_top_cfg
  // To maintain the same variables in B2B TB, use the below fucniton call
  //---------------------------------------------------------------------------
  virtual function void copy_top_cfg(cdn_pcie_hpa_dev_top_config cfg);
    if(cfg ==null)
      `uvm_fatal(get_full_name(), "cfg is null")

    // TC/VC mapping can't be different
    this.m_cap_vc_ext_cap = cfg.m_cap_vc_ext_cap;
    this.m_cap_vc_supp    = cfg.m_cap_vc_supp;
    this.num_vc_enabled   = cfg.num_vc_enabled;
    this.vc_tc_map        = new[cfg.vc_tc_map.size()];
    foreach(cfg.vc_tc_map[i])
      this.vc_tc_map        = cfg.vc_tc_map;
    this.vc_enable_val    = new[cfg.vc_enable_val.size()];
    foreach(cfg.vc_enable_val[i])
      this.vc_enable_val  = cfg.vc_enable_val;

  endfunction

  //---------------------------------------------------------------------------
  // Function: push_config_policies
  // This function loads all configuration policies given in Makefile
  // as UVM plus args, create and push them to configuration policy queue.
  //---------------------------------------------------------------------------
  protected function void push_config_policies_type();
    // Device and Device top config policies
    if ($value$plusargs("RAND_CFG=%0d", is_dev_rand_cfg)) begin
      `uvm_info(get_type_name(),
        $sformatf("## Got RAND_CFG =%0d from command line##", is_dev_rand_cfg),
        UVM_NONE)
    end
    else begin
      is_dev_rand_cfg = 1;
    end

  endfunction
//---------------------------------------------------------------------------
  // Function: allocate_vfs
  // This function controls the fine allocation of VFs to each PFs via populating m_pf_vf_map
  //---------------------------------------------------------------------------
  virtual function void allocate_vfs();
    //int loop_cnt = 0;
    int l_pf = 0;
    int unsigned l_num_vfs = 0;
    bit found_valid_pf_for_vf_map;
    bit [15:0] l_pf_vf_map_0[];
    bit [15:0] l_pf_vf_map_1[];

    if((!i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))
      loop_cnt_vf = l_num_enabled_pfs; //EP DUT can have strap specified Pfs
  else if (m_port_type == CDN_HPA_PCIE_DSP)
      loop_cnt_vf = 1; //RP has 1 Function
  else if ((i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))
      loop_cnt_vf = 2; //2 EP BFMs
    else
       `uvm_error(get_name(),$psprintf("Num pfs unknown"))

       

    if((!i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))//EP - DUT
    begin //{
      if((i_cfg.k_sriov_enable.sum(item) with (int'(item)) == 0) || !i_cfg.strap_sriov_enable)begin
        foreach(m_pf_vf_map[i])
          m_pf_vf_map[i] = 0;
        return;   
      end
      if(scenario)
      begin //{
        //For sanity traffic enable only 2 Vfs Max.
        if(scenario.sanity_traffic) begin
          assert(std::randomize(m_pf_vf_map) with { 
                                                    m_pf_vf_map.sum(item) with (int'(item)) == ((i_cfg.k_num_vfs > 1) ? 1 : i_cfg.k_num_vfs);
                                                    foreach(m_pf_vf_map[i]) { 
                                                      if(i < l_num_enabled_pfs) { m_pf_vf_map[i] >= 0; }
                                                      else { m_pf_vf_map[i] == 0; }
                                                    }
                                                    foreach(m_pf_vf_map[i])
                                                      if(!(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[i])
                                                        m_pf_vf_map[i] == 0;
                                                  });
        end
        else if(scenario.m_pf_setting inside {cdn_pcie_scenario_pkg::MAX_WITH_ALL_BAR_HIT,cdn_pcie_scenario_pkg::MAX})
        begin
          if(scenario.m_vf_allocation_check) begin
            //Distribute VFs in 2 set of PFs. First 8 must have Few VFs and rest must have VFs.
            if((2*parameters_cfg_pkg::KMAX_NUM_PFS)!=i_cfg.k_num_vfs)
              scenario.two_vf_per_pf=0;
              `uvm_info("DEBUG_VF_ALLOCATION", $sformatf("scenario.two_vf_per_pf=%0d", scenario.two_vf_per_pf), UVM_NONE)
            if(scenario.two_vf_per_pf)
              l_pf_vf_map_0 = new[parameters_cfg_pkg::KMAX_NUM_PFS];
            else
            l_pf_vf_map_0 = new[(parameters_cfg_pkg::KMAX_NUM_PFS>parameters_cfg_pkg::MAX_PFS_WITH_VF) ? parameters_cfg_pkg::MAX_PFS_WITH_VF : parameters_cfg_pkg::KMAX_NUM_PFS];
            assert(std::randomize(l_pf_vf_map_0) with {
              //l_pf_vf_map_0.size() == (parameters_cfg_pkg::KMAX_NUM_PFS>parameters_cfg_pkg::MAX_PFS_WITH_VF) ? parameters_cfg_pkg::MAX_PFS_WITH_VF : parameters_cfg_pkg::KMAX_NUM_PFS;
              if(scenario.two_vf_per_pf)
              l_pf_vf_map_0.sum(item) with (int'(item)) == i_cfg.k_num_vfs;
              else l_pf_vf_map_0.sum(item) with (int'(item)) == i_cfg.k_num_vfs/2;
              foreach(l_pf_vf_map_0[i]) { 
                if(i < l_num_enabled_pfs) {
                  if(scenario.two_vf_per_pf){
                    l_pf_vf_map_0[i] == 2;}
                  else {l_pf_vf_map_0[i] >=0;}
                  }
                else { l_pf_vf_map_0[i] == 0; }
              }
              foreach(l_pf_vf_map_0[i])
                if(!(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[i] || !i_cfg.strap_ari_enable)
                  l_pf_vf_map_0[i] == 0;
            });
            if(parameters_cfg_pkg::KMAX_NUM_PFS>parameters_cfg_pkg::MAX_PFS_WITH_VF) begin
              l_pf_vf_map_1 = new[(parameters_cfg_pkg::KMAX_NUM_PFS-parameters_cfg_pkg::MAX_PFS_WITH_VF)];
              assert(std::randomize(l_pf_vf_map_1) with {
                if(scenario.two_vf_per_pf)
                l_pf_vf_map_1.sum(item) with (int'(item)) ==0;
                else  l_pf_vf_map_1.sum(item) with (int'(item)) ==i_cfg.k_num_vfs/2;
                foreach(l_pf_vf_map_1[i]) { 
                  if((i+parameters_cfg_pkg::MAX_PFS_WITH_VF) < l_num_enabled_pfs) { l_pf_vf_map_1[i] >= 0; }
                  else { l_pf_vf_map_1[i] == 0; }
                }
                foreach(l_pf_vf_map_1[i])
                  if(!(i_cfg.k_sriov_enable[(i+parameters_cfg_pkg::MAX_PFS_WITH_VF)] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[(i+parameters_cfg_pkg::MAX_PFS_WITH_VF)] || !i_cfg.strap_ari_enable)
                    l_pf_vf_map_1[i] == 0;
              });
            end
            foreach(m_pf_vf_map[i]) begin
              if(i<l_pf_vf_map_0.size())
                m_pf_vf_map[i] = l_pf_vf_map_0[i];
              else
                m_pf_vf_map[i] = l_pf_vf_map_1[i-l_pf_vf_map_0.size()];
              `uvm_info("DEBUG_VF_ALLOCATION", $sformatf("l_pf_vf_map_0[%0d]=%0d", i, l_pf_vf_map_0[i]), UVM_NONE)
              `uvm_info("DEBUG_VF_ALLOCATION", $sformatf("l_pf_vf_map_1[%0d]=%0d", i-l_pf_vf_map_0.size(), l_pf_vf_map_1[i-l_pf_vf_map_0.size()]), UVM_NONE)
              `uvm_info("DEBUG_VF_ALLOCATION", $sformatf("m_pf_vf_map[%0d]=%0d", i, m_pf_vf_map[i]), UVM_NONE)
            end
          end
          else begin
            l_pf = $urandom_range(0, l_num_enabled_pfs - 1);
            randcase
              ((!(i_cfg.k_sriov_enable[l_pf] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[l_pf]) ? 0 : 50) : begin
                     //ALL_BAR + MAX
                     assert(std::randomize(m_pf_vf_map) with {
                       m_pf_vf_map[l_pf] == (i_cfg.k_num_vfs < 32) ? i_cfg.k_num_pfs:32;
                       m_pf_vf_map.sum(item) with (int'(item)) == i_cfg.k_num_vfs;
                       foreach(m_pf_vf_map[i])
                         if(!(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[i])
                           m_pf_vf_map[i] == 0;
                     });
                   end
                   
              50 : begin
              //MAX
              assert(std::randomize(m_pf_vf_map) with {
                  m_pf_vf_map.sum(item) with (int'(item)) == i_cfg.k_num_vfs;
                foreach(m_pf_vf_map[i]) { 
                  if(i < l_num_enabled_pfs) { m_pf_vf_map[i] >= 0; }
                  else { m_pf_vf_map[i] == 0; }
                }
                foreach(m_pf_vf_map[i])
                  if(!(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[i])
                    m_pf_vf_map[i] == 0;
              });
              end
            endcase
              `uvm_info("DEBUG_VF_ALLOCATION", $sformatf("m_pf_vf_map=%0p",m_pf_vf_map), UVM_NONE)
          end
        end

        if(scenario.m_pf_setting inside {cdn_pcie_scenario_pkg::MIN})
        begin
          foreach(m_pf_vf_map[i])
            m_pf_vf_map[i] = 0;
        end
        if(scenario.m_pf_setting inside {cdn_pcie_scenario_pkg::CUSTOM})
        begin
          assert(std::randomize(m_pf_vf_map)  with {
            if(scenario.m_num_vf <= i_cfg.k_num_vfs)
              m_pf_vf_map.sum(item) with (int'(item)) == scenario.m_num_vf;
            else
              m_pf_vf_map.sum(item) with (int'(item)) == i_cfg.k_num_vfs;
            foreach(m_pf_vf_map[i]) { 
              if(i < l_num_enabled_pfs) { m_pf_vf_map[i] >= 0; }
              else { m_pf_vf_map[i] == 0; }
            }
            foreach(m_pf_vf_map[i])
              if(!(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[i])
                m_pf_vf_map[i] == 0;
          });
          `uvm_info(get_full_name, $psprintf("scenario.m_num_vf = %0d, strap_pcie_rate_max =%0d, i_cfg.k_num_vfs =%0d, l_num_enabled_pfs = %0d", scenario.m_num_vf, i_cfg.strap_pcie_rate_max, i_cfg.k_num_vfs, l_num_enabled_pfs), UVM_NONE)
        end
        if(scenario.m_pf_setting inside {cdn_pcie_scenario_pkg::RANDOM})
        begin //{
          foreach(m_is_pf_disabled_by_lm[i]) begin
            if((i<l_num_enabled_pfs) && m_is_pf_disabled_by_lm[i]==0 && i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) begin
               found_valid_pf_for_vf_map = 1;
               break; 
            end
          end
          assert(std::randomize(l_num_vfs)  with {
            if(i_cfg.strap_sriov_enable == 0)
              l_num_vfs == 0;
            l_num_vfs <= i_cfg.k_num_vfs;
            l_num_vfs >= 0;
            (!found_valid_pf_for_vf_map) -> l_num_vfs ==0;
            if(i_cfg.strap_pcie_rate_max <= 2)
              l_num_vfs <= 2;
            else
              l_num_vfs dist {
                                [0:2    ] :=256,
                                [3:4    ] :=128,
                                [5:8    ] :=64,
                                [9:16   ] :=32,
                                [17:32  ] :=16,
                                [33:64  ] :=8,
                                [65:128 ] :=4,
                                [129:256] :=2
                             };
          });
          l_pf = $urandom_range(0, l_num_enabled_pfs - 1);
          randcase
            ((!(i_cfg.k_sriov_enable[l_pf] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[l_pf]) ? 0 : 50) : begin
            //ALL_BAR + MAX
            // l_pf = $urandom_range(0, l_num_enabled_pfs - 1);// nvatev - Replaced due to randomization failures
            assert(std::randomize(m_pf_vf_map) with {
              m_pf_vf_map.sum(item) with (int'(item)) == l_num_vfs;
              foreach(m_pf_vf_map[i])
                if(!(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[i])
                  m_pf_vf_map[i] == 0;
                else if (i==l_pf)
                  m_pf_vf_map[l_pf] == l_num_vfs;
            });
            end

            50 : begin
            //MAX
            assert(std::randomize(m_pf_vf_map) with {
              m_pf_vf_map.sum(item) with (int'(item)) == l_num_vfs;
              foreach(m_pf_vf_map[i]) { 
                if(i < l_num_enabled_pfs) { m_pf_vf_map[i] >= 0; }
                else { m_pf_vf_map[i] == 0; }
              }
              foreach(m_pf_vf_map[i])
                if(!(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[i])
                  m_pf_vf_map[i] == 0;
            });
            end
          endcase
          //assert(std::randomize(m_pf_vf_map)  with {
          //  m_pf_vf_map.sum(item) with (int'(item)) == l_num_vfs;
          //  foreach(m_pf_vf_map[i]) { 
          //    if(i < l_num_enabled_pfs) { m_pf_vf_map[i] >= 0; }
          //    else { m_pf_vf_map[i] == 0; }
          //  }
          //  foreach(m_pf_vf_map[i])
          //    if(i_cfg.k_sriov_enable[i] == 0)
          //      m_pf_vf_map[i] == 0;
          //});
          `uvm_info(get_full_name, $psprintf("l_num_vfs = %0d, strap_pcie_rate_max =%0d, i_cfg.k_num_vfs =%0d, l_num_enabled_pfs = %0d, i_cfg.strap_sriov_enable = %0d", l_num_vfs, i_cfg.strap_pcie_rate_max, i_cfg.k_num_vfs, l_num_enabled_pfs, i_cfg.strap_sriov_enable), UVM_NONE)
          foreach(m_pf_vf_map[i])
            `uvm_info(get_full_name, $psprintf("m_pf_vf_map[%d]= %0d", i, m_pf_vf_map[i]), UVM_NONE)
        end //}
      end //}
      else
      begin //{
        assert(std::randomize(m_pf_vf_map)  with {
          m_pf_vf_map.sum(item) with (int'(item)) <= i_cfg.k_num_vfs;
          m_pf_vf_map.sum(item) with (int'(item)) >= 0;
          foreach(m_pf_vf_map[i]) { 
            if(i < l_num_enabled_pfs) { m_pf_vf_map[i] >= 0; }
            else { m_pf_vf_map[i] == 0; }
          }
          foreach(m_pf_vf_map[i])
            if(!(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable) || m_is_pf_disabled_by_lm[i])
              m_pf_vf_map[i] == 0;
        });
      end //}
    end //}
    else //RP - DUT/BFM || EP-BFM
    begin
      foreach(m_pf_vf_map[i])
        m_pf_vf_map[i] = 0;
    end

    //foreach(m_pf_vf_map[i])
    //  `uvm_info(get_full_name, $psprintf("m_pf_vf_map[%d]= %0d", i, m_pf_vf_map[i]), UVM_NONE)
  endfunction : allocate_vfs

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------
  virtual function void create_pf_config();
    cdn_pcie_dev_config_random_policy dev_rand_pcy[];
    cdn_pcie_dev_config_default_policy dev_default_pcy[];
    cdn_pcie_hpa_config_base_policy base_pcy;
    //int loop_cnt;
    int idx;
    uvm_mem_region bar_region;
    cdn_cxl_io_32bit_rcrb_policy rcrb_32_policy;
    cdn_cxl_io_64bit_rcrb_policy rcrb_64_policy;
    cdn_cxl_io_64bit_rcrb_policy membar_policy;

    allocate_vfs();
    if((!i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))begin
	loop_cnt_pf = l_num_enabled_pfs; //EP DUT can have strap specified Pfs
  end
  else if (m_port_type == CDN_HPA_PCIE_DSP)
	loop_cnt_pf = 1; //RP has 1 Function
else if ((i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP)) begin
	loop_cnt_pf = 2; //2 EP BFMs
  end
    else
       `uvm_error(get_name(),$psprintf("Num pfs unknown"))

    dev_rand_pcy    = new[loop_cnt_pf];
    dev_default_pcy = new[loop_cnt_pf];



    // In CXL IO mode assign RCRB and membars from mem mam
    m_cxl_io_32_bar = 0; // TODO
    if(i_cfg.k_cxl_support && memory_map != null && is_dut_config) begin
      if(m_cxl_io_32_bar) begin
        rcrb_32_policy = new();
        bar_region = memory_map.request_region(2**13 ,rcrb_32_policy); // - 8k space
      end
      else begin
        cdn_cxl_io_64bit_rcrb_policy rcrb_64_policy = new();
        bar_region = memory_map.request_region(2**13 , rcrb_64_policy); // - 8k space
      end
      if(!assign_seq_mem)
        m_cxl_io_rcrb_bar = bar_region.get_start_offset();
      else  
        m_cxl_io_rcrb_bar = m_ep_dev_bar_info.m_cxl_io_rcrb.start_addr;

      membar_policy = new();
      bar_region       = memory_map.request_region(2**m_cxl_io_membar_aperture ,membar_policy); //TODO 8k space
      
      if(!assign_seq_mem) begin
        m_cxl_io_membar = bar_region.get_start_offset();
        m_cxl_io_bar_setup_i[6:1]  = m_cxl_io_membar_aperture;
      end
      else begin
        m_cxl_io_membar = m_ep_dev_bar_info.m_cxl_io_membar.start_addr;
        m_cxl_io_bar_setup_i[6:1]  = m_ep_dev_bar_info.m_cxl_io_membar.bar_aperture;
      end

      m_cxl_io_bar_setup_i[0]    = m_cxl_io_membar_en;
      m_cxl_io_bar_setup_i[63:7] = m_cxl_io_membar[63:7];
    end

    for (int i = 0; i< loop_cnt_pf ; i++) begin
    if ((i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))
     idx = 0;
    else
     idx = i;

      pf_config[i] = cdn_hpa_pcie_dev_config::type_id::create($psprintf("%0s.pf_config[%0d]",get_full_name(),i),this);
      pf_config[i].enable_err_reporting = enable_err_reporting;
      pf_config[i].k_pcie_rate_max = k_pcie_rate_max;
      pf_config[i].strap_pcie_rate_max = strap_pcie_rate_max;
      pf_config[i].k_max_read_request_size = k_max_read_request_size;
      pf_config[i].i_cfg = i_cfg;
      pf_config[i].m_cap_ari_supp = m_ari_supp;
      pf_config[i].m_pf_num = i;
      pf_config[i].m_vf_num = 'hDEAD; //Indicator that this dev_cfg is only PF and not VF
      pf_config[i].m_is_pf = 1;
      pf_config[i].m_pf_vf_map = this.m_pf_vf_map;
      pf_config[i].m_lm_sris_enable = this.m_lm_sris_enable;
      pf_config[i].inject_err_en = inject_err_en;
      pf_config[i].force_bar_chk_rp = force_bar_chk_rp;
      pf_config[i].is_dut_config = is_dut_config;
      //pf_config[i].m_uio_req_256B_bound_dis = this.m_uio_req_256B_bound_dis;
      if(i inside {[0:3]})
      pf_config[i].m_intr_pins = i+1;
      else
      pf_config[i].m_intr_pins = 1;
      if(i_cfg.k_cxl_support) begin
        pf_config[i].m_cxl_io_rcrb_bar        = this.m_cxl_io_rcrb_bar;
        pf_config[i].m_cxl_io_membar          = this.m_cxl_io_membar;
        pf_config[i].m_cxl_io_membar_aperture = this.m_cxl_io_membar_aperture;
      end

      if (lti_en && lti_en_dmwr_nonsys_lrattr_status) begin
        if (i_cfg.k_dmwr_req_support)
          pf_config[i].m_dmwr_req_en = 1;
        if (i_cfg.k_dmwr_compl_support)
          pf_config[i].m_dmwr_completer_supp = 1;
      end

      //$display("DEV_CFG: Created PF_%0d dev_cfg",i);

      if(is_dev_rand_cfg) begin
        dev_rand_pcy[i] = cdn_pcie_dev_config_random_policy::type_id::create($psprintf("%0s.dev_rand_pcy[%0d]",get_full_name(),i), this);
        $cast(base_pcy, dev_rand_pcy[i]);
        pf_config[i].pcy_q.push_back(base_pcy);
      end
      else begin
        // Default pociy class
        dev_default_pcy[i] = cdn_pcie_dev_config_default_policy::type_id::create($psprintf("%0s.dev_default_pcy[%0d]",get_full_name(),i), this);
        $cast(base_pcy, dev_default_pcy[i]);
        pf_config[i].pcy_q.push_back(base_pcy);
      end

      if(i==0) begin
        if (!pf_config[i].randomize() with {m_port_type == local::m_port_type;
          m_same_payload_size == local::m_same_payload_size;
          if(i_cfg.scenario)
            if(i_cfg.scenario.faultrazwi_split_cpl) 
               m_max_payload_size == local::m_max_payload_size;
          if (m_same_payload_size) {
            m_max_payload_size == local::m_max_payload_size; //same payload for all Functions
          }
          mixed_mps_supported == local::mixed_mps_supported;
          rx_mps_fixed == local::rx_mps_fixed;
                                            m_aspm_supp == local::m_aspm_supp;
					                                  m_TotalVFs  == ((!i_cfg.strap_is_rp) ? m_pf_vf_map[idx] : 0);
					                                  m_NumVFs    <= ((!i_cfg.strap_is_rp) ? m_pf_vf_map[idx] : 0);
					                                  m_vf_en  == ((i_cfg.strap_port_type inside {2,3})? 0 : ((!i_cfg.strap_is_rp) ? (i_cfg.k_sriov_enable[idx] && i_cfg.strap_sriov_enable) : 0));
					                                  //m_req_id.bus_num == ((local::m_port_type == CDN_HPA_PCIE_USP) ? m_ep_req_id.bus_num : m_rp_req_id.bus_num);
					                                  m_req_id.bus_num == local::m_req_id.bus_num;
                                            if((!i_cfg.strap_is_rp && is_dut_config) || (i_cfg.strap_is_rp && (!is_dut_config))) //EP mode
                                            {
					                                    if(!i_cfg.strap_ari_enable) {
					                                      m_req_id.device_num == (parameters_cfg_pkg::KMAX_SBSA_SUPPORT == 1 ? 0 : local::m_req_id.device_num);
					                                      m_req_id.function_num == local::function_num[i];
					                                    } else {
                                               {m_req_id.device_num,m_req_id.function_num} == local::function_num[i]; // Assign the randomzied func number variable
					                                    }
                                            }
                                            else //RP - ari capability is for EP only
                                            {
					                                    m_req_id.device_num == local::m_req_id.device_num;
					                                    m_req_id.function_num == local::function_num[i];
                                            }
                                            if(i_cfg.strap_is_rp && (!is_dut_config)) {
                                              acs_translation_blocking_en == is_acs_translation_blocking_en;
                                            }
					                                  m_extended_sync == m_ext_sync;
                                            // AXI Bridge limitation - 10/14 bit tag supports if all the functions supports 10/14 bit tag - common tag pool
`ifdef BRIDGE
                                            m_vf_10_bit_tag_req_en == m_10_bit_tag_req_en;
                                            m_vf_14_bit_tag_req_en == m_14_bit_tag_req_en;  
`endif // BRIDGE
                                            m_rcb == local::m_rcb;
                                            if(local::treat_pois_tlp_as_adv_nonfatal)
                                              m_poisoned_tlp_received_severity != local::treat_pois_tlp_as_adv_nonfatal;
                                            //TODO Disabling INTx for DUT DUT TB. E2E scoreboard needs Exp Intx packet, when Intx driven via pin
                                            is_dut_dut_tb -> dis_intr==1;
			                   }) begin
            `uvm_fatal(get_name(), "Randomization Failed!!!")
        end
      end else begin
        if (!pf_config[i].randomize() with {m_port_type == local::m_port_type;
          m_same_payload_size == local::m_same_payload_size;
          if(i_cfg.scenario)
            if(i_cfg.scenario.faultrazwi_split_cpl)
                m_max_payload_size == local::m_max_payload_size; //same payload for all Functions
          if (m_same_payload_size) {
            m_max_payload_size == local::m_max_payload_size; //same payload for all Functions
          }
          mixed_mps_supported == local::mixed_mps_supported;
          rx_mps_fixed == local::rx_mps_fixed;
                                            m_ats_ro_bit_support == pf_config[0].m_ats_ro_bit_support;
                                            //m_max_rd_req_size ==   pf_config[0].m_max_rd_req_size; //Implementation restriction. DUT will work on Min of all Functions programmed MRRS
					    m_dmwr_lengths_supp == pf_config[0].m_dmwr_lengths_supp;//When applicable, all Functions in a Multi-Function Device associated with an Upstream Port must report the same value in this field.
              m_ecrc_chk_en == pf_config[0].m_ecrc_chk_en; //If any PF enabled for ECRC chk, DUT will check for ECRC error. So, keep same values in all PF
					    //Implementation restriction. PF0 fields controls total device atomicop completer support
					    m_32_atomic_op_compl_supp == pf_config[0].m_32_atomic_op_compl_supp;
					    m_64_atomic_op_compl_supp == pf_config[0].m_64_atomic_op_compl_supp;
					    m_128_cas_compl_supp == pf_config[0].m_128_cas_compl_supp;
              // AXI Bridge limitation - 10/14 bit tag supports if all the functions supports 10/14 bit tag - common tag pool
`ifdef BRIDGE
              m_ext_tag_en == pf_config[0].m_ext_tag_en;
              m_ltr_en == pf_config[0].m_ltr_en;
              m_10_bit_tag_req_en == pf_config[0].m_10_bit_tag_req_en;
              m_vf_10_bit_tag_req_en == pf_config[0].m_10_bit_tag_req_en;
              m_14_bit_tag_req_en == pf_config[0].m_14_bit_tag_req_en;
              m_vf_14_bit_tag_req_en == pf_config[0].m_14_bit_tag_req_en;
`endif
					    m_TotalVFs  == ((!i_cfg.strap_is_rp) ? m_pf_vf_map[idx] : 0);
					    m_NumVFs    <= ((!i_cfg.strap_is_rp) ? m_pf_vf_map[idx] : 0);
					    m_vf_en  == ((i_cfg.strap_port_type inside {2,3})? 0 : ((!i_cfg.strap_is_rp) ? (i_cfg.k_sriov_enable[idx] && i_cfg.strap_sriov_enable) : 0));
					    //m_req_id.bus_num == ((local::m_port_type == CDN_HPA_PCIE_USP) ? m_ep_req_id.bus_num : m_rp_req_id.bus_num);
					    m_req_id.bus_num == local::m_req_id.bus_num;
              if(local::treat_pois_tlp_as_adv_nonfatal)
                m_poisoned_tlp_received_severity != local::treat_pois_tlp_as_adv_nonfatal;
              if((!i_cfg.strap_is_rp && is_dut_config) || (i_cfg.strap_is_rp && (!is_dut_config))) //EP mode
              {
					      if(!i_cfg.strap_ari_enable) {
					        m_req_id.device_num == (parameters_cfg_pkg::KMAX_SBSA_SUPPORT == 1 ? 0 : local::m_req_id.device_num);
					        m_req_id.function_num == local::function_num[i];
					      } else {
                  {m_req_id.device_num,m_req_id.function_num} == local::function_num[i];
					      }
              }
              else //RP - ari capability is for EP only
              {
					      m_req_id.device_num == local::m_req_id.device_num;
					      m_req_id.function_num == local::function_num[i];
              }
              if(i_cfg.strap_is_rp && (!is_dut_config)) {
                acs_translation_blocking_en == is_acs_translation_blocking_en;
              }
					    m_extended_sync == m_ext_sync;
					    m_aspm_supp == pf_config[0].m_aspm_supp; //All fns should report same value
					    m_l0s_exit_lat == pf_config[0].m_l0s_exit_lat; //All fns should report same value
					    m_l1_exit_lat == pf_config[0].m_l1_exit_lat; //All fns should report same value
					    root_port_rcb == pf_config[0].root_port_rcb;
					    //For Multi-Function Devices associated with an Upstream Port, all Functions that report a non-zero value
					    //for this field, must report the same non-zero value for this field.
					    m_emrgcy_pwr_reduc_supp inside {0,pf_config[0].m_emrgcy_pwr_reduc_supp};
					    m_emrgcy_pwr_reduc_init_reqd == pf_config[0].m_emrgcy_pwr_reduc_init_reqd;
              m_e2e_tlp_prefix_support == pf_config[0].m_e2e_tlp_prefix_support;
              m_max_e2e_support == pf_config[0].m_max_e2e_support;
              m_tph_cpl_support== pf_config[0].m_tph_cpl_support;
              m_rcb == local::m_rcb;
              m_ido_req_en == pf_config[0].m_ido_req_en;
              m_ido_cpl_en == pf_config[0].m_ido_cpl_en;
              `ifdef HAS_UIO
              m_uio_Mem_RdWr_req_en == pf_config[0].m_uio_Mem_RdWr_req_en;
              m_uio_req_256B_bound_dis == pf_config[0].m_uio_req_256B_bound_dis;
              `endif
              //Dev cap 3 reg
              m_rx_l0p_supp == pf_config[0].m_rx_l0p_supp;
              m_port_l0p_exit_lat == pf_config[0].m_port_l0p_exit_lat;
              m_retimer_l0p_exit_lat == pf_config[0].m_retimer_l0p_exit_lat;
              `ifdef HAS_UIO
              m_uio_Mem_RdWr_compl_supp == pf_config[0].m_uio_Mem_RdWr_compl_supp;
              m_uio_Mem_RdWr_req_supp == pf_config[0].m_uio_Mem_RdWr_req_supp;
              // SVC Res cap
              m_svcR_3_ProtocolsSupported== pf_config[0].m_svcR_3_ProtocolsSupported;
              // SVC Res ctrl
              m_svcR_3_sel== pf_config[0].m_svcR_3_sel;
              m_svcR_3_vc_en== pf_config[0].m_svcR_3_vc_en;
              `endif 
              
              //TODO Disabling INTx for DUT DUT TB. E2E scoreboard needs Exp Intx packet, when Intx driven via pin
              is_dut_dut_tb -> dis_intr==1;
			                   }) begin
            `uvm_fatal(get_name(), "Randomization Failed!!!")
        end
      end
       pf_config[i].exp_rom_en = i_cfg.k_exp_rom_bar_enable[i];

      `uvm_info("DEV_CFG",$psprintf("Randomized pf_config[%0d]= %0s",i,pf_config[i].sprint()),UVM_FULL)
      `uvm_info("DEV_CFG",$psprintf("Randomized pf_config[%0d]= %0s",i,pf_config[i].sprint()),UVM_NONE)

       foreach(m_unmapped_tc_list[k])
         pf_config[i].m_unmapped_tc_list.push_back(m_unmapped_tc_list[k]);

      end

  endfunction

  //TODO
  virtual function void create_vf_config();
    cdn_pcie_dev_config_random_policy dev_rand_pcy[][];
    cdn_pcie_dev_config_default_policy dev_default_pcy[][];
    cdn_pcie_hpa_config_base_policy base_pcy;

    dev_rand_pcy = new[l_num_enabled_pfs];
    dev_default_pcy = new[l_num_enabled_pfs];

    for (int i = 0; i< l_num_enabled_pfs ; i++) begin
      dev_rand_pcy[i] = new[pf_config[i].m_NumVFs];
      dev_default_pcy[i] = new[pf_config[i].m_NumVFs];
     for (int j = 0; j< pf_config[i].m_NumVFs  ; j++) begin
      vf_config[i][j] = cdn_hpa_pcie_dev_config::type_id::create($psprintf("%0s.vf_config[%0d][%0d]",get_full_name(),i,j),this);
      //vf_config[i][j].k_pcie_rate_max = k_pcie_rate_max;
      //vf_config[i][j].strap_pcie_rate_max = strap_pcie_rate_max;
      //vf_config[i][j].k_max_read_request_size = k_max_read_request_size;
      vf_config[i][j].i_cfg    = i_cfg;
      vf_config[i][j].m_vf_num = j;
      vf_config[i][j].m_pf_num = i;
      vf_config[i][j].m_is_vf  = 1;
      vf_config[i][j].inject_err_en            = inject_err_en;
      vf_config[i][j].force_bar_chk_rp         = force_bar_chk_rp;
      vf_config[i][j].m_cxl_io_rcrb_bar        = this.m_cxl_io_rcrb_bar;
      vf_config[i][j].m_cxl_io_membar          = this.m_cxl_io_membar;
      vf_config[i][j].m_cxl_io_membar_aperture = this.m_cxl_io_membar_aperture;
      vf_config[i][j].is_dut_config             = this.is_dut_config;

      //$display("DEV_CFG: Created PF_%0d_VF_%0d dev_cfg",i,j);

      if(is_dev_rand_cfg) begin
        dev_rand_pcy[i][j] = cdn_pcie_dev_config_random_policy::type_id::create($psprintf("%0s.dev_rand_pcy[%0d][%0d]",get_full_name(),i,j), this);
        $cast(base_pcy, dev_rand_pcy[i][j]);
        vf_config[i][j].pcy_q.push_back(base_pcy);
      end
      else begin
        // Default pociy class
        dev_default_pcy[i][j] = cdn_pcie_dev_config_default_policy::type_id::create($psprintf("%0s.dev_default_pcy[%0d][%0d]",get_full_name(),i,j), this);
        $cast(base_pcy, dev_default_pcy[i][j]);
        vf_config[i][j].pcy_q.push_back(base_pcy);
      end

      if(j==0) begin
        if (!vf_config[i][j].randomize() with {m_port_type == local::m_port_type;
					       m_req_id.bus_num == local::m_req_id.bus_num;
					       {m_req_id.device_num,m_req_id.function_num} == ({pf_config[i].m_req_id.device_num,pf_config[i].m_req_id.function_num} + pf_config[i].m_first_vf_Offset);
					       //Dev Cap reg
					       phantom_fn_supp == 0;
					       //Dev control reg
                                               m_corr_err_rpt_en  ==    pf_config[i].m_corr_err_rpt_en;
                                               m_non_fatal_err_rpt_en ==pf_config[i].m_non_fatal_err_rpt_en;
                                               m_fatal_err_rpt_en ==    pf_config[i].m_fatal_err_rpt_en;
                                               m_unsupp_req_rpt_en ==   pf_config[i].m_unsupp_req_rpt_en;
                                               m_relax_ordering_en ==   pf_config[i].m_relax_ordering_en;
                                               m_same_payload_size ==    pf_config[i].m_same_payload_size;
                                               m_max_payload_size ==    pf_config[i].m_max_payload_size;
                                               rx_mps_fixed ==    pf_config[i].rx_mps_fixed;
                                               mixed_mps_supported ==    pf_config[i].mixed_mps_supported;
                                               m_phantom_func_en ==     pf_config[i].m_phantom_func_en;
                                               m_aux_pwr_pm_en ==       pf_config[i].m_aux_pwr_pm_en;
                                               m_no_snoop_en ==         pf_config[i].m_no_snoop_en;
                                               m_max_rd_req_size ==     pf_config[i].m_max_rd_req_size;
                                               m_ats_ro_bit_support ==  pf_config[i].m_ats_ro_bit_support;
					       //Link cap register
					       m_aspm_supp ==        pf_config[i].m_aspm_supp; //TODO is this needed?
					       m_l0s_exit_lat == pf_config[i].m_l0s_exit_lat; //TODO is this needed?
					       m_l1_exit_lat == pf_config[i].m_l1_exit_lat; //TODO is this needed?
					       //Link control register
					       m_aspm_control ==        pf_config[i].m_aspm_control;
					       m_extended_sync ==        pf_config[i].m_extended_sync;
					       //Dev cap 2 reg
					       m_compl_timeout_ranges_supp == pf_config[i].m_compl_timeout_ranges_supp;
					       m_compl_timeout_disable_supp == pf_config[i].m_compl_timeout_disable_supp;
					       m_32_atomic_op_compl_supp == pf_config[i].m_32_atomic_op_compl_supp;
					       m_64_atomic_op_compl_supp == pf_config[i].m_64_atomic_op_compl_supp;
					       m_128_cas_compl_supp == pf_config[i].m_128_cas_compl_supp;
					       m_10bit_tag_reqr_supp == pf_config[i].m_vf_10_bit_tag_Req_supp; //If PF's SRIOV cap says 10 bit tag supp: Apply to all VFs
					       m_10_bit_tag_completer_cap == pf_config[i].m_10_bit_tag_completer_cap;
					       m_emrgcy_pwr_reduc_supp == pf_config[i].m_emrgcy_pwr_reduc_supp;
					       m_emrgcy_pwr_reduc_init_reqd == pf_config[i].m_emrgcy_pwr_reduc_init_reqd;
					       m_dmwr_lengths_supp == pf_config[i].m_dmwr_lengths_supp;
                 m_e2e_tlp_prefix_support == pf_config[0].m_e2e_tlp_prefix_support;
                 m_max_e2e_support == pf_config[0].m_max_e2e_support;
                 m_tph_cpl_support== pf_config[0].m_tph_cpl_support;
                                               //Dev control 2
					       m_compl_timeout_value == pf_config[i].m_compl_timeout_value;
					       m_compl_timeout_disable == pf_config[i].m_compl_timeout_disable;
					       m_atomic_op_req_en == pf_config[i].m_atomic_op_req_en;
					       m_ido_req_en == pf_config[i].m_ido_req_en;
					       m_ido_cpl_en == pf_config[i].m_ido_cpl_en;
					       // AXI Bridge limitation - 10/14 bit tag supports if all the functions supports 10/14 bit tag - common tag pool
`ifdef BRIDGE
                 m_ext_tag_en           ==  pf_config[0].m_ext_tag_en;
                 m_10_bit_tag_req_en    ==  pf_config[0].m_10_bit_tag_req_en;
		             m_vf_10_bit_tag_req_en ==  pf_config[0].m_10_bit_tag_req_en;
`else
                 m_ext_tag_en           ==  pf_config[i].m_ext_tag_en;
					       m_10_bit_tag_req_en    ==  pf_config[i].m_vf_10_bit_tag_req_en; //PF's sriov cap value applies to all VFs
`endif // BRIDGE
                 //Dev cap3
					       m_14_bit_tag_req_supp == pf_config[i].m_vf_14_bit_tag_Req_supp; //If PF's SRIOV cap says 14 bit tag supp: Apply to all VFs
                 m_rx_l0p_supp         == pf_config[i].m_rx_l0p_supp;
                 m_port_l0p_exit_lat == pf_config[i].m_port_l0p_exit_lat;
                 m_retimer_l0p_exit_lat == pf_config[i].m_retimer_l0p_exit_lat;
                 `ifdef HAS_UIO
                 m_uio_Mem_RdWr_compl_supp == pf_config[i].m_uio_Mem_RdWr_compl_supp;
                 m_uio_Mem_RdWr_req_supp == pf_config[i].m_uio_Mem_RdWr_req_supp;
                 m_uio_Mem_RdWr_req_en == pf_config[i].m_uio_Mem_RdWr_req_en;
                 m_uio_req_256B_bound_dis == pf_config[i].m_uio_req_256B_bound_dis;
                 // SVC Res cap
                 m_svcR_3_ProtocolsSupported== pf_config[i].m_svcR_3_ProtocolsSupported;
                 // SVC Res ctrl
                 m_svcR_3_sel== pf_config[i].m_svcR_3_sel;
                 m_svcR_3_vc_en== pf_config[i].m_svcR_3_vc_en;
                 `endif
   
                 // AXI Bridge limitation - 10/14 bit tag supports if all the functions supports 10/14 bit tag - common tag pool
`ifdef BRIDGE
				         m_14_bit_tag_req_en    ==  pf_config[0].m_14_bit_tag_req_en;
                 m_vf_14_bit_tag_req_en ==  pf_config[0].m_14_bit_tag_req_en;
`else
				         m_14_bit_tag_req_en    ==  pf_config[i].m_vf_14_bit_tag_req_en; //PF's sriov cap value applies to all VFs
`endif // BRIDGE
					       //ATS
					       m_ats_stu == pf_config[i].m_ats_stu;
					       m_ats_inv_queue_depth == pf_config[i].m_ats_inv_queue_depth; //zero for VF. Shares PF depth
					       m_cap_ats_en == pf_config[i].m_cap_ats_en; //TODO: VIPSR: 46514389
					       //PRI
					       m_cap_ats_page_req_en == pf_config[i].m_cap_ats_page_req_en;
                 m_prg_resp_pasid_required == pf_config[i].m_prg_resp_pasid_required;
					       prReqMax == pf_config[i].prReqMax;
					       prReqAlloc == pf_config[i].prReqAlloc;
					       //PASID
					       m_pasid_enb == pf_config[i].m_pasid_enb;
					       m_translated_req_with_pasid_supp == pf_config[i].m_translated_req_with_pasid_supp;
					       m_translated_req_with_pasid_enb  == pf_config[i].m_translated_req_with_pasid_enb;
					       m_pasid_attr == pf_config[i].m_pasid_attr;
                 m_max_pasid_width == pf_config[i].m_max_pasid_width;
					       m_max_pasid_val == pf_config[i].m_max_pasid_val;
					       //Command status reg
					       en_serr == pf_config[i].en_serr;
					       parity_err_res == pf_config[i].parity_err_res;
					       //Uncorr error mask reg
					       m_data_link_protocol_error_mask == 0;
					       m_surprise_down_error_mask == 0;
					       m_poisoned_tlp_received_mask == pf_config[i].m_poisoned_tlp_received_mask;
					       m_flow_control_protocol_error_mask == 0;
					       m_completion_timeout_mask == pf_config[i].m_completion_timeout_mask;
					       m_completer_abort_mask == pf_config[i].m_completer_abort_mask;
					       m_unexpected_completion_mask == pf_config[i].m_unexpected_completion_mask;
					       m_receiver_overflow_mask == 0;
					       m_malformed_tlp_mask == 0;
					       m_ecrc_error_mask == 0;
					       m_unsupported_request_error_mask == pf_config[i].m_unsupported_request_error_mask;
					       m_acs_violation_mask == pf_config[i].m_acs_violation_mask;
					       //Uncorr error severity reg
					       m_data_link_protocol_error_severity == 0;
					       m_surprise_down_error_severity == 0;
					       m_poisoned_tlp_received_severity == pf_config[i].m_poisoned_tlp_received_severity;
					       m_flow_control_protocol_error_severity == 0;
					       m_completion_timeout_severity == pf_config[i].m_completion_timeout_severity;
					       m_completer_abort_severity == pf_config[i].m_completer_abort_severity;
					       m_unexpected_completion_severity == pf_config[i].m_unexpected_completion_severity;
					       m_receiver_overflow_severity == 0;
					       m_malformed_tlp_severity == 0;
					       m_ecrc_error_severity == 0;
					       m_unsupported_request_error_severity == pf_config[i].m_unsupported_request_error_severity;
					       m_acs_violation_severity == pf_config[i].m_acs_violation_severity;
                                               //Correctable error mask
                                               m_receiver_error_mask ==          pf_config[i].m_receiver_error_mask;
                                               m_bad_tlp_mask ==                 pf_config[i].m_bad_tlp_mask;
                                               m_bad_dllp_mask ==                pf_config[i].m_bad_dllp_mask;
                                               m_replay_num_rollover_mask ==     pf_config[i].m_replay_num_rollover_mask;
                                               m_replay_timer_timeout_mask ==    pf_config[i].m_replay_timer_timeout_mask;
                                               m_header_log_overflow_mask ==     pf_config[i].m_header_log_overflow_mask;
                                               m_advisory_non_fatal_error_mask == pf_config[i].m_advisory_non_fatal_error_mask;
					       //AER cap & ctrl
					       m_ecrc_generation_capable == pf_config[i].m_ecrc_generation_capable;
					       m_ecrc_gen_en == pf_config[i].m_ecrc_gen_en;
					       m_ecrc_chk_en == pf_config[i].m_ecrc_chk_en;
                 m_rcb == pf_config[i].m_rcb;
	                                      }) begin
            `uvm_fatal(get_name(), "Randomization Failed!!!")
        end
      end else begin
        if (!vf_config[i][j].randomize() with {m_port_type == local::m_port_type;
					       m_req_id.bus_num == local::m_req_id.bus_num;
					       {m_req_id.device_num,m_req_id.function_num} == ({pf_config[i].m_req_id.device_num,pf_config[i].m_req_id.function_num} + pf_config[i].m_first_vf_Offset + (pf_config[i].m_vf_stride * j));
					       //Dev Cap reg
					       phantom_fn_supp == 0;
					       //Dev control reg
                                               m_corr_err_rpt_en  ==    pf_config[i].m_corr_err_rpt_en;
                                               m_non_fatal_err_rpt_en ==pf_config[i].m_non_fatal_err_rpt_en;
                                               m_fatal_err_rpt_en ==    pf_config[i].m_fatal_err_rpt_en;
                                               m_unsupp_req_rpt_en ==   pf_config[i].m_unsupp_req_rpt_en;
                                               m_relax_ordering_en ==   pf_config[i].m_relax_ordering_en;
                                               m_same_payload_size ==    pf_config[i].m_same_payload_size;
                                               m_max_payload_size ==    pf_config[i].m_max_payload_size;
                                               rx_mps_fixed ==    pf_config[i].rx_mps_fixed;
                                               mixed_mps_supported ==    pf_config[i].mixed_mps_supported;
                                               m_phantom_func_en ==     pf_config[i].m_phantom_func_en;
                                               m_aux_pwr_pm_en ==       pf_config[i].m_aux_pwr_pm_en;
                                               m_no_snoop_en ==         pf_config[i].m_no_snoop_en;
                                               m_max_rd_req_size ==     pf_config[i].m_max_rd_req_size;
                                               m_ats_ro_bit_support ==  pf_config[i].m_ats_ro_bit_support;
					       //Link cap register
					       m_aspm_supp ==        pf_config[i].m_aspm_supp; //TODO is this needed?
					       m_l0s_exit_lat == pf_config[i].m_l0s_exit_lat; //TODO is this needed?
					       m_l1_exit_lat == pf_config[i].m_l1_exit_lat; //TODO is this needed?
					       //Link control register
					       m_aspm_control ==        pf_config[i].m_aspm_control;
					       m_extended_sync ==        pf_config[i].m_extended_sync;
					       //Dev cap 2 reg
					       m_compl_timeout_ranges_supp == pf_config[i].m_compl_timeout_ranges_supp;
					       m_compl_timeout_disable_supp == pf_config[i].m_compl_timeout_disable_supp;
					       m_32_atomic_op_compl_supp == pf_config[i].m_32_atomic_op_compl_supp;
					       m_64_atomic_op_compl_supp == pf_config[i].m_64_atomic_op_compl_supp;
					       m_128_cas_compl_supp == pf_config[i].m_128_cas_compl_supp;
					       m_10bit_tag_reqr_supp == pf_config[i].m_vf_10_bit_tag_Req_supp; //If PF's SRIOV cap says 10 bit tag supp: Apply to all VFs
					       m_10_bit_tag_completer_cap == pf_config[i].m_10_bit_tag_completer_cap;
					       m_emrgcy_pwr_reduc_supp == pf_config[i].m_emrgcy_pwr_reduc_supp;
					       m_emrgcy_pwr_reduc_init_reqd == pf_config[i].m_emrgcy_pwr_reduc_init_reqd;
					       m_dmwr_lengths_supp == pf_config[i].m_dmwr_lengths_supp;
                 m_e2e_tlp_prefix_support == pf_config[0].m_e2e_tlp_prefix_support;
                 m_max_e2e_support == pf_config[0].m_max_e2e_support;
                 m_tph_cpl_support== pf_config[0].m_tph_cpl_support;
                                               //Dev control 2
					       m_compl_timeout_value == pf_config[i].m_compl_timeout_value;
					       m_compl_timeout_disable == pf_config[i].m_compl_timeout_disable;
					       m_atomic_op_req_en == pf_config[i].m_atomic_op_req_en;
					       m_ido_req_en == pf_config[i].m_ido_req_en;
					       m_ido_cpl_en == pf_config[i].m_ido_cpl_en;
                 // AXI Bridge limitation - 10/14 bit tag supports if all the functions supports 10/14 bit tag - common tag pool
`ifdef BRIDGE
                 m_ext_tag_en           ==  pf_config[0].m_ext_tag_en;
                 m_10_bit_tag_req_en    ==  pf_config[0].m_10_bit_tag_req_en;
		             m_vf_10_bit_tag_req_en ==  pf_config[0].m_10_bit_tag_req_en;
`else
               m_ext_tag_en           ==  pf_config[i].m_ext_tag_en;
				       m_10_bit_tag_req_en    ==  pf_config[i].m_vf_10_bit_tag_req_en; //PF's sriov cap value applies to all VFs
`endif // BRIDGE
                 //Dev cap3
					       m_14_bit_tag_req_supp == pf_config[i].m_vf_14_bit_tag_Req_supp; //If PF's SRIOV cap says 14 bit tag supp: Apply to all VFs
                 m_rx_l0p_supp         == pf_config[i].m_rx_l0p_supp;
                 m_port_l0p_exit_lat == pf_config[i].m_port_l0p_exit_lat;
                 m_retimer_l0p_exit_lat == pf_config[i].m_retimer_l0p_exit_lat;
                 `ifdef HAS_UIO
                 m_uio_Mem_RdWr_compl_supp == pf_config[i].m_uio_Mem_RdWr_compl_supp;
                 m_uio_Mem_RdWr_req_supp == pf_config[i].m_uio_Mem_RdWr_req_supp;
                 m_uio_Mem_RdWr_req_en == pf_config[i].m_uio_Mem_RdWr_req_en;
                 m_uio_req_256B_bound_dis == pf_config[i].m_uio_req_256B_bound_dis;
                 // SVC Res cap
                 m_svcR_3_ProtocolsSupported== pf_config[i].m_svcR_3_ProtocolsSupported;
                 // SVC Res ctrl
                 m_svcR_3_sel== pf_config[i].m_svcR_3_sel;
                 m_svcR_3_vc_en== pf_config[i].m_svcR_3_vc_en;
                 `endif 
                 // AXI Bridge limitation - 10/14 bit tag supports if all the functions supports 10/14 bit tag - common tag pool
`ifdef BRIDGE
				         m_14_bit_tag_req_en    ==  pf_config[0].m_14_bit_tag_req_en;
                 m_vf_14_bit_tag_req_en ==  pf_config[0].m_14_bit_tag_req_en;
`else
				         m_14_bit_tag_req_en    ==  pf_config[i].m_vf_14_bit_tag_req_en; //PF's sriov cap value applies to all VFs
`endif // BRIDGE
					       //ATS
					       m_ats_stu == pf_config[i].m_ats_stu;
					       m_ats_inv_queue_depth == pf_config[i].m_ats_inv_queue_depth; //zero for VF. Shares PF depth
					       m_cap_ats_en == pf_config[i].m_cap_ats_en; //TODO: VIPSR 46514389
					       //PRI
					       m_cap_ats_page_req_en == pf_config[i].m_cap_ats_page_req_en;
                 m_prg_resp_pasid_required == pf_config[i].m_prg_resp_pasid_required;
					       prReqMax == pf_config[i].prReqMax;
					       prReqAlloc == pf_config[i].prReqAlloc;
					       //TPH cap reg of all VFs should be same
					       m_no_st_mode_supp == vf_config[i][0].m_no_st_mode_supp;
					       m_interrupt_mode_vec_supp == vf_config[i][0].m_interrupt_mode_vec_supp;
					       m_device_spcific_mode_sup == vf_config[i][0].m_device_spcific_mode_sup;
					       m_ext_tph_req_supp == vf_config[i][0].m_ext_tph_req_supp;
					       m_st_table_loc == vf_config[i][0].m_st_table_loc;
					       m_st_table_size == vf_config[i][0].m_st_table_size;
					       //PASID
					       m_pasid_enb == pf_config[i].m_pasid_enb;
					       m_translated_req_with_pasid_supp == pf_config[i].m_translated_req_with_pasid_supp;
					       m_translated_req_with_pasid_enb  == pf_config[i].m_translated_req_with_pasid_enb;
					       m_pasid_attr == pf_config[i].m_pasid_attr;
					       m_max_pasid_val == pf_config[i].m_max_pasid_val;
					       //Command status reg
					       en_serr == pf_config[i].en_serr;
					       parity_err_res == pf_config[i].parity_err_res;
					       //Uncorr error mask reg
					       m_data_link_protocol_error_mask == 0;
					       m_surprise_down_error_mask == 0;
					       m_poisoned_tlp_received_mask == pf_config[i].m_poisoned_tlp_received_mask;
					       m_flow_control_protocol_error_mask == 0;
					       m_completion_timeout_mask == pf_config[i].m_completion_timeout_mask;
					       m_completer_abort_mask == pf_config[i].m_completer_abort_mask;
					       m_unexpected_completion_mask == pf_config[i].m_unexpected_completion_mask;
					       m_receiver_overflow_mask == 0;
					       m_malformed_tlp_mask == 0;
					       m_ecrc_error_mask == 0;
					       m_unsupported_request_error_mask == pf_config[i].m_unsupported_request_error_mask;
					       m_acs_violation_mask == pf_config[i].m_acs_violation_mask;
					       //Uncorr error severity reg
					       m_data_link_protocol_error_severity == 0;
					       m_surprise_down_error_severity == 0;
					       m_poisoned_tlp_received_severity == pf_config[i].m_poisoned_tlp_received_severity;
					       m_flow_control_protocol_error_severity == 0;
					       m_completion_timeout_severity == pf_config[i].m_completion_timeout_severity;
					       m_completer_abort_severity == pf_config[i].m_completer_abort_severity;
					       m_unexpected_completion_severity == pf_config[i].m_unexpected_completion_severity;
					       m_receiver_overflow_severity == 0;
					       m_malformed_tlp_severity == 0;
					       m_ecrc_error_severity == 0;
					       m_unsupported_request_error_severity == pf_config[i].m_unsupported_request_error_severity;
					       m_acs_violation_severity == pf_config[i].m_acs_violation_severity;
                                               //Correctable error mask
                                               m_receiver_error_mask ==          pf_config[i].m_receiver_error_mask;
                                               m_bad_tlp_mask ==                 pf_config[i].m_bad_tlp_mask;
                                               m_bad_dllp_mask ==                pf_config[i].m_bad_dllp_mask;
                                               m_replay_num_rollover_mask ==     pf_config[i].m_replay_num_rollover_mask;
                                               m_replay_timer_timeout_mask ==    pf_config[i].m_replay_timer_timeout_mask;
                                               m_header_log_overflow_mask ==     pf_config[i].m_header_log_overflow_mask;
                                               m_advisory_non_fatal_error_mask == pf_config[i].m_advisory_non_fatal_error_mask;
					       //AER cap & ctrl
					       m_ecrc_generation_capable == pf_config[i].m_ecrc_generation_capable;
					       m_ecrc_gen_en == pf_config[i].m_ecrc_gen_en;
					       m_ecrc_chk_en == pf_config[i].m_ecrc_chk_en;
                 m_rcb == pf_config[i].m_rcb;
			                      }) begin
            `uvm_fatal(get_name(), "Randomization Failed!!!")
        end
      end
      `uvm_info("DEV_CFG",$psprintf("Randomized vf_config[%0d][%0d]= %0s",i,j,vf_config[i][j].sprint()),UVM_FULL)

      foreach(m_unmapped_tc_list[k])
        vf_config[i][j].m_unmapped_tc_list.push_back(m_unmapped_tc_list[k]);

      end

    end
  endfunction

  //------------------------------------------------------------------------
  // Function: get_req_id_for_pf_vf
  // Returns requester id for the correspodning PF/VF
  //------------------------------------------------------------------------
  virtual function cdn_hpa_pcie_tlp_requester_id_s get_req_id_for_pf_vf(int pf=0, int vf=-1, bit is_vf_valid=0);
    if((vf == -1 || is_vf_valid ==0)  && pf < l_num_enabled_pfs) begin
      `uvm_info(get_full_name, $sformatf("For PF = %0d -> Requester ID is %0h ",  pf, pf_config[pf].m_req_id), UVM_DEBUG)
      return(pf_config[pf].m_req_id);
    end
    if(vf != -1 && is_vf_valid == 1  && (vf < pf_config[pf].m_NumVFs)) begin
      `uvm_info(get_full_name, $sformatf("For PF = %0d VF = %0d -> Requester ID is %0h ", pf, vf, vf_config[pf][vf].m_req_id), UVM_DEBUG)
      return(vf_config[pf][vf].m_req_id);
    end

    `uvm_error(get_full_name(), $sformatf(" PF = %0d or VF= %0d does not exist as per strap", pf, vf))

  endfunction

  //------------------------------------------------------------------------
  // Function: ucie_generate_exp_msi_message
  // generated the UCIe MSI interrupt posted exited request
  //------------------------------------------------------------------------
  function void ucie_generate_exp_msi_message(string l_msg_id, bit msi_64BAC_cap=1, bit msi_en=0, reg [63:0] msi_addr, reg [31:0] msi_data);
    exp_msi_fields_object       exp_msi_fields_h;

    if(!i_cfg.strap_is_rp)
      return;

    exp_msi_fields_h                    = new();
    if(msi_en)
      exp_msi_fields_h.m_tlp_type  = msi_64BAC_cap ? 'd6 /*CDN_HPA_PCIE_TLP_TYPE_MWr_64*/ : 'd3 /*CDN_HPA_PCIE_TLP_TYPE_MWr_32*/;
    else 
    exp_msi_fields_h.m_tlp_type  = 0;
    exp_msi_fields_h.requester_id       = {m_rp_req_id.bus_num, m_rp_req_id.device_num, 3'b000};
    exp_msi_fields_h.m_tlp_first_dw_be  = 4'hF;
    if((i_cfg.scenario != null)) begin
      if(i_cfg.scenario.is_flit_mode()) 
        exp_msi_fields_h.m_tlp_last_dw_be   = 4'hF; // UCIECTL-1041
      else
        exp_msi_fields_h.m_tlp_last_dw_be   = 4'h0; // UCIECTL-1041; as OHC-A1 is not there in FF2
    end

    exp_msi_fields_h.m_tlp_length       =  1; // no extended msg data is enabled
    exp_msi_fields_h.m_tlp_payload = new[4*exp_msi_fields_h.m_tlp_length];
    foreach(exp_msi_fields_h.m_tlp_payload[i]) begin
        exp_msi_fields_h.m_tlp_payload[i]   = msi_data[i*8 +: 8]; // TODO_UCIe: change wrt ucie config
    end
      exp_msi_fields_h.m_tlp_addr         = msi_addr;
    exp_msi_fields_q.push_back(exp_msi_fields_h);
    `uvm_info(l_msg_id,$psprintf("exp msi item is %0s", exp_msi_fields_h.sprint()),UVM_LOW);
  endfunction : ucie_generate_exp_msi_message

  //------------------------------------------------------------------------
  // Function: generate_exp_msi_message
  // Returns PF/VF structure for the matching requester id
  //------------------------------------------------------------------------
  function void generate_exp_msi_message(string l_msg_id, bit [127:0] interrupt_signals_sideband=0);
    exp_msi_fields_object       exp_msi_fields_h;
    bit [4:0] l_interrupt_vector_num;

    `uvm_info(l_msg_id,$psprintf("dev_top_cfg.exp_msi_fields_q.size()=%0d", exp_msi_fields_q.size()),UVM_DEBUG)  
    `uvm_info(l_msg_id,$psprintf("m_sbsa_msi_msg_gen_for_first_err=%0b", m_sbsa_msi_msg_gen_for_first_err),UVM_DEBUG)  
    //Check for Global MSI generation Enable {bit-1 from i_sbsa_ctrl_ib_msi_control}
    //Select target address base on setting  {bit-0 from i_sbsa_ctrl_ib_msi_control}
    //Check MSI gen enable for 3 diff type of errors {bit-2,3,4 from i_sbsa_ctrl_ib_msi_control}
    //As per JIRA PCIE-15658, i_msi_ctrl_reg[0] needs to be enabled for MSI gen.
    if((!m_sbsa_msi_global_en && this.sbsa_msi_control_init_done) || !i_cfg.strap_is_rp || !pf_config[0].m_msi_en || !this.msi_init_done || scenario.m_pxc_shadow_reg_mb_test) //PXC
      return;

    `uvm_info(l_msg_id,$psprintf("interrupt_signals_sideband=%0h", interrupt_signals_sideband),UVM_DEBUG)  
    //if(this.exp_msi_fields_q.size()==1)
    `uvm_info(l_msg_id,$psprintf("m_local_interrupt_in_process=%0h", m_local_interrupt_in_process),UVM_DEBUG)  
    if((m_local_interrupt_in_process) && (l_msg_id == "LOCAL_INTRPT"))
      return;

    //Check if MSI msg generation for recieved errors from other device is enabled.
    if(!m_sbsa_msi_msg_gen_en_for_efod && this.sbsa_msi_control_init_done && (l_msg_id == "ERROR_MSG_RCVD")) 
      return;

    //Check if MSI msg generation for local AER errors is enabled.
    //i_sbsa_ctrl_ib_msi_control[2] bit is for local aer error, should not mask cxs request 
    if(!m_sbsa_msi_msg_gen_en_for_lae && this.sbsa_msi_control_init_done && (l_msg_id == "AER_RCVD")) 
      return;

    //Check if MSI msg generation for local AER errors is disabled. Generate the MSI msg from interrupt logged as per JIRA PCIE-17043.
    if(m_sbsa_msi_msg_gen_en_for_lae && this.sbsa_msi_control_init_done && (l_msg_id == "AER_INTRPT")) 
      return;

    //When m_sbsa_msi_msg_gen_for_first_err set, only for the first error MSI is generated. Only after clearing root_error_status register new MSIs are generated.
    if((exp_msi_fields_q.size()!=0) && (m_sbsa_msi_msg_gen_for_first_err && this.sbsa_msi_control_init_done) && (l_msg_id == "AER_RCVD") && root_error_status_is_set)
      return;

    `uvm_info(l_msg_id,$psprintf("m_local_interrupt_in_process=%0h", m_local_interrupt_in_process),UVM_DEBUG)  
    if(l_msg_id inside {"LOCAL_INTRPT", "AER_INTRPT"}) m_local_interrupt_in_process = 1;

    exp_msi_fields_h                    = new();
    
    //System software may program the Message Upper Address register to zero so that the Function uses a 32-bit address for the MSI transaction
    if(!m_sbsa_msi_addr_sel) begin
      exp_msi_fields_h.m_tlp_type    =  (m_sbsa_ctrl_ib_msi_hi_addr==0) ? 'd3 /*CDN_HPA_PCIE_TLP_TYPE_MWr_32*/ : 'd6 /*CDN_HPA_PCIE_TLP_TYPE_MWr_64*/;
    end
    else begin
      if(pf_config[0].m_msi_en)
        exp_msi_fields_h.m_tlp_type  = pf_config[0].m_msi_64bit_addr_cap ? (((pf_config[0].m_msi_msg_upper_addr != 0) && (this.msi_addr_init_done)) ? 'd6 /*CDN_HPA_PCIE_TLP_TYPE_MWr_64*/ : 'd3 /*CDN_HPA_PCIE_TLP_TYPE_MWr_32*/) : 'd3 /*CDN_HPA_PCIE_TLP_TYPE_MWr_32*/;
      else 
        exp_msi_fields_h.m_tlp_type  = 0;
    end

    exp_msi_fields_h.requester_id       = {m_rp_req_id.bus_num, m_rp_req_id.device_num, 3'b000};
    exp_msi_fields_h.m_tlp_first_dw_be  = 4'hF;
    if((i_cfg.scenario != null)) begin
      if(i_cfg.scenario.is_flit_mode()) 
        exp_msi_fields_h.m_tlp_last_dw_be   = 4'hF; // UCIECTL-1041
      else
        exp_msi_fields_h.m_tlp_last_dw_be   = 4'h0; // UCIECTL-1041; as OHC-A1 is not there in TLP
    end

    //Spec line: 
    //For MSI when the Extended Message Data Enable bit is Clear, the DWORD that is written is made up of the value in the
    //MSI Message Data register in the lower two bytes and zeros in the upper two bytes. For MSI when the Extended Message
    //Data Enable bit is Set, the DWORD that is written is made up of the value in the MSI Message Data register in the lower
    //two bytes and the value in the MSI Extended Message Data register in the upper two bytes.

    //if(pf_config[0].m_msi_ext_msg_data_cap && pf_config[0].m_msi_ext_msg_data_en) begin
    //  exp_msi_fields_h.m_tlp_length         = 2;
    //end
    //else begin
      exp_msi_fields_h.m_tlp_length         = 1;
    //end
    exp_msi_fields_h.m_tlp_payload = new[4*exp_msi_fields_h.m_tlp_length];
    foreach(exp_msi_fields_h.m_tlp_payload[i]) begin
      if(this.msi_data_init_done) begin
        if(i<2) begin
          exp_msi_fields_h.m_tlp_payload[i]   = pf_config[0].m_msi_data[i*8 +: 8]; // TODO_UCIe: change wrt ucie config
        end
        else if (pf_config[0].m_msi_ext_msg_data_cap && pf_config[0].m_msi_ext_msg_data_en) begin
          exp_msi_fields_h.m_tlp_payload[i]   = pf_config[0].m_msi_ext_data[i*8 +: 8];// TODO_UCIe: change wrt ucie config
        end
        else begin
          exp_msi_fields_h.m_tlp_payload[i]   = 0;
        end
      end
      else begin
        exp_msi_fields_h.m_tlp_payload[i]   = 0;
      end
    end

    //CXL-3121: vector number in lower[4:0] of memory write for MSI.
    //Update below for:
    // PCI-PM link activation, FLit error counter interrupts - IMN from PCIe Cap register
    // L1PM Substates status registers. - IMN from PCIe Cap register
    // Hot-Plug - slot cap register  - IMN from PCIe Cap register
    // MMB command Status - IMN from MMB cap reg
    // MMPT - IMN from MMPT cap
    // FRS - IMN FRS.
    // DOE Interrupt status - IMN DOE.
    // CXS Interface - INT message number from CXS register.
    // MSI injection -  Int message number from MSI control injection register.
    
    if(scenario.is_cxl_dlco_mode() && l_msg_id == "CXL_DLCO_ERROR_RCVD")
      l_interrupt_vector_num = interrupt_signals_sideband[4:0]; //passed intr_num in this variable 
    else if (l_msg_id inside {"ERROR_MSG_RCVD", "AER_RCVD"})
      l_interrupt_vector_num = pf_config[0].m_advanced_error_interrupt_message_number; //PCIe Spec defined- Error msg rcvd from link or RP itself detected.
    else if (l_msg_id inside {"AER_INTRPT", "LOCAL_INTRPT"})
      l_interrupt_vector_num = this.m_sbsa_interrupt_message_number; //Implementation Specific- MSI for Local error status register 
    else if (l_msg_id inside {"DPC_TRIGGERED"})
      l_interrupt_vector_num = pf_config[0].dpc_intr_message_num;  
    else if (l_msg_id inside {"DRS_MSG_RCVD","PCIE_CAP_REG_INT_MSG_NUM"})
      l_interrupt_vector_num = pf_config[0].interrupt_message_number; // DRS Message Received Bit in link status2 transition from 0 to 1- IMN from PCIe Cap register
    else 
      l_interrupt_vector_num = 0;

    if (lti_en && lti_xlate_msi)
      exp_msi_fields_h.m_tlp_td = pf_config[0].m_ecrc_gen_en;
    else
      exp_msi_fields_h.m_tlp_td = (pf_config[0].m_ecrc_gen_en && this.ecrc_init_done);
    exp_msi_fields_h.m_tlp_payload[0][4:0] = l_interrupt_vector_num;
    if(!m_sbsa_msi_addr_sel)
      exp_msi_fields_h.m_tlp_addr         = {m_sbsa_ctrl_ib_msi_hi_addr,m_sbsa_ctrl_ib_msi_low_addr[31:2],2'b0};
    else if (lti_en && lti_xlate_msi) begin
      if (!translated_addr.exists({pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr} >> 12)) begin
        translated_addr[({pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr} >> 12)] = lti_msi_physical_addr;
        `uvm_info("LTI XLATION", $sformatf(" Setting SMMU to translate addr %0h to %0h", {pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr},lti_msi_physical_addr), UVM_DEBUG)
      end
      exp_msi_fields_h.m_tlp_addr         = {translated_addr[({pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr} >> 12)][63:12],pf_config[0].m_msi_msg_addr[11:0]};
      `uvm_info("LTI XLATION", $sformatf(" Translated MSI message address %0h to %0h", {pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr}, exp_msi_fields_h.m_tlp_addr), UVM_DEBUG)
      exp_msi_fields_h.m_tlp_type    = pf_config[0].m_msi_64bit_addr_cap ? 'd6 /*CDN_HPA_PCIE_TLP_TYPE_MWr_64*/ : 
                                       (exp_msi_fields_h.m_tlp_addr & 64'hffff_ffff_0000_0000) ? 'd6 : 'd3 /*CDN_HPA_PCIE_TLP_TYPE_MWr_32*/;
    end
    else 
      exp_msi_fields_h.m_tlp_addr         = {pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr}; 

    if(pf_config[0].m_ecrc_gen_en && this.ecrc_init_done) exp_msi_fields_h.m_tlp_td = 1;
    

    exp_msi_fields_q.push_back(exp_msi_fields_h);
    `uvm_info(l_msg_id,$psprintf("exp msi item is %0s", exp_msi_fields_h.sprint()),UVM_LOW);
  endfunction : generate_exp_msi_message


  function void generate_exp_error_correctable_msg();
    exp_msi_fields_object       exp_msg_fields_h;
    `uvm_info("debug_interrupt",$psprintf(" generate_exp_error_correctable_msg "),UVM_DEBUG)  

    exp_msg_fields_h                = new();
    exp_msg_fields_h.m_tlp_type     = 'd13 ; //CDN_HPA_PCIE_TLP_TYPE_Msg
    exp_msg_fields_h.m_tlp_tc       = 0    ;
    exp_msg_fields_h.m_tlp_td       = (pf_config[0].m_ecrc_gen_en && this.ecrc_init_done) ;
    exp_msg_fields_h.m_tlp_ep       = 0    ;
    exp_msg_fields_h.m_tlp_at_type  = 0    ;
    exp_msg_fields_h.m_tlp_length   = 0    ;
    exp_msg_fields_h.requester_id   = {m_rp_req_id.bus_num, m_rp_req_id.device_num, 3'b000};
    exp_msg_fields_h.m_tlp_msg_code = 8'h30;
    if(pf_config[0].m_ecrc_gen_en && this.ecrc_init_done && !this.flit_mode_negotiated) exp_msg_fields_h.m_tlp_td = 1;

    exp_msi_fields_q.push_back(exp_msg_fields_h);
  endfunction : generate_exp_error_correctable_msg

  //------------------------------------------------------------------------
  // Function: get_pf_vf_from_req_id
  // Returns PF/VF structure for the matching requester id
  //------------------------------------------------------------------------

  virtual function cdn_pcie_hpa_pf_vf_s get_pf_vf_from_req_id(cdn_hpa_pcie_tlp_requester_id_s req_id_s, bit bypass_vf_allocation_check=0);
    cdn_pcie_hpa_pf_vf_s pf_vf_s;
    int loop_cnt;

    if((!i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))
      loop_cnt = l_num_enabled_pfs; //EP DUT can have strap specified Pfs
    else if (m_port_type == CDN_HPA_PCIE_DSP)
      loop_cnt = 1; //RP has 1 Function
    else if ((i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))
      loop_cnt = 2; //2 EP BFMs
    else
      `uvm_error(get_name(),$psprintf("Num pfs unknown"))

    pf_vf_s.pf = 255;
    pf_vf_s.is_pf_valid = 0;

    for (int i = 0; i < loop_cnt; i++) begin
      if(pf_config[i].m_req_id == req_id_s) begin
        pf_vf_s.pf = i;
        pf_vf_s.vf = -1;
        pf_vf_s.is_vf_valid = 0 && pf_config[i].m_vf_en;
        pf_vf_s.is_pf_valid = 1;
        `uvm_info(get_name(),$psprintf("get_pf_vf_from_req_id: For req_id=%0h, Decoded PF='d%0d  VF='d%0d  is_vf_valid=%0d, is_pf_valid=%0d",
        {req_id_s.bus_num,req_id_s.device_num,req_id_s.function_num},pf_vf_s.pf,pf_vf_s.vf,pf_vf_s.is_vf_valid, pf_vf_s.is_pf_valid),UVM_DEBUG)
        return (pf_vf_s);
      end
    end

    for (int pf_i = 0; pf_i < loop_cnt; pf_i++ ) begin
      for (int vf_i = 0; vf_i < pf_config[pf_i].m_NumVFs; vf_i++) begin
        if((vf_config[pf_i][vf_i].m_req_id == req_id_s) && ((pf_i < parameters_cfg_pkg::MAX_PFS_WITH_VF)|| bypass_vf_allocation_check)) begin
          pf_vf_s.pf = pf_i;
          pf_vf_s.vf = vf_i;
          pf_vf_s.is_vf_valid = 1 && pf_config[pf_i].m_vf_en;
          pf_vf_s.is_pf_valid = 1;
          `uvm_info(get_name(),$psprintf("get_pf_vf_from_req_id: For req_id=%0h, Decoded PF='d%0d  VF='d%0d  is_vf_valid=%0d, is_pf_valid=%0d",
          {req_id_s.bus_num,req_id_s.device_num,req_id_s.function_num},pf_vf_s.pf,pf_vf_s.vf,pf_vf_s.is_vf_valid, pf_vf_s.is_pf_valid),UVM_DEBUG)
          return(pf_vf_s);
        end
      end
    end

    //`uvm_warning("get_type_name", $psprintf(" Requester id = %0d does not belong to any PF/VF",req_id_s))
    `uvm_warning(get_full_name(),$psprintf("Requester id = %0h does not belong to any PF/VF",req_id_s))
    return pf_vf_s;

  endfunction

    //---------------------------------------------------------------------------
  // Method: get_ifun_from_rid
  // This is used to get ifun from the RId.
  //---------------------------------------------------------------------------
  virtual function bit [15:0] get_ifun_from_rid(cdn_hpa_pcie_tlp_requester_id_s req_id_s); //(bit[7:0] pf, bit[15:0] vf, bit is_pf_valid, bit is_vf_valid);
    bit [15:0] ifun_num;
    if(i_cfg.strap_ari_enable && !i_cfg.strap_is_rp) begin
      if({req_id_s.device_num, req_id_s.function_num} >= l_num_enabled_pfs)
        ifun_num = {req_id_s.device_num, req_id_s.function_num} + (parameters_cfg_pkg::KMAX_NUM_PFS - l_num_enabled_pfs);
      else
        ifun_num = {req_id_s.device_num, req_id_s.function_num};
    end
    else begin
      if(req_id_s.function_num >= l_num_enabled_pfs)
        ifun_num = req_id_s.function_num + (parameters_cfg_pkg::KMAX_NUM_PFS - l_num_enabled_pfs);
      else
        ifun_num = req_id_s.function_num;
    end
    return ifun_num;
  endfunction : get_ifun_from_rid


  //------------------------------------------------------------------------
  // Function: get_pf_vf_dev_cfg_from_req_id
  // Returns PF/VF structure for the matching requester id
  //------------------------------------------------------------------------

  virtual function cdn_hpa_pcie_dev_config get_pf_vf_dev_cfg_from_req_id(cdn_hpa_pcie_tlp_requester_id_s req_id_s);
    int loop_cnt;

    if((!i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))
      loop_cnt = l_num_enabled_pfs; //EP DUT can have strap specified Pfs
    else if (m_port_type == CDN_HPA_PCIE_DSP)
      loop_cnt = 1; //RP has 1 Function
    else if ((i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP))
      loop_cnt = 2; //2 EP BFMs
    else
      `uvm_error(get_name(),$psprintf("Num pfs unknown"))

    for (int i = 0; i < loop_cnt; i++) begin
      if(pf_config[i].m_req_id == req_id_s) begin
        `uvm_info(get_name(),$psprintf("get_pf_vf_dev_cfg_from_req_id: For req_id=%0h, Decoded PF='d%0d  VF='d%0d  is_vf_valid=%0d, is_pf_valid=%0d",
        {req_id_s.bus_num,req_id_s.device_num,req_id_s.function_num},i,-1,0, 1),UVM_DEBUG)
        return (pf_config[i]);
      end
    end

    for (int pf_i = 0; pf_i < loop_cnt; pf_i++ ) begin
      for (int vf_i = 0; vf_i < pf_config[pf_i].m_NumVFs; vf_i++) begin
        if(vf_config[pf_i][vf_i].m_req_id == req_id_s) begin
          `uvm_info(get_name(),$psprintf("get_pf_vf_dev_cfg_from_req_id: For req_id=%0h, Decoded PF='d%0d  VF='d%0d  is_vf_valid=%0d, is_pf_valid=%0d",
          {req_id_s.bus_num,req_id_s.device_num,req_id_s.function_num},pf_i,vf_i,1,0),UVM_DEBUG)
          return(vf_config[pf_i][vf_i]);
        end
      end
    end

    //`uvm_warning("get_type_name", $psprintf(" Requester id = %0d does not belong to any PF/VF",req_id_s))
    `uvm_warning(get_full_name(),$psprintf("Requester id = %0d does not belong to any PF/VF",req_id_s))
    return null;

  endfunction
  //---------------------------------------------------------------------------
  // Method: get_device_config
  // This function get dev config for specyfic pf_function
  //---------------------------------------------------------------------------
  function cdn_hpa_pcie_dev_config get_device_config(int pf_number);
    return pf_config[pf_number];
  endfunction : get_device_config
  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  // Should new the TLM Analysis ports and the coverage groups.
  //------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hpa_dev_top_config", uvm_component parent = null);
    super.new(name, parent);

    if(!$value$plusargs("IDE_SPECIFIC_ERR=%s",ide_spec_err_scen)) ide_spec_err_scen="NO_IDE_SPEC_ERR";
         `uvm_info(get_name(),$psprintf("IDE_SPECIFIC_ERR=%s",ide_spec_err_scen),UVM_LOW)

    if(!$value$plusargs("FM_DLL_SPECIFIC_ERR=%s",fm_dll_spec_err_scen)) fm_dll_spec_err_scen="NO_FM_DLL_SPEC_ERR";
      `uvm_info(get_name(),$psprintf("FM_DLL_SPECIFIC_ERR=%s",fm_dll_spec_err_scen),UVM_LOW)
       
    if(!$value$plusargs("MORE_PM_SCEN=%0d",more_pm_scen)) more_pm_scen=0;

    if(!$value$plusargs("PCIE_6_1_SUPPORT=%0d",pcie_6_1_support)) pcie_6_1_support=0;

    if(!$value$plusargs("DEFAULT_CRED_INIT=%0d",default_cred_init)) default_cred_init=0;

    if(!$value$plusargs("ENABLE_ZERO_CREDIT_RANDOMIZATION=%0d",enable_zero_credit_randomization)) enable_zero_credit_randomization=1;

    if(!$value$plusargs("ENABLE_SEGMENTATION=%0d",enable_segmentation)) enable_segmentation=0;

    if(!$value$plusargs("PM_SPECIFIC_SCEN=%s",pm_spec_scen)) pm_spec_scen="NO_PM_SPECIFIC_SCEN";
         `uvm_info(get_name(),$psprintf("PM_SPECIFIC_SCEN=%s PCIE_6_1_SUPPORT=%0d",pm_spec_scen,pcie_6_1_support),UVM_LOW)
    
    if(!$value$plusargs("ASPM_L1_ENABLE=%0d",aspm_l1_enable))   aspm_l1_enable=0;
    if(!$value$plusargs("ASPM_L0S_ENABLE=%0d",aspm_l0s_enable)) aspm_l0s_enable=0;
    if(!$value$plusargs("ASPM_DISABLE=%0d",aspm_disable))       aspm_disable=0;

    //Create dynamic array with depth==11 to store 0-10 presets
    gen3_preset_coeff_map = new[11];
    gen4_preset_coeff_map = new[11];
    gen5_preset_coeff_map = new[11];
    gen6_preset_coeff_map = new[11];
    gen6_preset_coeff_map_new = new[11];
    `ifdef PCIE_GEN7
    gen7_preset_coeff_map = new[11];
    gen7_preset_coeff_map_new = new[11];
    `endif


    for(int i=0; i<11; i++)
    begin
      gen3_preset_coeff_map[i]=cdnpcie_hpa_eq_config::type_id::create($psprintf("gen3_preset_coeff_map[%0d]",i));
      gen4_preset_coeff_map[i]=cdnpcie_hpa_eq_config::type_id::create($psprintf("gen4_preset_coeff_map[%0d]",i));
      gen5_preset_coeff_map[i]=cdnpcie_hpa_eq_config::type_id::create($psprintf("gen5_preset_coeff_map[%0d]",i));
      gen6_preset_coeff_map[i]=cdnpcie_hpa_gen6_eq_config::type_id::create($psprintf("gen6_preset_coeff_map[%0d]",i));
      gen6_preset_coeff_map_new[i]=cdnpcie_hpa_gen6_eq_config::type_id::create($psprintf("gen6_preset_coeff_map_new[%0d]",i));
    `ifdef PCIE_GEN7
      gen7_preset_coeff_map[i]=cdnpcie_hpa_gen6_eq_config::type_id::create($psprintf("gen7_preset_coeff_map[%0d]",i));
      gen7_preset_coeff_map_new[i]=cdnpcie_hpa_gen6_eq_config::type_id::create($psprintf("gen7_preset_coeff_map_new[%0d]",i));
    `endif

      void'(gen3_preset_coeff_map[i].randomize with {preset==i;});
      void'(gen4_preset_coeff_map[i].randomize with {preset==i;});
      void'(gen5_preset_coeff_map[i].randomize with {preset==i;});
      void'(gen6_preset_coeff_map[i].randomize with {preset==i;});
      void'(gen6_preset_coeff_map_new[i].randomize with {preset==i;fs==gen6_preset_coeff_map[i].fs;lf==gen6_preset_coeff_map[i].lf;});
    `ifdef PCIE_GEN7
      void'(gen7_preset_coeff_map[i].randomize with {preset==i;});
      assert(gen7_preset_coeff_map_new[i].randomize with {preset==i;fs==gen7_preset_coeff_map[i].fs;lf==gen7_preset_coeff_map[i].lf;});
    `endif
    end

    // TODO: PL Team to add Switch Based Print for Debug Purspose
    //foreach(gen3_preset_coeff_map[i])
    //  gen3_preset_coeff_map[i].print();
    //
    //foreach(gen4_preset_coeff_map[i])
    //  gen4_preset_coeff_map[i].print();
    //
    //foreach(gen5_preset_coeff_map[i])
    //  gen5_preset_coeff_map[i].print();
    //
    //foreach(gen6_preset_coeff_map[i])
    //  gen6_preset_coeff_map[i].print();
    //
    //foreach(gen7_preset_coeff_map[i])
    //  gen7_preset_coeff_map[i].print();

    //Initially push all 32 itag vectors to queue
    for(int i=0; i<32; i++) itag_available_q.push_back(i);
    for(int i=0; i<512; i++) prg_index_available_q.push_back(i);

   dev_top_cfg_cg = new();
   pth_reg_program_cg = new();
   vc_cg = new();
   cif_cg = new();
   idg_cg = new();
   dl_top_config_cg = new();
   flit_mode_cg = new();
   dl_flow_control_cg = new();
   bar_coverage = new();
   cg__mrrs_rd_req_size = new();
   cg__interrupt_message_num = new();
   tdisp_reg_mon_cg = new();

   // Equalization related events
   eq_reg_rd_start = new();
   cpcs_sds_error  = new();
   gen6_sds_error  = new(); 
   `ifdef PCIE_GEN7
   gen7_sds_error  = new(); 
   `endif
   cpcs_skp_error  = new();
   eq_reg_rd_done  = new();

   set_after_lock  = new();
   /// corr_err_sts_rd = new();

   //which scenario it will take based on scenario file but default need to be set
   dut_credit_scenario["PH"]=RANDOM_CREDIT;
   dut_credit_scenario["PD"]=RANDOM_CREDIT;
   dut_credit_scenario["NPH"]=RANDOM_CREDIT;
   dut_credit_scenario["NPD"]=RANDOM_CREDIT;
   dut_credit_scenario["CPLH"]=RANDOM_CREDIT;
   dut_credit_scenario["CPLD"]=RANDOM_CREDIT;

   bfm_credit_scenario["PH"]=RANDOM_CREDIT;
   bfm_credit_scenario["PD"]=RANDOM_CREDIT;
   bfm_credit_scenario["NPH"]=RANDOM_CREDIT;
   bfm_credit_scenario["NPD"]=RANDOM_CREDIT;
   bfm_credit_scenario["CPLH"]=RANDOM_CREDIT;
   bfm_credit_scenario["CPLD"]=RANDOM_CREDIT;

   if(!$value$plusargs("DELAY_SYNC_SIGNAL_EN=%0d",del_sync_signal_en))
      del_sync_signal_en = 0;
    if(!$value$plusargs("ENABLE_RETIMER_EQ=%0d",enable_retimer_eq))
      enable_retimer_eq = 0;

   if(!$value$plusargs("COMP_LONG_RUN=%0d",en_long_run_comp)) en_long_run_comp=0;

   if(!$value$plusargs("NON_IDE_TRAFFIC_TEST=%0d",non_ide_traffic_test)) non_ide_traffic_test=0;
   if(!$value$plusargs("NON_CXL_IDE_TRAFFIC_TEST=%0d",non_cxl_ide_traffic_test)) non_cxl_ide_traffic_test=0;

    if(!$value$plusargs("LOOPBACK_TEST_EN=%0d",en_loopback))
      en_loopback = 0;
    if(!$value$plusargs("LOOPBACK_B4_LINKUP_EN=%0d",en_loopback_b4_linkup))
      en_loopback_b4_linkup = 0;
    if(!$value$plusargs("FULL_DELAY_SIM=%0d", en_full_delay_sim))
      en_full_delay_sim = 0;

    if(en_loopback || en_loopback_b4_linkup) enable_loopback = 1;

    if (!$value$plusargs("DO_NOT_RAND_LTI_META=%0d", do_not_randomize_lti_metadata))
      do_not_randomize_lti_metadata = 0;
  endfunction : new

  function void cpcs_policy_add(bit is_dev_rand_cfg);
    // push_cpcs_policies(is_dev_rand_cfg);
    cdn_pcie_cpcs_base_policy cpcs_base_pcy;

    if(is_dev_rand_cfg) begin
      //cdn_pcie_cpcs_random_policy cpcs_rand_pcy;
      //cpcs_rand_pcy = cdn_pcie_cpcs_random_policy::type_id::create($psprintf("%0s.cpcs_rand_pcy",get_full_name()), this);
      //$cast(cpcs_base_pcy,cpcs_rand_pcy);
      //m_cpcs_config.pcy_q.push_back(cpcs_base_pcy)
      `uvm_info("DEV_CFG",$psprintf("CPCS Random policy selected"),UVM_LOW)
      m_cpcs_config.push_policy_by_type(cdn_pcie_cpcs_random_policy::get_type(), "cpcs_random_pcy");
    end
    else begin
      //cdn_pcie_cpcs_default_policy cpcs_default_pcy;
      //cpcs_default_pcy = cdn_pcie_cpcs_default_policy::type_id::create("cpcs_default_pcy");
      //$cast(cpcs_base_pcy,cpcs_default_pcy);
      //m_cpcs_config.pcy_q.push_back(cpcs_base_pcy);
      //`ifdef TC_OR_SERIAL_MODE
         `uvm_info("DEV_CFG",$psprintf("CPCS Default policy selected"),UVM_LOW)
         m_cpcs_config.push_policy_by_type(cdn_pcie_cpcs_default_policy::get_type(), "cpcs_default_pcy");
       //`else
       //  `uvm_info("DEV_CFG",$psprintf("CPCS Random policy selected"),UVM_LOW)
       //  m_cpcs_config.push_policy_by_type(cdn_pcie_cpcs_random_policy::get_type(), "cpcs_random_pcy");
       //`endif

      //m_cpcs_config.push_policy_by_name(cdn_pcie_cpcs_default_policy::type_name, "cpcs_default_pcy");

    end

  endfunction
  
  function void pre_randomize();
    bit fall_back_mode;
    bit bit_shift_dis;
    bit shift_after_valid;
    push_config_policies_type();
    
    m_cpcs_config = cdnpcie_hpa_cpcs_config::type_id::create("m_cpcs_config");
    m_cpcs_config.i_cfg = i_cfg;

    ide_cfg = cdn_pcie_hpa_ide_config::type_id::create($psprintf("%0s.ide_cfg",get_full_name()),this);
    ide_cfg.i_cfg = i_cfg;
    ide_cfg.m_port_type = m_port_type;

    tdisp_cfg = cdn_pcie_hpa_tdisp_config::type_id::create("tdisp_cfg",,get_full_name());
    tdisp_cfg.i_cfg = i_cfg;
    tdisp_cfg.dut_ide_cfg = ide_cfg;

    asf_cfg = cdn_pcie_hpa_asf_config::type_id::create($psprintf("%0s.asf_cfg",get_full_name()),this);
    //asf_cfg.i_cfg = i_cfg;

    if ($value$plusargs("RAND_CFG=%0d", is_dev_rand_cfg)) begin
      `uvm_info(get_type_name(),
        $sformatf("## Got RAND_CFG =%0d from command line##", is_dev_rand_cfg),
        UVM_NONE)
    end
    else begin
      is_dev_rand_cfg = 1;
    end

    cpcs_policy_add(is_dev_rand_cfg);


   foreach (pcy_q[i]) begin
      //if((pcy_q[i].item.apply_for_all_pfs) || pcy_q[i].item.pf_func_num == this.func_num)
        if(pcy_q[i].set_item(this, func_num)) begin
	end
	else begin
          pcy_q.delete(i);
	end
    end
    if (!uvm_config_db#(cdn_pcie_scenario)::get(this, "", "scenario", scenario)) begin
      `uvm_info(get_type_name(), $sformatf("scenario is not present. full random scenario is chosen"),UVM_LOW)
    end

    if($value$plusargs("FALL_BACK_MODE=%d", fall_back_mode)) begin
      if(fall_back_mode) begin
        m_cxl_pcie_fall_back_mode.rand_mode(0);
	m_cxl_pcie_fall_back_mode = 1;
      end
      else begin
        m_cxl_pcie_fall_back_mode.rand_mode(0);
	m_cxl_pcie_fall_back_mode = 0;
      end
      `uvm_info(get_name(), $psprintf("Passed FALL_BACK_MODE from command line fall_back_mode = %0d", fall_back_mode),UVM_NONE)
    end
    if(scenario) begin
      cxl_ldid_prefix = scenario.cxl_ldid_prefix;
      vdm_for_cxl     = scenario.vdm_for_cxl;
      `uvm_info(get_name(), $psprintf("cxl_ldid_prefix = %0d, vdm_for_cxl=%d", cxl_ldid_prefix,vdm_for_cxl),UVM_DEBUG)
    end

    if((scenario != null) && scenario.is_ucie_mode) begin
      if(!$value$plusargs("UCIE_INTR_GEN=%0d",ucie_intr_gen)) ucie_intr_gen= 0;
        `uvm_info(get_type_name(),$sformatf("## UCIE_CONFIG Got UCIE_INTR_GEN=%0d from command line in dev vseq##", ucie_intr_gen),UVM_HIGH); 
    end
    if(scenario != null) begin
      if(!$value$plusargs("MIX_TRAFFIC_TEST=%0d",mix_traffic)) mix_traffic= 0;
        `uvm_info(get_type_name(),$sformatf("##  Got MIX_TRAFFIC_TEST=%0d from command line in dev vseq##", mix_traffic),UVM_HIGH); 
    end
    if(scenario) begin
         if(scenario.is_dev_pure_default_cfg) begin
           if(!uvm_config_db #(cdnpcie_reg_rdb)::get(this,"","reg_model",reg_model))
             `uvm_fatal(get_name(),"get config_db failed for reg_model handle")
         end
    end

    lti_en = ((parameters_cfg_pkg::LTI_SUPPORT == 1) && (i_cfg.strap_is_rp));

    if ($value$plusargs("LTI_ERR_INJ=%s",lti_err_inj)) begin
      `uvm_info("LTI_ERR_INJ", $psprintf("LTI_ERR_INJ=%0s",lti_err_inj), UVM_DEBUG);
    end

    if ($value$plusargs("LTI_MSG_CONV=%b",force_lti_msg_wr_conversion)) begin
      `uvm_info("LTI_MSG_CONV", $psprintf("LTI_MSG_CONV=%0b",force_lti_msg_wr_conversion), UVM_DEBUG);
    end

    if ($value$plusargs("LTI_MSI_CONV=%s",force_lti_msi_wr_conversion)) begin
      `uvm_info("LTI_MSI_CONV", $psprintf("LTI_MSI_CONV=%0s",force_lti_msi_wr_conversion), UVM_DEBUG);
    end

   if((!$value$plusargs("RP_MSI_INJECT_ENABLE=%0d",msi_inject_test_enable))) msi_inject_test_enable=0;
 
  endfunction

  //------------------------------------------------------------------------
  // Function: push_back_in_unmapped_tc_list
  // This function populates the m_unmapped_tc_list and updates the same in
  // m_unmapped_tc_list of all pf_config, vf_config
  //------------------------------------------------------------------------
  function void push_back_in_unmapped_tc_list(int indx);
    m_unmapped_tc_list.push_back(indx);

    foreach(pf_config[i])
      pf_config[i].m_unmapped_tc_list.push_back(indx);

    foreach(vf_config[i,j])
      vf_config[i][j].m_unmapped_tc_list.push_back(indx);
 
  endfunction: push_back_in_unmapped_tc_list

  //------------------------------------------------------------------------
  // Function: delete_from_unmapped_tc_list
  // This function deletes the elements from m_unmapped_tc_list and updates
  // the same in m_unmapped_tc_list of all pf_config, vf_config
  //------------------------------------------------------------------------
  function void delete_from_unmapped_tc_list(int tc);
    //check if queue is not empty
    if(m_unmapped_tc_list.size() !=0 ) begin
          m_unmapped_tc_list.delete(tc);

          foreach(pf_config[i]) begin
            if(pf_config[i].m_unmapped_tc_list.size() !=0 )
              pf_config[i].m_unmapped_tc_list.delete(tc);
          end

          foreach(vf_config[i,j]) begin
            if(vf_config[i][j].m_unmapped_tc_list.size() !=0 )
              vf_config[i][j].m_unmapped_tc_list.delete(tc);
          end
    end
  endfunction : delete_from_unmapped_tc_list

  //------------------------------------------------------------------------
  // Function: reset_unmapped_tc_list
  // This function resets m_unmapped_tc_list and updates
  // the same in m_unmapped_tc_list of all pf_config, vf_config
  //------------------------------------------------------------------------
  function void reset_unmapped_tc_list();
    m_unmapped_tc_list.delete();

    foreach(pf_config[i])
      pf_config[i].m_unmapped_tc_list.delete();

    foreach(vf_config[i,j])
      vf_config[i][j].m_unmapped_tc_list.delete();

    for(int i = 1; i < 8; i++)
      push_back_in_unmapped_tc_list(i);
  endfunction : reset_unmapped_tc_list

   function [12:0] count_encoding_to_value(input [4:0] encoding);
      begin
         case(encoding)
            5'd0:count_encoding_to_value = 13'd16;
            5'd1:count_encoding_to_value = 13'd32;
            5'd2:count_encoding_to_value = 13'd64;
            5'd3:count_encoding_to_value = 13'd128;
            5'd4:count_encoding_to_value = 13'd256;
            5'd5:count_encoding_to_value = 13'd512;
            5'd6:count_encoding_to_value = 13'd768;
            5'd7:count_encoding_to_value = 13'd1024;
            5'd8:count_encoding_to_value = 13'd1280;
            5'd9:count_encoding_to_value = 13'd1536;
            5'd10:count_encoding_to_value = 13'd1792;
            5'd11:count_encoding_to_value = 13'd2048;
            5'd12:count_encoding_to_value = 13'd2304;
            5'd13:count_encoding_to_value = 13'd2560;
            5'd14:count_encoding_to_value = 13'd2816;
            5'd15:count_encoding_to_value = 13'd3072;
            5'd16:count_encoding_to_value = 13'd3328;
            5'd17:count_encoding_to_value = 13'd3584;
            5'd18:count_encoding_to_value = 13'd3840;
            default:count_encoding_to_value = 13'd4096;            
         endcase // encoding
      end
   endfunction

  // CXL-MLD related changes
  function void cxl_mld_related_config();
    // CXL -MLD related changes 
    if (scenario) begin
      if (scenario.cxl_ldid_prefix && i_cfg.strap_is_rp==0) begin
        foreach(pf_config[i]) begin
          pf_config[i].do_copy(pf_config[0]);
          // Same Requester-id for all PFs 
          pf_config[i].m_req_id.bus_num        = pf_config[0].m_req_id.bus_num;
          pf_config[i].m_req_id.device_num     = pf_config[0].m_req_id.device_num;
          pf_config[i].m_req_id.function_num   = pf_config[0].m_req_id.function_num;
          `uvm_info(get_full_name(), $psprintf("CXL-MLD LDID modified value =%h for PF=%d ",pf_config[i].cxl_ldid,i), UVM_DEBUG)
        end
      end
    end
  endfunction

function void post_randomize();
    bit user_defined_cxl_pm_enable;
    bit user_defined_spl_pm_scen_enable;
    bit user_defined_all_vc_zero_credit_dut;
    bit user_defined_all_vc_zero_credit_vip;
    if(non_cxl_ide_traffic_test)begin
      scenario.cxl_ide_mode_tx = INSECURE_MODE; 
      scenario.cxl_ide_mode_rx = INSECURE_MODE; 
    end
 
    if(i_cfg.strap_is_rp) begin
       m_is_pf_disabled_by_lm=0; // not randomizing any bit to keep everything enabled when DUT is RP
    end
    else begin
      //TODO Please Fix this properly.
      //m_is_pf_disabled_by_lm[31:1]= $urandom_range(31'h1,31'h7FFF_FFFF); // not randomizing 0th bit to keep pf0 enabled
      // i_cfg.pf_enabled = ('hFFFF_FFFF & (~m_is_pf_disabled_by_lm));
    end
    
	if(i_cfg.k_flit_mode_support) begin
      flit_mode_supported_temp = 1;
    end
    if(!i_cfg.k_flit_mode_support) begin
      //In flit mode, when infinite credits to be advertised, scaled flow factor should be 2'b00
      foreach(m_fccpld_vc[i]) begin
        if(m_fccpld_vc[i] == 0) m_scaled_flow_ctrl_cpl_hdr_scale[i] =2'b01;
      end
      foreach(m_fccplh_vc[i]) begin
        if(m_fccplh_vc[i] == 0) m_scaled_flow_ctrl_cpl_data_scale[i]= 2'b01;
      end
    end
    foreach(tc_vc_map[i]) tc_vc_map[i] = 9'h1FF;
    if(i_cfg.scenario) begin
      if(i_cfg.scenario.is_flit_mode()) begin//{
        foreach(m_shared_fcph_vc[i])
        begin
          if(malform_credit_limit_p.size() != 0) begin
            if(m_scaled_flow_ctrl_posted_hdr_scale[i] == 0)
              malform_credit_limit_p[i] = ((m_shared_fcph_vc[i]) - 1);
            else
            begin
              malform_credit_limit_p[i] = ((m_shared_fcph_vc[i]) - 1) * (4**(m_scaled_flow_ctrl_posted_hdr_scale[i]-1));
            end
          end
        end
        if(malform_credit_limit_np.size() != 0) begin
          foreach(m_shared_fcnph_x_scale_vc[i])
            malform_credit_limit_np[i] = m_shared_fcnph_x_scale_vc[i] - 1;
        end
        if(malform_credit_limit_cpl.size() != 0) begin
          foreach(m_shared_fccplh_x_scale_vc[i])
            malform_credit_limit_cpl[i] = m_shared_fccplh_x_scale_vc[i] - 1;
        end
      end
      else begin
        foreach(m_fcph_vc[i])
        begin
          if(malform_credit_limit_p.size() != 0) begin
            if(m_scaled_flow_ctrl_posted_hdr_scale[i] == 0)
              malform_credit_limit_p[i] = ((m_fcph_vc[i]) - 1);
            else
            begin
              malform_credit_limit_p[i] = ((m_fcph_vc[i]) - 1) * (4**(m_scaled_flow_ctrl_posted_hdr_scale[i]-1));
            end
          end
          //if(malform_credit_limit_p[i] == 0)
          //`uvm_error(get_full_name(), "All posted header VC=%0d Malformed ")
        end
        if(malform_credit_limit_np.size() != 0) begin
          foreach(m_fcnph_x_scale_vc[i])
            malform_credit_limit_np[i] = m_fcnph_x_scale_vc[i] - 1;
        end
        if(malform_credit_limit_cpl.size() != 0) begin
          foreach(m_fccplh_x_scale_vc[i])
            malform_credit_limit_cpl[i] = m_fccplh_x_scale_vc[i] - 1;
        end
      end
    end
    else begin
      foreach(m_fcph_vc[i])
      begin
        if(malform_credit_limit_p.size() != 0) begin
          if(m_scaled_flow_ctrl_posted_hdr_scale[i] == 0)
            malform_credit_limit_p[i] = ((m_fcph_vc[i]) - 1);
          else
          begin
            malform_credit_limit_p[i] = ((m_fcph_vc[i]) - 1) * (4**(m_scaled_flow_ctrl_posted_hdr_scale[i]-1));
          end
        end
        //if(malform_credit_limit_p[i] == 0)
        //`uvm_error(get_full_name(), "All posted header VC=%0d Malformed ")
      end
      if(malform_credit_limit_np.size() != 0) begin
        foreach(m_fcnph_x_scale_vc[i])
          malform_credit_limit_np[i] = m_fcnph_x_scale_vc[i] - 1;
      end
      if(malform_credit_limit_cpl.size() != 0) begin
        foreach(m_fccplh_x_scale_vc[i])
          malform_credit_limit_cpl[i] = m_fccplh_x_scale_vc[i] - 1;
      end
    end

    if(scenario)
    begin
      m_num_allowed_errors = scenario.m_num_err;
      if(scenario.m_pf_setting == MAX)
        axi_reg_access_en = 1;
      if((scenario.m_is_dllp_err_test == 1) && is_dut_config)
        inject_err_en = 0;
      if((scenario.m_is_dll_flit_err_test == 1) && is_dut_config)
        inject_err_en = 0;  
    end
    //If k_num_vcs=1 && k_multi_tc_sup ==0 then only TC0 is applicable
    if(/*i_cfg.k_num_vcs == 1  &&*/ i_cfg.k_multi_tc_supp==0) begin
      vc_tc_map[0][7:1] = 0;
      `uvm_info(get_name(), $psprintf("k_multi_tc_supp==0 & k_num_vcs=1. Hence, vc_tc_map changed to TC0 only"),UVM_LOW)
    end
    
    foreach(vc_tc_map[i])
    begin
      for(int j = 0; j < 8; j++)
      begin
        if(vc_tc_map[i][j])
          tc_vc_map[j] = i;
      end
    end
    foreach(tc_vc_map[i])
      `uvm_info(get_full_name(), $psprintf("TC_VC_MAP tc = %0d mapped to vc = %0d",i, tc_vc_map[i]), UVM_DEBUG)

    //Initially pushing all TCs to unmapped TC list. These will be removed once
    //the mapping is completed.
    m_unmapped_tc_list.delete();
    for(int i = 1; i < 8; i++)
      m_unmapped_tc_list.push_back(i);

    create_pf_config();
    cxl_mld_related_config(); 

    if(i_cfg.strap_is_rp && is_dut_config) begin
      is_acs_translation_blocking_en = pf_config[0].acs_translation_blocking_en;
    end

    if(scenario) begin
      if((scenario.m_pf_setting == cdn_pcie_scenario_pkg::MAX) && scenario.m_vf_allocation_check) begin
        foreach(pf_config[pfn])
          pf_config[pfn].m_NumVFs = (!i_cfg.strap_is_rp) ? m_pf_vf_map[pfn] : 0;
      end
    end
    //Create VF config only if DUT is EP
    if((!i_cfg.strap_is_rp) && (m_port_type == CDN_HPA_PCIE_USP)) create_vf_config();

    foreach(pf_config[i])
    `uvm_info("DEBUG_REQ_ID", $psprintf("PORT_TYPE=%0s : Requester id of PF_%0d is 'h%0h ",m_port_type.name(),i,{pf_config[i].m_req_id.bus_num, pf_config[i].m_req_id.device_num, pf_config[i].m_req_id.function_num}),UVM_LOW)

    foreach(vf_config[i,j])
    `uvm_info("DEBUG_REQ_ID", $psprintf("PORT_TYPE=%0s : Requester id of PF_%0d_VF_%0d is 'h%0h ",m_port_type.name(),i,j,{vf_config[i][j].m_req_id.bus_num, vf_config[i][j].m_req_id.device_num, vf_config[i][j].m_req_id.function_num}),UVM_LOW)

    //`uvm_info(get_type_name(), $psprintf("Top Config is = %0s" , this.sprint()), UVM_LOW)

    flit_mode_cg.sample();
	m_local_extended_vc_count = parameters_cfg_pkg::KMAX_NUM_VCS;
    dl_top_config_cg.sample();


    dev_top_cfg_cg.sample();
    for(int i=0; i<num_vc_enabled ; i++) vc_cg.sample(i);
    for(int i=0; i<num_vc_enabled ; i++) dl_flow_control_cg.sample(i);

    for(int i=0; i< i_cfg.k_num_cifs ; i++) begin
      cif_cg.sample(i);
      for(int j=0; j< i_cfg.k_num_idgs[i] ; j++) idg_cg.sample(i,j);
    end

    begin
      if(m_port_type == CDN_HPA_PCIE_USP) begin
         m_intr_pins = 0;
         for(int i=0; i<l_num_enabled_pfs; i++) begin
           if(m_intr_pins < pf_config[i].m_intr_pins)
              m_intr_pins = pf_config[i].m_intr_pins; 
         end
       end
    end

    //********************************************************************
    // Below logic will create link list and store information in a quque to
    // access through a sequence
    //********************************************************************
    //Multi PF capabilities
    //for (int i=0; i<l_num_enabled_pfs; i++) begin
    foreach(pf_config[i]) begin
      pf_config[i].m_cap_pci_compatible_config_regs = new();
      pf_config[i].m_cap_pci_pm_ap                  = new();
      pf_config[i].m_cap_msi_cap                    = new();
      pf_config[i].m_cap_msix_cap                   = new();
      pf_config[i].m_cap_pcie_exp_cap               = new();
      pf_config[i].m_cap_aer_ext_cap                = new();
      pf_config[i].m_cap_ari_ext_cap                = new();
      pf_config[i].m_cap_resize_bar_ext_cap         = new();
      pf_config[i].m_cap_sriov_cap                  = new();
      pf_config[i].m_cap_tph_ext_cap                = new();
      pf_config[i].m_cap_pasid_ext_cap              = new();
      pf_config[i].m_cap_ats_cap                    = new();
      pf_config[i].m_cap_ats_pr_cap                 = new();
    end
    //PF0 specific capabilities
    m_cap_dev_serial_ext_cap                      =new();
    m_cap_pwr_budget_ext_cap                      =new();
    m_cap_ltr_ext_cap                             =new();
    m_cap_dpa_ext_cap                             =new();
    m_cap_sec_pcie_ext_cap                        =new();
    m_cap_vc_ext_cap                              =new();
    m_cap_l1_pm_ext_cap                           =new();
    m_cap_dl_feature_ext_cap                      =new();
    m_cap_lane_mrgn_ext_cap                       =new();
    m_cap_pl_16gt_ext_cap                         =new();
    m_cap_ptm_ext_cap                             =new();
    m_cap_npeme_ext_cap                           =new();
    m_cap_pl_32gt_ext_cap                         =new();
    m_cap_pl_64gt_ext_cap                         =new();
    m_cap_flit_log_ext_cap                        =new();
    m_cap_flit_perf_measr_ext_cap                 =new();
    m_cap_flit_err_inj_ext_cap                    =new();
    m_cap_apn_ext_cap                             =new();
    m_cap_ide_ext_cap                             =new();
    m_cap_dev3_ext_cap                            =new();
    m_cap_ucie_dvsec_cap                          =new();
    m_cap_ucie_dvsec_msi_cap                      =new();

    //Picking any random PF afetr PFO, from PF1 to PFn to issue register rd/wr
    if(l_num_enabled_pfs == 2) begin
        pf_index = 1;
    end else if(l_num_enabled_pfs >2) begin
        pf_index = $urandom_range(l_num_enabled_pfs-1, 2);
    end else begin
        pf_index = 'hDEAD;
    end
    `uvm_info(get_type_name(), $psprintf(" pf_cap_linked_list :: Picking PF[%0d] to access after PF0 done_creating_reg_linkedlist %d",pf_index, i_cfg.done_creating_reg_linkedlist ), UVM_LOW)

    //This post randomise function is getting called twice once for all
    //PFS(based on k_num_PFs) and once for only PF0 so restricting it to call
    //below functions only once
    //For PFs
    if(!i_cfg.done_creating_reg_linkedlist) begin
      pf_cap_linked_list();
      //For VFs
      vf_cap_linked_list();
    end
    //val1 SF0/1-> 1; MPS/16
    //     SF2  ->4;  MPS/64 +1
    //     SF3  ->8;  MPS/256 +1
    for(int vc = 0; vc < num_vc_enabled ; vc++)begin
      if(m_fcph_x_scale_vc[vc]<10)begin
        vc_allowed_posted_tlps[vc]=m_fcph_x_scale_vc[vc];
      end
      else if(m_fcpd_vc[vc]<min_p_pld_credits[vc]+10)begin
        vc_allowed_posted_tlps[vc]=$urandom_range(10,1);
      end
      else begin
        //minimum throttle for posted linked TC/VC
        vc_allowed_posted_tlps[vc]=50;
      end
    end
    for(int vc = 0; vc < num_vc_enabled ; vc++)begin
      if(m_fcnph_x_scale_vc[vc]<10)begin
        vc_allowed_nonposted_tlps[vc]=m_fcnph_x_scale_vc[vc];
      end
      else begin
        //minimum throttle for nonposted linked TC/VC
        vc_allowed_nonposted_tlps[vc]=50;
      end
    end
    if(scenario)
    begin
      if(scenario.m_ib_credit_throttle_enabled)
        m_credit_throttle_enabled = 1;
      num_tlps_allowed = scenario.m_ib_num_tlp_burst;
    end
    
    // Config Snoop Test Scenario
    if(scenario)
     begin
      if(scenario.m_is_snoop_test)
        begin
           m_lm_config_snoop_timeout_val=16'd4;  // Add random delay
           snoop_rsp_active_mode=1;
           snoop_rdata_random_mode=0;
           
          if(scenario.m_is_snoop_err_test)
           begin 
            snoop_rsp_delay_mode=1;
            snoop_rsp_delay_mode_before=0;
            snoop_rsp_delay_mode_after=1;
            snoop_rsp_dcd_err_mode=0;
           end
        end
      if(scenario.cxl_mmio_snoop_test)
        begin
           //mmio_snp_timeout_axi_clk_num_cycles=16'd4;  // Add random delay
           mmio_snoop_rsp_active_mode=1;
        end
           
      //    if(scenario.cxl_snoop_err_test)
      //     begin 
      //      mmio_snoop_rsp_delay_mode=1;
      //      mmio_snoop_rsp_delay_mode_before=0;
      //      mmio_snoop_rsp_delay_mode_after=1;
      //      mmio_snoop_rsp_dcd_err_mode=0;
      //     end
      //end
     end


    //Credit display
    foreach(m_fcph_vc[vc])begin
       if(m_port_type==CDN_HPA_PCIE_DSP && i_cfg.strap_is_rp || m_port_type==CDN_HPA_PCIE_USP && !i_cfg.strap_is_rp)
    	`uvm_info(get_type_name(), $psprintf(" Flow Control Credits DUT_CFG :: VC=%0d \n 	PH_SF=%0d    PH_Crdt=%0d, \n 	NPH_SF=%0d     NPH_Crdt=%0d \n 	CPLH_SF=%0d     CPLH_Crdt=%0d \n 	PD_SF=%0d     PD_Crdt=%0d \n 	NPD_SF=%0d     NPD_Crdt=%0d \n 	CPLD_SF=%0d     CPLD_Crdt=%0d",vc,m_scaled_flow_ctrl_posted_hdr_scale[vc],m_fcph_vc[vc],m_scaled_flow_ctrl_non_posted_hdr_scale[vc],m_fcnph_vc[vc],m_scaled_flow_ctrl_cpl_hdr_scale[vc],m_fccplh_vc[vc],m_scaled_flow_ctrl_posted_data_scale[vc],m_fcpd_vc[vc],m_scaled_flow_ctrl_non_posted_data_scale[vc],m_fcnpd_vc[vc],m_scaled_flow_ctrl_cpl_data_scale[vc],m_fccpld_vc[vc]), UVM_NONE)
       else
    	`uvm_info(get_type_name(), $psprintf(" Flow Control Credits BFM_CFG :: VC=%0d \n 	PH_SF=%0d    PH_Crdt=%0d, \n 	NPH_SF=%0d     NPH_Crdt=%0d \n 	CPLH_SF=%0d     CPLH_Crdt=%0d \n 	PD_SF=%0d     PD_Crdt=%0d \n 	NPD_SF=%0d     NPD_Crdt=%0d \n 	CPLD_SF=%0d     CPLD_Crdt=%0d",vc,m_scaled_flow_ctrl_posted_hdr_scale[vc],m_fcph_vc[vc],m_scaled_flow_ctrl_non_posted_hdr_scale[vc],m_fcnph_vc[vc],m_scaled_flow_ctrl_cpl_hdr_scale[vc],m_fccplh_vc[vc],m_scaled_flow_ctrl_posted_data_scale[vc],m_fcpd_vc[vc],m_scaled_flow_ctrl_non_posted_data_scale[vc],m_fcnpd_vc[vc],m_scaled_flow_ctrl_cpl_data_scale[vc],m_fccpld_vc[vc]), UVM_NONE)

    end

    if ($value$plusargs("CXL_PM_ENABLE=%0d", user_defined_cxl_pm_enable )) begin
      `uvm_info(get_type_name(), $sformatf("CXL_PM_ENABLE = %0d from command line for CXL.", user_defined_cxl_pm_enable), UVM_NONE)
       cxl_pm_scenario = user_defined_cxl_pm_enable;
    end

    if(scenario)
    begin
      if(scenario.m_is_reg_flit_err_test) 
        m_enable_flit_err_inj = 1;

      if(scenario.m_is_reg_based_flit_err_test) 
        m_enable_reg_based_flit_err_inj = 1;
   // TODO 
   // This is Temp Condition, seeing some issue in hpa tlp class 
   // Need to remove once hpa tlp issue fixed
    if(scenario.m_is_dll_flit_err_test)
      bypass_credit_check = 1;

    `uvm_info(get_type_name(), $psprintf("Post Randomize dll_flit_err_inj %0d bypass_credit_check %0d ",scenario.m_is_dll_flit_err_test, bypass_credit_check), UVM_NONE);
    end

    
    if(i_cfg.k_ide_supported) begin 
      randomize_ide_cfg();
      if(scenario)begin
        if(scenario.is_tdisp_mode() && m_build_sel_stream && (ide_cfg.m_num_sel_str_enabled > 0))begin
          randomize_tdisp_cfg();
        end
      end  
    end

    
    assert(asf_cfg.randomize());

    if($value$plusargs("ALL_VC_ZERO_SHARED_CRED_DUT=%0d",user_defined_all_vc_zero_credit_dut)) begin
      all_vc_zero_shared_cred_dut=user_defined_all_vc_zero_credit_dut;
      `uvm_info(get_type_name(), $sformatf("ALL_VC_ZERO_SHARED_CRED_DUT= %0d from command line.", user_defined_all_vc_zero_credit_dut), UVM_DEBUG)
    end

    if($value$plusargs("ALL_VC_ZERO_SHARED_CRED_VIP=%0d",user_defined_all_vc_zero_credit_vip)) begin
      all_vc_zero_shared_cred_vip=user_defined_all_vc_zero_credit_vip;
      `uvm_info(get_type_name(), $sformatf("ALL_VC_ZERO_SHARED_CRED_VIP= %0d from command line.", user_defined_all_vc_zero_credit_vip), UVM_DEBUG)
    end

    //TEMP: To force always use zero shared credits
    //all_vc_zero_shared_cred_vip=1;
    //all_vc_zero_shared_cred_dut=1;

    //If default credit initialization is chosen, compute in similar way of DUT default values
    //Only for dut's dev_top_cfg
    if(default_cred_init && (((m_port_type == CDN_HPA_PCIE_DSP && i_cfg.strap_is_rp) || (m_port_type == CDN_HPA_PCIE_USP && !i_cfg.strap_is_rp)))) begin //{
      `uvm_info("DEFAULT_CRED_OVERRIDE",$psprintf("Overriding the randomized credits with Default credits"),UVM_LOW);
      inf_zero_merged_shared_fcph = new[i_cfg.k_num_vcs];
      inf_zero_merged_shared_fcpd = new[i_cfg.k_num_vcs];
      inf_zero_merged_shared_fcnph = new[i_cfg.k_num_vcs];
      inf_zero_merged_shared_fcnpd = new[i_cfg.k_num_vcs];
      inf_zero_merged_shared_fccplh = new[i_cfg.k_num_vcs];
      inf_zero_merged_shared_fccpld = new[i_cfg.k_num_vcs];

      inf_zero_merged_dedicated_fcph = new[i_cfg.k_num_vcs];
      inf_zero_merged_dedicated_fcpd = new[i_cfg.k_num_vcs];
      inf_zero_merged_dedicated_fcnph = new[i_cfg.k_num_vcs];
      inf_zero_merged_dedicated_fcnpd = new[i_cfg.k_num_vcs];
      inf_zero_merged_dedicated_fccplh = new[i_cfg.k_num_vcs];
      inf_zero_merged_dedicated_fccpld = new[i_cfg.k_num_vcs];

      if((i_cfg.scenario != null) && i_cfg.scenario.is_flit_mode()) begin//{
         foreach(inf_zero_merged_shared_fcph[i]) begin
          inf_zero_merged_shared_fcph[i] = RANDOM_SCALE;
          inf_zero_merged_shared_fcpd[i] = RANDOM_SCALE;
          inf_zero_merged_shared_fcnph[i] = RANDOM_SCALE;
          inf_zero_merged_shared_fcnpd[i] = RANDOM_SCALE;
          inf_zero_merged_shared_fccplh[i] = INFINITE_CREDIT;
          inf_zero_merged_shared_fccpld[i] = INFINITE_CREDIT;
         end
        if(i_cfg.k_num_vcs==1) begin//{
         foreach(inf_zero_merged_dedicated_fcph[i]) begin
          inf_zero_merged_dedicated_fcph[i] = ZERO_CREDIT;
          inf_zero_merged_dedicated_fcpd[i] = ZERO_CREDIT;
          inf_zero_merged_dedicated_fcnph[i] = ZERO_CREDIT;
          inf_zero_merged_dedicated_fcnpd[i] = ZERO_CREDIT;
          inf_zero_merged_dedicated_fccplh[i] = ZERO_CREDIT;
          inf_zero_merged_dedicated_fccpld[i] = ZERO_CREDIT;
         end
        end else begin //}{
         foreach(inf_zero_merged_dedicated_fcph[i]) begin
          inf_zero_merged_dedicated_fcph[i] = RANDOM_SCALE;
          inf_zero_merged_dedicated_fcpd[i] = RANDOM_SCALE;
          inf_zero_merged_dedicated_fcnph[i] = RANDOM_SCALE;
          inf_zero_merged_dedicated_fcnpd[i] = RANDOM_SCALE;
          inf_zero_merged_dedicated_fccplh[i] = INFINITE_CREDIT;
          inf_zero_merged_dedicated_fccpld[i] = INFINITE_CREDIT;
         end
        end //}
      end//}

    case(i_cfg.k_datapath_wd)
      8'd4  : datapath_octa = 3'd0; 
      8'd8  : datapath_octa = 3'd1; 
      8'd16 : datapath_octa = 3'd2; 
      8'd32 : datapath_octa = 3'd3; 
      default : datapath_octa = 3'd0;
    endcase       

    for(int cif=0; cif<parameters_cfg_pkg::KMAX_NUM_CIFS; cif++) begin //{
      //Decode FIFO Depths
      posted_fifo_depth[cif] = count_encoding_to_value(i_cfg.k_posted_buffer_tlp_fifo_depth_encoded[cif]);
      non_posted_fifo_depth[cif] = count_encoding_to_value(i_cfg.k_nonposted_buffer_tlp_fifo_depth_encoded[cif]);
      compl_fifo_depth[cif] = count_encoding_to_value(i_cfg.k_compl_buffer_tlp_fifo_depth_encoded[cif]);
  
      //Decode FIFO TLP Counts
      posted_fifo_tlp_cnt[cif] = count_encoding_to_value(i_cfg.k_posted_buffer_num_tlp_support_encoded[cif]);
      non_posted_fifo_tlp_cnt[cif] = count_encoding_to_value(i_cfg.k_nonposted_buffer_num_tlp_support_encoded[cif]);
      compl_fifo_tlp_cnt[cif] = count_encoding_to_value(i_cfg.k_compl_buffer_num_tlp_support_encoded[cif]);

      `uvm_info("DEFAULT_CRED_INIT",$psprintf("k_posted_buffer_tlp_fifo_depth_encoded=%0d[%0d],\n k_nonposted_buffer_tlp_fifo_depth_encoded=%0d[%0d] \n k_posted_buffer_num_tlp_support_encoded=%0d[%0d] \n k_nonposted_buffer_num_tlp_support_encoded[cif]=%0d[%0d]",i_cfg.k_posted_buffer_tlp_fifo_depth_encoded[cif],posted_fifo_depth[cif], i_cfg.k_nonposted_buffer_tlp_fifo_depth_encoded[cif],non_posted_fifo_depth[cif],i_cfg.k_posted_buffer_num_tlp_support_encoded[cif],posted_fifo_tlp_cnt[cif],i_cfg.k_nonposted_buffer_num_tlp_support_encoded[cif], non_posted_fifo_tlp_cnt[cif]),UVM_LOW);

      //----------------------------
      //Calculate Posted Credits
      //----------------------------
      //Header is Same as TLP Count if there is no Prefix 
      posted_hdr_credits_cif[cif] =  posted_fifo_tlp_cnt[cif];
      //Calculate Total available Credits
      posted_octawords_avail[cif] = {2'd0,posted_fifo_depth[cif]} << datapath_octa;
      //Calculate Total Data Credits
      //posted_data_credits_cif[cif] = (i_cfg.k_pasid_supported|i_cfg.k_ext_tph_supported |i_cfg.k_ide_supported| (|i_cfg.k_vendor_prefix_local_support)) ? (posted_octawords_avail[cif] - (posted_hdr_credits_cif[cif] << 1'b1)) : (posted_octawords_avail[cif] - posted_hdr_credits_cif[cif]);


    //Data Credits will be total credit minus reserved for header
    //Calculation of header rsvd credit is dependent on prefix(s) and ecrc.
    //As ecrc(TS/ECRC) support is default, 8dw (2credits) will be always rsvd for
    //1 header. requires 12dw(3credits) as well when all prefixs are supported
    //OHC -A1(PASID)/A4(DESTINATION SEGMENT),	OHC-B (TPH)
    //OHC-C(IDE),MLD/DEDICCATED LOCAL PREFIX(2DW) 

    num_dws_prefix_support = {i_cfg.k_pasid_supported, i_cfg.k_ext_tph_supported, parameters_cfg_pkg::KMAX_IDE_SUPPORT , |i_cfg.k_vendor_prefix_local_support};
    num_dws_prefix_count = $countones(num_dws_prefix_support);
    
    posted_hdr_credits__2times[cif] = (posted_hdr_credits_cif[cif] << 1'b1);
    posted_hdr_credits__3times[cif] = posted_hdr_credits__2times[cif] + posted_hdr_credits_cif[cif];
    //For FM,Segment#, local_prefix, ECRC is always present - 3DWs +
    //4 dw header so > 1 prefix need 12DW(3 credits)
    //For NFM, ECRC is always present, so 1 + 4dw hdr
    // so >3 prefix need 12dw else 8 dw is sufficient 
    cfg_need_three_credits_for_each_tlp = (parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 1) ? (num_dws_prefix_count > 3'd1) : (num_dws_prefix_count > 3'd3);  

    posted_data_credits_cif[cif] =  cfg_need_three_credits_for_each_tlp ? (posted_octawords_avail[cif] - posted_hdr_credits__3times[cif]) : (posted_octawords_avail[cif] - posted_hdr_credits__2times[cif]);



      `uvm_info("DEFAULT_CRED_INIT",$psprintf("datapath_octa=%0d, cfg_need_three_credits_for_each_tlp=%0d, cif=%0d posted_hdr_credits__3times=%0d posted_hdr_credits__2times=%0d num_dws_prefix_count=%0d num_dws_prefix_support=%0d posted_hdr_credits_cif[cif]=%0d \n posted_octawords_avail[cif]=%0d \n posted_data_credits_cif[cif]=%0d",datapath_octa,cfg_need_three_credits_for_each_tlp,cif,posted_hdr_credits__3times[cif],posted_hdr_credits__2times[cif],num_dws_prefix_count,num_dws_prefix_support,posted_hdr_credits_cif[cif],posted_octawords_avail[cif],posted_data_credits_cif[cif]),UVM_LOW);






      //----------------------------
      //Calculate Non Posted Credits
      //----------------------------
      //Calculate Total available Credits
      non_posted_octawords_avail[cif] = {4'd0,non_posted_fifo_depth[cif]} << datapath_octa;
      //Header is Same as TLP Count if there is no Prefix 
      //non_posted_hdr_credits_cif[cif] = (non_posted_octawords_avail[cif] <= {2'd0,non_posted_fifo_tlp_cnt[cif]}) ? (non_posted_octawords_avail[cif] - 17'd4) : non_posted_fifo_tlp_cnt[cif];
      //Calculate Total Data Credits
      //non_posted_data_credits_cif[cif] = (non_posted_octawords_avail[cif] <= {2'd0,non_posted_fifo_tlp_cnt[cif]}) ? 17'd4 : (i_cfg.k_pasid_supported|i_cfg.k_ext_tph_supported|i_cfg.k_ide_supported| (|i_cfg.k_vendor_prefix_local_support)) ? (non_posted_octawords_avail[cif] - (non_posted_hdr_credits_cif[cif] << 1'b1)) : (non_posted_octawords_avail[cif] - non_posted_hdr_credits_cif[cif]);

    //Header and credit rsvd calculation changes are same as Posted
   non_posted_hdr_credits__2times[cif] = ({4'd0,non_posted_fifo_tlp_cnt[cif]} << 1'b1);
    non_posted_hdr_credits__3times[cif] = non_posted_hdr_credits__2times[cif] + {4'd0,non_posted_fifo_tlp_cnt[cif]}; 

    non_posted_hdr_credits_int_calc[cif] =  cfg_need_three_credits_for_each_tlp ? non_posted_hdr_credits__3times[cif] : non_posted_hdr_credits__2times[cif];
    //Reserving 4 credits as flit mode shared credit works on 4 credits grannular so always rsvd 4
    //if total np credit is less than equal(less is not correct config setting) header requirment then we pass total to
    //hdr and 4 np-posted data credit
    non_posted_hdr_credits_cif[cif] = (non_posted_octawords_avail[cif] <= non_posted_hdr_credits_int_calc[cif]) ? ({4'd0, non_posted_fifo_tlp_cnt[cif]} - 17'd4) : {4'd0, non_posted_fifo_tlp_cnt[cif]};
    //Calculate Total Data Credits
    non_posted_data_credits_cif[cif] = (non_posted_octawords_avail[cif] <= non_posted_hdr_credits_int_calc[cif]) ? 17'd4 : cfg_need_three_credits_for_each_tlp ? (non_posted_octawords_avail[cif] - non_posted_hdr_credits__3times[cif]) : (non_posted_octawords_avail[cif] - non_posted_hdr_credits__2times[cif]);



      `uvm_info("DEFAULT_CRED_INIT",$psprintf("non_posted_hdr_credits_cif[cif]=%0d \n non_posted_octawords_avail[cif]=%0d \n non_posted_data_credits_cif[cif]=%0d",non_posted_hdr_credits_cif[cif],non_posted_octawords_avail[cif],non_posted_data_credits_cif[cif]),UVM_LOW);
    end //}

      m_fcph_vc = new[i_cfg.k_num_vcs];
      m_fcpd_vc =new[i_cfg.k_num_vcs];
      m_fcnph_vc =new[i_cfg.k_num_vcs];
      m_fcnpd_vc =new[i_cfg.k_num_vcs];
           
      m_scaled_flow_ctrl_posted_hdr_scale=new[i_cfg.k_num_vcs];
      m_scaled_flow_ctrl_posted_data_scale=new[i_cfg.k_num_vcs];
      m_scaled_flow_ctrl_non_posted_hdr_scale=new[i_cfg.k_num_vcs];
      m_scaled_flow_ctrl_non_posted_data_scale=new[i_cfg.k_num_vcs];

      m_fcph_x_scale_vc   =new[i_cfg.k_num_vcs];
      m_fcpd_x_scale_vc   =new[i_cfg.k_num_vcs];
      m_fcnph_x_scale_vc  =new[i_cfg.k_num_vcs];
      m_fcnpd_x_scale_vc  =new[i_cfg.k_num_vcs];

      m_shared_fcph_vc = new[i_cfg.k_num_vcs];
      m_shared_fcpd_vc =new[i_cfg.k_num_vcs];
      m_shared_fcnph_vc =new[i_cfg.k_num_vcs];
      m_shared_fcnpd_vc =new[i_cfg.k_num_vcs];
           
      m_shared_scaled_flow_ctrl_posted_hdr_scale=new[i_cfg.k_num_vcs];
      m_shared_scaled_flow_ctrl_posted_data_scale=new[i_cfg.k_num_vcs];
      m_shared_scaled_flow_ctrl_non_posted_hdr_scale=new[i_cfg.k_num_vcs];
      m_shared_scaled_flow_ctrl_non_posted_data_scale=new[i_cfg.k_num_vcs];

      m_shared_fcph_x_scale_vc   =new[i_cfg.k_num_vcs];
      m_shared_fcpd_x_scale_vc   =new[i_cfg.k_num_vcs];
      m_shared_fcnph_x_scale_vc  =new[i_cfg.k_num_vcs];
      m_shared_fcnpd_x_scale_vc  =new[i_cfg.k_num_vcs];

      m_total_fcph_vc = new[i_cfg.k_num_vcs];
      m_total_fcpd_vc =new[i_cfg.k_num_vcs];
      m_total_fcnph_vc =new[i_cfg.k_num_vcs];
      m_total_fcnpd_vc =new[i_cfg.k_num_vcs];

      m_total_fcph_x_scale_vc   =new[i_cfg.k_num_vcs];
      m_total_fcpd_x_scale_vc   =new[i_cfg.k_num_vcs];
      m_total_fcnph_x_scale_vc  =new[i_cfg.k_num_vcs];
      m_total_fcnpd_x_scale_vc  =new[i_cfg.k_num_vcs];

      //TODO for multi cifs
      //For FM,we need to compute Ded credits first and subtract from total value to obtain shared credit
      if((i_cfg.scenario != null) && i_cfg.scenario.is_flit_mode()) begin//{
       for(int vc=0; vc<i_cfg.k_num_vcs; vc++) begin
        m_total_fcph_x_scale_vc[vc]= posted_hdr_credits_cif[0]/i_cfg.k_num_vcs;
        m_total_fcpd_x_scale_vc[vc]= posted_data_credits_cif[0]/i_cfg.k_num_vcs;
        m_total_fcnph_x_scale_vc[vc]= non_posted_hdr_credits_cif[0]/i_cfg.k_num_vcs;
        m_total_fcnpd_x_scale_vc[vc]= non_posted_data_credits_cif[0]/i_cfg.k_num_vcs;

        //Compute dedicated credits as per implementation documentation
        //To compute shared credits, total-dedicated
        //NOTE: Dedicated credits share the same scale factor as Shared/total credit as per implementation
        if(m_total_fcph_x_scale_vc[vc] >508) begin
          m_total_fcph_vc[vc]=m_total_fcph_x_scale_vc[vc]/16;
          m_scaled_flow_ctrl_posted_hdr_scale[vc] = 2'b11;
          m_shared_scaled_flow_ctrl_posted_hdr_scale[vc] = 2'b11;
        end else if (m_total_fcph_x_scale_vc[vc] >127) begin
          m_total_fcph_vc[vc]=m_total_fcph_x_scale_vc[vc]/4;
          m_scaled_flow_ctrl_posted_hdr_scale[vc] = 2'b10;
          m_shared_scaled_flow_ctrl_posted_hdr_scale[vc] = 2'b10;
        end else begin
          m_total_fcph_vc[vc]=m_total_fcph_x_scale_vc[vc]/1;
          m_scaled_flow_ctrl_posted_hdr_scale[vc] = 2'b01;
          m_shared_scaled_flow_ctrl_posted_hdr_scale[vc] = 2'b01;
        end
        //PD
        if(m_total_fcpd_x_scale_vc[vc] >8188) begin
          m_total_fcpd_vc[vc]=m_total_fcpd_x_scale_vc[vc]/16;
          m_scaled_flow_ctrl_posted_data_scale[vc] = 2'b11;
          m_shared_scaled_flow_ctrl_posted_data_scale[vc] = 2'b11;
        end else if (m_total_fcpd_x_scale_vc[vc] >2047) begin
          m_total_fcpd_vc[vc]=m_total_fcpd_x_scale_vc[vc]/4;
          m_scaled_flow_ctrl_posted_data_scale[vc] = 2'b10;
          m_shared_scaled_flow_ctrl_posted_data_scale[vc] = 2'b10;
        end else begin
          m_total_fcpd_vc[vc]=m_total_fcpd_x_scale_vc[vc]/1;
          m_scaled_flow_ctrl_posted_data_scale[vc] = 2'b01;
          m_shared_scaled_flow_ctrl_posted_data_scale[vc] = 2'b01;
        end

        //NPH
        if(m_total_fcnph_x_scale_vc[vc] >508) begin
          m_total_fcnph_vc[vc]=m_total_fcnph_x_scale_vc[vc]/16;
          m_scaled_flow_ctrl_non_posted_hdr_scale[vc] = 2'b11;
          m_shared_scaled_flow_ctrl_non_posted_hdr_scale[vc] = 2'b11;
        end else if (m_total_fcnph_x_scale_vc[vc] >127) begin
          m_total_fcnph_vc[vc]=m_total_fcnph_x_scale_vc[vc]/4;
          m_scaled_flow_ctrl_non_posted_hdr_scale[vc] = 2'b10;
          m_shared_scaled_flow_ctrl_non_posted_hdr_scale[vc] = 2'b10;
        end else begin
          m_total_fcnph_vc[vc]=m_total_fcnph_x_scale_vc[vc]/1;
          m_scaled_flow_ctrl_non_posted_hdr_scale[vc] = 2'b01;
          m_shared_scaled_flow_ctrl_non_posted_hdr_scale[vc] = 2'b01;
        end
        //NPD
        if(m_total_fcnpd_x_scale_vc[vc] >8188) begin
          m_total_fcnpd_vc[vc]=m_total_fcnpd_x_scale_vc[vc]/16;
          m_scaled_flow_ctrl_non_posted_data_scale[vc] = 2'b11;
          m_shared_scaled_flow_ctrl_non_posted_data_scale[vc] = 2'b11;
        end else if (m_total_fcnpd_x_scale_vc[vc] >2047) begin
          m_total_fcnpd_vc[vc]=m_total_fcnpd_x_scale_vc[vc]/4;
          m_scaled_flow_ctrl_non_posted_data_scale[vc] = 2'b10;
          m_shared_scaled_flow_ctrl_non_posted_data_scale[vc] = 2'b10;
        end else begin
          m_total_fcnpd_vc[vc]=m_total_fcnpd_x_scale_vc[vc]/1;
          m_scaled_flow_ctrl_non_posted_data_scale[vc] = 2'b01;
          m_shared_scaled_flow_ctrl_non_posted_data_scale[vc] = 2'b01;
        end

        //Dedicated credits
        if(i_cfg.k_num_vcs !=1) begin
         m_fcph_vc[vc] = 8'd1;
         m_fcpd_vc[vc] = int'((128 << i_cfg.k_max_payload_size)/16);
         m_fcnph_vc[vc] = 8'd1;
         m_fcnpd_vc[vc] = (i_cfg.k_dmwr_req_support || i_cfg.k_dmwr_compl_support) ? 12'd8 : ((i_cfg.k_atomic_op_support) ? 12'd2 : 12'd1);
        end else begin
         m_fcph_vc[vc] = 8'd0;
         m_fcpd_vc[vc] = 8'd0; 
         m_fcnph_vc[vc] = 8'd0;
         m_fcnpd_vc[vc] = 8'd0; 
         m_scaled_flow_ctrl_posted_hdr_scale[vc]=2'b01; //ZERO_CREDIT
         m_scaled_flow_ctrl_posted_data_scale[vc]=2'b01; //ZERO_CREDIT
         m_scaled_flow_ctrl_non_posted_hdr_scale[vc]=2'b01; //ZERO_CREDIT
         m_scaled_flow_ctrl_non_posted_data_scale[vc]=2'b01; //ZERO_CREDIT
        end

        //Spec mandates block of 4credit units for shared credits
        m_shared_fcph_vc[vc] = (m_total_fcph_vc[vc]- m_fcph_vc[vc]);
        m_shared_fcpd_vc[vc] = (m_total_fcpd_vc[vc]- m_fcpd_vc[vc]);
        m_shared_fcnph_vc[vc] = (m_total_fcnph_vc[vc]- m_fcnph_vc[vc]);
        m_shared_fcnpd_vc[vc] = (m_total_fcnpd_vc[vc]- m_fcnpd_vc[vc]); 
        //m_shared_fcph_vc[vc] = (m_total_fcph_vc[vc]- m_fcph_vc[vc])-((m_total_fcph_vc[vc]- m_fcph_vc[vc])%4);
        //m_shared_fcpd_vc[vc] = (m_total_fcpd_vc[vc]- m_fcpd_vc[vc]) - ((m_total_fcpd_vc[vc]- m_fcpd_vc[vc])%4);
        //m_shared_fcnph_vc[vc] = (m_total_fcnph_vc[vc]- m_fcnph_vc[vc])-((m_total_fcnph_vc[vc]- m_fcnph_vc[vc])%4);
        //m_shared_fcnpd_vc[vc] = (m_total_fcnpd_vc[vc]- m_fcnpd_vc[vc]) - ((m_total_fcnpd_vc[vc]- m_fcnpd_vc[vc])%4); 
        m_total_scaled_flow_ctrl_posted_hdr_scale=m_shared_scaled_flow_ctrl_posted_hdr_scale[0];
        m_total_scaled_flow_ctrl_posted_data_scale=m_shared_scaled_flow_ctrl_posted_data_scale[0];
        m_total_scaled_flow_ctrl_non_posted_hdr_scale=m_shared_scaled_flow_ctrl_non_posted_hdr_scale[0];
        m_total_scaled_flow_ctrl_non_posted_data_scale=m_shared_scaled_flow_ctrl_non_posted_data_scale[0];


        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_total_fcph_x_scale_vc[%0d]=%0d",vc,m_total_fcph_x_scale_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_total_fcpd_x_scale_vc[%0d]=%0d",vc,m_total_fcpd_x_scale_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_total_fcnph_x_scale_vc[%0d]=%0d",vc,m_total_fcnph_x_scale_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_total_fcnpd_x_scale_vc[%0d]=%0d",vc,m_total_fcnpd_x_scale_vc[vc]),UVM_LOW);

        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_total_fcph_vc[%0d]=%0d",vc,m_total_fcph_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_total_fcpd_vc[%0d]=%0d",vc,m_total_fcpd_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_total_fcnph_vc[%0d]=%0d",vc,m_total_fcnph_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_total_fcnpd_vc[%0d]=%0d",vc,m_total_fcnpd_vc[vc]),UVM_LOW);

        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcph_vc[%0d]=%0d",vc,m_fcph_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcpd_vc[%0d]=%0d",vc,m_fcpd_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcnph_vc[%0d]=%0d",vc,m_fcnph_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcnpd_vc[%0d]=%0d",vc,m_fcnpd_vc[vc]),UVM_LOW);

        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_posted_hdr_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_posted_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_posted_data_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_posted_data_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_non_posted_hdr_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_non_posted_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_non_posted_data_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_non_posted_data_scale[vc]),UVM_LOW);

        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_fcph_vc[%0d]=%0d",vc, m_shared_fcph_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_fcpd_vc[%0d]=%0d",vc, m_shared_fcpd_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_fcnph_vc[%0d]=%0d",vc,m_shared_fcnph_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_fcnpd_vc[%0d]=%0d",vc,m_shared_fcnpd_vc[vc]),UVM_LOW);

        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_scaled_flow_ctrl_posted_hdr_scale[%0d]=%0d",vc,     m_shared_scaled_flow_ctrl_posted_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_scaled_flow_ctrl_posted_data_scale[%0d]=%0d",vc,    m_shared_scaled_flow_ctrl_posted_data_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_scaled_flow_ctrl_non_posted_hdr_scale[%0d]=%0d",vc, m_shared_scaled_flow_ctrl_non_posted_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_scaled_flow_ctrl_non_posted_data_scale[%0d]=%0d",vc,m_shared_scaled_flow_ctrl_non_posted_data_scale[vc]),UVM_LOW);
       end
      end else begin //}{ NFM
       for(int vc=0; vc<i_cfg.k_num_vcs; vc++) begin
        m_fcph_x_scale_vc[vc]= posted_hdr_credits_cif[0]/i_cfg.k_num_vcs;
        m_fcpd_x_scale_vc[vc]= posted_data_credits_cif[0]/i_cfg.k_num_vcs;
        m_fcnph_x_scale_vc[vc]= non_posted_hdr_credits_cif[0]/i_cfg.k_num_vcs;
        m_fcnpd_x_scale_vc[vc]= non_posted_data_credits_cif[0]/i_cfg.k_num_vcs;

        //if(!m_dlf_exchange_en && !m_local_dl_feature_supp) begin
        if(i_cfg.strap_pcie_rate_max < 3) begin //Scaled flow not supported
         if(m_fcph_x_scale_vc[vc] >127) m_fcph_x_scale_vc[vc]=127;
         if(m_fcnph_x_scale_vc[vc] >127) m_fcnph_x_scale_vc[vc]=127;
         if(m_fcpd_x_scale_vc[vc] >2047) m_fcpd_x_scale_vc[vc]=2047;
         if(m_fcnpd_x_scale_vc[vc] >2047) m_fcnpd_x_scale_vc[vc]=2047;
        end
        //PH
        if(m_fcph_x_scale_vc[vc] >508) begin
          m_fcph_vc[vc]=m_fcph_x_scale_vc[vc]/16;
          m_scaled_flow_ctrl_posted_hdr_scale[vc] = 2'b11;
        end else if (m_fcph_x_scale_vc[vc] >127) begin
          m_fcph_vc[vc]=m_fcph_x_scale_vc[vc]/4;
          m_scaled_flow_ctrl_posted_hdr_scale[vc] = 2'b10;
        end else begin
          m_fcph_vc[vc]=m_fcph_x_scale_vc[vc]/1;
          m_scaled_flow_ctrl_posted_hdr_scale[vc] = (i_cfg.strap_pcie_rate_max < 3)? 2'b00 : 2'b01;
        end
        //PD
        if(m_fcpd_x_scale_vc[vc] >8188) begin
          m_fcpd_vc[vc]=m_fcpd_x_scale_vc[vc]/16;
          m_scaled_flow_ctrl_posted_data_scale[vc] = 2'b11;
        end else if (m_fcpd_x_scale_vc[vc] >2047) begin
          m_fcpd_vc[vc]=m_fcpd_x_scale_vc[vc]/4;
          m_scaled_flow_ctrl_posted_data_scale[vc] = 2'b10;
        end else begin
          m_fcpd_vc[vc]=m_fcpd_x_scale_vc[vc]/1;
          m_scaled_flow_ctrl_posted_data_scale[vc] = (i_cfg.strap_pcie_rate_max < 3)? 2'b00 : 2'b01;
        end

        //NPH
        if(m_fcnph_x_scale_vc[vc] >508) begin
          m_fcnph_vc[vc]=m_fcnph_x_scale_vc[vc]/16;
          m_scaled_flow_ctrl_non_posted_hdr_scale[vc] = 2'b11;
        end else if (m_fcnph_x_scale_vc[vc] >127) begin
          m_fcnph_vc[vc]=m_fcnph_x_scale_vc[vc]/4;
          m_scaled_flow_ctrl_non_posted_hdr_scale[vc] = 2'b10;
        end else begin
          m_fcnph_vc[vc]=m_fcnph_x_scale_vc[vc]/1;
          m_scaled_flow_ctrl_non_posted_hdr_scale[vc] = (i_cfg.strap_pcie_rate_max < 3)? 2'b00 : 2'b01;
        end
        //NPD
        if(m_fcnpd_x_scale_vc[vc] >8188) begin
          m_fcnpd_vc[vc]=m_fcnpd_x_scale_vc[vc]/16;
          m_scaled_flow_ctrl_non_posted_data_scale[vc] = 2'b11;
        end else if (m_fcnpd_x_scale_vc[vc] >2047) begin
          m_fcnpd_vc[vc]=m_fcnpd_x_scale_vc[vc]/4;
          m_scaled_flow_ctrl_non_posted_data_scale[vc] = 2'b10;
        end else begin
          m_fcnpd_vc[vc]=m_fcnpd_x_scale_vc[vc]/1;
          m_scaled_flow_ctrl_non_posted_data_scale[vc] = (i_cfg.strap_pcie_rate_max < 3)? 2'b00 : 2'b01;
        end
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcph_x_scale_vc[%0d]=%0d",vc,m_fcph_x_scale_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcpd_x_scale_vc[%0d]=%0d",vc,m_fcpd_x_scale_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcnph_x_scale_vc[%0d]=%0d",vc,m_fcnph_x_scale_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcnpd_x_scale_vc[%0d]=%0d",vc,m_fcnpd_x_scale_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcph_vc[%0d]=%0d",vc,m_fcph_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcpd_vc[%0d]=%0d",vc,m_fcpd_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcnph_vc[%0d]=%0d",vc,m_fcnph_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fcnpd_vc[%0d]=%0d",vc,m_fcnpd_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_posted_hdr_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_posted_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_posted_data_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_posted_data_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_non_posted_hdr_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_non_posted_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_non_posted_data_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_non_posted_data_scale[vc]),UVM_LOW);
       end
      end //}

      //Completion
      if((i_cfg.scenario != null) && i_cfg.scenario.is_flit_mode()) begin//{
       for(int vc=0; vc<i_cfg.k_num_vcs; vc++) begin
        m_fccplh_vc[vc] = 0;
        m_fccpld_vc[vc] = 0;
        m_scaled_flow_ctrl_cpl_hdr_scale[vc]= (i_cfg.k_num_vcs==1) ? 1: 0;
        m_scaled_flow_ctrl_cpl_data_scale[vc]= (i_cfg.k_num_vcs==1) ? 1: 0;
        m_fccplh_x_scale_vc[vc] = 0;
        m_fccpld_x_scale_vc[vc] = 0;
        m_shared_fccplh_vc[vc] = 0;
        m_shared_fccpld_vc[vc] = 0;
        m_shared_scaled_flow_ctrl_cpl_hdr_scale[vc]= 0;
        m_shared_scaled_flow_ctrl_cpl_data_scale[vc]= 0;
        m_shared_fccplh_x_scale_vc[vc] = 0;
        m_shared_fccpld_x_scale_vc[vc] = 0;
        m_total_scaled_flow_ctrl_cpl_hdr_scale=m_shared_scaled_flow_ctrl_cpl_hdr_scale[0];
        m_total_scaled_flow_ctrl_cpl_data_scale=m_shared_scaled_flow_ctrl_cpl_data_scale[0];
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fccplh_vc[%0d]=%0d",vc,m_fccplh_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fccpld_vc[%0d]=%0d",vc,m_fccpld_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_cpl_hdr_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_cpl_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_cpl_data_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_cpl_data_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_fccplh_vc[%0d]=%0d",vc,m_shared_fccplh_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_fccpld_vc[%0d]=%0d",vc,m_shared_fccpld_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_scaled_flow_ctrl_cpl_hdr_scale[%0d]=%0d",vc,m_shared_scaled_flow_ctrl_cpl_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_shared_scaled_flow_ctrl_cpl_data_scale[%0d]=%0d",vc,m_shared_scaled_flow_ctrl_cpl_data_scale[vc]),UVM_LOW);
       end
      end else begin //}{ NFM
       for(int vc=0; vc<i_cfg.k_num_vcs; vc++) begin
        m_fccplh_vc[vc] = 0;
        m_fccpld_vc[vc] = 0;
        m_scaled_flow_ctrl_cpl_hdr_scale[vc]= (i_cfg.strap_pcie_rate_max >= 3) ? 1: 0;
        m_scaled_flow_ctrl_cpl_data_scale[vc]= (i_cfg.strap_pcie_rate_max >= 3) ? 1: 0;
        m_fccplh_x_scale_vc[vc] = 0;
        m_fccpld_x_scale_vc[vc] = 0;
        m_shared_fccplh_vc[vc] = 0;
        m_shared_fccpld_vc[vc] = 0;
        m_shared_scaled_flow_ctrl_cpl_hdr_scale[vc]= 0;
        m_shared_scaled_flow_ctrl_cpl_data_scale[vc]= 0;
        m_shared_fccplh_x_scale_vc[vc] = 0;
        m_shared_fccpld_x_scale_vc[vc] = 0;
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fccplh_vc[%0d]=%0d",vc,m_fccplh_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_fccpld_vc[%0d]=%0d",vc,m_fccpld_vc[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_cpl_hdr_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_cpl_hdr_scale[vc]),UVM_LOW);
        `uvm_info("DEFAULT_CRED_INIT",$psprintf("m_scaled_flow_ctrl_cpl_data_scale[%0d]=%0d",vc,m_scaled_flow_ctrl_cpl_data_scale[vc]),UVM_LOW);
       end
      end //}
    end else if(((all_vc_zero_shared_cred_dut && 
                  ((m_port_type == CDN_HPA_PCIE_DSP && i_cfg.strap_is_rp) || (m_port_type == CDN_HPA_PCIE_USP && !i_cfg.strap_is_rp))
                 ) ||
                 (all_vc_zero_shared_cred_vip && 
                  ((m_port_type == CDN_HPA_PCIE_USP && i_cfg.strap_is_rp) || (m_port_type == CDN_HPA_PCIE_DSP && !i_cfg.strap_is_rp))
                 )
                ) && 
                i_cfg.k_num_vcs>1 &&
                (i_cfg.scenario != null) &&
                i_cfg.scenario.is_flit_mode()
               ) begin //} { //DUT || VIP initialized with zero credit for all vcs, provided k_num_vcs>1 & FM negotiated
      `uvm_info("ALL_VC_ZERO_SHARED_CREDIT_OVERRIDE",$psprintf("Overriding the %0s randomized credits with zero shared credits for all VCs. FC_TYPE=%0b",((m_port_type == CDN_HPA_PCIE_DSP && i_cfg.strap_is_rp) || (m_port_type == CDN_HPA_PCIE_USP && !i_cfg.strap_is_rp)) ? "DUT" : "VIP",all_vc_zero_shared_cred_fc_type),UVM_LOW);

      if(all_vc_zero_shared_cred_fc_type[0]==1 /*PH*/) begin //{
        foreach(m_shared_fcph_vc[vc]) begin//{
          m_shared_fcph_vc[vc]=0;
          m_shared_fcph_x_scale_vc[vc] =0;
          m_shared_scaled_flow_ctrl_posted_hdr_scale[vc]= 1; //Zero scale
          inf_zero_merged_shared_fcph[vc]=ZERO_CREDIT;
        end //}
      end //}

      if(all_vc_zero_shared_cred_fc_type[1]==1 /*PD*/) begin //{
        foreach(m_shared_fcpd_vc[vc]) begin//{
          m_shared_fcpd_vc[vc]=0;
          m_shared_fcpd_x_scale_vc[vc] =0;
          m_shared_scaled_flow_ctrl_posted_data_scale[vc]= 1; //Zero scale
          inf_zero_merged_shared_fcpd[vc]=ZERO_CREDIT;
        end //}
      end //}

      if(all_vc_zero_shared_cred_fc_type[2]==1 /*==NPH*/) begin //{
        foreach(m_shared_fcnph_vc[vc]) begin//{
          m_shared_fcnph_vc[vc]=0;
          m_shared_fcnph_x_scale_vc[vc] =0;
          m_shared_scaled_flow_ctrl_non_posted_hdr_scale[vc]= 1; //Zero scale
          inf_zero_merged_shared_fcnph[vc]=ZERO_CREDIT;
        end //}
      end //}

      if(all_vc_zero_shared_cred_fc_type[3]==1 /*==NPD*/) begin //{
        foreach(m_shared_fcnpd_vc[vc]) begin//{
          m_shared_fcnpd_vc[vc]=0;
          m_shared_fcnpd_x_scale_vc[vc] =0;
          m_shared_scaled_flow_ctrl_non_posted_data_scale[vc]= 1; //Zero scale
          inf_zero_merged_shared_fcnpd[vc]=ZERO_CREDIT;
        end //}
      end //}

      if(all_vc_zero_shared_cred_fc_type[4]==1 /*==CPLH*/) begin //{
        foreach(m_shared_fccplh_vc[vc]) begin//{
          m_shared_fccplh_vc[vc]=0;
          m_shared_fccplh_x_scale_vc[vc] =0;
          m_shared_scaled_flow_ctrl_cpl_hdr_scale[vc]= 1; //Zero scale
          inf_zero_merged_shared_fccplh[vc]=ZERO_CREDIT;
        end //}
      end //}

      if(all_vc_zero_shared_cred_fc_type[5]==1 /*==CPLD*/) begin //{
        foreach(m_shared_fccpld_vc[vc]) begin//{
          m_shared_fccpld_vc[vc]=0;
          m_shared_fccpld_x_scale_vc[vc] =0;
          m_shared_scaled_flow_ctrl_cpl_data_scale[vc]= 1; //Zero scale
          inf_zero_merged_shared_fccpld[vc]=ZERO_CREDIT;
        end //}
      end //}
    end//}

    foreach(m_shared_fcph_vc[i]) begin
      m_shared_fcph_vc_sum   += m_shared_fcph_vc[i];
      m_shared_fcpd_vc_sum   += m_shared_fcpd_vc[i];
      m_shared_fcnph_vc_sum  += m_shared_fcnph_vc[i];
      m_shared_fcnpd_vc_sum  += m_shared_fcnpd_vc[i];
      m_shared_fccplh_vc_sum += m_shared_fccplh_vc[i];
      m_shared_fccpld_vc_sum += m_shared_fccpld_vc[i];
    end
    if ($value$plusargs("LTI_BYPASS=%0d",lti_bypass)) begin
      `uvm_info("LTI_BYPASS", $psprintf("LTI_BYPASS=%0d",lti_bypass), UVM_DEBUG);
      lti_disable_xlation_for_msg_conversion = 1;
    end
    else begin
      lti_bypass = 0;
    end
    //  lti_bypass = 1;
    
    if ($value$plusargs("LTI_FAST_FLUSH=%0d",lti_link_down_fast_flush_mode)) begin
      `uvm_info("LTI_FAST_FLUSH", $psprintf("LTI link down fast flush mode set to %0d",lti_link_down_fast_flush_mode), UVM_DEBUG);
      tl2hls_linkdown_reset_beh = lti_link_down_fast_flush_mode ;  
    end

 endfunction

  function void randomize_ide_cfg();
   `uvm_info(get_type_name(), $psprintf("randomize_ide_cfg PCIE IDE CFG  %0s",get_type_name()), UVM_NONE);
    foreach(tc_vc_map[tc]) begin
      if(tc_vc_map[tc] != 9'h1FF) begin
        ide_cfg.m_tc_en[tc] = 1;
      end
    end

    ide_cfg.is_cxl_ide = 0;
    if (!(ide_cfg.randomize()))`uvm_fatal(get_full_name(), "Unable to randomize PCIE_IDE Config")

   `uvm_info(get_full_name(), $psprintf("DEBUG_IDE PCIE IDE cfg = %0s", ide_cfg.sprint()), UVM_DEBUG)
    if(m_build_sel_stream) ide_cfg.build_ide_selective_stream_config();
   `uvm_info(get_full_name(), $psprintf("DEBUG_IDE IDE cfg = %0s", ide_cfg.sprint()), UVM_DEBUG)

    foreach(ide_cfg.m_ide_selective_stream_config[i]) begin
     `uvm_info(get_full_name(), $psprintf("DEBUG_IDE IDE selective stream ID %0d cfg = %0s", i, ide_cfg.m_ide_selective_stream_config[i].sprint()), UVM_DEBUG)
      foreach(ide_cfg.m_ide_selective_stream_config[i].m_addr_association_block[j])
       `uvm_info(get_full_name(), $psprintf("DEBUG_IDE IDE selective stream %0d, addr association block %0d cfg = %0s", i, j, ide_cfg.m_ide_selective_stream_config[i].m_addr_association_block[j].sprint()), UVM_DEBUG)
    end
  endfunction : randomize_ide_cfg

  function void randomize_tdisp_cfg();
   `uvm_info(get_type_name(),"Randomizing TDISP config object",UVM_DEBUG);
    if(!tdisp_cfg.randomize()) `uvm_fatal(get_type_name(),"Unable to randomize TDISP config");
   `uvm_info(get_type_name(),$sformatf("tdisp_cfg:\n %0s",tdisp_cfg.sprint()),UVM_DEBUG);
  endfunction : randomize_tdisp_cfg

  function void pf_cap_linked_list();

      for (int i=0; i<loop_cnt_pf; i++) begin
          if(i==0) begin
              `uvm_info(get_type_name(), $psprintf(" pf_cap_linked_list :: Pushing in PF[%0d] capabilities in reg linked list", i ), UVM_LOW)
	      //I_pcie_base capability - should always present
              pf_config[i].m_cap_pci_compatible_config_regs = new();
              pf_config[i].m_cap_pci_compatible_config_regs.cap_addr         = 'h0;
              pf_config[i].m_cap_pci_compatible_config_regs.is_cap_present   = 1'b1;
              pf_config[i].m_cap_pci_compatible_config_regs.is_cap_enable    = 1'b1;
              pf_config[i].m_cap_pci_compatible_config_regs.cap_start_addr   = 'h0;
	      pf_config[i].m_cap_pci_compatible_config_regs.cap_end_addr     = 'h3C;
              pf_config[i].m_cap_pci_compatible_config_regs.next_cap_addr    = 'h80;
              pf_config[i].m_cap_pci_compatible_config_regs.is_usp_specific  = 'h1;
              pf_config[i].m_cap_pci_compatible_config_regs.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_pci_compatible_config_regs);

	      // PCI Power Management Capability Structure
              pf_config[i].m_cap_pci_pm_ap                  = new();
              pf_config[i].m_cap_pci_pm_ap.cap_addr         = 'h80;
              pf_config[i].m_cap_pci_pm_ap.is_cap_present   = 1'b1;
              pf_config[i].m_cap_pci_pm_ap.is_cap_enable    = 1'b1;
              pf_config[i].m_cap_pci_pm_ap.cap_start_addr   = 'h80;
	      pf_config[i].m_cap_pci_pm_ap.cap_end_addr     = 'h84;
	      //if(i_cfg.k_vpd_enable)
              //pf_config[i].m_cap_pci_pm_ap.next_cap_addr  = 'h88;
	      if(i_cfg.k_msi_enable)
              pf_config[i].m_cap_pci_pm_ap.next_cap_addr    = 'h90;
	      else if(i_cfg.k_msix_enable) //TODO : why cecking only 3 k_wire, cant we check all k_wires and assign add of last cap
              pf_config[i].m_cap_pci_pm_ap.next_cap_addr    = 'hB0;
	      else
              pf_config[i].m_cap_pci_pm_ap.next_cap_addr    = 'hC0;
              pf_config[i].m_cap_pci_pm_ap.is_usp_specific  = 'h1;
              pf_config[i].m_cap_pci_pm_ap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_pci_pm_ap);

	      // TODO : VPD Capability Structures is not present in dev_cfg

	      // MSI Capability Structures
              pf_config[i].m_cap_msi_cap                    = new();
              pf_config[i].m_cap_msi_cap.cap_addr         = 'h90;
              pf_config[i].m_cap_msi_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_msi_enable) //Make it 1 only wh  en capability is enabled
              pf_config[i].m_cap_msi_cap.is_cap_enable    = 1'b1;
              pf_config[i].m_cap_msi_cap.cap_start_addr   = 'h90;
	      pf_config[i].m_cap_msi_cap.cap_end_addr     = 'h90 +'h10;
	      if(i_cfg.k_msix_enable)
              pf_config[i].m_cap_msi_cap.next_cap_addr    = 'hB0;
	      else
              pf_config[i].m_cap_msi_cap.next_cap_addr    = 'hC0;
              pf_config[i].m_cap_msi_cap.is_usp_specific  = 'h1;
              pf_config[i].m_cap_msi_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_msi_cap);

              // MSI-X Capability and Table Structure
              pf_config[i].m_cap_msix_cap                   = new();
              pf_config[i].m_cap_msix_cap.cap_addr         = 'hB0;
              pf_config[i].m_cap_msix_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_msix_enable)
              pf_config[i].m_cap_msix_cap.is_cap_enable    = 1'b1;
              pf_config[i].m_cap_msix_cap.cap_start_addr   = 'hB0;
	      pf_config[i].m_cap_msix_cap.cap_end_addr     = 'hB0 +'h8;
              pf_config[i].m_cap_msix_cap.next_cap_addr    = 'hC0;
              pf_config[i].m_cap_msix_cap.is_usp_specific  = 'h1;
              pf_config[i].m_cap_msix_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_msix_cap);

	      //------------------------------------------------------------------------
              // PCI Express Capability Structure
              //------------------------------------------------------------------------
              pf_config[i].m_cap_pcie_exp_cap               = new();
              pf_config[i].m_cap_pcie_exp_cap.cap_addr         = 'hC0;
              pf_config[i].m_cap_pcie_exp_cap.is_cap_present   = 1'b1;
              pf_config[i].m_cap_pcie_exp_cap.is_cap_enable    = 1'b1;
              pf_config[i].m_cap_pcie_exp_cap.cap_start_addr   = 'hC0;
	      pf_config[i].m_cap_pcie_exp_cap.cap_end_addr     = 'hC0 +'h30;
              pf_config[i].m_cap_pcie_exp_cap.next_cap_addr    = 'h0; // TODO : should it end on'd0????
              pf_config[i].m_cap_pcie_exp_cap.is_usp_specific  = 'h1;
              pf_config[i].m_cap_pcie_exp_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_pcie_exp_cap);

              //------------------------------------------------------------------------
              // Advanced Error Reporting Extended Capability
              //------------------------------------------------------------------------
              pf_config[i].m_cap_aer_ext_cap                = new();
              pf_config[i].m_cap_aer_ext_cap.cap_addr       = 'h100;
              pf_config[i].m_cap_aer_ext_cap.is_cap_present = 1'b1;
              pf_config[i].m_cap_aer_ext_cap.is_cap_enable  = 1'b1; //Always present
              pf_config[i].m_cap_aer_ext_cap.cap_start_addr = 'h100;
	      pf_config[i].m_cap_aer_ext_cap.cap_end_addr   = 'h100 +'h3C; // TODO : spec defined add upto 'h44 but IPXACT goes till 'h38 , tlp_prelog register is not fully defined
	      //if(!i_cfg.strap_is_rp) begin
	          if(i_cfg.strap_ari_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h140;
	          else if(i_cfg.k_device_serial_num_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h150;
	          else if(i_cfg.k_power_budgeting_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h160;
	          else if(i_cfg.k_resizable_bar_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h180;
	          else if(i_cfg.k_ltr_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h1B8;
	          else if(i_cfg.k_dpa_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h1C0;
	          else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h200;
	          else if(i_cfg.k_tph_supported)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h274;
	          else if(i_cfg.strap_pcie_rate_max>='d2)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h300;
	          else
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h400;
	     // end else begin //EP mode
	    //      if(i_cfg.k_device_serial_num_enable)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h150;
	    //      else if(i_cfg.k_tph_supported)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h274;
	    //      else if(i_cfg.k_pcie_rate_max>='d3)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h300;
	    //      else if(i_cfg.k_pasid_supported) //TODO: need to recheck
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h440;
	    //      else if(i_cfg.k_num_vcs>1 & i_cfg.k_multi_tc_supp)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h4C0;
	    //      else if(i_cfg.k_l1_pm_substate_enable)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h900;
	    //      else if(i_cfg.k_pcie_rate_max>='d3)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h910;
	    //      else
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h0;
	    //  end//RP mode
              pf_config[i].m_cap_aer_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_aer_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_aer_ext_cap);

              // ARI Extended Capability
              pf_config[i].m_cap_ari_ext_cap                = new();
              pf_config[i].m_cap_ari_ext_cap.cap_addr           = 'h140; //'h140
              pf_config[i].m_cap_ari_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.strap_ari_enable) //Make it 1 only when capability is enabled
              pf_config[i].m_cap_ari_ext_cap.is_cap_enable      = 1'b1;
              pf_config[i].m_cap_ari_ext_cap.cap_start_addr     = 'h140;
	      pf_config[i].m_cap_ari_ext_cap.cap_end_addr       = 'h140 +'h4;
	      if(i_cfg.k_device_serial_num_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h150;
	      else if(i_cfg.k_power_budgeting_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h160;
	      else if(i_cfg.k_resizable_bar_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h180;
	      else if(i_cfg.k_ltr_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h1B8;
	      else if(i_cfg.k_dpa_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h1C0;
	      else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h200;
	      else if(i_cfg.k_tph_supported)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>='d2)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h300;
	      else
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr      = 'h400;
              pf_config[i].m_cap_ari_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_ari_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_ari_ext_cap);

              // Device  serial number Capability
              m_cap_dev_serial_ext_cap.cap_addr           = 'h150; //'h150
              m_cap_dev_serial_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.k_device_serial_num_enable) //Make it 1 only when capability is enabled
              m_cap_dev_serial_ext_cap.is_cap_enable      = 1'b1;
              m_cap_dev_serial_ext_cap.cap_start_addr     = 'h150;
	      m_cap_dev_serial_ext_cap.cap_end_addr       = 'h150 +'h8;

	      if(i_cfg.k_power_budgeting_enable)
              m_cap_dev_serial_ext_cap.next_cap_addr      = 'h160;
	      else if(i_cfg.k_resizable_bar_enable)
              m_cap_dev_serial_ext_cap.next_cap_addr      = 'h180;
	      else if(i_cfg.k_ltr_enable)
              m_cap_dev_serial_ext_cap.next_cap_addr      = 'h1B8;
	      else if(i_cfg.k_dpa_enable)
              m_cap_dev_serial_ext_cap.next_cap_addr      = 'h1C0;
	      else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              m_cap_dev_serial_ext_cap.next_cap_addr      = 'h200;
	      else if(i_cfg.k_tph_supported)
              m_cap_dev_serial_ext_cap.next_cap_addr      = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>='d2)
              m_cap_dev_serial_ext_cap.next_cap_addr      = 'h300;
	      else
              m_cap_dev_serial_ext_cap.next_cap_addr      = 'h400;
              m_cap_dev_serial_ext_cap.is_usp_specific    = 'h1;
              m_cap_dev_serial_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(m_cap_dev_serial_ext_cap);

              // Power Budgeting Extended Capability
              m_cap_pwr_budget_ext_cap.cap_addr           = 'h160; //'h160
              m_cap_pwr_budget_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.k_power_budgeting_enable)
              m_cap_pwr_budget_ext_cap.is_cap_enable      = 1'b1;
              m_cap_pwr_budget_ext_cap.cap_start_addr     = 'h160;
	      m_cap_pwr_budget_ext_cap.cap_end_addr       = 'h160 +'hC;

	      if(i_cfg.k_resizable_bar_enable)
              m_cap_pwr_budget_ext_cap.next_cap_addr      = 'h180;
	      else if(i_cfg.k_ltr_enable)
              m_cap_pwr_budget_ext_cap.next_cap_addr      = 'h1B8;
	      else if(i_cfg.k_dpa_enable)
              m_cap_pwr_budget_ext_cap.next_cap_addr      = 'h1C0;
	      else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              m_cap_pwr_budget_ext_cap.next_cap_addr      = 'h200;
	      else if(i_cfg.k_tph_supported)
              m_cap_pwr_budget_ext_cap.next_cap_addr      = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>='d2)
              m_cap_pwr_budget_ext_cap.next_cap_addr      = 'h300;
	      else
              m_cap_pwr_budget_ext_cap.next_cap_addr      = 'h400;
              m_cap_pwr_budget_ext_cap.is_usp_specific    = 'h1;
              m_cap_pwr_budget_ext_cap.is_dsp_specific    = 'h0;
              reg_linklist_q.push_back(m_cap_pwr_budget_ext_cap);

	      // Resizable BAR Extended Capability
              pf_config[i].m_cap_resize_bar_ext_cap         = new();
	      pf_config[i].m_cap_resize_bar_ext_cap.cap_addr           = 'h180; //'h180
              pf_config[i].m_cap_resize_bar_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.k_resizable_bar_enable)
              pf_config[i].m_cap_resize_bar_ext_cap.is_cap_enable      = 1'b1;
              pf_config[i].m_cap_resize_bar_ext_cap.cap_start_addr     = 'h180;
	      pf_config[i].m_cap_resize_bar_ext_cap.cap_end_addr       = 'h180 +'h10;
              //Next cap pointer
	      if(i_cfg.k_ltr_enable)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr      = 'h1B8;
	      else if(i_cfg.k_dpa_enable)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr      = 'h1C0;
	      else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr      = 'h200;
	      else if(i_cfg.k_tph_supported)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr      = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>='d2)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr      = 'h300;
	      else
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr      = 'h400;
              pf_config[i].m_cap_resize_bar_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_resize_bar_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_resize_bar_ext_cap);

              // Latency Tolerance Reporting (LTR) Extended Capability
	      m_cap_ltr_ext_cap.cap_addr           = 'h1B8; //'h1B8
              m_cap_ltr_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.k_ltr_enable)
              m_cap_ltr_ext_cap.is_cap_enable      = 1'b1;
              m_cap_ltr_ext_cap.cap_start_addr     = 'h1B8;
	      m_cap_ltr_ext_cap.cap_end_addr       = 'h1B8 +'h4;
              //Next cap pointer
	      if(i_cfg.k_dpa_enable)
              m_cap_ltr_ext_cap.next_cap_addr      = 'h1C0;
	      else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              m_cap_ltr_ext_cap.next_cap_addr      = 'h200;
	      else if(i_cfg.k_tph_supported)
              m_cap_ltr_ext_cap.next_cap_addr      = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>=    'd2)
              m_cap_ltr_ext_cap.next_cap_addr      = 'h300;
	      else
              m_cap_ltr_ext_cap.next_cap_addr      = 'h400;
              m_cap_ltr_ext_cap.is_usp_specific    = 'h1;
              m_cap_ltr_ext_cap.is_dsp_specific    = 'h0;
              reg_linklist_q.push_back(m_cap_ltr_ext_cap);

              //Dynamic Power Allocation Extended Capability (DPA Capability)
	      m_cap_dpa_ext_cap.cap_addr       = 'h1C0;
              m_cap_dpa_ext_cap.is_cap_present = 1'b1;
	      if(i_cfg.k_dpa_enable)
              m_cap_dpa_ext_cap.is_cap_enable  = 1'b1;
              m_cap_dpa_ext_cap.cap_start_addr = 'h1C0;
	      m_cap_dpa_ext_cap.cap_end_addr   = 'h1C0 +'h10;
              //Next cap pointer
	      if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              m_cap_dpa_ext_cap.next_cap_addr  = 'h200;
	      else if(i_cfg.k_tph_supported)
              m_cap_dpa_ext_cap.next_cap_addr  = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>='d2)
              m_cap_dpa_ext_cap.next_cap_addr  = 'h300;
	      else
              m_cap_dpa_ext_cap.next_cap_addr  = 'h400;
              m_cap_dpa_ext_cap.is_usp_specific    = 'h1;
              m_cap_dpa_ext_cap.is_dsp_specific    = 'h0; //Not for RP ????
              reg_linklist_q.push_back(m_cap_dpa_ext_cap);

              // SR-IOV Capabilities Register
              pf_config[i].m_cap_sriov_cap                  = new();
	      pf_config[i].m_cap_sriov_cap.cap_addr       = 'h200; //'h200
              pf_config[i].m_cap_sriov_cap.is_cap_present = 1'b1;
	      if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              pf_config[i].m_cap_sriov_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_sriov_cap.cap_start_addr = 'h200;
	      pf_config[i].m_cap_sriov_cap.cap_end_addr   = 'h200 +'h3C; //TODO : spec defined add upto 'h3c but IPXACT goes till 'h24 , VF_bar [1-5] registers are not defined
              //Next cap pointer
	      if(i_cfg.k_tph_supported)
              pf_config[i].m_cap_sriov_cap.next_cap_addr  = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>='d2)
              pf_config[i].m_cap_sriov_cap.next_cap_addr  = 'h300;
	      else
              pf_config[i].m_cap_sriov_cap.next_cap_addr  = 'h400;
              pf_config[i].m_cap_sriov_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_sriov_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_sriov_cap);

              // TPH Requester Extended Capability
              pf_config[i].m_cap_tph_ext_cap                = new();
	      pf_config[i].m_cap_tph_ext_cap.cap_addr           = 'h274; //'h274
              pf_config[i].m_cap_tph_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.k_tph_supported)
              pf_config[i].m_cap_tph_ext_cap.is_cap_enable      = 1'b1;
              pf_config[i].m_cap_tph_ext_cap.cap_start_addr     = 'h274;
	      pf_config[i].m_cap_tph_ext_cap.cap_end_addr       = 'h274 +'hC;
              //Next cap pointer
	      if(i_cfg.strap_pcie_rate_max>='d2)
              pf_config[i].m_cap_tph_ext_cap.next_cap_addr      = 'h300;
	      else
              pf_config[i].m_cap_tph_ext_cap.next_cap_addr      = 'h400;
              pf_config[i].m_cap_tph_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_tph_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_tph_ext_cap);

              // Secondary PCI Express Extended Capability
	      m_cap_sec_pcie_ext_cap.cap_addr           = 'h300; //'h300
              m_cap_sec_pcie_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.strap_pcie_rate_max>='d2)
              m_cap_sec_pcie_ext_cap.is_cap_enable      = 1'b1;
              m_cap_sec_pcie_ext_cap.cap_start_addr     = 'h300;
	      m_cap_sec_pcie_ext_cap.cap_end_addr       = 'h300 +'h48; // TODO: need to cross check
              //Next cap pointer
              m_cap_sec_pcie_ext_cap.next_cap_addr      = 'h400;
              m_cap_sec_pcie_ext_cap.is_usp_specific    = 'h1;
              m_cap_sec_pcie_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(m_cap_sec_pcie_ext_cap);

              // VENDOR_SPEC_CAP_REG_ADDR Capability  ??????

              // PASID Extended Capability Structure
              pf_config[i].m_cap_pasid_ext_cap              = new();
	      pf_config[i].m_cap_pasid_ext_cap.cap_addr           = 'h440; //'h440
              pf_config[i].m_cap_pasid_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.k_pasid_supported)
              pf_config[i].m_cap_pasid_ext_cap.is_cap_enable      = 1'b1;
              pf_config[i].m_cap_pasid_ext_cap.cap_start_addr     = 'h440;
	      pf_config[i].m_cap_pasid_ext_cap.cap_end_addr       = 'h440 +'h4;
              //Next cap pointer
	      if(i_cfg.k_num_vcs>1 & i_cfg.k_multi_tc_supp)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'h4C0;
	      else if(i_cfg.k_ats_enable)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'h5C0;
	      else if(i_cfg.k_l1_pm_substate_enable)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'h900;
	      else if(i_cfg.strap_pcie_rate_max>='d3)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'h910;
	      else if(i_cfg.k_ptm_enable)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'hA20;
	      else if(i_cfg.k_npem_enable)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'hA30;
	      else if(i_cfg.k_alt_prot_neg_support)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'hA90;
	      else if(i_cfg.k_ide_supported)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'hB70;
	      else
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr      = 'h0;
              pf_config[i].m_cap_pasid_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_pasid_ext_cap.is_dsp_specific    = 'h1; //spec says : For Root Ports, support and control is outside the scope of this specification ????
              reg_linklist_q.push_back(pf_config[i].m_cap_pasid_ext_cap);

              // Virtual Channel Extended Capability
	      m_cap_vc_ext_cap.cap_addr       = 'h4C0; //'h4C0
              m_cap_vc_ext_cap.is_cap_present = 1'b1;
	      if(i_cfg.k_num_vcs>1 & i_cfg.k_multi_tc_supp)
              m_cap_vc_ext_cap.is_cap_enable  = 1'b1;
              m_cap_vc_ext_cap.cap_start_addr = 'h4C0;
	      m_cap_vc_ext_cap.cap_end_addr   = 'h4C0 +'h18;
              //Next cap pointer
	      if(i_cfg.k_ats_enable)
              m_cap_vc_ext_cap.next_cap_addr  = 'h5C0;
	      else if(i_cfg.k_l1_pm_substate_enable)
              m_cap_vc_ext_cap.next_cap_addr  = 'h900;
	      else if(i_cfg.strap_pcie_rate_max>='d3)
              m_cap_vc_ext_cap.next_cap_addr  = 'h910;
	      else if(i_cfg.k_ptm_enable)
              m_cap_vc_ext_cap.next_cap_addr  = 'hA20;
	      else if(i_cfg.k_npem_enable)
              m_cap_vc_ext_cap.next_cap_addr  = 'hA30;
	      else if(i_cfg.k_alt_prot_neg_support)
              m_cap_vc_ext_cap.next_cap_addr  = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              m_cap_vc_ext_cap.next_cap_addr  = 'hA90;
	      else if(i_cfg.k_ide_supported)
              m_cap_vc_ext_cap.next_cap_addr  = 'hB70;
	      else
              m_cap_vc_ext_cap.next_cap_addr  = 'h0;
              m_cap_vc_ext_cap.is_usp_specific    = 'h0;
              m_cap_vc_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(m_cap_vc_ext_cap);

	      // ATS Extended Capability
              pf_config[i].m_cap_ats_cap                    = new();
	      pf_config[i].m_cap_ats_cap.cap_addr       = 'h5C0; //'h540
              pf_config[i].m_cap_ats_cap.is_cap_present = 1'b1;
	      if(i_cfg.k_ats_enable)
              pf_config[i].m_cap_ats_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_ats_cap.cap_start_addr = 'h5C0;
	      pf_config[i].m_cap_ats_cap.cap_end_addr   = 'h5C0 +'h4;
              //Next cap pointer
              pf_config[i].m_cap_ats_cap.next_cap_addr  = 'h640;
              pf_config[i].m_cap_ats_cap.is_usp_specific   = 'h1;
              pf_config[i].m_cap_ats_cap.is_dsp_specific   = 'h0;
              reg_linklist_q.push_back(pf_config[i].m_cap_ats_cap);

	      // ATS PR Extended Capability
              pf_config[i].m_cap_ats_pr_cap                 = new();
	      pf_config[i].m_cap_ats_pr_cap.cap_addr          = 'h640; //'h640
              pf_config[i].m_cap_ats_pr_cap.is_cap_present    = 1'b1;
	      if(i_cfg.k_ats_enable)
              pf_config[i].m_cap_ats_pr_cap.is_cap_enable     = 1'b1;
              pf_config[i].m_cap_ats_pr_cap.cap_start_addr    = 'h640;
	      pf_config[i].m_cap_ats_pr_cap.cap_end_addr      = 'h640 +'hC;
              //Next cap pointer
	      if(i_cfg.k_l1_pm_substate_enable)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr     = 'h900;
	      else if(i_cfg.strap_pcie_rate_max>='d3)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr     = 'h910;
	      else if(i_cfg.k_ptm_enable)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr     = 'hA20;
	      else if(i_cfg.k_npem_enable)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr     = 'hA30;
	      else if(i_cfg.k_alt_prot_neg_support)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr     = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr     = 'hA90;
	      else if(i_cfg.k_ide_supported)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr     = 'hB70;
	      else
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr     = 'h0;
              pf_config[i].m_cap_ats_pr_cap.is_usp_specific   = 'h1;
              pf_config[i].m_cap_ats_pr_cap.is_dsp_specific   = 'h0;
              reg_linklist_q.push_back(pf_config[i].m_cap_ats_pr_cap);

        //UCIE_DVSEC_CAPABILITY
       `ifdef UCIE
	        m_cap_ucie_dvsec_cap.cap_addr         = 'h700; 
          m_cap_ucie_dvsec_cap.is_cap_present   = 1'b1;
          m_cap_ucie_dvsec_cap.is_cap_enable    = 1'b1;
          m_cap_ucie_dvsec_cap.cap_start_addr   = 'h700;
	        m_cap_ucie_dvsec_cap.cap_end_addr     = 'h700 +'h4C; 
          m_cap_ucie_dvsec_cap.next_cap_addr    = 'h910;
          m_cap_ucie_dvsec_cap.is_usp_specific  = 'h1;
          m_cap_ucie_dvsec_cap.is_dsp_specific  = 'h1;
          reg_linklist_q.push_back(m_cap_ucie_dvsec_cap);

          if(i_cfg.strap_is_rp) begin //MSI CAP in UCIe can be accessed in RP only
	          m_cap_ucie_dvsec_msi_cap.cap_addr         = 'h800; 
            m_cap_ucie_dvsec_msi_cap.is_cap_present   = 1'b1;
            m_cap_ucie_dvsec_msi_cap.is_cap_enable    = 1'b1;
            m_cap_ucie_dvsec_msi_cap.cap_start_addr   = 'h800;
	          m_cap_ucie_dvsec_msi_cap.cap_end_addr     = 'h800 +'h14; 
            m_cap_ucie_dvsec_msi_cap.next_cap_addr    = 'h910;
            m_cap_ucie_dvsec_msi_cap.is_usp_specific  = 'h1;
            m_cap_ucie_dvsec_msi_cap.is_dsp_specific  = 'h1;
            reg_linklist_q.push_back(m_cap_ucie_dvsec_msi_cap);
          end
       `endif       

        `ifdef IDE
	      m_cap_ide_ext_cap.cap_addr       = 'hB70; //'h540
        m_cap_ide_ext_cap.is_cap_present = 1'b1;
	      if(i_cfg.k_ide_supported)
          m_cap_ide_ext_cap.is_cap_enable  = 1'b1;
        m_cap_ide_ext_cap.cap_start_addr = 'hB70;
	      m_cap_ide_ext_cap.cap_end_addr   = 'hE00;
        //Next cap pointer
        m_cap_ide_ext_cap.next_cap_addr  = 'hE00;
        m_cap_ide_ext_cap.is_usp_specific   = 'h0;
        m_cap_ide_ext_cap.is_dsp_specific   = 'h0;
        reg_linklist_q.push_back(m_cap_ide_ext_cap);
        `endif

              // L1 PM Substates Extended Capability
	      m_cap_l1_pm_ext_cap.cap_addr       = 'h900; //'h900
              m_cap_l1_pm_ext_cap.is_cap_present = 1'b1;
	      if(i_cfg.k_l1_pm_substate_enable)
              m_cap_l1_pm_ext_cap.is_cap_enable  = 1'b1;
              m_cap_l1_pm_ext_cap.cap_start_addr = 'h900;
	      m_cap_l1_pm_ext_cap.cap_end_addr   = 'h900 +'h10; //TODO :Spec says last addr='h10 but xml says 'hC
              //Next cap pointer
	      if(i_cfg.strap_pcie_rate_max>='d3)
             `ifdef UCIE
                m_cap_l1_pm_ext_cap.next_cap_addr = 'h700;
             `else
                m_cap_l1_pm_ext_cap.next_cap_addr  = 'h910;
             `endif
	      else if(i_cfg.k_ptm_enable)
              m_cap_l1_pm_ext_cap.next_cap_addr  = 'hA20;
	      else if(i_cfg.k_npem_enable)
              m_cap_l1_pm_ext_cap.next_cap_addr  = 'hA30;
	      else if(i_cfg.k_alt_prot_neg_support)
              m_cap_l1_pm_ext_cap.next_cap_addr  = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              m_cap_l1_pm_ext_cap.next_cap_addr  = 'hA90;
	      else if(i_cfg.k_ide_supported)
              m_cap_l1_pm_ext_cap.next_cap_addr  = 'hB70;
	      else
              m_cap_l1_pm_ext_cap.next_cap_addr  = 'h0;
              m_cap_l1_pm_ext_cap.is_usp_specific    = 'h1;
              m_cap_l1_pm_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(m_cap_l1_pm_ext_cap);

              // Data Link Feature Extended Capability
	      m_cap_dl_feature_ext_cap.cap_addr           = 'h910; //'h910
              m_cap_dl_feature_ext_cap.is_cap_present     = 1'b1;
	      //TODO : no need to check this as checki    ng above, if(i_cfg.k_pcie_rate_max>='d3)
              m_cap_dl_feature_ext_cap.is_cap_enable      = 1'b1;
              m_cap_dl_feature_ext_cap.cap_start_addr     = 'h910;
	      m_cap_dl_feature_ext_cap.cap_end_addr       = 'h910 +'h8;
              //Next cap pointer
	      if((i_cfg.strap_pcie_rate_max>='d3) && (i_cfg.k_rx_margining_enable))
              m_cap_dl_feature_ext_cap.next_cap_addr      = 'h920;
              else if(i_cfg.strap_pcie_rate_max>='d3)
              m_cap_dl_feature_ext_cap.next_cap_addr      = 'h9C0;
              else if(i_cfg.k_ptm_enable)
              m_cap_dl_feature_ext_cap.next_cap_addr      = 'hA20;
              else if(i_cfg.k_npem_enable)
              m_cap_dl_feature_ext_cap.next_cap_addr      = 'hA30;
              else if(i_cfg.k_alt_prot_neg_support)
              m_cap_dl_feature_ext_cap.next_cap_addr      = 'hA70;
              else if(i_cfg.k_dmwr_req_support)
              m_cap_dl_feature_ext_cap.next_cap_addr      = 'hA90;
	          else if(i_cfg.k_ide_supported)
              m_cap_dl_feature_ext_cap.next_cap_addr      = 'hB70;
              else
              m_cap_dl_feature_ext_cap.next_cap_addr      = 'h0;
              m_cap_dl_feature_ext_cap.is_usp_specific    = 'h1;
              m_cap_dl_feature_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(m_cap_dl_feature_ext_cap);

              // Lane Margining at the Receiver Extended Capability
	      m_cap_lane_mrgn_ext_cap.cap_addr           = 'h920; //'h920
              m_cap_lane_mrgn_ext_cap.is_cap_present     = 1'b1;
              m_cap_lane_mrgn_ext_cap.is_cap_enable      = 1'b1;
              m_cap_lane_mrgn_ext_cap.cap_start_addr     = 'h920;
	      m_cap_lane_mrgn_ext_cap.cap_end_addr       = 'h920 +'h8; //TODO: IPXACT says 'h8
              //Next cap pointer
              m_cap_lane_mrgn_ext_cap.next_cap_addr      = 'h9C0;
              m_cap_lane_mrgn_ext_cap.is_usp_specific    = 'h1;
              m_cap_lane_mrgn_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(m_cap_lane_mrgn_ext_cap);

              // Physical Layer 16.0 GT/s Extended Capability
	      m_cap_pl_16gt_ext_cap.cap_addr       = 'h9C0; //'h9C0
              m_cap_pl_16gt_ext_cap.is_cap_present = 1'b1;
              m_cap_pl_16gt_ext_cap.is_cap_enable  = 1'b1;
              m_cap_pl_16gt_ext_cap.cap_start_addr = 'h9C0;
	      m_cap_pl_16gt_ext_cap.cap_end_addr   = 'h9C0 +'h3C; //TODO: IPXACT says 'h20
              //Next cap pointe
          if(i_cfg.strap_pcie_rate_max>=4)
              m_cap_pl_16gt_ext_cap.next_cap_addr  = 'hA40;
	      else if(i_cfg.k_ptm_enable)
              m_cap_pl_16gt_ext_cap.next_cap_addr  = 'hA20;
	      else if(i_cfg.k_npem_enable)
              m_cap_pl_16gt_ext_cap.next_cap_addr  = 'hA30;
	      else if(i_cfg.k_alt_prot_neg_support)
              m_cap_pl_16gt_ext_cap.next_cap_addr  = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              m_cap_pl_16gt_ext_cap.next_cap_addr  = 'hA90;
	      else if(i_cfg.k_ide_supported)
              m_cap_pl_16gt_ext_cap.next_cap_addr  = 'hB70;
	      else
              m_cap_pl_16gt_ext_cap.next_cap_addr  = 'h0;
              m_cap_pl_16gt_ext_cap.is_usp_specific    = 'h1;
              m_cap_pl_16gt_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(m_cap_pl_16gt_ext_cap);

              // Precision Time Management Extended Capability
	      m_cap_ptm_ext_cap.cap_addr           = 'hA20; //'hA20
              m_cap_ptm_ext_cap.is_cap_present     = 1'b1;
	      if(i_cfg.k_ptm_enable)
              m_cap_ptm_ext_cap.is_cap_enable      = 1'b1;
              m_cap_ptm_ext_cap.cap_start_addr     = 'hA20;
	      m_cap_ptm_ext_cap.cap_end_addr       = 'hA20 +'h8;
              //Next cap pointer
	      if(i_cfg.k_npem_enable)
              m_cap_ptm_ext_cap.next_cap_addr      = 'hA30;
	      else if(i_cfg.k_alt_prot_neg_support)
              m_cap_ptm_ext_cap.next_cap_addr      = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              m_cap_ptm_ext_cap.next_cap_addr      = 'hA90;
	      else if(i_cfg.k_ide_supported)
              m_cap_ptm_ext_cap.next_cap_addr      = 'hB70;
	      else
              m_cap_ptm_ext_cap.next_cap_addr      = 'h0;
              m_cap_ptm_ext_cap.is_usp_specific    = 'h1;
              m_cap_ptm_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(m_cap_ptm_ext_cap);

              // Native PCIe Enclosure Management Extended Capability (NPEM Extended Capability)
	      m_cap_npeme_ext_cap.cap_addr          = 'hA30; //'hA30
              m_cap_npeme_ext_cap.is_cap_present    = 1'b1;
	      if(i_cfg.k_npem_enable)
              m_cap_npeme_ext_cap.is_cap_enable     = 1'b1;
              m_cap_npeme_ext_cap.cap_start_addr    = 'hA30;
	      m_cap_npeme_ext_cap.cap_end_addr      = 'hA30 +'hC;
              //Next cap pointer
	      if(i_cfg.k_alt_prot_neg_support)
              m_cap_npeme_ext_cap.next_cap_addr     = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              m_cap_npeme_ext_cap.next_cap_addr     = 'hA90;
	      else if(i_cfg.k_ide_supported)
              m_cap_npeme_ext_cap.next_cap_addr     = 'hB70;
	      else
              m_cap_npeme_ext_cap.next_cap_addr     = 'h0;
              m_cap_npeme_ext_cap.is_usp_specific   = 'h1;
              m_cap_npeme_ext_cap.is_dsp_specific   = 'h1;
              reg_linklist_q.push_back(m_cap_npeme_ext_cap);

              // Physical Layer 32.0 GT/s Extended Capability
	      m_cap_pl_32gt_ext_cap.cap_addr         = 'hA40; //'hA30
              m_cap_pl_32gt_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.strap_pcie_rate_max >=4)
              m_cap_pl_32gt_ext_cap.is_cap_enable    = 1'b1;
              m_cap_pl_32gt_ext_cap.cap_start_addr   = 'hA40;
	      m_cap_pl_32gt_ext_cap.cap_end_addr     = 'hA40 +'h3C;
              //Next cap pointer
          if(i_cfg.strap_pcie_rate_max >=5)
	          m_cap_pl_32gt_ext_cap.next_cap_addr    = 'hAA0;
          else if(i_cfg.k_ptm_enable)
              m_cap_pl_32gt_ext_cap.next_cap_addr    = 'hA20;
	      else if(i_cfg.k_npem_enable)
              m_cap_pl_32gt_ext_cap.next_cap_addr    = 'hA30;
          else if(i_cfg.k_alt_prot_neg_support)
              m_cap_pl_32gt_ext_cap.next_cap_addr    = 'hA70;
	      else if(i_cfg.k_dmwr_req_support) 
              m_cap_pl_32gt_ext_cap.next_cap_addr    = 'hA90;
	      else if(i_cfg.k_ide_supported)
              m_cap_pl_32gt_ext_cap.next_cap_addr    = 'hB70;
	      else
              m_cap_pl_32gt_ext_cap.next_cap_addr    = 'h0;
              m_cap_pl_32gt_ext_cap.is_usp_specific  = 'h1;
              m_cap_pl_32gt_ext_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(m_cap_pl_32gt_ext_cap);

              // Alternate Protocol Extended Capability
	      m_cap_apn_ext_cap.cap_addr         = 'hA70; //'hA30
              m_cap_apn_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_alt_prot_neg_support)
              m_cap_apn_ext_cap.is_cap_enable    = 1'b1;
              m_cap_apn_ext_cap.cap_start_addr   = 'hA70;
	      m_cap_apn_ext_cap.cap_end_addr     = 'hA70 +'h10; //TODO : IPXACT saying its 'h14
              //Next cap pointer
	      if(i_cfg.k_dmwr_req_support)
              m_cap_apn_ext_cap.next_cap_addr    = 'hA90;
	      else if(i_cfg.k_ide_supported)
              m_cap_apn_ext_cap.next_cap_addr    = 'hB70;
	      else
              m_cap_apn_ext_cap.next_cap_addr    = 'h0;
              m_cap_apn_ext_cap.is_usp_specific  = 'h1;
              m_cap_apn_ext_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(m_cap_apn_ext_cap);

	      // Device3 Extended Capability
	      m_cap_dev3_ext_cap.cap_addr         = 'hA90; //'hA30
              m_cap_dev3_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_dmwr_req_support)
              m_cap_dev3_ext_cap.is_cap_enable    = 1'b1;
              m_cap_dev3_ext_cap.cap_start_addr   = 'hA90;
	      m_cap_dev3_ext_cap.cap_end_addr     = 'hA90 +'hC; //TODO : IPXACT saying its 'h8
              //Next cap pointer
          if(i_cfg.k_ide_supported)
              m_cap_dev3_ext_cap.next_cap_addr    = 'hB70;
          else
              m_cap_dev3_ext_cap.next_cap_addr    = 'h0;
              m_cap_dev3_ext_cap.is_usp_specific  = 'h1;
              m_cap_dev3_ext_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(m_cap_dev3_ext_cap);

              // Physical Layer 64.0 GT/s Extended Capability
	      m_cap_pl_64gt_ext_cap.cap_addr         = 'hAA0; 
              m_cap_pl_64gt_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.strap_pcie_rate_max >=5)
              m_cap_pl_64gt_ext_cap.is_cap_enable    = 1'b1;
              m_cap_pl_64gt_ext_cap.cap_start_addr   = 'hAA0;
	          m_cap_pl_64gt_ext_cap.cap_end_addr     = 'hAA0 +'h1C;
              //Next cap pointer
              m_cap_pl_64gt_ext_cap.next_cap_addr    = 'hAD0;
              m_cap_pl_64gt_ext_cap.is_usp_specific  = 'h1;
              m_cap_pl_64gt_ext_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(m_cap_pl_64gt_ext_cap);

              //Flit Logging Extended Capability
          m_cap_flit_log_ext_cap.cap_addr         = 'hAD0; 
              m_cap_flit_log_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.strap_pcie_rate_max >=5)
              m_cap_flit_log_ext_cap.is_cap_enable    = 1'b1;
              m_cap_flit_log_ext_cap.cap_start_addr   = 'hAD0;
	          m_cap_flit_log_ext_cap.cap_end_addr     = 'hAD0 +'h38;
              //Next cap pointer
              m_cap_flit_log_ext_cap.next_cap_addr    = 'hB10;    
              m_cap_flit_log_ext_cap.is_usp_specific  = 'h1;
              m_cap_flit_log_ext_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(m_cap_flit_log_ext_cap);      

            //Flit Performance Measurement Extended Capability
          m_cap_flit_perf_measr_ext_cap.cap_addr         = 'hB10; 
              m_cap_flit_perf_measr_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.strap_pcie_rate_max >=5)
              m_cap_flit_perf_measr_ext_cap.is_cap_enable    = 1'b1;
              m_cap_flit_perf_measr_ext_cap.cap_start_addr   = 'hB10;
	          m_cap_flit_perf_measr_ext_cap.cap_end_addr     = 'hB10 +'h20;
              //Next cap pointer
              m_cap_flit_perf_measr_ext_cap.next_cap_addr    = 'hB40;    
              m_cap_flit_perf_measr_ext_cap.is_usp_specific  = 'h1;
              m_cap_flit_perf_measr_ext_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(m_cap_flit_perf_measr_ext_cap);

                //Flit Error Injection Extended Capability
          m_cap_flit_err_inj_ext_cap.cap_addr         = 'hB40; 
              m_cap_flit_err_inj_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.strap_pcie_rate_max >=5)
              m_cap_flit_err_inj_ext_cap.is_cap_enable    = 1'b1;
              m_cap_flit_err_inj_ext_cap.cap_start_addr   = 'hB40;
	      m_cap_flit_err_inj_ext_cap.cap_end_addr     = 'hB40 +'h20;
              //Next cap pointer
          if(i_cfg.k_ptm_enable)
              m_cap_flit_err_inj_ext_cap.next_cap_addr  = 'hA20;
	      else if(i_cfg.k_npem_enable)
              m_cap_flit_err_inj_ext_cap.next_cap_addr  = 'hA30;
          else if(i_cfg.k_alt_prot_neg_support)
              m_cap_flit_err_inj_ext_cap.next_cap_addr    = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)                          
              m_cap_flit_err_inj_ext_cap.next_cap_addr    = 'hA90; 
	      else if(i_cfg.k_ide_supported)
              m_cap_flit_err_inj_ext_cap.next_cap_addr    = 'hB70;
	      else
              m_cap_flit_err_inj_ext_cap.next_cap_addr    = 'h0;
              m_cap_flit_err_inj_ext_cap.is_usp_specific  = 'h1;
              m_cap_flit_err_inj_ext_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(m_cap_flit_err_inj_ext_cap);
 end else begin //pf_num
              //foreach(pf_config[i]) begin
              `uvm_info(get_type_name(), $psprintf("pf_cap_linked_list : PF_%0d reg_linkedlist_done %d", i, reg_linkedlist_done),UVM_LOW)
	      if( (i == pf_index) && !reg_linkedlist_done) begin
              `uvm_info(get_type_name(), $psprintf(" pf_cap_linked_list :: Pushing in PF[%0d] after PF0 in reg linked list", i), UVM_LOW)
	      //I_pcie_base capability - should always present
              //pf_config[i].m_cap_pci_compatible_config_regs = new();
              pf_config[i].m_cap_pci_compatible_config_regs.cap_addr       = 'h0;
              pf_config[i].m_cap_pci_compatible_config_regs.is_cap_present = 1'b1;
              pf_config[i].m_cap_pci_compatible_config_regs.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_pci_compatible_config_regs.cap_start_addr = 'h0;
              pf_config[i].m_cap_pci_compatible_config_regs.cap_end_addr   = 'h3C;
              pf_config[i].m_cap_pci_compatible_config_regs.next_cap_addr  = 'h80;
              pf_config[i].m_cap_pci_compatible_config_regs.is_usp_specific  = 'h1;
              pf_config[i].m_cap_pci_compatible_config_regs.is_dsp_specific  = 'h1;
              pf_config[i].m_cap_pci_compatible_config_regs.reg_num_pf     = i;
              reg_linklist_q.push_back(pf_config[i].m_cap_pci_compatible_config_regs);

              // PCI Power Management Capability Structure
              //pf_config[i].m_cap_pci_pm_ap                  = new();
              pf_config[i].m_cap_pci_pm_ap.cap_addr       = 'h80;
              pf_config[i].m_cap_pci_pm_ap.is_cap_present = 1'b1;
              pf_config[i].m_cap_pci_pm_ap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_pci_pm_ap.cap_start_addr = 'h80;
              pf_config[i].m_cap_pci_pm_ap.cap_end_addr   = 'h84;

              //if(i_cfg.k_vpd_enable)
              //pf_config[i].m_cap_pci_pm_ap.next_cap_addr  = VPD_CAP_REG_ADDR;
              if(i_cfg.k_msi_enable)
              pf_config[i].m_cap_pci_pm_ap.next_cap_addr  = 'h90;
              else if(i_cfg.k_msix_enable) //TODO : why cecking only 3 k_wire, cant we check all k_wires and assign add of last cap
              pf_config[i].m_cap_pci_pm_ap.next_cap_addr  = 'hB0;
              pf_config[i].m_cap_pci_pm_ap.reg_num_pf     = i;
              pf_config[i].m_cap_pci_pm_ap.is_usp_specific  = 'h1;
              pf_config[i].m_cap_pci_pm_ap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_pci_pm_ap);

              // TODO : VPD Capability Structures is not present in dev_cfg

              // MSI Capability Structures
              //pf_config[i].m_cap_msi_cap                    = new();
              pf_config[i].m_cap_msi_cap.cap_addr       = 'h90; //'h90
              pf_config[i].m_cap_msi_cap.is_cap_present = 1'b1;
              if(i_cfg.k_msi_enable) //Make it 1 only when capability is enabled
              pf_config[i].m_cap_msi_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_msi_cap.cap_start_addr = 'h90;
              pf_config[i].m_cap_msi_cap.cap_end_addr   = 'h90 +'h10;

              if(i_cfg.k_msix_enable)
              pf_config[i].m_cap_msi_cap.next_cap_addr  = 'hB0;
              else
              pf_config[i].m_cap_msi_cap.next_cap_addr  = 'hC0;
              pf_config[i].m_cap_msi_cap.reg_num_pf     = i;
              pf_config[i].m_cap_msi_cap.is_usp_specific  = 'h1;
              pf_config[i].m_cap_msi_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_msi_cap);

              // MSI-X Capability and Table Structure
              //pf_config[i].m_cap_msix_cap                   = new();
              pf_config[i].m_cap_msix_cap.cap_addr       = 'hB0; //'hB0
              pf_config[i].m_cap_msix_cap.is_cap_present = 1'b1;
              if(i_cfg.k_msix_enable)
              pf_config[i].m_cap_msix_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_msix_cap.cap_start_addr = 'hB0;
              pf_config[i].m_cap_msix_cap.cap_end_addr   = 'hB0 +'h8;
              pf_config[i].m_cap_msix_cap.next_cap_addr  = 'hC0;
              pf_config[i].m_cap_msix_cap.reg_num_pf     = i;
              pf_config[i].m_cap_msix_cap.is_usp_specific  = 'h1;
              pf_config[i].m_cap_msix_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_msix_cap);

              //------------------------------------------------------------------------
              // PCI Express Capability Structure
              //------------------------------------------------------------------------
              //pf_config[i].m_cap_pcie_exp_cap               = new();
              pf_config[i].m_cap_pcie_exp_cap.cap_addr       = 'hC0; //'hC0
              pf_config[i].m_cap_pcie_exp_cap.is_cap_present = 1'b1;
              pf_config[i].m_cap_pcie_exp_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_pcie_exp_cap.cap_start_addr = 'hC0;
              pf_config[i].m_cap_pcie_exp_cap.cap_end_addr   = 'hC0 +'h38; // TODO : spec defined add upto 'h38 but IPXACT goes till 'h30 , slot_cap_2 is not defined
              pf_config[i].m_cap_pcie_exp_cap.next_cap_addr  = 'h0; // TODO : should it end on'd0????
              pf_config[i].m_cap_pcie_exp_cap.reg_num_pf     = i;
              pf_config[i].m_cap_pcie_exp_cap.is_usp_specific  = 'h1;
              pf_config[i].m_cap_pcie_exp_cap.is_dsp_specific  = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_pcie_exp_cap);

              //------------------------------------------------------------------------
              // Advanced Error Reporting Extended Capability
              //------------------------------------------------------------------------
              //pf_config[i].m_cap_aer_ext_cap                = new();
              pf_config[i].m_cap_aer_ext_cap.cap_addr       = 'h100; //'h100
              pf_config[i].m_cap_aer_ext_cap.is_cap_present = 1'b1;
              pf_config[i].m_cap_aer_ext_cap.is_cap_enable  = 1'b1; //Always present
              pf_config[i].m_cap_aer_ext_cap.cap_start_addr = 'h100;
              pf_config[i].m_cap_aer_ext_cap.cap_end_addr   = 'h100 +'h44; // TODO : spec defined add upto 'h44 but IPXACT goes till 'h38 , tlp_prelog register is not fully defined
              //if(!i_cfg.strap_is_rp) begin
                  if(i_cfg.strap_ari_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h140;
                  else if(i_cfg.k_device_serial_num_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h150;
                  else if(i_cfg.k_power_budgeting_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h160;
                  else if(i_cfg.k_resizable_bar_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h180;
                  else if(i_cfg.k_ltr_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h1B8;
                  else if(i_cfg.k_dpa_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h1C0;
                  else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h200;
                  else if(i_cfg.k_tph_supported)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h274;
                  else if(i_cfg.strap_pcie_rate_max>='d2)
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h300;
                  else
                  pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h400;
             // end else begin //EP mode
            //      if(i_cfg.k_device_serial_num_enable)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h150;
            //      else if(i_cfg.k_tph_supported)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h274;
            //      else if(i_cfg.k_pcie_rate_max>='d3)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h300;
            //      else if(i_cfg.k_pasid_supported) //TODO: need to recheck
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h440;
            //      else if(i_cfg.k_num_vcs>1 & i_cfg.k_multi_tc_supp)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h4C0;
            //      else if(i_cfg.k_l1_pm_substate_enable)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h900;
            //      else if(i_cfg.k_pcie_rate_max>='d3)
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h910;
            //      else
            //      pf_config[i].m_cap_aer_ext_cap.next_cap_addr  = 'h0;
            //  end//RP mode
              pf_config[i].m_cap_aer_ext_cap.reg_num_pf     = i;
              pf_config[i].m_cap_aer_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_aer_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_aer_ext_cap);

              // ARI Extended Capability
              //pf_config[i].m_cap_ari_ext_cap                = new();
              pf_config[i].m_cap_ari_ext_cap.cap_addr       = 'h140; //'h140
              pf_config[i].m_cap_ari_ext_cap.is_cap_present = 1'b1;
              if(i_cfg.strap_ari_enable) //Make it 1 only when capability is enabled
              pf_config[i].m_cap_ari_ext_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_ari_ext_cap.cap_start_addr = 'h140;
              pf_config[i].m_cap_ari_ext_cap.cap_end_addr   = 'h140 +'h4;
              if(i_cfg.k_device_serial_num_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h150;
              else if(i_cfg.k_power_budgeting_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h160;
              else if(i_cfg.k_resizable_bar_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h180;
              else if(i_cfg.k_ltr_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h1B8;
              else if(i_cfg.k_dpa_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h1C0;
              else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h200;
              else if(i_cfg.k_tph_supported)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h274;
              else if(i_cfg.strap_pcie_rate_max>='d2)
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h300;
              else
              pf_config[i].m_cap_ari_ext_cap.next_cap_addr  = 'h400;
              pf_config[i].m_cap_ari_ext_cap.reg_num_pf     = i;
              pf_config[i].m_cap_ari_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_ari_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_ari_ext_cap);

              // Resizable BAR Extended Capability
              //pf_config[i].m_cap_resize_bar_ext_cap         = new();
              pf_config[i].m_cap_resize_bar_ext_cap.cap_addr       = 'h180; //'h180
              pf_config[i].m_cap_resize_bar_ext_cap.is_cap_present = 1'b1;
              if(i_cfg.k_resizable_bar_enable)
              pf_config[i].m_cap_resize_bar_ext_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_resize_bar_ext_cap.cap_start_addr = 'h180;
              pf_config[i].m_cap_resize_bar_ext_cap.cap_end_addr   = 'h180 +'h10;
              //Next cap pointer
              if(i_cfg.k_ltr_enable)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr  = 'h1B8;
              else if(i_cfg.k_dpa_enable)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr  = 'h1C0;
              else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr  = 'h200;
              else if(i_cfg.k_tph_supported)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr  = 'h274;
              else if(i_cfg.strap_pcie_rate_max>='d2)
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr  = 'h300;
              else
              pf_config[i].m_cap_resize_bar_ext_cap.next_cap_addr  = 'h400;
              pf_config[i].m_cap_resize_bar_ext_cap.reg_num_pf     = i;
              pf_config[i].m_cap_resize_bar_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_resize_bar_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_resize_bar_ext_cap);

              // SR-IOV Capabilities Register
              //pf_config[i].m_cap_sriov_cap                  = new();
              pf_config[i].m_cap_sriov_cap.cap_addr       = 'h200; //'h200
              pf_config[i].m_cap_sriov_cap.is_cap_present = 1'b1;
              if(i_cfg.k_sriov_enable[i] && i_cfg.strap_sriov_enable)
              pf_config[i].m_cap_sriov_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_sriov_cap.cap_start_addr = 'h200;
              pf_config[i].m_cap_sriov_cap.cap_end_addr   = 'h200 +'h3C; //TODO : spec defined add upto 'h3c but IPXACT goes till 'h24 , VF_bar [1-5] registers are not defined
              //Next cap pointer
              if(i_cfg.k_tph_supported)
              pf_config[i].m_cap_sriov_cap.next_cap_addr  = 'h274;
              else if(i_cfg.strap_pcie_rate_max>='d2)
              pf_config[i].m_cap_sriov_cap.next_cap_addr  = 'h300;
              else
              pf_config[i].m_cap_sriov_cap.next_cap_addr  = 'h400;
              pf_config[i].m_cap_sriov_cap.reg_num_pf     = i;
              pf_config[i].m_cap_sriov_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_sriov_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_sriov_cap);

              // TPH Requester Extended Capability
              //pf_config[i].m_cap_tph_ext_cap                = new();
              pf_config[i].m_cap_tph_ext_cap.cap_addr       = 'h274; //'h274
              pf_config[i].m_cap_tph_ext_cap.is_cap_present = 1'b1;
              if(i_cfg.k_tph_supported)
              pf_config[i].m_cap_tph_ext_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_tph_ext_cap.cap_start_addr = 'h274;
              pf_config[i].m_cap_tph_ext_cap.cap_end_addr   = 'h274 +'hC;
              //Next cap pointer
              if(i_cfg.strap_pcie_rate_max>='d2)
              pf_config[i].m_cap_tph_ext_cap.next_cap_addr  = 'h300;
              else
              pf_config[i].m_cap_tph_ext_cap.next_cap_addr  = 'h400;
              pf_config[i].m_cap_tph_ext_cap.reg_num_pf     = i;
              pf_config[i].m_cap_tph_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_tph_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_tph_ext_cap);

              // VENDOR_SPEC_CAP_REG_ADDR Capability  ??????

              // PASID Extended Capability Structure
              //pf_config[i].m_cap_pasid_ext_cap              = new();
              pf_config[i].m_cap_pasid_ext_cap.cap_addr       = 'h440; //'h440
              pf_config[i].m_cap_pasid_ext_cap.is_cap_present = 1'b1;
              if(i_cfg.k_pasid_supported)
              pf_config[i].m_cap_pasid_ext_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_pasid_ext_cap.cap_start_addr = 'h440;
              pf_config[i].m_cap_pasid_ext_cap.cap_end_addr   = 'h440 +'h4;
              //Next cap pointer
              if(i_cfg.k_num_vcs>1 & i_cfg.k_multi_tc_supp)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'h4C0;
              else if(i_cfg.k_ats_enable)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'h5C0;
              else if(i_cfg.k_l1_pm_substate_enable)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'h900;
              else if(i_cfg.strap_pcie_rate_max>='d3)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'h910;
              else if(i_cfg.k_ptm_enable)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'hA20;
              else if(i_cfg.k_npem_enable)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'hA30;
              else if(i_cfg.strap_pcie_rate_max >=4)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'hA40;
              else if(i_cfg.k_alt_prot_neg_support)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'hA70;
              else if(i_cfg.k_dmwr_req_support)
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'hA90;
              else
              pf_config[i].m_cap_pasid_ext_cap.next_cap_addr  = 'h0;
              pf_config[i].m_cap_pasid_ext_cap.reg_num_pf     = i;
              pf_config[i].m_cap_pasid_ext_cap.is_usp_specific    = 'h1;
              pf_config[i].m_cap_pasid_ext_cap.is_dsp_specific    = 'h1;
              reg_linklist_q.push_back(pf_config[i].m_cap_pasid_ext_cap);

              // ATS Extended Capability
              //pf_config[i].m_cap_ats_cap                    = new();
              pf_config[i].m_cap_ats_cap.cap_addr       = 'h5C0; //'h540
              pf_config[i].m_cap_ats_cap.is_cap_present = 1'b1;
              if(i_cfg.k_ats_enable)
              pf_config[i].m_cap_ats_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_ats_cap.cap_start_addr = 'h5C0;
              pf_config[i].m_cap_ats_cap.cap_end_addr   = 'h5C0 +'h4;
              //Next cap pointer
              pf_config[i].m_cap_ats_cap.next_cap_addr  = 'h640;
              pf_config[i].m_cap_ats_cap.reg_num_pf     = i;
              pf_config[i].m_cap_ats_cap.is_usp_specific   = 'h1;
              pf_config[i].m_cap_ats_cap.is_dsp_specific   = 'h0;
              reg_linklist_q.push_back(pf_config[i].m_cap_ats_cap);

              // ATS PR Extended Capability
              //pf_config[i].m_cap_ats_pr_cap                 = new();
              pf_config[i].m_cap_ats_pr_cap.cap_addr       = 'h640; //'h640
              pf_config[i].m_cap_ats_pr_cap.is_cap_present = 1'b1;
              if(i_cfg.k_ats_enable)
              pf_config[i].m_cap_ats_pr_cap.is_cap_enable  = 1'b1;
              pf_config[i].m_cap_ats_pr_cap.cap_start_addr = 'h640;
              pf_config[i].m_cap_ats_pr_cap.cap_end_addr   = 'h640 +'hC;
              //Next cap pointer
              if(i_cfg.k_l1_pm_substate_enable)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr  = 'h900;
              else if(i_cfg.strap_pcie_rate_max>='d3)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr  = 'h910;
              else if(i_cfg.k_ptm_enable)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr  = 'hA20;
              else if(i_cfg.k_npem_enable)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr  = 'hA30;
              else if(i_cfg.strap_pcie_rate_max >=4)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr  = 'hA40;
              else if(i_cfg.k_alt_prot_neg_support)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr  = 'hA70;
              else if(i_cfg.k_dmwr_req_support)
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr  = 'hA90;
              else
              pf_config[i].m_cap_ats_pr_cap.next_cap_addr  = 'h0;
              pf_config[i].m_cap_ats_pr_cap.reg_num_pf     = i;
              pf_config[i].m_cap_ats_pr_cap.is_usp_specific   = 'h1;
              pf_config[i].m_cap_ats_pr_cap.is_dsp_specific   = 'h0;
              reg_linklist_q.push_back(pf_config[i].m_cap_ats_pr_cap);
	      reg_linkedlist_done =1;
              end//Random PFn -if condn
	      //end//foreach
	  end //for all PFs 1-n
	  i_cfg.done_creating_reg_linkedlist = 1;
      `uvm_info(get_type_name(), $psprintf("pf_cap_linked_list :: pf_index = [%0d] and  reg_linklist_q size = [%0d] done_creating_pf_reg_linkedlist %d", i, reg_linklist_q.size(), i_cfg.done_creating_reg_linkedlist), UVM_LOW)
      end //for loop
  endfunction : pf_cap_linked_list

  function void vf_cap_linked_list();
      for (int i=0; i<loop_cnt_vf; i++) begin //k_num_pf loop
        for(int j=0; j<pf_config[i].m_NumVFs ; j++) begin //k_num_vf loop
          `uvm_info(get_type_name(), $psprintf("vf_cap_linked_list :: vf_index = [%0d] and  m_num_VFs %d j %d", i, pf_config[i].m_NumVFs, j), UVM_LOW)
          if(i==0 && j==0 && (vf_config[i][j].m_is_vf == 1) ) begin //Only for PF0-VF0
              `uvm_info(get_type_name(), $psprintf("vf_cap_linked_list :: Pushing in PF_%0d VF_%0d capabilities in reg linked list and  m_is_Vf %d", i, j, vf_config[i][j].m_is_vf), UVM_LOW)
              //------------------------------------------------------------------------
	      // PCIE base Capability Structures
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_pci_compatible_config_regs                  = new();
              vf_config[i][j].m_cap_pci_compatible_config_regs.cap_addr         = 'h0;
              vf_config[i][j].m_cap_pci_compatible_config_regs.is_cap_present   = 1'b1;
              vf_config[i][j].m_cap_pci_compatible_config_regs.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_pci_compatible_config_regs.cap_start_addr   = 'h0;
	      vf_config[i][j].m_cap_pci_compatible_config_regs.cap_end_addr     = 'h3C;
              vf_config[i][j].m_cap_pci_compatible_config_regs.next_cap_addr    = 'h80;
              vf_config[i][j].m_cap_pci_compatible_config_regs.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_pci_compatible_config_regs.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_pci_compatible_config_regs.reg_num_pf       = i;
              vf_config[i][j].m_cap_pci_compatible_config_regs.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_pci_compatible_config_regs);

              //------------------------------------------------------------------------
	      // PCI Power Management Capability Structure
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_pci_pm_ap                  = new();
              vf_config[i][j].m_cap_pci_pm_ap.cap_addr         = 'h80;
              vf_config[i][j].m_cap_pci_pm_ap.is_cap_present   = 1'b1;
              vf_config[i][j].m_cap_pci_pm_ap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_pci_pm_ap.cap_start_addr   = 'h80;
	      vf_config[i][j].m_cap_pci_pm_ap.cap_end_addr     = 'h84;
	      //if(i_cfg.k_vpd_enable)
              //vf_config[i][j][i].m_cap_pci_pm_ap.next_cap_addr  = 'h88;
	      if(i_cfg.k_msi_enable)
              vf_config[i][j].m_cap_pci_pm_ap.next_cap_addr    = 'h90;
	      else if(i_cfg.k_msix_enable) //TODO : why cecking only 3 k_wire, cant we check all k_wires and assign add of last cap
              vf_config[i][j].m_cap_pci_pm_ap.next_cap_addr    = 'hB0;
	      else
              vf_config[i][j].m_cap_pci_pm_ap.next_cap_addr    = 'hC0;
              vf_config[i][j].m_cap_pci_pm_ap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_pci_pm_ap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_pci_pm_ap.reg_num_pf       = i;
              vf_config[i][j].m_cap_pci_pm_ap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_pci_pm_ap);

	      // TODO : VPD Capability Structures is not present in dev_cfg

              //------------------------------------------------------------------------
	      // MSI Capability Structures
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_msi_cap                  = new();
              vf_config[i][j].m_cap_msi_cap.cap_addr         = 'h90;
              vf_config[i][j].m_cap_msi_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_msi_enable) //Make it 1 only when   capability is enabled
              vf_config[i][j].m_cap_msi_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_msi_cap.cap_start_addr   = 'h90;
	      vf_config[i][j].m_cap_msi_cap.cap_end_addr     = 'h90 +'h10;
	      if(i_cfg.k_msix_enable)
              vf_config[i][j].m_cap_msi_cap.next_cap_addr    = 'hB0;
	      else
              vf_config[i][j].m_cap_msi_cap.next_cap_addr    = 'hC0;
              vf_config[i][j].m_cap_msi_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_msi_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_msi_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_msi_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_msi_cap);

              //------------------------------------------------------------------------
              // MSI-X Capability and Table Structure
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_msix_cap                  = new();
              vf_config[i][j].m_cap_msix_cap.cap_addr         = 'hB0;
              vf_config[i][j].m_cap_msix_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_msix_enable)
              vf_config[i][j].m_cap_msix_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_msix_cap.cap_start_addr   = 'hB0;
	      vf_config[i][j].m_cap_msix_cap.cap_end_addr     = 'hB0 +'h8;
              vf_config[i][j].m_cap_msix_cap.next_cap_addr    = 'hC0;
              vf_config[i][j].m_cap_msix_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_msix_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_msix_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_msix_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_msix_cap);

	      //------------------------------------------------------------------------
              // PCI Express Capability Structure
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_pcie_exp_cap                  = new();
              vf_config[i][j].m_cap_pcie_exp_cap.cap_addr         = 'hC0;
              vf_config[i][j].m_cap_pcie_exp_cap.is_cap_present   = 1'b1;
              vf_config[i][j].m_cap_pcie_exp_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_pcie_exp_cap.cap_start_addr   = 'hC0;
	      vf_config[i][j].m_cap_pcie_exp_cap.cap_end_addr     = 'hC0 +'h38; // TODO : spec defined add upto 'h38 but IPXACT goes till 'h30 , slot_cap_2 is not defined
              vf_config[i][j].m_cap_pcie_exp_cap.next_cap_addr    = 'h0; // TODO : should it end on'd0????
              vf_config[i][j].m_cap_pcie_exp_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_pcie_exp_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_pcie_exp_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_pcie_exp_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_pcie_exp_cap);

              //------------------------------------------------------------------------
              // Advanced Error Reporting Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_aer_ext_cap                = new();
              vf_config[i][j].m_cap_aer_ext_cap.cap_addr       = 'h100;
              vf_config[i][j].m_cap_aer_ext_cap.is_cap_present = 1'b1;
              vf_config[i][j].m_cap_aer_ext_cap.is_cap_enable  = 1'b1; //Always present
              vf_config[i][j].m_cap_aer_ext_cap.cap_start_addr = 'h100;
	      vf_config[i][j].m_cap_aer_ext_cap.cap_end_addr   = 'h100 +'h44; // TODO : spec defined add upto 'h44 but IPXACT goes till 'h38 , tlp_prelog register is not fully defined
	      //if(!i_cfg.strap_is_rp) begin
	          if(i_cfg.strap_ari_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h140;
	          else if(i_cfg.k_device_serial_num_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h150;
	          else if(i_cfg.k_power_budgeting_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h160;
	          else if(i_cfg.k_resizable_bar_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h180;
	          else if(i_cfg.k_ltr_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h1B8;
	          else if(i_cfg.k_dpa_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h1C0;
	          else if(i_cfg.k_sriov_enable[0 && i_cfg.strap_sriov_enable])
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h200;
	          else if(i_cfg.k_tph_supported)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h274;
	          else if(i_cfg.strap_pcie_rate_max>='d2)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h300;
	          else
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h400;
	     // end else begin //EP mode
	    //      if(i_cfg.k_device_serial_num_enable)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h150;
	    //      else if(i_cfg.k_tph_supported)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h274;
	    //      else if(i_cfg.k_pcie_rate_max>='d3)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h300;
	    //      else if(i_cfg.k_pasid_supported) //TODO: need to recheck
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h440;
	    //      else if(i_cfg.k_num_vcs>1 & i_cfg.k_multi_tc_supp)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h4C0;
	    //      else if(i_cfg.k_l1_pm_substate_enable)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h900;
	    //      else if(i_cfg.k_pcie_rate_max>='d3)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h910;
	    //      else
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h0;
	    //  end//RP mode
              vf_config[i][j].m_cap_aer_ext_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_aer_ext_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_aer_ext_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_aer_ext_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_aer_ext_cap);

              //------------------------------------------------------------------------
              // ARI Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_ari_ext_cap                  = new();
              vf_config[i][j].m_cap_ari_ext_cap.cap_addr         = 'h140; //'h140
              vf_config[i][j].m_cap_ari_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.strap_ari_enable) //Make it 1 only when capability is enabled
              vf_config[i][j].m_cap_ari_ext_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_ari_ext_cap.cap_start_addr   = 'h140;
	      vf_config[i][j].m_cap_ari_ext_cap.cap_end_addr     = 'h140 +'h4;
	      if(i_cfg.k_device_serial_num_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h150;
	      else if(i_cfg.k_power_budgeting_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h160;
	      else if(i_cfg.k_resizable_bar_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h180;
	      else if(i_cfg.k_ltr_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h1B8;
	      else if(i_cfg.k_dpa_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h1C0;
	      else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h200;
	      else if(i_cfg.k_tph_supported)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>='d2)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h300;
	      else
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h400;
              vf_config[i][j].m_cap_ari_ext_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_ari_ext_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_ari_ext_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_ari_ext_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_ari_ext_cap);

              // Device  serial number Capability TODO : spec says VFS are
	      // permitted but not recommended to implement this feature

              //------------------------------------------------------------------------
              // TPH Requester Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_tph_ext_cap                  = new();
	      vf_config[i][j].m_cap_tph_ext_cap.cap_addr         = 'h274; //'h274
              vf_config[i][j].m_cap_tph_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_tph_supported)
              vf_config[i][j].m_cap_tph_ext_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_tph_ext_cap.cap_start_addr   = 'h274;
	      vf_config[i][j].m_cap_tph_ext_cap.cap_end_addr     = 'h274 +'hC;
              //Next cap pointer
	      if(i_cfg.strap_pcie_rate_max>='d2)
              vf_config[i][j].m_cap_tph_ext_cap.next_cap_addr    = 'h300;
	      else
              vf_config[i][j].m_cap_tph_ext_cap.next_cap_addr    = 'h400;
              vf_config[i][j].m_cap_tph_ext_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_tph_ext_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_tph_ext_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_tph_ext_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_tph_ext_cap);

              // TODO :VENDOR_SPEC_CAP_REG_ADDR Capability  ??????

              //------------------------------------------------------------------------
	      // ATS Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_ats_cap                    = new();
	      vf_config[i][j].m_cap_ats_cap.cap_addr         = 'h5C0; //'h540
              vf_config[i][j].m_cap_ats_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_ats_enable)
              vf_config[i][j].m_cap_ats_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_ats_cap.cap_start_addr   = 'h5C0;
	      vf_config[i][j].m_cap_ats_cap.cap_end_addr     = 'h5C0 +'h4;
              //Next cap pointer
              vf_config[i][j].m_cap_ats_cap.next_cap_addr    = 'h640;
              vf_config[i][j].m_cap_ats_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_ats_cap.is_dsp_specific  = 'h0;
              vf_config[i][j].m_cap_ats_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_ats_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_ats_cap);

              //------------------------------------------------------------------------
	      // ATS PR Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_ats_pr_cap                  = new();
	      vf_config[i][j].m_cap_ats_pr_cap.cap_addr         = 'h640; //'h640
              vf_config[i][j].m_cap_ats_pr_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_ats_enable)
              vf_config[i][j].m_cap_ats_pr_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_ats_pr_cap.cap_start_addr   = 'h640;
	      vf_config[i][j].m_cap_ats_pr_cap.cap_end_addr     = 'h640 +'hC;
              //Next cap pointer
	      if(i_cfg.k_l1_pm_substate_enable)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'h900;
	      else if(i_cfg.strap_pcie_rate_max>='d3)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'h910;
	      else if(i_cfg.k_ptm_enable)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA20;
	      else if(i_cfg.k_npem_enable)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA30;
	      else if(i_cfg.strap_pcie_rate_max >=4)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA40;
	      else if(i_cfg.k_alt_prot_neg_support)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA90;
	      else
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'h0;
              vf_config[i][j].m_cap_ats_pr_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_ats_pr_cap.is_dsp_specific  = 'h0;
              vf_config[i][j].m_cap_ats_pr_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_ats_pr_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_ats_pr_cap);

              //------------------------------------------------------------------------
	      // Device3 Extended Capability
              //------------------------------------------------------------------------
	      m_cap_dev3_ext_cap.cap_addr         = 'hA90; //'hA30
              m_cap_dev3_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_dmwr_req_support)
              m_cap_dev3_ext_cap.is_cap_enable    = 1'b1;
              m_cap_dev3_ext_cap.cap_start_addr   = 'hA90;
	      m_cap_dev3_ext_cap.cap_end_addr     = 'hA90 +'hC; //TODO : IPXACT saying its 'h8
              //Next cap pointer
              m_cap_dev3_ext_cap.next_cap_addr    = 'h0;
              m_cap_dev3_ext_cap.is_usp_specific  = 'h1;
              m_cap_dev3_ext_cap.is_dsp_specific  = 'h1;
              m_cap_dev3_ext_cap.reg_num_pf       = i;
              m_cap_dev3_ext_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(m_cap_dev3_ext_cap);
	  end else begin
	      vf_index = $urandom_range({16'h0,pf_config[i].m_NumVFs},1);
	      `uvm_info(get_type_name(), $psprintf("vf_cap_linked_list :: vf_index = [%0d] and  m_num_VFs %d j %d vf_num %d", i, pf_config[i].m_NumVFs, j, vf_index), UVM_LOW)
              if(i==pf_index && j==vf_index && (vf_config[i][j].m_is_vf == 1) ) begin //Only for PF0-VF0
              `uvm_info(get_type_name(), $psprintf("vf_cap_linked_list :: Pushing in PF_%0d VF_%0d capabilities in reg linked list and m_is_Vf %d", i, j, vf_config[i][j].m_is_vf), UVM_LOW)
              //------------------------------------------------------------------------
	      // PCIE base Capability Structures
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_pci_compatible_config_regs                  = new();
              vf_config[i][j].m_cap_pci_compatible_config_regs.cap_addr         = 'h0;
              vf_config[i][j].m_cap_pci_compatible_config_regs.is_cap_present   = 1'b1;
              vf_config[i][j].m_cap_pci_compatible_config_regs.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_pci_compatible_config_regs.cap_start_addr   = 'h0;
	      vf_config[i][j].m_cap_pci_compatible_config_regs.cap_end_addr     = 'h3C;
              vf_config[i][j].m_cap_pci_compatible_config_regs.next_cap_addr    = 'h80;
              vf_config[i][j].m_cap_pci_compatible_config_regs.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_pci_compatible_config_regs.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_pci_compatible_config_regs.reg_num_pf       = i;
              vf_config[i][j].m_cap_pci_compatible_config_regs.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_pci_compatible_config_regs);

              //------------------------------------------------------------------------
	      // PCI Power Management Capability Structure
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_pci_pm_ap                  = new();
              vf_config[i][j].m_cap_pci_pm_ap.cap_addr         = 'h80;
              vf_config[i][j].m_cap_pci_pm_ap.is_cap_present   = 1'b1;
              vf_config[i][j].m_cap_pci_pm_ap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_pci_pm_ap.cap_start_addr   = 'h80;
	      vf_config[i][j].m_cap_pci_pm_ap.cap_end_addr     = 'h84;
	      //if(i_cfg.k_vpd_enable)
              //vf_config[i][j][i].m_cap_pci_pm_ap.next_cap_addr  = 'h88;
	      if(i_cfg.k_msi_enable)
              vf_config[i][j].m_cap_pci_pm_ap.next_cap_addr    = 'h90;
	      else if(i_cfg.k_msix_enable) //TODO : why cecking only 3 k_wire, cant we check all k_wires and assign add of last cap
              vf_config[i][j].m_cap_pci_pm_ap.next_cap_addr    = 'hB0;
	      else
              vf_config[i][j].m_cap_pci_pm_ap.next_cap_addr    = 'hC0;
              vf_config[i][j].m_cap_pci_pm_ap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_pci_pm_ap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_pci_pm_ap.reg_num_pf       = i;
              vf_config[i][j].m_cap_pci_pm_ap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_pci_pm_ap);

	      // TODO : VPD Capability Structures is not present in dev_cfg

              //------------------------------------------------------------------------
	      // MSI Capability Structures
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_msi_cap                  = new();
              vf_config[i][j].m_cap_msi_cap.cap_addr         = 'h90;
              vf_config[i][j].m_cap_msi_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_msi_enable) //Make it 1 only when   capability is enabled
              vf_config[i][j].m_cap_msi_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_msi_cap.cap_start_addr   = 'h90;
	      vf_config[i][j].m_cap_msi_cap.cap_end_addr     = 'h90 +'h10;
	      if(i_cfg.k_msix_enable)
              vf_config[i][j].m_cap_msi_cap.next_cap_addr    = 'hB0;
	      else
              vf_config[i][j].m_cap_msi_cap.next_cap_addr    = 'hC0;
              vf_config[i][j].m_cap_msi_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_msi_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_msi_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_msi_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_msi_cap);

              //------------------------------------------------------------------------
              // MSI-X Capability and Table Structure
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_msix_cap                  = new();
              vf_config[i][j].m_cap_msix_cap.cap_addr         = 'hB0;
              vf_config[i][j].m_cap_msix_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_msix_enable)
              vf_config[i][j].m_cap_msix_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_msix_cap.cap_start_addr   = 'hB0;
	      vf_config[i][j].m_cap_msix_cap.cap_end_addr     = 'hB0 +'h8;
              vf_config[i][j].m_cap_msix_cap.next_cap_addr    = 'hC0;
              vf_config[i][j].m_cap_msix_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_msix_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_msix_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_msix_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_msix_cap);

	      //------------------------------------------------------------------------
              // PCI Express Capability Structure
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_pcie_exp_cap                  = new();
              vf_config[i][j].m_cap_pcie_exp_cap.cap_addr         = 'hC0;
              vf_config[i][j].m_cap_pcie_exp_cap.is_cap_present   = 1'b1;
              vf_config[i][j].m_cap_pcie_exp_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_pcie_exp_cap.cap_start_addr   = 'hC0;
	      vf_config[i][j].m_cap_pcie_exp_cap.cap_end_addr     = 'hC0 +'h38; // TODO : spec defined add upto 'h38 but IPXACT goes till 'h30 , slot_cap_2 is not defined
              vf_config[i][j].m_cap_pcie_exp_cap.next_cap_addr    = 'h0; // TODO : should it end on'd0????
              vf_config[i][j].m_cap_pcie_exp_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_pcie_exp_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_pcie_exp_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_pcie_exp_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_pcie_exp_cap);

              //------------------------------------------------------------------------
              // Advanced Error Reporting Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_aer_ext_cap                = new();
              vf_config[i][j].m_cap_aer_ext_cap.cap_addr       = 'h100;
              vf_config[i][j].m_cap_aer_ext_cap.is_cap_present = 1'b1;
              vf_config[i][j].m_cap_aer_ext_cap.is_cap_enable  = 1'b1; //Always present
              vf_config[i][j].m_cap_aer_ext_cap.cap_start_addr = 'h100;
	      vf_config[i][j].m_cap_aer_ext_cap.cap_end_addr   = 'h100 +'h44; // TODO : spec defined add upto 'h44 but IPXACT goes till 'h38 , tlp_prelog register is not fully defined
	      //if(!i_cfg.strap_is_rp) begin
	          if(i_cfg.strap_ari_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h140;
	          else if(i_cfg.k_device_serial_num_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h150;
	          else if(i_cfg.k_power_budgeting_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h160;
	          else if(i_cfg.k_resizable_bar_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h180;
	          else if(i_cfg.k_ltr_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h1B8;
	          else if(i_cfg.k_dpa_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h1C0;
	          else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h200;
	          else if(i_cfg.k_tph_supported)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h274;
	          else if(i_cfg.strap_pcie_rate_max>='d2)
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h300;
	          else
                  vf_config[i][j].m_cap_aer_ext_cap.next_cap_addr  = 'h400;
	     // end else begin //EP mode
	    //      if(i_cfg.k_device_serial_num_enable)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h150;
	    //      else if(i_cfg.k_tph_supported)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h274;
	    //      else if(i_cfg.k_pcie_rate_max>='d3)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h300;
	    //      else if(i_cfg.k_pasid_supported) //TODO: need to recheck
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h440;
	    //      else if(i_cfg.k_num_vcs>1 & i_cfg.k_multi_tc_supp)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h4C0;
	    //      else if(i_cfg.k_l1_pm_substate_enable)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h900;
	    //      else if(i_cfg.k_pcie_rate_max>='d3)
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h910;
	    //      else
            //      vf_config[i][j][i].m_cap_aer_ext_cap.next_cap_addr  = 'h0;
	    //  end//RP mode
              vf_config[i][j].m_cap_aer_ext_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_aer_ext_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_aer_ext_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_aer_ext_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_aer_ext_cap);

              //------------------------------------------------------------------------
              // ARI Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_ari_ext_cap                  = new();
              vf_config[i][j].m_cap_ari_ext_cap.cap_addr         = 'h140; //'h140
              vf_config[i][j].m_cap_ari_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.strap_ari_enable) //Make it 1 only when capability is enabled
              vf_config[i][j].m_cap_ari_ext_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_ari_ext_cap.cap_start_addr   = 'h140;
	      vf_config[i][j].m_cap_ari_ext_cap.cap_end_addr     = 'h140 +'h4;
	      if(i_cfg.k_device_serial_num_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h150;
	      else if(i_cfg.k_power_budgeting_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h160;
	      else if(i_cfg.k_resizable_bar_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h180;
	      else if(i_cfg.k_ltr_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h1B8;
	      else if(i_cfg.k_dpa_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h1C0;
	      else if(i_cfg.k_sriov_enable[0] && i_cfg.strap_sriov_enable)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h200;
	      else if(i_cfg.k_tph_supported)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h274;
	      else if(i_cfg.strap_pcie_rate_max>='d2)
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h300;
	      else
              vf_config[i][j].m_cap_ari_ext_cap.next_cap_addr    = 'h400;
              vf_config[i][j].m_cap_ari_ext_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_ari_ext_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_ari_ext_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_ari_ext_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_ari_ext_cap);

              // Device  serial number Capability TODO : spec says VFS are
	      // permitted but not recommended to implement this feature

              //------------------------------------------------------------------------
              // TPH Requester Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_tph_ext_cap                  = new();
	      vf_config[i][j].m_cap_tph_ext_cap.cap_addr         = 'h274; //'h274
              vf_config[i][j].m_cap_tph_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_tph_supported)
              vf_config[i][j].m_cap_tph_ext_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_tph_ext_cap.cap_start_addr   = 'h274;
	      vf_config[i][j].m_cap_tph_ext_cap.cap_end_addr     = 'h274 +'hC;
              //Next cap pointer
	      if(i_cfg.strap_pcie_rate_max>='d2)
              vf_config[i][j].m_cap_tph_ext_cap.next_cap_addr    = 'h300;
	      else
              vf_config[i][j].m_cap_tph_ext_cap.next_cap_addr    = 'h400;
              vf_config[i][j].m_cap_tph_ext_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_tph_ext_cap.is_dsp_specific  = 'h1;
              vf_config[i][j].m_cap_tph_ext_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_tph_ext_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_tph_ext_cap);

              // TODO :VENDOR_SPEC_CAP_REG_ADDR Capability  ??????

              //------------------------------------------------------------------------
	      // ATS Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_ats_cap                    = new();
	      vf_config[i][j].m_cap_ats_cap.cap_addr         = 'h5C0; //'h540
              vf_config[i][j].m_cap_ats_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_ats_enable)
              vf_config[i][j].m_cap_ats_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_ats_cap.cap_start_addr   = 'h5C0;
	      vf_config[i][j].m_cap_ats_cap.cap_end_addr     = 'h5C0 +'h4;
              //Next cap pointer
              vf_config[i][j].m_cap_ats_cap.next_cap_addr    = 'h640;
              vf_config[i][j].m_cap_ats_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_ats_cap.is_dsp_specific  = 'h0;
              vf_config[i][j].m_cap_ats_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_ats_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_ats_cap);

              //------------------------------------------------------------------------
	      // ATS PR Extended Capability
              //------------------------------------------------------------------------
              vf_config[i][j].m_cap_ats_pr_cap                  = new();
	      vf_config[i][j].m_cap_ats_pr_cap.cap_addr         = 'h640; //'h640
              vf_config[i][j].m_cap_ats_pr_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_ats_enable)
              vf_config[i][j].m_cap_ats_pr_cap.is_cap_enable    = 1'b1;
              vf_config[i][j].m_cap_ats_pr_cap.cap_start_addr   = 'h640;
	      vf_config[i][j].m_cap_ats_pr_cap.cap_end_addr     = 'h640 +'hC;
              //Next cap pointer
	      if(i_cfg.k_l1_pm_substate_enable)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'h900;
	      else if(i_cfg.strap_pcie_rate_max>='d3)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'h910;
	      else if(i_cfg.k_ptm_enable)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA20;
	      else if(i_cfg.k_npem_enable)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA30;
	      else if(i_cfg.strap_pcie_rate_max >=4)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA40;
	      else if(i_cfg.k_alt_prot_neg_support)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA70;
	      else if(i_cfg.k_dmwr_req_support)
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'hA90;
	      else
              vf_config[i][j].m_cap_ats_pr_cap.next_cap_addr    = 'h0;
              vf_config[i][j].m_cap_ats_pr_cap.is_usp_specific  = 'h1;
              vf_config[i][j].m_cap_ats_pr_cap.is_dsp_specific  = 'h0;
              vf_config[i][j].m_cap_ats_pr_cap.reg_num_pf       = i;
              vf_config[i][j].m_cap_ats_pr_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(vf_config[i][j].m_cap_ats_pr_cap);

              //------------------------------------------------------------------------
	      // Device3 Extended Capability
              //------------------------------------------------------------------------
	      m_cap_dev3_ext_cap.cap_addr         = 'hA90; //'hA30
              m_cap_dev3_ext_cap.is_cap_present   = 1'b1;
	      if(i_cfg.k_dmwr_req_support)
              m_cap_dev3_ext_cap.is_cap_enable    = 1'b1;
              m_cap_dev3_ext_cap.cap_start_addr   = 'hA90;
	      m_cap_dev3_ext_cap.cap_end_addr     = 'hA90 +'hC; //TODO : IPXACT saying its 'h8
              //Next cap pointer
              m_cap_dev3_ext_cap.next_cap_addr    = 'h0;
              m_cap_dev3_ext_cap.is_usp_specific  = 'h1;
              m_cap_dev3_ext_cap.is_dsp_specific  = 'h1;
              m_cap_dev3_ext_cap.reg_num_pf       = i;
              m_cap_dev3_ext_cap.reg_num_vf       = j;
              reg_linklist_q.push_back(m_cap_dev3_ext_cap);
	      end//PFn-VFn
	  end//PF0-VF0
        end// for loop - VFs
      `uvm_info(get_type_name(), $psprintf("vf_cap_linked_list :: Vf_index = [%0d] and  reg_linklist_q size = [%0d] done_creating_vf_reg_linkedlist %d", i, reg_linklist_q.size(), i_cfg.done_creating_reg_linkedlist), UVM_LOW)
      end//for loop - Pfs

  endfunction : vf_cap_linked_list

  //---------------------------------------------------------------------------
  // Method: pf_vf_to_index
  // This is a helper function to calculate the PF/VF index
  // Order of index is PF0..N,VF1,0.....VFM,N
  //---------------------------------------------------------------------------
  function int pf_vf_to_index(int pf, int vf = -1);
    if (vf == -1) begin
      return(pf);
    end
    else begin
      pf_vf_to_index = pf;
      for (int i=0; i<=pf; i++) begin
	if (i == pf) begin
	  pf_vf_to_index += vf;
	end
	else begin
          pf_vf_to_index += this.pf_config[i].m_TotalVFs;
	end
      end
    end
  endfunction // pf_vf_to_index

  //---------------------------------------------------------------------------
  // Method: index_to_pf
  // This is a helper function to calculate the PF index
  //---------------------------------------------------------------------------
  function int index_to_pf(int index);
    int curr_index;
    if (index < l_num_enabled_pfs) begin
      return(index);
    end
    else begin
      curr_index = l_num_enabled_pfs;
      for (int i=0; i< l_num_enabled_pfs; i++) begin
        `uvm_info(get_type_name(), $psprintf("index = [%0d] and  m_NumVFs = [%0d], m_TotalVFs = [%0d] ", i, pf_config[i].m_NumVFs, pf_config[i].m_TotalVFs), UVM_FULL)
        if(this.pf_config[i].m_TotalVFs == 0 )
	   continue;
	curr_index += this.pf_config[i].m_TotalVFs;
	if (curr_index > index) begin
	  index_to_pf = i;
	  break;
	end
        `uvm_info(get_type_name(), $psprintf("curr_index = [%0d] and  index = [%0d] index_to_pf = [%0d] ", curr_index, index, index_to_pf), UVM_FULL)
      end
    end
  endfunction // index_to_pf

  //---------------------------------------------------------------------------
  // Method: index_to_vf
  // This is a helper function to calculate the VF index
  //---------------------------------------------------------------------------
  function int index_to_vf(int index);
    int curr_index;
    int run_index;
    int vf_cnt = 0;

    `uvm_info(get_type_name(), $psprintf("index = [%0d] and k_num_pfs = [%0d] ", index, l_num_enabled_pfs), UVM_FULL)
    if (index < l_num_enabled_pfs) begin
      `uvm_info(get_type_name(), $psprintf("index = [%0d] and k_num_pfs = [%0d] ", index, l_num_enabled_pfs), UVM_FULL)
      return(-1);
    end
    else begin
      curr_index = l_num_enabled_pfs;
      run_index  = l_num_enabled_pfs;

      for (int i=0; i< l_num_enabled_pfs; i++) begin

	`uvm_info(get_type_name(), $psprintf("i = [%0d] and m_TotalVFs = [%0d] in PF = [%0d] ", i, pf_config[i].m_TotalVFs, i), UVM_FULL)
        run_index += this.pf_config[i].m_TotalVFs;
	if(i>0)
          vf_cnt += this.pf_config[i-1].m_TotalVFs;
	`uvm_info(get_type_name(), $psprintf("run_index = [%0d] vf_cnt= [%0d]", run_index, vf_cnt), UVM_FULL)
        if (index < run_index) begin
         index_to_vf = index - (curr_index + vf_cnt);
         break;
        end
      end
    end
  endfunction // index_to_vf


  //---------------------------------------------------------------------------
  // Method: tc_to_vc
  // This is a helper function to find TC mapped to VC
  //---------------------------------------------------------------------------
  function int tc_to_vc(int tc);
    if(tc == 0)
      return 0; // TC0 is laways mapped to VC0
    else if(tc inside {m_unmapped_tc_list}) begin
      `uvm_warning("get_type_name", $psprintf("TC = [%0d] Not Mapped to any VC", tc))
    end
    else begin
      foreach(vc_tc_map[i]) begin
        if(vc_tc_map[i][tc] == 1 ) begin
          `uvm_info(get_type_name(), $psprintf("TC = [%0d] Mapped to VC = [%0d]", tc, i), UVM_DEBUG)
          return i;
        end
      end
    end

  endfunction

  //---------------------------------------------------------------------------
  // Method: vc_to_cif
  // This is a helper function to find VC mapped to CIF
  //---------------------------------------------------------------------------
  function int vc_to_cif(int vc);
    //for(int i = 0; i <i_cfg.k_num_cifs; i++) begin
    //  if(i_cfg.k_vc_res_to_cif_mapping[i] == vc ) begin
    //    `uvm_info(get_type_name(), $psprintf("VC = [%0d] Mapped to CIF  = [%0d]", vc, i), UVM_DEBUG)
    //    return i;
    //  end
    //end
    if(i_cfg.k_vc_res_to_cif_mapping[vc] < i_cfg.k_num_cifs) begin
      return (i_cfg.k_vc_res_to_cif_mapping[vc]);
    end else begin
     `uvm_error(get_type_name(), $psprintf("VC = [%0d] Not Mapped to any CIF", vc))
    end
  endfunction

  //---------------------------------------------------------------------------
  // Method: tc_to_cif
  // This is a helper function to find TC mapped to CIF
  //---------------------------------------------------------------------------
  function int tc_to_cif(int tc);
    return(vc_to_cif(tc_to_vc(tc)));
  endfunction
  
  //-----------------------------------------------------------------------------
  // Method : pick_dev_cfg_for_ib_addr
  // Below API can be used when DUT is EP. It will return dev_cfg corresponding to the bar hit of incoming address
  //-----------------------------------------------------------------------------
  function  cdn_hpa_pcie_dev_config pick_dev_cfg_for_ib_addr (input bit [63:0] ib_addr, input string pkt_type="MEM") ;//Pkt_type = MEM/IO
     bit [63:0] start_addr;
     bit [63:0] end_addr;
     bit success_hit;

     if((pkt_type=="MEM") && m_cxl_negotiation == CXL_1_1) begin
       start_addr = m_cxl_io_rcrb_bar + 2**12;
       end_addr = m_cxl_io_rcrb_bar + 2**13;
       if(ib_addr >= start_addr && ib_addr <= end_addr) begin
         `uvm_info(get_full_name(),$psprintf("DEBUG_CXL_RCRB_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF0",pkt_type,ib_addr),UVM_LOW)
         success_hit = 1;
         return pf_config[0];
       end
       start_addr = m_cxl_io_membar;
       end_addr = m_cxl_io_membar + 2**m_cxl_io_membar_aperture;
       if(ib_addr >= start_addr && ib_addr <= end_addr) begin
         `uvm_info(get_full_name(),$psprintf("DEBUG_CXL_MEMBAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF0",pkt_type,ib_addr),UVM_LOW)
         success_hit = 1;
         return pf_config[0];
       end
     end

      //Search all available PFs first
      foreach(m_ep_dev_bar_info.m_pf[i]) begin //{
        foreach(m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
          if(((pkt_type=="MEM") && (m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable) &&
  				((m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32) ||
  				(m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH) ||
  				(m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_PREFETCH) ||
  				(m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32_PREFETCH) ||
  				(m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32)
  				)
  	    ) ||
             ((pkt_type=="IO")  && (m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable) &&
                                  (m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == IO_BAR))
  	  ) begin //{
              start_addr = m_ep_dev_bar_info.m_pf[i].bars[j].start_addr;
              end_addr = m_ep_dev_bar_info.m_pf[i].bars[j].start_addr+ (2**(m_ep_dev_bar_info.m_pf[i].bars[j].get_decoded_bar_aperture())) -1;

  	    if(ib_addr >= start_addr && ib_addr <= end_addr) begin
                `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF_%0d",pkt_type,ib_addr,i),UVM_LOW)
  	      success_hit = 1;
  	      return pf_config[i];
  	    end
  	    end //}
        end //}
      end //}

      //Search all available VFs
      foreach(vf_config[i,j]) begin //{
        if(vf_config[i][j].m_fun_bar_info != null) begin //{
         foreach(vf_config[i][j].m_fun_bar_info.bars[bar_i]) begin //{
           if((pkt_type=="MEM") && (vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
  	 			((vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
  	 			(vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_NON_PREFETCH) ||
  	 			(vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_PREFETCH) ||
  	 			(vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH)
  	 			)
  	   ) begin //{
               start_addr = vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr;
               end_addr = vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr+ (2**(vf_config[i][j].m_fun_bar_info.bars[bar_i].get_decoded_bar_aperture())) -1;

  	     if(ib_addr >= start_addr && ib_addr <= end_addr) begin
                 `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF_%0d VF_%0d",pkt_type,ib_addr,i,j),UVM_LOW)
  	       success_hit = 1;
  	       return vf_config[i][j];
  	     end
  	     end //}
         end //}
        end //}
      end //}


      if(!success_hit) begin
         `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: pkt_type=%0s with Inbound address (%0h) doesnot hit any PF/VF",pkt_type,ib_addr),UVM_LOW)
      end

  endfunction: pick_dev_cfg_for_ib_addr


  //-----------------------------------------------------------------------------------
  // Function: populate_metadata_info_for_ib_addr
  // Description: Below API can be used to populate meta data of HLS_IB_P/NP interface
  //-----------------------------------------------------------------------------------
  function  cdn_pcie_hpa_ib_meta_p_np_s populate_metadata_info_for_ib_addr (input bit [63:0] ib_addr, input string pkt_type="MEM") ;//Pkt_type = MEM/IO
    bit [63:0] start_addr;
    bit [63:0] end_addr;
    bit success_hit;
    cdn_pcie_hpa_ib_meta_p_np_s meta_s;
    bit [63:0] l_total_vf_aperture_aligned_mask;
    bit [63:0] l_total_vf_aperture_aligned_addr;
    bit target_addr_crossing_total_vf_aperture;


    if((pkt_type=="MEM") && m_cxl_negotiation ==  CXL_1_1) begin
      start_addr = m_cxl_io_rcrb_bar + 2**12;
      end_addr = m_cxl_io_rcrb_bar + 2**13;
      if(ib_addr >= start_addr && ib_addr <= end_addr) begin
        `uvm_info(get_full_name(),$psprintf("DEBUG_CXL_RCRB_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF0",pkt_type,ib_addr),UVM_LOW)
        success_hit = 1;
        meta_s.pf = 0;
        meta_s.vf = 15'h0;
        meta_s.cxl_io = 1'b1;
        meta_s.vf_or_pf= 1'b0;
        meta_s.bar = 0;
        meta_s.bar_aperture = 5; // always 4k
        meta_s.bar_prefetchable = 0;
        return meta_s;
      end

      // Mem bar decoding
      start_addr = m_cxl_io_membar;
      end_addr = m_cxl_io_membar + 2**m_cxl_io_membar_aperture;
      if(ib_addr >= start_addr && ib_addr <= end_addr) begin
        `uvm_info(get_full_name(),$psprintf("DEBUG_CXL_RCRB_BAR_HIT: pkt_type=%0s with Inbound address (%0h) hits PF0",pkt_type,ib_addr),UVM_LOW)
        success_hit = 1;
        meta_s.pf = 0;
        meta_s.vf = 15'h0;
        meta_s.cxl_io = 1'b1;
        meta_s.vf_or_pf= 1'b0;
        meta_s.bar = 1;
        meta_s.bar_aperture = m_cxl_io_membar_aperture;
        meta_s.bar_prefetchable = 0;
        return meta_s;
      end
    end


    //Search all available PFs first
    foreach(pf_config[i]) begin //{
      if(pf_config[i].m_fun_bar_info != null) begin //{
        foreach(pf_config[i].m_fun_bar_info.bars[bar_i]) begin //{
          if((bar_i inside {[2:5]}) && (i_cfg.strap_port_type inside {2})) continue;
          if(((pkt_type=="MEM") && (pf_config[i].m_fun_bar_info.bars[bar_i].bar_enable) &&
            ((pf_config[i].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
            (pf_config[i].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_NON_PREFETCH) ||
            (pf_config[i].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_PREFETCH) ||
            (pf_config[i].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH) ||
            (pf_config[i].m_fun_bar_info.bars[bar_i].bar_type == MEM_EROM_BAR_32))
             ) ||
             ((pkt_type=="IO") && (pf_config[i].m_fun_bar_info.bars[bar_i].bar_enable) && (pf_config[i].m_fun_bar_info.bars[bar_i].bar_type == IO_BAR))) begin //{
            
            start_addr = pf_config[i].m_fun_bar_info.bars[bar_i].start_addr;
            end_addr = pf_config[i].m_fun_bar_info.bars[bar_i].start_addr+ (2**(pf_config[i].m_fun_bar_info.bars[bar_i].get_decoded_bar_aperture())) -1;
            if(ib_addr >= start_addr && ib_addr <= end_addr) begin
              `uvm_info(get_full_name(),$psprintf("DEBUG_POPULATE_META_DATA: pkt_type=%0s with Inbound address (%0h) hits PF_%0d",pkt_type,ib_addr,i),UVM_LOW)
              success_hit = 1;
              meta_s.pf = pf_config[i].m_pf_num;
              meta_s.vf = 15'h0;
              meta_s.cxl_io = 1'b0;
              meta_s.vf_or_pf= 1'b0;
              meta_s.bar= bar_i; //TODO take care of EROM hit
              meta_s.bar_aperture = pf_config[i].m_fun_bar_info.bars[bar_i].bar_aperture;
              if(pf_config[i].m_fun_bar_info.bars[bar_i].bar_type inside {MEM_BAR_32_PREFETCH,MEM_BAR_64_PREFETCH})
                meta_s.bar_prefetchable = 1;
              else
                meta_s.bar_prefetchable = 0;
`ifdef HPA_ARCH2
              meta_s.generated_tlp = 0;
`endif
              return meta_s;
            end
          end //}
        end //}
      end //}
    end //}

    //Search all available VFs
    foreach(vf_config[i,j]) begin //{
      if(vf_config[i][j].m_fun_bar_info != null && pf_config[i].m_vf_en) begin //{ // VF should be enabled for particular PF.
        foreach(vf_config[i][j].m_fun_bar_info.bars[bar_i]) begin //{
          if((pkt_type=="MEM") && (vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
            ((vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
            (vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_NON_PREFETCH) ||
            (vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_PREFETCH) ||
            (vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH))) begin //{
            
            start_addr = vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr;
            end_addr = vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr+ (2**(vf_config[i][j].m_fun_bar_info.bars[bar_i].get_decoded_bar_aperture())) -1;

            if(ib_addr >= start_addr && ib_addr <= end_addr) begin
              `uvm_info(get_full_name(),$psprintf("DEBUG_POPULATE_META_DATA: pkt_type=%0s with Inbound address (%0h) hits PF_%0d VF_%0d",pkt_type,ib_addr,i,j),UVM_LOW)
              l_total_vf_aperture_aligned_mask = ~(((2**(vf_config[i][0].m_fun_bar_info.bars[bar_i].get_decoded_bar_aperture()))*pf_config[i].m_TotalVFs)-1);
              `uvm_info(get_full_name(),$psprintf("pf_config[%0d].m_TotalVFs =%0d, l_total_vf_aperture_aligned_mask=%0h", i, pf_config[i].m_TotalVFs, l_total_vf_aperture_aligned_mask),UVM_LOW)
              `uvm_info(get_full_name(),$psprintf("vf_config[%0d][0].m_fun_bar_info.bars[%0d].start_addr=%0h", i, bar_i, vf_config[i][0].m_fun_bar_info.bars[bar_i].start_addr),UVM_LOW)
              l_total_vf_aperture_aligned_addr = (l_total_vf_aperture_aligned_mask & vf_config[i][0].m_fun_bar_info.bars[bar_i].start_addr)+l_total_vf_aperture_aligned_mask;
              `uvm_info(get_full_name(),$psprintf("(l_total_vf_aperture_aligned_mask & vf_config[%0d][0].m_fun_bar_info.bars[%0d].start_addr)=%0h", i, bar_i, (l_total_vf_aperture_aligned_mask & vf_config[i][0].m_fun_bar_info.bars[bar_i].start_addr)),UVM_LOW)
              target_addr_crossing_total_vf_aperture = is_addr_crossing_total_vf_bar_aperture(ib_addr, l_total_vf_aperture_aligned_addr);
              success_hit = 1;
              meta_s.pf = vf_config[i][j].m_pf_num;
              meta_s.vf = vf_config[i][j].m_vf_num;
              meta_s.cxl_io = 1'b0;
              meta_s.vf_or_pf= 1'b1;
              meta_s.bar= bar_i;
              meta_s.bar_aperture = vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_aperture;
              if(vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type inside {MEM_BAR_32_PREFETCH,MEM_BAR_64_PREFETCH})
                meta_s.bar_prefetchable = 1;
              else
                meta_s.bar_prefetchable = 0;

`ifdef HPA_ARCH2
              meta_s.generated_tlp = 0;
`endif
              bar_coverage.sample(meta_s.pf, meta_s.vf, meta_s.bar, target_addr_crossing_total_vf_aperture);
              return meta_s;
            end
          end //}
        end //}
      end //}
    end //}


    if(!success_hit) begin
      `uvm_warning(get_full_name(),$psprintf("DEBUG_POPULATE_META_DATA: pkt_type=%0s with Inbound address (%0h) doesnot hit any PF/VF",pkt_type,ib_addr))
      meta_s.pf = 0;
      meta_s.vf = 0;
      meta_s.cxl_io = 0;
      meta_s.vf_or_pf= 0;
      meta_s.bar = 7; //No hit
      meta_s.bar_aperture = 6'h3F;
      meta_s.bar_prefetchable = 0;
`ifdef HPA_ARCH2
      meta_s.generated_tlp = 0;
`endif
      return meta_s;
    end

  endfunction: populate_metadata_info_for_ib_addr

  function bit is_addr_crossing_total_vf_bar_aperture(input bit [63:0] l_addr, bit [63:0] l_total_vf_aperture_aligned_addr);
    if(l_addr > l_total_vf_aperture_aligned_addr) begin
      //`uvm_fatal(get_full_name(),$psprintf("Address crossing total VF aperture alignment Addr=%0h, totalVF_aperture_aligned_address = %0h", l_addr, l_total_vf_aperture_aligned_addr))
      //`uvm_info(get_full_name(),$psprintf("Address crossing total VF aperture alignment Addr=%0h, totalVF_aperture_aligned_address = %0h", l_addr, l_total_vf_aperture_aligned_addr),UVM_LOW)
      return 1;
    end
    return 0;
  endfunction : is_addr_crossing_total_vf_bar_aperture

  //------------------------------------------------------------------------
  // Function: build_phase
  //------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    

    if (en_full_delay_sim) begin
    m_lm_ltssm_1ms_time_interval=1*1000;
    m_lm_ltssm_2ms_time_interval=2*1000;
    m_lm_ltssm_4ms_time_interval=4*1000;
    m_lm_ltssm_8ms_time_interval=8*1000;
    m_lm_ltssm_12ms_time_interval=12*1000;
    m_lm_ltssm_24ms_time_interval=24*1000;
    m_lm_ltssm_32ms_time_interval=32*1000;
    m_lm_ltssm_48ms_time_interval=48*1000;
    end 
    else begin
 //multiplying with scaling factor   
    m_lm_ltssm_1ms_time_interval=m_lm_ltssm_1ms_time_interval*hpa_timer.get_ltssm_timeout_scale();
    m_lm_ltssm_2ms_time_interval=m_lm_ltssm_2ms_time_interval*hpa_timer.get_ltssm_timeout_scale();
    m_lm_ltssm_4ms_time_interval=m_lm_ltssm_4ms_time_interval*hpa_timer.get_ltssm_timeout_scale();
    m_lm_ltssm_8ms_time_interval=m_lm_ltssm_8ms_time_interval*hpa_timer.get_ltssm_timeout_scale();
    m_lm_ltssm_12ms_time_interval=m_lm_ltssm_12ms_time_interval*hpa_timer.get_ltssm_timeout_scale();
    m_lm_ltssm_24ms_time_interval=m_lm_ltssm_24ms_time_interval*hpa_timer.get_ltssm_timeout_scale();
    m_lm_ltssm_32ms_time_interval=m_lm_ltssm_32ms_time_interval*hpa_timer.get_ltssm_timeout_scale();
    m_lm_ltssm_48ms_time_interval=m_lm_ltssm_48ms_time_interval*hpa_timer.get_ltssm_timeout_scale();
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
  // Function: calculate_p_np_cpl_header_credit
  //------------------------------------------------------------------------

 function int calculate_p_np_cpl_header_credit(logic [3:0] k_tl_rx_p_np_cpl_fifo_tlp_count,int k_num_cif);
    int max_hdr_credit;
    if(i_cfg.k_pasid_supported || i_cfg.k_ext_tph_supported)
      max_hdr_credit = k_tl_rx_p_np_cpl_fifo_tlp_count/(2*i_cfg.k_num_vcs);
    else
      max_hdr_credit = k_tl_rx_p_np_cpl_fifo_tlp_count/i_cfg.k_num_vcs;
    return  max_hdr_credit;
  endfunction

  function int calculate_p_data_credit(int k_num_cif);
    int max_data_credit_p;
    int k_prefix_present = (i_cfg.k_tph_supported || i_cfg.k_pasid_supported);
  //TODO :: max_data_credit_p = (i_cfg.k_posted_buffer_tlp_fifo_depth_encoded_val[k_num_cif] * i_cfg.k_datapath_wd/4 - i_cfg.k_posted_buffer_num_tlp_support_encoded_val[k_num_cif] *(1 + k_prefix_present))/i_cfg.k_num_vcs;
    return max_data_credit_p;
  endfunction

  function int calculate_np_data_credit(int k_num_cif);
    int max_data_credit_p,max_data_credit_np;
    int k_prefix_present = (i_cfg.k_tph_supported || i_cfg.k_pasid_supported);
  //TODO :: max_data_credit_np = (i_cfg.k_nonposted_buffer_tlp_fifo_depth_encoded_val[k_num_cif] * i_cfg.k_datapath_wd/4 - i_cfg.k_nonposted_buffer_num_tlp_support_encoded_val[k_num_cif] *(1 + k_prefix_present))/i_cfg.k_num_vcs;
    return max_data_credit_np;
  endfunction

  function int calculate_cpl_data_credit(int k_num_cif);
    int max_data_credit_cpl;
    int k_prefix_present = (i_cfg.k_tph_supported || i_cfg.k_pasid_supported);
  //TODO :: max_data_credit_cpl = (i_cfg.k_compl_buffer_tlp_fifo_depth_encoded_val[k_num_cif] * i_cfg.k_datapath_wd/4 - i_cfg.k_compl_buffer_num_tlp_support_encoded_val[k_num_cif] *(1 + k_prefix_present))/i_cfg.k_num_vcs;
    return max_data_credit_cpl;
  endfunction

  function cdn_pcie_hpa_pf_vf_s get_pf_vf_from_address(bit [31:0] addr);
    cdn_pcie_hpa_pf_vf_s pf_vf_s;
    bit [31:0] addr_lcl;
    //addr[25:24] indicates LM registers access
    if(addr[25:24] == 2'b01)
      addr_lcl = addr[23:14];
    else
      addr_lcl = addr[23:12];
    if(addr_lcl < l_num_enabled_pfs) begin
      if(addr[25:24] == 2'b01)
        pf_vf_s.pf = addr[23:14];
      else
        pf_vf_s.pf = addr[23:12];
      pf_vf_s.vf = -1;
      pf_vf_s.is_vf_valid = 0;
      return (pf_vf_s);
    end// else begin
    else if(i_cfg.k_num_vfs <255) begin //{ if(addr_lcl[23:14] < l_num_enabled_pfs)
      //if(i_cfg.strap_ari_enable) begin
      //  for (int pf_i = 0; pf_i < l_num_enabled_pfs; pf_i++ ) begin
      //    for (int vf_i = 0; vf_i < pf_config[pf_i].m_NumVFs; vf_i++) begin
      //      if(vf_config[pf_i][vf_i].m_req_id.function_num == addr_lcl) begin
      //        pf_vf_s.pf = pf_i;
      //        pf_vf_s.vf = vf_i;
      //        pf_vf_s.is_vf_valid = 1;
      //        return(pf_vf_s);
      //      end
      //    end
      //  end
      //end else begin
        for (int pf_i = 0; pf_i < l_num_enabled_pfs; pf_i++ ) begin
          for (int vf_i = 0; vf_i < pf_config[pf_i].m_NumVFs; vf_i++) begin
            if({vf_config[pf_i][vf_i].m_req_id.device_num,vf_config[pf_i][vf_i].m_req_id.function_num} == addr_lcl) begin
              pf_vf_s.pf = pf_i;
              pf_vf_s.vf = vf_i;
              pf_vf_s.is_vf_valid = 1;
              return(pf_vf_s);
            end
          end
        end
      //end
    end else begin //{ else if(i_cfg.k_num_vfs <255)
      //if(i_cfg.strap_ari_enable) begin
      //  for (int pf_i = 0; pf_i < l_num_enabled_pfs; pf_i++ ) begin
      //    for (int vf_i = 0; vf_i < pf_config[pf_i].m_NumVFs; vf_i++) begin
      //      if({vf_config[pf_i][vf_i].m_req_id.bus_num,vf_config[pf_i][vf_i].m_req_id.function_num} == addr_lcl) begin
      //        pf_vf_s.pf = pf_i;
      //        pf_vf_s.vf = vf_i;
      //        pf_vf_s.is_vf_valid = 1;
      //        return(pf_vf_s);
      //      end
      //    end
      //  end
      //end else begin
        for (int pf_i = 0; pf_i < l_num_enabled_pfs; pf_i++ ) begin
          for (int vf_i = 0; vf_i < pf_config[pf_i].m_NumVFs; vf_i++) begin
            if({vf_config[pf_i][vf_i].m_req_id.bus_num,vf_config[pf_i][vf_i].m_req_id.device_num,vf_config[pf_i][vf_i].m_req_id.function_num} == addr_lcl) begin
              pf_vf_s.pf = pf_i;
              pf_vf_s.vf = vf_i;
              pf_vf_s.is_vf_valid = 1;
              return(pf_vf_s);
            end
          end
        end
      //end
    end

  endfunction

  //------------------------------------------------------------------------
  // Function: get_symbol_time_delay
  // This Function will convert the internal delay into symbol time
  //------------------------------------------------------------------------
  virtual function int unsigned get_symbol_time_delay(int delay);
    real time_period;
    real symbol_time;
    int symbol_time_int;
    int mf;
    int m_max_link_width;
    if((k_pcie_rate_max==0) && (m_max_link_width == 32)) begin time_period = 0.0625 ;mf = 4;end
    if((k_pcie_rate_max==0) && (m_max_link_width == 16)) begin time_period = 0.125 ;mf = 8;end
    if((k_pcie_rate_max==1) && (m_max_link_width == 32))begin time_period = 0.125  ;mf = 4;end
    if((k_pcie_rate_max==1) && (m_max_link_width == 16))begin time_period = 0.25  ;mf = 8;end
    if((k_pcie_rate_max==2) && (m_max_link_width == 32))begin time_period = 0.25  ;mf = 4;end
    if((k_pcie_rate_max==2) && (m_max_link_width == 16))begin time_period = 0.5  ;mf = 8;end
    if((k_pcie_rate_max==3) && (m_max_link_width == 32))begin time_period = 0.5  ;mf = 4;end
    if((k_pcie_rate_max==3) && (m_max_link_width == 16))begin time_period = 1.0  ;mf = 8;end
    if((k_pcie_rate_max==4) && (m_max_link_width == 32))begin time_period = 1.0;mf = 4;end
    if((k_pcie_rate_max==4) && (m_max_link_width == 16))begin time_period = 2.0 ;mf = 8;end
    symbol_time  = delay/((time_period) *mf /*mf:: for 32 it is 4,for 16 it is 8*/);
   `uvm_info(get_full_name(), $sformatf("DEBUG_ack_freq::Pcie generation is %0d\t ack_nak_latency in symbol time is %0f\t  maximum link width is %0d\t ack nak latency in delay is %0d\t", k_pcie_rate_max,symbol_time,m_max_link_width,delay), UVM_DEBUG)
   symbol_time_int = symbol_time;
    return(symbol_time_int); //
  endfunction : get_symbol_time_delay

  function void do_print (uvm_printer printer);
	super.do_print(printer);
	foreach(dut_credit_scenario[i])
	printer.print_string($psprintf("dut_credit_scenario[%0s]",i),  dut_credit_scenario[i].name());
	foreach(bfm_credit_scenario[i])
	printer.print_string($psprintf("bfm_credit_scenario[%0s]",i),  bfm_credit_scenario[i].name());


  endfunction : do_print

  function void initialize_ide_selective_stream();
    cdn_hpa_pcie_tlp_requester_id_s l_req_id_base;
    cdn_hpa_pcie_tlp_requester_id_s l_req_id_limit;
    
    if(i_cfg.strap_ari_enable && (m_port_type == CDN_HPA_PCIE_USP) && (m_rp_req_id.device_num == 0) ) begin
      l_req_id_base  = {m_rp_req_id.bus_num,5'h0,3'h0};
    end
    else begin
      l_req_id_base  = (m_port_type == CDN_HPA_PCIE_DSP) ? {m_ep_req_id.bus_num,m_ep_req_id.device_num,3'h0} : {m_rp_req_id.bus_num,m_rp_req_id.device_num,3'h0};
    end

    l_req_id_limit = (m_port_type == CDN_HPA_PCIE_DSP) ? {m_ep_req_id.bus_num,5'h1F /*------------*/,3'h7} : {m_rp_req_id.bus_num,5'h1F /*------------*/,3'h7};

    foreach(ide_cfg.m_ide_selective_stream_config[i]) begin
      ide_cfg.m_ide_selective_stream_config[i].initialize_RID_association_block(l_req_id_base, l_req_id_limit, 1);//(rid_base, rid_limit, rid_valid);
      ide_cfg.m_ide_selective_stream_config[i].create_addr_association_block();
      if(enable_segmentation) ide_cfg.m_ide_selective_stream_config[i].initialize_segment(destination_segment);
    end
  endfunction : initialize_ide_selective_stream

  //----------------------------------------------------------------------------
  // Function: ram_err_injection_enable
  //----------------------------------------------------------------------------
  virtual function bit ram_err_injection_enable();
    if (m_p_ram_err_injection_enable[0] ||
        m_np_ram_err_injection_enable[0] ||
        m_cpl_ram_err_injection_enable[0]) begin
      ram_err_injection_enable = 1;
    end
    if(m_nprt_ram_err_injection_enable[0]) begin
      ram_err_injection_enable = 1;
    end
    if(m_bytecnt_ram_err_injection_enable[0]) begin
      ram_err_injection_enable = 1;
    end
  endfunction : ram_err_injection_enable

  //----------------------------------------------------------------------------
  // Function: ram_axi_err_injection_enable
  //----------------------------------------------------------------------------
  virtual function bit ram_axi_err_injection_enable();
    if (m_axi_ram_err_injection_enable) begin
      ram_axi_err_injection_enable = 1;
    end
  endfunction : ram_axi_err_injection_enable

  //----------------------------------------------------------------------------
  // Function: ram_dma_err_injection_enable
  //----------------------------------------------------------------------------
  virtual function bit ram_dma_err_injection_enable();
    if (m_dma_ram_err_injection_enable) begin
      ram_dma_err_injection_enable = 1;
    end
  endfunction : ram_dma_err_injection_enable

  //----------------------------------------------------------------------------
  // Function: ram_uncorrectable_err_injection_enable
  //----------------------------------------------------------------------------
  virtual function bit ram_uncorrectable_err_injection_enable();
    if(m_p_ram_err_injection_enable[1] ||
       m_np_ram_err_injection_enable[1] ||
       m_cpl_ram_err_injection_enable[1]) begin
      ram_uncorrectable_err_injection_enable = 1;
    end
    if(m_nprt_ram_err_injection_enable[1]) begin
      ram_uncorrectable_err_injection_enable = 1;
    end
    if(m_bytecnt_ram_err_injection_enable[1]) begin
      ram_uncorrectable_err_injection_enable = 1;
    end
  endfunction : ram_uncorrectable_err_injection_enable
  //----------------------------------------------------------------------------
  // Function: ram_axi_uncorrectable_err_injection_enable
  //----------------------------------------------------------------------------
  virtual function bit ram_axi_uncorrectable_err_injection_enable();
    if (m_axi_ram_err_injection_enable[1]) begin
      ram_axi_uncorrectable_err_injection_enable = 1;
    end
  endfunction : ram_axi_uncorrectable_err_injection_enable
  //----------------------------------------------------------------------------
  // Function: ram_dma_uncorrectable_err_injection_enable
  //----------------------------------------------------------------------------
  virtual function bit ram_dma_uncorrectable_err_injection_enable();
    if (m_dma_ram_err_injection_enable[1]) begin
      ram_dma_uncorrectable_err_injection_enable = 1;
    end
  endfunction : ram_dma_uncorrectable_err_injection_enable
  //----------------------------------------------------------------------------
  // Function: ram_replay_uncorrectable_err_injection_enable
  //----------------------------------------------------------------------------
  virtual function bit ram_replay_uncorrectable_err_injection_enable();
    if(m_replay_buffer_ram_err_injection_enable[1] ||
       m_replay_buffer_ctrl_ram_err_injection_enable[1]) begin
      ram_replay_uncorrectable_err_injection_enable = 1;
    end
  endfunction : ram_replay_uncorrectable_err_injection_enable

//  virtual function int get_min_mrrs_from_all_func();
//    int mrrs_min = pf_config[0].m_max_rd_req_size;
//    foreach (pf_config[func]) begin
//      if (pf_config[func].m_max_rd_req_size < mrrs_min) begin
//        mrrs_min = pf_config[func].m_max_rd_req_size;
//      end
//    end
//    return mrrs_min;
//  endfunction : get_min_mrrs_from_all_func
  virtual function int get_min_mrrs_from_all_func();
    int mrrs_min = pf_config[0].m_max_rd_req_size;
    int pf_enabled = ('hFFFF_FFFF & (~m_is_pf_disabled_by_lm));
    foreach (pf_config[func]) begin
      if(pf_enabled[func]==1)begin
        if(pf_config[func].m_max_rd_req_size < mrrs_min) begin
          mrrs_min = pf_config[func].m_max_rd_req_size;
        end
      end
    end
    return mrrs_min;
  endfunction : get_min_mrrs_from_all_func

  virtual function int get_min_rrs_in_dw();
    get_min_rrs_in_dw = (32<<get_min_mrrs_from_all_func());
  endfunction: get_min_rrs_in_dw

  virtual function int get_min_rrs_in_bytes();
    get_min_rrs_in_bytes = (128<<get_min_mrrs_from_all_func());
  endfunction: get_min_rrs_in_bytes

  virtual function void check_for_req_length_against_mrrs_programmed(bit [9:0] l_tlp_length);
    if (l_tlp_length > get_min_rrs_in_dw()) begin
      `uvm_error(get_full_name(),$sformatf("Packet length in Read Req is more than Minimum programmed, m_tlp_length =%0h, min_length_of_all_func =%0h", l_tlp_length, get_min_rrs_in_dw()))
    end
    else begin
      `uvm_info(get_full_name(),$sformatf("Packet length in Read Req is less than or equal to Minimum programmed, m_tlp_length =%0h, min_length_of_all_func =%0h", l_tlp_length, get_min_rrs_in_dw()), UVM_LOW)
      cg__mrrs_rd_req_size.sample(1);
    end
  endfunction : check_for_req_length_against_mrrs_programmed

  virtual function void cover_interrupt_message_num(bit[4:0] l_intr_msg_num);
      cg__interrupt_message_num.sample(l_intr_msg_num);
  endfunction : cover_interrupt_message_num

  virtual function void cover_tdisp_reg_mon(int tdisp_reg_block = 0, bit[1:0] tdisp_reg_attr = 0, bit[1:0] tdisp_reg_origin = 0, bit tdisp_attr_check = 0, bit tdisp_dbg_check = 0, bit tdisp_reg_access_check = 0, bit tdi_state_change_check = 0, bit error_status_check = 0, bit ide_strm_state_check = 0, bit ide_strm_lock_check = 0, bit tdisp_access_nse = 0, bit strap_is_rp = 0, bit lm_access_via_vsec = 0, bit tdi_state_change_when_flr = 0, bit tdi_state_change_by_app = 0, bit ide_reg_default_attr = 0, bit rmeda_reg_default_attr = 0, bit tdisp_reg_default_attr = 0, bit rmeda_tdisp_en_1_to_0 = 0, bit rmeda_tdisp_en_w_prot_forever = 0, bit msg2wr_reg_default_attr = 0);

      tdisp_reg_mon_cg.sample(tdisp_reg_block, tdisp_reg_attr, tdisp_reg_origin, tdisp_attr_check, tdisp_dbg_check, tdisp_reg_access_check, tdi_state_change_check, error_status_check, ide_strm_state_check, ide_strm_lock_check, tdisp_access_nse, strap_is_rp, lm_access_via_vsec, tdi_state_change_when_flr, tdi_state_change_by_app, ide_reg_default_attr, rmeda_reg_default_attr, tdisp_reg_default_attr, rmeda_tdisp_en_1_to_0, rmeda_tdisp_en_w_prot_forever, msg2wr_reg_default_attr);

  endfunction : cover_tdisp_reg_mon

  //---------------------------------------------------------------------------
  // Function: assign_reg_default_value
  // Function to assign config variable with default values of register 
  //---------------------------------------------------------------------------
  function void assign_reg_default_value();
      if(is_dut_config) begin 
         `include "default/cdn_pcie_hpa_dev_top_pure_default_policy.h"
      end
  endfunction : assign_reg_default_value

  function void reset_error_injection_knobs();
    `uvm_info("DEBUG_ISR","Resetting error injection knobs",UVM_LOW)
    this.acs_err_inj      = 0;
    this.ur_err_inj       = 0;
    this.posted_rsvd_type_err_inj       = 0;
    this.nonposted_rsvd_type_err_inj    = 0;
    this.completion_rsvd_type_err_inj   = 0;
    this.none_rsvd_type_err_inj   = 0;
    this.cfg_ur_err_inj   = 0;
    this.mf_err_inj       = 0;
    this.ecrc_err_inj     = 0;
    this.poisoned_err_inj = 0;
    this.inject_err_en    = 0;
    this.err_en_from_all_traffic = 0;
    this.cpl_err_inj      = 0;
    this.tlp_err_inj      = 0;
    this.dlp_err_inj      = 0;
    this.dllp_err_inj     = 0;
    this.dll_flit_err_inj = 0;
    this.plp_err_inj      = 0;
    this.ide_err_inj      = 0;
    this.uio_tlp_err_inj  = 0;
  endfunction : reset_error_injection_knobs

  //------------------------------------------------------------------------
  // Task: do_rp_msi_expected_pkt() : Test injection of MSI interrupt behaviour in RP mode, without actual MSI packets from the VIP. // PCIE-17040
  //------------------------------------------------------------------------
  task do_rp_msi_expected_pkt(bit msi_error_done);
    //exp_msi_fields_object       exp_msi_fields_h_q[$];
    exp_msi_fields_object       exp_msi_fields_h;
    bit [15:0] msi_inject_test_payload;

    msi_inject_test_payload = msi_inject_test_payload_q.pop_front();
          `uvm_info("LTI XLATION", $sformatf("DEV_TOP_Payload_value=%0p", msi_inject_test_payload), UVM_DEBUG)

    // Push this internally generated MSI packet to the TB posted SB
    // Only if the MSI injection is allowed
    if(pf_config[0].m_msi_en) // Check if MSI packet injection is allowed
    begin
      exp_msi_fields_h            = new();

      if(!m_sbsa_msi_addr_sel || msi_error_done==1)
      begin
        exp_msi_fields_h.m_tlp_type    = (m_sbsa_ctrl_ib_msi_hi_addr==0) ? 'd3 /*CDN_HPA_PCIE_TLP_TYPE_MWr_32*/ : 'd6 /*CDN_HPA_PCIE_TLP_TYPE_MWr_64*/;
        exp_msi_fields_h.m_tlp_addr    = {m_sbsa_ctrl_ib_msi_hi_addr,m_sbsa_ctrl_ib_msi_low_addr}; 
      end
      else if (lti_en && lti_xlate_msi) begin
        if (!translated_addr.exists({pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr} >> 12)) begin
          translated_addr[({pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr} >> 12)] = lti_msi_physical_addr;
          `uvm_info("LTI XLATION", $sformatf(" Setting SMMU to translate addr %0h to %0h", {pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr},lti_msi_physical_addr), UVM_DEBUG)
        end
        exp_msi_fields_h.m_tlp_addr         = {translated_addr[({pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr} >> 12)][63:12],pf_config[0].m_msi_msg_addr[11:0]};
        `uvm_info("LTI XLATION", $sformatf(" Translated MSI message address %0h to %0h", {pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr}, exp_msi_fields_h.m_tlp_addr), UVM_DEBUG)
        exp_msi_fields_h.m_tlp_type    = pf_config[0].m_msi_64bit_addr_cap ? 'd6 /*CDN_HPA_PCIE_TLP_TYPE_MWr_64*/ : 
                                         (exp_msi_fields_h.m_tlp_addr & 64'hffff_ffff_0000_0000) ? 'd6 : 'd3 /*CDN_HPA_PCIE_TLP_TYPE_MWr_32*/;
      end
      else
      begin
        exp_msi_fields_h.m_tlp_type    = pf_config[0].m_msi_64bit_addr_cap ? 'd6 /*CDN_HPA_PCIE_TLP_TYPE_MWr_64*/ : 'd3 /*CDN_HPA_PCIE_TLP_TYPE_MWr_32*/;
        exp_msi_fields_h.m_tlp_addr    = {pf_config[0].m_msi_msg_upper_addr, pf_config[0].m_msi_msg_addr};
      end

      if (lti_en && lti_xlate_msi) begin
        exp_msi_fields_h.m_tlp_td         = pf_config[0].m_ecrc_gen_en;
      end
      if (lti_en && msi_inject_test_enable) begin
        exp_msi_fields_h.m_tlp_td         = pf_config[0].m_ecrc_gen_en;
        `uvm_info("DEBUG_TD_MSI",$sformatf("DEBUG MSI INJECT: exp_msi_fields_h.m_tlp_td=%0d EXP_MSI_PACKET=%0p",exp_msi_fields_h.m_tlp_td,exp_msi_fields_h),UVM_HIGH)

      end        
      exp_msi_fields_h.requester_id       = {m_rp_req_id.bus_num, m_rp_req_id.device_num, 3'b000};
      exp_msi_fields_h.m_tlp_first_dw_be  = 4'hF;
      
      if(i_cfg.scenario.is_flit_mode())
      exp_msi_fields_h.m_tlp_last_dw_be   = 4'hF;
      else
      exp_msi_fields_h.m_tlp_last_dw_be   = 4'h0;
      
      exp_msi_fields_h.m_tlp_length         = 1;
      exp_msi_fields_h.m_tlp_payload = new[4*exp_msi_fields_h.m_tlp_length];
      //       exp_msi_fields_h.m_tlp_payload[0] = pf_config[0].m_msi_data[0 +: 8];
      //       exp_msi_fields_h.m_tlp_payload[1] = pf_config[0].m_msi_data[8 +: 8];
      exp_msi_fields_h.m_tlp_payload[0] = msi_inject_test_payload[0 +: 8];
      exp_msi_fields_h.m_tlp_payload[1] = msi_inject_test_payload[8 +: 8];
      exp_msi_fields_h.m_tlp_payload[2] = 8'h0;
      exp_msi_fields_h.m_tlp_payload[3] = 8'h0;
      // exp_msi_fields_h.print();
      // `uvm_info(get_full_name(),$psprintf("DEBUG MSI INJECT: BEFORE MSI QUEUE SIZE =%0d", exp_msi_fields_q.size()),UVM_HIGH)
      exp_msi_fields_q.push_back(exp_msi_fields_h);
       `uvm_info("DEBUG_TD_MSI",$sformatf("DEBUG MSI INJECT: exp_msi_fields_h.m_tlp_td=%0d EXP_MSI_PACKET=%0p",exp_msi_fields_h.m_tlp_td,exp_msi_fields_h),UVM_HIGH)

      // `uvm_info(get_full_name(),$psprintf("DEBUG MSI INJECT: AFTER MSI QUEUE SIZE =%0d", exp_msi_fields_q.size()),UVM_HIGH)
      if(msi_error_done==1) begin
        if(lti_en_msi_xlate_error_faultabort_status) m_msi_fault_abort_error = 1;
        if(lti_en_msi_xlate_error_faultrazwi_status) m_msi_fault_razwi_error = 1;
        if(lti_en_msi_xlate_unsupported_resp_status) m_msi_lti_ur_error = 1;
      end

      `uvm_info(get_full_name(),$psprintf("MSI_ERROR_INJECTED = %0d ,exp_msi_fields_h: %0s", msi_error_done,exp_msi_fields_h.sprint()),UVM_HIGH)

    end // if (pf_config[0].m_msi_en)
 
    //end
  endtask // do_rp_msi_expected_pkt

endclass
