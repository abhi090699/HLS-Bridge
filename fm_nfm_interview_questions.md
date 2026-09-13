# Basic interview questions: PCIe Flit Mode (FM) vs Non-Flit Mode (NFM)

Short answers follow each question. Details and bit maps: `tlp_flit_mode_mem_cfg_ohc.md`.

---

## A. What / why

**Q1. What is NFM and FM in PCIe?**  
NFM is the classic packetized Data Link (TLP/DLLP with STP/SDP) used through Gen5. FM is the Gen6+ model: the link carries fixed-size **flits**, and TLPs are packed inside them.

**Q2. From which generation is Flit Mode required?**  
Required at **64 GT/s (PCIe 6.0)**. It can also stay in use after downtraining if both ends negotiated flit.

**Q3. Why did PCIe add Flit Mode?**  
PAM4 at 64 GT/s has a much higher raw BER. Per-TLP LCRC + TLP replay is not enough. FM uses a fixed 256B flit with **FEC + CRC** so errors are corrected or replayed at flit granularity.

**Q4. Can a Gen6 device still run NFM?**  
Yes, if it trains below 64 GT/s and does **not** negotiate flit. HLS uses `k_flit_mode_support` and `misc_flit_mode`.

**Q5. What is the FM flit size?**  
**256 bytes.**

---

## B. Link / Data Link

**Q6. How is a TLP framed on the wire in NFM vs FM?**  
NFM: STP token + TLP bytes + LCRC. FM: one or more TLPs (and idle) packed into 256B flits; no STP/SDP framing.

**Q7. Where does the DLLP live?**  
NFM: separate **SDP** packet (InitFC, UpdateFC, ACK/NAK, PM). FM: **inside the flit**.

**Q8. How does error detection and replay differ?**  
NFM: per-TLP **LCRC**, ACK/NAK on TLP sequence numbers, replay TLPs. FM: per-flit **FEC+CRC**, replay **flits**.

**Q9. Is flow control still Posted / Non-Posted / Completion credits?**  
Yes. Credit classes are still TLP-based. FM only changes how those TLPs are scheduled onto flits.

**Q10. What replaced per-TLP LCRC for integrity of the TLP itself?**  
Link integrity is flit FEC/CRC. Optional TLP **ECRC** is still possible; in FM it is a **TS trailer**, not the NFM TD+LCRC picture.

---

## C. TLP DW0

**Q11. Draw or list NFM DW0 fields.**  
Fmt, Type, T9, TC, T8, Attr[2], LN, TH, TD, EP, Attr[1:0], AT, Length.

**Q12. Draw or list FM DW0 fields.**  
Fmt, Type, TC, **OHC[4:0]**, **TS[2:0]**, Attr[2], Attr[1:0], Length.

**Q13. Where did T9/T8 go in FM?**  
Into DW1 as part of **Tag[13:0]** (Mem/IO/CFG/Cpl). Message TLPs do **not** carry a Tag in FM DW1.

**Q14. Where did TH, TD, EP, AT, LN go in FM?**  
EP → DW1. AT → Mem address DW. TD → **TS** (ECRC trailer). TH/PH → **OHC-B**. LN hint is gone; LN **messages** are also not used in FM.

**Q15. What is OHC[4:0]?**  
Presence bits: [0] OHC-A, [1] OHC-B, [2] OHC-C, [4:3] OHC-E size (00 none, 01 1DW, 10 2DW, 11 4DW).

**Q16. What is TS?**  
Trailer size: none, 1DW ECRC, or IDE MAC / MAC+PCRC sizes.

**Q17. One Type encoding that changes in FM?**  
32-bit Memory Read Type is `00000b` in NFM and **`00011b` in FM**.

---

## D. Prefixes vs OHC

**Q18. Where do PASID / TPH / IDE sit in NFM vs FM?**  
NFM: TLP **prefixes before** the header. FM: **OHC after** the header — A (PASID/BE/segments), B (TPH/AMA), C (IDE/requester segment), E (vendor E2E).

