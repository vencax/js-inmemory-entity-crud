

class EntityStorageMock

  constructor: (idFieldName) ->
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
      v = @randomAttr(k, item[@fId]) if v == 'rand'
    @items[item[@fId]] = item

  remove: (id) ->
    delete @items[id]

  list: () ->
    return (v for k, v of @items)

  get: (id) ->
    return @items[id]

  update: (id, vals) ->
    for k, v of vals
      @items[id][k] = v
    return @items[id]

  exists: (id) ->
    return id of @items

  initExpressApp: (app, url)->

    self = this

    app.get url, (req, res) ->
      res.json(self.list())

    app.post url, (req, res) ->
      newItem = self.add(req.body)
      res.status(201).json(newItem)

    app.get "#{url}/:id", (req, res) ->
      return res.status(404).end() if not self.exists(req.params.id)
      res.json(self.get(req.params.id))

    app.put "#{url}/:id", (req, res) ->
      return res.status(404).end() if not self.exists(req.params.id)
      updated = self.update(req.params.id, req.body)
      res.json(updated)

    app.delete "#{url}/:id", (req, res) ->
      return res.status(404).end() if not self.exists(req.params.id)
      self.remove(req.params.id)
      res.status(200).end()

module.exports = EntityStorageMock
