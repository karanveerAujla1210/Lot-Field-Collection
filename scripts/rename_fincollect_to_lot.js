const fs = require('fs');
const path = require('path');

const rootDir = path.join(__dirname, '..');

// Directories to skip
const ignoreDirs = ['node_modules', '.git', 'dist'];

function processDirectory(dirPath) {
  const items = fs.readdirSync(dirPath);
  items.forEach(item => {
    const fullPath = path.join(dirPath, item);
    const relPath = path.relative(rootDir, fullPath);

    if (ignoreDirs.some(d => relPath.startsWith(d))) {
      return;
    }

    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      processDirectory(fullPath);
    } else if (stat.isFile()) {
      const ext = path.extname(fullPath).toLowerCase();
      // Process text files
      if (['.html', '.js', '.ts', '.json', '.md', '.sql', '.env', '.txt', '.css'].includes(ext) || item === '.env') {
        replaceInFile(fullPath);
      }
    }
  });
}

function replaceInFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    let original = content;

    // Direct Replacements
    content = content.replace(/LOT Field Collection/g, 'LOT Field Collection');
    content = content.replace(/LOT Field Collection/g, 'LOT Field Collection');
    content = content.replace(/fincollect\.com/g, 'lotfieldcollection.com');
    content = content.replace(/fincollect\.app/g, 'lotfieldcollection.app');
    content = content.replace(/lot-field-collection-backend/g, 'lot-field-collection-backend');
    content = content.replace(/lot-field-collection-crm/g, 'lot-field-collection-crm');
    content = content.replace(/lot-field-collection-realtime/g, 'lot-field-collection-realtime');
    content = content.replace(/lot_system_sync/g, 'lot_system_sync');
    content = content.replace(/lotSupabase/g, 'lotSupabase');

    if (content !== original) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`Replaced 'LOT Field Collection' in: ${path.relative(rootDir, filePath)}`);
    }
  } catch (err) {
    console.error(`Error reading ${filePath}:`, err.message);
  }
}

console.log('--- STARTING REPLACEMENT OF "LOT Field Collection" WITH "LOT Field Collection" ---');
processDirectory(rootDir);
console.log('--- REPLACEMENT COMPLETED ---');
