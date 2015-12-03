_ = require('lodash')
EventEmitter = require('events')

class EntityStorageMock extends EventEmitter

  constructor: (idFieldName, autoIdGenerator) ->
    super("EntityStorageMock")
    @fId = idFieldName
    @nextId = 0
    @items = {}
    @autoIdGenerator = autoIdGenerator || (item)->
      item[@fId] = @nextId
      @nextId++

  randomAttr: (attName, id, len=8) ->
    return "#{attName} value for #{id}; #{Math.random().toString(len)}"

  add: (item) ->
    if item[@fId] == undefined
      @autoIdGenerator(item)

    for k, v of item
      item[k] = @randomAttr(k, item[@fId]) if v == 'rand'

    if item.parent and @items[item.parent]
      parent = @items[item.parent]
      parent.children = [] if not parent.children
      parent.children.push item
    else
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
      try
        if req.query.attrs != undefined
          attrs = req.query.attrs.split(',')
        if req.query.filter != undefined
          filter = {}
          for i in req.query.filter.split('@')
            parts = i.split(':')
            filter[parts[0]] = parts[1]
        if req.query.limit != undefined
          limit = parseInt(req.query.limit)
        if req.query.offset != undefined
          offset = parseInt(req.query.offset)
        if req.query.order != undefined
          order = req.query.order
      catch e
        return res.status(400).send("wrong params: #{e}")

      results = self.list(attrs, filter)
      if limit or offset
        begin = offset || 0
        if limit
          end = offset + limit
          results = _.slice(results, begin, end)
        else
          results = _.slice(results, begin)
      if order
        results.sort (a, b)->
          a[order] > b[order]

      res.json(results)

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
