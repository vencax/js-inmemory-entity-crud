
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

  it "shall list items (with desired attrs)", (done) ->

    request.get
      url: "#{g.url}?name=#{g.data[1].name}"
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.length.should.eql 1
      body[0].should.be.eql g.data[1]
      done()
