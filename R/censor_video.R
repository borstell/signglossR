#' Censor video
#'
#' This function inputs a video and censors a manually defined region.
#'
#' @param video The video to be modified
#' @param filename The filename for the censored output video
#' @param path The path to the output video
#' @param automatic Whether to attempt automatic face detection (`automatic = TRUE` is default)
#' @param rescale_rect Rescale rectangle by factor if `automatic = TRUE` (default = 1)
#' @param width The width of the rectangle (only for `automatic = FALSE`)
#' @param height The height of the rectangle (only for `automatic = FALSE`)
#' @param x The x coordinate of the rectangle (only for `automatic = FALSE`)
#' @param y The y coordinate of the rectangle (only for `automatic = FALSE`)
#' @param color The color of the rectangle
#' @return The path to the censored video file
#' @export
censor_video <- function(video,
                         filename = NULL,
                         path = NULL,
                         automatic = TRUE,
                         rescale_rect = 1,
                         width = 100,
                         height = 100,
                         x = 100,
                         y = 100,
                         color = "black") {

  # Input video as vector
  video <- c(video)

  # Check inputs
  stopifnot("<filename> required" = all(!is.null(filename) | filename != ""))

  if (!is.null(filename)) {

    stopifnot("<video> and <filename> are of different lengths" = (length(video) == length(c(filename))))

  }

  # Store output filenames
  outfiles <- rep(NA, length(video))

  # Apply censoring per frame
  for (i in seq_along(video)) {

    # Output filename
    outfile <- paste0(path, filename[i])

    # Read video and metadata
    fps <- av::av_video_info(video[i])$video$framerate

    vid <- magick::image_read_video(video[i], fps = fps)

    # Automatic censoring
    if (automatic) {

      tmp_frame <- tempfile()

      magick::image_write(vid[1], path = tmp_frame)

      mask <-
        opencv::ocv_read(tmp_frame) |>
        opencv::ocv_facemask() |>
        attr("faces")

      # Reapply censoring across (potential) multiple faces
      for (n in 1:nrow(mask)) {

        r <- mask[n, ]$radius * rescale_rect
        x <- mask[n, ]$x - r
        y <- mask[n, ]$y - r

        vid <-
          magick::image_composite(
            vid,
            magick::image_blank(r * 2, r * 2, color = color), offset = paste0("+", x, "+", y)
          )

      }

      # Unlink tempfile
      unlink(tmp_frame)

      # Output file
      magick::image_write_video(vid, path = outfile, framerate = fps)

      # Apply manual censoring mask across frames
    } else {

      vid |>
        magick::image_composite(
          magick::image_blank(width, height, color = color), offset = paste0("+", x, "+", y)
          ) |>
        magick::image_write_video(path = outfile, framerate = fps)

    }

    # Store output filename
    outfiles[i] <- outfile

  }

  # Return output filenames
  return(outfiles)

}
