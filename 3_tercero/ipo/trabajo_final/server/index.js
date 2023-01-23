require('dotenv').config()
const session = require('express-session')
const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')
const MongoDBStore = require('connect-mongodb-session')(session)
const loginRouter = require('./routes/loginRoutes')
const bodyParser = require("body-parser");

const app = express()
const MAX_AGE = 1000 * 60 * 60 * 3 // 3hrs
const port = process.env.PORT || 5000

const corsOptions = {
  origin: 'http://localhost:3000',
  optionsSuccessStatus: 200,
}

mongoose.Promise = global.Promise
mongoose.connect(process.env.DATABASE_CONNECTION_STRING, {
  useNewUrlParser: true,
})

// setting up connect-mongodb-session store
const mongoDBstore = new MongoDBStore({
  uri: process.env.DATABASE_CONNECTION_STRING,
  collection: 'mySessions',
})

app.use(
  session({
    secret: process.env.SECRET,
    name: 'session-id', // cookies name to be put in "key" field in postman
    store: mongoDBstore,
    cookie: {
      maxAge: MAX_AGE, // this is when our cookies will expired and the session will not be valid anymore (user will be log out)
      sameSite: false,
      secure: false,
    },
    resave: true,
    saveUninitialized: false,
  })
)

app.use(cors(corsOptions))

// Bodyparser middleware
app.use(
  bodyParser.urlencoded({
    extended: false,
  })
);
app.use(bodyParser.json());

// ROUTERS
app.use('/api', loginRouter)

// START SERVER
app.listen(port, () => {
  console.log(`Server listening on port ${port}`)
})

module.exports = app
