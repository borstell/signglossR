#' Get multiple sign images
#'
#' This function inputs a string/vector of ID numbers and downloads the
#' images of the corresponding sign entries in the selected language.
#'
#' Arguments available for ASL:
#' A few esthetics arguments for the text annotation are optional (e.g. `gravity`, `fontsize`)
#'
#' Arguments available for STS:
#' Options include creating side-by-side or overlay images (defaults to FALSE) and
#' whether a horizontal trim (0 to 1; default=1) should be applied.
#'
#' @param ids ID numbers for the signs
#' @param directory The destination directory for the downloaded images
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @param glosstext Prints the ID gloss onto the image if set to `TRUE` (default = `FALSE`)
#' @param gravity The anchor point of the text annotation if selected (default = "north")
#' @param location The exact location of the text annotation relative to `gravity`
#' @param fontsize The fontsize for the text annotation (default = 70)
#' @param overlay Optional argument if overlay image wanted (defaults to FALSE)
#' @param trim Optional argument if horizontal trim wanted (values 0 to 1; default=1)
#' @return The path of the image files that were downloaded
#' @export
get_images <- function(ids, directory="./", acronym="sts", glosstext=FALSE, gravity="north", location="+10+20", fontsize=70, overlay=FALSE, trim=1) {
  current_dir <- paste0(getwd(),"/")
  if (directory !="./") {
    setwd(directory)
  }
  if (assertthat::is.string(ids)) {
    files <- c()
    for (i in stringr::str_split(ids, ",")) {
      files <- c(files, i)
    }
  }
  else {
    files <- ids
  }
  sequence <- c()
  for (i in files) {
    sequence <- c(sequence, signglossR::get_image(i, acronym, glosstext, gravity, location, fontsize, overlay, trim))
  }
  setwd(current_dir)
  return(sequence)
}
