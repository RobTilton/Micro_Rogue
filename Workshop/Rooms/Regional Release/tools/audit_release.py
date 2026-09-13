from pathlib import Path
import hashlib,json,re
root=Path(__file__).resolve().parents[4]
room=root/'Workshop/Rooms/Regional Release'
manifest=json.loads((room/'PROMOTION.json').read_text())
baseline=json.loads((root/'Production/BASELINE.json').read_text())
for name,expected in baseline['files'].items():
    assert hashlib.sha256((root/name).read_bytes()).hexdigest()==expected, name
for entry in manifest['regional_source']:
    assert hashlib.sha256((root/entry['source']).read_bytes()).hexdigest()==entry['sha256'], entry['source']
for folder in ['Actors','World','Persistence','UI']:
    for p in (root/'Production'/folder).glob('*.gd'):
        for target in re.findall(r'res://[^"\n]+',p.read_text()):
            assert target.startswith('res://Production/'),(p,target)
            assert not target.startswith('res://Production/Previous/'),(p,target)
            location=root/target[6:]
            assert location.exists() or list(location.parent.glob(location.name+'*')),(p,target)
        source=room/folder/p.name
        expected=source.read_text().replace('Workshop/Rooms/Regional Release/','Production/')
        if p.name=='storage_paths.gd': expected=expected.replace('user://regional_release/','user://worlds/')
        assert p.read_text()==expected, 'Room/Production divergence: '+str(p)
assert 'run/main_scene="res://Production/main.tscn"' in (root/'project.godot').read_text()
assert (root/'Production/Previous/WorldFoundation/main.tscn').exists()
print(f'Regional Release audit PASS: {len(baseline["files"])} resource hashes; unchanged source, matched promotion, independent runtime and F5 entry.')
