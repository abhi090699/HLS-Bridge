//----------------------------------------------------------------------------
// Drop-in 4DW occupancy predictor for FIFO_CRD_DW / lbb_credit_counter.
// Use from cdn_pcie_hls_bridge_monitor (expected) AND
// cdn_pcie_hls_bridge_fifo_crd_dw_seq (master stimulus) so both match DUT.
//
// Bug this replaces:
//   l_hdr_dw = (tlp.m_hdr_fmt[1]) ? 4 : 3;          // WRONG: [1] is "with data"
//   l_pay_dw = (tlp.m_tlp_length == 0) ? 1024 : ...; // WRONG for no-data NP
//   // plus zeroing payload when fmt[1]==0
//
// Log: FIFO_CRD_DW_MIDTEST_ERR port=0 NP observed_4dw=0x4 > expected_4dw=0x3
//   EXP  NP port0: hdr=4 pay=0 -> 1,  then hdr=3 pay=2 -> 2,  total 3
//   SEQ  NP port0: hdr=3 pay=2 -> 2,  then hdr=4 pay=2 -> 2,  total 4
//   DUT  NP port0: count=2 + count=2 = 4
// First NP was MRd_64 (4DW header, Length=2, no data on the wire). DUT adds Length.
//----------------------------------------------------------------------------
function automatic int unsigned calc_lbb_credit_4dw_cnt(cdn_hpa_pcie_tlp tlp_pkt);
  int unsigned hdr_dw;
  int unsigned pay_dw;
  hdr_dw = tlp_pkt.get_header_size() / 4;
  if (tlp_pkt.m_tlp_length == 0)
    pay_dw = tlp_pkt.m_hdr_fmt[1] ? 1024 : 0;
  else
    pay_dw = int'(tlp_pkt.m_tlp_length);
  return (hdr_dw + pay_dw + 3) / 4;
endfunction
