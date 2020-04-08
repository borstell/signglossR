#' Return zero padded STS ID number
#'
#' This function inputs a string and returns it with correct zero padding
#'
#' @param id And STS ID number input
#' @return Zero padded ID number
#' @export
sts_padding <- function(id) {
  return(stringr::str_pad(id, 5, pad = "0"))
}
