`ifndef CDN_PCIE_HLS_BRIDGE_DIRECTED_UIO_TEST_SV
`define CDN_PCIE_HLS_BRIDGE_DIRECTED_UIO_TEST_SV

// directed scenario 
class cdn_pcie_hls_bridge_directed_uio_scenario extends cdn_pcie_hls_bridge_scenario;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_uio_scenario)

  function new(string name="cdn_pcie_hls_bridge_directed_uio_scenario");
    super.new(name);

    m_traffic_type = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_traffic_type_e'(BOTH_OB_IB_TRAFFIC);
    m_ib_target = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI);
    
  endfunction : new

  constraint m_number_of_tlps_c {
    m_number_of_tlps == 100;
  }

  constraint m_number_of_tlp_bursts_c {
    m_number_of_tlp_bursts == 1;
  }

endclass : cdn_pcie_hls_bridge_directed_uio_scenario

// Directed Strap Policy
class cdn_pcie_hls_bridge_directed_strap_uio_policy  extends cdn_pcie_strap_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_strap_uio_policy)

  function new(string name="cdn_pcie_hls_bridge_directed_strap_uio_policy");
    super.new(name);
  endfunction : new

  constraint bar_64_c {
    foreach (item.k_bar_enable[i]) {
      $countones(item.k_bar_enable[i]) > 1;
      $countones(item.k_bar_type[i]) <= 4; // at least 2 MEM BARs
      $countones(item.k_bar_size[i]) > 1;
    }
    foreach (item.k_vf_bar_enable[i]) {
      $countones(item.k_vf_bar_enable[i]) > 1;
      $countones(item.k_vf_bar_size[i]) > 1;
    }
    foreach (item.k_rp_bar_enable[i]) {
      $countones(item.k_rp_bar_enable) >= 1;
      $countones(item.k_rp_bar_size) >= 1;
    }
  }
  
endclass : cdn_pcie_hls_bridge_directed_strap_uio_policy

// Directed Dev Config Policy
class cdn_pcie_hls_directed_uio_dev_config_policy extends cdn_pcie_hls_bridge_dev_config_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_directed_uio_dev_config_policy)

  function new(string name="cdn_pcie_hls_directed_uio_dev_config_policy");
    super.new(name);
  endfunction : new

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  constraint c_directed_uio_req_comp_enable {
    item.m_uio_Mem_RdWr_compl_supp == 1;
    item.m_uio_Mem_RdWr_req_supp == 1;
  }

  constraint c_uio_dev_ctrl3 {
    item.m_uio_Mem_RdWr_req_en == 1;
  }

endclass : cdn_pcie_hls_directed_uio_dev_config_policy

// Directed TLP
class cdn_pcie_hls_bridge_directed_uio_tlp extends cdn_hpa_pcie_tlp;

  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_uio_tlp)

  //---------------------------------------------------------------------------
  // Function : new
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_uio_tlp");
    super.new(name);
  endfunction

  constraint uio_req_tlp_c {
    m_tlp_type inside { CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr };
    m_tlp_type dist { CDN_HPA_PCIE_TLP_TYPE_UIOMRd := 1, CDN_HPA_PCIE_TLP_TYPE_UIOMWr := 1 };
  }

endclass : cdn_pcie_hls_bridge_directed_uio_tlp

class cdn_pcie_hls_bridge_directed_uio_test extends cdn_pcie_hls_bridge_base_test;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_directed_uio_test)

  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name and parent handler.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_uio_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: build_phase
  // This method builds instance of example testbench.
  //---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(cdn_pcie_hls_bridge_scenario::get_type(),      cdn_pcie_hls_bridge_directed_uio_scenario::get_type()); 
    set_type_override_by_type(cdn_hpa_pcie_tlp::get_type(),                  cdn_pcie_hls_bridge_directed_uio_tlp::get_type()); 
    set_type_override_by_type(cdn_pcie_strap_random_policy::get_type(),      cdn_pcie_hls_bridge_directed_strap_uio_policy::get_type()); 
    set_type_override_by_type(cdn_pcie_dev_config_random_policy::get_type(), cdn_pcie_hls_directed_uio_dev_config_policy::get_type());
    super.build_phase(phase);
      
  endfunction : build_phase

endclass : cdn_pcie_hls_bridge_directed_uio_test

