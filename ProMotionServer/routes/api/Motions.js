const express = require("express");
const router = express.Router();

const { Motion } = require("../../models/Motion");

router.get("/test", (_req, res) => res.json({ message: "Motions works" }));

router.get("/", async (_req, res) => {
  const Motions = Motion.find();
  res.json(Motions);
});

router.get("/all", async (_req, res) => {
  try {
    const Motions = await Motion.find().sort({ date: -1 });
    return res.json(Motions);
  } catch (e) {
    return res.sendStatus(500);
  }
});

module.exports = router;
