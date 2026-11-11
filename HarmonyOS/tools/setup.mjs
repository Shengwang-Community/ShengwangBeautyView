import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const [sdk, material, ...extra] = process.argv.slice(2);
if (!sdk || !material || extra.length !== 0) {
  console.error('Usage: node tools/setup.mjs /path/to/AgoraRtcSdk.har /path/to/AgoraBeautyMaterial.zip');
  process.exit(1);
}
for (const source of [sdk, material]) {
  if (!fs.existsSync(source) || !fs.statSync(source).isFile()) {
    console.error(`Package not found: ${source}`);
    process.exit(1);
  }
}
// Check the material before copying either package or creating local configuration.
execFileSync(process.execPath, [path.join(root, 'tools/verify-material.mjs'), material], { stdio: 'inherit' });
function copyPackage(source, relative) {
  const target = path.join(root, relative);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  if (path.resolve(source) !== target) {
    fs.copyFileSync(source, target);
  }
}
copyPackage(sdk, 'libs/AgoraRtcSdk.har');
copyPackage(material, 'entry/src/main/resources/rawfile/AgoraBeautyMaterial.zip');
const profile = path.join(root, 'build-profile.json5');
if (!fs.existsSync(profile)) {
  fs.copyFileSync(path.join(root, 'build-profile.template.json5'), profile);
}
const config = path.join(root, 'entry/src/main/ets/config/LocalConfig.ets');
if (!fs.existsSync(config)) {
  fs.mkdirSync(path.dirname(config), { recursive: true });
  fs.copyFileSync(path.join(path.dirname(config), 'LocalConfig.example.ets'), config);
}
console.log('SDK and material copied. Fill APP_ID (and TOKEN when required) in entry/src/main/ets/config/LocalConfig.ets, then configure signing in DevEco Studio.');
