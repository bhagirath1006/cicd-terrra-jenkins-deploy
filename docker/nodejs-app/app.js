const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.get('/', (req, res) => {
  res.json({ message: 'Node.js API is running' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

function healthcheck() {
  try {
    const http = require('http');
    http.get('http://localhost:' + PORT + '/health', (res) => {
      if (res.statusCode === 200) {
        process.exit(0);
      } else {
        process.exit(1);
      }
    }).on('error', () => {
      process.exit(1);
    });
  } catch (err) {
    process.exit(1);
  }
}

module.exports = app;
