const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const db = require('./database');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage: storage });

let categories = [
  { id: 1, name: "Books", items: [{ name: "Death Note", description: "Don't write your name inside of it...", rating: 4.5, image: "uploads/" }] },
  { id: 2, name: "Movies", items: [{ name: "Deadpool & Wolverine", description: "Those moves tho", rating: 4.9, image: null }] },
  { id: 3, name: "Comic Books", items: [{ name: "Rogue Sun", description: "Great comic, would definitely recommend", rating: 5.0, image: null }] },
  { id: 4, name: "Mangas", items: [{ name: "Dragon Ball", description: "THE GOAT of mangas", rating: 5.0, image: null }] },
  { id: 5, name: "Manwhas", items: [{ name: "Solo Leveling", description: "Okiro...", rating: 5.0, image: null }] }
];

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.get('/search', (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: 'Query parameter is required' });
  }

  db.all(
    `SELECT items.*, categories.name AS category 
     FROM items 
     JOIN categories ON items.category_id = categories.id 
     WHERE items.name LIKE ? OR items.description LIKE ?`,
    [`%${query}%`, `%${query}%`],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to search items' });
      }
      res.json(rows);
    }
  );
});

app.get('/categories', (req, res) => {
  db.all('SELECT id, name FROM categories', [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to fetch categories' });
    }
    res.json(rows);
  });
});


app.post('/add-item', upload.single('image'), (req, res) => {
  const { category, name, description, rating } = req.body;
  const image = req.file ? `/uploads/${req.file.filename}` : null;

  if (!category || !name || !description || typeof rating === 'undefined' || !image) {
    return res.status(400).json({ error: 'All fields are required, including an image' });
  }

  db.get('SELECT id FROM categories WHERE name = ?', [category], (err, row) => {
    if (err || !row) {
      return res.status(404).json({ error: 'Category not found' });
    }

    const categoryId = row.id;
    db.run(
      `INSERT INTO items (category_id, name, description, rating, image) VALUES (?, ?, ?, ?, ?)`,
      [categoryId, name, description, parseFloat(rating), image],
      function (err) {
        if (err) {
          return res.status(500).json({ error: 'Failed to add item' });
        }
        res.status(200).json({ message: 'Item added successfully', itemId: this.lastID });
      }
    );
  });
});

app.get('/items', (req, res) => {
  const { category } = req.query;

  if (!category) {
    return res.status(400).json({ error: 'Category query parameter is required' });
  }

  db.get('SELECT id FROM categories WHERE name = ?', [category], (err, row) => {
    if (err || !row) {
      return res.status(404).json({ error: 'Category not found' });
    }

    const categoryId = row.id;
    db.all('SELECT * FROM items WHERE category_id = ?', [categoryId], (err, rows) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to fetch items' });
      }
      res.json(rows);
    });
  });
});


app.get('/top-rated', (req, res) => {
  db.all(
    `SELECT items.*, categories.name AS category 
     FROM items 
     JOIN categories ON items.category_id = categories.id 
     ORDER BY rating DESC 
     LIMIT 5`,
    [],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to fetch top-rated items' });
      }
      res.json(rows);
    }
  );
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running on http://localhost:${port}`);
});