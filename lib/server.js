const express = require("express");
const app = express();
const port = 3000;

app.get("/books", (req, res) => {
  res.json({
    items: [
      {
        title: "Time Enough For Love",
        author: "Robert A. Heinlein",
      },
    ],
  });
});

module.exports = app.listen(port);
