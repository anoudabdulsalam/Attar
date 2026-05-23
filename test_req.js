const http = require('http');

const data = JSON.stringify({
  email: 'admin@attar.com',
  password: 'test'
});

const options = {
  hostname: 'localhost',
  port: 5000,
  path: '/api/admin/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = http.request(options, res => {
  console.log(`statusCode: ${res.statusCode}`);
  let body = '';
  res.on('data', d => {
    body += d;
  });
  res.on('end', () => {
    console.log('Response body:', body);
  });
});

req.on('error', error => {
  console.error(error);
});

req.write(data);
req.end();
