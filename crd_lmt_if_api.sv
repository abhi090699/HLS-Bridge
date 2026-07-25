`ifndef CDN_PCIE_HLS_BRIDGE_CRD_LMT_IF_API_BASE_SV
`define CDN_PCIE_HLS_BRIDGE_CRD_LMT_IF_API_BASE_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_crd_lmt_if_api_base
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_crd_lmt_if_api_base #(
  parameter string INTERFACE_NAME           = "cdn_pcie_hls_bridge_crd_lmt_if",
  parameter        KMAX_NUM_VCS             = 4,
  parameter        CRD_IN_LMT_HEADER_WIDTH  = 9,
  parameter        CRD_IN_LMT_PAYLOAD_WIDTH = 13,
  parameter        CRD_IN_LMT_CNTL_WIDTH    = 6
) extends uvm_object;

  `uvm_object_param_utils(cdn_pcie_hls_bridge_crd_lmt_if_api_base#(INTERFACE_NAME, KMAX_NUM_VCS, CRD_IN_LMT_HEADER_WIDTH, CRD_IN_LMT_PAYLOAD_WIDTH, CRD_IN_LMT_CNTL_WIDTH))

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_crd_lmt_if_api_base");
    super.new(name);
  endfunction : new

  virtual task wait_cb(int clk_cycles = 1);
    `uvm_fatal(get_type_name(), "wait_cb is not implemented")
  endtask : wait_cb

  virtual task wait_rst_act();
    `uvm_fatal(get_type_name(), "wait_rst_act is not implemented")
  endtask : wait_rst_act

  virtual task wait_rst_dis();
    `uvm_fatal(get_type_name(), "wait_rst_dis is not implemented")
  endtask : wait_rst_dis

  virtual task reset();
    `uvm_fatal(get_type_name(), "reset is not implemented")
  endtask : reset

  virtual task cover_if();
    `uvm_fatal(get_type_name(), "cover_if is not implemented")
  endtask : cover_if

  virtual task cover_link_down_if(bit link_down_on);
   `uvm_fatal(get_type_name(), "cover_link_down_if not implemented")
  endtask : cover_link_down_if
   
  //---------------
  // API definition
  //---------------
  virtual task set_crd_m_lmt_header(int unsigned vc, bit [CRD_IN_LMT_HEADER_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"set_crd_m_lmt_header is not implemented.");
  endtask : set_crd_m_lmt_header
    
  virtual task set_crd_m_lmt_payload(int unsigned vc, bit [CRD_IN_LMT_PAYLOAD_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"set_crd_m_lmt_payload is not implemented.");
  endtask : set_crd_m_lmt_payload
    
  virtual task set_crd_m_lmt_cntl(int unsigned vc, bit [CRD_IN_LMT_CNTL_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"set_crd_m_lmt_cntl is not implemented.");
  endtask : set_crd_m_lmt_cntl
  
  virtual function void get_crd_m_lmt_header(int unsigned vc, ref bit [CRD_IN_LMT_HEADER_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"get_crd_m_lmt_header is not implemented.");
  endfunction : get_crd_m_lmt_header
  
  virtual function void get_crd_m_lmt_payload(int unsigned vc, ref bit [CRD_IN_LMT_PAYLOAD_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"get_crd_m_lmt_payload is not implemented.");
  endfunction : get_crd_m_lmt_payload
    
  virtual function void get_crd_m_lmt_cntl(int unsigned vc, ref bit [CRD_IN_LMT_CNTL_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"get_crd_m_lmt_cntl is not implemented.");
  endfunction : get_crd_m_lmt_cntl

  virtual function void get_crd_s_lmt_header(int unsigned vc, ref bit [CRD_IN_LMT_HEADER_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"get_crd_s_lmt_header is not implemented.");
  endfunction : get_crd_s_lmt_header
  
  virtual function void get_crd_s_lmt_payload(int unsigned vc, ref bit [CRD_IN_LMT_PAYLOAD_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"get_crd_s_lmt_payload is not implemented.");
  endfunction : get_crd_s_lmt_payload
    
  virtual function void get_crd_s_lmt_cntl(int unsigned vc, ref bit [CRD_IN_LMT_CNTL_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"get_crd_s_lmt_cntl is not implemented.");
  endfunction : get_crd_s_lmt_cntl

  virtual function void get_crd_used_header(int unsigned vc, ref bit [CRD_IN_LMT_HEADER_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"get_crd_used_header is not implemented.");
  endfunction : get_crd_used_header
  
  virtual function void get_crd_used_payload(int unsigned vc, ref bit [CRD_IN_LMT_PAYLOAD_WIDTH - 1 : 0] value);
    `uvm_error(get_type_name(),"get_crd_used_payload is not implemented.");
  endfunction : get_crd_used_payload

