#' Check if input is numeric
#'
#' This function inputs value and returns TRUE if numeric
#'
#' @param x Any input value
#' @return TRUE/FALSE
#' @export
isNumeric <- function(x) {
  suppressWarnings(!is.na(as.numeric(x)))
}
