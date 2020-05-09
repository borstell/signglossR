#' Get multiple sign videos
#'
#' This function inputs a string/vector of ID numbers and downloads the
#' videos of the corresponding sign entries in the selected language.
#' 
#' @param ids ID numbers for the signs
#' @param directory The destination directory for the downloaded videos
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @return The path of the video files that were downloaded
#' @export
get_videos <- function(ids, directory="./", acronym="sts") {
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
    sequence <- c(sequence, signglossR::get_video(i, acronym))
  }
  setwd(current_dir)
  return(sequence)
}