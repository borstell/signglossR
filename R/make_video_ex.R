#' Make a video example from a videofile (with ffmpeg)
#'
#' This function inputs a video and allows for repeated and/or slowmotion playback
#'
#' @param video The path/filename to the video to be modified
#' @param destination The path/filename of the output video
#' @param speed Set the speed of the video to a factor (0 to 1) of the original (default is .5)
#' @param rep If output video is to be repeated through concatenation (default is `FALSE`)
#' @return The name of the output video file
#' @export
make_video_ex <- function(video, destination="./", speed=.5, rep=FALSE) {
  new_vid <- paste0(tempdir(),"/", basename(video))
  system(paste0("cp ", video, " ", new_vid))
  video <- new_vid
  speedlabel <- speed*100
  if (speed > 0) {
    speed <- 1/speed
  }
  else {
    speed <- 0.1
  }
  extension <- paste0(".", tools::file_ext(video))
  outfile <- paste0(gsub(extension, "", video), "_", speedlabel, extension)
  if (file.exists(outfile)) {
    system(paste0("rm ", outfile))
  }
  system(paste0('ffmpeg -i ', video, ' -filter:v "setpts=', speed, '*PTS" ', outfile))
  if (rep == TRUE) {
    txt_list <- paste0(tempdir(),"/signglossr_concat_list.txt")
    newfile <- paste0(paste0(gsub(extension, "", outfile)), "_", "REP", extension)
    if (file.exists(newfile)) {
      system(paste0("rm ", newfile))
    }
    system(paste0("(echo file \'", outfile, "\' & echo file \'", video, "\' )>", txt_list))
    system(paste0("ffmpeg -safe 0 -f concat -i ", txt_list, " -c copy ", newfile))
    system(paste0("rm ", txt_list))
    outfile <- newfile
  }
  if (destination == "./") {
    destination <- paste0("./",gsub(".*/", "", outfile))
  }
  system(paste0("mv ",outfile, " ", destination))
  for (f in c(new_vid, gsub("_REP", "", outfile))) {
    system(paste0("rm ", f))
  }
  return(destination)
}

