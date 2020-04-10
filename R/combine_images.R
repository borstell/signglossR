#' Combine images
#'
#' This function inputs a list of image files and outputs a concatenated or overlay image
#'
#' @param input A list of files (vector or comma-separated string) to be combined
#' @param destfile The specified path to the modified file created
#' @param stack Optional argument if concatenated image wanted: default FALSE gives horizontal sequence; TRUE gives vertically stacked
#' @param overlay Optional argument if overlay image wanted (defaults to FALSE)
#' @param trim Optional argument if horizontal trim wanted (values 0 to 1; default=1)
#' @return The name of the output image file
#' @export
combine_images <- function(input, destfile="", stack=FALSE, overlay=FALSE, trim=1) {
  if (assertthat::is.string(input)) {
    files <- c()
    for (i in stringr::str_split(input, ",")) {
      files <- c(files, i)
    }
  }
  else {
    files <- input
  }
  if (destfile == "") {
    extension <- paste0(".",tools::file_ext(files[1]))
    destfile <- gsub(extension, paste0("_COMBINED",extension), files[1])
  }
  im <- magick::image_read(files[1])
  width <- magick::image_info(im)[,2]
  height <- magick::image_info(im)[,3]
  if (trim < 1) {
    mid <- c(width*(1-trim)/2, height)
    new_width <- width*trim
    geomstring <- paste0(new_width,"x",height,"+",mid[1],"+",0)
    new_files <- c()
    for (i in files) {
      extension <- paste0(".",tools::file_ext(i))
      new_name <- gsub(extension, paste0("_signglossR-SEQ", extension), i)
      magick::image_write(magick::image_crop(magick::image_read(i), geomstring), new_name)
      new_files <- c(new_files, new_name)
    files <- new_files
    }
  }
  if (overlay == TRUE) {
    unlist(sapply(2:length(files), function(i) system(paste("convert",files[i], files[i-1],"-alpha set -compose dissolve -define compose:args='25' -gravity Center -composite",destfile,sep=" "))))
  }
  else {
    dimstring <- paste0("x", height)
    if (stack == TRUE) {
      dimstring <- paste0(width, "x")
    }
    magick::image_write(magick::image_append(magick::image_scale(magick::image_read(files), dimstring), stack = stack), destfile)
  }
  for (i in files) {
    if (length(i) != length(gsub("_signglossR-SEQ.", "", i))) {
      system(paste0("rm ", i))
    }
  }
  return(destfile)
}
