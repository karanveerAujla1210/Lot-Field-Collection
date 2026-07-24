const fs = require('fs');
const path = require('path');

const screens = [
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
  'visit_screen'
];

screens.forEach(screen => {
  const htmlPath = path.join(__dirname, '..', screen, 'code.html');
  if (fs.existsSync(htmlPath)) {
    let content = fs.readFileSync(htmlPath, 'utf8');
    if (!content.includes('fincollect-bridge.js')) {
      const scriptTags = `\n    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>\n    <script src="../src/bridge/fincollect-bridge.js"></script>\n</body></html>`;
      content = content.replace('</body></html>', scriptTags);
      fs.writeFileSync(htmlPath, content, 'utf8');
      console.log(`Added bridge script tag to ${screen}/code.html`);
    }
  }
});