`endif // CDN_PCIE_HLS_BRIDGE_DIRECTED_UIO_TEST_SV
`ifndef CDN_PCIE_HLS_BRIDGE_DIRECTED_IB_UIO_RD_TEST_SV
`define CDN_PCIE_HLS_BRIDGE_DIRECTED_IB_UIO_RD_TEST_SV

// directed scenario 
class cdn_pcie_hls_bridge_directed_ib_uio_rd_scenario extends cdn_pcie_hls_bridge_scenario;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_ib_uio_rd_scenario)

  function new(string name="cdn_pcie_hls_bridge_directed_ib_uio_rd_scenario");
    super.new(name);

    m_traffic_type = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_traffic_type_e'(IB_TRAFFIC_ONLY);
    m_ib_target = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI);
    
  endfunction : new

  constraint m_number_of_tlps_c {
    m_number_of_tlps == 50;
  }

  constraint m_number_of_tlp_bursts_c {
    m_number_of_tlp_bursts == 1;
  }

endclass

// Directed Strap Policy
class cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_policy  extends cdn_pcie_strap_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_policy)

  function new(string name="cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_policy");
    super.new(name);
  endfunction : new

  constraint bar_64_c {
    foreach (item.k_bar_enable[i]) {
      $countones(item.k_bar_enable[i]) > 1;
      $countones(item.k_bar_type[i]) <= 4; // at least 2 MEM BARs
      $countones(item.k_bar_size[i]) > 1;
    }
    foreach (item.k_vf_bar_enable[i]) {
      $countones(item.k_vf_bar_enable[i]) > 1;
      $countones(item.k_vf_bar_size[i]) > 1;
    }
    foreach (item.k_rp_bar_enable[i]) {
      $countones(item.k_rp_bar_enable) >= 1;
      $countones(item.k_rp_bar_size) >= 1;
    }
  }
  
endclass

// Directed Dev Config Policy
class cdn_pcie_hls_bridge_directed_ib_uio_rd_dev_config_policy extends cdn_pcie_hls_bridge_dev_config_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_ib_uio_rd_dev_config_policy)

  function new(string name="cdn_pcie_hls_bridge_directed_ib_uio_rd_dev_config_policy");
    super.new(name);
  endfunction : new

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  constraint c_directed_uio_req_comp_enable {
    item.m_uio_Mem_RdWr_compl_supp == 1;
    item.m_uio_Mem_RdWr_req_supp == 1;
  }

  constraint c_uio_dev_ctrl3 {
    item.m_uio_Mem_RdWr_req_en == 1;
  }

endclass : cdn_pcie_hls_bridge_directed_ib_uio_rd_dev_config_policy

// Directed TLP
class cdn_pcie_hls_bridge_directed_ib_uio_rd_tlp extends cdn_hpa_pcie_tlp;

  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_ib_uio_rd_tlp)

  //---------------------------------------------------------------------------
  // Function : new
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_ib_uio_rd_tlp");
    super.new(name);
  endfunction

  constraint uio_read_tlp_c {
    m_tlp_type == CDN_HPA_PCIE_TLP_TYPE_UIOMRd;
  }

endclass : cdn_pcie_hls_bridge_directed_ib_uio_rd_tlp

class cdn_pcie_hls_bridge_directed_ib_uio_rd_test extends cdn_pcie_hls_bridge_base_test;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_directed_ib_uio_rd_test)

  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name and parent handler.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_ib_uio_rd_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: build_phase
  // This method builds instance of example testbench.
  //---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(cdn_pcie_hls_bridge_scenario::get_type(),      cdn_pcie_hls_bridge_directed_ib_uio_rd_scenario::get_type()); 
    set_type_override_by_type(cdn_hpa_pcie_tlp::get_type(),                  cdn_pcie_hls_bridge_directed_ib_uio_rd_tlp::get_type()); 
    set_type_override_by_type(cdn_pcie_strap_random_policy::get_type(),      cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_policy::get_type()); 
    set_type_override_by_type(cdn_pcie_dev_config_random_policy::get_type(), cdn_pcie_hls_bridge_directed_ib_uio_rd_dev_config_policy::get_type());
    super.build_phase(phase);
      
  endfunction : build_phase

endclass : cdn_pcie_hls_bridge_directed_ib_uio_rd_test

`endif // CDN_PCIE_HLS_BRIDGE_DIRECTED_IB_UIO_RD_TEST_SV
`ifndef CDN_PCIE_HLS_BRIDGE_DIRECTED_IB_UIO_RD_WR_TEST_SV
`define CDN_PCIE_HLS_BRIDGE_DIRECTED_IB_UIO_RD_WR_TEST_SV

