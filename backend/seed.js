const db = require('./database');

const categories = ["Books", "Movies", "Comic Books", "Mangas", "Manwhas"];

categories.forEach((category) => {
  db.run(
    `INSERT OR IGNORE INTO categories (name) VALUES (?)`,
    [category],
    (err) => {
      if (err) {
        console.error(`Error inserting category ${category}:`, err.message);
      }
    }
  );
});

console.log('Categories seeded successfully.');