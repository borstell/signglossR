#' Make a GIF from a videofile (with ffmpeg)
#'
#' This function inputs a video and converts it to .gif using ffmpeg and ImageMagick
#'
#' @param file The path to the video to be converted
#' @param fps Set frame rate (fps: frames per second) for gif output (default is 12.5)
#' @param scale Scale the output video dimension to a factor (0 to 1) of the original (default is .5)
#' @return The name of the output .gif file
#' @export
make_gif <- function(file, fps=12.5, scale=.5) {
  width <- (av::av_media_info(file)$video$width * scale)
  delay <- round(100/fps)
  outfile <- gsub(tools::file_ext(file), "gif", file)
  system(paste0('ffmpeg -i ', file, ' -vf "fps=', fps, ',scale=', width,':-1:flags=lanczos" -c:v pam -f image2pipe - | convert -delay ', delay, ' - -loop 0 -layers optimize ', outfile))
  return(outfile)
}
