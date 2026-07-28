`ifndef CDN_HPA_PCIE_TLP_SV
`define CDN_HPA_PCIE_TLP_SV

typedef class cdn_hpa_pcie_tlp_vseqr;

typedef class cdn_hpa_pcie_tlp_base;
typedef class cdn_hpa_pcie_tlp;
typedef class cdn_pcie_hpa_compl_wrapper;
typedef class cdn_pcie_hpa_compl_lut_item;
typedef class cdn_hpa_user_err_data;

//------------------------------------------------------------------------
// Class: cdn_hpa_pcie_tlp_base
// This Class represents Base class for PCIe tlp which contains all the fields & constranints of the PCIe TLP
// This enables to re-randomize HPA tlp at post_randomize phase of cdn_hpa_pcie_tlp class
//------------------------------------------------------------------------
class cdn_hpa_pcie_tlp_base extends uvm_sequence_item;
  //---------------------------------------------------------------------------
  // Field: RcCfg
  // This Field is a handler for denali pcie config for root complex
  //---------------------------------------------------------------------------
  denaliPcieConfig RcCfg;
  //---------------------------------------------------------------------------
  // Field: EpCfg
  // This Field is a handler for denali pcie config for end point
  //---------------------------------------------------------------------------
  denaliPcieConfig EpCfg;
  //---------------------------------------------------------------------------
  // Field: tx_bfm_tlp_seq_num_q[$]
  // This Field is a transmit side sequence number reference queue
  //---------------------------------------------------------------------------
  int           tx_bfm_tlp_seq_num_q[$];
  //---------------------------------------------------------------------------
  // Field: rx_mon_tlp_seq_num_q[$]
  // This Field is a  passive agent receive side sequence number reference queue
  //---------------------------------------------------------------------------
  int           rx_mon_tlp_seq_num_q[$];
  //---------------------------------------------------------------------------
  // Field: corrpt_seq_num_flag_rx
  // This Field is a flag to check for the corrupt sequence number
  //---------------------------------------------------------------------------
  int           corrpt_seq_num_flag_rx;
  //---------------------------------------------------------------------------
  // Field: corrpt_dup_seq_num_flag_rx
  // This Field is a flag to check for the duplicate sequence number
  //---------------------------------------------------------------------------
  int           corrpt_dup_seq_num_flag_rx;
  //---------------------------------------------------------------------------
  // Field: last_seq_num
  // This Field is a last_seq_num which will be used to generate fault sequence
  // number in case of error injection
  int last_seq_num;
  //---------------------------------------------------------------------------
  // Field: first_seq_num
  // This Field is a first_seq_num which will be used to generate fault sequence
  // number in case of error injection
  //---------------------------------------------------------------------------
  int first_seq_num;

  //---------------------------------------------------------------------------
  // Field: acked_pkt
  // This is a utility field used in passive monitor to check if packet is acked
  //---------------------------------------------------------------------------
  int acked_pkt;

  //---------------------------------------------------------------------------
  // Field: ob_vip_processing_done
  // This is a utility field used in passive monitor to check if an OB packet is
  // processed by TL_TX_packet callback
  //---------------------------------------------------------------------------
  int ob_vip_processing_done;

  //---------------------------------------------------------------------------
  // Field: m_cfg_info
  // This structure stores vital information to extract devie config for a tlp
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_cfg_info_t m_cfg_info;
  bit m_cfg_info_valid;
  //---------------------------------------------------------------------------
  // Field: m_tlp_dir
  // This structure direction information w.r.t DUT for a tlp
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_dir_t m_tlp_dir; //inbound = 0; outbound = 1
  //------------------------------------------------------------------------
  // PHYSICAL MEMBER VARIABLES.
  //------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Field: pri_msi_msix_msg
  // This Field is makes a MSI/MSIx TLP route through Pins
  //---------------------------------------------------------------------------
  rand bit pri_msi_msix_msg;
  bit is_perf_mode;
  bit is_pkt_w_enderr;
  bit detected_ob_error;
  //---------------------------------------------------------------------------
  // Field: m_hdr_fmt
  // This Field is a tlp header format
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_fmt_t          m_hdr_fmt;
  //---------------------------------------------------------------------------
  // Field: m_hdr_type
  // This Field is a tlp header type
  //---------------------------------------------------------------------------
  rand bit [4:0]                       m_hdr_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_t9
  // This Field is a tlp tag_9 bit which will be useful to detect the
  // completion status of the transaction
  //---------------------------------------------------------------------------
  rand bit                             m_tlp_t9;
  //---------------------------------------------------------------------------
  // Field: m_tlp_tc
  // This Field is a tlp traffic class
  //---------------------------------------------------------------------------
  rand bit [2:0]                       m_tlp_tc;
  rand bit                             m_tlp_tc_has_active_ide_stream;
  rand bit [2:0]                       m_tlp_vc;
  //---------------------------------------------------------------------------
  // Field: m_tlp_tc
  // This Field is passes scenario specific error type for error injection
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_error_type_t   m_scenario_error_inject;

  //---------------------------------------------------------------------------
  // Field: error_injection_via_vip
  // This Field is a flag for enabling error injection using VIP
  //---------------------------------------------------------------------------
  bit  error_injection_via_vip;

  //---------------------------------------------------------------------------
  // Field: m_tlp_t8
  // This Field is a tlp tag_8 bit which will be useful to detect the
  // completion status of the transaction
  //---------------------------------------------------------------------------
  rand bit                             m_tlp_t8;
  //---------------------------------------------------------------------------
  // Field: m_tlp_attr1
  // This Field is a TLP attribute which will be used for ordering and snopping
  //---------------------------------------------------------------------------
  rand bit                             m_tlp_attr1;
  // Obne bit RSVD, May use for packing//TODO
  //---------------------------------------------------------------------------
  // Field: m_tlp_rsvd1
  // Thsi Field is a one bit reserved may use for packing
  //---------------------------------------------------------------------------
  rand bit                             m_tlp_rsvd1;
  //---------------------------------------------------------------------------
  // Field: m_tlp_ln
  // This Field is a tlp light weight notification
  //---------------------------------------------------------------------------
  rand bit                             m_tlp_ln;
  //---------------------------------------------------------------------------
  // Field: m_tlp_th
  // This Field is a tlp hint which will enable all the bytes in case of read
  //---------------------------------------------------------------------------
  rand bit                             m_tlp_th;
  //---------------------------------------------------------------------------
  // Field: m_tlp_td
  // This Field is a tlp digest which indicates the presence of ecrc
  //---------------------------------------------------------------------------
  rand bit                             m_tlp_td;
  //---------------------------------------------------------------------------
  // Field: m_tlp_ep
  // This Field is a tlp error poison bit which will be used for error injection
  //---------------------------------------------------------------------------
  rand bit                             m_tlp_ep;
  //---------------------------------------------------------------------------
  // Field: m_tlp_attr0
  // This field is a attribute which indcates the ordering and relaxed ordering of the packet
  //---------------------------------------------------------------------------
  rand bit [1:0]                       m_tlp_attr0;
  // m_tlp_addr tranlation type//TODO
  //---------------------------------------------------------------------------
  // Field: m_tlp_at_type
  // This Field is a address translation type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_at_type_t      m_tlp_at_type;
  // TLp length//TODO
  //---------------------------------------------------------------------------
  // Field: m_tlp_length
  // This Field is a  tlp length
  //---------------------------------------------------------------------------
  rand bit [9:0]                       m_tlp_length;

  // Tag scale
  //---------------------------------------------------------------------------
  // Field: m_tlp_tagscale
  // This Field is a tlp tagscale(For 10 bit tags: T9,T8)
  //---------------------------------------------------------------------------
  rand bit [1:0]                       m_tlp_tagscale;

  //---------------------------------------------------------------------------
  // Field: m_tlp_14_bit_tagscale
  // This Field is a tlp tagscale(For 14 bit tags: tag[13:10]
  //---------------------------------------------------------------------------
  rand bit [3:0]                       m_tlp_14_bit_tagscale;

  //---------------------------------------------------------------------------
  // Field: m_tlp_requester_id
  // This Field is a tlp requestor id
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_requester_id_s m_tlp_requester_id;
  rand cdn_hpa_pcie_tlp_requester_id_s m_tlp_requester_id_tb;
  //---------------------------------------------------------------------------
  // Field: m_tlp_completer_id
  // This Field is a  tlp completor id
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_requester_id_s m_tlp_completer_id;

  //---------------------------------------------------------------------------
  // Field: m_tlp_tag
  // This Filed is a 8 bit tags which will be useful to check the completion
  // status of the transction
  //---------------------------------------------------------------------------
  rand bit [7:0]                       m_tlp_tag;

  //---------------------------------------------------------------------------
  // Field: m_tag_err
  // This field is used to enabled modification of tag
  // (which is by default generated by active bfm internally)
  //---------------------------------------------------------------------------
  bit                             m_tag_modify;

  //---------------------------------------------------------------------------
  // Field: m_tlp_last_dw_be
  // This Field is a last double word byte enable
  //---------------------------------------------------------------------------
  rand bit [3:0]                       m_tlp_last_dw_be;
  //---------------------------------------------------------------------------
  // Field: m_tlp_first_dw_be
  // This Field is a first double word byte enable
  //---------------------------------------------------------------------------
  rand bit [3:0]                       m_tlp_first_dw_be;
  //---------------------------------------------------------------------------
  // Field: m_tlp_st_tag
  // This Field is steering tag bit
  //---------------------------------------------------------------------------
  rand bit [15:0]                      m_tlp_st_tag;

  //---------------------------------------------------------------------------
  // Field: m_tlp_addr
  // This field is a tlp address of 64/32 bits
  //---------------------------------------------------------------------------
  rand bit [63:0]                      m_tlp_addr;

  //---------------------------------------------------------------------------
  // Field: m_tlp_ext_reg_num
  // This Field is a exteneded register number
  //---------------------------------------------------------------------------
  rand bit [3:0]                             m_tlp_ext_reg_num;
  //---------------------------------------------------------------------------
  // Field: m_tlp_reg_num
  // This Field constains the tlp register number
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_tlp_reg_num;

  //---------------------------------------------------------------------------
  // Field: m_tlp_msg_code
  // This Field is a tlp message code
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_msg_type_t           m_tlp_msg_code;

  rand bit [1:0]                             m_tlp_ecs;

  rand bit                                   m_tlp_is_selective_sync_msg;
  //---------------------------------------------------------------------------
  // Field: m_tlp_msg_rout_type
  // This Field is a tlp message route type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_msg_routing_t        m_tlp_msg_rout_type;
  rand cdn_hpa_pcie_tlp_routing_t            m_tlp_rout_type;

  //---------------------------------------------------------------------------
  // Field: m_tlp_cpl_status
  // This Field is a tlp completion status
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_cpl_status_type_t        m_tlp_cpl_status;
  //---------------------------------------------------------------------------
  // Field: m_tlp_cpl_bcm
  // This Field is a tlp completion byte count modified
  //---------------------------------------------------------------------------
  rand bit                                   m_tlp_cpl_bcm;
  //---------------------------------------------------------------------------
  // Field: m_tlp_cpl_byte_cnt
  // This Field is a  tlp completion byte count
  //---------------------------------------------------------------------------
  rand bit [11:0]                            m_tlp_cpl_byte_cnt;
  //---------------------------------------------------------------------------
  // Field: m_tlp_cpl_lower_addr
  // This Field is a completion lower address of 7 bits
  //---------------------------------------------------------------------------
  rand bit [11:0]                            m_tlp_cpl_lower_addr;
  //---------------------------------------------------------------------------
  // Field: m_tlp_cpl_cdl
  // This Field is a completion CDL value asigned to use by CXL
  //---------------------------------------------------------------------------
  rand bit [1:0]                             m_tlp_cpl_cdl;
  //---------------------------------------------------------------------------
  // Field: m_is_atomic_op
  // This Field indictes whether the tlp_type is atomic opearation
  //---------------------------------------------------------------------------
  bit                                        m_is_atomic_op;

  //---------------------------------------------------------------------------
  // Field: m_hdr_fmt_prefix
  // TLP Prefixes Releated variables
  // If two prefixes are present ==> [Prefix0][Prefix1][TLP Header][TLP Payoad(if any)]
  // Keeping hdr_fmt==TLP Prefix as seperate array. Similarly for hdr_type
  // When prefix is not present in current packet then below two fields are not used in packet formation
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_fmt_t                m_hdr_fmt_prefix[];
  //---------------------------------------------------------------------------
  // Field: m_hdr_type_prefix
  // This Field constains the header type prefix
  //---------------------------------------------------------------------------
  rand bit [4:0]                             m_hdr_type_prefix[];
  //---------------------------------------------------------------------------
  // Field: m_tlp_ph
  // This Field is a tlp processing hint
  //---------------------------------------------------------------------------
  rand bit [1:0]                             m_tlp_ph;
  //---------------------------------------------------------------------------
  // Field: m_max_no_of_prefixes
  // This Field contains the maximum number of prefixes
  //---------------------------------------------------------------------------
  rand bit [2:0]                             m_max_no_of_prefixes;
  //---------------------------------------------------------------------------
  // Field: m_orphan_tlp_prefix
  // This Field is used for orphan TLP prefix (i.e. just a prefix without head or data)
  //---------------------------------------------------------------------------
  bit                                        m_orphan_tlp_prefix;
  //---------------------------------------------------------------------------
  // Field: m_tph_possible
  // This Field is a tlp processing hint possible
  //---------------------------------------------------------------------------
  rand bit                                   m_tph_possible;
  //---------------------------------------------------------------------------
  // Field: m_ide_prefix_possible
  // This Field indicates whether IDE Prefix possible for this TLP
  //---------------------------------------------------------------------------
  rand bit                                   m_ide_prefix_possible;
  //---------------------------------------------------------------------------
  // Field: m_ide_prefix_present
  // This Field indicates whether IDE Prefix is present for this TLP
  //---------------------------------------------------------------------------
  rand bit                                   m_ide_prefix_present;
  //---------------------------------------------------------------------------
  // Field: m_ext_tph_prefix_possible
  // This Field is a external tlp processing hint possible
  //---------------------------------------------------------------------------
  rand bit                                   m_ext_tph_prefix_possible;
  //---------------------------------------------------------------------------
  // Field: m_pasid_prefix_possible
  // This Field indicates process id prefix possible
  //---------------------------------------------------------------------------
  rand bit                                   m_pasid_prefix_possible;
  //---------------------------------------------------------------------------
  // Field: m_tph_present
  // This Field indicates tph present in tlp
  //---------------------------------------------------------------------------
  rand bit                                   m_tph_present;
  //---------------------------------------------------------------------------
  // Field: m_ext_tph_prefix_present
  // This Field indicates Extended tph prefix present
  //---------------------------------------------------------------------------
  rand bit                                   m_ext_tph_prefix_present;
  //---------------------------------------------------------------------------
  // Field: m_pasid_prefix_present
  // This Field indicates processid prefix present
  //---------------------------------------------------------------------------
  rand bit                                   m_pasid_prefix_present;
  //---------------------------------------------------------------------------
  // Field: m_tlp_prefix
  // This field is a array of tlp prefix
  //---------------------------------------------------------------------------
  rand reg [31:0]                            m_tlp_prefix[];
  //---------------------------------------------------------------------------
  // Field: m_tph_pasid_as_first_prefix
  // This Field is a process id as a first prefix
  //---------------------------------------------------------------------------
  rand bit                                   m_tph_pasid_as_first_prefix;
  //---------------------------------------------------------------------------
  // Field: m_pasid_value
  // This Field contains the process id value
  //---------------------------------------------------------------------------
  rand bit [19:0]                            m_pasid_value;
  //---------------------------------------------------------------------------
  // Field: m_pasid_pri_value
  // This Field is a process id prior value
  //---------------------------------------------------------------------------
  rand bit                                   m_pasid_pri_value;
  //---------------------------------------------------------------------------
  // Field: m_pasid_exec_value
  // This Field is a process id exec value
  //---------------------------------------------------------------------------
  rand bit                                   m_pasid_exec_value;
  //---------------------------------------------------------------------------
  // Field: m_tlp_ltr_msg_no_snoop_latency
  // This Field is a latency tolearnce reporting message for no snoop latency
  //---------------------------------------------------------------------------
  rand bit [15:0]                            m_tlp_ltr_msg_no_snoop_latency;
  //---------------------------------------------------------------------------
  // Field: m_tlp_ltr_msg_snoop_latency
  // This Field is a latency tolearnce reporting message for  snoop latency
  //---------------------------------------------------------------------------
  rand bit [15:0]                            m_tlp_ltr_msg_snoop_latency;

  //---------------------------------------------------------------------------
  // Field: m_tlp_vendor_id
  // This Field contains the vendor id
  // Common field for all VND Msgs (Type0/Type1) [Byte 10 & 11 od Msg]
  //---------------------------------------------------------------------------
  rand bit [15:0]                            m_tlp_vendor_id; //Common field for all VND Msgs (Type0/Type1) [Byte 10 & 11 of Msg]
  //---------------------------------------------------------------------------
  // Field: m_tlp_vendor_msg
  // This Field contains the vendor message
  // Common field for all VND Msgs (Type0/Type1) [Bytes 12 to 15 of Msg]
  //---------------------------------------------------------------------------
  rand bit [31:0]                            m_tlp_vendor_msg; //Common field for all VND Msgs (Type0/Type1) [Bytes 12 to 15 of Msg]

  //LN VND message
  //---------------------------------------------------------------------------
  // Field: m_tlp_ln_msg_cacheline_addr
  // This Field is a tlp light weight notification message for cacheline addr
  //---------------------------------------------------------------------------
  rand bit [63:6]                            m_tlp_ln_msg_cacheline_addr;
  //---------------------------------------------------------------------------
  // Field: m_tlp_ln_msg_nr
  // This Field is a tlp light weight notification msg notification requestor
  //---------------------------------------------------------------------------
  rand bit [1:0]                             m_tlp_ln_msg_nr;

  //FRS VND Msg//todo
  //---------------------------------------------------------------------------
  // Field: m_tlp_frs_msg_reason
  // This Field is a function readiness status message reason
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_frs_msg_reason_t         m_tlp_frs_msg_reason;

  //Hierarchy ID VND Msg//TODO
  //---------------------------------------------------------------------------
  // Field: m_tlp_hier_vmsg_hierarchy_id
  // This field is vendor message hierarchy id
  //---------------------------------------------------------------------------
  rand bit [15:0]                            m_tlp_hier_vmsg_hierarchy_id;
  //---------------------------------------------------------------------------
  // Field: m_tlp_hier_vmsg_guid_authority_id
  // This Field is a vendor message guid authority id
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_tlp_hier_vmsg_guid_authority_id;
  //---------------------------------------------------------------------------
  // Field: m_tlp_hier_vmsg_system_guid
  // This Field is a vmsg system guid
  //---------------------------------------------------------------------------
  rand bit [143:0]                           m_tlp_hier_vmsg_system_guid;

  //---------------------------------------------------------------------------
  // Field: m_tlp_payload
  // This field conatains the payload information of a TLP
  //---------------------------------------------------------------------------
  rand reg [7:0]                             m_tlp_payload[];

  //---------------------------------------------------------------------------
  // Field: m_tlp_ats_tr_nw_field
  // This Field is a address translation services no write field
  //---------------------------------------------------------------------------
  rand bit                                   m_tlp_ats_tr_nw_field;

  // ATS mesage
  // Invalidate request
  //---------------------------------------------------------------------------
  // Field: m_tlp_itag
  // The ITag field is constrained to the values 0 to 31 and is used by the TA to uniquely identify requests it issues
  //---------------------------------------------------------------------------
  rand bit [4:0]                             m_tlp_itag;
  // Invalidate CPL message
  //---------------------------------------------------------------------------
  // Field: m_tlp_itag_vector
  // This Field is The ITag Vector field is used to indicate which Invalidate Request has been completed
  //---------------------------------------------------------------------------
  rand bit [31:0]                            m_tlp_itag_vector ;
  //---------------------------------------------------------------------------
  // Field: m_inv_cpl_cnt
  // This Fiedl is a invalidate completion count
  //---------------------------------------------------------------------------
  rand bit [2:0]                             m_inv_cpl_cnt;

  //OBFF Message
  //---------------------------------------------------------------------------
  // Field: m_obffCode
  // This Field is a optimized buffer flush/fill message
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_ObffCode_t               m_obffCode;

  //PTM Message
  //---------------------------------------------------------------------------
  // Field: m_ptmMasterTime
  // The PTM Master Time field is a 64-bit value containing the value of PTM Master Time
  // at the receipt of the PTM Request Message for the current PTM Dialog
  //---------------------------------------------------------------------------
  rand bit[63:0] m_ptmMasterTime;
  //---------------------------------------------------------------------------
  // Field: m_ptmPropagationDelay
  // The Propagation Delay field is a 32-bit value containing the interval between the receipt of the PTM Request Message
  // and the transmission of the PTM Response Mes
  //---------------------------------------------------------------------------
  rand bit[31:0] m_ptmPropagationDelay;

  //Page request
  //---------------------------------------------------------------------------
  // Field: m_page_addr
  // This Field is a page address
  //---------------------------------------------------------------------------
  rand bit[51:0] m_page_addr;
  //---------------------------------------------------------------------------
  // Field: m_prReadRequested
  // This Fiels is a PR read requested
  //---------------------------------------------------------------------------
  rand bit       m_prReadRequested;
  //---------------------------------------------------------------------------
  // Field: m_prWriteRequested
  // This Field is a pr write requested
  //---------------------------------------------------------------------------
  rand bit       m_prWriteRequested;
  //---------------------------------------------------------------------------
  // Field: m_prLastRequest
  // This Field is a pr last request
  //---------------------------------------------------------------------------
  rand bit       m_prLastRequest;
  //---------------------------------------------------------------------------
  // Field: m_prGroupIndex
  // Request Group Index
  // Page Request Group Index- This field contains a Function supplied index to which the RC is responding. A given PRG Index will receive exactly one response per i
  // nstance of PRG (with the possible exception of a Response Failure).
  //---------------------------------------------------------------------------
  rand bit[8:0]  m_prGroupIndex;

  //Page Request Group (PRG) Response//todo
  //---------------------------------------------------------------------------
  // Field: m_prgResponseCode
  // This Field contains Page request group response
  //---------------------------------------------------------------------------
  rand bit[3:0]  m_prgResponseCode;

  //TLP DIgest (ECRC)
  //---------------------------------------------------------------------------
  // Field: ecrc_val
  // This Field contains the ecrc value
  //---------------------------------------------------------------------------
  bit[31:0] ecrc_val;
  //---------------------------------------------------------------------------
  // Field: ecrc_valid
  // This Field indicates ecrc valid or not
  //---------------------------------------------------------------------------
  bit       ecrc_valid;
  //---------------------------------------------------------------------------
  // Field: errored_ecrc
  // This Field indicates errored ecrc
  //---------------------------------------------------------------------------
  bit       errored_ecrc;
  //---------------------------------------------------------------------------
  // Field: dll_flit_err_test
  // This Field indicates dll_flit_err_test
  //---------------------------------------------------------------------------
  bit       dll_flit_err_test;
  //---------------------------------------------------------------------------
  // Field: is_local_pref_after_pth_err
  // This Field indicates is_local_pref_after_pth_err
  //---------------------------------------------------------------------------
  bit       is_local_pref_after_pth_err;
  // Field: is_pbr_missing_err
  // This Field indicates is_local_pref_after_pth_err
  //---------------------------------------------------------------------------
  bit       is_pbr_missing_err;
  // Field: is_tlp_header_rsvd
  // This Field indicates is_tlp_header_rsvd
  //---------------------------------------------------------------------------
  bit      is_tlp_header_rsvd;
  // Field: is_cpl_tlp_header_rsvd
  // This Field indicates is_cpl_tlp_header_rsvd
  //---------------------------------------------------------------------------
  bit      is_cpl_tlp_header_rsvd,m_skip_rsvd_type_check,rsvd_with_payload;
  // Field: is_posted_tlp_address_routed_header_rsvd
  // This Field indicates is_posted_tlp_address_routed_header_rsvd
  //---------------------------------------------------------------------------
  bit      is_posted_tlp_address_routed_header_rsvd;
  // Field: is_posted_tlp_id_routed_header_rsvd
  // This Field indicates is_posted_tlp_id_routed_header_rsvd
  //---------------------------------------------------------------------------
  bit      is_posted_tlp_id_routed_header_rsvd;
  // Field: is_nonposted_tlp_id_routed_header_rsvd
  // This Field indicates is_nonposted_tlp_id_routed_header_rsvd
  //---------------------------------------------------------------------------
  bit      is_nonposted_tlp_id_routed_header_rsvd;
  // Field: is_nonposted_tlp_address_routed_header_rsvd
  // This Field indicates is_nonposted_tlp_address_routed_header_rsvd
  //---------------------------------------------------------------------------
  bit      is_nonposted_tlp_address_routed_header_rsvd;
  bit      is_none_header_rsvd;
  // Field: is_pbr_ecrc_calculated_for_pth_err
  // This Field indicates is_pbr_ecrc_calculated_for_pth_err
  //---------------------------------------------------------------------------
  bit       is_pbr_ecrc_calculated_for_pth_err;
  //---------------------------------------------------------------------------
  // Field: m_td_wo_ecrc
  // This field is to be used to indicate that this TLP has TD as set but no
  // ECRC is included in the bitstream. It is used in error flow
  //---------------------------------------------------------------------------
  bit       m_td_wo_ecrc = 0;
  //---------------------------------------------------------------------------
  // Field: m_no_td_ecrc
  // This Field is no tlp digest ecrc
  //---------------------------------------------------------------------------
  bit       m_no_td_ecrc = 0;
  //---------------------------------------------------------------------------
  // Field: m_hls_err_chk_en
  // This Field makes sure that only malformed errors are checked in TL_RX
  // Its set from passive monitor callback & HLS rx monitor and used inside error predictor
  //---------------------------------------------------------------------------
  bit       m_hls_err_chk_en = 0;
  //---------------------------------------------------------------------------
  // Field: m_hls_bypass_constraint
  // This Field makes sure that hls should bypass some constraints not all
  //---------------------------------------------------------------------------
  bit       m_hls_bypass_constraint = 0;
  //---------------------------------------------------------------------------
  // Field: m_ide_metadata_check_en
  // It should be set to enable the IDE metadta check
  //---------------------------------------------------------------------------
  bit       m_ide_metadata_check_en = 0;
  //---------------------------------------------------------------------------
  // Field: m_non_func_specific
  // This Field, when set indicates that TLP is non-function specific
  // As per specification, errors given below are non-function specific
  //  All Physical Layer errors
  //  All Data Link Layer errors
  //  These Transaction Layer errors:
  //   ECRC Check Failed
  //   Unsupported Request, when caused by no Function claiming a TLP
  //   Receiver Overflow
  //   Flow Control Protocol Error
  //   Malformed TLP
  //   Unexpected Completion, when caused by no Function claiming a Completion
  //   Unexpected Completion, when caused by a Completion that cannot be forwarded by a Switch, and
  //     the Ingress Port is a Switch Upstream Port associated with a Multi-Function Device
  //   Some Transaction Layer errors (e.g., Poisoned TLP Received) may be Function-specific or not,
  //     depending upon whether the associated TLP targets a single Function or all Functions in that device.
  //  ---------------------------------------------------------------------------
  bit       m_non_func_specific = 0;

  bit       cfg_type1_target_pri; //CFG_1 will be consumed internally and completion data comes to hls_ib_compl
  bit       cfg_type0_target_pri; //CFG_0 will be consumed internally and completion data comes to hls_ib_compl
  bit       cfg_type1_target_sec;
  bit       cfg_type1_target_sec_non_zero_dev_ari_dis;
  bit       cfg_type1_target_pri_wrong_dev_fun;
  bit       cfg_type1_target_more_than_sec_less_equal_to_sub;
  bit       cfg_type1_target_more_than_sub;
  bit       target_vendor_id;

  bit       consumed_internally=1;
  //rand bit [7:0]  st_entry_index; 
  //---------------------------------------------------------------------------
  // Field: m_bar_info
  // This Field provides the bar info for current tlp if applicable
  // Used in HLS error predictor integration
  //---------------------------------------------------------------------------
  barInfo_t m_bar_info;
  //---------------------------------------------------------------------------
  // Field: m_pf_vf
  // This Field provides the DUT pf/vf information for current tlp
  // Used in HLS error predictor integration
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_pf_vf_s m_pf_vf;

  //Inter pack gap delay
  //---------------------------------------------------------------------------
  // Field: m_ipg
  // This FIeld is a inter pack gap delay
  //---------------------------------------------------------------------------
  rand int       m_ipg;

  //Reserved fields in packets
  //---------------------------------------------------------------------------
  // Field: force_rsvd_bits_as_zero
  // This Field is a reserved fields in packets
  //---------------------------------------------------------------------------
  rand bit               force_rsvd_bits_as_zero;
  //Memory packets
  //---No Rsvd fields explicitly in header ---

  //I0 Packets
  //---------------------------------------------------------------------------
  // Field: io_byte_11_rsvd_field_1_0
  // This Field is a IO byte 11 reserved field_1_0
  //---------------------------------------------------------------------------
  rand bit [1:0]    io_byte_11_rsvd_field_1_0;

  //Cfg packets
  //---------------------------------------------------------------------------
  // Field: cfg_byte_10_rsvd_field_7_4
  // This Field is a cfg byte_10 reserved field_7_4
  //---------------------------------------------------------------------------
  rand bit [3:0]    cfg_byte_10_rsvd_field_7_4;
  //---------------------------------------------------------------------------
  // Field: cfg_byte_11_rsvd_field_1_0
  // This Field is a cfg buye_11 reserved field_!_0
  //---------------------------------------------------------------------------
  rand bit [1:0]    cfg_byte_11_rsvd_field_1_0;

  //TLP Prefixes
  //TPH Prefix
  //---------------------------------------------------------------------------
  // Field: tph_byte_2_3_rsvd
  // This Field is a tlp processing hint byte_2_3 reserved
  //---------------------------------------------------------------------------
  rand bit [15:0]   tph_byte_2_3_rsvd;

  //Pasid Prefix
  //---------------------------------------------------------------------------
  // Field: pasid_byte_1_rsvd_field_5_4
  // This Field is a processid_byte_1 reserved field_5_4
  //---------------------------------------------------------------------------
  rand bit [1:0]    pasid_byte_1_rsvd_field_5_4;

  //Completion packets
  //---------------------------------------------------------------------------
  // Field: cpl_byte_12_rsvd_field_7
  // This Field is a completion byte_12 reserved field_7
  //---------------------------------------------------------------------------
  rand bit          cpl_byte_12_rsvd_field_7;
  //---------------------------------------------------------------------------
  // Field: cpl_byte_12_rsvd_field_4_0
  // This Field is a completion byte_12 reserved field_4_0
  //---------------------------------------------------------------------------
  rand bit [4:0]    cpl_byte_12_rsvd_field_4_0;
  //---------------------------------------------------------------------------
  // Field: cpl_byte_11_rsvd_field_7_4
  // This Field is a completion byte_11 reserved field_7_4
  //---------------------------------------------------------------------------
  rand bit [3:0]    cpl_byte_11_rsvd_field_7_4;
  //---------------------------------------------------------------------------
  // Field: cpl_byte_11_rsvd_field_3_0
  // This Field is a completion byte_11 reserved field_3_0
  //---------------------------------------------------------------------------
  rand bit [3:0]    cpl_byte_11_rsvd_field_3_0;
  //---------------------------------------------------------------------------

  //Message Packets
  //---------------------------------------------------------------------------
  // Field: msg_cmn_byte_8_15_rsvd
  // This Field is a message common byte_8_15 reserved
  //---------------------------------------------------------------------------
  rand bit [63:0]   msg_cmn_byte_8_15_rsvd;

  //Invalidate Req Message
  //---------------------------------------------------------------------------
  // Field: msg_inv_req_byte_6_field_7_rsvd_nfm
  // This Field is a Invalidate req message byte_6 filed_7 reserved
  //---------------------------------------------------------------------------
  rand bit          msg_inv_req_byte_6_field_7_rsvd_nfm;
  //---------------------------------------------------------------------------
  // Field: msg_inv_req_byte_6_field_6_5_rsvd
  // This Field is a Invalidate req message byte_6 filed_6_5 reserved
  //---------------------------------------------------------------------------
  rand bit [1:0]    msg_inv_req_byte_6_field_6_5_rsvd;
  //---------------------------------------------------------------------------
  // Field: msg_inv_req_byte_10_15_rsvd
  // This Field is a message invalid request byte_10_15 reserved
  //---------------------------------------------------------------------------
  rand bit [47:0]   msg_inv_req_byte_10_15_rsvd;

  //Invalidate complete Message
  //---------------------------------------------------------------------------
  // Field: msg_inv_cpl_byte_10_11_rsvd
  // This Field is a Invalidate complete message byte_10_11 reserved
  //---------------------------------------------------------------------------
  rand bit [12:0]   msg_inv_cpl_byte_10_11_rsvd;

  //PR Resp
  //---------------------------------------------------------------------------
  // Field: msg_pr_rsp_byte_10_field_3_1_rsvd
  // This Field is a reserved fields of page request response byte_10_field_3_1 reserved
  //---------------------------------------------------------------------------
  rand bit [2:0]    msg_pr_rsp_byte_10_field_3_1_rsvd;
  //---------------------------------------------------------------------------
  // Field: msg_pr_rsp_byte_12_15_rsvd
  // This Field is a reserved byte of page request response byte_12_15 reserved
  //---------------------------------------------------------------------------
  rand bit [31:0]   msg_pr_rsp_byte_12_15_rsvd;

  //LTR Message
  //---------------------------------------------------------------------------
  // Field: msg_ltr_byte_8_11_rsvd
  // This Field is a latency tolerance reporting reserved bytes
  //---------------------------------------------------------------------------
  rand bit [31:0]   msg_ltr_byte_8_11_rsvd;

  //OBFF Message
  //---------------------------------------------------------------------------
  // Field: msg_obff_byte_8_14_rsvd
  // This Field is a optimized buffer flush/fill reserved byte
  //---------------------------------------------------------------------------
  rand bit [59:0]   msg_obff_byte_8_14_rsvd;

  //Vendor messages
  //---------------------------------------------------------------------------
  // Field: msg_ln_drs_byte_13_15_rsvd
  // This Field is a ln drs byte_13_15 reserved fields
  //---------------------------------------------------------------------------
  rand bit [23:0]   msg_ln_drs_byte_13_15_rsvd;
  //---------------------------------------------------------------------------
  // Field: msg_ln_payload_rsvd
  // This Field is a reserved fields for message ln payload
  //---------------------------------------------------------------------------
  rand bit [3:0]    msg_ln_payload_rsvd;
  //---------------------------------------------------------------------------
  // Field: msg_frs_byte_13_15_rsvd
  // This Field is a unction readiness status byte_13_15 reserved
  //---------------------------------------------------------------------------
  rand bit [19:0]   msg_frs_byte_13_15_rsvd;
  //---------------------------------------------------------------------------
  // Field: msg_destination_id_rsvd
  // This Field is a message destination id reserved
  //---------------------------------------------------------------------------
  rand bit [15:0]   msg_destination_id_rsvd;

  //---------------------------------------------------------------------------
  // Field: second_dw_byte_6_field_6_rsvd
  // This Field is a CFG/IO/Mem tlp 2nd DW reserved field (byte_6 reserved field[6])
  //---------------------------------------------------------------------------
  rand bit          second_dw_byte_6_field_6_rsvd;

  //---------------------------------------------------------------------------
  // Field: second_dw_byte_6_msg_rsvd
  // This Field is a Msg tlp 2nd DW reserved field (byte_6 reserved field[6])
  //---------------------------------------------------------------------------
  rand bit [6:0]         second_dw_byte_6_msg_rsvd;

  //---------------------------------------------------------------------------
  // Field: vendor_definition_vd_msg
  // This Field is a Msg tlp 2nd DW (byte_6: Vendor definition). As sper 6.1 spec
  // The low 7 bits of byte 6 is available for vendor definition. Byte 6, bit 7 is Reserved in Non-Flit Mode
  // and is the EP bit in Flit Mode.
  //---------------------------------------------------------------------------
  rand bit [6:0]         vendor_definition_vd_msg;

  //---------------------------------------------------------------------------
  // Field: vendor_definition_vd_msg_rsvd_bit
  // This Field is a Msg tlp 2nd DW (byte_6: Vendor definition). As sper 6.1 spec
  // The low 7 bits of byte 6 is available for vendor definition. Byte 6, bit 7 is Reserved in Non-Flit Mode
  // and is the EP bit in Flit Mode.
  //---------------------------------------------------------------------------
  rand bit               vendor_definition_vd_msg_rsvd_bit;

  //---------------------------------------------------------------------------
  // Field: m_ohc_a1_byte_0_field_7_rsvd
  // This Field is a ohc_a1 byte_0 field_7 reserved
  //---------------------------------------------------------------------------
  rand bit          m_ohc_a1_byte_0_field_7_rsvd;

  //---------------------------------------------------------------------------
  // Field: m_ohc_a1_byte_3_rsvd
  // This Field is a ohc_a1 byte_3 is LBE_FBE, whihc is reserved for msg
  //---------------------------------------------------------------------------
  rand bit [7:0]    m_ohc_a1_byte_3_rsvd;

  //---------------------------------------------------------------------------
  // Field: m_ohc_a2_byte_0_2_rsvd
  // This Field is a ohc_a2 byte_0_to_2 reserved
  //---------------------------------------------------------------------------
  rand bit [23:0]   m_ohc_a2_byte_0_2_rsvd;

  //---------------------------------------------------------------------------
  // Field: m_ohc_a3_byte_1_rsvd
  // This Field is a ohc_a3 byte_1 reserved
  //---------------------------------------------------------------------------
  rand bit [7:0]   m_ohc_a3_byte_1_rsvd;

  //---------------------------------------------------------------------------
  // Field: m_ohc_a3_byte_2_rsvd
  // This Field is a ohc_a3 byte_2 reserved
  //---------------------------------------------------------------------------
  rand bit [6:0]   m_ohc_a3_byte_2_rsvd;

  //---------------------------------------------------------------------------
  // Field: m_ohc_a4_byte_2_field_5_4_rsvd
  // This Field represents bits [5:4] in Byte 2 of OHC-A4, which are Reserved.
  //---------------------------------------------------------------------------
  rand bit [1:0]   m_ohc_a4_byte_2_field_5_4_rsvd;

  //---------------------------------------------------------------------------
  // Field: m_ohc_a5_byte_2_3_rsvd
  // This Field is a ohc_a5 byte_2_to_3 reserved
  //---------------------------------------------------------------------------
  rand bit [9:0]   m_ohc_a5_byte_2_3_rsvd;

  //---------------------------------------------------------------------------
  // Field: m_ohc_b_byte_0_rsvd
  // This Field is a ohc_B byte_0 reserved
  //---------------------------------------------------------------------------
  rand bit [7:0]   m_ohc_b_byte_0_rsvd;

  //---------------------------------------------------------------------------
  // Field: m_ohc_c_byte_3_field_2_rsvd
  // This Field is indicator of rsvd field value in OHC-C fields
  //---------------------------------------------------------------------------
  rand bit                                   m_ohc_c_byte_3_field_2_rsvd;

  //DLP fields
  //---------------------------------------------------------------------------
  // Field: m_dlp_lcrc
  // This Field is a lcrc value of a DL packet
  //---------------------------------------------------------------------------
  rand bit [31:0] m_dlp_lcrc;
  //---------------------------------------------------------------------------
  // Field: m_dlp_seq_num
  // This Field is a sequence number of DL paket
  //---------------------------------------------------------------------------
  rand bit [11:0] m_dlp_seq_num;

  //reserved bit error - store first four reserved bit in sequence number here
  //bit [3:0] m_first_four;
  //---------------------------------------------------------------------------
  // Field: lcrc_err
  // This Field is a  lcrc error
  //---------------------------------------------------------------------------
  bit lcrc_err;

  //---------------------------------------------------------------------------
  // Field: pcrc_err
  // This Field is a  ide_pcrc error
  //---------------------------------------------------------------------------
  bit pcrc_err;
  
  //---------------------------------------------------------------------------
  // Field: ide_mac_err
  // This Field is a  ide_mac error
  //---------------------------------------------------------------------------
  bit ide_mac_err;

  //---------------------------------------------------------------------------
  // Field: set_enderr
  // This Field is used to indicate to TLP2CXS converter to inject an ENDERR
  //---------------------------------------------------------------------------
  bit set_enderr;

  //---------------------------------------------------------------------------
  // Field: ide_mac_zero_whn_aggr_not_supp_err
  // This Field is a ide_mac_zero_whn_aggr_not_supp_err
  //---------------------------------------------------------------------------
  bit ide_mac_zero_whn_aggr_not_supp_err;

  //---------------------------------------------------------------------------
  // Field: ide_mac_zero_whn_aggr_supp_err
  // This Field is a ide_mac_zero_whn_aggr_supp_err
  //---------------------------------------------------------------------------
  bit ide_mac_zero_whn_aggr_supp_err;

  // Field: reverse_data_on_CPLd
  // This Field is a  reverse_data_on_CPLd
  //---------------------------------------------------------------------------
  bit reverse_data_on_CPLd;
  //---------------------------------------------------------------------------
  // Field: seq_num_err
  // Thsi Field is a  sequence number error
  //---------------------------------------------------------------------------
  bit seq_num_err;

  //PLP fields
  //---------------------------------------------------------------------------
  // Field: m_plp_beginFrame
  // This Field is a Pl start frame
  //---------------------------------------------------------------------------
  rand bit [8:0] m_plp_beginFrame;
  //---------------------------------------------------------------------------
  // Field: m_plp_endFrame
  // This Field is a  PL end frame
  //---------------------------------------------------------------------------
  rand bit [8:0] m_plp_endFrame;

  //---------------------------------------------------------------------------
  // Field:tlp_sqr_handle
  // Use this field to keep track of number of TLPs sent from BFM in sequencer
  // update this variable at the post_randomize phase
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_vseqr  tlp_sqr_handle;

  //------------------------------------------------------------------------
  // CONTROL MEMBER VARIABLES
  //------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Field: m_tlp_type
  // This Field is a tlp type eg:)posted non posted ...
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_type_t               m_tlp_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_e2e_prfx_type
  // This Field is a end2end prefix type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_eprfx_t              m_tlp_e2e_prfx_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_local_prfx_type
  // This Field is a tlp local prefix type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_lprfx_t              m_tlp_local_prfx_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_req_type
  // This Field is a tlp request type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_request_type_t       m_tlp_req_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_trans_type
  // This Field is a tlp transction type eg)Msg,IO,Memory.......
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_transaction_type_t       m_tlp_trans_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_addr_type
  // This Field is a  tlp address type eg) 32 bit or  64 bit
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_addr_format_type_t   m_tlp_addr_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_np_req_type
  // This Field is a tlp non posted request type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_non_posted_req_type_t    m_tlp_np_req_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_vdm_msg_subtype
  // This Field is a vendor message sub type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_vdm_msg_sub_type_t   m_tlp_vdm_msg_subtype;
  //---------------------------------------------------------------------------
  // Field: m_tlp_len_type
  // This Field is a  tlp packet length type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_category_type_t      m_tlp_len_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_burst_type
  // This Field is a tlp burst type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_category_type_t      m_tlp_burst_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_ipg_type
  // This Field is a tlp  ipg type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_category_type_t      m_tlp_ipg_type;
  //---------------------------------------------------------------------------
  // Field: m_tlp_vdm_msg_type
  // This Field is a  tlp vendor message type
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_vdm_msg_type_t       m_tlp_vdm_msg_type;
  //---------------------------------------------------------------------------
  // Field: cdn_hpa_cxl_vdm_msg_sub_type_t
  // This Field is a  tlp vendor message type
  //---------------------------------------------------------------------------
  rand cdn_hpa_cxl_vdm_msg_sub_type_t        m_cxl_error_vdm_msg;
  bit vdm_for_cxl;
  //---------------------------------------------------------------------------
  // Field: type1_dev
  // This Field is a type 1 device
  //---------------------------------------------------------------------------
  rand bit                                   type1_dev;

  // Holds all the PCIe device capability info
  // Holds the info about BARs
  //---------------------------------------------------------------------------
  // Field: m_pcie_dev_cfg
  // This is a handler to function level config
  // Holds all the PCIe device capability info
  // Holds the info about BARs
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_dev_config                    m_pcie_dev_cfg;
  //---------------------------------------------------------------------------
  // Field: m_pcie_dut_dev_cfg
  // This is a handler to pcie DUT dev config
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_dev_config                    m_pcie_dut_dev_cfg;
  //---------------------------------------------------------------------------
  // Field: m_pcie_bfm_dev_cfg
  // This is a handler to pcie BFM dev config
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_dev_config                    m_pcie_bfm_dev_cfg;
  //---------------------------------------------------------------------------
  // Field: m_pcie_dev_top_cfg
  // This is a handler to device level config
  // Holds all the function config handles
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_dev_top_config                m_pcie_dev_top_cfg;

  bit all_traffic_tlp;

  //---------------------------------------------------------------------------
  // Field: m_pcie_link_cfg
  // This is a handle to link level config
  // Holds configurations of upstream and downstream devices
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_link_config                   m_pcie_link_cfg;
  //---------------------------------------------------------------------------
  // Field: m_sel_pf
  // This Field is a function number for id based  routing
  //---------------------------------------------------------------------------
  int unsigned                               m_sel_pf;
  //---------------------------------------------------------------------------
  // Field: m_sel_vf
  // This Field is a VF device select
  //---------------------------------------------------------------------------
  int unsigned                               m_sel_vf;

  // TO print more verbose messages
  //---------------------------------------------------------------------------
  // Field: debug_mode_en
  // This Field is to print more verbose messages
  //---------------------------------------------------------------------------
  bit debug_mode_en;

  // To collect Non Posted packet while generating the completions
  //---------------------------------------------------------------------------
  // Field: np_req_tlp
  // This Field is to collect Non posted packet while generating the completions
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp                           np_req_tlp;
  // Control flag to generate invalid completion status
  //---------------------------------------------------------------------------
  // Field: rsvd_cpl_status
  // Control flag to generate invalid completion status
  //---------------------------------------------------------------------------
  rand bit                                   rsvd_cpl_status;
  //---------------------------------------------------------------------------
  // Field: is_mem_read
  // This Field indicates  a  memory read
  //---------------------------------------------------------------------------
  rand bit                                   is_mem_read;

  // Control flag to generate undefined msg_code
  //---------------------------------------------------------------------------
  // Field: send_undefined_msg_code
  // This Field is a Control flag to generate undefined msg_code
  //---------------------------------------------------------------------------
  rand bit                                   send_undefined_msg_code;

  // This bit is applicable only for NP requests which needs to wait for the responses
  //---------------------------------------------------------------------------
  // Field: is_blocking
  // This bit is applicable only for NP requests which needs to wait for the responses
  //---------------------------------------------------------------------------
  rand bit is_blocking;
  rand int unique_id;

  //---------------------------------------------------------------------------
  // Field: m_msi_msix_pkt
  // This Field is used to genearte MSI/MSIX Memeory write TLPs
  //---------------------------------------------------------------------------
  bit                               m_msi_msix_pkt;

  //---------------------------------------------------------------------------
  // Field: enable_directed_cfgwr0
  // This Field is used to enable directed CfgWr0 TLP generation in post_randomize
  //---------------------------------------------------------------------------
  bit                               enable_directed_cfgwr0;

  //---------------------------------------------------------------------------
  // Field: enable_directed_iowr
  // This Field is used to enable directed IOWr TLP generation in post_randomize
  //---------------------------------------------------------------------------
  bit                               enable_directed_iowr;

  //------------------------------------------------------------------------
  // Error Control Knobs
  //------------------------------------------------------------------------

  // Enum with error strings to store the detected errors from error predictor
  //---------------------------------------------------------------------------
  // Field: m_tlp_errors_detected[$]
  // This Field is a Enum with error strings to store the detected errors from error predictor
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_error_type_t         m_tlp_errors_detected[$];

  //DLLP coverage queue
  //Field: dllp_err_q_cov
  //---------------------------------------------------------------------------
  // Field: dllp_err_q_cov
  // This Field is a dllp error coverage queue
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_tlp_error_type_t dllp_err_q_cov[$]; //dllp_error queue for coverage hit
  //Field: dllp_err_set
  //---------------------------------------------------------------------------
  // Field: dllp_err_set
  // This field indicates the dllp error set
  //---------------------------------------------------------------------------
  bit dllp_err_set;                                //dllp error injected
  //field m_inject_plp_err
  rand bit m_inject_plp_err;
  // To support standard errors which are supported by VIP
  // TODO for now use denali VIP EI
  // rand denaliPcieEiTypeT m_error_injects[];

  // To inject HPA Errors and To add an identifier to packet used the below
  //---------------------------------------------------------------------------
  // Field: enable_inject_errors
  // This Field is To enable the error injection based on this enable bit
  // error bit in the vipuserdata has_error enabled and error injection will happen
  //---------------------------------------------------------------------------
  rand bit               enable_inject_errors;
  //---------------------------------------------------------------------------
  // Field: top_cfg_enable_errors
  // This Field is used to enable the error injection based on the top config control bit
  //---------------------------------------------------------------------------
  rand bit               top_cfg_enable_errors;//todo
  //---------------------------------------------------------------------------
  // Field: disable_inject_errors
  // To be used from sequence level to override top cfg error control enable
  //---------------------------------------------------------------------------
  rand bit               disable_inject_errors;
  //Only inject DL error
  //---------------------------------------------------------------------------
  // Field: m_inject_dl_err
  // This Field is only inject DL error
  //---------------------------------------------------------------------------
  rand bit               m_inject_dl_err;
  //Block level users may make this bit one to inject error in seq_item generaton itself
  //---------------------------------------------------------------------------
  // Field: inject_err_in_seq_item
  // This Field is Block level users may make this bit one to inject error in seq_item generaton itself
  //---------------------------------------------------------------------------
  bit                    inject_err_in_seq_item =0;
  //---------------------------------------------------------------------------
  // Field: flr_valid_tag_diff_reqid
  // This Field is used to store the info for valid tag and diff reqid
  //---------------------------------------------------------------------------
  bit                    flr_valid_tag_diff_reqid;
  //---------------------------------------------------------------------------
  // Field: vip_userdata
  // This is a handler to vip userdata which contains all the error patterns
  //---------------------------------------------------------------------------
  cdn_pcie_vip_userdata  vip_userdata;
  //---------------------------------------------------------------------------
  // Field: m_user_error_inject_obj
  // This Field is a  handler to user  error inject object
  //---------------------------------------------------------------------------
  rand cdn_hpa_user_err_data m_user_error_inject_obj;
  //---------------------------------------------------------------------------
  // Field: error_inject_success
  // This field is a error inject success bit
  //---------------------------------------------------------------------------
  bit                    error_inject_success;
  bit                    predict_error;
  //---------------------------------------------------------------------------
  // Field: error_discard_packet
  // This field makes cb_monitor discard the current packet
  //---------------------------------------------------------------------------
  bit                    error_discard_packet;
  //---------------------------------------------------------------------------
  // Field: uio_cpl_diff_status
  // This field makes uio cpl with status
  //---------------------------------------------------------------------------
  bit                    uio_cpl_diff_status;

  //---------------------------------------------------------------------------
  // Field: error_rsvd_packet
  // This field makes cb_monitor instruct vip to put rsvd bits in pcie packet
  //---------------------------------------------------------------------------
  bit                    error_rsvd_packet;

  //---------------------------------------------------------------------------
  // Field: error_null_packet
  // This field instructs vip to inject nullified tlp
  //---------------------------------------------------------------------------
  bit                    error_null_packet;

  //---------------------------------------------------------------------------
  // Field: compl_lut_obj
  // This Field is a handler to hpa completion LUT wrapper class
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_compl_wrapper compl_lut_obj;

  //---------------------------------------------------------------------------
  // Field: compl_lut_obj_8bit
  // This Field is a handler to hpa completion LUT wrapper class
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_compl_wrapper compl_lut_obj_8bit;

  //---------------------------------------------------------------------------
  // Field: compl_lut_obj_10bit
  // This Field is a handler to hpa completion LUT wrapper class
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_compl_wrapper compl_lut_obj_10bit;

  //---------------------------------------------------------------------------
  // Field: compl_lut_obj_14bit
  // This Field is a handler to hpa completion LUT wrapper class
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_compl_wrapper compl_lut_obj_14bit;

  //---------------------------------------------------------------------------
  // Field: lut_item
  // This Field contains the return value of local completion managers
  // It is later passed to error predictor where it gets used for completion
  // error prediction
  //---------------------------------------------------------------------------
  cdn_pcie_hpa_compl_lut_item lut_item;

  // Control knobs based on the capability support and Enable

  //PACK/UNPACK/COMPARE control knobs
  //Prefix control knobs
  //---------------------------------------------------------------------------
  // Field: pack_prefix
  // This Field is a pack prefix
  //---------------------------------------------------------------------------
  bit                    pack_prefix=0;
  //---------------------------------------------------------------------------
  // Field: unpack_prefix
  // This Field is a unpack prefix
  //---------------------------------------------------------------------------
  bit                    unpack_prefix=1;
  //---------------------------------------------------------------------------
  // Field: compare_prefix
  // This Field is a  compare prefix
  //---------------------------------------------------------------------------
  bit                    compare_prefix=1;

  //ECRC control knobs
  //We need to set pack_ecrc in Bypass VIP mode as we connected error predictor in driver component.
  //HPA TLP is directly going to the predictor through driver, bypassing VIP. This setup requires
  //ECRC to be generated from sequence item itself.
  `ifdef BYPASS_VIP_MODE
    //---------------------------------------------------------------------------
    // Field: pack_ecrc
    // This Field is a ecrc control knobs
    // which pack ecrc is set to one in case of bypass vip mode
    //---------------------------------------------------------------------------
    bit                    pack_ecrc=1;
    `elsif HPA_ARCH2
    //---------------------------------------------------------------------------
    // Field: pack_ecrc
    // This Field is a ecrc control knobs
    // which pack ecrc is set to one in case of normal  mode
    //---------------------------------------------------------------------------
    bit                    pack_ecrc=1;
  `else
    //---------------------------------------------------------------------------
    // Field: pack_ecrc
    // This Field is a ecrc control knobs
    // which pack ecrc is set to one in case of normal  mode
    //---------------------------------------------------------------------------
    bit                    pack_ecrc=0;
  `endif
  //---------------------------------------------------------------------------
  // Field: pack_ecrc_local
  // This Field is a ecrc control knobs
  // which pack ecrc when required, no need to set it during randomization
  //---------------------------------------------------------------------------
  bit                    pack_ecrc_local=0;
  //---------------------------------------------------------------------------
  // Field: unpack_ecrc
  // This field is a  unpack ecrc by default set to zero
  //---------------------------------------------------------------------------
  bit                    unpack_ecrc=0;
  //---------------------------------------------------------------------------
  // Field: pack_trailer
  // This Field is a trailer control knobs
  // which pack trailer when required, by default set to one
  //---------------------------------------------------------------------------
  bit                    pack_trailer=1;
  //---------------------------------------------------------------------------
  // Field: pack_ide_trailer
  // This field is a  pack IDE trailer by default set to zero
  //---------------------------------------------------------------------------
  bit                    pack_ide_trailer=0;
  //---------------------------------------------------------------------------
  // Field: unpack_ide_trailer
  // This field is a  unpack IDE trailer by default set to one
  //---------------------------------------------------------------------------
  bit                    unpack_ide_trailer=1;
  //---------------------------------------------------------------------------
  // Field: unpack_rsvd_trailer
  // This field is a  unpack RSVD trailer by default set to one
  //---------------------------------------------------------------------------
  bit                    unpack_rsvd_trailer=1;
  //---------------------------------------------------------------------------
  // Field: compare_ecrc
  // This Field is a  compare ecrc by default set to zero
  //---------------------------------------------------------------------------
  bit                    compare_ecrc=0;

  //---------------------------------------------------------------------------
  // Field: pack_flit_mode_local_prefix
  // This Field is used to pack flit mode local prefix
  //---------------------------------------------------------------------------
  bit                    pack_flit_mode_local_prefix = 0;
  bit                    local_fm_tlp_prefix_valid = 0;

  //Reserved bits knobs
  //---------------------------------------------------------------------------
  // Field: compare_rsvd_bits
  // This Field is a reserved bit knobs
  // for compare reserved bits
  //---------------------------------------------------------------------------
  bit                    compare_rsvd_bits=1;
  //---------------------------------------------------------------------------
  // Field: print_rsvd_bits
  // This Field is a reserved bit knobs
  // for print reserved bits
  //---------------------------------------------------------------------------
  bit                    print_rsvd_bits=1;

  //Packed array
  //---------------------------------------------------------------------------
  // Field: m_data
  // This field is a packed array which will be useful in pack bytes of hpa tlp
  //---------------------------------------------------------------------------
  byte  unsigned         m_data[];
  //---------------------------------------------------------------------------
  // Field: prfx_bytes
  // This Field is a prefix bytes which will be used in get_prefix_bytes
  //---------------------------------------------------------------------------
  byte  unsigned         prfx_bytes[];

  //---------------------------------------------------------------------------
  // Field: tc
  // This Field is a traffic class
  //---------------------------------------------------------------------------
  tc_type                tc;
  //---------------------------------------------------------------------------
  // Field: seq_num
  // This Field is a sequence number
  //---------------------------------------------------------------------------
  seq_num_type           seq_num;
  //---------------------------------------------------------------------------
  // Field: pkt_num
  // This Field is a  packet number
  //---------------------------------------------------------------------------
  int unsigned           pkt_num;
  //---------------------------------------------------------------------------
  // Field: p_pkt_num
  // This Field is a posted packet number
  //---------------------------------------------------------------------------
  int unsigned           p_pkt_num;
  //---------------------------------------------------------------------------
  // Field: np_pkt_num
  // This Field is a non posted packet number
  //---------------------------------------------------------------------------
  int unsigned           np_pkt_num;
  //---------------------------------------------------------------------------
  // Field: cpl_pkt_num
  // This Field is a completion packet number
  //---------------------------------------------------------------------------
  int unsigned           cpl_pkt_num;
  //---------------------------------------------------------------------------
  // Field: cpl_pkt_num_in_flit
  // This Field is a completion packet number in flit
  //---------------------------------------------------------------------------
  int unsigned           cpl_pkt_num_in_flit;
  //---------------------------------------------------------------------------
  // Field: pkt_rx_time
  // This Field indicates the packet receive time
  //---------------------------------------------------------------------------
  time                   pkt_rx_time=0;
  time                   exp_pkt_time=0;

  // PACK/UNPACK/COMPARE Control knobs
  // Intx
  //---------------------------------------------------------------------------
  // Field: pack_intx
  // This Field is a pack  intx
  //---------------------------------------------------------------------------
  bit                    pack_intx;
  //---------------------------------------------------------------------------
  // Field: unpack_intx
  // This Field is a unpack intx
  //---------------------------------------------------------------------------
  bit                    unpack_intx;
  // MSI/MSIX
  //---------------------------------------------------------------------------
  // Field: pack_msi_msix
  // This Field is pack messge signaled interrupt
  //---------------------------------------------------------------------------
  bit                    pack_msi_msix;
  //---------------------------------------------------------------------------
  // Field: unpack_msi_msix
  // This Field is unpack message signaled interrupt
  //---------------------------------------------------------------------------
  bit                    unpack_msi_msix;
  // PRINT Control knobs
  // Intx
  //---------------------------------------------------------------------------
  // Field: print_intx
  // This Field is used to print the interrupt emulation
  //---------------------------------------------------------------------------
  bit                    print_intx;
  // MSI/MSIX
  //---------------------------------------------------------------------------
  // Field: print_msi_msix
  // This Field is used to print the message signalled interrupt
  //---------------------------------------------------------------------------
 bit                    print_msi_msix;
  //---------------------------------------------------------------------------
  // Field: m_erom_bar_hit
  // This Field is used to cover the erom bar hit tlp
  //---------------------------------------------------------------------------
  bit                    m_erom_bar_hit;


  //-------------------------------------------------------------------
  // Intx Random fields
  //-------------------------------------------------------------------
  //this is used to set/not-set int_pending_bit
  //---------------------------------------------------------------------------
  // Field: requestor_id
  // This Field is a requestor id
  //---------------------------------------------------------------------------
  rand bit[7:0]                              requestor_id;
  //---------------------------------------------------------------------------
  // Field: is_high
  // This Field is used to set/not-set int pending bit
  //---------------------------------------------------------------------------
  rand bit                                   is_high;
  //---------------------------------------------------------------------------
  // Field: dis_intr
  // This Field is disable interrupt
  //---------------------------------------------------------------------------
  rand bit                                  dis_intr;
  //---------------------------------------------------------------------------
  // Field: pf_number
  // This Field is for pf number
  //---------------------------------------------------------------------------
  rand int                                  pf_number;
  rand int                                  pf_number_a;
  rand int                                  pf_number_b;
  rand int                                  pf_number_c;
  rand int                                  pf_number_d;
  //---------------------------------------------------------------------------
  // Field: vf_number
  // This Field is for vf number
  //---------------------------------------------------------------------------
  rand int                                       vf_number;
  //new value of the INTX_IN pins
  //---------------------------------------------------------------------------
  // Field: intx_in_pin_value
  // This Field is new value of the INTX_IN pins
  //---------------------------------------------------------------------------
  rand bit [3:0]                             intx_in_pin_value;
  //new value of the Number of pins value
  //---------------------------------------------------------------------------
  // Field: intx_in_pin_valid_value
  // This Field is new value of the Number of pins value
  //---------------------------------------------------------------------------
  rand bit [3:0]                             intx_in_pin_valid_value;
  //new value of the INTX_OUT pins
  //---------------------------------------------------------------------------
  // Field: intx_out_pin_value
  // This Field is new value of the INTX_OUT pins
  //---------------------------------------------------------------------------
  rand bit [3:0]                             intx_out_pin_value;
  //new value of the INT_ACK pins
  //---------------------------------------------------------------------------
  // Field: int_ack_pin_value
  // This Field is new value of the INT_ACK pins
  //---------------------------------------------------------------------------
  rand bit [3:0]                             int_ack_pin_value;
  //PIN to assert or de-assert
  //---------------------------------------------------------------------------
  // Field: intx_pin
  // This field is PIN to assert or de-assert
  //---------------------------------------------------------------------------
  rand cdn_pcie_intx_trans_kind              intx_pin[4];
  //---------------------------------------------------------------------------
  // Field: intx_out_pin
  // This Field is a inteerupt out pin
  //---------------------------------------------------------------------------
  rand cdn_pcie_intx_trans_kind              intx_out_pin[4];
  //pending status vector. used by monitor. Assuming a max of 64 PFs
  //---------------------------------------------------------------------------
  // Field: intx_pending_status
  // This Field is a  pending status vector used by monitor assuming a max of 64 pfs
  //---------------------------------------------------------------------------
  rand bit [63:0] intx_pending_status;
  rand bit [3:0]  m_intr_pins[4];
  rand bit        m_intr_pins_flag[4];

  rand bit intr_pin_en[4];
  bit dont_update_intx_pin;
  //---------------------------------------------------------------------------
  // Field: fid_active
  // This Field is a function id active
  //---------------------------------------------------------------------------
  rand bit [255:0] fid_active;

  //posedge clock time at which request asserted and ack received
  //---------------------------------------------------------------------------
  // Field: start_time[4], end_time[4]//todo
  // This Field is posedge clock time at which request asserted and ack received
  //---------------------------------------------------------------------------
  time start_time[4], end_time[4];


  //-------------------------------------------------------------------
  // MSI/MSIX Random fields
  //-------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Field: msi_en
  // This Field is a message signaled interrupt bit enable
  //---------------------------------------------------------------------------
  rand bit                       msi_en;
  //---------------------------------------------------------------------------
  // Field: id_based_ordering
  // This Field is id based ordering
  //---------------------------------------------------------------------------
  rand bit                       id_based_ordering;
  //---------------------------------------------------------------------------
  // Field: msi_msix_requestor_id
  // This Field is a msix requestor id
  //---------------------------------------------------------------------------
  rand bit [24:0]                msi_msix_requestor_id;
  //---------------------------------------------------------------------------
  // Field: intr_number
  // This Field is  interrupt number
  // Valid values : [0 : 31]
  //---------------------------------------------------------------------------
  rand bit [4:0]                 intr_number; //Valid values : [0 : 31]
  //---------------------------------------------------------------------------
  // Field: intr_number_bits
  // This Field is a interrupt number bits
  // Valid values : [0 : 31]
  //---------------------------------------------------------------------------
  rand bit [4:0]                 intr_number_bits; //Valid values : [0 : 31]
  //---------------------------------------------------------------------------
  // Field: intr_number_bits_cap
  // This Field is a interrupt number bits cap
  // Valid values : [0 : 31]
  //---------------------------------------------------------------------------
  rand bit [4:0]                 intr_number_bits_cap; //Valid values : [0 : 31]
  //---------------------------------------------------------------------------
  // Field: int_msix_msg_data
  // This Field is a msix message data
  //---------------------------------------------------------------------------
  rand bit [31:0]                int_msix_msg_data;
  //---------------------------------------------------------------------------
  // Field: int_msix_msg_lo_addr
  // This Field is a msix lower address message
  //---------------------------------------------------------------------------
  rand bit [31:0]                int_msix_msg_lo_addr;
  //---------------------------------------------------------------------------
  // Field: int_msix_msg_hi_addr
  // This Field is a msix higher address message
  //---------------------------------------------------------------------------
  rand bit [31:0]                int_msix_msg_hi_addr;

  //---------------------------------------------------------------------------
  // Field: pending_status
  // This Field is a pending status for msix
  //---------------------------------------------------------------------------
  rand bit [31:0]                pending_status;
  //---------------------------------------------------------------------------
  // Field: requestor_id_for_pending_status
  // This Fiels is a requestor id for pensing status
  //---------------------------------------------------------------------------
  rand bit [7:0]                 requestor_id_for_pending_status;
  //---------------------------------------------------------------------------
  // Field: int_msi_pending_status_valid
  // This Field is a msi pending status valid
  //---------------------------------------------------------------------------
  rand bit                       int_msi_pending_status_valid;
  //---------------------------------------------------------------------------
  // Field: int_msi_pending_status
  // This Field is a int msi pending status
  //---------------------------------------------------------------------------
  rand bit [31:0]                int_msi_pending_status;
  //---------------------------------------------------------------------------
  // Field: msi_msg_low_addr
  // This Field is a msi message of lower address
  //---------------------------------------------------------------------------
  rand bit [31:0]                msi_msg_low_addr;
  //---------------------------------------------------------------------------
  // Field: msi_msg_hi_addr
  // This Field is a msi message of higher address
  //---------------------------------------------------------------------------
  rand bit [31:0]                msi_msg_hi_addr;
  //---------------------------------------------------------------------------
  // Field: msi_msg_data
  // This Field is a msi message data
  //---------------------------------------------------------------------------
  rand bit [31:0]                msi_msg_data;
  //---------------------------------------------------------------------------
  // Field: ext_msg_data_en
  // This Field is a extended message data enable
  //---------------------------------------------------------------------------
  rand bit                       ext_msg_data_en;
  //---------------------------------------------------------------------------
  // Field: msi_64bit_addr_cap
  // This Field is a 64 bit addr capable
  //---------------------------------------------------------------------------
  rand bit                       msi_64bit_addr_cap;
  //---------------------------------------------------------------------------
  // Field: msi_per_vector_masking_cap
  // This Field is a msi per vector masking capable
  //---------------------------------------------------------------------------
  rand bit                       msi_per_vector_masking_cap;
  //---------------------------------------------------------------------------
  // Field: msi_mask
  // This Field is a msi mask
  //---------------------------------------------------------------------------
  rand bit [31:0]                msi_mask;
  //---------------------------------------------------------------------------
  // Field: msix_mask
  // This Field is a msix mask
  //---------------------------------------------------------------------------
  rand bit                       msix_mask;
  //---------------------------------------------------------------------------
  // Field: msi_enable
  // This Field is msi enable
  //---------------------------------------------------------------------------
  rand bit                       msi_enable;
  //---------------------------------------------------------------------------
  // Field: st_tag_pin_or_reg
  // This Field indicate st_tag selection bit from pin or register
  //---------------------------------------------------------------------------
  rand bit                       st_tag_pin_or_reg;
  //---------------------------------------------------------------------------
  // Field: tph_st_table_index
  // This Field gives the valid index value
  //---------------------------------------------------------------------------
  rand bit [6:0]                 tph_st_table_index;
  //---------------------------------------------------------------------------
  // Field: msix_en
  // This Field is a msix enable
  //---------------------------------------------------------------------------
  rand bit                       msix_en;

  //---------------------------------------------------------------------------
  // Field: tph_present
  // This Field indicates tph present
  //---------------------------------------------------------------------------
  rand bit                       tph_present;
  //---------------------------------------------------------------------------
  // Field: extended_tph_valid
  // This Fiels is a extended tph valid
  //---------------------------------------------------------------------------
  rand bit                       extended_tph_valid;
  //---------------------------------------------------------------------------
  // Field: int_msg_valid
  // This Field is a interrupt message valid
  //---------------------------------------------------------------------------
  rand bit [1:0]                 int_msg_valid;
  //---------------------------------------------------------------------------
  // Field: tph_type
  // This Field is a tph type
  //---------------------------------------------------------------------------
  rand bit [1:0]                 tph_type;
  //---------------------------------------------------------------------------
  // Field: tph_st_tag
  // This Field is a status tag
  //---------------------------------------------------------------------------
  rand bit [16:0]                tph_st_tag;

  //attr
  //---------------------------------------------------------------------------
  // Field: attributes
  // This Field is a  attribute which indicates ordering,snooping
  //---------------------------------------------------------------------------
  rand bit [2:0]                 attributes;
  //---------------------------------------------------------------------------
  // Field: attr_no_snoop
  // This Field is a attribute no snoop
  //---------------------------------------------------------------------------
  rand bit                       attr_no_snoop;
  //---------------------------------------------------------------------------
  // Field: attr_relax_ordering
  // This Field is a relax ordering attribute
  //---------------------------------------------------------------------------
  rand bit                       attr_relax_ordering;
  //---------------------------------------------------------------------------
  // Field: attr_ido
  // This Field is a attribute id which will be used in do_pack function
  //---------------------------------------------------------------------------
  rand bit                       attr_ido;

  //PASID
  //---------------------------------------------------------------------------
  // Field: pasidPresent
  // This Field os a process id present
  //---------------------------------------------------------------------------
  rand bit pasidPresent;
  //---------------------------------------------------------------------------
  // Field: pasidVal
  // This Field is a process id value
  //---------------------------------------------------------------------------
  rand bit [23:0] pasidVal;
  //---------------------------------------------------------------------------
  // Field: pasidExecReq
  // This Field is a passid exetended  request
  //---------------------------------------------------------------------------
  rand bit pasidExecReq;
  //---------------------------------------------------------------------------
  // Field: pasidPriModeReq
  // This Field is a passid prior mose request
  //---------------------------------------------------------------------------
  rand bit pasidPriModeReq;

  //ATS
  //---------------------------------------------------------------------------
  // Field: atsPresent
  // This Field is ats present
  //---------------------------------------------------------------------------
  rand bit [1:0] atsPresent;
  //---------------------------------------------------------------------------
  // Field: ats_at
  // This Field is address translation services for at
  //---------------------------------------------------------------------------
  rand bit [1:0] ats_at;
  //---------------------------------------------------------------------------
  // Field: tc_val
  // This Field is a traffic class vlaue
  //---------------------------------------------------------------------------
  rand bit [2:0] tc_val;

  //assigned by monitor for scoreboardign purpose
  //---------------------------------------------------------------------------
  // Field: abort_status
  // This Field is assigned by monitor for scoreboardign purpose
  //---------------------------------------------------------------------------
  bit                            abort_status;
  //---------------------------------------------------------------------------
  // Field: int_mask_changed_ipfivf
  // TODO
  //---------------------------------------------------------------------------
  bit [24:0]                     int_mask_changed_ipfivf;
  //---------------------------------------------------------------------------
  // Field: int_mask_changed_valid
  // TODO
  //---------------------------------------------------------------------------
  bit                            int_mask_changed_valid;
  //---------------------------------------------------------------------------
  // Field: int_msg_done
  // This Field is a interrupt message done
  //---------------------------------------------------------------------------
  bit [3:0]                      int_msg_done;
  //---------------------------------------------------------------------------
  // Field: int_msi_cap
  // This Field is int msi capability
  //---------------------------------------------------------------------------
  bit [35:0]                     int_msi_cap;
  //---------------------------------------------------------------------------
  // Field: int_msix_cap
  // This Fiedl is int msix capability
  //---------------------------------------------------------------------------
  bit [1:0]                      int_msix_cap;

  //posedge clock time at which request asserted and ack received
  //---------------------------------------------------------------------------
  // Field: msi_msix_start_time, msi_msix_end_time
  //posedge clock time at which request asserted and ack received
  //---------------------------------------------------------------------------
  time msi_msix_start_time, msi_msix_end_time;

  // TODO: Consider Negotiation instead of mode
  //---------------------------------------------------------------------------
  // Field: cxl_mode
  // 0 - NO CXL mode
  // 1 - CXL mode
  //---------------------------------------------------------------------------
  bit cxl_mode;

  // Field: cxl_sbsa_test
  // 0 - NO CXL mode
  // 1 - CXL mode
  //---------------------------------------------------------------------------
  bit cxl_sbsa_test;
  //---------------------------------------------------------------------------
  // Field: cxl_version
  // This field will specify CXL version
  //---------------------------------------------------------------------------
  int  cxl_version;
  //---------------------------------------------------------------------------
  // Field: cxl_vdm_master
  // This field will specify CXL master and slave
  //---------------------------------------------------------------------------
  rand bit cxl_vdm_master;
  //---------------------------------------------------------------------------
  // Field: cxl_io_tlp
  // This field is used to select address which targets RCRB space
  //---------------------------------------------------------------------------
  rand bit cxl_io_tlp;

  //---------------------------------------------------------------------------
  // Field: cxl_io_rcrb_tlp
  // This field is used to select address which targets RCRB space
  //---------------------------------------------------------------------------
  rand bit cxl_io_rcrb_tlp;
  bit cxl_io_rcrb_cov_tlp;
  //---------------------------------------------------------------------------
  // Field: cxl_io_membar_tlp
  // This field is used to select address which targets RCRB space
  //---------------------------------------------------------------------------
  rand bit cxl_io_membar_tlp;
  bit cxl_io_membar_cov_tlp;

  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pm_logical_opcode
  //
  //---------------------------------------------------------------------------
  rand cdn_hpa_cxl_pm_logical_op_t           m_cxl_vdm_pm_logical_opcode;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pm_agt_id
  // O
  //---------------------------------------------------------------------------
  rand bit [6:0]                             m_cxl_vdm_pm_agt_id;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pm_agt_id_rsvd_bit
  //
  //---------------------------------------------------------------------------
  rand bit                                   m_cxl_vdm_pm_agt_id_rsvd_bit;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_parameter
  //
  //---------------------------------------------------------------------------
  rand bit [15:0]                            m_cxl_vdm_parameter;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_payload
  //
  //---------------------------------------------------------------------------
  rand bit [95:0]                            m_cxl_vdm_payload;
  //---------------------------------------------------------------------------
  // Field: msg_pm_cxl_vnd_msg_byte_12_14_rsvd
  //
  //---------------------------------------------------------------------------
  rand bit [23:0]                            msg_pm_cxl_vnd_msg_byte_12_14_rsvd;
  //---------------------------------------------------------------------------
  // Field: msg_cxl_vdm_msg_bits_rsvd
  // Byte 12 an 13 is reserved
  //---------------------------------------------------------------------------
  rand bit [19:0]                            msg_cxl_vdm_msg_bits_rsvd;
  //---------------------------------------------------------------------------
  // Field: msg_cxl_vdm_msg_fw_interrupt_vector
  // firmware interrupt vector
  //---------------------------------------------------------------------------
  rand bit [3:0]                            msg_cxl_vdm_msg_fw_interrupt_vector;

  //CXL VND PM Msg Parameter field segregation
  //Credit Return
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_crd_rtn_param_field_rsvd
  //---------------------------------------------------------------------------
  rand bit [15:0]                            m_cxl_vdm_crd_rtn_param_field_rsvd;
  //AGent_info
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_agt_info_req_or_rsp
  //---------------------------------------------------------------------------
  rand bit                                   m_cxl_vdm_agt_info_req_or_rsp; //0: Req   1: Rsp
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_agt_info_index
  //---------------------------------------------------------------------------
  rand bit [6:0]                             m_cxl_vdm_agt_info_index;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_agt_info_param_byte1_rsvd
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_cxl_vdm_agt_info_param_byte1_rsvd;
  //PM Req
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pmreq_req_or_rsp
  //---------------------------------------------------------------------------
  rand bit                                   m_cxl_vdm_pmreq_req_or_rsp; //0: Req   1: Rsp
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pmreq_ea
  //---------------------------------------------------------------------------
  rand bit                                   m_cxl_vdm_pmreq_ea;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pmreq_go
  //---------------------------------------------------------------------------
  rand bit                                   m_cxl_vdm_pmreq_go;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pmreq_param_byte0_1_rsvd
  //---------------------------------------------------------------------------
  rand bit [12:0]                            m_cxl_vdm_pmreq_param_byte0_1_rsvd;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pmreq_param_bit1_rsvd
  // Bit 1 is reserved for CXL2.0
  //---------------------------------------------------------------------------
  rand bit                             m_cxl_vdm_pmreq_param_bit1_rsvd;
  //GPF
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_param_byte0_1_rsvd
  // Reserved bytes
  //---------------------------------------------------------------------------
  rand bit [14:0]                            m_cxl_vdm_gpf_param_byte0_1_rsvd;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_req_or_rsp
  // Reserved bit
  //---------------------------------------------------------------------------
  rand bit                                   m_cxl_vdm_gpf_req_or_rsp; //0: Req   1: Rsp


  //RESET Prep
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_resetprep_req_or_rsp
  //---------------------------------------------------------------------------
  rand bit                                   m_cxl_vdm_resetprep_req_or_rsp; //0: Req   1: Rsp
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_resetprep_param_byte0_1_rsvd
  //---------------------------------------------------------------------------
  rand bit [14:0]                            m_cxl_vdm_resetprep_param_byte0_1_rsvd;

  //CXL VND PM Msg Payload field segregation
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_crd_rtn_payload_num_credits
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_cxl_vdm_crd_rtn_payload_num_credits;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_crd_rtn_payload_tgt_agt_id
  //---------------------------------------------------------------------------
  rand bit [6:0]                             m_cxl_vdm_crd_rtn_payload_tgt_agt_id;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_crd_rtn_payload_rsvd
  //---------------------------------------------------------------------------
  rand bit [80:0]                            m_cxl_vdm_crd_rtn_payload_rsvd;
  //AGent_info
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_agt_info_revision_id
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_cxl_vdm_agt_info_revision_id; //Holds reserved values when m_cxl_vdm_agt_info_index!=0
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_agt_info_payload_rsvd
  // This Field Holds reserved values when m_cxl_vdm_agt_info_index!=0
  //---------------------------------------------------------------------------
  rand bit [87:0]                            m_cxl_vdm_agt_info_payload_rsvd;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_agt_info_capability_vector_bit0
  // Always set to indicate support for PM messages defined in CXL 1.1 spec.
  //---------------------------------------------------------------------------
  rand bit                             m_cxl_vdm_agt_info_capability_vector_bit0;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_agt_info_capability_vector_bit1
  // Support for GPF messages.
  //---------------------------------------------------------------------------
  rand bit                             m_cxl_vdm_agt_info_capability_vector_bit1;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_agt_info_payload_rsvd_93_3
  // This Field Holds reserved values when m_cxl_vdm_agt_info_index!=0
  //---------------------------------------------------------------------------
  rand bit [93:0]                            m_cxl_vdm_agt_info_payload_rsvd_93_3;

  //PM Req
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pmreq_ltr
  //---------------------------------------------------------------------------
  rand bit [31:0]                            m_cxl_vdm_pmreq_ltr;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pmreq_payload_rsvd
  //---------------------------------------------------------------------------
  rand bit [63:0]                            m_cxl_vdm_pmreq_payload_rsvd;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_pmreq_ltr_2
  // PCIe LTR format
  //---------------------------------------------------------------------------
  rand bit [31:0]                            m_cxl_vdm_pmreq_ltr_2;

  //RESET Prep
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_resetprep_reset_type
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_cxl_vdm_resetprep_reset_type; //TODO can it be made as enum
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_resetprep_prep_type
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_cxl_vdm_resetprep_prep_type; //TODO can it be made as enum
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_resetprep_phase
  //---------------------------------------------------------------------------
  rand bit [1:0]                             m_cxl_vdm_resetprep_phase; //TODO can it be made as enum
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_resetprep_payload_rsvd
  //---------------------------------------------------------------------------
  rand bit [77:0]                            m_cxl_vdm_resetprep_payload_rsvd;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_resetprep_payload_rsvd_96_9
  // Reserved bits
  //---------------------------------------------------------------------------
  rand bit [79:0]                            m_cxl_vdm_resetprep_payload_rsvd_95_9;

  //GPF
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_payload_bit0
  // Set to indicate powerful immenent, only valid for phase1 request messages
  //---------------------------------------------------------------------------
  rand bit                             m_cxl_vdm_gpf_payload_bit0;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_payload_bit1
  // Set to indicate device must flush its caches. Only valid for Phase 1 request messages
  //---------------------------------------------------------------------------
  rand bit                             m_cxl_vdm_gpf_payload_bit1;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_payload_rsvd_7_2
  // This field [7:2] is reserved
  //---------------------------------------------------------------------------
  rand bit [5:0]                            m_cxl_vdm_gpf_payload_rsvd_7_2;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_status_bit8
  // Set to indicate Cache Flush phase encountered an error. Only valid for Phase 1 responses and Phase 2 requests
  //---------------------------------------------------------------------------
  rand bit                             m_cxl_vdm_gpf_status_bit8;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_payload_rsvd_15_9
  //  This field [15:9] is reserved
  //---------------------------------------------------------------------------
  rand bit [6:0]                             m_cxl_vdm_gpf_payload_rsvd_15_9;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_payload_phase
  // Phase 0/1
  //---------------------------------------------------------------------------
  rand bit [1:0]                             m_cxl_vdm_gpf_payload_phase;
  //---------------------------------------------------------------------------
  // Field: m_cxl_vdm_gpf_payload_rsvd_95_18
  //  This field [95:18] is reserved
  //---------------------------------------------------------------------------
  rand bit [76:0]                             m_cxl_vdm_gpf_payload_rsvd_95_18;

  //ATS - CXL
  //---------------------------------------------------------------------------
  // Field: m_cxl_src
  //---------------------------------------------------------------------------
  rand bit                                   m_cxl_src;

  rand bit [15:0]                            m_cxl_ldid;
  bit                                        cxl_ldid_prefix;

  //---------------------------------------------------------------------------
  // Field: is_cxl_pbr_mode
  // This Field is indicator if CXL is in PBR mode (FM)
  //---------------------------------------------------------------------------
  bit                                        is_cxl_pbr_mode;

  //---------------------------------------------------------------------------
  // Field: hls_ib_p_np_meta_s
  // TODO
  //---------------------------------------------------------------------------
  cdn_pcie_hls_ib_p_np_metadata_s            hls_ib_p_np_meta_s;//todo
  //---------------------------------------------------------------------------
  // Field: hls_ib_cpl_meta_s
  // TODO
  //---------------------------------------------------------------------------
  cdn_pcie_hls_ib_cpl_metadata_s             hls_ib_cpl_meta_s; //todo

  //---------------------------------------------------------------------------
  // Field: hls_ob_meta_s
  // Field to store the tl2hls metadata
  //---------------------------------------------------------------------------
  cdn_pcie_tl2hls_p_np_metadata_s                 hls_tl2hls_p_np_meta_s;
  //---------------------------------------------------------------------------
  // Field: hls_ob_meta_s
  // Field to store the tl2hls metadata
  //---------------------------------------------------------------------------
  cdn_pcie_tl2hls_cpl_metadata_s                 hls_tl2hls_cpl_meta_s;
  //---------------------------------------------------------------------------
  // Field: hls_ob_meta_s
  // Field to store the al2hls/OB metadata
  //---------------------------------------------------------------------------
  cdn_pcie_ob_metadata_s                    hls_ob_meta_s;
  //---------------------------------------------------------------------------
  // Field: hls_ob_meta_s
  // Field to store the al2hls/OB metadata
  //---------------------------------------------------------------------------
  cdn_pcie_hls2tl_metadata_s                hls_hls2tl_meta_s;
  //---------------------------------------------------------------------------
  // Field: is_ib_pkt
  // Indicats whether this is IB or OB Packet
  //---------------------------------------------------------------------------
  bit                                        is_ib_pkt; //1-> IB pkt; 0-> OB Pkt //todo
  //---------------------------------------------------------------------------
  // Field: m_cpl_part
  // Indicats whether this is First/Last/FirstLast CPl
  //---------------------------------------------------------------------------
  cdn_hpa_pcie_cpl_t                         m_cpl_part; //1-> IB pkt; 0-> OB Pkt //todo
  //---------------------------------------------------------------------------
  // Field: is_translation_cpl
  // Translation completion indicator
  //---------------------------------------------------------------------------
  bit                                        is_translation_cpl; //1-> Translation completion indicator;

  //---------------------------------------------------------------------------
  // Field: hls_module_traffic
  // Used to indicate HLS module traffic for module level TB
  //---------------------------------------------------------------------------
  bit                                        hls_module_traffic;

  //---------------------------------------------------------------------------
  // Field: is_flit_mode
  // This Field is indicator to generate flit mode tlp. Default: Non-Flit mode
  //---------------------------------------------------------------------------
  bit                                        is_flit_mode;

  //---------------------------------------------------------------------------
  // Field: is_ide_tlp
  // This Field is indicator to generate ide tlp. Default: Not a IDE Tlp
  //---------------------------------------------------------------------------
  bit                                        is_ide_tlp;

  //---------------------------------------------------------------------------
  // Field: is_stream_id_discard
  // This Field is indicator to subsequent tlp discarded due to stream id.
  //---------------------------------------------------------------------------
  bit                                        is_stream_id_discard;

  //---------------------------------------------------------------------------
  // Field: hpa_generation
  // This Field is indicator to generate hpa 1.0/2.0 tlp. Default: 1.0
  //---------------------------------------------------------------------------
  hpa_generation_t                           hpa_generation;

  bit                                        pcie_6_1_support;

  //------------------------------------------------------------------------------
  // Field: num_uio_vcs
  // This bit is to indicate if support for UIO packets is:
  // 0 - disabled
  // 1 - enabled on VC3
  // 2 - enabled on VC3 and VC4
  //------------------------------------------------------------------------------
  bit [1:0]                                  num_uio_vcs;

  // Field: axi_region_prog
  // This bit is to indicate whether pcie tlp randomize for axi
  // programming initaily
  bit                                        axi_region_prog;

  //---------------------------------------------------------------------------
  // Field: m_ohc_hdr
  // This Field is the OHC header field in Flit mode
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_ohc_hdr_s                     m_ohc_hdr;

  //---------------------------------------------------------------------------
  // Field: m_ts
  // This Field is trailer field
  // This field contains ECRC, PCRC(P) and MAC(M) information for IDE/non-IDE TLP
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_ts_type_t                m_ts;

  //---------------------------------------------------------------------------
  // Field: m_ts_payload[]
  // This Field is the corresponding payload for trailer indicated by m_ts
  //---------------------------------------------------------------------------
  rand reg [7:0]                             m_ts_payload[];

  //---------------------------------------------------------------------------
  // Field: implcit_byte_enable_mem_tlps
  // This Field is indicator to send a MEM TLP without OHC-A1(Ie., BE are implied to 'hF & no pasid present).
  //---------------------------------------------------------------------------
  rand bit                                   implcit_byte_enable_mem_tlps;

  //---------------------------------------------------------------------------
  // Field: m_destination_segment
  // This Field is indicator of destination segment in OHC-A fields
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_destination_segment;

  //---------------------------------------------------------------------------
  // Field: m_destination_segment_valid
  // This Field is indicator of destination segment valid in OHC-A fields
  //---------------------------------------------------------------------------
  rand bit                                   m_destination_segment_valid;

  //---------------------------------------------------------------------------
  // Field: m_requester_segment
  // This Field is indicator of requester segment in OHC-A/C fields
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_requester_segment;

  //---------------------------------------------------------------------------
  // Field: m_completer_segment
  // This Field is indicator of completion segment in OHC-A fields
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_completer_segment;

  //---------------------------------------------------------------------------
  // Field: m_hv
  // This Field is indicator of PH&ST valid in OHC-B fields
  //---------------------------------------------------------------------------
  rand bit [1:0]                             m_hv;

  //---------------------------------------------------------------------------
  // Field: m_ama_value
  // This Field is indicator of AMA value in OHC-B fields/TPH Prefix in NFM
  //---------------------------------------------------------------------------
  rand bit [2:0]                             m_ama_value;

  //---------------------------------------------------------------------------
  // Field: m_ama_valid
  // This Field is indicator of AMA value in OHC-B fields/TPH Prefix in NFM
  //---------------------------------------------------------------------------
  rand bit                                   m_ama_valid;

  //---------------------------------------------------------------------------
  // Field: m_pr_sent_counter
  // This Field indicates number of IDE Posted Requests Sent prior to NP/CPL TLP
  // This value will be calculated internally by the DUT/BFM
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_pr_sent_counter;

  //---------------------------------------------------------------------------
  // Field: m_stream_id
  // This Field indicates Stream ID for IDE TLP
  //---------------------------------------------------------------------------
  rand bit [7:0]                             m_stream_id;
  rand int                                   m_stream_id_int;
  rand bit                                   m_sel_stream_possible;
  rand bit                                   use_user_defined_stream_id;

  //---------------------------------------------------------------------------
  // Field: m_sub_stream
  // This Field indicates sub stream ID for IDE TLP
  //---------------------------------------------------------------------------
  rand bit [3:0]                             m_sub_stream;

  //---------------------------------------------------------------------------
  // Field: m_requester_segment_valid
  // This Field is indicator of P value in OHC-C fields
  //---------------------------------------------------------------------------
  rand bit                                   m_requester_segment_valid;

  //---------------------------------------------------------------------------
  // Field:  msg_ide_sync_byte_8_11_rsvd
  // This Field is IDE Sync Msg reserved bits for bytes 8 to 11
  //---------------------------------------------------------------------------
  rand bit [31:0]                            msg_ide_sync_byte_8_11_rsvd;

  //---------------------------------------------------------------------------
  // Field:  msg_ide_sync_byte_14_rsvd
  // This Field is IDE Sync Msg reserved bits for 14th byte
  //---------------------------------------------------------------------------
  rand bit [7:0]                             msg_ide_sync_byte_14_rsvd;

  //---------------------------------------------------------------------------
  // Field:  msg_ide_sync_byte_12_rsvd
  // This Field is IDE Sync Msg reserved bits for 12th byte
  //---------------------------------------------------------------------------
  rand bit [7:0]                             msg_ide_sync_byte_12_rsvd;

  //---------------------------------------------------------------------------
  // Field: msg_ide_sync_pr_sent_cnt_np
  // This Field indicates number of IDE Posted Requests Sent prior to NP TLP
  //---------------------------------------------------------------------------
  rand bit [7:0]                             msg_ide_sync_pr_sent_cnt_np;

  //---------------------------------------------------------------------------
  // Field: msg_ide_sync_pr_sent_cnt_cpl
  // This Field indicates number of IDE Posted Requests Sent prior to CPL TLP
  //---------------------------------------------------------------------------
  rand bit [7:0]                             msg_ide_sync_pr_sent_cnt_cpl;

  //---------------------------------------------------------------------------
  // Field:  msg_ide_escort_byte_6_field_6_2
  // This Field is IDE Escort Msg reserved bits[6:2] for 6th byte
  //---------------------------------------------------------------------------
  rand bit [4:0]                             msg_ide_escort_byte_6_field_6_2;

  //---------------------------------------------------------------------------
  // Field: msg_ide_escort_sse
  // This Field indicates the sub stream escort type in IDE Escort MSG
  //---------------------------------------------------------------------------
  rand bit [1:0]                             msg_ide_escort_sse;

  //---------------------------------------------------------------------------
  // Field:  msg_ide_fail_byte_8_9_rsvd
  // This Field is IDE Fail Msg reserved bits for bytes 8 to 9
  //---------------------------------------------------------------------------
  rand bit [15:0]                             msg_ide_fail_byte_8_9_rsvd;

  //---------------------------------------------------------------------------
  // Field:  msg_ide_fail_byte_10_rsvd
  // This Field is IDE Fail Msg reserved bits for 10th byte
  //---------------------------------------------------------------------------
  rand bit [7:0]                             msg_ide_fail_byte_10_rsvd;

  //---------------------------------------------------------------------------
  // Field:  msg_ide_fail_byte_12_15_rsvd
  // This Field is IDE Fail Msg reserved bits for bytes 12 to 15
  //---------------------------------------------------------------------------
  rand bit [31:0]                            msg_ide_fail_byte_12_15_rsvd;

  //---------------------------------------------------------------------------
  // Field:  msg_ide_fail_stream_id
  // This Field is IDE Fail Msg Stream ID
  //---------------------------------------------------------------------------
  rand bit [7:0]                             msg_ide_fail_stream_id;

  //---------------------------------------------------------------------------
  // Field: m_ide_p
  // This Field indicates PCRC(P) Bit for IDE TLP
  //---------------------------------------------------------------------------
  rand bit                                   m_ide_p;
  rand bit[31:0]                             m_ide_pcrc;
  rand bit[31:0]                             t_ide_pcrc;
  bit                                        ide_pr_sent_counter_err;
  bit                                        ide_invalid_substream;

  //---------------------------------------------------------------------------
  // Field: misrouted_ide_tlp_err
  // This Field indicates MISROUTED IDE ERROR for IDE TLP
  //---------------------------------------------------------------------------
  bit                                         misrouted_ide_tlp_err;

  //---------------------------------------------------------------------------
  // Field: m_ide_m
  // This Field indicates MAC(M) bit for IDE TLP
  //---------------------------------------------------------------------------
  rand bit                                   m_ide_m;
  bit                                        m_tl_layer_scoreboard;
  rand bit                                   m_complete_aggregate;
  rand bit[7:0]                              m_ide_mac[12];
  rand bit[7:0]                              t_ide_mac[12];
  bit                                        m_tlp_discard;

  //---------------------------------------------------------------------------
  // Field: m_ide_k
  // This Field indicates Key Toggle(K) value for IDE TLP
  //---------------------------------------------------------------------------
  rand bit                                   m_ide_k;

  //---------------------------------------------------------------------------
  // Field: m_ide_t
  // This Field indicates Trusted(T) value for IDE TLP
  //---------------------------------------------------------------------------
  rand bit                                   m_ide_t;

  //---------------------------------------------------------------------------
  // Field: m_ide_hdr_fmt_prefix
  // This fields contains IDE TLP Prefix header format
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_fmt_t                m_ide_hdr_fmt_prefix;

  //---------------------------------------------------------------------------
  // Field: m_ide_hdr_type_prefix
  // This fields contains IDE TLP Prefix header type
  //---------------------------------------------------------------------------
  rand bit [4:0]                             m_ide_hdr_type_prefix;

  //---------------------------------------------------------------------------
  // Field: m_ide_tlp_prefix
  // This field is the value of IDE TLP prefix
  //---------------------------------------------------------------------------
  rand bit [31:0]                            m_ide_tlp_prefix;

  //---------------------------------------------------------------------------
  // Field: m_ohc_a
  // This Field is OHC-A(A1/A2/A3/A4/A5) of the TLP
  // It is a concatenation of other random fields, so it should not be random itself.
  //---------------------------------------------------------------------------
  bit [31:0]                                 m_ohc_a;

  //---------------------------------------------------------------------------
  // Field: m_ohc_b
  // This Field is OHC-B of the TLP
  // It is a concatenation of other random fields, so it should not be random itself.
  //---------------------------------------------------------------------------
  bit [31:0]                                 m_ohc_b;

  //---------------------------------------------------------------------------
  // Field: m_ohc_c
  // This Field is OHC-C of the TLP
  // All IDE TLPs must include OHC-C. For TLPs with OHC-C that are not IDE TLPs,
  // the Sub-Stream[3:0] field must be 0111b.
  // It is a concatenation of other random fields, so it should not be random itself.
  //---------------------------------------------------------------------------
  bit [31:0]                                 m_ohc_c;

  //---------------------------------------------------------------------------
  // Field: m_ohc_e
  // This Field is DWs of OHC-E1/E2/E4 of the TLP
  //---------------------------------------------------------------------------
  rand bit [31:0]                             m_ohc_e[];

  //---------------------------------------------------------------------------
  // Field: num_of_valid_vnd_e2e_prefixes
  // This Field indicates number of valid Vendore defined E2E prefixes in flit mode.
  // Greater than this are no Entry values
  //---------------------------------------------------------------------------
  rand bit [2:0]                              num_of_valid_vnd_e2e_prefixes;

  //---------------------------------------------------------------------------
  // Field: num_of_vnd_e2e_prefixes
  // This Field indicates number of Vendore defined E2E prefixes in flit mode.
  //---------------------------------------------------------------------------
  rand bit [2:0]                              num_of_vnd_e2e_prefixes;

  //---------------------------------------------------------------------------
  // Field: remote_supp_vnd_e2e_prefixes
  // This Field indicates other end device support Vendore defined E2E prefixes in flit mode.
  //---------------------------------------------------------------------------
  rand bit                                    remote_supp_vnd_e2e_prefixes;

  //---------------------------------------------------------------------------
  // Field: m_max_no_of_ohc_e_prefixes
  // This Field contains the maximum number of OHC-E prefixes
  //---------------------------------------------------------------------------
  rand bit [2:0]                             m_max_no_of_ohc_e_prefixes;
  ////---------------------------------------------------------------------------
  //// Field: m_completion_segment_differ
  //// This Field is CSD field of the cpl TLP
  //   Removed in 0.71 spec
  ////---------------------------------------------------------------------------
  //rand bit                                    m_completion_segment_differ;

  //---------------------------------------------------------------------------
  // Field: m_max_no_of_local_prefixes
  // This Field contains the maximum number of local prefixes
  //---------------------------------------------------------------------------
  rand bit [1:0]                             m_max_no_of_local_prefixes;

  //---------------------------------------------------------------------------
  // Field: m_local_prefix_possible
  // This Field indicator is for local prefixes possibility
  //---------------------------------------------------------------------------
  rand bit                                   m_local_prefix_possible;

  //---------------------------------------------------------------------------
  // Field: m_flit_mode_local_prefix_possible
  // This Field indicator is for FM local prefix possibility
  //---------------------------------------------------------------------------
  rand bit                                   m_flit_mode_local_prefix_possible;

  //---------------------------------------------------------------------------
  // Field: m_tlp_local_prefix
  // This field is a array of tlp prefix
  //---------------------------------------------------------------------------
  rand reg [31:0]                            m_tlp_local_prefix[];

  //---------------------------------------------------------------------------
  // Field: m_tlp_local_prefix_data
  // This field is a array of tlp prefix
  //---------------------------------------------------------------------------
  rand reg [23:0]                            m_tlp_local_prefix_data[];

  //---------------------------------------------------------------------------
  // Field: m_hdr_fmt_local_prefix
  // TLP Prefixes Releated variables
  // If two prefixes are present ==> [Prefix0][Prefix1][TLP Header][TLP Payoad(if any)]
  // Keeping hdr_fmt==TLP Prefix as seperate array. Similarly for hdr_type
  // When prefix is not present in current packet then below two fields are not used in packet formation
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_tlp_fmt_t                m_hdr_fmt_local_prefix[];
  //---------------------------------------------------------------------------
  // Field: m_hdr_type_local_prefix
  // This Field constains the header type prefix
  //---------------------------------------------------------------------------
  rand cdn_hpa_pcie_vnd_def_loc_prfx_t       m_hdr_type_local_prefix[];

  //---------------------------------------------------------------------------
  // Field: m_tlp_uses_dedicated_credits
  // This Field in Flit-mode Local TLP prefix indicates whether TLP uses
  // Dedicated credits
  //---------------------------------------------------------------------------
  rand bit                                   m_tlp_uses_dedicated_credits;

  //---------------------------------------------------------------------------
  // Field: m_flit_mode_local_prefix_as_first_prefix
  // This Field will control the order of packing Local prefixes
  //---------------------------------------------------------------------------
  rand bit                                   m_flit_mode_local_prefix_as_first_prefix;
  
  //  //---------------------------------------------------------------------------
  //  // Field: m_pth_possible
  //  // This Field indicates whether PTH possible for this TLP
  //  //---------------------------------------------------------------------------
  //  rand bit                                   m_pth_possible;
  
  //---------------------------------------------------------------------------
  // Field: m_tlp_pbr_tlp_header
  // This field is to define PTH in PBR mode (added before TLP header)
  //---------------------------------------------------------------------------
  rand bit [31:0]                            m_tlp_pbr_tlp_header;
  
  //---------------------------------------------------------------------------
  // Field: m_tlp_pth_rsvd
  // This Field in Flit-mode PTH
  //---------------------------------------------------------------------------
  rand bit [2:0]                             m_tlp_pth_rsvd;
  
  //---------------------------------------------------------------------------
  // Field: m_tlp_pth_hie
  // This Field in Flit-mode PTH
  // PTH.Hie (hierarchical) bit determines when intermediate PBR switches
  // must use static routing. (CXL Section 7.7.6.2)
  //---------------------------------------------------------------------------
  rand bit                                   m_tlp_pth_hie;
  
  //---------------------------------------------------------------------------
  // Field: m_tlp_pth_dsar
  // This Field in Flit-mode PTH
  // DSAR: (Downstream Acceptance Rules) (CXL Section 7.7.7.1)
  //---------------------------------------------------------------------------
  rand bit                                   m_tlp_pth_dsar;
  
  //---------------------------------------------------------------------------
  // Field: m_tlp_pth_pif
  // This Field in Flit-mode PTH
  // PIF: PID forward (CXL Section 7.7.3.3)
  //---------------------------------------------------------------------------
  rand bit                                   m_tlp_pth_pif;
  
  //---------------------------------------------------------------------------
  // Field: m_tlp_pth_spid
  // This Field in Flit-mode PTH is for Source PBR ID
  //---------------------------------------------------------------------------
  rand bit [11:0]                            m_tlp_pth_spid;
  
  //---------------------------------------------------------------------------
  // Field: m_tlp_pth_dpid
  // This Field in Flit-mode PTH id for Destination PBR ID
  //---------------------------------------------------------------------------
  rand bit [11:0]                            m_tlp_pth_dpid;
  
  //---------------------------------------------------------------------------
  // Field: m_invalid_req_id
  // This Field is set, if req id is invalid
  //---------------------------------------------------------------------------
  bit m_invalid_req_id;
  bit cpl_req_id_mismatch;

  //------------------------------------------------------------------------------
  // Field: byte_count_mismatch_but_chk_disabled
  // This bit is set if byte count mismatch is present but check is disabled
  //------------------------------------------------------------------------------
  bit m_byte_count_mismatch_but_chk_disabled;

  //------------------------------------------------------------------------------
  // Field: msg_code_ur_err_but_check_disabled
  // This bit is set if msg core ur error is present but check is disabled
  //------------------------------------------------------------------------------
  bit msg_code_ur_err_but_check_disabled;

  //------------------------------------------------------------------------------
  // Field: m_msg_routing_type_err_but_chk_disabled
  // This bit is set if byte count mismatch is present but check is disabled
  //------------------------------------------------------------------------------
  bit m_msg_routing_type_err_but_chk_disabled;

  //------------------------------------------------------------------------------
  // Field: m_lower_addr_mismatch_but_chk_disabled
  // This bit is set if lower addr mismatch is present but check is disabled
  //------------------------------------------------------------------------------
  bit m_lower_addr_mismatch_but_chk_disabled;

  //------------------------------------------------------------------------------
  // Field: m_cpl_complete
  // This bit is set if byte count mismatch is present/ check is disabled
  // 1: ByteCount greater than expected, if less 0
  //------------------------------------------------------------------------------
  bit m_cpl_complete;

  //------------------------------------------------------------------------------
  // Field: m_compare_byte_cnt
  // This bit is set if byte count mismatch is present/ check is disabled
  // 1: ByteCount greater than expected, if less 0
  //------------------------------------------------------------------------------
  bit m_compare_byte_cnt = 1;

  //------------------------------------------------------------------------------
  // Field: m_compare_completer_segment
  // This bit is set to enable_comparision of completer segment
  // set 0 to disable check completer_segment check
  //------------------------------------------------------------------------------
  bit m_compare_completer_segment = 1;

  //------------------------------------------------------------------------------
  // Field: m_compare_cpl_lower_addr
  // This bit is set if Lower addr mismatch is present/ check is disabled
  //------------------------------------------------------------------------------
  bit m_compare_cpl_lower_addr = 1;

  //------------------------------------------------------------------------------
  // Field: m_compare_tlp_length
  // This bit is set if length field mismatch is present/ check is disabled
  //------------------------------------------------------------------------------
  bit m_compare_tlp_length = 1;

  //------------------------------------------------------------------------------
  // Field: m_erom_bar_sel
  // This bit is set if erom bar is selected
  //------------------------------------------------------------------------------
  rand bit m_erom_bar_sel;

  //------------------------------------------------------------------------------
  // Field: hlsob2cfg_tlp
  // This bit is to indicate the OB cfg tlp targetting it's own config space in RP mode
  //------------------------------------------------------------------------------
  bit hlsob2cfg_tlp;

  //------------------------------------------------------------------------------
  // Field: cfg2hls_tlp
  // This bit is to indicate the tlp received from own config space RP mode
  //------------------------------------------------------------------------------
  bit cfg2hls_tlp;

  //------------------------------------------------------------------------------
  // Field: m_len_neq_payload_err,m_errored_length
  // This bit is to indicate the reserved tyoe error in module level
  //------------------------------------------------------------------------------
  bit m_len_neq_payload_err;
  bit[9:0] m_errored_length;
  bit unpack_payload=1;

  string ptc_cv_test_name;

  bit m_expect_enderror;
  bit pkt_targeting_vf_in_not_allowed_pf;
  bit pkt_targeting_disabled_vf;

  //------------------------------------------------------------------------
  // HIGHER LEVEL CONTROL KNOBS
  //------------------------------------------------------------------------
  bit apply_directed_tlp;
  int num_of_header_dw;
  bit [31:0] rsvd_4th_dw;
  bit [31:0] rsvd_5th_dw;
  bit [31:0] rsvd_6th_dw;
  bit [31:0] rsvd_7th_dw;
  bit [31:0] rsvd_8th_dw;

  rand bit tdisp_is_ib;
  rand int tdisp_func_num;
  rand int tdisp_stream_id;
  rand int default_stream_id;
  rand bit msg_type_tc_0;
        
  
  //------------------------------------------------------------------------
  // CONSTRAINT BLOCKS.
  //-----------------------------------------------------------
  //--------------------------------------------------------------------------
  // Constraint:
  // This soft constraint will set the enable the error injection bits to zero.
  //--------------------------------------------------------------------------
  constraint c_err_inj {
    soft enable_inject_errors == 0;
    soft m_inject_dl_err == 0;
    soft disable_inject_errors == 0;
    soft m_scenario_error_inject == CDN_HPA_PCIE_TLP_NO_ERR;
    solve m_tlp_type before m_scenario_error_inject;

    if(m_pcie_dev_top_cfg.inject_err_en || (m_pcie_dev_top_cfg.i_cfg.strap_port_type inside {2}))
    top_cfg_enable_errors == 1;
    else
    top_cfg_enable_errors == 0;
  }

  constraint pri_msi_msix_msg_c {
    pri_msi_msix_msg dist {0:=80,1:=20};
  }

  //--------------------------------------------------------------------------
  // Constraint: c_cxl_io_mem_tlp
  //--------------------------------------------------------------------------
  constraint  c_cxl_io_mem_tlp {
    if(m_pcie_dev_top_cfg.m_cxl_negotiation == CXL_1_1) {
      //CXL RCRB/MemBAR space is common to all function and PF0 will be returned for all destination targetted by the CXLIO packet.
      //Hence Generating it only for PF0
      if(m_pcie_dev_cfg.m_req_id.function_num == 0)
      // 1/4 Tlps for CXL RCRB/MEMBAR and 3/4 Tlps PCIe BARs
      cxl_io_tlp dist {1:=1, 0:=4};
      //cxl_io_tlp == 1;
      else
      cxl_io_tlp == 0;
    }
    else  {
      cxl_io_tlp == 0;
    }
    if(cxl_io_tlp) {
      cxl_io_rcrb_tlp != cxl_io_membar_tlp;
    }
    else {
      cxl_io_rcrb_tlp == 0;
      cxl_io_membar_tlp == 0;
    }
    if(cxl_io_tlp && m_tlp_length < 2 **(7+m_pcie_dev_top_cfg.m_cxl_io_membar_aperture))
    cxl_io_membar_tlp == 0;
    solve cxl_io_tlp before cxl_io_rcrb_tlp;
    solve cxl_io_tlp before cxl_io_membar_tlp;

    cxl_io_rcrb_tlp -> !(m_tlp_type inside {
      CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
      CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32, CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
      CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
      CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64
    });
    // TODO - VIPSR # Currently VIP is considering the Memory TLPs with prefixes are UR requests
    cxl_io_rcrb_tlp -> m_max_no_of_prefixes  == 0;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_int_msg_valid
  // This soft constraint generate interrupt message valid
  //--------------------------------------------------------------------------
  constraint c_int_msg_valid {
    soft int_msg_valid inside {1,2};
  }

  //--------------------------------------------------------------------------
  // Constraint: c_m_msi_msix_pkt
  // This soft constraint generate for normal traffice
  // For msi/msix need to drive 1 from the sequence
  //--------------------------------------------------------------------------
  //  constraint c_m_msi_msix_pkt {
  //    soft m_msi_msix_pkt == 0;
  //  }

  //--------------------------------------------------------------------------
  // Constraint: c_st_tag_pin_or_reg
  // This constraint generate st tag value for MSI/MSIX
  // 0 - Value will be taken from Pin
  // 1 - Value will be taken from Register
  //--------------------------------------------------------------------------
  constraint c_st_tag_pin_or_reg {
    solve m_tph_present before st_tag_pin_or_reg;
    soft st_tag_pin_or_reg dist {0:=50, 1:=50};
    if(m_pcie_dev_cfg.m_st_table_loc != 1){
      st_tag_pin_or_reg == 0;
    }
    if((m_tph_present == 0) || (m_pcie_dev_cfg.m_st_mode_sel == 2'b00)){
      st_tag_pin_or_reg == 0;
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_tph_st_table_index
  // This constraint generate tph_st_table_index value for MSI/MSIX
  //--------------------------------------------------------------------------
  constraint c_tph_st_table_index {
    soft tph_st_table_index == m_pcie_dev_top_cfg.tph_st_table_index;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_tlp_fmt_and_type
  // This Constraint generate TLP header format and the type of transaction
  //--------------------------------------------------------------------------
  constraint c_tlp_fmt_and_type {
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32 && is_flit_mode)      -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b00011;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32 && !is_flit_mode)      -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b00000;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)      -> m_hdr_fmt == 3'b001 && m_hdr_type == 5'b00000;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)    -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b00001;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)    -> m_hdr_fmt == 3'b001 && m_hdr_type == 5'b00001;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32)      -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b00000;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_64)      -> m_hdr_fmt == 3'b011 && m_hdr_type == 5'b00000;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IORd)        -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b00010;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IOWr)        -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b00010;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd0)      -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b00100;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr0)      -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b00100;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd1)      -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b00101;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr1)      -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b00101;
    //(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_TCfgRd)      -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b11011;
    //(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_TCfgWr)      -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b11011;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg)         -> m_hdr_fmt == 3'b001 && m_hdr_type[4:3] == 2'b10;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg)         -> m_hdr_type[2:0] inside {[CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC : CDN_HPA_PCIE_TLP_MSG_ROUT_GATHER_TO_RC]};
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD)        -> m_hdr_fmt == 3'b011 && m_hdr_type[4:3] == 2'b10;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD)        -> m_hdr_type[2:0] inside {[CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC : CDN_HPA_PCIE_TLP_MSG_ROUT_GATHER_TO_RC]};
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl)         -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b01010;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplD)        -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b01010;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplLk)       -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b01011;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplDLk)      -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b01011;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32) -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b01100;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64) -> m_hdr_fmt == 3'b011 && m_hdr_type == 5'b01100;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)     -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b01101;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)     -> m_hdr_fmt == 3'b011 && m_hdr_type == 5'b01101;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)      -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b01110;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)      -> m_hdr_fmt == 3'b011 && m_hdr_type == 5'b01110;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32)     -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b11011;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64)     -> m_hdr_fmt == 3'b011 && m_hdr_type == 5'b11011;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl)    -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b01100;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCpl)    -> m_hdr_fmt == 3'b000 && m_hdr_type == 5'b01101;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd)      -> m_hdr_fmt == 3'b001 && m_hdr_type == 5'b00010;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD)   -> m_hdr_fmt == 3'b010 && m_hdr_type == 5'b01000;
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr)      -> m_hdr_fmt == 3'b011 && m_hdr_type == 5'b00001;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_uio_tlp_type
  // This Constraint will block UIO TLP generation
  // SVC is used instead of VC for UIO case. 
  //--------------------------------------------------------------------------
  constraint c_uio_tlp_type {
    ((parameters_cfg_pkg::NUM_UIO_VCS == 0) || (is_flit_mode == 0) || (m_pcie_dev_top_cfg.num_vc_enabled < 2)) ->
    !(m_tlp_type inside {
      CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl,
      CDN_HPA_PCIE_TLP_TYPE_UIORdCpl,
      CDN_HPA_PCIE_TLP_TYPE_UIOMRd,
      CDN_HPA_PCIE_TLP_TYPE_UIORdCplD,
      CDN_HPA_PCIE_TLP_TYPE_UIOMWr
    });

    // --- If function doesn't supports UIO Requester Enable then don't generate UIO TLP. ----
    (m_pcie_dev_cfg.m_uio_Mem_RdWr_req_en == 0 || m_pcie_dev_cfg.en_bus_master == 0) -> !(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr});
    
    // --- If the other end completer doesn't supports UIO then don't generate UIO TLP. -------
    ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && (m_pcie_link_cfg.usp_dev_config.m_uio_Mem_RdWr_compl_supp == 0)) -> !(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr});
    ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (m_pcie_link_cfg.dsp_dev_config.m_uio_Mem_RdWr_compl_supp == 0)) -> !(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr});
  }

  //--------------------------------------------------------------------------
  // Constraint: c_addr_format_type
  // Thsi Constraint will generate the tlp address format eg)32 bit or 64 bit
  //--------------------------------------------------------------------------
  constraint c_addr_format_type {
    ((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_32) &&
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)) ->
    (m_tlp_type inside {
      CDN_HPA_PCIE_TLP_TYPE_MWr_32,
      CDN_HPA_PCIE_TLP_TYPE_MRd_32,
      CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,
      CDN_HPA_PCIE_TLP_TYPE_DMWr_32,
      CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,
      CDN_HPA_PCIE_TLP_TYPE_Swap_32,
      CDN_HPA_PCIE_TLP_TYPE_Cas_32
    });

    ((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_64) &&
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)) ->
    m_tlp_type inside {
      CDN_HPA_PCIE_TLP_TYPE_MWr_64,
      CDN_HPA_PCIE_TLP_TYPE_MRd_64,
      CDN_HPA_PCIE_TLP_TYPE_MRdLk_64,
      CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
      CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
      CDN_HPA_PCIE_TLP_TYPE_Swap_64,
      CDN_HPA_PCIE_TLP_TYPE_Cas_64,
      CDN_HPA_PCIE_TLP_TYPE_UIOMRd,
      CDN_HPA_PCIE_TLP_TYPE_UIOMWr
    };
    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && !m_pcie_dev_cfg.bypass_dut_type_chk)
    {
      m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_MRdLk_64;
      m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_MRdLk_32;
    }

  }

  //--------------------------------------------------------------------------
  // Constraint to select tlp based on the access type transactions
  //--------------------------------------------------------------------------
  // Constraint: c_tlp_trans_type
  // This Constraint to select tlp based on the access type transaction
  //--------------------------------------------------------------------------
  constraint c_tlp_trans_type {
    //solve m_tlp_trans_type before m_tlp_type;

    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)    -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)    -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_64)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32)     -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64)     -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32) -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64) -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)     -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)     -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE);

    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IORd)        -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IOWr)        -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE);

    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd0)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd1)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr0)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr1)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE);

    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg)         -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD)        -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE);

    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplD)        -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl)         -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplLk)       -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplDLk)      -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl)    -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCpl)    -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE);
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD)   -> (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE);
  }
 constraint c_req_type {
    (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) ->
    (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32,
    CDN_HPA_PCIE_TLP_TYPE_MWr_64,
    CDN_HPA_PCIE_TLP_TYPE_Msg,
    CDN_HPA_PCIE_TLP_TYPE_MsgD,
    CDN_HPA_PCIE_TLP_TYPE_UIOMWr});


    ((m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) &&
    (m_tlp_np_req_type == CDN_HPA_PCIE_READ_REQ)) ->
    (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd0,
    CDN_HPA_PCIE_TLP_TYPE_CfgRd1,
    CDN_HPA_PCIE_TLP_TYPE_IORd,
    CDN_HPA_PCIE_TLP_TYPE_MRd_32,
    CDN_HPA_PCIE_TLP_TYPE_MRd_64,
    CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,
    CDN_HPA_PCIE_TLP_TYPE_MRdLk_64,
    CDN_HPA_PCIE_TLP_TYPE_UIOMRd});

    ((m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) &&
    (m_tlp_np_req_type == CDN_HPA_PCIE_NPR_WITH_DATA)) ->
    (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgWr0,
    CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
    CDN_HPA_PCIE_TLP_TYPE_IOWr,
    CDN_HPA_PCIE_TLP_TYPE_DMWr_32,
    CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
    CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,
    CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
    CDN_HPA_PCIE_TLP_TYPE_Swap_32,
    CDN_HPA_PCIE_TLP_TYPE_Swap_64,
    CDN_HPA_PCIE_TLP_TYPE_Cas_32,
    CDN_HPA_PCIE_TLP_TYPE_Cas_64});

    (m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) ->
    (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl,
    CDN_HPA_PCIE_TLP_TYPE_CplD,
    CDN_HPA_PCIE_TLP_TYPE_CplLk,
    CDN_HPA_PCIE_TLP_TYPE_CplDLk,
    CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl,
    CDN_HPA_PCIE_TLP_TYPE_UIORdCpl,
    CDN_HPA_PCIE_TLP_TYPE_UIORdCplD});
  }

  //--------------------------------------------------------------------------
  // Constraint: c_vdm_msg_type
  // This Constraint is used to generate vendom message type
  //--------------------------------------------------------------------------
  constraint c_vdm_msg_type {
    if(m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1})) {
      vendor_definition_vd_msg dist {0:=10, [1:50]:=15, [51:100]:=20,[101:127]:=10};
    }else {
      vendor_definition_vd_msg==0;
    }
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type1) -> m_tlp_vdm_msg_subtype inside {[CDN_HPA_PCIE_TLP_VDM_LN : CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1]};
    (cxl_mode == 0) -> m_tlp_vendor_id != 16'h1E98; //when vendor id is 'h1E98, cxl related payload fields are expected to be populated. so avoid this vendor id
    //in non-cxl mode
    solve m_tlp_msg_code before m_tlp_vdm_msg_subtype;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_mem_tlp_for_tdisp
  // This Constraint is used to generate mem type tlp for tdisp
  //--------------------------------------------------------------------------
  constraint c_mem_tlp_for_tdisp {

    soft msg_type_tc_0 == 0;
    //tdisp_is_ib == (m_pcie_dev_top_cfg.i_cfg.strap_is_rp ? (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) : (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP));
    //tdisp_func_num == (tdisp_is_ib ? (m_pcie_dev_top_cfg.i_cfg.strap_is_rp ? (m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num) : (m_pcie_link_cfg.usp_dev_config.m_req_id.function_num)) : (m_pcie_dev_top_cfg.i_cfg.strap_is_rp ? (m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num) : (m_pcie_link_cfg.usp_dev_config.m_req_id.function_num)));
    tdisp_func_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
    if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) {
          if(!(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete,CDN_HPA_PCIE_TLP_MSG_IDE_Sync, CDN_HPA_PCIE_TLP_MSG_IDE_Escort, CDN_HPA_PCIE_TLP_MSG_IDE_Fail})) { msg_type_tc_0 == 1; } 
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete}))                               { msg_type_tc_0 == 0; } 
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && (m_tlp_vdm_msg_subtype !=CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1))                 { msg_type_tc_0 == 1; }
          //if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && (m_tlp_vdm_msg_subtype ==CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1))                 { msg_type_tc_0 == 0; }
    }

    if (m_pcie_dev_top_cfg.scenario != null) {
      if(m_pcie_dev_top_cfg.scenario.is_tdisp_mode() && (m_pcie_dev_top_cfg.ide_cfg.m_num_sel_str_enabled != 0) && m_pcie_dev_top_cfg.tdisp_init_done && (m_pcie_dev_top_cfg.non_ide_traffic_test == 0) && (tdisp_func_num <= m_pcie_dev_top_cfg.tdisp_cfg.tdi_access_index)){ 
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) {
          m_ide_prefix_present == 1;
          m_sel_stream_possible == 1;
          use_user_defined_stream_id == 1;
          m_stream_id_int == m_pcie_dev_top_cfg.tdisp_cfg.stream_association[tdisp_func_num];
          tdisp_stream_id == m_pcie_dev_top_cfg.tdisp_cfg.stream_association[tdisp_func_num];
          m_tlp_tc == m_pcie_dev_top_cfg.ide_cfg.sel_stream_id_tc_map[tdisp_stream_id];
        }  
        else if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (!msg_type_tc_0)) {
          m_ide_prefix_present == 1;
          m_sel_stream_possible == 1;
          use_user_defined_stream_id == 1;
          m_stream_id_int == m_pcie_dev_top_cfg.tdisp_cfg.stream_association[tdisp_func_num];
          tdisp_stream_id == m_pcie_dev_top_cfg.tdisp_cfg.stream_association[tdisp_func_num];
          m_tlp_tc == m_pcie_dev_top_cfg.ide_cfg.sel_stream_id_tc_map[tdisp_stream_id];
        }  
        else  { use_user_defined_stream_id == 0; }
      }
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_msg_route
  // This Constraint is used to genarte message routing
  //--------------------------------------------------------------------------
  constraint c_msg_route {
    solve m_tlp_msg_code before m_tlp_msg_rout_type;
  }

  // Constraint for Byte enables
  //--------------------------------------------------------------------------
  // Constraint: c_last_dw_be
  // This Constraint generate BYte enables
  //--------------------------------------------------------------------------
  constraint c_last_dw_be {
    // For memory read requests with TH bit set byte enables carry ST field
    m_tlp_length == 1 -> m_tlp_last_dw_be == 0;
    if (((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32)    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)   || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)|| (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)     || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64))
    && (m_tlp_th == 1) && !is_flit_mode) {
      m_tlp_last_dw_be == m_tlp_st_tag[7:4];
    }
    else if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) {
      m_tlp_last_dw_be == 'b0;
    }
    else if (  ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
    && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) ) {
      m_tlp_last_dw_be == 'b1111;
    }
    else {
      m_tlp_length == 2 -> m_tlp_last_dw_be != 'b0;
      // If not QW aligned non contiguos byte enable is not allowed
      m_tlp_length == 2 && m_tlp_addr[2] != 'b0 -> m_tlp_last_dw_be inside {'b0001, 'b0011, 'b0111, 'b1111};
      m_tlp_length == 0 || m_tlp_length > 2 -> m_tlp_last_dw_be inside {'b0001, 'b0011, 'b0111, 'b1111};
    }
    solve m_tlp_length  before m_tlp_last_dw_be;
    solve m_tlp_th      before m_tlp_last_dw_be;
    solve m_tlp_st_tag  before m_tlp_last_dw_be;
    solve m_tlp_at_type before m_tlp_last_dw_be;
    solve m_tlp_type    before m_tlp_last_dw_be;
  }

  // FBE constraints
  //--------------------------------------------------------------------------
  // Constraint: c_first_dw_be
  // This Constraint will generate first double word byte enable
  //--------------------------------------------------------------------------
  constraint c_first_dw_be {
    if ( (  (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)     || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32)    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)   || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)|| (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)     || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64) )
    && (m_tlp_th == 1) && !is_flit_mode) {
      m_tlp_first_dw_be == m_tlp_st_tag [3:0];
    } else if(  (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64) ) {
      m_tlp_first_dw_be == 'b0;
    } else if (  ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
    && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) ) {
      m_tlp_first_dw_be == 'b1111;
    } else {
      // For FBE non contiguous is allowed for 1DW/2DW length
      (m_tlp_length == 2) -> m_tlp_first_dw_be != 'b0;
      // If not QW aligned non contiguos byte enable is not allowed in 2DW length
      (m_tlp_length == 2 && m_tlp_addr[2] != 'b0) -> m_tlp_first_dw_be inside { 'b1000, 'b1100, 'b1110, 'b1111 };
      (m_tlp_length == 0 || m_tlp_length > 2) -> m_tlp_first_dw_be inside { 'b1000, 'b1100, 'b1110, 'b1111 };

    }
    solve m_tlp_length  before m_tlp_first_dw_be;
    solve m_tlp_th      before m_tlp_first_dw_be;
    solve m_tlp_at_type before m_tlp_first_dw_be;
    solve m_tlp_type    before m_tlp_first_dw_be;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_flit_mode
  // Holds constraint specific to flit mode tlps
  //--------------------------------------------------------------------------
  constraint c_flit_mode {
    solve m_pasid_prefix_present,m_pasid_pri_value,m_tlp_msg_code,m_tlp_msg_rout_type,
    m_pasid_exec_value,m_pasid_value,
    m_destination_segment, m_destination_segment_valid, m_completer_segment,
    m_tlp_last_dw_be,m_tlp_first_dw_be,
    m_tlp_msg_code,m_tlp_cpl_lower_addr,m_tlp_cpl_status,
    m_tlp_trans_type,implcit_byte_enable_mem_tlps, m_tlp_at_type before m_ohc_hdr;

    solve m_tlp_ats_tr_nw_field,m_pasid_prefix_present before implcit_byte_enable_mem_tlps;

    solve m_tlp_st_tag,m_tlp_ph,m_hv,m_ama_value,m_ama_valid,
    m_ext_tph_prefix_present,m_tph_present,m_tlp_trans_type before m_ohc_hdr;

    solve m_ext_tph_prefix_present,m_tph_present before m_hv;

    solve m_ext_tph_prefix_possible before m_ama_valid,m_ama_value;

    solve m_requester_segment, m_pr_sent_counter, m_stream_id, m_sub_stream,
    m_requester_segment_valid,m_ide_k,m_ide_t,m_tlp_trans_type before m_ohc_hdr;

    if (m_pcie_dev_cfg.m_ats_mem_attr_enable && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translated) && (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)) { //AMA exists only for TA transactions
      m_ama_valid dist {1:=70, 0:=30};
      //HPA_2.0 supports AMA vaues in EXT TPH Prefix
      soft ((hpa_generation != hpa_generation_2)) -> m_ama_valid==0;
      soft (!m_ext_tph_prefix_possible && !is_flit_mode) -> m_ama_valid==0;
      if(m_ama_valid) {
        m_ama_value dist {[0:3]:=50, [4:7]:=50};
        m_ama_value != m_pcie_dev_cfg.m_ats_mem_attr_default; //when AMAE is Set, the Requestor is permitted to provide only non-default AMA values in Requests using the TPH TLP Prefix.
      } else {
        m_ama_value==0;
      }
    } else {
      m_ama_valid==0;
      m_ama_value==0;
    }
    if (is_flit_mode) {
      //m_ohc_hdr constraints
      if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) {
        // PCI-Express_Base_6.0.1 10.2.2 Translation Requests: In Flit Mode, OHC-A1 must be included, and the No Write (NW flag is contained in OHC-A1)
        if (m_pasid_prefix_present || !implcit_byte_enable_mem_tlps || m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) {
          m_ohc_hdr.ohc_a_present == 1;
        } else {
          m_ohc_hdr.ohc_a_present == 0;
        }
      }
      if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE) { //OHC-A is must
        m_ohc_hdr.ohc_a_present == 1;
      }
      if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) { //OHC-A is must
        m_ohc_hdr.ohc_a_present == 1;
      }
      if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) {
        if (pcie_6_1_support && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PR_Request) {
          if (m_pasid_prefix_present) {
            m_ohc_hdr.ohc_a_present == 1;
          }
          `ifndef TOP_LEVEL_SIMS
            else {
              m_ohc_hdr.ohc_a_present dist {0 := 70, 1 := 30};
            }
          `endif
        } else {
          if (m_destination_segment_valid || m_pasid_prefix_present) { //DSV will be 1 for manadatory Msgs (inv_req/inv_cpl/PRG) and optionally 1 for other ID rout msgs
            m_ohc_hdr.ohc_a_present==1;
          }
          `ifndef TOP_LEVEL_SIMS
            else { //Other messages can still have OHC-A4 but DSV & dest_seg should be zero
              m_ohc_hdr.ohc_a_present dist {1 := 30, 0 := 70};
            }
          `endif
        }
      }
      if (m_tlp_trans_type ==  CDN_HPA_PCIE_TRANS_CPL_TYPE) {
        soft m_ohc_hdr.ohc_a_present == 1; //Can be overriden by Cif router
      }

      if ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) &&
      (m_ext_tph_prefix_present || m_tph_present || m_ama_valid)) {
        m_ohc_hdr.ohc_b_present==1;
      } else {
        m_ohc_hdr.ohc_b_present == 0;
      }

      //Requester segment permitted in only few TLPs in OHC-C(Mem[Optionally]/Msg). Req segment is qualified by RSV
      //                  Also, when segment ID is not captured by device/fn, then OHC-C should not be included at all
      //                  when segmet is captured by device, must include OHC-C for Messages and maybe included in Mem requests
      //                  sub_stream should be 0111b for non-IDE TLPs inside OHC-C
      solve m_requester_segment_valid, is_ide_tlp, m_ide_prefix_present before m_ohc_hdr;
      if (m_requester_segment_valid || is_ide_tlp || m_ide_prefix_present) {
        m_ohc_hdr.ohc_c_present == 1;
      } else {
        m_ohc_hdr.ohc_c_present == 0;
      }

      //Byte 0, bits [7:4] are encoded:
      //-> 0000b - No Entry - The reminder of the DW is Reserved
      //-> 0001b - E-E Prefix DW - The reminder of the DW is defined below
      //-> 0010b-1111b - Reserved - Receivers must handle as No Entry
      //Byte 0, bits [3:0] take the value of E[3:0] in the corresponding E-E Prefix (see § Table 2-39).
      //Bytes 1, 2 and 3 take the value of bytes 1, 2 and 3 in the corresponding E-E Prefix.
      //OHC-E must be populated in order, starting with the first DW. Any unused DW in OHC-E must be populated indicating No
      //Entry. Transmitters must use the smallest possible OHC-E and avoid unnecessary No Entry DWs
      solve remote_supp_vnd_e2e_prefixes,m_max_no_of_ohc_e_prefixes before m_ohc_hdr;
      solve m_ohc_hdr before m_ohc_e,num_of_vnd_e2e_prefixes;
      solve num_of_vnd_e2e_prefixes before num_of_valid_vnd_e2e_prefixes;
      solve num_of_valid_vnd_e2e_prefixes before m_ohc_e;

      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) remote_supp_vnd_e2e_prefixes == m_pcie_link_cfg.usp_dev_config.m_e2e_tlp_prefix_support;
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) remote_supp_vnd_e2e_prefixes == m_pcie_link_cfg.dsp_dev_config.m_e2e_tlp_prefix_support;

      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) m_max_no_of_ohc_e_prefixes == ((m_pcie_link_cfg.usp_dev_config.m_max_e2e_support == 0) ? 'd4 : m_pcie_link_cfg.usp_dev_config.m_max_e2e_support);
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) m_max_no_of_ohc_e_prefixes == ((m_pcie_link_cfg.dsp_dev_config.m_max_e2e_support == 0) ? 'd4 : m_pcie_link_cfg.dsp_dev_config.m_max_e2e_support);

      (remote_supp_vnd_e2e_prefixes && (m_max_no_of_ohc_e_prefixes < 2)) -> m_ohc_hdr.ohc_ex_present != ohc_e2_present;
      (remote_supp_vnd_e2e_prefixes && (m_max_no_of_ohc_e_prefixes < 3)) -> m_ohc_hdr.ohc_ex_present != ohc_e4_present;
      !remote_supp_vnd_e2e_prefixes -> (m_ohc_hdr.ohc_ex_present == no_ohc_ex_present);

      //OHC_E is cut through, disabling for config packets JIRA: PCIE-15847
      (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) -> (m_ohc_hdr.ohc_ex_present == no_ohc_ex_present);

      m_ohc_e.size == ((m_ohc_hdr.ohc_ex_present == ohc_e1_present) ? 1 :
      (m_ohc_hdr.ohc_ex_present == ohc_e2_present) ? 2 :
      (m_ohc_hdr.ohc_ex_present == ohc_e4_present) ? 4 :
      /*------------------------------------------*/ 0 );

      num_of_vnd_e2e_prefixes == ((m_ohc_hdr.ohc_ex_present == ohc_e1_present) ? 1 :
      (m_ohc_hdr.ohc_ex_present == ohc_e2_present) ? 2 :
      (m_ohc_hdr.ohc_ex_present == ohc_e4_present) ? 4 :
      /*------------------------------------------*/ 0 );

      if(num_of_vnd_e2e_prefixes !=0) {
        num_of_valid_vnd_e2e_prefixes dist {[0:num_of_vnd_e2e_prefixes-1]:/10 ,num_of_vnd_e2e_prefixes:=90};
        num_of_valid_vnd_e2e_prefixes <= num_of_vnd_e2e_prefixes;
        //When max_e2e_prefix supported is 3, then we can't send OHC-E with 4DW of OHC-E (So, making anything less than num_of_vnd_e2e_prefixes)
        (num_of_vnd_e2e_prefixes ==4 && m_max_no_of_ohc_e_prefixes!=4) -> num_of_valid_vnd_e2e_prefixes !=num_of_vnd_e2e_prefixes;
      }
      else {
        num_of_valid_vnd_e2e_prefixes == 0;
      }

      foreach(m_ohc_e[i]) {
        if((i+1) <= num_of_valid_vnd_e2e_prefixes) {
          //if(i==0) {
          m_ohc_e[i][31:28] == 4'b1; //E-E Prefix
          m_ohc_e[i][27:24] dist {4'b1110:=50, 4'b1111:=50};//Prefix type: VendPrefixE0 or VendPrefixE1
          //}
        } else {
          m_ohc_e[i] == 32'd0; //No Entry. Any unused DW in OHC-E must be populated indicating No Entry
        }
      }

      //m_ts
      //soft m_ts inside {CDN_HPA_PCIE_NO_TRAILER,CDN_HPA_PCIE_1DW_ECRC_TRAILER};
      solve m_ide_prefix_present, m_tlp_td, m_ide_m, m_ide_p, m_ide_prefix_present before m_ts;
      (!m_ide_prefix_present &&  m_tlp_td == 0)        -> (m_ts == CDN_HPA_PCIE_NO_TRAILER);
      (!m_ide_prefix_present &&  m_tlp_td == 1)        -> (m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER);
      ( m_ide_prefix_present &&  m_ide_m  && !m_ide_p) -> (m_ts == CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER);
      ( m_ide_prefix_present &&  m_ide_m  &&  m_ide_p) -> (m_ts == CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER);
      ( m_ide_prefix_present && !m_ide_m)              -> (m_ts == CDN_HPA_PCIE_NO_TRAILER);


      //m_ts_payload
      //Whenever ECRC to be appended, TS should be CDN_HPA_PCIE_1DW_ECRC_TRAILER,
      m_ts_payload.size() == 4*((m_ts == CDN_HPA_PCIE_NO_TRAILER /*----------------------*/ ) ? 0 :
      (m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER /*----------------*/ ) ? 1 :
      (m_ts == CDN_HPA_PCIE_1DW_RSVD_TRAILER /*----------------*/ ) ? 1 :
      (m_ts == CDN_HPA_PCIE_2DW_RSVD_TRAILER /*----------------*/ ) ? 2 :
      (m_ts == CDN_HPA_PCIE_2DW_RSVD1_TRAILER /*---------------*/ ) ? 2 :
      //(m_ts == CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER /**/ ) ? 3 : //m_ts_payload added and ptrs updated by IDE_TX design
      //(m_ts == CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER ) ? 4 : //m_ts_payload added and ptrs updated by IDE_TX design
      (m_ts == CDN_HPA_PCIE_5DW_RSVD_TRAILER /*----------------*/ ) ? 5 :
      8'h0);

      //implcit_byte_enable_mem_tlps
      (m_pasid_prefix_present || m_tlp_ats_tr_nw_field) -> implcit_byte_enable_mem_tlps==0;
      (m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MEM_TYPE) -> implcit_byte_enable_mem_tlps==0;
      implcit_byte_enable_mem_tlps dist {0:=70, 1:=30};

      //Requester segment permitted in only few TLPs in OHC-C(Mem[Optionally]/Msg). Req segment is qualified by RSV
      //Also, when segment ID is not captured by device/fn, then OHC-C should not be included at all
      //when segmet is captured by device, must include OHC-C for Messages and maybe included in Mem requests
      //sub_stream should be 0111b for non-IDE TLPs inside OHC-C

      //Destination segment in OHC-A4 (Msg): If segment captured bit is clear, Route by ID Message Requests initiated by the Requester must not include a Destination Segment and DSV should be 0
      //                                     If segment captured bit is set, destination segment is [Must: ats_inv_req/inv_cpl/PRG, optional: other id routed msgs]

      //Destination segment in OHC-A3 (CFG) : All cfg tlps should have OHC-A3 with DSV=1 and should indicate corresponsding other device segment (Ie., EP device will capture this destination segment field as its requester segment)

      //Completer segment in OHC-A5(CPL) : Should be copied from captured destination segment value from IB cfg tlps(Ie., Device/fn's requester segment)
      //Destination segment in OHC-A5(CPL) : Should be copied from NP Req's Requester segment(OHC-C of IB NP Req). When IB NP Req doesn't have Req segment(Ie., no OHC-C) or
      //                                     segment id is still not captured by device, then DSV should clear and destination segment should=8'h00

      // Destination segment in OHC-A3/OHC-A4/OHC-A5 are qualified by DSV bit

      //m_destination_segment && m_requester_segment
      solve m_tlp_trans_type,m_tlp_msg_code,m_tlp_msg_rout_type before m_requester_segment_valid,m_destination_segment;
      solve m_destination_segment_valid before m_destination_segment;
      solve m_requester_segment_valid before m_requester_segment;

      if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
        if(!m_pcie_link_cfg.usp_dev_top_config.captured_segment_number && m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CFG_TYPE) {
          m_destination_segment_valid == 0;
          m_requester_segment_valid == 0;
        }
        else {
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) m_destination_segment_valid == 0;
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE)  m_destination_segment_valid == 0;
          //if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) m_destination_segment_valid == 1;

          //DSV should be 1 for CFG
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) {
            `ifndef DUT_DUT_MODE //VIPSR#46684335 VIP don't support segmentation. Segmentation verified only in DUT_DUT
              m_destination_segment_valid == m_pcie_dev_top_cfg.enable_segmentation;
            `else
              m_destination_segment_valid == 1;
            `endif
          }

          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MSG_TYPE}) {
            //In Flit Mode, when Route by ID is used and the Destination Segment is different from the Requester Segment, OHC-A4
            //must be present and include the Destination Segment in byte 0 and DSV must be Set. DSV is permitted to be Set when
            //the Destination Segment is the same as the Requester Segment. DSV must be Clear when Route by ID is not used. When
            //DSV is clear, the Destination Segment field must be set to 00h.
            //destination segment is [Must: ats_inv_req/inv_cpl/PRG, optional: other id routed msgs].
            //DSV=0 && dest_segment=0 for other msg with rout_type!=id_routing
            if(m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) m_destination_segment_valid == 0; //Other than route by ID msg can go with OHC-A4 but with DSV=0 & Dst_seg=0
            if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}) m_destination_segment_valid == 1; //DSV must for these msgs
          }

          if(m_ide_prefix_present) {
            /**/ if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) m_requester_segment_valid == 0;
            else if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) m_requester_segment_valid == 0;
            else /*-----------------------------------------------*/ m_requester_segment_valid == 1;
          }
          else {
            /**/ if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) m_requester_segment_valid == 1;
            else if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) m_requester_segment_valid == 0; //dist {0:=50, 1:=50};//anilks:: Enable this random after VIPSR::46827681
            else /*-----------------------------------------------*/ m_requester_segment_valid == 0;
          }
        }
      }

      if(m_destination_segment_valid == 0) {
        m_destination_segment == 0;
      }
      else {
        if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
          //soumitm :: TODO :: m_destination_segment should be RANDOM
          if(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) m_destination_segment == m_pcie_link_cfg.usp_dev_top_config.destination_segment;
          if(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) m_destination_segment == m_pcie_link_cfg.dsp_dev_top_config.destination_segment;
        }
      }

      //m_requester_segment
      if(m_requester_segment_valid == 0) {
        m_requester_segment == 0;
      }
      else {
        if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
          m_requester_segment == m_pcie_dev_top_cfg.requester_segment;
        }
      }

      //m_completer_segment
      if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE}) {
        if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
          //soumitm :: TODO :: this should be m_pcie_dev_top_cfg.destination_segment
          soft m_completer_segment == m_pcie_dev_top_cfg.requester_segment;
        }
      }
      else {
        m_completer_segment == 0;
      }

      //m_hv
      (m_ext_tph_prefix_present) -> m_hv==2'b11;
      (!m_ext_tph_prefix_present && m_tph_present) -> m_hv ==2'b01;
      soft !(m_hv inside {2'b10});
      (!m_ext_tph_prefix_present && !m_tph_present) -> m_hv==2'b0;

      //PCIe Spec OHC-B 2.2.1.2
      if (m_hv == 2'b00) {
        m_tlp_st_tag == 16'h0000;
        m_tlp_ph == 2'b00;
      }

    } else { //if(is_flit_mode)
      //Just make zero. No use case of these varaibles in NFM.
      implcit_byte_enable_mem_tlps == 0;
      m_ts_payload.size() == 0;
      m_ohc_hdr == 0;
      m_ohc_e.size ==0;
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_dmwr
  //TODO
  //--------------------------------------------------------------------------
  constraint c_dmwr {
    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) &&
    ((m_pcie_dev_cfg.m_dmwr_req_en == 0) ||
    (m_pcie_link_cfg.usp_dev_config.m_dmwr_completer_supp == 0))) {!(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64});}

    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) &&
    ((m_pcie_dev_cfg.m_dmwr_req_en == 0) ||
    (!(m_pcie_link_cfg.dsp_dev_config.m_dmwr_completer_supp | m_pcie_link_cfg.dsp_dev_config.m_dmwr_routing_supp)))) {!(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64});}

    if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64}) {
      // For ARM RP program, when the DMWr is transmitted over AXI-5 interface, AMBA AXI issue K mandates length of 64B. Address also has to be 64B aligned.
      // TODO: It is a valid condition only for packets that travel through AXI-Bridge, probably old condition still legal for HLS i/f packets
      // (In case where HLS_Bridge uses an HLS port for that TLP, not AXI.)
      `ifdef HAS_ARM
        `ifdef BRIDGE
          m_tlp_length       ==   16;
          m_tlp_addr[5:0]    ==    0;
          m_tlp_first_dw_be  == 4'hF;
          m_tlp_last_dw_be   == 4'hF;
        `endif
      `endif
      if(((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (m_pcie_link_cfg.dsp_dev_config.m_dmwr_lengths_supp == 0)) ||
      ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && (m_pcie_link_cfg.usp_dev_config.m_dmwr_lengths_supp == 0))){
        m_tlp_length inside {[1:16]};
      } else {
        m_tlp_length inside {[1:32]};
      }
    }
  }

  // Address Constraints:
  // For 32 Address
  //--------------------------------------------------------------------------
  // Constraint: c_addr_32bit
  // This constraint generate address for 32 bit Address
  //--------------------------------------------------------------------------
  constraint c_addr_32bit {
    ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IORd)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IOWr)) -> (m_tlp_addr[63:32] == 0);
  }

  //TODO: Move c_tag_scale_assign to tag_manager.
  // assign T9, T8 bits to Tag scale
  //--------------------------------------------------------------------------
  // Constraint: c_tag_scale_assign
  // This Constraint will assign the T9,T8 bits to tag scale
  //--------------------------------------------------------------------------
  constraint c_tag_scale_assign {
    if (!m_pcie_dev_cfg.bypass_dut_type_chk) {
      //14-bit tagscale constraint
      if(((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && ((m_pcie_dev_cfg.m_14_bit_tag_req_en== 1) && (m_pcie_link_cfg.usp_dev_config.m_14_bit_tag_compl_supp == 1))) ||
      ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && ((m_pcie_dev_cfg.m_14_bit_tag_req_en== 1) && (m_pcie_link_cfg.dsp_dev_config.m_14_bit_tag_compl_supp == 1)))) {
        m_tlp_tagscale == {m_tlp_t9, m_tlp_t8};
        (m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) -> {m_tlp_14_bit_tagscale, m_tlp_t9, m_tlp_t8} != 6'h0; //Tags[13:8] can't be 00
        (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) -> {m_tlp_14_bit_tagscale, m_tlp_t9, m_tlp_t8} == 6'h0; //For posted Tags[13:8] is reserved
        ((m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) && ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) || (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Msg,CDN_HPA_PCIE_TLP_TYPE_MsgD}))) -> {m_tlp_tag} == 8'h0; //For MSG, byte 6 is reserved
      } else {
        m_tlp_14_bit_tagscale == 4'h0;
        //10-bit tagscale contraint
        if(((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && ((m_pcie_dev_cfg.m_10_bit_tag_req_en== 0) || (m_pcie_link_cfg.usp_dev_config.m_10_bit_tag_completer_cap == 0))) ||
        ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && ((m_pcie_dev_cfg.m_10_bit_tag_req_en== 0) || (m_pcie_link_cfg.dsp_dev_config.m_10_bit_tag_completer_cap == 0)))){
          m_tlp_tagscale == 0;
          {m_tlp_t9, m_tlp_t8} == 2'b00;
          ((m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) && ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) || (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Msg,CDN_HPA_PCIE_TLP_TYPE_MsgD}))) -> {m_tlp_tag} == 8'h0; //For MSG, byte 6 is reserved
        } else {
          m_tlp_tagscale == {m_tlp_t9, m_tlp_t8};
          (m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) -> {m_tlp_t9, m_tlp_t8} != 2'b00; //Tags[9:8] can't be 00
          (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) -> {m_tlp_t9, m_tlp_t8} == 2'b00; //For posted Tags[9:8] should be zero
          ((m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) && ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) || (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Msg,CDN_HPA_PCIE_TLP_TYPE_MsgD}))) -> {m_tlp_tag} == 8'h0; //For MSG, byte 6 is reserved
        }
      }
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_atomic_tlps_disable
  // This Constraint is used to disable atomic tlps
  //--------------------------------------------------------------------------
  constraint c_atomic_tlps_disable {
    //If atomic req en is not enabled, don't generate atomic packets
    if(m_pcie_dev_cfg.m_atomic_op_req_en== 0) {!(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32:CDN_HPA_PCIE_TLP_TYPE_Cas_64]});}
    if(tlp_sqr_handle)
    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && m_pcie_link_cfg.dsp_dev_config.m_atomic_op_egress_block == 1) {!(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32:CDN_HPA_PCIE_TLP_TYPE_Cas_64]});}
    //If other end don't have atomic support, disable atomic packets genration
    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) &&
    (m_pcie_link_cfg.usp_dev_config.m_32_atomic_op_compl_supp == 0 ) &&
    (m_pcie_link_cfg.usp_dev_config.m_64_atomic_op_compl_supp == 0 )) {!(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32:CDN_HPA_PCIE_TLP_TYPE_Swap_64]});}
    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) &&
    (m_pcie_link_cfg.dsp_dev_config.m_32_atomic_op_compl_supp == 0 ) &&
    (m_pcie_link_cfg.dsp_dev_config.m_64_atomic_op_compl_supp == 0 )) {!(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32:CDN_HPA_PCIE_TLP_TYPE_Swap_64]});}
    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) &&
    (m_pcie_link_cfg.usp_dev_config.m_32_atomic_op_compl_supp == 0 ) &&
    (m_pcie_link_cfg.usp_dev_config.m_64_atomic_op_compl_supp == 0 ) &&
    (m_pcie_link_cfg.usp_dev_config.m_128_cas_compl_supp == 0 )) {!(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_Cas_32:CDN_HPA_PCIE_TLP_TYPE_Cas_64]});}
    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) &&
    (m_pcie_link_cfg.dsp_dev_config.m_32_atomic_op_compl_supp == 0 ) &&
    (m_pcie_link_cfg.dsp_dev_config.m_64_atomic_op_compl_supp == 0 ) &&
    (m_pcie_link_cfg.dsp_dev_config.m_128_cas_compl_supp == 0 )) {!(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_Cas_32:CDN_HPA_PCIE_TLP_TYPE_Cas_64]});}
  }

  //--------------------------------------------------------------------------
  // Constraint: c_vf_constraints
  // This Constraint generates virtual function based on IB and OB
  //--------------------------------------------------------------------------
  constraint c_vf_constraints {
    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && (m_pcie_link_cfg.usp_dev_config.m_is_vf)) {
      //List all IB Tlps which are Not to be received by a VF Function (Ie., when EP device with VFs is the target)
      m_tlp_trans_type != CDN_HPA_PCIE_TRANS_IO_TYPE;
    }
    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (m_pcie_link_cfg.usp_dev_config.m_is_vf)) {
      //List all OB Tlps which are Not to be Tx by a VF Function (Ie., when EP device with VFs is the initiator)
      !(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A : CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D]});
      !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PM_PME,CDN_HPA_PCIE_TLP_MSG_PME_TO_Ack,
      CDN_HPA_PCIE_TLP_MSG_LTR,CDN_HPA_PCIE_TLP_MSG_PTM_Req});

    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_no_OB_LTR_constraints
  // This Constraint holds generation of LTR Msg OB from DUT //PCIE-15741 comment date 2/Jan/2024
  //--------------------------------------------------------------------------
  constraint c_no_OB_LTR_constraints {
    if( ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && (m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP)) ||
    ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_EP))) {
      m_tlp_trans_type != CDN_HPA_PCIE_TLP_MSG_LTR;
    }
  }


  // Length constraints
  //--------------------------------------------------------------------------
  // Constraint: c_len_default
  // This constraint will generate the length constraints
  //--------------------------------------------------------------------------
  constraint c_len_default {
    //TODO add with error control knobs
    ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg && m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) ||
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl) ||
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplLk) ||
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl) ||
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCpl)) ->
    m_tlp_length == 0;
    ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE) ||
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE)) ->
    m_tlp_length == 1;

    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_SLOT_Power_Limit) -> m_tlp_length == 1;
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_AT_Invalidate)    -> m_tlp_length == 2;
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD)        -> m_tlp_length == 1;
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE &&
    (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
    m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_LN) -> {m_tlp_length == 2;}
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE &&
    (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
    m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_HIER_ID) -> {m_tlp_length == 4;}
    if(parameters_cfg_pkg::LTI_SUPPORT || parameters_cfg_pkg::MSG2WR_SUPPORT) {
      if(!m_pcie_dev_top_cfg.lti_en_msg_length_check_error) {
        (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0, CDN_HPA_PCIE_TLP_MSG_VD_Type1})) -> (m_tlp_length <= 512);
      }
    }
  }

  // Memory TLP length rules
  //--------------------------------------------------------------------------
  // Constraint: c_len_control
  // This constraint generates memory TLP length rules
  //--------------------------------------------------------------------------
  constraint c_len_control {
    m_tlp_length inside {[0:1023]};

    //`ifdef HPA2_IDE_BRANCH
    //   //VIPSR_46664771 :: avoiding 4K len TLPs
    //   if(is_flit_mode && (m_hdr_fmt[1] == 1)) m_tlp_length != 0;
    //`endif
  }

  // TODO Will provide the weights based on control knobs
  //--------------------------------------------------------------------------
  // Constraint: c_mem_tlp_len
  // This Constraint genrerate memeory TLP length based on transaction type
  // for 32 or 64 bit
  //--------------------------------------------------------------------------
  constraint c_mem_tlp_len {
    if(
      (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_64)
      ||(m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_MsgD)
      ||(m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_CplD)
      ||(m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_CplDLk)
      ||(m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_UIORdCplD)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr)
    ){
      if(m_pcie_dev_cfg.m_max_payload_size_dw == 1024){
        m_tlp_length inside {[0: m_pcie_dev_cfg.m_max_payload_size_dw]};
      }
      else {
        m_tlp_length inside {[1: m_pcie_dev_cfg.m_max_payload_size_dw]};
      }

      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) {
        if(m_pcie_link_cfg.usp_dev_config.m_max_payload_size_dw < 1024 ) { m_tlp_length != 0;}
        else m_tlp_length < m_pcie_link_cfg.usp_dev_config.m_max_payload_size_dw;
      }
      else {
        if(m_pcie_link_cfg.dsp_dev_config.m_max_payload_size_dw < 1024 ) { m_tlp_length != 0;}
        else m_tlp_length < m_pcie_link_cfg.dsp_dev_config.m_max_payload_size_dw;
      }
    }

    if(
      (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd)
    ){
      if(m_pcie_dev_top_cfg.get_min_rrs_in_dw() == 1024){
        m_tlp_length inside {[0: m_pcie_dev_top_cfg.get_min_rrs_in_dw()-1]};
      }
      else {
        m_tlp_length inside {[1: m_pcie_dev_top_cfg.get_min_rrs_in_dw()]};
      }
    }

    // Translation request is similar to memory read and has the below rules
    // TODO give more weightage to 2 as one STU has more use case
    if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
    && m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) {
      // Maximum setting for the length is RCB and LSB of length is zero
      // Translation is in 8 bytes
      m_tlp_length != 0;
      m_tlp_length[0] == 0;

      if(m_pcie_dev_top_cfg.m_rcb) // RCB is 128 bytes - length is 32 DW
      {
        m_tlp_length inside{[2:32]};
      }
      else { // RCB is 64 bytes
        m_tlp_length inside{[2:16]};
      }
    }

    // AtomicOP requests sizes:
    if(
      (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)
    ) {
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) {
        if(m_pcie_link_cfg.usp_dev_config.m_32_atomic_op_compl_supp == 0 ) { m_tlp_length != 1;}
        if(m_pcie_link_cfg.usp_dev_config.m_64_atomic_op_compl_supp == 0 ) { m_tlp_length != 2;}
      } else {
        if(m_pcie_link_cfg.dsp_dev_config.m_32_atomic_op_compl_supp == 0 ) { m_tlp_length != 1;}
        if(m_pcie_link_cfg.dsp_dev_config.m_64_atomic_op_compl_supp == 0 ) { m_tlp_length != 2;}
      }
      m_tlp_length inside {1,2};
    }
    if(
      (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)
    ) {
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) {
        if(m_pcie_link_cfg.usp_dev_config.m_32_atomic_op_compl_supp == 0 ) { m_tlp_length != 2;}
        if(m_pcie_link_cfg.usp_dev_config.m_64_atomic_op_compl_supp == 0 ) { m_tlp_length != 4;}
        if(m_pcie_link_cfg.usp_dev_config.m_128_cas_compl_supp == 0 )      { m_tlp_length != 8;}
      } else {
        if(m_pcie_link_cfg.dsp_dev_config.m_32_atomic_op_compl_supp == 0 ) { m_tlp_length != 2;}
        if(m_pcie_link_cfg.dsp_dev_config.m_64_atomic_op_compl_supp == 0 ) { m_tlp_length != 4;}
        if(m_pcie_link_cfg.dsp_dev_config.m_128_cas_compl_supp == 0 )      { m_tlp_length != 8;}
      }
      m_tlp_length inside {2,4,8};
    }
    // Do not cross 256B boundary for UIO
    // TODO: add check for "UIO Request 256B Boundary Disable" in "Device Control 3 Register"
`ifndef BRIDGE_MODULE_MODE
      if (
        ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && !m_pcie_dev_top_cfg.i_cfg.strap_is_rp) ||
        ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && m_pcie_dev_top_cfg.i_cfg.strap_is_rp)
      ) {
        if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMWr, CDN_HPA_PCIE_TLP_TYPE_UIOMRd}) {
          m_tlp_length inside {[1:64]};
        }
      }
`endif // BRIDGE_MODULE_MODE

  }

  //--------------------------------------------------------------------------
  // Constraint: c_lti_tlp_len
  // TLP contraints related to length for LTI testing
  //--------------------------------------------------------------------------
  `ifdef HAS_ARM
    constraint c_lti_tlp_len {
      if((m_pcie_dev_top_cfg.lti_en || parameters_cfg_pkg::MSG2WR_SUPPORT) && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD && (m_pcie_dev_top_cfg.lti_vdm_disable_wr_conversion == 0 || m_pcie_dev_top_cfg.lti_other_msg_disable_wr_conversion == 0) && !(m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD || ((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && (m_tlp_vdm_msg_subtype inside { CDN_HPA_PCIE_TLP_VDM_LN , CDN_HPA_PCIE_TLP_VDM_HIER_ID } )))) {
        if(m_pcie_dev_top_cfg.lti_en_msg_length_check_error) {
          if(m_pcie_dev_cfg.m_max_payload_size_dw == 1024) {
            m_tlp_length dist {[1:(m_pcie_dev_cfg.m_max_payload_size_dw - 16)] := 60, 0 := 30}; //TODO fix randomization, need to randomize > max_payload_size_dw, requires to be ran with ALL_TRAFFIC, SANITY_TRAFFIC constraints in size is 0,1,2, but in max_payload_size less than 1024 length 0 cannot be selected.
            //m_tlp_length inside {0};
           }
           else {
             m_tlp_length dist {[1:(m_pcie_dev_cfg.m_max_payload_size_dw - 16)] := 60, [m_pcie_dev_cfg.m_max_payload_size_dw:1023] := 10, 0 := 30}; 
             //m_tlp_length inside {/*0*/[1:m_pcie_dev_cfg.m_max_payload_size_dw]}; // if max payload size in dw <1024, length can't be 0   ,  //TODO fix randomization, need to randomize > max_payload_size_dw, requires to be ran with ALL_TRAFFIC, SANITY_TRAFFIC constraints in size is 0,1,2, but in max_payload_size less than 1024 length 0 cannot be selected.                                        
           }
        }
        else {
          m_tlp_length > 0;
          m_tlp_length <= m_pcie_dev_cfg.m_max_payload_size_dw - 16; // Full tlp length along with header,ohc,trailer,prefix
        }
      }
    }
  `endif

  //--------------------------------------------------------------------------
  // Constraint: c_payload_size
  // This Constraint is used to generate payload size
  //--------------------------------------------------------------------------
  constraint c_payload_size {
    (  (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IORd)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd0)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd1)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplLk)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCpl)) -> m_tlp_payload.size() == 0;

    ( (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_64)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IOWr)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr0)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgWr1)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplD)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplDLk)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr)) -> m_tlp_payload.size() == (((m_tlp_length== 0) ? 1024 : m_tlp_length) * 4);
    solve m_tlp_length before m_tlp_payload;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_default_payload_size
  // This Constraint is used to generate default payload size
  //--------------------------------------------------------------------------
  constraint c_default_payload_size {
    m_tlp_payload.size() <= 4096; // TODO add len errors
  }

  //--------------------------------------------------------------------------
  // Constraint: c_msg_slot_payload_constr
  // This Constraint generates message payload values for slot power message
  //--------------------------------------------------------------------------
  constraint c_msg_slot_payload_constr {
    if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_SLOT_Power_Limit)) {
      m_tlp_payload[3]       == 0;
      m_tlp_payload[2]       == 0;
      m_tlp_payload[1][2+:6] == 0;
      m_tlp_payload[1][1:0] != m_pcie_dev_top_cfg.m_slot_pwer_limit_scale; // separates internally generated msg from traffic seq generated msg
      //!(m_tlp_payload[0][7:0] inside {8'hF0,8'hF1,8'hF2}); // separates internally generated msg from traffic seq generated msg
    }
    solve m_tlp_type before m_tlp_payload;
    solve m_tlp_type before m_tlp_msg_code;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_msg_payload_constr
  // This Constraint generates message payload values based on ptmpropogation delay
  // ln message cacheline addr,vdm hier id
  //--------------------------------------------------------------------------
  constraint c_msg_payload_constr {
    if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD)) {
      m_tlp_payload[0]       == m_ptmPropagationDelay[31:24];
      m_tlp_payload[1]       == m_ptmPropagationDelay[23:16];
      m_tlp_payload[2]       == m_ptmPropagationDelay[15:8];
      m_tlp_payload[3]       == m_ptmPropagationDelay[7:0];
    }
    if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type1) && ( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_LN)) {
      m_tlp_payload[0]       == m_tlp_ln_msg_cacheline_addr[63:56];
      m_tlp_payload[1]       == m_tlp_ln_msg_cacheline_addr[55:48];
      m_tlp_payload[2]       == m_tlp_ln_msg_cacheline_addr[47:40];
      m_tlp_payload[3]       == m_tlp_ln_msg_cacheline_addr[39:32];
      m_tlp_payload[4]       == m_tlp_ln_msg_cacheline_addr[31:24];
      m_tlp_payload[5]       == m_tlp_ln_msg_cacheline_addr[23:16];
      m_tlp_payload[6]       == m_tlp_ln_msg_cacheline_addr[15:8];
      m_tlp_payload[7]       == {m_tlp_ln_msg_cacheline_addr[7:6],msg_ln_payload_rsvd,m_tlp_ln_msg_nr};
    }
    if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type1) && ( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_HIER_ID)) {
      {m_tlp_payload[0],m_tlp_payload[1],m_tlp_payload[2],m_tlp_payload[3]} == m_tlp_hier_vmsg_system_guid[127:96];
      {m_tlp_payload[4],m_tlp_payload[5],m_tlp_payload[6],m_tlp_payload[7]} == m_tlp_hier_vmsg_system_guid[95:64];
      {m_tlp_payload[8],m_tlp_payload[9],m_tlp_payload[10],m_tlp_payload[11]} == m_tlp_hier_vmsg_system_guid[63:32];
      {m_tlp_payload[12],m_tlp_payload[13],m_tlp_payload[14],m_tlp_payload[15]} == m_tlp_hier_vmsg_system_guid[31:0];
    }
    solve m_tlp_type before m_tlp_payload;
    solve m_tlp_type before m_tlp_msg_code;
  }

  //// TODO: Select a valid address?? Based on the PF BARs
  //// Address can not cross the 4k boundary
  // TODO : replace (2**bar.bar_aperture) with bar.end_address
  //--------------------------------------------------------------------------
  // Constraint: c_tlp_addr
  // This constraint generates tlp address and address can not cross the 4k boundary
  //--------------------------------------------------------------------------
  constraint c_erom_possible {
    if(!m_pcie_dev_cfg.bypass_bar_randomization) {
      if(m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.is_erom_bar_exists()) {
        m_erom_bar_sel == 1; //dist {1:=10, 0 :=0};
      }
      else {
        m_erom_bar_sel == 0;
      }
    }
  }


  constraint c_tlp_addr {
    //  solve m_msi_msix_pkt, m_tlp_type before m_tlp_addr;
    if(
      ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32))
      && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && !m_pcie_dev_cfg.bypass_bar_randomization
    ) // RP
    {
      //TODO::
      //if(m_ide_prefix_present && (m_pcie_dev_top_cfg.ide_cfg.find_stream_type(m_stream_id) == SELECTIVE_STREAM))
      //  m_pcie_link_cfg.usp_dev_top_config.ide_cfg.m_ide_selective_stream_config[m_stream_id].is_addr_inside_addr_assoc(m_tlp_addr,1) == 1;
      //m_pcie_link_cfg.usp_dev_top_config.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_addr_association_block.or(addr_assoc_block) with (addr_assoc_block.is_addr_inside_block(m_tlp_addr,1) == 1);

      if(m_erom_bar_sel &&  m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) {
        m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (m_tlp_addr[31:0] inside {
          [bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]
        }
        && bar.bar_type inside {MEM_EROM_BAR_32});
      }


      else if(!cxl_io_rcrb_tlp && !cxl_io_membar_tlp) {
        (m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (m_tlp_addr[31:0] inside {
          `ifdef IPS_TB
            [bar.start_addr : ((bar.end_addr) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]
          `else
            [bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]
          `endif
        } && bar.bar_type inside {MEM_BAR_32,MEM_BAR_32_PREFETCH}));
      }
      else if(cxl_io_rcrb_tlp && m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar[63:32] == 0 && m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar[31:0] !=0) {
        m_tlp_addr[31:0] inside {[m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar +2**12 : ((m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar + 2**13) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]};
      }
      else if(cxl_io_membar_tlp && m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar[63:32] == 0 && m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar[31:0] !=0) {
        m_tlp_addr[31:0] inside {[m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar: ((m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar + 2**12) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]};
      }
      else { // For extra guarding
        (m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (m_tlp_addr[31:0] inside {
          `ifdef IPS_TB
            [bar.start_addr : ((bar.end_addr) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]
          `else
            [bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]
          `endif
        } && bar.bar_type inside {MEM_BAR_32,MEM_BAR_32_PREFETCH}));
      }

      //(cxl_io_tlp && cxl_io_rcrb_tlp && m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar[63:32] == 0 && m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar[31:0] !=0 )
      // ?
      //   m_tlp_addr[31:0] inside {[m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar : ((m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar + 2**12) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
      // :
      // ((cxl_io_tlp && cxl_io_membar_tlp && m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar[63:32] == 0 && m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar[31:0] !=0 )
      //  ?
      //   m_tlp_addr[31:0] inside {[m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar : ((m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar + 2**12/*TODO*/) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
      //  :
      //   (m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (m_tlp_addr[31:0] inside {
      //   [bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
      //   && bar.bar_type inside {MEM_BAR_32,MEM_BAR_32_PREFETCH})));
    }
    //    if(m_msi_msix_pkt && ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32))
    //       && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !m_pcie_dev_cfg.bypass_bar_randomization
    //      ) { // EP
    //       m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (
    //       m_tlp_addr[31:0] inside {[bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
    //       && bar.bar_type == MSI_OR_MSIX_BAR_32);
    //    }
    //    if(m_msi_msix_pkt && ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_64))
    //       && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !m_pcie_dev_cfg.bypass_bar_randomization
    //       ) { // EP
    //       m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (
    //       m_tlp_addr[63:0] inside {[bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
    //       && bar.bar_type == MSI_OR_MSIX_BAR_64);
    //    }

    if(
      !m_msi_msix_pkt && (((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32))
      && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !m_pcie_dev_cfg.bypass_bar_randomization // EP
    )) {
      //TODO::
      //if(m_ide_prefix_present && (m_pcie_dev_top_cfg.ide_cfg.find_stream_type(m_stream_id) == SELECTIVE_STREAM))
      //  m_pcie_link_cfg.dsp_dev_top_config.ide_cfg.m_ide_selective_stream_config[m_stream_id].is_addr_inside_addr_assoc(m_tlp_addr,1) == 1;
      //m_pcie_link_cfg.dsp_dev_top_config.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_addr_association_block.or(addr_assoc_block) with (addr_assoc_block.is_addr_inside_block(m_tlp_addr,1) == 1);
      m_pcie_link_cfg.dsp_dev_config.m_fun_bar_info.bars.or(bar) with(
        `ifdef IPS_TB
          m_tlp_addr[31:0] inside {[bar.start_addr : ((bar.end_addr) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
        `else
          m_tlp_addr[31:0] inside {[bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
        `endif
        && bar.bar_type inside {MEM_BAR_32,MEM_BAR_32_PREFETCH}
      );
    }

    if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_64) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd))
    && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && !m_pcie_dev_cfg.bypass_bar_randomization) {
      //TODO::
      //if(m_ide_prefix_present && (m_pcie_dev_top_cfg.ide_cfg.find_stream_type(m_stream_id) == SELECTIVE_STREAM))
      //  m_pcie_link_cfg.usp_dev_top_config.ide_cfg.m_ide_selective_stream_config[m_stream_id].is_addr_inside_addr_assoc(m_tlp_addr,0) == 1;
      //m_pcie_link_cfg.usp_dev_top_config.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_addr_association_block.or(addr_assoc_block) with (addr_assoc_block.is_addr_inside_block(m_tlp_addr,0) == 1);

      if(!cxl_io_rcrb_tlp && !cxl_io_membar_tlp) {
        (m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (
          `ifdef IPS_TB
            m_tlp_addr[63:0] inside {[bar.start_addr : ((bar.end_addr) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
          `else
            m_tlp_addr[63:0] inside {[bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
          `endif
          && bar.bar_type inside {MEM_BAR_64_NON_PREFETCH,MEM_BAR_64_PREFETCH}
        ));
      }
      else if(cxl_io_rcrb_tlp && m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar[63:32] != 0) {
        m_tlp_addr[63:0] inside {[m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar + 2**12 : ((m_pcie_link_cfg.usp_dev_config.m_cxl_io_rcrb_bar + 2**13) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]};
      }
      else if(cxl_io_membar_tlp && m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar[63:32] != 0) {
        m_tlp_addr[63:0] inside {[m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar:
        ((m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar + 2**m_pcie_link_cfg.usp_dev_config.m_cxl_io_membar_aperture) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]};
      }
      else { // For extra guarding
        (m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (
          `ifdef IPS_TB
            m_tlp_addr[63:0] inside {[bar.start_addr : ((bar.end_addr) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
          `else
            m_tlp_addr[63:0] inside {[bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
          `endif
          && bar.bar_type inside {MEM_BAR_64_NON_PREFETCH,MEM_BAR_64_PREFETCH}
        ));
      }
    }

    if(!m_msi_msix_pkt && (((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_64) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_DMWr_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)
    ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd))
    && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !m_pcie_dev_cfg.bypass_bar_randomization)) {
      //TODO::
      //if(m_ide_prefix_present && (m_pcie_dev_top_cfg.ide_cfg.find_stream_type(m_stream_id) == SELECTIVE_STREAM))
      //  m_pcie_link_cfg.dsp_dev_top_config.ide_cfg.m_ide_selective_stream_config[m_stream_id].is_addr_inside_addr_assoc(m_tlp_addr,0) == 1;
      //m_pcie_link_cfg.dsp_dev_top_config.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_addr_association_block.or(addr_assoc_block) with (addr_assoc_block.is_addr_inside_block(m_tlp_addr,0) == 1);
      m_pcie_link_cfg.dsp_dev_config.m_fun_bar_info.bars.or(bar) with(
        `ifdef IPS_TB
          m_tlp_addr[63:0] inside {[bar.start_addr : ((bar.end_addr) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
        `else
          m_tlp_addr[63:0] inside {[bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
        `endif
        && bar.bar_type inside {MEM_BAR_64_NON_PREFETCH,MEM_BAR_64_PREFETCH}
      );
    }

    // If function is selected ensure function has atlease one IO BAR
    // Other wise Need to initiate TLP from the random IO BAR...
    if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IOWr) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IORd)) /*&& m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP*/  && !m_pcie_dev_cfg.bypass_bar_randomization){
      m_pcie_link_cfg.usp_dev_config.m_fun_bar_info.bars.or(bar) with (
        `ifdef IPS_TB
          m_tlp_addr[31:0] inside {[bar.start_addr : ((bar.end_addr) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
        `else
          m_tlp_addr[31:0] inside {[bar.start_addr : ((bar.start_addr + (2**(bar.bar_aperture+7))) - (((m_tlp_length== 0) ? 1024 : m_tlp_length)*4)+1)]}
        `endif
        && bar.bar_type == IO_BAR
      );
    }

    // For AtomicOp Requests, the Address must be naturally aligned with the operand size
    if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)) {
      m_tlp_length == 2 -> m_tlp_addr[2] == 0;
    }
    else if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
    || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) {
      m_tlp_length == 4 -> m_tlp_addr[2] == 0;
      m_tlp_length == 8 -> m_tlp_addr[3:2] == 0;
    }

    m_tlp_addr[1:0] == 0;
    // Address cannot cross 4K boundary
    m_tlp_addr[11:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h400;

    // UIO Request cannot cross 256B boundary
    // TODO: add check for "UIO Request 256B Boundary Disable" in "Device Control 3 Register"
    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) {
      if (!m_pcie_link_cfg.usp_dev_config.m_uio_req_256B_bound_dis && ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd))) {
        m_tlp_addr[7:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h40;
      }
    } else {
      if (!m_pcie_link_cfg.dsp_dev_config.m_uio_req_256B_bound_dis && ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMWr) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd))) {
        m_tlp_addr[7:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h40;
      }
    }

    //TR should have [11:0] == 0 when page_align_req==1
    //TODO Enable the below after VIPSR #46911881
    //if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
    //          && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pcie_dev_cfg.m_ats_page_align_req) { soft m_tlp_addr[11:2] == 0;}
    if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
    && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) { soft m_tlp_addr[11:2] == 0;}

    if(!m_pcie_dev_cfg.bypass_bar_randomization) {
      //JIRA PCIE-10834: when cpld credits = MPS, MRd addresses with length=MPS would be 4dw aligned
      if((m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) && (m_pcie_dev_cfg.m_max_payload_size_dw == (m_tlp_length == 0) ? 1024 : m_tlp_length) &&
      (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP))
      {
        //RP OB
        if(((m_pcie_link_cfg.dsp_dev_top_config.m_fccpld_x_scale_vc[(m_pcie_link_cfg.dsp_dev_top_config.tc_vc_map[m_tlp_tc])])*4) == m_pcie_dev_cfg.m_max_payload_size_dw)
        m_tlp_addr[3:0] == 0;
      }
      if((m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) && (m_pcie_dev_cfg.m_max_payload_size_dw == (m_tlp_length == 0) ? 1024 : m_tlp_length) &&
      (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_EP))
      {
        /*EP OB*/
        if(((m_pcie_link_cfg.usp_dev_top_config.m_fccpld_x_scale_vc[(m_pcie_link_cfg.usp_dev_top_config.tc_vc_map[m_tlp_tc])])*4) == m_pcie_dev_cfg.m_max_payload_size_dw)
        m_tlp_addr[3:0] == 0;
      }
    }

    solve m_tlp_length before m_tlp_addr;
    solve cxl_io_tlp before m_tlp_addr;
    solve m_tlp_tc before m_tlp_addr;
  }

  // TODO Add for Completion rules - RCB

  //Message codes with feature_en control
  //--------------------------------------------------------------------------
  // Constraint: c_msg_code_with_feature_en
  // This Constraint generate Message code with feature_en control
  //--------------------------------------------------------------------------
  constraint c_msg_code_with_feature_en {
    if(m_pcie_link_cfg.usp_dev_config.m_cap_ats_en == 0){ !(m_tlp_msg_code inside { CDN_HPA_PCIE_TLP_MSG_AT_Invalidate});}
    if(m_pcie_link_cfg.usp_dev_config.m_cap_ats_supp == 0){ !(m_tlp_msg_code inside { CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete});}
    if(m_pcie_dev_cfg.m_cap_ats_page_req_en ==0) {!(m_tlp_msg_code inside { CDN_HPA_PCIE_TLP_MSG_PR_Request});}
      //CHeck RP config before ѕending page reuest
   `ifdef TOP_LEVEL_SIMS
    if(m_pcie_link_cfg.dsp_dev_config.m_cap_ats_page_req_en ==0) {!(m_tlp_msg_code inside { CDN_HPA_PCIE_TLP_MSG_PR_Request});}
   `endif
    `ifndef BRIDGE_MODULE_MODE
      if((m_pcie_dev_cfg.m_ptm_requester_cap && m_pcie_dev_cfg.m_ptm_en) ==0) {!(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_PTM_Req:CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD]});}
      if(m_pcie_dev_cfg.m_ltr_en ==0) {!(m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_LTR);}
    `endif

    //   //Only IDE TLPs should reach DTI
    //   if (m_pcie_dev_top_cfg.scenario != null) {
    //    if (m_pcie_dev_top_cfg.scenario.m_generate_invalidate_msg_traffic) {
    //      if(parameters_cfg_pkg::KMAX_DTI_SUPPORT && parameters_cfg_pkg::KMAX_IDE_SUPPORT) {
    //        (m_tlp_msg_code inside { CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete, CDN_HPA_PCIE_TLP_MSG_PR_Request}) -> (m_ide_prefix_present == 1);
    //        (m_tlp_at_type inside {CDN_HPA_PCIE_AT_Translation_Request})                                            -> (m_ide_prefix_present == 1);
    //        }
    //      }
    //    }
  }


  // Message TLP rules
  //--------------------------------------------------------------------------
  // Constraint: c_msg_type
  // This constarint generate message TLP rules
  //--------------------------------------------------------------------------
  constraint c_msg_type {
    solve m_tlp_type before m_tlp_msg_code;
    (m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_MsgD) ->
    !(m_tlp_msg_code inside{
      CDN_HPA_PCIE_TLP_MSG_LOCK_Unlock,
      CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete,
      CDN_HPA_PCIE_TLP_MSG_PR_Request,
      CDN_HPA_PCIE_TLP_MSG_PR_Group_Response,
      CDN_HPA_PCIE_TLP_MSG_LTR,
      CDN_HPA_PCIE_TLP_MSG_OBFF,
      CDN_HPA_PCIE_TLP_MSG_PM_Active_State_Nak,
      CDN_HPA_PCIE_TLP_MSG_PM_PME,
      CDN_HPA_PCIE_TLP_MSG_PME_Turn_Off,
      CDN_HPA_PCIE_TLP_MSG_PME_TO_Ack,
      CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A,
      CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B,
      CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C,
      CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D,
      CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A,
      CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B,
      CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C,
      CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D,
      CDN_HPA_PCIE_TLP_MSG_ERR_COR,
      CDN_HPA_PCIE_TLP_MSG_ERR_NONFATAL,
      CDN_HPA_PCIE_TLP_MSG_ERR_FATAL,
      CDN_HPA_PCIE_TLP_MSG_HP_Power_On,
      CDN_HPA_PCIE_TLP_MSG_HP_Power_Off,
      CDN_HPA_PCIE_TLP_MSG_HP_Power_Blink,
      CDN_HPA_PCIE_TLP_MSG_HP_Attention_Pressed,
      CDN_HPA_PCIE_TLP_MSG_HP_Attention_On,
      CDN_HPA_PCIE_TLP_MSG_HP_Attention_Off,
      CDN_HPA_PCIE_TLP_MSG_HP_Attention_Blink,
      CDN_HPA_PCIE_TLP_MSG_PTM_Req,
      CDN_HPA_PCIE_TLP_MSG_IDE_Sync,
      CDN_HPA_PCIE_TLP_MSG_IDE_Escort,
      CDN_HPA_PCIE_TLP_MSG_IDE_Fail
    });

    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg) ->
    !( m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_SLOT_Power_Limit} );
  }

  constraint c_msg_type_no_invalidate {
    (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg) -> !( m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate} );
  }

// When TDISP is enabled Page request/response messages are not supported for the functions whose TDIs are not associated with TC_0 mapped streams
  constraint c_msg_type_no_page_request {
    if ((m_pcie_dev_top_cfg.scenario != null) && (m_pcie_dev_top_cfg.scenario.is_tdisp_mode())&& (m_pcie_dev_top_cfg.tdisp_init_done) && (m_pcie_dev_top_cfg.ide_cfg.m_num_sel_str_enabled != 0) && (m_pcie_dev_cfg.m_req_id.function_num <= m_pcie_dev_top_cfg.tdisp_cfg.tdi_access_index)){
      if ((m_pcie_dev_top_cfg.tdisp_cfg.tdi_association[m_pcie_dev_cfg.m_req_id.function_num]) && (m_pcie_dev_top_cfg.ide_cfg.sel_stream_id_tc_map[m_pcie_dev_top_cfg.tdisp_cfg.stream_association[m_pcie_dev_cfg.m_req_id.function_num]] != 0)){
        (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete,CDN_HPA_PCIE_TLP_MSG_IDE_Sync, CDN_HPA_PCIE_TLP_MSG_IDE_Escort, CDN_HPA_PCIE_TLP_MSG_IDE_Fail});
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) !(m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_DRS,CDN_HPA_PCIE_TLP_VDM_FRS,CDN_HPA_PCIE_TLP_VDM_HIER_ID});
      }  
    }
  }

  constraint c_ide_msg_type {
    //IDE Sync and Fail Messages can not be generated manually at top-level
    //TODO: Modify this for IDE Module TB verification
    `ifndef HLS_MODULE_MODE
      `ifndef BRIDGE_MODULE_MODE
        !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_IDE_Sync, CDN_HPA_PCIE_TLP_MSG_IDE_Escort, CDN_HPA_PCIE_TLP_MSG_IDE_Fail});
      `endif
    `endif

    `ifndef BRIDGE_MODULE_MODE
      (!m_pcie_dev_top_cfg.i_cfg.k_ide_supported) -> !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_IDE_Sync, CDN_HPA_PCIE_TLP_MSG_IDE_Escort, CDN_HPA_PCIE_TLP_MSG_IDE_Fail});
    `endif
  }

  // The below constraints are separated to make it easy for EI
  //--------------------------------------------------------------------------
  // Constraint: c_default_dsp_msg_rules
  // This constraints are separated to make it easy for EI
  //--------------------------------------------------------------------------
  constraint c_default_dsp_msg_rules {
    if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) {
        !(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A : CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D]});
        !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PM_PME,[CDN_HPA_PCIE_TLP_MSG_PME_TO_Ack:CDN_HPA_PCIE_TLP_MSG_RSVD_28_3131],
        [CDN_HPA_PCIE_TLP_MSG_RSVD_40_4740:CDN_HPA_PCIE_TLP_MSG_ERR_FATAL],CDN_HPA_PCIE_TLP_MSG_LTR,
        CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete,CDN_HPA_PCIE_TLP_MSG_PR_Request});
        (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) -> (m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_DRS);
        (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) -> (m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_FRS);
        (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1} && is_flit_mode) -> (m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_LN); //FM don't support LN Message
        (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_PTM_Req);
        //After PCIE1.1 this ignore messages are degraded. Monitor drops the packet
        !(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_HP_Attention_Off:CDN_HPA_PCIE_TLP_MSG_HP_Attention_Pressed]});
      }
    }
  }

  // TODO Control knob to disable the special packets
  //--------------------------------------------------------------------------
  // Constraint: c_default_usp_msg_rules
  // This Constraint is used to generate default upstream message rules
  //--------------------------------------------------------------------------
  constraint c_default_usp_msg_rules {
    if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) {
        m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_PM_Active_State_Nak;
        m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_SLOT_Power_Limit;
        (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) -> (m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_LN);
        (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) -> (m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_HIER_ID);
        m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD;
        m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_OBFF;
        !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_LOCK_Unlock,
        CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,
        CDN_HPA_PCIE_TLP_MSG_PR_Group_Response});
        //After PCIE1.1 this ignore messages are degraded. Monitor drops the packet
        !(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_HP_Attention_Off:CDN_HPA_PCIE_TLP_MSG_HP_Attention_Pressed]});
      }
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_port_specific_msg_routing
  // This Constraint generates port specic message routing
  //--------------------------------------------------------------------------
  constraint c_port_specific_msg_routing {
    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !m_pcie_dev_cfg.bypass_dut_type_chk) {
      m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC;
    }

    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && !m_pcie_dev_cfg.bypass_dut_type_chk) {
      m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC;
    }
    soft !(m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_RSVD6,CDN_HPA_PCIE_TLP_MSG_ROUT_RSVD7});
  }

  //--------------------------------------------------------------------------
  // Constraint: c_port_specific_msg_routing
  // This Constraint generates port specic message routing
  //--------------------------------------------------------------------------
  constraint c_tlp_routing {
    solve m_tlp_trans_type before m_tlp_rout_type;
    if (m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE}) {
      m_tlp_rout_type == CDN_HPA_PCIE_TLP_ROUT_BY_ADDR;
    }
    else if (m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE}) {
      m_tlp_rout_type == CDN_HPA_PCIE_TLP_ROUT_BY_ID;
    }
    else {
      m_tlp_rout_type == CDN_HPA_PCIE_TLP_ROUT_BY_OTHER;
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_msg_rout_to_rc
  // This Constraint generates rout to rc msg for selective streams
  //--------------------------------------------------------------------------
  constraint c_msg_rout_to_rc {
    if ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_pcie_dev_top_cfg.ide_init_done) && (m_pcie_dev_top_cfg.ide_cfg.m_num_sel_str_enabled != 0) && (m_pcie_dev_top_cfg.scenario != null) && (m_pcie_dev_top_cfg.scenario.is_ide_mode())) {
      default_stream_id == m_pcie_dev_top_cfg.ide_cfg.find_default_stream_id_and_mapped_tc(m_tlp_tc);
      if (default_stream_id == -1) {
        (m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC);
      }
      else {
        if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC){
          m_sel_stream_possible == 1;
          use_user_defined_stream_id == 1;
          m_stream_id_int == default_stream_id;          
        }
      }
    }
  }

  // CFG and IO writes initiated only by DSP/RP
  //--------------------------------------------------------------------------
  // Constraint: c_default_dsp_tlps
  // This Constraint will set that CFG and IO writes initiated only by DSP/RP
  //--------------------------------------------------------------------------
  constraint c_default_dsp_tlps {
    if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
      if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)){
        (m_tlp_trans_type != CDN_HPA_PCIE_TRANS_IO_TYPE);
        (m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CFG_TYPE);
      }
    }
  }

  //  //--------------------------------------------------------------------------
  //  // Constraint: c_default_dsp_tlps
  //  // This Constraint will set that CFG and IO writes initiated only by DSP/RP
  //  //--------------------------------------------------------------------------
  //  constraint c_tlp_trans_enable {
  //    //if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
  //    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)){
  //      (m_tlp_trans_type != CDN_HPA_PCIE_TRANS_IO_TYPE);
  //      (m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CFG_TYPE);
  //    }
  //    if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
  //      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP)
  //      {
  //        if(!(m_pcie_link_cfg.usp_dev_config.en_io_space)) m_tlp_trans_type != CDN_HPA_PCIE_TRANS_IO_TYPE;
  //        if(!(m_pcie_link_cfg.usp_dev_config.en_memory_space)) m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MEM_TYPE;
  //        if(!(m_pcie_link_cfg.usp_dev_config.en_bus_master)) {!(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_MEM_TYPE});}
  //      }
  //      else
  //      {
  //        if(!(m_pcie_link_cfg.dsp_dev_config.en_io_space)) m_tlp_trans_type != CDN_HPA_PCIE_TRANS_IO_TYPE;
  //        if(!(m_pcie_link_cfg.dsp_dev_config.en_memory_space)) m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MEM_TYPE;
  //        if(!(m_pcie_link_cfg.dsp_dev_config.en_bus_master)) {!(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_MEM_TYPE});}
  //      }
  //    }
  //  }

  //--------------------------------------------------------------------------
  // Constraint: c_default_func0_rules
  // This Constraint generates defaukt func0 rules
  //--------------------------------------------------------------------------
  constraint c_default_func0_rules {
    // Doing in cif router
    //  if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
    //    if((m_pcie_dev_top_cfg.i_cfg.strap_is_rp)){
    (m_tlp_requester_id.function_num != 0) ->  !(m_tlp_msg_code inside
    {[CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A : CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D]});
    //  }
    // }
    (m_tlp_requester_id.function_num != 0) -> m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_LOCK_Unlock;
  }

  constraint c_m_intr_pins {
    solve m_intr_pins_flag[0], m_intr_pins_flag[1], m_intr_pins_flag[2], m_intr_pins_flag[3] before m_intr_pins[0], m_intr_pins[1], m_intr_pins[2], m_intr_pins[3];
    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) {
      if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
        foreach(m_pcie_dev_top_cfg.pf_config[i]) {
          if(!m_pcie_dev_top_cfg.pf_config[i].dis_intr) {
            if(m_pcie_dev_top_cfg.pf_config[i].m_intr_pins == 1) {
              m_intr_pins[0] == 1;
              m_intr_pins_flag[0] == 1;
            }
            else if(m_pcie_dev_top_cfg.pf_config[i].m_intr_pins == 2) {
              m_intr_pins[1] == 2;
              m_intr_pins_flag[1] == 1;
            }
            else if(m_pcie_dev_top_cfg.pf_config[i].m_intr_pins == 3) {
              m_intr_pins[2] == 3;
              m_intr_pins_flag[2] == 1;
            }
            else if(m_pcie_dev_top_cfg.pf_config[i].m_intr_pins == 4) {
              m_intr_pins[3] == 4;
              m_intr_pins_flag[3] == 1;
            }
          }
        }
        if(m_intr_pins_flag[0] == 0) {
          m_intr_pins[0] == 0;
        }
        if(m_intr_pins_flag[1] == 0) {
          m_intr_pins[1] == 0;
        }
        if(m_intr_pins_flag[2] == 0) {
          m_intr_pins[2] == 0;
        }
        if(m_intr_pins_flag[3] == 0) {
          m_intr_pins[3] == 0;
        }
      }
    }
  }

  constraint c_m_intr_pins_flag {
    soft m_intr_pins_flag[0] == 0 ;
    soft m_intr_pins_flag[1] == 0 ;
    soft m_intr_pins_flag[2] == 0 ;
    soft m_intr_pins_flag[3] == 0 ;
  }

  constraint c_intr_pin_for_enabled_pfs {
    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) {
      if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
        foreach(m_pcie_dev_top_cfg.pf_config[i]) {
          if(!m_pcie_dev_top_cfg.pf_config[i].dis_intr && m_pcie_dev_top_cfg.m_is_pf_disabled_by_lm[i]==0) {
            if(m_pcie_dev_top_cfg.pf_config[i].m_intr_pins == 1) {
              intr_pin_en[0] ==1;
            }
            else if(m_pcie_dev_top_cfg.pf_config[i].m_intr_pins == 2) {
              intr_pin_en[1] ==1;
            }
            else if(m_pcie_dev_top_cfg.pf_config[i].m_intr_pins == 3) {
              intr_pin_en[2] ==1;
            }
            else if(m_pcie_dev_top_cfg.pf_config[i].m_intr_pins == 4) {
              intr_pin_en[3] ==1;
            }
          }
        }
      }
    }
  }

  constraint c_intr_pin_en{
    soft intr_pin_en[0] == 0 ;
    soft intr_pin_en[1] == 0 ;
    soft intr_pin_en[2] == 0 ;
    soft intr_pin_en[3] == 0 ;
  }


constraint c_intx_msg_intr_pins {
    solve m_intr_pins[0],m_intr_pins[1],m_intr_pins[2],m_intr_pins[3], intr_pin_en[0], intr_pin_en[1], intr_pin_en[2], intr_pin_en[3] before m_tlp_msg_code;

    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && (!m_pcie_dev_cfg.bypass_dut_type_chk))
    {
      if(((m_intr_pins[0] != 1 && (m_intr_pins[1] != 2 && (m_intr_pins[2] != 3 && m_intr_pins[3] != 4))))) {
        !(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A : CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D]});
      }
      if(( m_intr_pins[0] != 1 &&  m_pcie_dev_top_cfg.intx_pin_or_hls == 1) || (intr_pin_en[0] != 1 && m_pcie_dev_top_cfg.intx_pin_or_hls == 0) ) {
        !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A, CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A});
      }
      if(( m_intr_pins[1] != 2 &&  m_pcie_dev_top_cfg.intx_pin_or_hls == 1) || (intr_pin_en[1] != 1 && m_pcie_dev_top_cfg.intx_pin_or_hls == 0) ) {
        !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B, CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B});
      }
      if(( m_intr_pins[2] != 3 &&  m_pcie_dev_top_cfg.intx_pin_or_hls == 1) || (intr_pin_en[2] != 1 && m_pcie_dev_top_cfg.intx_pin_or_hls == 0) ) {
        !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C, CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C});
      }
      if(( m_intr_pins[3] != 4 &&  m_pcie_dev_top_cfg.intx_pin_or_hls == 1) || (intr_pin_en[3] != 1 && m_pcie_dev_top_cfg.intx_pin_or_hls == 0) ) {
        !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D, CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D});
      }
      if((intr_pin_en[0] != 1 && intr_pin_en[1] != 1 && intr_pin_en[2] != 1 && intr_pin_en[3] != 1) && m_pcie_dev_top_cfg.intx_pin_or_hls == 0) {
        !(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A : CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D]});
      }
      

      if(m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_EP /*OUTBOUND from EP DUT*/ && m_pcie_dev_top_cfg.intx_pin_or_hls /*PIN mode*/){
        if(m_pcie_dev_top_cfg.intx_pin_assert[0]) {
          m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A ;
        }
        else {
          m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_assert[1]) {
          m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B ;
        }
        else {
          m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_assert[2]) {
          m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C ;
        }
        else {
          m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_assert[3]) {
          m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D ;
        }
        else {
          m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D ;
        }
      }

      if(m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP /*OUTBOUND from EP DUT*/ && m_pcie_dev_top_cfg.intx_ib_b2b){
        if(m_pcie_dev_top_cfg.intx_pin_ib_deassert[0]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[0]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_deassert[1]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[1]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_deassert[2]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[2]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_deassert[3]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[3]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D) ;
        }
      }
      if(m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP /*OUTBOUND from EP DUT*/ && !m_pcie_dev_top_cfg.intx_ib_b2b){
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[0] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[0]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[0] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[0]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[1] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[1]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[1] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[1]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[2] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[2]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[2] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[2]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[3] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[3]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D) ;
        }
        if(m_pcie_dev_top_cfg.intx_pin_ib_assert[3] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[3]) {
          (m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D) ;
        }
      }
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_default_routing_id
  // This Constraint generates default routing id
  //--------------------------------------------------------------------------
  constraint c_default_routing_id {

    if((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !m_pcie_dev_cfg.bypass_dut_type_chk)){
      m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC;
    }
    (m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A : CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D]})
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;

    m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PM_Active_State_Nak
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;

    m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PM_PME
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC;

    m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PME_Turn_Off
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC;

    m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PME_TO_Ack
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_GATHER_TO_RC;

    (m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_ERR_COR:CDN_HPA_PCIE_TLP_MSG_ERR_FATAL]})
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC;

    (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_LOCK_Unlock)
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC;

    (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_SLOT_Power_Limit)
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;

    if(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_HP_Attention_Off:CDN_HPA_PCIE_TLP_MSG_HP_Attention_Pressed]}) {
      m_tlp_msg_rout_type== CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;
    }

    if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}) {
      m_tlp_msg_rout_type== CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID;
    }

    (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_LTR)
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;

    m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PR_Request
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC;

    (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_OBFF)
    -> m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;

    if(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_PTM_Req:CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD]}) {
      m_tlp_msg_rout_type== CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;
    }

    if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) {
      m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC,[CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID:CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE]};}

      if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
      m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN}) { m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID,CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC}; }

      if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
      m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_DRS}) { m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE}; }

      if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
      m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}) { m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC}; }

      if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
      m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_HIER_ID}) { m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC}; }

      if (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_IDE_Sync, CDN_HPA_PCIE_TLP_MSG_IDE_Escort, CDN_HPA_PCIE_TLP_MSG_IDE_Fail}) {
        m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID, CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE};
      }

    }

    //--------------------------------------------------------------------------
    // Constraint: c_sbsa_ari_fwd_dis
    // This Constraint ensures the non ID routed msg in case of SBSA and ari is disabled
    // Restriction only to RP DUT outbound tlps (After sbsa is enabled in LM)
    //--------------------------------------------------------------------------
    //constraint c_sbsa_ari_fwd_dis {
    //  if ((m_pcie_dev_top_cfg.send_sbsa_cfg_type_1 && (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && m_pcie_dev_top_cfg.i_cfg.strap_is_rp) && !m_pcie_dev_cfg.m_ari_fwd_en) {
    //    m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID;
    //  }
    //}

    //--------------------------------------------------------------------------
    // Constraint: m_obffCodeConstraint
    // This Constraint generated optimises buffer flush/fill values
    //--------------------------------------------------------------------------
    constraint m_obffCodeConstraint {
      m_obffCode inside { CDN_HPA_PCIE_OBFF_idle, CDN_HPA_PCIE_OBFF_obff, CDN_HPA_PCIE_OBFF_cpuActive };
      `ifndef BRIDGE_MODULE_MODE
        ((m_pcie_link_cfg.usp_dev_config.m_obff_en inside {2'b00,2'b11} ) || (m_pcie_dev_cfg.m_obff_en inside {2'b00,2'b11} )) -> !(m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_OBFF);
      `endif
    }

    //--------------------------------------------------------------------------
    // Constraint: dis_intrConstraint
    // This Constraint disable the interrupt based on msig intx assert and deassert
    //--------------------------------------------------------------------------
    constraint dis_intrConstraint {
      solve dis_intr before m_tlp_msg_code;
      `ifndef BRIDGE_MODULE_MODE
        (dis_intr == 1 ) -> !(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A : CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D]});
      `endif
    }

    //--------------------------------------------------------------------------
    // Constraint: c_dis_intr
    // This Constraint disable the interrupt based on msig intx assert and deassert
    //--------------------------------------------------------------------------
    constraint c_dis_intr {
      dis_intr == m_pcie_dev_cfg.dis_intr ;
    }

    //--------------------------------------------------------------------------
    // Constraint: c_vdm_id
    // This Constraint will generate vendor message id
    //--------------------------------------------------------------------------
    constraint c_vdm_id {
      if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && (m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_Msg)) {
        m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_DRS,CDN_HPA_PCIE_TLP_VDM_FRS,CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1};}
        if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && (m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_MsgD)) {
          m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_HIER_ID,CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1};}

          //Ensure STD_VD_1 msg doesn't have valid subtype encoding
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && (m_tlp_vdm_msg_subtype ==CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1)) {
            !(m_tlp_vendor_msg[31:24] inside {8'h0,8'h8,8'h9,8'h1});
          }
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
          m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_DRS,CDN_HPA_PCIE_TLP_VDM_FRS,CDN_HPA_PCIE_TLP_VDM_HIER_ID}) {
            m_tlp_vendor_id == 16'h0001;
            m_tlp_vendor_msg[31:24] == m_tlp_vdm_msg_subtype;
            m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC,[CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID:CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE]};
          }
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
          m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_DRS}) {
            m_tlp_vendor_msg[23:0] == msg_ln_drs_byte_13_15_rsvd;
          }
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
          m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}) {
            m_tlp_vendor_msg[23:4] == msg_frs_byte_13_15_rsvd;
            m_tlp_vendor_msg[3:0] == m_tlp_frs_msg_reason;
          }
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
          m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_HIER_ID}) {
            m_tlp_vendor_msg[15:0] == m_tlp_hier_vmsg_system_guid[143:128];
            m_tlp_vendor_msg[23:16] == m_tlp_hier_vmsg_guid_authority_id;
          }
        }

        //--------------------------------------------------------------------------
        // Constraint: c_msg_protocol_handling
        // This Constraint will apply PCIe protocol handling constraint
        //--------------------------------------------------------------------------
        constraint c_msg_protocol_handling {
          `ifndef BRIDGE_MODULE_MODE
            //INV_CPL & PRG_RESP are response messages and that souldn't be Tx without Recieving Req.
            (!m_pcie_dev_cfg.bypass_dut_type_chk && !m_hls_bypass_constraint) -> soft !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response});

            //If other end EP device don't have buffer to accomadate inv_req (As specified in its inv_queue_depth), don't initaite INV_REQ
            if(m_pcie_dev_top_cfg.inv_req_outstanding >= m_pcie_link_cfg.usp_dev_config.m_ats_inv_queue_depth) {
              m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_AT_Invalidate;
            }
            //Initiate page req when EP device(initator) dev/Fn allowed by PRReqAlloc
            if(m_pcie_dev_top_cfg.pr_req_outstanding >= m_pcie_dev_cfg.prReqAlloc) {
              m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_PR_Request;
            }
          `endif
        }

        //Constraint to make specific msg fields
        //--------------------------------------------------------------------------
        // Constraint: c_msg_specific_fields
        // This Constraint will make specific msg fields
        //--------------------------------------------------------------------------
        constraint c_msg_specific_fields {
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_OBFF) {m_obffCode==0;}
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) {
            m_tlp_itag==0;
          } else {
            `ifndef TOP_LEVEL_SIMS
              soft m_tlp_itag inside {m_pcie_dev_top_cfg.itag_available_q};
            `else
              m_tlp_itag inside {m_pcie_dev_top_cfg.itag_available_q};
            `endif
          }
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) {m_inv_cpl_cnt==0;  m_tlp_itag_vector==0;}
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_LTR) {m_tlp_ltr_msg_snoop_latency==0;m_tlp_ltr_msg_no_snoop_latency==0;}
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD})) {m_ptmMasterTime==0; m_ptmPropagationDelay==0; }
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PR_Request)
          {
            soft ((m_prReadRequested+m_prWriteRequested) inside {[1:2]});
            soft m_prLastRequest==1;
            
            //table 10-6 : Read Access Requested
            if(m_pasid_prefix_present){
              if(m_pasid_exec_value == 1)
              m_prReadRequested == 1;
            }
          } //TODO Ignoring stop marker(RW=00 & L=1) Also, Making PRLAST=1. To code for multiple PR in a single group & Stop_marker
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_PR_Request) {m_page_addr==0;m_prReadRequested==0;m_prWriteRequested==0;m_prLastRequest==0;}
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response})) {m_prGroupIndex==0;}
          if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PR_Request)) {m_prGroupIndex inside {m_pcie_dev_top_cfg.prg_index_available_q}};
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code != CDN_HPA_PCIE_TLP_MSG_PR_Group_Response) {soft m_prgResponseCode==0;}
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1})) {m_tlp_vendor_id==0; m_tlp_vendor_msg==0;  }
          if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}) {m_tlp_frs_msg_reason inside {[CDN_HPA_PCIE_DRS_MSG_RCVD:CDN_HPA_PCIE_FLR_COMPLETED],CDN_HPA_PCIE_VF_ENABLED,CDN_HPA_PCIE_VF_DISABLED}; }
        }
        // messages attributes
        //--------------------------------------------------------------------------
        // Constraint: c_msg_attr
        // This Constraint to generate message attributes
        //--------------------------------------------------------------------------
        constraint c_msg_attr {
          (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE &&
          (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
          m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_DRS,CDN_HPA_PCIE_TLP_VDM_FRS,CDN_HPA_PCIE_TLP_VDM_HIER_ID}) -> {m_tlp_attr1 == 0; m_tlp_attr0 == 0;}

          (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE &&
          (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
          m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_LN) -> {m_tlp_attr0[0] == 0;}

          if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) &&
          (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) &&
          (m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID)
        ) {m_tlp_attr1 ==0;}
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE &&
        //TODO Due to VIPSR_46377783 making RO bit =0 in PR/PRG messages
        //(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Group_Response,CDN_HPA_PCIE_TLP_MSG_PR_Request})) {m_tlp_attr0[0] == 0;}
        (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Group_Response,CDN_HPA_PCIE_TLP_MSG_PR_Request})) {m_tlp_attr0[1:0] == 0;}

        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE &&
        ((m_prLastRequest) &&(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request}))) {m_tlp_attr0[1] == 0;} //RO bit shouldn't be set if its Last req in PRG

        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE &&
        (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete})) {m_tlp_attr1 == 0;
        m_tlp_attr0 == 0;}

        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE &&
        !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1,
        CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response})) {m_tlp_attr0 == 0;m_tlp_attr1 == 0;}

      }

      // TODO Function number requiremnts for PM messages

      //constraint tc_vc mapping based tc select
      //--------------------------------------------------------------------------
      // Constraint: tc_vc_map_based_tc_c
      // This Constraint will mapp tc_vc nased on tc select
      //--------------------------------------------------------------------------
      constraint tc_vc_map_based_tc_c {
        if(m_pcie_dev_cfg.m_unmapped_tc_list.size != 0  ) {
          !(m_tlp_tc inside {m_pcie_dev_cfg.m_unmapped_tc_list});
        }
      }

      //--------------------------------------------------------------------------
      // Constraint: uio_vc_3_4
      // This Constraint will set correct VC for UIO TLPs
      // SVC is used instead of VC for UIO case. 
      //--------------------------------------------------------------------------
      constraint uio_vc_3_4 {
        if (!axi_region_prog && is_flit_mode && (parameters_cfg_pkg::NUM_UIO_VCS > 0)) {
          if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr,CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl,CDN_HPA_PCIE_TLP_TYPE_UIORdCpl,CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) {
            (m_pcie_dev_top_cfg.num_vc_enabled >= 2 && parameters_cfg_pkg::NUM_UIO_VCS == 1) -> (m_pcie_dev_top_cfg.vc_tc_map[1][m_tlp_tc] == 1);
            (m_pcie_dev_top_cfg.num_vc_enabled >= 3 && parameters_cfg_pkg::NUM_UIO_VCS == 2) -> (m_pcie_dev_top_cfg.vc_tc_map[1][m_tlp_tc] == 1 || m_pcie_dev_top_cfg.vc_tc_map[2][m_tlp_tc] == 1);
          }
          else {
            // Non-UIO TLPs should not use UIO VCs (VC1 and VC2)
            (m_pcie_dev_top_cfg.num_vc_enabled >= 2 && parameters_cfg_pkg::NUM_UIO_VCS == 1) -> (m_pcie_dev_top_cfg.vc_tc_map[1][m_tlp_tc] == 0);
            (m_pcie_dev_top_cfg.num_vc_enabled >= 3 && parameters_cfg_pkg::NUM_UIO_VCS == 2) -> (m_pcie_dev_top_cfg.vc_tc_map[1][m_tlp_tc] == 0 && m_pcie_dev_top_cfg.vc_tc_map[2][m_tlp_tc] == 0);
          }
        }
      }

      //--------------------------------------------------------------------------
      // Constraint: c_non_uio_tc_selection
      // This Constraint ensures non-UIO TLPs select TC that doesn't map to UIO VCs
      // Provides additional protection to ensure TC selection avoids UIO VCs for non-UIO TLPs
      //--------------------------------------------------------------------------
      constraint c_non_uio_tc_selection {
        if (!axi_region_prog && is_flit_mode && (parameters_cfg_pkg::NUM_UIO_VCS > 0)) {
          // Non-UIO TLPs should not select any TC that maps to UIO VCs
          !(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr,
                               CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl,
                               CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) -> 
          {
            if (parameters_cfg_pkg::NUM_UIO_VCS == 1 && m_pcie_dev_top_cfg.num_vc_enabled >= 2) {
              // When VC1 is UIO VC, ensure non-UIO TLPs don't pick TC mapped to VC1
              foreach (m_pcie_dev_top_cfg.vc_tc_map[1][tc]) {
                if (m_pcie_dev_top_cfg.vc_tc_map[1][tc] == 1) {
                  m_tlp_tc != tc;
                }
              }
            }
            if (parameters_cfg_pkg::NUM_UIO_VCS == 2 && m_pcie_dev_top_cfg.num_vc_enabled >= 3) {
              // When VC1 and VC2 are UIO VCs, ensure non-UIO TLPs don't pick TC mapped to VC1 or VC2
              foreach (m_pcie_dev_top_cfg.vc_tc_map[1][tc]) {
                if (m_pcie_dev_top_cfg.vc_tc_map[1][tc] == 1) {
                  m_tlp_tc != tc;
                }
              }
              foreach (m_pcie_dev_top_cfg.vc_tc_map[2][tc]) {
                if (m_pcie_dev_top_cfg.vc_tc_map[2][tc] == 1) {
                  m_tlp_tc != tc;
                }
              }
            }
          }
        }
      }

      // Default traffic class
      // Config requests can only use TC0
      //--------------------------------------------------------------------------
      // Constraint: c_tc_zero
      // This constraint will set Default traffic class
      // Confighis  requests can only use TC0
      //--------------------------------------------------------------------------
      constraint c_tc_zero {
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) {
          if(!(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete,CDN_HPA_PCIE_TLP_MSG_IDE_Sync, CDN_HPA_PCIE_TLP_MSG_IDE_Escort, CDN_HPA_PCIE_TLP_MSG_IDE_Fail})) { m_tlp_tc == 0; }
          if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1} && m_tlp_vdm_msg_subtype !=CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1) { m_tlp_tc == 0; }
        }
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) { m_tlp_tc == 0; }
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE ) { m_tlp_tc == 0; }
        if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64}) { m_tlp_tc == 0; }
      }

      //--------------------------------------------------------------------------
      // Constraint: c_ltr_msg
      // This Constraint generates latency tolerance reporting values
      //--------------------------------------------------------------------------
      constraint c_ltr_msg {
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_LTR)) {
          //LTR Message should contains reserved value (0) in the Requester Function Number field
          m_tlp_requester_id.function_num == 0;

          //No-Snoop/Snoop Latency value should not exceeded the conglomerated (for Multi Funciton Device),
          //or the lowest maximum value associated with the function 0.
          //TODO: For handling OC and SB, generating latency values always less than programmed value
          //and greater than 0 to distinguish b/n client generated pkts vs internally generated packets.
          if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
            //m_tlp_ltr_msg_snoop_latency[12:0] > 0;
            //m_tlp_ltr_msg_no_snoop_latency[12:0] > 0;
            //m_tlp_ltr_msg_no_snoop_latency[12:0] < {m_pcie_link_cfg.usp_dev_top_config.m_nosnoop_sc,m_pcie_link_cfg.usp_dev_top_config.m_nosnoop_lat};
            //m_tlp_ltr_msg_snoop_latency[12:0] < {m_pcie_link_cfg.usp_dev_top_config.m_snoop_sc,m_pcie_link_cfg.usp_dev_top_config.m_snoop_lat};
            36'((2**(m_tlp_ltr_msg_snoop_latency[12:10]*5))*m_tlp_ltr_msg_snoop_latency[9:0]) < 36'((2**(m_pcie_link_cfg.usp_dev_top_config.m_snoop_sc*5))*m_pcie_link_cfg.usp_dev_top_config.m_snoop_lat);
            36'((2**(m_tlp_ltr_msg_no_snoop_latency[12:10]*5))*m_tlp_ltr_msg_no_snoop_latency[9:0]) < 36'((2**(m_pcie_link_cfg.usp_dev_top_config.m_nosnoop_sc*5))*m_pcie_link_cfg.usp_dev_top_config.m_nosnoop_lat);
            m_tlp_ltr_msg_snoop_latency[9:0] > 0;
            m_tlp_ltr_msg_no_snoop_latency[9:0] > 0;
          }

          m_tlp_ltr_msg_no_snoop_latency[15] dist {0:=50,1:=50}; //Requirement field
          soft m_tlp_ltr_msg_no_snoop_latency[14:13] == 0; //Reserved field
          m_tlp_ltr_msg_no_snoop_latency[12:10] inside {[0:5]}; //Latency scale
          m_tlp_ltr_msg_no_snoop_latency[9:0] >=0;

          m_tlp_ltr_msg_snoop_latency[15] dist {0:=50,1:=50}; //Requirement field
          soft m_tlp_ltr_msg_snoop_latency[14:13] == 0; //Reserved field
          m_tlp_ltr_msg_snoop_latency[12:10] inside {[0:5]}; //Latency scale
          m_tlp_ltr_msg_snoop_latency[9:0] >=0;
        }
      }

      //--------------------------------------------------------------------------
      // Constraint: c_m_tlp_ln
      // This soft Constraint will set teh tlp light weight notification to zero
      //--------------------------------------------------------------------------
      constraint c_m_tlp_ln {soft m_tlp_ln == 0;}

      // Config/IO requerst rules
      // LN, TH. ATTR2 is RSVD - for now make zero
      // Attr[1:0]  is zero
      //--------------------------------------------------------------------------
      // Constraint: c_cfg_rules
      // Config/IO requerst rules
      // LN, TH. ATTR2 is RSVD - for now make zero
      // Attr[1:0]  is zero
      //--------------------------------------------------------------------------
      constraint c_cfg_rules {
        m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE-> {m_tlp_attr1 == 0; m_tlp_attr0 == 0;
        m_tlp_ln == 0;
        m_tlp_th == 0;
        m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated;
        m_tlp_reg_num[1:0] == cfg_byte_11_rsvd_field_1_0;
      }
    }
    // Added different constraints to make it easy for EI
    //--------------------------------------------------------------------------
    // Constraint: c_io_rules
    // Added different constraints to make it easy for EI
    //--------------------------------------------------------------------------
    constraint c_io_rules {
      m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE -> {m_tlp_attr1 == 0; m_tlp_attr0 == 0;
      m_tlp_ln == 0;
      m_tlp_th == 0;
      m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated;
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_msg_rules
  // This Constraint generates messge rules
  //--------------------------------------------------------------------------
  constraint c_msg_rules {
    solve m_tlp_msg_rout_type before m_hdr_type;
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) -> {m_tlp_ln == 0; m_tlp_th == 0; m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated;}
    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) ->  m_hdr_type[2:0]==m_tlp_msg_rout_type;

    //No undefined msg_code by default
    send_undefined_msg_code==0;
    solve send_undefined_msg_code before m_tlp_msg_code;

    (send_undefined_msg_code==0) -> !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_RSVD_3,[CDN_HPA_PCIE_TLP_MSG_RSVD_6_156:CDN_HPA_PCIE_TLP_MSG_RSVD_6_1515],CDN_HPA_PCIE_TLP_MSG_RSVD_17,
    CDN_HPA_PCIE_TLP_MSG_RSVD_19,[CDN_HPA_PCIE_TLP_MSG_RSVD_21_2321:CDN_HPA_PCIE_TLP_MSG_RSVD_21_2323],CDN_HPA_PCIE_TLP_MSG_RSVD_26,
    [CDN_HPA_PCIE_TLP_MSG_RSVD_28_3128:CDN_HPA_PCIE_TLP_MSG_RSVD_28_3131],[CDN_HPA_PCIE_TLP_MSG_RSVD_40_4740:CDN_HPA_PCIE_TLP_MSG_RSVD_40_4747],
    CDN_HPA_PCIE_TLP_MSG_RSVD_50,[CDN_HPA_PCIE_TLP_MSG_RSVD_52_6352:CDN_HPA_PCIE_TLP_MSG_RSVD_52_6363],CDN_HPA_PCIE_TLP_MSG_RSVD_66,
    CDN_HPA_PCIE_TLP_MSG_RSVD_70,[CDN_HPA_PCIE_TLP_MSG_RSVD_73_7973:CDN_HPA_PCIE_TLP_MSG_RSVD_73_7979],CDN_HPA_PCIE_TLP_MSG_RSVD_81,
    [CDN_HPA_PCIE_TLP_MSG_RSVD_87_12587:CDN_HPA_PCIE_TLP_MSG_RSVD_87_125125], [CDN_HPA_PCIE_TLP_MSG_RSVD_128_255128:CDN_HPA_PCIE_TLP_MSG_RSVD_128_255255]});
  }

  //--------------------------------------------------------------------------
  // Constraint: c_undefine_msg_tx
  // This Constraint generates undefined message tx
  //--------------------------------------------------------------------------
  constraint c_undefine_msg_tx {
    (send_undefined_msg_code==1) -> m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_RSVD_3,[CDN_HPA_PCIE_TLP_MSG_RSVD_6_156:CDN_HPA_PCIE_TLP_MSG_RSVD_6_1515],CDN_HPA_PCIE_TLP_MSG_RSVD_17,
    CDN_HPA_PCIE_TLP_MSG_RSVD_19,[CDN_HPA_PCIE_TLP_MSG_RSVD_21_2321:CDN_HPA_PCIE_TLP_MSG_RSVD_21_2323],CDN_HPA_PCIE_TLP_MSG_RSVD_26,
    [CDN_HPA_PCIE_TLP_MSG_RSVD_28_3128:CDN_HPA_PCIE_TLP_MSG_RSVD_28_3131],[CDN_HPA_PCIE_TLP_MSG_RSVD_40_4740:CDN_HPA_PCIE_TLP_MSG_RSVD_40_4747],
    CDN_HPA_PCIE_TLP_MSG_RSVD_50,[CDN_HPA_PCIE_TLP_MSG_RSVD_52_6352:CDN_HPA_PCIE_TLP_MSG_RSVD_52_6363],CDN_HPA_PCIE_TLP_MSG_RSVD_66,
    CDN_HPA_PCIE_TLP_MSG_RSVD_70,[CDN_HPA_PCIE_TLP_MSG_RSVD_73_7973:CDN_HPA_PCIE_TLP_MSG_RSVD_73_7979],CDN_HPA_PCIE_TLP_MSG_RSVD_81,
    [CDN_HPA_PCIE_TLP_MSG_RSVD_87_12587:CDN_HPA_PCIE_TLP_MSG_RSVD_87_125125], [CDN_HPA_PCIE_TLP_MSG_RSVD_128_255128:CDN_HPA_PCIE_TLP_MSG_RSVD_128_255255]};
  }

  //--------------------------------------------------------------------------
  // Constraint: c_tlp_req_to_type_mapping
  // This Constraint generates tlp request to type mapping
  //--------------------------------------------------------------------------
  constraint c_tlp_req_to_type_mapping {
    (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) ->
    !(m_tlp_trans_type inside {[CDN_HPA_PCIE_TRANS_IO_TYPE : CDN_HPA_PCIE_TRANS_CFG_TYPE]});
  }

  // TODO BUS# changes dynamically in simualtion for EP
  //--------------------------------------------------------------------------
  // Constraint: c_req_id
  // This Constraint will generate the request id based on the BDF in the config.
  //--------------------------------------------------------------------------
  constraint c_req_id {
    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && !m_pcie_dev_cfg.bypass_dut_type_chk) {
      // CXL-895 IO TLPs targetting RCRB and MEMBARs are function agnostic
      // So RCRB and MEMABR TLPs alaways target with function-0
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE && cxl_io_tlp) {
        soft m_tlp_requester_id.bus_num == m_pcie_dev_top_cfg.pf_config[0].m_req_id.bus_num;
        soft m_tlp_requester_id.device_num == m_pcie_dev_top_cfg.pf_config[0].m_req_id.device_num;
        soft m_tlp_requester_id.function_num == m_pcie_dev_top_cfg.pf_config[0].m_req_id.function_num;
      }

      if(m_tlp_req_type != CDN_HPA_PCIE_TRANS_COMPLETION) {
        soft m_tlp_requester_id.bus_num == m_pcie_dev_cfg.m_req_id.bus_num;
        soft m_tlp_requester_id.device_num == m_pcie_dev_cfg.m_req_id.device_num;
        soft m_tlp_requester_id.function_num == m_pcie_dev_cfg.m_req_id.function_num;
      }
      else {
        // For completions Req ID is directly from the NP requester
        if(np_req_tlp != null){
          soft m_tlp_requester_id.bus_num == np_req_tlp.m_tlp_requester_id.bus_num;
          soft m_tlp_requester_id.device_num == np_req_tlp.m_tlp_requester_id.device_num;
          soft m_tlp_requester_id.function_num == np_req_tlp.m_tlp_requester_id.function_num;
        }
      }
      if((m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Msg,CDN_HPA_PCIE_TLP_TYPE_MsgD})){
        //If the Route by ID routing is used, bytes 8 and 9 form a 16-bit field for the destination ID. otherwise these bytes are Reserved.
        soft m_tlp_completer_id.bus_num == msg_destination_id_rsvd;
        soft m_tlp_completer_id.device_num == msg_destination_id_rsvd;
        soft m_tlp_completer_id.function_num == msg_destination_id_rsvd;
      } else {
        if((m_pcie_dev_top_cfg.send_sbsa_cfg_type_1 || (m_pcie_dev_top_cfg.i_cfg.strap_port_type inside {1,3})) && (m_tlp_trans_type==CDN_HPA_PCIE_TRANS_CFG_TYPE) && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1,CDN_HPA_PCIE_TLP_TYPE_CfgWr1})) {
          //This will require to gen the cfg tlp, which will get routed to Own COnfig space
          if(cfg_type1_target_pri && (m_pcie_dev_top_cfg.i_cfg.strap_port_type inside {1,3})){
            soft m_tlp_completer_id.bus_num inside {m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.pri_bus_num};
            soft m_tlp_completer_id.device_num == m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num;
          }
          else if (cfg_type1_target_sec) {
            //this will be required to gen the cfg tlp, which will get converted to type0 by HAL
            soft m_tlp_completer_id.bus_num inside {m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.sec_bus_num};
            soft m_tlp_completer_id.device_num == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
            if(target_vendor_id) {
              soft m_tlp_ext_reg_num == 0;
              soft m_tlp_reg_num     == 0;
            }
          }
          else if (cfg_type1_target_sec_non_zero_dev_ari_dis) {
            //this will be required to gen the cfg tlp, which will get converted to type0 by HAL
            soft m_tlp_completer_id.bus_num inside {m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.sec_bus_num};
            if(!m_pcie_dev_cfg.m_ari_fwd_en) {
              soft m_tlp_completer_id.device_num != m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            }
            else {
              soft m_tlp_completer_id.device_num == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            }
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
          }
          else if (cfg_type1_target_pri_wrong_dev_fun) {
            //this will be required to gen the cfg tlp, which will get addressed with UR Cpl by HAL
            //Error Combinations:
            //DSP Primary, USP Dev, X- Func
            //DSP Primary, DSP Dev, USP Func
            soft m_tlp_completer_id.bus_num      inside {m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.pri_bus_num};
            soft m_tlp_completer_id.device_num   != m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num inside {m_pcie_link_cfg.usp_dev_config.m_req_id.function_num,m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num};
            //soft {m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} != {m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num,m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num}; //TODO: Try this by removing above two lines
          }
          else if (cfg_type1_target_more_than_sec_less_equal_to_sub) {
            //this will be required to gen the cfg tlp, which will be passed as type1 by HAL
            soft m_tlp_completer_id.bus_num > m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.sec_bus_num;
            soft m_tlp_completer_id.bus_num <= m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.sub_bus_num;
            soft m_tlp_completer_id.device_num   inside {m_pcie_link_cfg.usp_dev_config.m_req_id.device_num, m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num};
            soft m_tlp_completer_id.function_num inside {m_pcie_link_cfg.usp_dev_config.m_req_id.function_num,m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num};
          }
          else if (cfg_type1_target_more_than_sub) {
            //this will be required to gen the cfg tlp, which will get addrssed with UR Cpl by  HAL.
            soft m_tlp_completer_id.bus_num > m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.sub_bus_num;
            soft m_tlp_completer_id.device_num   inside {m_pcie_link_cfg.usp_dev_config.m_req_id.device_num, m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num};
            soft m_tlp_completer_id.function_num inside {m_pcie_link_cfg.usp_dev_config.m_req_id.function_num,m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num};
          }
          else {
            soft m_tlp_completer_id.bus_num == m_pcie_link_cfg.usp_dev_config.m_req_id.bus_num;
            soft m_tlp_completer_id.device_num == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
          }
        }
        else if((m_pcie_dev_top_cfg.i_cfg.strap_port_type inside {2}) && (m_tlp_trans_type==CDN_HPA_PCIE_TRANS_CFG_TYPE) && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1,CDN_HPA_PCIE_TLP_TYPE_CfgWr1})) {
          //This will require to gen the cfg tlp, which will get routed to Own COnfig space
          if(cfg_type1_target_pri){
            soft m_tlp_completer_id.bus_num inside {m_pcie_link_cfg.usp_dev_top_config.m_usp_pri_sec_sub_bus.pri_bus_num};
            soft m_tlp_completer_id.device_num   == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
          }
          else if (cfg_type1_target_sec) {
            //this will be required to gen the cfg tlp, which will get converted to type0 by HAL
            soft m_tlp_completer_id.bus_num inside {m_pcie_link_cfg.usp_dev_top_config.m_usp_pri_sec_sub_bus.sec_bus_num};
            soft m_tlp_completer_id.device_num == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
            if(target_vendor_id) {
              soft m_tlp_ext_reg_num == 0;
              soft m_tlp_reg_num     == 0;
            }
          }
          else if (cfg_type1_target_sec_non_zero_dev_ari_dis) {
            //this will be required to gen the cfg tlp, which will get converted to type0 by HAL
            soft m_tlp_completer_id.bus_num inside {m_pcie_link_cfg.usp_dev_top_config.m_usp_pri_sec_sub_bus.sec_bus_num};
            if(!m_pcie_dev_cfg.m_ari_fwd_en) {
              soft m_tlp_completer_id.device_num != m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            }
            else {
              soft m_tlp_completer_id.device_num == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            }
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
          }
          else if (cfg_type1_target_pri_wrong_dev_fun) {
            //this will be required to gen the cfg tlp, which will get addressed with UR Cpl by HAL
            //Error Combinations:
            //DSP Primary, USP Dev, X- Func
            //DSP Primary, DSP Dev, USP Func
            soft m_tlp_completer_id.bus_num      inside {m_pcie_link_cfg.usp_dev_top_config.m_usp_pri_sec_sub_bus.pri_bus_num};
            soft m_tlp_completer_id.device_num   != m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num inside {m_pcie_link_cfg.usp_dev_config.m_req_id.function_num,m_pcie_link_cfg.usp_dev_config.m_req_id.function_num};
            //soft {m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} != {m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num,m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num}; //TODO: Try this by removing above two lines
          }
          else if (cfg_type1_target_more_than_sec_less_equal_to_sub) {
            //this will be required to gen the cfg tlp, which will be passed as type1 by HAL
            soft m_tlp_completer_id.bus_num > m_pcie_link_cfg.usp_dev_top_config.m_usp_pri_sec_sub_bus.sec_bus_num;
            soft m_tlp_completer_id.bus_num <= m_pcie_link_cfg.usp_dev_top_config.m_usp_pri_sec_sub_bus.sub_bus_num;
            soft m_tlp_completer_id.device_num   inside {m_pcie_link_cfg.usp_dev_config.m_req_id.device_num, m_pcie_link_cfg.usp_dev_config.m_req_id.device_num};
            soft m_tlp_completer_id.function_num inside {m_pcie_link_cfg.usp_dev_config.m_req_id.function_num,m_pcie_link_cfg.usp_dev_config.m_req_id.function_num};
          }
          else if (cfg_type1_target_more_than_sub) {
            //this will be required to gen the cfg tlp, which will get addrssed with UR Cpl by  HAL.
            soft m_tlp_completer_id.bus_num > m_pcie_link_cfg.usp_dev_top_config.m_usp_pri_sec_sub_bus.sub_bus_num;
            soft m_tlp_completer_id.device_num   inside {m_pcie_link_cfg.usp_dev_config.m_req_id.device_num, m_pcie_link_cfg.usp_dev_config.m_req_id.device_num};
            soft m_tlp_completer_id.function_num inside {m_pcie_link_cfg.usp_dev_config.m_req_id.function_num,m_pcie_link_cfg.usp_dev_config.m_req_id.function_num};
          }
          else {
            soft m_tlp_completer_id.bus_num == m_pcie_link_cfg.usp_dev_config.m_req_id.bus_num;
            soft m_tlp_completer_id.device_num == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
          }
        }
        else {
          if((m_pcie_dev_top_cfg.send_sbsa_cfg_type_1 || (m_pcie_dev_top_cfg.i_cfg.strap_port_type inside {1,2,3})) && (m_tlp_trans_type==CDN_HPA_PCIE_TRANS_CFG_TYPE)) {
            //This will require to gen the cfg tlp, which will get routed to Own COnfig space
            if(cfg_type0_target_pri){
              soft m_tlp_completer_id.bus_num inside {m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.pri_bus_num, [m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.sec_bus_num:m_pcie_dev_top_cfg.m_rp_pri_sec_sub_bus.sub_bus_num] };
              soft m_tlp_completer_id.device_num == m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num;
              soft m_tlp_completer_id.function_num == m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num;
            }
            else {
              soft m_tlp_completer_id.bus_num == m_pcie_link_cfg.usp_dev_config.m_req_id.bus_num;
              soft m_tlp_completer_id.device_num == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
              soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
              if(target_vendor_id) {
                soft m_tlp_ext_reg_num == 0;
                soft m_tlp_reg_num     == 0;
              }
            }
          }
          else {
            soft m_tlp_completer_id.bus_num == m_pcie_link_cfg.usp_dev_config.m_req_id.bus_num;
            soft m_tlp_completer_id.device_num == m_pcie_link_cfg.usp_dev_config.m_req_id.device_num;
            soft m_tlp_completer_id.function_num == m_pcie_link_cfg.usp_dev_config.m_req_id.function_num;
          }
        }
      }
    }
    else {
      if(m_tlp_req_type != CDN_HPA_PCIE_TRANS_COMPLETION) {
        soft m_tlp_requester_id.bus_num == m_pcie_dev_cfg.m_req_id.bus_num;
        soft m_tlp_requester_id_tb.bus_num == m_pcie_dev_cfg.m_req_id.bus_num;
        soft m_tlp_requester_id.device_num == m_pcie_dev_cfg.m_req_id.device_num;
        soft m_tlp_requester_id_tb.device_num == m_pcie_dev_cfg.m_req_id.device_num;
        soft m_tlp_requester_id.function_num == m_pcie_dev_cfg.m_req_id.function_num;
        soft m_tlp_requester_id_tb.function_num == m_pcie_dev_cfg.m_req_id.function_num;
      }
      else {
        // For complations Req ID is directly from the NP requester
        if(np_req_tlp != null){
          soft  m_tlp_requester_id.bus_num == np_req_tlp.m_tlp_requester_id.bus_num;
          soft  m_tlp_requester_id.device_num == np_req_tlp.m_tlp_requester_id.device_num;
          soft  m_tlp_requester_id.function_num == np_req_tlp.m_tlp_requester_id.function_num;
        }
      }
      if((m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Msg,CDN_HPA_PCIE_TLP_TYPE_MsgD})){
        //If the Route by ID routing is used, bytes 8 and 9 form a 16-bit field for the destination ID. otherwise these bytes are Reserved.
        soft m_tlp_completer_id.bus_num == msg_destination_id_rsvd;
        soft m_tlp_completer_id.device_num == msg_destination_id_rsvd;
        soft m_tlp_completer_id.function_num == msg_destination_id_rsvd;
      } else {
        soft m_tlp_completer_id.bus_num == m_pcie_link_cfg.dsp_dev_config.m_req_id.bus_num;
        soft m_tlp_completer_id.device_num == m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num;
        soft m_tlp_completer_id.function_num == m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num;
      }
    }
    //solve m_tlp_msg_rout_type before m_tlp_completer_id;
    //solve m_tlp_trans_type before m_tlp_completer_id;
  }

  //TODO constraint c_type1_stream_id {
  //TODO   if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
  //TODO     if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1}) && m_ide_prefix_present) {
  //TODO       m_stream_id     == m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_stream_id;
  //TODO       m_stream_id_int == m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_stream_id;
  //TODO     }
  //TODO   }
  //TODO }
  // Enable this based on legacy device type
  //--------------------------------------------------------------------------
  // Constraint: c_type1_cfg
  // This Constraint will enable this based on legacy device type
  //--------------------------------------------------------------------------
  constraint c_type1_cfg {
    if(!m_pcie_dev_cfg.bypass_dut_type_chk){
      if(m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_en && m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE && m_ide_prefix_present){
	 	    m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1};
      }  
     // if(m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_en && m_ide_prefix_present) {
     //   (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1});
     // }
      /*if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1} && m_ide_prefix_present) {
        m_stream_id ==m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_stream_id;
      
       //{
       //   if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].is_RID_inside_range(
       //     { m_pcie_link_cfg.usp_dev_config.m_req_id.bus_num, m_pcie_link_cfg.usp_dev_config.m_req_id.device_num, m_pcie_link_cfg.usp_dev_config.m_req_id.function_num }
       //   )) m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1};
       //}
      }*/
      else if (m_pcie_dev_top_cfg.send_sbsa_cfg_type_1 || (m_pcie_dev_top_cfg.i_cfg.strap_port_type inside {2,3})) {
        if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) && (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP)) {
          (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1,CDN_HPA_PCIE_TLP_TYPE_CfgRd0, CDN_HPA_PCIE_TLP_TYPE_CfgWr0});
          cfg_type1_target_pri                             -> (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1});
          cfg_type0_target_pri                             -> (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd0, CDN_HPA_PCIE_TLP_TYPE_CfgWr0});
          cfg_type1_target_sec                             -> (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1});
          cfg_type1_target_sec_non_zero_dev_ari_dis        -> (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1});
          cfg_type1_target_pri_wrong_dev_fun               -> (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1});
          cfg_type1_target_more_than_sec_less_equal_to_sub -> (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1});
          cfg_type1_target_more_than_sub                   -> (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1});
        }
      }
      else {
        type1_dev == m_pcie_dev_cfg.is_legacy_device;

        type1_dev && m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE
        -> { m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_CfgRd0; m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_CfgWr0;}
        if(!m_pcie_dev_top_cfg.scenario.m_pxc_shadow_reg_mb_test){
        !type1_dev && m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE
        -> { m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_CfgRd1; m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_CfgWr1;}
        }
      }
      solve type1_dev before m_tlp_type;
    }
  }

  //ATS is not supported AT bits should be zero
  //--------------------------------------------------------------------------
  // Constraint: c_default_ats
  // This Constraint will check if  ATS is not supported AT bits should be zero
  //--------------------------------------------------------------------------
  constraint c_default_ats {
    if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
      if(m_pcie_dev_cfg.m_cap_ats_en == 0){m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated;} // TODO Need to remove generation logic

      `ifndef HLS_BRIDGE_MODULE
        // EP sends the translation request
        if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP){m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated;}
      `endif
      soft m_tlp_at_type != CDN_HPA_PCIE_AT_Reserved;
      //if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_MRd_32:CDN_HPA_PCIE_TLP_TYPE_MWr_64],CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64})) {m_tlp_at_type== CDN_HPA_PCIE_AT_Untranslated;}
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)) {m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated;}
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && !(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64})) {m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request;}
    }

    // sending a Translation Request as a UIO Memory Read is not allowed by the spec
    if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr}) {m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request;}

    //VIP issue fixed: BFM throws error when no_write bit is set in TR req. Making zero, Revisit this later
    //TL_TLP_MF_vlRsvMAddr [PCISIG-TXN.2.0#2].  Erroneous TLP - Non-0 Reserved bits(s), Address[1:0], in Memory Request TLP
    //soft m_tlp_ats_tr_nw_field == 0;
    (m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request) ->  soft m_tlp_ats_tr_nw_field==0;
    
    `ifndef HLS_MODULE_MODE
      // TODO - Temporary VIP workaround to avoid reports of: Detected (TX) [FATAL-MalformedTlp] TL_ATS_TRANSLATIONREQUEST_NW_FLAG_CLEAR
      // Because ATS is not fully supported at Flit Mode. Revisit after VIPSR 46767691 is fixed.
      (is_flit_mode && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) ->  soft m_tlp_ats_tr_nw_field==1;
    `endif

    (!cxl_mode || (m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request)) ->   m_cxl_src==0;

  }

  //Only DSP can send MRdLk TLPs
  //--------------------------------------------------------------------------
  // Constraint: c_MrdLk_dsp
  // This Constraint will set Only DSP can send MRdLk TLPs
  //--------------------------------------------------------------------------
  constraint c_MrdLk_dsp {
    if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP){!(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64});}
    }
    if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64}) {
      m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated;
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_default_attr
  // This Constraint will generate the default attribute for ordering and snooping
  //--------------------------------------------------------------------------
  constraint c_default_attr {
    // Attr[2] - ID based ordering
    if((m_pcie_dev_cfg.m_ido_req_en == 0) && (m_tlp_req_type != CDN_HPA_PCIE_TRANS_COMPLETION)) {m_tlp_attr1 == 0;}
    // Attr[1] - Relaxed ordering
    if((m_pcie_dev_cfg.m_relax_ordering_en == 0) && (m_tlp_req_type != CDN_HPA_PCIE_TRANS_COMPLETION)) {m_tlp_attr0[1] == 0;}
    // Attr[0] - No Snoop attribute
    if((m_pcie_dev_cfg.m_no_snoop_en == 0) && (m_tlp_req_type != CDN_HPA_PCIE_TRANS_COMPLETION)) {m_tlp_attr0[0] == 0;}
  }

  //--------------------------------------------------------------------------
  // Constraint: c_td_constr
  // ECRC Gen should be enabled to set TD
  // Behavior is like the legacy controller. It is an OR of the following
  // 1)  ECRC generation bit is set in AER
  // 2)  TD bit is set in ob -TLP
  // In both cases, TD bit is set and ECRC is inserted
  // But Don't make td=1, when k_wire is disabled
  //--------------------------------------------------------------------------

  `ifndef HPA_ARCH2
    constraint c_td_constr {
      if(m_pcie_dev_cfg.m_ecrc_gen_en == 0) {m_tlp_td == 0;}
      if(m_ide_prefix_present == 1) {m_tlp_td == 0;}
    }
  `else
    constraint c_td_constr {
      //TODO can TD be 1/TS indicate 1DW_ECRC_TRAILER even when ecrc_gen_en=1 ?
      if(m_ide_prefix_present == 1) {
        m_tlp_td == 0;
      }
      `ifndef TL_RX_MODULE_MODE // Require TD to be random
        else if(m_pcie_dev_cfg.m_ecrc_gen_en && m_pcie_dev_top_cfg.ecrc_init_done) {
          m_tlp_td == 1;
        }
        else {
          m_tlp_td == 0;
        }
      `endif
    }
  `endif
  //--------------------------------------------------------------------------
  // Constraint: c_ats_attr_constr
  // This Constraint generates address translation services attributes
  //--------------------------------------------------------------------------
  constraint c_ats_attr_constr {
    if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_MRd_32:CDN_HPA_PCIE_TLP_TYPE_MWr_64]}
      && (m_tlp_at_type==CDN_HPA_PCIE_AT_Translation_Request)){
        m_tlp_attr0[0] == 0;
        (!m_pcie_dev_cfg.m_ats_ro_bit_support) -> m_tlp_attr0[1] == 0;
        //CB 6.1 this is not required.
        //Comment this after VIP: Case #46818973
        m_tlp_attr1 == 0;
      }
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_uio_attr_constr
  // This Constraint set IDO and RO attributes for UIO to 0
  // [spec]: Attr[2:1], corresponding to IDO and RO in non-UIO Memory Requests, are Reserved
  //--------------------------------------------------------------------------
  constraint c_uio_attr_constr {
    if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr}) {
      m_tlp_attr0[1] == 0;
      m_tlp_attr1    == 0;
    }
  }

  // Completion(CPL) constraints
  //--------------------------------------------------------------------------
  // Constraint: c_cpl_status
  // This Constraint generates completion status
  //--------------------------------------------------------------------------
  constraint c_cpl_status {
    m_tlp_cpl_status inside {[CDN_HPA_PCIE_CPL_SC : CDN_HPA_PCIE_CPL_CRS], CDN_HPA_PCIE_CPL_ABORT};
    soft rsvd_cpl_status == 0;
    //cfg tlp can have CRS status and DMWR will have RRS response
    if((m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CFG_TYPE && (m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_DMWr_32 || m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_DMWr_64))) {m_tlp_cpl_status != CDN_HPA_PCIE_CPL_CRS;}
    if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) {soft m_tlp_cpl_status==CDN_HPA_PCIE_CPL_SC;} //CPLD should be SUCCESS status
  }

  //--------------------------------------------------------------------------
  // Constraint: c_invalid_cpl_status
  // This Constraint generates invalid completion status
  //--------------------------------------------------------------------------
  constraint c_invalid_cpl_status {
    rsvd_cpl_status == 1 -> m_tlp_cpl_status inside{CDN_HPA_PCIE_CPL_RSVD3, [CDN_HPA_PCIE_CPL_RSVD5 : CDN_HPA_PCIE_CPL_RSVD7]};
  }

  //--------------------------------------------------------------------------
  // Constraint: c_bcm
  // This Constraint sets bcm to 0
  //--------------------------------------------------------------------------
  constraint c_bcm {
    m_tlp_cpl_bcm == 0;
  }

  // TH bit is reserved and AT[1:0] must be zero
  //--------------------------------------------------------------------------
  // Constraint: c_cpl_at
  // This Constraint will set that  if  TH bit is reserved and AT[1:0] must be zero
  //--------------------------------------------------------------------------
  constraint c_cpl_at {
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) {
      m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated;
      m_tlp_th == 0;
    }
  }

  // Added soft constraint to support for EI
  //--------------------------------------------------------------------------
  // Constraint: c_cpl_rules
  // This Constraint will genrate the completion rules
  // Added soft constarint to support EI
  //--------------------------------------------------------------------------
  constraint c_cpl_rules {
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) {
      if(m_pcie_dev_cfg.m_ido_cpl_en){
        m_tlp_attr1 inside {[0:1]};
      }
      else {
        if(np_req_tlp != null) {
          m_tlp_attr1 == np_req_tlp.m_tlp_attr1;
          m_tlp_attr0 == np_req_tlp.m_tlp_attr0;
        }
        else {  /// When CPL generated randomly without request and ido_cpl_en=0
          m_tlp_attr1 == 0;
        }
      }
      if(np_req_tlp != null) {
        soft if(m_pcie_dev_cfg.m_cap_completer_ln ==1  && np_req_tlp.m_tlp_ln ==1){ m_tlp_ln == 1;}
        soft m_tlp_tag == np_req_tlp.m_tlp_tag;
        soft m_tlp_tc == np_req_tlp.m_tlp_tc;
      }
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_cfg_blocking
  // This Constraint defines default value of these parameters, if not pass
  // from sequence
  //--------------------------------------------------------------------------
  constraint c_cfg_blocking {
    soft is_blocking == 0;
    soft unique_id == 0;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_is_mem_rd
  // This Constraint will generate the memory read for normal and legacy devices
  // for 32 and 64 bits.
  //--------------------------------------------------------------------------
  constraint c_is_mem_rd {
    is_mem_read == 1 -> {
      ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)
      ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)
    )};
  }
  //--------------------------------------------------------------------------
  // Constraint: c_cpl_byte_cnt
  // This Constraint will set the completion byte count based on the config read request size
  //--------------------------------------------------------------------------

  constraint c_cpl_byte_cnt {
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) {
      if(m_pcie_dev_top_cfg.get_min_rrs_in_bytes() == 4096){
        m_tlp_cpl_byte_cnt inside {[0: m_pcie_dev_top_cfg.get_min_rrs_in_bytes()-1]};
      }
      else {
        m_tlp_cpl_byte_cnt inside {[1: m_pcie_dev_top_cfg.get_min_rrs_in_bytes()-1]};
      }
      if(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl && m_tlp_cpl_status == CDN_HPA_PCIE_CPL_SC) {
        m_tlp_cpl_byte_cnt == 4;
      }
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_cpl_cdl
  // This Constraint generates CDL field values that is used by CXL
  // PCIe controller is ignoring this data.
  //--------------------------------------------------------------------------
  constraint c_cpl_cdl {
    m_tlp_cpl_cdl inside {[2'b00:2'b11]};
  }

  //--------------------------------------------------------------------------
  // Constraint: c_poisoned_tlp
  // This Constraint generates poised tlp for error injection
  //--------------------------------------------------------------------------
  constraint c_poisoned_tlp {
    if(!m_pcie_dev_cfg.bypass_dut_type_chk) {
      soft m_tlp_ep == 0;
      if (!(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
      CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,
      CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
      CDN_HPA_PCIE_TLP_TYPE_IOWr,CDN_HPA_PCIE_TLP_TYPE_MsgD,
      CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
      CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
      CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
      CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64})) {m_tlp_ep == 0;}
    }
  }

  // !!!!!!!!!!!!!!!!!TODO!!!!!!!!!!!!!!!!!
  // HPA2 RTL supports local prefixes but need to consider them based on CXL negotiated device type
  //`ifdef HPA_ARCH2
  //  //`ifdef CXL_CFG
  //    constraint c_cxl_ldid_issue_temp_constr{
  //      m_local_prefix_possible == 0;
  //    }
  //  //`endif
  //`endif

  //PBR: PTH Constraints
  //--------------------------------------------------------------------------
  // Constraint: c_pbr_tlp_hdr_constr
  // This Constraint generates PTH possibility (CXL Spec 3.1.8)
  //--------------------------------------------------------------------------
  constraint c_pbr_tlp_hdr_constr {
    //PTH valid in FM

    if(is_cxl_pbr_mode) {
      m_tlp_pth_spid == m_pcie_dev_top_cfg.cxl_pth_spid;
      m_tlp_pth_dpid == m_pcie_dev_top_cfg.cxl_pth_dpid;
      m_tlp_pth_rsvd == 0; //VIPSR#46800202
      m_tlp_pbr_tlp_header == {2'b11, m_tlp_pth_rsvd, m_tlp_pth_hie, m_tlp_pth_dsar, m_tlp_pth_pif, m_tlp_pth_spid, m_tlp_pth_dpid};
    }
    else {
      m_tlp_pbr_tlp_header == 0;
      m_tlp_pth_hie        == 0;
      m_tlp_pth_dsar       == 0;
      m_tlp_pth_pif        == 0;
      m_tlp_pth_spid       == 0;
      m_tlp_pth_dpid       == 0;
      m_tlp_pth_rsvd       == 0;
    }

    solve m_tlp_pth_rsvd, m_tlp_pth_hie, m_tlp_pth_dsar, m_tlp_pth_pif, m_tlp_pth_spid, m_tlp_pth_dpid before m_tlp_pbr_tlp_header;
  }


  //Prefix constraints
  //--------------------------------------------------------------------------
  // Constraint: c_tph_possibility_constr
  // This Constraint generates tph possibility
  //--------------------------------------------------------------------------
  constraint c_tph_possibility_constr{
    //seq_item.randomize() will generate PASID/TPH/EXT_TPH based on dev capability and
    //other end capability and based on packet type.

    solve m_ext_tph_prefix_possible before m_ext_tph_prefix_present;
    solve m_pasid_prefix_possible, cxl_io_tlp before m_pasid_prefix_present;
    solve m_tph_possible before m_tph_present;

    solve m_tlp_trans_type, m_tlp_at_type before m_tph_possible;
    solve m_tlp_trans_type, m_tlp_at_type before m_ext_tph_prefix_possible;
    solve m_tlp_trans_type, m_tlp_at_type, m_tlp_msg_code before m_pasid_prefix_possible;

    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) {
      if(!is_flit_mode)  { //FM don't have restriction based on max_e2e field (Other than OHC-E, which is taken seperately)
        m_max_no_of_prefixes <= ((m_pcie_link_cfg.usp_dev_config.m_max_e2e_support ==0) ? 'd4 : m_pcie_link_cfg.usp_dev_config.m_max_e2e_support);
        m_max_no_of_prefixes <= ((m_pcie_dev_cfg.m_max_e2e_support ==0) ? 'd4 : m_pcie_dev_cfg.m_max_e2e_support);
      }
      if(
        (m_pcie_dev_cfg.m_tph_req_en inside {CDN_HPA_PCIE_TPH_REQ_SUPPORTED,CDN_HPA_PCIE_TPH_AND_EXT_TPH_REQ_SUPPORTED}) &&
        (m_pcie_link_cfg.usp_dev_config.m_tph_cpl_support inside {CDN_HPA_PCIE_TPH_CPL_SUPPORTED,CDN_HPA_PCIE_TPH_AND_EXT_TPH_CPL_SUPPORTED}) &&
        (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)
      ){
         m_tph_possible ==1;
      } else {
         m_tph_possible ==0;
      }

      //FOr flit mode m_e2e_tlp_prefix_support doesn't guard from generation of pasid/tph prefixes
      if(
        (m_pcie_dev_cfg.m_tph_req_en inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_REQ_SUPPORTED}) &&
        (m_pcie_link_cfg.usp_dev_config.m_tph_cpl_support inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_CPL_SUPPORTED}) &&
        (m_pcie_link_cfg.usp_dev_config.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) &&
        (m_pcie_link_cfg.usp_dev_config.m_ext_fmt_field_support ==1 ) &&
        (m_pcie_dev_cfg.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) &&
        (m_pcie_dev_cfg.m_ext_fmt_field_support ==1 ) &&
        (m_pcie_dev_cfg.m_ext_tph_req_supp ==1 ) &&
        (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)
      ){
         m_ext_tph_prefix_possible ==1;
      } else {
         m_ext_tph_prefix_possible ==0;
      }

      if(
        (((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (m_tlp_at_type != CDN_HPA_PCIE_AT_Translated)) ||
        ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response} &&
        (m_pcie_link_cfg.usp_dev_config.m_cap_ats_en ==1 || m_pcie_dev_cfg.bypass_prefix_cfgs)))) &&
        (m_pcie_link_cfg.usp_dev_config.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) && //Other end should have e2e_prefix support
        (m_pcie_link_cfg.usp_dev_config.m_ext_fmt_field_support ==1 ) &&
        (m_pcie_dev_cfg.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) &&
        (m_pcie_dev_cfg.m_ext_fmt_field_support ==1 ) &&
        (m_pcie_link_cfg.usp_dev_config.m_pasid_enb ==1 ) //EP Device should have PASID Enabled
      ) {
         m_pasid_prefix_possible == 1;
      } else {
         m_pasid_prefix_possible == 0;
      }
    } else { //m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP
      if(!is_flit_mode)  { //FM don't have restriction based on max_e2e field (Other than OHC-E, which is taken seperately)
        m_max_no_of_prefixes <= ((m_pcie_link_cfg.dsp_dev_config.m_max_e2e_support ==0) ? 'd4 : m_pcie_link_cfg.dsp_dev_config.m_max_e2e_support);
        m_max_no_of_prefixes <= ((m_pcie_dev_cfg.m_max_e2e_support ==0) ? 'd4 : m_pcie_dev_cfg.m_max_e2e_support);
      }
      if(
        (m_pcie_dev_cfg.m_tph_req_en inside {CDN_HPA_PCIE_TPH_REQ_SUPPORTED,CDN_HPA_PCIE_TPH_AND_EXT_TPH_REQ_SUPPORTED}) &&
        (m_pcie_link_cfg.dsp_dev_config.m_tph_cpl_support inside {CDN_HPA_PCIE_TPH_CPL_SUPPORTED,CDN_HPA_PCIE_TPH_AND_EXT_TPH_CPL_SUPPORTED}) &&
        ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request))
      ){
        m_tph_possible ==1;
      } else {
        m_tph_possible ==0;
      }

      if(
        (m_pcie_dev_cfg.m_tph_req_en inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_REQ_SUPPORTED}) &&
        (m_pcie_link_cfg.dsp_dev_config.m_tph_cpl_support inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_CPL_SUPPORTED}) &&
        (m_pcie_link_cfg.dsp_dev_config.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) &&
        (m_pcie_link_cfg.dsp_dev_config.m_ext_fmt_field_support ==1 ) &&
        (m_pcie_dev_cfg.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) &&
        (m_pcie_dev_cfg.m_ext_fmt_field_support ==1 ) &&
        (m_pcie_dev_cfg.m_ext_tph_req_supp ==1 ) &&
        ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request))
      ){
        m_ext_tph_prefix_possible ==1;
      } else {
        m_ext_tph_prefix_possible ==0;
      }

      if(
        (((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) &&
        ((m_tlp_at_type != CDN_HPA_PCIE_AT_Translated) || (m_tlp_at_type == CDN_HPA_PCIE_AT_Translated && m_pcie_dev_cfg.m_translated_req_with_pasid_enb))) ||
        ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response} &&
        (m_pcie_dev_cfg.m_cap_ats_en ==1 || m_pcie_dev_cfg.bypass_prefix_cfgs)))) &&
        (m_pcie_link_cfg.dsp_dev_config.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) && //Other end should have e2e_prefix support
        (m_pcie_link_cfg.dsp_dev_config.m_ext_fmt_field_support ==1 ) &&
        (m_pcie_dev_cfg.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) &&
        (m_pcie_dev_cfg.m_ext_fmt_field_support ==1 ) &&
        (m_pcie_dev_cfg.m_pasid_enb ==1 ) //EP Device should have PASID Enabled
      ) {
        m_pasid_prefix_possible == 1;
      } else {
        m_pasid_prefix_possible == 0;
      }
    }

    //Temporary constarints to enable a single type of prefix
    //m_max_no_of_prefixes inside {[0:(m_pasid_prefix_possible)]};
    //m_ext_tph_prefix_present == 0;
    //m_max_no_of_prefixes inside {[0:(m_ext_tph_prefix_possible)]};
    //m_pasid_prefix_present== 0;

    m_max_no_of_prefixes inside {[0:(m_pasid_prefix_possible + m_ext_tph_prefix_possible + m_ide_prefix_present)]};
    m_max_no_of_prefixes == ((m_ext_tph_prefix_present || m_ama_valid) + m_pasid_prefix_present + m_ide_prefix_present);
    (m_ext_tph_prefix_possible == 0) -> m_ext_tph_prefix_present==0;
    `ifdef IDE_REF_TLP
      m_pasid_prefix_present==0;
    `else
      (m_pasid_prefix_possible == 0) -> m_pasid_prefix_present==0;
    `endif
    cxl_io_tlp -> m_pasid_prefix_present==0;
    (m_tph_possible == 0) -> m_tph_present==0;
    m_tlp_prefix.size() == m_max_no_of_prefixes - m_ide_prefix_present;
    m_hdr_fmt_prefix.size() == m_max_no_of_prefixes - m_ide_prefix_present;
    m_hdr_type_prefix.size() == m_max_no_of_prefixes - m_ide_prefix_present;

    //Local prefix
    if(hpa_generation == hpa_generation_2) {
      if(m_pcie_dev_cfg.bypass_prefix_cfgs && is_flit_mode)
      m_max_no_of_local_prefixes inside {[0:2]}; //Total 2 Local prefixes possible (1 Flit-mode Local prefix + 1 VendPrefix)
      else
      m_max_no_of_local_prefixes inside {[0:1]}; //NFM: Total 3 prefixes possible (2 E2E + 1Local prefix), FM: Max 1 VendPrefix possible
    } else{
      m_max_no_of_local_prefixes==0; //2 E2E prefixes are supported
    }
    if (!m_pcie_dev_cfg.bypass_prefix_cfgs && m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[0] && cxl_ldid_prefix && cxl_mode){
      m_local_prefix_possible==1;
      m_max_no_of_local_prefixes==1;
    }
    //if (!m_pcie_dev_cfg.bypass_prefix_cfgs && m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[0] && !cxl_ldid_prefix && cxl_mode){
    //  m_local_prefix_possible==0;
    //  m_max_no_of_local_prefixes==0;
    //}
    else {
      (!m_pcie_dev_cfg.bypass_prefix_cfgs &&
      (!m_pcie_link_cfg.dsp_dev_config.m_ext_fmt_field_support ||
      !m_pcie_link_cfg.usp_dev_config.m_ext_fmt_field_support ||
      m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support == 0)) -> m_local_prefix_possible==0;
    }

    `ifdef HLS_MODULE_MODE
      (!m_pcie_link_cfg.dsp_dev_config.m_ext_fmt_field_support ||
      !m_pcie_link_cfg.usp_dev_config.m_ext_fmt_field_support ||
      m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support == 0) -> m_local_prefix_possible==0;
    `endif

    (!is_flit_mode) -> m_flit_mode_local_prefix_possible == 0;

    // Client should not generate by default. Will be controlled from module sequence
    soft m_flit_mode_local_prefix_possible == 0;

    m_max_no_of_local_prefixes == m_local_prefix_possible + m_flit_mode_local_prefix_possible;

    `ifdef IDE_REF_TLP
      m_max_no_of_local_prefixes == 0;
    `endif

    m_tlp_local_prefix.size() == m_max_no_of_local_prefixes;
    m_tlp_local_prefix_data.size() == m_max_no_of_local_prefixes;
    m_hdr_fmt_local_prefix.size() == m_max_no_of_local_prefixes;
    m_hdr_type_local_prefix.size() == m_max_no_of_local_prefixes;


    `ifndef HLS_BRIDGE_MODULE
    if(m_tlp_local_prefix.size() > 1) { // Both FM Local Prefix & VendPrefix possible
      // Interchanged order of packing local prefixes
      if(m_flit_mode_local_prefix_as_first_prefix) {
        // Pack FM Local Prefix first
        m_hdr_type_local_prefix[0] == CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX;
        m_tlp_local_prefix_data[0] == {m_tlp_uses_dedicated_credits, 23'b0};
        (!m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[0]) -> m_hdr_type_local_prefix[1] != CDN_HPA_PCIE_VEND_PREFIX_L0;
        (!m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[1]) -> m_hdr_type_local_prefix[1] != CDN_HPA_PCIE_VEND_PREFIX_L1;
        m_hdr_type_local_prefix[1] != CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX;
      } else {
        // Pack VendPrefix first
        (!m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[0]) -> m_hdr_type_local_prefix[0] != CDN_HPA_PCIE_VEND_PREFIX_L0;
        (!m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[1]) -> m_hdr_type_local_prefix[0] != CDN_HPA_PCIE_VEND_PREFIX_L1;
        m_hdr_type_local_prefix[0] != CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX; //client should not generate
        m_hdr_type_local_prefix[1] == CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX;
        m_tlp_local_prefix_data[1] == {m_tlp_uses_dedicated_credits, 23'b0};
      }
    } else if(m_tlp_local_prefix.size() == 1) {
      if(m_local_prefix_possible) {
        (!m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[0]) -> m_hdr_type_local_prefix[0] != CDN_HPA_PCIE_VEND_PREFIX_L0;
        (!m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[1]) -> m_hdr_type_local_prefix[0] != CDN_HPA_PCIE_VEND_PREFIX_L1;
        m_hdr_type_local_prefix[0] != CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX;
        (m_pcie_dev_top_cfg.i_cfg.k_vendor_prefix_local_support[0] && cxl_ldid_prefix) -> { m_hdr_type_local_prefix[0] == CDN_HPA_PCIE_VEND_PREFIX_L0;
        m_tlp_local_prefix_data[0] == {m_cxl_ldid,8'd0};}
      } else if(m_flit_mode_local_prefix_possible) {
        m_hdr_type_local_prefix[0] == CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX;
        m_tlp_local_prefix_data[0] == {m_tlp_uses_dedicated_credits, 23'b0};
      }
    }
    `endif // not HLS_BRIDGE_MODULE

    solve m_pasid_prefix_possible before  m_max_no_of_prefixes;
    solve m_ext_tph_prefix_possible before  m_max_no_of_prefixes;
    solve m_ama_valid before m_max_no_of_prefixes;
    solve m_max_no_of_prefixes before m_tlp_prefix;

    solve m_max_no_of_local_prefixes before m_tlp_local_prefix,m_hdr_fmt_local_prefix,m_hdr_type_local_prefix,m_tlp_local_prefix_data;
    solve m_local_prefix_possible, m_flit_mode_local_prefix_possible before m_max_no_of_local_prefixes;
    solve m_tlp_uses_dedicated_credits before m_tlp_local_prefix_data;

  }

  //--------------------------------------------------------------------------
  // Constraint: c_tlp_uses_dedicated_credits
  // This bit indicates TLP uses dedicated credits.
  //--------------------------------------------------------------------------
  constraint c_tlp_uses_dedicated_credits {
    if(m_flit_mode_local_prefix_possible) {
      m_tlp_uses_dedicated_credits dist {1'b0:=60, 1'b1:=40};
    } else {
      m_tlp_uses_dedicated_credits == 1'b0;
    }
  }

  //--------------------------------------------------------------------------
  // Constraint: c_local_prefix
  // This Constraint forms the Local prefix(es)
  //--------------------------------------------------------------------------
  constraint c_local_prefix {
    foreach( m_tlp_local_prefix[i]) {
      m_hdr_fmt_local_prefix[i] == CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
      m_tlp_local_prefix[i] == {m_hdr_fmt_local_prefix[i],m_hdr_type_local_prefix[i],m_tlp_local_prefix_data[i]};
    }
  }
//TODO For NFM to FM
  //--------------------------------------------------------------------------
  // Constraint: c_pxc_no_local_prefix
  // In NFM->FM test mode (KMAX_FLIT_MODE_SUPPORT==0), the TB sends FM-encoded
  // TLPs on the HLS CXS bus.  A Local TLP Prefix embedded in m_data causes
  // CXS 8-byte alignment gaps (ERR043) when multiple packets share one flit,
  // leading to DL_TLP_CRC_BAD at the PCIe endpoint.
  // Hard-force m_max_no_of_local_prefixes==0 to prevent prefix generation.
  //--------------------------------------------------------------------------
`ifdef PXC
  constraint c_pxc_no_local_prefix {
    if (parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 0) {
      m_max_no_of_local_prefixes  == 0;
      m_local_prefix_possible     == 0;
    }
  }
`endif

  constraint c_use_user_stream_id {
    soft use_user_defined_stream_id==0;
  }

  constraint c_complete_aggr {
    if (m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) {
      m_complete_aggregate == 1;
    }
  }

  constraint c_ide_prefix_possibility {
    solve m_tlp_tc_has_active_ide_stream before m_ide_prefix_possible;
    solve m_ide_prefix_possible before m_ide_prefix_present;
    solve m_tlp_tc before m_ide_prefix_present,m_stream_id_int;
    solve m_stream_id_int before m_ide_prefix_present,m_stream_id;
    solve m_sel_stream_possible,use_user_defined_stream_id before m_tlp_tc,m_stream_id_int;

    //PCIE Spec: 11.4.10
    //TEE-I/O capable devices that support ATS and have ATS enabled must generate translation requests and page requests
    //for a TDI in RUN state with T bit Set.
    //ATS Translated Read or Write Requests must only be issued by the TDI while in RUN, and must Set the T bit. Completions
    //for ATS Translated Read Requests issued by the TDI while in RUN are permitted to be be received with the T bit Set or
    //Clear.
    `ifndef HLS_MODULE_MODE
    if (m_pcie_dev_top_cfg.scenario != null) {
      if ((parameters_cfg_pkg::KMAX_TDISP_SUPPORT == 2) && m_pcie_dev_top_cfg.ide_init_done && parameters_cfg_pkg::KMAX_DTI_SUPPORT && parameters_cfg_pkg::KMAX_IDE_SUPPORT && (m_pcie_dev_top_cfg.non_ide_traffic_test != 1)) {
        if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MWr_64)) {
          if ((m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) || (m_tlp_at_type == CDN_HPA_PCIE_AT_Translated) ) {
            m_ide_prefix_present == 1;
            m_ide_t == 1;

            //if ((m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request))
            //  m_tlp_tc == 0;
          }
        }

        else if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request})) {
          m_ide_prefix_present == 1;
          m_ide_t == 1;
          m_tlp_tc == 0;
          //m_tlp_tc == m_pcie_dev_top_cfg.ide_cfg.find_tc_to_map_selective_stream();
        }
        else {
          
          // foreach(link_stream_id_tc_map[tc]) {
          //
          // }
        }

      }
    }
    `endif

    //IDE Prefix Possibility
    // variable needed to be considered
    // 1. m_tlp_tc -> randomize freely
    // 2. is m_tlp_tc associated with (any link stream && link stream enabled) or (selective stream && selective stream enabled)

    //IDE configuration usage is limited in module level, so bypassing the condition for IDE prefix possible
    (!m_pcie_dev_top_cfg.i_cfg.k_ide_supported) -> (m_ide_prefix_possible == 0);
    `ifdef TOP_LEVEL_SIMS
      ((!m_tlp_tc_has_active_ide_stream) || (!m_pcie_dev_top_cfg.ide_init_done)) -> (m_ide_prefix_possible == 0);
    `endif

    if(m_pcie_dev_top_cfg.non_ide_traffic_test == 1) m_ide_prefix_possible == 0;
    else if(m_pcie_dev_top_cfg.i_cfg.k_ide_supported && m_pcie_dev_top_cfg.ide_init_done &&
    (m_pcie_link_cfg.dsp_dev_config.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) &&
    (m_pcie_link_cfg.usp_dev_config.m_e2e_tlp_prefix_support ==1 || is_flit_mode ) &&
    (m_pcie_link_cfg.dsp_dev_config.m_ext_fmt_field_support ==1 ) &&
    (m_pcie_link_cfg.usp_dev_config.m_ext_fmt_field_support ==1 ) &&
    (m_tlp_tc_has_active_ide_stream || m_pcie_dev_cfg.bypass_prefix_cfgs)) {
      m_ide_prefix_possible == 1;
    } else {
      `ifdef HLS_MODULE_MODE
        m_ide_prefix_possible == 0;
        `elsif TOP_LEVEL_SIMS
        m_ide_prefix_possible == 0;
      `else
        soft m_ide_prefix_possible == 0;
      `endif
    }
    (m_ide_prefix_possible == 0) -> m_ide_prefix_present == 0;

    `ifdef TOP_LEVEL_SIMS
      if(!use_user_defined_stream_id) {
        m_stream_id_int == m_pcie_dev_top_cfg.ide_cfg.find_stream_id_mapped_to_tc(m_tlp_tc, m_sel_stream_possible);
      }
      m_stream_id == ((m_stream_id_int != -1) ? m_stream_id_int : 0);
      m_pr_sent_counter == 0;
      (m_stream_id_int == -1) -> m_ide_prefix_present == 0;
      if((m_stream_id_int != -1) && (m_ide_prefix_possible == 1)) {
        m_ide_prefix_present == (m_pcie_dev_top_cfg.ide_cfg.force_non_ide_tlp == 0);
      }
    `else
      `ifdef HLS_MODULE_MODE
        if(!use_user_defined_stream_id) {
          m_stream_id_int == m_pcie_dev_top_cfg.ide_cfg.find_stream_id_mapped_to_tc(m_tlp_tc, m_sel_stream_possible);
        }
        if(m_stream_id_int != -1) m_stream_id == m_stream_id_int;
        else m_stream_id == 0;
        m_pr_sent_counter == 0;
        (m_stream_id_int == -1) -> m_ide_prefix_present == 0;
        if(m_stream_id_int != -1 && m_ide_prefix_possible == 1) {
          (m_pcie_dev_top_cfg.ide_cfg.force_non_ide_tlp == 1) -> m_ide_prefix_present == 0;
          (m_pcie_dev_top_cfg.ide_cfg.force_non_ide_tlp == 0) -> m_ide_prefix_present == 1;
        }
      `else
        //module teams needs this random
        (m_ide_prefix_possible == 1) -> soft m_ide_prefix_present == 1;
      `endif
    `endif
  }

constraint c_valid_ide_prefix {
    solve m_tlp_tc_has_active_ide_stream before m_ide_prefix_possible;
    solve m_ide_prefix_present before m_max_no_of_prefixes;
    solve m_tlp_tc before m_stream_id;
    solve m_ide_prefix_present before m_ide_tlp_prefix, m_ide_hdr_fmt_prefix, m_ide_hdr_type_prefix, m_pr_sent_counter, m_sub_stream;

    //Adding IDE Prefix, based on m_max_no_prefixes
    //IDE prefix formation is not required when the TLP is driven from VIP BFM, hence different variable for IDE prefix
    //BFM frames the IDE prefix and appends it to the TLP based on TC if it is mapped to any of the streams
    if(m_ide_prefix_present) {
      m_ide_hdr_fmt_prefix == CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
      m_ide_hdr_type_prefix == 5'b10010;
      m_ide_tlp_prefix == {m_ide_hdr_fmt_prefix, m_ide_hdr_type_prefix, m_pr_sent_counter, m_stream_id, m_sub_stream, m_ide_p, m_ide_m, m_ide_k, m_ide_t};
    }
    else {
      soft m_ide_hdr_fmt_prefix == 0;
      soft m_ide_hdr_type_prefix == 0;
      soft m_ide_tlp_prefix == 'h0;
    }

    if (!m_ide_prefix_present) {
      if (is_flit_mode) {
        m_sub_stream == 4'h7;
      }
      else {
        m_sub_stream == 4'h0;
      }
    } else if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64, CDN_HPA_PCIE_TLP_TYPE_Msg, CDN_HPA_PCIE_TLP_TYPE_MsgD, CDN_HPA_PCIE_TLP_TYPE_UIOMWr}) {
      m_sub_stream == 4'h0;
    } else if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl,CDN_HPA_PCIE_TLP_TYPE_CplD, CDN_HPA_PCIE_TLP_TYPE_CplLk,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
    CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) {
      m_sub_stream == 4'h2;
    } else {
      m_sub_stream == 4'h1;
    }
  }

  constraint c_valid_ide_pmkt_bits {
    //solve m_ide_prefix_present before m_ide_p, m_ide_m, m_ide_k, m_ide_t;
    //solve m_stream_id before m_ide_p, m_ide_m, m_ide_t;
    solve m_ide_prefix_present, m_stream_id before m_ide_p, m_ide_m, m_ide_k, m_ide_t;

    if(m_ide_prefix_present) {
      `ifdef TOP_LEVEL_SIMS
        !(m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) -> m_ide_m == 1;
        !(m_pcie_dev_top_cfg.ide_cfg.m_pcrc_supp) -> m_ide_p == 0;
        if(m_pcie_dev_top_cfg.ide_cfg.m_pcrc_supp) {
          if(!m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) {
            if(m_tlp_payload.size() == 0) { m_ide_p == 0; }
            else {
              //TODO: why this 2 foreach?? first identify link/sel stream. Accordingly, if((link_stream&& m_pcie_dev_top_cfg.ide_cfg.link_ide_pcrc_enable[m_stream_id]) || (!link_stream && (m_pcie_dev_top_cfg.ide_cfg.link_ide_pcrc_enable[m_stream_id])) { m_ide_p == 1; } else m_ide_p==0;
              foreach(m_pcie_dev_top_cfg.ide_cfg.link_stream_id_tc_map[i]) {
                if ((i == m_tlp_tc) &&
                    (m_pcie_dev_top_cfg.ide_cfg.link_stream_id_tc_map[m_tlp_tc] == m_stream_id) &&
                    m_pcie_dev_top_cfg.ide_cfg.link_ide_str_enable[m_stream_id]) {
                  m_ide_p == (m_pcie_dev_top_cfg.ide_cfg.link_ide_pcrc_enable[m_stream_id] ? 1 : 0);
                  }
                }

              foreach(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[i]) {
                if ((i == m_stream_id) &&
                    m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_selective_ide_stream_enable) {
                  m_ide_p == (m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_pcrc_enable ? 1 : 0);
                }
              }
            }
          }
        }
        m_ide_k == m_pcie_dev_top_cfg.ide_cfg.curr_active_keyset[m_stream_id][0];
      `else
        !(m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) -> soft m_ide_m == 1;
        (m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) -> soft m_ide_m == 0;
        soft m_ide_p == 0;
        soft m_ide_k == 0;
      `endif
       foreach(m_pcie_dev_top_cfg.ide_cfg.link_stream_id_tc_map[i]) {
         if(i == m_tlp_tc) {
           if((m_pcie_dev_top_cfg.ide_cfg.link_stream_id_tc_map[m_tlp_tc] == m_stream_id) && m_pcie_dev_top_cfg.ide_cfg.link_ide_str_enable[m_stream_id]) {
             m_ide_t == 0;
           }
         }
       }
       foreach(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[i]) {
         if((i == m_stream_id) && m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_selective_ide_stream_enable) {
           m_ide_t == (m_pcie_dev_top_cfg.i_cfg.strap_is_rp ? (m_pcie_dev_top_cfg.tdisp_cfg.cfg_rmeda_tdisp_en ? m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_tee_lim_stream : 0) :m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_tee_lim_stream);
         }
       }
       //(m_pcie_dev_top_cfg.ide_cfg.find_stream_type(m_stream_id) == SELECTIVE_STREAM) -> m_ide_t == 1;
       //(m_pcie_dev_top_cfg.ide_cfg.find_stream_type(m_stream_id) == LINK_STREAM) -> m_ide_t == 0;
       //((!m_pcie_dev_top_cfg.rmeda_tdisp_en) && m_pcie_dev_top_cfg.i_cfg.strap_is_rp) -> m_ide_t == 0; 
     }
     else {
       soft m_ide_m == 0;
       soft m_ide_p == 0;
       soft m_ide_k == 0;
       soft m_ide_t == 0;
     }
   }

  constraint c_has_active_ide_stream {
    solve m_tlp_tc before m_tlp_tc_has_active_ide_stream;

    if(m_pcie_dev_top_cfg.ide_cfg.is_tc_mapped_to_enabled_stream_id(m_tlp_tc)) {
      m_tlp_tc_has_active_ide_stream == 1;
    }
    else {
      `ifdef TOP_LEVEL_SIMS
        m_tlp_tc_has_active_ide_stream == 0;
      `else
        soft m_tlp_tc_has_active_ide_stream == 0;
      `endif
    }
  }

  constraint c_ide_sel_stream_possible {
    solve m_tlp_trans_type, m_tlp_type, m_tlp_msg_rout_type before m_sel_stream_possible;

    //TODO: Revisit Solve tlp_addr, tlp_type before m_sel_stream_possible;
    //dev_cfg.check_ide_addr_association(tlp_addr)
    //Now based on sel_stream_possible, we will pick stream_id from another API find_stream_id_mapped_to_tc
    if (m_pcie_dev_top_cfg.ide_cfg.m_num_sel_str_enabled > 0){

      if (vdm_for_cxl && (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type0) && (m_tlp_vendor_id == 'h1E98)) {m_sel_stream_possible == 0;}
      else {
        // Default to 1, override below as needed
        m_sel_stream_possible == (
          // Case 1: MEM_TYPE
          (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) ? (
            ((m_pcie_link_cfg.dsp_dev_config.m_is_sel_stream_bar && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) ||
             (m_pcie_link_cfg.usp_dev_config.m_is_sel_stream_bar && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP)) ? 1 : 0
          ) :
          // Case 2: CfgRd0, CfgWr0, IORd, IOWr
          (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd0, CDN_HPA_PCIE_TLP_TYPE_CfgWr0, CDN_HPA_PCIE_TLP_TYPE_IORd, CDN_HPA_PCIE_TLP_TYPE_IOWr}) ? 0 :
          // Case 3: CfgRd1, CfgWr1
          (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1}) ? (
            (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) ? (
              (m_pcie_dev_top_cfg.ide_cfg.is_RID_inside_any_sel_stream({
                m_pcie_link_cfg.dsp_dev_config.m_req_id.bus_num,
                m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num,
                m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num
              }) && (m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_en)) ? 1 : 0
            ) :
	     (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) ? (
             (m_pcie_dev_top_cfg.ide_cfg.is_RID_inside_any_sel_stream({
               m_pcie_link_cfg.usp_dev_config.m_req_id.bus_num,
               m_pcie_link_cfg.usp_dev_config.m_req_id.device_num,
               m_pcie_link_cfg.usp_dev_config.m_req_id.function_num
             }) && (m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_en)) ? 1 : 0
           ) : 0
         ) :
         // Case 4: Msg, MsgD
         (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Msg, CDN_HPA_PCIE_TLP_TYPE_MsgD}) ? (
           (m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID}) ? (
             (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) ? (
               m_pcie_dev_top_cfg.ide_cfg.is_RID_inside_any_sel_stream({
                 m_pcie_link_cfg.dsp_dev_config.m_req_id.bus_num,
                 m_pcie_link_cfg.dsp_dev_config.m_req_id.device_num,
                 m_pcie_link_cfg.dsp_dev_config.m_req_id.function_num
               }) ? 1 : 0
	        ) :
        (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) ? (
          m_pcie_dev_top_cfg.ide_cfg.is_RID_inside_any_sel_stream({
            m_pcie_link_cfg.usp_dev_config.m_req_id.bus_num,
            m_pcie_link_cfg.usp_dev_config.m_req_id.device_num,
            m_pcie_link_cfg.usp_dev_config.m_req_id.function_num
          }) ? 1 : 0
        ) : 0
      ) :
      (m_tlp_msg_rout_type inside {CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ADDR}) ? 1 : 0
    ) :
    // Default case
    1
  );
          }
    }
    else {
      m_sel_stream_possible == 0;
    }
  }

  constraint c_ide_aggr_length_control {
    if(m_pcie_dev_top_cfg.i_cfg.k_ide_supported) {
      if(m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) {
        if(m_ide_prefix_present) {
          if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg) ||
          (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl) ||
          (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplLk))
          m_tlp_length == 0; //length field is reserved
          else
          m_tlp_length inside {[1:256]}; //aggr limit upto 256DW
          //TODO: Currenlty in post_randomize 192B is taken as threshold to complete aggregate. Below line should be the correct fix
          //(m_tlp_length + m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream]) <256;
        }
      }
    }
  }

  constraint c_cxl_ldid_local_prefix{
  
    //(cxl_ldid_prefix == 0 ) -> m_cxl_ldid inside {[0:15],16'hFFFF};
    (cxl_ldid_prefix == 1 ) -> m_cxl_ldid == m_pcie_dev_cfg.cxl_ldid;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_tlp_tph_constr
  // This Constraint generates tlp processing hints
  //--------------------------------------------------------------------------
  constraint c_tlp_tph_constr {
    solve m_ext_tph_prefix_present, m_tph_present before m_tlp_th;
    if(m_ext_tph_prefix_present || m_tph_present) {
      m_tlp_th==1;
    } else {
      m_tlp_th==0;
    }

    solve m_ext_tph_prefix_present before m_tlp_st_tag;
    if(!m_ext_tph_prefix_present) m_tlp_st_tag[15:8]==0;
    if(m_pcie_dev_cfg.m_st_mode_sel == 2'b00) m_tlp_st_tag == 0; //No ST mode operation
    if(m_pcie_dev_cfg.m_st_mode_sel == 2'b01) m_tlp_st_tag < (2**m_pcie_dev_cfg.m_msi_multi_msg_en);
    if(m_pcie_dev_cfg.m_st_mode_sel == 2'b01 && m_pcie_dev_cfg.m_st_table_size<(2**m_pcie_dev_cfg.m_msi_multi_msg_en)) m_tlp_st_tag ==0; //spec mandates in interrupt mode if st_table_size < interrupts eenable st_tag==0
    //if(m_pcie_dev_cfg.m_st_mode_sel == 2'b10 && m_tph_present) {
    //   st_entry_index < m_pcie_dev_cfg.m_st_table_size;
    //   if(!m_ext_tph_prefix_present) 
    //     m_tlp_st_tag[7:0] == m_pcie_dev_cfg.m_st_lower[st_entry_index];
    //   else                          
    //     m_tlp_st_tag      == {m_pcie_dev_cfg.m_st_upper[st_entry_index],m_pcie_dev_cfg.m_st_lower[st_entry_index]}; 
    //}

    solve m_pasid_prefix_present before m_pasid_value, m_pasid_pri_value, m_pasid_exec_value;
    if(!m_pasid_prefix_present) {
      m_pasid_value == 0;
      m_pasid_pri_value == 0;
      m_pasid_exec_value == 0;
    } else {
      //TODO Multiple PR_REQ in a PRG_IDX should have same Pasid.
      //For Page response , pasid should be filled from page req's pasid_val
      if(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Group_Response})) || m_hls_bypass_constraint) {
        m_pasid_value inside {[0:m_pcie_link_cfg.usp_dev_config.m_max_pasid_val]};
      }
      (m_pcie_link_cfg.usp_dev_config.m_pasid_attr[1] ==0 ) -> soft m_pasid_pri_value == 0;
      (m_pcie_link_cfg.usp_dev_config.m_pasid_attr[0] ==0 ) -> soft m_pasid_exec_value == 0;
      // Section 6.20.2.3 Execute Requested - For Memory Requests, other than an Untranslated Memory Read Request, the bit is Reserved.
      ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && !((m_tlp_at_type == CDN_HPA_PCIE_AT_Untranslated) && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,
      CDN_HPA_PCIE_TLP_TYPE_MRd_64,
      CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,
      CDN_HPA_PCIE_TLP_TYPE_MRdLk_64,
      CDN_HPA_PCIE_TLP_TYPE_UIOMRd}))) -> m_pasid_exec_value == 0;
      ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Group_Response})) -> {soft m_pasid_pri_value == 0; soft m_pasid_exec_value == 0;}
    }

    solve m_ext_tph_prefix_present, m_ama_valid, m_pasid_prefix_present, m_tph_pasid_as_first_prefix before m_tlp_st_tag, tph_byte_2_3_rsvd;
    if((m_ext_tph_prefix_present || m_ama_valid) && m_pasid_prefix_present) {
      if(m_tph_pasid_as_first_prefix) { //TPH is prefix[0] ; PASID is prefix[1]
        m_hdr_fmt_prefix[0] == CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
        m_hdr_type_prefix[0] == 5'b10000;
        if(hpa_generation != hpa_generation_2) {
          m_tlp_prefix[0] == {m_hdr_fmt_prefix[0],m_hdr_type_prefix[0],m_tlp_st_tag[15:8],tph_byte_2_3_rsvd};
        } else {
          m_tlp_prefix[0] == {m_hdr_fmt_prefix[0],m_hdr_type_prefix[0],m_tlp_st_tag[15:8],m_ama_value,m_ama_valid,tph_byte_2_3_rsvd[11:0]};
        }

        m_hdr_fmt_prefix[1] == CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
        m_hdr_type_prefix[1] == 5'b10001;
        m_tlp_prefix[1] == {m_hdr_fmt_prefix[1],m_hdr_type_prefix[1],m_pasid_pri_value,m_pasid_exec_value,pasid_byte_1_rsvd_field_5_4,m_pasid_value};
      } else { //PASID is prefix[0] ; TPH is prefix[1]
        m_hdr_fmt_prefix[0] == CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
        m_hdr_type_prefix[0] == 5'b10001;
        m_tlp_prefix[0] == {m_hdr_fmt_prefix[0],m_hdr_type_prefix[0],m_pasid_pri_value,m_pasid_exec_value,pasid_byte_1_rsvd_field_5_4,m_pasid_value};

        m_hdr_fmt_prefix[1] == CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
        m_hdr_type_prefix[1] == 5'b10000;
        if(hpa_generation != hpa_generation_2) {
          m_tlp_prefix[1] == {m_hdr_fmt_prefix[1],m_hdr_type_prefix[1],m_tlp_st_tag[15:8],tph_byte_2_3_rsvd};
        } else {
          m_tlp_prefix[1] == {m_hdr_fmt_prefix[1],m_hdr_type_prefix[1],m_tlp_st_tag[15:8],m_ama_value,m_ama_valid,tph_byte_2_3_rsvd[11:0]};
        }
      }
    } else if (m_ext_tph_prefix_present || m_ama_valid) {
      m_hdr_fmt_prefix[0] == CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
      m_hdr_type_prefix[0] == 5'b10000;
      if(hpa_generation != hpa_generation_2) {
        m_tlp_prefix[0] == {m_hdr_fmt_prefix[0],m_hdr_type_prefix[0],m_tlp_st_tag[15:8],tph_byte_2_3_rsvd};
      } else {
        m_tlp_prefix[0] == {m_hdr_fmt_prefix[0],m_hdr_type_prefix[0],m_tlp_st_tag[15:8],m_ama_value,m_ama_valid,tph_byte_2_3_rsvd[11:0]};
      }
    } else if (m_pasid_prefix_present) {
      m_hdr_fmt_prefix[0] == CDN_HPA_PCIE_TLP_FMT_TLP_PREFIX;
      m_hdr_type_prefix[0] == 5'b10001;
      m_tlp_prefix[0] == {m_hdr_fmt_prefix[0],m_hdr_type_prefix[0],m_pasid_pri_value,m_pasid_exec_value,pasid_byte_1_rsvd_field_5_4,m_pasid_value};
    }

    (m_tlp_th ==0) -> m_tlp_ph==0;
    solve m_tlp_th before m_tlp_ph;
  }

  //--------------------------------------------------------------------------
  // Constraint: c_ipg
  // This Constraint is used to generate tlp_ipg_type based on the tlp delay
  //--------------------------------------------------------------------------
  constraint c_ipg {
    soft m_tlp_ipg_type != CDN_HPA_PCIE_TLP_DELAY_UNDEFINED;
    m_tlp_ipg_type dist {CDN_HPA_PCIE_TLP_DELAY_ZERO:=10,CDN_HPA_PCIE_TLP_DELAY_MIN:=90, CDN_HPA_PCIE_TLP_DELAY_SMALL:=5, [CDN_HPA_PCIE_TLP_DELAY_MED:CDN_HPA_PCIE_TLP_DELAY_MAX]:=1};
    (m_tlp_ipg_type == CDN_HPA_PCIE_TLP_DELAY_ZERO) -> m_ipg == 0;
    (m_tlp_ipg_type == CDN_HPA_PCIE_TLP_DELAY_MIN) -> m_ipg inside {[0:2]};
    (m_tlp_ipg_type == CDN_HPA_PCIE_TLP_DELAY_SMALL) -> m_ipg inside {[3:10]};
    (m_tlp_ipg_type == CDN_HPA_PCIE_TLP_DELAY_MED) -> m_ipg inside {[10:30]};
    (m_tlp_ipg_type == CDN_HPA_PCIE_TLP_DELAY_LARGE) -> m_ipg inside {[30:50]};
    (m_tlp_ipg_type == CDN_HPA_PCIE_TLP_DELAY_MAX) -> m_ipg inside {[75:100]};
  }


  //--------------------------------------------------------------------------
  // Constraint: c_rsvd_fields
  // This Constraint will set all the reserved field bits to zero
  //--------------------------------------------------------------------------
  constraint c_rsvd_fields {
    soft force_rsvd_bits_as_zero == 1;
    if(!force_rsvd_bits_as_zero) {
      soft msg_inv_req_byte_6_field_7_rsvd_nfm == 0; //For INV_REQ tag can't be greater than 32
      soft msg_inv_req_byte_6_field_6_5_rsvd == 0; //For INV_REQ tag can't be greater than 32
      soft msg_destination_id_rsvd == 0;
      msg_pm_cxl_vnd_msg_byte_12_14_rsvd == 0;
      m_cxl_vdm_pm_agt_id_rsvd_bit == 0;
      m_cxl_vdm_crd_rtn_param_field_rsvd == 0;
      m_cxl_vdm_agt_info_param_byte1_rsvd == 0;
      m_cxl_vdm_pmreq_param_byte0_1_rsvd == 0;
      m_cxl_vdm_resetprep_param_byte0_1_rsvd == 0;
      m_cxl_vdm_crd_rtn_payload_rsvd == 0;
      m_cxl_vdm_agt_info_payload_rsvd == 0;
      m_cxl_vdm_pmreq_payload_rsvd == 0;
      m_cxl_vdm_resetprep_payload_rsvd == 0;
      m_cxl_vdm_agt_info_payload_rsvd_93_3 == 0;
      m_cxl_vdm_resetprep_payload_rsvd_95_9 == 0;
      m_cxl_vdm_gpf_payload_rsvd_95_18 == 0;
      m_cxl_vdm_gpf_payload_rsvd_15_9 == 0;
      m_cxl_vdm_gpf_payload_rsvd_7_2 == 0;
      m_cxl_vdm_pmreq_param_bit1_rsvd == 0;
      m_cxl_vdm_gpf_param_byte0_1_rsvd == 0;

      soft cfg_byte_11_rsvd_field_1_0 == 0;
      soft cfg_byte_10_rsvd_field_7_4 == 0;
      soft tph_byte_2_3_rsvd == 0;
      soft pasid_byte_1_rsvd_field_5_4 == 0;

      soft m_ohc_a1_byte_0_field_7_rsvd==0;
      soft m_ohc_a1_byte_3_rsvd==0;
      soft m_ohc_a2_byte_0_2_rsvd==0;
      soft m_ohc_a3_byte_1_rsvd==0;
      soft m_ohc_a3_byte_2_rsvd==0;
      soft m_ohc_a4_byte_2_field_5_4_rsvd == 0;
      soft m_ohc_a5_byte_2_3_rsvd==0;
      soft m_ohc_b_byte_0_rsvd==0;
      soft m_ohc_c_byte_3_field_2_rsvd==0;
      soft second_dw_byte_6_field_6_rsvd ==0;
      //soft io_byte_11_rsvd_field_1_0 == 0;
      //soft cpl_byte_12_rsvd_field_7 == 0;
      //soft msg_cmn_byte_8_15_rsvd == 0;
      //soft msg_inv_req_byte_10_15_rsvd == 0;
      //soft msg_inv_cpl_byte_10_11_rsvd == 0;
      //soft msg_pr_rsp_byte_10_field_3_1_rsvd == 0;
      //soft msg_pr_rsp_byte_12_15_rsvd == 0;
      //soft msg_ltr_byte_8_11_rsvd == 0;
      //soft msg_obff_byte_8_14_rsvd == 0;
      //soft msg_ln_drs_byte_13_15_rsvd == 0;
      //soft msg_ln_payload_rsvd == 0;
      //soft msg_frs_byte_13_15_rsvd == 0;
    } else {
      soft m_ohc_a1_byte_0_field_7_rsvd==0;
      soft m_ohc_a1_byte_3_rsvd==0;
      soft m_ohc_a2_byte_0_2_rsvd==0;
      soft m_ohc_a3_byte_1_rsvd==0;
      soft m_ohc_a3_byte_2_rsvd==0;
      soft m_ohc_a4_byte_2_field_5_4_rsvd == 0;
      soft m_ohc_a5_byte_2_3_rsvd==0;
      soft m_ohc_b_byte_0_rsvd==0;
      soft m_ohc_c_byte_3_field_2_rsvd==0;
      soft msg_inv_req_byte_6_field_7_rsvd_nfm == 0; //For INV_REQ tag can't be greater than 32
      soft msg_inv_req_byte_6_field_6_5_rsvd == 0; //For INV_REQ tag can't be greater than 32
      soft second_dw_byte_6_field_6_rsvd ==0;
      soft second_dw_byte_6_msg_rsvd==0;
      soft msg_destination_id_rsvd == 0;
      soft io_byte_11_rsvd_field_1_0 == 0;
      soft cfg_byte_11_rsvd_field_1_0 == 0;
      soft cfg_byte_10_rsvd_field_7_4 == 0;
      soft tph_byte_2_3_rsvd == 0;
      soft pasid_byte_1_rsvd_field_5_4 == 0;
      soft cpl_byte_12_rsvd_field_7 == 0;
      soft cpl_byte_12_rsvd_field_4_0 == 0;
      soft cpl_byte_11_rsvd_field_7_4 == 0;
      soft cpl_byte_11_rsvd_field_3_0 == 0;
      soft msg_cmn_byte_8_15_rsvd == 0;
      soft msg_inv_req_byte_10_15_rsvd == 0;
      soft msg_inv_cpl_byte_10_11_rsvd == 0;
      soft msg_pr_rsp_byte_10_field_3_1_rsvd == 0;
      soft msg_pr_rsp_byte_12_15_rsvd == 0;
      soft msg_ltr_byte_8_11_rsvd == 0;
      soft msg_obff_byte_8_14_rsvd == 0;
      soft msg_ln_drs_byte_13_15_rsvd == 0;
      soft msg_ln_payload_rsvd == 0;
      soft msg_frs_byte_13_15_rsvd == 0;
      msg_pm_cxl_vnd_msg_byte_12_14_rsvd == 0;
      m_cxl_vdm_pm_agt_id_rsvd_bit == 0;
      m_cxl_vdm_crd_rtn_param_field_rsvd == 0;
      m_cxl_vdm_agt_info_param_byte1_rsvd == 0;
      m_cxl_vdm_pmreq_param_byte0_1_rsvd == 0;
      m_cxl_vdm_resetprep_param_byte0_1_rsvd == 0;
      m_cxl_vdm_crd_rtn_payload_rsvd == 0;
      m_cxl_vdm_agt_info_payload_rsvd == 0;
      m_cxl_vdm_pmreq_payload_rsvd == 0;
      m_cxl_vdm_resetprep_payload_rsvd == 0;
      m_cxl_vdm_agt_info_payload_rsvd_93_3 == 0;
      m_cxl_vdm_resetprep_payload_rsvd_95_9 == 0;
      m_cxl_vdm_gpf_payload_rsvd_95_18 == 0;
      m_cxl_vdm_gpf_payload_rsvd_15_9 == 0;
      m_cxl_vdm_gpf_payload_rsvd_7_2 == 0;
      m_cxl_vdm_pmreq_param_bit1_rsvd == 0;
      m_cxl_vdm_gpf_param_byte0_1_rsvd ==0;
      soft m_tlp_pth_rsvd == 0;
    }
  }

  //-----------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //-----------------------------------------------------------------------------
  `uvm_object_utils_begin(cdn_hpa_pcie_tlp_base)
  // TODO
  //`uvm_field_enum(,,UVM_DEFAULT + UVM_NOPACK + UVM_NOCOMPARE + UVM_NOPRINT + UVM_NORECORD)
  `uvm_object_utils_end
  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  function new(string name = "cdn_hpa_pcie_tlp_base");
    super.new(name);
    if($value$plusargs("PTC_CV_TEST=%s", ptc_cv_test_name))  begin
      // `uvm_info("DEBUG_TL_CV", $psprintf("PTC_CV_TEST=%0s Selected", ptc_cv_test_name), UVM_DEBUG);
    end
    
    //Turnoff the constraint. Suspecting Tool issue : This cause CFG/IO payload to be zero
    //Enable in msg sequence alone
    //m_user_error_inject_obj = cdn_hpa_user_err_data::type_id::create("m_user_error_inject_obj");
    m_user_error_inject_obj = new("m_user_error_inject_obj");
    c_msg_payload_constr.constraint_mode(0);
  endfunction : new

  //------------------------------------------------------------------------
  // Function: do_copy
  // Extend the do_copy method for the physical member fields to copy
  //------------------------------------------------------------------------
  function void do_copy (uvm_object rhs);
    cdn_hpa_pcie_tlp_base item;
    super.do_copy(rhs);
    if(rhs == null) return;
    if(!$cast(item, rhs) ) begin
      `uvm_fatal(get_type_name(),"Cast failed at do_copy method")
    end
    // We can copy all the fields with out checking the TLP type
    m_tlp_req_type      = item.m_tlp_req_type;
    m_tlp_trans_type    = item.m_tlp_trans_type;
    m_tlp_np_req_type   = item.m_tlp_np_req_type;
    m_tlp_rout_type     = item.m_tlp_rout_type;
    int_msg_valid       = item.int_msg_valid;
    m_hdr_fmt           = item.m_hdr_fmt;
    m_hdr_type          = item.m_hdr_type;
    m_tlp_t9            = item.m_tlp_t9;
    m_tlp_tc            = item.m_tlp_tc;
    m_tlp_t8            = item.m_tlp_t8;
    m_tlp_attr1         = item.m_tlp_attr1;
    m_tlp_ln            = item.m_tlp_ln;
    m_tlp_th            = item.m_tlp_th;
    m_tlp_td            = item.m_tlp_td;
    m_tlp_ep            = item.m_tlp_ep;
    m_tlp_attr0         = item.m_tlp_attr0;
    m_tlp_length        = item.m_tlp_length;
    m_tlp_requester_id  = item.m_tlp_requester_id;
    m_tlp_completer_id  = item.m_tlp_completer_id;
    m_tlp_tag           = item.m_tlp_tag;
    m_tlp_last_dw_be    = item.m_tlp_last_dw_be;
    m_tlp_first_dw_be   = item.m_tlp_first_dw_be;
    m_tlp_addr          = item.m_tlp_addr;
    m_expect_enderror   = item.m_expect_enderror;
    intr_pin_en         = item.intr_pin_en;

    m_tlp_payload       = new[item.m_tlp_payload.size()];
    foreach(item.m_tlp_payload[i]) begin
      m_tlp_payload[i] = item.m_tlp_payload[i];
    end

    m_tlp_msg_rout_type = item.m_tlp_msg_rout_type;
    m_tlp_msg_code      = item.m_tlp_msg_code;

    m_max_no_of_prefixes = item.m_max_no_of_prefixes;

    m_ide_prefix_present = item.m_ide_prefix_present;
    m_ide_tlp_prefix = item.m_ide_tlp_prefix;
    m_ide_hdr_fmt_prefix = item.m_ide_hdr_fmt_prefix;
    m_ide_hdr_type_prefix = item.m_ide_hdr_type_prefix;

    m_tlp_prefix      = new[item.m_tlp_prefix.size()];
    foreach(m_tlp_prefix[i]) begin
      m_tlp_prefix[i] = item.m_tlp_prefix[i];
    end

    m_hdr_fmt_prefix = new[item.m_hdr_fmt_prefix.size()];
    foreach(m_hdr_fmt_prefix[i]) begin
      m_hdr_fmt_prefix[i] = item.m_hdr_fmt_prefix[i];
    end

    m_hdr_type_prefix = new[item.m_hdr_type_prefix.size()];
    foreach(m_hdr_type_prefix[i]) begin
      m_hdr_type_prefix[i] = item.m_hdr_type_prefix[i];
    end

    m_tlp_uses_dedicated_credits = item.m_tlp_uses_dedicated_credits;
    m_max_no_of_local_prefixes = item.m_max_no_of_local_prefixes;
    m_local_prefix_possible = item.m_local_prefix_possible;
    m_tlp_local_prefix      = new[item.m_tlp_local_prefix.size()];
    foreach(m_tlp_local_prefix[i]) begin
      m_tlp_local_prefix[i] = item.m_tlp_local_prefix[i];
    end

    m_tlp_local_prefix_data      = new[item.m_tlp_local_prefix_data.size()];
    foreach(m_tlp_local_prefix_data[i]) begin
      m_tlp_local_prefix_data[i] = item.m_tlp_local_prefix_data[i];
    end
    
    //PTH: PBR (add any condition?)
    m_tlp_pbr_tlp_header = item.m_tlp_pbr_tlp_header;
    m_tlp_pth_spid       = item.m_tlp_pth_spid;
    m_tlp_pth_dpid       = item.m_tlp_pth_dpid;
    m_tlp_pth_hie        = item.m_tlp_pth_hie;
    m_tlp_pth_pif        = item.m_tlp_pth_pif;
    m_tlp_pth_dsar       = item.m_tlp_pth_dsar;
    m_tlp_pth_rsvd       = item.m_tlp_pth_rsvd;

    m_hdr_fmt_local_prefix      = new[item.m_hdr_fmt_local_prefix.size()];
    foreach(m_hdr_fmt_local_prefix[i]) begin
      m_hdr_fmt_local_prefix[i] = item.m_hdr_fmt_local_prefix[i];
    end

    m_hdr_type_local_prefix      = new[item.m_hdr_type_local_prefix.size()];
    foreach(m_hdr_type_local_prefix[i]) begin
      m_hdr_type_local_prefix[i] = item.m_hdr_type_local_prefix[i];
    end

    m_tlp_cpl_status                  = item.m_tlp_cpl_status;
    m_tlp_cpl_bcm                     = item.m_tlp_cpl_bcm;
    m_tlp_cpl_byte_cnt                = item.m_tlp_cpl_byte_cnt;
    m_tlp_addr_type                   = item.m_tlp_addr_type;
    m_tlp_type                        = item.m_tlp_type;
    m_tlp_ph                          = item.m_tlp_ph;
    m_tlp_ats_tr_nw_field             = item.m_tlp_ats_tr_nw_field;
    m_tlp_at_type                     = item.m_tlp_at_type;
    m_tlp_ext_reg_num                 = item.m_tlp_ext_reg_num;
    m_tlp_reg_num                     = item.m_tlp_reg_num;
    m_tlp_cpl_lower_addr              = item.m_tlp_cpl_lower_addr;
    m_tlp_vdm_msg_subtype             = item.m_tlp_vdm_msg_subtype;
    m_tlp_hier_vmsg_hierarchy_id      = item.m_tlp_hier_vmsg_hierarchy_id;
    m_tlp_hier_vmsg_guid_authority_id = item.m_tlp_hier_vmsg_guid_authority_id;
    m_tlp_vendor_id                   = item.m_tlp_vendor_id;
    m_tlp_vendor_msg                  = item.m_tlp_vendor_msg;
    m_inv_cpl_cnt                     = item.m_inv_cpl_cnt;
    m_tlp_itag_vector                 = item.m_tlp_itag_vector;
    m_tlp_itag                        = item.m_tlp_itag;
    m_tlp_ltr_msg_no_snoop_latency    = item.m_tlp_ltr_msg_no_snoop_latency;
    m_tlp_ltr_msg_snoop_latency       = item.m_tlp_ltr_msg_snoop_latency;
    m_page_addr                       = item.m_page_addr;
    m_prGroupIndex                    = item.m_prGroupIndex;
    m_prLastRequest                   = item.m_prLastRequest;
    m_prWriteRequested                = item.m_prWriteRequested;
    m_prReadRequested                 = item.m_prReadRequested;
    m_prgResponseCode                 = item.m_prgResponseCode;
    m_obffCode                        = item.m_obffCode;
    m_ptmMasterTime                   = item.m_ptmMasterTime;
    m_ptmPropagationDelay             = item.m_ptmPropagationDelay;
    m_tlp_cpl_cdl                     = item.m_tlp_cpl_cdl;
    uio_cpl_diff_status               = item.uio_cpl_diff_status;


    m_tlp_payload                     = new[item.m_tlp_payload.size()];
    foreach(m_tlp_payload[i]) begin
      m_tlp_payload[i] = item.m_tlp_payload[i];
    end

    m_data                            = new[item.m_data.size()];
    foreach(m_data[i]) begin
      m_data[i] = item.m_data[i];
    end

    prfx_bytes                        = new[item.prfx_bytes.size()];
    foreach(prfx_bytes[i]) begin
      prfx_bytes[i] = item.prfx_bytes[i];
    end

    m_tlp_ln_msg_nr         = item.m_tlp_ln_msg_nr;
    m_tlp_frs_msg_reason = item.m_tlp_frs_msg_reason;
    m_tlp_ln_msg_cacheline_addr = item.m_tlp_ln_msg_cacheline_addr;
    m_tlp_hier_vmsg_system_guid = item.m_tlp_hier_vmsg_system_guid;

    ecrc_val = item.ecrc_val;
    ecrc_valid = item.ecrc_valid;

    m_pasid_prefix_present = item.m_pasid_prefix_present;
    m_pasid_value = item.m_pasid_value;
    m_pasid_pri_value = item.m_pasid_pri_value;
    m_pasid_exec_value = item.m_pasid_exec_value;

    m_ext_tph_prefix_present = item.m_ext_tph_prefix_present;
    m_ama_valid = item.m_ama_valid;
    m_ama_value = item.m_ama_value;
    m_tlp_st_tag = item.m_tlp_st_tag;
    vip_userdata = item.vip_userdata;

    //NFM Rsvd fields copy
    msg_inv_req_byte_6_field_7_rsvd_nfm = item.msg_inv_req_byte_6_field_7_rsvd_nfm;
    msg_inv_req_byte_6_field_6_5_rsvd = item.msg_inv_req_byte_6_field_6_5_rsvd;
    msg_destination_id_rsvd = item.msg_destination_id_rsvd;
    io_byte_11_rsvd_field_1_0 = item.io_byte_11_rsvd_field_1_0;
    cfg_byte_11_rsvd_field_1_0 = item.cfg_byte_11_rsvd_field_1_0;
    cfg_byte_10_rsvd_field_7_4 = item.cfg_byte_10_rsvd_field_7_4;
    tph_byte_2_3_rsvd = item.tph_byte_2_3_rsvd;
    pasid_byte_1_rsvd_field_5_4 = item.pasid_byte_1_rsvd_field_5_4;
    cpl_byte_12_rsvd_field_7 = item.cpl_byte_12_rsvd_field_7 ;
    cpl_byte_12_rsvd_field_4_0 = item.cpl_byte_12_rsvd_field_4_0;
    cpl_byte_11_rsvd_field_7_4 = item.cpl_byte_11_rsvd_field_7_4;
    cpl_byte_11_rsvd_field_3_0 = item.cpl_byte_11_rsvd_field_3_0;
    msg_ide_fail_byte_8_9_rsvd = item.msg_ide_fail_byte_8_9_rsvd ;
    msg_ide_fail_byte_10_rsvd = item.msg_ide_fail_byte_10_rsvd ;
    msg_ide_fail_byte_12_15_rsvd = item.msg_ide_fail_byte_12_15_rsvd ;
    msg_cmn_byte_8_15_rsvd = item.msg_cmn_byte_8_15_rsvd ;
    msg_inv_req_byte_10_15_rsvd = item.msg_inv_req_byte_10_15_rsvd ;
    msg_inv_cpl_byte_10_11_rsvd = item.msg_inv_cpl_byte_10_11_rsvd ;
    msg_pr_rsp_byte_10_field_3_1_rsvd = item.msg_pr_rsp_byte_10_field_3_1_rsvd ;
    msg_pr_rsp_byte_12_15_rsvd = item.msg_pr_rsp_byte_12_15_rsvd ;
    msg_ltr_byte_8_11_rsvd = item.msg_ltr_byte_8_11_rsvd ;
    msg_obff_byte_8_14_rsvd = item.msg_obff_byte_8_14_rsvd ;
    msg_ln_drs_byte_13_15_rsvd = item.msg_ln_drs_byte_13_15_rsvd ;
    msg_ln_payload_rsvd = item.msg_ln_payload_rsvd ;
    msg_frs_byte_13_15_rsvd = item.msg_frs_byte_13_15_rsvd ;

    // For checks
    tc       = item.tc;
    seq_num  = item.seq_num;
    pkt_num  = item.pkt_num;
    p_pkt_num  = item.p_pkt_num;
    np_pkt_num  = item.np_pkt_num;
    cpl_pkt_num  = item.cpl_pkt_num;
    cpl_pkt_num_in_flit  = item.cpl_pkt_num_in_flit;
    pkt_rx_time = item.pkt_rx_time;
    m_byte_count_mismatch_but_chk_disabled = item.m_byte_count_mismatch_but_chk_disabled;
    m_cpl_complete = item.m_cpl_complete;
    hlsob2cfg_tlp = item.hlsob2cfg_tlp;
    cfg2hls_tlp = item.cfg2hls_tlp;
    m_lower_addr_mismatch_but_chk_disabled = item.m_lower_addr_mismatch_but_chk_disabled;

    //CXL fields
    cxl_mode = item.cxl_mode;
    cxl_sbsa_test = item.cxl_sbsa_test;
    cxl_ldid_prefix = item.cxl_ldid_prefix;
    cxl_version = item.cxl_version;
    m_cxl_vdm_pm_logical_opcode = item.m_cxl_vdm_pm_logical_opcode;
    m_cxl_vdm_pm_agt_id = item.m_cxl_vdm_pm_agt_id;
    m_cxl_vdm_pm_agt_id_rsvd_bit = item.m_cxl_vdm_pm_agt_id_rsvd_bit;
    m_cxl_vdm_parameter = item.m_cxl_vdm_parameter;
    m_cxl_vdm_payload = item.m_cxl_vdm_payload;
    msg_pm_cxl_vnd_msg_byte_12_14_rsvd = item.msg_pm_cxl_vnd_msg_byte_12_14_rsvd;

    m_cxl_vdm_crd_rtn_param_field_rsvd = item.m_cxl_vdm_crd_rtn_param_field_rsvd ;
    m_cxl_vdm_agt_info_req_or_rsp = item.m_cxl_vdm_agt_info_req_or_rsp ;
    m_cxl_vdm_agt_info_index = item.m_cxl_vdm_agt_info_index ;
    m_cxl_vdm_agt_info_param_byte1_rsvd = item.m_cxl_vdm_agt_info_param_byte1_rsvd ;
    m_cxl_vdm_pmreq_req_or_rsp = item.m_cxl_vdm_pmreq_req_or_rsp ;
    m_cxl_vdm_pmreq_ea = item.m_cxl_vdm_pmreq_ea ;
    m_cxl_vdm_pmreq_go = item.m_cxl_vdm_pmreq_go ;
    m_cxl_vdm_pmreq_param_byte0_1_rsvd = item.m_cxl_vdm_pmreq_param_byte0_1_rsvd ;
    m_cxl_vdm_resetprep_req_or_rsp = item.m_cxl_vdm_resetprep_req_or_rsp ;
    m_cxl_vdm_resetprep_param_byte0_1_rsvd = item.m_cxl_vdm_resetprep_param_byte0_1_rsvd ;
    m_cxl_vdm_crd_rtn_payload_num_credits = item.m_cxl_vdm_crd_rtn_payload_num_credits ;
    m_cxl_vdm_crd_rtn_payload_tgt_agt_id = item.m_cxl_vdm_crd_rtn_payload_tgt_agt_id ;
    m_cxl_vdm_crd_rtn_payload_rsvd = item.m_cxl_vdm_crd_rtn_payload_rsvd ;
    m_cxl_vdm_agt_info_revision_id = item.m_cxl_vdm_agt_info_revision_id ;
    m_cxl_vdm_agt_info_payload_rsvd = item.m_cxl_vdm_agt_info_payload_rsvd ;
    m_cxl_vdm_pmreq_ltr = item.m_cxl_vdm_pmreq_ltr ;
    m_cxl_vdm_pmreq_payload_rsvd = item.m_cxl_vdm_pmreq_payload_rsvd ;
    m_cxl_vdm_resetprep_reset_type = item.m_cxl_vdm_resetprep_reset_type ;
    m_cxl_vdm_resetprep_prep_type = item.m_cxl_vdm_resetprep_prep_type ;
    m_cxl_vdm_resetprep_phase = item.m_cxl_vdm_resetprep_phase ;
    m_cxl_vdm_resetprep_payload_rsvd = item.m_cxl_vdm_resetprep_payload_rsvd ;
    m_cxl_vdm_agt_info_payload_rsvd_93_3 = item.m_cxl_vdm_agt_info_payload_rsvd_93_3;
    m_cxl_vdm_resetprep_payload_rsvd_95_9 = item.m_cxl_vdm_resetprep_payload_rsvd_95_9;
    m_cxl_vdm_gpf_payload_bit0 = item.m_cxl_vdm_gpf_payload_bit0;
    m_cxl_vdm_gpf_payload_bit1 = item.m_cxl_vdm_gpf_payload_bit1;
    m_cxl_vdm_gpf_payload_rsvd_7_2 = item.m_cxl_vdm_gpf_payload_rsvd_7_2;
    m_cxl_vdm_gpf_status_bit8 = item.m_cxl_vdm_gpf_status_bit8;
    m_cxl_vdm_gpf_payload_rsvd_15_9 = item.m_cxl_vdm_gpf_payload_rsvd_15_9;
    m_cxl_vdm_gpf_payload_phase = item.m_cxl_vdm_gpf_payload_phase;
    m_cxl_vdm_gpf_payload_rsvd_95_18 = item.m_cxl_vdm_gpf_payload_rsvd_95_18;
    m_cxl_vdm_pmreq_param_bit1_rsvd = item.m_cxl_vdm_pmreq_param_bit1_rsvd;
    m_cxl_vdm_gpf_param_byte0_1_rsvd = item.m_cxl_vdm_gpf_param_byte0_1_rsvd;
    m_cxl_vdm_pmreq_ltr_2 = item.m_cxl_vdm_pmreq_ltr_2;

    m_cxl_src = item.m_cxl_src ;
    m_cxl_ldid = item.m_cxl_ldid;
    msi_msix_requestor_id = item.msi_msix_requestor_id;
    intr_number_bits   = item.intr_number_bits;
    m_pcie_dev_cfg     = item.m_pcie_dev_cfg;
    m_pcie_dut_dev_cfg = item.m_pcie_dut_dev_cfg;
    //m_pcie_bfm_dev_cfg = item.m_pcie_bfm_dev_cfg;
    m_pcie_dev_top_cfg = item.m_pcie_dev_top_cfg;
    m_pcie_link_cfg    = item.m_pcie_link_cfg;

    is_translation_cpl = item.is_translation_cpl;
    is_ib_pkt = item.is_ib_pkt;
    m_cpl_part = item.m_cpl_part;
    hls_ib_cpl_meta_s = item.hls_ib_cpl_meta_s;
    hls_ib_p_np_meta_s = item.hls_ib_p_np_meta_s;
    is_flit_mode = item.is_flit_mode;
    cxl_mode = item.cxl_mode;
    cxl_sbsa_test = item.cxl_sbsa_test;
    is_cxl_pbr_mode = item.is_cxl_pbr_mode;
    is_ide_tlp = item.is_ide_tlp;
    hpa_generation = item.hpa_generation;
    pcie_6_1_support = item.pcie_6_1_support;
    m_ohc_hdr = item.m_ohc_hdr;
    m_ts = item.m_ts;
    m_tlp_14_bit_tagscale = item.m_tlp_14_bit_tagscale;
    m_tlp_tagscale = item.m_tlp_tagscale;
    m_ts_payload    = new[item.m_ts_payload.size()];
    foreach(m_ts_payload[i]) begin
      m_ts_payload[i] = item.m_ts_payload[i];
    end

    implcit_byte_enable_mem_tlps = item.implcit_byte_enable_mem_tlps;
    m_destination_segment = item.m_destination_segment;
    m_destination_segment_valid= item.m_destination_segment_valid;
    m_requester_segment = item.m_requester_segment;
    m_completer_segment = item.m_completer_segment;
    m_hv = item.m_hv;
    m_ama_value = item.m_ama_value;
    m_ama_valid = item.m_ama_valid;
    m_ide_tlp_prefix = item.m_ide_tlp_prefix;
    m_pr_sent_counter = item.m_pr_sent_counter;
    m_stream_id = item.m_stream_id;
    m_sub_stream = item.m_sub_stream;
    m_requester_segment_valid = item.m_requester_segment_valid;
    m_ide_p = item.m_ide_p;
    m_ide_m = item.m_ide_m;
    m_ide_k = item.m_ide_k;
    m_ide_t = item.m_ide_t;
    msg_ide_fail_stream_id       = item.msg_ide_fail_stream_id      ;
    msg_ide_sync_pr_sent_cnt_np  = item.msg_ide_sync_pr_sent_cnt_np ;
    msg_ide_sync_pr_sent_cnt_cpl = item.msg_ide_sync_pr_sent_cnt_cpl;
    m_tlp_is_selective_sync_msg  = item.m_tlp_is_selective_sync_msg;
    m_tl_layer_scoreboard = item.m_tl_layer_scoreboard;
    m_ohc_a = item.m_ohc_a;
    m_ohc_b = item.m_ohc_b;
    m_ohc_c = item.m_ohc_c;
    m_ohc_e = new[item.m_ohc_e.size()];
    foreach(m_ohc_e[i]) begin
      m_ohc_e[i] = item.m_ohc_e[i];
    end
    num_of_vnd_e2e_prefixes = item.num_of_vnd_e2e_prefixes;
    num_of_valid_vnd_e2e_prefixes = item.num_of_valid_vnd_e2e_prefixes;

    //m_completion_segment_differ = item.m_completion_segment_differ;

    //Rsvd fields flit mode
    second_dw_byte_6_field_6_rsvd = item.second_dw_byte_6_field_6_rsvd;
    second_dw_byte_6_msg_rsvd = item.second_dw_byte_6_msg_rsvd;
    vendor_definition_vd_msg = item.vendor_definition_vd_msg;
    vendor_definition_vd_msg_rsvd_bit = item.vendor_definition_vd_msg_rsvd_bit;
    m_ohc_a1_byte_0_field_7_rsvd = item.m_ohc_a1_byte_0_field_7_rsvd;
    m_ohc_a1_byte_3_rsvd = item.m_ohc_a1_byte_3_rsvd;
    m_ohc_a2_byte_0_2_rsvd = item.m_ohc_a2_byte_0_2_rsvd;
    m_ohc_a3_byte_1_rsvd = item.m_ohc_a3_byte_1_rsvd;
    m_ohc_a3_byte_2_rsvd = item.m_ohc_a3_byte_2_rsvd;
    m_ohc_a4_byte_2_field_5_4_rsvd = item.m_ohc_a4_byte_2_field_5_4_rsvd;
    m_ohc_a5_byte_2_3_rsvd = item.m_ohc_a5_byte_2_3_rsvd;
    m_ohc_b_byte_0_rsvd = item.m_ohc_b_byte_0_rsvd;
    m_ohc_c_byte_3_field_2_rsvd = item.m_ohc_c_byte_3_field_2_rsvd;
    msg_ide_sync_pr_sent_cnt_cpl = item.msg_ide_sync_pr_sent_cnt_cpl;
    msg_ide_sync_pr_sent_cnt_np  = item.msg_ide_sync_pr_sent_cnt_np;
    misrouted_ide_tlp_err = item.misrouted_ide_tlp_err;
    ide_pr_sent_counter_err = item.ide_pr_sent_counter_err;
    ide_mac_err = item.ide_mac_err;
    ide_mac_zero_whn_aggr_not_supp_err = item.ide_mac_zero_whn_aggr_not_supp_err;
    ide_mac_zero_whn_aggr_supp_err = item.ide_mac_zero_whn_aggr_supp_err;
    pcrc_err = item.pcrc_err;
    ide_invalid_substream = item.ide_invalid_substream;

    cfg_type1_target_pri                             = item.cfg_type1_target_pri;
    cfg_type0_target_pri                             = item.cfg_type0_target_pri;
    cfg_type1_target_sec                             = item.cfg_type1_target_sec;
    cfg_type1_target_sec_non_zero_dev_ari_dis        = item.cfg_type1_target_sec_non_zero_dev_ari_dis;
    cfg_type1_target_pri_wrong_dev_fun               = item.cfg_type1_target_pri_wrong_dev_fun;
    cfg_type1_target_more_than_sec_less_equal_to_sub = item.cfg_type1_target_more_than_sec_less_equal_to_sub;
    cfg_type1_target_more_than_sub                   = item.cfg_type1_target_more_than_sub;

    pack_flit_mode_local_prefix                      = item.pack_flit_mode_local_prefix;

  endfunction

endclass

//---------------------------------------------------------------------------------------------
// Class: cdn_hpa_pcie_tlp
// This class will contain all the utility functions to enable manipulation of hpa tlp packet
//---------------------------------------------------------------------------------------------
class cdn_hpa_pcie_tlp extends cdn_hpa_pcie_tlp_base;

  //--------------------------------------------------------------------------
  // Constraint: c_cxl_vdm_pm_msg
  // Overriding this constraint for cxl2.0 vdm support
  //--------------------------------------------------------------------------

  constraint c_cxl_not_vdm_pm_msg {
    (!cxl_mode && (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type0)) -> m_cxl_vdm_pm_logical_opcode == CDN_HPA_VDM_STD_VD_TYPE0;
  }

  // For CXLVer 2&3
  constraint c_cxl_vdm_pm_logical_opcode_ver_2 {
    if (cxl_mode==1 && cxl_version > 1 && vdm_for_cxl==1 )
    {
      solve m_cxl_vdm_agt_info_param_byte1_rsvd,m_cxl_vdm_agt_info_index,m_cxl_vdm_agt_info_req_or_rsp,m_cxl_vdm_resetprep_param_byte0_1_rsvd,m_cxl_vdm_resetprep_req_or_rsp,m_cxl_vdm_pmreq_param_byte0_1_rsvd,m_cxl_vdm_pmreq_go,m_cxl_vdm_pmreq_param_bit1_rsvd,m_cxl_vdm_pmreq_req_or_rsp,m_cxl_vdm_gpf_param_byte0_1_rsvd,m_cxl_vdm_gpf_req_or_rsp before m_cxl_vdm_parameter;
      // As per CXL Ver 2 Spec values for different varaibles
      m_cxl_vdm_pm_agt_id == 0 ; //m_cxl_vdm_crd_rtn_payload_tgt_agt_id;
      m_cxl_vdm_crd_rtn_payload_tgt_agt_id ==0;
      m_cxl_vdm_gpf_payload_phase inside {'h0, 'h1};

      if (m_cxl_vdm_agt_info_index ==0) {
        m_cxl_vdm_agt_info_capability_vector_bit0==1; // CXL 1.1 Spec VDM supported
        m_cxl_vdm_agt_info_capability_vector_bit1==1; // GPF supported
      }
      else{
        m_cxl_vdm_agt_info_capability_vector_bit0==0; // CXL 1.1 Spec VDM supported
        m_cxl_vdm_agt_info_capability_vector_bit1==0; // GPF supported
      }
      // Main constraint block
      if ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type0))
      {
        if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) {   //CDN_HPA_CXL_AGENT_INFO
          m_cxl_vdm_parameter == {m_cxl_vdm_agt_info_param_byte1_rsvd,m_cxl_vdm_agt_info_index,m_cxl_vdm_agt_info_req_or_rsp};
          m_cxl_vdm_payload == {m_cxl_vdm_agt_info_payload_rsvd_93_3,m_cxl_vdm_agt_info_capability_vector_bit1,m_cxl_vdm_agt_info_capability_vector_bit0};
        }
        else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) {   // CDN_HPA_CXL_RESET_PREP
          m_cxl_vdm_parameter == {m_cxl_vdm_resetprep_param_byte0_1_rsvd,m_cxl_vdm_resetprep_req_or_rsp};
          m_cxl_vdm_payload == {m_cxl_vdm_resetprep_payload_rsvd_95_9,m_cxl_vdm_resetprep_prep_type,m_cxl_vdm_resetprep_reset_type};
        }
        else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) {  //CDN_HPA_CXL_PM_REQ_RSP_GO
          m_cxl_vdm_parameter == {m_cxl_vdm_pmreq_param_byte0_1_rsvd,m_cxl_vdm_pmreq_go,m_cxl_vdm_pmreq_param_bit1_rsvd,m_cxl_vdm_pmreq_req_or_rsp};
          m_cxl_vdm_payload == {m_cxl_vdm_pmreq_payload_rsvd,m_cxl_vdm_pmreq_ltr_2};
        }
        else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_GPF) { //CDN_HPA_CXL_GPF
          m_cxl_vdm_parameter == {m_cxl_vdm_gpf_param_byte0_1_rsvd,m_cxl_vdm_gpf_req_or_rsp};
          m_cxl_vdm_payload == {m_cxl_vdm_gpf_payload_rsvd_95_18,m_cxl_vdm_gpf_payload_phase,m_cxl_vdm_gpf_payload_rsvd_15_9,m_cxl_vdm_gpf_status_bit8,m_cxl_vdm_gpf_payload_rsvd_7_2,m_cxl_vdm_gpf_payload_bit1,m_cxl_vdm_gpf_payload_bit0};
        }
        else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) { //CDN_HPA_CXL_CREDIT_RTN
          m_cxl_vdm_parameter == 'h0;
          m_cxl_vdm_payload == {m_cxl_vdm_crd_rtn_payload_rsvd,m_cxl_vdm_crd_rtn_payload_tgt_agt_id,m_cxl_vdm_crd_rtn_payload_num_credits};
        }
        else {
          m_cxl_vdm_parameter == 'h0;
          m_cxl_vdm_payload =='h0;
        }
        foreach(m_tlp_payload[i]) {
          if(i==0) m_tlp_payload[i] == m_cxl_vdm_pm_logical_opcode;
          else if (i==1) m_tlp_payload[i] == {m_cxl_vdm_pm_agt_id_rsvd_bit,m_cxl_vdm_pm_agt_id};
          else if (i==2) m_tlp_payload[i] == m_cxl_vdm_parameter[7:0];
          else if (i==3) m_tlp_payload[i] == m_cxl_vdm_parameter[15:8];
          else {m_tlp_payload[i] == m_cxl_vdm_payload[(((i-4)*8)+7)-:8];}
        }
      }
      solve m_tlp_msg_code before m_cxl_vdm_pm_logical_opcode;
      //solve force_rsvd_bits_as_zero before  m_tlp_payload;
    }
  }


  constraint c_cxl_vdm_pm_logical_opcode_ver_1 {
    if (!is_flit_mode && cxl_mode==1 && cxl_version == 1 && vdm_for_cxl==1 )
    {
      m_cxl_vdm_pm_agt_id == 'h7f ; //m_cxl_vdm_crd_rtn_payload_tgt_agt_id;
      m_cxl_vdm_crd_rtn_payload_tgt_agt_id ==0;

      // Main constraint block
      if ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type0))
      {

        if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) {
          m_cxl_vdm_parameter == {m_cxl_vdm_agt_info_param_byte1_rsvd,m_cxl_vdm_agt_info_index,m_cxl_vdm_agt_info_req_or_rsp};
          m_cxl_vdm_payload == {m_cxl_vdm_agt_info_payload_rsvd,m_cxl_vdm_agt_info_revision_id};
        }
        else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) {
          m_cxl_vdm_parameter == {m_cxl_vdm_resetprep_param_byte0_1_rsvd,m_cxl_vdm_resetprep_req_or_rsp};
          m_cxl_vdm_payload == {m_cxl_vdm_resetprep_payload_rsvd,m_cxl_vdm_resetprep_phase,m_cxl_vdm_resetprep_prep_type,m_cxl_vdm_resetprep_reset_type};
        }
        else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) {
          m_cxl_vdm_parameter == {m_cxl_vdm_pmreq_param_byte0_1_rsvd,m_cxl_vdm_pmreq_go,m_cxl_vdm_pmreq_ea,m_cxl_vdm_pmreq_req_or_rsp};
          m_cxl_vdm_payload == {m_cxl_vdm_pmreq_payload_rsvd,m_cxl_vdm_pmreq_ltr};
        }
        else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) { //CDN_HPA_CXL_CREDIT_RTN
          m_cxl_vdm_parameter == 'h0;
          m_cxl_vdm_payload == {m_cxl_vdm_crd_rtn_payload_rsvd,m_cxl_vdm_crd_rtn_payload_tgt_agt_id,m_cxl_vdm_crd_rtn_payload_num_credits};
        }
        else {
          m_cxl_vdm_parameter == m_cxl_vdm_crd_rtn_param_field_rsvd;
          m_cxl_vdm_payload =='h0;
        }

        foreach(m_tlp_payload[i]) {
          if(i==0) m_tlp_payload[i] == m_cxl_vdm_pm_logical_opcode;
          else if (i==1) m_tlp_payload[i] == {m_cxl_vdm_pm_agt_id_rsvd_bit,m_cxl_vdm_pm_agt_id};
          else if (i==2) m_tlp_payload[i] == m_cxl_vdm_parameter[7:0];
          else if (i==3) m_tlp_payload[i] == m_cxl_vdm_parameter[15:8];
          else {m_tlp_payload[i] == m_cxl_vdm_payload[(((i-4)*8)+7)-:8];}
        }
      }
      solve m_tlp_msg_code before m_cxl_vdm_pm_logical_opcode;
    }
  }

  constraint c_cxl_vdm_pm_msg {
    if (cxl_mode==1 && vdm_for_cxl==1 ){
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE  && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type0 && (m_cxl_vdm_pm_logical_opcode != CDN_HPA_VDM_STD_VD_TYPE0)){
        m_tlp_vendor_msg == {msg_pm_cxl_vnd_msg_byte_12_14_rsvd, 8'h68};
        m_tlp_vendor_id == 16'h1E98;
        m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;
        m_tlp_length == 4;
        

        // VIP has implemented checks for 2.0 so aligneding checks for same.
        m_cxl_vdm_resetprep_reset_type inside {'h1,'h3,'h4, 'h5, 'h10};
        m_cxl_vdm_resetprep_prep_type == 'h0;
        m_cxl_vdm_resetprep_phase == 'h0;
        m_cxl_vdm_pmreq_go == 1;
        //m_cxl_vdm_agt_info_index==0;
        m_cxl_vdm_crd_rtn_payload_num_credits == 8'hFF;  //Programmed to max value
        if (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP){
          m_cxl_vdm_agt_info_req_or_rsp ==1; // In case of RP request
          m_cxl_vdm_resetprep_req_or_rsp == 1;
        }
        else{
          m_cxl_vdm_agt_info_req_or_rsp ==0; // In case of EP request
          m_cxl_vdm_resetprep_req_or_rsp == 0;
        }
        if(is_flit_mode){
          m_tlp_tc                   == 0;
          m_tlp_attr0                == 0;
          m_tlp_attr1                == 0;
        }
        
      }
      // For CXL VDM Error Message code
      if ((cxl_version >1 && m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type0 &&  m_cxl_error_vdm_msg == CDN_HPA_CXL_VDM_MEFN && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP))
      {
        //m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_VDM_MEFN;
        m_tlp_vendor_id == 16'h1E98;
        m_tlp_length == 0;
        m_tlp_vendor_msg == {msg_cxl_vdm_msg_bits_rsvd, msg_cxl_vdm_msg_fw_interrupt_vector, 8'h0};
        m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC;
        if(is_flit_mode){
          m_tlp_tc                   == 0;
          m_tlp_attr0                == 0;
          m_tlp_attr1                == 0;
        }

      }
      
      solve m_tlp_msg_code before m_cxl_vdm_pm_logical_opcode;
    }
  }


  `ifdef BRIDGE
    //--------------------------------------------------------------------------
    // Constraint: axi_slave_payload_limitations_cs
    // Limits the payload to the
    //--------------------------------------------------------------------------
    constraint axi_slave_payload_limitations_cs {
      if (
        ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && m_pcie_dev_top_cfg.i_cfg.strap_is_rp) ||
        ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && !m_pcie_dev_top_cfg.i_cfg.strap_is_rp)
      ) {
        if (m_tlp_type inside {
          CDN_HPA_PCIE_TLP_TYPE_MRd_32,
          CDN_HPA_PCIE_TLP_TYPE_MRd_64,
          CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,
          CDN_HPA_PCIE_TLP_TYPE_MRdLk_64,
          CDN_HPA_PCIE_TLP_TYPE_IORd,
          CDN_HPA_PCIE_TLP_TYPE_CfgRd0,
          CDN_HPA_PCIE_TLP_TYPE_CfgRd1,
          CDN_HPA_PCIE_TLP_TYPE_UIOMRd
        }) {
          32*m_tlp_length + ((8*m_tlp_addr)%parameters_cfg_pkg::KMAX_AXI_S_DATA_WIDTH) <= parameters_cfg_pkg::KMAX_AXI_S_DATA_WIDTH*m_pcie_dev_top_cfg.i_cfg.decode_axi_slv_read_max_beats(0);
          if(!is_perf_mode) {
            (parameters_cfg_pkg::KMAX_AXI_S_DATA_WIDTH*m_pcie_dev_top_cfg.i_cfg.decode_axi_slv_read_max_beats(0) < 8*4096) -> (m_tlp_length != 0);
          }
        }
        else if (m_tlp_type inside {
          CDN_HPA_PCIE_TLP_TYPE_MWr_32,
          CDN_HPA_PCIE_TLP_TYPE_MWr_64,
          CDN_HPA_PCIE_TLP_TYPE_DMWr_32,
          CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
          CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,
          CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
          CDN_HPA_PCIE_TLP_TYPE_Swap_32,
          CDN_HPA_PCIE_TLP_TYPE_Swap_64,
          CDN_HPA_PCIE_TLP_TYPE_Cas_32,
          CDN_HPA_PCIE_TLP_TYPE_Cas_64,
          CDN_HPA_PCIE_TLP_TYPE_IOWr,
          CDN_HPA_PCIE_TLP_TYPE_CfgWr0,
          CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
          CDN_HPA_PCIE_TLP_TYPE_MsgD,
          CDN_HPA_PCIE_TLP_TYPE_UIOMWr
        }) {
          32*m_tlp_length + ((8*m_tlp_addr)%parameters_cfg_pkg::KMAX_AXI_S_DATA_WIDTH) <= parameters_cfg_pkg::KMAX_AXI_S_DATA_WIDTH*m_pcie_dev_top_cfg.i_cfg.decode_axi_slv_write_max_beats(0);
          if(!is_perf_mode) {
            (parameters_cfg_pkg::KMAX_AXI_S_DATA_WIDTH*m_pcie_dev_top_cfg.i_cfg.decode_axi_slv_write_max_beats(0) < 8*4096) -> (m_tlp_length != 0);
          }
        }
      }
    }

    //--------------------------------------------------------------------------
    // Constraint: axi_slave_region_msg_payload_limitations_cs
    // Limits messages payload size when region access is enabled.
    //--------------------------------------------------------------------------
    constraint axi_slave_region_msg_payload_limitations_cs {
      if (
        ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && m_pcie_dev_top_cfg.i_cfg.strap_is_rp) ||
        ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && !m_pcie_dev_top_cfg.i_cfg.strap_is_rp)
      ) {
        ((m_pcie_dev_top_cfg.i_cfg.k_axi_s_rg_access[0]) && (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD)) -> (m_tlp_length inside {[1:8]});
      }
    }

    //--------------------------------------------------------------------------
    // Constraint: axi_address_translation_request_payload_limit_cs
    // AXI Bridge does not support address translation requests with length > 2.
    //--------------------------------------------------------------------------
    constraint axi_address_translation_request_payload_limit_cs {
      (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) -> (m_tlp_length == 2);
      (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) -> (m_tlp_addr[2:0] == 3'b000);
    }

    //--------------------------------------------------------------------------
    // Constraint: axi_slave_flit_mode_l_dw_be_cs
    // AXI Bridge requires OHC A set for requests with l_dw_be!='hF.
    //--------------------------------------------------------------------------
    constraint axi_slave_flit_mode_l_dw_be_cs {
      if (is_flit_mode &&
      m_tlp_type inside {
        CDN_HPA_PCIE_TLP_TYPE_MWr_32,
        CDN_HPA_PCIE_TLP_TYPE_MWr_64,
        CDN_HPA_PCIE_TLP_TYPE_DMWr_32,
        CDN_HPA_PCIE_TLP_TYPE_DMWr_64
      }
    ) {
      ((m_tlp_length != 1) && (m_tlp_last_dw_be != 'b1111)) -> (m_ohc_hdr.ohc_a_present == 'b1);
    }
  }
  `endif // BRIDGE

  constraint uio_lower_addr_c {
    m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD -> m_tlp_cpl_lower_addr[1:0] == 0;
  }

  //------------------------------------------------------------------------
  // Property: policy_q
  // Queue of handlers to TLP policy objects.
  //------------------------------------------------------------------------
  local rand cdn_hpa_pcie_tlp_policy policy_q[$];

  //------------------------------------------------------------------------
  // Function: push_policy
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  virtual function void push_policy(cdn_hpa_pcie_tlp_policy policy);
    if (policy == null) begin
      `uvm_error(get_type_name(), $sformatf("Input object handler 'policy' is NULL"))
      return;
    end
    policy.set_item(this);
    policy_q.push_back(policy);
  endfunction : push_policy

  //------------------------------------------------------------------------
  // Function: size
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  virtual function int size();
    return policy_q.size();
  endfunction : size

  //------------------------------------------------------------------------
  // Function: delete
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  virtual function void delete(input integer index);
    policy_q.delete(index);
  endfunction : delete

  //------------------------------------------------------------------------
  // Function: push_policy_by_type
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  virtual function void push_policy_by_type(uvm_object_wrapper pcy_type, string inst_name);
    cdn_hpa_pcie_tlp_policy policy;
    uvm_coreservice_t cs = uvm_coreservice_t::get();
    uvm_factory factory = cs.get_factory();
    uvm_object object = factory.create_object_by_type(pcy_type, "", inst_name);
    if (object == null) begin
      `uvm_error(get_type_name(), $sformatf("Cannot create policy by type"))
      return;
    end
    if (!$cast(policy, object)) begin
      `uvm_error(get_type_name(), $sformatf("Cannot cast object to the policy"))
      return;
    end
    push_policy(policy);
  endfunction : push_policy_by_type

  function void assign_payload_size(int sizee);
    // Allocate memory for the dynamic array
    $display("assign_payload_size sizee = %d",sizee);
    m_tlp_payload = new[sizee];
  endfunction
  
  //------------------------------------------------------------------------
  // Function: push_policy_by_name
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  virtual function void push_policy_by_name(string type_name, string inst_name);
    cdn_hpa_pcie_tlp_policy policy;
    uvm_coreservice_t cs = uvm_coreservice_t::get();
    uvm_factory factory = cs.get_factory();
    uvm_object object = factory.create_object_by_name(type_name, "", inst_name);
    if (object == null) begin
      `uvm_error(get_type_name(), $sformatf("Cannot create policy with type name: %s", type_name))
      return;
    end
    if (!$cast(policy, object)) begin
      `uvm_error(get_type_name(), $sformatf("Cannot cast object of type name '%s' to the policy", type_name))
      return;
    end
    push_policy(policy);
  endfunction : push_policy_by_name

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  // The field macros are required for packing/unpacking and checking.
  `uvm_object_utils_begin(cdn_hpa_pcie_tlp)
  // TODO
  //`uvm_field_enum(,,UVM_DEFAULT + UVM_NOPACK + UVM_NOCOMPARE + UVM_NOPRINT + UVM_NORECORD)
  //  `uvm_field_enum(cdn_hpa_pcie_tlp_fmt_t, m_hdr_fmt, UVM_ALL_ON | UVM_NOPACK)
  //  `uvm_field_int(m_hdr_type, UVM_ALL_ON|UVM_NOPACK)



  `uvm_object_utils_end

  //------------------------------------------------------------------------
  // METHODS.
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  function new(string name = "cdn_hpa_pcie_tlp");
    super.new(name);
    //Turnoff the constraint. Suspecting Tool issue : This cause CFG/IO payload to be zero
    //Enable in msg sequence alone
    //c_msg_payload_constr.constraint_mode(0);
    errored_ecrc = 0;
    m_orphan_tlp_prefix = 0;
    is_perf_mode = is_ob_p_perf_mode_enabled()||is_ib_p_perf_mode_enabled();
  endfunction : new
  //---------------------------------------------------------------------------
  // Function: is_ob_p_perf_mode_enabled
  // Returns true if plusarg 'OB_POSTED_PERF_MODE' is equal to 1.
  //---------------------------------------------------------------------------
  local function bit is_ob_p_perf_mode_enabled();
    bit result;
    void'($value$plusargs("OB_POSTED_PERF_MODE=%0d",result));
    return result;
  endfunction : is_ob_p_perf_mode_enabled

  //---------------------------------------------------------------------------
  // Function: is_ob_np_perf_mode_enabled
  // Returns true if plusarg 'OB_NONPOSTED_PERF_MODE' is equal to 1.
  //---------------------------------------------------------------------------
  local function bit is_ib_p_perf_mode_enabled();
    bit result;
    void'($value$plusargs("IB_POSTED_PERF_MODE=%0d",result));
    return result;
  endfunction : is_ib_p_perf_mode_enabled

  function void print_msg(uvm_printer printer);
    printer.print_string("m_tlp_msg_code", m_tlp_msg_code.name());
    printer.print_string("m_tlp_msg_rout_type", m_tlp_msg_rout_type.name());
    printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);

    if(m_tlp_msg_rout_type==CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
      printer.print_int("m_tlp_completer_id", m_tlp_completer_id, 16);
    end
    //ADD VDM separately
    if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin
      printer.print_int("m_tlp_vendor_id", m_tlp_vendor_id, 16);
      printer.print_int("m_tlp_vendor_msg_4th_DW", m_tlp_vendor_msg, 32);
    end

    if(cxl_mode && vdm_for_cxl==1 &&(m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0}) && (m_cxl_vdm_pm_logical_opcode != CDN_HPA_VDM_STD_VD_TYPE0)) begin //{
      if(print_rsvd_bits) begin
        printer.print_int("msg_pm_cxl_vnd_msg_byte_12_14_rsvd", msg_pm_cxl_vnd_msg_byte_12_14_rsvd,$bits(msg_pm_cxl_vnd_msg_byte_12_14_rsvd));
      end
      printer.print_string("m_cxl_vdm_pm_logical_opcode",m_cxl_vdm_pm_logical_opcode.name());
      if(print_rsvd_bits) begin
        printer.print_int("m_cxl_vdm_pm_agt_id_rsvd_bit", m_cxl_vdm_pm_agt_id_rsvd_bit,$bits(m_cxl_vdm_pm_agt_id_rsvd_bit));
      end
      printer.print_int("m_cxl_vdm_pm_agt_id", m_cxl_vdm_pm_agt_id,$bits(m_cxl_vdm_pm_agt_id));
      printer.print_int("m_cxl_vdm_parameter", m_cxl_vdm_parameter,$bits(m_cxl_vdm_parameter));
      printer.print_int("m_cxl_vdm_payload", m_cxl_vdm_payload,$bits(m_cxl_vdm_payload));
      if(cxl_version == 2 && cxl_mode ==1) begin // MP
        if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_agt_info_param_byte1_rsvd", m_cxl_vdm_agt_info_param_byte1_rsvd,$bits(m_cxl_vdm_agt_info_param_byte1_rsvd));
          end
          printer.print_int("m_cxl_vdm_agt_info_index", m_cxl_vdm_agt_info_index,$bits(m_cxl_vdm_agt_info_index));
          printer.print_int("m_cxl_vdm_agt_info_req_or_rsp", m_cxl_vdm_agt_info_req_or_rsp,$bits(m_cxl_vdm_agt_info_req_or_rsp));
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_agt_info_payload_rsvd_93_3", m_cxl_vdm_agt_info_payload_rsvd_93_3,$bits(m_cxl_vdm_agt_info_payload_rsvd_93_3));
          end
          printer.print_int("m_cxl_vdm_agt_info_capability_vector_bit1", m_cxl_vdm_agt_info_capability_vector_bit1,$bits(m_cxl_vdm_agt_info_capability_vector_bit1));
          printer.print_int("m_cxl_vdm_agt_info_capability_vector_bit0", m_cxl_vdm_agt_info_capability_vector_bit0,$bits(m_cxl_vdm_agt_info_capability_vector_bit0));
        end
        if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_resetprep_param_byte0_1_rsvd", m_cxl_vdm_resetprep_param_byte0_1_rsvd,$bits(m_cxl_vdm_resetprep_param_byte0_1_rsvd));
          end
          printer.print_int("m_cxl_vdm_resetprep_req_or_rsp", m_cxl_vdm_resetprep_req_or_rsp,$bits(m_cxl_vdm_resetprep_req_or_rsp));
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_resetprep_payload_rsvd_95_9", m_cxl_vdm_resetprep_payload_rsvd_95_9,$bits(m_cxl_vdm_resetprep_payload_rsvd_95_9));
          end
          printer.print_int("m_cxl_vdm_resetprep_prep_type", m_cxl_vdm_resetprep_prep_type,$bits(m_cxl_vdm_resetprep_prep_type));
          printer.print_int("m_cxl_vdm_resetprep_reset_type", m_cxl_vdm_resetprep_reset_type,$bits(m_cxl_vdm_resetprep_reset_type));
        end
        if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_pmreq_param_byte0_1_rsvd", m_cxl_vdm_pmreq_param_byte0_1_rsvd,$bits(m_cxl_vdm_pmreq_param_byte0_1_rsvd));
          end
          printer.print_int("m_cxl_vdm_pmreq_go", m_cxl_vdm_pmreq_go,$bits(m_cxl_vdm_pmreq_go));
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_pmreq_param_bit1_rsvd", m_cxl_vdm_pmreq_param_bit1_rsvd,$bits(m_cxl_vdm_pmreq_param_bit1_rsvd));
          end
          printer.print_int("m_cxl_vdm_pmreq_req_or_rsp", m_cxl_vdm_pmreq_req_or_rsp,$bits(m_cxl_vdm_pmreq_req_or_rsp));
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_pmreq_payload_rsvd", m_cxl_vdm_pmreq_payload_rsvd,$bits(m_cxl_vdm_pmreq_payload_rsvd));
          end
          printer.print_int("m_cxl_vdm_pmreq_ltr_2", m_cxl_vdm_pmreq_ltr_2,$bits(m_cxl_vdm_pmreq_ltr_2));
        end
        if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_GPF) begin
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_gpf_param_byte0_1_rsvd", m_cxl_vdm_gpf_param_byte0_1_rsvd,$bits(m_cxl_vdm_gpf_param_byte0_1_rsvd));
          end
          printer.print_int("m_cxl_vdm_gpf_req_or_rsp", m_cxl_vdm_gpf_req_or_rsp,$bits(m_cxl_vdm_gpf_req_or_rsp));
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_gpf_payload_rsvd_95_18", m_cxl_vdm_gpf_payload_rsvd_95_18,$bits(m_cxl_vdm_gpf_payload_rsvd_95_18));
          end
          printer.print_int("m_cxl_vdm_gpf_payload_phase", m_cxl_vdm_gpf_payload_phase,$bits(m_cxl_vdm_gpf_payload_phase));
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_gpf_payload_rsvd_15_9", m_cxl_vdm_gpf_payload_rsvd_15_9,$bits(m_cxl_vdm_gpf_payload_rsvd_15_9));
          end
          printer.print_int("m_cxl_vdm_gpf_status_bit8", m_cxl_vdm_gpf_status_bit8,$bits(m_cxl_vdm_gpf_status_bit8));
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_gpf_payload_rsvd_7_2", m_cxl_vdm_gpf_payload_rsvd_7_2,$bits(m_cxl_vdm_gpf_payload_rsvd_7_2));
          end
          printer.print_int("m_cxl_vdm_gpf_payload_bit1", m_cxl_vdm_gpf_payload_bit1,$bits(m_cxl_vdm_gpf_payload_bit1));
          printer.print_int("m_cxl_vdm_gpf_payload_bit0", m_cxl_vdm_gpf_payload_bit0,$bits(m_cxl_vdm_gpf_payload_bit0));
        end
        if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) begin
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_crd_rtn_param_field_rsvd", m_cxl_vdm_crd_rtn_param_field_rsvd,$bits(m_cxl_vdm_crd_rtn_param_field_rsvd));
            printer.print_int("m_cxl_vdm_crd_rtn_payload_rsvd", m_cxl_vdm_crd_rtn_payload_rsvd,$bits(m_cxl_vdm_crd_rtn_payload_rsvd));
          end
          printer.print_int("m_cxl_vdm_crd_rtn_payload_tgt_agt_id", m_cxl_vdm_crd_rtn_payload_tgt_agt_id,$bits(m_cxl_vdm_crd_rtn_payload_tgt_agt_id));
          printer.print_int("m_cxl_vdm_crd_rtn_payload_num_credits", m_cxl_vdm_crd_rtn_payload_num_credits,$bits(m_cxl_vdm_crd_rtn_payload_num_credits));
        end
      end //}
    end else begin
      if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin
        if(print_rsvd_bits) begin
          printer.print_int("m_cxl_vdm_agt_info_param_byte1_rsvd", m_cxl_vdm_agt_info_param_byte1_rsvd,$bits(m_cxl_vdm_agt_info_param_byte1_rsvd));
        end
        printer.print_int("m_cxl_vdm_agt_info_index", m_cxl_vdm_agt_info_index,$bits(m_cxl_vdm_agt_info_index));
        printer.print_int("m_cxl_vdm_agt_info_req_or_rsp", m_cxl_vdm_agt_info_req_or_rsp,$bits(m_cxl_vdm_agt_info_req_or_rsp));
        if(print_rsvd_bits) begin
          printer.print_int("m_cxl_vdm_agt_info_payload_rsvd", m_cxl_vdm_agt_info_payload_rsvd,$bits(m_cxl_vdm_agt_info_payload_rsvd));
        end
        printer.print_int("m_cxl_vdm_agt_info_revision_id", m_cxl_vdm_agt_info_revision_id,$bits(m_cxl_vdm_agt_info_revision_id));
      end
      if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin
        if(print_rsvd_bits) begin
          printer.print_int("m_cxl_vdm_resetprep_param_byte0_1_rsvd", m_cxl_vdm_resetprep_param_byte0_1_rsvd,$bits(m_cxl_vdm_resetprep_param_byte0_1_rsvd));
        end
        printer.print_int("m_cxl_vdm_resetprep_req_or_rsp", m_cxl_vdm_resetprep_req_or_rsp,$bits(m_cxl_vdm_resetprep_req_or_rsp));
        if(print_rsvd_bits) begin
          printer.print_int("m_cxl_vdm_resetprep_payload_rsvd", m_cxl_vdm_resetprep_payload_rsvd,$bits(m_cxl_vdm_resetprep_payload_rsvd));
        end
        printer.print_int("m_cxl_vdm_resetprep_phase", m_cxl_vdm_resetprep_phase,$bits(m_cxl_vdm_resetprep_phase));
        printer.print_int("m_cxl_vdm_resetprep_prep_type", m_cxl_vdm_resetprep_prep_type,$bits(m_cxl_vdm_resetprep_prep_type));
        printer.print_int("m_cxl_vdm_resetprep_reset_type", m_cxl_vdm_resetprep_reset_type,$bits(m_cxl_vdm_resetprep_reset_type));
      end
      if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin
        if(print_rsvd_bits) begin
          printer.print_int("m_cxl_vdm_pmreq_param_byte0_1_rsvd", m_cxl_vdm_pmreq_param_byte0_1_rsvd,$bits(m_cxl_vdm_pmreq_param_byte0_1_rsvd));
        end
        printer.print_int("m_cxl_vdm_pmreq_go", m_cxl_vdm_pmreq_go,$bits(m_cxl_vdm_pmreq_go));
        printer.print_int("m_cxl_vdm_pmreq_ea", m_cxl_vdm_pmreq_ea,$bits(m_cxl_vdm_pmreq_ea));
        printer.print_int("m_cxl_vdm_pmreq_req_or_rsp", m_cxl_vdm_pmreq_req_or_rsp,$bits(m_cxl_vdm_pmreq_req_or_rsp));
        if(print_rsvd_bits) begin
          printer.print_int("m_cxl_vdm_pmreq_payload_rsvd", m_cxl_vdm_pmreq_payload_rsvd,$bits(m_cxl_vdm_pmreq_payload_rsvd));
        end
        printer.print_int("m_cxl_vdm_pmreq_ltr", m_cxl_vdm_pmreq_ltr,$bits(m_cxl_vdm_pmreq_ltr));
      end
      if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) begin
        if(print_rsvd_bits) begin
          printer.print_int("m_cxl_vdm_crd_rtn_param_field_rsvd", m_cxl_vdm_crd_rtn_param_field_rsvd,$bits(m_cxl_vdm_crd_rtn_param_field_rsvd));
          printer.print_int("m_cxl_vdm_crd_rtn_payload_rsvd", m_cxl_vdm_crd_rtn_payload_rsvd,$bits(m_cxl_vdm_crd_rtn_payload_rsvd));
        end
        printer.print_int("m_cxl_vdm_crd_rtn_payload_tgt_agt_id", m_cxl_vdm_crd_rtn_payload_tgt_agt_id,$bits(m_cxl_vdm_crd_rtn_payload_tgt_agt_id));
        printer.print_int("m_cxl_vdm_crd_rtn_payload_num_credits", m_cxl_vdm_crd_rtn_payload_num_credits,$bits(m_cxl_vdm_crd_rtn_payload_num_credits));
      end
    end //}

    if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin
      printer.print_string("m_tlp_vdm_msg_subtype", m_tlp_vdm_msg_subtype.name());
      if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_HIER_ID) begin
        printer.print_int("m_tlp_hier_vmsg_hierarchy_id", m_tlp_hier_vmsg_hierarchy_id,16);
        printer.print_int("m_tlp_hier_vmsg_guid_authority_id", m_tlp_hier_vmsg_guid_authority_id,8);
        printer.print_int("m_tlp_hier_vmsg_system_guid", m_tlp_hier_vmsg_system_guid,144);
      end
      if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_FRS) begin
        printer.print_string("m_tlp_frs_msg_reason", m_tlp_frs_msg_reason.name());
      end
      if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_LN) begin
        printer.print_int("m_tlp_ln_msg_cacheline_addr", m_tlp_ln_msg_cacheline_addr,58);
        printer.print_int("m_tlp_ln_msg_nr", m_tlp_ln_msg_nr,2);
      end
    end

    // IF LTR message add
    if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin
      printer.print_int("m_tlp_ltr_msg_no_snoop_latency",m_tlp_ltr_msg_no_snoop_latency,16);
      printer.print_int("m_tlp_ltr_msg_snoop_latency",m_tlp_ltr_msg_snoop_latency,16);
    end

    // If ATS mesage
    if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin
      printer.print_int("m_inv_cpl_cnt",m_inv_cpl_cnt,3);
      printer.print_int("m_tlp_itag_vector",m_tlp_itag_vector,32);
    end

    if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
      printer.print_int("m_tlp_itag",m_tlp_itag,5);
    end
    // OBFF message
    if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin
      printer.print_string("m_obffCode",m_obffCode.name());
    end

    // IDE FAIL message
    if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Fail) begin
      printer.print_int("msg_ide_fail_stream_id",msg_ide_fail_stream_id, 8);
    end

    // IDE SYNC message
    if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Sync) begin
      printer.print_int("msg_ide_sync_pr_sent_cnt_cpl",msg_ide_sync_pr_sent_cnt_cpl, 8);
      printer.print_int("msg_ide_sync_pr_sent_cnt_np",msg_ide_sync_pr_sent_cnt_np, 8);
    end

    // IDE ESCORT message
    if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin
      printer.print_int("msg_ide_escort_sse",msg_ide_escort_sse, 2);
    end

    // PTM message
    if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD})) begin
      printer.print_int("m_ptmMasterTime",m_ptmMasterTime,64);
      printer.print_int("m_ptmPropagationDelay",m_ptmPropagationDelay,32);
    end

    // ATS - PRI
    if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request}) begin
      printer.print_int("m_page_addr",m_page_addr,52);
      printer.print_int("m_prReadRequested",m_prReadRequested,1);
      printer.print_int("m_prWriteRequested",m_prWriteRequested,1);
      printer.print_int("m_prLastRequest",m_prLastRequest,1);
    end
    if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}) begin
      printer.print_int("m_prGroupIndex",m_prGroupIndex,9);
    end

    // Page request response
    if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}) begin
      printer.print_int("m_prgResponseCode",m_prgResponseCode,4);
    end
  endfunction: print_msg
  
  //------------------------------------------------------------------------
  // Function: do_print
  // Extend the do_print method to print relevent fields based on TLP type
  //------------------------------------------------------------------------
  function void do_print (uvm_printer printer);
    bit [7:0] trailer_size_decoded;
    int       num_prefix_print;
    super.do_print(printer);
    printer.print_int("is_ide_tlp",is_ide_tlp,$bits(is_ide_tlp));
    printer.print_int("is_flit_mode",is_flit_mode,$bits(is_flit_mode));
    printer.print_int("pcie_6_1_support",pcie_6_1_support,$bits(pcie_6_1_support));
    printer.print_int("cxl_mode",cxl_mode,$bits(cxl_mode));
    printer.print_int("cxl_sbsa_test",cxl_sbsa_test,$bits(cxl_sbsa_test));
    printer.print_int("is_cxl_pbr_mode",is_cxl_pbr_mode,$bits(is_cxl_pbr_mode));
    printer.print_string("hpa_generation",hpa_generation.name());
    printer.print_int("apply_directed_tlp",apply_directed_tlp,$bits(apply_directed_tlp));
    printer.print_int("axi_region_prog",axi_region_prog,$bits(axi_region_prog));
    printer.print_string("m_tlp_req_type", m_tlp_req_type.name());
    // Byte 0 to 3 of first DW is common for all TLPs
    if(is_flit_mode) begin //{
      printer.print_string("m_tlp_type", m_tlp_type.name());
      printer.print_string("m_tlp_trans_type", m_tlp_trans_type.name());
      printer.print_string("m_tlp_vdm_msg_subtype", m_tlp_vdm_msg_subtype.name());
      printer.print_int("m_type",{m_hdr_fmt,m_hdr_type},8);
      printer.print_int("m_tlp_tc",m_tlp_tc,$bits(m_tlp_tc));
      printer.print_string("m_ohc_hdr",$sformatf("%0p",m_ohc_hdr));
      printer.print_string("m_ts", m_ts.name());
      printer.print_int("m_tlp_attr",{m_tlp_attr1,m_tlp_attr0},3);
      printer.print_int("m_tlp_length",m_tlp_length,$bits(m_tlp_length));
      if(m_tlp_trans_type !=CDN_HPA_PCIE_TRANS_MSG_TYPE) printer.print_int("m_tlp_tag", {m_tlp_14_bit_tagscale,m_tlp_t9,m_tlp_t8,m_tlp_tag}, 14);
      if (pcie_6_1_support && m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1})) printer.print_int("vendor_definition_vd_msg_7bits",vendor_definition_vd_msg,$bits(vendor_definition_vd_msg));//vendor_definition_vd_msg
      printer.print_int("m_tlp_ep",m_tlp_ep,$bits(m_tlp_ep));
    end else begin //}{
      printer.print_string("m_tlp_type", m_tlp_type.name());
      printer.print_string("m_tlp_trans_type", m_tlp_trans_type.name());
      printer.print_string("m_tlp_vdm_msg_subtype", m_tlp_vdm_msg_subtype.name());
      printer.print_string("m_hdr_fmt",m_hdr_fmt.name());
      printer.print_int("m_hdr_type",m_hdr_type,$bits(m_hdr_type));
      printer.print_int("m_tlp_t9",m_tlp_t9,1);
      printer.print_int("m_tlp_tc",m_tlp_tc,$bits(m_tlp_tc));
      printer.print_int("m_tlp_t8",m_tlp_t8,1);
      printer.print_int("m_tlp_attr1",m_tlp_attr1,1);
      printer.print_int("m_tlp_ln",m_tlp_ln,1);
      printer.print_int("m_tlp_th",m_tlp_th,1);
      printer.print_int("m_tlp_td",m_tlp_td,1);
      printer.print_int("m_tlp_ep",m_tlp_ep,1);
      printer.print_int("m_tlp_attr0",m_tlp_attr0,2);
      printer.print_string("m_tlp_at_type",m_tlp_at_type.name());
      printer.print_int("m_tlp_length",m_tlp_length,10);
      printer.print_int("m_tlp_tag", m_tlp_tag, 8);
      if (pcie_6_1_support && m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1})) printer.print_int("vendor_definition_vd_msg_7bits",vendor_definition_vd_msg,$bits(vendor_definition_vd_msg));//vendor_definition_vd_msg
    end //}

    case (m_tlp_trans_type) inside
      CDN_HPA_PCIE_TRANS_RSVD_TYPE : begin
        if (m_tlp_rout_type==CDN_HPA_PCIE_TLP_ROUT_BY_ADDR) begin
          // TODO check registering a strcture
          if(is_flit_mode) printer.print_int("implcit_byte_enable_mem_tlps", implcit_byte_enable_mem_tlps, 1);
          if(!is_flit_mode || (!implcit_byte_enable_mem_tlps && is_flit_mode)) begin
            printer.print_int("m_tlp_last_dw_be", m_tlp_last_dw_be, 4);
            printer.print_int("m_tlp_first_dw_be", m_tlp_first_dw_be, 4);
          end
          printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
          printer.print_int("m_tlp_addr",m_tlp_addr,64);
          printer.print_string("m_tlp_at_type",m_tlp_at_type.name());

          if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            if(!is_flit_mode) printer.print_int("m_tlp_ats_tr_nw_field",m_tlp_ats_tr_nw_field,1);
            if(cxl_mode) printer.print_int("m_cxl_src",m_cxl_src,1);
          end
        end
        else if(m_tlp_msg_rout_type==CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
          print_msg(printer);
          //printer.print_string("m_tlp_msg_code", m_tlp_msg_code.name());
          //printer.print_string("m_tlp_msg_rout_type", m_tlp_msg_rout_type.name());
          //printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);

          //if(m_tlp_msg_rout_type==CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
          //  printer.print_int("m_tlp_completer_id", m_tlp_completer_id, 16);
          //end
        end
      end
 CDN_HPA_PCIE_TRANS_MEM_TYPE : begin
        // TODO check registering a strcture
        if(is_flit_mode) printer.print_int("implcit_byte_enable_mem_tlps", implcit_byte_enable_mem_tlps, 1);
        if(!is_flit_mode || (!implcit_byte_enable_mem_tlps && is_flit_mode)) begin
          printer.print_int("m_tlp_last_dw_be", m_tlp_last_dw_be, 4);
          printer.print_int("m_tlp_first_dw_be", m_tlp_first_dw_be, 4);
        end
        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
        printer.print_int("m_tlp_addr",m_tlp_addr,64);
        printer.print_string("m_tlp_at_type",m_tlp_at_type.name());

        if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
          if(!is_flit_mode) printer.print_int("m_tlp_ats_tr_nw_field",m_tlp_ats_tr_nw_field,1);
          if(cxl_mode) printer.print_int("m_cxl_src",m_cxl_src,1);
        end
      end
      CDN_HPA_PCIE_TRANS_IO_TYPE : begin
        printer.print_int("m_tlp_last_dw_be", m_tlp_last_dw_be, 4);
        printer.print_int("m_tlp_first_dw_be", m_tlp_first_dw_be, 4);
        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
        printer.print_int("m_tlp_addr",m_tlp_addr,64);
      end
      CDN_HPA_PCIE_TRANS_CFG_TYPE : begin
        printer.print_int("m_tlp_last_dw_be", m_tlp_last_dw_be, 4);
        printer.print_int("m_tlp_first_dw_be", m_tlp_first_dw_be, 4);

        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
        printer.print_int("m_tlp_completer_id", m_tlp_completer_id, 16);
        printer.print_int("m_tlp_ext_reg_num", m_tlp_ext_reg_num, 4);
        printer.print_int("m_tlp_reg_num", m_tlp_reg_num, 8);
        printer.print_int("is_blocking",is_blocking,$bits(is_blocking));
        printer.print_int("unique_id",unique_id,$bits(unique_id));
      end
      CDN_HPA_PCIE_TRANS_MSG_TYPE : begin
        printer.print_string("m_tlp_msg_code", m_tlp_msg_code.name());
        printer.print_string("m_tlp_msg_rout_type", m_tlp_msg_rout_type.name());
        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);

        if(m_tlp_msg_rout_type==CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
          printer.print_int("m_tlp_completer_id", m_tlp_completer_id, 16);
        end
        //ADD VDM separately
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin
          printer.print_int("m_tlp_vendor_id", m_tlp_vendor_id, 16);
          printer.print_int("m_tlp_vendor_msg_4th_DW", m_tlp_vendor_msg, 32);
        end

        if(cxl_mode && vdm_for_cxl==1 &&(m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0}) && (m_cxl_vdm_pm_logical_opcode != CDN_HPA_VDM_STD_VD_TYPE0)) begin //{
          if(print_rsvd_bits) begin
            printer.print_int("msg_pm_cxl_vnd_msg_byte_12_14_rsvd", msg_pm_cxl_vnd_msg_byte_12_14_rsvd,$bits(msg_pm_cxl_vnd_msg_byte_12_14_rsvd));
          end
          printer.print_string("m_cxl_vdm_pm_logical_opcode",m_cxl_vdm_pm_logical_opcode.name());
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_pm_agt_id_rsvd_bit", m_cxl_vdm_pm_agt_id_rsvd_bit,$bits(m_cxl_vdm_pm_agt_id_rsvd_bit));
          end
          printer.print_int("m_cxl_vdm_pm_agt_id", m_cxl_vdm_pm_agt_id,$bits(m_cxl_vdm_pm_agt_id));
          printer.print_int("m_cxl_vdm_parameter", m_cxl_vdm_parameter,$bits(m_cxl_vdm_parameter));
          printer.print_int("m_cxl_vdm_payload", m_cxl_vdm_payload,$bits(m_cxl_vdm_payload));
          if(cxl_version == 2 && cxl_mode ==1) begin // MP
            if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_agt_info_param_byte1_rsvd", m_cxl_vdm_agt_info_param_byte1_rsvd,$bits(m_cxl_vdm_agt_info_param_byte1_rsvd));
              end
              printer.print_int("m_cxl_vdm_agt_info_index", m_cxl_vdm_agt_info_index,$bits(m_cxl_vdm_agt_info_index));
              printer.print_int("m_cxl_vdm_agt_info_req_or_rsp", m_cxl_vdm_agt_info_req_or_rsp,$bits(m_cxl_vdm_agt_info_req_or_rsp));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_agt_info_payload_rsvd_93_3", m_cxl_vdm_agt_info_payload_rsvd_93_3,$bits(m_cxl_vdm_agt_info_payload_rsvd_93_3));
              end
              printer.print_int("m_cxl_vdm_agt_info_capability_vector_bit1", m_cxl_vdm_agt_info_capability_vector_bit1,$bits(m_cxl_vdm_agt_info_capability_vector_bit1));
              printer.print_int("m_cxl_vdm_agt_info_capability_vector_bit0", m_cxl_vdm_agt_info_capability_vector_bit0,$bits(m_cxl_vdm_agt_info_capability_vector_bit0));
            end
            if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_resetprep_param_byte0_1_rsvd", m_cxl_vdm_resetprep_param_byte0_1_rsvd,$bits(m_cxl_vdm_resetprep_param_byte0_1_rsvd));
              end
              printer.print_int("m_cxl_vdm_resetprep_req_or_rsp", m_cxl_vdm_resetprep_req_or_rsp,$bits(m_cxl_vdm_resetprep_req_or_rsp));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_resetprep_payload_rsvd_95_9", m_cxl_vdm_resetprep_payload_rsvd_95_9,$bits(m_cxl_vdm_resetprep_payload_rsvd_95_9));
              end
              printer.print_int("m_cxl_vdm_resetprep_prep_type", m_cxl_vdm_resetprep_prep_type,$bits(m_cxl_vdm_resetprep_prep_type));
              printer.print_int("m_cxl_vdm_resetprep_reset_type", m_cxl_vdm_resetprep_reset_type,$bits(m_cxl_vdm_resetprep_reset_type));
            end
            if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_pmreq_param_byte0_1_rsvd", m_cxl_vdm_pmreq_param_byte0_1_rsvd,$bits(m_cxl_vdm_pmreq_param_byte0_1_rsvd));
              end
              printer.print_int("m_cxl_vdm_pmreq_go", m_cxl_vdm_pmreq_go,$bits(m_cxl_vdm_pmreq_go));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_pmreq_param_bit1_rsvd", m_cxl_vdm_pmreq_param_bit1_rsvd,$bits(m_cxl_vdm_pmreq_param_bit1_rsvd));
              end
              printer.print_int("m_cxl_vdm_pmreq_req_or_rsp", m_cxl_vdm_pmreq_req_or_rsp,$bits(m_cxl_vdm_pmreq_req_or_rsp));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_pmreq_payload_rsvd", m_cxl_vdm_pmreq_payload_rsvd,$bits(m_cxl_vdm_pmreq_payload_rsvd));
              end
              printer.print_int("m_cxl_vdm_pmreq_ltr_2", m_cxl_vdm_pmreq_ltr_2,$bits(m_cxl_vdm_pmreq_ltr_2));
            end
            if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_GPF) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_gpf_param_byte0_1_rsvd", m_cxl_vdm_gpf_param_byte0_1_rsvd,$bits(m_cxl_vdm_gpf_param_byte0_1_rsvd));
              end
              printer.print_int("m_cxl_vdm_gpf_req_or_rsp", m_cxl_vdm_gpf_req_or_rsp,$bits(m_cxl_vdm_gpf_req_or_rsp));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_gpf_payload_rsvd_95_18", m_cxl_vdm_gpf_payload_rsvd_95_18,$bits(m_cxl_vdm_gpf_payload_rsvd_95_18));
              end
              printer.print_int("m_cxl_vdm_gpf_payload_phase", m_cxl_vdm_gpf_payload_phase,$bits(m_cxl_vdm_gpf_payload_phase));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_gpf_payload_rsvd_15_9", m_cxl_vdm_gpf_payload_rsvd_15_9,$bits(m_cxl_vdm_gpf_payload_rsvd_15_9));
              end
              printer.print_int("m_cxl_vdm_gpf_status_bit8", m_cxl_vdm_gpf_status_bit8,$bits(m_cxl_vdm_gpf_status_bit8));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_gpf_payload_rsvd_7_2", m_cxl_vdm_gpf_payload_rsvd_7_2,$bits(m_cxl_vdm_gpf_payload_rsvd_7_2));
              end
              printer.print_int("m_cxl_vdm_gpf_payload_bit1", m_cxl_vdm_gpf_payload_bit1,$bits(m_cxl_vdm_gpf_payload_bit1));
              printer.print_int("m_cxl_vdm_gpf_payload_bit0", m_cxl_vdm_gpf_payload_bit0,$bits(m_cxl_vdm_gpf_payload_bit0));
            end
            if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_crd_rtn_param_field_rsvd", m_cxl_vdm_crd_rtn_param_field_rsvd,$bits(m_cxl_vdm_crd_rtn_param_field_rsvd));
                printer.print_int("m_cxl_vdm_crd_rtn_payload_rsvd", m_cxl_vdm_crd_rtn_payload_rsvd,$bits(m_cxl_vdm_crd_rtn_payload_rsvd));
              end
              printer.print_int("m_cxl_vdm_crd_rtn_payload_tgt_agt_id", m_cxl_vdm_crd_rtn_payload_tgt_agt_id,$bits(m_cxl_vdm_crd_rtn_payload_tgt_agt_id));
              printer.print_int("m_cxl_vdm_crd_rtn_payload_num_credits", m_cxl_vdm_crd_rtn_payload_num_credits,$bits(m_cxl_vdm_crd_rtn_payload_num_credits));
            end
          end //}
        end else begin
          if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_agt_info_param_byte1_rsvd", m_cxl_vdm_agt_info_param_byte1_rsvd,$bits(m_cxl_vdm_agt_info_param_byte1_rsvd));
            end
            printer.print_int("m_cxl_vdm_agt_info_index", m_cxl_vdm_agt_info_index,$bits(m_cxl_vdm_agt_info_index));
            printer.print_int("m_cxl_vdm_agt_info_req_or_rsp", m_cxl_vdm_agt_info_req_or_rsp,$bits(m_cxl_vdm_agt_info_req_or_rsp));
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_agt_info_payload_rsvd", m_cxl_vdm_agt_info_payload_rsvd,$bits(m_cxl_vdm_agt_info_payload_rsvd));
            end
            printer.print_int("m_cxl_vdm_agt_info_revision_id", m_cxl_vdm_agt_info_revision_id,$bits(m_cxl_vdm_agt_info_revision_id));
          end
          if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_resetprep_param_byte0_1_rsvd", m_cxl_vdm_resetprep_param_byte0_1_rsvd,$bits(m_cxl_vdm_resetprep_param_byte0_1_rsvd));
            end
            printer.print_int("m_cxl_vdm_resetprep_req_or_rsp", m_cxl_vdm_resetprep_req_or_rsp,$bits(m_cxl_vdm_resetprep_req_or_rsp));
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_resetprep_payload_rsvd", m_cxl_vdm_resetprep_payload_rsvd,$bits(m_cxl_vdm_resetprep_payload_rsvd));
            end
            printer.print_int("m_cxl_vdm_resetprep_phase", m_cxl_vdm_resetprep_phase,$bits(m_cxl_vdm_resetprep_phase));
            printer.print_int("m_cxl_vdm_resetprep_prep_type", m_cxl_vdm_resetprep_prep_type,$bits(m_cxl_vdm_resetprep_prep_type));
            printer.print_int("m_cxl_vdm_resetprep_reset_type", m_cxl_vdm_resetprep_reset_type,$bits(m_cxl_vdm_resetprep_reset_type));
          end
          if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_pmreq_param_byte0_1_rsvd", m_cxl_vdm_pmreq_param_byte0_1_rsvd,$bits(m_cxl_vdm_pmreq_param_byte0_1_rsvd));
            end
            printer.print_int("m_cxl_vdm_pmreq_go", m_cxl_vdm_pmreq_go,$bits(m_cxl_vdm_pmreq_go));
            printer.print_int("m_cxl_vdm_pmreq_ea", m_cxl_vdm_pmreq_ea,$bits(m_cxl_vdm_pmreq_ea));
            printer.print_int("m_cxl_vdm_pmreq_req_or_rsp", m_cxl_vdm_pmreq_req_or_rsp,$bits(m_cxl_vdm_pmreq_req_or_rsp));
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_pmreq_payload_rsvd", m_cxl_vdm_pmreq_payload_rsvd,$bits(m_cxl_vdm_pmreq_payload_rsvd));
            end
            printer.print_int("m_cxl_vdm_pmreq_ltr", m_cxl_vdm_pmreq_ltr,$bits(m_cxl_vdm_pmreq_ltr));
          end
          if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) begin
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_crd_rtn_param_field_rsvd", m_cxl_vdm_crd_rtn_param_field_rsvd,$bits(m_cxl_vdm_crd_rtn_param_field_rsvd));
              printer.print_int("m_cxl_vdm_crd_rtn_payload_rsvd", m_cxl_vdm_crd_rtn_payload_rsvd,$bits(m_cxl_vdm_crd_rtn_payload_rsvd));
            end
            printer.print_int("m_cxl_vdm_crd_rtn_payload_tgt_agt_id", m_cxl_vdm_crd_rtn_payload_tgt_agt_id,$bits(m_cxl_vdm_crd_rtn_payload_tgt_agt_id));
            printer.print_int("m_cxl_vdm_crd_rtn_payload_num_credits", m_cxl_vdm_crd_rtn_payload_num_credits,$bits(m_cxl_vdm_crd_rtn_payload_num_credits));
          end
        end //}

        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin
          printer.print_string("m_tlp_vdm_msg_subtype", m_tlp_vdm_msg_subtype.name());
          if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_HIER_ID) begin
            printer.print_int("m_tlp_hier_vmsg_hierarchy_id", m_tlp_hier_vmsg_hierarchy_id,16);
            printer.print_int("m_tlp_hier_vmsg_guid_authority_id", m_tlp_hier_vmsg_guid_authority_id,8);
            printer.print_int("m_tlp_hier_vmsg_system_guid", m_tlp_hier_vmsg_system_guid,144);
          end
          if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_FRS) begin
            printer.print_string("m_tlp_frs_msg_reason", m_tlp_frs_msg_reason.name());
          end
          if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_LN) begin
            printer.print_int("m_tlp_ln_msg_cacheline_addr", m_tlp_ln_msg_cacheline_addr,58);
            printer.print_int("m_tlp_ln_msg_nr", m_tlp_ln_msg_nr,2);
          end
        end

        // IF LTR message add
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin
          printer.print_int("m_tlp_ltr_msg_no_snoop_latency",m_tlp_ltr_msg_no_snoop_latency,16);
          printer.print_int("m_tlp_ltr_msg_snoop_latency",m_tlp_ltr_msg_snoop_latency,16);
        end

        // If ATS mesage
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin
          printer.print_int("m_inv_cpl_cnt",m_inv_cpl_cnt,3);
          printer.print_int("m_tlp_itag_vector",m_tlp_itag_vector,32);
        end

        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
          printer.print_int("m_tlp_itag",m_tlp_itag,5);
        end
        // OBFF message
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin
          printer.print_string("m_obffCode",m_obffCode.name());
        end

        // IDE FAIL message
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Fail) begin
          printer.print_int("msg_ide_fail_stream_id",msg_ide_fail_stream_id, 8);
        end

        // IDE SYNC message
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Sync) begin
          printer.print_int("msg_ide_sync_pr_sent_cnt_cpl",msg_ide_sync_pr_sent_cnt_cpl, 8);
          printer.print_int("msg_ide_sync_pr_sent_cnt_np",msg_ide_sync_pr_sent_cnt_np, 8);
        end

        // IDE ESCORT message
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin
          printer.print_int("msg_ide_escort_sse",msg_ide_escort_sse, 2);
        end

        // PTM message
        if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD})) begin
          printer.print_int("m_ptmMasterTime",m_ptmMasterTime,64);
          printer.print_int("m_ptmPropagationDelay",m_ptmPropagationDelay,32);
        end

        // ATS - PRI
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request}) begin
          printer.print_int("m_page_addr",m_page_addr,52);
          printer.print_int("m_prReadRequested",m_prReadRequested,1);
          printer.print_int("m_prWriteRequested",m_prWriteRequested,1);
          printer.print_int("m_prLastRequest",m_prLastRequest,1);
        end
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}) begin
          printer.print_int("m_prGroupIndex",m_prGroupIndex,9);
        end

        // Page request response
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}) begin
          printer.print_int("m_prgResponseCode",m_prgResponseCode,4);
        end
      end

      CDN_HPA_PCIE_TRANS_CPL_TYPE: begin
        printer.print_int("m_tlp_completer_id", m_tlp_completer_id, 16);
        printer.print_string("m_tlp_cpl_status",m_tlp_cpl_status.name());
        if(!is_flit_mode) printer.print_int("m_tlp_cpl_bcm", m_tlp_cpl_bcm, 1);
        //if(is_flit_mode) printer.print_int("m_completion_segment_differ", m_completion_segment_differ, 1);
        printer.print_int("m_tlp_cpl_byte_cnt", m_tlp_cpl_byte_cnt, 12);

        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
        printer.print_int("m_tlp_cpl_lower_addr", m_tlp_cpl_lower_addr, 12);
        printer.print_int("rsvd_4th_dw", rsvd_4th_dw, 32);
        printer.print_int("rsvd_5th_dw", rsvd_5th_dw, 32);
        printer.print_int("rsvd_6th_dw", rsvd_6th_dw, 32);
        printer.print_int("rsvd_7th_dw", rsvd_7th_dw, 32);
        if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl,CDN_HPA_PCIE_TLP_TYPE_UIORdCpl,CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) begin
          printer.print_int("m_tlp_cpl_cdl", m_tlp_cpl_cdl, 2);
        end
      end

      default : begin
        `uvm_warning(get_type_name(), $psprintf("TLP Type is not valid"))
      end
    endcase

    //Prefixes
    printer.print_int("m_tlp_uses_dedicated_credits",m_tlp_uses_dedicated_credits,$bits(m_tlp_uses_dedicated_credits));
    printer.print_int("m_max_no_of_local_prefixes",m_max_no_of_local_prefixes,$bits(m_max_no_of_local_prefixes));
    printer.print_int("m_local_prefix_possible",m_local_prefix_possible,$bits(m_local_prefix_possible));
    foreach(m_tlp_local_prefix[i]) begin
      printer.print_int($psprintf("m_tlp_local_prefix[%0d]",i),m_tlp_local_prefix[i],$bits(m_tlp_local_prefix[i]));
      printer.print_int($psprintf("m_tlp_local_prefix_data[%0d]",i),m_tlp_local_prefix_data[i],$bits(m_tlp_local_prefix_data[i]));
      printer.print_string($psprintf("m_hdr_type_local_prefix[%0d]",i),m_hdr_type_local_prefix[i].name());
    end
    if(m_ide_prefix_present || (m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE}) || ((m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MSG_TYPE}) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate})))begin
      printer.print_int("m_max_no_of_prefixes",m_max_no_of_prefixes,$bits(m_max_no_of_prefixes));
      if(m_max_no_of_prefixes!=0) begin
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) begin
          printer.print_int("m_tph_present",m_tph_present,1);
          printer.print_int("m_ext_tph_prefix_present",m_ext_tph_prefix_present,1);
        end
        printer.print_int("m_pasid_prefix_present",m_pasid_prefix_present,1);
        printer.print_int("m_ide_prefix_present",m_ide_prefix_present,1);
        printer.print_int("m_sel_stream_possible",m_sel_stream_possible,1);
      end
      if(!is_flit_mode && (m_ext_tph_prefix_present || m_tph_present)) begin
        printer.print_int("m_tlp_st_tag",m_tlp_st_tag,16);
        printer.print_int("m_tlp_ph",m_tlp_ph,2);
      end
      if((hpa_generation == hpa_generation_2) && !is_flit_mode) begin
        printer.print_int("m_ama_valid",m_ama_valid,$bits(m_ama_valid));
        printer.print_int("m_ama_value",m_ama_value,$bits(m_ama_value));
      end
      if(!is_flit_mode && m_pasid_prefix_present) begin
        printer.print_int("m_pasid_value",m_pasid_value,20);
        printer.print_int("m_pasid_pri_value",m_pasid_pri_value,1);
        printer.print_int("m_pasid_exec_value",m_pasid_exec_value,1);
      end
      if(!is_flit_mode && m_ide_prefix_present) begin
        printer.print_int("m_ide_tlp_prefix",m_ide_tlp_prefix,32);
        printer.print_int("m_ide_hdr_type_prefix",m_ide_hdr_type_prefix,5);
        printer.print_int("m_ide_hdr_fmt_prefix",m_ide_hdr_fmt_prefix,3);
        printer.print_int("use_user_defined_stream_id",use_user_defined_stream_id,$bits(use_user_defined_stream_id));
        printer.print_int("m_stream_id_int",m_stream_id_int,$bits(m_stream_id_int));
        printer.print_int("m_stream_id",m_stream_id,8);
        printer.print_int("m_sub_stream",m_sub_stream,4);
        printer.print_int("m_pr_sent_counter",m_pr_sent_counter,8);
        printer.print_int("m_ide_m",m_ide_m,1);
        printer.print_int("m_ide_p",m_ide_p,1);
        printer.print_int("m_ide_k",m_ide_k,1);
        printer.print_int("m_ide_t",m_ide_t,1);
        if(m_ide_m) begin
          foreach(m_ide_mac[i])
          printer.print_int($psprintf("m_ide_mac[%0d]", i),m_ide_mac[i],8);
        end
        if(m_ide_p)
        printer.print_int("m_ide_pcrc",m_ide_pcrc,32);
      end
      foreach(m_tlp_prefix[i]) begin
        if(!is_flit_mode || m_tlp_prefix[i][31:28] != 4'b1001) printer.print_int($psprintf("m_tlp_prefix[%0d]",i),m_tlp_prefix[i],32);
      end
    end

    if(is_flit_mode) begin
      if(m_ohc_hdr.ohc_a_present) begin
        printer.print_int("m_ohc_a",m_ohc_a,$bits(m_ohc_a));
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE,CDN_HPA_PCIE_TRANS_MSG_TYPE,CDN_HPA_PCIE_TRANS_CPL_TYPE}) begin
          printer.print_int("m_destination_segment",m_destination_segment,$bits(m_destination_segment));
          printer.print_int("m_destination_segment_valid",m_destination_segment_valid,$bits(m_destination_segment_valid));
        end
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) begin
          printer.print_int("m_completer_segment",m_completer_segment,$bits(m_completer_segment));
        end
        if(m_pasid_prefix_present) begin
          printer.print_int("m_pasid_value",m_pasid_value,20);
          printer.print_int("m_pasid_pri_value",m_pasid_pri_value,1);
          printer.print_int("m_pasid_exec_value",m_pasid_exec_value,1);
        end
      end
      if(m_ohc_hdr.ohc_b_present) begin
        printer.print_int("m_ohc_b",m_ohc_b,$bits(m_ohc_b));
        if(m_ext_tph_prefix_present || m_tph_present) begin
          printer.print_int("m_tlp_st_tag",m_tlp_st_tag,16);
          printer.print_int("m_tlp_ph",m_tlp_ph,2);
        end
        printer.print_int("m_hv",m_hv,$bits(m_hv));
        printer.print_int("m_ama_value",m_ama_value,$bits(m_ama_value));
        printer.print_int("m_ama_valid",m_ama_valid,$bits(m_ama_valid));
      end
      if(m_ohc_hdr.ohc_c_present) begin
        printer.print_int("m_ohc_c",m_ohc_c,$bits(m_ohc_c));
        printer.print_int("m_requester_segment",m_requester_segment,$bits(m_requester_segment));
        printer.print_int("m_pr_sent_counter",m_pr_sent_counter,$bits(m_pr_sent_counter));
        printer.print_int("m_stream_id",m_stream_id,$bits(m_stream_id));
        printer.print_int("m_sub_stream",m_sub_stream,$bits(m_sub_stream));
        printer.print_int("m_requester_segment_valid",m_requester_segment_valid,$bits(m_requester_segment_valid));
        printer.print_int("m_ide_k",m_ide_k,$bits(m_ide_k));
        printer.print_int("m_ide_t",m_ide_t,$bits(m_ide_t));
      end
      if(m_ohc_hdr.ohc_ex_present!=no_ohc_ex_present) begin
        printer.print_int("num_of_vnd_e2e_prefixes",num_of_vnd_e2e_prefixes,$bits(num_of_vnd_e2e_prefixes));
        printer.print_int("num_of_valid_vnd_e2e_prefixes",num_of_valid_vnd_e2e_prefixes,$bits(num_of_valid_vnd_e2e_prefixes));
        foreach(m_ohc_e[i])
        printer.print_int($psprintf("m_ohc_e[%0d]",i),m_ohc_e[i],32);
      end
    end

    // TODO Add payload in custom way?
    foreach(m_tlp_payload[i])  begin
      if((i<=7) || (i>=(((m_tlp_length== 0) ? 1022 : m_tlp_length-2) * 4))) printer.print_int($psprintf("m_tlp_payload[%0d]",i),m_tlp_payload[i],8);
    end

    if(is_flit_mode) begin
      for(int i=0; i<(m_ts_payload.size()/4); i++) begin
        printer.print_int($psprintf("m_trailer[%0d]",i),{m_ts_payload[3+i*4],m_ts_payload[2+i*4],m_ts_payload[1+i*4],m_ts_payload[i*4]},32);
      end
    end

    if(!is_flit_mode) printer.print_int("ecrc_val",ecrc_val,32);

    //Print reseved fields (when control knob is enabled)
    if(print_rsvd_bits) begin
      if(is_flit_mode && m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE})
      printer.print_int("second_dw_byte_6_field_6_rsvd",second_dw_byte_6_field_6_rsvd,$bits(second_dw_byte_6_field_6_rsvd));
      if(is_flit_mode) begin //{
        if(m_ohc_hdr.ohc_a_present) begin
          if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            printer.print_int("m_tlp_ats_tr_nw_field",m_tlp_ats_tr_nw_field,1);
          end else if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE}) printer.print_int("m_ohc_a1_byte_0_field_7_rsvd",m_ohc_a1_byte_0_field_7_rsvd,$bits(m_ohc_a1_byte_0_field_7_rsvd));
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE}) printer.print_int("m_ohc_a2_byte_0_2_rsvd",m_ohc_a2_byte_0_2_rsvd,$bits(m_ohc_a2_byte_0_2_rsvd));
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE})begin
            printer.print_int("m_ohc_a3_byte_1_rsvd",m_ohc_a3_byte_1_rsvd,$bits(m_ohc_a3_byte_1_rsvd));
            printer.print_int("m_ohc_a3_byte_2_rsvd",m_ohc_a3_byte_2_rsvd,$bits(m_ohc_a3_byte_2_rsvd));
          end
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MSG_TYPE})begin
            if(pcie_6_1_support && m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Request) begin
              printer.print_int("m_ohc_a1_byte_0_field_7_rsvd",m_ohc_a1_byte_0_field_7_rsvd,$bits(m_ohc_a1_byte_0_field_7_rsvd));
              printer.print_int("m_ohc_a1_byte_3_rsvd",m_ohc_a1_byte_3_rsvd,$bits(m_ohc_a1_byte_3_rsvd));
            end else begin
              printer.print_int("second_dw_byte_6_msg_rsvd",second_dw_byte_6_msg_rsvd,$bits(second_dw_byte_6_msg_rsvd));
              printer.print_int("m_ohc_a4_byte_2_field_5_4_rsvd", m_ohc_a4_byte_2_field_5_4_rsvd, $bits(m_ohc_a4_byte_2_field_5_4_rsvd));
            end
          end
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE}) printer.print_int("m_ohc_a5_byte_2_3_rsvd",m_ohc_a5_byte_2_3_rsvd,$bits(m_ohc_a5_byte_2_3_rsvd));
        end
        if(m_ohc_hdr.ohc_b_present) begin
          printer.print_int("m_ohc_b_byte_0_rsvd",m_ohc_b_byte_0_rsvd,$bits(m_ohc_b_byte_0_rsvd));
        end
        if(m_ohc_hdr.ohc_c_present) begin
          printer.print_int("m_ohc_c_byte_3_field_2_rsvd",m_ohc_c_byte_3_field_2_rsvd,$bits(m_ohc_c_byte_3_field_2_rsvd));
        end
      end //}

      if(m_ext_tph_prefix_present) printer.print_int("tph_byte_2_3_rsvd",tph_byte_2_3_rsvd,16);
      if(m_pasid_prefix_present) printer.print_int("pasid_byte_1_rsvd_field_5_4",pasid_byte_1_rsvd_field_5_4,2);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE) printer.print_int("io_byte_11_rsvd_field_1_0",io_byte_11_rsvd_field_1_0,2);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) printer.print_int("cfg_byte_10_rsvd_field_7_4",cfg_byte_10_rsvd_field_7_4,4);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) printer.print_int("cpl_byte_12_rsvd_field_7",cpl_byte_12_rsvd_field_7,1);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) printer.print_int("cpl_byte_12_rsvd_field_4_0",cpl_byte_12_rsvd_field_4_0, 5);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) printer.print_int("cpl_byte_11_rsvd_field_7_4",cpl_byte_11_rsvd_field_7_4, 4);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) printer.print_int("cpl_byte_11_rsvd_field_3_0",cpl_byte_11_rsvd_field_3_0, 4);

      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) begin
        if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_DRS}) begin
          printer.print_int("msg_ln_drs_byte_13_15_rsvd",msg_ln_drs_byte_13_15_rsvd,$bits(msg_ln_drs_byte_13_15_rsvd));
        end else if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}) begin
          printer.print_int("msg_frs_byte_13_15_rsvd",msg_frs_byte_13_15_rsvd,$bits(msg_frs_byte_13_15_rsvd));
        end else if (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
          printer.print_int("msg_inv_req_byte_6_field_6_5_rsvd",msg_inv_req_byte_6_field_6_5_rsvd,$bits(msg_inv_req_byte_6_field_6_5_rsvd));
          printer.print_int("msg_inv_req_byte_10_15_rsvd",msg_inv_req_byte_10_15_rsvd,$bits(msg_inv_req_byte_10_15_rsvd));
        end else if (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin
          printer.print_int("msg_inv_cpl_byte_10_11_rsvd",msg_inv_cpl_byte_10_11_rsvd,$bits(msg_inv_cpl_byte_10_11_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin
          printer.print_int("msg_ltr_byte_8_11_rsvd",msg_ltr_byte_8_11_rsvd,$bits(msg_ltr_byte_8_11_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Group_Response) begin
          printer.print_int("msg_pr_rsp_byte_10_field_3_1_rsvd",msg_pr_rsp_byte_10_field_3_1_rsvd,$bits(msg_pr_rsp_byte_10_field_3_1_rsvd));
          printer.print_int("msg_pr_rsp_byte_12_15_rsvd",msg_pr_rsp_byte_12_15_rsvd,$bits(msg_pr_rsp_byte_12_15_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin
          printer.print_int("msg_obff_byte_8_14_rsvd",msg_obff_byte_8_14_rsvd,$bits(msg_obff_byte_8_14_rsvd));
        end else if((!(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1,CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD})) || ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD))) begin //3rd & 4th DW are Rsvd for other messages
          printer.print_int("msg_cmn_byte_8_15_rsvd",msg_cmn_byte_8_15_rsvd,$bits(msg_cmn_byte_8_15_rsvd));
        end
      end
    end

    printer.print_int("pkt_num",pkt_num,$bits(pkt_num));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) printer.print_int("p_pkt_num",p_pkt_num,$bits(p_pkt_num));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) printer.print_int("np_pkt_num",np_pkt_num,$bits(np_pkt_num));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) printer.print_int("cpl_pkt_num",cpl_pkt_num,$bits(cpl_pkt_num));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) printer.print_int("cpl_pkt_num_in_flit",cpl_pkt_num_in_flit,$bits(cpl_pkt_num_in_flit));
    printer.print_int("pkt_rx_time",pkt_rx_time,$bits(pkt_rx_time),UVM_TIME);

    if(print_intx) begin
      printer.print_int("print_intx",print_intx,$bits(print_intx));
      printer.print_int("pack_intx",pack_intx,$bits(pack_intx));
      printer.print_int("requestor_id",requestor_id,$bits(requestor_id));
      printer.print_int("is_high",is_high,$bits(is_high));
      printer.print_int("intx_in_pin_value",intx_in_pin_value,$bits(intx_in_pin_value));
      printer.print_int("intx_out_pin_value",intx_out_pin_value,$bits(intx_out_pin_value));
      printer.print_int("int_ack_pin_value",int_ack_pin_value,$bits(int_ack_pin_value));
      printer.print_int("intx_pending_status",intx_pending_status,$bits(intx_pending_status));
      //  printer.print_int("m_intr_pins",m_intr_pins,$bits(m_intr_pins));
      printer.print_int("fid_active",fid_active,$bits(fid_active));
    end
    if(print_msi_msix) begin
      printer.print_int("print_msi_msix",print_msi_msix,$bits(print_msi_msix));
      printer.print_int("pack_msi_msix",pack_msi_msix,$bits(pack_msi_msix));
      printer.print_int("msi_en",msi_en,$bits(msi_en));
      printer.print_int("id_based_ordering",id_based_ordering,$bits(id_based_ordering));
      printer.print_int("msi_msix_requestor_id",msi_msix_requestor_id,$bits(msi_msix_requestor_id));
      printer.print_int("intr_number",intr_number,$bits(intr_number));
      printer.print_int("intr_number_bits",intr_number_bits,$bits(intr_number_bits));
      printer.print_int("intr_number_bits_cap",intr_number_bits_cap,$bits(intr_number_bits_cap));
      printer.print_int("int_msix_msg_data",int_msix_msg_data,$bits(int_msix_msg_data));
      printer.print_int("int_msix_msg_lo_addr",int_msix_msg_lo_addr,$bits(int_msix_msg_lo_addr));
      printer.print_int("int_msix_msg_hi_addr",int_msix_msg_hi_addr,$bits(int_msix_msg_hi_addr));
      printer.print_int("pending_status",pending_status,$bits(pending_status));
      printer.print_int("requestor_id_for_pending_status",requestor_id_for_pending_status,$bits(requestor_id_for_pending_status));
      printer.print_int("int_msi_pending_status_valid",int_msi_pending_status_valid,$bits(int_msi_pending_status_valid));
      printer.print_int("int_msi_pending_status",int_msi_pending_status,$bits(int_msi_pending_status));
      printer.print_int("msi_msg_low_addr",msi_msg_low_addr,$bits(msi_msg_low_addr));
      printer.print_int("msi_msg_hi_addr",msi_msg_hi_addr,$bits(msi_msg_hi_addr));
      printer.print_int("msi_msg_hi_addr",msi_msg_hi_addr,$bits(msi_msg_hi_addr));
      printer.print_int("msi_msg_data",msi_msg_data,$bits(msi_msg_data));
      printer.print_int("ext_msg_data_en",ext_msg_data_en,$bits(ext_msg_data_en));
      printer.print_int("msi_64bit_addr_cap",msi_64bit_addr_cap,$bits(msi_64bit_addr_cap));
      printer.print_int("msi_per_vector_masking_cap",msi_per_vector_masking_cap,$bits(msi_per_vector_masking_cap));
      printer.print_int("st_tag_pin_or_reg",st_tag_pin_or_reg,$bits(st_tag_pin_or_reg));
      printer.print_int("tph_st_table_index",tph_st_table_index,$bits(tph_st_table_index));
      printer.print_int("int_mask_changed_ipfivf",int_mask_changed_ipfivf,$bits(int_mask_changed_ipfivf));
      printer.print_int("int_mask_changed_valid",int_mask_changed_valid,$bits(int_mask_changed_valid));
      printer.print_int("int_msg_done",int_msg_done,$bits(int_msg_done));
      printer.print_int("int_msi_cap",int_msi_cap,$bits(int_msi_cap));
      printer.print_int("int_msix_cap",int_msix_cap,$bits(int_msix_cap));
    end

    printer.print_int("is_ib_pkt",is_ib_pkt,$bits(is_ib_pkt));
    if(m_tlp_trans_type==CDN_HPA_PCIE_TRANS_CFG_TYPE) begin
      printer.print_int("cfg_type1_target_pri",cfg_type1_target_pri,$bits(cfg_type1_target_pri));
      printer.print_int("cfg_type0_target_pri",cfg_type0_target_pri,$bits(cfg_type0_target_pri));
      printer.print_int("cfg_type1_target_sec",cfg_type1_target_sec,$bits(cfg_type1_target_sec));
      printer.print_int("cfg_type1_target_sec_non_zero_dev_ari_dis",cfg_type1_target_sec_non_zero_dev_ari_dis,$bits(cfg_type1_target_sec_non_zero_dev_ari_dis));
      printer.print_int("cfg_type1_target_pri_wrong_dev_fun",cfg_type1_target_pri_wrong_dev_fun,$bits(cfg_type1_target_pri_wrong_dev_fun));
      printer.print_int("cfg_type1_target_more_than_sec_less_equal_to_sub",cfg_type1_target_more_than_sec_less_equal_to_sub,$bits(cfg_type1_target_more_than_sec_less_equal_to_sub));
      printer.print_int("cfg_type1_target_more_than_sub",cfg_type1_target_more_than_sub,$bits(cfg_type1_target_more_than_sub));
    end
    printer.print_int("m_cpl_part",m_cpl_part,$bits(m_cpl_part));
    printer.print_int("m_expect_enderror",m_expect_enderror,$bits(m_expect_enderror));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) begin
      printer.print_int("is_translation_cpl",is_translation_cpl,$bits(is_translation_cpl));
    end
    if(is_ib_pkt) begin
      if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) begin
        printer.print_int("hls_ib_cpl_meta_s.pf", hls_ib_cpl_meta_s.pf, $bits(hls_ib_cpl_meta_s.pf) );
        printer.print_int("hls_ib_cpl_meta_s.vf", hls_ib_cpl_meta_s.vf, $bits(hls_ib_cpl_meta_s.vf) );
        printer.print_int("hls_ib_cpl_meta_s.vf_or_pf", hls_ib_cpl_meta_s.vf_or_pf, $bits(hls_ib_cpl_meta_s.vf_or_pf) );
        printer.print_int("hls_ib_cpl_meta_s.cpl_complete", hls_ib_cpl_meta_s.cpl_complete, $bits(hls_ib_cpl_meta_s.cpl_complete) );
        printer.print_int("hls_ib_cpl_meta_s.cpl_err_code", hls_ib_cpl_meta_s.cpl_err_code, $bits(hls_ib_cpl_meta_s.cpl_err_code) );
        `ifdef HPA_ARCH2
          printer.print_int("hls_ib_cpl_meta_s.generated_tlp", hls_ib_cpl_meta_s.generated_tlp, $bits(hls_ib_cpl_meta_s.generated_tlp) );
        `endif
      end else begin //P/NP
        printer.print_int("hls_ib_p_np_meta_s.pf", hls_ib_p_np_meta_s.pf, $bits(hls_ib_p_np_meta_s.pf) );
        printer.print_int("hls_ib_p_np_meta_s.vf", hls_ib_p_np_meta_s.vf, $bits(hls_ib_p_np_meta_s.vf) );
        printer.print_int("hls_ib_p_np_meta_s.cxl_io", hls_ib_p_np_meta_s.cxl_io, $bits(hls_ib_p_np_meta_s.cxl_io) );
        printer.print_int("hls_ib_p_np_meta_s.vf_or_pf", hls_ib_p_np_meta_s.vf_or_pf, $bits(hls_ib_p_np_meta_s.vf_or_pf) );
        printer.print_int("hls_ib_p_np_meta_s.bar", hls_ib_p_np_meta_s.bar, $bits(hls_ib_p_np_meta_s.bar) );
        printer.print_int("hls_ib_p_np_meta_s.bar_aperture", hls_ib_p_np_meta_s.bar_aperture, $bits(hls_ib_p_np_meta_s.bar_aperture) );
        printer.print_int("hls_ib_p_np_meta_s.bar_prefetchable", hls_ib_p_np_meta_s.bar_prefetchable, $bits(hls_ib_p_np_meta_s.bar_prefetchable) );
        `ifdef HPA_ARCH2
          printer.print_int("hls_ib_p_np_meta_s.generated_tlp", hls_ib_p_np_meta_s.generated_tlp, $bits(hls_ib_p_np_meta_s.generated_tlp) );
        `endif
      end
    end
    printer.print_int("cxl_io_tlp",cxl_io_tlp,$bits(cxl_io_tlp));
    printer.print_int("cxl_io_rcrb_tlp",cxl_io_rcrb_tlp,$bits(cxl_io_rcrb_tlp));
    printer.print_int("cxl_io_membar_tlp",cxl_io_membar_tlp,$bits(cxl_io_membar_tlp));

    //PBR: PTH
    if(is_cxl_pbr_mode)
    begin
      printer.print_int("m_tlp_pbr_tlp_header",m_tlp_pbr_tlp_header,32);
      printer.print_int("m_tlp_pth_hie" , m_tlp_pth_hie , 1 );
      printer.print_int("m_tlp_pth_dsar", m_tlp_pth_dsar, 1 );
      printer.print_int("m_tlp_pth_pif" , m_tlp_pth_pif , 1 );
      printer.print_int("m_tlp_pth_spid", m_tlp_pth_spid, 12);
      printer.print_int("m_tlp_pth_dpid", m_tlp_pth_dpid, 12);
      printer.print_int("m_tlp_pth_rsvd", m_tlp_pth_rsvd, 3 );
    end
    if(cxl_mode && cxl_ldid_prefix)
    printer.print_int("m_cxl_ldid",m_cxl_ldid,16);

    // Print first 3 DWs of m_data in 0xXXXXXXXX__0xXXXXXXXX__0xXXXXXXXX format
    num_prefix_print = m_max_no_of_prefixes + m_max_no_of_local_prefixes + is_cxl_pbr_mode;
    num_prefix_print =  num_prefix_print*4;
    if(m_data.size() >= (12+num_prefix_print)) begin
      printer.print_string("m_data_3DW", $psprintf("0x%02x%02x%02x%02x__0x%02x%02x%02x%02x__0x%02x%02x%02x%02x",
        m_data[0+num_prefix_print], m_data[1+num_prefix_print], m_data[2+num_prefix_print], m_data[3+num_prefix_print],
        m_data[4+num_prefix_print], m_data[5+num_prefix_print], m_data[6+num_prefix_print], m_data[7+num_prefix_print],
        m_data[8+num_prefix_print], m_data[9+num_prefix_print], m_data[10+num_prefix_print], m_data[11+num_prefix_print]));
    end else if(m_data.size() > 0) begin
      printer.print_string("m_data_3DW", convert_bytes_to_dw_string(m_data));
    end

  endfunction

  //------------------------------------------------------------------------
  // Function: check_function_specific
  //
  //------------------------------------------------------------------------
  virtual function void check_function_specific(bit is_malformed_err = 0, bit is_req_id_err = 0);
    /*
    Notes:
    Function independent error
    
    mem request hits IO Bar -> still function specific?
    IO request hits MEM Bar -> still function specific?
    
    1. Mem-TLP
    request , destination address
    
    a. request matches a bar completely
    1. if it is a VF, VFs are not enabled for corresponding PF -> non function specific
    1. if it is a VF, VFs are enabled for corresponding PF -> function specific
    2. if it is a PF, then definitely function specific, even if it is function 0
    b. request spans two bars ->
    1. if the next bar range doesn't exit -> is this function specific?
    2. if the next bar range belong to same function -> function specific
    3. if the next bar range belong to different function -> is this function specific?
    
    2. IO TLP
    request, destination
    
    a. request matches a bar completely
    1. if it is a VF, VFs are not enabled for corresponding PF -> ?
    1. if it is a VF, VFs are enabled for corresponding PF -> function specific
    2. if it is a PF, then definitely function specific, even if it is function 0
    b. request spans two bars ->
    1. if the next bar range doesn't exit -> is this function specific?
    2. if the next bar range belong to same function -> function specific
    3. if the next bar range belong to different function -> is this function specific?
    
    3. MSG TLP
    a. if(CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) -> completer ID
    1. completer ID is not valid -> non function specifc
    2. completer ID is valid -> function specific
    b. else -> ?
    CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC :
    CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ADDR :
    CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC :
    CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE :
    CDN_HPA_PCIE_TLP_MSG_ROUT_GATHER_TO_RC :
    
    
    4. CFG TLP -> completer ID
    a. completer ID is not valid -> non function specifc
    b. completer ID is valid -> function specific
    
    5. CPL TLP -> requester ID
    a. requester ID is not valid -> non function specifc
    b. requester ID is valid -> function specific
    */

    //Check if TLP is Malformed or has ECRC errors - If Yes, then TLP is non-function specific
    
    m_non_func_specific = 0;
    if(is_malformed_err) begin
      m_non_func_specific = 1;
      `uvm_info("check_function_specific", $psprintf("malformed_err detected"),UVM_DEBUG)
    end

    //Check for all other cases - Errored or non-errored
    if(!is_malformed_err) begin //{
      if((m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_MEM_TYPE}) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_rout_type == CDN_HPA_PCIE_TLP_ROUT_BY_ADDR))) begin //{
        if (((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (!m_pcie_dev_top_cfg.force_bar_chk_rp)) || ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && (m_pcie_dev_top_cfg.force_bar_chk_rp))) begin //{
          if(m_tlp_trans_type==CDN_HPA_PCIE_TRANS_IO_TYPE) begin //{
            if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) begin
              if(is_io_bar_hit_info(m_tlp_addr).bar_hit == 0)
                m_non_func_specific = 0; //Discuss with Rajesp and Navdeep 
              else
                m_non_func_specific = 0;
            end
            else if (is_io_bar_hit_info(m_tlp_addr).bar_hit == 0)
            m_non_func_specific = 1;
            else
            m_non_func_specific = 0;
          end //}
          else begin //m_tlp_trans_type==CDN_HPA_PCIE_TRANS_MEM_TYPE {
            if ((is_mem_bar_hit_info(m_tlp_addr).bar_hit == 0) && (is_vf_mem_bar_hit_info(m_tlp_addr).bar_hit == 0) && (is_cxl_io_bar_hit_info(m_tlp_addr).bar_hit == 0) && (is_erom_bar_hit_info(m_tlp_addr).bar_hit == 0))
            m_non_func_specific = 1;
            else
            m_non_func_specific = 0;
          end //}
        end //}
      end //}
      if((m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE, CDN_HPA_PCIE_TRANS_MSG_TYPE, CDN_HPA_PCIE_TRANS_CPL_TYPE}) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID))) begin //{
        if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID))) begin //{
          if((m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) /* || (!m_pcie_dev_top_cfg.en_inv_msg_code)*/ ) begin //{ //As per JIRA: 12377
            if((m_tlp_msg_code inside { CDN_HPA_PCIE_TLP_MSG_AT_Invalidate, CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete, CDN_HPA_PCIE_TLP_MSG_PR_Group_Response,
                                        CDN_HPA_PCIE_TLP_MSG_VD_Type0, CDN_HPA_PCIE_TLP_MSG_VD_Type1,CDN_HPA_PCIE_TLP_MSG_IDE_Fail,CDN_HPA_PCIE_TLP_MSG_IDE_Sync,CDN_HPA_PCIE_TLP_MSG_IDE_Escort })  || 
               ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID))) begin /*invalidate, invalidate completion, PRG RESPONSE, VD_TYPE0, VD_TYPE1*/ //{
              if(is_function_id_active(m_tlp_completer_id))
              m_non_func_specific = 0;
              else
              m_non_func_specific = 1;
            end //}
            else begin
              m_non_func_specific = 1;
            end
          end //}
          else begin
            m_non_func_specific = 1;
          end
        end //}
        else if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1}/* &&
        m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP*/ && !m_pcie_dev_top_cfg.err_report_on_type1_cfg_access)
        //CfgWr1/CfgRd1 UR packet will be considered function specific/non-function specific based on setting of field FSERT1 in ip_cfg_reg0
        m_non_func_specific = 1;
        else if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE} && lut_item != null) begin //{
          `uvm_info("check_function_specific", $psprintf("checking for cpl, m_non_func_specific=%0b", m_non_func_specific),UVM_DEBUG)
          if(lut_item.m_invalid_tag == 1) begin
            if(flr_valid_tag_diff_reqid)
            m_non_func_specific = 1;
            else if((m_pf_vf.is_pf_valid == 0) && (m_pf_vf.is_vf_valid == 0))
            m_non_func_specific = 1;
            else
            m_non_func_specific = 0;
          end
          else if (cpl_req_id_mismatch) begin //{ //Unexpexted Cpl with Invalid tag is Non-function specific error
            `uvm_info("check_function_specific", $psprintf("m_invalid_tag=%0b is_req_id_err=%0b for cpl", lut_item.m_invalid_tag, is_req_id_err),UVM_DEBUG)
            m_non_func_specific = 1;
          end //}
        end //}
        else begin //{
          `uvm_info("check_function_specific", $psprintf("lut_item == null"),UVM_DEBUG)
          if((m_pf_vf.is_pf_valid == 0) && (m_pf_vf.is_vf_valid == 0))
            m_non_func_specific = 1;
          else
            m_non_func_specific = 0;
        end //}
      end //}
    end //}
    `uvm_info(get_full_name(),$psprintf("m_non_func_specific=%0d",m_non_func_specific),UVM_DEBUG);
    // hls error predictor can take the following signals out
    //m_non_func_specific
    //m_pf_vf
    // set m_hls_err_chk_en = 1
    // populate m_cfg_info
    // call get_cfg_from_tlp();
  endfunction : check_function_specific


  //------------------------------------------------------------------------
  // Function: get_prefixes
  // Method to get the prefixes as byte array
  //------------------------------------------------------------------------
  function void get_prefixes(ref byte unsigned prefix_bytes[], input bit include_local_prfx=1, input bit include_ide_prfx=1, input bit include_fm_local_prefix=0);

    `uvm_info("update_ecrc_value",$sformatf("m_max_no_of_local_prefixes=%0d",m_max_no_of_local_prefixes),UVM_DEBUG)
    `uvm_info("update_ecrc_value",$sformatf("m_tlp_local_prefix=%0p",m_tlp_local_prefix),UVM_DEBUG)
    // Local Prefixes
    if(m_max_no_of_local_prefixes) begin
      if(m_tlp_local_prefix.size() > 1) begin
        if(include_local_prfx && include_fm_local_prefix)
        prefix_bytes = {>>{m_tlp_local_prefix}};
        else begin
          for(int i=0; i< m_tlp_local_prefix.size() ; i++) begin
            if(include_local_prfx && (m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_VEND_PREFIX_L0 || m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_VEND_PREFIX_L1))
            prefix_bytes = {>>{m_tlp_local_prefix[i]}};
            else if(include_fm_local_prefix && m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX)
            prefix_bytes = {>>{m_tlp_local_prefix[i]}};
          end
        end
      end else if(m_tlp_local_prefix.size() == 1) begin
        if(include_local_prfx && m_local_prefix_possible)
        prefix_bytes = {>>{m_tlp_local_prefix[0]}};
        else if(include_fm_local_prefix && m_flit_mode_local_prefix_possible)
        prefix_bytes = {>>{m_tlp_local_prefix[0]}};
      end
    end
    `uvm_info("update_ecrc_value",$sformatf("prefix_bytes=%0p",prefix_bytes),UVM_DEBUG)

    // IDE Prefix
    if(include_ide_prfx && m_ide_prefix_present && !is_flit_mode) begin
      prefix_bytes = {>>{prefix_bytes,m_ide_tlp_prefix}};
    end
    `uvm_info("update_ecrc_value",$sformatf("prefix_bytes=%0p",prefix_bytes),UVM_DEBUG)

    // E2E Prefixes
    if(m_tlp_prefix.size()> 0 && !is_flit_mode) begin
      for(int i=0; i< m_tlp_prefix.size() ; i++) begin
        prefix_bytes = {>>{prefix_bytes,m_tlp_prefix[i]}};
        `uvm_info("update_ecrc_value",$sformatf("prefix_bytes=%0p",prefix_bytes),UVM_DEBUG)
      end
    end
  endfunction

  //------------------------------------------------------------------------
  // Function: is_io_bar_hit
  // Method to detect the given address falling in any of the IO BARs
  //------------------------------------------------------------------------

  //function  bit is_io_bar_hit (bit[63:0] bar_addr);
  function barInfo_t is_io_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;
    cdn_hpa_pcie_bar_type_t bar_type;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;

    bar_type = IO_BAR ;

    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    ///bar_32 = (bar_type == MEM_BAR_32 || bar_type == MEM_BAR_32_PREFETCH ||  bar_type == IO_BAR );

    if (ep_rp_dut) begin // { EP
      if(dev_top_cfg.m_ep_dev_bar_info)
      begin //{
        foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
          foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
            if ( dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
            dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == bar_type ) begin //{

              bar_addr_l =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr;
              bar_addr_h =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr +
              dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size-1 ;

              if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
                is_io_bar_hit_info.bar_hit  = 1 ;
                is_io_bar_hit_info.func_num = i ;
                is_io_bar_hit_info.pf_num  = i ;
                is_io_bar_hit_info.bar_type = dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type ;
              end
            end //}
          end //}
        end //}
      end //}
    end //}

    else begin //{ RC
      if(dev_top_cfg.m_rp_dev_bar_info)
      begin//{
        foreach (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j]) begin //{
          if ( dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_enable &&
          dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == bar_type ) begin //{
            bar_addr_l =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr;
            bar_addr_h =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr +
            dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].size-1 ;
            if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
              is_io_bar_hit_info.bar_hit  = 1 ;
              is_io_bar_hit_info.bar_type = dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type ;
            end
          end //}
        end //}
      end //}
    end //}
    ///return 1;
  endfunction : is_io_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_mem_bar_hit
  // Method to detect the given address falling in any of the Memory BARs
  //TODO::undefined bar range in mem
  //------------------------------------------------------------------------
  //function bit is_mem_bar_hit(bit[63:0] bar_addr);
  function barInfo_t is_mem_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    bar_32 = (bar_addr[63:32] == 0);

    if (ep_rp_dut) begin // { EP
      `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 1"),UVM_LOW)
      if(dev_top_cfg.m_ep_dev_bar_info) begin //{
        //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 2"),UVM_DEBUG)
        foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
          //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 3 = %0d",i),UVM_DEBUG)
          foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
            //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 4 = %0d, %0d",i, j),UVM_DEBUG)
            //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 4 = %0s",dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].sprint()),UVM_DEBUG)
            //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 4, start_add = %0h, end addr = %0h ", dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr, dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size),UVM_DEBUG)
            if ( dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
            ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32) ||
            (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH) ||
            (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_PREFETCH) ||
            (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32_PREFETCH) ||
            ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32) && is_memrd_op()))) begin //{

              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 5 target addr = %0h", bar_addr),UVM_DEBUG)
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 5, start_add = %0h, end addr = %0h ", dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr, dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size),UVM_DEBUG)
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 5, start_add = %0h, end addr = %0h ", dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr, dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size),UVM_DEBUG)
              bar_addr_l =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr;
              bar_addr_h =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr +
              dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size-1 ;
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 5, start_add = %0x, end addr = %0x ", bar_addr_l, bar_addr_h),UVM_DEBUG)

              if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
                //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_DEBUG)
                is_mem_bar_hit_info.bar_hit  = 1 ;
                is_mem_bar_hit_info.func_num = i ;
                is_mem_bar_hit_info.pf_num  = i ;
                is_mem_bar_hit_info.vf_num  = -1 ;
                is_mem_bar_hit_info.bar_num = j;
                is_mem_bar_hit_info.bar_type = dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type ;
                //Just for coverage purpose for EROM Hit packets
                if ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32) && is_memrd_op())
                m_erom_bar_hit = 1;
              end
            end //}
            if(is_mem_bar_hit_info.bar_hit)
            break;
          end //}
          if(is_mem_bar_hit_info.bar_hit)
          break;
        end //}
      end //}
    end //}

    else begin //{ RC
      if(dev_top_cfg.m_rp_dev_bar_info)
      begin//{
        foreach (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j]) begin //{
          if ( dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_enable &&
          ((bar_32 && (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32 |
          dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32_PREFETCH)) |
          (!bar_32 && (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH |
          dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_64_PREFETCH) ))) begin //{
            bar_addr_l =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr;
            bar_addr_h =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr +
            dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].size-1 ;
            if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
              is_mem_bar_hit_info.bar_hit  = 1 ;
              is_mem_bar_hit_info.bar_num = j;
              is_mem_bar_hit_info.bar_type = dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type ;
            end
          end //}
        end //}
      end //}
    end //}
    ///return 1;
  endfunction : is_mem_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_erom_bar_hit_info
  // Method to detect the given address falling in EROM BARs
  //TODO::undefined bar range in mem
  //------------------------------------------------------------------------
  function barInfo_t is_erom_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    bar_32 = (bar_addr[63:32] == 0);

    if (ep_rp_dut) begin // { EP
      if(dev_top_cfg.m_ep_dev_bar_info) begin //{
        foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
          foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
            if (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable && (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32)) begin //{
              bar_addr_l =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr;
              bar_addr_h =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr +
              dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size-1 ;
              if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
                is_erom_bar_hit_info.bar_hit  = 1 ;
                is_erom_bar_hit_info.func_num = i ;
                is_erom_bar_hit_info.pf_num  = i ;
                is_erom_bar_hit_info.vf_num  = -1 ;
                is_erom_bar_hit_info.bar_type = dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type ;
              end
            end //}
            if(is_erom_bar_hit_info.bar_hit)
            break;
          end //}
          if(is_erom_bar_hit_info.bar_hit)
          break;
        end //}
      end //}
    end //}

    //else begin //{ RC
    //  if(dev_top_cfg.m_rp_dev_bar_info)
    //  begin//{
    //    foreach (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j]) begin //{
    //      if ( dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_enable &&
    //           ((bar_32 && (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32 |
    //             dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32_PREFETCH)) |
    //           (!bar_32 && (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH |
    //             dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_64_PREFETCH) ))) begin //{
    //        bar_addr_l =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr;
    //        bar_addr_h =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr +
    //                      dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].size-1 ;
    //        if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
    //          is_erom_bar_hit_info.bar_hit  = 1 ;
    //          is_erom_bar_hit_info.bar_type = dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type ;
    //        end
    //      end //}
    //    end //}
    //  end //}
    //end //}
    ///return 1;
  endfunction : is_erom_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_cxl_io_bar_hit_info
  // Method to detect the given feature is supported in any of the active functions
  // Method to detect the given address falling in cxl_io BARs
  //------------------------------------------------------------------------
  function barInfo_t is_cxl_io_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    bar_32 = (bar_addr[63:32] == 0);
    `uvm_info(get_full_name(),$psprintf("ep_rp_dut=%0b",ep_rp_dut),UVM_LOW)
    `uvm_info(get_full_name(),$psprintf("dev_top_cfg.m_cxl_negotiation=%0b",dev_top_cfg.m_cxl_negotiation),UVM_LOW)

    if (ep_rp_dut) begin // { EP
      if(dev_top_cfg.m_cxl_negotiation) begin //{
        foreach (dev_top_cfg.pf_config[i]) begin //{
          //cxl io rcrb bar
          bar_addr_l = dev_top_cfg.pf_config[i].m_cxl_io_rcrb_bar + 2**12;
          bar_addr_h = dev_top_cfg.pf_config[i].m_cxl_io_rcrb_bar + 2**13 -1;

          `uvm_info(get_full_name(),$psprintf("bar_addr_l=%0h, bar_addr_h=%0h", bar_addr_l, bar_addr_h),UVM_LOW)
          if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
            `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_LOW)
            is_cxl_io_bar_hit_info.bar_hit  = 1 ;
            is_cxl_io_bar_hit_info.func_num = i ;
            is_cxl_io_bar_hit_info.pf_num   = i ;
            is_cxl_io_bar_hit_info.vf_num   = -1 ;
            is_cxl_io_bar_hit_info.bar_type = RSVD_BAR_64;
            break;
          end

          //cxl io membar
          bar_addr_l = dev_top_cfg.pf_config[i].m_cxl_io_membar;
          bar_addr_h = dev_top_cfg.pf_config[i].m_cxl_io_membar + 2**(dev_top_cfg.pf_config[i].m_cxl_io_membar_aperture)-1;

          if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin //{
            //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_LOW)
            is_cxl_io_bar_hit_info.bar_hit  = 1 ;
            is_cxl_io_bar_hit_info.func_num = i ;
            is_cxl_io_bar_hit_info.pf_num   = i ;
            is_cxl_io_bar_hit_info.vf_num   = -1 ;
            is_cxl_io_bar_hit_info.bar_type = RSVD_BAR_64;
            break;
          end //}
        end //}
        if(is_cxl_io_bar_hit_info.bar_hit==0) begin
          foreach (dev_top_cfg.vf_config[i,j]) begin //{
            //cxl io rcrb bar
            bar_addr_l = dev_top_cfg.vf_config[i][j].m_cxl_io_rcrb_bar + 2**12;
            bar_addr_h = dev_top_cfg.vf_config[i][j].m_cxl_io_rcrb_bar + 2**13;

            if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_LOW)
              is_cxl_io_bar_hit_info.bar_hit  = 1 ;
              is_cxl_io_bar_hit_info.func_num = i ;
              is_cxl_io_bar_hit_info.pf_num   = i ;
              is_cxl_io_bar_hit_info.vf_num   = j ;
              is_cxl_io_bar_hit_info.bar_type = RSVD_BAR_64;
              break;
            end

            //cxl io membar
            bar_addr_l = dev_top_cfg.vf_config[i][j].m_cxl_io_membar;
            bar_addr_h = dev_top_cfg.vf_config[i][j].m_cxl_io_membar + 2**(dev_top_cfg.vf_config[i][j].m_cxl_io_membar_aperture)-1;

            if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin //{
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_LOW)
              is_cxl_io_bar_hit_info.bar_hit  = 1 ;
              is_cxl_io_bar_hit_info.func_num = i ;
              is_cxl_io_bar_hit_info.pf_num   = i ;
              is_cxl_io_bar_hit_info.vf_num   = j ;
              is_cxl_io_bar_hit_info.bar_type = RSVD_BAR_64;
              break;
            end //}
          end //}
        end
      end //}
    end //}

  endfunction : is_cxl_io_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_feature_supported_by_any_func
  // Method to detect the given feature is supported in any of the active functions
  //------------------------------------------------------------------------
  function bit is_feature_supported_by_any_func(cdn_hpa_pcie_feature_name_t feature_name, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    cdn_pcie_hpa_dev_top_config l_pcie_dev_top_cfg;

    if(dev_top_cfg)
    l_pcie_dev_top_cfg= dev_top_cfg;
    else
    l_pcie_dev_top_cfg = m_pcie_dev_top_cfg;

    if (feature_name == CDN_HPA_PCIE_E2E_TLP_PREFIX ) begin
      foreach (l_pcie_dev_top_cfg.pf_config[i]) begin
        if (l_pcie_dev_top_cfg.pf_config[i].m_e2e_tlp_prefix_support) begin
          return 1;
        end
      end
    end
    return 0;
    // TODO: Have to add for Remaining feature
  endfunction : is_feature_supported_by_any_func

  //------------------------------------------------------------------------
  // Function: is_function_id_active
  // Method to detect whether the given function id is implemented/enabled
  // Function returns 0 if the function id is not active or not implemented
  //------------------------------------------------------------------------
  function bit is_function_id_active(cdn_hpa_pcie_tlp_requester_id_s fn_id);
    // TODO: Function need to be implemented and change the return value
    cdn_pcie_hpa_dev_top_config l_pcie_dev_top_cfg;
    bit [2:0] l_function_num;
    bit is_active;
    //if(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.usp_dev_top_config;
    //else
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.dsp_dev_top_config;
    l_pcie_dev_top_cfg = m_pcie_dev_top_cfg;

    foreach(l_pcie_dev_top_cfg.pf_config[i]) begin
      if(fn_id == l_pcie_dev_top_cfg.pf_config[i].m_req_id) begin
        is_active = 1;
        break;
      end
    end
    if(is_active == 0) begin
      foreach(l_pcie_dev_top_cfg.vf_config[i,j]) begin
        if((fn_id == l_pcie_dev_top_cfg.vf_config[i][j].m_req_id) && !l_pcie_dev_top_cfg.pf_config[i].m_vf_en) begin//{
          pkt_targeting_disabled_vf = 1;
          break;
        end//}
        if((fn_id == l_pcie_dev_top_cfg.vf_config[i][j].m_req_id) && (i<parameters_cfg_pkg::MAX_PFS_WITH_VF)) begin
          is_active = 1;
          break;
        end
        if((fn_id == l_pcie_dev_top_cfg.vf_config[i][j].m_req_id) && (i>=parameters_cfg_pkg::MAX_PFS_WITH_VF)) begin
          pkt_targeting_vf_in_not_allowed_pf = 1;
          break;
        end
      end
    end
    return is_active;
  endfunction : is_function_id_active

  // TODO: check it since HLS checks only function not bus and device number for request.
  //------------------------------------------------------------------------
  // Function: is_function_valid
  // Method to detect whether the given function id is implemented/enabled
  // Function returns 0 if the function id is not active or not implemented
  //------------------------------------------------------------------------
  function bit is_function_valid(cdn_hpa_pcie_tlp_requester_id_s fn_id);
    // TODO: Function need to be implemented and change the return value
    cdn_pcie_hpa_dev_top_config l_pcie_dev_top_cfg;
    cdn_hpa_pcie_tlp_requester_id_s l_func_id;
    bit ari_enable;
    bit is_active;
    bit [7:0] req_func_num;
    bit [7:0] cfg_func_num;
    //if(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.usp_dev_top_config;
    //else
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.dsp_dev_top_config;
    l_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
    ari_enable = l_pcie_dev_top_cfg.i_cfg.strap_ari_enable;

    foreach(l_pcie_dev_top_cfg.pf_config[i])
    begin
      l_func_id = l_pcie_dev_top_cfg.pf_config[i].m_req_id;
      if(ari_enable) begin
        req_func_num = {l_func_id.device_num,l_func_id.function_num};
        cfg_func_num = {fn_id.device_num,fn_id.function_num};
      end
      else begin
        req_func_num = l_func_id.function_num;
        cfg_func_num = fn_id.function_num;
      end
      if(req_func_num == cfg_func_num)
      begin
        is_active = 1;
        break;
      end
    end
    if(is_active == 0)
    foreach(l_pcie_dev_top_cfg.vf_config[i,j])
    begin
      l_func_id = l_pcie_dev_top_cfg.vf_config[i][j].m_req_id;
      if(ari_enable) begin
        req_func_num = {l_func_id.device_num,l_func_id.function_num};
        cfg_func_num = {fn_id.device_num,fn_id.function_num};
      end
      else begin
        req_func_num = l_func_id.function_num;
        cfg_func_num = fn_id.function_num;
      end
      if(req_func_num == cfg_func_num)
      begin
        is_active = 1;
        break;
      end
    end
    return is_active;
  endfunction : is_function_valid

  //------------------------------------------------------------------------
  // Function: check_bus_device_func
  // Method to detect whether the given function id is implemented/enabled
  // Function returns 0 if the function id is not active or not implemented
  //------------------------------------------------------------------------
  function bit [2:0] check_bus_device_func(cdn_hpa_pcie_tlp_requester_id_s fn_id);
    // TODO: Function need to be implemented and change the return value
    cdn_pcie_hpa_dev_top_config l_pcie_dev_top_cfg;
    cdn_hpa_pcie_tlp_requester_id_s l_func_id;
    bit ari_enable;
    bit is_active;
    bit [7:0] req_func_num;
    bit [7:0] cfg_func_num;
    bit bus_num_match,dev_num_match,func_num_match;
    //if(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.usp_dev_top_config;
    //else
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.dsp_dev_top_config;
    l_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
    ari_enable = l_pcie_dev_top_cfg.i_cfg.strap_ari_enable;

    foreach(l_pcie_dev_top_cfg.pf_config[i])
    begin
      l_func_id = l_pcie_dev_top_cfg.pf_config[i].m_req_id;
      if(ari_enable) begin
        req_func_num = {l_func_id.device_num,l_func_id.function_num};
        cfg_func_num = {fn_id.device_num,fn_id.function_num};
        dev_num_match = 1'b1; //for ARI do not check for device, make it 1
      end
      else begin
        req_func_num = l_func_id.function_num;
        cfg_func_num = fn_id.function_num;
      end
      if(fn_id == l_func_id)
      begin
        {bus_num_match,dev_num_match,func_num_match}  = 3'b111;
        break;
      end
      else if(req_func_num == cfg_func_num) begin
        func_num_match=1'b1;
        if((fn_id.bus_num == l_func_id.bus_num)) begin
          bus_num_match = 1'b1;
        end
        else if (!ari_enable && (fn_id.device_num == l_func_id.device_num)) begin
          dev_num_match = 1'b1;
        end
      end
    end
    if(func_num_match == 0) begin
      foreach(l_pcie_dev_top_cfg.vf_config[i,j])
      begin
        l_func_id = l_pcie_dev_top_cfg.vf_config[i][j].m_req_id;
        if(ari_enable) begin
          req_func_num = {l_func_id.device_num,l_func_id.function_num};
          cfg_func_num = {fn_id.device_num,fn_id.function_num};
          dev_num_match = 1'b1; //for ARI do not check for device, make it 1
        end
        else begin
          req_func_num = l_func_id.function_num;
          cfg_func_num = fn_id.function_num;
        end
        if(fn_id == l_func_id)
        begin
          {bus_num_match,dev_num_match,func_num_match}  = 3'b111;
          break;
        end
        else if(req_func_num == cfg_func_num) begin
          func_num_match=1'b1;
          if((fn_id.bus_num == l_func_id.bus_num)) begin
            bus_num_match = 1'b1;
          end
          else if (!ari_enable && (fn_id.device_num == l_func_id.device_num)) begin
            dev_num_match = 1'b1;
          end
        end
      end
    end
    `uvm_info(get_full_name(),$sformatf("{bus_num_match,dev_num_match,func_num_match} = %0b",{bus_num_match,dev_num_match,func_num_match}),UVM_DEBUG);
    return {bus_num_match,dev_num_match,func_num_match};
  endfunction : check_bus_device_func


  //------------------------------------------------------------------------
  // Function: is_vf_mem_bar_hit
  // Method to detect the given address belongs to VF or not
  //------------------------------------------------------------------------
  function barInfo_t is_vf_mem_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;
    bit [63:0] start_addr;
    bit [63:0] end_addr;
    bit success_hit;
    ///bit[63:0] bar_size_loc;
    cdn_hpa_pcie_bar_type_t bar_type;

    // TODO: for EROM_BAR, there is no addr mentioned for EROM BAR

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    bar_32 = (bar_addr[63:32] == 0);


    //Search all available VFs
    foreach(dev_top_cfg.vf_config[i,j]) begin //{
      if(i >= parameters_cfg_pkg::MAX_PFS_WITH_VF) begin
        pkt_targeting_vf_in_not_allowed_pf = 1;
        continue;
      end
      if(!dev_top_cfg.pf_config[i].m_vf_en) begin//{
        pkt_targeting_disabled_vf = 1;
        continue;
      end//}
      if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) begin //{
        foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) begin //{
          if(
            (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
            ((dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
            (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_NON_PREFETCH) ||
            (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_PREFETCH) ||
            (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH))
          )
          begin //{
            start_addr = dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr;
            end_addr = dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr+ (2**(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].get_decoded_bar_aperture())) -1;

            if(bar_addr >= start_addr && bar_addr <= end_addr) begin //{
              is_vf_mem_bar_hit_info.vf_num  = j ;
              is_vf_mem_bar_hit_info.pf_num  = i ;
              is_vf_mem_bar_hit_info.bar_hit  = 1 ;
              is_vf_mem_bar_hit_info.bar_num  = bar_i;
              is_vf_mem_bar_hit_info.func_num = dev_top_cfg.vf_config[i][j].m_req_id.function_num;
              is_vf_mem_bar_hit_info.dev_num = dev_top_cfg.vf_config[i][j].m_req_id.device_num;
              is_vf_mem_bar_hit_info.bar_type = dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type;
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: with address (%0h) hits PF_%0d VF_%0d, start_addr = %0h, end_addr = %0h",bar_addr,i,j,start_addr, end_addr),UVM_LOW)
            end //}
          end //}
        end //}
      end //}
    end //}

    return is_vf_mem_bar_hit_info;

  endfunction : is_vf_mem_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_vf_id
  // Method to detect the given transaction id belongs to PF/VF
  //------------------------------------------------------------------------
  function bit is_vf_id(cdn_hpa_pcie_tlp_requester_id_s fn_id);
    // TODO: Function need to be implemented and change the return value
    return 0;
  endfunction : is_vf_id

  //------------------------------------------------------------------------
  // Function: randomize_mem_bar_addr
  // Method to detect the given address falling in any of the Memory BARs
  //TODO::undefined bar range in mem
  //------------------------------------------------------------------------
  function bit[63:0] randomize_mem_bar_addr (bit is_64, bit io_bar=0);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[31:0] bar_addr_32;
    bit[63:0] bar_addr;
    bit       mem_bar_hit;
    cdn_pcie_hpa_dev_top_config dev_top_cfg;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    if(is_64 == 0)
    begin //{
      bar_32 = 1;

      if (ep_rp_dut) begin // { EP
        `uvm_info(get_full_name(),$sformatf("dev_top_cfg=%0s",dev_top_cfg.get_name()),UVM_DEBUG)
        if(dev_top_cfg.m_ep_dev_bar_info)
        begin //{
          //For debug purpose
          //foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin
          //  foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin
          //    `uvm_info(get_full_name(),$sformatf("dev_top_cfg.m_ep_dev_bar_info.m_pf[%0d].bars[%0d] = %0s",i, j, dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].sprint()),UVM_DEBUG)
          //  end
          //end
          //foreach(dev_top_cfg.vf_config[i,j]) begin
          //  if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) begin
          //    foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) begin
          //      `uvm_info(get_full_name(),$sformatf(" dev_top_cfg.vf_config[%0d][%0d].m_fun_bar_info.bars[%0d] = %0s",i, j, bar_i, dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].sprint()),UVM_DEBUG)
          //    end
          //  end
          //end
          if(!io_bar) begin
            assert(std::randomize(bar_addr_32) with {
              foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) {
                foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) {
                  if (
                    dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
                    ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32) ||
                    (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32_PREFETCH) ||
                    (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MSI_OR_MSIX_BAR_32) ||
                    (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32))
                  ) {
                    !(bar_addr_32 inside {
                      [dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr :
                      dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size]
                    });
                  }
                }
              }
              foreach(dev_top_cfg.vf_config[i,j]) {
                if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) {
                  foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) {
                    if(
                      (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
                      ((dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
                      (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH)
                      || (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MSI_OR_MSIX_BAR_32))
                    ) {
                      !(bar_addr_32 inside {
                        [dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr :
                        dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr + (2**(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_aperture + 7)) -1]
                      });
                    }
                  }
                }
              }
              // For AtomicOp Requests, the Address must be naturally aligned with the operand size
              if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)) {
                bar_addr_32[2] == 0;
              }
              else if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) {
                if(m_tlp_length == 4) bar_addr_32[2] == 0;
                if(m_tlp_length == 8) bar_addr_32[3:2] == 0;
              }

              bar_addr_32[1:0] == 0;
              // Address cannot cross 4K boundary
              bar_addr_32[11:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h400;
              //TR should have [11:0] == 0 when page_align_req==1
              if(
                ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
                && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pcie_dev_cfg.m_ats_page_align_req
              ) {
                soft bar_addr_32[11:2] == 0;
              }
              if(m_tlp_length == 2) bar_addr_32[2] == 0; //To avoid CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR, CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR
            });
          end
          else begin
            foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
              foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
                if (
                  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
                  (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == IO_BAR)
                )
                begin //{
                  assert(std::randomize(bar_addr_32) with {bar_addr_32 inside {[dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr :
                  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size]};});
                  mem_bar_hit = 1;
                end //}
                if(mem_bar_hit) break;
              end //}
              if(mem_bar_hit) break;
            end //}
            if(mem_bar_hit) begin //{
              // For AtomicOp Requests, the Address must be naturally aligned with the operand size
              if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)) begin //{
                bar_addr_32[2] = 0;
              end //}
              else if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) begin //{
                if(m_tlp_length == 4) bar_addr_32[2] = 0;
                if(m_tlp_length == 8) bar_addr_32[3:2] = 0;
              end //}

              bar_addr_32[1:0] = 0;
              // //Address cannot cross 4K boundary
              // bar_addr_32[11:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h400;
              // //TR should have [11:0] == 0 when page_align_req==1
              // if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
              //           && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pcie_dev_cfg.m_ats_page_align_req) begin
              //           bar_addr_32[11:2] = 0;
              // end
              // if(m_tlp_length == 2) bar_addr_32[2] == 0; //To avoid CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR, CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR
            end //}
            else begin
              bar_addr_32 = 0;
            end
          end
        end //}
      end //}
 CDN_HPA_PCIE_TRANS_MEM_TYPE : begin
        // TODO check registering a strcture
        if(is_flit_mode) printer.print_int("implcit_byte_enable_mem_tlps", implcit_byte_enable_mem_tlps, 1);
        if(!is_flit_mode || (!implcit_byte_enable_mem_tlps && is_flit_mode)) begin
          printer.print_int("m_tlp_last_dw_be", m_tlp_last_dw_be, 4);
          printer.print_int("m_tlp_first_dw_be", m_tlp_first_dw_be, 4);
        end
        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
        printer.print_int("m_tlp_addr",m_tlp_addr,64);
        printer.print_string("m_tlp_at_type",m_tlp_at_type.name());

        if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
          if(!is_flit_mode) printer.print_int("m_tlp_ats_tr_nw_field",m_tlp_ats_tr_nw_field,1);
          if(cxl_mode) printer.print_int("m_cxl_src",m_cxl_src,1);
        end
      end
      CDN_HPA_PCIE_TRANS_IO_TYPE : begin
        printer.print_int("m_tlp_last_dw_be", m_tlp_last_dw_be, 4);
        printer.print_int("m_tlp_first_dw_be", m_tlp_first_dw_be, 4);
        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
        printer.print_int("m_tlp_addr",m_tlp_addr,64);
      end
      CDN_HPA_PCIE_TRANS_CFG_TYPE : begin
        printer.print_int("m_tlp_last_dw_be", m_tlp_last_dw_be, 4);
        printer.print_int("m_tlp_first_dw_be", m_tlp_first_dw_be, 4);

        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
        printer.print_int("m_tlp_completer_id", m_tlp_completer_id, 16);
        printer.print_int("m_tlp_ext_reg_num", m_tlp_ext_reg_num, 4);
        printer.print_int("m_tlp_reg_num", m_tlp_reg_num, 8);
        printer.print_int("is_blocking",is_blocking,$bits(is_blocking));
        printer.print_int("unique_id",unique_id,$bits(unique_id));
      end
      CDN_HPA_PCIE_TRANS_MSG_TYPE : begin
        printer.print_string("m_tlp_msg_code", m_tlp_msg_code.name());
        printer.print_string("m_tlp_msg_rout_type", m_tlp_msg_rout_type.name());
        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);

        if(m_tlp_msg_rout_type==CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
          printer.print_int("m_tlp_completer_id", m_tlp_completer_id, 16);
        end
        //ADD VDM separately
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin
          printer.print_int("m_tlp_vendor_id", m_tlp_vendor_id, 16);
          printer.print_int("m_tlp_vendor_msg_4th_DW", m_tlp_vendor_msg, 32);
        end

        if(cxl_mode && vdm_for_cxl==1 &&(m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0}) && (m_cxl_vdm_pm_logical_opcode != CDN_HPA_VDM_STD_VD_TYPE0)) begin //{
          if(print_rsvd_bits) begin
            printer.print_int("msg_pm_cxl_vnd_msg_byte_12_14_rsvd", msg_pm_cxl_vnd_msg_byte_12_14_rsvd,$bits(msg_pm_cxl_vnd_msg_byte_12_14_rsvd));
          end
          printer.print_string("m_cxl_vdm_pm_logical_opcode",m_cxl_vdm_pm_logical_opcode.name());
          if(print_rsvd_bits) begin
            printer.print_int("m_cxl_vdm_pm_agt_id_rsvd_bit", m_cxl_vdm_pm_agt_id_rsvd_bit,$bits(m_cxl_vdm_pm_agt_id_rsvd_bit));
          end
          printer.print_int("m_cxl_vdm_pm_agt_id", m_cxl_vdm_pm_agt_id,$bits(m_cxl_vdm_pm_agt_id));
          printer.print_int("m_cxl_vdm_parameter", m_cxl_vdm_parameter,$bits(m_cxl_vdm_parameter));
          printer.print_int("m_cxl_vdm_payload", m_cxl_vdm_payload,$bits(m_cxl_vdm_payload));
          if(cxl_version == 2 && cxl_mode ==1) begin // MP
            if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_agt_info_param_byte1_rsvd", m_cxl_vdm_agt_info_param_byte1_rsvd,$bits(m_cxl_vdm_agt_info_param_byte1_rsvd));
              end
              printer.print_int("m_cxl_vdm_agt_info_index", m_cxl_vdm_agt_info_index,$bits(m_cxl_vdm_agt_info_index));
              printer.print_int("m_cxl_vdm_agt_info_req_or_rsp", m_cxl_vdm_agt_info_req_or_rsp,$bits(m_cxl_vdm_agt_info_req_or_rsp));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_agt_info_payload_rsvd_93_3", m_cxl_vdm_agt_info_payload_rsvd_93_3,$bits(m_cxl_vdm_agt_info_payload_rsvd_93_3));
              end
              printer.print_int("m_cxl_vdm_agt_info_capability_vector_bit1", m_cxl_vdm_agt_info_capability_vector_bit1,$bits(m_cxl_vdm_agt_info_capability_vector_bit1));
              printer.print_int("m_cxl_vdm_agt_info_capability_vector_bit0", m_cxl_vdm_agt_info_capability_vector_bit0,$bits(m_cxl_vdm_agt_info_capability_vector_bit0));
            end
            if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_resetprep_param_byte0_1_rsvd", m_cxl_vdm_resetprep_param_byte0_1_rsvd,$bits(m_cxl_vdm_resetprep_param_byte0_1_rsvd));
              end
              printer.print_int("m_cxl_vdm_resetprep_req_or_rsp", m_cxl_vdm_resetprep_req_or_rsp,$bits(m_cxl_vdm_resetprep_req_or_rsp));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_resetprep_payload_rsvd_95_9", m_cxl_vdm_resetprep_payload_rsvd_95_9,$bits(m_cxl_vdm_resetprep_payload_rsvd_95_9));
              end
              printer.print_int("m_cxl_vdm_resetprep_prep_type", m_cxl_vdm_resetprep_prep_type,$bits(m_cxl_vdm_resetprep_prep_type));
              printer.print_int("m_cxl_vdm_resetprep_reset_type", m_cxl_vdm_resetprep_reset_type,$bits(m_cxl_vdm_resetprep_reset_type));
            end
            if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_pmreq_param_byte0_1_rsvd", m_cxl_vdm_pmreq_param_byte0_1_rsvd,$bits(m_cxl_vdm_pmreq_param_byte0_1_rsvd));
              end
              printer.print_int("m_cxl_vdm_pmreq_go", m_cxl_vdm_pmreq_go,$bits(m_cxl_vdm_pmreq_go));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_pmreq_param_bit1_rsvd", m_cxl_vdm_pmreq_param_bit1_rsvd,$bits(m_cxl_vdm_pmreq_param_bit1_rsvd));
              end
              printer.print_int("m_cxl_vdm_pmreq_req_or_rsp", m_cxl_vdm_pmreq_req_or_rsp,$bits(m_cxl_vdm_pmreq_req_or_rsp));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_pmreq_payload_rsvd", m_cxl_vdm_pmreq_payload_rsvd,$bits(m_cxl_vdm_pmreq_payload_rsvd));
              end
              printer.print_int("m_cxl_vdm_pmreq_ltr_2", m_cxl_vdm_pmreq_ltr_2,$bits(m_cxl_vdm_pmreq_ltr_2));
            end
            if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_GPF) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_gpf_param_byte0_1_rsvd", m_cxl_vdm_gpf_param_byte0_1_rsvd,$bits(m_cxl_vdm_gpf_param_byte0_1_rsvd));
              end
              printer.print_int("m_cxl_vdm_gpf_req_or_rsp", m_cxl_vdm_gpf_req_or_rsp,$bits(m_cxl_vdm_gpf_req_or_rsp));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_gpf_payload_rsvd_95_18", m_cxl_vdm_gpf_payload_rsvd_95_18,$bits(m_cxl_vdm_gpf_payload_rsvd_95_18));
              end
              printer.print_int("m_cxl_vdm_gpf_payload_phase", m_cxl_vdm_gpf_payload_phase,$bits(m_cxl_vdm_gpf_payload_phase));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_gpf_payload_rsvd_15_9", m_cxl_vdm_gpf_payload_rsvd_15_9,$bits(m_cxl_vdm_gpf_payload_rsvd_15_9));
              end
              printer.print_int("m_cxl_vdm_gpf_status_bit8", m_cxl_vdm_gpf_status_bit8,$bits(m_cxl_vdm_gpf_status_bit8));
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_gpf_payload_rsvd_7_2", m_cxl_vdm_gpf_payload_rsvd_7_2,$bits(m_cxl_vdm_gpf_payload_rsvd_7_2));
              end
              printer.print_int("m_cxl_vdm_gpf_payload_bit1", m_cxl_vdm_gpf_payload_bit1,$bits(m_cxl_vdm_gpf_payload_bit1));
              printer.print_int("m_cxl_vdm_gpf_payload_bit0", m_cxl_vdm_gpf_payload_bit0,$bits(m_cxl_vdm_gpf_payload_bit0));
            end
            if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) begin
              if(print_rsvd_bits) begin
                printer.print_int("m_cxl_vdm_crd_rtn_param_field_rsvd", m_cxl_vdm_crd_rtn_param_field_rsvd,$bits(m_cxl_vdm_crd_rtn_param_field_rsvd));
                printer.print_int("m_cxl_vdm_crd_rtn_payload_rsvd", m_cxl_vdm_crd_rtn_payload_rsvd,$bits(m_cxl_vdm_crd_rtn_payload_rsvd));
              end
              printer.print_int("m_cxl_vdm_crd_rtn_payload_tgt_agt_id", m_cxl_vdm_crd_rtn_payload_tgt_agt_id,$bits(m_cxl_vdm_crd_rtn_payload_tgt_agt_id));
              printer.print_int("m_cxl_vdm_crd_rtn_payload_num_credits", m_cxl_vdm_crd_rtn_payload_num_credits,$bits(m_cxl_vdm_crd_rtn_payload_num_credits));
            end
          end //}
        end else begin
          if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_agt_info_param_byte1_rsvd", m_cxl_vdm_agt_info_param_byte1_rsvd,$bits(m_cxl_vdm_agt_info_param_byte1_rsvd));
            end
            printer.print_int("m_cxl_vdm_agt_info_index", m_cxl_vdm_agt_info_index,$bits(m_cxl_vdm_agt_info_index));
            printer.print_int("m_cxl_vdm_agt_info_req_or_rsp", m_cxl_vdm_agt_info_req_or_rsp,$bits(m_cxl_vdm_agt_info_req_or_rsp));
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_agt_info_payload_rsvd", m_cxl_vdm_agt_info_payload_rsvd,$bits(m_cxl_vdm_agt_info_payload_rsvd));
            end
            printer.print_int("m_cxl_vdm_agt_info_revision_id", m_cxl_vdm_agt_info_revision_id,$bits(m_cxl_vdm_agt_info_revision_id));
          end
          if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_resetprep_param_byte0_1_rsvd", m_cxl_vdm_resetprep_param_byte0_1_rsvd,$bits(m_cxl_vdm_resetprep_param_byte0_1_rsvd));
            end
            printer.print_int("m_cxl_vdm_resetprep_req_or_rsp", m_cxl_vdm_resetprep_req_or_rsp,$bits(m_cxl_vdm_resetprep_req_or_rsp));
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_resetprep_payload_rsvd", m_cxl_vdm_resetprep_payload_rsvd,$bits(m_cxl_vdm_resetprep_payload_rsvd));
            end
            printer.print_int("m_cxl_vdm_resetprep_phase", m_cxl_vdm_resetprep_phase,$bits(m_cxl_vdm_resetprep_phase));
            printer.print_int("m_cxl_vdm_resetprep_prep_type", m_cxl_vdm_resetprep_prep_type,$bits(m_cxl_vdm_resetprep_prep_type));
            printer.print_int("m_cxl_vdm_resetprep_reset_type", m_cxl_vdm_resetprep_reset_type,$bits(m_cxl_vdm_resetprep_reset_type));
          end
          if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_pmreq_param_byte0_1_rsvd", m_cxl_vdm_pmreq_param_byte0_1_rsvd,$bits(m_cxl_vdm_pmreq_param_byte0_1_rsvd));
            end
            printer.print_int("m_cxl_vdm_pmreq_go", m_cxl_vdm_pmreq_go,$bits(m_cxl_vdm_pmreq_go));
            printer.print_int("m_cxl_vdm_pmreq_ea", m_cxl_vdm_pmreq_ea,$bits(m_cxl_vdm_pmreq_ea));
            printer.print_int("m_cxl_vdm_pmreq_req_or_rsp", m_cxl_vdm_pmreq_req_or_rsp,$bits(m_cxl_vdm_pmreq_req_or_rsp));
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_pmreq_payload_rsvd", m_cxl_vdm_pmreq_payload_rsvd,$bits(m_cxl_vdm_pmreq_payload_rsvd));
            end
            printer.print_int("m_cxl_vdm_pmreq_ltr", m_cxl_vdm_pmreq_ltr,$bits(m_cxl_vdm_pmreq_ltr));
          end
          if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) begin
            if(print_rsvd_bits) begin
              printer.print_int("m_cxl_vdm_crd_rtn_param_field_rsvd", m_cxl_vdm_crd_rtn_param_field_rsvd,$bits(m_cxl_vdm_crd_rtn_param_field_rsvd));
              printer.print_int("m_cxl_vdm_crd_rtn_payload_rsvd", m_cxl_vdm_crd_rtn_payload_rsvd,$bits(m_cxl_vdm_crd_rtn_payload_rsvd));
            end
            printer.print_int("m_cxl_vdm_crd_rtn_payload_tgt_agt_id", m_cxl_vdm_crd_rtn_payload_tgt_agt_id,$bits(m_cxl_vdm_crd_rtn_payload_tgt_agt_id));
            printer.print_int("m_cxl_vdm_crd_rtn_payload_num_credits", m_cxl_vdm_crd_rtn_payload_num_credits,$bits(m_cxl_vdm_crd_rtn_payload_num_credits));
          end
        end //}

        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin
          printer.print_string("m_tlp_vdm_msg_subtype", m_tlp_vdm_msg_subtype.name());
          if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_HIER_ID) begin
            printer.print_int("m_tlp_hier_vmsg_hierarchy_id", m_tlp_hier_vmsg_hierarchy_id,16);
            printer.print_int("m_tlp_hier_vmsg_guid_authority_id", m_tlp_hier_vmsg_guid_authority_id,8);
            printer.print_int("m_tlp_hier_vmsg_system_guid", m_tlp_hier_vmsg_system_guid,144);
          end
          if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_FRS) begin
            printer.print_string("m_tlp_frs_msg_reason", m_tlp_frs_msg_reason.name());
          end
          if( m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_LN) begin
            printer.print_int("m_tlp_ln_msg_cacheline_addr", m_tlp_ln_msg_cacheline_addr,58);
            printer.print_int("m_tlp_ln_msg_nr", m_tlp_ln_msg_nr,2);
          end
        end

        // IF LTR message add
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin
          printer.print_int("m_tlp_ltr_msg_no_snoop_latency",m_tlp_ltr_msg_no_snoop_latency,16);
          printer.print_int("m_tlp_ltr_msg_snoop_latency",m_tlp_ltr_msg_snoop_latency,16);
        end

        // If ATS mesage
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin
          printer.print_int("m_inv_cpl_cnt",m_inv_cpl_cnt,3);
          printer.print_int("m_tlp_itag_vector",m_tlp_itag_vector,32);
        end

        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
          printer.print_int("m_tlp_itag",m_tlp_itag,5);
        end
        // OBFF message
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin
          printer.print_string("m_obffCode",m_obffCode.name());
        end

        // IDE FAIL message
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Fail) begin
          printer.print_int("msg_ide_fail_stream_id",msg_ide_fail_stream_id, 8);
        end

        // IDE SYNC message
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Sync) begin
          printer.print_int("msg_ide_sync_pr_sent_cnt_cpl",msg_ide_sync_pr_sent_cnt_cpl, 8);
          printer.print_int("msg_ide_sync_pr_sent_cnt_np",msg_ide_sync_pr_sent_cnt_np, 8);
        end

        // IDE ESCORT message
        if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin
          printer.print_int("msg_ide_escort_sse",msg_ide_escort_sse, 2);
        end

        // PTM message
        if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD})) begin
          printer.print_int("m_ptmMasterTime",m_ptmMasterTime,64);
          printer.print_int("m_ptmPropagationDelay",m_ptmPropagationDelay,32);
        end

        // ATS - PRI
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request}) begin
          printer.print_int("m_page_addr",m_page_addr,52);
          printer.print_int("m_prReadRequested",m_prReadRequested,1);
          printer.print_int("m_prWriteRequested",m_prWriteRequested,1);
          printer.print_int("m_prLastRequest",m_prLastRequest,1);
        end
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}) begin
          printer.print_int("m_prGroupIndex",m_prGroupIndex,9);
        end

        // Page request response
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}) begin
          printer.print_int("m_prgResponseCode",m_prgResponseCode,4);
        end
      end

      CDN_HPA_PCIE_TRANS_CPL_TYPE: begin
        printer.print_int("m_tlp_completer_id", m_tlp_completer_id, 16);
        printer.print_string("m_tlp_cpl_status",m_tlp_cpl_status.name());
        if(!is_flit_mode) printer.print_int("m_tlp_cpl_bcm", m_tlp_cpl_bcm, 1);
        //if(is_flit_mode) printer.print_int("m_completion_segment_differ", m_completion_segment_differ, 1);
        printer.print_int("m_tlp_cpl_byte_cnt", m_tlp_cpl_byte_cnt, 12);

        printer.print_int("m_tlp_requester_id", m_tlp_requester_id, 16);
        printer.print_int("m_tlp_cpl_lower_addr", m_tlp_cpl_lower_addr, 12);
        printer.print_int("rsvd_4th_dw", rsvd_4th_dw, 32);
        printer.print_int("rsvd_5th_dw", rsvd_5th_dw, 32);
        printer.print_int("rsvd_6th_dw", rsvd_6th_dw, 32);
        printer.print_int("rsvd_7th_dw", rsvd_7th_dw, 32);
        if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl,CDN_HPA_PCIE_TLP_TYPE_UIORdCpl,CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) begin
          printer.print_int("m_tlp_cpl_cdl", m_tlp_cpl_cdl, 2);
        end
      end

      default : begin
        `uvm_warning(get_type_name(), $psprintf("TLP Type is not valid"))
      end
    endcase

    //Prefixes
    printer.print_int("m_tlp_uses_dedicated_credits",m_tlp_uses_dedicated_credits,$bits(m_tlp_uses_dedicated_credits));
    printer.print_int("m_max_no_of_local_prefixes",m_max_no_of_local_prefixes,$bits(m_max_no_of_local_prefixes));
    printer.print_int("m_local_prefix_possible",m_local_prefix_possible,$bits(m_local_prefix_possible));
    foreach(m_tlp_local_prefix[i]) begin
      printer.print_int($psprintf("m_tlp_local_prefix[%0d]",i),m_tlp_local_prefix[i],$bits(m_tlp_local_prefix[i]));
      printer.print_int($psprintf("m_tlp_local_prefix_data[%0d]",i),m_tlp_local_prefix_data[i],$bits(m_tlp_local_prefix_data[i]));
      printer.print_string($psprintf("m_hdr_type_local_prefix[%0d]",i),m_hdr_type_local_prefix[i].name());
    end
    if(m_ide_prefix_present || (m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE}) || ((m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MSG_TYPE}) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response,CDN_HPA_PCIE_TLP_MSG_AT_Invalidate})))begin
      printer.print_int("m_max_no_of_prefixes",m_max_no_of_prefixes,$bits(m_max_no_of_prefixes));
      if(m_max_no_of_prefixes!=0) begin
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) begin
          printer.print_int("m_tph_present",m_tph_present,1);
          printer.print_int("m_ext_tph_prefix_present",m_ext_tph_prefix_present,1);
        end
        printer.print_int("m_pasid_prefix_present",m_pasid_prefix_present,1);
        printer.print_int("m_ide_prefix_present",m_ide_prefix_present,1);
        printer.print_int("m_sel_stream_possible",m_sel_stream_possible,1);
      end
      if(!is_flit_mode && (m_ext_tph_prefix_present || m_tph_present)) begin
        printer.print_int("m_tlp_st_tag",m_tlp_st_tag,16);
        printer.print_int("m_tlp_ph",m_tlp_ph,2);
      end
      if((hpa_generation == hpa_generation_2) && !is_flit_mode) begin
        printer.print_int("m_ama_valid",m_ama_valid,$bits(m_ama_valid));
        printer.print_int("m_ama_value",m_ama_value,$bits(m_ama_value));
      end
      if(!is_flit_mode && m_pasid_prefix_present) begin
        printer.print_int("m_pasid_value",m_pasid_value,20);
        printer.print_int("m_pasid_pri_value",m_pasid_pri_value,1);
        printer.print_int("m_pasid_exec_value",m_pasid_exec_value,1);
      end
      if(!is_flit_mode && m_ide_prefix_present) begin
        printer.print_int("m_ide_tlp_prefix",m_ide_tlp_prefix,32);
        printer.print_int("m_ide_hdr_type_prefix",m_ide_hdr_type_prefix,5);
        printer.print_int("m_ide_hdr_fmt_prefix",m_ide_hdr_fmt_prefix,3);
        printer.print_int("use_user_defined_stream_id",use_user_defined_stream_id,$bits(use_user_defined_stream_id));
        printer.print_int("m_stream_id_int",m_stream_id_int,$bits(m_stream_id_int));
        printer.print_int("m_stream_id",m_stream_id,8);
        printer.print_int("m_sub_stream",m_sub_stream,4);
        printer.print_int("m_pr_sent_counter",m_pr_sent_counter,8);
        printer.print_int("m_ide_m",m_ide_m,1);
        printer.print_int("m_ide_p",m_ide_p,1);
        printer.print_int("m_ide_k",m_ide_k,1);
        printer.print_int("m_ide_t",m_ide_t,1);
        if(m_ide_m) begin
          foreach(m_ide_mac[i])
          printer.print_int($psprintf("m_ide_mac[%0d]", i),m_ide_mac[i],8);
        end
        if(m_ide_p)
        printer.print_int("m_ide_pcrc",m_ide_pcrc,32);
      end
      foreach(m_tlp_prefix[i]) begin
        if(!is_flit_mode || m_tlp_prefix[i][31:28] != 4'b1001) printer.print_int($psprintf("m_tlp_prefix[%0d]",i),m_tlp_prefix[i],32);
      end
    end

    if(is_flit_mode) begin
      if(m_ohc_hdr.ohc_a_present) begin
        printer.print_int("m_ohc_a",m_ohc_a,$bits(m_ohc_a));
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE,CDN_HPA_PCIE_TRANS_MSG_TYPE,CDN_HPA_PCIE_TRANS_CPL_TYPE}) begin
          printer.print_int("m_destination_segment",m_destination_segment,$bits(m_destination_segment));
          printer.print_int("m_destination_segment_valid",m_destination_segment_valid,$bits(m_destination_segment_valid));
        end
        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) begin
          printer.print_int("m_completer_segment",m_completer_segment,$bits(m_completer_segment));
        end
        if(m_pasid_prefix_present) begin
          printer.print_int("m_pasid_value",m_pasid_value,20);
          printer.print_int("m_pasid_pri_value",m_pasid_pri_value,1);
          printer.print_int("m_pasid_exec_value",m_pasid_exec_value,1);
        end
      end
      if(m_ohc_hdr.ohc_b_present) begin
        printer.print_int("m_ohc_b",m_ohc_b,$bits(m_ohc_b));
        if(m_ext_tph_prefix_present || m_tph_present) begin
          printer.print_int("m_tlp_st_tag",m_tlp_st_tag,16);
          printer.print_int("m_tlp_ph",m_tlp_ph,2);
        end
        printer.print_int("m_hv",m_hv,$bits(m_hv));
        printer.print_int("m_ama_value",m_ama_value,$bits(m_ama_value));
        printer.print_int("m_ama_valid",m_ama_valid,$bits(m_ama_valid));
      end
      if(m_ohc_hdr.ohc_c_present) begin
        printer.print_int("m_ohc_c",m_ohc_c,$bits(m_ohc_c));
        printer.print_int("m_requester_segment",m_requester_segment,$bits(m_requester_segment));
        printer.print_int("m_pr_sent_counter",m_pr_sent_counter,$bits(m_pr_sent_counter));
        printer.print_int("m_stream_id",m_stream_id,$bits(m_stream_id));
        printer.print_int("m_sub_stream",m_sub_stream,$bits(m_sub_stream));
        printer.print_int("m_requester_segment_valid",m_requester_segment_valid,$bits(m_requester_segment_valid));
        printer.print_int("m_ide_k",m_ide_k,$bits(m_ide_k));
        printer.print_int("m_ide_t",m_ide_t,$bits(m_ide_t));
      end
      if(m_ohc_hdr.ohc_ex_present!=no_ohc_ex_present) begin
        printer.print_int("num_of_vnd_e2e_prefixes",num_of_vnd_e2e_prefixes,$bits(num_of_vnd_e2e_prefixes));
        printer.print_int("num_of_valid_vnd_e2e_prefixes",num_of_valid_vnd_e2e_prefixes,$bits(num_of_valid_vnd_e2e_prefixes));
        foreach(m_ohc_e[i])
        printer.print_int($psprintf("m_ohc_e[%0d]",i),m_ohc_e[i],32);
      end
    end

    // TODO Add payload in custom way?
    foreach(m_tlp_payload[i])  begin
      if((i<=7) || (i>=(((m_tlp_length== 0) ? 1022 : m_tlp_length-2) * 4))) printer.print_int($psprintf("m_tlp_payload[%0d]",i),m_tlp_payload[i],8);
    end

    if(is_flit_mode) begin
      for(int i=0; i<(m_ts_payload.size()/4); i++) begin
        printer.print_int($psprintf("m_trailer[%0d]",i),{m_ts_payload[3+i*4],m_ts_payload[2+i*4],m_ts_payload[1+i*4],m_ts_payload[i*4]},32);
      end
    end

    if(!is_flit_mode) printer.print_int("ecrc_val",ecrc_val,32);

    //Print reseved fields (when control knob is enabled)
    if(print_rsvd_bits) begin
      if(is_flit_mode && m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE})
      printer.print_int("second_dw_byte_6_field_6_rsvd",second_dw_byte_6_field_6_rsvd,$bits(second_dw_byte_6_field_6_rsvd));
      if(is_flit_mode) begin //{
        if(m_ohc_hdr.ohc_a_present) begin
          if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            printer.print_int("m_tlp_ats_tr_nw_field",m_tlp_ats_tr_nw_field,1);
          end else if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE}) printer.print_int("m_ohc_a1_byte_0_field_7_rsvd",m_ohc_a1_byte_0_field_7_rsvd,$bits(m_ohc_a1_byte_0_field_7_rsvd));
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE}) printer.print_int("m_ohc_a2_byte_0_2_rsvd",m_ohc_a2_byte_0_2_rsvd,$bits(m_ohc_a2_byte_0_2_rsvd));
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE})begin
            printer.print_int("m_ohc_a3_byte_1_rsvd",m_ohc_a3_byte_1_rsvd,$bits(m_ohc_a3_byte_1_rsvd));
            printer.print_int("m_ohc_a3_byte_2_rsvd",m_ohc_a3_byte_2_rsvd,$bits(m_ohc_a3_byte_2_rsvd));
          end
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MSG_TYPE})begin
            if(pcie_6_1_support && m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Request) begin
              printer.print_int("m_ohc_a1_byte_0_field_7_rsvd",m_ohc_a1_byte_0_field_7_rsvd,$bits(m_ohc_a1_byte_0_field_7_rsvd));
              printer.print_int("m_ohc_a1_byte_3_rsvd",m_ohc_a1_byte_3_rsvd,$bits(m_ohc_a1_byte_3_rsvd));
            end else begin
              printer.print_int("second_dw_byte_6_msg_rsvd",second_dw_byte_6_msg_rsvd,$bits(second_dw_byte_6_msg_rsvd));
              printer.print_int("m_ohc_a4_byte_2_field_5_4_rsvd", m_ohc_a4_byte_2_field_5_4_rsvd, $bits(m_ohc_a4_byte_2_field_5_4_rsvd));
            end
          end
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE}) printer.print_int("m_ohc_a5_byte_2_3_rsvd",m_ohc_a5_byte_2_3_rsvd,$bits(m_ohc_a5_byte_2_3_rsvd));
        end
        if(m_ohc_hdr.ohc_b_present) begin
          printer.print_int("m_ohc_b_byte_0_rsvd",m_ohc_b_byte_0_rsvd,$bits(m_ohc_b_byte_0_rsvd));
        end
        if(m_ohc_hdr.ohc_c_present) begin
          printer.print_int("m_ohc_c_byte_3_field_2_rsvd",m_ohc_c_byte_3_field_2_rsvd,$bits(m_ohc_c_byte_3_field_2_rsvd));
        end
      end //}

      if(m_ext_tph_prefix_present) printer.print_int("tph_byte_2_3_rsvd",tph_byte_2_3_rsvd,16);
      if(m_pasid_prefix_present) printer.print_int("pasid_byte_1_rsvd_field_5_4",pasid_byte_1_rsvd_field_5_4,2);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE) printer.print_int("io_byte_11_rsvd_field_1_0",io_byte_11_rsvd_field_1_0,2);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) printer.print_int("cfg_byte_10_rsvd_field_7_4",cfg_byte_10_rsvd_field_7_4,4);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) printer.print_int("cpl_byte_12_rsvd_field_7",cpl_byte_12_rsvd_field_7,1);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) printer.print_int("cpl_byte_12_rsvd_field_4_0",cpl_byte_12_rsvd_field_4_0, 5);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) printer.print_int("cpl_byte_11_rsvd_field_7_4",cpl_byte_11_rsvd_field_7_4, 4);
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) printer.print_int("cpl_byte_11_rsvd_field_3_0",cpl_byte_11_rsvd_field_3_0, 4);

      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) begin
        if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_DRS}) begin
          printer.print_int("msg_ln_drs_byte_13_15_rsvd",msg_ln_drs_byte_13_15_rsvd,$bits(msg_ln_drs_byte_13_15_rsvd));
        end else if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}) begin
          printer.print_int("msg_frs_byte_13_15_rsvd",msg_frs_byte_13_15_rsvd,$bits(msg_frs_byte_13_15_rsvd));
        end else if (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
          printer.print_int("msg_inv_req_byte_6_field_6_5_rsvd",msg_inv_req_byte_6_field_6_5_rsvd,$bits(msg_inv_req_byte_6_field_6_5_rsvd));
          printer.print_int("msg_inv_req_byte_10_15_rsvd",msg_inv_req_byte_10_15_rsvd,$bits(msg_inv_req_byte_10_15_rsvd));
        end else if (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin
          printer.print_int("msg_inv_cpl_byte_10_11_rsvd",msg_inv_cpl_byte_10_11_rsvd,$bits(msg_inv_cpl_byte_10_11_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin
          printer.print_int("msg_ltr_byte_8_11_rsvd",msg_ltr_byte_8_11_rsvd,$bits(msg_ltr_byte_8_11_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Group_Response) begin
          printer.print_int("msg_pr_rsp_byte_10_field_3_1_rsvd",msg_pr_rsp_byte_10_field_3_1_rsvd,$bits(msg_pr_rsp_byte_10_field_3_1_rsvd));
          printer.print_int("msg_pr_rsp_byte_12_15_rsvd",msg_pr_rsp_byte_12_15_rsvd,$bits(msg_pr_rsp_byte_12_15_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin
          printer.print_int("msg_obff_byte_8_14_rsvd",msg_obff_byte_8_14_rsvd,$bits(msg_obff_byte_8_14_rsvd));
        end else if((!(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1,CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD})) || ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD))) begin //3rd & 4th DW are Rsvd for other messages
          printer.print_int("msg_cmn_byte_8_15_rsvd",msg_cmn_byte_8_15_rsvd,$bits(msg_cmn_byte_8_15_rsvd));
        end
      end
    end

    printer.print_int("pkt_num",pkt_num,$bits(pkt_num));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) printer.print_int("p_pkt_num",p_pkt_num,$bits(p_pkt_num));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) printer.print_int("np_pkt_num",np_pkt_num,$bits(np_pkt_num));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) printer.print_int("cpl_pkt_num",cpl_pkt_num,$bits(cpl_pkt_num));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) printer.print_int("cpl_pkt_num_in_flit",cpl_pkt_num_in_flit,$bits(cpl_pkt_num_in_flit));
    printer.print_int("pkt_rx_time",pkt_rx_time,$bits(pkt_rx_time),UVM_TIME);

    if(print_intx) begin
      printer.print_int("print_intx",print_intx,$bits(print_intx));
      printer.print_int("pack_intx",pack_intx,$bits(pack_intx));
      printer.print_int("requestor_id",requestor_id,$bits(requestor_id));
      printer.print_int("is_high",is_high,$bits(is_high));
      printer.print_int("intx_in_pin_value",intx_in_pin_value,$bits(intx_in_pin_value));
      printer.print_int("intx_out_pin_value",intx_out_pin_value,$bits(intx_out_pin_value));
      printer.print_int("int_ack_pin_value",int_ack_pin_value,$bits(int_ack_pin_value));
      printer.print_int("intx_pending_status",intx_pending_status,$bits(intx_pending_status));
      //  printer.print_int("m_intr_pins",m_intr_pins,$bits(m_intr_pins));
      printer.print_int("fid_active",fid_active,$bits(fid_active));
    end
    if(print_msi_msix) begin
      printer.print_int("print_msi_msix",print_msi_msix,$bits(print_msi_msix));
      printer.print_int("pack_msi_msix",pack_msi_msix,$bits(pack_msi_msix));
      printer.print_int("msi_en",msi_en,$bits(msi_en));
      printer.print_int("id_based_ordering",id_based_ordering,$bits(id_based_ordering));
      printer.print_int("msi_msix_requestor_id",msi_msix_requestor_id,$bits(msi_msix_requestor_id));
      printer.print_int("intr_number",intr_number,$bits(intr_number));
      printer.print_int("intr_number_bits",intr_number_bits,$bits(intr_number_bits));
      printer.print_int("intr_number_bits_cap",intr_number_bits_cap,$bits(intr_number_bits_cap));
      printer.print_int("int_msix_msg_data",int_msix_msg_data,$bits(int_msix_msg_data));
      printer.print_int("int_msix_msg_lo_addr",int_msix_msg_lo_addr,$bits(int_msix_msg_lo_addr));
      printer.print_int("int_msix_msg_hi_addr",int_msix_msg_hi_addr,$bits(int_msix_msg_hi_addr));
      printer.print_int("pending_status",pending_status,$bits(pending_status));
      printer.print_int("requestor_id_for_pending_status",requestor_id_for_pending_status,$bits(requestor_id_for_pending_status));
      printer.print_int("int_msi_pending_status_valid",int_msi_pending_status_valid,$bits(int_msi_pending_status_valid));
      printer.print_int("int_msi_pending_status",int_msi_pending_status,$bits(int_msi_pending_status));
      printer.print_int("msi_msg_low_addr",msi_msg_low_addr,$bits(msi_msg_low_addr));
      printer.print_int("msi_msg_hi_addr",msi_msg_hi_addr,$bits(msi_msg_hi_addr));
      printer.print_int("msi_msg_hi_addr",msi_msg_hi_addr,$bits(msi_msg_hi_addr));
      printer.print_int("msi_msg_data",msi_msg_data,$bits(msi_msg_data));
      printer.print_int("ext_msg_data_en",ext_msg_data_en,$bits(ext_msg_data_en));
      printer.print_int("msi_64bit_addr_cap",msi_64bit_addr_cap,$bits(msi_64bit_addr_cap));
      printer.print_int("msi_per_vector_masking_cap",msi_per_vector_masking_cap,$bits(msi_per_vector_masking_cap));
      printer.print_int("st_tag_pin_or_reg",st_tag_pin_or_reg,$bits(st_tag_pin_or_reg));
      printer.print_int("tph_st_table_index",tph_st_table_index,$bits(tph_st_table_index));
      printer.print_int("int_mask_changed_ipfivf",int_mask_changed_ipfivf,$bits(int_mask_changed_ipfivf));
      printer.print_int("int_mask_changed_valid",int_mask_changed_valid,$bits(int_mask_changed_valid));
      printer.print_int("int_msg_done",int_msg_done,$bits(int_msg_done));
      printer.print_int("int_msi_cap",int_msi_cap,$bits(int_msi_cap));
      printer.print_int("int_msix_cap",int_msix_cap,$bits(int_msix_cap));
    end

    printer.print_int("is_ib_pkt",is_ib_pkt,$bits(is_ib_pkt));
    if(m_tlp_trans_type==CDN_HPA_PCIE_TRANS_CFG_TYPE) begin
      printer.print_int("cfg_type1_target_pri",cfg_type1_target_pri,$bits(cfg_type1_target_pri));
      printer.print_int("cfg_type0_target_pri",cfg_type0_target_pri,$bits(cfg_type0_target_pri));
      printer.print_int("cfg_type1_target_sec",cfg_type1_target_sec,$bits(cfg_type1_target_sec));
      printer.print_int("cfg_type1_target_sec_non_zero_dev_ari_dis",cfg_type1_target_sec_non_zero_dev_ari_dis,$bits(cfg_type1_target_sec_non_zero_dev_ari_dis));
      printer.print_int("cfg_type1_target_pri_wrong_dev_fun",cfg_type1_target_pri_wrong_dev_fun,$bits(cfg_type1_target_pri_wrong_dev_fun));
      printer.print_int("cfg_type1_target_more_than_sec_less_equal_to_sub",cfg_type1_target_more_than_sec_less_equal_to_sub,$bits(cfg_type1_target_more_than_sec_less_equal_to_sub));
      printer.print_int("cfg_type1_target_more_than_sub",cfg_type1_target_more_than_sub,$bits(cfg_type1_target_more_than_sub));
    end
    printer.print_int("m_cpl_part",m_cpl_part,$bits(m_cpl_part));
    printer.print_int("m_expect_enderror",m_expect_enderror,$bits(m_expect_enderror));
    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) begin
      printer.print_int("is_translation_cpl",is_translation_cpl,$bits(is_translation_cpl));
    end
    if(is_ib_pkt) begin
      if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) begin
        printer.print_int("hls_ib_cpl_meta_s.pf", hls_ib_cpl_meta_s.pf, $bits(hls_ib_cpl_meta_s.pf) );
        printer.print_int("hls_ib_cpl_meta_s.vf", hls_ib_cpl_meta_s.vf, $bits(hls_ib_cpl_meta_s.vf) );
        printer.print_int("hls_ib_cpl_meta_s.vf_or_pf", hls_ib_cpl_meta_s.vf_or_pf, $bits(hls_ib_cpl_meta_s.vf_or_pf) );
        printer.print_int("hls_ib_cpl_meta_s.cpl_complete", hls_ib_cpl_meta_s.cpl_complete, $bits(hls_ib_cpl_meta_s.cpl_complete) );
        printer.print_int("hls_ib_cpl_meta_s.cpl_err_code", hls_ib_cpl_meta_s.cpl_err_code, $bits(hls_ib_cpl_meta_s.cpl_err_code) );
        `ifdef HPA_ARCH2
          printer.print_int("hls_ib_cpl_meta_s.generated_tlp", hls_ib_cpl_meta_s.generated_tlp, $bits(hls_ib_cpl_meta_s.generated_tlp) );
        `endif
      end else begin //P/NP
        printer.print_int("hls_ib_p_np_meta_s.pf", hls_ib_p_np_meta_s.pf, $bits(hls_ib_p_np_meta_s.pf) );
        printer.print_int("hls_ib_p_np_meta_s.vf", hls_ib_p_np_meta_s.vf, $bits(hls_ib_p_np_meta_s.vf) );
        printer.print_int("hls_ib_p_np_meta_s.cxl_io", hls_ib_p_np_meta_s.cxl_io, $bits(hls_ib_p_np_meta_s.cxl_io) );
        printer.print_int("hls_ib_p_np_meta_s.vf_or_pf", hls_ib_p_np_meta_s.vf_or_pf, $bits(hls_ib_p_np_meta_s.vf_or_pf) );
        printer.print_int("hls_ib_p_np_meta_s.bar", hls_ib_p_np_meta_s.bar, $bits(hls_ib_p_np_meta_s.bar) );
        printer.print_int("hls_ib_p_np_meta_s.bar_aperture", hls_ib_p_np_meta_s.bar_aperture, $bits(hls_ib_p_np_meta_s.bar_aperture) );
        printer.print_int("hls_ib_p_np_meta_s.bar_prefetchable", hls_ib_p_np_meta_s.bar_prefetchable, $bits(hls_ib_p_np_meta_s.bar_prefetchable) );
        `ifdef HPA_ARCH2
          printer.print_int("hls_ib_p_np_meta_s.generated_tlp", hls_ib_p_np_meta_s.generated_tlp, $bits(hls_ib_p_np_meta_s.generated_tlp) );
        `endif
      end
    end
    printer.print_int("cxl_io_tlp",cxl_io_tlp,$bits(cxl_io_tlp));
    printer.print_int("cxl_io_rcrb_tlp",cxl_io_rcrb_tlp,$bits(cxl_io_rcrb_tlp));
    printer.print_int("cxl_io_membar_tlp",cxl_io_membar_tlp,$bits(cxl_io_membar_tlp));

    //PBR: PTH
    if(is_cxl_pbr_mode)
    begin
      printer.print_int("m_tlp_pbr_tlp_header",m_tlp_pbr_tlp_header,32);
      printer.print_int("m_tlp_pth_hie" , m_tlp_pth_hie , 1 );
      printer.print_int("m_tlp_pth_dsar", m_tlp_pth_dsar, 1 );
      printer.print_int("m_tlp_pth_pif" , m_tlp_pth_pif , 1 );
      printer.print_int("m_tlp_pth_spid", m_tlp_pth_spid, 12);
      printer.print_int("m_tlp_pth_dpid", m_tlp_pth_dpid, 12);
      printer.print_int("m_tlp_pth_rsvd", m_tlp_pth_rsvd, 3 );
    end
    if(cxl_mode && cxl_ldid_prefix)
    printer.print_int("m_cxl_ldid",m_cxl_ldid,16);

    // Print first 3 DWs of m_data in 0xXXXXXXXX__0xXXXXXXXX__0xXXXXXXXX format
    num_prefix_print = m_max_no_of_prefixes + m_max_no_of_local_prefixes + is_cxl_pbr_mode;
    num_prefix_print =  num_prefix_print*4;
    if(m_data.size() >= (12+num_prefix_print)) begin
      printer.print_string("m_data_3DW", $psprintf("0x%02x%02x%02x%02x__0x%02x%02x%02x%02x__0x%02x%02x%02x%02x",
        m_data[0+num_prefix_print], m_data[1+num_prefix_print], m_data[2+num_prefix_print], m_data[3+num_prefix_print],
        m_data[4+num_prefix_print], m_data[5+num_prefix_print], m_data[6+num_prefix_print], m_data[7+num_prefix_print],
        m_data[8+num_prefix_print], m_data[9+num_prefix_print], m_data[10+num_prefix_print], m_data[11+num_prefix_print]));
    end else if(m_data.size() > 0) begin
      printer.print_string("m_data_3DW", convert_bytes_to_dw_string(m_data));
    end

  endfunction

  //------------------------------------------------------------------------
  // Function: check_function_specific
  //
  //------------------------------------------------------------------------
  virtual function void check_function_specific(bit is_malformed_err = 0, bit is_req_id_err = 0);
    /*
    Notes:
    Function independent error
    
    mem request hits IO Bar -> still function specific?
    IO request hits MEM Bar -> still function specific?
    
    1. Mem-TLP
    request , destination address
    
    a. request matches a bar completely
    1. if it is a VF, VFs are not enabled for corresponding PF -> non function specific
    1. if it is a VF, VFs are enabled for corresponding PF -> function specific
    2. if it is a PF, then definitely function specific, even if it is function 0
    b. request spans two bars ->
    1. if the next bar range doesn't exit -> is this function specific?
    2. if the next bar range belong to same function -> function specific
    3. if the next bar range belong to different function -> is this function specific?
    
    2. IO TLP
    request, destination
    
    a. request matches a bar completely
    1. if it is a VF, VFs are not enabled for corresponding PF -> ?
    1. if it is a VF, VFs are enabled for corresponding PF -> function specific
    2. if it is a PF, then definitely function specific, even if it is function 0
    b. request spans two bars ->
    1. if the next bar range doesn't exit -> is this function specific?
    2. if the next bar range belong to same function -> function specific
    3. if the next bar range belong to different function -> is this function specific?
    
    3. MSG TLP
    a. if(CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) -> completer ID
    1. completer ID is not valid -> non function specifc
    2. completer ID is valid -> function specific
    b. else -> ?
    CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC :
    CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ADDR :
    CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC :
    CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE :
    CDN_HPA_PCIE_TLP_MSG_ROUT_GATHER_TO_RC :
    
    
    4. CFG TLP -> completer ID
    a. completer ID is not valid -> non function specifc
    b. completer ID is valid -> function specific
    
    5. CPL TLP -> requester ID
    a. requester ID is not valid -> non function specifc
    b. requester ID is valid -> function specific
    */

    //Check if TLP is Malformed or has ECRC errors - If Yes, then TLP is non-function specific
    
    m_non_func_specific = 0;
    if(is_malformed_err) begin
      m_non_func_specific = 1;
      `uvm_info("check_function_specific", $psprintf("malformed_err detected"),UVM_DEBUG)
    end

    //Check for all other cases - Errored or non-errored
    if(!is_malformed_err) begin //{
      if((m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_MEM_TYPE}) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_rout_type == CDN_HPA_PCIE_TLP_ROUT_BY_ADDR))) begin //{
        if (((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (!m_pcie_dev_top_cfg.force_bar_chk_rp)) || ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && (m_pcie_dev_top_cfg.force_bar_chk_rp))) begin //{
          if(m_tlp_trans_type==CDN_HPA_PCIE_TRANS_IO_TYPE) begin //{
            if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) begin
              if(is_io_bar_hit_info(m_tlp_addr).bar_hit == 0)
                m_non_func_specific = 0; //Discuss with Rajesp and Navdeep 
              else
                m_non_func_specific = 0;
            end
            else if (is_io_bar_hit_info(m_tlp_addr).bar_hit == 0)
            m_non_func_specific = 1;
            else
            m_non_func_specific = 0;
          end //}
          else begin //m_tlp_trans_type==CDN_HPA_PCIE_TRANS_MEM_TYPE {
            if ((is_mem_bar_hit_info(m_tlp_addr).bar_hit == 0) && (is_vf_mem_bar_hit_info(m_tlp_addr).bar_hit == 0) && (is_cxl_io_bar_hit_info(m_tlp_addr).bar_hit == 0) && (is_erom_bar_hit_info(m_tlp_addr).bar_hit == 0))
            m_non_func_specific = 1;
            else
            m_non_func_specific = 0;
          end //}
        end //}
      end //}
      if((m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE, CDN_HPA_PCIE_TRANS_MSG_TYPE, CDN_HPA_PCIE_TRANS_CPL_TYPE}) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID))) begin //{
        if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID))) begin //{
          if((m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) /* || (!m_pcie_dev_top_cfg.en_inv_msg_code)*/ ) begin //{ //As per JIRA: 12377
            if((m_tlp_msg_code inside { CDN_HPA_PCIE_TLP_MSG_AT_Invalidate, CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete, CDN_HPA_PCIE_TLP_MSG_PR_Group_Response,
                                        CDN_HPA_PCIE_TLP_MSG_VD_Type0, CDN_HPA_PCIE_TLP_MSG_VD_Type1,CDN_HPA_PCIE_TLP_MSG_IDE_Fail,CDN_HPA_PCIE_TLP_MSG_IDE_Sync,CDN_HPA_PCIE_TLP_MSG_IDE_Escort })  || 
               ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID))) begin /*invalidate, invalidate completion, PRG RESPONSE, VD_TYPE0, VD_TYPE1*/ //{
              if(is_function_id_active(m_tlp_completer_id))
              m_non_func_specific = 0;
              else
              m_non_func_specific = 1;
            end //}
            else begin
              m_non_func_specific = 1;
            end
          end //}
          else begin
            m_non_func_specific = 1;
          end
        end //}
        else if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgWr1}/* &&
        m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP*/ && !m_pcie_dev_top_cfg.err_report_on_type1_cfg_access)
        //CfgWr1/CfgRd1 UR packet will be considered function specific/non-function specific based on setting of field FSERT1 in ip_cfg_reg0
        m_non_func_specific = 1;
        else if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE} && lut_item != null) begin //{
          `uvm_info("check_function_specific", $psprintf("checking for cpl, m_non_func_specific=%0b", m_non_func_specific),UVM_DEBUG)
          if(lut_item.m_invalid_tag == 1) begin
            if(flr_valid_tag_diff_reqid)
            m_non_func_specific = 1;
            else if((m_pf_vf.is_pf_valid == 0) && (m_pf_vf.is_vf_valid == 0))
            m_non_func_specific = 1;
            else
            m_non_func_specific = 0;
          end
          else if (cpl_req_id_mismatch) begin //{ //Unexpexted Cpl with Invalid tag is Non-function specific error
            `uvm_info("check_function_specific", $psprintf("m_invalid_tag=%0b is_req_id_err=%0b for cpl", lut_item.m_invalid_tag, is_req_id_err),UVM_DEBUG)
            m_non_func_specific = 1;
          end //}
        end //}
        else begin //{
          `uvm_info("check_function_specific", $psprintf("lut_item == null"),UVM_DEBUG)
          if((m_pf_vf.is_pf_valid == 0) && (m_pf_vf.is_vf_valid == 0))
            m_non_func_specific = 1;
          else
            m_non_func_specific = 0;
        end //}
      end //}
    end //}
    `uvm_info(get_full_name(),$psprintf("m_non_func_specific=%0d",m_non_func_specific),UVM_DEBUG);
    // hls error predictor can take the following signals out
    //m_non_func_specific
    //m_pf_vf
    // set m_hls_err_chk_en = 1
    // populate m_cfg_info
    // call get_cfg_from_tlp();
  endfunction : check_function_specific


  //------------------------------------------------------------------------
  // Function: get_prefixes
  // Method to get the prefixes as byte array
  //------------------------------------------------------------------------
  function void get_prefixes(ref byte unsigned prefix_bytes[], input bit include_local_prfx=1, input bit include_ide_prfx=1, input bit include_fm_local_prefix=0);

    `uvm_info("update_ecrc_value",$sformatf("m_max_no_of_local_prefixes=%0d",m_max_no_of_local_prefixes),UVM_DEBUG)
    `uvm_info("update_ecrc_value",$sformatf("m_tlp_local_prefix=%0p",m_tlp_local_prefix),UVM_DEBUG)
    // Local Prefixes
    if(m_max_no_of_local_prefixes) begin
      if(m_tlp_local_prefix.size() > 1) begin
        if(include_local_prfx && include_fm_local_prefix)
        prefix_bytes = {>>{m_tlp_local_prefix}};
        else begin
          for(int i=0; i< m_tlp_local_prefix.size() ; i++) begin
            if(include_local_prfx && (m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_VEND_PREFIX_L0 || m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_VEND_PREFIX_L1))
            prefix_bytes = {>>{m_tlp_local_prefix[i]}};
            else if(include_fm_local_prefix && m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX)
            prefix_bytes = {>>{m_tlp_local_prefix[i]}};
          end
        end
      end else if(m_tlp_local_prefix.size() == 1) begin
        if(include_local_prfx && m_local_prefix_possible)
        prefix_bytes = {>>{m_tlp_local_prefix[0]}};
        else if(include_fm_local_prefix && m_flit_mode_local_prefix_possible)
        prefix_bytes = {>>{m_tlp_local_prefix[0]}};
      end
    end
    `uvm_info("update_ecrc_value",$sformatf("prefix_bytes=%0p",prefix_bytes),UVM_DEBUG)

    // IDE Prefix
    if(include_ide_prfx && m_ide_prefix_present && !is_flit_mode) begin
      prefix_bytes = {>>{prefix_bytes,m_ide_tlp_prefix}};
    end
    `uvm_info("update_ecrc_value",$sformatf("prefix_bytes=%0p",prefix_bytes),UVM_DEBUG)

    // E2E Prefixes
    if(m_tlp_prefix.size()> 0 && !is_flit_mode) begin
      for(int i=0; i< m_tlp_prefix.size() ; i++) begin
        prefix_bytes = {>>{prefix_bytes,m_tlp_prefix[i]}};
        `uvm_info("update_ecrc_value",$sformatf("prefix_bytes=%0p",prefix_bytes),UVM_DEBUG)
      end
    end
  endfunction

  //------------------------------------------------------------------------
  // Function: is_io_bar_hit
  // Method to detect the given address falling in any of the IO BARs
  //------------------------------------------------------------------------

  //function  bit is_io_bar_hit (bit[63:0] bar_addr);
  function barInfo_t is_io_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;
    cdn_hpa_pcie_bar_type_t bar_type;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;

    bar_type = IO_BAR ;

    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    ///bar_32 = (bar_type == MEM_BAR_32 || bar_type == MEM_BAR_32_PREFETCH ||  bar_type == IO_BAR );

    if (ep_rp_dut) begin // { EP
      if(dev_top_cfg.m_ep_dev_bar_info)
      begin //{
        foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
          foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
            if ( dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
            dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == bar_type ) begin //{

              bar_addr_l =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr;
              bar_addr_h =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr +
              dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size-1 ;

              if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
                is_io_bar_hit_info.bar_hit  = 1 ;
                is_io_bar_hit_info.func_num = i ;
                is_io_bar_hit_info.pf_num  = i ;
                is_io_bar_hit_info.bar_type = dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type ;
              end
            end //}
          end //}
        end //}
      end //}
    end //}

    else begin //{ RC
      if(dev_top_cfg.m_rp_dev_bar_info)
      begin//{
        foreach (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j]) begin //{
          if ( dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_enable &&
          dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == bar_type ) begin //{
            bar_addr_l =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr;
            bar_addr_h =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr +
            dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].size-1 ;
            if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
              is_io_bar_hit_info.bar_hit  = 1 ;
              is_io_bar_hit_info.bar_type = dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type ;
            end
          end //}
        end //}
      end //}
    end //}
    ///return 1;
  endfunction : is_io_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_mem_bar_hit
  // Method to detect the given address falling in any of the Memory BARs
  //TODO::undefined bar range in mem
  //------------------------------------------------------------------------
  //function bit is_mem_bar_hit(bit[63:0] bar_addr);
  function barInfo_t is_mem_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    bar_32 = (bar_addr[63:32] == 0);

    if (ep_rp_dut) begin // { EP
      `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 1"),UVM_LOW)
      if(dev_top_cfg.m_ep_dev_bar_info) begin //{
        //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 2"),UVM_DEBUG)
        foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
          //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 3 = %0d",i),UVM_DEBUG)
          foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
            //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 4 = %0d, %0d",i, j),UVM_DEBUG)
            //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 4 = %0s",dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].sprint()),UVM_DEBUG)
            //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 4, start_add = %0h, end addr = %0h ", dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr, dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size),UVM_DEBUG)
            if ( dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
            ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32) ||
            (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH) ||
            (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_64_PREFETCH) ||
            (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32_PREFETCH) ||
            ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32) && is_memrd_op()))) begin //{

              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 5 target addr = %0h", bar_addr),UVM_DEBUG)
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 5, start_add = %0h, end addr = %0h ", dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr, dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size),UVM_DEBUG)
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 5, start_add = %0h, end addr = %0h ", dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr, dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size),UVM_DEBUG)
              bar_addr_l =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr;
              bar_addr_h =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr +
              dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size-1 ;
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 5, start_add = %0x, end addr = %0x ", bar_addr_l, bar_addr_h),UVM_DEBUG)

              if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
                //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_DEBUG)
                is_mem_bar_hit_info.bar_hit  = 1 ;
                is_mem_bar_hit_info.func_num = i ;
                is_mem_bar_hit_info.pf_num  = i ;
                is_mem_bar_hit_info.vf_num  = -1 ;
                is_mem_bar_hit_info.bar_num = j;
                is_mem_bar_hit_info.bar_type = dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type ;
                //Just for coverage purpose for EROM Hit packets
                if ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32) && is_memrd_op())
                m_erom_bar_hit = 1;
              end
            end //}
            if(is_mem_bar_hit_info.bar_hit)
            break;
          end //}
          if(is_mem_bar_hit_info.bar_hit)
          break;
        end //}
      end //}
    end //}

    else begin //{ RC
      if(dev_top_cfg.m_rp_dev_bar_info)
      begin//{
        foreach (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j]) begin //{
          if ( dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_enable &&
          ((bar_32 && (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32 |
          dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32_PREFETCH)) |
          (!bar_32 && (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH |
          dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_64_PREFETCH) ))) begin //{
            bar_addr_l =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr;
            bar_addr_h =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr +
            dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].size-1 ;
            if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
              is_mem_bar_hit_info.bar_hit  = 1 ;
              is_mem_bar_hit_info.bar_num = j;
              is_mem_bar_hit_info.bar_type = dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type ;
            end
          end //}
        end //}
      end //}
    end //}
    ///return 1;
  endfunction : is_mem_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_erom_bar_hit_info
  // Method to detect the given address falling in EROM BARs
  //TODO::undefined bar range in mem
  //------------------------------------------------------------------------
  function barInfo_t is_erom_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    bar_32 = (bar_addr[63:32] == 0);

    if (ep_rp_dut) begin // { EP
      if(dev_top_cfg.m_ep_dev_bar_info) begin //{
        foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
          foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
            if (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable && (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32)) begin //{
              bar_addr_l =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr;
              bar_addr_h =  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr +
              dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size-1 ;
              if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
                is_erom_bar_hit_info.bar_hit  = 1 ;
                is_erom_bar_hit_info.func_num = i ;
                is_erom_bar_hit_info.pf_num  = i ;
                is_erom_bar_hit_info.vf_num  = -1 ;
                is_erom_bar_hit_info.bar_type = dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type ;
              end
            end //}
            if(is_erom_bar_hit_info.bar_hit)
            break;
          end //}
          if(is_erom_bar_hit_info.bar_hit)
          break;
        end //}
      end //}
    end //}

    //else begin //{ RC
    //  if(dev_top_cfg.m_rp_dev_bar_info)
    //  begin//{
    //    foreach (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j]) begin //{
    //      if ( dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_enable &&
    //           ((bar_32 && (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32 |
    //             dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32_PREFETCH)) |
    //           (!bar_32 && (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_64_NON_PREFETCH |
    //             dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_64_PREFETCH) ))) begin //{
    //        bar_addr_l =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr;
    //        bar_addr_h =  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr +
    //                      dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].size-1 ;
    //        if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
    //          is_erom_bar_hit_info.bar_hit  = 1 ;
    //          is_erom_bar_hit_info.bar_type = dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type ;
    //        end
    //      end //}
    //    end //}
    //  end //}
    //end //}
    ///return 1;
  endfunction : is_erom_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_cxl_io_bar_hit_info
  // Method to detect the given feature is supported in any of the active functions
  // Method to detect the given address falling in cxl_io BARs
  //------------------------------------------------------------------------
  function barInfo_t is_cxl_io_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    bar_32 = (bar_addr[63:32] == 0);
    `uvm_info(get_full_name(),$psprintf("ep_rp_dut=%0b",ep_rp_dut),UVM_LOW)
    `uvm_info(get_full_name(),$psprintf("dev_top_cfg.m_cxl_negotiation=%0b",dev_top_cfg.m_cxl_negotiation),UVM_LOW)

    if (ep_rp_dut) begin // { EP
      if(dev_top_cfg.m_cxl_negotiation) begin //{
        foreach (dev_top_cfg.pf_config[i]) begin //{
          //cxl io rcrb bar
          bar_addr_l = dev_top_cfg.pf_config[i].m_cxl_io_rcrb_bar + 2**12;
          bar_addr_h = dev_top_cfg.pf_config[i].m_cxl_io_rcrb_bar + 2**13 -1;

          `uvm_info(get_full_name(),$psprintf("bar_addr_l=%0h, bar_addr_h=%0h", bar_addr_l, bar_addr_h),UVM_LOW)
          if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
            `uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_LOW)
            is_cxl_io_bar_hit_info.bar_hit  = 1 ;
            is_cxl_io_bar_hit_info.func_num = i ;
            is_cxl_io_bar_hit_info.pf_num   = i ;
            is_cxl_io_bar_hit_info.vf_num   = -1 ;
            is_cxl_io_bar_hit_info.bar_type = RSVD_BAR_64;
            break;
          end

          //cxl io membar
          bar_addr_l = dev_top_cfg.pf_config[i].m_cxl_io_membar;
          bar_addr_h = dev_top_cfg.pf_config[i].m_cxl_io_membar + 2**(dev_top_cfg.pf_config[i].m_cxl_io_membar_aperture)-1;

          if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin //{
            //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_LOW)
            is_cxl_io_bar_hit_info.bar_hit  = 1 ;
            is_cxl_io_bar_hit_info.func_num = i ;
            is_cxl_io_bar_hit_info.pf_num   = i ;
            is_cxl_io_bar_hit_info.vf_num   = -1 ;
            is_cxl_io_bar_hit_info.bar_type = RSVD_BAR_64;
            break;
          end //}
        end //}
        if(is_cxl_io_bar_hit_info.bar_hit==0) begin
          foreach (dev_top_cfg.vf_config[i,j]) begin //{
            //cxl io rcrb bar
            bar_addr_l = dev_top_cfg.vf_config[i][j].m_cxl_io_rcrb_bar + 2**12;
            bar_addr_h = dev_top_cfg.vf_config[i][j].m_cxl_io_rcrb_bar + 2**13;

            if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_LOW)
              is_cxl_io_bar_hit_info.bar_hit  = 1 ;
              is_cxl_io_bar_hit_info.func_num = i ;
              is_cxl_io_bar_hit_info.pf_num   = i ;
              is_cxl_io_bar_hit_info.vf_num   = j ;
              is_cxl_io_bar_hit_info.bar_type = RSVD_BAR_64;
              break;
            end

            //cxl io membar
            bar_addr_l = dev_top_cfg.vf_config[i][j].m_cxl_io_membar;
            bar_addr_h = dev_top_cfg.vf_config[i][j].m_cxl_io_membar + 2**(dev_top_cfg.vf_config[i][j].m_cxl_io_membar_aperture)-1;

            if(bar_addr >= bar_addr_l && bar_addr <= bar_addr_h) begin //{
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: 6 "),UVM_LOW)
              is_cxl_io_bar_hit_info.bar_hit  = 1 ;
              is_cxl_io_bar_hit_info.func_num = i ;
              is_cxl_io_bar_hit_info.pf_num   = i ;
              is_cxl_io_bar_hit_info.vf_num   = j ;
              is_cxl_io_bar_hit_info.bar_type = RSVD_BAR_64;
              break;
            end //}
          end //}
        end
      end //}
    end //}

  endfunction : is_cxl_io_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_feature_supported_by_any_func
  // Method to detect the given feature is supported in any of the active functions
  //------------------------------------------------------------------------
  function bit is_feature_supported_by_any_func(cdn_hpa_pcie_feature_name_t feature_name, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    cdn_pcie_hpa_dev_top_config l_pcie_dev_top_cfg;

    if(dev_top_cfg)
    l_pcie_dev_top_cfg= dev_top_cfg;
    else
    l_pcie_dev_top_cfg = m_pcie_dev_top_cfg;

    if (feature_name == CDN_HPA_PCIE_E2E_TLP_PREFIX ) begin
      foreach (l_pcie_dev_top_cfg.pf_config[i]) begin
        if (l_pcie_dev_top_cfg.pf_config[i].m_e2e_tlp_prefix_support) begin
          return 1;
        end
      end
    end
    return 0;
    // TODO: Have to add for Remaining feature
  endfunction : is_feature_supported_by_any_func

  //------------------------------------------------------------------------
  // Function: is_function_id_active
  // Method to detect whether the given function id is implemented/enabled
  // Function returns 0 if the function id is not active or not implemented
  //------------------------------------------------------------------------
  function bit is_function_id_active(cdn_hpa_pcie_tlp_requester_id_s fn_id);
    // TODO: Function need to be implemented and change the return value
    cdn_pcie_hpa_dev_top_config l_pcie_dev_top_cfg;
    bit [2:0] l_function_num;
    bit is_active;
    //if(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.usp_dev_top_config;
    //else
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.dsp_dev_top_config;
    l_pcie_dev_top_cfg = m_pcie_dev_top_cfg;

    foreach(l_pcie_dev_top_cfg.pf_config[i]) begin
      if(fn_id == l_pcie_dev_top_cfg.pf_config[i].m_req_id) begin
        is_active = 1;
        break;
      end
    end
    if(is_active == 0) begin
      foreach(l_pcie_dev_top_cfg.vf_config[i,j]) begin
        if((fn_id == l_pcie_dev_top_cfg.vf_config[i][j].m_req_id) && !l_pcie_dev_top_cfg.pf_config[i].m_vf_en) begin//{
          pkt_targeting_disabled_vf = 1;
          break;
        end//}
        if((fn_id == l_pcie_dev_top_cfg.vf_config[i][j].m_req_id) && (i<parameters_cfg_pkg::MAX_PFS_WITH_VF)) begin
          is_active = 1;
          break;
        end
        if((fn_id == l_pcie_dev_top_cfg.vf_config[i][j].m_req_id) && (i>=parameters_cfg_pkg::MAX_PFS_WITH_VF)) begin
          pkt_targeting_vf_in_not_allowed_pf = 1;
          break;
        end
      end
    end
    return is_active;
  endfunction : is_function_id_active

  // TODO: check it since HLS checks only function not bus and device number for request.
  //------------------------------------------------------------------------
  // Function: is_function_valid
  // Method to detect whether the given function id is implemented/enabled
  // Function returns 0 if the function id is not active or not implemented
  //------------------------------------------------------------------------
  function bit is_function_valid(cdn_hpa_pcie_tlp_requester_id_s fn_id);
    // TODO: Function need to be implemented and change the return value
    cdn_pcie_hpa_dev_top_config l_pcie_dev_top_cfg;
    cdn_hpa_pcie_tlp_requester_id_s l_func_id;
    bit ari_enable;
    bit is_active;
    bit [7:0] req_func_num;
    bit [7:0] cfg_func_num;
    //if(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.usp_dev_top_config;
    //else
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.dsp_dev_top_config;
    l_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
    ari_enable = l_pcie_dev_top_cfg.i_cfg.strap_ari_enable;

    foreach(l_pcie_dev_top_cfg.pf_config[i])
    begin
      l_func_id = l_pcie_dev_top_cfg.pf_config[i].m_req_id;
      if(ari_enable) begin
        req_func_num = {l_func_id.device_num,l_func_id.function_num};
        cfg_func_num = {fn_id.device_num,fn_id.function_num};
      end
      else begin
        req_func_num = l_func_id.function_num;
        cfg_func_num = fn_id.function_num;
      end
      if(req_func_num == cfg_func_num)
      begin
        is_active = 1;
        break;
      end
    end
    if(is_active == 0)
    foreach(l_pcie_dev_top_cfg.vf_config[i,j])
    begin
      l_func_id = l_pcie_dev_top_cfg.vf_config[i][j].m_req_id;
      if(ari_enable) begin
        req_func_num = {l_func_id.device_num,l_func_id.function_num};
        cfg_func_num = {fn_id.device_num,fn_id.function_num};
      end
      else begin
        req_func_num = l_func_id.function_num;
        cfg_func_num = fn_id.function_num;
      end
      if(req_func_num == cfg_func_num)
      begin
        is_active = 1;
        break;
      end
    end
    return is_active;
  endfunction : is_function_valid

  //------------------------------------------------------------------------
  // Function: check_bus_device_func
  // Method to detect whether the given function id is implemented/enabled
  // Function returns 0 if the function id is not active or not implemented
  //------------------------------------------------------------------------
  function bit [2:0] check_bus_device_func(cdn_hpa_pcie_tlp_requester_id_s fn_id);
    // TODO: Function need to be implemented and change the return value
    cdn_pcie_hpa_dev_top_config l_pcie_dev_top_cfg;
    cdn_hpa_pcie_tlp_requester_id_s l_func_id;
    bit ari_enable;
    bit is_active;
    bit [7:0] req_func_num;
    bit [7:0] cfg_func_num;
    bit bus_num_match,dev_num_match,func_num_match;
    //if(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.usp_dev_top_config;
    //else
    //  l_pcie_dev_top_cfg = m_pcie_link_cfg.dsp_dev_top_config;
    l_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
    ari_enable = l_pcie_dev_top_cfg.i_cfg.strap_ari_enable;

    foreach(l_pcie_dev_top_cfg.pf_config[i])
    begin
      l_func_id = l_pcie_dev_top_cfg.pf_config[i].m_req_id;
      if(ari_enable) begin
        req_func_num = {l_func_id.device_num,l_func_id.function_num};
        cfg_func_num = {fn_id.device_num,fn_id.function_num};
        dev_num_match = 1'b1; //for ARI do not check for device, make it 1
      end
      else begin
        req_func_num = l_func_id.function_num;
        cfg_func_num = fn_id.function_num;
      end
      if(fn_id == l_func_id)
      begin
        {bus_num_match,dev_num_match,func_num_match}  = 3'b111;
        break;
      end
      else if(req_func_num == cfg_func_num) begin
        func_num_match=1'b1;
        if((fn_id.bus_num == l_func_id.bus_num)) begin
          bus_num_match = 1'b1;
        end
        else if (!ari_enable && (fn_id.device_num == l_func_id.device_num)) begin
          dev_num_match = 1'b1;
        end
      end
    end
    if(func_num_match == 0) begin
      foreach(l_pcie_dev_top_cfg.vf_config[i,j])
      begin
        l_func_id = l_pcie_dev_top_cfg.vf_config[i][j].m_req_id;
        if(ari_enable) begin
          req_func_num = {l_func_id.device_num,l_func_id.function_num};
          cfg_func_num = {fn_id.device_num,fn_id.function_num};
          dev_num_match = 1'b1; //for ARI do not check for device, make it 1
        end
        else begin
          req_func_num = l_func_id.function_num;
          cfg_func_num = fn_id.function_num;
        end
        if(fn_id == l_func_id)
        begin
          {bus_num_match,dev_num_match,func_num_match}  = 3'b111;
          break;
        end
        else if(req_func_num == cfg_func_num) begin
          func_num_match=1'b1;
          if((fn_id.bus_num == l_func_id.bus_num)) begin
            bus_num_match = 1'b1;
          end
          else if (!ari_enable && (fn_id.device_num == l_func_id.device_num)) begin
            dev_num_match = 1'b1;
          end
        end
      end
    end
    `uvm_info(get_full_name(),$sformatf("{bus_num_match,dev_num_match,func_num_match} = %0b",{bus_num_match,dev_num_match,func_num_match}),UVM_DEBUG);
    return {bus_num_match,dev_num_match,func_num_match};
  endfunction : check_bus_device_func


  //------------------------------------------------------------------------
  // Function: is_vf_mem_bar_hit
  // Method to detect the given address belongs to VF or not
  //------------------------------------------------------------------------
  function barInfo_t is_vf_mem_bar_hit_info(bit[63:0] bar_addr, cdn_pcie_hpa_dev_top_config dev_top_cfg = null);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[63:0] bar_addr_l;
    bit[63:0] bar_addr_h;
    bit [63:0] start_addr;
    bit [63:0] end_addr;
    bit success_hit;
    ///bit[63:0] bar_size_loc;
    cdn_hpa_pcie_bar_type_t bar_type;

    // TODO: for EROM_BAR, there is no addr mentioned for EROM BAR

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    bar_32 = (bar_addr[63:32] == 0);


    //Search all available VFs
    foreach(dev_top_cfg.vf_config[i,j]) begin //{
      if(i >= parameters_cfg_pkg::MAX_PFS_WITH_VF) begin
        pkt_targeting_vf_in_not_allowed_pf = 1;
        continue;
      end
      if(!dev_top_cfg.pf_config[i].m_vf_en) begin//{
        pkt_targeting_disabled_vf = 1;
        continue;
      end//}
      if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) begin //{
        foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) begin //{
          if(
            (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
            ((dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
            (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_NON_PREFETCH) ||
            (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_PREFETCH) ||
            (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH))
          )
          begin //{
            start_addr = dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr;
            end_addr = dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr+ (2**(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].get_decoded_bar_aperture())) -1;

            if(bar_addr >= start_addr && bar_addr <= end_addr) begin //{
              is_vf_mem_bar_hit_info.vf_num  = j ;
              is_vf_mem_bar_hit_info.pf_num  = i ;
              is_vf_mem_bar_hit_info.bar_hit  = 1 ;
              is_vf_mem_bar_hit_info.bar_num  = bar_i;
              is_vf_mem_bar_hit_info.func_num = dev_top_cfg.vf_config[i][j].m_req_id.function_num;
              is_vf_mem_bar_hit_info.dev_num = dev_top_cfg.vf_config[i][j].m_req_id.device_num;
              is_vf_mem_bar_hit_info.bar_type = dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type;
              //`uvm_info(get_full_name(),$psprintf("DEBUG_BAR_HIT: with address (%0h) hits PF_%0d VF_%0d, start_addr = %0h, end_addr = %0h",bar_addr,i,j,start_addr, end_addr),UVM_LOW)
            end //}
          end //}
        end //}
      end //}
    end //}

    return is_vf_mem_bar_hit_info;

  endfunction : is_vf_mem_bar_hit_info

  //------------------------------------------------------------------------
  // Function: is_vf_id
  // Method to detect the given transaction id belongs to PF/VF
  //------------------------------------------------------------------------
  function bit is_vf_id(cdn_hpa_pcie_tlp_requester_id_s fn_id);
    // TODO: Function need to be implemented and change the return value
    return 0;
  endfunction : is_vf_id

  //------------------------------------------------------------------------
  // Function: randomize_mem_bar_addr
  // Method to detect the given address falling in any of the Memory BARs
  //TODO::undefined bar range in mem
  //------------------------------------------------------------------------
  function bit[63:0] randomize_mem_bar_addr (bit is_64, bit io_bar=0);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[31:0] bar_addr_32;
    bit[63:0] bar_addr;
    bit       mem_bar_hit;
    cdn_pcie_hpa_dev_top_config dev_top_cfg;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;
    if(is_64 == 0)
    begin //{
      bar_32 = 1;

      if (ep_rp_dut) begin // { EP
        `uvm_info(get_full_name(),$sformatf("dev_top_cfg=%0s",dev_top_cfg.get_name()),UVM_DEBUG)
        if(dev_top_cfg.m_ep_dev_bar_info)
        begin //{
          //For debug purpose
          //foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin
          //  foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin
          //    `uvm_info(get_full_name(),$sformatf("dev_top_cfg.m_ep_dev_bar_info.m_pf[%0d].bars[%0d] = %0s",i, j, dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].sprint()),UVM_DEBUG)
          //  end
          //end
          //foreach(dev_top_cfg.vf_config[i,j]) begin
          //  if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) begin
          //    foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) begin
          //      `uvm_info(get_full_name(),$sformatf(" dev_top_cfg.vf_config[%0d][%0d].m_fun_bar_info.bars[%0d] = %0s",i, j, bar_i, dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].sprint()),UVM_DEBUG)
          //    end
          //  end
          //end
          if(!io_bar) begin
            assert(std::randomize(bar_addr_32) with {
              foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) {
                foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) {
                  if (
                    dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
                    ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32) ||
                    (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32_PREFETCH) ||
                    (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MSI_OR_MSIX_BAR_32) ||
                    (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32))
                  ) {
                    !(bar_addr_32 inside {
                      [dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr :
                      dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size]
                    });
                  }
                }
              }
              foreach(dev_top_cfg.vf_config[i,j]) {
                if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) {
                  foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) {
                    if(
                      (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
                      ((dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
                      (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH)
                      || (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MSI_OR_MSIX_BAR_32))
                    ) {
                      !(bar_addr_32 inside {
                        [dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr :
                        dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr + (2**(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_aperture + 7)) -1]
                      });
                    }
                  }
                }
              }
              // For AtomicOp Requests, the Address must be naturally aligned with the operand size
              if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)) {
                bar_addr_32[2] == 0;
              }
              else if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) {
                if(m_tlp_length == 4) bar_addr_32[2] == 0;
                if(m_tlp_length == 8) bar_addr_32[3:2] == 0;
              }

              bar_addr_32[1:0] == 0;
              // Address cannot cross 4K boundary
              bar_addr_32[11:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h400;
              //TR should have [11:0] == 0 when page_align_req==1
              if(
                ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
                && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pcie_dev_cfg.m_ats_page_align_req
              ) {
                soft bar_addr_32[11:2] == 0;
              }
              if(m_tlp_length == 2) bar_addr_32[2] == 0; //To avoid CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR, CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR
            });
          end
          else begin
            foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
              foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
                if (
                  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
                  (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == IO_BAR)
                )
                begin //{
                  assert(std::randomize(bar_addr_32) with {bar_addr_32 inside {[dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr :
                  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size]};});
                  mem_bar_hit = 1;
                end //}
                if(mem_bar_hit) break;
              end //}
              if(mem_bar_hit) break;
            end //}
            if(mem_bar_hit) begin //{
              // For AtomicOp Requests, the Address must be naturally aligned with the operand size
              if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)) begin //{
                bar_addr_32[2] = 0;
              end //}
              else if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
              || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) begin //{
                if(m_tlp_length == 4) bar_addr_32[2] = 0;
                if(m_tlp_length == 8) bar_addr_32[3:2] = 0;
              end //}

              bar_addr_32[1:0] = 0;
              // //Address cannot cross 4K boundary
              // bar_addr_32[11:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h400;
              // //TR should have [11:0] == 0 when page_align_req==1
              // if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
              //           && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pcie_dev_cfg.m_ats_page_align_req) begin
              //           bar_addr_32[11:2] = 0;
              // end
              // if(m_tlp_length == 2) bar_addr_32[2] == 0; //To avoid CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR, CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR
            end //}
            else begin
              bar_addr_32 = 0;
            end
          end
        end //}
      end //}
 else begin //{ RC
        if(dev_top_cfg.m_rp_dev_bar_info)
        begin//{
          assert(std::randomize(bar_addr_32) with {
            foreach (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j]) {
              if (
                dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_enable &&
                ((dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32) ||
                (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32_PREFETCH) ||
                (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MSI_OR_MSIX_BAR_32) ||
                (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_EROM_BAR_32))
              ) {

                !(bar_addr_32 inside {
                  [dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr :
                  dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr + dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].size]
                });
              }
            }
            foreach(dev_top_cfg.vf_config[i,j]) {
              if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) {
                foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) {
                  if(
                    (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
                    ((dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
                    (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH)
                    || (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MSI_OR_MSIX_BAR_32))
                  ) {
                    !(bar_addr_32 inside {
                      [dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr :
                      dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr + (2**(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_aperture + 7)) -1]
                    });
                  }
                }
              }
            }
            // For AtomicOp Requests, the Address must be naturally aligned with the operand size
            if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
            || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
            || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
            || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)) {
              bar_addr_32[2] == 0;
            }
            else if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
            || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) {
              if(m_tlp_length == 4) bar_addr_32[2] == 0;
              if(m_tlp_length == 8) bar_addr_32[3:2] == 0;
            }

            bar_addr_32[1:0] == 0;
            // Address cannot cross 4K boundary
            bar_addr_32[11:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h400;
            //TR should have [11:0] == 0 when page_align_req==1
            if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
            && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pcie_dev_cfg.m_ats_page_align_req) {soft bar_addr_32[11:2] == 0;}
            if(m_tlp_length == 2) bar_addr_32[2] == 0; //To avoid CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR, CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR
          });
        end //}
      end //}
      bar_addr = bar_addr_32;
    end //}
    else
    begin //{
      assert(std::randomize(bar_addr) with {
        foreach(dev_top_cfg.vf_config[i,j]) {
          if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) {
            foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) {
              if(
                (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
                ((dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_NON_PREFETCH) ||
                (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_64_PREFETCH)
                || (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MSI_OR_MSIX_BAR_64))
              ) {
                !(bar_addr inside {
                  [dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr :
                  dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr + (2**(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_aperture + 7)) -1]
                });
              }
            }
          }
        }
        // For AtomicOp Requests, the Address must be naturally aligned with the operand size
        if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)) {
          bar_addr[2] == 0;
        }
        else if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) {
          if(m_tlp_length == 4) bar_addr[2] == 0;
          if(m_tlp_length == 8) bar_addr[3:2] == 0;
        }

        bar_addr[1:0] == 0;
        // Address cannot cross 4K boundary
        bar_addr[11:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h400;
        //TR should have [11:0] == 0 when page_align_req==1
        if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
        && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pcie_dev_cfg.m_ats_page_align_req) {soft bar_addr[11:2] == 0;}
        if(m_tlp_length == 2) bar_addr[2] == 0; //To avoid CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR, CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR
      });
    end //}
    return bar_addr;
  endfunction : randomize_mem_bar_addr

  //------------------------------------------------------------------------
  // Function: randomize_io_bar_addr
  // Method to detect the given address falling in any of the Memory BARs
  //TODO::undefined bar range in mem
  //------------------------------------------------------------------------
  function bit[63:0] randomize_io_bar_addr (bit mem_bar=0);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[31:0] bar_addr_32;
    bit[63:0] bar_addr;
    bit       mem_bar_hit;
    cdn_pcie_hpa_dev_top_config dev_top_cfg;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;

    if (ep_rp_dut) begin // { EP
      `uvm_info(get_full_name(),$sformatf("dev_top_cfg=%0s",dev_top_cfg.get_name()),UVM_DEBUG)
      if(dev_top_cfg.m_ep_dev_bar_info) begin //{
        if(!mem_bar) begin //{
          assert(std::randomize(bar_addr_32) with {
            foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) {
              foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) {
                if (
                  dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
                  ((dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == IO_BAR) )
                ) {
                  !(bar_addr_32 inside {
                    [dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr :
                    dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size]
                  });
                }
              }
            }
          });
        end //}
        else begin//{
          foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
            foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
              if (
                dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable &&
                (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32 ||
                dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_BAR_32_PREFETCH)
              )
              begin //{
                assert(std::randomize(bar_addr_32) with {
                  bar_addr_32 inside {
                    [dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr :
                    dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size -1]
                  };
                });
                mem_bar_hit=1;
              end //}
              if(mem_bar_hit) break;
            end //}
            if(mem_bar_hit) break;
          end //}
          if(!mem_bar_hit)
          bar_addr_32 = 0;
        end //}
      end //}
    end //}

    bar_addr = bar_addr_32;
    return bar_addr;
  endfunction : randomize_io_bar_addr

  //------------------------------------------------------------------------
  // Function: randomize_mem_bar_to_get_rom_addr
  // Method to detect the given address falling in any of the EROM BARs
  //------------------------------------------------------------------------
  function bit[63:0] randomize_mem_bar_to_get_rom_addr (bit is_64, bit io_bar=0);
    bit ep_rp_dut, bar_32; // 1:ep 0:rp
    bit[31:0] bar_addr_32;
    bit[63:0] bar_addr;
    bit       mem_bar_hit;
    cdn_pcie_hpa_dev_top_config dev_top_cfg;

    if(dev_top_cfg == null)
    dev_top_cfg = m_pcie_dev_top_cfg;
    ep_rp_dut = (m_cfg_info.m_port_type == CDN_HPA_PCIE_USP) ;

    if (ep_rp_dut) begin // { EP
      `uvm_info(get_full_name(),$sformatf("dev_top_cfg=%0s",dev_top_cfg.get_name()),UVM_DEBUG)
      if(dev_top_cfg.m_ep_dev_bar_info) begin //{
        foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i]) begin //{
          foreach (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j]) begin //{
            if (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_enable && (dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].bar_type == MEM_EROM_BAR_32)) begin //{
              assert(std::randomize(bar_addr_32) with {bar_addr_32 inside {[dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr :
              dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].start_addr + dev_top_cfg.m_ep_dev_bar_info.m_pf[i].bars[j].size]};});
              mem_bar_hit = 1;
            end //}
            if(mem_bar_hit) break;
          end //}
          if(mem_bar_hit) break;
        end //}
        if(mem_bar_hit) begin //{
          bar_addr_32[1:0] = 0;
        end //}
        else begin
          bar_addr_32 = 0;
        end
      end //}
    end //}

    //else begin //{ RC
    //  if(dev_top_cfg.m_rp_dev_bar_info)
    //  begin//{
    //    assert(std::randomize(bar_addr_32) with {
    //      foreach (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j]) {
    //        if ( dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_enable &&
    //             ((dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32) ||
    //              (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MEM_BAR_32_PREFETCH)
    //               || (dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].bar_type == MSI_OR_MSIX_BAR_32)
    //             )
    //           ) {

    //          !(bar_addr_32 inside { [dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr :
    //                               dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].start_addr + dev_top_cfg.m_rp_dev_bar_info.m_pf[0].bars[j].size]
    //                             });
    //        }
    //      }
    //      foreach(dev_top_cfg.vf_config[i,j]) {
    //        if(dev_top_cfg.vf_config[i][j].m_fun_bar_info != null) {
    //          foreach(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i]) {
    //            if((dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_enable) &&
    //                ((dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32) ||
    //                 (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MEM_BAR_32_PREFETCH)
    //                  || (dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_type == MSI_OR_MSIX_BAR_32)
    //                )
    //              ) {
    //              !(bar_addr_32 inside { [dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr :
    //                                   dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].start_addr + (2**(dev_top_cfg.vf_config[i][j].m_fun_bar_info.bars[bar_i].bar_aperture + 7)) -1]
    //                                });
    //            }
    //          }
    //        }
    //      }
    //      // For AtomicOp Requests, the Address must be naturally aligned with the operand size
    //      if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
    //         || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
    //         || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
    //         || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)) {
    //        bar_addr_32[2] == 0;
    //      }
    //      else if ((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
    //           || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)) {
    //        if(m_tlp_length == 4) bar_addr_32[2] == 0;
    //        if(m_tlp_length == 8) bar_addr_32[3:2] == 0;
    //      }

    //      bar_addr_32[1:0] == 0;
    //      // Address cannot cross 4K boundary
    //      bar_addr_32[11:2] + ((m_tlp_length == 0) ? 1024 : m_tlp_length) <= 'h400;
    //      //TR should have [11:0] == 0 when page_align_req==1
    //      if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64))
    //                && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pcie_dev_cfg.m_ats_page_align_req) {soft bar_addr_32[11:2] == 0;}
    //      if(m_tlp_length == 2) bar_addr_32[2] == 0; //To avoid CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR, CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR
    //    });
    //  end //}
    //end //}
    bar_addr = bar_addr_32;
    return bar_addr;
  endfunction : randomize_mem_bar_to_get_rom_addr


  function void get_num_of_reserved_header_dw();
    if({m_hdr_fmt,m_hdr_type} inside {6,7})     num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {26})      num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {202,203}) num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {204,205}) num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {14,15})       num_of_header_dw = 3;
    if({m_hdr_fmt,m_hdr_type} inside {24,25})       num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {40,41,42,43}) num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {172,173})     num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {174,175})     num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {28,29})   num_of_header_dw = 3;
    if({m_hdr_fmt,m_hdr_type} inside {60,61})   num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {62,63})   num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {30,31})   num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {200,201}) num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {70,71})   num_of_header_dw = 3;
    if({m_hdr_fmt,m_hdr_type} inside {240,241}) num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {242,243}) num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {244,245}) num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {246,247}) num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {35,[36:39],[56:59]}) num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {[160:167]})          num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {[192:199]})          num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {[232:239]})          num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {111,120,121,122,[124:127]}) num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {[16:19],[20:21]})           num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {[80:83],84,85})             num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {22,23,86,87})               num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {8,9})                       num_of_header_dw = 3;
    if({m_hdr_fmt,m_hdr_type} inside {44,45,54,55}) num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {46,47}) num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {88,89}) num_of_header_dw = 3;
    if({m_hdr_fmt,m_hdr_type} inside {92,93,118,119})   num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {94,95})   num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {65,67})   num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {206,207}) num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {79,[144:147]})       num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {[148:151]})          num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {[152:155],168,169})  num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {[156:159],170,171})  num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {90,[98:99],[100:103],[104:107]}) num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {[176:183],[184:191]})            num_of_header_dw = 5;
    if({m_hdr_fmt,m_hdr_type} inside {[208:215],[216:223]})            num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {[248:255]})                      num_of_header_dw = 7;
    if({m_hdr_fmt,m_hdr_type} inside {224,225}) num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {226,227}) num_of_header_dw = 6;
    if({m_hdr_fmt,m_hdr_type} inside {228,229}) num_of_header_dw = 4;
    if({m_hdr_fmt,m_hdr_type} inside {230,231}) num_of_header_dw = 6;
  endfunction: get_num_of_reserved_header_dw

  function void get_route_and_address_type();
    if({m_hdr_fmt,m_hdr_type} inside {8,9,88,89,44,45, 46,47,54,55,92,93, 94,95, 65,67, 206,207,118,119}) begin
      m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_OTHER;
    end
    if({m_hdr_fmt,m_hdr_type} inside {79,[144:147], [148:151], [152:155],168,169, [156:159],170,171,90,[98:99],[100:103],[104:107], [176:183],[184:191], [208:215],[216:223], [248:255]}) begin
      //is_posted_tlp_address_routed_header_rsvd = 1;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_ADDR;
      m_tlp_addr_type     = CDN_HPA_PCIE_ADDR_64;
    end
    if({m_hdr_fmt,m_hdr_type} inside {28,29,70,71,60,61, 62,63, 30,31, 200,201,240,241,242,243,244,245,246,247}) begin
      is_nonposted_tlp_id_routed_header_rsvd = 1;
      m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_OTHER;
    end
    if({m_hdr_fmt,m_hdr_type} inside {35,[36:39],[56:59],[160:167],[192:199],[232:239],111,120,121,122,[124:127], [16:19],[20:21], [80:83],84,85, 22,23,86,87}) begin
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_ADDR;
      m_tlp_addr_type     = CDN_HPA_PCIE_ADDR_64;
    end
    if({m_hdr_fmt,m_hdr_type} inside {[224:231]}) begin
      m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_OTHER;
    end
  endfunction: get_route_and_address_type

  function void get_tlp_type(bit [7:0] l_hdr_fmt);
    if(l_hdr_fmt inside {6,7,14,15,24,25,26,40,41,42,43,73,172,173,174,175,202,203,204,205}) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_CPL_Rsvd;
    end
    if(l_hdr_fmt inside {8,9,88,89,44,45, 46,47,54,55,92,93, 94,95, 65,67, 206,207,118,119}) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_P_Rsvd;
    end
    if(l_hdr_fmt inside {79,[144:147], [148:151], [152:155],168,169, [156:159],170,171,90,[98:99],[100:103],[104:107], [176:183],[184:191], [208:215],[216:223], [248:255]}) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_P_Rsvd;
    end
    if(l_hdr_fmt inside {28,29,70,71,60,61, 62,63, 30,31, 200,201,240,241,242,243,244,245,246,247}) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_NP_Rsvd;
    end
    if(l_hdr_fmt inside {35,[36:39],[56:59],[160:167],[192:199],[232:239],111,120,121,122,[124:127], [16:19],[20:21], [80:83],84,85, 22,23,86,87}) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_NP_Rsvd;
    end    
    if(l_hdr_fmt inside {[224:231]}) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_NONE_Rsvd;
    end
  endfunction: get_tlp_type

  function void populate_rsvd_type_related_var();
    if({m_hdr_fmt,m_hdr_type} inside {6,7,14,15,24,25,26,40,41,42,43,73,172,173,174,175,202,203,204,205}) begin
      get_num_of_reserved_header_dw();
      is_cpl_tlp_header_rsvd = 1;
    end
    if({m_hdr_fmt,m_hdr_type} inside {8,9,88,89,44,45, 46,47,54,55,92,93, 94,95, 65,67, 206,207,118,119}) begin
      get_num_of_reserved_header_dw();
      is_posted_tlp_id_routed_header_rsvd = 1;
    end
    if({m_hdr_fmt,m_hdr_type} inside {79,[144:147], [148:151], [152:155],168,169, [156:159],170,171,90,[98:99],[100:103],[104:107], [176:183],[184:191], [208:215],[216:223], [248:255]}) begin
      get_num_of_reserved_header_dw();
      //is_posted_tlp_address_routed_header_rsvd = 1;
    end
    if({m_hdr_fmt,m_hdr_type} inside {28,29,70,71,60,61, 62,63, 30,31, 200,201,240,241,242,243,244,245,246,247}) begin
      get_num_of_reserved_header_dw();
      is_nonposted_tlp_id_routed_header_rsvd = 1;
    end
    if({m_hdr_fmt,m_hdr_type} inside {35,[36:39],[56:59],[160:167],[192:199],[232:239],111,120,121,122,[124:127], [16:19],[20:21], [80:83],84,85, 22,23,86,87}) begin
      get_num_of_reserved_header_dw();
      is_nonposted_tlp_address_routed_header_rsvd = 1;
    end
    if({m_hdr_fmt,m_hdr_type} inside {[224:231]}) begin
      get_num_of_reserved_header_dw();
      is_none_header_rsvd = 1;
    end
  endfunction : populate_rsvd_type_related_var

  //------------------------------------------------------------------------
  // Function: do_pack
  // Extend the do_pack method to update all the Physical members of a TLP
  //------------------------------------------------------------------------
  function void do_pack (uvm_packer packer);
    super.do_pack(packer);
    packer.reset();
    packer.big_endian=1;

    if(!m_skip_rsvd_type_check) begin
      populate_rsvd_type_related_var();
      //if({m_hdr_fmt,m_hdr_type} inside {6,7,14,15,24,25,26,40,41,42,43,73,172,173,174,175,202,203,204,205}) begin
      //  get_num_of_reserved_header_dw();
      //  is_cpl_tlp_header_rsvd = 1;
      //end
      //if({m_hdr_fmt,m_hdr_type} inside {8,9,88,89,44,45, 46,47,54,55,92,93, 94,95, 65,67, 206,207,118,119}) begin
      //  get_num_of_reserved_header_dw();
      //  is_posted_tlp_id_routed_header_rsvd = 1;
      //end
      //if({m_hdr_fmt,m_hdr_type} inside {79,[144:147], [148:151], [152:155],168,169, [156:159],170,171,90,[98:99],[100:103],[104:107], [176:183],[184:191], [208:215],[216:223], [248:255]}) begin
      //  get_num_of_reserved_header_dw();
      //  //is_posted_tlp_address_routed_header_rsvd = 1;
      //end
      //if({m_hdr_fmt,m_hdr_type} inside {28,29,70,71,60,61, 62,63, 30,31, 200,201,240,241,242,243,244,245,246,247}) begin
      //  get_num_of_reserved_header_dw();
      //  is_nonposted_tlp_id_routed_header_rsvd = 1;
      //end
      //if({m_hdr_fmt,m_hdr_type} inside {35,[36:39],[56:59],[160:167],[192:199],[232:239],111,120,121,122,[124:127], [16:19],[20:21], [80:83],84,85, 22,23,86,87}) begin
      //  get_num_of_reserved_header_dw();
      //  is_nonposted_tlp_address_routed_header_rsvd = 1;
      //end
      //if({m_hdr_fmt,m_hdr_type} inside {[224:231]}) begin
      //  get_num_of_reserved_header_dw();
      //  is_none_header_rsvd = 1;
      //end
    end
    //Pack Prefixes, if any
    //In HPA 2.0/flit_mode: Prefix is not part of metadata. So, pack it
    if(pack_prefix || hpa_generation==hpa_generation_2 || is_flit_mode) begin
      //For flit mode, only local prefix to be packed at start before header
      if(m_max_no_of_local_prefixes>0) begin 
        foreach(m_tlp_local_prefix[i]) begin
          `uvm_info(get_full_name(),$sformatf("m_tlp_local_prefix=%0h",m_tlp_local_prefix[i]),UVM_LOW)
          if(m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_VEND_PREFIX_L0 || m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_VEND_PREFIX_L1)
          packer.pack_field_int(m_tlp_local_prefix[i], 32);
          if(m_hdr_type_local_prefix[i] == CDN_HPA_PCIE_FLIT_MODE_LOCAL_PREFIX && pack_flit_mode_local_prefix)
          packer.pack_field_int(m_tlp_local_prefix[i], 32);
        end
      end


      if(!is_flit_mode) begin
        if(m_ide_prefix_present)
        packer.pack_field_int(m_ide_tlp_prefix, 32);
        foreach(m_tlp_prefix[i]) begin
          packer.pack_field_int(m_tlp_prefix[i], 32);
        end
      end
    end

    //PBR: packing PTH; transmitted on the immediate DWORD preceding the TLP Header base
    if(is_cxl_pbr_mode)
    begin
      if (!is_pbr_missing_err)begin // PBR Header is not packed for this error
        packer.pack_field_int(m_tlp_pbr_tlp_header, 32);
      end
    end

    // First DW is common for all TLPs
    if(is_flit_mode) begin //{
      `uvm_pack_enumN(m_hdr_fmt,$bits(m_hdr_fmt));
      packer.pack_field_int(m_hdr_type,$bits(m_hdr_type));
      packer.pack_field_int(m_tlp_tc,$bits(m_tlp_tc));
      packer.pack_field_int(m_ohc_hdr,$bits(m_ohc_hdr));
      `uvm_pack_enumN(m_ts,$bits(m_ts));
      packer.pack_field_int(m_tlp_attr1,$bits(m_tlp_attr1));
      packer.pack_field_int(m_tlp_attr0,$bits(m_tlp_attr0));
      packer.pack_field_int(m_tlp_length,$bits(m_tlp_length));
    end else begin //}{
      `uvm_pack_enumN(m_hdr_fmt,$bits(m_hdr_fmt));
      packer.pack_field_int(m_hdr_type,$bits(m_hdr_type));
      packer.pack_field_int(m_tlp_t9,$bits(m_tlp_t9));
      packer.pack_field_int(m_tlp_tc,$bits(m_tlp_tc));
      packer.pack_field_int(m_tlp_t8,$bits(m_tlp_t8));
      packer.pack_field_int(m_tlp_attr1,$bits(m_tlp_attr1));
      packer.pack_field_int(m_tlp_ln,$bits(m_tlp_ln));
      packer.pack_field_int(m_tlp_th,$bits(m_tlp_th));
      packer.pack_field_int(m_tlp_td,$bits(m_tlp_td));
      packer.pack_field_int(m_tlp_ep,$bits(m_tlp_ep));
      packer.pack_field_int(m_tlp_attr0,$bits(m_tlp_attr0));
      `uvm_pack_enumN(m_tlp_at_type,$bits(m_tlp_at_type));
      packer.pack_field_int(m_tlp_length,$bits(m_tlp_length));
    end//}

    // The below Header words change based on TLP Type
    // Second DW
    if(is_flit_mode) begin //{
      if((m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE}) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && ((m_tlp_req_type==CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) || (m_tlp_rout_type == CDN_HPA_PCIE_TLP_ROUT_BY_ADDR))))begin
        packer.pack_field_int(m_tlp_requester_id.bus_num, $bits(m_tlp_requester_id.bus_num));
        packer.pack_field_int(m_tlp_requester_id.device_num, $bits(m_tlp_requester_id.device_num));
        packer.pack_field_int(m_tlp_requester_id.function_num, $bits(m_tlp_requester_id.function_num));
        packer.pack_field_int(m_tlp_ep,$bits(m_tlp_ep));
        packer.pack_field_int(second_dw_byte_6_field_6_rsvd, $bits(second_dw_byte_6_field_6_rsvd));
        packer.pack_field_int(m_tlp_14_bit_tagscale, $bits(m_tlp_14_bit_tagscale));
        packer.pack_field_int(m_tlp_t9,$bits(m_tlp_t9));
        packer.pack_field_int(m_tlp_t8,$bits(m_tlp_t8));
        packer.pack_field_int(m_tlp_tag , $bits(m_tlp_tag));
      end
      else if((m_tlp_trans_type==CDN_HPA_PCIE_TRANS_MSG_TYPE)  || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (m_tlp_rout_type == CDN_HPA_PCIE_TLP_ROUT_BY_OTHER))) begin //{
        packer.pack_field_int(m_tlp_requester_id.bus_num, $bits(m_tlp_requester_id.bus_num));
        packer.pack_field_int(m_tlp_requester_id.device_num, $bits(m_tlp_requester_id.device_num));
        packer.pack_field_int(m_tlp_requester_id.function_num, $bits(m_tlp_requester_id.function_num));
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate}) begin
          packer.pack_field_int(m_tlp_ep,$bits(m_tlp_ep));
          packer.pack_field_int(msg_inv_req_byte_6_field_6_5_rsvd ,2);
          packer.pack_field_int(m_tlp_itag , $bits(m_tlp_itag));
        end else begin
          packer.pack_field_int(m_tlp_ep,$bits(m_tlp_ep));
          if(pcie_6_1_support && m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1})) begin
            packer.pack_field_int(vendor_definition_vd_msg,$bits(vendor_definition_vd_msg));
          end else if(m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin
            packer.pack_field_int(msg_ide_escort_byte_6_field_6_2,$bits(msg_ide_escort_byte_6_field_6_2));
            packer.pack_field_int(msg_ide_escort_sse,$bits(msg_ide_escort_sse));
          end else begin
            packer.pack_field_int(second_dw_byte_6_msg_rsvd,$bits(second_dw_byte_6_msg_rsvd));
          end
        end
        packer.pack_field_int(m_tlp_msg_code,$bits(m_tlp_msg_code));
      end //}
      if ((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD, CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk,
                              CDN_HPA_PCIE_TLP_TYPE_UIORdCplD, CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_CPL_Rsvd}) || is_cpl_tlp_header_rsvd) begin
        packer.pack_field_int(m_tlp_completer_id.bus_num, 8);
        packer.pack_field_int(m_tlp_completer_id.device_num, 5);
        packer.pack_field_int(m_tlp_completer_id.function_num, 3);
        packer.pack_field_int(m_tlp_ep,$bits(m_tlp_ep));
        if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl}) begin
          packer.pack_field_int(second_dw_byte_6_field_6_rsvd, $bits(second_dw_byte_6_field_6_rsvd));
        end
        else begin
          packer.pack_field_int(m_tlp_cpl_lower_addr[6], 1);
        end
        packer.pack_field_int(m_tlp_14_bit_tagscale, $bits(m_tlp_14_bit_tagscale));
        packer.pack_field_int(m_tlp_t9,$bits(m_tlp_t9));
        packer.pack_field_int(m_tlp_t8,$bits(m_tlp_t8));
        packer.pack_field_int(m_tlp_tag , $bits(m_tlp_tag));
      end
    end else begin //}{
      if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE,CDN_HPA_PCIE_TRANS_MSG_TYPE}) begin
        packer.pack_field_int(m_tlp_requester_id.bus_num, $bits(m_tlp_requester_id.bus_num));
        packer.pack_field_int(m_tlp_requester_id.device_num, $bits(m_tlp_requester_id.device_num));
        packer.pack_field_int(m_tlp_requester_id.function_num, $bits(m_tlp_requester_id.function_num));
        if(((m_tlp_trans_type==CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate))) begin //INV_REQ
          packer.pack_field_int(msg_inv_req_byte_6_field_7_rsvd_nfm, $bits(msg_inv_req_byte_6_field_7_rsvd_nfm));
          packer.pack_field_int(msg_inv_req_byte_6_field_6_5_rsvd ,2);
          packer.pack_field_int(m_tlp_itag , $bits(m_tlp_itag));
        end else if(pcie_6_1_support && m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1})) begin //VD_MSG
          packer.pack_field_int(vendor_definition_vd_msg_rsvd_bit,$bits(vendor_definition_vd_msg_rsvd_bit));
          packer.pack_field_int(vendor_definition_vd_msg,$bits(vendor_definition_vd_msg));
        end else if((m_tlp_trans_type==CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_IDE_Escort)) begin
          packer.pack_field_int(msg_inv_req_byte_6_field_7_rsvd_nfm, $bits(msg_inv_req_byte_6_field_7_rsvd_nfm));
          packer.pack_field_int(msg_ide_escort_byte_6_field_6_2,$bits(msg_ide_escort_byte_6_field_6_2));
          packer.pack_field_int(msg_ide_escort_sse,$bits(msg_ide_escort_sse));
        end else begin
          packer.pack_field_int(m_tlp_tag , $bits(m_tlp_tag));
        end

        if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MSG_TYPE) begin
          packer.pack_field_int(m_tlp_last_dw_be, $bits(m_tlp_last_dw_be));
          packer.pack_field_int(m_tlp_first_dw_be, $bits(m_tlp_first_dw_be));
        end else begin
          packer.pack_field_int(m_tlp_msg_code,8);
        end
      end

      if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD, CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk}) begin
        packer.pack_field_int(m_tlp_completer_id.bus_num, 8);
        packer.pack_field_int(m_tlp_completer_id.device_num, 5);
        packer.pack_field_int(m_tlp_completer_id.function_num, 3);
        `uvm_pack_enumN(m_tlp_cpl_status,$bits(m_tlp_cpl_status));
        packer.pack_field_int(m_tlp_cpl_bcm, 1);
        packer.pack_field_int(m_tlp_cpl_byte_cnt, 12);
      end
    end //}

    // Third & Fourth DWs
    if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_RSVD_TYPE}) begin
      if(m_tlp_rout_type==CDN_HPA_PCIE_TLP_ROUT_BY_ADDR) begin
        if((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_64))
          packer.pack_field_int(m_tlp_addr[63:32],32);
        packer.pack_field_int(m_tlp_addr[31:4],28);
        if(is_flit_mode) begin //{
          if(cxl_mode && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            packer.pack_field_int(m_cxl_src,1);
            packer.pack_field_int(1'b0,1);
          end else begin
            packer.pack_field_int(m_tlp_addr[3:2],2);
          end
          `uvm_pack_enumN(m_tlp_at_type,$bits(m_tlp_at_type));
        end else begin //}{
          if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            //TR Req and it can't have TPH. Instead no_write flag can be appended at addr[0] position
            if(cxl_mode) begin
              packer.pack_field_int(m_cxl_src,1);
              packer.pack_field_int(2'b0,2);
            end else begin
              packer.pack_field_int(m_tlp_addr[3:2],2);
              packer.pack_field_int(1'b0,1);
            end
            packer.pack_field_int(m_tlp_ats_tr_nw_field,1);
          end else begin
            packer.pack_field_int(m_tlp_addr[3:2],2);
            packer.pack_field_int(m_tlp_ph,2); //m_tlp_ph=2'b00 when TH=0. Taken care in constraint
          end
        end //}      
      end
      else if(m_tlp_rout_type==CDN_HPA_PCIE_TLP_ROUT_BY_OTHER) begin
        packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
        packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
        packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
        packer.pack_field_int(msg_cmn_byte_8_15_rsvd[23:16],8);
        packer.pack_field_int(msg_cmn_byte_8_15_rsvd[31:24],8);
        if(num_of_header_dw>=4) begin
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[39:32],8);
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[47:40],8);
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[55:48],8);
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[63:56],8);
        end
      end
    end
    case(m_tlp_trans_type) inside
      CDN_HPA_PCIE_TRANS_MEM_TYPE: begin
        if((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_64))
        packer.pack_field_int(m_tlp_addr[63:32],32);
        packer.pack_field_int(m_tlp_addr[31:4],28);
        if(is_flit_mode) begin //{
          if(cxl_mode && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            packer.pack_field_int(m_cxl_src,1);
            packer.pack_field_int(1'b0,1);
          end else begin
            packer.pack_field_int(m_tlp_addr[3:2],2);
          end
          `uvm_pack_enumN(m_tlp_at_type,$bits(m_tlp_at_type));
        end else begin //}{
          if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            //TR Req and it can't have TPH. Instead no_write flag can be appended at addr[0] position
            if(cxl_mode) begin
              packer.pack_field_int(m_cxl_src,1);
              packer.pack_field_int(2'b0,2);
            end else begin
              packer.pack_field_int(m_tlp_addr[3:2],2);
              packer.pack_field_int(1'b0,1);
            end
            packer.pack_field_int(m_tlp_ats_tr_nw_field,1);
          end else begin
            packer.pack_field_int(m_tlp_addr[3:2],2);
            packer.pack_field_int(m_tlp_ph,2); //m_tlp_ph=2'b00 when TH=0. Taken care in constraint
          end
        end //}
      end
      CDN_HPA_PCIE_TRANS_IO_TYPE : begin
        packer.pack_field_int(m_tlp_addr[31:2],30);
        packer.pack_field_int(io_byte_11_rsvd_field_1_0,2);
      end
      CDN_HPA_PCIE_TRANS_CFG_TYPE : begin
        packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
        packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
        packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
        packer.pack_field_int(cfg_byte_10_rsvd_field_7_4,$bits(cfg_byte_10_rsvd_field_7_4));
        packer.pack_field_int(m_tlp_ext_reg_num,$bits(m_tlp_ext_reg_num));
        packer.pack_field_int(m_tlp_reg_num,$bits(m_tlp_reg_num));
      end
    endcase

    // Cpl
    if ((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD,
    CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk, CDN_HPA_PCIE_TLP_TYPE_CPL_Rsvd}) || is_cpl_tlp_header_rsvd) begin
      if(is_flit_mode) begin //{
        packer.pack_field_int(m_tlp_requester_id.bus_num, 8);
        packer.pack_field_int(m_tlp_requester_id.device_num, 5);
        packer.pack_field_int(m_tlp_requester_id.function_num, 3);
        //packer.pack_field_int(m_completion_segment_differ, $bits(m_completion_segment_differ));
        packer.pack_field_int(m_tlp_cpl_lower_addr[5:2], 4);
        packer.pack_field_int(m_tlp_cpl_byte_cnt, 12);
      end else begin //}{
        packer.pack_field_int(m_tlp_requester_id.bus_num, 8);
        packer.pack_field_int(m_tlp_requester_id.device_num, 5);
        packer.pack_field_int(m_tlp_requester_id.function_num, 3);
        packer.pack_field_int(m_tlp_tag, 8);
        packer.pack_field_int(cpl_byte_12_rsvd_field_7, 1);
        packer.pack_field_int(m_tlp_cpl_lower_addr[6:0], 7);
      end //}
    end

    // Cpl UIO
    if (is_flit_mode && m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) begin
      packer.pack_field_int(m_tlp_requester_id.bus_num, 8);
      packer.pack_field_int(m_tlp_requester_id.device_num, 5);
      packer.pack_field_int(m_tlp_requester_id.function_num, 3);
      if (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD) begin
        packer.pack_field_int(m_tlp_cpl_lower_addr[5:2], 4);
        packer.pack_field_int(cpl_byte_11_rsvd_field_3_0, 4);
        packer.pack_field_int(cpl_byte_12_rsvd_field_7, 1);
        packer.pack_field_int(m_tlp_cpl_cdl, 2);
        packer.pack_field_int(m_tlp_cpl_lower_addr[11:7], 5);
      end
      else begin
        packer.pack_field_int(cpl_byte_11_rsvd_field_7_4, 4);
        packer.pack_field_int(cpl_byte_11_rsvd_field_3_0, 4);
        packer.pack_field_int(cpl_byte_12_rsvd_field_7, 1);
        packer.pack_field_int(m_tlp_cpl_cdl, 2);
        packer.pack_field_int(cpl_byte_12_rsvd_field_4_0, 5);
      end
    end

    //Msgs
    if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) begin
      if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin
        if((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type0) || ((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type1)&&(m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_HIER_ID))) begin
          packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
          packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
          packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
        end else begin
          packer.pack_field_int(m_tlp_hier_vmsg_hierarchy_id,$bits(m_tlp_hier_vmsg_hierarchy_id));
        end
        packer.pack_field_int(m_tlp_vendor_id,$bits(m_tlp_vendor_id));
        packer.pack_field_int(m_tlp_vendor_msg,$bits(m_tlp_vendor_msg));
      end else if (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
        packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
        packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
        packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
        packer.pack_field_int(msg_inv_req_byte_10_15_rsvd,$bits(msg_inv_req_byte_10_15_rsvd));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin
        packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
        packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
        packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
        packer.pack_field_int(msg_inv_cpl_byte_10_11_rsvd,$bits(msg_inv_cpl_byte_10_11_rsvd));
        packer.pack_field_int(m_inv_cpl_cnt,$bits(m_inv_cpl_cnt));
        packer.pack_field_int(m_tlp_itag_vector,$bits(m_tlp_itag_vector));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin
        if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
          packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
          packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
          packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
          packer.pack_field_int(msg_ltr_byte_8_11_rsvd[23:16],8);
          packer.pack_field_int(msg_ltr_byte_8_11_rsvd[31:24],8);
        end else begin
          packer.pack_field_int(msg_ltr_byte_8_11_rsvd,$bits(msg_ltr_byte_8_11_rsvd));
        end
        packer.pack_field_int(m_tlp_ltr_msg_no_snoop_latency,$bits(m_tlp_ltr_msg_no_snoop_latency));
        packer.pack_field_int(m_tlp_ltr_msg_snoop_latency,$bits(m_tlp_ltr_msg_snoop_latency));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Request) begin
        packer.pack_field_int(m_page_addr,$bits(m_page_addr));
        packer.pack_field_int(m_prGroupIndex,$bits(m_prGroupIndex));
        packer.pack_field_int(m_prLastRequest,$bits(m_prLastRequest));
        packer.pack_field_int(m_prWriteRequested,$bits(m_prWriteRequested));
        packer.pack_field_int(m_prReadRequested,$bits(m_prReadRequested));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Group_Response) begin
        packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
        packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
        packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
        packer.pack_field_int(m_prgResponseCode,$bits(m_prgResponseCode));
        packer.pack_field_int(msg_pr_rsp_byte_10_field_3_1_rsvd,$bits(msg_pr_rsp_byte_10_field_3_1_rsvd));
        packer.pack_field_int(m_prGroupIndex,$bits(m_prGroupIndex));
        packer.pack_field_int(msg_pr_rsp_byte_12_15_rsvd,$bits(msg_pr_rsp_byte_12_15_rsvd));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin
        if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
          packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
          packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
          packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
          packer.pack_field_int(msg_obff_byte_8_14_rsvd[23:16],8);
          packer.pack_field_int(msg_obff_byte_8_14_rsvd[31:24],8);
          packer.pack_field_int(msg_obff_byte_8_14_rsvd[39:32],8);
          packer.pack_field_int(msg_obff_byte_8_14_rsvd[47:40],8);
          packer.pack_field_int(msg_obff_byte_8_14_rsvd[55:48],8);
          packer.pack_field_int(msg_obff_byte_8_14_rsvd[59:56],4);
        end else begin
          packer.pack_field_int(msg_obff_byte_8_14_rsvd,$bits(msg_obff_byte_8_14_rsvd));
        end
        packer.pack_field_int(m_obffCode,$bits(m_obffCode));
      end else if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code== CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD)) begin
        if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
          packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
          packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
          packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
          packer.pack_field_int(m_ptmMasterTime[23:16], 8);
          packer.pack_field_int(m_ptmMasterTime[31:24], 8);
          packer.pack_field_int(m_ptmMasterTime[39:32], 8);
          packer.pack_field_int(m_ptmMasterTime[47:40], 8);
          packer.pack_field_int(m_ptmMasterTime[55:48], 8);
          packer.pack_field_int(m_ptmMasterTime[63:56], 8);
        end else begin
          packer.pack_field_int(m_ptmMasterTime,$bits(m_ptmMasterTime));
        end
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Sync) begin
        if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
          packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
          packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
          packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
          packer.pack_field_int(msg_ide_sync_byte_8_11_rsvd[23:16],8);
          packer.pack_field_int(msg_ide_sync_byte_8_11_rsvd[31:24],8);
        end else begin //} {
          packer.pack_field_int(msg_ide_sync_byte_8_11_rsvd,$bits(msg_ide_sync_byte_8_11_rsvd));
        end
        packer.pack_field_int(msg_ide_sync_byte_12_rsvd,8);
        packer.pack_field_int(msg_ide_sync_pr_sent_cnt_cpl,$bits(msg_ide_sync_pr_sent_cnt_cpl));
        packer.pack_field_int(msg_ide_sync_byte_14_rsvd,8);
        packer.pack_field_int(msg_ide_sync_pr_sent_cnt_np ,$bits(msg_ide_sync_pr_sent_cnt_np));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin
        if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
          packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
          packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
          packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
          packer.pack_field_int(msg_ide_sync_byte_8_11_rsvd[23:16],8);
          packer.pack_field_int(msg_ide_sync_byte_8_11_rsvd[31:24],8);
        end else begin //} {
          packer.pack_field_int(msg_ide_sync_byte_8_11_rsvd,$bits(msg_ide_sync_byte_8_11_rsvd));
        end
        packer.pack_field_int(msg_ide_fail_byte_12_15_rsvd,$bits(msg_ide_fail_byte_12_15_rsvd));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Fail) begin
        if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
          packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
          packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
          packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
        end else begin //} {
          packer.pack_field_int(msg_ide_fail_byte_8_9_rsvd,$bits(msg_ide_fail_byte_8_9_rsvd));
        end
        packer.pack_field_int(msg_ide_fail_byte_10_rsvd,8);
        packer.pack_field_int(msg_ide_fail_stream_id,$bits(msg_ide_fail_stream_id));
        packer.pack_field_int(msg_ide_fail_byte_12_15_rsvd,$bits(msg_ide_fail_byte_12_15_rsvd));

      end else begin //3rd & 4th DW are Rsvd for other messages
        if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
          packer.pack_field_int(m_tlp_completer_id.bus_num,$bits(m_tlp_completer_id.bus_num));
          packer.pack_field_int(m_tlp_completer_id.device_num,$bits(m_tlp_completer_id.device_num));
          packer.pack_field_int(m_tlp_completer_id.function_num,$bits(m_tlp_completer_id.function_num));
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[23:16],8);
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[31:24],8);
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[39:32],8);
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[47:40],8);
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[55:48],8);
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd[63:56],8);
        end else begin
          packer.pack_field_int(msg_cmn_byte_8_15_rsvd,$bits(msg_cmn_byte_8_15_rsvd));
        end
      end
    end

    if(is_flit_mode) begin
      if ((num_of_header_dw >= 4) && (m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_CPL_Rsvd)) begin
        packer.pack_field_int(rsvd_4th_dw,32);
      end
      if (num_of_header_dw >= 5) begin
        packer.pack_field_int(rsvd_5th_dw,32);
      end
      if (num_of_header_dw >= 6) begin
        packer.pack_field_int(rsvd_6th_dw,32);
      end
      if (num_of_header_dw >= 7) begin
        packer.pack_field_int(rsvd_7th_dw,32);
      end
      if (num_of_header_dw >= 8) begin
        packer.pack_field_int(rsvd_7th_dw,32);
      end
    end

    //Flit mode :- Pack OHC fields
    if(is_flit_mode) begin
      if(m_ohc_hdr.ohc_a_present) packer.pack_field_int(m_ohc_a,$bits(m_ohc_a));
      if(m_ohc_hdr.ohc_b_present) packer.pack_field_int(m_ohc_b,$bits(m_ohc_b));
      if(m_ohc_hdr.ohc_c_present) packer.pack_field_int(m_ohc_c,$bits(m_ohc_c));
      if(m_ohc_hdr.ohc_ex_present!=no_ohc_ex_present) begin
        foreach(m_ohc_e[i]) packer.pack_field_int(m_ohc_e[i],32);
      end
    end

    if(({m_hdr_fmt,m_hdr_type} inside {/*completion*/ 6,7,26,73,202,203,204,205, 
                                      /*Posted*/ 88,89,90,92,93,[98:99],[100:103],[104:107], 94,95,[176:183],[184:191], 65,67,[208:215],[216:223], 206,207,[248:255], 118,119,
                                      /*NonPosted*/ 70,71,111,120,121,122,[124:127],240,241, [16:19],[20:21],242,243, [80:83],84,85,244,245, 22,23,86,87,246,247, 
                                      /*None*/ [228:231]
                                     }) && (!m_skip_rsvd_type_check)) begin
      rsvd_with_payload = 1;
    end

    // payload present
    if(((m_hdr_fmt[1] == 1'b1) && (m_tlp_trans_type != CDN_HPA_PCIE_TRANS_RSVD_TYPE)) || rsvd_with_payload) begin
      foreach(m_tlp_payload[i]) begin
        packer.pack_field_int(m_tlp_payload[i], 8);
      end
    end

    //Flit mode :- Pack TS Payload
    //If pack_ecrc==1 && m_ts==CDN_HPA_PCIE_1DW_ECRC_TRAILER, then in post_randomize ECRC will be appended. So, no need to pack explicitly
    // pack_ecrc && m_td
    //TODO Check with Karthik for flit mode condition check
    //if(is_flit_mode && (m_ts!=CDN_HPA_PCIE_1DW_ECRC_TRAILER || (!pack_ecrc && m_ts==CDN_HPA_PCIE_1DW_ECRC_TRAILER))) begin
    //if(is_flit_mode && (m_ts!=CDN_HPA_PCIE_1DW_ECRC_TRAILER)) begin
    //if(is_flit_mode && (m_ts!=CDN_HPA_PCIE_1DW_ECRC_TRAILER || (!pack_ecrc && m_ts==CDN_HPA_PCIE_1DW_ECRC_TRAILER) || (pack_ecrc_local && (m_ts==CDN_HPA_PCIE_1DW_ECRC_TRAILER)))) begin
    if(is_flit_mode) begin
      if(!((m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER) && !pack_ecrc_local) && pack_trailer) begin
        foreach(m_ts_payload[i]) packer.pack_field_int(m_ts_payload[i], 8);
      end
    end
    else begin
      if(pack_ecrc_local && m_tlp_td && !m_ide_prefix_present) begin //{
        packer.pack_field_int(ecrc_val, 32);
      end
      else if(m_ide_prefix_present && pack_ide_trailer) begin
        if(m_ide_m) begin
          if(m_ide_p) packer.pack_field_int(m_ide_pcrc,32);
          for(int i=12; i>0; i--) packer.pack_field_int(m_ide_mac[i-1],8);
        end
      end
    end

    if(pack_intx) begin
      packer.pack_field_int(requestor_id,$bits(requestor_id));
      packer.pack_field_int(intx_in_pin_value,$bits(intx_in_pin_value));
      packer.pack_field_int(intx_in_pin_valid_value,$bits(intx_in_pin_valid_value));
      packer.pack_field_int(intx_out_pin_value,$bits(intx_out_pin_value));
      packer.pack_field_int(int_ack_pin_value,$bits(int_ack_pin_value));
      foreach(intx_pin[i]) begin
        `uvm_pack_enumN(intx_pin[i],$bits(intx_pin[i]));
      end
      foreach(intx_out_pin[i]) begin
        `uvm_pack_enumN(intx_out_pin[i],$bits(intx_out_pin[i]));
      end
      packer.pack_field_int(intx_pending_status,$bits(intx_pending_status));
      //  packer.pack_field_int(m_intr_pins,$bits(m_intr_pins));
      foreach(start_time[i]) begin
        packer.pack_field_int(start_time[i],$bits(start_time[i]));
      end
      foreach(end_time[i]) begin
        packer.pack_field_int(end_time[i],$bits(end_time[i]));
      end
      packer.pack_field_int(fid_active,$bits(fid_active));
    end

    if(pack_msi_msix) begin
      packer.pack_field_int(msi_en,$bits(msi_en));
      packer.pack_field_int(id_based_ordering,$bits(id_based_ordering));
      packer.pack_field_int(msi_msix_requestor_id,$bits(msi_msix_requestor_id));
      packer.pack_field_int(intr_number,$bits(intr_number));
      packer.pack_field_int(intr_number_bits,$bits(intr_number_bits));
      packer.pack_field_int(intr_number_bits_cap,$bits(intr_number_bits_cap));
      packer.pack_field_int(int_msix_msg_data,$bits(int_msix_msg_data));
      packer.pack_field_int(int_msix_msg_lo_addr,$bits(int_msix_msg_lo_addr));
      packer.pack_field_int(int_msix_msg_hi_addr,$bits(int_msix_msg_hi_addr));
      packer.pack_field_int(pending_status,$bits(pending_status));
      packer.pack_field_int(requestor_id_for_pending_status,$bits(requestor_id_for_pending_status));
      packer.pack_field_int(int_msi_pending_status_valid,$bits(int_msi_pending_status_valid));
      packer.pack_field_int(int_msi_pending_status,$bits(int_msi_pending_status));
      packer.pack_field_int(msi_msg_low_addr,$bits(msi_msg_low_addr));
      packer.pack_field_int(msi_msg_hi_addr,$bits(msi_msg_hi_addr));
      packer.pack_field_int(msi_msg_data,$bits(msi_msg_data));
      packer.pack_field_int(ext_msg_data_en,$bits(ext_msg_data_en));
      packer.pack_field_int(msi_64bit_addr_cap,$bits(msi_64bit_addr_cap));
      packer.pack_field_int(msi_per_vector_masking_cap,$bits(msi_per_vector_masking_cap));
      packer.pack_field_int(st_tag_pin_or_reg,$bits(st_tag_pin_or_reg));
      packer.pack_field_int(tph_st_table_index,$bits(tph_st_table_index));
      packer.pack_field_int(tph_present,$bits(tph_present));
      packer.pack_field_int(extended_tph_valid,$bits(extended_tph_valid));
      packer.pack_field_int(int_msg_valid,$bits(int_msg_valid));
      packer.pack_field_int(tph_type,$bits(tph_type));
      packer.pack_field_int(tph_st_tag,$bits(tph_st_tag));
      packer.pack_field_int(attributes,$bits(attributes));
      packer.pack_field_int(attr_no_snoop,$bits(attr_no_snoop));
      packer.pack_field_int(attr_relax_ordering,$bits(attr_relax_ordering));
      packer.pack_field_int(attr_ido,$bits(attr_ido));
      packer.pack_field_int(pasidPresent,$bits(pasidPresent));
      packer.pack_field_int(pasidVal,$bits(pasidVal));
      packer.pack_field_int(pasidExecReq,$bits(pasidExecReq));
      packer.pack_field_int(pasidPriModeReq,$bits(pasidPriModeReq));
      packer.pack_field_int(atsPresent,$bits(atsPresent));
      packer.pack_field_int(ats_at,$bits(ats_at));
      packer.pack_field_int(tc_val,$bits(tc_val));
      packer.pack_field_int(abort_status,$bits(abort_status));
      packer.pack_field_int(int_mask_changed_ipfivf,$bits(int_mask_changed_ipfivf));
      packer.pack_field_int(int_mask_changed_valid,$bits(int_mask_changed_valid));
      packer.pack_field_int(int_msg_done,$bits(int_msg_done));
      packer.pack_field_int(int_msi_cap,$bits(int_msi_cap));
      packer.pack_field_int(int_msix_cap,$bits(int_msix_cap));
      packer.pack_field_int(msi_msix_start_time,$bits(msi_msix_start_time));
      packer.pack_field_int(msi_msix_end_time,$bits(msi_msix_end_time));
    end

  endfunction

  //------------------------------------------------------------------------
  // Function: do_unpack
  // Extend the do_unpack method for the control member fields
  //------------------------------------------------------------------------
  function void do_unpack (uvm_packer packer);
    bit [31:0] temp,temp_dw,temp_3rd_dw,temp_4th_dw;
    bit [2:0] prfx_cnt;
    bit [2:0] local_prfx_cnt;
    bit [7:0] trailer_size_decoded;
    bit [2:0] m_ohc_e_size_decoded;
    int bit_stream_size;
    byte unsigned packer_data_byte[];
    bit first_local_prefix_unpacked;
    bit pbr_unpacked=0;
    bit hdr_fmt_set = 0;
    bit pbr_and_hdr_fmt_set = 0;
    bit [31:0] temp_err_data;
    
    packer.big_endian=1;
    super.do_unpack(packer);
    `uvm_info(get_full_name(),$sformatf("Calling do unpack for %0s ",get_full_name()),UVM_DEBUG);

    bit_stream_size = packer.get_packed_size();
    packer.get_bytes(packer_data_byte);

    `uvm_info(get_type_name(),$sformatf("Unpacking %p ",packer_data_byte ),UVM_DEBUG);

    if((unpack_prefix || hpa_generation==hpa_generation_2 || is_flit_mode) && bit_stream_size > 0) begin //{
      do begin //{
        // Unpack the Fmt
        temp = 32'h00000000;
        temp[31:29] = packer.unpack_field_int(3);
        `uvm_info(get_full_name(),$sformatf("temp[31:29]=%0b",temp[31:29]),UVM_DEBUG);
        if(temp[31:29] == 3'b100) begin //Prefix {
          temp[28:0] = packer.unpack_field_int(29);
          if(temp[28]==1) begin //{ E2E Prefix
            if((temp[28:24] == 5'b10010) && (!is_flit_mode)) begin //IDE Prefix
              m_ide_prefix_present = 1;
              m_ide_tlp_prefix = temp[31:0];
              m_ide_hdr_fmt_prefix = cdn_hpa_pcie_tlp_fmt_t'(temp[31:29]);
              m_ide_hdr_type_prefix = temp[28:24];
              m_pr_sent_counter = temp[23:16];
              m_stream_id = temp[15:8];
              m_sub_stream = temp[7:4];
              {m_ide_p, m_ide_m, m_ide_k, m_ide_t} = temp[3:0];
            end
            else begin
              if(!is_flit_mode) begin
                m_tlp_prefix = new[prfx_cnt+1](m_tlp_prefix);
                m_hdr_fmt_prefix = new[prfx_cnt+1](m_hdr_fmt_prefix);
                m_hdr_type_prefix = new[prfx_cnt+1](m_hdr_type_prefix);
                m_tlp_prefix[prfx_cnt] = temp[31:0];
                m_hdr_fmt_prefix[prfx_cnt] = cdn_hpa_pcie_tlp_fmt_t'(temp[31:29]);
                m_hdr_type_prefix[prfx_cnt] = temp[28:24];
                if(m_hdr_type_prefix[prfx_cnt] ==  5'b10000) begin //TPH Prefix {
                  m_tlp_st_tag[15:8] = temp[23:16];
                  if((hpa_generation != hpa_generation_2) && !is_flit_mode) begin
                    tph_byte_2_3_rsvd = temp[15:0];
                  end else begin
                    m_ama_valid = temp[12];
                    m_ama_value = temp[15:13];
                    tph_byte_2_3_rsvd = temp[11:0];
                  end
                  m_tlp_e2e_prfx_type = CDN_HPA_PCIE_TLP_Tph;
                  m_ext_tph_prefix_present = 1;
                end //}
                if(m_hdr_type_prefix[prfx_cnt] ==  5'b10001) begin //PASID Prefix {
                  m_pasid_pri_value = temp[23];
                  m_pasid_exec_value = temp[22];
                  pasid_byte_1_rsvd_field_5_4 = temp[21:20];
                  m_pasid_value = temp[19:0];
                  m_tlp_e2e_prfx_type = CDN_HPA_PCIE_TLP_Pasid;
                  m_pasid_prefix_present = 1;
                end //}
                prfx_cnt++;
              end
              else begin //144-159
                `uvm_info(get_full_name(), $psprintf("posted reserved type"), UVM_DEBUG) // B406 Errata - Reserved Local Prefix
                is_posted_tlp_address_routed_header_rsvd = 1;
                m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(temp[31:29]);
                hdr_fmt_set = 1;
              end
            end
          end else begin //}{ Local Prefix
            if(temp[28:24] == 5'b01110 || temp[28:24] == 5'b01111 || temp[28:24] == 5'b01101) begin
              m_tlp_local_prefix = new[local_prfx_cnt+1](m_tlp_local_prefix);
              m_hdr_fmt_local_prefix = new[local_prfx_cnt+1](m_hdr_fmt_local_prefix);
              m_hdr_type_local_prefix = new[local_prfx_cnt+1](m_hdr_type_local_prefix);
              m_tlp_local_prefix_data = new[local_prfx_cnt+1](m_tlp_local_prefix_data);
              m_tlp_local_prefix[local_prfx_cnt] = temp[31:0];
              m_hdr_fmt_local_prefix[local_prfx_cnt] = cdn_hpa_pcie_tlp_fmt_t'(temp[31:29]);
              m_hdr_type_local_prefix[local_prfx_cnt] = cdn_hpa_pcie_vnd_def_loc_prfx_t'(temp[28:24]);
              m_tlp_local_prefix_data[local_prfx_cnt] = temp[23:0];
              if(cxl_mode && cxl_ldid_prefix && temp[28:24] == 5'b01110) //CDN_HPA_PCIE_VEND_PREFIX_L0_only
              m_cxl_ldid = temp[23:8];
              if(temp[28:24] == 5'b01110 || temp[28:24] == 5'b01111)
              m_local_prefix_possible = 1;
              else if(temp[28:24] == 5'b01101) begin
                m_flit_mode_local_prefix_possible = 1;
                m_tlp_uses_dedicated_credits = temp[23];
                `uvm_info(get_full_name(),$sformatf("m_tlp_local_prefix_data=%0h",m_tlp_local_prefix_data[local_prfx_cnt]),UVM_LOW)
              end
              local_prfx_cnt++;
              if(first_local_prefix_unpacked == 0) begin
                first_local_prefix_unpacked = 1;
                m_flit_mode_local_prefix_as_first_prefix = temp[28:24] == 5'b01101 ? 1: 0;
              end
            end
            else begin // ERROR SCENARIOS
              if (temp[28:24] inside {[5'b0_0000:5'b0_1100]} && /*!is_cxl_pbr_mode &&*/ local_prfx_cnt == 2) begin
                `uvm_info(get_full_name(), $psprintf("Local Prefix 5:0 data field has a RSVD Value!"), UVM_DEBUG) // B406 Errata - Reserved Local Prefix
                `uvm_info(get_full_name(), $psprintf("Local Prefix value = %h", temp), UVM_DEBUG)
                is_tlp_header_rsvd = 1;
                m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(temp[31:29]);
                if (pbr_unpacked || !is_cxl_pbr_mode)
                  hdr_fmt_set = 1;
              end
              else if (temp[28:24] inside {[5'b0_0000:5'b0_1100]}) begin
                `uvm_info(get_full_name(), $psprintf("Local Prefix 5:0 data field has a RSVD Value!"), UVM_DEBUG) // B406 Errata - Reserved Local Prefix
                `uvm_info(get_full_name(), $psprintf("Local Prefix value = %h", temp), UVM_DEBUG)
                is_tlp_header_rsvd = 1;
                m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(temp[31:29]);
                if (pbr_unpacked || !is_cxl_pbr_mode)
                  hdr_fmt_set = 1;
              end
              else begin
                `uvm_info(get_full_name(), $psprintf("Local Prefix is corrupted!"), UVM_DEBUG) // Information about corrupted local prefix
                `uvm_info(get_full_name(), $psprintf("Local Prefix value = %h", temp), UVM_DEBUG)
                m_tlp_local_prefix = new[local_prfx_cnt+1](m_tlp_local_prefix);
                m_hdr_fmt_local_prefix = new[local_prfx_cnt+1](m_hdr_fmt_local_prefix);
                m_hdr_type_local_prefix = new[local_prfx_cnt+1](m_hdr_type_local_prefix);
                m_tlp_local_prefix_data = new[local_prfx_cnt+1](m_tlp_local_prefix_data);
                m_tlp_local_prefix[local_prfx_cnt] = temp[31:0];
                m_hdr_fmt_local_prefix[local_prfx_cnt] = cdn_hpa_pcie_tlp_fmt_t'(temp[31:29]);
                m_hdr_type_local_prefix[local_prfx_cnt] = cdn_hpa_pcie_vnd_def_loc_prfx_t'(temp[28:24]);
                m_tlp_local_prefix_data[local_prfx_cnt] = temp[23:0];
                m_local_prefix_possible = 1;
                local_prfx_cnt++;
                if(first_local_prefix_unpacked == 0) begin
                  first_local_prefix_unpacked = 1;
                  m_flit_mode_local_prefix_as_first_prefix = temp[28:24] == 5'b01101 ? 1: 0;
                end
              end
            end
            
            if (pbr_unpacked && local_prfx_cnt<2) begin
              `uvm_info(get_type_name(), $sformatf("Local Prefix Unpacked After PBR Header!"), UVM_DEBUG);
              is_local_pref_after_pth_err = 1;
            end
          end //}
        end
    `ifndef HLS_MODULE_MODE
        else if((temp[31:30] == 2'b11) && (is_cxl_pbr_mode)) //TODO enable for reserved type
    `else
        else if((temp[31:30] == 2'b11) && (is_cxl_pbr_mode)) //TODO enable for reserved type
    `endif
        begin
          if(pbr_unpacked) break; //PBR is packed and another temp[31:30] == 2'b11 could be reserved type
          `uvm_info(get_type_name(),$sformatf("Unpacking CXL PBR PTH"),UVM_DEBUG);
          temp[28:0] = packer.unpack_field_int(29);
          //29,28,27 bit rsvd
          m_tlp_pbr_tlp_header = temp[31:0];
          m_tlp_pth_rsvd       = temp[29:27];
          m_tlp_pth_hie        = temp[26];
          m_tlp_pth_dsar       = temp[25];
          m_tlp_pth_pif        = temp[24];
          m_tlp_pth_spid       = temp[23:12];
          m_tlp_pth_dpid       = temp[11:0];
          pbr_unpacked = 1;
        end
        else begin //TLP header } {
          m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(temp[31:29]);
          `uvm_info(get_type_name(),$sformatf("m_hdr_fmt=%0b",m_hdr_fmt),UVM_DEBUG);
          if (pbr_unpacked || !is_cxl_pbr_mode)
          hdr_fmt_set = 1;  // Exit while loop once all headers are unpacked. This is used for guarding in case of local prefix related error injection scenarios
        end //}
        bit_stream_size -= 32;
      end while(temp[31:29] inside {3'b100, 3'b110, 3'b111} && !hdr_fmt_set); //}
    end else begin //} {
      
      m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(packer.unpack_field_int(3));
    end //}

    first_local_prefix_unpacked = 0;
    m_max_no_of_prefixes = prfx_cnt+ m_ide_prefix_present;
    m_max_no_of_local_prefixes = local_prfx_cnt;
    if (is_local_pref_after_pth_err) begin
      //For this error scenario the position of the data fields is swapped.
      //Normal Operation: Local_Prefix[0] -> Local_Prefix [1] -> PBR Header
      //Error Injected: PBR Header -> Local_Prefix[0] -> Local_Prefix[1]
      // We have to unpack the TLP in the same order to prevent scoreboarding issues.
      // If we have 2 local prefixes, we have to swap pbr header field with local_prefix[0],
      // but actual local_prefix[0] must precede local_prefix[1] therefore we swap the data of local_prefix[1] with new pbr_header data

      temp_err_data = m_tlp_local_prefix[0];
      m_tlp_local_prefix[0] = m_tlp_pbr_tlp_header;
      
      if (m_tlp_local_prefix.size()==1)
      m_tlp_pbr_tlp_header = temp_err_data;
      else if (m_tlp_local_prefix.size()>1)begin
        m_tlp_pbr_tlp_header = m_tlp_local_prefix[m_tlp_local_prefix.size()-1]; // PBR Header would take the last prefix value
        m_tlp_local_prefix[1] = temp_err_data;

        for (int i = m_tlp_local_prefix.size()-1; i>1; i--) begin
          m_tlp_local_prefix[i] = m_tlp_local_prefix[i-1];
        end
      end
    end // if (is_local_pref_after_pth_err)
    if (is_cxl_pbr_mode && !pbr_unpacked) // CDN_HPA_PCIE_TLP_PBR_MISSING_PTH_HEADER_ERR
    is_pbr_missing_err = 1; // Flag bit used in packer to guard pbr header packing

    // If received orphan TLP prefix, do not extract other TLP header fields and return from do_unpack
    if(bit_stream_size == 0 && prfx_cnt > 0) begin
      m_orphan_tlp_prefix = 1;
      return;
    end
    // First DW is common for all TLPs
    // Unpack the Type
    `uvm_info(get_type_name(),$sformatf("Unpacking First DW is common for all TLPs"),UVM_DEBUG);
    if (!is_tlp_header_rsvd && !is_posted_tlp_address_routed_header_rsvd) begin
      m_hdr_type = packer.unpack_field_int($bits(m_hdr_type));
      `uvm_info(get_type_name(),$sformatf("m_hdr_type=%0b",m_hdr_type),UVM_DEBUG);
    end else begin
      m_hdr_type = temp[28:24]; // for is_tlp_header_rsvd error, the header related fields are already unpacked
      `uvm_info(get_type_name(),$sformatf("m_hdr_type=%0b",m_hdr_type),UVM_DEBUG);
    end
    casex ({m_hdr_fmt,m_hdr_type})
      8'b0000_0000 : if(!is_flit_mode) m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_MRd_32;
      8'b0000_0011 : if(is_flit_mode) m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_MRd_32;
      8'b0010_0000 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_MRd_64;
      8'b0000_0001 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_MRdLk_32;
      8'b0010_0001 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_MRdLk_64;
      8'b0100_0000 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_MWr_32;
      8'b0110_0000 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_MWr_64;
      8'b0101_1011 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_DMWr_32;
      8'b0111_1011 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_DMWr_64;
      8'b0000_0010 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_IORd;
      8'b0100_0010 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_IOWr;
      8'b0000_0100 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_CfgRd0;
      8'b0100_0100 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_CfgWr0;
      8'b0000_0101 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_CfgRd1;
      8'b0100_0101 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_CfgWr1;
      //8'b0001_1011 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_TCfgRd;
      //8'b0101_1011 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_TCfgWr;
      8'b0011_0??? : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Msg;
      8'b0111_0??? : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_MsgD;
      8'b0000_1010 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Cpl;
      8'b0100_1010 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_CplD;
      8'b0000_1011 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_CplLk;
      8'b0100_1011 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_CplDLk;
      8'b0100_1100 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32;
      8'b0110_1100 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64;
      8'b0100_1101 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Swap_32;
      8'b0110_1101 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Swap_64;
      8'b0100_1110 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Cas_32;
      8'b0110_1110 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Cas_64;
      8'b0000_1100 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl;
      8'b0000_1101 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIORdCpl;
      8'b0010_0010 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIOMRd;
      8'b0100_1000 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIORdCplD;
      8'b0110_0001 : m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIOMWr;
      default      : begin
        //Used in tl_rx module for rsvd type
        assert(std::randomize(m_tlp_type) with {
          m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_Rsvd37:CDN_HPA_PCIE_TLP_TYPE_Rsvd63]};
        });
      end
    endcase

    if({m_hdr_fmt,m_hdr_type} inside {6,7,14,15,24,25,26,40,41,42,43,73,172,173,174,175,202,203,204,205}) begin
      is_cpl_tlp_header_rsvd = 1;
      m_tlp_type          = CDN_HPA_PCIE_TLP_TYPE_CPL_Rsvd;
    end
    if({m_hdr_fmt,m_hdr_type} inside {8,9,88,89,44,45, 46,47,54,55,92,93, 94,95, 65,67, 206,207,118,119}) begin
      is_posted_tlp_id_routed_header_rsvd = 1;
      m_tlp_req_type      = CDN_HPA_PCIE_TRANS_POSTED_REQ;
      m_tlp_type          = CDN_HPA_PCIE_TLP_TYPE_P_Rsvd;
      m_tlp_trans_type    = CDN_HPA_PCIE_TRANS_RSVD_TYPE;
      m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_OTHER;
    end
    if({m_hdr_fmt,m_hdr_type} inside {79,[144:147], [148:151], [152:155],168,169, [156:159],170,171,90,[98:99],[100:103],[104:107], [176:183],[184:191], [208:215],[216:223], [248:255]}) begin
      //is_posted_tlp_address_routed_header_rsvd = 1;
      m_tlp_req_type      = CDN_HPA_PCIE_TRANS_POSTED_REQ;
      m_tlp_type          = CDN_HPA_PCIE_TLP_TYPE_P_Rsvd;
      m_tlp_trans_type    = CDN_HPA_PCIE_TRANS_RSVD_TYPE;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_ADDR;
      m_tlp_addr_type     = CDN_HPA_PCIE_ADDR_64;
    end
    if({m_hdr_fmt,m_hdr_type} inside {28,29,70,71,60,61, 62,63, 30,31, 200,201,240,241,242,243,244,245,246,247}) begin
      is_nonposted_tlp_id_routed_header_rsvd = 1;
      m_tlp_req_type      = CDN_HPA_PCIE_TRANS_NON_POSTED_REQ;
      m_tlp_type          = CDN_HPA_PCIE_TLP_TYPE_NP_Rsvd;
      m_tlp_trans_type    = CDN_HPA_PCIE_TRANS_RSVD_TYPE;
      m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_OTHER;
    end
    if({m_hdr_fmt,m_hdr_type} inside {35,[36:39],[56:59],[160:167],[192:199],[232:239],111,120,121,122,[124:127], [16:19],[20:21], [80:83],84,85, 22,23,86,87}) begin
      is_nonposted_tlp_address_routed_header_rsvd = 1;
      m_tlp_req_type      = CDN_HPA_PCIE_TRANS_NON_POSTED_REQ;
      m_tlp_type          = CDN_HPA_PCIE_TLP_TYPE_NP_Rsvd;
      m_tlp_trans_type    = CDN_HPA_PCIE_TRANS_RSVD_TYPE;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_ADDR;
      m_tlp_addr_type     = CDN_HPA_PCIE_ADDR_64;
    end
    if({m_hdr_fmt,m_hdr_type} inside {[224:227]}) begin
      m_tlp_req_type      = CDN_HPA_PCIE_TRANS_POSTED_REQ;
      m_tlp_type          = CDN_HPA_PCIE_TLP_TYPE_NONE_Rsvd;
      m_tlp_trans_type    = CDN_HPA_PCIE_TRANS_RSVD_TYPE;
      m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_OTHER;
    end
    if({m_hdr_fmt,m_hdr_type} inside {[228:231]}) begin
      m_tlp_req_type      = CDN_HPA_PCIE_TRANS_POSTED_REQ;
      m_tlp_type          = CDN_HPA_PCIE_TLP_TYPE_NONE_Rsvd;
      m_tlp_trans_type    = CDN_HPA_PCIE_TRANS_RSVD_TYPE;
      m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;
      m_tlp_rout_type     = CDN_HPA_PCIE_TLP_ROUT_BY_OTHER;
    end
    //
    //if tlp is rsvd type we are not unpacking and exiting from this function
    if(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_Rsvd37:CDN_HPA_PCIE_TLP_TYPE_Rsvd63]} && !is_tlp_header_rsvd && !is_cpl_tlp_header_rsvd) // for is_tlp_header_rsvd, unpack the rest of the TLP
    return;

    case (m_tlp_type) inside
      CDN_HPA_PCIE_TLP_TYPE_MRd_32, CDN_HPA_PCIE_TLP_TYPE_MRd_64, CDN_HPA_PCIE_TLP_TYPE_MRdLk_32, CDN_HPA_PCIE_TLP_TYPE_MRdLk_64, CDN_HPA_PCIE_TLP_TYPE_MWr_32,
      CDN_HPA_PCIE_TLP_TYPE_MWr_64, CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32, CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64, CDN_HPA_PCIE_TLP_TYPE_Swap_32,
      CDN_HPA_PCIE_TLP_TYPE_Swap_64, CDN_HPA_PCIE_TLP_TYPE_Cas_32, CDN_HPA_PCIE_TLP_TYPE_Cas_64, CDN_HPA_PCIE_TLP_TYPE_DMWr_32, CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
      CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr : m_tlp_trans_type = CDN_HPA_PCIE_TRANS_MEM_TYPE;

      CDN_HPA_PCIE_TLP_TYPE_IORd, CDN_HPA_PCIE_TLP_TYPE_IOWr : m_tlp_trans_type = CDN_HPA_PCIE_TRANS_IO_TYPE;

      CDN_HPA_PCIE_TLP_TYPE_CfgRd0, CDN_HPA_PCIE_TLP_TYPE_CfgRd1,
      CDN_HPA_PCIE_TLP_TYPE_CfgWr0, CDN_HPA_PCIE_TLP_TYPE_CfgWr1 : m_tlp_trans_type = CDN_HPA_PCIE_TRANS_CFG_TYPE;

      CDN_HPA_PCIE_TLP_TYPE_Msg, CDN_HPA_PCIE_TLP_TYPE_MsgD : m_tlp_trans_type = CDN_HPA_PCIE_TRANS_MSG_TYPE;

      CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD,
      CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk,
      CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl,
      CDN_HPA_PCIE_TLP_TYPE_UIORdCplD : m_tlp_trans_type = CDN_HPA_PCIE_TRANS_CPL_TYPE;
    endcase

    case (m_tlp_type) inside
      CDN_HPA_PCIE_TLP_TYPE_MWr_32, CDN_HPA_PCIE_TLP_TYPE_MWr_64,
      CDN_HPA_PCIE_TLP_TYPE_Msg, CDN_HPA_PCIE_TLP_TYPE_MsgD,
      CDN_HPA_PCIE_TLP_TYPE_UIOMWr : m_tlp_req_type = CDN_HPA_PCIE_TRANS_POSTED_REQ;

      CDN_HPA_PCIE_TLP_TYPE_CfgRd0, CDN_HPA_PCIE_TLP_TYPE_CfgRd1,
      CDN_HPA_PCIE_TLP_TYPE_CfgWr0, CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
      CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32, CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64, CDN_HPA_PCIE_TLP_TYPE_Swap_32,
      CDN_HPA_PCIE_TLP_TYPE_Swap_64, CDN_HPA_PCIE_TLP_TYPE_Cas_32, CDN_HPA_PCIE_TLP_TYPE_Cas_64,
      CDN_HPA_PCIE_TLP_TYPE_IORd, CDN_HPA_PCIE_TLP_TYPE_IOWr, CDN_HPA_PCIE_TLP_TYPE_MRd_32,
      CDN_HPA_PCIE_TLP_TYPE_MRd_64, CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,
      CDN_HPA_PCIE_TLP_TYPE_DMWr_32, CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
      CDN_HPA_PCIE_TLP_TYPE_MRdLk_64, CDN_HPA_PCIE_TLP_TYPE_UIOMRd : m_tlp_req_type = CDN_HPA_PCIE_TRANS_NON_POSTED_REQ;

      CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD,
      CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk,
      CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl,
      CDN_HPA_PCIE_TLP_TYPE_UIORdCplD : m_tlp_req_type = CDN_HPA_PCIE_TRANS_COMPLETION;
    endcase

    if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) begin //{
      if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd0, CDN_HPA_PCIE_TLP_TYPE_CfgRd1,
      CDN_HPA_PCIE_TLP_TYPE_IORd, CDN_HPA_PCIE_TLP_TYPE_MRd_32,
      CDN_HPA_PCIE_TLP_TYPE_MRd_64, CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,
      CDN_HPA_PCIE_TLP_TYPE_MRdLk_64, CDN_HPA_PCIE_TLP_TYPE_UIOMRd}) m_tlp_np_req_type = CDN_HPA_PCIE_READ_REQ;
      if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgWr0, CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
      CDN_HPA_PCIE_TLP_TYPE_IOWr, CDN_HPA_PCIE_TLP_TYPE_DMWr_32,
      CDN_HPA_PCIE_TLP_TYPE_DMWr_64, CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,
      CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64, CDN_HPA_PCIE_TLP_TYPE_Swap_32,
      CDN_HPA_PCIE_TLP_TYPE_Swap_64, CDN_HPA_PCIE_TLP_TYPE_Cas_32,
      CDN_HPA_PCIE_TLP_TYPE_Cas_64}) m_tlp_np_req_type = CDN_HPA_PCIE_NPR_WITH_DATA;
    end //}

    if({m_hdr_fmt,m_hdr_type} inside {6,7,14,15,24,25,26,40,41,42,43,73,172,173,174,175,202,203,204,205}) begin
      m_tlp_trans_type = CDN_HPA_PCIE_TRANS_CPL_TYPE;
      m_tlp_req_type = CDN_HPA_PCIE_TRANS_COMPLETION;
    end

    if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) begin //{
      if(m_tlp_type inside {
        CDN_HPA_PCIE_TLP_TYPE_MWr_64,
        CDN_HPA_PCIE_TLP_TYPE_MRd_64,
        CDN_HPA_PCIE_TLP_TYPE_MRdLk_64,
        CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
        CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
        CDN_HPA_PCIE_TLP_TYPE_Swap_64,
        CDN_HPA_PCIE_TLP_TYPE_Cas_64,
        CDN_HPA_PCIE_TLP_TYPE_UIOMRd,
        CDN_HPA_PCIE_TLP_TYPE_UIOMWr
      }) m_tlp_addr_type = CDN_HPA_PCIE_ADDR_64;
      else  m_tlp_addr_type = CDN_HPA_PCIE_ADDR_32;
    end //}

    if({m_hdr_fmt,m_hdr_type} inside {/*completion*/ 6,7,26,73,202,203,204,205, 
                                      /*Posted*/ 88,89,90,92,93,[98:99],[100:103],[104:107], 94,95,[176:183],[184:191], 65,67,[208:215],[216:223], 206,207,[248:255],118,119,
                                      /*NonPosted*/ 70,71,111,120,121,122,[124:127],240,241, [16:19],[20:21],242,243, [80:83],84,85,244,245, 22,23,86,87,246,247, 
                                      /*None*/ 228,229,230,231 }) begin
      rsvd_with_payload = 1;
    end
    if(is_flit_mode) begin
      //Completion
      if({m_hdr_fmt,m_hdr_type} inside {6,7})         num_of_header_dw = 4;
      if({m_hdr_fmt,m_hdr_type} inside {26})          num_of_header_dw = 7;
      if({m_hdr_fmt,m_hdr_type} inside {202,203})     num_of_header_dw = 5;
      if({m_hdr_fmt,m_hdr_type} inside {204,205})     num_of_header_dw = 6;
      if({m_hdr_fmt,m_hdr_type} inside {14,15})       num_of_header_dw = 3;
      if({m_hdr_fmt,m_hdr_type} inside {24,25})       num_of_header_dw = 7;
      if({m_hdr_fmt,m_hdr_type} inside {40,41,42,43}) num_of_header_dw = 4;
      if({m_hdr_fmt,m_hdr_type} inside {172,173})     num_of_header_dw = 5;
      if({m_hdr_fmt,m_hdr_type} inside {174,175})     num_of_header_dw = 6;

      //Posted
      if({m_hdr_fmt,m_hdr_type} inside {8,9,88,89}) num_of_header_dw = 3;
      if({m_hdr_fmt,m_hdr_type} inside {44,45,54,55,92,93,118,119,79,[144:147],90,[98:99],[100:103],[104:107]}) num_of_header_dw = 4;
      if({m_hdr_fmt,m_hdr_type} inside {46,47,94,95,[148:151],[176:183],[184:191]}) num_of_header_dw = 5;
      if({m_hdr_fmt,m_hdr_type} inside {65,67,[152:155],168,169,[208:215],[216:223]})  num_of_header_dw = 6;
      if({m_hdr_fmt,m_hdr_type} inside {206,207,[156:159],170,171,[248:255]})          num_of_header_dw = 7;

      //NonPosted
      if({m_hdr_fmt,m_hdr_type} inside {28,29,70,71}) num_of_header_dw = 3;
      if({m_hdr_fmt,m_hdr_type} inside {60,61,240,241,35,[36:39],[56:59],111,120,121,122,[124:127]}) num_of_header_dw = 4;
      if({m_hdr_fmt,m_hdr_type} inside {62,63,[160:167],[16:19],[20:21],242,243}) num_of_header_dw = 5;
      if({m_hdr_fmt,m_hdr_type} inside {30,31,[192:199],[80:83],84,85,244,245})   num_of_header_dw = 6;
      if({m_hdr_fmt,m_hdr_type} inside {200,201,[232:239],22,23,86,87,246,247})   num_of_header_dw = 7;

      //None
      if({m_hdr_fmt,m_hdr_type} inside {224,225}) num_of_header_dw = 4;
      if({m_hdr_fmt,m_hdr_type} inside {226,227}) num_of_header_dw = 6;
      if({m_hdr_fmt,m_hdr_type} inside {228,229}) num_of_header_dw = 4;
      if({m_hdr_fmt,m_hdr_type} inside {230,231}) num_of_header_dw = 6;
    end    

    // msg request
    if (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg || m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) begin //{
      case (m_hdr_type[2:0])
        3'b000 : m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC;
        3'b001 : m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ADDR;
        3'b010 : m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID;
        3'b011 : m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_BROADCAST_FROM_RC;
        3'b100 : m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;
        3'b101 : m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_GATHER_TO_RC;
        3'b110 : m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_RSVD6;
        3'b111 : m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_RSVD7;
      endcase
      m_hdr_type[2:0] = m_tlp_msg_rout_type;
    end //}
    if(is_flit_mode) begin //{
      if (!is_tlp_header_rsvd && !is_posted_tlp_address_routed_header_rsvd) begin
        m_tlp_tc = packer.unpack_field_int($bits(m_tlp_tc));
        m_ohc_hdr= packer.unpack_field_int($bits(m_ohc_hdr));
        m_ts = cdn_hpa_pcie_ts_type_t'(packer.unpack_field_int($bits(m_ts)));
        if(m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER)
        m_tlp_td = 1;
        m_tlp_attr1 = packer.unpack_field_int($bits(m_tlp_attr1));
        m_tlp_attr0 = packer.unpack_field_int($bits(m_tlp_attr0));
        m_tlp_length = packer.unpack_field_int($bits(m_tlp_length));
        `uvm_info(get_type_name(),$sformatf("m_ohc_hdr=%0h",m_ohc_hdr),UVM_DEBUG);
      end
      else begin // if is_tlp_header_rsvd, the header related fields are already unpacked
        m_tlp_tc = temp[23:21];
        m_ohc_hdr= temp[20:16];
        m_ts = cdn_hpa_pcie_ts_type_t'(temp[15:13]);
        if(m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER)
        m_tlp_td = 1;
        m_tlp_attr1 = temp[12];
        m_tlp_attr0 = temp[11:10];
        m_tlp_length = temp[9:0];
        `uvm_info(get_type_name(),$sformatf("m_ohc_hdr=%0h",m_ohc_hdr),UVM_DEBUG);
      end
    end else begin //}{
      m_tlp_t9 = packer.unpack_field_int($bits(m_tlp_t9));
      m_tlp_tc = packer.unpack_field_int($bits(m_tlp_tc));
      m_tlp_t8 = packer.unpack_field_int($bits(m_tlp_t8));
      m_tlp_attr1 = packer.unpack_field_int($bits(m_tlp_attr1));
      m_tlp_ln = packer.unpack_field_int($bits(m_tlp_ln));
      m_tlp_th = packer.unpack_field_int($bits(m_tlp_th));
      m_tlp_td = packer.unpack_field_int($bits(m_tlp_td));
      m_tlp_ep = packer.unpack_field_int($bits(m_tlp_ep));
      m_tlp_attr0 = packer.unpack_field_int($bits(m_tlp_attr0));
      `uvm_unpack_enumN(m_tlp_at_type, $bits(m_tlp_at_type), cdn_hpa_pcie_tlp_at_type_t);
      m_tlp_length = packer.unpack_field_int($bits(m_tlp_length));
      m_tlp_tagscale = {m_tlp_t9, m_tlp_t8};
    end //}
    // The below Header words change based on TLP Type
    // Second DW
    `uvm_info(get_type_name(),$sformatf("Unpacking Second DW is common for all TLPs"),UVM_DEBUG);
    if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE,CDN_HPA_PCIE_TRANS_MSG_TYPE,CDN_HPA_PCIE_TRANS_RSVD_TYPE}) begin //{
      m_tlp_requester_id.bus_num = packer.unpack_field_int($bits(m_tlp_requester_id.bus_num));
      m_tlp_requester_id.device_num = packer.unpack_field_int($bits(m_tlp_requester_id.device_num));
      m_tlp_requester_id.function_num = packer.unpack_field_int( $bits(m_tlp_requester_id.function_num));
      if(is_flit_mode) begin //{
        temp_dw=32'h0000_0000;
        temp_dw[15:0] = packer.unpack_field_int(16);
        if((m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE}) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_RSVD_TYPE) && ((m_tlp_req_type==CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) || (m_tlp_rout_type == CDN_HPA_PCIE_TLP_ROUT_BY_ADDR)))) begin //{
          m_tlp_ep = temp_dw[15];
          second_dw_byte_6_field_6_rsvd = temp_dw[14];
          m_tlp_14_bit_tagscale = temp_dw[13:10];
          m_tlp_t9 = temp_dw[9];
          m_tlp_t8 = temp_dw[8];
          m_tlp_tag = temp_dw[7:0];
        end else begin //}{Msg
          m_tlp_msg_code = cdn_hpa_pcie_tlp_msg_type_t'(temp_dw[7:0]);
          if(m_tlp_msg_code!=CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
            m_tlp_ep = temp_dw[15];
            if(pcie_6_1_support && m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1})) begin
              vendor_definition_vd_msg = temp_dw[14:8];
            end else if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_IDE_Escort)) begin
              m_tlp_ep = temp_dw[15];
              msg_ide_escort_byte_6_field_6_2 = temp_dw[14:10];
              msg_ide_escort_sse = temp_dw[9:8];
            end else begin
              second_dw_byte_6_msg_rsvd = temp_dw[14:8];
            end
          end else begin //INV Req
            m_tlp_ep = temp_dw[15];
            msg_inv_req_byte_6_field_6_5_rsvd = temp_dw[14:13];
            m_tlp_itag= temp_dw[12:8];
          end
        end //}
      end else begin //}{
//Tag assignment
        if(((m_tlp_trans_type==CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate))) begin //{INV_REQ
          msg_inv_req_byte_6_field_7_rsvd_nfm = temp_dw[7];
          msg_inv_req_byte_6_field_6_5_rsvd = temp_dw[6:5];
          m_tlp_itag= temp_dw[4:0];
        end else if(pcie_6_1_support && m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1})) begin //VD_MSG
          vendor_definition_vd_msg_rsvd_bit = temp_dw[7];
          vendor_definition_vd_msg = temp_dw[6:0];
        end else if(m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin
          msg_ide_escort_byte_6_field_6_2 = temp_dw[6:2];
          msg_ide_escort_sse = temp_dw[1:0];
        end else begin //othermsgs } {
          m_tlp_tag = temp_dw[7:0];
        end //}
        if((m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) && (m_tlp_th==1)) m_tlp_st_tag[7:0]=m_tlp_tag;

      end //}
    end //}

    if ((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD, CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk}) || is_cpl_tlp_header_rsvd) begin
      m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
      m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
      m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
      if(is_flit_mode) begin //{
        m_tlp_ep = packer.unpack_field_int($bits(m_tlp_ep));
        m_tlp_cpl_lower_addr[6] = packer.unpack_field_int(1);
        m_tlp_14_bit_tagscale = packer.unpack_field_int($bits(m_tlp_14_bit_tagscale));
        m_tlp_t9 = packer.unpack_field_int($bits(m_tlp_t9));
        m_tlp_t8 = packer.unpack_field_int($bits(m_tlp_t8));
        m_tlp_tag = packer.unpack_field_int($bits(m_tlp_tag));
      end else begin  //}{
        `uvm_unpack_enumN(m_tlp_cpl_status, $bits(m_tlp_cpl_status), cdn_hpa_pcie_cpl_status_type_t);
        m_tlp_cpl_bcm = packer.unpack_field_int( $bits(m_tlp_cpl_bcm));
        m_tlp_cpl_byte_cnt= packer.unpack_field_int( $bits(m_tlp_cpl_byte_cnt));
      end //}
    end

    if (is_flit_mode && m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) begin
      m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
      m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
      m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
      m_tlp_ep = packer.unpack_field_int($bits(m_tlp_ep));
      if (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD) begin
        m_tlp_cpl_lower_addr[6] = packer.unpack_field_int(1);
      end
      else begin
        second_dw_byte_6_field_6_rsvd  = packer.unpack_field_int(1);
      end
      m_tlp_14_bit_tagscale = packer.unpack_field_int($bits(m_tlp_14_bit_tagscale));
      m_tlp_t9 = packer.unpack_field_int($bits(m_tlp_t9));
      m_tlp_t8 = packer.unpack_field_int($bits(m_tlp_t8));
      m_tlp_tag = packer.unpack_field_int($bits(m_tlp_tag));
    end

    m_tlp_tagscale = {m_tlp_t9, m_tlp_t8};
    // Third & Fourth DWs
    `uvm_info(get_type_name(),$sformatf("Unpacking Third & Fourth DW is common for all TLPs"),UVM_DEBUG);
    if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_RSVD_TYPE}) begin
      if(m_tlp_rout_type==CDN_HPA_PCIE_TLP_ROUT_BY_ADDR) begin
        if((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_64))
          m_tlp_addr[63:32] = packer.unpack_field_int(32);
        m_tlp_addr[31:4] = packer.unpack_field_int(28);
        if(is_flit_mode) begin //{
          temp_4th_dw=32'h0000_0000;
          temp_4th_dw[3:0] = packer.unpack_field_int(4);
          m_tlp_at_type = cdn_hpa_pcie_tlp_at_type_t'(temp_4th_dw[1:0]);
          if(cxl_mode && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            m_cxl_src = temp_4th_dw[3];
          end else begin
            m_tlp_addr[3:2] = temp_4th_dw[3:2];
          end
        end else begin //}{
          if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            temp_4th_dw=32'h0000_0000;
            if(cxl_mode) begin
              m_cxl_src = packer.unpack_field_int(1);
              temp_4th_dw[1:0] = packer.unpack_field_int(2);
            end else begin
              m_tlp_addr[3:2] = packer.unpack_field_int(2);
              temp_4th_dw[0] = packer.unpack_field_int(1);
            end
            m_tlp_ats_tr_nw_field =  packer.unpack_field_int(1);
          end else begin
            m_tlp_addr[3:2] = packer.unpack_field_int(2);
            m_tlp_ph =  packer.unpack_field_int(2);
          end
        end //}
      end
      if (m_tlp_rout_type==CDN_HPA_PCIE_TLP_ROUT_BY_OTHER) begin //{
        m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
        m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
        m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
        msg_cmn_byte_8_15_rsvd[23:16] = packer.unpack_field_int(8);
        msg_cmn_byte_8_15_rsvd[31:24] = packer.unpack_field_int(8);
        if(num_of_header_dw >= 4) begin
          msg_cmn_byte_8_15_rsvd[39:32] = packer.unpack_field_int(8);
          msg_cmn_byte_8_15_rsvd[47:40] = packer.unpack_field_int(8);
          msg_cmn_byte_8_15_rsvd[55:48] = packer.unpack_field_int(8);
          msg_cmn_byte_8_15_rsvd[63:56] = packer.unpack_field_int(8);
        end
      end
    end
    case(m_tlp_trans_type) inside
      CDN_HPA_PCIE_TRANS_MEM_TYPE: begin
        if((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_64))
        m_tlp_addr[63:32] = packer.unpack_field_int(32);
        m_tlp_addr[31:4] = packer.unpack_field_int(28);
        if(is_flit_mode) begin //{
          temp_4th_dw=32'h0000_0000;
          temp_4th_dw[3:0] = packer.unpack_field_int(4);
          m_tlp_at_type = cdn_hpa_pcie_tlp_at_type_t'(temp_4th_dw[1:0]);
          if(cxl_mode && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            m_cxl_src = temp_4th_dw[3];
          end else begin
            m_tlp_addr[3:2] = temp_4th_dw[3:2];
          end
        end else begin //}{
          if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            temp_4th_dw=32'h0000_0000;
            if(cxl_mode) begin
              m_cxl_src = packer.unpack_field_int(1);
              temp_4th_dw[1:0] = packer.unpack_field_int(2);
            end else begin
              m_tlp_addr[3:2] = packer.unpack_field_int(2);
              temp_4th_dw[0] = packer.unpack_field_int(1);
            end
            m_tlp_ats_tr_nw_field =  packer.unpack_field_int(1);
          end else begin
            m_tlp_addr[3:2] = packer.unpack_field_int(2);
            m_tlp_ph =  packer.unpack_field_int(2);
          end
        end //}
      end
      CDN_HPA_PCIE_TRANS_IO_TYPE : begin
        m_tlp_addr[31:2] = packer.unpack_field_int(30);
        io_byte_11_rsvd_field_1_0 =  packer.unpack_field_int(2);
      end
      CDN_HPA_PCIE_TRANS_CFG_TYPE : begin
        m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
        m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
        m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
        cfg_byte_10_rsvd_field_7_4 = packer.unpack_field_int($bits(cfg_byte_10_rsvd_field_7_4));
        m_tlp_ext_reg_num = packer.unpack_field_int($bits(m_tlp_ext_reg_num));
        m_tlp_reg_num = packer.unpack_field_int($bits(m_tlp_reg_num));
      end
    endcase

    // Cpl
    if ((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD, CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk}) || is_cpl_tlp_header_rsvd) begin
      m_tlp_requester_id.bus_num = packer.unpack_field_int($bits(m_tlp_requester_id.bus_num));
      m_tlp_requester_id.device_num = packer.unpack_field_int($bits(m_tlp_requester_id.device_num));
      m_tlp_requester_id.function_num = packer.unpack_field_int( $bits(m_tlp_requester_id.function_num));
      if(is_flit_mode) begin //{
        //m_completion_segment_differ = packer.unpack_field_int( $bits(m_completion_segment_differ));
        m_tlp_cpl_lower_addr[5:2] = packer.unpack_field_int(4);
        m_tlp_cpl_byte_cnt = packer.unpack_field_int( $bits(m_tlp_cpl_byte_cnt));
      end else begin //}{
        m_tlp_tag = packer.unpack_field_int($bits(m_tlp_tag));
        cpl_byte_12_rsvd_field_7 = packer.unpack_field_int($bits(cpl_byte_12_rsvd_field_7));
        m_tlp_cpl_lower_addr[6:0] = packer.unpack_field_int(7);
      end //}
    end

    // Cpl UIO
    if (is_flit_mode && m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) begin
      m_tlp_requester_id.bus_num = packer.unpack_field_int($bits(m_tlp_requester_id.bus_num));
      m_tlp_requester_id.device_num = packer.unpack_field_int($bits(m_tlp_requester_id.device_num));
      m_tlp_requester_id.function_num = packer.unpack_field_int( $bits(m_tlp_requester_id.function_num));
      if (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD) begin
        m_tlp_cpl_lower_addr[5:2] = packer.unpack_field_int(4);
        cpl_byte_11_rsvd_field_3_0 = packer.unpack_field_int($bits(cpl_byte_11_rsvd_field_3_0));
        cpl_byte_12_rsvd_field_7 = packer.unpack_field_int($bits(cpl_byte_12_rsvd_field_7));
        m_tlp_cpl_cdl = packer.unpack_field_int($bits(m_tlp_cpl_cdl));
        m_tlp_cpl_lower_addr[11:7] = packer.unpack_field_int(5);
      end
      else begin
        cpl_byte_11_rsvd_field_7_4 = packer.unpack_field_int($bits(cpl_byte_11_rsvd_field_7_4));
        cpl_byte_11_rsvd_field_3_0 = packer.unpack_field_int($bits(cpl_byte_11_rsvd_field_3_0));
        cpl_byte_12_rsvd_field_7 = packer.unpack_field_int($bits(cpl_byte_12_rsvd_field_7));
        m_tlp_cpl_cdl = packer.unpack_field_int($bits(m_tlp_cpl_cdl));
        cpl_byte_12_rsvd_field_4_0 = packer.unpack_field_int($bits(cpl_byte_12_rsvd_field_4_0));
      end
    end

    //Msgs
    if(is_flit_mode && (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE)) begin //{
      temp_3rd_dw = 32'd0;
      temp_4th_dw = 32'd0;
      temp_3rd_dw[31:0] = packer.unpack_field_int(32);
      temp_4th_dw[31:0] = packer.unpack_field_int(32);
    end else begin //}{
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) begin //{
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin //{
          temp = 32'd0;
          temp[15:0] = packer.unpack_field_int(16);
          m_tlp_vendor_id = packer.unpack_field_int($bits(m_tlp_vendor_id));
          m_tlp_vendor_msg = packer.unpack_field_int($bits(m_tlp_vendor_msg));
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && (m_tlp_vendor_msg[31:24] inside {8'b0000_0000, 8'b0000_1000,8'b0000_1001,8'b0000_0001})) m_tlp_vdm_msg_subtype = cdn_hpa_pcie_tlp_vdm_msg_sub_type_t'(m_tlp_vendor_msg[31:24]);
          else if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1})
          m_tlp_vdm_msg_subtype = CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1;
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}) begin //{
            msg_frs_byte_13_15_rsvd =  m_tlp_vendor_msg[23:4];
            m_tlp_frs_msg_reason = cdn_hpa_pcie_frs_msg_reason_t'(m_tlp_vendor_msg[3:0]);
          end //}
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_DRS}) begin //{
            msg_ln_drs_byte_13_15_rsvd = m_tlp_vendor_msg[23:0];
          end //}
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_HIER_ID}) begin //{
            m_tlp_hier_vmsg_system_guid[143:128] = m_tlp_vendor_msg[15:0];
            m_tlp_hier_vmsg_guid_authority_id = m_tlp_vendor_msg[23:16];
          end //}

          if((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type0) || ((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type1)&&(m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_HIER_ID))) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp[15:0] ;
          end else begin //}{
            m_tlp_hier_vmsg_hierarchy_id = temp[15:0];
          end //}
        end else if (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin//} {
          m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
          m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
          m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
          msg_inv_req_byte_10_15_rsvd = packer.unpack_field_int($bits(msg_inv_req_byte_10_15_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin //}{
          m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
          m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
          m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
          msg_inv_cpl_byte_10_11_rsvd = packer.unpack_field_int($bits(msg_inv_cpl_byte_10_11_rsvd));
          m_inv_cpl_cnt = packer.unpack_field_int($bits(m_inv_cpl_cnt));
          m_tlp_itag_vector = packer.unpack_field_int($bits(m_tlp_itag_vector));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
            m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
            m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
            msg_ltr_byte_8_11_rsvd[23:16] = packer.unpack_field_int(8);
            msg_ltr_byte_8_11_rsvd[31:24] = packer.unpack_field_int(8);
          end else begin //}{
            msg_ltr_byte_8_11_rsvd = packer.unpack_field_int($bits(msg_ltr_byte_8_11_rsvd));
          end //}
          m_tlp_ltr_msg_no_snoop_latency = packer.unpack_field_int($bits(m_tlp_ltr_msg_no_snoop_latency));
          m_tlp_ltr_msg_snoop_latency = packer.unpack_field_int($bits(m_tlp_ltr_msg_snoop_latency));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Request) begin //}{
          m_page_addr = packer.unpack_field_int($bits(m_page_addr));
          m_prGroupIndex = packer.unpack_field_int($bits(m_prGroupIndex));
          m_prLastRequest = packer.unpack_field_int($bits(m_prLastRequest));
          m_prWriteRequested = packer.unpack_field_int($bits(m_prWriteRequested));
          m_prReadRequested = packer.unpack_field_int($bits(m_prReadRequested));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Group_Response) begin //}{
          m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
          m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
          m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
          m_prgResponseCode = packer.unpack_field_int($bits(m_prgResponseCode));
          msg_pr_rsp_byte_10_field_3_1_rsvd = packer.unpack_field_int($bits(msg_pr_rsp_byte_10_field_3_1_rsvd));
          m_prGroupIndex = packer.unpack_field_int($bits(m_prGroupIndex));
          msg_pr_rsp_byte_12_15_rsvd = packer.unpack_field_int($bits(msg_pr_rsp_byte_12_15_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
            m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
            m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
            msg_obff_byte_8_14_rsvd[23:16] = packer.unpack_field_int(8);
            msg_obff_byte_8_14_rsvd[31:24] = packer.unpack_field_int(8);
            msg_obff_byte_8_14_rsvd[39:32] = packer.unpack_field_int(8);
            msg_obff_byte_8_14_rsvd[47:40] = packer.unpack_field_int(8);
            msg_obff_byte_8_14_rsvd[55:48] = packer.unpack_field_int(8);
            msg_obff_byte_8_14_rsvd[59:56] = packer.unpack_field_int(4);
          end else begin //}{
            msg_obff_byte_8_14_rsvd = packer.unpack_field_int($bits(msg_obff_byte_8_14_rsvd));
          end //}
          m_obffCode = cdn_hpa_pcie_ObffCode_t'(packer.unpack_field_int($bits(m_obffCode)));
        end else if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code== CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD)) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
            m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
            m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
            m_ptmMasterTime[23:16] = packer.unpack_field_int(8);
            m_ptmMasterTime[31:24] = packer.unpack_field_int(8);
          end else begin //}{
            m_ptmMasterTime = packer.unpack_field_int($bits(m_ptmMasterTime));
          end //}
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Sync) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
            m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
            m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
            msg_ide_sync_byte_8_11_rsvd[23:16] = packer.unpack_field_int(8);
            msg_ide_sync_byte_8_11_rsvd[31:24] = packer.unpack_field_int(8);
          end else begin //}{
            msg_ide_sync_byte_8_11_rsvd = packer.unpack_field_int($bits(msg_ide_sync_byte_8_11_rsvd));
          end //}
          msg_ide_sync_byte_12_rsvd = packer.unpack_field_int(8);
          msg_ide_sync_pr_sent_cnt_cpl = packer.unpack_field_int($bits(msg_ide_sync_pr_sent_cnt_cpl));
          msg_ide_sync_byte_14_rsvd = packer.unpack_field_int(8);
          msg_ide_sync_pr_sent_cnt_np = packer.unpack_field_int($bits(msg_ide_sync_pr_sent_cnt_np));
        end else if(m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
            m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
            m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
            msg_ide_sync_byte_8_11_rsvd[23:16] = packer.unpack_field_int(8);
            msg_ide_sync_byte_8_11_rsvd[31:24] = packer.unpack_field_int(8);
          end else begin //}{
            msg_ide_sync_byte_8_11_rsvd = packer.unpack_field_int($bits(msg_ide_sync_byte_8_11_rsvd));
          end //}
          msg_ide_fail_byte_12_15_rsvd = packer.unpack_field_int($bits(msg_ide_fail_byte_12_15_rsvd));
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Fail) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
            m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
            m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
          end else begin //}{
            msg_ide_fail_byte_8_9_rsvd = packer.unpack_field_int($bits(msg_ide_fail_byte_8_9_rsvd));
          end //}
          msg_ide_fail_byte_10_rsvd = packer.unpack_field_int($bits(msg_ide_fail_byte_10_rsvd));
          msg_ide_fail_stream_id = packer.unpack_field_int($bits(msg_ide_fail_stream_id));
          msg_ide_fail_byte_12_15_rsvd = packer.unpack_field_int($bits(msg_ide_fail_byte_12_15_rsvd));
        end else begin //3rd & 4th DW are Rsvd for other messages }{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            m_tlp_completer_id.bus_num = packer.unpack_field_int($bits(m_tlp_completer_id.bus_num));
            m_tlp_completer_id.device_num = packer.unpack_field_int($bits(m_tlp_completer_id.device_num));
            m_tlp_completer_id.function_num = packer.unpack_field_int( $bits(m_tlp_completer_id.function_num));
            msg_cmn_byte_8_15_rsvd[23:16] = packer.unpack_field_int(8);
            msg_cmn_byte_8_15_rsvd[31:24] = packer.unpack_field_int(8);
            msg_cmn_byte_8_15_rsvd[39:32] = packer.unpack_field_int(8);
            msg_cmn_byte_8_15_rsvd[47:40] = packer.unpack_field_int(8);
            msg_cmn_byte_8_15_rsvd[55:48] = packer.unpack_field_int(8);
            msg_cmn_byte_8_15_rsvd[63:56] = packer.unpack_field_int(8);
          end else begin //}{
            msg_cmn_byte_8_15_rsvd = packer.unpack_field_int($bits(msg_cmn_byte_8_15_rsvd));
          end //}
        end //}
      end //}
    end //}

    if(is_flit_mode) begin
      if ((num_of_header_dw >= 4) && (is_cpl_tlp_header_rsvd)) begin
        rsvd_4th_dw = packer.unpack_field_int(32);
        `uvm_info(get_type_name(),$sformatf("rsvd_4th_dw=%0h",rsvd_4th_dw),UVM_DEBUG);
      end
      if (num_of_header_dw >= 5) begin
        rsvd_5th_dw = packer.unpack_field_int(32);
        `uvm_info(get_type_name(),$sformatf("rsvd_5th_dw=%0h",rsvd_5th_dw),UVM_DEBUG);
      end
      if (num_of_header_dw >= 6) begin
        rsvd_6th_dw = packer.unpack_field_int(32);
        `uvm_info(get_type_name(),$sformatf("rsvd_6th_dw=%0h",rsvd_6th_dw),UVM_DEBUG);
      end
      if (num_of_header_dw >= 7) begin
        rsvd_7th_dw = packer.unpack_field_int(32);
        `uvm_info(get_type_name(),$sformatf("rsvd_7th_dw=%0h",rsvd_7th_dw),UVM_DEBUG);
      end
      if (num_of_header_dw >= 8) begin
        rsvd_8th_dw = packer.unpack_field_int(32);
        `uvm_info(get_type_name(),$sformatf("rsvd_8th_dw=%0h",rsvd_8th_dw),UVM_DEBUG);
      end
    end

    `uvm_info(get_type_name(),$sformatf("m_tlp_trans_type=%0s",m_tlp_trans_type.name()),UVM_DEBUG);
    //Unpack OHC incase of flit mode
    if(is_flit_mode) begin
      if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE} && !m_ohc_hdr.ohc_a_present) begin // {
        implcit_byte_enable_mem_tlps=1; //No explciit byte enable fields
        m_tlp_last_dw_be =  4'hF; //Implied to be 'hF. Need to extract this info for CPL generation by cif router
        m_tlp_first_dw_be =  4'hF;//Implied to be 'hF. Need to extract this info for CPL generation by cif router
      end //}
      if(m_ohc_hdr.ohc_a_present) begin //{
        `uvm_info(get_type_name(),$sformatf("Unpacking ohc_a_present"),UVM_DEBUG);
        m_ohc_a = packer.unpack_field_int($bits(m_ohc_a));
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE}) begin //{   //OHC-A1
          if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)) &&
          (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
            m_tlp_ats_tr_nw_field = m_ohc_a[31];
          end else begin
            m_ohc_a1_byte_0_field_7_rsvd = m_ohc_a[31];
          end
          m_pasid_prefix_present = m_ohc_a[30];
          if(m_pasid_prefix_present) begin
            prfx_cnt++;
            m_pasid_pri_value = m_ohc_a[29];
            m_pasid_exec_value = m_ohc_a[28];
            m_pasid_value = m_ohc_a[27:8];
            m_tlp_e2e_prfx_type = CDN_HPA_PCIE_TLP_Pasid;
          end
          m_tlp_last_dw_be =  m_ohc_a[7:4];
          m_tlp_first_dw_be =  m_ohc_a[3:0];
        end //}
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE}) begin //{   //OHC-A2
          m_ohc_a2_byte_0_2_rsvd = m_ohc_a[31:8];
          m_tlp_last_dw_be =  m_ohc_a[7:4];
          m_tlp_first_dw_be =  m_ohc_a[3:0];
        end //}
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE}) begin //{  //OHC-A3
          m_destination_segment = m_ohc_a[31:24];
          m_ohc_a3_byte_1_rsvd = m_ohc_a[23:16];
          m_destination_segment_valid = m_ohc_a[15];
          m_ohc_a3_byte_2_rsvd = m_ohc_a[14:8];
          m_tlp_last_dw_be =  m_ohc_a[7:4];
          m_tlp_first_dw_be =  m_ohc_a[3:0];
        end //}
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MSG_TYPE}) begin //{
          if(pcie_6_1_support && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC) && (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Request)) begin//{ //OHC-A1
            // As per section --- only PR Request can have PASID
            m_ohc_a1_byte_0_field_7_rsvd = m_ohc_a[31];
            m_pasid_prefix_present = m_ohc_a[30];
            if(m_pasid_prefix_present) begin
              prfx_cnt++;
              m_pasid_pri_value = m_ohc_a[29];
              m_pasid_exec_value = m_ohc_a[28];
              m_pasid_value = m_ohc_a[27:8];
              m_tlp_e2e_prfx_type = CDN_HPA_PCIE_TLP_Pasid;
            end
            m_ohc_a1_byte_3_rsvd = m_ohc_a[7:0];
          end else begin //}{   //OHC-A4
            m_destination_segment_valid = m_ohc_a[15];
            m_pasid_prefix_present = m_ohc_a[14];
            if(m_destination_segment_valid) m_destination_segment = m_ohc_a[31:24];
            if(m_pasid_prefix_present) begin
              prfx_cnt++;
              m_pasid_value[15:8] = m_ohc_a[23:16];
              m_pasid_value[19:16] = m_ohc_a[11:8];
              m_pasid_value[7:0] = m_ohc_a[7:0];
              m_tlp_e2e_prfx_type = CDN_HPA_PCIE_TLP_Pasid;
            end
            m_ohc_a4_byte_2_field_5_4_rsvd = m_ohc_a[13:12];
          end //}
        end//}
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE}) begin //{  //OHC-A5
          m_destination_segment=  m_ohc_a[31:24];
          m_completer_segment =  m_ohc_a[23:16];
          m_destination_segment_valid = m_ohc_a[15];
          m_ohc_a5_byte_2_3_rsvd = m_ohc_a[14:5];
          m_tlp_cpl_lower_addr[1:0] = m_ohc_a[4:3];
          m_tlp_cpl_status = cdn_hpa_pcie_cpl_status_type_t'(m_ohc_a[2:0]);
        end //}
      end //}
      if(m_ohc_hdr.ohc_b_present) begin
        `uvm_info(get_type_name(),$sformatf("Unpacking ohc_b_present"),UVM_DEBUG);
        m_ohc_b = packer.unpack_field_int($bits(m_ohc_b));
        m_ohc_b_byte_0_rsvd = m_ohc_b[31:24];
        m_hv = m_ohc_b[5:4];
        m_ama_valid = m_ohc_b[0];
        if(m_ama_valid) m_ama_value=m_ohc_b[3:1];
        if(m_hv==2'b11) begin
          m_tlp_st_tag[15:8] = m_ohc_b[23:16];
          m_ext_tph_prefix_present = 1;
          prfx_cnt++;
        end
        if(m_hv inside {2'b01,2'b11}) begin
          m_tlp_st_tag[7:0] = m_ohc_b[15:8];
          m_tlp_ph = m_ohc_b[7:6];
        end
      end
      if(m_ohc_hdr.ohc_c_present) begin
        `uvm_info(get_type_name(),$sformatf("Unpacking ohc_c_present"),UVM_DEBUG);
        m_ohc_c = packer.unpack_field_int($bits(m_ohc_c));
        m_requester_segment =  m_ohc_c[31:24];
        m_pr_sent_counter = m_ohc_c[23:16];
        m_stream_id = m_ohc_c[15:8];
        m_sub_stream = m_ohc_c[7:4];
        m_requester_segment_valid = m_ohc_c[3];
        m_ohc_c_byte_3_field_2_rsvd = m_ohc_c[2];
        m_ide_k = m_ohc_c[1];
        m_ide_t = m_ohc_c[0];
        if(m_sub_stream!=4'h7) begin
          m_ide_prefix_present=1;
          is_ide_tlp = 1;
        end
      end
      m_ohc_e_size_decoded = ((m_ohc_hdr.ohc_ex_present==ohc_e1_present) ? 1 :
      (m_ohc_hdr.ohc_ex_present==ohc_e2_present) ? 2 :
      (m_ohc_hdr.ohc_ex_present==ohc_e4_present) ? 4 : 0);
      num_of_vnd_e2e_prefixes = m_ohc_e_size_decoded;
      if(m_ohc_hdr.ohc_ex_present!=no_ohc_ex_present) begin
        `uvm_info(get_type_name(),$sformatf("Unpacking ohc_e_present"),UVM_DEBUG);
        m_ohc_e = new[m_ohc_e_size_decoded];
        foreach(m_ohc_e[i]) begin
          m_ohc_e[i] = packer.unpack_field_int(32);
          if(m_ohc_e[i] !=0) num_of_valid_vnd_e2e_prefixes++;
        end
      end
      m_max_no_of_prefixes = prfx_cnt+ m_ide_prefix_present;
    end

    //Extract messages 3rd & 4th DW from temp_3rd_dw, temp_4th_dw incase of flit mode
    if(is_flit_mode) begin //{
      if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) begin //{
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin //{
          m_tlp_vendor_id = temp_3rd_dw[15:0];
          m_tlp_vendor_msg = temp_4th_dw[31:0];
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && (m_tlp_vendor_msg[31:24] inside {8'b0000_0000, 8'b0000_1000,8'b0000_1001,8'b0000_0001})) m_tlp_vdm_msg_subtype = cdn_hpa_pcie_tlp_vdm_msg_sub_type_t'(m_tlp_vendor_msg[31:24]);
          else if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1})
          m_tlp_vdm_msg_subtype = CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1;
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}) begin //{
            msg_frs_byte_13_15_rsvd =  m_tlp_vendor_msg[23:4];
            m_tlp_frs_msg_reason = cdn_hpa_pcie_frs_msg_reason_t'(m_tlp_vendor_msg[3:0]);
          end //}
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_DRS}) begin //{
            msg_ln_drs_byte_13_15_rsvd = m_tlp_vendor_msg[23:0];
          end //}
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_HIER_ID}) begin //{
            m_tlp_hier_vmsg_system_guid[143:128] = m_tlp_vendor_msg[15:0];
            m_tlp_hier_vmsg_guid_authority_id = m_tlp_vendor_msg[23:16];
          end //}

          if((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type0) || ((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type1)&&(m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_HIER_ID))) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16] ;
          end else begin //}{
            m_tlp_hier_vmsg_hierarchy_id = temp_3rd_dw [31:16];
          end //}
        end else if (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin//} {
          {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16] ;
          msg_inv_req_byte_10_15_rsvd = {temp_3rd_dw[15:0],temp_4th_dw};
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin //}{
          {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16] ;
          msg_inv_cpl_byte_10_11_rsvd = temp_3rd_dw[15:3];
          m_inv_cpl_cnt = temp_3rd_dw[2:0];
          m_tlp_itag_vector = temp_4th_dw;
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16] ;
            msg_ltr_byte_8_11_rsvd[23:16] = temp_3rd_dw[15:8];
            msg_ltr_byte_8_11_rsvd[31:24] = temp_3rd_dw[7:0];
          end else begin //}{
            msg_ltr_byte_8_11_rsvd = temp_3rd_dw;
          end //}
          m_tlp_ltr_msg_no_snoop_latency = temp_4th_dw[31:16];
          m_tlp_ltr_msg_snoop_latency = temp_4th_dw[15:0];
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Request) begin //}{
          m_page_addr = {temp_3rd_dw,temp_4th_dw[31:12]};
          m_prGroupIndex = temp_4th_dw[11:3];
          m_prLastRequest = temp_4th_dw[2];
          m_prWriteRequested =temp_4th_dw[1];
          m_prReadRequested =temp_4th_dw[0];
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Group_Response) begin //}{
          {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16] ;
          m_prgResponseCode = temp_3rd_dw[15:12];
          msg_pr_rsp_byte_10_field_3_1_rsvd =temp_3rd_dw[11:9];
          m_prGroupIndex =temp_3rd_dw[8:0];
          msg_pr_rsp_byte_12_15_rsvd = temp_4th_dw;
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16] ;
            msg_obff_byte_8_14_rsvd[23:16] = temp_3rd_dw[15:8];
            msg_obff_byte_8_14_rsvd[31:24] = temp_3rd_dw[7:0];
            msg_obff_byte_8_14_rsvd[39:32] = temp_4th_dw[31:24];
            msg_obff_byte_8_14_rsvd[47:40] = temp_4th_dw[23:16];
            msg_obff_byte_8_14_rsvd[55:48] = temp_4th_dw[15:8];
            msg_obff_byte_8_14_rsvd[59:56] = temp_4th_dw[7:4];
          end else begin //}{
            msg_obff_byte_8_14_rsvd = {temp_3rd_dw,temp_4th_dw[31:4]};
          end //}
          m_obffCode = cdn_hpa_pcie_ObffCode_t'(temp_4th_dw[3:0]);
        end else if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code== CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD)) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16] ;
            m_ptmMasterTime[23:16] = temp_3rd_dw[15:8];
            m_ptmMasterTime[31:24] = temp_3rd_dw[7:0];
          end else begin //}{
            m_ptmMasterTime = {temp_3rd_dw,temp_4th_dw};
          end //}
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Sync) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16];
            msg_ide_sync_byte_8_11_rsvd[23:16] = temp_3rd_dw[15:8];
            msg_ide_sync_byte_8_11_rsvd[31:24] = temp_3rd_dw[7:0];
          end else begin //}{
            msg_ide_sync_byte_8_11_rsvd = temp_3rd_dw;
          end //}
          msg_ide_sync_byte_12_rsvd = temp_4th_dw[31:24];
          msg_ide_sync_pr_sent_cnt_cpl = temp_4th_dw[23:16];
          msg_ide_sync_byte_14_rsvd = temp_4th_dw[15:8];
          msg_ide_sync_pr_sent_cnt_np = temp_4th_dw[7:0];
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16];
            msg_ide_sync_byte_8_11_rsvd[23:16] = temp_3rd_dw[15:8];
            msg_ide_sync_byte_8_11_rsvd[31:24] = temp_3rd_dw[7:0];
          end else begin //}{
            msg_ide_sync_byte_8_11_rsvd = temp_3rd_dw;
          end //}
          msg_ide_fail_byte_12_15_rsvd = temp_4th_dw;
        end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Fail) begin //}{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16];
          end else begin //}{
            msg_ide_fail_byte_8_9_rsvd = temp_3rd_dw [31:16];
          end //}
          msg_ide_fail_byte_10_rsvd = temp_3rd_dw[15:8];
          msg_ide_fail_stream_id = temp_3rd_dw[7:0];
          msg_ide_fail_byte_12_15_rsvd = temp_4th_dw;
        end else begin //3rd & 4th DW are Rsvd for other messages }{
          if (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin //{
            {m_tlp_completer_id.bus_num,m_tlp_completer_id.device_num,m_tlp_completer_id.function_num} = temp_3rd_dw [31:16] ;
            msg_cmn_byte_8_15_rsvd[23:16] = temp_3rd_dw[15:8];
            msg_cmn_byte_8_15_rsvd[31:24] = temp_3rd_dw[7:0];
            msg_cmn_byte_8_15_rsvd[39:32] = temp_4th_dw[31:24];
            msg_cmn_byte_8_15_rsvd[47:40] = temp_4th_dw[23:16];
            msg_cmn_byte_8_15_rsvd[55:48] = temp_4th_dw[15:8];
            msg_cmn_byte_8_15_rsvd[63:56] = temp_4th_dw[7:0];
          end else begin //}{
            msg_cmn_byte_8_15_rsvd = {temp_3rd_dw,temp_4th_dw};
          end //}
        end //}
      end //}
    end //}


    `uvm_info(get_type_name(),$sformatf("Unpacking payload"),UVM_DEBUG);
    // if payload is present
    m_tlp_payload = new[0];
    if(((m_hdr_fmt[1] == 1'b1) && (m_tlp_trans_type != CDN_HPA_PCIE_TRANS_RSVD_TYPE) && (unpack_payload)) || rsvd_with_payload) begin
      //Masking this for payload length mismatch error (tl_rx module)
      if(!m_len_neq_payload_err)
      m_tlp_payload = new[(((m_tlp_length == 0) ? 1024 : m_tlp_length)*4)];
      else if (is_cpl_tlp_header_rsvd)
      m_tlp_payload = new[(m_tlp_length)*4];
      else
      m_tlp_payload = new[(m_errored_length)*4];
      foreach(m_tlp_payload[i]) m_tlp_payload[i] = packer.unpack_field_int(8);
    end

    `ifdef CDNS_IDE //TODO :: ask module guys to use unpack_ide_trailer for guarding
      //Unpack IDE PCRC and MAC for NFM
      if(!is_flit_mode && unpack_ide_trailer) begin
        if(m_ide_m) begin
          `uvm_info(get_type_name(),$sformatf("Unpacking MAC and PCRC"),UVM_DEBUG);
          if(m_ide_p) m_ide_pcrc = packer.unpack_field_int(32);
          for(int i=0; i<12; i++) m_ide_mac[12-1-i] = packer.unpack_field_int(8);
        end
      end
    `endif

    //Unpack trailer incase of flit mode
    if(is_flit_mode) begin
      trailer_size_decoded = (
        (m_ts == CDN_HPA_PCIE_NO_TRAILER /*----------------------*/ ) ? 0 :
        (m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER /*----------------*/ ) ? 1 :
        (m_ts == CDN_HPA_PCIE_1DW_RSVD_TRAILER /*----------------*/ ) ? 1 :
        (m_ts == CDN_HPA_PCIE_2DW_RSVD_TRAILER /*----------------*/ ) ? 2 :
        (m_ts == CDN_HPA_PCIE_2DW_RSVD1_TRAILER /*---------------*/ ) ? 2 :
        (m_ts == CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER /**/ ) ? 3 :
        (m_ts == CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER ) ? 4 :
        (m_ts == CDN_HPA_PCIE_5DW_RSVD_TRAILER /*----------------*/ ) ? 5 :
        8'h0
      );
      if(
        !(m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER && !unpack_ecrc) &&
        !((m_ts == CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER ||
        m_ts == CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER) && !unpack_ide_trailer) &&
        !((m_ts == CDN_HPA_PCIE_1DW_RSVD_TRAILER ||
        m_ts == CDN_HPA_PCIE_2DW_RSVD_TRAILER ||
        m_ts == CDN_HPA_PCIE_2DW_RSVD1_TRAILER ||
        m_ts == CDN_HPA_PCIE_5DW_RSVD_TRAILER) && !unpack_rsvd_trailer)
      )
      begin
        `uvm_info(get_type_name(),$sformatf("Unpacking trailer"),UVM_DEBUG);
        m_ts_payload = new[trailer_size_decoded*4];
        foreach(m_ts_payload[i]) m_ts_payload[i] = packer.unpack_field_int(8);
        if(m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER) ecrc_valid = 1;
      end
    end

    //ECRC
    if(unpack_ecrc && m_tlp_td && !is_flit_mode && !m_ide_prefix_present) begin //{
      `uvm_info(get_type_name(),$sformatf("Unpacking ECRC"),UVM_DEBUG);
      ecrc_val = packer.unpack_field_int(32);
      ecrc_valid = 1;
    end //}

    //Some msg fields are in payload
    //Unpacking those fields
    //CXL VDM Message only
    if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE ) && !is_posted_tlp_id_routed_header_rsvd && !is_nonposted_tlp_id_routed_header_rsvd) begin
      //`uvm_info(get_full_name(), $psprintf("Come in Unpack funtion Message m_tlp_type=%s, m_tlp_msg_code=%s, m_tlp_length=%d, m_tlp_vendor_id=%h ",m_tlp_type.name(),m_tlp_msg_code.name(), m_tlp_length, m_tlp_vendor_id ), UVM_LOW)
      if((m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0}) && m_tlp_length==4 && m_tlp_vendor_id == 16'h1E98) begin //{
        foreach(m_tlp_payload[i]) begin
          if(i==0) m_cxl_vdm_pm_logical_opcode = cdn_hpa_cxl_pm_logical_op_t'(m_tlp_payload[i]);
          else if (i==1) {m_cxl_vdm_pm_agt_id_rsvd_bit,m_cxl_vdm_pm_agt_id} = m_tlp_payload[i];
          else if (i==2) m_cxl_vdm_parameter[7:0] = m_tlp_payload[i];
          else if (i==3) m_cxl_vdm_parameter[15:8] = m_tlp_payload[i];
          else m_cxl_vdm_payload[(((i-4)*8)+7)-:8] = m_tlp_payload[i];
        end
        if(m_cxl_vdm_pm_logical_opcode != CDN_HPA_VDM_STD_VD_TYPE0) msg_pm_cxl_vnd_msg_byte_12_14_rsvd = m_tlp_vendor_msg[31:8];
        //foreach(m_tlp_payload[i]) begin
        //`uvm_info(get_full_name(), $psprintf("Come in Unpack funtion m_cxl_vdm_pm_logical_opcode=%s m_cxl_vdm_pm_agt_id=%d m_tlp_payload[i=%d]=%h",m_cxl_vdm_pm_logical_opcode.name(),m_cxl_vdm_pm_agt_id,i,m_tlp_payload[i] ), UVM_LOW)
        // end
        //if(cxl_version == 2 && cxl_mode ==1  && vdm_for_cxl==1) begin // MP
        if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin  //CDN_HPA_CXL_AGENT_INFO
          {m_cxl_vdm_agt_info_payload_rsvd_93_3,
          m_cxl_vdm_agt_info_capability_vector_bit1,
          m_cxl_vdm_agt_info_capability_vector_bit0} = m_cxl_vdm_payload;

          {m_cxl_vdm_agt_info_param_byte1_rsvd,
          m_cxl_vdm_agt_info_index,
          m_cxl_vdm_agt_info_req_or_rsp} = m_cxl_vdm_parameter;
          //`uvm_info(get_full_name(),$psprintf("Come in Unpack funtion CDN_HPA_CXL_AGENT_INFO "),UVM_LOW)
        end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin  //CDN_HPA_CXL_RESET_PREP
          {m_cxl_vdm_resetprep_payload_rsvd_95_9,
          m_cxl_vdm_resetprep_prep_type,
          m_cxl_vdm_resetprep_reset_type } = m_cxl_vdm_payload;

          {m_cxl_vdm_resetprep_param_byte0_1_rsvd,
          m_cxl_vdm_resetprep_req_or_rsp} = m_cxl_vdm_parameter;
          //`uvm_info(get_full_name(),$psprintf("Come in Unpack funtion CDN_HPA_CXL_RESET_PREP "),UVM_LOW)
        end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin  //CDN_HPA_CXL_PM_REQ_RSP_GO
          {m_cxl_vdm_gpf_payload_rsvd_95_18,
          m_cxl_vdm_gpf_payload_phase,
          m_cxl_vdm_gpf_payload_rsvd_15_9,
          m_cxl_vdm_gpf_status_bit8,
          m_cxl_vdm_gpf_payload_rsvd_7_2,
          m_cxl_vdm_gpf_payload_bit1,
          m_cxl_vdm_gpf_payload_bit0}= m_cxl_vdm_payload;

          {m_cxl_vdm_pmreq_param_byte0_1_rsvd,
          m_cxl_vdm_pmreq_go,
          m_cxl_vdm_pmreq_param_bit1_rsvd,
          m_cxl_vdm_pmreq_req_or_rsp} = m_cxl_vdm_parameter;
          //`uvm_info(get_full_name(),$psprintf("Come in Unpack funtion CDN_HPA_CXL_PM_REQ_RSP_GO "),UVM_LOW)
        end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_GPF) begin  //CDN_HPA_CXL_GPF
          {m_cxl_vdm_pmreq_payload_rsvd,
          m_cxl_vdm_pmreq_ltr_2}= m_cxl_vdm_payload;

          {m_cxl_vdm_gpf_param_byte0_1_rsvd,
          m_cxl_vdm_gpf_req_or_rsp}= m_cxl_vdm_parameter;
        end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_CREDIT_RTN) begin  //CDN_HPA_CXL_GPF
          {m_cxl_vdm_crd_rtn_payload_rsvd,
          m_cxl_vdm_crd_rtn_payload_tgt_agt_id,
          m_cxl_vdm_crd_rtn_payload_num_credits } = m_cxl_vdm_payload;
          m_cxl_vdm_crd_rtn_param_field_rsvd = m_cxl_vdm_parameter;
          //`uvm_info(get_full_name(),$psprintf("Come in Unpack funtion CDN_HPA_CXL_CREDIT_RTN "),UVM_LOW)
        end
        else begin
          //m_cxl_vdm_pm_logical_opcode = CDN_HPA_VDM_STD_VD_TYPE0; //Default for std vnd msg0
          `uvm_info(get_full_name(),$psprintf("Come in Unpack funtion Unwanted Message  "),UVM_DEBUG)
        end
      end else begin//}
        // CXL VDM ERROR Message without data
        if(cxl_mode == 1 && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg && m_tlp_length == 0 && m_tlp_vendor_id == 16'h1E98 )begin
          m_cxl_error_vdm_msg= CDN_HPA_CXL_VDM_MEFN;
          //getting unable to find received packet in p/np; Why was this assigned to 0 for CXL VDM MSG with no data?
          //m_tlp_vendor_msg =32'h00000000;
          //`uvm_info(get_full_name(),$psprintf("Come in Unpack funtion CDN_HPA_CXL_VDM_MEFN "),UVM_LOW)
        end //else

      end

      if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code== CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD))) begin
        m_ptmPropagationDelay = {m_tlp_payload[0],m_tlp_payload[1],m_tlp_payload[2],m_tlp_payload[3]};
      end
      if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN}) begin
        m_tlp_ln_msg_cacheline_addr[63:6] = {m_tlp_payload[0],m_tlp_payload[1],m_tlp_payload[2],m_tlp_payload[3],
        m_tlp_payload[4],m_tlp_payload[5],m_tlp_payload[6],m_tlp_payload[7][7:6]};
        msg_ln_payload_rsvd =  m_tlp_payload[7][5:2];
        m_tlp_ln_msg_nr =  m_tlp_payload[7][1:0];
      end
      if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_HIER_ID}) begin
        m_tlp_hier_vmsg_system_guid[127:0] = {m_tlp_payload[0],m_tlp_payload[1],m_tlp_payload[2],m_tlp_payload[3],
        m_tlp_payload[4],m_tlp_payload[5],m_tlp_payload[6],m_tlp_payload[7],
        m_tlp_payload[8],m_tlp_payload[9],m_tlp_payload[10],m_tlp_payload[11],
        m_tlp_payload[12],m_tlp_payload[13],m_tlp_payload[14],m_tlp_payload[15]};
      end
    end
    if(unpack_intx) begin
      requestor_id = packer.unpack_field_int($bits(requestor_id));
      intx_in_pin_value = packer.unpack_field_int($bits(intx_in_pin_value));
      intx_in_pin_valid_value = packer.unpack_field_int($bits(intx_in_pin_valid_value));
      intx_out_pin_value = packer.unpack_field_int($bits(intx_out_pin_value));
      int_ack_pin_value =  packer.unpack_field_int($bits(int_ack_pin_value));
      foreach(intx_pin[i]) begin
        `uvm_unpack_enumN(intx_pin[i], $bits(intx_pin[i]), cdn_pcie_intx_trans_kind);
      end
      foreach(intx_out_pin[i]) begin
        `uvm_unpack_enumN(intx_out_pin[i], $bits(intx_out_pin[i]), cdn_pcie_intx_trans_kind);
      end
      intx_pending_status = packer.unpack_field_int($bits(intx_pending_status));
      //  m_intr_pins = packer.unpack_field_int($bits(m_intr_pins));
      foreach(start_time[i]) begin
        start_time[i] = packer.unpack_field_int($bits(start_time[i]));
      end
      foreach(end_time[i]) begin
        end_time[i] =  packer.unpack_field_int($bits(end_time[i]));
      end
      fid_active = packer.unpack_field_int($bits(fid_active));
    end

    if(unpack_msi_msix) begin
      msi_en = packer.unpack_field_int($bits(msi_en));
      id_based_ordering = packer.unpack_field_int($bits(id_based_ordering));
      msi_msix_requestor_id = packer.unpack_field_int($bits(msi_msix_requestor_id));
      intr_number = packer.unpack_field_int($bits(intr_number));
      intr_number_bits = packer.unpack_field_int($bits(intr_number_bits));
      intr_number_bits_cap = packer.unpack_field_int($bits(intr_number_bits_cap));
      int_msix_msg_data = packer.unpack_field_int($bits(int_msix_msg_data));
      int_msix_msg_lo_addr = packer.unpack_field_int($bits(int_msix_msg_lo_addr));
      int_msix_msg_hi_addr = packer.unpack_field_int($bits(int_msix_msg_hi_addr));
      pending_status = packer.unpack_field_int($bits(pending_status));
      requestor_id_for_pending_status = packer.unpack_field_int($bits(requestor_id_for_pending_status));
      int_msi_pending_status_valid = packer.unpack_field_int($bits(int_msi_pending_status_valid));
      int_msi_pending_status = packer.unpack_field_int($bits(int_msi_pending_status));
      msi_msg_low_addr = packer.unpack_field_int($bits(msi_msg_low_addr));
      msi_msg_hi_addr = packer.unpack_field_int($bits(msi_msg_hi_addr));
      msi_msg_data = packer.unpack_field_int($bits(msi_msg_data));
      ext_msg_data_en = packer.unpack_field_int($bits(ext_msg_data_en));
      msi_64bit_addr_cap = packer.unpack_field_int($bits(msi_64bit_addr_cap));
      msi_per_vector_masking_cap = packer.unpack_field_int($bits(msi_per_vector_masking_cap));
      st_tag_pin_or_reg = packer.unpack_field_int($bits(st_tag_pin_or_reg));
      tph_st_table_index = packer.unpack_field_int($bits(tph_st_table_index));
      tph_present = packer.unpack_field_int($bits(tph_present));
      extended_tph_valid = packer.unpack_field_int($bits(extended_tph_valid));
      int_msg_valid = packer.unpack_field_int($bits(int_msg_valid));
      tph_type = packer.unpack_field_int($bits(tph_type));
      tph_st_tag = packer.unpack_field_int($bits(tph_st_tag));
      attributes = packer.unpack_field_int($bits(attributes));
      attr_no_snoop = packer.unpack_field_int($bits(attr_no_snoop));
      attr_relax_ordering = packer.unpack_field_int($bits(attr_relax_ordering));
      attr_ido = packer.unpack_field_int($bits(attr_ido));
      pasidPresent = packer.unpack_field_int($bits(pasidPresent));
      pasidVal = packer.unpack_field_int($bits(pasidVal));
      pasidExecReq = packer.unpack_field_int($bits(pasidExecReq));
      pasidPriModeReq = packer.unpack_field_int($bits(pasidPriModeReq));
      atsPresent = packer.unpack_field_int($bits(atsPresent));
      ats_at = packer.unpack_field_int($bits(ats_at));
      tc_val = packer.unpack_field_int($bits(tc_val));
      abort_status = packer.unpack_field_int($bits(abort_status));
      int_mask_changed_ipfivf = packer.unpack_field_int($bits(int_mask_changed_ipfivf));
      int_mask_changed_valid = packer.unpack_field_int($bits(int_mask_changed_valid));
      int_msg_done = packer.unpack_field_int($bits(int_msg_done));
      int_msi_cap = packer.unpack_field_int($bits(int_msi_cap));
      int_msix_cap = packer.unpack_field_int($bits(int_msix_cap));
      msi_msix_start_time = packer.unpack_field_int($bits(msi_msix_start_time));
      msi_msix_end_time = packer.unpack_field_int($bits(msi_msix_end_time));
    end
  endfunction

  //------------------------------------------------------------------------
  // Function: do_compare
  // Extend the do_compare method for the physical member fields
  //------------------------------------------------------------------------
  virtual function bit do_compare (uvm_object rhs,uvm_comparer comparer);
    cdn_hpa_pcie_tlp rhs_;
    do_compare = super.do_compare(rhs,comparer);
    $cast(rhs_,rhs);

    //Compare Prefixes, if any
    if(compare_prefix ==1) begin
      //Local prefixes
      foreach(m_tlp_local_prefix[i]) begin
        do_compare &= comparer.compare_field_int($psprintf("m_tlp_local_prefix[%0d]",i), m_tlp_local_prefix[i], rhs_.m_tlp_local_prefix[i], $bits(m_tlp_local_prefix[i]) );
        do_compare &= comparer.compare_field_int($psprintf("m_hdr_fmt_local_prefix[%0d]",i), m_hdr_fmt_local_prefix[i], rhs_.m_hdr_fmt_local_prefix[i], $bits(m_hdr_fmt_local_prefix[i]) );
        do_compare &= comparer.compare_field_int($psprintf("m_hdr_type_local_prefix[%0d]",i), m_hdr_type_local_prefix[i], rhs_.m_hdr_type_local_prefix[i], $bits(m_hdr_type_local_prefix[i]) );
        do_compare &= comparer.compare_field_int($psprintf("m_tlp_local_prefix_data[%0d]",i), m_tlp_local_prefix_data[i], rhs_.m_tlp_local_prefix_data[i], $bits(m_tlp_local_prefix_data[i]) );
        
        `uvm_info(get_type_name(), $psprintf(" m_tlp_local_prefix[i]=%h, rhs_.m_tlp_local_prefix[i]=%h, m_hdr_fmt_local_prefix[i]=%h, rhs_.m_hdr_fmt_local_prefix[i]=%h, m_hdr_type_local_prefix[i] =%h, rhs_.m_hdr_type_local_prefix[i]=%h, m_tlp_local_prefix_data[i]=%h, rhs_.m_tlp_local_prefix_data[i]=%h  ",this.m_tlp_local_prefix[i], rhs_.m_tlp_local_prefix[i], this.m_hdr_fmt_local_prefix[i], rhs_.m_hdr_fmt_local_prefix[i],this.m_hdr_type_local_prefix[i], rhs_.m_hdr_type_local_prefix[i],this.m_tlp_local_prefix_data[i], rhs_.m_tlp_local_prefix_data[i]), UVM_LOW)
      end
      //E2E prefixes (Skip for flit mode: E2E prefix is part of OHC for flit mode)
      if(!is_flit_mode) begin
        do_compare &= comparer.compare_field_int("m_ide_hdr_type_prefix", m_ide_hdr_type_prefix, rhs_.m_ide_hdr_type_prefix, 5);
        do_compare &= comparer.compare_field_int("m_ide_hdr_fmt_prefix", m_ide_hdr_fmt_prefix, rhs_.m_ide_hdr_fmt_prefix, 3);
        do_compare &= comparer.compare_field_int("m_stream_id", m_stream_id, rhs_.m_stream_id, 8);
        do_compare &= comparer.compare_field_int("m_sub_stream", m_sub_stream, rhs_.m_sub_stream, 4);
        if(m_cfg_info_valid) begin
          if(m_cfg_info.m_tlp_dir == CDN_HPA_PCIE_INBOUND || !(m_tlp_req_type inside {CDN_HPA_PCIE_TRANS_POSTED_REQ,CDN_HPA_PCIE_TRANS_NON_POSTED_REQ})) begin
            do_compare &= comparer.compare_field_int("m_ide_m", m_ide_m, rhs_.m_ide_m, 1);
            do_compare &= comparer.compare_field_int("m_ide_p", m_ide_p, rhs_.m_ide_p, 1);
          end else begin //outbound
            //M&P bits not compared for OB NP req. Because, 8B/10B/14B tag manager may make a mess in ordering generated and fed to driver due to tag not available in one tag pool. Rely on VIP checks
            //TODO:  do_compare why m/p checks has filters for internally gen Posted packets?
            //whenever IDE aggregation is enabled, internally generated IDE_SYNC msg can terminate the aggregation.
            //So the next item generated by seq can have P=1(to complete aggregation) but DUT might reset the P bit (If the curr tlp
            //doesn't have payload and as last aggreagtion is completed).
            //But TODO still applied for removing the m/p check for msi/msix and TC0 P packets
            if(m_tlp_req_type==CDN_HPA_PCIE_TRANS_POSTED_REQ) begin
              if(!(m_pcie_dev_top_cfg.i_cfg.k_msix_enable || m_pcie_dev_top_cfg.i_cfg.k_msi_enable)) begin
                if(m_tlp_tc != 0) begin
                  do_compare &= comparer.compare_field_int("m_ide_m", m_ide_m, rhs_.m_ide_m, 1);
                  if(!m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) begin
                    do_compare &= comparer.compare_field_int("m_ide_p", m_ide_p, rhs_.m_ide_p, 1);
                  end
                end
              end
            end
          end
        end
        //do_compare &= comparer.compare_field_int("m_ide_k", m_ide_k, rhs_.m_ide_k, 1);
        do_compare &= comparer.compare_field_int("m_ide_t", m_ide_t, rhs_.m_ide_t, 1);

        foreach(m_tlp_prefix[i]) begin
          do_compare &= comparer.compare_field_int($psprintf("m_tlp_prefix[%0d]",i), m_tlp_prefix[i], rhs_.m_tlp_prefix[i], 32);
          do_compare &= comparer.compare_field_int($psprintf("m_hdr_fmt_prefix[%0d]",i), m_hdr_fmt_prefix[i], rhs_.m_hdr_fmt_prefix[i], 3);
          do_compare &= comparer.compare_field_int($psprintf("m_hdr_type_prefix[%0d]",i), m_hdr_type_prefix[i], rhs_.m_hdr_type_prefix[i], 5);
          if((m_hdr_type_prefix[i] == 5'b10000) && compare_rsvd_bits)
          if(hpa_generation != hpa_generation_2) do_compare &= comparer.compare_field_int("tph_byte_2_3_rsvd",tph_byte_2_3_rsvd ,rhs_.tph_byte_2_3_rsvd ,$bits(tph_byte_2_3_rsvd));
          else do_compare &= comparer.compare_field_int("tph_byte_2_3_rsvd",tph_byte_2_3_rsvd[11:0],rhs_.tph_byte_2_3_rsvd[11:0] ,$bits(tph_byte_2_3_rsvd[11:0]));
          if((m_hdr_type_prefix[i] == 5'b10001) && compare_rsvd_bits)
          do_compare &= comparer.compare_field_int("pasid_byte_1_rsvd_field_5_4",pasid_byte_1_rsvd_field_5_4 ,rhs_.pasid_byte_1_rsvd_field_5_4 ,$bits(pasid_byte_1_rsvd_field_5_4));
        end
      end
    end
    
    //PTH
    //`uvm_info(get_type_name(), $psprintf("Comparing PTH %h %d", m_tlp_pbr_tlp_header, isIntxPkt), UVM_DEBUG)
    //CXL spec 3.1.1: A Function on a CXL device must not generate INTx messages if that Function participates in CXL.cache protocol or CXL.mem protocols.
    //If INTx: Not comparing CXL PBR TLP header
    if(!isIntxPkt)
    begin
      do_compare &= comparer.compare_field_int("m_tlp_pbr_tlp_header", m_tlp_pbr_tlp_header, rhs_.m_tlp_pbr_tlp_header, $bits(m_tlp_pbr_tlp_header));
      do_compare &= comparer.compare_field_int("m_tlp_pth_hie"       , m_tlp_pth_hie       , rhs_.m_tlp_pth_hie       , $bits(m_tlp_pth_hie       ));
      do_compare &= comparer.compare_field_int("m_tlp_pth_dsar"      , m_tlp_pth_dsar      , rhs_.m_tlp_pth_dsar      , $bits(m_tlp_pth_dsar      ));
      do_compare &= comparer.compare_field_int("m_tlp_pth_pif"       , m_tlp_pth_pif       , rhs_.m_tlp_pth_pif       , $bits(m_tlp_pth_pif       ));
      do_compare &= comparer.compare_field_int("m_tlp_pth_spid"      , m_tlp_pth_spid      , rhs_.m_tlp_pth_spid      , $bits(m_tlp_pth_spid      ));
      do_compare &= comparer.compare_field_int("m_tlp_pth_dpid"      , m_tlp_pth_dpid      , rhs_.m_tlp_pth_dpid      , $bits(m_tlp_pth_dpid      ));
      do_compare &= comparer.compare_field_int("m_tlp_pth_rsvd"      , m_tlp_pth_rsvd      , rhs_.m_tlp_pth_rsvd      , $bits(m_tlp_pth_rsvd      ));
    end

    // First DW - comparing all fileds
    //`uvm_compare_enum(m_hdr_fmt, rhs_.m_hdr_fmt, cdn_hpa_pcie_tlp_fmt_t); // TODO
    if(is_flit_mode) begin //{
      do_compare &= comparer.compare_field_int("m_type", {m_hdr_fmt,m_hdr_type}, {rhs_.m_hdr_fmt,rhs_.m_hdr_type}, 8);
      do_compare &= comparer.compare_field_int("m_tlp_tc", m_tlp_tc, rhs_.m_tlp_tc, $bits(m_tlp_tc) );
      do_compare &= comparer.compare_field_int("m_ohc_hdr", m_ohc_hdr, rhs_.m_ohc_hdr, $bits(m_ohc_hdr) );
     `ifndef PXC //TODO ankitm PXC
      do_compare &= comparer.compare_field_int("m_ts", m_ts, rhs_.m_ts, $bits(m_ts) );
     `endif
      do_compare &= comparer.compare_field_int("m_tlp_attr", {m_tlp_attr1,m_tlp_attr0}, {rhs_.m_tlp_attr1,rhs_.m_tlp_attr0}, 3);
      if(rhs_.m_compare_tlp_length)
      do_compare &= comparer.compare_field_int("m_tlp_length", m_tlp_length, rhs_.m_tlp_length, $bits(m_tlp_length));
    end else begin //}{
      do_compare &= comparer.compare_field_int("m_hdr_fmt", m_hdr_fmt, rhs_.m_hdr_fmt, $bits(m_hdr_fmt) );
      do_compare &= comparer.compare_field_int("m_hdr_type", m_hdr_type, rhs_.m_hdr_type, $bits(m_hdr_type) );
      do_compare &= comparer.compare_field_int("m_tlp_t9", m_tlp_t9, rhs_.m_tlp_t9, $bits(m_tlp_t9) );
      do_compare &= comparer.compare_field_int("m_tlp_tc", m_tlp_tc, rhs_.m_tlp_tc, $bits(m_tlp_tc) );
      do_compare &= comparer.compare_field_int("m_tlp_t8", m_tlp_t8, rhs_.m_tlp_t8, $bits(m_tlp_t8) );
      do_compare &= comparer.compare_field_int("m_tlp_attr1", m_tlp_attr1, rhs_.m_tlp_attr1, $bits(m_tlp_attr1) );
      do_compare &= comparer.compare_field_int("m_tlp_ln", m_tlp_ln, rhs_.m_tlp_ln, $bits(m_tlp_ln) );
      do_compare &= comparer.compare_field_int("m_tlp_th", m_tlp_th, rhs_.m_tlp_th, $bits(m_tlp_th) );
      do_compare &= comparer.compare_field_int("m_tlp_td", m_tlp_td, rhs_.m_tlp_td, $bits(m_tlp_td) );
      do_compare &= comparer.compare_field_int("m_tlp_ep", m_tlp_ep, rhs_.m_tlp_ep, $bits(m_tlp_ep) );
      do_compare &= comparer.compare_field_int("m_tlp_attr0", m_tlp_attr0, rhs_.m_tlp_attr0, $bits(m_tlp_attr0) );
      do_compare &= comparer.compare_field_int("m_hdr_type", m_hdr_type, rhs_.m_hdr_type, $bits(m_hdr_type) );
      //`uvm_compare_enum("m_tlp_at_type", m_tlp_at_type, cdn_hpa_pcie_tlp_at_type_t, $bits(m_tlp_at_type)); // TODO
      do_compare &= comparer.compare_field_int("m_tlp_at_type", m_tlp_at_type,rhs_.m_tlp_at_type,$bits(m_tlp_at_type));
      if(rhs_.m_compare_tlp_length)
      do_compare &= comparer.compare_field_int("m_tlp_length", m_tlp_length, rhs_.m_tlp_length, $bits(m_tlp_length));
    end //}
    // The below Header words change based on TLP Type
    // Second DW
    if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE,CDN_HPA_PCIE_TRANS_MSG_TYPE}) begin //{
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.bus_num", m_tlp_requester_id.bus_num, rhs_.m_tlp_requester_id.bus_num, $bits(m_tlp_requester_id.bus_num) );
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.device_num", m_tlp_requester_id.device_num, rhs_.m_tlp_requester_id.device_num, $bits(m_tlp_requester_id.device_num) );
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.function_num", m_tlp_requester_id.function_num, rhs_.m_tlp_requester_id.function_num, $bits(m_tlp_requester_id.function_num) );

      //Byte 6,7 of second DW
      if(m_tlp_trans_type !=CDN_HPA_PCIE_TRANS_MSG_TYPE) begin //{
        if(is_flit_mode) begin
          do_compare &= comparer.compare_field_int("m_tlp_ep", m_tlp_ep, rhs_.m_tlp_ep, $bits(m_tlp_ep) );
          if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("second_dw_byte_6_field_6_rsvd", second_dw_byte_6_field_6_rsvd, rhs_.second_dw_byte_6_field_6_rsvd, $bits(second_dw_byte_6_field_6_rsvd) );
          do_compare &= comparer.compare_field_int("m_tlp_tag",{m_tlp_14_bit_tagscale,m_tlp_t9,m_tlp_t8,m_tlp_tag} , {rhs_.m_tlp_14_bit_tagscale,rhs_.m_tlp_t9,rhs_.m_tlp_t8,rhs_.m_tlp_tag}, 14 );
        end else begin //NFM
          do_compare &= comparer.compare_field_int("m_tlp_tag", m_tlp_tag, rhs_.m_tlp_tag, $bits(m_tlp_tag) );
        end
      end else begin //}{
        if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate}) begin //{ //common to both FM & NFM
          if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_inv_req_byte_6_field_7_rsvd_nfm", msg_inv_req_byte_6_field_7_rsvd_nfm,rhs_.msg_inv_req_byte_6_field_7_rsvd_nfm ,$bits(msg_inv_req_byte_6_field_7_rsvd_nfm));
          if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_inv_req_byte_6_field_6_5_rsvd", msg_inv_req_byte_6_field_6_5_rsvd,rhs_.msg_inv_req_byte_6_field_6_5_rsvd ,$bits(msg_inv_req_byte_6_field_6_5_rsvd));
          do_compare &= comparer.compare_field_int("m_tlp_itag", m_tlp_itag, rhs_.m_tlp_itag, $bits(m_tlp_itag) );
        end else begin //}{
          if(is_flit_mode) begin
            do_compare &= comparer.compare_field_int("m_tlp_ep", m_tlp_ep, rhs_.m_tlp_ep, $bits(m_tlp_ep) );
            if(pcie_6_1_support && m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}))
            do_compare &= comparer.compare_field_int("vendor_definition_vd_msg", vendor_definition_vd_msg, rhs_.vendor_definition_vd_msg, $bits(vendor_definition_vd_msg) );
            else begin
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("second_dw_byte_6_msg_rsvd", second_dw_byte_6_msg_rsvd,rhs_.second_dw_byte_6_msg_rsvd,$bits(second_dw_byte_6_msg_rsvd));
            end
          end else begin //NFM
            if(pcie_6_1_support && m_tlp_trans_type ==CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}))
            do_compare &= comparer.compare_field_int("vendor_definition_vd_msg", vendor_definition_vd_msg, rhs_.vendor_definition_vd_msg, $bits(vendor_definition_vd_msg) );
            else begin
              do_compare &= comparer.compare_field_int("m_tlp_tag", m_tlp_tag, rhs_.m_tlp_tag, $bits(m_tlp_tag));
            end
          end
        end //}
      end //}

case(m_tlp_trans_type) inside
        CDN_HPA_PCIE_TRANS_MEM_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE : begin
          if(!is_flit_mode || (!implcit_byte_enable_mem_tlps && is_flit_mode) || (m_tlp_trans_type!=CDN_HPA_PCIE_TRANS_MEM_TYPE)) begin
            do_compare &= comparer.compare_field_int("m_tlp_last_dw_be", m_tlp_last_dw_be, rhs_.m_tlp_last_dw_be, $bits(m_tlp_last_dw_be) );
            do_compare &= comparer.compare_field_int("m_tlp_first_dw_be", m_tlp_first_dw_be, rhs_.m_tlp_first_dw_be, $bits(m_tlp_first_dw_be) );
          end
          if((m_tlp_th && !is_flit_mode) || (is_flit_mode && m_hv inside {2'b01,2'b11})) do_compare &= comparer.compare_field_int("m_tlp_st_tag", m_tlp_st_tag, rhs_.m_tlp_st_tag, $bits(m_tlp_st_tag) );
        end
        CDN_HPA_PCIE_TRANS_MSG_TYPE : begin
          do_compare &= comparer.compare_field_int("m_tlp_msg_code", m_tlp_msg_code, rhs_.m_tlp_msg_code, $bits(m_tlp_msg_code) );
        end
      endcase
    end //}

    if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD, CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk,
    CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) begin
      do_compare &= comparer.compare_field_int("m_tlp_completer_id.bus_num", m_tlp_completer_id.bus_num, rhs_.m_tlp_completer_id.bus_num, $bits(m_tlp_completer_id.bus_num) );
      do_compare &= comparer.compare_field_int("m_tlp_completer_id.device_num", m_tlp_completer_id.device_num, rhs_.m_tlp_completer_id.device_num, $bits(m_tlp_completer_id.device_num) );
      do_compare &= comparer.compare_field_int("m_tlp_completer_id.function_num", m_tlp_completer_id.function_num, rhs_.m_tlp_completer_id.function_num, $bits(m_tlp_completer_id.function_num) );
      //`uvm_compare_enum("m_tlp_cpl_status", m_tlp_cpl_status, cdn_hpa_pcie_cpl_status_type_t, $bits(m_tlp_cpl_status)); // TODO
      if(is_flit_mode) do_compare &= comparer.compare_field_int("m_tlp_ep", m_tlp_ep, rhs_.m_tlp_ep, $bits(m_tlp_ep) );
      do_compare &= comparer.compare_field_int("m_tlp_cpl_status", m_tlp_cpl_status, rhs_.m_tlp_cpl_status, $bits(m_tlp_cpl_status) );
      if(!is_flit_mode) do_compare &= comparer.compare_field_int("m_tlp_cpl_bcm", m_tlp_cpl_bcm, rhs_.m_tlp_cpl_bcm, $bits(m_tlp_cpl_bcm) );
      if (!(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD})) // non-UIO
      if(rhs_.m_compare_byte_cnt)
        do_compare &= comparer.compare_field_int("m_tlp_cpl_byte_cnt", m_tlp_cpl_byte_cnt, rhs_.m_tlp_cpl_byte_cnt, $bits(m_tlp_cpl_byte_cnt) );
    end

    // Third & Fourth DWs
    case(m_tlp_trans_type) inside

      CDN_HPA_PCIE_TRANS_MEM_TYPE: begin
        do_compare &= comparer.compare_field_int("m_tlp_addr[31:2]", m_tlp_addr[31:2], rhs_.m_tlp_addr[31:2], $bits(m_tlp_addr[31:2]) );
        if((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_64))
        do_compare &= comparer.compare_field_int("m_tlp_addr[63:32]", m_tlp_addr[63:32], rhs_.m_tlp_addr[63:32], $bits(m_tlp_addr[63:32]) );
        if((m_tlp_th && !is_flit_mode) || (is_flit_mode && m_hv inside {2'b01,2'b11})) do_compare &= comparer.compare_field_int("m_tlp_ph", m_tlp_ph, rhs_.m_tlp_ph, $bits(m_tlp_ph) );
        if(!is_flit_mode && m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) do_compare &= comparer.compare_field_int("m_tlp_ats_tr_nw_field", m_tlp_ats_tr_nw_field, rhs_.m_tlp_ats_tr_nw_field, $bits(m_tlp_ats_tr_nw_field) );
        if(cxl_mode && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) do_compare &= comparer.compare_field_int("m_cxl_src",m_cxl_src,rhs_.m_cxl_src,$bits(m_cxl_src));
        do_compare &= comparer.compare_field_int("m_tlp_at_type", m_tlp_at_type,rhs_.m_tlp_at_type,$bits(m_tlp_at_type));
      end
      CDN_HPA_PCIE_TRANS_IO_TYPE : begin
        do_compare &= comparer.compare_field_int("m_tlp_addr[31:2]", m_tlp_addr[31:2], rhs_.m_tlp_addr[31:2], $bits(m_tlp_addr[31:2]) );
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("io_byte_11_rsvd_field_1_0",io_byte_11_rsvd_field_1_0 ,rhs_.io_byte_11_rsvd_field_1_0 ,$bits(io_byte_11_rsvd_field_1_0));
      end
      CDN_HPA_PCIE_TRANS_CFG_TYPE : begin
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.bus_num", m_tlp_completer_id.bus_num, rhs_.m_tlp_completer_id.bus_num, $bits(m_tlp_completer_id.bus_num) );
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.device_num", m_tlp_completer_id.device_num, rhs_.m_tlp_completer_id.device_num, $bits(m_tlp_completer_id.device_num) );
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.function_num", m_tlp_completer_id.function_num, rhs_.m_tlp_completer_id.function_num, $bits(m_tlp_completer_id.function_num) );
        do_compare &= comparer.compare_field_int("m_tlp_ext_reg_num", m_tlp_ext_reg_num, rhs_.m_tlp_ext_reg_num, $bits(m_tlp_ext_reg_num) );
        do_compare &= comparer.compare_field_int("m_tlp_reg_num", m_tlp_reg_num, rhs_.m_tlp_reg_num, $bits(m_tlp_reg_num) );
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("cfg_byte_10_rsvd_field_7_4",cfg_byte_10_rsvd_field_7_4 ,rhs_.cfg_byte_10_rsvd_field_7_4 ,$bits(cfg_byte_10_rsvd_field_7_4));
      end
    endcase

    // Cpl
    if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplD, CDN_HPA_PCIE_TLP_TYPE_CplLk, CDN_HPA_PCIE_TLP_TYPE_CplDLk}) begin
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.bus_num", m_tlp_requester_id.bus_num, rhs_.m_tlp_requester_id.bus_num, $bits(m_tlp_requester_id.bus_num) );
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.device_num", m_tlp_requester_id.device_num, rhs_.m_tlp_requester_id.device_num, $bits(m_tlp_requester_id.device_num) );
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.function_num", m_tlp_requester_id.function_num, rhs_.m_tlp_requester_id.function_num, $bits(m_tlp_requester_id.function_num) );
      if(!is_flit_mode) do_compare &= comparer.compare_field_int("m_tlp_tag", m_tlp_tag, rhs_.m_tlp_tag, $bits(m_tlp_tag) );
      else do_compare &= comparer.compare_field_int("m_tlp_tag",{m_tlp_14_bit_tagscale,m_tlp_t9,m_tlp_t8,m_tlp_tag} , {rhs_.m_tlp_14_bit_tagscale,rhs_.m_tlp_t9,rhs_.m_tlp_t8,rhs_.m_tlp_tag}, 14 );
      if(rhs_.m_compare_cpl_lower_addr)
      do_compare &= comparer.compare_field_int("m_tlp_cpl_lower_addr", m_tlp_cpl_lower_addr, rhs_.m_tlp_cpl_lower_addr, $bits(m_tlp_cpl_lower_addr) );
      if(!is_flit_mode && compare_rsvd_bits) do_compare &= comparer.compare_field_int("cpl_byte_12_rsvd_field_7", cpl_byte_12_rsvd_field_7,rhs_.cpl_byte_12_rsvd_field_7 ,$bits(cpl_byte_12_rsvd_field_7));
      //if(is_flit_mode) do_compare &= comparer.compare_field_int("m_completion_segment_differ", m_completion_segment_differ, rhs_.m_completion_segment_differ, $bits(m_completion_segment_differ) );
    end

    // Cpl UIO
    if (is_flit_mode && m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCplD}) begin
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.bus_num", m_tlp_requester_id.bus_num, rhs_.m_tlp_requester_id.bus_num, $bits(m_tlp_requester_id.bus_num) );
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.device_num", m_tlp_requester_id.device_num, rhs_.m_tlp_requester_id.device_num, $bits(m_tlp_requester_id.device_num) );
      do_compare &= comparer.compare_field_int("m_tlp_requester_id.function_num", m_tlp_requester_id.function_num, rhs_.m_tlp_requester_id.function_num, $bits(m_tlp_requester_id.function_num) );
      do_compare &= comparer.compare_field_int("m_tlp_cpl_cdl", m_tlp_cpl_cdl, rhs_.m_tlp_cpl_cdl, $bits(m_tlp_cpl_cdl));
      do_compare &= comparer.compare_field_int("m_tlp_tag",{m_tlp_14_bit_tagscale,m_tlp_t9,m_tlp_t8,m_tlp_tag} , {rhs_.m_tlp_14_bit_tagscale,rhs_.m_tlp_t9,rhs_.m_tlp_t8,rhs_.m_tlp_tag}, 14 );
      if (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIORdCplD) begin
        do_compare &= comparer.compare_field_int("m_tlp_cpl_lower_addr", m_tlp_cpl_lower_addr, rhs_.m_tlp_cpl_lower_addr, $bits(m_tlp_cpl_lower_addr));
        if (compare_rsvd_bits) do_compare &= comparer.compare_field_int("cpl_byte_11_rsvd_field_3_0", cpl_byte_11_rsvd_field_3_0, rhs_.cpl_byte_11_rsvd_field_3_0, $bits(cpl_byte_11_rsvd_field_3_0));
        if (compare_rsvd_bits) do_compare &= comparer.compare_field_int("cpl_byte_12_rsvd_field_7", cpl_byte_12_rsvd_field_7, rhs_.cpl_byte_12_rsvd_field_7, $bits(cpl_byte_12_rsvd_field_7));
      end
      else if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl, CDN_HPA_PCIE_TLP_TYPE_UIORdCpl}) begin
        if (compare_rsvd_bits) do_compare &= comparer.compare_field_int("cpl_byte_11_rsvd_field_7_4", cpl_byte_11_rsvd_field_7_4, rhs_.cpl_byte_11_rsvd_field_7_4, $bits(cpl_byte_11_rsvd_field_7_4));
        if (compare_rsvd_bits) do_compare &= comparer.compare_field_int("cpl_byte_11_rsvd_field_3_0", cpl_byte_11_rsvd_field_3_0, rhs_.cpl_byte_11_rsvd_field_3_0, $bits(cpl_byte_11_rsvd_field_3_0));
        if (compare_rsvd_bits) do_compare &= comparer.compare_field_int("cpl_byte_12_rsvd_field_7", cpl_byte_12_rsvd_field_7, rhs_.cpl_byte_12_rsvd_field_7, $bits(cpl_byte_12_rsvd_field_7));
        if (compare_rsvd_bits) do_compare &= comparer.compare_field_int("cpl_byte_12_rsvd_field_4_0", cpl_byte_12_rsvd_field_4_0, rhs_.cpl_byte_12_rsvd_field_4_0, $bits(cpl_byte_12_rsvd_field_4_0));
      end
    end

    //Msgs
    if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) begin
      if(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}) begin
        if((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type0) || ((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type1)&&(m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_HIER_ID))) begin
          do_compare &= comparer.compare_field_int("m_tlp_completer_id.bus_num", m_tlp_completer_id.bus_num, rhs_.m_tlp_completer_id.bus_num, $bits(m_tlp_completer_id.bus_num) );
          do_compare &= comparer.compare_field_int("m_tlp_completer_id.device_num", m_tlp_completer_id.device_num, rhs_.m_tlp_completer_id.device_num, $bits(m_tlp_completer_id.device_num) );
          do_compare &= comparer.compare_field_int("m_tlp_completer_id.function_num", m_tlp_completer_id.function_num, rhs_.m_tlp_completer_id.function_num, $bits(m_tlp_completer_id.function_num) );
        end else begin
          //denali packet has no field for populating m_tlp_hier_vmsg_hierarchy_id
          //WHen BDF field used to populate the same, we get denali error. How we are not getting error ??
          do_compare &= comparer.compare_field_int("m_tlp_hier_vmsg_hierarchy_id",m_tlp_hier_vmsg_hierarchy_id,rhs_.m_tlp_hier_vmsg_hierarchy_id,$bits(m_tlp_hier_vmsg_hierarchy_id));
        end
        do_compare &= comparer.compare_field_int("m_tlp_vendor_id",m_tlp_vendor_id,rhs_.m_tlp_vendor_id,$bits(m_tlp_vendor_id));
        do_compare &= comparer.compare_field_int("m_tlp_vendor_msg",m_tlp_vendor_msg,rhs_.m_tlp_vendor_msg,$bits(m_tlp_vendor_msg));

        if(cxl_mode && (cxl_version == 2 && cxl_mode ==1 && vdm_for_cxl==1) && (m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_Msg && m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0}) && (m_cxl_vdm_pm_logical_opcode != CDN_HPA_VDM_STD_VD_TYPE0)) begin //{
          do_compare &= comparer.compare_field_int("msg_cxl_vdm_msg_fw_interrupt_vector", msg_cxl_vdm_msg_fw_interrupt_vector, rhs_.msg_cxl_vdm_msg_fw_interrupt_vector, $bits(msg_cxl_vdm_msg_fw_interrupt_vector) );
          if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_cxl_vdm_msg_bits_rsvd", msg_cxl_vdm_msg_bits_rsvd, rhs_.msg_cxl_vdm_msg_bits_rsvd, $bits(msg_cxl_vdm_msg_bits_rsvd) );
        end //}

        if(cxl_mode &&(m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0}) && (m_cxl_vdm_pm_logical_opcode != CDN_HPA_VDM_STD_VD_TYPE0)) begin //{
          if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_pm_cxl_vnd_msg_byte_12_14_rsvd",msg_pm_cxl_vnd_msg_byte_12_14_rsvd,rhs_.msg_pm_cxl_vnd_msg_byte_12_14_rsvd,$bits(msg_pm_cxl_vnd_msg_byte_12_14_rsvd));
          do_compare &= comparer.compare_field_int("m_cxl_vdm_pm_logical_opcode", m_cxl_vdm_pm_logical_opcode, rhs_.m_cxl_vdm_pm_logical_opcode, $bits(m_cxl_vdm_pm_logical_opcode) );
          do_compare &= comparer.compare_field_int("m_cxl_vdm_pm_agt_id", m_cxl_vdm_pm_agt_id, rhs_.m_cxl_vdm_pm_agt_id, $bits(m_cxl_vdm_pm_agt_id) );
          if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_pm_agt_id_rsvd_bit", m_cxl_vdm_pm_agt_id_rsvd_bit, rhs_.m_cxl_vdm_pm_agt_id_rsvd_bit, $bits(m_cxl_vdm_pm_agt_id_rsvd_bit) );
          do_compare &= comparer.compare_field_int("m_cxl_vdm_parameter", m_cxl_vdm_parameter, rhs_.m_cxl_vdm_parameter, $bits(m_cxl_vdm_parameter) );
          do_compare &= comparer.compare_field_int("m_cxl_vdm_payload", m_cxl_vdm_payload, rhs_.m_cxl_vdm_payload, $bits(m_cxl_vdm_payload) );
          if (cxl_version == 2 && cxl_mode ==1  && vdm_for_cxl==1) begin
            if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin //{CDN_HPA_CXL_AGENT_INFO
              do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_req_or_rsp", m_cxl_vdm_agt_info_req_or_rsp, rhs_.m_cxl_vdm_agt_info_req_or_rsp, $bits(m_cxl_vdm_agt_info_req_or_rsp) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_index", m_cxl_vdm_agt_info_index, rhs_.m_cxl_vdm_agt_info_index, $bits(m_cxl_vdm_agt_info_index) );
              if(compare_rsvd_bits)
              do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_param_byte1_rsvd", m_cxl_vdm_agt_info_param_byte1_rsvd, rhs_.m_cxl_vdm_agt_info_param_byte1_rsvd, $bits(m_cxl_vdm_agt_info_param_byte1_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_capability_vector_bit0", m_cxl_vdm_agt_info_capability_vector_bit0, rhs_.m_cxl_vdm_agt_info_capability_vector_bit0, $bits(m_cxl_vdm_agt_info_capability_vector_bit0) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_capability_vector_bit1", m_cxl_vdm_agt_info_capability_vector_bit1, rhs_.m_cxl_vdm_agt_info_capability_vector_bit1, $bits(m_cxl_vdm_agt_info_capability_vector_bit1) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_payload_rsvd_93_3", m_cxl_vdm_agt_info_payload_rsvd_93_3, rhs_.m_cxl_vdm_agt_info_payload_rsvd_93_3, $bits(m_cxl_vdm_agt_info_payload_rsvd_93_3) );
            end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin //{CDN_HPA_CXL_RESET_PREP
              do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_req_or_rsp", m_cxl_vdm_resetprep_req_or_rsp, rhs_.m_cxl_vdm_resetprep_req_or_rsp, $bits(m_cxl_vdm_resetprep_req_or_rsp) );
              if(compare_rsvd_bits)
              do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_param_byte0_1_rsvd", m_cxl_vdm_resetprep_param_byte0_1_rsvd, rhs_.m_cxl_vdm_resetprep_param_byte0_1_rsvd, $bits(m_cxl_vdm_resetprep_param_byte0_1_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_reset_type", m_cxl_vdm_resetprep_reset_type, rhs_.m_cxl_vdm_resetprep_reset_type, $bits(m_cxl_vdm_resetprep_reset_type) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_prep_type", m_cxl_vdm_resetprep_prep_type, rhs_.m_cxl_vdm_resetprep_prep_type, $bits(m_cxl_vdm_resetprep_prep_type) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_payload_rsvd_95_9", m_cxl_vdm_resetprep_payload_rsvd_95_9, rhs_.m_cxl_vdm_resetprep_payload_rsvd_95_9, $bits(m_cxl_vdm_resetprep_payload_rsvd_95_9) );
            end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin //{CDN_HPA_CXL_PM_REQ_RSP_GO
              do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_req_or_rsp", m_cxl_vdm_pmreq_req_or_rsp, rhs_.m_cxl_vdm_pmreq_req_or_rsp, $bits(m_cxl_vdm_pmreq_req_or_rsp) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_param_bit1_rsvd", m_cxl_vdm_pmreq_param_bit1_rsvd, rhs_.m_cxl_vdm_pmreq_param_bit1_rsvd, $bits(m_cxl_vdm_pmreq_param_bit1_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_go", m_cxl_vdm_pmreq_go, rhs_.m_cxl_vdm_pmreq_go, $bits(m_cxl_vdm_pmreq_go) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_param_byte0_1_rsvd", m_cxl_vdm_pmreq_param_byte0_1_rsvd, rhs_.m_cxl_vdm_pmreq_param_byte0_1_rsvd, $bits(m_cxl_vdm_pmreq_param_byte0_1_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_ltr_2", m_cxl_vdm_pmreq_ltr_2, rhs_.m_cxl_vdm_pmreq_ltr_2, $bits(m_cxl_vdm_pmreq_ltr_2) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_payload_rsvd", m_cxl_vdm_pmreq_payload_rsvd, rhs_.m_cxl_vdm_pmreq_payload_rsvd, $bits(m_cxl_vdm_pmreq_payload_rsvd) );
            end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_GPF) begin //{ CDN_HPA_CXL_GPF
              do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_req_or_rsp", m_cxl_vdm_gpf_req_or_rsp, rhs_.m_cxl_vdm_gpf_req_or_rsp, $bits(m_cxl_vdm_gpf_req_or_rsp) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_param_byte0_1_rsvd", m_cxl_vdm_gpf_param_byte0_1_rsvd, rhs_.m_cxl_vdm_gpf_param_byte0_1_rsvd, $bits(m_cxl_vdm_gpf_param_byte0_1_rsvd) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_payload_rsvd_95_18", m_cxl_vdm_gpf_payload_rsvd_95_18, rhs_.m_cxl_vdm_gpf_payload_rsvd_95_18, $bits(m_cxl_vdm_gpf_payload_rsvd_95_18) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_payload_phase", m_cxl_vdm_gpf_payload_phase, rhs_.m_cxl_vdm_gpf_payload_phase, $bits(m_cxl_vdm_gpf_payload_phase) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_payload_rsvd_15_9", m_cxl_vdm_gpf_payload_rsvd_15_9, rhs_.m_cxl_vdm_gpf_payload_rsvd_15_9, $bits(m_cxl_vdm_gpf_payload_rsvd_15_9) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_status_bit8", m_cxl_vdm_gpf_status_bit8, rhs_.m_cxl_vdm_gpf_status_bit8, $bits(m_cxl_vdm_gpf_status_bit8) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_payload_rsvd_7_2", m_cxl_vdm_gpf_payload_rsvd_7_2, rhs_.m_cxl_vdm_gpf_payload_rsvd_7_2, $bits(m_cxl_vdm_gpf_payload_rsvd_7_2) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_payload_bit1", m_cxl_vdm_gpf_payload_bit1, rhs_.m_cxl_vdm_gpf_payload_bit1, $bits(m_cxl_vdm_gpf_payload_bit1) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_gpf_payload_bit0", m_cxl_vdm_gpf_payload_bit0, rhs_.m_cxl_vdm_gpf_payload_bit0, $bits(m_cxl_vdm_gpf_payload_bit0) );
            end else begin //CDN_HPA_CXL_CREDIT_RTN
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_crd_rtn_param_field_rsvd", m_cxl_vdm_crd_rtn_param_field_rsvd, rhs_.m_cxl_vdm_crd_rtn_param_field_rsvd, $bits(m_cxl_vdm_crd_rtn_param_field_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_crd_rtn_payload_num_credits", m_cxl_vdm_crd_rtn_payload_num_credits, rhs_.m_cxl_vdm_crd_rtn_payload_num_credits, $bits(m_cxl_vdm_crd_rtn_payload_num_credits) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_crd_rtn_payload_tgt_agt_id", m_cxl_vdm_crd_rtn_payload_tgt_agt_id, rhs_.m_cxl_vdm_crd_rtn_payload_tgt_agt_id, $bits(m_cxl_vdm_crd_rtn_payload_tgt_agt_id) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_crd_rtn_payload_rsvd", m_cxl_vdm_crd_rtn_payload_rsvd, rhs_.m_cxl_vdm_crd_rtn_payload_rsvd, $bits(m_cxl_vdm_crd_rtn_payload_rsvd) );
            end
          end else if (cxl_version == 1 && cxl_mode ==1  && vdm_for_cxl==1) begin
            if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin
              do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_req_or_rsp", m_cxl_vdm_agt_info_req_or_rsp, rhs_.m_cxl_vdm_agt_info_req_or_rsp, $bits(m_cxl_vdm_agt_info_req_or_rsp) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_index", m_cxl_vdm_agt_info_index, rhs_.m_cxl_vdm_agt_info_index, $bits(m_cxl_vdm_agt_info_index) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_param_byte1_rsvd", m_cxl_vdm_agt_info_param_byte1_rsvd, rhs_.m_cxl_vdm_agt_info_param_byte1_rsvd, $bits(m_cxl_vdm_agt_info_param_byte1_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_revision_id", m_cxl_vdm_agt_info_revision_id, rhs_.m_cxl_vdm_agt_info_revision_id, $bits(m_cxl_vdm_agt_info_revision_id) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_agt_info_payload_rsvd", m_cxl_vdm_agt_info_payload_rsvd, rhs_.m_cxl_vdm_agt_info_payload_rsvd, $bits(m_cxl_vdm_agt_info_payload_rsvd) );
            end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin
              do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_req_or_rsp", m_cxl_vdm_resetprep_req_or_rsp, rhs_.m_cxl_vdm_resetprep_req_or_rsp, $bits(m_cxl_vdm_resetprep_req_or_rsp) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_param_byte0_1_rsvd", m_cxl_vdm_resetprep_param_byte0_1_rsvd, rhs_.m_cxl_vdm_resetprep_param_byte0_1_rsvd, $bits(m_cxl_vdm_resetprep_param_byte0_1_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_reset_type", m_cxl_vdm_resetprep_reset_type, rhs_.m_cxl_vdm_resetprep_reset_type, $bits(m_cxl_vdm_resetprep_reset_type) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_prep_type", m_cxl_vdm_resetprep_prep_type, rhs_.m_cxl_vdm_resetprep_prep_type, $bits(m_cxl_vdm_resetprep_prep_type) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_phase", m_cxl_vdm_resetprep_phase, rhs_.m_cxl_vdm_resetprep_phase, $bits(m_cxl_vdm_resetprep_phase) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_resetprep_payload_rsvd", m_cxl_vdm_resetprep_payload_rsvd, rhs_.m_cxl_vdm_resetprep_payload_rsvd, $bits(m_cxl_vdm_resetprep_payload_rsvd) );
            end else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin
              do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_req_or_rsp", m_cxl_vdm_pmreq_req_or_rsp, rhs_.m_cxl_vdm_pmreq_req_or_rsp, $bits(m_cxl_vdm_pmreq_req_or_rsp) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_ea", m_cxl_vdm_pmreq_ea, rhs_.m_cxl_vdm_pmreq_ea, $bits(m_cxl_vdm_pmreq_ea) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_go", m_cxl_vdm_pmreq_go, rhs_.m_cxl_vdm_pmreq_go, $bits(m_cxl_vdm_pmreq_go) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_param_byte0_1_rsvd", m_cxl_vdm_pmreq_param_byte0_1_rsvd, rhs_.m_cxl_vdm_pmreq_param_byte0_1_rsvd, $bits(m_cxl_vdm_pmreq_param_byte0_1_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_ltr", m_cxl_vdm_pmreq_ltr, rhs_.m_cxl_vdm_pmreq_ltr, $bits(m_cxl_vdm_pmreq_ltr) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_pmreq_payload_rsvd", m_cxl_vdm_pmreq_payload_rsvd, rhs_.m_cxl_vdm_pmreq_payload_rsvd, $bits(m_cxl_vdm_pmreq_payload_rsvd) );
            end else begin //CDN_HPA_CXL_CREDIT_RTN
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_crd_rtn_param_field_rsvd", m_cxl_vdm_crd_rtn_param_field_rsvd, rhs_.m_cxl_vdm_crd_rtn_param_field_rsvd, $bits(m_cxl_vdm_crd_rtn_param_field_rsvd) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_crd_rtn_payload_num_credits", m_cxl_vdm_crd_rtn_payload_num_credits, rhs_.m_cxl_vdm_crd_rtn_payload_num_credits, $bits(m_cxl_vdm_crd_rtn_payload_num_credits) );
              do_compare &= comparer.compare_field_int("m_cxl_vdm_crd_rtn_payload_tgt_agt_id", m_cxl_vdm_crd_rtn_payload_tgt_agt_id, rhs_.m_cxl_vdm_crd_rtn_payload_tgt_agt_id, $bits(m_cxl_vdm_crd_rtn_payload_tgt_agt_id) );
              if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("m_cxl_vdm_crd_rtn_payload_rsvd", m_cxl_vdm_crd_rtn_payload_rsvd, rhs_.m_cxl_vdm_crd_rtn_payload_rsvd, $bits(m_cxl_vdm_crd_rtn_payload_rsvd) );
            end
          end
        end//}


        if((m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_VD_Type1)&&(m_tlp_vdm_msg_subtype != CDN_HPA_PCIE_TLP_VDM_STD_VD_TYPE1))
        do_compare &= comparer.compare_field_int("m_tlp_vdm_msg_subtype",m_tlp_vdm_msg_subtype,rhs_.m_tlp_vdm_msg_subtype,$bits(m_tlp_vdm_msg_subtype));
        if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}) begin
          do_compare &= comparer.compare_field_int("m_tlp_frs_msg_reason", m_tlp_frs_msg_reason, rhs_.m_tlp_frs_msg_reason, $bits(m_tlp_frs_msg_reason) );
          if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_frs_byte_13_15_rsvd",msg_frs_byte_13_15_rsvd ,rhs_.msg_frs_byte_13_15_rsvd ,$bits(msg_frs_byte_13_15_rsvd));
        end
        if(!(m_tl_layer_scoreboard && m_ide_prefix_present)) begin
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_HIER_ID}) begin
            do_compare &= comparer.compare_field("m_tlp_hier_vmsg_system_guid", m_tlp_hier_vmsg_system_guid, rhs_.m_tlp_hier_vmsg_system_guid, $bits(m_tlp_hier_vmsg_system_guid) );
            do_compare &= comparer.compare_field_int("m_tlp_hier_vmsg_guid_authority_id", m_tlp_hier_vmsg_guid_authority_id, rhs_.m_tlp_hier_vmsg_guid_authority_id, $bits(m_tlp_hier_vmsg_guid_authority_id) );
          end
          if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN})begin
            do_compare &= comparer.compare_field_int("m_tlp_ln_msg_cacheline_addr", m_tlp_ln_msg_cacheline_addr, rhs_.m_tlp_ln_msg_cacheline_addr, $bits(m_tlp_ln_msg_cacheline_addr) );
            do_compare &= comparer.compare_field_int("m_tlp_ln_msg_nr",m_tlp_ln_msg_nr ,rhs_.m_tlp_ln_msg_nr ,$bits(m_tlp_ln_msg_nr));
            if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_ln_payload_rsvd",msg_ln_payload_rsvd ,rhs_.msg_ln_payload_rsvd ,$bits(msg_ln_payload_rsvd));
          end
        end
        if((m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_LN,CDN_HPA_PCIE_TLP_VDM_DRS}) begin
          if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_ln_drs_byte_13_15_rsvd",msg_ln_drs_byte_13_15_rsvd ,rhs_.msg_ln_drs_byte_13_15_rsvd ,$bits(msg_ln_drs_byte_13_15_rsvd));
        end
      end else if (m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.bus_num", m_tlp_completer_id.bus_num, rhs_.m_tlp_completer_id.bus_num, $bits(m_tlp_completer_id.bus_num) );
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.device_num", m_tlp_completer_id.device_num, rhs_.m_tlp_completer_id.device_num, $bits(m_tlp_completer_id.device_num) );
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.function_num", m_tlp_completer_id.function_num, rhs_.m_tlp_completer_id.function_num, $bits(m_tlp_completer_id.function_num) );
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_inv_req_byte_10_15_rsvd",msg_inv_req_byte_10_15_rsvd ,rhs_.msg_inv_req_byte_10_15_rsvd ,$bits(msg_inv_req_byte_10_15_rsvd));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_AT_Invalidate_Complete) begin
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.bus_num", m_tlp_completer_id.bus_num, rhs_.m_tlp_completer_id.bus_num, $bits(m_tlp_completer_id.bus_num) );
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.device_num", m_tlp_completer_id.device_num, rhs_.m_tlp_completer_id.device_num, $bits(m_tlp_completer_id.device_num) );
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.function_num", m_tlp_completer_id.function_num, rhs_.m_tlp_completer_id.function_num, $bits(m_tlp_completer_id.function_num) );
        do_compare &= comparer.compare_field_int("m_inv_cpl_cnt", m_inv_cpl_cnt, rhs_.m_inv_cpl_cnt, $bits(m_inv_cpl_cnt) );
        do_compare &= comparer.compare_field_int("m_tlp_itag_vector", m_tlp_itag_vector, rhs_.m_tlp_itag_vector, $bits(m_tlp_itag_vector) );
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_inv_cpl_byte_10_11_rsvd",msg_inv_cpl_byte_10_11_rsvd ,rhs_.msg_inv_cpl_byte_10_11_rsvd ,$bits(msg_inv_cpl_byte_10_11_rsvd));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_LTR) begin
        do_compare &= comparer.compare_field_int("m_tlp_ltr_msg_no_snoop_latency", m_tlp_ltr_msg_no_snoop_latency, rhs_.m_tlp_ltr_msg_no_snoop_latency, $bits(m_tlp_ltr_msg_no_snoop_latency) );
        do_compare &= comparer.compare_field_int("m_tlp_ltr_msg_snoop_latency", m_tlp_ltr_msg_snoop_latency, rhs_.m_tlp_ltr_msg_snoop_latency, $bits(m_tlp_ltr_msg_snoop_latency) );
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_ltr_byte_8_11_rsvd",msg_ltr_byte_8_11_rsvd ,rhs_.msg_ltr_byte_8_11_rsvd ,$bits(msg_ltr_byte_8_11_rsvd));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Request) begin
        do_compare &= comparer.compare_field_int("m_page_addr", m_page_addr, rhs_.m_page_addr, $bits(m_page_addr) );
        do_compare &= comparer.compare_field_int("m_prGroupIndex", m_prGroupIndex, rhs_.m_prGroupIndex, $bits(m_prGroupIndex) );
        do_compare &= comparer.compare_field_int("m_prLastRequest", m_prLastRequest, rhs_.m_prLastRequest, $bits(m_prLastRequest) );
        do_compare &= comparer.compare_field_int("m_prWriteRequested", m_prWriteRequested, rhs_.m_prWriteRequested, $bits(m_prWriteRequested) );
        do_compare &= comparer.compare_field_int("m_prReadRequested", m_prReadRequested, rhs_.m_prReadRequested, $bits(m_prReadRequested) );
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Group_Response) begin
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.bus_num", m_tlp_completer_id.bus_num, rhs_.m_tlp_completer_id.bus_num, $bits(m_tlp_completer_id.bus_num) );
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.device_num", m_tlp_completer_id.device_num, rhs_.m_tlp_completer_id.device_num, $bits(m_tlp_completer_id.device_num) );
        do_compare &= comparer.compare_field_int("m_tlp_completer_id.function_num", m_tlp_completer_id.function_num, rhs_.m_tlp_completer_id.function_num, $bits(m_tlp_completer_id.function_num) );
        do_compare &= comparer.compare_field_int("m_prgResponseCode", m_prgResponseCode, rhs_.m_prgResponseCode, $bits(m_prgResponseCode) );
        do_compare &= comparer.compare_field_int("m_prGroupIndex", m_prGroupIndex, rhs_.m_prGroupIndex, $bits(m_prGroupIndex) );
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_pr_rsp_byte_10_field_3_1_rsvd",msg_pr_rsp_byte_10_field_3_1_rsvd ,rhs_.msg_pr_rsp_byte_10_field_3_1_rsvd ,$bits(msg_pr_rsp_byte_10_field_3_1_rsvd));
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_pr_rsp_byte_12_15_rsvd",msg_pr_rsp_byte_12_15_rsvd ,rhs_.msg_pr_rsp_byte_12_15_rsvd ,$bits(msg_pr_rsp_byte_12_15_rsvd));
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_OBFF) begin
        do_compare &= comparer.compare_field_int("m_obffCode", m_obffCode, rhs_.m_obffCode, $bits(m_obffCode) );
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_obff_byte_8_14_rsvd",msg_obff_byte_8_14_rsvd ,rhs_.msg_obff_byte_8_14_rsvd ,$bits(msg_obff_byte_8_14_rsvd));
      end else if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD) && (m_tlp_msg_code== CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD))) begin
        do_compare &= comparer.compare_field_int("m_ptmMasterTime", m_ptmMasterTime, rhs_.m_ptmMasterTime, $bits(m_ptmMasterTime) );
        if(!(m_tl_layer_scoreboard && m_ide_prefix_present)) begin
          do_compare &= comparer.compare_field_int("m_ptmPropagationDelay", m_ptmPropagationDelay, rhs_.m_ptmPropagationDelay, $bits(m_ptmPropagationDelay) );
        end
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Fail) begin
        do_compare &= comparer.compare_field_int("msg_ide_fail_stream_id",  msg_ide_fail_stream_id,  rhs_.msg_ide_fail_stream_id,  $bits(msg_ide_fail_stream_id) );
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Sync) begin
        do_compare &= comparer.compare_field_int("msg_ide_sync_pr_sent_cnt_np",  msg_ide_sync_pr_sent_cnt_np,  rhs_.msg_ide_sync_pr_sent_cnt_np,  $bits(msg_ide_sync_pr_sent_cnt_np) );
        do_compare &= comparer.compare_field_int("msg_ide_sync_pr_sent_cnt_cpl", msg_ide_sync_pr_sent_cnt_cpl, rhs_.msg_ide_sync_pr_sent_cnt_cpl, $bits(msg_ide_sync_pr_sent_cnt_cpl) );
      end else if(m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_IDE_Escort) begin
        do_compare &= comparer.compare_field_int("msg_ide_escort_sse", msg_ide_escort_sse, rhs_.msg_ide_escort_sse, $bits(msg_ide_escort_sse) );
      end else begin //All other messages
        if(compare_rsvd_bits) do_compare &= comparer.compare_field_int("msg_cmn_byte_8_15_rsvd", msg_cmn_byte_8_15_rsvd, rhs_.msg_cmn_byte_8_15_rsvd, $bits(msg_cmn_byte_8_15_rsvd) );
      end
    end

    //Compare OHC fields in flit mode
    if(is_flit_mode) begin //{
      if(m_ohc_hdr.ohc_a_present) begin //{
        do_compare &= comparer.compare_field_int("m_ohc_a", m_ohc_a, rhs_.m_ohc_a, $bits(m_ohc_a) );
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE}) begin //{
          do_compare &= comparer.compare_field_int("m_pasid_prefix_present", m_pasid_prefix_present, rhs_.m_pasid_prefix_present, $bits(m_pasid_prefix_present) );
          if(m_pasid_prefix_present) begin
            do_compare &= comparer.compare_field_int("m_pasid_pri_value", m_pasid_pri_value, rhs_.m_pasid_pri_value, $bits(m_pasid_pri_value) );
            do_compare &= comparer.compare_field_int("m_pasid_exec_value", m_pasid_exec_value, rhs_.m_pasid_exec_value, $bits(m_pasid_exec_value) );
            do_compare &= comparer.compare_field_int("m_pasid_value", m_pasid_value, rhs_.m_pasid_value, $bits(m_pasid_value) );
          end
        end else if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MSG_TYPE}) begin //}{
          do_compare &= comparer.compare_field_int("m_pasid_prefix_present", m_pasid_prefix_present, rhs_.m_pasid_prefix_present, $bits(m_pasid_prefix_present) );
          if(m_pasid_prefix_present) begin
            do_compare &= comparer.compare_field_int("m_pasid_pri_value", m_pasid_pri_value, rhs_.m_pasid_pri_value, $bits(m_pasid_pri_value) );
            do_compare &= comparer.compare_field_int("m_pasid_value", m_pasid_value, rhs_.m_pasid_value, $bits(m_pasid_value) );
          end
          do_compare &= comparer.compare_field_int("m_destination_segment_valid", m_destination_segment_valid, rhs_.m_destination_segment_valid, $bits(m_destination_segment_valid) );
          if(m_destination_segment_valid) do_compare &= comparer.compare_field_int("m_destination_segment", m_destination_segment, rhs_.m_destination_segment, $bits(m_destination_segment) );
        end else if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE,CDN_HPA_PCIE_TRANS_CPL_TYPE}) begin //}{
          do_compare &= comparer.compare_field_int("m_destination_segment_valid", m_destination_segment_valid, rhs_.m_destination_segment_valid, $bits(m_destination_segment_valid) );
          if(m_destination_segment_valid) do_compare &= comparer.compare_field_int("m_destination_segment", m_destination_segment, rhs_.m_destination_segment, $bits(m_destination_segment) );
          if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE}) begin //{
            if(rhs_.m_compare_completer_segment)
              do_compare &= comparer.compare_field_int("m_completer_segment", m_completer_segment, rhs_.m_completer_segment, $bits(m_completer_segment) );
          end //}
        end //}
      end //}
      if(m_ohc_hdr.ohc_b_present) begin //{
        do_compare &= comparer.compare_field_int("m_ohc_b", m_ohc_b, rhs_.m_ohc_b, $bits(m_ohc_b) );
        do_compare &= comparer.compare_field_int("m_hv", m_hv, rhs_.m_hv, $bits(m_hv) );
        do_compare &= comparer.compare_field_int("m_ama_valid", m_ama_valid, rhs_.m_ama_valid, $bits(m_ama_valid) );
        if(m_ama_valid) do_compare &= comparer.compare_field_int("m_ama_value", m_ama_value, rhs_.m_ama_value, $bits(m_ama_value) );
      end  //}
      if(m_ohc_hdr.ohc_c_present) begin//{
        //soumitm :: as ll individual fields are being compared separately, no need to compare combined OHC-C.
        //do_compare &= comparer.compare_field_int("m_ohc_c", m_ohc_c, rhs_.m_ohc_c, $bits(m_ohc_c) );
        if(m_requester_segment_valid) do_compare &= comparer.compare_field_int("m_requester_segment", m_requester_segment, rhs_.m_requester_segment, $bits(m_requester_segment) );
        //soumitm :: PR_SENT counter is added internally by the IDE design. VIP has protocol checks to detect any PR_CNTR issues
        //do_compare &= comparer.compare_field_int("m_pr_sent_counter", m_pr_sent_counter, rhs_.m_pr_sent_counter, $bits(m_pr_sent_counter) );
        do_compare &= comparer.compare_field_int("m_stream_id", m_stream_id, rhs_.m_stream_id, $bits(m_stream_id) );
        do_compare &= comparer.compare_field_int("m_sub_stream", m_sub_stream, rhs_.m_sub_stream, $bits(m_sub_stream) );
        do_compare &= comparer.compare_field_int("m_requester_segment_valid", m_requester_segment_valid, rhs_.m_requester_segment_valid, $bits(m_requester_segment_valid) );
        //soumitm :: TODO :: K bit comparison :: check for CDNS_IDE, disable for Rianta
        do_compare &= comparer.compare_field_int("m_ide_k", m_ide_k, rhs_.m_ide_k, $bits(m_ide_k) );
        do_compare &= comparer.compare_field_int("m_ide_t", m_ide_t, rhs_.m_ide_t, $bits(m_ide_t) );
      end  //}
      if(m_ohc_hdr.ohc_ex_present!=no_ohc_ex_present) begin
        foreach(m_ohc_e[i]) begin
          do_compare &= comparer.compare_field_int($psprintf("m_ohc_e[%0d]",i), m_ohc_e[i], rhs_.m_ohc_e[i], 32);
        end
      end
    end //}

    if(is_flit_mode && compare_rsvd_bits) begin //{
      if(m_ohc_hdr.ohc_a_present) begin
        if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)) &&
        (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) begin
          do_compare &= comparer.compare_field_int("m_tlp_ats_tr_nw_field", m_tlp_ats_tr_nw_field, rhs_.m_tlp_ats_tr_nw_field, $bits(m_tlp_ats_tr_nw_field) );
        end else if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MEM_TYPE}) do_compare &= comparer.compare_field_int("m_ohc_a1_byte_0_field_7_rsvd", m_ohc_a1_byte_0_field_7_rsvd, rhs_.m_ohc_a1_byte_0_field_7_rsvd, $bits(m_ohc_a1_byte_0_field_7_rsvd) );
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE}) do_compare &= comparer.compare_field_int("m_ohc_a2_byte_0_2_rsvd", m_ohc_a2_byte_0_2_rsvd, rhs_.m_ohc_a2_byte_0_2_rsvd, $bits(m_ohc_a2_byte_0_2_rsvd) );
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE}) begin
          do_compare &= comparer.compare_field_int("m_ohc_a3_byte_1_rsvd", m_ohc_a3_byte_1_rsvd, rhs_.m_ohc_a3_byte_1_rsvd, $bits(m_ohc_a3_byte_1_rsvd) );
          do_compare &= comparer.compare_field_int("m_ohc_a3_byte_2_rsvd", m_ohc_a3_byte_2_rsvd, rhs_.m_ohc_a3_byte_2_rsvd, $bits(m_ohc_a3_byte_2_rsvd) );
        end
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_MSG_TYPE}) begin
          if(pcie_6_1_support && m_tlp_msg_code==CDN_HPA_PCIE_TLP_MSG_PR_Request) begin
            do_compare &= comparer.compare_field_int("m_ohc_a1_byte_0_field_7_rsvd", m_ohc_a1_byte_0_field_7_rsvd, rhs_.m_ohc_a1_byte_0_field_7_rsvd, $bits(m_ohc_a1_byte_0_field_7_rsvd) );
            do_compare &= comparer.compare_field_int("m_ohc_a1_byte_3_rsvd", m_ohc_a1_byte_3_rsvd, rhs_.m_ohc_a1_byte_3_rsvd, $bits(m_ohc_a1_byte_3_rsvd) );
          end else begin
            do_compare &= comparer.compare_field_int("m_ohc_a4_byte_2_field_5_4_rsvd", m_ohc_a4_byte_2_field_5_4_rsvd, rhs_.m_ohc_a4_byte_2_field_5_4_rsvd, $bits(m_ohc_a4_byte_2_field_5_4_rsvd) );
          end
        end
        if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE}) do_compare &= comparer.compare_field_int("m_ohc_a5_byte_2_3_rsvd", m_ohc_a5_byte_2_3_rsvd, rhs_.m_ohc_a5_byte_2_3_rsvd, $bits(m_ohc_a5_byte_2_3_rsvd) );
      end
      if(m_ohc_hdr.ohc_b_present) begin
        do_compare &= comparer.compare_field_int("m_ohc_b_byte_0_rsvd",m_ohc_b_byte_0_rsvd,rhs_.m_ohc_b_byte_0_rsvd, $bits(m_ohc_b_byte_0_rsvd));
      end
      if(m_ohc_hdr.ohc_c_present) begin
        do_compare &= comparer.compare_field_int("m_ohc_c_byte_3_field_2_rsvd",m_ohc_c_byte_3_field_2_rsvd,rhs_.m_ohc_c_byte_3_field_2_rsvd, $bits(m_ohc_c_byte_3_field_2_rsvd));
      end
    end //}

    //Payload check
    //if(m_ide_m == 1) begin //VIPSR-46601979, for aggregation fragments, CIPHER_OP callbacks dont provide decrypted data
    if(!(m_tl_layer_scoreboard && m_ide_prefix_present)) begin
      foreach(m_tlp_payload[i]) begin
        do_compare &= comparer.compare_field_int($psprintf("m_tlp_payload[%0d]",i), m_tlp_payload[i], rhs_.m_tlp_payload[i], 8);
      end
    end

   `ifndef PXC //TODO ankitm PXC
    //TS payload check
    if(is_flit_mode && compare_ecrc && m_ts) begin //{
      foreach(m_ts_payload[i]) begin
        do_compare &= comparer.compare_field_int($psprintf("m_ts_payload[%0d]",i), m_ts_payload[i], rhs_.m_ts_payload[i], 8);
      end
    end //}
   `endif

    //ECRC
    if(compare_ecrc && m_tlp_td && !is_flit_mode) begin //{
      do_compare &= comparer.compare_field_int("ecrc_val", ecrc_val, rhs_.ecrc_val, $bits(ecrc_val) );
    end //}

    if(is_ib_pkt) begin
     `ifndef PXC
      if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION) begin
        do_compare &= comparer.compare_field_int("hls_ib_cpl_meta_s.pf", hls_ib_cpl_meta_s.pf, rhs_.hls_ib_cpl_meta_s.pf, $bits(hls_ib_cpl_meta_s.pf) );
        do_compare &= comparer.compare_field_int("hls_ib_cpl_meta_s.vf", hls_ib_cpl_meta_s.vf, rhs_.hls_ib_cpl_meta_s.vf, $bits(hls_ib_cpl_meta_s.vf) );
        do_compare &= comparer.compare_field_int("hls_ib_cpl_meta_s.vf_or_pf", hls_ib_cpl_meta_s.vf_or_pf, rhs_.hls_ib_cpl_meta_s.vf_or_pf, $bits(hls_ib_cpl_meta_s.vf_or_pf) );
        do_compare &= comparer.compare_field_int("hls_ib_cpl_meta_s.cpl_complete", hls_ib_cpl_meta_s.cpl_complete, rhs_.hls_ib_cpl_meta_s.cpl_complete, $bits(hls_ib_cpl_meta_s.cpl_complete) );
        do_compare &= comparer.compare_field_int("hls_ib_cpl_meta_s.cpl_err_code", hls_ib_cpl_meta_s.cpl_err_code, rhs_.hls_ib_cpl_meta_s.cpl_err_code, $bits(hls_ib_cpl_meta_s.cpl_err_code) );
        `ifdef HPA_ARCH2
          do_compare &= comparer.compare_field_int("hls_ib_cpl_meta_s.generated_tlp", hls_ib_cpl_meta_s.generated_tlp, rhs_.hls_ib_cpl_meta_s.generated_tlp, $bits(hls_ib_cpl_meta_s.generated_tlp) );
        `endif
      end else begin //P/NP
        do_compare &= comparer.compare_field_int("hls_ib_p_np_meta_s.pf", hls_ib_p_np_meta_s.pf, rhs_.hls_ib_p_np_meta_s.pf, $bits(hls_ib_p_np_meta_s.pf) );
        do_compare &= comparer.compare_field_int("hls_ib_p_np_meta_s.vf", hls_ib_p_np_meta_s.vf, rhs_.hls_ib_p_np_meta_s.vf, $bits(hls_ib_p_np_meta_s.vf) );
        do_compare &= comparer.compare_field_int("hls_ib_p_np_meta_s.cxl_io", hls_ib_p_np_meta_s.cxl_io, rhs_.hls_ib_p_np_meta_s.cxl_io, $bits(hls_ib_p_np_meta_s.cxl_io) );
        do_compare &= comparer.compare_field_int("hls_ib_p_np_meta_s.vf_or_pf", hls_ib_p_np_meta_s.vf_or_pf, rhs_.hls_ib_p_np_meta_s.vf_or_pf, $bits(hls_ib_p_np_meta_s.vf_or_pf) );
        do_compare &= comparer.compare_field_int("hls_ib_p_np_meta_s.bar", hls_ib_p_np_meta_s.bar, rhs_.hls_ib_p_np_meta_s.bar, $bits(hls_ib_p_np_meta_s.bar) );
        do_compare &= comparer.compare_field_int("hls_ib_p_np_meta_s.bar_aperture", hls_ib_p_np_meta_s.bar_aperture, rhs_.hls_ib_p_np_meta_s.bar_aperture, $bits(hls_ib_p_np_meta_s.bar_aperture) );
        do_compare &= comparer.compare_field_int("hls_ib_p_np_meta_s.bar_prefetchable", hls_ib_p_np_meta_s.bar_prefetchable, rhs_.hls_ib_p_np_meta_s.bar_prefetchable, $bits(hls_ib_p_np_meta_s.bar_prefetchable) );
        `ifdef HPA_ARCH2
          do_compare &= comparer.compare_field_int("hls_ib_p_np_meta_s.generated_tlp", hls_ib_p_np_meta_s.generated_tlp, rhs_.hls_ib_p_np_meta_s.generated_tlp, $bits(hls_ib_p_np_meta_s.generated_tlp) );
        `endif
      end
     `endif
    end
    //do_compare &= comparer.compare_field_int("xx", xx, rhs_.xx, $bits(xx) );

  endfunction

  //------------------------------------------------------------------------
  // Function: do_copy
  // Extend the do_copy method for the physical member fields to copy
  //------------------------------------------------------------------------
  function void do_copy (uvm_object rhs);
    //cdn_hpa_pcie_tlp item;
    cdn_hpa_pcie_tlp_base item;
    super.do_copy(rhs);
  endfunction

  //------------------------------------------------------------------------
  // Function: convert2string
  // This function will convert the data type to string format
  //------------------------------------------------------------------------
  virtual function string convert2string();
    string s = super.convert2string();
    // TODO Add any specific format
    return s;
  endfunction

  //------------------------------------------------------------------------
  // Function: convert_bytes_to_dw_string
  // This function converts a byte array to 32-bit DW formatted string
  // Output format: 0xXXXXXXXX__0xXXXXXXXX__...
  //------------------------------------------------------------------------
  virtual function string convert_bytes_to_dw_string(bit [7:0] data[]);
    string result;
    int num_dws;
    bit [31:0] dw_val;
    
    num_dws = (data.size() + 3) / 4; // Round up to include partial DW
    result = "";
    
    for (int i = 0; i < num_dws; i++) begin
      dw_val = 0;
      // Pack 4 bytes into DW (big-endian: first byte is MSB)
      for (int j = 0; j < 4; j++) begin
        int byte_idx = (i * 4) + j;
        if (byte_idx < data.size())
          dw_val = (dw_val << 8) | data[byte_idx];
        else
          dw_val = (dw_val << 8); // Pad with zeros
      end
      if (i == 0)
        result = $psprintf("0x%08x", dw_val);
      else
        result = $psprintf("%s__0x%08x", result, dw_val);
    end
    
    return result;
  endfunction

  //------------------------------------------------------------------------
  // Function: byte_array
  // Pack bits into bytes and print out if requested via debug_en.
  // Use typedef to woraround not being able to return an array from a function
  //------------------------------------------------------------------------
  virtual function byte_array pack_bits_into_bytes (bit bits[]);
    int num_of_bytes;
    bit [7:0] packed_bytes[];

    // Check we have an integral number of bytes
    if (bits.size()%8!=0) begin
      `uvm_info(get_type_name(), $psprintf("Number of bits = %0d", bits.size()), UVM_NONE)
      `uvm_fatal(get_type_name(), "The number of bits is not an integral number of bytes!")
    end

    num_of_bytes = bits.size()/8;
    packed_bytes = new[num_of_bytes];
    for (int i=0; i<num_of_bytes; i++) begin
      packed_bytes[i] = {bits[7+(i*8)],
      bits[6+(i*8)],
      bits[5+(i*8)],
      bits[4+(i*8)],
      bits[3+(i*8)],
      bits[2+(i*8)],
      bits[1+(i*8)],
      bits[0+(i*8)]};
      if (debug_mode_en) begin
        `uvm_info(get_type_name(), $psprintf("packed_bytes[%0d]=0x%0h", i, packed_bytes[i]), UVM_NONE)
      end
    end

    if (debug_mode_en) begin
      foreach (bits[i]) begin
        if (i%8==0) begin
          `uvm_info(get_type_name(), "", UVM_NONE)
        end
        `uvm_info(get_type_name(), $psprintf("bits[%0d]=%0b", i, bits[i]), UVM_NONE)
      end
    end

    return packed_bytes;
  endfunction : pack_bits_into_bytes

  //----------------------------------------------------------------------------
  // Function: calc_crc_per_byte
  // Calculate CRC on a per byte basis (this is much faster because we're not
  // iterating over individual bits like calc_crc_per_bit function does)
  //----------------------------------------------------------------------------
  virtual function bit [31:0] calc_crc_per_byte(ref byte unsigned databyte_stream[],
    input int start_index = -1,
    input int end_index   = -1);
    bit [31:0] l_crc     = CRC32SEED;
    bit [31:0] l_new_crc = CRC32SEED;
    byte       l_data;
    byte       l_databyte_stream[];

    start_index = (start_index == -1) ? 0 : start_index;
    end_index   = (end_index   == -1) ? databyte_stream.size() : end_index;

    for(int loop_byte = start_index;
    loop_byte < end_index;
    loop_byte++) begin

      // Transpose byte (input reflected)
      for(int i = 0; i < 8; i++)
      l_data[i] = databyte_stream[loop_byte][7-i];

      l_new_crc[ 0] = l_data[6] ^ l_data[0] ^ l_crc[24] ^ l_crc[30];
      l_new_crc[ 1] = l_data[7] ^ l_data[6] ^ l_data[1] ^ l_data[0] ^ l_crc[24] ^ l_crc[25] ^ l_crc[30] ^ l_crc[31];
      l_new_crc[ 2] = l_data[7] ^ l_data[6] ^ l_data[2] ^ l_data[1] ^ l_data[0] ^ l_crc[24] ^ l_crc[25] ^ l_crc[26] ^ l_crc[30] ^ l_crc[31];
      l_new_crc[ 3] = l_data[7] ^ l_data[3] ^ l_data[2] ^ l_data[1] ^ l_crc[25] ^ l_crc[26] ^ l_crc[27] ^ l_crc[31];
      l_new_crc[ 4] = l_data[6] ^ l_data[4] ^ l_data[3] ^ l_data[2] ^ l_data[0] ^ l_crc[24] ^ l_crc[26] ^ l_crc[27] ^ l_crc[28] ^ l_crc[30];
      l_new_crc[ 5] = l_data[7] ^ l_data[6] ^ l_data[5] ^ l_data[4] ^ l_data[3] ^ l_data[1] ^ l_data[0] ^ l_crc[24] ^ l_crc[25] ^ l_crc[27] ^ l_crc[28] ^ l_crc[29] ^ l_crc[30] ^ l_crc[31];
      l_new_crc[ 6] = l_data[7] ^ l_data[6] ^ l_data[5] ^ l_data[4] ^ l_data[2] ^ l_data[1] ^ l_crc[25] ^ l_crc[26] ^ l_crc[28] ^ l_crc[29] ^ l_crc[30] ^ l_crc[31];
      l_new_crc[ 7] = l_data[7] ^ l_data[5] ^ l_data[3] ^ l_data[2] ^ l_data[0] ^ l_crc[24] ^ l_crc[26] ^ l_crc[27] ^ l_crc[29] ^ l_crc[31];
      l_new_crc[ 8] = l_data[4] ^ l_data[3] ^ l_data[1] ^ l_data[0] ^ l_crc[0] ^ l_crc[24] ^ l_crc[25] ^ l_crc[27] ^ l_crc[28];
      l_new_crc[ 9] = l_data[5] ^ l_data[4] ^ l_data[2] ^ l_data[1] ^ l_crc[1] ^ l_crc[25] ^ l_crc[26] ^ l_crc[28] ^ l_crc[29];
      l_new_crc[10] = l_data[5] ^ l_data[3] ^ l_data[2] ^ l_data[0] ^ l_crc[2] ^ l_crc[24] ^ l_crc[26] ^ l_crc[27] ^ l_crc[29];
      l_new_crc[11] = l_data[4] ^ l_data[3] ^ l_data[1] ^ l_data[0] ^ l_crc[3] ^ l_crc[24] ^ l_crc[25] ^ l_crc[27] ^ l_crc[28];
      l_new_crc[12] = l_data[6] ^ l_data[5] ^ l_data[4] ^ l_data[2] ^ l_data[1] ^ l_data[0] ^ l_crc[4] ^ l_crc[24] ^ l_crc[25] ^ l_crc[26] ^ l_crc[28] ^ l_crc[29] ^ l_crc[30];
      l_new_crc[13] = l_data[7] ^ l_data[6] ^ l_data[5] ^ l_data[3] ^ l_data[2] ^ l_data[1] ^ l_crc[5] ^ l_crc[25] ^ l_crc[26] ^ l_crc[27] ^ l_crc[29] ^ l_crc[30] ^ l_crc[31];
      l_new_crc[14] = l_data[7] ^ l_data[6] ^ l_data[4] ^ l_data[3] ^ l_data[2] ^ l_crc[6] ^ l_crc[26] ^ l_crc[27] ^ l_crc[28] ^ l_crc[30] ^ l_crc[31];
      l_new_crc[15] = l_data[7] ^ l_data[5] ^ l_data[4] ^ l_data[3] ^ l_crc[7] ^ l_crc[27] ^ l_crc[28] ^ l_crc[29] ^ l_crc[31];
      l_new_crc[16] = l_data[5] ^ l_data[4] ^ l_data[0] ^ l_crc[8] ^ l_crc[24] ^ l_crc[28] ^ l_crc[29];
      l_new_crc[17] = l_data[6] ^ l_data[5] ^ l_data[1] ^ l_crc[9] ^ l_crc[25] ^ l_crc[29] ^ l_crc[30];
      l_new_crc[18] = l_data[7] ^ l_data[6] ^ l_data[2] ^ l_crc[10] ^ l_crc[26] ^ l_crc[30] ^ l_crc[31];
      l_new_crc[19] = l_data[7] ^ l_data[3] ^ l_crc[11] ^ l_crc[27] ^ l_crc[31];
      l_new_crc[20] = l_data[4] ^ l_crc[12] ^ l_crc[28];
      l_new_crc[21] = l_data[5] ^ l_crc[13] ^ l_crc[29];
      l_new_crc[22] = l_data[0] ^ l_crc[14] ^ l_crc[24];
      l_new_crc[23] = l_data[6] ^ l_data[1] ^ l_data[0] ^ l_crc[15] ^ l_crc[24] ^ l_crc[25] ^ l_crc[30];
      l_new_crc[24] = l_data[7] ^ l_data[2] ^ l_data[1] ^ l_crc[16] ^ l_crc[25] ^ l_crc[26] ^ l_crc[31];
      l_new_crc[25] = l_data[3] ^ l_data[2] ^ l_crc[17] ^ l_crc[26] ^ l_crc[27];
      l_new_crc[26] = l_data[6] ^ l_data[4] ^ l_data[3] ^ l_data[0] ^ l_crc[18] ^ l_crc[24] ^ l_crc[27] ^ l_crc[28] ^ l_crc[30];
      l_new_crc[27] = l_data[7] ^ l_data[5] ^ l_data[4] ^ l_data[1] ^ l_crc[19] ^ l_crc[25] ^ l_crc[28] ^ l_crc[29] ^ l_crc[31];
      l_new_crc[28] = l_data[6] ^ l_data[5] ^ l_data[2] ^ l_crc[20] ^ l_crc[26] ^ l_crc[29] ^ l_crc[30];
      l_new_crc[29] = l_data[7] ^ l_data[6] ^ l_data[3] ^ l_crc[21] ^ l_crc[27] ^ l_crc[30] ^ l_crc[31];
      l_new_crc[30] = l_data[7] ^ l_data[4] ^ l_crc[22] ^ l_crc[28] ^ l_crc[31];
      l_new_crc[31] = l_data[5] ^ l_crc[23] ^ l_crc[29];

      l_crc = l_new_crc;
    end

    `uvm_info("calc_crc_per_byte",
    $sformatf("Calculated CRC for data[%0d:%0d]: 0x%0h", start_index, end_index - 1, l_crc),
    UVM_DEBUG)

    // Complement/invert the output
    l_crc = ~l_crc;

    `uvm_info("calc_crc_per_byte",
    $sformatf("Complement CRC is: 0x%0h", l_crc),
    UVM_DEBUG)

    return l_crc;

  endfunction : calc_crc_per_byte

  //----------------------------------------------------------------------------
  // Function: map_crc_bytes
  // Map the ECRC bits to TLP digest field as defined in Figure 2-46 from standard
  //----------------------------------------------------------------------------
  virtual function void map_crc_bytes(bit [31:0] crc_bits, ref byte unsigned crc_bytes[4]);
    //soumitm :: TODO :: replace with this
    //crc_bytes = {<< byte{ {<< bit{crc_bits}} }};

    for (int loop_byte = 0; loop_byte < 4; loop_byte++) begin
      byte l_ecrc_byte = crc_bits[loop_byte*8 +: 8];
      byte l_ecrc_byte_reversed;

      // First reverse the byte
      for (int loop_bit = 0; loop_bit < 8; loop_bit++)
      l_ecrc_byte_reversed[8-1-loop_bit] = l_ecrc_byte[loop_bit];

      // Map the byte
      crc_bytes[4-1-loop_byte] = l_ecrc_byte_reversed;
    end
  endfunction : map_crc_bytes

  //----------------------------------------------------------------------------
  // Function : pre_randomize
  // TLP generation prerequisites capabilities like MPS, MRS, Capability support
  // and enable.
  // This TLP needs to work in HLS to AXI Bridge set up, module level TB
  // and for PCIe VIP TLPs. So below approach is selected
  //----------------------------------------------------------------------------
  function void pre_randomize();

    if(1) begin
      uvm_sequencer_base      base_sqr;
      cdn_hpa_pcie_tlp_vseqr  seq_sqr;

      base_sqr = get_sequencer();
      if(base_sqr != null) begin
        if ($cast(seq_sqr, base_sqr)) begin
          tlp_sqr_handle = seq_sqr;
          //if($value$plusargs("CXL_IO_VDM_ONLY=%0d",vdm_for_cxl))
          //  vdm_for_cxl =1;
          //else vdm_for_cxl =0;
        end
      end
    end
    // AR: please use appropriate verbosity control or remove this entirely
    // `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM:cxl_mode=%0d", cxl_mode), UVM_DEBUG)

    if (m_pcie_dev_cfg == null) begin
      // device config is null means sequence has not set the target device
      // Randomize the device config in ENV once
      // and access device config from ENV/sequencer each time while TLP
      // is randomized.
      // As of now get the config from the sequencer and randomizes the TLP
      // NOTE : Reason for this approach:
      // Avoids the frequent mutiple access of config_db to get dev config.
      // To make it easy for bridge team
      uvm_sequencer_base      base_sqr;
      cdn_hpa_pcie_tlp_vseqr  seq_sqr;

      base_sqr = get_sequencer();
      if(base_sqr == null)
      `uvm_fatal("pre_randomize", " Seqr Null !!!");

      if (! $cast(seq_sqr, base_sqr)) begin
        `uvm_fatal("pre_randomize", "Cast failed!!!");
        return;
      end

      m_pcie_dev_cfg = seq_sqr.m_pcie_dev_cfg;

      // Select a random function of all functions for ID based routing
      // TODO for now
      // assert(std::randomize(m_sel_pf) with { m_sel_pf inside {[0: m_pcie_dev_cfg.m_sriov_info.num_pfs-1]}; });

      // Select a random BAR of all BARS which matches the required TLP for address
      // TODO I suppose random function is enough
      // assert(std::randomize(sel_bar) with { sel_bar >= 0; sel_bar < m_pcie_dev_cfg.m_device_bars.all_bars.size(); });

      end  /*else begin
      `uvm_info(get_full_name(),$psprintf("DBG_SEQ_ITEM: hpa item: dev_cfg handle is passed from sequence  %0s",m_pcie_dev_cfg.sprint(uvm_default_line_printer)),UVM_FULL);
      end */

      if(1) begin
        uvm_sequencer_base      base_sqr;
        cdn_hpa_pcie_tlp_vseqr  seq_sqr;

        base_sqr = get_sequencer();
        if(base_sqr != null) begin
          if ($cast(seq_sqr, base_sqr)) begin
            if(!m_pcie_dev_cfg.bypass_dut_type_chk) begin //Bypassing for Module Level ENVs
              `ifndef HLS_MODULE_MODE
                hpa_generation = seq_sqr.hpa_generation;
                is_flit_mode = seq_sqr.flit_mode_negotiated;
              `endif
            end
          end
        end
      end

      if (m_pcie_link_cfg == null) begin
        uvm_sequencer_base      base_sqr;
        cdn_hpa_pcie_tlp_vseqr  seq_sqr;

        base_sqr = get_sequencer();
        if (! $cast(seq_sqr, base_sqr)) begin
          `uvm_fatal("pre_randomize", "Cast failed!!!");
          return;
        end

        m_pcie_link_cfg= seq_sqr.m_pcie_link_cfg;
      end
      /* else begin
      `uvm_info(get_full_name(),$psprintf("DBG_SEQ_ITEM: hpa item: link_cfg handle is passed from sequence usp_dev_cfg %0s",m_pcie_link_cfg.usp_dev_config.sprint()),UVM_FULL);
      end */

      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)
      begin
        m_pcie_dut_dev_cfg = m_pcie_link_cfg.dsp_dev_config;
        //m_pcie_bfm_dev_cfg = m_pcie_link_cfg.usp_dev_config;
        //`uvm_info("DEBUG::DATA",$psprintf("m_pcie_dut_dev_cfg \n %0s",m_pcie_dut_dev_cfg.sprint()),UVM_DEBUG)
      end
      else
      begin
        m_pcie_dut_dev_cfg = m_pcie_link_cfg.usp_dev_config;
        //m_pcie_bfm_dev_cfg = m_pcie_link_cfg.dsp_dev_config;
        //`uvm_info("DEBUG::DATA",$psprintf("m_pcie_dut_dev_cfg \n %0s",m_pcie_dut_dev_cfg.sprint()),UVM_DEBUG)
      end

      if (m_pcie_dev_top_cfg == null) begin
        uvm_sequencer_base      base_sqr;
        cdn_hpa_pcie_tlp_vseqr  seq_sqr;

        base_sqr = get_sequencer();
        if (base_sqr == null || ! $cast(seq_sqr, base_sqr)) begin
          `uvm_fatal("pre_randomize", "Cast failed!!!");
          return;
        end

        m_pcie_dev_top_cfg= seq_sqr.m_pcie_dev_top_cfg;

      end

      pcie_6_1_support=m_pcie_dev_top_cfg.pcie_6_1_support;

      `ifdef HPA_ARCH2
        if(!m_pcie_dev_cfg.bypass_dut_type_chk) //Bypassing for Module Level ENVs
        hpa_generation = hpa_generation_2;
      `endif

      //soumitm :: TODO :: WHO is disabling this constraint??
      //move all disable directives to module testbench
      `ifndef CDNS_IDE
        `ifndef TOP_LEVEL_SIMS
          //Enablig this constraint for Module level so that m_tlp_tc
          //is not randomized from m_pcie_dev_cfg.m_unmapped_tc_list
          //tc_vc_map_based_tc_c.constraint_mode(0);
          `ifndef HLS_MODULE_MODE
            `ifndef TL_RX_MODULE_MODE
              c_td_constr.constraint_mode(0);
            `endif
          `endif
        `endif
      `endif

      `uvm_info(get_full_name(),$psprintf("hpa_generation = %0s, ", hpa_generation.name()),UVM_DEBUG)
      `uvm_info(get_full_name(),$psprintf("is_flit_mode = %0d pcie_6_1_support=%0d, ", is_flit_mode,pcie_6_1_support),UVM_DEBUG)

      //`uvm_info(get_full_name(),$psprintf("m_pcie_dev_top_cfg = %0s", m_pcie_dev_top_cfg.sprint()), UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf("m_pcie_dev_top_cfg.unmapped_tc_list = %0p", m_pcie_dev_top_cfg.m_unmapped_tc_list), UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf("m_pcie_dev_cfg.m_unmapped_tc_list= %0p", m_pcie_dev_cfg.m_unmapped_tc_list), UVM_DEBUG)

      if(m_pcie_dev_top_cfg.pf_config.size()==0) begin
        m_pcie_dev_top_cfg.pf_config[0] = m_pcie_dev_cfg;
      end
      super.pre_randomize();
      if (!std::randomize(target_vendor_id)) $fatal(1, "[guys] randomization failure");

      if (m_pcie_dev_top_cfg != null) begin
        if (m_pcie_dev_top_cfg.scenario != null) begin
          cxl_mode = m_pcie_dev_top_cfg.scenario.is_cxl_mode();
          if(m_pcie_dev_top_cfg.scenario.is_cxl_10()) cxl_version = 1;
          else if (m_pcie_dev_top_cfg.scenario.is_cxl_20()) cxl_version = 2;
          else if (m_pcie_dev_top_cfg.scenario.is_cxl_30()) cxl_version = 3;
          else cxl_version = 0;
          cxl_ldid_prefix = m_pcie_dev_top_cfg.scenario.cxl_ldid_prefix;
          vdm_for_cxl     = m_pcie_dev_top_cfg.scenario.vdm_for_cxl;
          is_cxl_pbr_mode = m_pcie_dev_top_cfg.scenario.is_cxl_pbr_mode();

          `uvm_info("DEBUG_CXL_VER", $psprintf(" TLP File  cxl_ver =%d cxl_mode=%d  vdm_for_cxl=%d cxl_ldid_prefix=%d, is_cxl_pbr_mode=%d m_pcie_dev_cfg.cxl_ldid=%h, m_cxl_ldid=%h,m_pcie_dev_cfg.m_pf_num=%d",cxl_version, cxl_mode, vdm_for_cxl,cxl_ldid_prefix, is_cxl_pbr_mode,m_pcie_dev_cfg.cxl_ldid,m_cxl_ldid,m_pcie_dev_cfg.m_pf_num), UVM_DEBUG)
        end

      end
      if(m_pcie_dev_top_cfg.intx_cntr == 0)
      m_pcie_dev_top_cfg.intx_pin_assert = 4'b0000;
      //`uvm_info(get_full_name(),$psprintf("pre_randomize m_pcie_dev_top_cfg.intx_pin_assert = %0h ",m_pcie_dev_top_cfg.intx_pin_assert),UVM_DEBUG)
      //`uvm_info("DEBUG_CXL_VER", $psprintf(" Pre TLP File dev_seqr.cxl_version=%d,  cxl_ver =%d cxl_mode=%d seq_sqr.cxl_mode=%d vdm_for_cxl=%d cxl_ldid_prefix=%d, m_cxl_ldid=%h",seq_sqr.cxl_version,  cxl_version,cxl_mode, seq_sqr.cxl_mode ,vdm_for_cxl,m_pcie_dev_top_cfg.cxl_ldid_prefix,m_cxl_ldid), UVM_DEBUG)

      if(apply_directed_tlp && !axi_region_prog)
      get_tlp_polcies();

    endfunction

    //----------------------------------------------------------------------------
    // Function : get_tlp_policies
    // Method to push TLP policies to create Psudo random or directed tests
    //----------------------------------------------------------------------------
    virtual function void get_tlp_polcies();
      if (m_pcie_dev_top_cfg != null) begin
        if (m_pcie_dev_top_cfg.scenario != null) begin
          for (int i=0; i< m_pcie_dev_top_cfg.scenario.tlp_scenario_q.size(); i++) begin
            apply_tlp_policies(m_pcie_dev_top_cfg.scenario.tlp_scenario_q[i]);
          end
        end
      end
      
    endfunction : get_tlp_polcies

    //----------------------------------------------------------------------------
    // Function : apply_tlp_policies
    // Empty for now and we can ad some base logic based on some common requirements
    //----------------------------------------------------------------------------
    virtual function void apply_tlp_policies(tlp_policy_types_t tlp_pol_types);
    endfunction

    //----------------------------------------------------------------------------
    // Function : generate_directed_cfgwr0_tlp
    // This function generates a directed CfgWr0 TLP with proper constraints
    // Call this function when enable_directed_cfgwr0 flag is set
    //----------------------------------------------------------------------------
    virtual function void generate_directed_cfgwr0_tlp();
      `uvm_info(get_full_name(), "Generating Directed CfgWr0 TLP", UVM_MEDIUM)
      
      // Set TLP type and transaction type for CfgWr0
      m_tlp_type       = CDN_HPA_PCIE_TLP_TYPE_CfgWr0;
      m_tlp_trans_type = CDN_HPA_PCIE_TRANS_CFG_TYPE;
      
      // Set header format and type as per PCIe spec for CfgWr0
      m_hdr_fmt        = cdn_hpa_pcie_tlp_fmt_t'(3'b010);  // With data
      m_hdr_type       = 5'b00100; // Type 0 Configuration Write
      
      // Set request type for non-posted request with data
      m_tlp_req_type   = CDN_HPA_PCIE_TRANS_NON_POSTED_REQ;
      m_tlp_np_req_type = CDN_HPA_PCIE_NPR_WITH_DATA;
      
      // Configuration transactions must have TC=0
      m_tlp_tc         = 3'b000;
      
      // Configuration transactions must have Attr=0
      m_tlp_attr1      = 1'b0;
      m_tlp_attr0      = 2'b00;
      
      // Set length to 1 DW (typical for config write)
      m_tlp_length     = 10'h001;
      
      // Set byte enables (all bytes enabled for single DW)
      m_tlp_first_dw_be = 4'b1111;
      m_tlp_last_dw_be  = 4'b0000;
      
      // Configure register number (can be modified as needed)
      // Default: writing to register 0
      m_tlp_reg_num     = 8'h00;
      m_tlp_ext_reg_num = 4'h0;
      
      // Setup payload - 4 bytes for single DW
      m_tlp_payload = new[4];
      foreach(m_tlp_payload[i]) begin
        m_tlp_payload[i] = 8'h00; // Default data, can be customized
      end
      
      // Clear TD (no ECRC by default for directed test)
      m_tlp_td = 1'b0;
      
      // Clear EP (no poison)
      m_tlp_ep = 1'b0;
      
      // Set AT type to default
      m_tlp_at_type = CDN_HPA_PCIE_AT_Untranslated;
      
      `uvm_info(get_full_name(), 
                $sformatf("Directed CfgWr0 TLP generated: Type=%s, Trans=%s, Reg=0x%02x, Ext_Reg=0x%01x, Length=%0d", 
                          m_tlp_type.name(), m_tlp_trans_type.name(), m_tlp_reg_num, m_tlp_ext_reg_num, m_tlp_length), 
                UVM_MEDIUM)
    endfunction : generate_directed_cfgwr0_tlp

    //----------------------------------------------------------------------------
    // Function : generate_directed_iowr_tlp
    // This function generates a directed IOWr TLP with proper PCIe constraints
    // Call this function when enable_directed_iowr flag is set
    //----------------------------------------------------------------------------
    virtual function void generate_directed_iowr_tlp();
      `uvm_info(get_full_name(), "Generating Directed IOWr TLP", UVM_MEDIUM)
      
      // Set TLP type and transaction type for IOWr
      m_tlp_type       = CDN_HPA_PCIE_TLP_TYPE_IOWr;
      m_tlp_trans_type = CDN_HPA_PCIE_TRANS_IO_TYPE;
      
      // Set header format and type as per PCIe spec for IOWr
      m_hdr_fmt        = cdn_hpa_pcie_tlp_fmt_t'(3'b010);  // 3DW header with data
      m_hdr_type       = 5'b00010; // I/O Write
      
      // Set request type for non-posted request with data
      m_tlp_req_type   = CDN_HPA_PCIE_TRANS_NON_POSTED_REQ;
      m_tlp_np_req_type = CDN_HPA_PCIE_NPR_WITH_DATA;
      
      // I/O transactions must have TC=0 (per PCIe spec)
      m_tlp_tc         = 3'b000;
      
      // I/O transactions must have Attr=0 (per PCIe spec)
      m_tlp_attr1      = 1'b0;
      m_tlp_attr0      = 2'b00;
      
      // I/O transactions are always 1 DW (4 bytes)
      m_tlp_length     = 10'h001;
      
      // Set byte enables (all bytes enabled for single DW)
      m_tlp_first_dw_be = 4'b1111;
      m_tlp_last_dw_be  = 4'b0000;  // Not used for single DW
      
      // I/O address (32-bit only, upper 32 bits must be 0)
      // Default to address 0, user can customize after generation
      m_tlp_addr[63:32] = 32'h0000_0000;  // Upper 32 bits must be 0 for I/O
      m_tlp_addr[31:0]  = 32'h0000_0000;  // Lower 32 bits - customizable
      
      // Address type - I/O is always 32-bit addressing
      m_tlp_addr_type  = CDN_HPA_PCIE_ADDR_32;
      
      // Setup payload - 4 bytes for single DW
      m_tlp_payload = new[4];
      foreach(m_tlp_payload[i]) begin
        m_tlp_payload[i] = 8'hCC; // Default data, can be customized
      end
      
      // Clear TD (no ECRC by default for directed test)
      m_tlp_td = 1'b0;
      
      // Clear EP (no poison)
      m_tlp_ep = 1'b0;
      
      // Set AT type to default (untranslated for I/O)
      m_tlp_at_type = CDN_HPA_PCIE_AT_Untranslated;
      
      // Clear LN (Light weight notification not used for I/O)
      m_tlp_ln = 1'b0;
      
      // Clear TH (TLP hints not used for I/O)
      m_tlp_th = 1'b0;
      
      // Requester ID - Set based on device config or use defaults
      if (m_pcie_dev_cfg != null) begin
        // Soft constraints will auto-populate from m_pcie_dev_cfg
      end else begin
        // Explicit setting for standalone testing
        m_tlp_requester_id.bus_num      = 8'h00;
        m_tlp_requester_id.device_num   = 5'h00;
        m_tlp_requester_id.function_num = 3'h0;
      end
      
      `uvm_info(get_full_name(), 
                $sformatf("Directed IOWr TLP generated: Type=%s, Trans=%s, Addr=0x%08x, Length=%0d, Req_ID=0x%04x", 
                          m_tlp_type.name(), 
                          m_tlp_trans_type.name(), 
                          m_tlp_addr[31:0], 
                          m_tlp_length,
                          {m_tlp_requester_id.bus_num, m_tlp_requester_id.device_num, m_tlp_requester_id.function_num}), 
                UVM_MEDIUM)
    endfunction : generate_directed_iowr_tlp

    //----------------------------------------------------------------------------
    // Function : post_randomize
    // Pack method is done
    // ECRC computation and packing is done
    //----------------------------------------------------------------------------
    function void post_randomize();
      bit[2:0] vc = m_pcie_dev_top_cfg.tc_to_vc(m_tlp_tc);
      int q_idx[$];
      int uio_tc_vc_map_q[$];
      int tc_vc_correct_q[$];
      int uio_tc_match[$];
      int unmap_tc_vc[$];
      int uio_tc_val;

      m_tlp_vc = vc;

      `uvm_info(get_full_name(),$psprintf("m_tlp_type = %0s, m_tlp_addr = %0h ",m_tlp_type.name(), m_tlp_addr),UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf(" %0d, %0d ", m_cxl_ldid, m_pcie_dev_top_cfg.cxl_ldid),UVM_DEBUG)
      super.post_randomize();
      
      // Generate directed CfgWr0 TLP if enabled
      if (enable_directed_cfgwr0) begin
        generate_directed_cfgwr0_tlp();
      end
      
      // Generate directed IOWr TLP if enabled
      if (enable_directed_iowr) begin
        generate_directed_iowr_tlp();
      end
      
      `uvm_info(get_full_name(),$psprintf("m_tlp_tc = %0d, m_tlp_tc_has_active_ide_stream = %0d, m_ide_prefix_possible = %0d, m_ide_prefix_present= %0d, m_tlp_td: %0d, m_sel_stream_possible = %0d", m_tlp_tc, m_tlp_tc_has_active_ide_stream, m_ide_prefix_possible, m_ide_prefix_present, m_tlp_td,m_sel_stream_possible),UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf("m_sel_stream_possible = %0d", m_sel_stream_possible),UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf("m_pcie_link_cfg.dsp_dev_config.m_is_sel_stream_bar = %0d", m_pcie_link_cfg.dsp_dev_config.m_is_sel_stream_bar),UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf("m_pcie_link_cfg.usp_dev_config.m_is_sel_stream_bar = %0d", m_pcie_link_cfg.usp_dev_config.m_is_sel_stream_bar),UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf("m_stream_id_int= %0h", m_stream_id_int),UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf("m_ide_prefix_possible= %0d", m_ide_prefix_possible),UVM_DEBUG)
      //`uvm_info(get_full_name(),$psprintf("m_ide_prefix_present= %0d", m_ide_prefix_present),UVM_DEBUG)


      //setting m_cxl_vdm_payload/m_tlp_payload reserved bit as zero
      //if (cxl_mode && (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type0)) begin
      //  if(m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_AGENT_INFO) begin
      //    m_cxl_vdm_payload [95:8] = 0 ;
      //   {m_tlp_payload [15],  m_tlp_payload [14], m_tlp_payload [13], m_tlp_payload [12], m_tlp_payload [11], m_tlp_payload [10], m_tlp_payload [9], m_tlp_payload [8], m_tlp_payload [7], m_tlp_payload [6], m_tlp_payload [5]} = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00} ;
      //  end
      //  //else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_RESET_PREP) begin
      //  //  m_cxl_vdm_payload [95:18] = 0 ;
      //  // {m_tlp_payload [15],  m_tlp_payload [14], m_tlp_payload [13], m_tlp_payload [12], m_tlp_payload [11], m_tlp_payload [10], m_tlp_payload [9], m_tlp_payload [8], m_tlp_payload [7], m_tlp_payload [6][7:2] } = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 6'b000000} ;
      //  //end
      //  else if (m_cxl_vdm_pm_logical_opcode == CDN_HPA_CXL_PM_REQ_RSP_GO) begin
      //    m_cxl_vdm_payload [95:32]= 0 ;
      //   {m_tlp_payload [15],  m_tlp_payload [14], m_tlp_payload [13], m_tlp_payload [12], m_tlp_payload [11], m_tlp_payload [10], m_tlp_payload [9], m_tlp_payload [8] } = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00} ;
      //  end else begin //CDN_HPA_CXL_CREDIT_RTN
      //    m_cxl_vdm_payload [95:15] = 0 ;
      //   {m_tlp_payload [15],  m_tlp_payload [14], m_tlp_payload [13], m_tlp_payload [12], m_tlp_payload [11], m_tlp_payload [10], m_tlp_payload [9], m_tlp_payload [8], m_tlp_payload [7], m_tlp_payload [6], m_tlp_payload [5][7] } = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 1'b0} ;
      //  end
      //end
      //else if (cxl_mode && cxl_version==2 && m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type0 && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) begin
      //   m_cxl_error_vdm_msg = CDN_HPA_CXL_VDM_MEFN ;
      //   m_tlp_vendor_id = 16'h1E98;
      //   m_tlp_length = 0;
      //   m_tlp_vendor_msg = {msg_cxl_vdm_msg_bits_rsvd, msg_cxl_vdm_msg_fw_interrupt_vector, 8'h0};
      //   m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_TO_RC;
      //   `uvm_info(get_full_name(),$psprintf("Come in Post Randomize funtion CDN_HPA_CXL_VDM_MEFN "),UVM_LOW)
      //end

      //m_ohc_a concatenation
      if (m_ohc_hdr.ohc_a_present) begin
        if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) begin
          m_ohc_a = {
            (((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) ||
            (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)) &&
            (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request)) ? m_tlp_ats_tr_nw_field : m_ohc_a1_byte_0_field_7_rsvd,
            m_pasid_prefix_present,
            m_pasid_pri_value,
            m_pasid_exec_value,
            m_pasid_value,
            m_tlp_last_dw_be,
            m_tlp_first_dw_be
          };
        end
        if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE) begin //OHC-A is must
          m_ohc_a = { m_ohc_a2_byte_0_2_rsvd,
          m_tlp_last_dw_be,
          m_tlp_first_dw_be
        };
      end
      if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) begin //OHC-A is must
        m_ohc_a = {
          m_destination_segment,
          m_ohc_a3_byte_1_rsvd,
          m_destination_segment_valid,
          m_ohc_a3_byte_2_rsvd,
          m_tlp_last_dw_be,
          m_tlp_first_dw_be
        };
      end
      if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) begin
        if (pcie_6_1_support && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PR_Request) begin
          if (m_pasid_prefix_present) begin
            m_ohc_a = {
              m_ohc_a1_byte_0_field_7_rsvd,
              m_pasid_prefix_present,
              m_pasid_pri_value,
              m_pasid_exec_value,
              m_pasid_value,
              m_ohc_a1_byte_3_rsvd
            };
          end else begin
            m_ohc_a = 32'b0; //OHC-A is rsvd
          end
        end else begin
          m_ohc_a = {
            m_destination_segment,
            m_pasid_value[15:8],
            m_destination_segment_valid,
            m_pasid_prefix_present,
            m_ohc_a4_byte_2_field_5_4_rsvd,
            m_pasid_value[19:16],
            m_pasid_value[7:0]
          };
        end
      end
      if (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE) begin
        m_ohc_a = {
          m_destination_segment,
          m_completer_segment,
          m_destination_segment_valid,
          m_ohc_a5_byte_2_3_rsvd,
          m_tlp_cpl_lower_addr[1:0],
          m_tlp_cpl_status
        };
      end
    end else begin
      m_ohc_a = 32'b0;
    end

    // m_ohc_b concatenation
    if (m_ohc_hdr.ohc_b_present) begin
      m_ohc_b = {
        m_ohc_b_byte_0_rsvd,
        m_tlp_st_tag,
        m_tlp_ph,
        m_hv,
        m_ama_value,
        m_ama_valid
      };
    end else begin
      m_ohc_b = 32'b0;
    end

    //m_ohc_c concatenation
    if (m_ohc_hdr.ohc_c_present) begin
      m_ohc_c = {
        m_requester_segment,
        m_pr_sent_counter,
        m_stream_id,
        m_sub_stream,
        m_requester_segment_valid,
        m_ohc_c_byte_3_field_2_rsvd,
        m_ide_k,
        m_ide_t
      };
    end else begin
      m_ohc_c = 32'b0;
    end

    if((m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_EP) /*OUTBOUND from EP DUT*/ && (m_pcie_dev_top_cfg.intx_pin_or_hls) /*PIN mode*/&&(m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_Msg) && !dont_update_intx_pin) begin
      case(m_tlp_msg_code)
        CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A   : m_pcie_dev_top_cfg.intx_pin_assert[0] = 1;
        CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A : m_pcie_dev_top_cfg.intx_pin_assert[0] = 0;
        CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B   : m_pcie_dev_top_cfg.intx_pin_assert[1] = 1;
        CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B : m_pcie_dev_top_cfg.intx_pin_assert[1] = 0;
        CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C   : m_pcie_dev_top_cfg.intx_pin_assert[2] = 1;
        CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C : m_pcie_dev_top_cfg.intx_pin_assert[2] = 0;
        CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D   : m_pcie_dev_top_cfg.intx_pin_assert[3] = 1;
        CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D : m_pcie_dev_top_cfg.intx_pin_assert[3] = 0;
        default   :  `uvm_info(get_full_name(),$psprintf("m_tlp_type = %0s, m_tlp_msg_code = %0s ",m_tlp_type.name(), m_tlp_msg_code.name),UVM_DEBUG)
      endcase
      if(m_tlp_msg_code inside {[CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A:CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D]}) begin
        m_pcie_dev_top_cfg.intx_cntr = m_pcie_dev_top_cfg.intx_cntr + 1;
      end
    end

    case(m_tlp_msg_code)
      CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A   : begin
        m_pcie_dev_top_cfg.intx_pin_ib_assert[0] = 1;
        m_pcie_dev_top_cfg.intx_a_cntr = 0;
      end
      CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A : begin
        m_pcie_dev_top_cfg.intx_pin_ib_deassert[0] = 1;
        m_pcie_dev_top_cfg.intx_a_cntr = 0;
      end
      CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B   : begin
        m_pcie_dev_top_cfg.intx_pin_ib_assert[1] = 1;
        m_pcie_dev_top_cfg.intx_b_cntr = 0;
      end
      CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B : begin
        m_pcie_dev_top_cfg.intx_pin_ib_deassert[1] = 1;
        m_pcie_dev_top_cfg.intx_b_cntr = 0;
      end
      CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C   : begin
        m_pcie_dev_top_cfg.intx_pin_ib_assert[2] = 1;
        m_pcie_dev_top_cfg.intx_c_cntr = 0;
      end
      CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C : begin
        m_pcie_dev_top_cfg.intx_pin_ib_deassert[2] = 1;
        m_pcie_dev_top_cfg.intx_c_cntr = 0;
      end
      CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D   : begin
        m_pcie_dev_top_cfg.intx_pin_ib_assert[3] = 1;
        m_pcie_dev_top_cfg.intx_d_cntr = 0;
      end
      CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D : begin
        m_pcie_dev_top_cfg.intx_pin_ib_deassert[3] = 1;
        m_pcie_dev_top_cfg.intx_d_cntr = 0;
      end
      default   :  `uvm_info(get_full_name(),$psprintf("m_tlp_type = %0s, m_tlp_msg_code = %0s ",m_tlp_type.name(), m_tlp_msg_code.name),UVM_DEBUG)
    endcase

    if((m_pcie_dev_top_cfg.intx_pin_ib_assert[0] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[0]) && (m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)) begin
      if(!(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_A,CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_A}) && (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ && m_tlp_tc == 0)) begin
        m_pcie_dev_top_cfg.intx_a_cntr = m_pcie_dev_top_cfg.intx_a_cntr + 1;
      end
    end
    if((m_pcie_dev_top_cfg.intx_pin_ib_assert[1] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[1]) && (m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)) begin
      if(!(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_B,CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_B}) && (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ && m_tlp_tc == 0)) begin
        m_pcie_dev_top_cfg.intx_b_cntr = m_pcie_dev_top_cfg.intx_b_cntr + 1;
      end
    end
    if((m_pcie_dev_top_cfg.intx_pin_ib_assert[2] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[2]) && (m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)) begin
      if(!(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_C,CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_C}) && (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ && m_tlp_tc == 0)) begin
        m_pcie_dev_top_cfg.intx_c_cntr = m_pcie_dev_top_cfg.intx_c_cntr + 1;
      end
    end
    if((m_pcie_dev_top_cfg.intx_pin_ib_assert[3] || m_pcie_dev_top_cfg.intx_pin_ib_deassert[3]) && (m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP && m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)) begin
      if(!(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_INTX_ASSERT_D,CDN_HPA_PCIE_TLP_MSG_INTX_DEASSERT_D}) && (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ && m_tlp_tc == 0)) begin
        m_pcie_dev_top_cfg.intx_d_cntr = m_pcie_dev_top_cfg.intx_d_cntr + 1;
      end
    end

    if(m_pcie_dev_top_cfg.intx_a_cntr > 20) begin
      m_pcie_dev_top_cfg.intx_pin_ib_assert[0] = 0;
      m_pcie_dev_top_cfg.intx_pin_ib_deassert[0] = 0;
    end
    if(m_pcie_dev_top_cfg.intx_b_cntr > 20) begin
      m_pcie_dev_top_cfg.intx_pin_ib_assert[1] = 0;
      m_pcie_dev_top_cfg.intx_pin_ib_deassert[1] = 0;
    end
    if(m_pcie_dev_top_cfg.intx_c_cntr > 20) begin
      m_pcie_dev_top_cfg.intx_pin_ib_assert[2] = 0;
      m_pcie_dev_top_cfg.intx_pin_ib_deassert[2] = 0;
    end
    if(m_pcie_dev_top_cfg.intx_d_cntr > 20) begin
      m_pcie_dev_top_cfg.intx_pin_ib_assert[3] = 0;
      m_pcie_dev_top_cfg.intx_pin_ib_deassert[3] = 0;
    end

    //For ATS INvalidate req, once a INV_Req has been sent, pop the item from the m_pcie_dev_top_cfg.itag_available_q
    if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_AT_Invalidate) begin
      q_idx = {};
      q_idx = m_pcie_dev_top_cfg.itag_available_q.find_index(item) with (item==m_tlp_itag);
      if(q_idx.size() !=0) begin
        m_pcie_dev_top_cfg.itag_available_q.delete(q_idx[0]);
        `uvm_info("DEBUG_ATS",$psprintf("itag_available_q deleted for itag='h%0h",m_tlp_itag),UVM_DEBUG)
      end
      m_pcie_dev_top_cfg.inv_req_outstanding++;
    end

    //For ATS Page req, once a page_req has been sent, pop the item from the m_pcie_dev_top_cfg.prg_index_available_q
    //TODO While doing multiple PR Requests with same PRG_IDX, this needs modification
    if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PR_Request) begin
      q_idx = {};
      q_idx = m_pcie_dev_top_cfg.prg_index_available_q.find_index(item) with (item==m_prGroupIndex);
      if(q_idx.size() !=0) begin
        m_pcie_dev_top_cfg.prg_index_available_q.delete(q_idx[0]);
        `uvm_info("DEBUG_ATS",$psprintf("prg_index_available_q deleted for PRG_IDX='h%0h",m_prGroupIndex),UVM_DEBUG)
      end
      m_pcie_dev_top_cfg.pr_req_outstanding++;
    end

    //Error Injection
    vip_userdata = cdn_pcie_vip_userdata::type_id::create("vip_userdata");
    err_inj_vip_userdata(vip_userdata);

    if(implcit_byte_enable_mem_tlps && is_flit_mode) begin
      m_tlp_last_dw_be  =  4'hF;
      m_tlp_first_dw_be =  4'hF;
    end

    //TODO : Soumit suggested as this code was adding ide prefixes
    //`ifndef CDNS_IDE
    // if(m_ide_prefix_present) begin
    //   if(m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) begin
    //     if(m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream] == 0) begin
    //       if(m_pcie_dev_top_cfg.i_cfg.strap_is_rp) begin
    //         case(m_sub_stream)
    //           4'h0 : m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream] = $urandom_range(1,(32'h1 << m_pcie_dev_top_cfg.ide_cfg.dsp_link_ide_tx_pr_aggr_mode[m_stream_id] ));
    //           4'h1 : m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream] = $urandom_range(1,(32'h1 << m_pcie_dev_top_cfg.ide_cfg.dsp_link_ide_tx_npr_aggr_mode[m_stream_id]));
    //           4'h2 : m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream] = $urandom_range(1,(32'h1 << m_pcie_dev_top_cfg.ide_cfg.dsp_link_ide_tx_cpl_aggr_mode[m_stream_id]));
    //         endcase
    //       end
    //       else begin
    //         case(m_sub_stream)
    //           4'h0 : m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream] = $urandom_range(1,(32'h1 << m_pcie_dev_top_cfg.ide_cfg.usp_link_ide_tx_pr_aggr_mode[m_stream_id] ));
    //           4'h1 : m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream] = $urandom_range(1,(32'h1 << m_pcie_dev_top_cfg.ide_cfg.usp_link_ide_tx_npr_aggr_mode[m_stream_id]));
    //           4'h2 : m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream] = $urandom_range(1,(32'h1 << m_pcie_dev_top_cfg.ide_cfg.usp_link_ide_tx_cpl_aggr_mode[m_stream_id]));
    //         endcase
    //       end
    //     end

    //     `uvm_info("DEBUG_AGGR",$psprintf("Before considering current tlp, randomized ide_mac_tlp_idx[%0h][%0h]=%0d; ob_ide_tlp_count=%0d ob_ide_tlp_payload=%0d",m_stream_id,m_sub_stream,m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream],m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream], m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream]),UVM_DEBUG)
    //     m_ide_m = 0;
    //     m_ide_p = 0;
    //     m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream]++;
    //     m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream] += (m_tlp_payload.size()/4);
    //     `uvm_info("DEBUG_AGGR",$psprintf("After considering current tlp but before checks, randomized ide_mac_tlp_idx[%0h][%0h]=%0d; ob_ide_tlp_count=%0d ob_ide_tlp_payload=%0d",m_stream_id,m_sub_stream,m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream],m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream], m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream]),UVM_DEBUG)
    //     //`uvm_info("DEBUG_AGGR",$psprintf("After considering current tlp, ide_mac_tlp_idx=%0d  ob_ide_tlp_payload=%0d",,m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream], m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream]),UVM_DEBUG)

    //     if(m_complete_aggregate)
    //     begin
    //       m_ide_m = 1;
    //       if(m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream] > 0) begin
    //         if(m_pcie_dev_top_cfg.ide_cfg.link_ide_pcrc_enable[m_stream_id]) begin
    //           m_ide_p = 1;
    //         end
    //         if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id] != null) begin
    //           if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_pcrc_enable) m_ide_p = 1;
    //         end
    //       end
    //       m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream] = 0;
    //       m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream] = 0;
    //     end
    //     else if(m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream] == m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream]) begin
    //       m_ide_m = 1;
    //       if(m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream] > 0) begin
    //         if(m_pcie_dev_top_cfg.ide_cfg.link_ide_pcrc_enable[m_stream_id]) begin
    //           m_ide_p = 1;
    //         end
    //         if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id] != null) begin
    //           if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_pcrc_enable) m_ide_p = 1;
    //         end
    //       end
    //       m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream] = 0;
    //       m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream] = 0;
    //     end
    //     else if(m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream] < m_pcie_dev_top_cfg.ide_cfg.ide_mac_tlp_idx[m_stream_id][m_sub_stream]) begin
    //       if(m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream] > 192) begin //soumitm :: TODO :: make the limit smarter
    //         m_ide_m = 1;
    //         if(m_pcie_dev_top_cfg.ide_cfg.link_ide_pcrc_enable[m_stream_id]) begin
    //           m_ide_p = 1;
    //         end
    //         if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id] != null) begin
    //           if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_pcrc_enable) m_ide_p = 1;
    //         end
    //         m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream] = 0;
    //         m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream] = 0;
    //       end
    //     end
    //     m_pcie_dev_top_cfg.ide_cfg.is_aggregation_complete[m_stream_id][m_sub_stream] = m_ide_m;
    //     m_ide_tlp_prefix[2] = m_ide_m;
    //     m_ide_tlp_prefix[3] = m_ide_p;

    //     //soumitm :: TODO :: revisit for aggregation
    //     if(is_flit_mode) begin
    //       if(m_ide_m && !m_ide_p) m_ts = CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER;
    //       if(m_ide_m &&  m_ide_p) m_ts = CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER;

    //       // To initialize m_ts_payload size
    //       update_ts_payload();
    //     end

    //     `uvm_info("DEBUG_AGGR",$psprintf("After considering current tlp & after checks, ob_ide_tlp_count[%0h][%0h]=%0d  ob_ide_tlp_payload=%0d m_ide_m=%0d m_ide_p=%0d",m_stream_id,m_sub_stream,m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_count[m_stream_id][m_sub_stream],m_pcie_dev_top_cfg.ide_cfg.ob_ide_tlp_payload[m_stream_id][m_sub_stream],m_ide_m, m_ide_p),UVM_DEBUG)
    //     void'(this.pack_bytes(this.m_data));
    //   end
    // end
    //`endif

    //setting is_ide_tlp variable for AXI bridge use
    is_ide_tlp = m_ide_prefix_present;

    update_cfgtype_1_streamid();

    //NAV UIO_TODO prints to see whether UIO is sending via VC3/VC4   
   /* if (parameters_cfg_pkg::UIO_SUPPORT) begin 
      foreach(m_pcie_dev_top_cfg.tc_vc_map[i]) begin
        if (parameters_cfg_pkg::NUM_UIO_VCS == 1 ) begin
          if ((m_pcie_dev_top_cfg.tc_vc_map[i] == 1)) uio_tc_vc_map_q.push_front(i);
        end
        else begin 
          if (m_pcie_dev_top_cfg.tc_vc_map[i] inside {1, 2}) begin  
            uio_tc_vc_map_q.push_front(i);
           end
        end
       end

       `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize TC Mapped to uio m_tlp_tc = %0d vc= %0d  %p",m_tlp_tc,vc,uio_tc_vc_map_q), UVM_DEBUG)
       `ifndef IDE_MODULE_LEVEL_SIM
       if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_UIOMWr, CDN_HPA_PCIE_TLP_TYPE_UIOMRd }) begin 
         tc_vc_correct_q = uio_tc_vc_map_q.find_index(x) with (x == m_tlp_tc);
         if (tc_vc_correct_q.size()>0) begin
          `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize m_tlp_tc = %0d mapped UIO tc = %p m_stream_id= %0h",m_tlp_tc, uio_tc_vc_map_q,m_stream_id), UVM_DEBUG)
         end  
         else begin
           uio_tc_val = $urandom_range(uio_tc_vc_map_q.size()-1, 0);
           m_tlp_tc = uio_tc_vc_map_q[uio_tc_val]; 
         end
         //m_tlp_tc = m_pcie_dev_top_cfg.vc_tc_map[1] 
         `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize m_tlp_tc = %0d mapped UIO tc = %p m_stream_id= %0h",m_tlp_tc, uio_tc_vc_map_q,m_stream_id), UVM_DEBUG)
         if(!use_user_defined_stream_id) begin
           m_stream_id_int = m_pcie_dev_top_cfg.ide_cfg.find_stream_id_mapped_to_tc(m_tlp_tc, m_sel_stream_possible);
           m_stream_id = ((m_stream_id_int != -1) ? m_stream_id_int : 0);
           `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize m_tlp_tc = %0d mapped UIO tc = %p m_stream_id= %0h",m_tlp_tc, uio_tc_vc_map_q,m_stream_id), UVM_DEBUG)
         end

       end
       else begin
       `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize TC Mapped to uio m_tlp_tc[vc]= %0d  %p",vc,uio_tc_vc_map_q), UVM_DEBUG)
       uio_tc_match =  uio_tc_vc_map_q.find_index(x) with (x == vc);
       `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize TC Mapped to uio m_tlp_tc = %p  %p",uio_tc_match,uio_tc_vc_map_q), UVM_DEBUG)
       //if (uio_tc_match.size() != 0) begin
       //    `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize TC Mapped to uio m_tlp_tc = %p  %p",uio_tc_match,uio_tc_vc_map_q), UVM_DEBUG)
       //      m_tlp_tc = 0 ;   
       //  end
       //unmap_tc_vc =  m_pcie_dev_cfg.m_unmapped_tc_list.find_index(x) with (x == vc);
       //`uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize TC Mapped to uio vc= %p   %p",uio_tc_match,m_pcie_dev_cfg.m_unmapped_tc_list), UVM_DEBUG)
       //if (unmap_tc_vc.size() != 0) begin
       //  `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize TC Mapped to uio m_tlp_tc = %p  %p",uio_tc_match,uio_tc_vc_map_q), UVM_DEBUG)
       //  m_tlp_tc = 0 ;   
       //end

       //if (unmap_tc_vc.size() == 0 && uio_tc_match.size() == 0) begin
       //  `uvm_info(get_full_name(), $psprintf("[UIO_TLP] Post Randomize TC Mapped to non_uio m_tlp_tc[vc]= %d  %p",vc,uio_tc_vc_map_q), UVM_DEBUG)
       //  m_tlp_tc = vc ;    
       //end
       end
      `endif
     end*/
     //

  `uvm_info("DEBUG_CXL_VER", $psprintf(" TLP File cxl_ver =%d cxl_mode=%d  vdm_for_cxl=%d cxl_ldid_prefix=%d m_cxl_vdm_pm_logical_opcode=%s m_tlp_tc= %0d m_stream_id = %0h m_ide_t = %0b strap_is_rp = %0b, tdisp_func_num = %0d, tdisp_is_ib = %0b,tdisp_stream_id = %0h,default_stream_id = %0h, msg_type_tc_0 = %0b",cxl_version,cxl_mode,vdm_for_cxl,cxl_ldid_prefix,m_cxl_vdm_pm_logical_opcode.name(),m_tlp_tc,m_stream_id,m_ide_t,m_pcie_dev_top_cfg.i_cfg.strap_is_rp,tdisp_func_num,tdisp_is_ib,tdisp_stream_id,default_stream_id,msg_type_tc_0), UVM_DEBUG)
  `uvm_info("DEBUG_STREAM_SRC", $psprintf(" stream_src: use_user_defined_stream_id=%0b m_stream_id_int=%0d m_stream_id=%0h m_sel_stream_possible=%0b m_ide_prefix_possible=%0b m_ide_prefix_present=%0b m_tlp_tc=%0d m_tlp_msg_rout_type=%0s m_tlp_msg_code=%0s usp_func_num=%0h", use_user_defined_stream_id, m_stream_id_int, m_stream_id, m_sel_stream_possible, m_ide_prefix_possible, m_ide_prefix_present, m_tlp_tc, m_tlp_msg_rout_type.name(), m_tlp_msg_code.name(), m_pcie_link_cfg.usp_dev_config.m_req_id.function_num), UVM_DEBUG)
    
    
    //`uvm_info("CXL1_MMIO_TLP", $psprintf("device_config[pf=%0h] picked is \n%0s ",m_pcie_dev_cfg.m_pf_num,m_pcie_dev_cfg.sprint()), UVM_DEBUG)
    //`uvm_info("CXL2_MMIO_TLP", $psprintf("link_usp_config[pf=%0h] picked is \n%0s ",m_pcie_link_cfg.usp_dev_config.m_pf_num,m_pcie_link_cfg.usp_dev_config.sprint()), UVM_DEBUG)
    //`uvm_info("CXL3_MMIO_TLP", $psprintf("link_dsp_config[pf=%0h] picked is \n%0s ",m_pcie_link_cfg.dsp_dev_config.m_pf_num,m_pcie_link_cfg.dsp_dev_config.sprint()), UVM_DEBUG)
  endfunction : post_randomize


 function void err_inj_vip_userdata(ref cdn_pcie_vip_userdata vip_userdata);
    bit[2:0] non_zero_tc = 0;
    bit all_unmapped_tc = are_all_tc_unmapped(m_pcie_dev_top_cfg.m_unmapped_tc_list);
    bit[2:0] vc = m_pcie_dev_top_cfg.tc_to_vc(m_tlp_tc);
    bit l_is_memrd_op;
    int local_unmapped_tc_list_size,local_m_tlp_local_prefix_size;
    int local_pasid_prefix,local_tph_prefix;
    bit is_e2e_tlp_prefix_supp = (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) ? is_feature_supported_by_any_func(CDN_HPA_PCIE_E2E_TLP_PREFIX, m_pcie_link_cfg.usp_dev_top_config) : is_feature_supported_by_any_func(CDN_HPA_PCIE_E2E_TLP_PREFIX, m_pcie_link_cfg.dsp_dev_top_config);
    cdn_pcie_hpa_dev_top_config l_dut_dev_top_cfg;


    if(!(m_pcie_dev_cfg.bypass_dut_type_chk))
    begin
      if(m_pcie_link_cfg.m_dut_mode == CDN_HPA_PCIE_RP)
      l_dut_dev_top_cfg = m_pcie_link_cfg.dsp_dev_top_config;
      else
      l_dut_dev_top_cfg = m_pcie_link_cfg.usp_dev_top_config;
    end

    //If TH==1 & Posted Mem transaction, tag is replaced by st_tag
    if((m_tlp_th == 1) && (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64})) 
      m_tlp_tag = m_tlp_st_tag[7:0];
    `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM:pre inclusion m_tlp_length = %0d, m_tlp_payload.size() = %0d, m_user_error_inject_obj.m_user_error_injects.size = %0d ", m_tlp_length, m_tlp_payload.size(), m_user_error_inject_obj.m_user_error_injects.size), UVM_DEBUG)
    // DISPLAY FOR DEBUG
    `uvm_info("DEBUG::DATA",$psprintf("DEBUG::DATA: m_tlp_type = %0p, m_tlp_at_type = %0p, m_pasid_prefix_present = %0d, m_pasid_value=%0h, m_max_pasid_val=%0h",m_tlp_type,m_tlp_at_type,m_pasid_prefix_present, m_pasid_value, m_pcie_link_cfg.usp_dev_config.m_max_pasid_val),UVM_DEBUG)
    m_is_atomic_op = is_atomic_op();
    l_is_memrd_op  = is_memrd_op();

    vip_userdata.hpa_pkt_num = m_pcie_dev_cfg.get_hpa_pkt_num();
    vip_userdata.m_pcie_dev_top_cfg = m_pcie_dev_top_cfg;
    non_zero_tc = find_non_zero_tc(m_pcie_dev_top_cfg.m_unmapped_tc_list);
    if(config_error_control())
      vip_userdata.has_err = 1;
    if(m_pcie_dev_top_cfg.ide_spec_err_scen=="IDE_MAC_BIT_ZERO_GRT_EIGHT_TLPS_WHN_AGGR_SUPP") begin
      `uvm_info(get_name(),$psprintf("DEBUG_ERR: ide_mac_zero_grt_eight_tlps_whn_aggr_supp_err=%0b stream_id %0h sub_stream=%0h",
      m_pcie_dev_top_cfg.ide_cfg.ide_mac_zero_grt_eight_tlps_whn_aggr_supp_err,
      m_pcie_dev_top_cfg.ide_cfg.aggr_err_in_stream_id,
      m_pcie_dev_top_cfg.ide_cfg.aggr_err_in_sub_stream),UVM_DEBUG);
    end

    `ifndef IDE_MODULE_LEVEL_SIM
      if(m_pcie_dev_top_cfg.ide_cfg.ide_mac_zero_grt_eight_tlps_whn_aggr_supp_err &&
      m_stream_id  == m_pcie_dev_top_cfg.ide_cfg.aggr_err_in_stream_id &&
      m_sub_stream == m_pcie_dev_top_cfg.ide_cfg.aggr_err_in_sub_stream) begin //{
        vip_userdata.has_err = 1;
        assert(vip_userdata.randomize() with {
          m_error_injects.size inside {1};
          foreach(m_error_injects[i])
          m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_MAC_BIT_ZERO_GRT_EIGHT_TLPS_WHN_AGGR_SUPP};
        });
        `uvm_info(get_name(),$psprintf("DEBUG_ERR: Error injected is CDN_HPA_PCIE_TLP_IDE_MAC_BIT_ZERO_GRT_EIGHT_TLPS_WHN_AGGR_SUPP" ),UVM_DEBUG);
      end else begin //}{
        if(m_user_error_inject_obj.m_user_error_injects.size == 0 && (enable_inject_errors || top_cfg_enable_errors) && vip_userdata.has_err) begin //{
          if( m_pcie_dev_top_cfg.tlp_err_inj == 0 &&
          m_pcie_dev_top_cfg.cpl_err_inj == 0 &&
          m_pcie_dev_top_cfg.poisoned_err_inj == 0 &&
          m_pcie_dev_top_cfg.ecrc_err_inj == 0 &&
          m_pcie_dev_top_cfg.dllp_err_inj == 0 &&
          m_pcie_dev_top_cfg.dll_flit_err_inj == 0 &&
          m_pcie_dev_top_cfg.dlp_err_inj == 0 &&
          m_pcie_dev_top_cfg.ide_err_inj == 0 &&
          m_pcie_dev_top_cfg.plp_err_inj == 0 &&
          m_pcie_link_cfg.usp_dev_config.power_state ==0)
          begin
            `uvm_info("DEBUG_ERR",$psprintf("NO error selected"),UVM_DEBUG)
            assert(vip_userdata.randomize() with {
              m_error_injects.size == 1;
              foreach(m_error_injects[i])
              m_error_injects[i] == CDN_HPA_PCIE_TLP_NO_ERR;
            });
          end
          else
          begin //{
            `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_scenario_error_inject= %0s",m_scenario_error_inject.name()),UVM_DEBUG)
            if(m_scenario_error_inject != CDN_HPA_PCIE_TLP_NO_ERR)
            begin
              if(m_scenario_error_inject == CDN_HPA_PCIE_TLP_UIO_NON_SVC_PROTOCOL_ERR)
              begin
            `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_scenario_error_inject= %0s",m_scenario_error_inject.name()),UVM_DEBUG)
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_UIO_NON_SVC_PROTOCOL_ERR;
                });
                // condition only for OUTBOUND
                if(m_pcie_dev_top_cfg.scenario.m_is_uio_ob_err_test)
                inject_error(vip_userdata);
              end
              if(m_scenario_error_inject == CDN_HPA_PCIE_TLP_MAP_NON_UIO_VC_ERR)
              begin
               `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_scenario_error_inject= %0s",m_scenario_error_inject.name()),UVM_DEBUG)
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_MAP_NON_UIO_VC_ERR;
                });
                // condition only for OUTBOUND
                if(m_pcie_dev_top_cfg.scenario.m_is_uio_ob_err_test)
                inject_error(vip_userdata);
               `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_error_injects= %0s",vip_userdata.m_error_injects[0].name()),UVM_DEBUG)
              end
              if(m_scenario_error_inject == CDN_HPA_PCIE_TLP_UIO_REQ_256B_DISABLED_UR_ERR)
              begin
            `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_scenario_error_inject= %0s",m_scenario_error_inject.name()),UVM_DEBUG)
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_UIO_REQ_256B_DISABLED_UR_ERR;
                });
                // condition only for OUTBOUND
                if(m_pcie_dev_top_cfg.scenario.m_is_uio_ob_err_test)
                inject_error(vip_userdata);
              end
              if(m_scenario_error_inject == CDN_HPA_PCIE_TLP_UIO_REQ_EN_DISABLED_UR_ERR)
              begin
            `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_scenario_error_inject= %0s",m_scenario_error_inject.name()),UVM_DEBUG)
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_UIO_REQ_EN_DISABLED_UR_ERR;
                });
                // condition only for OUTBOUND
                if(m_pcie_dev_top_cfg.scenario.m_is_uio_ob_err_test)
                inject_error(vip_userdata);
              end
              if(m_scenario_error_inject == CDN_HPA_PCIE_TLP_NULL_ERR)
              begin
                error_injection_via_vip = 1;
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_NULL_ERR;
                });
                inject_error(vip_userdata);
              end
              else if(m_scenario_error_inject == CDN_HPA_PCIE_TLP_RSVD_ERR) begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_RSVD_ERR;
                });
              end
              else if(m_scenario_error_inject == CDN_HPA_DLLP_REPLY_TIMEOUT_ERR) begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_DLLP_REPLY_TIMEOUT_ERR;
                });
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_MSG_ERR_CODE_ERR) && (m_tlp_tc == 0) && (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg))
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_MSG_ERR_CODE_ERR;
                });
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_POISONED_ERR) &&
              (m_tlp_type inside {
                CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
                CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,CDN_HPA_PCIE_TLP_TYPE_UIOMWr,
                CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
                CDN_HPA_PCIE_TLP_TYPE_IOWr,CDN_HPA_PCIE_TLP_TYPE_MsgD,
                CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
                CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
                CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
                CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64})
              ) begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_POISONED_ERR;
                });
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_CPL_POISON_ERR) &&
              (m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) &&
              !(m_tlp_type inside {
                CDN_HPA_PCIE_TLP_TYPE_CfgWr0,
                CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
                CDN_HPA_PCIE_TLP_TYPE_IOWr,
                CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
                CDN_HPA_PCIE_TLP_TYPE_DMWr_32})
              ) begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_CPL_POISON_ERR;
                });
              end

              else if(m_scenario_error_inject == CDN_HPA_PCIE_TLP_ECRC_ERR && m_tlp_td)
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_ECRC_ERR;
                });
              end

              else if(m_scenario_error_inject == CDN_HPA_PCIE_TLP_CPL_ECRC_ERR && (m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) && m_tlp_td)
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_CPL_ECRC_ERR;
                });
              end
              
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_CFG_UNSUPP_FUNC_UR_ERR) && (m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) )
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_CFG_UNSUPP_FUNC_UR_ERR;
                });
              end

              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_TO_NON_D0_FUNC_UR_ERR))
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_TO_NON_D0_FUNC_UR_ERR;
                });
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_CPL_TO_NON_D0_FUNC_UC_ERR))
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_CPL_TO_NON_D0_FUNC_UC_ERR;
                });
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_UIO_NON_SVC_PROTOCOL_ERR))
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_UIO_NON_SVC_PROTOCOL_ERR;
                });
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_MAP_NON_UIO_VC_ERR))
              begin
               `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_scenario_error_inject= %0s",m_scenario_error_inject.name()),UVM_DEBUG)
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_MAP_NON_UIO_VC_ERR;
                });
               `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_error_injects= %0s",vip_userdata.m_error_injects[0].name()),UVM_DEBUG)
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_IDE_SYNC_FAIL_MSG_ON_UIO_STREAM))
              begin
               `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_scenario_error_inject= %0s",m_scenario_error_inject.name()),UVM_DEBUG)
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_IDE_SYNC_FAIL_MSG_ON_UIO_STREAM;
                });
               `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_error_injects= %0s",vip_userdata.m_error_injects[0].name()),UVM_DEBUG)
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_UIO_REQ_256B_DISABLED_UR_ERR))
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_UIO_REQ_256B_DISABLED_UR_ERR;
                });
               `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected m_error_injects= %0s",vip_userdata.m_error_injects[0].name()),UVM_DEBUG)
              end
              else if((m_scenario_error_inject == CDN_HPA_PCIE_TLP_UIO_REQ_EN_DISABLED_UR_ERR))
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_UIO_REQ_EN_DISABLED_UR_ERR;
                });
              end
              else
              begin
                assert(vip_userdata.randomize() with {
                  m_error_injects.size == 1;
                  m_error_injects[0] == CDN_HPA_PCIE_TLP_NO_ERR;
                });
              end
            end
            else
            begin              
              if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP)
                local_unmapped_tc_list_size= m_pcie_link_cfg.usp_dev_config.m_unmapped_tc_list.size();
              else
                local_unmapped_tc_list_size= m_pcie_link_cfg.dsp_dev_config.m_unmapped_tc_list.size();
              local_m_tlp_local_prefix_size=m_tlp_local_prefix.size();
              `uvm_info("DEBUG_ERR",$psprintf("error is supposed to be selected"),UVM_DEBUG)
              `uvm_info("DEBUG_ERR",$psprintf("m_pcie_dev_top_cfg=%0s",m_pcie_dev_top_cfg.sprint()),UVM_DEBUG)
              local_pasid_prefix = (m_pcie_dut_dev_cfg.m_cap_pasid_supp && m_pcie_dut_dev_cfg.m_pasid_enb &&
              m_pcie_dut_dev_cfg.m_e2e_tlp_prefix_support &&
              m_pcie_dut_dev_cfg.m_ext_fmt_field_support &&
              (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE  &&
              m_tlp_at_type != CDN_HPA_PCIE_AT_Translated ||
              ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}))));

              local_tph_prefix = (m_pcie_dut_dev_cfg.m_e2e_tlp_prefix_support &&
              m_pcie_dut_dev_cfg.m_ext_fmt_field_support  &&
              m_pcie_dut_dev_cfg.m_ext_tph_req_supp &&
              m_pcie_dev_cfg.m_tph_req_en inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_REQ_SUPPORTED} &&
              (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE &&
              m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request));

              assert(vip_userdata.randomize() with {

                `ifdef HLS_MODULE_MODE
                  //TODO enable multiple error injection for HPA2
                  `ifdef HPA_ARCH2
                    m_error_injects.size inside {1};
                  `else
                    m_error_injects.size inside {1};
                    //m_error_injects.size inside {1,2,3};
                  `endif
                `else
                  m_error_injects.size inside {1};
                `endif
                foreach(m_error_injects[i])
                {
                  //m_error_injects[i] dist {
                  //          //CDN_HPA_PCIE_TLP_NO_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_IO_LEN_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_CFG_LEN_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_ATTR_ERR:=10, 
                  //          //CDN_HPA_PCIE_TLP_FBE_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_LEN_GTHN_1_LBE_0_ERR:=10,
                  //          ////CDN_HPA_PCIE_TLP_LEN_EQ_1_LBE_NON_0_ERR:=10,
                  //          ////CDN_HPA_PCIE_TLP_LEN_GTHN_2_FBE_NCBE_ERR:=10,
                  //          //////CDN_HPA_PCIE_TLP_LEN_GTHN_2_LBE_NCBE_ERR:=10,
                  //          ////CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR:=10,
                  //          ////CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_ATOMIC_OP_LEN_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_ATOMICOP_ADDR_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_ADDR_CROSS_4K_BNDRY_ERR:=10,
                  //          CDN_HPA_PCIE_TLP_IO_CFG_MSG_NON_0_TC_ERR:=10,
                  //          CDN_HPA_PCIE_TLP_DMWR_CPL_DIS_UR_ERR:=10,
                  //          CDN_HPA_PCIE_TLP_AT_ODD_DWORD_ERR:=10,
                  //          CDN_HPA_PCIE_TLP_E2E_PREFIX_WO_SUPPORT_ERR:=10,
                  //          CDN_HPA_PCIE_TLP_PREFIX_GTHN_SUPPORT_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_PBR_LOCAL_PREFIX_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_PBR_LOCAL_PREFIX_AFTER_PTH_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_MAP_UIO_VC_ERR:=10,
                  //          //CDN_HPA_PCIE_TLP_MAP_NON_UIO_VC_ERR:=10,
                  //          CDN_HPA_PCIE_TLP_DMWR_LEN_MALFORMED_ERR:=10
                  //        }; 
                  m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_ERR_CODE_ERR;
                  m_error_injects[i] != CDN_HPA_PCIE_TLP_RSVD_ERR;
                  m_error_injects[i] != CDN_HPA_PCIE_TLP_NULL_ERR;
                  m_error_injects[i] != CDN_HPA_PCIE_TLP_TO_NON_D0_FUNC_UR_ERR;
                  m_error_injects[i] != CDN_HPA_PCIE_CPL_TO_NON_D0_FUNC_UC_ERR;
                  // m_error_injects[i] == CDN_HPA_PCIE_PLP_STP_CRC_ERR;
                  // m_error_injects[i] == CDN_HPA_PCIE_PLP_INCRT_STP_LEN0;
                  // m_error_injects[i] == CDN_HPA_PCIE_PLP_STP_FRAME_PARITY_ERR;
                  // m_error_injects[i] == CDN_HPA_PCIE_PLP_STP_ERR;
                  // m_error_injects[i] == CDN_HPA_PCIE_PLP_INCRT_STP_LEN;
                  // m_error_injects[i] == CDN_HPA_PCIE_PLP_SDP_ERR;
                  //m_error_injects[i] == CDN_HPA_PCIE_DLP_LCRC_ERR;
                  //m_error_injects[i] == CDN_HPA_PCIE_DLP_SEQ_NUM_ERR;
                  foreach(m_error_injects[j])
                  if(j<i)
                  m_error_injects[i] != m_error_injects[j];
                  if(m_inject_dl_err)
                  // m_error_injects[i] inside {CDN_HPA_DLLP_SEQNUM_ERR,CDN_HPA_DLLP_ACK_NAK_LCRC_ERR,CDN_HPA_DLLP_UPDATEFC_LCRC_ERR,CDN_HPA_DLLP_UPDATEFC_HRD_CORRPT_ERR,CDN_HPA_DLLP_UPDATEFC_DATA_CORRPT_ERR,CDN_HPA_DLLP_TYPE_UNKNOWN_ERR,CDN_HPA_DLLP_REPLY_TIMEOUT_ERR,CDN_HPA_DLLP_SUCCESSIVE_NAK_ERR,CDN_HPA_DLLP_TYPE_CORRPT_ERR,CDN_HPA_DLLP_ACK_NAK_RSVD_FIELD_ERR,CDN_HPA_DLLP_CORRUPT_ACK_NAK_RSVD_FIELD_ERR,CDN_HPA_DLLP_DUP_ACK_ERR,CDN_HPA_DLLP_UPDATEFC_HDRSC_CORRPT_ERR,CDN_HPA_DLLP_UPDATEFC_DATASC_CORRPT_ERR,CDN_HPA_DLLP_ACK_NAK_NON_ZERO_RSVD_ERR,CDN_HPA_DLLP_ACK_NAK_CORRUPT_RSVD_ERR,CDN_HPA_DLLP_NAK_FOLLOWED_ACK_ERR,CDN_HPA_DLLP_UPDATEFC_HDRSC_PER_VC_ERR,CDN_HPA_DLLP_UPDATEFC_DATASC_PER_VC_ERR,CDN_HPA_PME_TO_ACK_DROP_ERR,CDN_HPA_DLLP_REPLY_NUM_ROLLOVER_ERR};
                  m_error_injects[i] inside {CDN_HPA_DLLP_DUP_ACK_ERR};

                  if(m_pcie_dev_top_cfg.i_cfg.k_pcie_rate_max < 3) {
                    m_error_injects[i] != CDN_HPA_DLLP_UPDATEFC_HDRSC_CORRPT_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_UPDATEFC_DATASC_CORRPT_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_UPDATEFC_HDRSC_PER_VC_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_UPDATEFC_DATASC_PER_VC_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_INITFC1_HDRSC_UNSUPP_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_INITFC1_DATASC_UNSUPP_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_INITFC2_HDRSC_UNSUPP_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_INITFC2_DATASC_UNSUPP_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_FC_LCRC_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_FEATURE_ACK_CORRPT_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_FEATURE_SUPP_CORRPT_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_FEATURE_ACK_CORRPT_GOOD_LCRC_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_FEATURE_SUPP_CORRPT_GOOD_LCRC_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_FEATURE_NON_ZERO_RSVD_ERR;
                    m_error_injects[i] != CDN_HPA_DLLP_FEATURE_CORRUPT_RSVD_FIELD_ERR;
                  }

                  if(m_pcie_dev_top_cfg.i_cfg.k_num_vcs == 1) {
                    m_error_injects[i] !=CDN_HPA_DLLP_UPDATEFC_HDRSC_PER_VC_ERR;
                    m_error_injects[i] !=CDN_HPA_DLLP_UPDATEFC_DATASC_PER_VC_ERR ;
                  }
                  //PM DLLPs are blocked now as the feature is not yet implemented,
                  //TODO: Remove this constraints once it is available.
                  m_error_injects[i] != CDN_HPA_DLLP_PM_LCRC_ERR;
                  m_error_injects[i] != CDN_HPA_DLLP_PM_NON_ZERO_RSVD_ERR;
                  m_error_injects[i] != CDN_HPA_DLLP_PM_CORRUPT_RSVD_ERR;
                  m_error_injects[i] != CDN_HPA_DLLP_PME_TO_ACK_DROP_ERR;

                  if(!(is_cxl_pbr_mode && ((local_m_tlp_local_prefix_size>0) && m_local_prefix_possible)))
                  !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_PBR_LOCAL_PREFIX_AFTER_PTH_ERR});

                  if ((local_unmapped_tc_list_size == 0) || (m_ide_prefix_present))
                  !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_UNMAPPED_TC_ERR});

                  if (local_unmapped_tc_list_size == 7)
                  !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_CPL_TC_ERR});

                  if (!is_cxl_pbr_mode || (is_cxl_pbr_mode  && !((local_m_tlp_local_prefix_size>0) && m_local_prefix_possible))) 
                  !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_PBR_LOCAL_PREFIX_ERR});

                  if(!(parameters_cfg_pkg::NUM_UIO_VCS >0) || !(parameters_cfg_pkg::UIO_SUPPORT))
                  !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_MAP_UIO_VC_ERR, CDN_HPA_PCIE_TLP_MAP_NON_UIO_VC_ERR,CDN_HPA_PCIE_UIO_TLP_NFM,CDN_HPA_PCIE_TLP_IDE_SYNC_FAIL_MSG_ON_UIO_STREAM,CDN_HPA_PCIE_TLP_UIO_NON_SVC_PROTOCOL_ERR,CDN_HPA_PCIE_TLP_UIO_REQ_EN_DISABLED_UR_ERR,CDN_HPA_PCIE_TLP_UIO_COMPL_SUPP_DISABLED_UR_ERR,CDN_HPA_PCIE_TLP_UIO_REQ_256B_DISABLED_UR_ERR});

                  if((!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) && (m_tlp_np_req_type == CDN_HPA_PCIE_NPR_WITH_DATA))) || 
                    (m_pcie_dev_cfg.m_dmwr_req_en == 0) ||
                    ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP) && (m_pcie_link_cfg.usp_dev_config.m_dmwr_completer_supp)) ||
                    ((m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (m_pcie_link_cfg.dsp_dev_config.m_dmwr_completer_supp || m_pcie_link_cfg.dsp_dev_config.m_dmwr_routing_supp)))
                  !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_DMWR_CPL_DIS_UR_ERR});

                  if((!m_pcie_dev_top_cfg.tlp_err_inj) && (!m_pcie_dev_top_cfg.cpl_err_inj))
                  {
                    !(m_error_injects[i] inside {m_common_errors});
                  }

                  if(!m_pcie_dev_top_cfg.poisoned_err_inj)
                  !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_POISONED_ERR, CDN_HPA_PCIE_TLP_POISONED_ERR_NODATA});

                  //if(m_pcie_dev_top_cfg.ecrc_err_inj && m_pcie_dev_top_cfg.mf_err_inj && m_pcie_dev_top_cfg.scenario != null && m_pcie_dev_top_cfg.scenario.m_generate_invalidate_msg_traffic) {
                  //  m_error_injects[i] inside {CDN_HPA_PCIE_TLP_ECRC_ERR,m_malformed_errors};
                  //}

                  if(!m_pcie_dev_top_cfg.ecrc_err_inj)
                  !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_ECRC_ERR});

                  if(!m_pcie_dev_top_cfg.tlp_err_inj)
                  {
                    !(m_error_injects[i] inside {m_malformed_errors, m_UR_errors, m_CFG_UR_errors});
                  }

                  if(!m_pcie_dev_top_cfg.uio_tlp_err_inj)
                  {
                    !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_UIO_NON_SVC_PROTOCOL_ERR,CDN_HPA_PCIE_TLP_MAP_NON_UIO_VC_ERR,CDN_HPA_PCIE_TLP_IDE_SYNC_FAIL_MSG_ON_UIO_STREAM,CDN_HPA_PCIE_TLP_UIO_REQ_256B_DISABLED_UR_ERR,CDN_HPA_PCIE_TLP_UIO_REQ_EN_DISABLED_UR_ERR});
                  }

                  if(!m_pcie_dev_top_cfg.ur_err_inj)
                  {
                    !(m_error_injects[i] inside {m_UR_errors});
                  }

                  if(!m_pcie_dev_top_cfg.posted_rsvd_type_err_inj)
                  {
                    !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_FM_POSTED_RSVD_TYPE_ERR});
                  }

                  if(!m_pcie_dev_top_cfg.nonposted_rsvd_type_err_inj)
                  {
                    !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_FM_NONPOSTED_RSVD_TYPE_ERR});
                  }

                  if(!m_pcie_dev_top_cfg.completion_rsvd_type_err_inj)
                  {
                    !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_FM_CPL_RSVD_TYPE_ERR});
                  }

                  if(!m_pcie_dev_top_cfg.none_rsvd_type_err_inj)
                  {
                    !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_FM_NONE_RSVD_TYPE_ERR});
                  }

                  if(!m_pcie_dev_top_cfg.acs_err_inj)
                  {
                    !(m_error_injects[i] inside {m_acs_errors});
                  }

                  if(!m_pcie_dev_top_cfg.cfg_ur_err_inj)
                  {
                    !(m_error_injects[i] inside {m_CFG_UR_errors});
                  }
                  //if it is cpl error or it is ib/mf err
                  if(!(m_pcie_dev_top_cfg.cpl_err_inj || m_pcie_dev_top_cfg.mf_err_inj))
                  {
                    !(m_error_injects[i] inside {m_common_errors});
                  }

                  if(!m_pcie_dev_top_cfg.mf_err_inj)
                  {
                    !(m_error_injects[i] inside {m_malformed_errors});
                  }

                  if(!m_pcie_dev_top_cfg.dlp_err_inj)
                  {
                    !(m_error_injects[i] inside {m_DLP_errors});
                  }

                  if(!m_pcie_dev_top_cfg.ide_err_inj)
                  {
                    !(m_error_injects[i] inside {m_IDE_errors});
                  }

                  if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ) m_error_injects[i] != CDN_HPA_PCIE_TLP_IDE_WRONG_PR_SENT_COUNTER_ERR;

                  if(!m_pcie_dev_top_cfg.plp_err_inj)
                  {
                    !(m_error_injects[i] inside {m_PLP_errors});
                  }

                  if(!m_pcie_dev_top_cfg.dllp_err_inj)
                  {
                    !(m_error_injects[i] inside {m_DLLP_errors});
                    !(m_error_injects[i] inside {m_DLLP_errors_initfcs});
                  }
                  if(!m_pcie_dev_top_cfg.dll_flit_err_inj)
                  {
                    !(m_error_injects[i] inside {m_FLIT_DLLP_errors});
                  }

                  if(!m_pcie_dev_top_cfg.cpl_err_inj)
                  {
                    !(m_error_injects[i] inside {m_CPL_errors});
                  }

                  if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MSG_TYPE)
                  {
                    !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_FAIL_ERR});
                    !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_FAIL_WRONG_ECRC_ERR});
                  }

                  //PCIE-14488: Non-Func Specific message with PCRC error has issue.
                  if(m_ide_p == 0 || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID))) !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_WRONG_PCRC_ERR});
                  if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MSG_TYPE) !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_FAIL_ERR,CDN_HPA_PCIE_TLP_IDE_FAIL_WRONG_ECRC_ERR,CDN_HPA_PCIE_TLP_IDE_FAIL_INVALID_STREAM_ID_ERR,CDN_HPA_PCIE_TLP_IDE_FAIL_INVALID_TC_ERR,CDN_HPA_PCIE_TLP_IDE_FAIL_INVALID_STREAM_TC_ERR});

                  if(!m_ide_prefix_present || m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_MAC_BIT_ZERO_WHN_AGGR_NOT_SUPP});
                  if(!m_ide_prefix_present || !m_pcie_dev_top_cfg.ide_cfg.m_aggr_supp) !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_MAC_BIT_ZERO_GRT_EIGHT_TLPS_WHN_AGGR_SUPP});

                  if(m_tlp_req_type != CDN_HPA_PCIE_TRANS_NON_POSTED_REQ)
                  !(m_error_injects[i] inside {m_CPL_errors});

                  if((m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ) &&
                  (m_tlp_type inside {
                    CDN_HPA_PCIE_TLP_TYPE_CfgWr0,
                    CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
                    CDN_HPA_PCIE_TLP_TYPE_IOWr,
                    CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
                    CDN_HPA_PCIE_TLP_TYPE_DMWr_32})) //non-posted packets with no payload in their completion
                    {
                      !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_CPL_POISON_ERR});
                    }

                    //    //this is a hack
                    // if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ)
                    // {
                    //   if(!l_is_memrd_op)
                    //     m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_LOWER_ADDR_UNEXP_ERR;
                    //   else
                    //     (m_error_injects[i] inside {m_CPL_errors, m_common_errors});
                    // }
                    // UR Errors
                    //trans type

                    if(!m_ide_prefix_present)
                    {
                      !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_WRONG_MAC_ERR, CDN_HPA_PCIE_TLP_IDE_WRONG_PR_SENT_COUNTER_ERR, CDN_HPA_PCIE_TLP_IDE_INVALID_SUBSTREAM_ERR});
                    }

                    //soumitm :: TODO :: set these errors as IDE TLP also
                    if(m_ide_prefix_present)
                    {
                      !(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IDE_FAIL_ERR, CDN_HPA_PCIE_TLP_IDE_FAIL_WRONG_ECRC_ERR, CDN_HPA_PCIE_TLP_IDE_FAIL_INVALID_STREAM_ID_ERR, CDN_HPA_PCIE_TLP_IDE_FAIL_INVALID_TC_ERR});
                    }

                    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CFG_TYPE)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_CFG_TYPE1_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_CFG_UNSUPP_FUNC_UR_ERR;
                    }
                    //if(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE, CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CPL_TYPE})
                    //{
                    //  m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_POSTED_RSVD_TYPE_ERR;
                    //  m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_NONPOSTED_RSVD_TYPE_ERR;
                    //}

                    //if(((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_rout_type!=CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID)))
                    //{
                    //  m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_POSTED_RSVD_TYPE_ERR;
                    //  m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_NONPOSTED_RSVD_TYPE_ERR;
                    //}

                    //if (m_hdr_fmt inside {CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA, CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA}){
                    //  m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_POSTED_RSVD_TYPE_ERR;
                    //  m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_NONPOSTED_RSVD_TYPE_ERR;
                    //}

                    if(m_tlp_req_type != CDN_HPA_PCIE_TRANS_POSTED_REQ)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_POSTED_RSVD_TYPE_ERR;
                    }

                    if(m_tlp_req_type != CDN_HPA_PCIE_TRANS_NON_POSTED_REQ)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_NONPOSTED_RSVD_TYPE_ERR;
                    }

                    //if((m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MSG_TYPE) || (m_tlp_msg_rout_type!=CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE))
                    //{
                    //  m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_NONE_RSVD_TYPE_ERR;
                    //}
                    
                    if(m_tlp_req_type != CDN_HPA_PCIE_TRANS_POSTED_REQ)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_FM_NONE_RSVD_TYPE_ERR;
                    }

                    if(!(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE))
                    (!(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_IO_TX_BAR_UR_ERR, CDN_HPA_PCIE_TLP_IO_REQ_MEM_BAR_HIT_UR_ERR}));

                    if(!(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_MEM_TYPE}))
                    m_error_injects[i] != CDN_HPA_PCIE_TLP_WR_HIT_EROM_BAR_UR_ERR;

                    if(!(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP))
                    (!(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_MSG_UNSUPP_FUNC_UR_ERR, CDN_HPA_PCIE_TLP_OBFF_EN_UR_ERR, CDN_HPA_PCIE_TLP_PTM_CAP_UR_ERR}));

                    if(!(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP))
                    (!(m_error_injects[i] inside {CDN_HPA_PCIE_TLP_OBFF_DSP_UR_ERR, CDN_HPA_PCIE_TLP_PTM_CAP_UR_ERR}));

                    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_IO_TYPE)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_EN_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_TX_BAR_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_REQ_MEM_BAR_HIT_UR_ERR;
                    }

                    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MEM_TYPE)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_AOP_LEN_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MRDLK_EP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_EN_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_TX_BAR_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_REQ_IO_BAR_HIT_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DMWR_CPL_DIS_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DMWR_LEN_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DMWR_LEN_MALFORMED_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_VF_MSE_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_NON_MRD_AT_REQ_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_AT_RSVD_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_E2E_UNSUPP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_EXT_TAG_DISABLED_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PASID_DISABLED_UR_ERR;
                      `ifndef HLS_MODULE_MODE
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_PASID_MAX_WIDTH_UR_ERR;
                      `endif
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DSP_RX_AOP_WHEN_EGRESS_BLOCK_ERR;
                    }
                    
                    if(!(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64})) {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DMWR_LEN_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DMWR_LEN_MALFORMED_ERR;
                    }

                    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MSG_TYPE)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_CODE_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_TYPE_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_ROUTING_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_UNSUPP_FUNC_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_WRONG_BD_NO_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_LTR_DSP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_DSP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_DIS_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_OBFF_DSP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_OBFF_EN_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_CAP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_INV_REQ_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_ATS_UR_ERR;
                    }

                    if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0, CDN_HPA_PCIE_TLP_MSG_VD_Type1})){
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_TYPE_UR_ERR;
                    }

                    //As per JIRA 11419, need to updated top level config to get proper func info
                    if (((!m_pcie_link_cfg.usp_dev_top_config.filter_ur_tlp) && (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP)) ||
                    ((!m_pcie_link_cfg.dsp_dev_top_config.filter_ur_tlp) && (m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP))  ||
                    ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_rout_type != CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID)))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_UNSUPP_FUNC_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_REQ_MEM_BAR_HIT_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_REQ_IO_BAR_HIT_UR_ERR;
                    }

                    if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0, CDN_HPA_PCIE_TLP_MSG_VD_Type1})
                    m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_ROUTING_UR_ERR;

                    `ifndef HLS_MODULE_MODE
                      //For moduel tb, error got injected through inject_error call in cif router.
                      //This error should get injected in seq item while sending Non-Posted packet only.
                      if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CPL_TYPE)
                      {
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_RSVD_UR_ERR;
                      }
                    `endif

                    if(!(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_MEM_TYPE}))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_BUS_MASTER_EN_UR_ERR;
                    }

                    //port type
                    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_LTR_DSP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_NON_MRD_AT_REQ_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_AT_RSVD_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_DSP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_OBFF_DSP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DSP_RX_AOP_WHEN_EGRESS_BLOCK_ERR;
                    }

                    if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_ATS_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_E2E_UNSUPP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_INV_REQ_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_CFG_UNSUPP_FUNC_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_CFG_TYPE1_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MRDLK_EP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_OBFF_EN_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PASID_DISABLED_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_DIS_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_WRONG_BD_NO_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_TX_BAR_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_REQ_MEM_BAR_HIT_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_UNSUPP_FUNC_UR_ERR;
                    }

                    //capability
                    //config
                    if(!(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && m_pcie_dut_dev_cfg.acs_source_validation_en && (m_pcie_dev_top_cfg.scenario != null) && m_pcie_dev_top_cfg.scenario.acs_source_validation))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_ACS_SOURCE_VALIDATION_ERR;
                    }
                    if(!(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && m_pcie_dut_dev_cfg.acs_translation_blocking_en && (m_pcie_dev_top_cfg.scenario != null) && m_pcie_dev_top_cfg.scenario.acs_translation_blocking))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_ACS_TRANSLATION_BLOCKING_ERR;
                    }
                    if(!(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && m_pcie_dut_dev_cfg.acs_io_request_blocking_en && (m_pcie_dev_top_cfg.scenario != null) && m_pcie_dev_top_cfg.scenario.acs_io_request_blocking))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_ACS_IO_REQUEST_BLOCKING_ERR;
                    }
                    if(m_pcie_dev_cfg.m_ltr_supp && m_pcie_dev_cfg.m_ltr_en)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_LTR_DSP_UR_ERR;
                    }
                    if(!(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && m_pcie_dev_cfg.m_ptm_requester_cap && m_pcie_dut_dev_cfg.m_cap_ptm_supp && !m_pcie_dut_dev_cfg.m_ptm_en))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_DSP_UR_ERR;
                    }
                    if(!(m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP && m_pcie_dev_cfg.m_ptm_requester_cap && m_pcie_dut_dev_cfg.m_cap_ptm_supp && !m_pcie_dut_dev_cfg.m_ptm_en))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_DIS_UR_ERR;
                    }
                    if(m_pcie_dut_dev_cfg.m_port_type != CDN_HPA_PCIE_DSP)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_OBFF_DSP_UR_ERR;
                    }
                    if((m_pcie_dut_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) && (m_pcie_dut_dev_cfg.m_obff_en inside {2'b01,2'b10}))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_OBFF_EN_UR_ERR;
                    }
                    if(m_pcie_dut_dev_cfg.m_cap_ptm_supp)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_CAP_UR_ERR;
                    }
                    if(m_pcie_dut_dev_cfg.en_memory_space)//todo::access DUT's dev config
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_EN_UR_ERR;
                    }
                    if(m_pcie_dut_dev_cfg.en_io_space) //todo::access DUT's dev config
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_EN_UR_ERR;
                    }
                    if(m_pcie_dut_dev_cfg.en_bus_master) //todo::access DUT's dev config
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_BUS_MASTER_EN_UR_ERR;
                    }
                    if((m_pcie_dev_cfg.m_vf_mse && m_pcie_dev_cfg.m_vf_en) || (!m_pcie_dev_cfg.m_vf_en))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MEM_VF_MSE_UR_ERR;
                    }
                    if((m_pcie_dut_dev_cfg.m_cap_ats_en == 0) || (m_pcie_dut_dev_cfg.m_ats_stu == 0/*4KB*/) )
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_INV_REQ_UR_ERR;
                    }
                    if((m_pcie_dut_dev_cfg.m_e2e_tlp_prefix_support ==1) || (is_e2e_tlp_prefix_supp == 0))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_E2E_UNSUPP_UR_ERR;
                    }
                    //if E2E tlp prefix is supported in device and it is not supported to a particular function it is a UR error.
                    //if E2E tlp prefix is not supported in device, then receiving it is a malformed error.
                    if(is_e2e_tlp_prefix_supp == 1)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_E2E_PREFIX_WO_SUPPORT_ERR;
                    }
                    if((((!((m_pcie_dev_cfg.m_tph_req_en inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_REQ_SUPPORTED}) &&
                    (m_pcie_dut_dev_cfg.m_tph_cpl_support inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_CPL_SUPPORTED}) &&
                    (m_pcie_dev_cfg.m_e2e_tlp_prefix_support ==1 ) &&
                    (m_pcie_dev_cfg.m_ext_fmt_field_support ==1 ) &&
                    (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)
                    ) && (!m_pcie_dev_cfg.bypass_prefix_cfgs))||(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)  && (m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request)) && (m_pcie_dev_cfg.bypass_prefix_cfgs)))
                    && 
                    ((!(((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (m_tlp_at_type != CDN_HPA_PCIE_AT_Translated)) ||
                    ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}))) && ((m_pcie_dev_cfg.bypass_prefix_cfgs)))||((!((((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (m_tlp_at_type != CDN_HPA_PCIE_AT_Translated)) ||
                    ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}))) &&
                    (m_pcie_dev_cfg.m_e2e_tlp_prefix_support ==1 ) && //active bfm end should have e2e_prefix support
                    (m_pcie_dut_dev_cfg.m_e2e_tlp_prefix_support ==1 )  //active bfm end should have e2e_prefix support
                    )&&(!m_pcie_dev_cfg.bypass_prefix_cfgs))))))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_E2E_PREFIX_WO_SUPPORT_ERR;
                    }
                    if(m_pcie_dut_dev_cfg.m_tph_cpl_support inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_CPL_SUPPORTED})
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_EXT_TAG_DISABLED_UR_ERR;
                    }
                    if(!m_pcie_dut_dev_cfg.m_cap_pasid_supp || (m_pcie_dut_dev_cfg.m_cap_pasid_supp && m_pcie_dut_dev_cfg.m_pasid_enb))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PASID_DISABLED_UR_ERR;
                    }
                    if(m_pcie_dev_top_cfg.i_cfg.k_ide_supported)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_IDE_DISABLED_UR_ERR;
                    }
                    if(!(m_pcie_dut_dev_cfg.m_cap_pasid_supp && m_pcie_dut_dev_cfg.m_pasid_enb))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PASID_MAX_WIDTH_UR_ERR;
                    }
                    if(m_pcie_dut_dev_cfg.m_cap_ats_supp)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_ATS_UR_ERR;
                    }
                    if((!(m_pcie_dut_dev_cfg.m_atomic_op_egress_block)) || (m_pcie_dut_dev_cfg.m_atomic_op_req_en == 0))
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DSP_RX_AOP_WHEN_EGRESS_BLOCK_ERR;
                    }

                    if(m_pcie_dut_dev_cfg.m_32_atomic_op_compl_supp && m_pcie_dut_dev_cfg.m_64_atomic_op_compl_supp && m_pcie_dut_dev_cfg.m_128_cas_compl_supp)
                    m_error_injects[i] != CDN_HPA_PCIE_TLP_AOP_LEN_UR_ERR;

                    if(!m_is_atomic_op)
                    m_error_injects[i] != CDN_HPA_PCIE_TLP_AOP_LEN_UR_ERR;

                    if(!(l_is_memrd_op || (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE) || (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE)))
                    m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_LOWER_ADDR_UNEXP_ERR;

                    if((m_pcie_dev_top_cfg.tc_vc_map[m_tlp_tc] != 0) && m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE)//to avoid reserved message code err as malformed because only vendor defined messages are allowed on non-zero tc
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MSG_CODE_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_ATS_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PASID_MAX_WIDTH_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PASID_DISABLED_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PREFIX_GTHN_SUPPORT_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_PTM_CAP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_LTR_DSP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DSP_ISSUE_ERR_MSG_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_DSP_ISSUE_INTX_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_OBFF_EN_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_OBFF_DSP_UR_ERR;
                    }

                    if(m_tlp_tc != 0)
                    {
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_LTR_DSP_UR_ERR;
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_MRDLK_EP_UR_ERR;
                    }
                    if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64,CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64}) //change mrd32/64 only (nonposted requests to mrdlk to avoid complications related to expected completions at active BFM)
                    m_error_injects[i] != CDN_HPA_PCIE_TLP_MRDLK_EP_UR_ERR;
                    //m_error_injects[i] == CDN_HPA_PCIE_TLP_LTR_DSP_UR_ERR;// set_req_tlp_mrdlk_ep_ur_err();
                    //todo::not support m_error_injects[i] == CDN_HPA_PCIE_TLP_AOP_LEN_UR_ERR;// set_req_tlp_mrdlk_ep_ur_err();
                    //m_error_injects[i] == CDN_HPA_PCIE_TLP_PASID_DISABLED_UR_ERR;
                    //m_error_injects[i] == CDN_HPA_PCIE_TLP_PASID_MAX_WIDTH_UR_ERR;
                    //m_error_injects[i] inside {CDN_HPA_PCIE_TLP_MSG_TYPE_UR_ERR, CDN_HPA_PCIE_TLP_MSG_ROUTING_UR_ERR, CDN_HPA_PCIE_TLP_MSG_CODE_UR_ERR};
                    //m_error_injects[i] == CDN_HPA_PCIE_TLP_E2E_UNSUPP_UR_ERR;
                    //m_error_injects[i] == CDN_HPA_PCIE_TLP_ATS_UR_ERR;

                    //cannot do len neq payload error : it will give problems in do_unpack method
                    //m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_LEN_NEQ_PAYLOAD_ERR;
                    //m_error_injects[i] !  = CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR;
                    //if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CPL_TYPE)
                    //if(i==0)
                    //m_error_injects[i] ==  CDN_HPA_PCIE_TLP_TD_WO_ECRC_ERR;
                    //else
                    //  m_error_injects[i] ==  CDN_HPA_PCIE_PLP_SDP_ERR;

                    if(!(m_pcie_dut_dev_cfg.m_cap_pasid_supp && m_pcie_dut_dev_cfg.m_pasid_enb && m_pcie_dut_dev_cfg.m_e2e_tlp_prefix_support && m_pcie_dut_dev_cfg.m_ext_fmt_field_support && m_pcie_dut_dev_cfg.m_ext_tph_req_supp))
                    //if(hpa_tlp.m_pcie_dut_dev_cfg.m_max_e2e_support < 2)
                    m_error_injects[i] !=  CDN_HPA_PCIE_TLP_PREFIX_GTHN_SUPPORT_ERR;

                    if(!(local_pasid_prefix^local_tph_prefix))
                    m_error_injects[i] !=  CDN_HPA_PCIE_TLP_PREFIX_GTHN_SUPPORT_ERR;


                    if(!(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_CfgRd0:CDN_HPA_PCIE_TLP_TYPE_CfgWr1], CDN_HPA_PCIE_TLP_TYPE_DMWr_32, CDN_HPA_PCIE_TLP_TYPE_DMWr_64}))
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_CRS_VALID;

                    if(!((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_IORd, CDN_HPA_PCIE_TLP_TYPE_IOWr, CDN_HPA_PCIE_TLP_TYPE_MRd_32, CDN_HPA_PCIE_TLP_TYPE_MRd_64}) || m_is_atomic_op))
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_CRS_ERR;

                    if(!(m_tlp_type inside {
                      CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
                      CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,
                      CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
                      CDN_HPA_PCIE_TLP_TYPE_IOWr,CDN_HPA_PCIE_TLP_TYPE_MsgD,
                      CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
                      CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
                      CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
                      CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64}))
                      m_error_injects[i] != CDN_HPA_PCIE_TLP_POISONED_ERR;
                      if((m_tlp_type inside {
                        CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
                        CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,
                        CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
                        CDN_HPA_PCIE_TLP_TYPE_IOWr,CDN_HPA_PCIE_TLP_TYPE_MsgD,
                        CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
                        CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
                        CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
                        CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64}))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_POISONED_ERR_NODATA;


                        // if(!is_cpl_err)
                        // {
                        //   m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_CRS_ERR;
                        //   m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_CA_ERR;
                        //   m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_UR_ERR;
                        //   m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_LOWER_ADDR_UNEXP_ERR;
                        //   m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_BYTE_COUNT_UNEXP_ERR;
                        //   m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_PASID_CA_ERR;
                        //   m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_TRANSLATION_STU_UR_ERR;
                        //   m_error_injects[i] != CDN_HPA_PCIE_TLP_CPLDS_RCB_ERR;
                        // }
                        if(!(/*is_cpl_err && */(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}) && (m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) && m_pasid_prefix_present))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_CPL_PASID_CA_ERR;
                          m_error_injects[i] !=CDN_HPA_PCIE_TLP_CPL_TRANSLATION_STU_UR_ERR;
                        }

                        if(!m_tlp_td)
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_ECRC_ERR;
                        }
                        if(!(m_tlp_td))//remove ecrc
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_TD_WO_ECRC_ERR;
                        }
                        if((m_tlp_td))//remove ecrc
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_NO_TD_WD_ECRC_ERR;
                        }

                        if(((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Msg, CDN_HPA_PCIE_TLP_TYPE_MsgD, [CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32:CDN_HPA_PCIE_TLP_TYPE_Cas_64]}) ||
                        (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32, CDN_HPA_PCIE_TLP_TYPE_MRd_64, CDN_HPA_PCIE_TLP_TYPE_DMWr_64, CDN_HPA_PCIE_TLP_TYPE_DMWr_32} && m_tlp_th) ||
                        !(m_tlp_trans_type inside { CDN_HPA_PCIE_TRANS_MEM_TYPE,  CDN_HPA_PCIE_TRANS_IO_TYPE, CDN_HPA_PCIE_TRANS_CFG_TYPE})))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_FBE_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_2_FBE_NCBE_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_EQ_1_LBE_NON_0_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_1_LBE_0_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_2_LBE_NCBE_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR;
                        }
                        else
                        {
                          if(!(m_tlp_length > 1))
                          {
                            m_error_injects[i] != CDN_HPA_PCIE_TLP_FBE_ERR;
                          }
                          if(!(m_tlp_length > 2 || m_tlp_length == 0))
                          {
                            m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_2_FBE_NCBE_ERR;
                          }
                          if(!(m_tlp_length == 1))
                          {
                            m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_EQ_1_LBE_NON_0_ERR;
                          }
                          if(!(m_tlp_length > 1))
                          {
                            m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_1_LBE_0_ERR;
                          }
                          if(!(m_tlp_length > 2 || m_tlp_length == 0))
                          {
                            m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_2_LBE_NCBE_ERR;
                          }
                          if((m_tlp_length != 2) || (m_tlp_addr[2] == 0))
                          {
                            m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_EQ_2_FBE_NCBE_ERR;
                            m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_EQ_2_LBE_NCBE_ERR;
                          }
                        }
                        if(!m_is_atomic_op)
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_ATOMIC_OP_LEN_ERR;//payload - len change error
                        }
                        if (((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32, CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64, CDN_HPA_PCIE_TLP_TYPE_Swap_32, CDN_HPA_PCIE_TLP_TYPE_Swap_64}) && (m_tlp_length==1)) || 
                            ((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cas_32, CDN_HPA_PCIE_TLP_TYPE_Cas_64}) && (m_tlp_length==2)))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_ATOMICOP_ADDR_ERR;
                        }
                        if(m_pcie_dev_top_cfg.tc_vc_mapping_done==0) {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_UNMAPPED_TC_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_CFG_MSG_NON_0_TC_ERR;
                          //!(m_error_injects[i] inside {m_malformed_errors, m_common_errors});//fatal errors
                        }
                        if(!l_dut_dev_top_cfg.bypass_credit_check) {
                          if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ)
                          if(l_dut_dev_top_cfg.malform_credit_limit_p[vc] ==0) {
                            !(m_error_injects[i] inside {m_malformed_errors, m_common_errors});//fatal errors
                          }
                          if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ)
                          if(l_dut_dev_top_cfg.malform_credit_limit_np[vc] ==0) {
                            !(m_error_injects[i] inside {m_malformed_errors, m_common_errors});//fatal errors
                          }
                          if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION)
                          if(l_dut_dev_top_cfg.malform_credit_limit_cpl[vc] ==0) {
                            !(m_error_injects[i] inside {m_common_errors});//fatal errors
                          }
                        }

                        //if m_unmapped_tc_list has all the tc except 0 (1,2,3,4,5,6,7)
                        //then don't inject non 0 TC error
                        //i({m_pcie_dev_top_cfg.m_unmapped_tc_list});
                        if(all_unmapped_tc)
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_CFG_MSG_NON_0_TC_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_VDM_MSG_NON_0_TC_ERR;
                        }

                        if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) || 
                           m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_Cpl,CDN_HPA_PCIE_TLP_TYPE_CplLk} || 
                           m_is_atomic_op || 
                           (m_tlp_length == 1) || 
                           ((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64}) && (({m_tlp_addr[11:2], 2'b00} + m_pcie_dev_top_cfg.get_min_rrs_in_dw()) < 'h400)) || 
                           ((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64}) && (({m_tlp_addr[11:2], 2'b00} + m_pcie_dev_cfg.m_max_payload_size_dw) < 'h400)))
                         m_error_injects[i] != CDN_HPA_PCIE_TLP_ADDR_CROSS_4K_BNDRY_ERR;

                        if(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE )
                        || (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE)
                        || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && !(m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type0,CDN_HPA_PCIE_TLP_MSG_VD_Type1}))))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_CFG_MSG_NON_0_TC_ERR;
                        if(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type1 && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_DRS, CDN_HPA_PCIE_TLP_VDM_FRS, CDN_HPA_PCIE_TLP_VDM_HIER_ID}))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_VDM_MSG_NON_0_TC_ERR;
                        if(non_zero_tc)
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_CFG_MSG_NON_0_TC_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_VDM_MSG_NON_0_TC_ERR;
                        }

                        if(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type1 && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_HIER_ID}))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_VDM_HIER_ID_LEN_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_VDM_HIER_ID_TLP_TYPE_ERR;
                        }
                        if(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type1 && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_FRS}))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_VDM_FRS_TYPE_ERR;
                        }
                        if(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type1 && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_DRS}))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_VDM_DRS_TYPE_ERR;
                        }
                        if(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_VD_Type1 && m_tlp_vdm_msg_subtype inside {CDN_HPA_PCIE_TLP_VDM_DRS, CDN_HPA_PCIE_TLP_VDM_FRS, CDN_HPA_PCIE_TLP_VDM_HIER_ID}))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_VDMSG_ROUTING_ERR;
                        }
                        if(!((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE) || (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE)))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_ATTR_ERR;
                          //m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_CFG_LBE_ERR;
                        }

                        //hack for attribute error
                        // if((((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE) || (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE))&& (m_pcie_dev_top_cfg.cpl_err_inj == 1)))
                        //   m_error_injects[i] == CDN_HPA_PCIE_TLP_ATTR_ERR;


                        //if(!(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && ((m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_MsgD) || (m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_Msg))))
                        if(!(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_Msg))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_DSP_ISSUE_INTX_ERR;
                        if(!(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_DSP && (m_tlp_type ==  CDN_HPA_PCIE_TLP_TYPE_Msg)))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_DSP_ISSUE_ERR_MSG_ERR;
                        if(m_tlp_type inside {
                          CDN_HPA_PCIE_TLP_TYPE_MRd_32,
                          CDN_HPA_PCIE_TLP_TYPE_MRd_64,
                          CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,
                          CDN_HPA_PCIE_TLP_TYPE_MRdLk_64
                        }&& (!m_pcie_dev_top_cfg.cpl_err_inj))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR;

                        if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_DMWr_32, CDN_HPA_PCIE_TLP_TYPE_DMWr_64})
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR;

                        if(m_is_atomic_op && (!m_pcie_dev_top_cfg.cpl_err_inj))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR;
                        }
                        if(m_tlp_trans_type ==  CDN_HPA_PCIE_TRANS_CPL_TYPE)
                        {
                          if((m_tlp_type inside { CDN_HPA_PCIE_TLP_TYPE_Cpl, CDN_HPA_PCIE_TLP_TYPE_CplLk}))
                          {
                            m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR;
                          }
                          //m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR;
                        }
                        if(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg)
                        ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl)
                        ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplLk)
                        ||(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE && (m_pcie_dev_top_cfg.cpl_err_inj == 0))
                        ||(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE && (m_pcie_dev_top_cfg.cpl_err_inj == 0))
                        ||(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_SLOT_Power_Limit)
                        ||(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_AT_Invalidate)
                        ||(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MsgD && m_tlp_msg_code == CDN_HPA_PCIE_TLP_MSG_PTM_Resp_RespD)
                        ||(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_LN)
                        ||(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_HIER_ID)))
                        //length = 1
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR;

                        if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_IO_TYPE && (m_pcie_dev_top_cfg.cpl_err_inj == 1) && m_tlp_type != CDN_HPA_PCIE_TLP_TYPE_IORd)
                        ||(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CFG_TYPE && (m_pcie_dev_top_cfg.cpl_err_inj == 1) && (!m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd1, CDN_HPA_PCIE_TLP_TYPE_CfgRd0})))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR;

                        if(!(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_IORd, CDN_HPA_PCIE_TLP_TYPE_IOWr}))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_IO_LEN_ERR;

                        if(!(m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_CfgRd0:CDN_HPA_PCIE_TLP_TYPE_CfgWr1]}))
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_CFG_LEN_ERR;

                        if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_32)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRdLk_64)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_IORd)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd0)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CfgRd1)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl)
                        || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_CplLk)) //m_tlp_payload.size() = 0
                        m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR;

                        if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_VD_Type1}) && m_tlp_vdm_msg_subtype == CDN_HPA_PCIE_TLP_VDM_HIER_ID)
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR;
                        }
                        else
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_VDM_HIER_ID_LEN_ERR;
                        }
                        if(!(((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_32) ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_MRd_64)) && m_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request))
                        {
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_AT_ODD_DWORD_ERR;
                          m_error_injects[i] != CDN_HPA_PCIE_TLP_AT_EXCEED_RCB_ERR;
                        }
                        ////if(!((m_ext_tph_prefix_possible==0 && m_pasid_prefix_possible==0) || (m_pcie_link_cfg.usp_dev_config.m_e2e_tlp_prefix_support ==1)))
                        if(!(((m_pcie_dev_cfg.m_tph_req_en inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_REQ_SUPPORTED}) &&
                        (m_pcie_dut_dev_cfg.m_tph_cpl_support inside {CDN_HPA_PCIE_TPH_AND_EXT_TPH_CPL_SUPPORTED}) &&
                        !(m_pcie_dut_dev_cfg.m_e2e_tlp_prefix_support ==1 ) &&
                        (m_pcie_dut_dev_cfg.m_ext_fmt_field_support ==1 ) &&
                        (m_pcie_dev_cfg.m_ext_tph_req_supp ==1 ) &&
                        (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE)
                      )||
                      ((((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (m_tlp_at_type != CDN_HPA_PCIE_AT_Translated)) || ((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE) && (m_tlp_msg_code inside {CDN_HPA_PCIE_TLP_MSG_AT_Invalidate,CDN_HPA_PCIE_TLP_MSG_PR_Request,CDN_HPA_PCIE_TLP_MSG_PR_Group_Response}))) &&
                      !(m_pcie_dut_dev_cfg.m_e2e_tlp_prefix_support ==1 ) && //Other end should have e2e_prefix support
                      (m_pcie_dut_dev_cfg.m_ext_fmt_field_support ==1 ) /*&&
                      (m_pcie_dut_dev_cfg.m_pasid_enb ==1 ) //EP Device should have PASID Enabled*/ /*for this error injection keep pasid en = 1*/
                    )))
                    m_error_injects[i] != CDN_HPA_PCIE_TLP_E2E_PREFIX_WO_SUPPORT_ERR;
                  }

                });
              end
            end //}
            foreach(vip_userdata.m_error_injects[i])
            begin //{
              if(vip_userdata.m_error_injects[i] inside {  CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR,
              CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR,
              CDN_HPA_PCIE_TLP_ATOMIC_OP_LEN_ERR,
              CDN_HPA_PCIE_TLP_VDM_HIER_ID_LEN_ERR,
              CDN_HPA_PCIE_TLP_CPL_LEN_NEQ_PAYLOAD_ERR,
              CDN_HPA_PCIE_TLP_CPL_LEN_GTHN_MPS_ERR })
              foreach(vip_userdata.m_error_injects[j])
              if((j>i) && (vip_userdata.m_error_injects[j] inside {  CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR,
              CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR,
              CDN_HPA_PCIE_TLP_ATOMIC_OP_LEN_ERR,
              CDN_HPA_PCIE_TLP_VDM_HIER_ID_LEN_ERR,
              CDN_HPA_PCIE_TLP_CPL_LEN_NEQ_PAYLOAD_ERR,
              CDN_HPA_PCIE_TLP_CPL_LEN_GTHN_MPS_ERR }))
              vip_userdata.m_error_injects[j] = CDN_HPA_PCIE_TLP_NO_ERR;
              if(vip_userdata.m_error_injects[i] inside { CDN_HPA_PCIE_TLP_ATOMIC_OP_LEN_ERR} || (vip_userdata.m_error_injects[i] inside { CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR} && m_is_atomic_op))
              foreach(vip_userdata.m_error_injects[j])
              if(j>i && vip_userdata.m_error_injects[j] inside {CDN_HPA_PCIE_TLP_ATOMICOP_ADDR_ERR})
              vip_userdata.m_error_injects[j] = CDN_HPA_PCIE_TLP_NO_ERR;
              if(vip_userdata.m_error_injects[i] inside { CDN_HPA_PCIE_TLP_ATOMICOP_ADDR_ERR})
              foreach(vip_userdata.m_error_injects[j])
              if(j>i && vip_userdata.m_error_injects[j] inside {CDN_HPA_PCIE_TLP_ATOMIC_OP_LEN_ERR, CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR})
              vip_userdata.m_error_injects[j] = CDN_HPA_PCIE_TLP_NO_ERR;
              if(vip_userdata.m_error_injects[i] inside { CDN_HPA_PCIE_TLP_NO_TD_WD_ECRC_ERR, CDN_HPA_PCIE_TLP_TD_WO_ECRC_ERR})
              foreach(vip_userdata.m_error_injects[j])
              if((j>i) && (vip_userdata.m_error_injects[j] inside {  CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR,
              CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR,
              CDN_HPA_PCIE_TLP_ATOMIC_OP_LEN_ERR,
              CDN_HPA_PCIE_TLP_VDM_HIER_ID_LEN_ERR,
              CDN_HPA_PCIE_TLP_CPL_LEN_NEQ_PAYLOAD_ERR,
              CDN_HPA_PCIE_TLP_CPL_LEN_GTHN_MPS_ERR }))
              vip_userdata.m_error_injects[j] = CDN_HPA_PCIE_TLP_NO_ERR;
              if(vip_userdata.m_error_injects[i] inside { CDN_HPA_PCIE_TLP_FBE_ERR, CDN_HPA_PCIE_TLP_LEN_GTHN_2_FBE_NCBE_ERR})
              foreach(vip_userdata.m_error_injects[j])
              if(j>i && vip_userdata.m_error_injects[j] inside { CDN_HPA_PCIE_TLP_FBE_ERR,
              CDN_HPA_PCIE_TLP_LEN_GTHN_2_FBE_NCBE_ERR,
              CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR,
              CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR })
              vip_userdata.m_error_injects[j] = CDN_HPA_PCIE_TLP_NO_ERR;
              if(vip_userdata.m_error_injects[i] inside { CDN_HPA_PCIE_TLP_LEN_GTHN_1_LBE_0_ERR,
              CDN_HPA_PCIE_TLP_LEN_EQ_1_LBE_NON_0_ERR,
              CDN_HPA_PCIE_TLP_LEN_GTHN_2_LBE_NCBE_ERR })
              foreach(vip_userdata.m_error_injects[j])
              if(j>i && vip_userdata.m_error_injects[j] inside { CDN_HPA_PCIE_TLP_LEN_GTHN_1_LBE_0_ERR,
              CDN_HPA_PCIE_TLP_LEN_EQ_1_LBE_NON_0_ERR,
              CDN_HPA_PCIE_TLP_LEN_GTHN_2_LBE_NCBE_ERR,
              CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR,
              CDN_HPA_PCIE_TLP_LEN_NEQ_PAYLOAD_ERR })
              vip_userdata.m_error_injects[j] = CDN_HPA_PCIE_TLP_NO_ERR;
              if(vip_userdata.m_error_injects[i] inside { CDN_HPA_PCIE_TLP_ADDR_CROSS_4K_BNDRY_ERR})
              foreach(vip_userdata.m_error_injects[j])
              if((j>i) && (vip_userdata.m_error_injects[j] inside {  CDN_HPA_PCIE_TLP_LEN_GTHN_MPS_ERR,
              CDN_HPA_PCIE_TLP_ATOMIC_OP_LEN_ERR,
              CDN_HPA_PCIE_TLP_VDM_HIER_ID_LEN_ERR,
              CDN_HPA_PCIE_TLP_CPL_LEN_GTHN_MPS_ERR }))
              vip_userdata.m_error_injects[j] = CDN_HPA_PCIE_TLP_NO_ERR;
              if(vip_userdata.m_error_injects[i] inside { CDN_HPA_PCIE_TLP_DSP_ISSUE_ERR_MSG_ERR, CDN_HPA_PCIE_TLP_DSP_ISSUE_INTX_ERR})
              foreach(vip_userdata.m_error_injects[j])
              if((j>i) && (vip_userdata.m_error_injects[j] inside {  CDN_HPA_PCIE_TLP_DSP_ISSUE_ERR_MSG_ERR,
              CDN_HPA_PCIE_TLP_DSP_ISSUE_INTX_ERR,
              CDN_HPA_PCIE_TLP_VDMSG_ROUTING_ERR,
              CDN_HPA_PCIE_TLP_VDM_MSG_NON_0_TC_ERR,
              CDN_HPA_PCIE_TLP_VDM_HIER_ID_LEN_ERR,
              CDN_HPA_PCIE_TLP_VDM_HIER_ID_TLP_TYPE_ERR,
              CDN_HPA_PCIE_TLP_VDM_DRS_TYPE_ERR,
              CDN_HPA_PCIE_TLP_VDM_FRS_TYPE_ERR
            }))
            vip_userdata.m_error_injects[j] = CDN_HPA_PCIE_TLP_NO_ERR;
          end //}
          if(!(m_pcie_dev_cfg.bypass_dut_type_chk))
          begin //{
            foreach(vip_userdata.m_error_injects[i])
            begin //{
              if(vip_userdata.m_error_injects[i] inside {vip_userdata.m_malformed_errors, vip_userdata.m_common_errors})
              begin //{
                if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ)
                if(l_dut_dev_top_cfg.malform_credit_limit_p[vc] > 0)
                begin //{
                  l_dut_dev_top_cfg.malform_credit_limit_p[vc]--;
                end //}
                if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_NON_POSTED_REQ)
                if(l_dut_dev_top_cfg.malform_credit_limit_np[vc] > 0)
                begin //{
                  l_dut_dev_top_cfg.malform_credit_limit_np[vc]--;
                end //}
                if(m_tlp_req_type == CDN_HPA_PCIE_TRANS_COMPLETION)
                if(l_dut_dev_top_cfg.malform_credit_limit_cpl[vc] > 0)
                begin //{
                  l_dut_dev_top_cfg.malform_credit_limit_cpl[vc]--;
                end //}
              end //}
            end //}
          end //}
        end //}
        else if (m_user_error_inject_obj.m_user_error_injects.size) begin //{
          // TODO: remove this when c_temp is not needed or it is soft
          // Module level TBs use user defined error injection
          // User needs to make sure that while trying to inject malform errors, dut credits are not exhausted
          vip_userdata.c_temp.constraint_mode(0);
          if(top_cfg_enable_errors)
          vip_userdata.has_err = 1;
          assert(vip_userdata.randomize() with {
            m_error_injects.size == m_user_error_inject_obj.m_user_error_injects.size;
            foreach(m_error_injects[i])
            m_error_injects[i] == m_user_error_inject_obj.m_user_error_injects[i];
          });
          m_user_error_inject_obj.copy_to_vip_userdata(vip_userdata);
        end //}
      end //}
    `endif

 else if (m_user_error_inject_obj.m_user_error_injects.size) begin //{
          // TODO: remove this when c_temp is not needed or it is soft
          // Module level TBs use user defined error injection
          // User needs to make sure that while trying to inject malform errors, dut credits are not exhausted
          vip_userdata.c_temp.constraint_mode(0);
          if(top_cfg_enable_errors)
          vip_userdata.has_err = 1;
          assert(vip_userdata.randomize() with {
            m_error_injects.size == m_user_error_inject_obj.m_user_error_injects.size;
            foreach(m_error_injects[i])
            m_error_injects[i] == m_user_error_inject_obj.m_user_error_injects[i];
          });
          m_user_error_inject_obj.copy_to_vip_userdata(vip_userdata);
        end //}
      end //}
    `endif

    //vip_userdata.hpa_pkt_num = m_pcie_dev_cfg.get_hpa_pkt_num();
    //if (enable_inject_errors==1) vip_userdata.has_err = 1;
    if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd0,CDN_HPA_PCIE_TLP_TYPE_CfgRd1,
    CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1}) vip_userdata.is_blocking_tr = is_blocking;
    if (m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgRd0,CDN_HPA_PCIE_TLP_TYPE_CfgRd1,
    CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1}) vip_userdata.unique_id = unique_id;

    if(inject_err_in_seq_item)
    inject_error(vip_userdata);

    foreach(vip_userdata.m_error_injects[i]) begin
      if(vip_userdata.m_error_injects[i]== CDN_HPA_PCIE_TLP_IDE_MAC_BIT_ZERO_GRT_EIGHT_TLPS_WHN_AGGR_SUPP) begin
        m_pcie_dev_top_cfg.ide_cfg.ide_mac_zero_grt_eight_tlps_whn_aggr_supp_err = 1;
        m_pcie_dev_top_cfg.ide_cfg.aggr_err_in_stream_id= m_stream_id;
        m_pcie_dev_top_cfg.ide_cfg.aggr_err_in_sub_stream=m_sub_stream;
        `uvm_info("DEBUG_ERR",$psprintf("DEBUG_ERR: Error injected=CDN_HPA_PCIE_TLP_IDE_MAC_BIT_ZERO_GRT_EIGHT_TLPS_WHN_AGGR_SUPP. For stream=%0h & sub_stream=%0h ",m_pcie_dev_top_cfg.ide_cfg.aggr_err_in_stream_id, m_pcie_dev_top_cfg.ide_cfg.aggr_err_in_sub_stream),UVM_DEBUG)

        m_pcie_dev_top_cfg.ide_cfg.num_tlps_with_err_inj_ide_mac_zero_whn_aggr_supp[m_stream_id][m_sub_stream]++;
        `uvm_info(get_name(),$psprintf("DEBUG_ERR: ide_mac_zero_grt_eight_tlps_whn_aggr_supp_err: num_tlps_with_err_inj_ide_mac_zero_whn_aggr_supp =%0d",m_pcie_dev_top_cfg.ide_cfg.num_tlps_with_err_inj_ide_mac_zero_whn_aggr_supp[m_stream_id][m_sub_stream]),UVM_LOW)
        if(m_pcie_dev_top_cfg.ide_cfg.num_tlps_with_err_inj_ide_mac_zero_whn_aggr_supp[m_stream_id][m_sub_stream] ==10) begin
          m_pcie_dev_top_cfg.ide_cfg.ide_mac_zero_grt_eight_tlps_whn_aggr_supp_err=0;
          m_pcie_dev_top_cfg.ide_cfg.num_tlps_with_err_inj_ide_mac_zero_whn_aggr_supp[m_stream_id][m_sub_stream]=0;
          `uvm_info(get_name(),$psprintf("DEBUG_ERR: ide_mac_zero_grt_eight_tlps_whn_aggr_supp_err: Reset var: num_tlps_with_err_inj_ide_mac_zero_whn_aggr_supp =%0d",m_pcie_dev_top_cfg.ide_cfg.num_tlps_with_err_inj_ide_mac_zero_whn_aggr_supp[m_stream_id][m_sub_stream]),UVM_LOW)
        end
      end
    end

    // TODO:: Tool issue: #46692903 - Causing OHC-A[7:0] to randomize to invalid values
    // Re-assigning first byte of m_ohc_a for valid TLP types
    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MSG_TYPE && m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CPL_TYPE)
      m_ohc_a[7:0] = {m_tlp_last_dw_be, m_tlp_first_dw_be};

    //Pack the seq_item to byte array
    void'(this.pack_bytes(m_data));
    `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_data=%s", convert_bytes_to_dw_string(m_data)), UVM_DEBUG)

    if(m_orphan_tlp_prefix && pack_prefix)
    begin
      m_data = new[m_max_no_of_prefixes * 4];
      get_prefixes(prfx_bytes);
      m_data = prfx_bytes;
    end

    `uvm_info(get_full_name(),$psprintf("m_tlp_td = %0x, m_td_wo_ecrc = %0x, m_no_td_ecrc = %0x, pack_ecrc = %0d", m_tlp_td, m_td_wo_ecrc, m_no_td_ecrc, pack_ecrc),UVM_DEBUG)
    //If pack_ecrc ==1 & TD==1, compute the ECRC and append to m_data
    //ECRC should be computed including E2E prefix bytes
    if(!m_pcie_dev_cfg.bypass_dut_type_chk && is_flit_mode  && (m_sub_stream == 'h7)) begin
      `uvm_info(get_type_name(),$psprintf("Modifying IDE TLP field to force Non-IDE TLP, force_non_ide_tlp = %0d",m_pcie_dev_top_cfg.ide_cfg.force_non_ide_tlp),UVM_DEBUG)

      //all other IDE fields in OHC-C are reserved
      m_stream_id = 0;
      m_ide_k     = 0;
      m_ide_t     = 0;
      m_pr_sent_counter = 0;
      recalc_ide_prefix();

      //no IDE MAC, replace trailer to have ECRC if enabled
      m_tlp_td = (m_pcie_dev_cfg.m_ecrc_gen_en  && m_pcie_dev_top_cfg.ecrc_init_done ) ? 1 : 0;
      m_ts     = m_tlp_td ? CDN_HPA_PCIE_1DW_ECRC_TRAILER : CDN_HPA_PCIE_NO_TRAILER;

      //repack modified fields in m_data
      void'(pack_bytes(m_data));
    end
    // td = 1 and ecrc to be included , td = 0 and ecrc to be included
    //    if((pack_ecrc && ((m_tlp_td && (!m_td_wo_ecrc)) || (!m_tlp_td && m_no_td_ecrc))) || test_crc) begin //{
    //For Flit mode: Local prefix should be avoided from lcrc computation. TD bit position setting also will change
    if(pack_ecrc && ((is_flit_mode && m_ts==CDN_HPA_PCIE_1DW_ECRC_TRAILER && !m_td_wo_ecrc) || ((m_tlp_td && (!m_td_wo_ecrc)) || (!m_tlp_td && m_no_td_ecrc)))) begin //{
      byte unsigned l_digest[4];
      if(errored_ecrc || m_pcie_dev_top_cfg.m_tl_to_pack_ecrc)
      assert(std::randomize(ecrc_val));
      else
      ecrc_val = get_ecrc();

      // For some of the error scenario need to recalculate ecrc
      // Error injection is happening in PL call back
      // if(m_pcie_dev_top_cfg.dll_flit_err_inj)
      if (m_pcie_dev_top_cfg.scenario != null) begin
        if(m_pcie_dev_top_cfg.scenario.m_is_dll_flit_err_test) begin
          ecrc_val = get_ecrc();
        end
      end
      ecrc_valid = 1;

      // Map the ECRC bits to TLP digest field as defined in Figure 2-46 from standard
      //map_crc_bytes(ecrc_val, l_digest);
       l_digest = {>> byte{ecrc_val} };

      if(pack_ecrc) begin
        m_data = {m_data, l_digest};
      end

      // Active BFM  ECRC  data that actually goes on the bus
      //ecrc_val = {>>{l_digest}};

      //Update the fields for tlp print purpose
      if (is_flit_mode) begin
        m_ts = CDN_HPA_PCIE_1DW_ECRC_TRAILER;
        m_ts_payload = new[4];
        foreach (m_ts_payload[item])
        m_ts_payload[3-item] = l_digest[item];
      end

      if (is_pbr_ecrc_calculated_for_pth_err) `uvm_info(get_full_name(), $psprintf("_PBR_ECRC_CALCULATED_FOR_PTH_ERR: Error is injected; pkt with the below ecrc (trailer) must be dropped "), UVM_DEBUG)
      `uvm_info(get_full_name(),
      $psprintf("Post randomize :: ecrc_val mapped = %0p m_data=%0p", l_digest, m_data),
      UVM_DEBUG)

      //`uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: After ECRC Inclusion m_data=%p,\n m_tlp_payload.size() = %0d,\n l_digest = %p", m_data, m_tlp_payload.size(), l_digest), UVM_DEBUG)
    end //}
    //if(vip_userdata)
    //begin
    //  foreach(vip_userdata.m_error_injects[i])
    //  `uvm_info(get_type_name(), $psprintf("DEBUG_ERR: enable_inject_errors = %0d, top_cfg_enable_errors = %0d, vip_userdata.m_error_injects[%0d]= %0d", enable_inject_errors, top_cfg_enable_errors, i, vip_userdata.m_error_injects[i]), UVM_DEBUG)
    //end

    if(tlp_sqr_handle)
    begin
      if(!is_blocking) //don't track blocking req using m_tlp_sent as m_tlp_sent is used to track normal traffic (EOT). blocking requests will be tracked via VIP Qs or sequence (sequence blocks till it receives completion)
      tlp_sqr_handle.m_tlp_sent = tlp_sqr_handle.m_tlp_sent + 1;
      //if(!(isIntxPkt() && m_pcie_dev_top_cfg.intx_pin_or_hls == 1))
      if(all_traffic_tlp)
      tlp_sqr_handle.m_tlp_sent_all = tlp_sqr_handle.m_tlp_sent_all + 1;
      //if(!all_traffic_tlp)
      //  tlp_sqr_handle.m_tlp_formed_all;// = tlp_sqr_handle.m_tlp_sent + 1;

      if(vip_userdata)
      vip_userdata.debug_tlp_num = tlp_sqr_handle.m_tlp_sent;
      `uvm_info(get_type_name(), $psprintf("DEBUG_ERR::TLP_NUM = %0d, tlp_sent=%0d/m_tlp_formed=%0d/m_tlp_sent_all=%0d,m_tlp_formed_all=%0d, vip_user_data.has_err = %0d, vip_userdata.m_error_injects = %0p, all_traffic_tlp = %0d, m_ide_p = %0d, m_ide_prefix_present = %0d, m_ide_tlp_prefix = %0h", vip_userdata.debug_tlp_num, tlp_sqr_handle.m_tlp_sent, tlp_sqr_handle.m_tlp_formed, tlp_sqr_handle.m_tlp_sent_all, tlp_sqr_handle.m_tlp_formed_all, vip_userdata.has_err, vip_userdata.m_error_injects, all_traffic_tlp, m_ide_p, m_ide_prefix_present, m_ide_tlp_prefix), UVM_DEBUG)

      if (vip_userdata && vip_userdata.has_err && (vip_userdata.m_error_injects[0] == CDN_HPA_PCIE_TLP_NO_ERR)) begin
        m_pcie_dev_top_cfg.inject_error_in_next_packet = 1;
      end
      
    end

    vip_userdata.print_vip_userdata();
  endfunction : err_inj_vip_userdata

  function void update_cfgtype_1_streamid();
    if(!m_pcie_dev_cfg.bypass_dut_type_chk) begin 
      if(m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_en) begin
        if((m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_CfgWr1, CDN_HPA_PCIE_TLP_TYPE_CfgRd1 }) && m_ide_prefix_present) begin
          m_stream_id =  m_pcie_dev_top_cfg.ide_cfg.cfg_req_as_type_1_stream_id;
          m_ide_p     = (((m_tlp_payload.size() != 0) & m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_pcrc_enable) ? 1 : 0);
          m_ts        = (((m_tlp_payload.size() != 0) & m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_pcrc_enable) ? CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER : CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER);
          recalc_ide_prefix();
          `uvm_info(get_type_name(), $psprintf("[DEBUG_IDE_INIT][DUT] stream_id updated to %0h",m_stream_id),UVM_DEBUG);
        end
      end
    end  
  endfunction : update_cfgtype_1_streamid

  function void update_ecrc_value(bit not_send_ecrc=0);
    byte unsigned l_digest[4];
    if(has_ecrc()) begin
      if(errored_ecrc || not_send_ecrc)
      assert(std::randomize(ecrc_val));
      else
      ecrc_val = get_ecrc();
      ecrc_valid = 1;

      // Map the ECRC bits to TLP digest field as defined in Figure 2-46 from standard
      //map_crc_bytes(ecrc_val, l_digest);
      l_digest = {>>byte{ecrc_val}};
      m_data = {m_data, l_digest};

      // Easier to debug data that actually goes on the bus
      //ecrc_val = {>>{l_digest}};
      if (is_flit_mode) begin
        m_ts_payload = new[4];
        foreach (m_ts_payload[item])
        m_ts_payload[3-item] = l_digest[item];
      end
    end
  endfunction : update_ecrc_value

  //----------------------------------------------------------------------------
  // Function : config_error_control
  // This function will decide when to enable error inside this TLP
  //----------------------------------------------------------------------------
  function bit config_error_control();
    bit error_control;
    int l_pos_tlp_b2b_err_inj = 'b0;
    int l_num_tlp_b2b_err_inj = 'b0;
    error_control = 0;

    if(!disable_inject_errors)
    begin

      if(tlp_sqr_handle == null)
      return error_control;

      //sparse error
      //excluded first tlp from error
      if (m_pcie_dev_top_cfg.scenario != null) begin
        if(m_pcie_dev_top_cfg.flit_mode_negotiated && (m_pcie_dev_top_cfg.scenario.m_is_dll_flit_err_test)) begin //TODO Need to convert this logic into flit based
         `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: m_pcie_dev_top_cfg.flit_err_count =%h m_pcie_dev_top_cfg.local_flit_err_count = %h enable_inject_error = %h, top_cfg_enable_errors = %h, m_pcie_dev_top_cfg.num_errors  %h  m_pcie_dev_top_cfg.m_num_allowed_errors  = %h  ", m_pcie_dev_top_cfg.flit_err_count,m_pcie_dev_top_cfg.local_flit_err_count,enable_inject_errors, top_cfg_enable_errors,m_pcie_dev_top_cfg.num_errors, m_pcie_dev_top_cfg.m_num_allowed_errors ), UVM_DEBUG)
          if((m_pcie_dev_top_cfg.flit_err_count > m_pcie_dev_top_cfg.local_flit_err_count) && (enable_inject_errors || (top_cfg_enable_errors && ((m_pcie_dev_top_cfg.num_errors < m_pcie_dev_top_cfg.m_num_allowed_errors) || (m_pcie_dev_top_cfg.m_num_allowed_errors == 0)))) && ((tlp_sqr_handle.m_tlp_sent)%(m_pcie_dev_top_cfg.freq_err) == 'b0) && tlp_sqr_handle.m_tlp_sent) begin
            error_control = 'b1;
            m_pcie_dev_top_cfg.local_flit_err_count = m_pcie_dev_top_cfg.local_flit_err_count + 1;
          end
        end
        else begin
          if((enable_inject_errors || (top_cfg_enable_errors && ((m_pcie_dev_top_cfg.num_errors < m_pcie_dev_top_cfg.m_num_allowed_errors) || (m_pcie_dev_top_cfg.m_num_allowed_errors == 0)))) &&
          (((tlp_sqr_handle.m_tlp_sent)%(m_pcie_dev_top_cfg.freq_err) == 'b0) || m_pcie_dev_top_cfg.inject_error_in_next_packet) && tlp_sqr_handle.m_tlp_sent) begin
            error_control = 'b1;
            m_pcie_dev_top_cfg.inject_error_in_next_packet = 0;
          end
        end
      end
      else begin
        if((enable_inject_errors || (top_cfg_enable_errors && ((m_pcie_dev_top_cfg.num_errors < m_pcie_dev_top_cfg.m_num_allowed_errors) || (m_pcie_dev_top_cfg.m_num_allowed_errors == 0)))) && ((tlp_sqr_handle.m_tlp_sent)%(m_pcie_dev_top_cfg.freq_err) == 'b0) && tlp_sqr_handle.m_tlp_sent)
        error_control = 'b1;
      end
      //tlp_sqr_handle.b2b_err_inj
      if(tlp_sqr_handle.b2b_err_inj && (tlp_sqr_handle.m_tlp_sent == 0))
      begin
        if(tlp_sqr_handle.pos_tlp_b2b_err_inj == 'b0)
        assert(std::randomize(l_pos_tlp_b2b_err_inj) with {l_pos_tlp_b2b_err_inj < tlp_sqr_handle.num_tlps;});
        else
        l_pos_tlp_b2b_err_inj = tlp_sqr_handle.pos_tlp_b2b_err_inj;

        if(tlp_sqr_handle.num_tlp_b2b_err_inj == 'b0)
        assert(std::randomize(l_num_tlp_b2b_err_inj) with {l_num_tlp_b2b_err_inj < tlp_sqr_handle.num_tlps;});
        else
        l_num_tlp_b2b_err_inj = tlp_sqr_handle.num_tlp_b2b_err_inj;

        tlp_sqr_handle.pos_tlp_b2b_err_inj = l_pos_tlp_b2b_err_inj;
        tlp_sqr_handle.num_tlp_b2b_err_inj = l_num_tlp_b2b_err_inj;
      end

      if(tlp_sqr_handle.b2b_err_inj && enable_inject_errors && (tlp_sqr_handle.m_tlp_sent inside {tlp_sqr_handle.pos_tlp_b2b_err_inj, tlp_sqr_handle.pos_tlp_b2b_err_inj + tlp_sqr_handle.num_tlp_b2b_err_inj}))
      error_control = 'b1;

      if((m_scenario_error_inject inside {CDN_HPA_PCIE_TLP_TO_NON_D0_FUNC_UR_ERR,CDN_HPA_PCIE_CPL_TO_NON_D0_FUNC_UC_ERR}))
      error_control = 'b1;
      if((m_scenario_error_inject inside {CDN_HPA_PCIE_TLP_CPL_POISON_ERR,CDN_HPA_PCIE_TLP_POISONED_ERR,CDN_HPA_PCIE_TLP_ECRC_ERR,CDN_HPA_PCIE_TLP_CPL_ECRC_ERR,CDN_HPA_PCIE_TLP_CFG_UNSUPP_FUNC_UR_ERR}) &&
      m_pcie_dev_top_cfg.m_ptc_test_err_scen==1)
      error_control = 'b1;

      `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM:config_error_control \n TLP no =%0d,\n enable_inject_errors = %0d,\n top_cfg_enable_errors = %0d,\n m_pcie_dev_top_cfg.freq_err = %0d,\n tlp_sqr_handle.b2b_err_inj = %0d,\n tlp_sqr_handle.pos_tlp_b2b_err_inj = %0d,\n, tlp_sqr_handle.num_tlp_b2b_err_inj = %0d,\n tlp_sqr_handle.num_tlps = %0d,\n m_pcie_dev_top_cfg.tc_vc_mapping_done =%0d,\n m_pcie_dev_top_cfg.dllp_err_inj=%0d,\n m_pcie_dev_top_cfg.dll_flit_err_inj =%0d,\n m_pcie_dev_top_cfg.tlp_err_inj=%0d, m_pcie_dev_top_cfg.poisoned_err_inj = %0d, \n m_pcie_dev_top_cfg.ecrc_err_inj = %0d, \n m_pcie_dev_top_cfg.mf_err_inj = %0d, \n m_pcie_dev_top_cfg.ur_err_inj = %0d,\n m_pcie_dev_top_cfg.cpl_err_inj = %0d,\n m_pcie_dev_top_cfg.plp_err_inj = %0d, m_pcie_dev_top_cfg.ide_err_inj = %0d, \n error_control = %0d,\n m_pcie_dev_top_cfg.num_errors = %0d,\n m_pcie_dev_top_cfg.m_num_allowed_errors = %0d, \n m_scenario_error_inject = %0s \n  m_ptc_test_err_scen=%0d", tlp_sqr_handle.m_tlp_sent, enable_inject_errors, top_cfg_enable_errors, m_pcie_dev_top_cfg.freq_err, tlp_sqr_handle.b2b_err_inj, tlp_sqr_handle.pos_tlp_b2b_err_inj, tlp_sqr_handle.num_tlp_b2b_err_inj, tlp_sqr_handle.num_tlps,m_pcie_dev_top_cfg.tc_vc_mapping_done,m_pcie_dev_top_cfg.dllp_err_inj, m_pcie_dev_top_cfg.dll_flit_err_inj, m_pcie_dev_top_cfg.tlp_err_inj,  m_pcie_dev_top_cfg.poisoned_err_inj, m_pcie_dev_top_cfg.ecrc_err_inj, m_pcie_dev_top_cfg.mf_err_inj, m_pcie_dev_top_cfg.ur_err_inj, m_pcie_dev_top_cfg.cpl_err_inj, m_pcie_dev_top_cfg.plp_err_inj, m_pcie_dev_top_cfg.ide_err_inj, error_control, m_pcie_dev_top_cfg.num_errors, m_pcie_dev_top_cfg.m_num_allowed_errors, m_scenario_error_inject.name(),m_pcie_dev_top_cfg.m_ptc_test_err_scen), UVM_DEBUG)

    end
    else
    begin
      `uvm_info(get_type_name(), $psprintf("DEBUG_SEQ_ITEM: Error injection of this TLP is disabled from parent sequence. disable_inject_errors = %0d", disable_inject_errors), UVM_DEBUG)
      error_control = 'b0;
    end
    if(m_pcie_dev_top_cfg.ide_cfg.ide_mac_zero_grt_eight_tlps_whn_aggr_supp_err) error_control=0; //If MAC_BIT_ZERO in eight consecutive tlps of same stream/sub_stream in progress, don't inject another error
    return error_control;
  endfunction : config_error_control


  //----------------------------------------------------------------------------
  // Function : get_header_size
  // This function will look at the format and return the header size in bytes
  //----------------------------------------------------------------------------
  virtual function int get_header_size();
    case (m_hdr_fmt)
      CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_NO_DATA,
      CDN_HPA_PCIE_TLP_FMT_3DW_HEADER_WITH_DATA : get_header_size = 12;
      CDN_HPA_PCIE_TLP_FMT_4DW_HEADER_WITH_DATA,
      CDN_HPA_PCIE_TLP_FMT_4DW_HEADER_NO_DATA   : get_header_size = 16;
      default   : get_header_size = 16;
    endcase
  endfunction : get_header_size

  //----------------------------------------------------------------------------
  // Function : get_ohc_wd_size
  // This function will look at the OHC and return the size in DW
  //----------------------------------------------------------------------------
  virtual function int get_ohc_dw_size();
    if (m_ohc_hdr) begin
      if(m_ohc_hdr.ohc_a_present) begin
        get_ohc_dw_size += 1;
      end
      if(m_ohc_hdr.ohc_b_present) begin
        get_ohc_dw_size += 1;
      end
      if(m_ohc_hdr.ohc_c_present) begin
        get_ohc_dw_size += 1;
      end
      if(m_ohc_hdr.ohc_ex_present==ohc_e1_present) begin
        get_ohc_dw_size += 1;
      end
      if(m_ohc_hdr.ohc_ex_present==ohc_e2_present) begin
        get_ohc_dw_size += 2;
      end
      if(m_ohc_hdr.ohc_ex_present==ohc_e4_present) begin
        get_ohc_dw_size += 4;
      end
    end
  endfunction : get_ohc_dw_size


  //---------------------------------------------------------
  // Function : get_trailer_dw_size
  // This function will look at the trailer and return the size in DW
  //-------------------------------------------------------------
  virtual function int get_trailer_dw_size();
    int trailer_size_decoded;
    trailer_size_decoded = (( m_ts ==CDN_HPA_PCIE_1DW_ECRC_TRAILER )  ? 1 :
    ( m_ts ==CDN_HPA_PCIE_1DW_RSVD_TRAILER )  ? 1 :
    ( m_ts ==CDN_HPA_PCIE_2DW_RSVD_TRAILER )  ? 2 :
    ( m_ts ==CDN_HPA_PCIE_2DW_RSVD1_TRAILER)  ? 2 :
    ( m_ts ==CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER) ? 3 :
    ( m_ts ==CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER) ? 4 :
    ( m_ts ==CDN_HPA_PCIE_5DW_RSVD_TRAILER) ? 5 : 0);
    return trailer_size_decoded;
  endfunction : get_trailer_dw_size

  //----------------------------------------------------------------------------
  // Function : recalc_ide_prefix
  // This function will re-assemble IDE prefix with current values of the fields
  //----------------------------------------------------------------------------
  virtual function void recalc_ide_prefix();
    m_ide_tlp_prefix = {m_ide_hdr_fmt_prefix, m_ide_hdr_type_prefix, m_pr_sent_counter, m_stream_id, m_sub_stream, m_ide_p, m_ide_m, m_ide_k, m_ide_t};
    m_ohc_c = {m_requester_segment, m_pr_sent_counter, m_stream_id, m_sub_stream, m_requester_segment_valid, m_ohc_c_byte_3_field_2_rsvd, m_ide_k, m_ide_t};
  endfunction : recalc_ide_prefix

  //----------------------------------------------------------------------------
  // Function : get_ide_aad_size
  // This function will look at the IDE AAD and return the size in bytes
  //----------------------------------------------------------------------------
  virtual function int get_ide_aad_size(bit[3:0] partial_header_enc_mode = 0);
    get_ide_aad_size = (is_flit_mode) ? (get_header_size() + (get_ohc_dw_size()*4)) : (get_header_size() + (m_max_no_of_prefixes*4));
    if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (partial_header_enc_mode > 0)) begin
      get_ide_aad_size -= ((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_64) ? (partial_header_enc_mode + 1) : ((partial_header_enc_mode > 2) ? 3 : (partial_header_enc_mode + 1)));
      get_ide_aad_size -= partial_hdr_enc_with_be();
    end
  endfunction : get_ide_aad_size

  //----------------------------------------------------------------------------
  // Function : get_ide_pld_size
  // This function will look at the IDE PLD and return the size in bytes
  //----------------------------------------------------------------------------
  virtual function int get_ide_pld_size(bit[3:0] partial_header_enc_mode = 0);
    get_ide_pld_size = m_tlp_payload.size() + (has_pcrc()*4);
    if((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) && (partial_header_enc_mode > 0)) begin
      get_ide_pld_size += ((m_tlp_addr_type == CDN_HPA_PCIE_ADDR_64) ? (partial_header_enc_mode + 1) : ((partial_header_enc_mode > 2) ? 3 : (partial_header_enc_mode + 1)));
      get_ide_pld_size += partial_hdr_enc_with_be();
    end
  endfunction : get_ide_pld_size

  //----------------------------------------------------------------------------
  // Function : has_ecrc
  // This function returns true if ECRC bit is set in the TLP
  //----------------------------------------------------------------------------
  virtual function bit has_ecrc();
    has_ecrc = (is_flit_mode ? (m_ts == CDN_HPA_PCIE_1DW_ECRC_TRAILER) : (m_tlp_td == 1));
  endfunction : has_ecrc

  //----------------------------------------------------------------------------
  // Function : has_pcrc
  // This function returns true if PCRC bit is set in the TLP
  //----------------------------------------------------------------------------
  virtual function bit has_pcrc();
    has_pcrc = (has_mac()) ? ((is_flit_mode) ? (m_ts == CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER) : (m_ide_p == 1)) : 0;
  endfunction : has_pcrc

  //----------------------------------------------------------------------------
  // Function : has_mac
  // This function returns true if MAC bit is set in the TLP
  //----------------------------------------------------------------------------
  virtual function bit has_mac();
    has_mac = (is_flit_mode) ? (m_ts == CDN_HPA_PCIE_3DW_WITH_IDE_MAC_OR_RSVD_TRAILER || m_ts == CDN_HPA_PCIE_4DW_WITH_IDE_MAC_PCRC_OR_RSVD_TRAILER) : (m_ide_m == 1);
  endfunction : has_mac

  //----------------------------------------------------------------------------
  // Function : get_ide_pcrc
  // This function will extract PCRC for NFM/FM TLP
  //----------------------------------------------------------------------------
  virtual function bit[31:0] get_ide_pcrc();
    if(!is_flit_mode) get_ide_pcrc = m_ide_pcrc;
    else /*--------*/ get_ide_pcrc =  { >> byte {m_ts_payload[0:3]}};
  endfunction : get_ide_pcrc

  //----------------------------------------------------------------------------
  // Function : get_ide_mac
  // This function will extract MAC for NFM/FM TLP
  //----------------------------------------------------------------------------
  virtual function bit[95:0] get_ide_mac();
    if(!is_flit_mode) get_ide_mac = { << byte {m_ide_mac}};
    else begin
      if(has_pcrc) get_ide_mac = { >> byte {m_ts_payload[4:15]}};
      else /*---*/ get_ide_mac = { >> byte {m_ts_payload[0:11]}};
    end
  endfunction : get_ide_mac

  //----------------------------------------------------------------------------
  // Function : partial_hdr_enc_with_be
  // This function will return true if TLP can have partial header encryption
  //----------------------------------------------------------------------------
  virtual function bit partial_hdr_enc_with_be();
    if(m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MEM_TYPE) begin
      if(is_flit_mode && m_ohc_hdr.ohc_a_present) partial_hdr_enc_with_be = 1;
      if(!is_flit_mode && (m_tlp_at_type != CDN_HPA_PCIE_AT_Translation_Request)) begin
        if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64}                 ) partial_hdr_enc_with_be = 1;
        if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRd_32,CDN_HPA_PCIE_TLP_TYPE_MRd_64}     && !m_tlp_th) partial_hdr_enc_with_be = 1;
        if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_MRdLk_32,CDN_HPA_PCIE_TLP_TYPE_MRdLk_64} && !m_tlp_th) partial_hdr_enc_with_be = 1;
        if(m_tlp_type inside {CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64}   && !m_tlp_th) partial_hdr_enc_with_be = 1;
      end
    end
  endfunction : partial_hdr_enc_with_be

  //----------------------------------------------------------------------------
  // Function : set_ide_invalid_substream_err
  // This function will inject CDN_HPA_PCIE_TLP_IDE_INVALID_SUBSTREAM_ERR in the TLP
  //----------------------------------------------------------------------------
  virtual function void set_ide_invalid_substream_err();
    bit[3:0] l_sub_stream = m_sub_stream;

    if(!m_ide_prefix_present) begin
      error_inject_success = 0;
     `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] cannot inject CDN_HPA_PCIE_TLP_IDE_INVALID_SUBSTREAM_ERR"),UVM_DEBUG);
      return;
    end

    if( is_flit_mode) assert(std::randomize(m_sub_stream) with {!(m_sub_stream inside {0,1,2,7});});
    if(!is_flit_mode) assert(std::randomize(m_sub_stream) with {!(m_sub_stream inside {0,1,2});});
    recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));

    ide_invalid_substream = 1;
    error_inject_success = 1;
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] CDN_HPA_PCIE_TLP_IDE_INVALID_SUBSTREAM_ERR injected"),UVM_DEBUG);
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] Original sub_stream = %0d, Corrupted sub_stream = %0d",l_sub_stream,m_sub_stream),UVM_DEBUG);
  endfunction : set_ide_invalid_substream_err

  //----------------------------------------------------------------------------
  // Function : set_ide_fail_err
  // This function will inject CDN_HPA_PCIE_TLP_IDE_FAIL_ERR in the TLP
  //----------------------------------------------------------------------------
  virtual function void set_ide_fail_err(int fail_type = 0);
    bit[7:0] stream_id;
    //For IB detected IDE Check Failed errors, an IDE Fail message needs to be sent for the affected stream. Handshake with TL to obtain credits and trigger injection of IDE Fail message. It is OK to stall pipeline to handle this.
    //Spec suggested supporting both non IDE and IDE Fail message TLPs, generation priority as following:
    //     -  For Link Stream Fail, a non IDE Fail will be issued.
    //     -  For Selective Stream Fail, IDE Fail is preferred whenever there are another Link Streams configured in same TC enabled and currently in Secure State, otherwise a non IDE Fail will be issued as default.
    //
    // FMT - TYPE - MSG
    // TC  - hpa_tlp.m_tlp_tc
    // TH= 0
    // TD= 0
    // EP= 0
    // AT= 00
    // Length = 0
    // Requester ID = function 0 ->
    //    The Requester ID must be set to the RID of the Function implementing IDE at the Transmitting Port.
    // Message Code - CDN_HPA_PCIE_TLP_MSG_IDE_Fail
    //
    // stream ID - hpa_tlp.m_stream_id
    // Destination ID -
    //         hpa_tlp.m_pcie_dev_top_cfg.ide_cfg.find_stream_type(hpa_tlp.m_stream_id) == LINK_STREAM, SELECTIVE_STREAM
    //
    //    if(SELECTIVE_STREAM)
    //        Destination ==  hpa_tlp.m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_RID_base
    //    IDE Sync and IDE Fail Messages associated with a Selective IDE Stream must use Route by ID (010b),
    //  and the Destination ID must contain the value in the RID Base field of the Selective IDE RID Association
    //  Register Block
    //
    //
    //         if( hpa_tlp.m_pcie_dev_top_cfg.ide_cfg.find_stream_type(hpa_tlp.m_stream_id) == LINK_STREAM)
    //           //no prefix required
    //
    //         if(( hpa_tlp.m_pcie_dev_top_cfg.ide_cfg.find_stream_type(hpa_tlp.m_stream_id) == SELECTIVE_STREAM) && hpa_tlp.m_pcie_dev_top_cfg.ide_cfg.link_ide_str_enable[hpa_tlp.m_tlp_tc])
    //           //link stream prefix
    //           prefix = 92 00  hpa_tlp.m_pcie_dev_top_cfg.ide_cfg.link_stream_id_tc_map[hpa_tlp.m_tlp_tc]  substream = 0,p=0, m=1, k=0, t=0
    //
    //     push this TLP into a scoreboard
    //           m_ide_fail_tlp_scoreboard.write_expected_tr(ide_fail_msg);

    //modify a generated MSG TLP into an IDE Fail MSG
   
    error_inject_success = 0;
    if(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Msg && m_ide_prefix_present) begin
      //Remove all Prefixes
      this.m_tlp_prefix.delete();
      this.m_hdr_fmt_prefix.delete();
      this.m_hdr_type_prefix.delete();
      this.m_ide_prefix_present = 0;
      this.m_pasid_prefix_present = 0;
      this.m_ext_tph_prefix_present = 0;
      this.m_ohc_hdr.ohc_a_present = 0;
      this.m_ohc_hdr.ohc_b_present = 0;
      this.m_ohc_hdr.ohc_c_present = 0;
      this.m_ohc_hdr.ohc_ex_present = no_ohc_ex_present;
      this.m_ide_p = 0;
      this.m_ide_m = 0;
      this.m_ide_k = 0;
      this.m_ide_t = 0;
      recalc_ide_prefix();

      if(fail_type == 0) begin
        assert(std::randomize(stream_id) with {(stream_id inside {m_pcie_dev_top_cfg.ide_cfg.stream_id}) && (m_pcie_dev_top_cfg.ide_cfg.is_stream_enabled(stream_id) == 1);});
        assert(std::randomize(m_tlp_tc) with {m_tlp_tc == m_pcie_dev_top_cfg.ide_cfg.find_tc_mapped_to_stream_id(stream_id);});
      end

      if(fail_type == 1) begin
        assert(std::randomize(stream_id) with {(stream_id inside {m_pcie_dev_top_cfg.ide_cfg.stream_id}) && (m_pcie_dev_top_cfg.ide_cfg.is_stream_enabled(stream_id) == 1);});
        assert(std::randomize(m_tlp_tc) with {m_tlp_tc == m_pcie_dev_top_cfg.ide_cfg.find_tc_mapped_to_stream_id(stream_id);});
      end

      if(fail_type == 2) begin
        assert(std::randomize(stream_id) with {!(stream_id inside {m_pcie_dev_top_cfg.ide_cfg.stream_id});});
      end

      if(fail_type == 3) begin
        assert(std::randomize(stream_id) with {(stream_id inside {m_pcie_dev_top_cfg.ide_cfg.stream_id}) && (m_pcie_dev_top_cfg.ide_cfg.is_stream_enabled(stream_id) == 1);});
        assert(std::randomize(m_tlp_tc) with {m_tlp_tc != m_pcie_dev_top_cfg.ide_cfg.find_tc_mapped_to_stream_id(stream_id);});
      end

      if(fail_type == 4) begin
        assert(std::randomize(stream_id) with {(stream_id inside {m_pcie_dev_top_cfg.ide_cfg.stream_id}) && (m_pcie_dev_top_cfg.ide_cfg.is_stream_enabled(stream_id) == 0);});
        assert(std::randomize(m_tlp_tc) with {m_tlp_tc != m_pcie_dev_top_cfg.ide_cfg.find_tc_mapped_to_stream_id(stream_id);});
      end

      if(m_pcie_dev_top_cfg.ide_cfg.find_stream_type(stream_id) == SELECTIVE_STREAM) this.m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID;
      if(m_pcie_dev_top_cfg.ide_cfg.find_stream_type(stream_id) == LINK_STREAM)      this.m_tlp_msg_rout_type = CDN_HPA_PCIE_TLP_MSG_ROUT_LOCAL_TERMINATE;

      //HDR_DW0
      this.m_hdr_type[2:0] = this.m_tlp_msg_rout_type;
      this.m_tlp_th = 0;
      this.m_tlp_td = m_pcie_dev_top_cfg.pf_config[0].m_ecrc_gen_en;
      this.m_tlp_ep = 0;
      this.m_tlp_attr1 = 0;
      this.m_tlp_attr0 = 0;

      //HDR_DW1
      if(m_pcie_dev_cfg.m_port_type == CDN_HPA_PCIE_USP) begin
        this.m_tlp_requester_id.bus_num      = m_pcie_link_cfg.usp_dev_top_config.pf_config[0].m_req_id.bus_num     ;
        this.m_tlp_requester_id.device_num   = m_pcie_link_cfg.usp_dev_top_config.pf_config[0].m_req_id.device_num  ;
        this.m_tlp_requester_id.function_num = m_pcie_link_cfg.usp_dev_top_config.pf_config[0].m_req_id.function_num;
      end
      else begin
        this.m_tlp_requester_id.bus_num      = m_pcie_link_cfg.dsp_dev_top_config.pf_config[0].m_req_id.bus_num     ;
        this.m_tlp_requester_id.device_num   = m_pcie_link_cfg.dsp_dev_top_config.pf_config[0].m_req_id.device_num  ;
        this.m_tlp_requester_id.function_num = m_pcie_link_cfg.dsp_dev_top_config.pf_config[0].m_req_id.function_num;
      end

      this.m_tlp_msg_code = CDN_HPA_PCIE_TLP_MSG_IDE_Fail;

      //HDR_DW2
      if(this.m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID) begin
        this.m_tlp_completer_id.bus_num      = m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[stream_id].m_RID_base[15:8];
        this.m_tlp_completer_id.device_num   = m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[stream_id].m_RID_base[7:3];
        this.m_tlp_completer_id.function_num = m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[stream_id].m_RID_base[2:0];
      end

      this.msg_ide_fail_stream_id = stream_id;

      //re-pack m_data
      void'(this.pack_bytes(this.m_data));

      //re-calc ECRC
      update_ecrc_value();
      if(fail_type == 1) this.ecrc_val = 32'h0a0a0a0a;
  
      void'(this.pack_bytes(this.m_data));
      error_inject_success = 1;
     `uvm_info(get_type_name(),$psprintf("Modified IDE FAIL MSG TLP: \n %s ", this.sprint()),UVM_DEBUG);
    end
    else begin 
     `uvm_info(get_type_name(),$psprintf("No IDE FAIL MSG TLP INJECTED"),UVM_DEBUG);
    end

  endfunction : set_ide_fail_err

  //----------------------------------------------------------------------------
  // Function :set_wrong_mac_zero_whn_aggr_not_supp_err
  // This function will inject MAC error in the TLP
  //----------------------------------------------------------------------------
  virtual function void set_wrong_mac_zero_whn_aggr_not_supp_err();
    if(!m_ide_prefix_present) begin
      error_inject_success = 0;
     `uvm_info(get_full_name(),$psprintf("MAC bit zero error NOT injected for Non-IDE TLP"),UVM_LOW)
      return;
    end

    if(!is_flit_mode) m_ide_m = 0;
    if(!is_flit_mode) m_ide_p = 0;
    if( is_flit_mode) m_ts = CDN_HPA_PCIE_NO_TRAILER;
    recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));
    ide_mac_zero_whn_aggr_not_supp_err = 1;
   `uvm_info(get_full_name(),$psprintf("set_wrong_mac_zero_whn_aggr_not_supp_err: Error injected is for MAC bit"),UVM_LOW)
  endfunction : set_wrong_mac_zero_whn_aggr_not_supp_err

  //----------------------------------------------------------------------------
  // Function : set_wrong_mac_zero_grt_eight_tlps_whn_aggr_supp_err
  // This function will inject MAC error in the TLP
  //----------------------------------------------------------------------------
  virtual function void set_wrong_mac_zero_grt_eight_tlps_whn_aggr_supp_err();
    if(!m_ide_prefix_present) begin
      error_inject_success = 0;
     `uvm_info(get_full_name(),$psprintf("MAC bit zero error NOT injected for Non-IDE TLP"),UVM_LOW)
      return;
    end

    if(!is_flit_mode) m_ide_m = 0;
    if(!is_flit_mode) m_ide_p = 0;
    if( is_flit_mode) m_ts = CDN_HPA_PCIE_NO_TRAILER;
    recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));
    ide_mac_zero_whn_aggr_supp_err = 1;
   `uvm_info(get_full_name(),$psprintf("set_wrong_mac_zero_grt_eight_tlps_whn_aggr_supp_err: Error injected is for MAC bit"),UVM_LOW)
  endfunction : set_wrong_mac_zero_grt_eight_tlps_whn_aggr_supp_err

  //----------------------------------------------------------------------------
  // Function : set_wrong_mac_err
  // This function will inject MAC error in the TLP
  //----------------------------------------------------------------------------
  virtual function void set_wrong_mac_err();
    if(has_mac()) begin
      for(int i=0; i<12; i++) begin
        t_ide_mac[i] = m_ide_mac[i];
        m_ide_mac[i] = 'hFF;
      end
      for(int i=has_pcrc(); i<(has_pcrc()+3); i++) begin
       m_ts_payload[i] = 32'hFFFFFFFF;
      end
      ide_mac_err = 1;
     `uvm_info(get_full_name(),$psprintf("actual  MAC=%p",t_ide_mac),UVM_LOW)
     `uvm_info(get_full_name(),$psprintf("Error injected is for  MAC=%p",m_ide_mac),UVM_LOW)
    end
    else begin
      error_inject_success = 0;
     `uvm_info(get_full_name(),$psprintf("Wrong MAC error NOT injected for Non-IDE TLP"),UVM_LOW)
    end
  endfunction : set_wrong_mac_err

  //----------------------------------------------------------------------------
  // Function : set_wrong_misrouted_ide_tlp_err
  // This function will inject MISROUTED_IDE_TLP error in the TLP
  //----------------------------------------------------------------------------
  virtual function void set_wrong_misrouted_ide_tlp_err();
    bit [7:0] h_stream_id = m_stream_id;

    if(!m_ide_prefix_present) begin
      error_inject_success = 0;
     `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] cannot inject CDN_HPA_PCIE_TLP_IDE_WRONG_MISROUTED_IDE_TLP_ERR"),UVM_DEBUG);
      return;
    end

    assert(std::randomize(m_stream_id) with { !(m_stream_id inside {this.m_pcie_dev_top_cfg.ide_cfg.stream_id}); });
    this.m_pr_sent_counter = 0;
    recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));

    misrouted_ide_tlp_err = 1;
    error_inject_success = 1;
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] CDN_HPA_PCIE_TLP_IDE_WRONG_MISROUTED_IDE_TLP_ERR injected"),UVM_DEBUG);
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] Original stream_id = %0h, Corrupted stream_id = %0h",h_stream_id,m_stream_id),UVM_DEBUG);
  endfunction : set_wrong_misrouted_ide_tlp_err

  //----------------------------------------------------------------------------
  // Function : set_wrong_pcrc_err
  // This function will inject PCRC error in the TLP
  //----------------------------------------------------------------------------
  virtual function void set_wrong_pcrc_err();
    if(has_pcrc()) begin
      t_ide_pcrc = m_ide_pcrc;
      assert(std::randomize(m_ide_pcrc) with {m_ide_pcrc != t_ide_pcrc;});
      for(int i= 0; i <4; i ++) begin  
        m_ts_payload[3-i] = m_ide_pcrc[(i*8)+:8];
      end
      pcrc_err = 1;
     `uvm_info(get_full_name(),$psprintf("Error injected is PCRC =%h", m_ide_pcrc),UVM_LOW)
     `uvm_info(get_full_name(),$psprintf("actual PCRC =%h", t_ide_pcrc),UVM_LOW)
    end
    else begin
      error_inject_success = 0;
     `uvm_info(get_full_name(),$psprintf("error NOT injected for P bit not set in TLP"),UVM_LOW)
    end
  endfunction : set_wrong_pcrc_err

  //----------------------------------------------------------------------------
  // Function : set_wrong_pr_sent_counter_err
  // This function will inject PR SENT COUNTER error in the TLP
  //----------------------------------------------------------------------------
  virtual function void set_wrong_pr_sent_counter_err();
    bit [7:0] t_ide_pr_sent_counter = m_pr_sent_counter;

    if(!m_ide_prefix_present || (m_tlp_req_type == CDN_HPA_PCIE_TRANS_POSTED_REQ)) begin
      error_inject_success = 0;
     `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] cannot inject CDN_HPA_PCIE_TLP_IDE_WRONG_PR_SENT_COUNTER_ERR"),UVM_DEBUG);
      return;
    end
  
    assert(std::randomize(m_pr_sent_counter) with { m_pr_sent_counter != t_ide_pr_sent_counter; });
    recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));

    ide_pr_sent_counter_err=1;
    vip_userdata.m_pr_sent_counter = t_ide_pr_sent_counter;
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] CDN_HPA_PCIE_TLP_IDE_WRONG_PR_SENT_COUNTER_ERR injected"),UVM_DEBUG);
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] Original pr_sent_cntr = %0d, Corrupted pr_sent_cntr = %0d",t_ide_pr_sent_counter,m_pr_sent_counter),UVM_DEBUG);
  endfunction :set_wrong_pr_sent_counter_err

  //----------------------------------------------------------------------------
  // Function : inject_ecrc_err
  // This function will inject ECRC error in the TLP
  //----------------------------------------------------------------------------
  virtual function void inject_ecrc_err();

    for (int loop_byte = 0; loop_byte < 4; loop_byte++) begin
      // Random selection of various interesting scenarion of this error type
      randcase
        1 : m_data[m_data.size()-1-loop_byte] = 0;
        8 : m_data[m_data.size()-1-loop_byte] = $urandom_range(0, 'hFF);
        1 : m_data[m_data.size()-1-loop_byte] = 'hFF;
      endcase
    end
  endfunction : inject_ecrc_err

  //----------------------------------------------------------------------------
  // Function : has_ecrc_err
  // This function will detect ECRC error in the TLP
  //----------------------------------------------------------------------------
  virtual function bit has_ecrc_err(bit local_prefix_include = 0);
    bit [31:0]       exp_ecrc;
    bit [31:0]       obs_ecrc;

    if(has_ecrc()) begin
      //- get expected ECRC ------------------------------------------------
      exp_ecrc = get_ecrc(local_prefix_include);

      //- Fetch observed ECRC --------------------------------------------------
      if(!is_flit_mode) obs_ecrc = this.ecrc_val;
      else /*--------*/ obs_ecrc = {>>{this.m_ts_payload}};

      //- Set error if match fail ----------------------------------------------
   `  uvm_info(get_full_name(), $sformatf("Observed ECRC = %0h, Expected ECRC = %0h",obs_ecrc,exp_ecrc),UVM_DEBUG);
      has_ecrc_err = (obs_ecrc != exp_ecrc);
    end
  endfunction : has_ecrc_err


  //----------------------------------------------------------------------------
  // Function : get_ecrc
  // This function will calculate and return ECRC
  //----------------------------------------------------------------------------
  function bit[31:0] get_ecrc(bit local_prefix_include = 0);
    cdn_hpa_pcie_tlp m_tlp;
    if(!$cast(m_tlp,this.clone())) `uvm_fatal("has_ecrc_err","Unable to clone reference TLP");
    if(!m_tlp.m_data.size()) `uvm_fatal("has_ecrc_err", "Sanity check: TLP m_data member is empty.");

    if(m_tlp.has_ecrc()) begin
      m_tlp.populate_rsvd_type_related_var(); //Need to populate rsvd related fields befor m_hdr_type[0] update.
      m_tlp.rsvd_with_payload = m_tlp.has_payload();                    //Need to populate rsvd related fields befor m_hdr_type[0] update.
      //- Remove LPRFX + PTH + original ECRC -----------------------------------
      m_tlp.m_max_no_of_local_prefixes &= local_prefix_include;
      m_tlp.is_cxl_pbr_mode /*------*/  = 0;
      m_tlp.pack_ecrc_local /*------*/  = 0;
      m_tlp.pack_trailer /*---------*/  = 0;

      //- Set variant fields Type/EP -------------------------------------------
      m_tlp.m_hdr_type[0] = 1;          //Type field Bit 0 is variant
      m_tlp.m_tlp_ep = 1;               //EP bit is variant
      m_tlp.m_skip_rsvd_type_check = 1; //Skip Reserved Type field population

      //- Re-Pack tlp item -----------------------------------------------------
      void'(m_tlp.pack_bytes(m_tlp.m_data));

      //- Compute expected ECRC ------------------------------------------------
      get_ecrc = calc_crc_per_byte(m_tlp.m_data);
      get_ecrc = {<< byte{ {<< bit{get_ecrc}} }};
      `uvm_info("get_ecrc",$psprintf("ecrc_val = %0x, calculate crc = %0x, m_tlp.m_data = %0p", get_ecrc, calc_crc_per_byte(m_tlp.m_data), m_tlp.m_data),UVM_DEBUG)
    end
  endfunction : get_ecrc

  //----------------------------------------------------------------------------
  // Function : get_pcrc
  // This function will calculate and return PCRC
  //----------------------------------------------------------------------------
  virtual function bit[31:0] get_pcrc(bit use_user_payload=0, bit[7:0] user_payload[]=m_tlp_payload);
    byte unsigned payload[]; //calc_crc_per_byte task required ref byte unsigned dynamic array

    if(!use_user_payload) begin
      payload = new[m_tlp_payload.size()];
      payload = {>>{m_tlp_payload}};
    end
    else begin
      payload = new[user_payload.size()];
      payload = {>>{user_payload}};
    end

    get_pcrc = calc_crc_per_byte(payload);
    get_pcrc = {<< byte{ {<< bit{get_pcrc}} }};
  endfunction : get_pcrc

  //----------------------------------------------------------------------------
  // Function : has_pcrc_err
  // This function will detect PCRC error in the TLP
  //----------------------------------------------------------------------------
  virtual function bit has_pcrc_err(bit [31:0] exp_pcrc);
    if(m_ide_prefix_present && has_pcrc()) begin
      if(get_ide_pcrc() != exp_pcrc) begin
        has_pcrc_err = 1;
       `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] PCRC mismatch. Actual = %0h, Expected = %0h",get_ide_pcrc(),exp_pcrc),UVM_DEBUG);
      end
    end
  endfunction : has_pcrc_err

  //----------------------------------------------------------------------------
  // Function : has_mac_err
  // This function will detect MAC error in the TLP
  //----------------------------------------------------------------------------
  virtual function bit has_mac_err();
    bit[95:0] exp_mac = { << byte {t_ide_mac}};
    bit[95:0] obs_mac = get_ide_mac();

    if(m_ide_prefix_present && has_mac()) begin
      if(obs_mac != exp_mac) begin
        has_mac_err = 1;
       `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] MAC mismatch. Actual = %0h, Expected = %0h",obs_mac,exp_mac),UVM_DEBUG);
      end
    end
  endfunction : has_mac_err

  //----------------------------------------------------------------------------
  // Function : set_req_dlp_lcrc_err
  // This error function will inject CDN_HPA_PCIE_DLP_LCRC_ERR in the DLP
  //----------------------------------------------------------------------------
  function void set_req_dlp_lcrc_err();
    bit [31:0] l_dlp_lcrc = m_dlp_lcrc;
    lcrc_err = 1;
    assert(std::randomize(m_dlp_lcrc) with {
      if(vip_userdata.m_en_user_data)
      m_dlp_lcrc == vip_userdata.m_dlp_lcrc;
      else
      m_dlp_lcrc != l_dlp_lcrc;
    });
    `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_DLP_LCRC_ERR. LCRC = %0x,Seq_no=%0d", m_dlp_lcrc,m_dlp_seq_num),UVM_DEBUG)
  endfunction : set_req_dlp_lcrc_err

  //----------------------------------------------------------------------------
  // Function : set_req_plp_beginFrame
  // This error function will inject CDN_HPA_PCIE_PLP_BEGINFRAME_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_req_plp_beginFrame();
    bit [31:0] l_plp_beginFrame = m_plp_beginFrame;
    assert(std::randomize(m_plp_beginFrame) with {
      if(vip_userdata.m_en_user_data)
      m_plp_beginFrame == vip_userdata.m_plp_beginFrame;
      else
      m_plp_beginFrame == l_plp_beginFrame;
    });
  endfunction : set_req_plp_beginFrame

  //----------------------------------------------------------------------------
  // Function : set_req_plp_endFrame
  // This error function will inject CDN_HPA_PCIE_PLP_ENDFRAME_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_req_plp_endFrame(bit nullified);
    bit [31:0] l_plp_endFrame = m_plp_endFrame;
    assert(std::randomize(m_plp_endFrame) with {
      if(vip_userdata.m_en_user_data)
      m_plp_endFrame == vip_userdata.m_plp_endFrame;
      else if (nullified)
      m_plp_endFrame == 'h1FE;
      else
      m_plp_endFrame == l_plp_endFrame;
    });
  endfunction : set_req_plp_endFrame

  //----------------------------------------------------------------------------
  // Function : set_req_dlp_seq_num_err
  // This error function will inject CDN_HPA_PCIE_DLP_SEQ_NUM_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_req_dlp_seq_num_err();
    bit [11:0] l_dlp_seq_num = m_dlp_seq_num;
    seq_num_err = 1;
    assert(std::randomize(m_dlp_seq_num) with {
      if(vip_userdata.m_en_user_data)
      m_dlp_seq_num == vip_userdata.m_dlp_seq_num;
      else
      {
        m_dlp_seq_num != l_dlp_seq_num;
        if(last_seq_num < first_seq_num)//rollover
        {
          !(m_dlp_seq_num inside{[first_seq_num : 'hFFF]});
          !(m_dlp_seq_num inside{[0 : last_seq_num]});
        }
        else
        !(m_dlp_seq_num inside{[first_seq_num : last_seq_num]});
      }
    });
    `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_DLP_SEQ_NUM_ERR. m_dlp_seq_num = %0d", m_dlp_seq_num),UVM_DEBUG)
  endfunction : set_req_dlp_seq_num_err

  //----------------------------------------------------------------------------
  // Function : set_req_dlp_dup_seq_num_err
  // This error function will inject CDN_HPA_PCIE_DLP_DUP_SEQ_NUM_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_req_dlp_dup_seq_num_err();
    bit [11:0] l_dlp_seq_num = m_dlp_seq_num;
    seq_num_err = 1;
    assert(std::randomize(m_dlp_seq_num) with {
      if(vip_userdata.m_en_user_data)
      m_dlp_seq_num == vip_userdata.m_dlp_seq_num;
      else
      {
        if(l_dlp_seq_num == 0)
        {
          m_dlp_seq_num == 'hFFF;
        }
        else
        {
          m_dlp_seq_num == l_dlp_seq_num - 1;
        }
      }
    });
    `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_DLP_DUP_SEQ_NUM_ERR. m_dlp_seq_num = %0d", m_dlp_seq_num),UVM_DEBUG)
  endfunction : set_req_dlp_dup_seq_num_err

  //----------------------------------------------------------------------------
  // Function : set_req_tlp_aop_egress_block_err
  // This error function will inject CDN_HPA_PCIE_TLP_DSP_RX_AOP_WHEN_EGRESS_BLOCK_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_req_tlp_aop_egress_block_err();
    if((m_pcie_dev_cfg.m_port_type != CDN_HPA_PCIE_USP) || (!(m_pcie_dut_dev_cfg.m_atomic_op_egress_block)) || (m_pcie_dut_dev_cfg.m_atomic_op_req_en == 0) || m_tlp_trans_type != CDN_HPA_PCIE_TRANS_MEM_TYPE)
    error_inject_success = 0;
    else
    begin
      //get_tlp(CDN_HPA_PCIE_TRANS_MEM_TYPE);
      //If atomic req en is not enabled, don't generate atomic packets
      assert(std::randomize(m_tlp_type) with {m_tlp_type inside {[CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32:CDN_HPA_PCIE_TLP_TYPE_Cas_64]};});
      if(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32) begin m_hdr_fmt =cdn_hpa_pcie_tlp_fmt_t'( 3'b010); m_hdr_type = 5'b01100; end
      if(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64) begin m_hdr_fmt =cdn_hpa_pcie_tlp_fmt_t'( 3'b011); m_hdr_type = 5'b01100; end
      if(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)     begin m_hdr_fmt =cdn_hpa_pcie_tlp_fmt_t'( 3'b010); m_hdr_type = 5'b01101; end
      if(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64)     begin m_hdr_fmt =cdn_hpa_pcie_tlp_fmt_t'( 3'b011); m_hdr_type = 5'b01101; end
      if(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)      begin m_hdr_fmt =cdn_hpa_pcie_tlp_fmt_t'( 3'b010); m_hdr_type = 5'b01110; end
      if(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64)      begin m_hdr_fmt =cdn_hpa_pcie_tlp_fmt_t'( 3'b011); m_hdr_type = 5'b01110; end
      assert(std::randomize(m_tlp_length) with {
        // AtomicOP requests sizes:
        if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32)
        ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64)
        ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_32)
        ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Swap_64))
        {
          m_tlp_length inside {1,2};
        }
        if((m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_32)
        ||(m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cas_64))
        {
          m_tlp_length inside {2,4,8};
        }
      });
      align_byte_en();
      align_length_payload(m_tlp_length*4);
      void'(align_atomic_addr());
    end
  endfunction : set_req_tlp_aop_egress_block_err

  //----------------------------------------------------------------------------
  // Function : set_req_tlp_poisoned_err
  // This error function will inject CDN_HPA_PCIE_TLP_POISONED_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_req_tlp_poisoned_err(bit poison_nodata=0);
    if(!poison_nodata) begin
      if(!(m_tlp_type inside {
        CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
        CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,
        CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
        CDN_HPA_PCIE_TLP_TYPE_IOWr,CDN_HPA_PCIE_TLP_TYPE_MsgD,
        CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
        CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
        CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
        CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64,CDN_HPA_PCIE_TLP_TYPE_UIOMWr
      }))
      error_inject_success = 0;
      else
      assert(std::randomize(m_tlp_ep) with {
        if((m_tlp_type inside {
          CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
          CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,
          CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
          CDN_HPA_PCIE_TLP_TYPE_IOWr,CDN_HPA_PCIE_TLP_TYPE_MsgD,
          CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
          CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
          CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
          CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64,CDN_HPA_PCIE_TLP_TYPE_UIOMWr
        })) {m_tlp_ep == 1;}}
      );
    end
    else begin
      if((m_tlp_type inside {
        CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
        CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,
        CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
        CDN_HPA_PCIE_TLP_TYPE_IOWr,CDN_HPA_PCIE_TLP_TYPE_MsgD,
        CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
        CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
        CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
        CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64,CDN_HPA_PCIE_TLP_TYPE_UIOMWr
      }))
      error_inject_success = 0;
      else
      assert(std::randomize(m_tlp_ep) with {
        if(!(m_tlp_type inside {
          CDN_HPA_PCIE_TLP_TYPE_CfgWr0,CDN_HPA_PCIE_TLP_TYPE_CfgWr1,
          CDN_HPA_PCIE_TLP_TYPE_MWr_32,CDN_HPA_PCIE_TLP_TYPE_MWr_64,
          CDN_HPA_PCIE_TLP_TYPE_DMWr_32,CDN_HPA_PCIE_TLP_TYPE_DMWr_64,
          CDN_HPA_PCIE_TLP_TYPE_IOWr,CDN_HPA_PCIE_TLP_TYPE_MsgD,
          CDN_HPA_PCIE_TLP_TYPE_CplD,CDN_HPA_PCIE_TLP_TYPE_CplDLk,
          CDN_HPA_PCIE_TLP_TYPE_FetchAdd_32,CDN_HPA_PCIE_TLP_TYPE_FetchAdd_64,
          CDN_HPA_PCIE_TLP_TYPE_Swap_32,CDN_HPA_PCIE_TLP_TYPE_Swap_64,
          CDN_HPA_PCIE_TLP_TYPE_Cas_32,CDN_HPA_PCIE_TLP_TYPE_Cas_64,CDN_HPA_PCIE_TLP_TYPE_UIOMWr
        })) {m_tlp_ep == 1;}}
      );
    end

  endfunction : set_req_tlp_poisoned_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_10bit_tag_unexp_err
  // This error function will inject CDN_HPA_PCIE_TLP_CPL_10BIT_TAG_UNEXP_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_10bit_tag_unexp_err();
    bit[9:0] temp_tag = 0;
    if(m_pcie_dev_cfg.m_10_bit_tag_completer_cap)
    begin
      error_inject_success = 0;
    end
    else
    begin
      //temp_tag = compl_lut_obj.compl_lut.xor with (item.m_req_tag);
      if(compl_lut_obj)
      assert(std::randomize(m_tlp_tag) with {
        //(m_tlp_tag ^ temp_tag) == 0;
        foreach(compl_lut_obj.compl_lut[i])
        m_tlp_tag != compl_lut_obj.compl_lut[i].m_req_tag;
        if(!m_pcie_dev_cfg.m_10_bit_tag_completer_cap)
        {m_tlp_t9,m_tlp_t8 }== 2'b00;
      });
      else
      error_inject_success = 0;
      `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_TLP_CPL_10BIT_TAG_UNEXP_ERR"),UVM_DEBUG)
    end
  endfunction : set_cpl_tlp_10bit_tag_unexp_err

  //todo::cpl with E2E prefixes are not supported
  // //----------------------------------------------------------------------------
  // // Function : set_cpl_tlp_unsupp_e2e_unexp_err
  // // This error function will inject CDN_HPA_PCIE_TLP_CPL_UNSUPP_E2E_UNEXP_ERR in the TLP
  // //----------------------------------------------------------------------------
  // function void set_cpl_tlp_unsupp_e2e_unexp_err();
  //   error_inject_success = 0;
  //   //if(compute_prefixes() == 0)
  //   //  error_inject_success = 0;
  //   `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_TLP_CPL_UNSUPP_E2E_UNEXP_ERR"),UVM_DEBUG)
  // endfunction : set_cpl_tlp_unsupp_e2e_unexp_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_byte_count_unexp_err
  // This error function will inject CDN_HPA_PCIE_TLP_CPL_BYTE_COUNT_UNEXP_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_byte_count_unexp_err();
    bit [11:0] l_tlp_cpl_byte_cnt = m_tlp_cpl_byte_cnt;

    if((m_tlp_req_type != CDN_HPA_PCIE_TRANS_COMPLETION) || (m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_Cpl && m_tlp_cpl_status == CDN_HPA_PCIE_CPL_SC))
    error_inject_success = 0;
    else
    begin
      assert(std::randomize(m_tlp_cpl_byte_cnt) with {
        if(m_pcie_dev_top_cfg.get_min_rrs_in_bytes() == 4096){
          m_tlp_cpl_byte_cnt inside {[0: m_pcie_dev_top_cfg.get_min_rrs_in_bytes()-1]};
        }
        else {
          m_tlp_cpl_byte_cnt inside {[1: m_pcie_dev_top_cfg.get_min_rrs_in_bytes()-1]};
        }
        m_tlp_cpl_byte_cnt != l_tlp_cpl_byte_cnt;
        if(lut_item.m_req_tlp_at_type == CDN_HPA_PCIE_AT_Translation_Request) {
          m_tlp_cpl_byte_cnt > l_tlp_cpl_byte_cnt;
        }
      });
      //assert(std::randomize(m_tlp_cpl_lower_addr) with {m_tlp_cpl_lower_addr == 0;});
    end
    `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_TLP_CPL_BYTE_COUNT_UNEXP_ERR"),UVM_DEBUG)
  endfunction : set_cpl_tlp_byte_count_unexp_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_lower_addr_unexp_err
  // This error function will inject CDN_HPA_PCIE_TLP_CPL_LOWER_ADDR_UNEXP_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_lower_addr_unexp_err();
    bit [6:0] lower_addr = m_tlp_cpl_lower_addr;

    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CPL_TYPE)
    error_inject_success = 0;
    else begin
      `ifdef HLS_MODULE_MODE
        assert(std::randomize(m_tlp_cpl_lower_addr) with {m_tlp_cpl_lower_addr[5:0] != lower_addr[5:0];}); //As per JIRA: PCIE-11291, will update for RCB violation check
      `else
        assert(std::randomize(m_tlp_cpl_lower_addr) with {m_tlp_cpl_lower_addr != lower_addr;});
      `endif
      `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_TLP_CPL_LOWER_ADDR_UNEXP_ERR"),UVM_DEBUG)
      if(m_tlp_cpl_lower_addr[1:0] != 2'b00) begin
        m_ohc_hdr.ohc_a_present = 1;
        m_ohc_a[4:3] = m_tlp_cpl_lower_addr[1:0];
      end
    end
  endfunction : set_cpl_tlp_lower_addr_unexp_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_UR_err
  // This error function will inject CDN_HPA_PCIE_TLP_CPL_UR_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_UR_err();
    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CPL_TYPE)
    error_inject_success = 0;
    else
    begin
    if(compl_lut_obj)begin
      if(compl_lut_obj.compl_lut[{m_tlp_14_bit_tagscale,m_tlp_t9,m_tlp_t8,m_tlp_tag}].m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_UIOMWr) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl;
      m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(3'b000);
      m_hdr_type = 5'b01100;
     // m_tlp_length = 1;
      end
      else if(compl_lut_obj.compl_lut[{m_tlp_14_bit_tagscale,m_tlp_t9,m_tlp_t8,m_tlp_tag}].m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_UIOMRd) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIORdCpl;
      m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(3'b000);
      m_hdr_type = 5'b01101;
      //m_tlp_length = 1;
     // m_tlp_payload.delete();
      end
      else begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Cpl;
      m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(3'b000);
      m_hdr_type = 5'b01010;
      m_tlp_length = 1;
       m_tlp_payload.delete();
      end
      end
      //m_tlp_payload.delete();
      assert(std::randomize(m_tlp_cpl_status) with {m_tlp_cpl_status inside {CDN_HPA_PCIE_CPL_UR};});
      m_ohc_hdr.ohc_a_present = 1;
      m_ohc_a[2:0] = m_tlp_cpl_status;
    end
    `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_TLP_CPL_UR_ERR"),UVM_DEBUG)
  endfunction : set_cpl_tlp_UR_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_CA_err
  // This error function will inject CDN_HPA_PCIE_TLP_CPL_CA_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_CA_err();
    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CPL_TYPE)
    error_inject_success = 0;
    else
    begin
    if(compl_lut_obj)begin
      if(compl_lut_obj.compl_lut[{m_tlp_14_bit_tagscale,m_tlp_t9, m_tlp_t8, m_tlp_tag}].m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_UIOMWr) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIOWrCpl;
      m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(3'b000);
      m_hdr_type = 5'b01100;
     // m_tlp_length = 1;
      end
      else if(compl_lut_obj.compl_lut[{m_tlp_14_bit_tagscale,m_tlp_t9, m_tlp_t8, m_tlp_tag}].m_tlp_type==CDN_HPA_PCIE_TLP_TYPE_UIOMRd) begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_UIORdCpl;
      m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(3'b000);
      m_hdr_type = 5'b01101;
      //m_tlp_length = 1;
      end
      else begin
      m_tlp_type = CDN_HPA_PCIE_TLP_TYPE_Cpl;
      m_hdr_fmt = cdn_hpa_pcie_tlp_fmt_t'(3'b000);
      m_hdr_type = 5'b01010;
      m_tlp_length = 1;
      m_tlp_payload.delete();
      end
      end
      //m_tlp_payload.delete();
      assert(std::randomize(m_tlp_cpl_status) with {m_tlp_cpl_status inside {CDN_HPA_PCIE_CPL_ABORT};});
      m_ohc_hdr.ohc_a_present = 1;
      m_ohc_a[2:0] = m_tlp_cpl_status;
    end
    `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_TLP_CPL_CA_ERR"),UVM_DEBUG)
  endfunction : set_cpl_tlp_CA_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_TC_err
  // This error function will inject CDN_HPA_PCIE_TLP_CPL_TC_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_TC_err();
    bit[2:0] l_tlp_tc;
    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CPL_TYPE)
    error_inject_success = 0;
    else
    begin
      if(!(std::randomize(l_tlp_tc) with {
        l_tlp_tc != m_tlp_tc;
        !(l_tlp_tc inside {m_pcie_dev_cfg.m_unmapped_tc_list});
      }))
      error_inject_success = 0;
      else
      m_tlp_tc = l_tlp_tc;
    end
    `uvm_info(get_full_name(),$psprintf("Error injected is = %0d for CDN_HPA_PCIE_TLP_CPL_TC_ERR", error_inject_success),UVM_DEBUG)
  endfunction : set_cpl_tlp_TC_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_Attr_err
  // This error function will inject CDN_HPA_PCIE_TLP_CPL_Attr_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_Attr_err();
    bit[1:0] actual_attr0 = m_tlp_attr0;
    if(m_tlp_trans_type != CDN_HPA_PCIE_TRANS_CPL_TYPE)
    error_inject_success = 0;
    else
    begin
      assert(std::randomize(m_tlp_attr0) with {m_tlp_attr0 != actual_attr0;});
    end
    `uvm_info(get_full_name(),$psprintf("Error injected is CDN_HPA_PCIE_TLP_CPL_Attr_ERR"),UVM_DEBUG)
  endfunction : set_cpl_tlp_Attr_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_stream_id_err
  // This error function will inject CDN_HPA_PCIE_TLP_CPL_STREAM_ID_ERR in the TLP
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_stream_id_err();
    bit[7:0] h_stream_id = m_stream_id;

    if(!(m_ide_prefix_present && (m_tlp_trans_type == CDN_HPA_PCIE_TRANS_CPL_TYPE))) begin
      error_inject_success = 0;
     `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] cannot inject CDN_HPA_PCIE_TLP_CPL_STREAM_ID_ERR"),UVM_DEBUG);
      return;
    end

    assert(std::randomize(m_stream_id) with {m_stream_id inside {m_pcie_dev_top_cfg.ide_cfg.stream_id}; m_stream_id != h_stream_id;});
    recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));

    error_inject_success = 1;
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] CDN_HPA_PCIE_TLP_CPL_STREAM_ID_ERR injected"),UVM_DEBUG);
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] Original streamID = %0d, Corrupted streamID = %0d",h_stream_id,m_stream_id),UVM_DEBUG);
  endfunction : set_cpl_tlp_stream_id_err
  
  //----------------------------------------------------------------------------
  // Function : set_tlp_rid_value_err
  // This error function will inject CDN_HPA_PCIE_TLP_RID_MISMATCH_ERR in the TLP
  // the error will only be injected on route_by_id TLP ( i.e. CFG,MSG/MSGd(rout_by_id only) TLPS)
  //----------------------------------------------------------------------------
  function void set_tlp_rid_value_err();
    bit[15:0] target_bdf;

    if(!(m_ide_prefix_present && (m_sel_stream_possible) &&(((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE ) && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID)) || (m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE})))) begin
      error_inject_success = 0;
     `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] cannot inject CDN_HPA_PCIE_TLP_RID_MISMATCH_ERR"),UVM_DEBUG);
      return;
    end
    
    else begin
      if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id] != null) begin
        `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] Original requester_id  = %0h",m_tlp_requester_id),UVM_DEBUG);
        m_tlp_requester_id = (m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_RID_limit +'h100); 
        `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] corrupted requester_id  = %0h",m_tlp_requester_id),UVM_DEBUG);
      end
      else begin
        return;
      end
    end
    //recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));

    error_inject_success = 1;
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] CDN_HPA_PCIE_TLP_RID_MISMATCH_ERR injected"),UVM_DEBUG);
  endfunction : set_tlp_rid_value_err

  //----------------------------------------------------------------------------
  // Function : set_tlp_segment_value_err
  // This error function will inject CDN_HPA_PCIE_TLP_SEGMENT_MISMATCH_ERR in the TLP
  // the error will only be injected on route_by_id TLP in Flit mode ( i.e. CFG,MSG/MSGd(rout_by_id only) TLPS)
  //----------------------------------------------------------------------------
  function void set_tlp_segment_value_err();
    bit[15:0] target_bdf;

    if(!(m_ide_prefix_present && is_flit_mode && (m_sel_stream_possible) &&(((m_tlp_trans_type == CDN_HPA_PCIE_TRANS_MSG_TYPE ) && (m_tlp_msg_rout_type == CDN_HPA_PCIE_TLP_MSG_ROUT_BY_ID)) || (m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CFG_TYPE})))) begin
      error_inject_success = 0;
     `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] cannot inject CDN_HPA_PCIE_TLP_SEGMENT_MISMATCH_ERR"),UVM_DEBUG);
      return;
    end
    
    else begin
      if (m_requester_segment_valid && (m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id] != null))begin
        `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] Original m_requester_segment  = %0h",m_requester_segment),UVM_DEBUG);
        m_requester_segment = (m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_segment_base +'h10); 
        `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] corrupted m_requester_segment  = %0h",m_requester_segment),UVM_DEBUG);
        error_inject_success = 1;
      end
      else begin
        `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] cannot inject CDN_HPA_PCIE_TLP_SEGMENT_MISMATCH_ERR"),UVM_DEBUG);
        error_inject_success = 0;
      end  
    end
    recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));

   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] CDN_HPA_PCIE_TLP_SEGMENT_MISMATCH_ERR injected"),UVM_DEBUG);
  endfunction : set_tlp_segment_value_err

  //----------------------------------------------------------------------------
  // Function : set_cpl_tlp_rid_value_err
  // This error function will inject CDN_HPA_PCIE_CPL_TLP_RID_MISMATCH_ERR in the TLP
  // the error will only be injected on route_by_id TLP ( i.e. Cpl/Cpld TLPS)
  //----------------------------------------------------------------------------
  function void set_cpl_tlp_rid_value_err();
    bit[15:0] target_bdf;

    if(!(m_ide_prefix_present &&(m_tlp_trans_type inside {CDN_HPA_PCIE_TRANS_CPL_TYPE})) || (m_pcie_dev_top_cfg.ide_cfg.m_num_sel_str_enabled == 0)) begin
      error_inject_success = 0;
     `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] cannot inject CDN_HPA_PCIE_CPL_TLP_RID_MISMATCH_ERR"),UVM_DEBUG);
      return;
    end
    
    else begin
      if(m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id] != null) begin
        `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] Original completer_id  = %0h",m_tlp_completer_id),UVM_DEBUG);
        m_tlp_completer_id = (m_pcie_dev_top_cfg.ide_cfg.m_ide_selective_stream_config[m_stream_id].m_RID_limit +'h100); 
        `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] corrupted completer_id  = %0h",m_tlp_completer_id),UVM_DEBUG);
      end
      else begin
        return;
      end
    end
    //recalc_ide_prefix();
    void'(this.pack_bytes(this.m_data));

    error_inject_success = 1;
   `uvm_info(get_type_name(),$psprintf("[DEBUG_IDE_ERR] CDN_HPA_PCIE_CPL_TLP_RID_MISMATCH_ERR injected"),UVM_DEBUG);
  endfunction : set_cpl_tlp_rid_value_err
