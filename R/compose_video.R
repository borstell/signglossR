#' Compose a modified video from a video file
#'
#' This function inputs a video and allows for repeated and/or slowmotion playback
#'
#' @param video The filename to the video to be modified
#' @param filename The filename of the output video
#' @param path The path to the output video
#' @param fps The original framerate of the input video (default = 24; original = NULL)
#' @param speed Set the speed of the video to a factor (0 to 1) of the original (default is .5)
#' @param rep If output video is to be repeated through concatenation (default is `FALSE`)
#' @param scale The resizing proportion of the original video (0 to 1; default is 1 = original size)
#' @param crop_region The region to be cropped (e.g. '100x150+100+100', (width x height +upper_x +upper_y)).
#' @param text The text string to be added to the video
#' @param textcolor The color of the text annotation (default is "white")
#' @param boxcolor The color of the textbox (default is `NULL`)
#' @param font The font of the text annotation (default is "Helvetica")
#' @param fontsize The fontsize of the text annotation (default is 70)
#' @param rel_fontsize Whether to adjust the fontsize relative to width (x) or height (y)
#' @param gravity The anchor point of the added text (default is "southwest")
#' @param location The location of the text relative to the anchor point
#' @return The name of the output video file
#' @export
compose_video <- function(video,
                          filename = NULL,
                          path = NULL,
                          fps = 24,
                          speed = .5,
                          rep = FALSE,
                          scale = 1,
                          crop_region = "",
                          text = NULL,
                          textcolor = "white",
                          boxcolor = NULL,
                          font = "Helvetica",
                          fontsize = "70",
                          rel_fontsize = "",
                          gravity = "southwest",
                          location = "+20+20") {

  image <- c(image)
  text <- c(text)

  if (!is.null(filename)) {

    stopifnot("<video> and <filename> are of different lengths" = (length(video) == length(c(filename))))

  }

  outfiles <- rep(NA, length(video))

  if (length(text) <= 1) {

    text <- rep(text[1], length(video))

  }

  for (i in seq_along(video)) {

    outfile <- paste0(path, filename[i])

    vid_info <- av::av_video_info(video[i])
    height <- vid_info$video$height
    width <- vid_info$video$width

    if (is.null(fps)) {

      fps <- vid_info$video$framerate

    }

    if (fps > 60) {

      fps <- 60
      message("Warning: fps automatically set to 60")

    }

    if (speed > 0 & speed < 1) {

      speed <- speed

    } else {

      speed <- 1

    }

    if (speed > 0 & speed < 1) {

      if (rep) {

        vid <- magick::image_read_video(video[i], fps = fps)
        vid2 <- magick::image_read_video(video[i], fps = round(fps / speed))

        out_vid <- c(vid, vid2)

      } else {

        vid2 <- magick::image_read_video(video[i], fps = round(fps / speed))

        out_vid <- c(vid2)

      }

    } else {

      if (rep) {

        vid <- magick::image_read_video(video[i], fps = fps)

        out_vid <- c(vid, vid)

      } else {

        vid <- magick::image_read_video(video[i], fps = fps)

        out_vid <- c(vid)

      }

    }

    if (scale > 0 & scale < 1) {

      out_vid <-
        out_vid |>
        magick::image_scale(as.character(width * scale))

    }

    if (!is.null(text[i])) {

      fontsize <- as.numeric(fontsize)

      if (rel_fontsize == "y") {

        fontsize = fontsize * (height * scale / 1000)

      }

      if (rel_fontsize == "x") {

        fontsize = fontsize * (width * scale / 1000)

      }

      if (crop_region != "") {

        out_vid <-
          out_vid |>
          magick::image_crop(geometry = crop_region)

      }

      out_vid <-
        out_vid |>
        magick::image_annotate(text[i],
                               size = fontsize,
                               font = font,
                               color = textcolor,
                               boxcolor = boxcolor,
                               weight = 700,
                               gravity = gravity,
                               location = location)

    }

    magick::image_write_video(
      out_vid,
      path = outfile,
      framerate = fps
    )

    outfiles[i] <- outfile

  }

  return(outfiles)

}
