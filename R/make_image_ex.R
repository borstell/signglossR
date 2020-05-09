#' Make an image example from an image file
#'
#' This function inputs an image file and allows for resizing, cropping, and text annotations
#'
#' @param image The path to the image file to be modified
#' @param destination The path/filename of the output image
#' @param scale The resizing proportion of the original image (0 to 1; default is 1 = original size)
#' @param crop Whether to crop image to region (`crop=FALSE` is default)
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
make_image_ex <- function(image, destination="./", scale=1, crop=FALSE, region='100x150+100+100', text="", textcolor="white", font="Helvetica", fontsize="70", gravity="southwest", location="+20+20", border=FALSE) {
  extension <- tools::file_ext(image)
  if (destination == "./") {
    extension <- paste0(".",tools::file_ext(image))
    destination <- gsub(extension, paste0("_EXAMPLE", extension), image)
  }
  im <- magick::image_read(image)
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
  magick::image_write(im, path = destination)
  return(destination)
}
