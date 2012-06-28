var CoffeeScript = require('coffee-script');
var App          = require('./src/start');
var Fs           = require('fs')

config = JSON.parse(Fs.readFileSync(__dirname + '/config.json'))

app = new App(config)

app.on('run', app.run)

setInterval(function() {
  app.emit('run') }
  , config.interval * 1000
)

console.log("Pingmeister started with " + config.interval + " seconds runs")
