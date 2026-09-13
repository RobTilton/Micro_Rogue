# Production Promotion — DOTS
Updated: 2026-09-12
Checkpoint: [Production Promotion]+[Validation]+[Adoption]

## Contract and authority

Rob reports the game working and accepts the current World Foundation experience. After the alignment for a self-contained Production runtime, clear Actors/World/Persistence/UI/Assets modules, F5 adoption, existing-save continuity and documentation, Rob issued **Execute**. Root launcher and Production writes are explicitly authorized. No new gameplay, deletion or Git commit. Preserve previous Production/Current, Gameplay and Splash, all Workshop sources, tests and artwork. Placeholder status does not justify a Production dependency on Workshop.

Baseline: accepted working files in World Foundation composed with Actor Foundation and UI Foundation. No user Git checkpoint supplied; source hashes and original launcher/reference hashes are recorded in PROMOTION.json and Reference/. World Foundation user playtest is accepted for this promotion; promoted F5 human verification is a separate final check.

| Checkpoint | Responsibility | Depends on | Completion | Status | Evidence |
|---|---|---|---|---|---|
| [Production Promotion]+[Delivery]+[Inventory] | Exact resource closure and stable source mapping | accepted source | required scripts/assets identified; baseline hashes recorded | complete | PROMOTION.json; 69 source files, hashes and preserved launcher |
| [Production Promotion]+[Runtime]+[Modules] | Self-contained Production modules and entry | Inventory | no runtime references to Workshop or earlier Production baseline | complete | 70 owned runtime files; resource audit and isolated package pass |
| [Production Promotion]+[Persistence]+[Continuity] | Independent writable storage and safe save migration | Modules | current Workshop progress loads unchanged in Production; original files retained | complete | SAVE_MIGRATION.json: no complete user saves; migration fixtures 12 checks, original hashes preserved |
| [Production Promotion]+[Validation]+[Adoption] | Runtime, save, visual and isolation checks; F5 launcher/docs | Modules, Continuity | required checks pass; F5 entry and authoritative docs agree | complete | 63,534 checks across suites; isolated render; F5 startup; Production/BASELINE.json and audit pass |
| [Production Promotion]+[Validation]+[Playtest] | Rob confirms promoted F5 build | Adoption | human validation | awaiting_validation | Source gameplay accepted; promoted F5 human check pending |

Implementation and adoption complete. Next: Rob’s F5 verification. All evidence retained under this Room; reusable promotion/migration helpers in tools/. Tests remain outside the runtime. Production uses its own resources and user:// save storage. No automatic commit or destructive cleanup.

## Closeout

Production/main.tscn is the root F5 entry. All five runtime modules and placeholder assets are independent of Workshop and earlier builds. Production/BASELINE.json records 139 resource/hash records; PROMOTION.json records provenance and the isolated package checksum. All accepted source scripts/assets and earlier Production/Current hashes still match. Root and module documentation and source-Room handoff notices are synchronized. Save transfer found no complete user worlds to import; no fixture was installed into the real Continue menu. No deletion, Git commit or unapproved gameplay work.
