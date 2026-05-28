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
  console.log('=== AUTH FLOW TEST ===\n');

  try {
    // Test 1: Signup
    console.log('TEST 1: Signup');
    const signupRes = await makeRequest('POST', '/api/auth/register', {
      email: 'test@example.com',
      password: 'Test@1234',
      firstName: 'John',
      lastName: 'Doe',
    });
    console.log(`Status: ${signupRes.status}`);
    console.log(`Success: ${signupRes.data.success}`);
    console.log(`User Email: ${signupRes.data.user?.email}`);
    console.log(`Token: ${signupRes.data.token ? '✓ Received' : '✗ Not received'}\n`);

    // Test 2: Login
    console.log('TEST 2: Login');
    const loginRes = await makeRequest('POST', '/api/auth/login', {
      email: 'test@example.com',
      password: 'Test@1234',
    });
    console.log(`Status: ${loginRes.status}`);
    console.log(`Success: ${loginRes.data.success}`);
    console.log(`Token: ${loginRes.data.token ? '✓ Received' : '✗ Not received'}\n`);

    // Test 3: Duplicate email
    console.log('TEST 3: Duplicate Email (should fail)');
    const dupRes = await makeRequest('POST', '/api/auth/register', {
      email: 'test@example.com',
      password: 'Different@123',
      firstName: 'Jane',
      lastName: 'Doe',
    });
    console.log(`Status: ${dupRes.status}`);
    console.log(`Message: ${dupRes.data.message || dupRes.data}\n`);

    // Test 4: Wrong password
    console.log('TEST 4: Wrong Password (should fail)');
    const wrongRes = await makeRequest('POST', '/api/auth/login', {
      email: 'test@example.com',
      password: 'WrongPassword123',
    });
    console.log(`Status: ${wrongRes.status}`);
    console.log(`Message: ${wrongRes.data.message || wrongRes.data}\n`);

    console.log('=== ALL TESTS COMPLETED ===');
  } catch (err) {
    console.error('Test Error:', err.message);
  }
}

runTests();
