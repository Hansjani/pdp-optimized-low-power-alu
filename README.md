# Low-Power 32-bit ALU Design

This project currently supports a baseline 32-bit ALU and an operand-isolation low-power variant. Additional optimized variants such as clock gating and multi-VT optimization are planned for future updates.

## Project Structure

```text
rtl/
  common/       Shared arithmetic, logic, and shift units
  baseline/     Baseline bit-sliced ALU source
  optimized/    Operand-isolation ALU
tb/             Verilog testbenches
scripts/
  sim/          Simulation and power-flow helper scripts
  synth/        Generic synthesis helper script
  pd/           OpenROAD physical-design flow scripts
constraints/    SDC timing constraints
docs/           Project documentation
```

Generated simulation, synthesis, report, waveform, and physical-design outputs are intentionally ignored by Git. Recreate them locally using the scripts instead of committing them.

## Prerequisites

- Icarus Verilog (`iverilog`, `vvp`)
- Yosys
- OpenROAD, for the physical-design flow
- SKY130 PDK installed locally
- `PDK_ROOT` exported to the directory that contains `sky130/`

Example:

```bash
export PDK_ROOT=/path/to/pdks
```

## Run Simulation

Run the unified ALU testbench for a supported mode:

```bash
bash scripts/sim/run_gate_sim.sh baseline
bash scripts/sim/run_gate_sim.sh op_iso
```

The testbench checks arithmetic, logic, and shift operations against a golden model and writes waveform files under `waves/`.

Planned modes: `clk_gate` and `multi_vt`.

## Run Synthesis

For a selected design/top module:

```bash
bash scripts/synth/synth_module.sh baseline alu_base_bit_sliced
bash scripts/synth/synth_module.sh operand_isolation alu_op_iso
```

Generated netlists and reports are written under `netlist/` and `reports/`, which are ignored by Git.

## Physical Design

Source the design environment, then run the OpenROAD flow scripts:

```bash
source scripts/pd/export_variables.sh baseline
openroad scripts/pd/00_physical_design.tcl

source scripts/pd/export_variables.sh operand_isolation
openroad scripts/pd/00_physical_design.tcl
```

Supported public flow targets are `baseline` and `operand_isolation`.

## Tool Command Reference

See `docs/tool_commands.md` for the Icarus Verilog, Yosys, and OpenROAD commands used by this project and what each command does.

## GitHub Upload Checklist

- No API keys, tokens, passwords, or private keys were found by a local text scan.
- Machine-specific PDK paths were replaced with `PDK_ROOT`.
- Generated outputs are excluded through `.gitignore`.
- Keep committed content focused on source RTL, testbenches, scripts, constraints, and docs.
