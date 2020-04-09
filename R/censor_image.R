#' Censor image using blurring or solid black
#'
#' This function inputs an image and applies blurring or solid black
#' censoring of a defined region. It returns a new file in the same directoy.
#'
#' @param file The path to the image to be modified
#' @param region The region to be modified (defaults to '100x150+100+100', (width x height +upper_x +upper_y))
#' @param method The method of censoring: "blur" or "black" ("blur" is default)
#' @return The name of the image file that was modified
#' @export
censor_image <- function(file, region='100x150+100+100', method='blur') {
  extension <- tools::file_ext(file)
  new_filename <- paste0("./", paste0(gsub(paste0(".", extension), "", gsub(".*/", "", file)), "_censored", ".", extension))
  if (method == "blur") {
    system(paste0("convert ", file, " -region ", region, " -blur 0x8 ", new_filename))
  }
  else {
    system(paste0("convert ", file, " -region ", region, " -fill black -colorize 100% ", new_filename))
  }
  return(new_filename)
}
