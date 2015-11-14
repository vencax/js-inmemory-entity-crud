
should = require 'should'
request = require 'request'


module.exports = (g) ->

  g.data = [
    name: "iPhone 4 32GB černý"
    url: "iphone-4-32gb-cerny"
    perex: 'rand',
    photo: {"src":"/img/350x300.gif","width":350,"heigth":300},
    producer: "Apple",
    availability: "skladem",
    price: 15000
  ,
    name: "iPhone 3 32GB hnedy"
    url: "iphone-3-32gb-hnedy"
    perex: 'rand',
    photo: {"src":"/img/350x300.gif","width":350,"heigth":300},
    producer: "Apple",
    availability: "skladem",
    price: 3000
  ]

  g.new =
    name: "iPhone 13 1GB hnedy"
    url: "iphone-13-1gb-hnedy"
    perex: 'rand',
    photo: {"src":"/img/350x300.gif","width":350,"heigth":300},
    producer: "Apple",
    availability: "skladem",
    price: 7000

  for i in g.data
    g.cls.add i

  it "shall get first data item", (done) ->
    request.get "#{g.url}/#{g.data[0].url}", (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body = JSON.parse(body)
      body.url.should.eql g.data[0].url
      body.name.should.eql g.data[0].name
      body.price.should.eql g.data[0].price
      done()

  it "shall create a new item", (done) ->
    request
      url: g.url
      body: g.new
      json: true,
      method: 'post'
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 201
      body.url.should.eql g.new.url
      body.name.should.eql g.new.name
      body.price.should.eql g.new.price
      done()

  it "shall list films (only basic info)", (done) ->

    request.get
      url: g.url
      json: true
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.length.should.eql 3
      done()

  it "shall update the new item", (done) ->

    change =
      name: 'gandalf'
      price: 123

    request
      url: "#{g.url}/#{g.new.url}"
      body: change
      json: true,
      method: 'put'
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.name.should.eql change.name
      body.price.should.eql change.price
      done()

  it "shall delete the new item", (done) ->
    request
      url: "#{g.url}/#{g.new.url}"
      method: 'delete'
    , (err, res, body) ->
      return done(err) if err
      console.log body
      res.statusCode.should.eql 200
      done()

  it "shall automaticly generate id", (done) ->
    c = new g.Index('id')
    data =
      name: "iPhone 4 32GB černý"
      url: "iphone-4-32gb-cerny"
    newItem = c.add data

    should.exists newItem.id
    done()
