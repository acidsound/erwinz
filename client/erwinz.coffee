@vis = null
@idx = 0

Meteor.startup ->
  @vis = d3.select("svg")
    .attr("width", 960)
    .attr("height", 500)

@dragmove= (d,i)->
  console.log d.x, d.y

_.extend Template.main,
  events:
    'click #addBox': ->
      Entities.insert 
        v:++idx
        name: "#box#{idx}"
        height: 100
        width: 100
        x: 10
        y: 10
  rendered:->
    drawEntity = (rect)->
      vis.append("g").append("rect")
      .attr("name", "box#{rect.v}")
      .attr("x", rect.x)
      .attr("y", rect.y)
      .attr("width", rect.width)
      .attr("height", rect.height)
      .attr("stroke", "#000000")
      .attr("stroke-width", 1)
      .attr("fill", "#fff")
      .attr("cursor", "default")
      .attr("_id", rect._id)
      .call(d3.behavior.drag().on("drag", (d)->
          x= parseFloat(d3.select(@).attr("x")) + d3.event.dx
          y= parseFloat(d3.select(@).attr("y")) + d3.event.dy
          id= d3.select(@).attr("_id")
          d3.select(@).style "fill", "#855"
          d3.select(@).attr("x", x)
          d3.select(@).attr("y", y)
          Entities.update d3.select(@).attr("_id"),
            $set:
              x: x
              y: y
#          if d3.select("[data-source=#{@id}]")[0][0]
#            d3.select("[data-source=#{@id}]").attr("stroke", "#008")
#            d3.select("[data-source=#{@id}]").attr("x1", parseFloat(d3.select("[data-source=#{@id}]").attr("x1")) + d3.event.dx)
#            d3.select("[data-source=#{@id}]").attr("y1", parseFloat(d3.select("[data-source=#{@id}]").attr("y1")) + d3.event.dy)
#          if d3.select("[data-dest=#{@id}]")[0][0]
#            d3.select("[data-dest=#{@id}]").attr("stroke", "#008")
#            d3.select("[data-dest=#{@id}]").attr("x2", parseFloat(d3.select("[data-dest=#{@id}]").attr("x2")) + d3.event.dx)
#            d3.select("[data-dest=#{@id}]").attr("y2", parseFloat(d3.select("[data-dest=#{@id}]").attr("y2")) + d3.event.dy)
          d3.select(@).attr("cursor", "move")
        ).on("dragend", ->
#          if d3.select("[data-source=#{@id}]")[0][0]
#            d3.select("[data-source=#{@id}]").attr("stroke", "#800")
#          d3.select("[data-dest=#{@id}]").attr("stroke", "#800")
          d3.select(@).style "fill", "#fff"
          d3.select(@).attr("cursor", "default")
        ))
    boxes = Entities.find().observe
      added: (item)->
        drawEntity item
      changed: (item)->
        d3.select("[_id=#{item._id}]").attr("x", item.x).attr("y", item.y)

    boxes = boxes.count and boxes.fetch() or [{}]
    boxes.reduce (v1, v2)->
      vis.append("g").append("line")
      .attr("id", "line#{v2}")
      .attr("data-source", "box#{v1.v}")
      .attr("data-dest", "box#{v2.v}")
      .attr("x1", v1.x + v1.width/2)
      .attr("y1", v1.y + v1.height/2)
      .attr("x2", v2.x + v2.width/2)
      .attr("y2", v2.y + v2.height/2)
      .attr("stroke", "#800")
      .attr("stroke-width", 1)
      .attr("class", "link")
      v2
