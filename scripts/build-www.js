const fs = require('fs');
const path = require('path');

const rootDir = __dirname;
// Source is the reorganized frontend/ directory
const frontendDir = path.join(rootDir, '..', 'frontend');
const wwwDir = path.join(rootDir, '..', 'mobile', 'android', 'app', 'src', 'main', 'assets', 'public');

if (!fs.existsSync(wwwDir)) {
  fs.mkdirSync(wwwDir, { recursive: true });
}

function copyRecursive(src, dest) {
  if (!fs.existsSync(src)) return;
  const stats = fs.statSync(src);
  if (stats.isDirectory()) {
    if (!fs.existsSync(dest)) fs.mkdirSync(dest, { recursive: true });
    fs.readdirSync(src).forEach(child => {
      copyRecursive(path.join(src, child), path.join(dest, child));
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

// Copy entire frontend/ into mobile www
copyRecursive(frontendDir, wwwDir);

console.log('[Build WWW] Frontend copied to mobile assets successfully.');
console.log(`  Source:      ${frontendDir}`);
console.log(`  Destination: ${wwwDir}`);
