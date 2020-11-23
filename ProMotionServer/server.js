const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const cors = require("cors");

const users = require("./routes/api/Users");
const motions = require("./routes/api/Motions");

const app = express();
const db = require("./config/keys").mongoURI; // remove keys for prod

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(cors());

mongoose
  .connect(db, { useNewUrlParser: true })
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.log(err));

app.use("/users", users);
app.use("/motions", motions);

const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`Listening to port ${port}`));
