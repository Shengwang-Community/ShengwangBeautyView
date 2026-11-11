import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const archive = process.argv[2] ? path.resolve(process.argv[2]) :
  path.join(root, 'entry/src/main/resources/rawfile/AgoraBeautyMaterial.zip');
if (!fs.existsSync(archive)) {
  console.error(`Material not found: ${archive}\nRun node tools/setup.mjs /path/to/AgoraRtcSdk.har /path/to/AgoraBeautyMaterial.zip first.`);
  process.exit(1);
}
const expected = '3d75a6e4f7023d24223225d2ca50024896524068847859424d49aa53dc0cbdb8';
const digest = crypto.createHash('sha256').update(fs.readFileSync(archive)).digest('hex');
assert.equal(digest, expected, 'Material changed: check templates and update BeautyMaterial.VERSION / README');
const names = new Set(execFileSync('unzip', ['-Z1', archive], { encoding: 'utf8' }).trim().split('\n'));
const config = JSON.parse(execFileSync('unzip', ['-p', archive, 'beauty_material_functional/config.json'], { encoding: 'utf8' }));
const manager = fs.readFileSync(path.join(root, 'entry/src/main/ets/beauty/ShengwangBeautyManager.ets'), 'utf8');
const templates = [...manager.matchAll(/new EffectTemplate\('[^']+', '([^']+)'\)/g)].map(match => match[1]);
assert.equal(new Set(templates).size, 59);
for (const key of templates) {
  const relative = config.user_interface_option[key];
  assert.ok(relative, `Unknown template: ${key}`);
  assert.ok(names.has(`beauty_material_functional/${relative}config.json`), `Missing config: ${key}`);
}
for (const item of ['lip/lip001', 'blush/blush001', 'facial/facial001',
  'eyeshadow/eyeshadowleft001', 'eyebrow/eyebrowleft001', 'eyelash/eyelashleft002', 'pupil/pupil001']) {
  assert.ok(names.has(`resource/${item}.png`), `Missing resource: ${item}`);
}
console.log(`Material verified: SHA-256 ${digest}, ${templates.length} UI templates, shared resources complete.`);
