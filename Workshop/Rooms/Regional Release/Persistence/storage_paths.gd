extends RefCounted
## Writable game data belongs to the Godot user directory, never development resources.
const ROOT: String = "user://regional_release/"
const SNAPSHOTS: String = ROOT+"snapshots/"
const AUTOSAVES: String = ROOT+"autosaves/"
const ARCHIVES: String = ROOT+"archives/"
const IMPORTS: String = ROOT+"imports/"
