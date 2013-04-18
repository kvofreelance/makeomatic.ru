###
  Dependencies
###
express        = require 'express'
dot            = require 'express-dot'
async          = require 'async'
_              = require 'underscore'
lessMiddleware = require 'less-middleware'
conf           = require './conf'
util           = require 'util'


app  = express()
root = __dirname

###
  start the app
###


startApp = ->

  app.configure ->
    #shared settings
    app.set 'env', process.env.NODE_ENV || 'development'
    app.engine 'dot', dot.__express
    # view settings
    app.set 'views'       , "#{root}/views"
    app.set 'view engine' , 'dot'

    app.use express.static "#{root}/../static"

    app.use express.methodOverride()
    app.use express.bodyParser {uploadDir: "#{root}/../tmp"}
    app.use app.router


  app.configure "production", ->
    app.set 'port', 80
    app.set 'host', '127.0.0.1'

    app.use express.errorHandler
      dumpExceptions: false
      showStack: false

    app.use (req, res, next) ->
      res.render '404', {layout: false}, 404

    app.use (err,req,res,next) ->
      # custom error page
      console.error err
      res.send "Error", 500

  app.configure "development", ->
    app.set 'port', process.env.PORT || 9100
    app.set 'host', '0.0.0.0'
    app.use (req, res, next) ->
      res.render '404', {layout: false}, 404
    app.use express.errorHandler
      dumpExceptions: true
      showStack: true


  ###
    Enable routes
  ###
  require('./router')(app)



  app.listen app.get('port'), app.get('host')
  util.log(util.format('ENV: %s, listening on http://%s:%s', app.get('env'), app.get('host'), app.get('port')));


###
  Export app for some further use
###

startApp()