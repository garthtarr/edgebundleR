HTMLWidgets.widget({
  name: 'edgebundleR',
  type: 'output',
  initialize: function(el, width, height) {
    return {};
  },

  renderValue: function(el, xin, instance) {
    // save params for reference from resize method
    instance.xin = xin;
    // draw the graphic
    this.drawGraphic(el, xin, el.offsetWidth, el.offsetHeight);
  },
  drawGraphic: function(el, xin, width, height){
    // remove existing children
    while (el.firstChild)
      el.removeChild(el.firstChild);


    var size = d3.min([width,height]);
    var w = size,
    h = size,
    rx = w / 2,
    ry = h / 2,
    m0,
    rotate = 0;

    var splines = [];

    var cluster = d3.layout.cluster()
                  .size([360, ry-xin.padding])
                  .sort(function(a, b) { return d3.ascending(a.key, b.key); });

    var bundle = d3.layout.bundle();
    var line = d3.svg.line.radial()
                  .interpolate("bundle")
                  .tension(xin.tension)
                  .radius(function(d) { return d.y; })
                  .angle(function(d) { return d.x / 180 * Math.PI; });

    //var div = d3.select("body").insert("div", "h2")
    var div = d3.select(el).insert("div")
                //.style("top", "-80px")
                //.style("left", "-160px")
                .style("width", w + "px")
                .style("height", w + "px")
                .style("position", "absolute")
                .style("margin-left", "auto")
                .style("margin-right", "auto")
                .style("left", "0")
                .style("right", "0")
                .style("backface-visibility", "hidden");


    var svg = div.append("svg")
                .attr("width", w + "px")
                .attr("height", w + "px")
                .append("g")
                .attr("id","actualplot")
                .attr("transform", "translate(" + rx + "," + ry + ")");

    svg.append("path")
      .attr("class", "arc")
      .attr("d", d3.svg.arc().outerRadius(ry - 120).innerRadius(0).padRadius(0).startAngle(0).endAngle(2 * Math.PI))
      .on("mousedown", mousedown);

    classes = JSON.parse(xin.json_real);
    nodes = cluster.nodes(packages.root(classes));
    links = packages.imports(nodes);
    splines = bundle(links);

    var path = svg.selectAll("path.link")
                .data(links)
                .enter().append("path")
                .attr("class", function(d) {
                  return "link source-" + d.source.key + " target-" + d.target.key;
                })
                .attr("d", function(d, i) { return line(splines[i]); })
                .style("stroke", function(d){
                  if(d.source.color) return d.source.color;
                  /*if(!xin.directed) return 'steelblue';*/
                });

    var nodes_g = svg.selectAll("g.node")
      .data(nodes.filter(function(n) { return !n.children; }))
      .enter().append("g")
        .attr("class", "node")
        .attr("id", function(d) { return "node-" + d.key; })
        .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })
        .style("font-size",xin.fontsize);

    nodes_g.append("text")
      .attr("dx", function(d) { return d.x < 180 ? 8 : -8; })
      .attr("dy", ".31em")
      .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
      .attr("transform", function(d) { return d.x < 180 ? null : "rotate(180)"; })
      .style("fill", function(d){
        if(d.color) return d.color;
      })
      .text(function(d) { return d.key; })
      .on("mouseover", mouseover)
      .on("mouseout", mouseout);

    // set up a scale to size nodes based on xin.nodesize
    var nodesizer = d3.scale.linear()
      .domain(d3.extent(nodes.map(function(d){return d.size})))
      .range(xin.nodesize);

    nodes_g.append("circle")
    	.attr("cx", 0)
    	.attr("cy", 0)
    	.attr("fill", function(d,i){
        if(d.color) return d.color;
        return 'steelblue';
    	})
    	.attr("opacity", 1.0)
    	.attr("r", function(d,i){
    	  var size = d3.max(nodesizer.range());
    	  if(d.size){
    	    size = nodesizer(d.size)
  	    }
    	  return Math.round(Math.pow(size, 1/2));
    	});

    d3.select(el)
      .on("mousemove", mousemove)
      .on("mouseup", mouseup);

    function mouse(e) {
      return [e.pageX - rx, e.pageY - ry];
    }

    function mousedown() {
      m0 = mouse(d3.event);
      d3.event.preventDefault();
    }

    function mousemove() {
      if (m0) {
        var m1 = mouse(d3.event),
        dm = Math.atan2(cross(m0, m1), dot(m0, m1)) * 180 / Math.PI;
        div.style("transform", "translateY(" + (ry - rx) + "px)rotateZ(" + dm + "deg)translateY(" + (rx - ry) + "px)");
      }
    }

    function mouseup() {
      if (m0) {
        var m1 = mouse(d3.event),
        dm = Math.atan2(cross(m0, m1), dot(m0, m1)) * 180 / Math.PI;
        rotate += dm;
        if (rotate > 360) rotate -= 360;
        else if (rotate < 0) rotate += 360;
        m0 = null;
        div.style("transform", null);
        svg
          .attr("transform", "translate(" + rx + "," + ry + ")rotate(" + rotate + ")")
          .selectAll("g.node text")
          .attr("dx", function(d) {
            return (d.x + rotate) % 360 < 180 ? 8 : -8;
          })
          .attr("text-anchor", function(d) {
            return (d.x + rotate) % 360 < 180 ? "start" : "end";
          })
          .attr("transform", function(d) {
            return (d.x + rotate) % 360 < 180 ? null : "rotate(180)";
          });
      }
    }

    function mouseover(d) {
      svg.selectAll("path.link.target-" + d.key)
        .classed("target", true)
        .each(updateNodes("source", true));
      svg.selectAll("path.link.source-" + d.key)
        .classed("source", true)
        .each(updateNodes("target", true));
    }

    function mouseout(d) {
      svg.selectAll("path.link.source-" + d.key)
        .classed("source", false)
        .each(updateNodes("target", false));
      svg.selectAll("path.link.target-" + d.key)
        .classed("target", false)
        .each(updateNodes("source", false));
    }

    function updateNodes(name, value) {
      return function(d) {
        if (value) this.parentNode.appendChild(this);
        svg.select("#node-" + d[name].key).classed(name, value);
      };
    }

    function cross(a, b) {
      return a[0] * b[1] - a[1] * b[0];
    }

    function dot(a, b) {
      return a[0] * b[0] + a[1] * b[1];
    }


  },
  resize: function(el, width, height, instance) {
    if(instance.xin){
      this.drawGraphic(el, instance.xin, width, height);
    }
  }
});
