const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://tflsmxmuvrecrewknbvb.supabase.co';
const SUPABASE_KEY = 'sb_publishable_OAx279ocalpzqLVAhhMb-w_WdfkOWUH';
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testLogin() {
  console.log('Testing authentication for Super Admin...');
  const { data, error } = await supabase.auth.signInWithPassword({
    email: 'singh2212karanveer@gmail.com',
    password: 'Aujla@1210'
  });

  if (error) {
    console.log('Login Result:', error.message);
  } else {
    console.log('SUCCESS! Super Admin authenticated:', data.user.id, data.user.email);
  }
}

testLogin();
