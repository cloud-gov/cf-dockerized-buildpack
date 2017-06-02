var express = require('express')
var app = express()
var port = process.env.PORT

app.get('/', function (req, res) {
    res.send('Hello World! I am running on port ' + port)
})

app.listen(port, function () {
    console.log('Example app listening on port ' + port)
})