// directed scenario 
class cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_scenario extends cdn_pcie_hls_bridge_scenario;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_scenario)

  function new(string name="cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_scenario");
    super.new(name);

    m_traffic_type = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_traffic_type_e'(IB_TRAFFIC_ONLY);
    m_ib_target = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI);
    
  endfunction : new

  constraint m_number_of_tlps_c {
    m_number_of_tlps == 100;
  }

  constraint m_number_of_tlp_bursts_c {
    m_number_of_tlp_bursts == 1;
  }

endclass : cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_scenario

// Directed Strap Policy
class cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_wr_policy  extends cdn_pcie_strap_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_wr_policy)

  function new(string name="cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_wr_policy");
    super.new(name);
  endfunction : new

  constraint bar_64_c {
    foreach (item.k_bar_enable[i]) {
      $countones(item.k_bar_enable[i]) > 1;
      $countones(item.k_bar_type[i]) <= 4; // at least 2 MEM BARs
      $countones(item.k_bar_size[i]) > 1;
    }
    foreach (item.k_vf_bar_enable[i]) {
      $countones(item.k_vf_bar_enable[i]) > 1;
      $countones(item.k_vf_bar_size[i]) > 1;
    }
    foreach (item.k_rp_bar_enable[i]) {
      $countones(item.k_rp_bar_enable) >= 1;
      $countones(item.k_rp_bar_size) >= 1;
    }
  }
  
endclass : cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_wr_policy

// Directed Dev Config Policy
class cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_dev_config_policy extends cdn_pcie_hls_bridge_dev_config_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_dev_config_policy)

  function new(string name="cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_dev_config_policy");
    super.new(name);
  endfunction : new

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  constraint c_directed_uio_req_comp_enable {
    item.m_uio_Mem_RdWr_compl_supp == 1;
    item.m_uio_Mem_RdWr_req_supp == 1;
  }

  constraint c_uio_dev_ctrl3 {
    item.m_uio_Mem_RdWr_req_en == 1;
  }

endclass : cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_dev_config_policy

// Directed TLP
class cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_tlp extends cdn_hpa_pcie_tlp;

  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_tlp)

  //---------------------------------------------------------------------------
  // Function : new
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_tlp");
    super.new(name);
  endfunction

  constraint uio_req_tlp_c {
    m_tlp_type inside { CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr };
    m_tlp_type dist { CDN_HPA_PCIE_TLP_TYPE_UIOMRd := 1, CDN_HPA_PCIE_TLP_TYPE_UIOMWr := 1 };
  }

endclass : cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_tlp

class cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_test extends cdn_pcie_hls_bridge_base_test;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_test)

  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name and parent handler.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: build_phase
  // This method builds instance of example testbench.
  //---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(cdn_pcie_hls_bridge_scenario::get_type(),      cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_scenario::get_type()); 
    set_type_override_by_type(cdn_hpa_pcie_tlp::get_type(),                  cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_tlp::get_type()); 
    set_type_override_by_type(cdn_pcie_strap_random_policy::get_type(),      cdn_pcie_hls_bridge_directed_strap_ib_uio_rd_wr_policy::get_type()); 
    set_type_override_by_type(cdn_pcie_dev_config_random_policy::get_type(), cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_dev_config_policy::get_type());
    super.build_phase(phase);
      
  endfunction : build_phase

endclass : cdn_pcie_hls_bridge_directed_ib_uio_rd_wr_test

