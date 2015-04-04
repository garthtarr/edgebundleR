#' Save a edge bundle to an HTML file
#'
#' Save a edge buyndle graph to an HTML file for sharing with others. The HTML can
#' include it's dependencies in an adjacent directory or can bundle all
#' dependencies into the HTML file (via base64 encoding).
#'
#' @param x plot to save (e.g. result of calling the function
#'   \code{edgebundle}).
#'
#' @inheritParams htmlwidgets::saveWidget
#'
#' @export
saveEdgebundle <- function(x, file, selfcontained = TRUE) {
  htmlwidgets::saveWidget(x, file, selfcontained)
}
