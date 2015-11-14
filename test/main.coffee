
should = require 'should'
fs = require 'fs'
express = require 'express'
bodyParser = require 'body-parser'

Crud = require('./crud')
Retrieval = require('./retrieval')

port = process.env.PORT || 3333
process.env.NODE_ENV = 'devel'

g =
  user:
    email: '112'
    groups: []


# entry ...
describe "app", ->

  # init server
  app = express()
  app.use(bodyParser.json())

  g.Index = require "../index"

  g.cls = new g.Index('url')
  g.baseurl = '/items'
  g.cls.initExpressApp(app, g.baseurl)

  server = null

  before (done) ->
    server = app.listen port, (err) ->
      return done(err) if err
      done()

  after (done) ->
    server.close()
    done()

  # run the rest of tests
  g.url = "http://localhost:#{port}#{g.baseurl}"

  Crud(g)
  Retrieval(g)
