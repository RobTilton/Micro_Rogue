from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[4]
ROOM=ROOT/'Workshop/Rooms/Production Promotion'
manifest=json.loads((ROOM/'PROMOTION.json').read_text())
remap={item['source']:item['destination'] for item in manifest['files']}
# Tests remain in Workshop, but every runtime import points into the promoted modules.
remap.update({
 'Workshop/Rooms/Actor Foundation/main.tscn':'Workshop/Rooms/Production Promotion/tests/actor_fixture.tscn',
 'Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn':'Workshop/Rooms/Production Promotion/tests/ui_fixture.tscn',
 'Workshop/Rooms/World Foundation/tests/':'Workshop/Rooms/Production Promotion/tests/',
 'Workshop/Rooms/Actor Foundation/tests/':'Workshop/Rooms/Production Promotion/tests/',
 'Workshop/Rooms/UI Foundation/Prototype/tests/':'Workshop/Rooms/Production Promotion/tests/',
})
suites={
 'World Foundation':['world_test','world_ui_test','autosave_test','restart_test','autosave_restart_test','topology_test','capture_world'],
 'Actor Foundation':['actor_simulation_test','actor_ui_test'],
 'UI Foundation/Prototype':['baseline_rules_test','ui_foundation_test','drag_input_test','floating_panels_test'],
}
for area,names in suites.items():
 for name in names:
  source=ROOT/'Workshop/Rooms'/area/'tests'/(name+'.gd')
  dest=ROOM/'tests'/(name+'.gd')
  if dest.exists(): raise RuntimeError('Test destination already exists: '+str(dest))
  text=source.read_text()
  for before,after in sorted(remap.items(),key=lambda p:len(p[0]),reverse=True): text=text.replace(before,after)
  if 'game.autosave_directory =' in text:
   text=text.replace('\troot.add_child(game)','\tgame.snapshot_directory = game.autosave_directory.path_join("snapshots/")\n\troot.add_child(game)')
  dest.write_text(text)
for name,script in [('actor_fixture','actor_game'),('ui_fixture','game_ui')]:
 (ROOM/'tests'/(name+'.tscn')).write_text(f'''[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://Production/UI/{script}.gd" id="1"]
[node name="ValidationFixture" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")
''')
# Required compatibility fixture will be copied by migration validation, not synthesized.
print('Prepared',sum(map(len,suites.values())),'Production-targeted test/capture scripts and two UI fixtures.')
# Confirm imported texture settings retain the accepted source parameters.
for item in manifest['files']:
 if not item['source'].endswith('.png'): continue
 a=Path(str(ROOT/item['source'])+'.import'); b=Path(str(ROOT/item['destination'])+'.import')
 if a.exists() and b.exists() and a.read_text().split('[params]')[-1].strip()!=b.read_text().split('[params]')[-1].strip():
  raise RuntimeError('Texture import settings differ: '+item['destination'])
print('All copied texture import parameters match their source.')
