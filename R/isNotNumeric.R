#' Check if input is not numeric
#'
#' This function inputs value and returns TRUE if not numeric
#'
#' @param x Any input value
#' @return TRUE/FALSE
#' @export
isNotNumeric <- function(x) {
  suppressWarnings(is.na(as.numeric(x)))
}
