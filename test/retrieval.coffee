
should = require 'should'
request = require 'request'


module.exports = (g) ->

  it "shall list items (only desired attrs)", (done) ->

    request.get
      url: "#{g.url}?attrs=name,price"
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.length.should.eql 2
      Object.keys(body[0]).should.be.eql ['name', 'price']
      done()

  it "shall get desired item (with desired attrs)", (done) ->

    request.get
      url: "#{g.url}/#{g.data[1].url}?attrs=name,perex"
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      Object.keys(body).should.be.eql ['name', 'perex']
      body.should.be.eql
        name: g.data[1].name
        perex: g.data[1].perex
      done()

  it "shall list items with desired name", (done) ->

    request.get
      url: "#{g.url}?filter=name:#{g.data[1].name}"
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.length.should.eql 1
      body[0].should.be.eql g.data[1]
      done()

  it "shall list items from 1-", (done) ->

    g.third =
      name: "ajPhone"
      url: "ajphone"
      perex: 'rand',
      photo: {"src":"/img/350x300.gif","width":350,"heigth":300},
      producer: "Apple",
      availability: "skladem",
      price: 30000
    g.cls.add g.third

    request.get
      url: "#{g.url}?offset=1"
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.length.should.eql 2
      body[0].should.be.eql g.data[1]
      done()

  it "shall list items from 1-2", (done) ->

    request.get
      url: "#{g.url}?offset=1&limit=1"
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.length.should.eql 1
      body[0].should.be.eql g.data[1]
      done()

  it "shall list items ordered by price", (done) ->

    request.get
      url: "#{g.url}?order=price"
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.length.should.eql 3
      body[0].should.be.eql g.data[1]
      body[1].should.be.eql g.data[0]
      body[2].should.be.eql g.third
      done()

  it "shall list items ordered by name", (done) ->

    request.get
      url: "#{g.url}?order=name"
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.length.should.eql 3
      body[0].should.be.eql g.third
      done()
