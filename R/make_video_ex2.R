#' Make a video example from a videofile (with ffmpeg and av)
#'
#' This function inputs a video and allows for repeated and/or slowmotion playback
#'
#' @param video The path/filename to the video to be modified
#' @param destination The path/filename of the output video
#' @param speed Set the speed of the video to a factor (0 to 1) of the original (default is .5)
#' @param rep If output video is to be repeated through concatenation (default is `FALSE`)
#' @return The name of the output video file
#' @export
make_video_ex2 <- function(video, destination="./", speed=.5, rep=FALSE) {
  original <- c(video)
  if (destination=="./") {
    destination <- paste0(gsub(paste0(".",tools::file_ext(original[1])),"",original[1]),"_signglossR.",tools::file_ext(original[1]))
  }
  if (speed >= 1) {
    speed <- 1
  }
  if (speed==0) {
    speed <- 0.1
  }
  new <- c()
  for (n in 1:length(original)) {
    extension <- paste0(".", tools::file_ext(original[n]))
    new_name <- paste0(gsub(extension, "", original[n]),"_signglossR","_",n,extension)
    fps <- round(av::av_video_info(original[n])$video$framerate)
    new_speed <- fps*speed
    new <- c(new, av::av_encode_video(original[n], output = paste0(tempdir(),"/",basename(new_name)), framerate = new_speed))
  }
  if (rep==FALSE){
    av::av_video_convert(new, output=destination)
  }
  if (rep==TRUE) {
    av::av_video_convert(c(rbind(new,new)), output=destination)
  }
  return(destination)
}
