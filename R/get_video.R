#' Get sign video
#'
#' This function inputs an ID number and a sign language acronym and
#' downloads the video of the corresponding sign entry in the linked resource.
#'
#' @param id ID number for the sign
#' @param destination The path/filename of the downloaded video
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @return The name of the video file that was downloaded
#' @export
get_video <- function(id, destination="./", acronym="sts") {
  acronym <- tolower(acronym)
  if (acronym == "asl") {
    vid_name <- signglossR::get_video_asl(id, destination)
  }
  if (acronym %in% c("sts", "ssl")) {
    vid_name <- signglossR::get_video_sts(id, destination)
  }
  else {
    message(paste0("Language <", acronym, "> not available."))
    stop()
  }
  return(vid_name)
}
