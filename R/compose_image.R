#' Compose a modified/annotated image from an image file
#'
#' This function inputs an image file and allows for resizing, cropping, and text annotations
#'
#' @param image The path to the image file to be modified
#' @param filename The filename of the output image
#' @param path The path to the output image
#' @param scale The resizing proportion of the original image (0 to 1; default is 1 = original size)
#' @param crop_region The region to be cropped (e.g. '100x150+100+100', (width x height +upper_x +upper_y)).
#' @param text The text string to be added to the image
#' @param textcolor The color of the text annotation (default is "white")
#' @param boxcolor The color of the textbox (default is `NULL`)
#' @param font The font of the text annotation (default is "Helvetica")
#' @param fontsize The fontsize of the text annotation (default is 70)
#' @param rel_fontsize Whether to adjust the fontsize relative to width (x) or height (y)
#' @param gravity The anchor point of the added text (default is "southwest")
#' @param location The location of the text relative to the anchor point
#' @param border Set to `TRUE` if you want a black border frame for the output image
#' @return The filename of the image file that was created
#' @export
compose_image <- function(image,
                          filename = NULL,
                          path = NULL,
                          scale = 1,
                          crop_region = NULL,
                          text = NULL,
                          textcolor = "white",
                          boxcolor = NULL,
                          font = "Helvetica",
                          fontsize = 70,
                          rel_fontsize = NULL,
                          gravity = "southwest",
                          location = "+20+20",
                          border = FALSE) {

  image <- c(image)
  text <- c(text)

  if (!is.null(filename)) {

    stopifnot("<image> and <filename> are of different lengths" = (length(image) == length(c(filename))))

  }

  outfiles <- rep(NA, length(image))

  if (length(text) <= 1) {

    text <- rep(text[1], length(image))

  }

  for (i in seq_along(image)) {

    outfile <- paste0(path, filename[i])

    im <- magick::image_read(image[i])

    if (!is.null(crop_region)) {

      im <- magick::image_crop(im, geometry = crop_region)

    }

    width <- magick::image_info(im)[,2]
    height <- magick::image_info(im)[,3]

    if (scale > 0 & scale < 1) {

      im <- magick::image_scale(im, as.character(width * scale))

    }

    if (!is.null(text[i])) {

      fontsize <- as.numeric(fontsize)

      if (identical(rel_fontsize, "y")) {

        fontsize = fontsize * (height / 1000)

      }

      if (identical(rel_fontsize, "x")) {

        fontsize = fontsize * (width / 1000)

      }

      im <- magick::image_annotate(im,
                                   text[i],
                                   size = fontsize,
                                   font = font,
                                   color = textcolor,
                                   boxcolor = boxcolor,
                                   weight = 700,
                                   gravity = gravity,
                                   location = location)

    }

    if (border == TRUE) {

      im <- magick::image_border(im, "#000000", "5x5")

    }

    magick::image_write(im, path = outfile)
    outfiles[i] <- outfile

  }

  return(outfiles)

}
