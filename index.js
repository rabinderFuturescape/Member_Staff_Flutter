const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Member Staff API' });
});

// Member routes placeholder
app.get('/api/members', (req, res) => {
  res.json({ message: 'Members API endpoint' });
});

// Staff routes placeholder
app.get('/api/staff', (req, res) => {
  res.json({ message: 'Staff API endpoint' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
