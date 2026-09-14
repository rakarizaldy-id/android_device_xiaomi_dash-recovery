#!/usr/bin/env python3
import sys, zipfile, tempfile, os, shutil
from pathlib import Path
ff = Path(sys.argv[1])

def rewrite(zip_path, transform):
    zp = Path(zip_path)
    with zipfile.ZipFile(zp, 'r') as zin:
        infos = zin.infolist()
        payload = {i.filename: zin.read(i.filename) for i in infos}
    key = 'META-INF/com/google/android/update-binary'
    text = payload[key].decode('utf-8')
    new = transform(text)
    if new == text:
        raise SystemExit(f'no changes applied to {zp}')
    payload[key] = new.encode('utf-8')
    tmp = zp.with_suffix('.zip.tmp')
    with zipfile.ZipFile(tmp, 'w') as zout:
        for i in infos:
            data = payload[i.filename]
            zi = zipfile.ZipInfo(i.filename, i.date_time)
            zi.compress_type = i.compress_type
            zi.comment = i.comment
            zi.extra = i.extra
            zi.create_system = i.create_system
            zi.external_attr = i.external_attr
            zi.internal_attr = i.internal_attr
            zi.flag_bits = i.flag_bits
            zout.writestr(zi, data)
    os.replace(tmp, zp)

def backup(t):
    a='\tcp -af $SRC_S/.foxs $DEST_S/\n'
    b=a+'\tcp -af $SRC_S/scaling $DEST_S/ 2>/dev/null\n\tcp -af $SRC_S/.splash $DEST_S/ 2>/dev/null\n'
    if a not in t: raise SystemExit('backup anchor1 missing')
    t=t.replace(a,b,1)
    lines=t.splitlines(True)
    out=[]; done=False
    for line in lines:
        out.append(line)
        if (not done) and 'rm -rf $fox_settings"/".navbar' in line:
            out.append("\techo '\\t rm -f $fox_settings\"/\"scaling' >> $U\n")
            out.append("\techo '\\t rm -rf $fox_settings\"/\".splash' >> $U\n")
            done=True
    if not done: raise SystemExit('backup anchor2 missing')
    return ''.join(out)

def reset(t):
    a='rm -f $FOX_SETTINGS/.fox*\n'
    b=a+'rm -f $FOX_SETTINGS/scaling\nrm -rf $FOX_SETTINGS/.splash\nrm -rf $FOX_HOME/.theme $FOX_HOME/.navbar\nrm -f $FOX_HOME/.foxs $FOX_HOME/scaling\nrm -rf $FOX_HOME/.splash\nFOX_HOME_ROOT=$(dirname "$FOX_HOME")\nrm -f "$FOX_HOME_ROOT/theme/ui.zip"\nmkdir -p "$FOX_SETTINGS"\ntouch "$FOX_SETTINGS/.dash-migrated-v1"\n'
    if a not in t: raise SystemExit('reset anchor missing')
    return t.replace(a,b,1)

def delete(t):
    a='rm -f $FOX_SETTINGS/.fox*\n'
    b=a+'rm -f $FOX_SETTINGS/scaling\nrm -rf $FOX_SETTINGS/.splash\nrm -rf $FOX_HOME/OTA $FOX_HOME/.theme $FOX_HOME/.navbar\nrm -f $FOX_HOME/.foxs $FOX_HOME/scaling\nrm -rf $FOX_HOME/.splash\nFOX_HOME_ROOT=$(dirname "$FOX_HOME")\nrm -f "$FOX_HOME_ROOT/theme/ui.zip"\nmkdir -p "$FOX_SETTINGS"\ntouch "$FOX_SETTINGS/.dash-migrated-v1"\n'
    if a not in t: raise SystemExit('delete anchor missing')
    return t.replace(a,b,1)

rewrite(ff/'OF_backup_settings/OF_backup_settings.zip', backup)
rewrite(ff/'OF_reset/OF_reset.zip', reset)
rewrite(ff/'OF_DelFiles/OF_DelFiles.zip', delete)
print('DASH Fox Addons patched: backup/reset/delete')
