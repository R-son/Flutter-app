const db = require('./database');

const initialData = [
  {
    id: 1,
    name: "Books",
    items: [
      {
        name: "Death Note",
        description: "Don't write your name inside of it...",
        rating: 4.5,
        image: "/uploads/DeathNote.jpg",
      },
    ],
  },
  {
    id: 2,
    name: "Movies",
    items: [
      {
        name: "Deadpool & Wolverine",
        description: "Those moves tho",
        rating: 4.9,
        image: "/uploads/Deadpool_and_Wolverine.jpeg",
      },
    ],
  },
  {
    id: 3,
    name: "Comic Books",
    items: [
      {
        name: "Rogue Sun",
        description: "Great comic, would definitely recommend",
        rating: 5.0,
        image: "/uploads/RogueSun.jpg",
      },
    ],
  },
  {
    id: 4,
    name: "Mangas",
    items: [
      {
        name: "Dragon Ball",
        description: "THE GOAT of mangas",
        rating: 5.0,
        image: "/uploads/DragonBall.jpg",
      },
    ],
  },
  {
    id: 5,
    name: "Manwhas",
    items: [
      {
        name: "Solo Leveling",
        description: "Okiro...",
        rating: 5.0,
        image: "/uploads/SoloLeveling.jpg",
      },
    ],
  },
];

function clearDatabase() {
  return new Promise((resolve, reject) => {
    db.exec(
      `
      DELETE FROM items;
      DELETE FROM categories;
    `,
      (err) => {
        if (err) reject(err);
        else resolve();
      }
    );
  });
}

async function seedDatabase() {
  try {
    console.log('Clearing existing database...');
    await clearDatabase();
    console.log('Database cleared.');

    console.log('Seeding new data...');
    initialData.forEach((category) => {
      db.run(
        `INSERT OR IGNORE INTO categories (id, name) VALUES (?, ?)`,
        [category.id, category.name],
        function (err) {
          if (err) {
            console.error(`Error inserting category ${category.name}:`, err.message);
          } else {
            category.items.forEach((item) => {
              db.run(
                `INSERT INTO items (category_id, name, description, rating, image) VALUES (?, ?, ?, ?, ?)`,
                [category.id, item.name, item.description, item.rating, item.image],
                (err) => {
                  if (err) {
                    console.error(`Error inserting item ${item.name}:`, err.message);
                  }
                }
              );
            });
          }
        }
      );
    });

    console.log('Database seeded successfully.');
  } catch (error) {
    console.error('Error during database seeding:', error.message);
  } finally {
    db.close();
  }
}

seedDatabase();