const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

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
  { id: 1, name: "Books", items: [{ name: "Death Note", description: "Don't write your name inside of it...", rating: 4.5, image: null }] },
  { id: 2, name: "Movies", items: [{ name: "Deadpool & Wolverine", description: "Those moves tho", rating: 4.9, image: null }] },
  { id: 3, name: "Comic Books", items: [{ name: "Rogue Sun", description: "Great comic, would definitely recommend", rating: 5.0, image: null }] },
  { id: 4, name: "Mangas", items: [{ name: "Dragon Ball", description: "THE GOAT of mangas", rating: 5.0, image: null }] },
  { id: 5, name: "Manwhas", items: [{ name: "Solo Leveling", description: "Okiro...", rating: 5.0, image: null }] }
];

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.get('/search', (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: "Query parameter is required" });
  }

  const allItems = categories.flatMap((category) => category.items.map((item) => ({
    ...item,
    category: category.name,
  })));

  const filteredItems = allItems.filter((item) =>
    item.name.toLowerCase().includes(query.toLowerCase()) ||
    item.description.toLowerCase().includes(query.toLowerCase())
  );

  res.json(filteredItems);
});


app.get('/categories', (req, res) => {
  res.json(categories);
});

app.post('/add-item', upload.single('image'), (req, res) => {
  const { category, name, description, rating } = req.body;
  const image = req.file ? `/uploads/${req.file.filename}` : null;

  if (!category || !name || !description || typeof rating === 'undefined' || !image) {
    return res.status(400).json({ error: "All fields are required, including an image" });
  }

  const categoryIndex = categories.findIndex((cat) => cat.name === category);
  if (categoryIndex === -1) {
    return res.status(404).json({ error: "Category not found" });
  }

  const newItem = { name, description, rating: parseFloat(rating), image };
  categories[categoryIndex].items.push(newItem);

  res.status(200).json({ message: "Item added successfully", item: newItem });
});

app.get('/items', (req, res) => {
  const { category } = req.query;

  if (!category) {
    return res.status(400).json({ error: "Category query parameter is required" });
  }

  const categoryData = categories.find((cat) => cat.name === category);
  if (!categoryData) {
    return res.status(404).json({ error: "Category not found" });
  }

  res.json(categoryData.items);
});

app.get('/top-rated', (req, res) => {
  const allItems = categories.flatMap((category) => category.items);
  const topRatedItems = allItems
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 5);
  res.json(topRatedItems);
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running on http://localhost:${port}`);
});