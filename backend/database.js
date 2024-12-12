const sqlite3 = require('sqlite3').verbose();

const db = new sqlite3.Database('./data.db', (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('Connected to SQLite database.');

    // Ensure categories table exists
    db.run(
      `CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE
      )`
    );

    // Ensure items table exists, adding rating_count if necessary
    db.run(
      `CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT,
        description TEXT,
        rating REAL DEFAULT 0,  -- Default rating to 0
        rating_count INTEGER DEFAULT 0,  -- Default rating_count to 0
        image TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )`
    );
  }
});

module.exports = db;