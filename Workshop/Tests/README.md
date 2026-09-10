# Runtime Validation

Current Production suites live in **PromotedCurrent/** and import Production/Current directly. Run each `*_test.gd` with `godot --headless --path . --script Workshop/Tests/PromotedCurrent/<name>_test.gd`. Seven suites: baseline_rules, ui_foundation, drag_input, tile_inspection, floating_panels, map_world, tile_choices; 2,190 checks pass. `capture_production.gd` requires a display and asserts root launch/script ownership. StartingSlice below validates the preserved earlier baseline, not current Production.

Updated: 2026-09-09
Checkpoint: [starting Slice]+[Delivery]+[ProductionPromotion]
Implementation baseline: tests relocated with the accepted slice; imports target Production directly.

Run from the repository root using Godot 4.4.1. Replace `godot` with your Godot executable path if needed.

```sh
godot --headless --path . --script Workshop/Tests/StartingSlice/slice_test.gd
godot --headless --path . --script Workshop/Tests/StartingSlice/flow_test.gd
godot --headless --path . --script Workshop/Tests/StartingSlice/inventory_cooldowns_test.gd
godot --headless --path . --quit-after 3
```

The rule suite covers damage, healing, XP, equipment and generation (2,027 checks). The inventory/cooldown suite covers clocks, costs, ownership and empty equipment slots (37 checks). The flow suite exercises character creation through encounter/death. Startup validates root scene loading.

All passed after Production relocation. Headless evidence does not replace human visual playtesting or establish finished balance. These scripts are validation infrastructure; Production must not import them.
