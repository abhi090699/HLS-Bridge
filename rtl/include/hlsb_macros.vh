// Minimal macro shims for open-source RTL lint/simulation.
// The production Cadence flow provides the canonical definitions.

`ifndef HLSB_MACROS_VH
`define HLSB_MACROS_VH

// Flatten array[dim0][dim1-1:0] -> wide bus (use inside an existing generate block).
`define HLSB_2D_TO_WIDE(wide_name, array_name, gen_label, dim0, dim1) \
  wire [dim0*dim1-1:0] wide_name; \
  for (gen_label = 0; gen_label < dim0; gen_label = gen_label + 1) begin \
    assign wide_name[gen_label*dim1 +: dim1] = array_name[gen_label]; \
  end

// Unpack wide bus -> array[dim0][dim1-1:0] (standalone at module scope).
`define HLSB_WIDE_TO_2D(array_name, wide_name, gen_label, dim0, dim1) \
  wire [dim1-1:0] array_name [dim0-1:0]; \
  generate \
    genvar gen_label; \
    for (gen_label = 0; gen_label < dim0; gen_label = gen_label + 1) begin \
      assign array_name[gen_label] = wide_name[gen_label*dim1 +: dim1]; \
    end \
  endgenerate

// Simplified HLS control unpack (use inside an existing generate block).
`define HLSB_HLS_UNPACK_CNTL( \
    cntl_bus, sop, strptr, eop, enderror, endptr, metadata, \
    num_tlps, max_tlps, strptr_wd, endptr_wd, metadata_wd, pkt_cntl_wd, gen_label) \
  for (gen_label = 0; gen_label < num_tlps; gen_label = gen_label + 1) begin \
    localparam integer HLSB_SLOT_WD = 3 + strptr_wd + endptr_wd + metadata_wd; \
    localparam integer HLSB_SLOT_BASE = gen_label * HLSB_SLOT_WD; \
    assign sop[gen_label] = cntl_bus[HLSB_SLOT_BASE]; \
    assign strptr[gen_label] = cntl_bus[HLSB_SLOT_BASE + 1 +: strptr_wd]; \
    assign eop[gen_label] = cntl_bus[HLSB_SLOT_BASE + 1 + strptr_wd]; \
    assign enderror[gen_label] = cntl_bus[HLSB_SLOT_BASE + 2 + strptr_wd]; \
    assign endptr[gen_label] = cntl_bus[HLSB_SLOT_BASE + 3 + strptr_wd +: endptr_wd]; \
    assign metadata[gen_label] = cntl_bus[HLSB_SLOT_BASE + 3 + strptr_wd + endptr_wd +: metadata_wd]; \
  end

`endif
