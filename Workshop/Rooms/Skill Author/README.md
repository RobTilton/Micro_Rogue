# Skill Author — Quick Start
Updated: 2026-09-14

1. Open `Tool/SkillAuthor.tscn` in Godot. Select its **SkillAuthor** root node and switch to the **2D** view.
2. In the Inspector, expand **Draft**. Enter a display name and lowercase ID such as `martial_show_off` (blank ID derives from the name).
3. Pick a **Skill Bucket**, skill kind and tags. Choose **Custom** for a bucket not yet listed.
4. Under **Footprint**, pick a preset and rotation. The 2D preview updates. For a custom shape, set the author's **Cell To Edit** coordinates, then click **Add Hex** or **Remove Hex**. The preview labels q,r coordinates. First edit converts a preset into a custom shape.
5. Fill **Unlock Prerequisites**, **Origin and Chain**, and the effect text. Refer to other skills by their IDs, even if you have not authored them yet. Use notes or **Undecided** when a rule is not settled.
6. Click the author's **Add Adjacency Rule** button for each rule you want. Expand **Draft → Adjacency → Adjacency Rules**, then expand its new resource to set count, matching bucket/tags/specific IDs, mandatory/optional status and bonus notes.
7. Write what the skill does under **Effect Idea → Effect Description**. Add optional bonuses, balancing notes and open questions as needed.
8. Click **Save New Revision**. The Status field reports the saved paths. Choose **New Blank Skill** when ready for the next idea. Save your current work first.

Drafts go into `Library/` as two matching files:
- `skill_id_r001.tres`: editable Godot resource.
- `skill_id_r001.json`: complete readable review data for later implementation.

Each save creates the next revision and preserves earlier files. To revise an idea, select its `.tres` under **Load Path**, then click **Load Copy for Editing**. Saving the scene alone is not the same as saving a skill into the Library.

Optional: **F6** runs the shape preview with click-to-toggle hex painting and a Save button. Author the named draft in the Inspector first. Runtime painting changes are kept only when you click Save; load that saved `.tres` back in the editor to continue editing it. **F5 still runs Production.** No plugin enablement is required.

These files capture skill ideas; they do not execute the written effects or add active skills to Production. Once you have a batch, point Cody at `Library/`. Use the highest revision of each skill ID for review; earlier revisions remain history.