`endif // CDN_PCIE_HLS_BRIDGE_DIRECTED_IB_UIO_RD_WR_TEST_SV
`ifndef CDN_PCIE_HLS_BRIDGE_DIRECTED_OB_UIO_RD_WR_TEST_SV
`define CDN_PCIE_HLS_BRIDGE_DIRECTED_OB_UIO_RD_WR_TEST_SV

// directed scenario 
class cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_scenario extends cdn_pcie_hls_bridge_scenario;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_scenario)

  function new(string name="cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_scenario");
    super.new(name);

    m_traffic_type = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_traffic_type_e'(OB_TRAFFIC_ONLY);
    
  endfunction : new

  constraint m_number_of_tlps_c {
    m_number_of_tlps == 100;
  }

  constraint m_number_of_tlp_bursts_c {
    m_number_of_tlp_bursts == 1;
  }

endclass : cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_scenario

// Directed Strap Policy
class cdn_pcie_hls_bridge_directed_strap_ob_uio_rd_wr_policy  extends cdn_pcie_strap_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_strap_ob_uio_rd_wr_policy)

  function new(string name="cdn_pcie_hls_bridge_directed_strap_ob_uio_rd_wr_policy");
    super.new(name);
  endfunction : new

  constraint bar_64_c {
    foreach (item.k_bar_enable[i]) {
      $countones(item.k_bar_enable[i]) > 1;
      $countones(item.k_bar_type[i]) <= 4; // at least 2 MEM BARs
      $countones(item.k_bar_size[i]) > 1;
    }
    foreach (item.k_vf_bar_enable[i]) {
      $countones(item.k_vf_bar_enable[i]) > 1;
      $countones(item.k_vf_bar_size[i]) > 1;
    }
    foreach (item.k_rp_bar_enable[i]) {
      $countones(item.k_rp_bar_enable) >= 1;
      $countones(item.k_rp_bar_size) >= 1;
    }
  }
  
endclass : cdn_pcie_hls_bridge_directed_strap_ob_uio_rd_wr_policy

// Directed Dev Config Policy
class cdn_pcie_hls_directed_ob_uio_rd_wr_dev_config_policy extends cdn_pcie_hls_bridge_dev_config_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_directed_ob_uio_rd_wr_dev_config_policy)

  function new(string name="cdn_pcie_hls_directed_ob_uio_rd_wr_dev_config_policy");
    super.new(name);
  endfunction : new

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  constraint c_directed_uio_req_comp_enable {
    item.m_uio_Mem_RdWr_compl_supp == 1;
    item.m_uio_Mem_RdWr_req_supp == 1;
  }

  constraint c_uio_dev_ctrl3 {
    item.m_uio_Mem_RdWr_req_en == 1;
  }

endclass : cdn_pcie_hls_directed_ob_uio_rd_wr_dev_config_policy

// Directed TLP
class cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_tlp extends cdn_hpa_pcie_tlp;

  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_tlp)

  //---------------------------------------------------------------------------
  // Function : new
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_tlp");
    super.new(name);
  endfunction

  constraint uio_req_tlp_c {
    m_tlp_type inside { CDN_HPA_PCIE_TLP_TYPE_UIOMRd, CDN_HPA_PCIE_TLP_TYPE_UIOMWr };
    m_tlp_type dist { CDN_HPA_PCIE_TLP_TYPE_UIOMRd := 1, CDN_HPA_PCIE_TLP_TYPE_UIOMWr := 1 };
  }

endclass : cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_tlp

class cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_test extends cdn_pcie_hls_bridge_base_test;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_test)

  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name and parent handler.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: build_phase
  // This method builds instance of example testbench.
  //---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(cdn_pcie_hls_bridge_scenario::get_type(),      cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_scenario::get_type()); 
    set_type_override_by_type(cdn_hpa_pcie_tlp::get_type(),                  cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_tlp::get_type()); 
    set_type_override_by_type(cdn_pcie_strap_random_policy::get_type(),      cdn_pcie_hls_bridge_directed_strap_ob_uio_rd_wr_policy::get_type()); 
    set_type_override_by_type(cdn_pcie_dev_config_random_policy::get_type(), cdn_pcie_hls_directed_ob_uio_rd_wr_dev_config_policy::get_type());
    super.build_phase(phase);
      
  endfunction : build_phase

endclass : cdn_pcie_hls_bridge_directed_ob_uio_rd_wr_test

`endif // CDN_PCIE_HLS_BRIDGE_DIRECTED_OB_UIO_RD_WR_TEST_SV
`ifndef CDN_PCIE_HLS_BRIDGE_DIRECTED_NONUIO_UIO_TEST_SV
`define CDN_PCIE_HLS_BRIDGE_DIRECTED_NONUIO_UIO_TEST_SV

