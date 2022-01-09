#' Get ASL sign video (ASL Signbank)
#'
#' This function inputs an ASL ID gloss or number and downloads the
#' video of the corresponding sign entry in ASL Signbank.
#'
#' @param id ID number for the ASL sign
#' @param destination The path/filename of the downloaded video
#' @return The name of the video file that was downloaded
#' @export
get_video_asl <- function(id, destination="./") {
  if (signglossR::isNotNumeric(id)) {
    id <- signglossR::gloss2id_asl(id)
  }
  asl_vid <- xml2::read_html(paste0("https://aslsignbank.haskins.yale.edu", "/dictionary/gloss/", id, ".html")) %>%
    rvest::html_elements("[id='videoplayer']") %>%
    rvest::html_attr("src")
  vid_name <- paste0("ASL_", gsub(".*/", "", asl_vid))
  path <- paste0("./", vid_name)
  if (destination != "./") {
    path <- destination
  }
  utils::download.file(paste0("https://aslsignbank.haskins.yale.edu", asl_vid), destfile = path)
  return(path)
}
