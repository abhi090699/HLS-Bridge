# HLS-Bridge

Cadence UVM verification environment and RTL sources for the PCIe HLS Bridge module.

This repository contains verification IP, testbench components, and synthesizable RTL blocks (QoS, MSI, delivered-count logic, and the top-level bridge). The canonical simulation flow uses **Cadence Xcelium** with **Denali VIP** and a full project tree that includes `verif/uvc_lib` and `rtl` file lists.

## Quick start (Cloud Agent / open-source smoke tests)

The committed Cloud Agent environment installs open-source tooling and runs a Verilator smoke test against the QoS counter RTL:

```bash
./scripts/cloud-agent-install.sh
make -C sim smoke
```

Additional lint coverage:

```bash
make -C sim lint
```

## Full UVM simulation (Cadence)

The root `Makefile` targets the production flow:

| Variable | Purpose |
| --- | --- |
| `DENALI` | Path to the Cadence Denali VIP installation |
| `CURRENT_PROJECT_PATH` | Root of the full PCIe project containing `verif/uvc_lib` and `rtl` |
| `TEST` | UVM test name (default: `cdn_pcie_hls_bridge_base_test`) |
| `CONFIG` | Configuration package name (default: `ga_config`) |

Example (requires licensed Cadence tools and the complete project checkout):

```bash
export CURRENT_PROJECT_PATH=/path/to/pcie/project
export DENALI=/path/to/denali/vip
make run TEST=cdn_pcie_hls_bridge_base_test SEED=1
```

Interactive debug:

```bash
make run_i
```

Help:

```bash
make help
make list_tests
```

## Repository layout

| Path | Description |
| --- | --- |
| `*.sv` | UVM testbench, environment, sequences, and checkers |
| `*.v` | Synthesizable RTL (QoS, MSI, delivered count, top) |
| `Makefile` | Cadence Xcelium / UVM simulation flow |
| `sim/` | Open-source Verilator smoke tests |
| `rtl/include/hlsb_macros.vh` | Macro shims for open-source RTL lint/sim |
| `scripts/` | Cloud Agent install/start helpers |

## Tooling notes

- **Production**: Cadence Xcelium (`xrun`), UVM 1.2, Denali PCIe/CXS/Stream VIP
- **Smoke tests**: Verilator 5.x, Icarus Verilog, GNU Make, `bc`
- Cadence-specific include macros (`HLSB_*`) are stubbed under `rtl/include/` for open-source simulation only; the production flow should use the project-provided macro headers.

## Logs

`LOG.log` and `debug.log` contain example UVM simulation output from an internal Cadence regression run.
