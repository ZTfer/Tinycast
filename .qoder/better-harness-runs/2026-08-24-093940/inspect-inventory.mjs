import fs from 'fs';
const lane = JSON.parse(fs.readFileSync('.qoder/better-harness-runs/2026-08-24-093940/lane-agent-customize.json', 'utf8'));
const lint = lane.lane.envelopes.lint.data;
const inv = lane.lane.envelopes.inventory.data;
const integrity = lane.lane.envelopes.integrity.data;

const names = new Set();
function collect(o) {
  if (Array.isArray(o)) { o.forEach(collect); return; }
  if (o && typeof o === 'object') {
    for (const k of Object.keys(o)) {
      if (/name|skill|id/i.test(k) && typeof o[k] === 'string') names.add(o[k]);
      collect(o[k]);
    }
  }
}
collect(lint); collect(inv);
const arr = [...names].filter((n) => n.length > 2 && n.length < 60);
console.log('total name-like strings:', arr.length);
const gitish = arr.filter((n) => /commit|git|vcs|version/i.test(n));
console.log('git/commit-like names:', JSON.stringify(gitish));

console.log('--- inventory coverageRows:');
for (const r of (inv.coverageRows || [])) console.log(JSON.stringify(r));
console.log('--- inventory summary:', JSON.stringify(inv.summary));
console.log('--- inventory ownerRoutes:', JSON.stringify(inv.ownerRoutes).slice(0, 3000));
console.log('--- memories:', JSON.stringify(inv.memories));
console.log('--- warnings:', JSON.stringify((inv.warnings || []).slice(0, 8)));
console.log('--- integrity data keys:', Object.keys(integrity));
console.log('--- integrity:', JSON.stringify(integrity).slice(0, 2500));
console.log('--- lint summary:', JSON.stringify(lint.summary || (lint.findings ? { findings: lint.findings.length } : Object.keys(lint))));
