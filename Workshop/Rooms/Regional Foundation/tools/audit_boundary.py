from pathlib import Path
import hashlib,json,re
root=Path(__file__).resolve().parents[4]
room=root/'Workshop/Rooms/Regional Foundation'
for entry in json.loads((room/'SOURCE_BASELINE.json').read_text()):
    assert hashlib.sha256((root/entry['source']).read_bytes()).hexdigest()==entry['sha256'], entry['source']
for folder in ['Actors','World','Persistence','UI']:
    for path in (room/folder).glob('*.gd'):
        for target in re.findall(r'res://[^"\n]+',path.read_text()):
            assert target.startswith(('res://Workshop/Rooms/Regional Foundation/','res://Production/Assets/')), (path,target)
scene=(room/'main.tscn').read_text()
assert 'res://Workshop/Rooms/Regional Foundation/UI/world_game.gd' in scene
scene_ids=set(re.findall(r'uid="([^"]+)"',scene))
production_ids=set(re.findall(r'uid="([^"]+)"',(root/'Production/main.tscn').read_text()))
assert not scene_ids.intersection(production_ids), 'Room must not reuse Production scene/script IDs.'
assert 'run/main_scene="res://Production/main.tscn"' in (root/'project.godot').read_text()
assert 'user://regional_foundation/' in (room/'Persistence/storage_paths.gd').read_text()
print('Regional boundary PASS: source scripts unchanged, scoped runtime dependencies, separate saves, Production remains F5.')
