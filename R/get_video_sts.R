#' Get STS sign video (Svenskt teckenspråkslexikon)
#'
#' This function inputs an STS ID number and downloads the video
#' of the corresponding sign entry in Svenskt teckenspråkslexikon.
#'
#' @param id ID number for the STS sign
#' @return The name of the video file that was downloaded
#' @export
get_video_sts <- function(id) {
  if (signglossR::isNotNumeric(as.character(id))) {
    print("The <id> argument has to be numeric (e.g. '3' or '00004')")
    stop()
  }
  id <- stringr::str_pad(id, 5, pad = "0")
  sts_vid <- xml2::read_html(paste0("https://teckensprakslexikon.su.se/ord/", id)) %>%
    rvest::html_nodes("[type='video/mp4']") %>%
    rvest::html_attr("src")
  sts_vid <- paste0("https://teckensprakslexikon.su.se", sts_vid[1])
  vid_name <- paste0("STS_", gsub(".*/", "", sts_vid))
  path <- paste0("./", vid_name)
  utils::download.file(sts_vid, destfile = path)
  return(path)
}