// directed scenario 
class cdn_pcie_hls_bridge_directed_nonuio_uio_scenario extends cdn_pcie_hls_bridge_scenario;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_nonuio_uio_scenario)

  function new(string name="cdn_pcie_hls_bridge_directed_nonuio_uio_scenario");
    super.new(name);

    // m_ib_target = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI_DTI);
  endfunction : new

  // constraint m_number_of_tlps_c {
  //   m_number_of_tlps == 100;
  // }

  // constraint m_number_of_tlp_bursts_c {
  //   m_number_of_tlp_bursts == 1;
  // }

  constraint m_strap_port_type_c {
    m_strap_port_type == 1;
  }

endclass : cdn_pcie_hls_bridge_directed_nonuio_uio_scenario

// Directed Strap Policy
class cdn_pcie_hls_bridge_directed_strap_nonuio_uio_policy  extends cdn_pcie_strap_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_strap_nonuio_uio_policy)

  function new(string name="cdn_pcie_hls_bridge_directed_strap_nonuio_uio_policy");
    super.new(name);
  endfunction : new

  constraint bar_64_c {
    foreach (item.k_bar_enable[i]) {
      $countones(item.k_bar_enable[i]) > 1;
      $countones(item.k_bar_type[i]) <= 4; // at least 2 MEM BARs
      $countones(item.k_bar_size[i]) > 1;
    }
    foreach (item.k_vf_bar_enable[i]) {
      $countones(item.k_vf_bar_enable[i]) > 1;
      $countones(item.k_vf_bar_size[i]) > 1;
    }
    foreach (item.k_rp_bar_enable[i]) {
      $countones(item.k_rp_bar_enable) >= 1;
      $countones(item.k_rp_bar_size) >= 1;
    }
  }
  
endclass : cdn_pcie_hls_bridge_directed_strap_nonuio_uio_policy

// Directed Dev Config Policy
class cdn_pcie_hls_directed_nonuio_uio_dev_config_policy extends cdn_pcie_hls_bridge_dev_config_random_policy;
  
  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_directed_nonuio_uio_dev_config_policy)

  function new(string name="cdn_pcie_hls_directed_nonuio_uio_dev_config_policy");
    super.new(name);
  endfunction : new

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  constraint c_directed_uio_req_comp_enable {
    item.m_uio_Mem_RdWr_compl_supp == 1;
    item.m_uio_Mem_RdWr_req_supp == 1;
  }

  constraint c_uio_dev_ctrl3 {
    item.m_uio_Mem_RdWr_req_en == 1;
  }

endclass : cdn_pcie_hls_directed_nonuio_uio_dev_config_policy


// Directed TLP
class cdn_pcie_hls_bridge_directed_nonuio_uio_tlp extends cdn_hpa_pcie_tlp;

  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_directed_nonuio_uio_tlp)

  //---------------------------------------------------------------------------
  // Function : new
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_nonuio_uio_tlp");
    super.new(name);
  endfunction

  constraint uio_and_nonuio_tlp_c {
    m_tlp_type dist { CDN_HPA_PCIE_TLP_TYPE_UIOMRd := 1, CDN_HPA_PCIE_TLP_TYPE_UIOMWr := 1, [0:31] :/ 1 };
  }

endclass : cdn_pcie_hls_bridge_directed_nonuio_uio_tlp

class cdn_pcie_hls_bridge_directed_nonuio_uio_test extends cdn_pcie_hls_bridge_base_test;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_directed_nonuio_uio_test)

  //---------------------------------------------------------------------------
  // Constructor: new
  // This constructor sets default name and parent handler.
  //---------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_directed_nonuio_uio_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: build_phase
  // This method builds instance of example testbench.
  //---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(cdn_pcie_hls_bridge_scenario::get_type(),      cdn_pcie_hls_bridge_directed_nonuio_uio_scenario::get_type()); 
    // set_type_override_by_type(cdn_hpa_pcie_tlp::get_type(),                  cdn_pcie_hls_bridge_directed_nonuio_uio_tlp::get_type()); 
    set_type_override_by_type(cdn_pcie_strap_random_policy::get_type(),      cdn_pcie_hls_bridge_directed_strap_nonuio_uio_policy::get_type()); 
    set_type_override_by_type(cdn_pcie_dev_config_random_policy::get_type(), cdn_pcie_hls_directed_nonuio_uio_dev_config_policy::get_type());
    super.build_phase(phase);
      
  endfunction : build_phase

