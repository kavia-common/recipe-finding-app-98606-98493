const express = require('express')
const multer = require('multer')
const path = require('path')
const fs = require('fs')
const UPLOAD_DIR = path.resolve(__dirname, 'uploads')
fs.mkdirSync(UPLOAD_DIR, { recursive: true })
const app = express()
app.use(express.json())
app.get('/health', (_, res) => res.json({ ok: true }))
const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, UPLOAD_DIR),
  filename: (_, file, cb) => cb(null, Date.now() + '-' + file.originalname)
})
const upload = multer({ storage })
app.post('/recognize', upload.single('image'), (req, res) => {
  res.json({ status: 'stub', file: req.file ? req.file.filename : null })
})
const port = process.env.PORT || 4000
const srv = app.listen(port, () => console.log('mock api listening', port))
module.exports = srv
