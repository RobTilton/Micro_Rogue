# MCA Workshop
Updated: 2026-09-10

Workshop contains bounded work, agent operating context, documentation and reusable tooling. Production is the separately authorized delivery/runtime boundary. Follow the [shared contract](AI_AGENTS_README/SHARED/.AGENTS.md); this directory does not grant execution authority.

- [Agent context](AI_AGENTS_README/README.md): startup routing, primers, contracts and templates.
- [Documentation format](Documentation_Format_README.md): explicit document structure and maintenance rules.
- [AI-facing documentation](AI_Facing_Documentation/README.md): protocol, system contracts and shader contracts.
- [Rooms](Rooms/README.md): create one bounded outcome with DOTS before implementation.
- [ToolShed](ToolShed/README.md): proven reusable parts/builds, initially empty.
- [Audits](_Audits/README.md): evidence without execution authority.
- [Retired material](Trashcans/README.md): retained artifacts, not active context or deletion permission.

## Current Project Boundary

The accepted game is in `Production/`. There is only one Godot project: root `project.godot`. F5 launches Production/Current/ui/main.tscn. Open Rooms/UI Foundation/Prototype/ui/main.tscn and press F6 to iterate in Workshop. Future Rooms add scenes under Workshop, not nested project.godot files. Workshop contains development and validation material, not dependencies required by the Production runtime.

- [Design](Design/README.md): project-level provisional intent.
- [Tests](Tests/README.md): headless checks importing the adopted Production code.
- [Production system contract](AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/MICRO_ROGUE_SLICE.md): current runtime ownership and behavior.
- [Completed starting Slice](<Rooms/starting Slice/DOTS.md>): acceptance and promotion evidence; original standalone splash retained.

Future iterations use scoped Rooms and import only necessary dependencies. Production changes follow the approved promotion scope. Root retains the Godot launcher and repository setup; all game content lives in Production or Workshop.
