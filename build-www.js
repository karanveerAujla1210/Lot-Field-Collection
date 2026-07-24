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

// Copy screen folders
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

// Create entry point index.html in www/
const indexHtmlContent = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>FinCollect Mobile</title>
  <script>
    window.location.href = "login_screen/code.html";
  </script>
</head>
<body>
</body>
</html>`;

fs.writeFileSync(path.join(wwwDir, 'index.html'), indexHtmlContent, 'utf8');
console.log('[Build WWW] Mobile web directory www/ created successfully.');
