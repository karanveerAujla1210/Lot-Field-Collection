const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const root = path.join(__dirname, '..');
const nextDir = path.join(root, 'frontend-next');
const outDir = path.join(nextDir, 'out');
const mobileWww = path.join(root, 'mobile', 'android', 'app', 'src', 'main', 'assets', 'public');

// Build Next.js as static export for mobile
console.log('[build-www] Building Next.js static export...');
execSync('npm run build', {
  cwd: nextDir,
  env: { ...process.env, BUILD_TARGET: 'mobile' },
  stdio: 'inherit',
});

if (!fs.existsSync(outDir)) {
  console.error('[build-www] ERROR: Next.js out/ directory not found after build.');
  process.exit(1);
}

// Clear and recreate destination
if (fs.existsSync(mobileWww)) fs.rmSync(mobileWww, { recursive: true });
fs.mkdirSync(mobileWww, { recursive: true });

function copyRecursive(src, dest) {
  const stats = fs.statSync(src);
  if (stats.isDirectory()) {
    fs.mkdirSync(dest, { recursive: true });
    fs.readdirSync(src).forEach(child =>
      copyRecursive(path.join(src, child), path.join(dest, child))
    );
  } else {
    fs.copyFileSync(src, dest);
  }
}

copyRecursive(outDir, mobileWww);

console.log('[build-www] Done.');
console.log(`  Source:      ${outDir}`);
console.log(`  Destination: ${mobileWww}`);
