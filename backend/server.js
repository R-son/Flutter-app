const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const multer = require("multer");
const path = require("path");
const db = require("./database");
const { exec } = require("child_process");

// Function to execute seed.js
function runSeedScript() {
  exec("node seed.js", (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing seed.js: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`stderr: ${stderr}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
  });
}

// Run the seed script
runSeedScript();

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage: storage });

// let categories = [
//   { id: 1, name: "Books", items: [{ name: "Death Note", description: "Don't write your name inside of it...", rating: 4.5, image: "uploads/" }] },
//   { id: 2, name: "Movies", items: [{ name: "Deadpool & Wolverine", description: "Those moves tho", rating: 4.9, image: null }] },
//   { id: 3, name: "Comic Books", items: [{ name: "Rogue Sun", description: "Great comic, would definitely recommend", rating: 5.0, image: null }] },
//   { id: 4, name: "Mangas", items: [{ name: "Dragon Ball", description: "THE GOAT of mangas", rating: 5.0, image: null }] },
//   { id: 5, name: "Manwhas", items: [{ name: "Solo Leveling", description: "Okiro...", rating: 5.0, image: null }] }
// ];

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.get("/search", (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: "Query parameter is required" });
  }

  db.all(
    `SELECT items.*, categories.name AS category 
     FROM items 
     JOIN categories ON items.category_id = categories.id 
     WHERE items.name LIKE ? OR items.description LIKE ?`,
    [`%${query}%`, `%${query}%`],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: "Failed to search items" });
      }
      res.json(rows);
    }
  );
});

app.put("/update-item/:id", (req, res) => {
  const { id } = req.params;
  const { name, description, rating, image } = req.body;

  if (!name || !description || typeof rating === "undefined") {
    return res.status(400).json({ error: "All fields are required" });
  }

  db.run(
    `UPDATE items SET name = ?, description = ?, rating = ?, image = ? WHERE id = ?`,
    [name, description, parseFloat(rating), image || null, id],
    function (err) {
      if (err) {
        return res.status(500).json({ error: "Failed to update item" });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: "Item not found" });
      }
      res.status(200).json({ message: "Item updated successfully" });
    }
  );
});

app.get("/categories", (req, res) => {
  db.all("SELECT id, name FROM categories", [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: "Failed to fetch categories" });
    }
    res.json(rows);
  });
});

app.post("/update-rating", (req, res) => {
  const { id, userRating } = req.body;

  // Validate input
  if (
    !id ||
    typeof userRating !== "number" ||
    userRating < 0 ||
    userRating > 5
  ) {
    return res.status(400).json({ error: "Invalid data" });
  }

  // Fetch current rating and rating count
  db.get(
    `SELECT rating, rating_count FROM items WHERE id = ?`,
    [id],
    (err, row) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: "Failed to fetch item rating" });
      }
      if (!row) {
        return res.status(404).json({ error: "Item not found" });
      }

      const currentRating = row.rating;
      const currentRatingCount = row.rating_count;

      // Calculate the new rating
      const newRatingCount = currentRatingCount + 1;
      const newRating =
        (currentRating * currentRatingCount + userRating) / newRatingCount;

      // Update the item with the new rating and rating count
      db.run(
        `UPDATE items SET rating = ?, rating_count = ? WHERE id = ?`,
        [newRating, newRatingCount, id],
        (updateErr) => {
          if (updateErr) {
            return res.status(500).json({ error: "Failed to update rating" });
          }
          res.json({ message: "Rating updated successfully", newRating });
        }
      );
    }
  );
});

app.post("/add-item", upload.single("image"), (req, res) => {
  const { category, name, description, rating } = req.body;
  console.log(req.body);
  const image = req.file ? `/uploads/${req.file.filename}` : null;

  if (
    !category ||
    !name ||
    !description ||
    typeof rating === "undefined" ||
    !image
  ) {
    return res
      .status(400)
      .json({ error: "All fields are required, including an image" });
  }

  db.get("SELECT id FROM categories WHERE name = ?", [category], (err, row) => {
    if (err || !row) {
      return res.status(404).json({ error: "Category not found" });
    }

    const categoryId = row.id;
    db.run(
      `INSERT INTO items (category_id, name, description, rating, image) VALUES (?, ?, ?, ?, ?)`,
      [categoryId, name, description, parseFloat(rating), image],
      function (err) {
        if (err) {
          return res.status(500).json({ error: "Failed to add item" });
        }
        res
          .status(200)
          .json({ message: "Item added successfully", itemId: this.lastID });
      }
    );
  });
});

app.delete("/delete-item/:id", (req, res) => {
  const { id } = req.params;

  if (!id) {
    return res.status(400).json({ error: "Item ID is required" });
  }

  db.run(`DELETE FROM items WHERE id = ?`, [id], function (err) {
    if (err) {
      return res.status(500).json({ error: "Failed to delete item" });
    }
    if (this.changes === 0) {
      return res.status(404).json({ error: "Item not found" });
    }
    res.status(200).json({ message: "Item deleted successfully" });
  });
});

app.post("/add-category", (req, res) => {
  const { name } = req.body;

  if (!name) {
    return res.status(400).json({ error: "Category name is required" });
  }

  db.run(`INSERT INTO categories (name) VALUES (?)`, [name], function (err) {
    if (err) {
      if (err.message.includes("UNIQUE constraint")) {
        return res.status(400).json({ error: "Category already exists" });
      }
      return res.status(500).json({ error: "Failed to add category" });
    }
    res
      .status(201)
      .json({ message: "Category added successfully", id: this.lastID });
  });
});

app.put("/update-category/:id", (req, res) => {
  const { id } = req.params;
  const { name } = req.body;

  if (!name) {
    return res.status(400).json({ error: "Category name is required" });
  }

  db.run(
    `UPDATE categories SET name = ? WHERE id = ?`,
    [name, id],
    function (err) {
      if (err) {
        return res.status(500).json({ error: "Failed to update category" });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: "Category not found" });
      }
      res.status(200).json({ message: "Category updated successfully" });
    }
  );
});

app.delete("/delete-category/:id", (req, res) => {
  const { id } = req.params;

  if (!id) {
    return res.status(400).json({ error: "Category ID is required" });
  }

  db.run(`DELETE FROM items WHERE category_id = ?`, [id], function (err) {
    if (err) {
      return res
        .status(500)
        .json({ error: "Failed to delete items for the category" });
    }

    db.run(`DELETE FROM categories WHERE id = ?`, [id], function (err) {
      if (err) {
        return res.status(500).json({ error: "Failed to delete category" });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: "Category not found" });
      }
      res
        .status(200)
        .json({
          message: "Category and associated items deleted successfully",
        });
    });
  });
});

app.get("/items", (req, res) => {
  const { category } = req.query;

  if (category) {
    db.get(
      "SELECT id FROM categories WHERE name = ?",
      [category],
      (err, row) => {
        if (err || !row) {
          return res.status(404).json({ error: "Category not found" });
        }

        const categoryId = row.id;
        db.all(
          "SELECT * FROM items WHERE category_id = ?",
          [categoryId],
          (err, rows) => {
            if (err) {
              return res.status(500).json({ error: "Failed to fetch items" });
            }
            res.json(rows);
          }
        );
      }
    );
  } else {
    db.all("SELECT * FROM items", (err, rows) => {
      if (err) {
        return res.status(500).json({ error: "Failed to fetch items" });
      }
      res.json(rows);
    });
  }
});

app.get("/top-rated", (req, res) => {
  db.all(
    `SELECT items.*, categories.name AS category 
     FROM items 
     JOIN categories ON items.category_id = categories.id 
     ORDER BY rating DESC 
     LIMIT 5`,
    [],
    (err, rows) => {
      if (err) {
        return res
          .status(500)
          .json({ error: "Failed to fetch top-rated items" });
      }
      res.json(rows);
    }
  );
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Server is running on http://localhost:${port}`);
});
