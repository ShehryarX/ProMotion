const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const userSchema = new Schema({
  firstName: {
    type: String,
    required: true
  },
  lastName: {
    type: String,
    required: true
  },
  phoneNumber: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    default: Date.now()
  },
  friendList: {
    type: Array,
    required: true
  },
  challengeList: {
    type: Array,
    required: true
  },
  practiceList: {
    type: Array,
    required: true
  },
  password: {
    type: String,
    required: true
  }

});

module.exports = {
  user: mongoose.model("", userSchema)
};