**Q19. Do any prefixes still go in front of the FM header?**  
Yes: **local / vendor-L prefixes** (and CXL PTH if PBR). End-to-end prefixes do not.

**Q20. Map OHC-A by TLP type.**  
A1 Mem (and PR+PASID), A2 IO, **A3 CFG (mandatory)**, A4 Msg, A5 Completion.

**Q21. Can CFG have OHC-E?**  
No. This VIP forces `ohc_ex_present == none` on CFG.

**Q22. How do you know an FM TLP is IDE?**  
OHC-C present and **Sub-stream ≠ `4'h7`**. NFM uses an IDE prefix DW instead.

---

## E. Mem / CFG / Cpl / Msg

**Q23. Where are First/Last DW Byte Enables in FM?**  
OHC-A1/A2/A3. If a **Memory** TLP omits OHC-A, FBE/LBE are implied **`4'hF`**.

**Q24. When must OHC-A1 be present on a Memory Request?**  
PASID, explicit BEs (not all `F`), or ATS Translation Request (NW flag is in OHC-A1).

**Q25. What happened to BCM on Completions?**  
**Removed** in FM.

**Q26. Where is Completion Status in FM?**  
**OHC-A5[2:0]**. If OHC-A is omitted: Status = **SC** and LA[1:0] = **00**.

**Q27. Split of Lower Address on an FM Completion?**  
LA[6] in DW1, LA[5:2] in DW2, LA[1:0] in OHC-A5.

**Q28. When must a completer send OHC-A5?**  
Status ≠ SC, or LA[1:0] ≠ 00, or captured segment ≠ Mem request requester segment.

**Q29. CFG completion DSV/Dest Seg?**  
**DSV=0**, Dest Seg=**00h**. Completer Segment is 00h if segment not captured, else the captured segment.

**Q30. What is special about Message DW1 in FM?**  
No Tag. Byte 6 is ITAG (ATS Inv), SSE (IDE Escort), vendor field (VDM), or reserved. Byte 7 is **Message Code**. Routing is Type[2:0].

**Q31. DSV rules on Messages?**  
DSV must be **0** unless Route by ID. Must be **1** for ATS Invalidate, Invalidate Complete, and PR Group Response.

**Q32. When is OHC-C required on Messages?**  
If the function has **captured a segment** (RSV=1), or the TLP is IDE. Mem OHC-C is optional; CFG/Cpl RSV is 0 (OHC-C mainly for IDE).

---

## F. Features that exist only (or mainly) in FM

**Q33. What is TLP segmentation?**  
8-bit Dest / Requester / Completer **segment** IDs in OHC so a fabric can route beyond 16-bit BDF. HLS `REQ_SEG_IN_TLP_IS_VALID` applies only in FM.

**Q34. What is UIO?**  
Unordered I/O: extra VC/Cpl types allowed only when flit is negotiated (`NUM_UIO_VCS`).

**Q35. MSI vs Msg TLP — catch question.**  
MSI/MSI-X are **Memory Writes**, not Message TLPs. INTx is a Msg TLP (posted).

---

## G. Quick fire (expect one-liners)

**Q36. Flit size?** 256B  
**Q37. Who has LCRC?** NFM  
**Q38. Who has OHC?** FM  
**Q39. Who has STP/SDP?** NFM  
**Q40. BCM in FM?** No  
**Q41. Implied Mem BEs if no OHC-A?** `F`/`F`  
**Q42. LN message in FM?** Not supported  
**Q43. IDE in FM?** OHC-C  
**Q44. Tag in FM Msg DW1?** No  
**Q45. OHC pack order?** A then B then C then E  

---

## H. Questions they may ask you to draw

1. NFM vs FM DW0 (side by side).  
2. FM Memory Request strip: DW0–Addr, optional OHC-A1/B/C, payload, TS.  
3. FM Completion strip and where Status / LA bits live.  
4. OHC[4:0] bit meaning.  
5. Prefix (NFM) vs OHC (FM) for PASID + IDE.
