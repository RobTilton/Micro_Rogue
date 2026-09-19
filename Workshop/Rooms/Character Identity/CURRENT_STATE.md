# Character Identity
Updated: 2026-09-18

Production character creation now accepts a name (40 characters maximum; blank becomes Adventurer) and permits two extra full rerolls after the initial six-die roll. Rerolling clears assignments and preserves the typed name. The disabled button displays zero remaining; its handler also rejects further rolls. Assigning/shuffling existing dice does not consume rerolls.

Creation saves retain name, dice and remaining rolls; loading does not replenish spent rolls. New characters, including retirement successors, start with a blank name and two rerolls. Existing unfinished saves without these fields default to a blank name and two rerolls. Confirmed actors retain their name through normal persistence and retirement. Production save validation rejects invalid name/counter data.

Resuming creation also exposed and fixed town population accessing an unloaded parent map: it now ensures that map exists first.

Validation: 17 actual-scene checks passed with isolated test saves and no script errors, covering exhausted rerolls, name/counter reload, actor naming and retirement/new-character behavior. Prior source files are retained in this Room. Human F5 visual acceptance pending.
