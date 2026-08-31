# DTI ATS Inbound and Outbound Flow

Maps PCI Express Base Specification Rev 5.0 Chapter 10 (Address Translation Services) onto the HLS Bridge DTI (`dti_hls_wrapper`) when `KMAX_DTI_SUPPORT = 1`.

In this platform the Device ATC sits on the PCIe link. The Translation Agent (TA) and ATPT live in the SMMU / TCU, reached over AXI-Stream DTI (`dti_dn` / `dti_up`). The HLS Bridge DTI block is the ATS endpoint toward the TA: it converts ATS TLPs on HLS into DTI transactions and back.

Direction convention (HLS Bridge):

| Term | Meaning |
| --- | --- |
| Inbound (IB) | PCIe Core HAL → HLS Bridge → DTI → SMMU (`dti_dn`) |
| Outbound (OB) | SMMU (`dti_up`) → DTI → HLS Bridge → PCIe Core HAL |

DTI uses four HLS channels (there is no IB completion DTI and no OB non-posted DTI):

| HLS channel | RTL nets | DTI wrapper ports | TLP class |
| --- | --- | --- | --- |
| IB Posted | `hls_ib_posted_dti_*` | `hls2rx_posted_*` | Posted messages from the Device |
| IB Non-Posted | `hls_ib_nonposted_dti_*` | `hls2rx_nonposted_*` | Translation Requests |
| OB Posted | `hls_ob_posted_dti_*` | `hls2tx_posted_*` | Posted messages from the TA |
| OB Completion | `hls_ob_compl_dti_*` | `hls2tx_compl_*` | Translation Completions |

Tokens: `k_dti_tok_trans_min1` (outstanding Translation Requests) and `k_dti_tok_inv_min1` (outstanding Invalidates; ATS ITag pool is 0–31). `pri_supported` (`dti_pri_supported` / `hls_ib_posted_dti_pri_supported`) must be 1 for Page Requests to be routed to DTI; if 0 they are routed to AXI.

```
                    PCIe Device (ATC)
                           |
                      PCIe Core HAL
           IB P/NP/C                    OB P/NP/C
                           |
                 +---------v----------+
                 |     hls_bridge     |
                 |  ib_p / ib_np      |
                 |  ob_p / ob_c      |
                 |         |          |
                 |    dti_hls_wrapper |
                 +---------+----------+
                           |
                 dti_dn (M)     dti_up (S)
                           |
                    SMMU / TCU (TA, ATPT)
```

---

## 1. ATS TLP to DTI channel map

AT field (Memory Requests only; reserved on other TLPs):

| AT[1:0] | Mnemonic | Role |
| --- | --- | --- |
| `00b` | Untranslated | TA may treat as virtual or physical |
| `01b` | Translation Request | Memory Read only; UR if used on a Memory Write |
| `10b` | Translated | ATC already translated; TA may skip translate or UR |
| `11b` | Reserved | UR |

| ATS protocol | Spec TLP | P/NP/C | HLS DTI path | AXI-Stream |
| --- | --- | --- | --- | --- |
| Translation Request | MRd, AT=`01b`, Length even DWs, NW in bit 0 of last DW | NP | **IB NP** | `dti_dn` |
| Translation Completion (success) | CplD, Status Success, 8B entries | C | **OB C** | `dti_up` |
| Translation Completion (fail) | Cpl, UR/CA (no data) | C | **OB C** | `dti_up` |
| Invalidate Request | MsgD, Msg Code `0000 0001b`, 64-bit range, ITag 0–31 | P | **OB P** | `dti_up` |
| Invalidate Completion | Msg, Msg Code `0000 0010b`, ITag Vector, CC | P | **IB P** | `dti_dn` |
| Page Request | Msg to RC, Msg Code `0000 0100b`, TC=0 | P | **IB P** | `dti_dn` |
| Stop Marker | Page Request with L=1, W=0, R=0, PASID prefix | P | **IB P** | `dti_dn` |
| PRG Response | Msg by ID, Msg Code `0000 0101b`, TC=0 | P | **OB P** | `dti_up` |
| Translated MRd/MWr | AT=`10b` | P or NP | AXI (not DTI ATS) | — |
| Untranslated DMA | AT=`00b` | P or NP | AXI / LTI | — |

PASID TLP Prefix (20-bit PASID, unused MSBs 0) is permitted on: untranslated Memory Requests, Translation Requests, Page Requests, Invalidate Requests, PRG Responses. Without PASID the untranslated address is RID-only; with PASID it is RID+PASID (typically GVA vs GPA).

