#' Censor image using blurring or solid rectangle
#'
#' This function inputs an image and applies blurring of detected faces
#' or solid rectangle censoring of a manually defined region.
#'
#' @param image The image to be modified
#' @param filename The filename for the censored output image
#' @param path The path to the output image
#' @param automatic Whether to use automatic face detection (`automatic = TRUE` is default)
#' @param blur The amount of blur if `automatic = TRUE` (0 to 100)
#' @param width The width of the rectangle (only for `automatic=FALSE`)
#' @param height The height of the rectangle (only for `automatic=FALSE`)
#' @param x The x coordinate of the rectangle (only for `automatic=FALSE`)
#' @param y The y coordinate of the rectangle (only for `automatic=FALSE`)
#' @param color The color of the rectangle (only for `automatic=FALSE`)
#' @return The path to the censored image file
#' @export
censor_image <- function(image,
                         filename = NULL,
                         path = NULL,
                         automatic = TRUE,
                         blur = 75,
                         width = 100,
                         height = 100,
                         x = 100,
                         y = 100,
                         color = "black") {

  # Image input as vector
  image <- c(image)

  # Check inputs
  stopifnot("<filename> required" = all(!is.null(filename) | filename != ""))

  if (!is.null(filename)) {

    stopifnot("<image> and <filename> are of different lengths" = (length(image) == length(c(filename))))

  }

  # Store output filenames
  outfiles <- rep(NA, length(image))

  # Apply censoring per image
  for (i in seq_along(image)) {

    # Output filename
    outfile <- paste0(path, filename[i])

    # Manually defined censoring mask
    if (automatic == FALSE) {

      img <-
        magick::image_read(image[i]) |>
        magick::image_composite(
          magick::image_blank(width, height, color = color), offset = paste0("+", x, "+", y)
        ) |>
        magick::image_write(path = outfile)

      # Automatic censoring mask
    } else {

      img <- opencv::ocv_read(image[i])
      mask <- opencv::ocv_facemask(img)
      masked <- opencv::ocv_copyto(opencv::ocv_blur(img, k = blur), img, mask)
      opencv::ocv_write(masked, outfile)

    }

    # Store output files
    outfiles[i] <- outfile

  }

  # Return output filenames
  return(outfiles)

}
