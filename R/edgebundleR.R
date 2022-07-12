#' Circle plot with bundled edges
#'
#' Takes an appropriately structured JSON file or a square symmetric matrix (e.g. a
#' correlation matrix or precision matrix) and outputs a circle plot with the nodes
#' around the circumfrence and linkages between the connected nodes. Adapted from
#' the  Mike Bostock's D3 Hierarchical Edge Bundling example using the htmlwidgets
#' framework.
#'
#' @param x an appropriately structured JSON file (see vignette for details) or a
#'   square symmetric matrix (e.g. correlation matrix) or an igraph object.
#' @param tension numeric between 0 and 1 giving the tension of the links
#' @param cutoff numeric giving the threshold dependence for linkages to be plotted
#' @param width the width of the plot when viewed externally
#' @param fontsize font size of the node labels
#' @param padding the padding (in px) between the inner radius of links and the
#'   edge of the plot.  Increase this when the labels run outside the edges of
#'   the plot.  Default: 100.
#' @param nodesize two element vector of the min and max node size
#'   to scale the node circle size.  If a size is not provided for each
#'   node, then the node size will be the max node size provided in
#'   this argument.  Default: c(5,20).
#' @param directed whether or not the graph is directed. Does not work yet.
#'   Need to think about how to implement this cleanly.
#'
#' @import htmlwidgets
#' @import rjson
#' @import igraph
#'
#' @examples
#' \dontrun{
#' require(igraph)
#' ws_graph = watts.strogatz.game(1, 50, 4, 0.05)
#' edgebundle(ws_graph,tension = 0.1,fontsize = 20)
#' }
#'
#' @export
edgebundle <- function(x, tension=0.5, cutoff=0.1, width = NULL,
                       fontsize = 14, padding=100, nodesize = c(5,20),
                       directed = FALSE,
                       selectNodeAction = NULL,
                       mouseoverAction = NULL,
                       mouseoutAction = NULL,
                       deselectNodeAction = NULL) {
  if((typeof(x)=="character")){
    json_data <- rjson::fromJSON(file = x)
    json_real = rjson::toJSON(json_data)
  } else if (class(x)=="igraph"){
    json_real = edgeToJSON_igraph(x)#d3r::d3_igraph(x)#edgeToJSON_igraph(x)
    directed = is.directed(x)
  } else {
    if(!isSymmetric(x)){
      warning("x needs to be a symmetric matrix (e.g. a correlation matrix).")
      return()
    }
    directed = FALSE
    corX = x
    adj = corX>cutoff
    edges = adjToEdge(adj)
    json_real = edgeToJSON_matrix(edges)
  }
  height=width
  # forward options using x
  xin = list(
    json_real = json_real,
    width=width,
    height=height,
    padding=padding,
    tension = tension,
    fontsize = fontsize,
    nodesize = nodesize,
    directed = directed,
    selectNodeAction = selectNodeAction,
    mouseoverAction = mouseoverAction,
    mouseoutAction = mouseoutAction,
    deselectNodeAction = deselectNodeAction
  )
  # create widget
  htmlwidgets::createWidget(
    name = 'edgebundleR',
    xin,
    width = width,
    height = height,
    #htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
    package = 'edgebundleR'
  )
}

#' Widget output function for use in Shiny
#'
#' @param outputId Shiny output ID
#' @param width width default '100\%'
#' @param height height default '400px'
#'
#' @export
edgebundleOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'edgebundleR', width, height, package = 'edgebundleR')
}

#' Widget render function for use in Shiny
#'
#' @param expr edgebundle expression
#' @param env environment
#' @param quoted logical, default = FALSE
#'
#' @export
renderEdgebundle <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, edgebundleOutput, env, quoted = TRUE)
}
