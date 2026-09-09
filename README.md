# New Workshop Template
Updated: 2026-09-09

A reusable MCA (Mutual Collaborative Alignment) starting structure. Copy this directory's **contents**, including hidden files, into a new project root. Production is intentionally empty. No game content, tools, completed Rooms, evidence or project history is included.

Start with [AGENTS.md](AGENTS.md). It routes Codex to the shared contract and collaboration primer. The alternate [collaboration primer](Workshop/AI_AGENTS_README/CHAD_ONLY/AI_WORKFLOW_CONTEXT_PRIMER.md) is retained for agents using that entry. This template preserves Rob/Cody collaboration names; adjust names and relevant personal context if ownership changes. A template supplies workflow, not approval to start a task.

Read [Documentation Format](Workshop/Documentation_Format_README.md) when creating project documents. It defines the format directly and links the blank templates; no older project documents are needed.

```text
AGENTS.md
Production/                         Empty production boundary
Workshop/
  README.md
  Documentation_Format_README.md
  AI_AGENTS_README/                  Contracts, primers, blank templates
  AI_Facing_Documentation/           Protocol and empty system/shader libraries
  Rooms/                            New bounded tasks, no existing Rooms
  ToolShed/
    Ledger/                         Schema and empty catalogs
    StorageUnits/                   Empty reusable-parts storage
    Completed_Tool_Builds/          Empty reusable-build storage
  _Audits/                          Empty current/archive report storage
  Trashcans/                        Empty retained-retirement storage
```

Audit and retirement folders are supporting storage, not mandatory work stages. Add domain-specific directories only when a project needs them. Godot notes, Python installation details, assets, populated catalogs, personal audit/script folders and historical workflows were intentionally excluded.

Production has no README or .gitkeep because it must be empty. Git does not preserve empty directories; recreate `Production/` after a Git-only transfer if necessary. Other empty structural folders use README placeholders.