---

## 2. Inbound DTI flow (Device ATC → TA)

IB packets enter `hls_ib_posted_hal` / `hls_ib_nonposted_hal`. `cdns_hls_bridge_ib_p` / `ib_np` decode the TLP and route ATS traffic with dest DTI (`ROUTE_TO_DTI`). DTI consumes HLS, tracks translation / invalidate tokens, and emits DTI frames on `dti_dn`.

### 2.1 Translation Request (IB NP)

Device decides an ATC fill is useful (hot buffers, queues, frame buffers). It issues a Translation Request that uses the same routing and ordering as a Memory Read. Multiple requests may be outstanding; each TC is its own ordering domain and the Completion must use the same TC.

TA steps: (1) Function is ATS-enabled, (2) access rights, (3) whether a translation can be given. Page size is a power of two, naturally aligned, minimum 4096 B (STU). TA may return fewer translations than requested, never more. Length is even DWs; each translation is 8 bytes; implied range is `2^(STU+12) * (Length/2)` bytes. Bits 11:0 of the untranslated address are implied 0. NW Set means read-only; TA may ignore NW but if it returns R-only the Function must not write with that translation. NW Clear permits the TA to mark the page dirty.

```
Device ATC          HAL IB NP         hls ib_np          DTI              SMMU TA
    |                  |                 |                |                  |
    |  MRd AT=01 NW    |                 |                |                  |
    |----------------->|  HLS IB NP     |                |                  |
    |                  |---------------->|  hls2rx_np     |                  |
    |                  |                 |--------------->|  dti_dn XLAT    |
    |                  |                 |                |----------------->|
    |                  |                 |                |   consume trans tok |
```

Must not depend on Translation Completions ordering vs other Requests. RO may be Set on the Request and then on the Completion. Completions that overlap a later Invalidate of the same range are stale and must be discarded (see §4).

### 2.2 Page Request (IB P, PRI)

PRI is independent of other ATS features; a Function may implement ATS without PRI, but PRI requires ATS. Page Request Messages use TC 0 (other TC is Malformed at RC/endpoint). One credit per page request, not per PRG. Allocation is static while the interface is enabled (`Outstanding Page Request Allocation`, capacity in Capacity register). R/W/L and 9-bit PRG Index identify the group; Last (L) Set ends the PRG. Host does not respond until the last request of the PRG (except Response Failure). W Set permits dirty; Function should not set W without explicit write permission.

If `pri_supported` is 0, IB Posted decode routes Page Requests to AXI, not DTI.

Stop Marker (optional PASID stop): L=1, W=0, R=0, PASID prefix, Marker Type `00000b`, TC=0, RO Clear. No response, does not consume Page Request allocation. After a Stop Marker, later Page Requests with that PASID are a new incarnation.

```
Device PRI           HAL IB P          hls ib_p           DTI              SMMU TA
    |                  |                 |                |                  |
    |  PR Msg TC=0     |                 |                |                  |
    |  PRG, R/W/L      |---------------->|  hls2rx_p      |                  |
    |                  |                 |--------------->|  dti_dn PRI     |
    |                  |                 |                |----------------->|
```

### 2.3 Invalidate Completion (IB P)

Sent after the Function has: (1) stopped using stale translations for new requests, (2) retired or tagged-discard outstanding translated Reads / Translation Requests in the range, (3) pushed posted writes that used the stale translated address so the Inv Cpl arrives at the TA after those writes. One Inv Cpl per TC that may have referenced the range; CC is the number of copies (CC=0 means 8). ITag Vector bit *n* corresponds to ITag *n*. Coalesce only if same TC, same CC, and identical RID/CC/ITag Vector on all fragments.

Must accept Inv Req and send Inv Cpl even if ATS Enable is Clear and even if Bus Master Enable is Clear. Must not make Inv Req acceptance depend on transmitting Inv Cpl (both posted). Queue depth advertised in ATS Capability Invalidate Queue Depth (`00000b` = 32).

```
Device ATC          HAL IB P          hls ib_p           DTI              SMMU TA
    |                  |                 |                |                  |
    |  Inv Cpl CC,ITAGV|                 |                |                  |
    |----------------->|--------------->|--------------->|  dti_dn SYNC/INVACK
    |                  |                 |                |----------------->|
    |                  |                 |                |   release ITag   |
```

---

## 3. Outbound DTI flow (TA → Device ATC)

SMMU / TCU drives `dti_up`. DTI converts to HLS OB Posted or OB Completion, then HAL sends the TLP toward the Device. Completions use the Translation Request TC. Inv Req / PRG Response may use any TC (Inv Cpl may use a different TC than the Inv Req to push posted writes).

