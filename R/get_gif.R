#' Get sign gif
#'
#' This function inputs an  ID number and downloads the
#' GIF of the corresponding sign entry in the selected language.
#'
#' @param id ID number for the sign
#' @param destination The path/filename of the downloaded image
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @return The path of the image file that was downloaded
#' @export
get_gif <- function(id, destination="./", acronym="sts") {
  acronym <- tolower(acronym)
  if (acronym %in% c("sts", "ssl")) {
    gif_name <- signglossR::get_gif_sts(id, destination)
  }
  return(gif_name)
}