endclass : cdn_pcie_hls_bridge_directed_nonuio_uio_test

`endif // CDN_PCIE_HLS_BRIDGE_DIRECTED_NONUIO_UIO_TEST_SV

`ifndef CDN_PCIE_HLS_BRIDGE_BACKPRESSURE_TEST_SV
`define CDN_PCIE_HLS_BRIDGE_BACKPRESSURE_TEST_SV

//------------------------------------------------------------------------------
// Class : cdn_pcie_hls_bridge_backpressure_scenario
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_backpressure_scenario extends cdn_pcie_hls_bridge_scenario;

  //----------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_backpressure_scenario)

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_backpressure_scenario");
    super.new(name);
  endfunction : new

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  // Overriding parent class constraint.
  constraint c_m_backpressure_scenario {
    m_backpressure_scenario inside {cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_backpressure_scenario_e'(BACKPRESSURE_OB), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_backpressure_scenario_e'(BACKPRESSURE_IB), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_backpressure_scenario_e'(BACKPRESSURE_MSI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_backpressure_scenario_e'(BACKPRESSURE_ALL)};
  }

endclass : cdn_pcie_hls_bridge_backpressure_scenario

//------------------------------------------------------------------------------
// Class : cdn_pcie_hls_bridge_backpressure_env_config
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_backpressure_env_config extends cdn_pcie_hls_bridge_env_config;
  
  //----------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_backpressure_env_config)

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_backpressure_env_config");
    super.new(name);
  endfunction : new

  //---------------------------------------------------------------------------
  // Method: configure_cxs_hal_agent_cfg
  // Common method used to configure the CXS VIP for the HAL Side Interfaces.
  //---------------------------------------------------------------------------
  virtual function void configure_cxs_hal_agent_cfg(bit is_inbound_dir = 0, bit is_pnp_cxs_vip = 0, ref cdn_hls_config passive_cfg, ref cdn_hls_config active_cfg);
    super.configure_cxs_hal_agent_cfg(.is_inbound_dir(is_inbound_dir), .is_pnp_cxs_vip(is_pnp_cxs_vip), .passive_cfg(passive_cfg), .active_cfg(active_cfg));
    
    if(is_inbound_dir == 0 && en_backpressure_ob == 1) begin
      //- CXS Passive config ---------------------------------------------------
      passive_cfg.GntAllocation    = CDN_CXS_CFG_GNT_ALLOCATION_NO_DISTRIBUTION ;
      passive_cfg.MaxCrdGntAllowed = 1                                          ;
      passive_cfg.MinCrdGnt        = 400                                        ;
      passive_cfg.MaxCrdGnt        = 500                                        ;
      
      //- CXS active config ---------------------------------------------------
      if(is_active()) begin 
        active_cfg.GntAllocation    = CDN_CXS_CFG_GNT_ALLOCATION_NO_DISTRIBUTION ;
        active_cfg.MaxCrdGntAllowed = 1                                          ;
        active_cfg.MinCrdGnt        = 400                                        ;
        active_cfg.MaxCrdGnt        = 500                                        ;
      end
    end
  endfunction : configure_cxs_hal_agent_cfg

  //---------------------------------------------------------------------------
  // Method: configure_cxs_axi_agent_cfg
  // Common method used to configure the CXS VIP for the AXI Side Interfaces.
  //---------------------------------------------------------------------------
  virtual function void configure_cxs_axi_agent_cfg(bit is_inbound_dir = 0, bit is_pnp_cxs_vip = 0, ref cdn_hls_config passive_cfg[parameters_cfg_pkg::NUM_HLS_PORTS], ref cdn_hls_config active_cfg[parameters_cfg_pkg::NUM_HLS_PORTS]);
    super.configure_cxs_axi_agent_cfg(.is_inbound_dir(is_inbound_dir), .is_pnp_cxs_vip(is_pnp_cxs_vip), .passive_cfg(passive_cfg), .active_cfg(active_cfg));

    if(is_inbound_dir == 1 && en_backpressure_ib == 1) begin
      //- CXS Passive config ---------------------------------------------------
      foreach(passive_cfg[loop_port]) begin
        passive_cfg[loop_port].GntAllocation    = CDN_CXS_CFG_GNT_ALLOCATION_NO_DISTRIBUTION ;
        passive_cfg[loop_port].MaxCrdGntAllowed = 1                                          ;
        passive_cfg[loop_port].MinCrdGnt        = 400                                        ;
        passive_cfg[loop_port].MaxCrdGnt        = 500                                        ;
      end

      //- CXS active config ---------------------------------------------------
      if(is_active()) begin 
        foreach(active_cfg[loop_port]) begin
          active_cfg[loop_port].GntAllocation    = CDN_CXS_CFG_GNT_ALLOCATION_NO_DISTRIBUTION ;
          active_cfg[loop_port].MaxCrdGntAllowed = 1                                          ;
          active_cfg[loop_port].MinCrdGnt        = 400                                        ;
          active_cfg[loop_port].MaxCrdGnt        = 500                                        ;
        end
      end
    end
  endfunction : configure_cxs_axi_agent_cfg

endclass : cdn_pcie_hls_bridge_backpressure_env_config

//------------------------------------------------------------------------------
// Class : cdn_pcie_hls_bridge_backpressure_vseq
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_backpressure_vseq extends cdn_pcie_hls_bridge_vseq;

  //----------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //----------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_backpressure_vseq)

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_backpressure_vseq");
    super.new(name);
  endfunction : new

  //----------------------------------------------------------------------------
  // Task: do_user_config_pre_traffic
  //----------------------------------------------------------------------------
  virtual task do_user_config_pre_traffic(string msg_id = "");
    string l_msg_id = {msg_id, "[do_user_config_pre_traffic]"};

    //---- Backpressures MSI interface based on the scenario knobs. ---------------
    if(m_scenario.m_backpressure_scenario inside {BACKPRESSURE_MSI, BACKPRESSURE_ALL}) begin
      fork 
        forever begin
          p_sequencer.p_env.m_axis_msi_slv_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_STREAM_REG_driveTready, 2'b11);
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(1));
          p_sequencer.p_env.m_axis_msi_slv_env.act_agent.sequencer.pAgent.regInst.writeReg(DENALI_STREAM_REG_driveTready, 2'b01);
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles($urandom_range(1000, 500)));
        end
      join_none
    end
  endtask : do_user_config_pre_traffic

endclass : cdn_pcie_hls_bridge_backpressure_vseq

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_backpressure_test
// Test to verify backpressure scenarios on OB/IB/MSI.
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_backpressure_test extends cdn_pcie_hls_bridge_base_test;

  //----------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //----------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_backpressure_test)

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_backpressure_test", uvm_component parent);
    super.new(name, parent);

    //------------
    // Overrides
    //------------
    // -- Scenario override ----------------------------
    set_type_override_by_type(cdn_pcie_hls_bridge_scenario::get_type(), cdn_pcie_hls_bridge_backpressure_scenario::get_type());
    
    // -- Environment Configuration override -----------
    set_type_override_by_type(cdn_pcie_hls_bridge_env_config::get_type(), cdn_pcie_hls_bridge_backpressure_env_config::get_type());

    // -- Vseq override --------------------------------
    set_type_override_by_type(cdn_pcie_hls_bridge_vseq::get_type(), cdn_pcie_hls_bridge_backpressure_vseq::get_type());
  endfunction : new

  //----------------------------------------------------------------------------
  // Function: end_of_elaboration
  //----------------------------------------------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase

  //---------------------------------------------------------------------------
  // Method: create_scenario
  // Overriding Base Class Method. 
  //---------------------------------------------------------------------------
  virtual function void create_scenario(string msg_id = "");
    super.create_scenario(.msg_id(msg_id));

    m_env_cfg.en_backpressure_ob = (m_scenario.m_backpressure_scenario inside {BACKPRESSURE_ALL, BACKPRESSURE_OB});
    m_env_cfg.en_backpressure_ib = (m_scenario.m_backpressure_scenario inside {BACKPRESSURE_ALL, BACKPRESSURE_IB}); 
  endfunction : create_scenario

endclass : cdn_pcie_hls_bridge_backpressure_test

`endif // CDN_PCIE_HLS_BRIDGE_BACKPRESSURE_TEST_SV
now add about these tests as resume points
