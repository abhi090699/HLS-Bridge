module hls_bridge_qos_counter #(
   /////////////////////////////////////////////////////////////////////////////
   //                                Parameters                               //
   /////////////////////////////////////////////////////////////////////////////
   parameter  BUS_WIDTH             = 18,
   parameter  DATA_SIZE             = 13,
   parameter  NUM_IF                = 2,
   parameter  KMAX_NUM_TLPS_PER_CLK = 4,
   parameter  ASF_SUPPORT           = 2,
   localparam BUS_CHK_WIDTH         = (BUS_WIDTH +7)/8,
   localparam PREFIX_SIZE           = BUS_WIDTH-DATA_SIZE,
   localparam DTI_COUNTER_SIZE      = 3//$clog2(KMAX_NUM_TLPS_PER_CLK)
   //   localparam BIN_SIZE_EN         = NUM_IF>2 ? $clog2(NUM_IF) : 1
  )(
  /*BSF:isClock=1,clock_group="CORE",doc= Power down / Power Shut-Off Core Clock ;*/
  input                                                       core_clk,
  /*BSF:isClock=1,clock_group="CORE",doc= Power down / Power Shut-Off Core Clock ;*/
  input                                                       core_rst_n,
  //BSF:doc= Adder enable per HLS port;
  input wire  [NUM_IF-1:0]                                    enable,
  //BSF:doc= Adder clear;
  input wire                                                  clear,
  //BSF:doc= Data to add from AXI-Bridge;
  input wire  [BUS_WIDTH*NUM_IF-1:0]                          data,
  //BSF:doc= Data to add from AXI-Bridge;
  input wire  [KMAX_NUM_TLPS_PER_CLK:0]                       dti_en,
  //BSF:doc= Dadta to add from MSI module;
  output wire [BUS_WIDTH-1:0]                                 output_count,
  //------------------------------------------------------------------------------
  //BSF:doc= Generated parity for data;
  output wire [BUS_CHK_WIDTH-1:0]                              output_count_chk
);

  reg [DATA_SIZE-1:0]         data_add;
  reg [DATA_SIZE-1:0]         data_to_add [NUM_IF-1:0];
  reg [PREFIX_SIZE-1:0]       prefix;
  reg [BUS_WIDTH-1:0]         output_cout_reg;
  reg [DTI_COUNTER_SIZE-1:0]  dti_data_add;

  wire [BUS_WIDTH-1:0]        output_cout_w;
  wire [DATA_SIZE-1:0]        temp_count;
  wire                        enable_bit;

  genvar gv_x;
  `HLSB_WIDE_TO_2D (data_tab,data,gen_data_tab,NUM_IF,BUS_WIDTH)

  // write only selected data
  always @(*) begin : gate_input_data
  integer i;
    for (i=0; i<NUM_IF; i=i+1)
    data_to_add[i] = {DATA_SIZE{1'b0}};
    prefix         = {PREFIX_SIZE{1'b0}};

    for (i=0; i<NUM_IF; i=i+1) begin
      if (enable[i]) begin
        data_to_add[i] = data_tab[i][DATA_SIZE-1:0];
        prefix         = data_tab[i][BUS_WIDTH-1:DATA_SIZE];
      end
    end
  end

  // write only selected data
  always @(*) begin : gate_dti_input_data
  integer i;
    dti_data_add = {DTI_COUNTER_SIZE{1'b0}};

    for (i=0 ; i<=KMAX_NUM_TLPS_PER_CLK ; i=i+1) begin
      if (dti_en[i])
        dti_data_add = dti_data_add +1'b1;
    end
  end

  always @(*) begin : add_input_data
  integer i;
    data_add = {DATA_SIZE{1'b0}};
    for (i=0; i<NUM_IF; i=i+1)
      data_add = data_add + data_to_add[i];
  end

  assign enable_bit = |enable;
  assign temp_count = enable_bit ? output_cout_reg[DATA_SIZE-1:0] 
                                  + data_add + dti_data_add 
                                  : {DATA_SIZE{1'b0}};

  assign output_cout_w = (~clear & enable_bit) ? {prefix,temp_count} :
                         ( clear & enable_bit) ? {prefix,data_add}   :
                                                 {BUS_WIDTH{1'b0}};
  //always @(posedge core_clk or negedge core_rst_n) begin
  //  if(core_rst_n == 1'b0) begin
  //    output_cout_reg <= {BUS_WIDTH{1'b0}};
  //  end
  //  else begin
  //   if (clear & ~enable_bit)
  //     output_cout_reg <= {BUS_WIDTH{1'b0}};
  //   else if (~clear & enable_bit)
  //     output_cout_reg <= {prefix,temp_count};
  //   else if (clear & enable_bit)
  //     output_cout_reg <= {prefix,data_add};
  //  end
  //end

  always @(posedge core_clk or negedge core_rst_n) begin
    if(core_rst_n == 1'b0) begin
      output_cout_reg <= {BUS_WIDTH{1'b0}};
    end
    else begin
     if (clear | enable_bit)
      output_cout_reg <= output_cout_w;
    end
  end

  //Assign Ouputp
  assign  output_count = output_cout_reg;

 //------------------------------------------------------------------------------
 // ASF
 //------------------------------------------------------------------------------
  generate
  if (ASF_SUPPORT >1) begin : ctag_asf_gen
    //wire [7:0] data_add_temp_chk;
    //wire [7:0] temp_count_chk;
    reg [BUS_CHK_WIDTH-1:0]      output_cout_reg_chk;

    //assign data_add_temp_chk = {6'b000000,data_add[17:16]};
    //assign temp_count_chk    = {6'b000000,temp_count[17:16]};

    //always @(posedge core_clk or negedge core_rst_n) begin
    //  if(core_rst_n == 1'b0) begin
    //    output_cout_reg_chk <= {BUS_CHK_WIDTH{1'b1}};
    //  end
    //  else begin
    //   if (clear & ~enable_bit)
    //     output_cout_reg_chk  <= {BUS_CHK_WIDTH{1'b1}};
    //   else if (~clear & enable_bit)
    //     output_cout_reg_chk <= ~{^temp_count_chk,^temp_count[15:8],^temp_count[7:0]};
    //   else if (clear & enable_bit)
    //     output_cout_reg_chk <= ~{^data_add_temp_chk,^data_add[15:8],^data_add[7:0]};
    //  end
    //end
    always @(posedge core_clk or negedge core_rst_n) begin
      if(core_rst_n == 1'b0) begin
        output_cout_reg_chk <= {BUS_CHK_WIDTH{1'b1}};
      end
      else begin
       if (clear | enable_bit)
        output_cout_reg_chk <= ~{^output_cout_w[23:16],^output_cout_w[15:8],^output_cout_w[7:0]};
      end
    end
    //Assign Ouputp
    assign  output_count_chk = output_cout_reg_chk;

  end //ASF_SUPPORT
  else begin : ctag_no_asf_gen
    assign  output_count_chk = {BUS_CHK_WIDTH{1'b0}};
  end
  endgenerate

  //------------------------------------------------------------------------------
  // counter overflow assertion
  //------------------------------------------------------------------------------
 `ifdef ABV_ON
   `define AXI_ABV_ON
  `endif

  `ifdef AXI_ABV_ON
    reg [BUS_WIDTH+3:0] data_sum;
     always @(*) begin
       integer i;
       data_sum = {BUS_WIDTH+3{1'b0}};
       for (i=1 ; i<NUM_IF ;i=i+1)
         data_sum = data_sum + data_to_add[i];
     end

    property lti_c_internal_counter_ofverflow;
      @(posedge core_clk) disable iff (!core_rst_n)
      (
      ($past(!clear) |-> $past(output_cout_reg[DATA_SIZE-1:0]) <= output_cout_reg[DATA_SIZE-1:0])
      );
    endproperty

    property lti_c_internal_counter_ofverflow_in_single_cycle;
      @(posedge core_clk) disable iff (!core_rst_n)
      (|enable |-> data_sum <= {DATA_SIZE{1'b1}});
    endproperty

    a_lti_c_internal_counter_ofverflow                 : assert property (lti_c_internal_counter_ofverflow);
    a_lti_c_internal_counter_ofverflow_in_single_cycle : assert property (lti_c_internal_counter_ofverflow_in_single_cycle);
  `endif 




endmodule