### 3.1 Translation Completion (OB C)

At least one Completion per Translation Request (1:1 even on failure). Success may be one or two CplDs. RC may pipeline Completions in any order vs Requests. Same TC as the Request. Success payload is 8-byte entries: Translated Address[63:12], S, N, Global, Priv, Exe, U, R, W.

| R,W | Meaning | Cache? |
| --- | --- | --- |
| `00b` | Invalid / hole; address undefined | Must not cache |
| `01b` | Write (and ZLR) only | Yes |
| `10b` | Read (incl. ZLR) only | Yes |
| `11b` | Read and Write | Yes |

U Set: range is untranslated-access only; do not use Translated Address with AT=`10b`. Global Set: cache in all PASIDs (only if Request had PASID; Function that uses Global must set Global Invalidate Supported). If S is Set, low-order translated-address bits encode size (4K / 8K / 16K / …). Size smaller than programmed STU is treated as UR. No-data Completions: UR disables ATC until re-enabled; CA is a TA error (AER); reserved status treated as UR; CRS is Malformed.

```
SMMU TA             DTI               hls ob_c            HAL OB C          Device ATC
    |                 |                 |                  |                 |
    |  dti_up XLAT Cpl |                 |                  |                 |
    |----------------->|  hls2tx_c     |                  |                 |
    |  release trans tok|--------------->|----------------->|  CplD / Cpl    |
    |                 |                 |                  |---------------->|
    |                 |                 |                  |   fill ATC or   |
    |                 |                 |                  |   note miss     |
```

### 3.2 Invalidate Request (OB P)

When ATPT changes a mapping that might be in an ATC, TA sends Inv Req: untranslated range (S encoding same as Translation Size), TC, ITag unique until Completions or vendor timeout. Range is naturally aligned, ≥ STU×4K. ATC may UR or round up if range < STU. Global Invalidate (only with PASID prefix): if Function supports it, Set invalidates Global and non-Global mappings in the range for all PASIDs; Clear invalidates only non-Global mappings for that PASID. Inv Req without PASID invalidates non-PASID mappings in the range **and** all PASID mappings at all addresses.

TB: TCU sequence `cdn_pcie_dti_ats_inv_req_seq` injects Inv Req; DUT presents it on HLS OB Posted; `cdn_pcie_hls_bridge_inv_cpl_seq` returns Inv Cpl on IB Posted.

```
SMMU TA             DTI               hls ob_p            HAL OB P          Device ATC
    |                 |                 |                  |                 |
    |  dti_up INV      |                 |                  |                 |
    |----------------->|  hls2tx_p     |                  |  MsgD Inv Req   |
    |  occupy ITag     |--------------->|----------------->|---------------->|
    |                 |                 |                  |   drop ATC hit  |
    |                 |                 |                  |   drain reads  |
```

### 3.3 PRG Response (OB P)

One PRG Response per PRG (not per page). Codes: `0000b` Success, `0001b` Invalid Request, `1111b` Response Failure (disables PRI until reset; Function ignores later PRG Responses), unused codes treated as Response Failure. Unexpected PRG Index sets UPRGI and is handled like an unexpected completion. If PRG Response PASID Required is Set, the Response carries the Page Request PASID (Exe/Priv reserved on the prefix). Function must sink consecutive Responses without depending on other TLPs.

```
SMMU TA             DTI               hls ob_p            HAL OB P          Device PRI
    |                 |                 |                  |                 |
    |  dti_up PRG RSP  |                 |                  |                 |
    |----------------->|--------------->|----------------->|  Msg PRG RSP   |
    |                 |                 |                  |---------------->|
    |                 |                 |                  |   then ATS XLAT|
```

---

## 4. Invalidate vs Translation Request overlap (IB NP + OB P)

Inv Req and Translation Completions are unordered across TCs. ATC must snoop outstanding Translation Requests against every Inv Req. For a request of N STUs (`N = Length/2`), snoop from the STU-aligned start through N STUs. On overlap, tag the Translation Request invalid and discard its Completion before sending Inv Cpl. If the Completion arrives before Inv Cpl is sent, the Function may use the translation only if Invalidate Completion Semantics are still met.

Implicit invalidate (no Inv Cpl): Conventional Reset, FLR, ATS Enable 0→1. Stopping a PASID invalidates non-Global mappings for that PASID. Software must not change PASID enable bits while ATS Enable is Set.

---

## 5. Combined IB + OB protocol sequences

