@vis = null
@idx = 0
@guideArrow = null

Meteor.startup ->
  @vis = d3.select("svg")
  .attr("width", 960)
  .attr("height", 500)

@dragmove = (d)->
  console.log d.x, d.y

_.extend Template.main,
  events:
    'click #addBox': ->
      Entities.insert
        height: 100
        width: 100
        x: 10
        y: 10
  rendered: ->
    guideArrow = vis.append("g")
    .append("line")
    .attr("x1", 0)
    .attr("y1", 0)
    .attr("x2", 0)
    .attr("y2", 0)
    .attr("stroke", "#000000")
    .attr("stroke-width", 1)
    dragBox = (obj)->
      x = parseFloat(d3.select(obj).attr("x")) + d3.event.dx
      y = parseFloat(d3.select(obj).attr("y")) + d3.event.dy
      d3.select(obj).style "fill", "#855"
      d3.select(obj).attr("x", x)
      d3.select(obj).attr("y", y)
      Entities.update d3.select(obj).attr("_id"),
        $set:
          x: x
          y: y
      d3.select(obj).attr("cursor", "move")

    dragArrow = (obj)->
      console.log 'dragArrow'

    drawEntity = (rect)->
      vis.append("g").append("rect")
      .attr("name", "box#{rect.v}")
      .attr("class", "entity")
      .attr("x", rect.x)
      .attr("y", rect.y)
      .attr("width", rect.width)
      .attr("height", rect.height)
      .attr("_id", rect._id)
      .on("click", ->
          @
        )
      .call(d3.behavior.drag().on("drag",->
          d3.event.sourceEvent.shiftKey and dragArrow(@) or dragBox(@)
        ).on("dragend", ->
          d3.select(@).attr "fill", "#fff"
          d3.select(@).attr "cursor", "default"
        ).on("dragstart", ->
          console.log 'start', d3.event.sourceEvent.shiftKey
          d3.event.sourceEvent.shiftKey and d3.event.sourceEvent.stopPropagation()
        ))
    Entities.find().observe
      added: (item)->
        drawEntity item
      changed: (item)->
        d3.select("[_id=#{item._id}]").attr("x", item.x).attr("y", item.y)
      removed: (item)->
        d3.select("[_id=#{item._id}]").remove()