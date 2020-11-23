const express = require("express");
const axios = require("axios");

const router = express.Router();

const { User } = require("../../models/User");
const { Motion } = require("../../models/Motion");

router.get("/test", (_req, res) => res.json({ message: "Users works" }));

router.get("/", async (_req, res) => {
  const Users = await User.find();
  return res.json(Users);
});

router.post("/register", async (req, res) => {
  const UserCount = await User.count();
  const User = new User({
    ...req.body,
  });

  try {
    const result = await User.save();
    return res.json(result);
  } catch (e) {
    return res.status(500).json(e);
  }
});

router.get("/all", async (req, res) => {
  try {
    const Users = await User.find();
    return res.json(Users);
  } catch (e) {
    return res.sendStatus(500);
  }
});

router.post("/isRegistered", async (req, res) => {
  const { phoneNumber } = req.body;

  const User = await User.findOne({ phoneNumber });

  if (!User) {
    return res.status(404).json({ message: "User not found" });
  }

  return res.json({ firstName: User.firstName });
});

router.post("/authVerify", async (req, res) => {
  const { phoneNumber } = req.body;

  const User = await User.findOne({ phoneNumber });

  if (!User) {
    return res.status(404);
  }

  return res.sendStatus(200);
});

module.exports = router;