### 5.1 Translation fill then translated DMA

```
Device ATC                    HLS Bridge DTI                 SMMU TA
    |                              |                              |
    |  IB NP: Trans Req AT=01     |                              |
    |----------------------------->|----------------------------->|
    |                              |                              |
    |  OB C: CplD R/W, PA, S, N    |                              |
    |<-----------------------------|<-----------------------------|
    |  ATC fill (E=1)             |                              |
    |                              |                              |
    |  MRd/MWr AT=10 (AXI path)     |                              |
    |---------------------------------------------------------------> memory
```

ATS Enable (E) must be Set before ATC entries are used. Host software cannot write ATC contents except via ATS (reset only invalidates). Intermix of translated and untranslated requests is allowed. Untranslated and translated address ranges may overlap.

### 5.2 Invalidate (single TC)

```
                    TA ATPT update
                         |
Device ATC                    HLS Bridge DTI                 SMMU TA
    |                              |                              |
    |  OB P: Inv Req ITag=i range  |                              |
    |<-----------------------------|<-----------------------------|
    |  drop overlapping ATC       |                              |
    |  drain NP using PA           |                              |
    |  push posted writes (same TC)|                              |
    |  IB P: Inv Cpl CC=1 ITAGV    |                              |
    |----------------------------->|----------------------------->|
    |                              |  ITag free                   |
```

### 5.3 Invalidate with multi-TC flush

```
Device ATC                    HLS Bridge DTI                 SMMU TA
    |                              |                              |
    |  OB P: Inv Req ITag=3        |                              |
    |<-----------------------------|<-----------------------------|
    |  IB P: Inv Cpl TC=0 CC=2     |                              |
    |----------------------------->|----------------------------->|  wait 2
    |  IB P: Inv Cpl TC=1 CC=2     |                              |
    |----------------------------->|----------------------------->|  done
```

### 5.4 PRI then ATS translation

```
Device                        HLS Bridge DTI                 Host / TA
    |                              |                              |
    |  IB P: Page Req PRG=k L=1    |                              |
    |----------------------------->|----------------------------->|  pin / page-in
    |  OB P: PRG RSP Success        |                              |
    |<-----------------------------|<-----------------------------|
    |  IB NP: Trans Req            |                              |
    |----------------------------->|----------------------------->|
    |  OB C: Trans Cpl             |                              |
    |<-----------------------------|<-----------------------------|
```

Response Failure (`1111b`) is terminal until PRI Reset. Invalid Request (`0001b`) will not succeed if reissued without a mapping change.

---

## 6. Channel, credit, and sideband notes

- IB Posted to DTI participates in posted-to-posted ordering and delivery-count (`dc_dti_*`, `crd_dti_lmt_posted_*`). Order check can be disabled via `dbg_dis_o_chk_dti`.
- IB NP Translation Requests consume translation tokens until the matching OB Completion.
- OB Posted Invalidates occupy ITag until all Inv Cpl copies (CC) arrive or a vendor timeout (spec suggests Device respond within 1 minute +50%/−0%).
- QoS: `hls_bridge_qos_dti_pck_enc` counts SOP/EOP on DTI HLS IB P (`IS_POSTED=1` → P&REQ and P&RESP) and IB NP (`IS_POSTED=0` → NP&REQ and NP&RESP).
- Clock: `axi_dti_clk` / `axi_dti_rst_n`; `axi_dti_qactive` for clock gating. Inv traffic in TB asserts `dti_clk_gater_vif.upstream_clk_req`.
- Registers: DTI ATS model on internal AXI-Lite master port `[1]`; ATS Extended Capability ID `000Fh`, PRI Extended Capability ID `0013h`.

---

## 7. Enable / disable and error summary

| Condition | Required behavior |
| --- | --- |
| ATS Capability not enabled | No Translation Requests; all DMA AT=`00b` |
| Trans Cpl Status UR | Disable ATC; no translated AT until re-enabled |
| Trans Cpl size < STU | Treat as UR |
| AT=`01b` on Memory Write | UR at TA |
| AT=`11b` | UR |
| Inv Req to non-ATS Function | UR |
| Unexpected Inv Cpl ITag | Implementation-specific; often UC |
| PRI oversubscribe / RC overflow | Response Failure; disable PRI |
| Unexpected PRG Index | Set UPRGI; treat as unexpected completion |
| Page/PRG Response TC ≠ 0 | Malformed at RC/endpoint (switches do not check) |
| BME Clear with queued writes | Send or drop those writes so Inv Cpl is not blocked |
