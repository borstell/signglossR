#' Make a video example from a videofile (with ffmpeg)
#'
#' This function inputs a video and allows for repeated and/or slowmotion playback
#'
#' @param file The path to the video to be converted
#' @param speed Set the speed of the video to a factor (0 to 1) of the original (default is .5)
#' @param rep If output video is to be repeated through concatenation (default is `FALSE`)
#' @return The name of the output video file
#' @export
make_video_ex <- function(file, speed=.5, rep=FALSE) {
  speedlabel <- speed*100
  if (speed > 0) {
    speed <- 1/speed
  }
  else {
    speed <- 0.1
  }
  extension <- paste0(".", tools::file_ext(file))
  outfile <- paste0(gsub(extension, "", file), "_", speedlabel, extension)
  if (file.exists(outfile)) {
    system(paste0("rm ", outfile))
  }
  system(paste0('ffmpeg -i ', file, ' -filter:v "setpts=', speed, '*PTS" ', outfile))
  if (rep == TRUE) {
    txt_list <- "./signglossr_concat_list.txt"
    newfile <- paste0(paste0(gsub(extension, "", outfile)), "_", "REP", extension)
    if (file.exists(newfile)) {
      system(paste0("rm ", newfile))
    }
    system(paste0("(echo file \'", outfile, "\' & echo file \'", file, "\' )>", txt_list))
    system(paste0("ffmpeg -safe 0 -f concat -i ", txt_list, " -c copy ", newfile))
    system(paste0("rm ", txt_list))
    outfile <- newfile
  }
  return(outfile)
}
