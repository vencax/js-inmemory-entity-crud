_ = require('lodash')
EventEmitter = require('events')

class EntityStorageMock extends EventEmitter

  constructor: (idFieldName) ->
    super("EntityStorageMock")
    @fId = idFieldName
    @nextId = 0
    @items = {}

  randomAttr: (attName, id, len=8) ->
    return "#{attName} value for #{id}; #{Math.random().toString(len)}"

  add: (item) ->
    if item[@fId] == undefined
      item[@fId] = @nextId
      @nextId++
    for k, v of item
      item[k] = @randomAttr(k, item[@fId]) if v == 'rand'
    @items[item[@fId]] = item
    @emit('add', item)
    return item

  remove: (id) ->
    item = @items[id]
    delete @items[id]
    @emit('remove', item)

  list: (attrs, filter) ->
    _match = (item)->
      for k, v of filter
        if item[k] != v
          return false
      return true

    rv = []
    for id, i of @items
      if filter
        continue if not _match(i)
      if attrs
        rv.push(_.pick(i, attrs))
      else
        rv.push(i)
    return rv

  get: (id, attrs) ->
    return _.pick(@items[id], attrs) if attrs
    return @items[id]

  update: (id, vals) ->
    item = @items[id]
    for k, v of vals
      item[k] = v
    @emit('update', item)
    return item

  exists: (id) ->
    return id of @items

  initExpressApp: (app, url)->
    self = this

    app.get url, (req, res) ->
      if req.query.attrs != undefined
        try
          attrs = req.query.attrs.split(',')
        delete req.query.attrs
      filter = req.query # the rest of query is filter
      res.json(self.list(attrs, filter))

    app.post url, (req, res) ->
      newItem = self.add(req.body)
      res.status(201).json(newItem)

    app.get "#{url}/:id", (req, res) ->
      return res.status(404).end() if not self.exists(req.params.id)
      try
        attrs = req.query.attrs.split(',')
      catch
        attrs = undefined
      res.json(self.get(req.params.id, attrs))

    app.put "#{url}/:id", (req, res) ->
      return res.status(404).end() if not self.exists(req.params.id)
      updated = self.update(req.params.id, req.body)
      res.json(updated)

    app.delete "#{url}/:id", (req, res) ->
      return res.status(404).end() if not self.exists(req.params.id)
      self.remove(req.params.id)
      res.status(200).end()

module.exports = EntityStorageMock
