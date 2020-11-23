const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const MotionSchema = new Schema({
  user: {
    type: Schema.Types.ObjectId,
    ref: "User"
  },
  rating: {
    type: Number,
    required: true
  },
  motionType: {
    type: String,
    default: 'practice'
  },
  date: {
    type: Date,
    default: Date.now()
  }
});

module.exports = {
  Motion: mongoose.model("Motions", MotionSchema)
};