endclass : cdn_pcie_hls_bridge_crd_lmt_if_api_base

`endif // CDN_PCIE_HLS_BRIDGE_CRD_LMT_IF_API_BASE_SV

`ifndef CDN_PCIE_HLS_BRIDGE_CRD_LMT_IF_SV
`define CDN_PCIE_HLS_BRIDGE_CRD_LMT_IF_SV

//------------------------------------------------------------------------------
// Interface: cdn_pcie_hls_bridge_crd_lmt_if
//------------------------------------------------------------------------------
interface cdn_pcie_hls_bridge_crd_lmt_if #(
  parameter string INTERFACE_NAME           = "cdn_pcie_hls_bridge_crd_lmt_if",
  parameter        KMAX_NUM_VCS             = 4,
  parameter        CRD_IN_LMT_HEADER_WIDTH  = 9,
  parameter        CRD_IN_LMT_PAYLOAD_WIDTH = 13,
  parameter        CRD_IN_LMT_CNTL_WIDTH    = 6
) 
(
  input                                                     clk               ,
  input                                                     rst_n             ,

  inout [(KMAX_NUM_VCS * CRD_IN_LMT_HEADER_WIDTH) - 1  : 0] crd_s_lmt_header  ,
  inout [(KMAX_NUM_VCS * CRD_IN_LMT_PAYLOAD_WIDTH) - 1 : 0] crd_s_lmt_payload ,
  inout [(KMAX_NUM_VCS * CRD_IN_LMT_CNTL_WIDTH) - 1    : 0] crd_s_lmt_cntl    ,

  inout [(KMAX_NUM_VCS * CRD_IN_LMT_HEADER_WIDTH) - 1  : 0] crd_m_lmt_header  ,
  inout [(KMAX_NUM_VCS * CRD_IN_LMT_PAYLOAD_WIDTH) - 1 : 0] crd_m_lmt_payload ,
  inout [(KMAX_NUM_VCS * CRD_IN_LMT_CNTL_WIDTH) - 1    : 0] crd_m_lmt_cntl    ,
 
  inout [(KMAX_NUM_VCS * CRD_IN_LMT_HEADER_WIDTH) - 1  : 0] crd_used_header   ,
  inout [(KMAX_NUM_VCS * CRD_IN_LMT_PAYLOAD_WIDTH) - 1 : 0] crd_used_payload
);

  //----------------------------------------------------------------------------
  // Package imports
  //----------------------------------------------------------------------------
  import uvm_pkg::*;
  import cdn_pcie_hls_bridge_dut_if_pkg::*;
  `include "uvm_macros.svh"

  //----------------------------------------------------------------------------
  // Clocking blocks
  //----------------------------------------------------------------------------
  clocking cb @(posedge clk);
    input  crd_s_lmt_header ;
    input  crd_s_lmt_payload;
    input  crd_s_lmt_cntl   ;
    output crd_m_lmt_header ;
    output crd_m_lmt_payload;
    output crd_m_lmt_cntl   ;
    input  crd_used_header  ;
    input  crd_used_payload ;
  endclocking : cb

  clocking cb_mon @(posedge clk);
    input crd_s_lmt_header ;
    input crd_s_lmt_payload;
    input crd_s_lmt_cntl   ;
    input crd_m_lmt_header ;
    input crd_m_lmt_payload;
    input crd_m_lmt_cntl   ;
    input crd_used_header  ;
    input crd_used_payload ;
  endclocking : cb_mon

  //------------------------
  // Coverage implementation
  //------------------------
  covergroup cg_crd_lmt_header_range(string cg_name) with function sample(bit [CRD_IN_LMT_HEADER_WIDTH-1 : 0] crd_lmt_header);
    
    option.per_instance = 1       ;
    option.name         = cg_name ;

    cp_HEADER_LIMIT_RANGE : coverpoint crd_lmt_header iff (rst_n == 1) {
      bins LOW    = {[0:100]}  ;
      bins MEDIUM = {[101:400]};
      bins HIGH   = {[401:511]};
    }

  endgroup : cg_crd_lmt_header_range

  covergroup cg_crd_lmt_payload_range(string cg_name) with function sample(bit [CRD_IN_LMT_PAYLOAD_WIDTH-1 : 0] crd_lmt_payload);
    
    option.per_instance = 1       ;
    option.name         = cg_name ;
  
    cp_PAYLOAD_LIMIT_RANGE : coverpoint crd_lmt_payload iff (rst_n == 1) {
      bins LOW    = {[0:2000]}   ;
      bins MEDIUM = {[2001:7000]};
      bins HIGH   = {[7001:8191]};
    }
  
  endgroup : cg_crd_lmt_payload_range
  
  covergroup cg_crd_lmt_cntl(string cg_name) with function sample(bit [CRD_IN_LMT_CNTL_WIDTH-1 : 0] crd_lmt_cntl);
    
    option.per_instance = 1       ;
    option.name         = cg_name ;
    
    cp_HEADER_CREDITS_INFINITE : coverpoint crd_lmt_cntl[0] iff (rst_n == 1) {
      bins INFINITE     = {1};
      bins NOT_INFINITE = {0};
    }
    
    cp_PAYLOAD_CREDITS_INFINITE : coverpoint crd_lmt_cntl[1] iff (rst_n == 1) {
      bins INFINITE     = {1};
      bins NOT_INFINITE = {0};
    }

    cp_HEADER_CREDITS_SCALE : coverpoint crd_lmt_cntl[3:2] iff (rst_n == 1) {
      bins SCALE[] = {[0:3]};
    }
    
    cp_PAYLOAD_CREDITS_SCALE : coverpoint crd_lmt_cntl[5:4] iff (rst_n == 1) {
      bins SCALE[] = {[0:3]};
    }

  endgroup : cg_crd_lmt_cntl

    covergroup cg_crd_lmt_linkdown(string cg_name) with function sample(bit [CRD_IN_LMT_CNTL_WIDTH-1 : 0]    crd_lmt_cntl, int in);
      
      option.per_instance = 1       ;
      option.name         = cg_name ;

      cp_crd_lmt_cntl : coverpoint crd_lmt_cntl {
	 bins CRD_LMT_INFINITE = {3};
      }
       
      cp_link_down : coverpoint in {
	 bins LINK_DOWN_ON = {1};
      }

      crd_lmt_cntl_ld_cross : cross cp_crd_lmt_cntl, cp_link_down;
       
    endgroup
  //----------------------------------------------------------------------------
  // Implementation of interface class within the scope of the SV if
  //----------------------------------------------------------------------------
  class cdn_pcie_hls_bridge_crd_lmt_if_api #(
    parameter string INTERFACE_NAME           = "cdn_pcie_hls_bridge_crd_lmt_if",
    parameter        KMAX_NUM_VCS             = 4,
    parameter        CRD_IN_LMT_HEADER_WIDTH  = 9,
    parameter        CRD_IN_LMT_PAYLOAD_WIDTH = 13,
    parameter        CRD_IN_LMT_CNTL_WIDTH    = 6
  ) extends cdn_pcie_hls_bridge_crd_lmt_if_api_base #(.INTERFACE_NAME          ( INTERFACE_NAME           ),
                                                      .KMAX_NUM_VCS            ( KMAX_NUM_VCS             ),
                                                      .CRD_IN_LMT_HEADER_WIDTH ( CRD_IN_LMT_HEADER_WIDTH  ),
                                                      .CRD_IN_LMT_PAYLOAD_WIDTH( CRD_IN_LMT_PAYLOAD_WIDTH ),
                                                      .CRD_IN_LMT_CNTL_WIDTH   ( CRD_IN_LMT_CNTL_WIDTH    ));
    
    cg_crd_lmt_header_range  cg_crd_m_lmt_header_range_h [KMAX_NUM_VCS];
    cg_crd_lmt_header_range  cg_crd_s_lmt_header_range_h [KMAX_NUM_VCS];
    cg_crd_lmt_payload_range cg_crd_m_lmt_payload_range_h[KMAX_NUM_VCS];
    cg_crd_lmt_payload_range cg_crd_s_lmt_payload_range_h[KMAX_NUM_VCS];
    cg_crd_lmt_cntl          cg_crd_m_lmt_cntl_h         [KMAX_NUM_VCS];
    cg_crd_lmt_cntl          cg_crd_s_lmt_cntl_h         [KMAX_NUM_VCS];
    cg_crd_lmt_linkdown      cg_crd_m_lmt_linkdown_h     [KMAX_NUM_VCS];
    cg_crd_lmt_linkdown      cg_crd_s_lmt_linkdown_h     [KMAX_NUM_VCS];
    //----------------------------------------------------------------------------
    // UVM automation macros
    //----------------------------------------------------------------------------
    `uvm_object_param_utils(cdn_pcie_hls_bridge_crd_lmt_if_api#(INTERFACE_NAME, KMAX_NUM_VCS, CRD_IN_LMT_HEADER_WIDTH, CRD_IN_LMT_PAYLOAD_WIDTH, CRD_IN_LMT_CNTL_WIDTH))

    //--------------------------------------------------------------------------
    // Function: new
    // Class constructor.
    //--------------------------------------------------------------------------
    function new(string name="cdn_pcie_hls_bridge_crd_lmt_if_api");
      super.new(name);
      foreach(cg_crd_m_lmt_header_range_h[loop_vc]) begin
        cg_crd_m_lmt_header_range_h[loop_vc]  = new(.cg_name($sformatf("cg_%0s_crd_m_lmt_header_range_%0d_h" , INTERFACE_NAME, loop_vc)));
        cg_crd_m_lmt_payload_range_h[loop_vc] = new(.cg_name($sformatf("cg_%0s_crd_m_lmt_payload_range_%0d_h", INTERFACE_NAME, loop_vc)));
        cg_crd_m_lmt_cntl_h[loop_vc]          = new(.cg_name($sformatf("cg_%0s_crd_m_lmt_cntl_%0d_h"         , INTERFACE_NAME, loop_vc)));
	cg_crd_m_lmt_linkdown_h[loop_vc]      = new(.cg_name($sformatf("cg_%0s_crd_m_lmt_linkdown_%0d_h"     , INTERFACE_NAME, loop_vc)));
      end
      foreach(cg_crd_s_lmt_header_range_h[loop_vc]) begin
        cg_crd_s_lmt_header_range_h[loop_vc]  = new(.cg_name($sformatf("cg_%0s_crd_s_lmt_header_range_%0d_h" , INTERFACE_NAME, loop_vc)));
        cg_crd_s_lmt_payload_range_h[loop_vc] = new(.cg_name($sformatf("cg_%0s_crd_s_lmt_payload_range_%0d_h", INTERFACE_NAME, loop_vc)));
        cg_crd_s_lmt_cntl_h[loop_vc]          = new(.cg_name($sformatf("cg_%0s_crd_s_lmt_cntl_%0d_h"         , INTERFACE_NAME, loop_vc)));
	cg_crd_s_lmt_linkdown_h[loop_vc]      = new(.cg_name($sformatf("cg_%0s_crd_s_lmt_linkdown_%0d_h"     , INTERFACE_NAME, loop_vc)));
      end
    endfunction : new
    
    //-------------------------------------------------------------------------
    // Method: reset
    //-------------------------------------------------------------------------
    task reset();
      cb.crd_m_lmt_header  <= 'd0;
      cb.crd_m_lmt_payload <= 'd0;
      cb.crd_m_lmt_cntl    <= 'd0;
    endtask : reset
    
    //-------------------------------------------------------------------------
    // Method: wait_cb
    //-------------------------------------------------------------------------
    task wait_cb(int clk_cycles = 1);
      repeat(clk_cycles) begin
        @(cb_mon);
      end
    endtask : wait_cb

    //-------------------------------------------------------------------------
    // Method: wait_rst_act
    //-------------------------------------------------------------------------
    task wait_rst_act();
      wait (rst_n==0);
    endtask : wait_rst_act

    //-------------------------------------------------------------------------
    // Method: wait_rst_dis
    //-------------------------------------------------------------------------
    task wait_rst_dis();
      wait (rst_n==1);
    endtask : wait_rst_dis
    
    //-------------------------------------------------------------------------
    // Method: cover_if
    //-------------------------------------------------------------------------
    virtual task cover_if();
      forever begin
        @(posedge rst_n or
          cb_mon.crd_s_lmt_header or
          cb_mon.crd_s_lmt_payload or
          cb_mon.crd_s_lmt_cntl or
          cb_mon.crd_m_lmt_header or
          cb_mon.crd_m_lmt_payload or
          cb_mon.crd_m_lmt_cntl
         );
        foreach(cg_crd_m_lmt_header_range_h[loop_vc]) begin
          cg_crd_m_lmt_header_range_h[loop_vc].sample(cb_mon.crd_m_lmt_header[(loop_vc * CRD_IN_LMT_HEADER_WIDTH) +: CRD_IN_LMT_HEADER_WIDTH]);
          cg_crd_m_lmt_payload_range_h[loop_vc].sample(cb_mon.crd_m_lmt_payload[(loop_vc * CRD_IN_LMT_PAYLOAD_WIDTH) +: CRD_IN_LMT_PAYLOAD_WIDTH]);
          cg_crd_m_lmt_cntl_h[loop_vc].sample(cb_mon.crd_m_lmt_cntl[(loop_vc * CRD_IN_LMT_CNTL_WIDTH) +: CRD_IN_LMT_CNTL_WIDTH]);
        end
        foreach(cg_crd_s_lmt_header_range_h[loop_vc]) begin
          cg_crd_s_lmt_header_range_h[loop_vc].sample(cb_mon.crd_s_lmt_header[(loop_vc * CRD_IN_LMT_HEADER_WIDTH) +: CRD_IN_LMT_HEADER_WIDTH]);
          cg_crd_s_lmt_payload_range_h[loop_vc].sample(cb_mon.crd_s_lmt_payload[(loop_vc * CRD_IN_LMT_PAYLOAD_WIDTH) +: CRD_IN_LMT_PAYLOAD_WIDTH]);
          cg_crd_s_lmt_cntl_h[loop_vc].sample(cb_mon.crd_s_lmt_cntl[(loop_vc * CRD_IN_LMT_CNTL_WIDTH) +: CRD_IN_LMT_CNTL_WIDTH]);
        end
      end

    endtask : cover_if

     virtual task cover_link_down_if(bit link_down_on);
        @(posedge rst_n or
          cb_mon.crd_s_lmt_header or
          cb_mon.crd_s_lmt_payload or
          cb_mon.crd_s_lmt_cntl or
          cb_mon.crd_m_lmt_header or
          cb_mon.crd_m_lmt_payload or
          cb_mon.crd_m_lmt_cntl
         );
	  foreach(cg_crd_m_lmt_linkdown_h[loop_vc]) begin 
	     cg_crd_m_lmt_linkdown_h[loop_vc].sample(cb_mon.crd_m_lmt_cntl[(loop_vc * CRD_IN_LMT_CNTL_WIDTH) +: CRD_IN_LMT_CNTL_WIDTH], link_down_on);	   
	  end
	  foreach(cg_crd_s_lmt_linkdown_h[loop_vc]) begin 
	     cg_crd_s_lmt_linkdown_h[loop_vc].sample(cb_mon.crd_s_lmt_cntl[(loop_vc * CRD_IN_LMT_CNTL_WIDTH) +: CRD_IN_LMT_CNTL_WIDTH], link_down_on);	   
	  end
     endtask : cover_link_down_if
     
    //-------------------
    // API implementation
    //-------------------
    task set_crd_m_lmt_header(int unsigned vc, bit [CRD_IN_LMT_HEADER_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      cb.crd_m_lmt_header[(vc * CRD_IN_LMT_HEADER_WIDTH) +: CRD_IN_LMT_HEADER_WIDTH] <= value;
    endtask : set_crd_m_lmt_header
    

    task set_crd_m_lmt_payload(int unsigned vc, bit [CRD_IN_LMT_PAYLOAD_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      cb.crd_m_lmt_payload[(vc * CRD_IN_LMT_PAYLOAD_WIDTH) +: CRD_IN_LMT_PAYLOAD_WIDTH] <= value;
    endtask : set_crd_m_lmt_payload


    task set_crd_m_lmt_cntl(int unsigned vc, bit [CRD_IN_LMT_CNTL_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      cb.crd_m_lmt_cntl[(vc * CRD_IN_LMT_CNTL_WIDTH) +: CRD_IN_LMT_CNTL_WIDTH] <= value;
    endtask : set_crd_m_lmt_cntl


    function void get_crd_s_lmt_header(int unsigned vc, ref bit [CRD_IN_LMT_HEADER_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      value = cb_mon.crd_s_lmt_header[(vc * CRD_IN_LMT_HEADER_WIDTH) +: CRD_IN_LMT_HEADER_WIDTH];
    endfunction : get_crd_s_lmt_header
    

    function void get_crd_s_lmt_payload(int unsigned vc, ref bit [CRD_IN_LMT_PAYLOAD_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      value = cb_mon.crd_s_lmt_payload[(vc * CRD_IN_LMT_PAYLOAD_WIDTH) +: CRD_IN_LMT_PAYLOAD_WIDTH];
    endfunction : get_crd_s_lmt_payload


    function void get_crd_s_lmt_cntl(int unsigned vc, ref bit [CRD_IN_LMT_CNTL_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      value = cb_mon.crd_s_lmt_cntl[(vc * CRD_IN_LMT_CNTL_WIDTH) +: CRD_IN_LMT_CNTL_WIDTH];
    endfunction : get_crd_s_lmt_cntl


    function void get_crd_m_lmt_header(int unsigned vc, ref bit [CRD_IN_LMT_HEADER_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      value = cb_mon.crd_m_lmt_header[(vc * CRD_IN_LMT_HEADER_WIDTH) +: CRD_IN_LMT_HEADER_WIDTH];
    endfunction : get_crd_m_lmt_header
    

    function void get_crd_m_lmt_payload(int unsigned vc, ref bit [CRD_IN_LMT_PAYLOAD_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      value = cb_mon.crd_m_lmt_payload[(vc * CRD_IN_LMT_PAYLOAD_WIDTH) +: CRD_IN_LMT_PAYLOAD_WIDTH];
    endfunction : get_crd_m_lmt_payload


    function void get_crd_m_lmt_cntl(int unsigned vc, ref bit [CRD_IN_LMT_CNTL_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      value = cb_mon.crd_m_lmt_cntl[(vc * CRD_IN_LMT_CNTL_WIDTH) +: CRD_IN_LMT_CNTL_WIDTH];
    endfunction : get_crd_m_lmt_cntl

     
    function void get_crd_used_header(int unsigned vc, ref bit [CRD_IN_LMT_HEADER_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
          `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end

      value = cb_mon.crd_used_header[(vc * CRD_IN_LMT_HEADER_WIDTH) +: CRD_IN_LMT_HEADER_WIDTH];
    endfunction : get_crd_used_header


     function void get_crd_used_payload(int unsigned vc, ref bit [CRD_IN_LMT_PAYLOAD_WIDTH - 1 : 0] value);
      if(vc > (KMAX_NUM_VCS - 1)) begin
        `uvm_error(get_type_name(), $sformatf("Provided VC value: %0d can't be greater than the KMAX_NUM_VCS: %0d", vc, KMAX_NUM_VCS));
      end
      
      value = cb_mon.crd_used_payload[(vc * CRD_IN_LMT_PAYLOAD_WIDTH) +: CRD_IN_LMT_PAYLOAD_WIDTH];
     endfunction : get_crd_used_payload
     
  endclass : cdn_pcie_hls_bridge_crd_lmt_if_api

  // Instance of API class
  cdn_pcie_hls_bridge_crd_lmt_if_api #(.INTERFACE_NAME           ( INTERFACE_NAME           ),
                                       .KMAX_NUM_VCS             ( KMAX_NUM_VCS             ),
                                       .CRD_IN_LMT_HEADER_WIDTH  ( CRD_IN_LMT_HEADER_WIDTH  ),
                                       .CRD_IN_LMT_PAYLOAD_WIDTH ( CRD_IN_LMT_PAYLOAD_WIDTH ),
                                       .CRD_IN_LMT_CNTL_WIDTH    ( CRD_IN_LMT_CNTL_WIDTH    )) api = new();
   
endinterface : cdn_pcie_hls_bridge_crd_lmt_if

`endif // CDN_PCIE_HLS_BRIDGE_CRD_LMT_IF_SV
