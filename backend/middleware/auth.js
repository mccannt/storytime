const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const authenticateAdmin = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.admin = decoded;
    next();
  } catch (error) {
    res.status(400).json({ error: 'Invalid token.' });
  }
};

const generateToken = () => {
  return jwt.sign(
    { admin: true, timestamp: Date.now() },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );
};

const verifyPassword = async (password) => {
  // For simplicity, we're using plain text comparison
  // In production, you should hash the admin password
  return password === process.env.ADMIN_PASSWORD;
};

module.exports = {
  authenticateAdmin,
  generateToken,
  verifyPassword
};