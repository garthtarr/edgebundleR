#' Helper function to convert edges to JSON
#'
#' @param edges a matrix of edge relationships
#'
edgeToJSON_matrix = function(edges){
  output = list()
  for(i in unique(as.vector(edges))){
    name = i
    imports = NULL
    if(any(edges[,1]==i)) imports = as.vector(edges[edges[,1]==i,2])
    output[[i]] = list(name = name,imports = imports)
  }
  names(output) = NULL
  rjson::toJSON(output)
}


#' Helper function to convert an igraph to JSON
#'
#' @param graph an igraph
#'
edgeToJSON_igraph = function(graph){
  df <- get.data.frame(graph,what="both")
  vertices <- df$vertices
  edges <- df$edges
  # if the vertex names are unspecified, number them
  if(is.null(df$vertices$name)){
    vertices$name = as.character(sort(unique(unlist(edges))))
  }
  imports <- NULL
  # get all attributes if defined in vertices of the igraph
  output <- apply(
    vertices,MARGIN=1,function(vtx){
      name <- vtx[["name"]]
      if(any(edges[,1]==name)) imports = as.vector(edges[edges[,1]==name,2])
      c(vtx,imports=list(imports))
    }
  )
  output <- unname(output)
  rjson::toJSON(output)
}

#' Helper function to convert adjacency matrix to edges
#'
#' @param adj an adjacency matrix
#'
adjToEdge = function(adj){
  adj = (adj+t(adj)>0)*1
  diag(adj) = 1
  diag(adj)[rowSums(adj)>1]=0
  if(is.null(colnames(adj))){
    posts = 1:dim(adj)[1]
    arg1 = paste("%0",nchar(max(posts)),"s",sep="")
    posts = sprintf(arg1,posts)
    colnames(adj) = rownames(adj) = paste("V",posts,sep="")
  }
  edges = which(adj>0,2)
  edges = edges[edges[,2]>=edges[,1],]
  edges[,1] = rownames(adj)[edges[,1]]
  edges[,2] = rownames(adj)[as.numeric(edges[,2])]
  edges
}

#' Flare software class hierarchy
#'
#' A JSON file enumerating the dependencies between classes
#' in a software class hierarchy. Dependencies are bundled
#' according to the parent packages.
#'
#' @name flare-imports.json
#' @format A JSON data file (with txt extension for R)
#' @details Sourced from Mike Bostock's examples, see here: http://bl.ocks.org/mbostock/raw/7607999/
#' @docType data
#' @keywords datasets
#' @examples
#' \dontrun{
#' filepath = system.file("sampleData", "flare-imports.json", package = "edgebundleR")
#' edgebundle(filepath,width=800,height=800,fontsize=8,tension=0.95)
#' }
NULL
