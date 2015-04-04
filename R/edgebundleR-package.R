#' Helper function to convert edges to JSON
#'
edgeToJSON = function(edges){
  output = list()
  for(i in unique(as.vector(edges))){
    name = i
    imports = NULL
    if(any(edges[,1]==i))imports = as.vector(edges[edges[,1]==i,2])
    output[[i]] = list(name = name,imports = imports)
  }
  names(output) = NULL
  rjson::toJSON(output)
}

#' Helper function to convert adjacency matrix to edges
#'
adjToEdge = function(adj){
  adj = (adj+t(adj)>0)*1
  diag(adj) = 1
  diag(adj)[rowSums(adj)>1]=0
  if(is.null(colnames(adj))){
    colnames(adj) = rownames(adj) = paste("V",1:dim(adj)[1],sep="")
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
