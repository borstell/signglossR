#' Get STS sign GIF (Svenskt teckenspråkslexikon)
#'
#' This function inputs an STS ID number and downloads the GIF
#' of the corresponding sign entry in Svenskt teckenspråkslexikon.
#'
#' @param id ID number for the STS sign
#' @param destination The path/filename of the downloaded image
#' @return The path of the image file that was downloaded
#' @export
get_gif_sts <- function(id, destination="./") {
  if (signglossR::isNotNumeric(as.character(id))) {
    message("The <id> argument has to be numeric (e.g. '3' or '00004')")
    stop()
  }
  id <- stringr::str_pad(id, 5, pad = "0")
  filler <- stringr::str_sub(id, 1,2)
  sts_gif <- paste0("https://teckensprakslexikon.su.se/photos/", filler, "/", id,"-animation.gif")
  tmp_dir <- tempdir()
  gif_name <- paste0("STS_", gsub("-animation","",gsub(".*/", "", sts_gif)))
  path <- paste0("./", gif_name)
  if (destination != "./") {
    path <- destination
  }
  utils::download.file(sts_gif, destfile = path)
  return(path)
}
