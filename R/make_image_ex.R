#' Make image example from an image file
#'
#' This function inputs an image file and allows for resizing, cropping, and text annotations
#'
#' @param file The path to the image to be modified
#' @param destfile The specified path to the modified file created
#' @param crop Whether to use automatic face detection or not (`automatic=TRUE` is default)
#' @param scale The resizing proportion of the original image (0 to 1; default is 1 = original size)
#' @param region The region to be cropped (defaults to '100x150+100+100', (width x height +upper_x +upper_y)). Only for `crop=TRUE`
#' @param text The text string to be added to the image
#' @param textcolor The color of the text annotation (default is "white")
#' @param font The font of the text annotation (default is "Helvetica")
#' @param fontsize The fontsize of the text annotation (default is 70)
#' @param gravity The anchor point of the added text (default is "southwest")
#' @param location The location of the text relative to the anchor point
#' @param border Set to `TRUE` if you want a black border frame for the output image
#' @return The name of the image file that was created
#' @export
make_image_ex <- function(file, destfile="", crop=FALSE, scale=1, region='100x150+100+100', text="", textcolor="white", font="Helvetica", fontsize="70", gravity="southwest", location="+20+20", border=FALSE) {
  extension <- tools::file_ext(file)
  if (destfile == "") {
    extension <- paste0(".",tools::file_ext(file))
    destfile <- gsub(extension, paste0("_EXAMPLE", extension), file)
  }
  im <- magick::image_read(file)
  if (crop == TRUE) {
    im <- magick::image_crop(im, geometry = region)
  }
  width <- magick::image_info(im)[,2]
  height <- magick::image_info(im)[,3]
  im <- magick::image_scale(im, as.character(width*scale))
  if (text != "") {
    im <- magick::image_annotate(im, text, size = fontsize, font = font, color = textcolor, weight = 700, gravity = gravity, location = location)
  }
  if (border == TRUE) {
    im <- magick::image_border(im, "#000000", "5x5")
  }
  magick::image_write(im, path = destfile)
  return(destfile)
}
