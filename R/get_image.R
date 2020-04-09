#' Get sign image
#'
#' This function inputs an  ID number and downloads the
#' image of the corresponding sign entry in the selected language.
#'
#' Arguments available for ASL:
#' A few esthetics arguments for the text annotation are optional (e.g. `gravity`, `fontsize`)
#'
#' Arguments available for STS:
#' Options include creating side-by-side or overlay images (defaults to FALSE) and
#' whether a horizontal trim (0 to 1; default=1) should be applied.
#'
#' @param id ID number for the sign
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @param glosstext Prints the ID gloss onto the image if set to `TRUE` (default = `FALSE`)
#' @param gravity The anchor point of the text annotation if selected (default = "north")
#' @param location The exact location of the text annotation relative to `gravity`
#' @param fontsize The fontsize for the text annotation (default = 70)
#' @param overlay Optional argument if overlay image wanted (defaults to FALSE)
#' @param trim Optional argument if horizontal trim wanted (values 0 to 1; default=1)
#' @return The path of the image file that was downloaded
#' @export
get_image <- function(id, acronym="sts", glosstext=FALSE, gravity="north", location="+10+20", fontsize=70, overlay=FALSE, trim=1) {
  acronym <- tolower(acronym)
  if (acronym == "asl") {
    img_name <- signglossR::get_image_asl(id, glosstext, gravity, location, fontsize)
  }
  if (acronym %in% c("sts", "ssl")) {
    img_name <- signglossR::get_image_sts(id, overlay, trim)
  }
  return(img_name)
}
