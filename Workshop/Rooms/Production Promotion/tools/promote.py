"""Contained copy/remap of the accepted runtime; refuses to overwrite destinations."""
from pathlib import Path
import hashlib, json, re
ROOT = Path(__file__).resolve().parents[4]
ROOM = ROOT / 'Workshop/Rooms/Production Promotion'
SOURCE = 'Workshop/Rooms/World Foundation/main.tscn'
CODE = {'.gd','.tscn','.tres','.gdshader'}
RESOURCE = re.compile(r'''["'](res://[^"'\n]+)["']''')
DYNAMIC = {
 'Workshop/Chad-Casso/Local_Map_': ['Workshop/Chad-Casso/Local_Map_'+b+'.png' for b in ['Plains','Forest','Hills','Mountains','Desert']],
 'Workshop/Rooms/UI Foundation/Prototype/art/items/': ['Workshop/Rooms/UI Foundation/Prototype/art/items/bronze_sword.png'],
}
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def closure():
 pending=[SOURCE]; seen=set()
 while pending:
  name=pending.pop()
  if name in DYNAMIC:
   pending.extend(DYNAMIC[name]); continue
  if name in seen: continue
  path=ROOT/name
  if not path.is_file(): raise RuntimeError('Unresolved runtime dependency: '+name)
  seen.add(name)
  if path.suffix in CODE:
   for uri in RESOURCE.findall(path.read_text()):
    if '/saves/' not in uri: pending.append(uri[6:])
 return sorted(seen)
def target(name):
 p=Path(name); base=p.name
 if name == SOURCE: return 'Production/main.tscn'
 if name.startswith('Workshop/Chad-Casso/'): return 'Production/Assets/Terrain/'+base
 if '/Actor Foundation/art/' in name: return 'Production/Assets/Actors/'+base
 if '/Prototype/art/items/' in name: return 'Production/Assets/Items/'+base
 if '/World Foundation/domain/' in name:
  module='Persistence' if base in ['autosave_journal.gd','map_state.gd','persistent_actor_world.gd'] else 'World'
  return 'Production/'+module+'/'+base
 if '/Actor Foundation/domain/' in name: return 'Production/Actors/'+base
 if '/Prototype/domain/' in name:
  module='Actors' if base in ['grid_inventory.gd','item_inspection.gd'] else 'World'
  return 'Production/'+module+'/'+base
 if '/Prototype/gameplay/' in name:
  if base in ['main.gd','hex_board.gd','die_slot.gd']:
   return 'Production/UI/'+('base_game.gd' if base=='main.gd' else base)
  return 'Production/Actors/'+base
 if '/splash/' in name: return 'Production/UI/'+base
 if '/ui/' in name: return 'Production/UI/'+('game_ui.gd' if base=='workshop_game.gd' else base)
 raise RuntimeError('Missing destination rule: '+name)
def main():
 sources=closure(); mapping={s:target(s) for s in sources}
 if len(set(mapping.values())) != len(mapping): raise RuntimeError('Destination collision')
 # Validate all writes and dependencies before creating anything.
 for source,dest in mapping.items():
  if (ROOT/dest).exists(): raise RuntimeError('Preserved destination already exists: '+dest)
 replacements=dict(mapping)
 replacements.update({'Workshop/Chad-Casso/Local_Map_':'Production/Assets/Terrain/Local_Map_',
  'Workshop/Rooms/UI Foundation/Prototype/art/items/':'Production/Assets/Items/',
  'res://Workshop/Rooms/World Foundation/saves/':'user://worlds/'})
 records=[]
 for source,dest in mapping.items():
  original=ROOT/source; output=ROOT/dest; output.parent.mkdir(parents=True,exist_ok=True)
  if original.suffix in CODE:
   text=original.read_text()
   for before,after in sorted(replacements.items(),key=lambda p:len(p[0]),reverse=True): text=text.replace(before,after)
   if original.suffix in ['.tscn','.tres']: text=re.sub(r' uid="uid://[^\"]+"','',text)
   if dest=='Production/main.tscn': text=text.replace('name="WorldFoundation"','name="MicroRogue"')
   output.write_text(text)
  else: output.write_bytes(original.read_bytes())
  records.append({'source':source,'destination':dest,'source_sha256':digest(original),'copied_sha256':digest(output)})
 for source,label in [('project.godot','project.godot.before'),('README.md','ROOT_README.before.md'),('Production/README.md','PRODUCTION_README.before.md')]:
  (ROOM/'Reference'/label).write_bytes((ROOT/source).read_bytes())
 previous={str(p.relative_to(ROOT)):digest(p) for p in (ROOT/'Production/Current').rglob('*') if p.is_file()}
 manifest={'date':'2026-09-12','entry':'res://Production/main.tscn','files':records,'previous_production':previous,'storage':'user://worlds/','gameplay_changes':False}
 (ROOM/'PROMOTION.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print(f'Copied {len(records)} required files; source bytes {sum((ROOT/s).stat().st_size for s in sources)}; previous Production/Current preserved.')
if __name__=='__main__': main()
