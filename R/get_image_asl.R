#' Get ASL sign image (ASL Signbank)
#'
#' This function inputs an ASL ID gloss or number and downloads the
#' image of the corresponding sign entry in ASL Signbank.
#'
#' A few esthetics arguments for the text annotation are optional (e.g. `gravity`, `fontsize`)
#'
#' @param id ID number for the ASL sign
#' @param destination The path/filename of the downloaded image
#' @param glosstext Prints the ID gloss onto the image if set to `TRUE` (default = `FALSE`)
#' @param gravity The anchor point of the text annotation if selected (default = "north")
#' @param location The exact location of the text annotation relative to `gravity`
#' @param fontsize The fontsize for the text annotation (default = 70)
#' @return The path of the image file that was downloaded
#' @export
get_image_asl <- function(id, destination="./", glosstext=FALSE, gravity="north", location="+20+20", fontsize=70) {
  if (signglossR::isNotNumeric(id)) {
    id <- signglossR::gloss2id_asl(id)
  }
  asl_vid <- xml2::read_html(paste0("https://aslsignbank.haskins.yale.edu", "/dictionary/gloss/", id, ".html")) %>%
    rvest::html_elements("[id='videoplayer']") %>%
    rvest::html_attr("src")
  asl_img <- gsub("mp4", "jpg", gsub("/glossvideo/", "/glossimage/", asl_vid))
  img_name <- paste0("./ASL_", gsub(".*/", "", asl_img))
  if (destination != "./") {
    img_name <- destination
  }
  utils::download.file(paste0("https://aslsignbank.haskins.yale.edu", asl_img), destfile = img_name)
  if (glosstext == TRUE) {
    if (tolower(gravity) %in% c("north", "south")) {
      location == "+0+20"
    }
    text_image <- magick::image_annotate(magick::image_read(img_name), as.character(signglossR::id2gloss_asl(id)), size = fontsize, font = "Helvetica", color = "white", weight = 700, gravity = gravity, location = location)
    magick::image_write(text_image, path = img_name)
  }
  return(img_name)
}
