#include <cstdio>
#include <cstdlib>

#include "Vhls_bridge_qos_counter.h"
#include "verilated.h"

static void tick(Vhls_bridge_qos_counter *dut) {
  dut->core_clk = 0;
  dut->eval();
  dut->core_clk = 1;
  dut->eval();
}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);

  Vhls_bridge_qos_counter dut;
  dut.core_rst_n = 0;
  dut.enable = 0;
  dut.clear = 0;
  dut.data = 0;
  dut.dti_en = 0;

  for (int i = 0; i < 4; ++i) {
    tick(&dut);
  }

  dut.core_rst_n = 1;

  // Enable both interfaces and accumulate one count on interface 0.
  dut.enable = 0b11;
  dut.clear = 0;
  dut.data = 1ULL;  // DATA_SIZE=13 count on port 0
  dut.dti_en = 0b001;  // one DTI increment
  tick(&dut);

  const uint32_t count = dut.output_count;
  if (count == 0) {
    std::fprintf(stderr, "FAIL: expected non-zero QoS counter output, got 0\n");
    return EXIT_FAILURE;
  }

  // Clear with enable asserted should latch prefix+data_add path.
  dut.clear = 1;
  tick(&dut);

  std::printf("QoS counter smoke test passed (output_count=0x%x)\n", count);
  return EXIT_SUCCESS;
}
