# Enemy Roster
Updated: 2026-09-16

Approved outcome: all imported enemy types, hostility/player-level weighted family spawning and a humanoid boolean governing equipment/learned skills. User clarified werebeasts humanoid; flesh golems non-humanoid.
Scope: Production actors/generation/actions/persistence/rendering, source copies, targeted checks and docs. Preserve world identities, actors and possessions. No commits or player-save resets. Starting state: Adventure Loop — Attack Effects plus Belt Pouch Layout changes, preserved originals under Reference/.

- [Enemy Roster]+[Generation]+[Families]: complete. 12 families/42 variants, weighted family/tier selection across generation and respawn. Catalogue and CURRENT_STATE.md are tuning references. Seed/coverage checks passed.
- [Enemy Roster]+[Actions]+[Anatomy]: complete; depends on Families. Natural attacks and shared humanoid guards, stat advancement and item-preserving legacy migration. Focused and save checks passed.
- [Enemy Roster]+[Presentation]+[Sprites]: awaiting_validation; depends on Families. All variants mapped to copied art, clean alpha, bounded size. Rendered gallery inspected; human acceptance pending.
- [Enemy Roster]+[Validation]+[Integration]: awaiting_validation; depends on preceding Boxes. 596 focused + 72 integration checks passed; scope whitespace clean. Production baseline/README and Workshop TODO synchronized. Remaining dependency is human visual/balance acceptance.

Last completed implementation checkpoint: [Enemy Roster]+[Actions]+[Anatomy]. No active implementation Box. Next: F5 playtest; newly generated/respawned populations use new weights. Retain Reference originals, scripts, isolated test saves and roster.png. Deferred limits are in CURRENT_STATE.md.
