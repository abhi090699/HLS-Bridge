REPO_ROOT := $(abspath ..)
RTL_INC := $(REPO_ROOT)/rtl/include
RTL_SRC := $(REPO_ROOT)
SMOKE_DIR := $(CURDIR)/rtl_smoke
BUILD_DIR := $(CURDIR)/obj_dir

.PHONY: smoke lint clean help

help:
	@echo "Open-source RTL smoke tests for HLS-Bridge"
	@echo ""
	@echo "Targets:"
	@echo "  smoke  - Build and run Verilator QoS counter smoke test"
	@echo "  lint   - Lint key RTL modules with Verilator"
	@echo "  clean  - Remove build artifacts"

smoke: $(BUILD_DIR)/Vhls_bridge_qos_counter
	@echo "[smoke] Running QoS counter simulation..."
	@$(BUILD_DIR)/Vhls_bridge_qos_counter
	@echo "[smoke] PASS"

$(BUILD_DIR)/Vhls_bridge_qos_counter: $(SMOKE_DIR)/qos_counter_smoke.v $(RTL_SRC)/qos_counter.v $(SMOKE_DIR)/tb_qos_counter.cpp
	@rm -rf $(BUILD_DIR)
	verilator -Wall -Wno-DECLFILENAME -Wno-WIDTHEXPAND -Wno-SELRANGE -Wno-UNUSEDGENVAR \
		--cc --exe --build -Mdir $(BUILD_DIR) \
		-I$(RTL_INC) \
		--top-module hls_bridge_qos_counter \
		$(SMOKE_DIR)/qos_counter_smoke.v \
		$(RTL_SRC)/qos_counter.v \
		$(SMOKE_DIR)/tb_qos_counter.cpp

lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-WIDTHEXPAND -Wno-SELRANGE -Wno-UNUSEDGENVAR -I$(RTL_INC) \
		$(SMOKE_DIR)/qos_counter_smoke.v \
		$(RTL_SRC)/qos_counter.v
	@echo "[lint] PASS"

clean:
	rm -rf $(BUILD_DIR)
