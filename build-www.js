const fs = require('fs');
const path = require('path');

const rootDir = __dirname;
const wwwDir = path.join(rootDir, 'www');

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

// Copy screen folders & root index.html
const folders = [
  'admin_dashboard',
  'customer_details',
  'customer_list',
  'dashboard',
  'fincollect_executive',
  'follow_up_screen',
  'live_monitoring',
  'login_screen',
  'payment_screen',
  'portfolio_manager',
  'profile_screen',
  'reports_analytics',
  'splash_screen',
  'staff_management',
  'sync_screen',
  'visit_screen',
  'src',
  'dist'
];

folders.forEach(folder => {
  const srcPath = path.join(rootDir, folder);
  const destPath = path.join(wwwDir, folder);
  copyRecursive(srcPath, destPath);
});

// Copy root index.html to www/index.html
fs.copyFileSync(path.join(rootDir, 'index.html'), path.join(wwwDir, 'index.html'));
console.log('[Build WWW] Single master portal www/index.html created successfully.');
