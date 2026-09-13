"""Read-only promotion audit; verifies baseline and active resource boundaries."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[4]
ROOM=ROOT/'Workshop/Rooms/Production Promotion'
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 manifest=json.loads((ROOM/'PROMOTION.json').read_text())
 errors=[]
 for entry in manifest['files']:
  if sha(ROOT/entry['source'])!=entry['source_sha256']: errors.append('Accepted source changed: '+entry['source'])
 for name,expected in manifest['previous_production'].items():
  if sha(ROOT/name)!=expected: errors.append('Earlier baseline changed: '+name)
 baseline=json.loads((ROOT/'Production/BASELINE.json').read_text())
 for name,expected in baseline['files'].items():
  if sha(ROOT/name)!=expected: errors.append('Production baseline changed: '+name)
 for module in ['Actors','World','Persistence','UI']:
  for path in (ROOT/'Production'/module).rglob('*.gd'):
   for uri in re.findall(r'''["'](res://[^"'\n]+)["']''',path.read_text()):
    if not uri.startswith('res://Production/') or uri.startswith(('res://Production/Current/','res://Production/Gameplay/','res://Production/Splash/')):
     errors.append('Runtime crosses boundary: '+uri)
    target=ROOT/uri[6:]
    if not target.exists() and not list(target.parent.glob(target.name+'*')): errors.append('Missing runtime resource: '+uri)
 if 'run/main_scene="res://Production/main.tscn"' not in (ROOT/'project.godot').read_text(): errors.append('F5 entry differs')
 if errors: raise SystemExit('\n'.join(errors))
 print(f'Promotion audit PASS: {len(manifest["files"])} accepted sources, preserved earlier build, {len(baseline["files"])} Production resource/hash records, isolated references and F5 entry.')
if __name__=='__main__': main()
