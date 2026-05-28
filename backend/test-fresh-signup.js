const http = require('http');

function makeRequest(method, path, data) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            data: JSON.parse(body),
          });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });

    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function runTests() {
  console.log('=== FRESH EMAIL SIGNUP TEST ===\n');

  try {
    // Use a fresh email each time
    const timestamp = Date.now();
    const freshEmail = `user_${timestamp}@test.com`;

    // Test 1: Fresh signup
    console.log(`TEST 1: Fresh Signup (${freshEmail})`);
    const signupRes = await makeRequest('POST', '/api/auth/register', {
      email: freshEmail,
      password: 'Test@1234',
      firstName: 'John',
      lastName: 'Doe',
    });
    console.log(`Status: ${signupRes.status}`);
    console.log(`Response: ${JSON.stringify(signupRes.data, null, 2)}`);
    console.log(`Success: ${signupRes.data.success}`);
    console.log(`User Email: ${signupRes.data.user?.email}`);
    console.log(`Token: ${signupRes.data.token ? '✓ Received' : '✗ Not received'}\n`);

    // Test 2: Login with same credentials
    if (signupRes.data.success) {
      console.log(`TEST 2: Login with same credentials`);
      const loginRes = await makeRequest('POST', '/api/auth/login', {
        email: freshEmail,
        password: 'Test@1234',
      });
      console.log(`Status: ${loginRes.status}`);
      console.log(`Success: ${loginRes.data.success}`);
      console.log(`Token: ${loginRes.data.token ? '✓ Received' : '✗ Not received'}\n`);
    }

    console.log('=== TEST COMPLETED ===');
  } catch (err) {
    console.error('Test Error:', err.message);
  }
}

runTests();
