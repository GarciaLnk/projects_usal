const UserSchema = require("../models/UserSchema");
const bcrypt = require("bcrypt");
const express = require("express");
const router = express.Router();

router.post("/register", (req, res) => {
  const { name, email, password, password2 } = req.body;

  if (!name || !email || !password || !password2)
    return res
      .status(400)
      .json({ msg: "Name, password and email are required" });

  if (password.length < 8) {
    return res
      .status(400)
      .json({ msg: "Password should be at least 8 characters long" });
  }

  if (password !== password2) {
    return res.status(400).json({ msg: "Passwords must match" });
  }

  UserSchema.findOne({ email: req.body.email }).then((user) => {
    if (user) {
      return res.status(400).json({ email: "Email already exists" });
    } else {
      const newUser = new UserSchema({
        name: req.body.name,
        email: req.body.email,
        password: req.body.password,
      });

      // Hash password before saving in database
      bcrypt.genSalt(10, (err, salt) => {
        bcrypt.hash(newUser.password, salt, (err, hash) => {
          if (err) throw err;
          newUser.password = hash;
          newUser
            .save()
            .then((user) => res.json(user))
            .catch((err) => console.log(err));
        });
      });
    }
  });
});

router.post(`/login`, (req, res) => {
  const email = req.body.email;
  const password = req.body.password;

  // Find user by email
  UserSchema.findOne({ email }).then((user) => {
    // Check if user exists
    if (!user) {
      return res.status(404).json({ emailnotfound: "Email not found" });
    }

    // Check password
    bcrypt.compare(password, user.password).then((isMatch) => {
      if (isMatch) {
        const userSession = { name: user.name, email: user.email }; // creating user session to keep user loggedin also on refresh
        req.session.user = userSession; // attach user session to session object from express-session

        return res
          .status(200)
          .json({ msg: "You have logged in successfully", userSession }); // attach user session id to the response. It will be transfer in the cookies
      } else {
        return res
          .status(400)
          .json({ passwordincorrect: "Password incorrect" });
      }
    });
  });
});

router.get("/isAuth", (req, res) => {
  if (req.session.user) {
    return res.json(req.session.user);
  } else {
    return res.status(401).json("unauthorize");
  }
});

router.delete(`/logout`, async (req, res) => {
  req.session.destroy((error) => {
    if (error) throw error;

    res.clearCookie("session-id");
    res.status(200).send("Logout Success");
  });
});

module.exports = router;
