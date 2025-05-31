const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();
const { authenticateAdmin } = require('../middleware/auth');
const router = express.Router();

// Database connection
const db = new sqlite3.Database(process.env.DB_PATH);

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.resolve(__dirname, process.env.UPLOAD_DIR);
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const filename = file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname);
    cb(null, filename);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Only PDF files are allowed!'), false);
    }
  }
});

// Get all PDFs
router.get('/', (req, res) => {
  const query = `
    SELECT id, title, filename, description, file_size, uploaded_at, download_count, view_count
    FROM pdfs 
    ORDER BY uploaded_at DESC
  `;
  
  db.all(query, [], (err, rows) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    res.json(rows);
  });
});

// Get single PDF metadata
router.get('/:id', (req, res) => {
  const { id } = req.params;
  
  const query = `
    SELECT id, title, filename, description, file_size, uploaded_at, download_count, view_count
    FROM pdfs 
    WHERE id = ?
  `;
  
  db.get(query, [id], (err, row) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    
    if (!row) {
      return res.status(404).json({ error: 'PDF not found' });
    }
    
    res.json(row);
  });
});

// Serve PDF file
router.get('/file/:filename', (req, res) => {
  const { filename } = req.params;
  const filePath = path.resolve(__dirname, process.env.UPLOAD_DIR, filename);
  
  // Check if file exists
  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'File not found' });
  }
  
  // Increment view count
  const updateQuery = 'UPDATE pdfs SET view_count = view_count + 1 WHERE filename = ?';
  db.run(updateQuery, [filename], (err) => {
    if (err) {
      console.error('Error updating view count:', err);
    }
  });
  
  // Set appropriate headers
  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `inline; filename="${encodeURIComponent(filename)}"`);
  
  // Stream the file
  const fileStream = fs.createReadStream(filePath);
  
  // Handle stream errors
  fileStream.on('error', (streamErr) => {
    console.error('File stream error:', streamErr);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Error reading file' });
    }
  });
  
  fileStream.pipe(res);
});

// Download PDF file
router.get('/download/:filename', (req, res) => {
  const { filename } = req.params;
  const filePath = path.resolve(__dirname, process.env.UPLOAD_DIR, filename);
  
  // Check if file exists
  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'File not found' });
  }
  
  // Increment download count
  const updateQuery = 'UPDATE pdfs SET download_count = download_count + 1 WHERE filename = ?';
  db.run(updateQuery, [filename], (err) => {
    if (err) {
      console.error('Error updating download count:', err);
    }
  });
  
  // Get original title for download filename
  const getQuery = 'SELECT title FROM pdfs WHERE filename = ?';
  db.get(getQuery, [filename], (err, row) => {
    let downloadName = filename;
    if (!err && row && row.title) {
      // Sanitize the title for use as filename
      const sanitizedTitle = row.title.replace(/[^a-zA-Z0-9\s\-_\.]/g, '').trim();
      downloadName = sanitizedTitle ? `${sanitizedTitle}.pdf` : filename;
    }
    
    // Set download headers
    res.setHeader('Content-Type', 'application/pdf');
    
    // Properly encode filename for Content-Disposition header
    const encodedFilename = encodeURIComponent(downloadName);
    res.setHeader('Content-Disposition', `attachment; filename*=UTF-8''${encodedFilename}`);
    
    // Stream the file
    const fileStream = fs.createReadStream(filePath);
    
    // Handle stream errors
    fileStream.on('error', (streamErr) => {
      console.error('File stream error:', streamErr);
      if (!res.headersSent) {
        res.status(500).json({ error: 'Error reading file' });
      }
    });
    
    fileStream.pipe(res);
  });
});

// Upload PDF (Admin only)
router.post('/upload', authenticateAdmin, upload.single('pdf'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    
    const { title, description } = req.body;
    
    if (!title) {
      // Delete uploaded file if title is missing
      fs.unlinkSync(req.file.path);
      return res.status(400).json({ error: 'Title is required' });
    }
    
    // Insert PDF metadata into database
    const insertQuery = `
      INSERT INTO pdfs (title, filename, description, file_size)
      VALUES (?, ?, ?, ?)
    `;
    
    db.run(insertQuery, [title, req.file.filename, description || '', req.file.size], function(err) {
      if (err) {
        console.error('Database error:', err);
        // Delete uploaded file on database error
        fs.unlinkSync(req.file.path);
        return res.status(500).json({ error: 'Database error' });
      }
      
      res.status(201).json({
        message: 'PDF uploaded successfully',
        pdf: {
          id: this.lastID,
          title,
          filename: req.file.filename,
          description: description || '',
          file_size: req.file.size
        }
      });
    });
    
  } catch (error) {
    console.error('Upload error:', error);
    if (req.file) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ error: 'Upload failed' });
  }
});

// Delete PDF (Admin only)
router.delete('/:id', authenticateAdmin, (req, res) => {
  const { id } = req.params;
  
  // First get the filename to delete the file
  const getQuery = 'SELECT filename FROM pdfs WHERE id = ?';
  db.get(getQuery, [id], (err, row) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    
    if (!row) {
      return res.status(404).json({ error: 'PDF not found' });
    }
    
    // Delete from database
    const deleteQuery = 'DELETE FROM pdfs WHERE id = ?';
    db.run(deleteQuery, [id], function(err) {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      
      // Delete file from filesystem
      const filePath = path.resolve(__dirname, process.env.UPLOAD_DIR, row.filename);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
      
      res.json({ message: 'PDF deleted successfully' });
    });
  });
});

module.exports = router;