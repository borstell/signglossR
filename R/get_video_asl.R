#' Get ASL sign video (ASL Signbank)
#'
#' This function inputs an ASL ID gloss or number and downloads the
#' video of the corresponding sign entry in ASL Signbank.
#'
#' @param id ID number for the ASL sign
#' @return The name of the video file that was downloaded
#' @export
get_video_asl <- function(id) {
  if (signglossR::notNumeric(id)) {
    id <- signglossR::gloss2id_asl(id)
  }
  asl_vid <- xml2::read_html(paste0("https://aslsignbank.haskins.yale.edu", "/dictionary/gloss/", id, ".html")) %>%
    rvest::html_nodes("[id='videoplayer']") %>%
    rvest::html_attr("src")
  vid_name <- paste0("ASL_", gsub(".*/", "", asl_vid))
  path <- paste0("./media/videos/", vid_name)
  utils::download.file(paste0("https://aslsignbank.haskins.yale.edu", asl_vid), destfile = path)
  return(path)
}
