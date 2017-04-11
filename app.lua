box.cfg({})

box.once('counters', function() 

  box.schema.space.create('counters')

  box.space.counters:create_index('primary', {
    unique = true,
    type = 'hash',
    parts = {1, 'str'}
  })

end)

local uuid = box.info().server.uuid

local function handler(self)
  box.space.counters:upsert({self.peer.host, 0}, {{'+', 2, 1}})
  return self:render{ json = { 
    counter = box.space.counters:get(self.peer.host)[2],
    server = uuid
  }}
end

local server = require('http.server').new(os.Host, 8000)
server:route({ path = '/' }, handler)
server:start()
