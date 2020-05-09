#' Censor image using blurring or solid black
#'
#' This function inputs an image and applies blurring or solid black
#' censoring of a defined region. It returns a new file in the same directoy.
#'
#' @param file The path/filename to the image to be modified
#' @param destination The path/filename to the censored output image
#' @param automatic Whether to use automatic face detection or not (`automatic=TRUE` is default)
#' @param style The style of censoring: "blur" or "black" ("blur" is default)
#' @param blur The amount of blur if `style="blur` (0 to 10; default is 8)
#' @param region The region to be modified (defaults to '100x150+100+100', (width x height +upper_x +upper_y)). Only for `automatic=FALSE`
#' @return The name of the image file that was modified
#' @export
censor_image <- function(file, destination="./", automatic=TRUE, style='blur', blur=8, region='100x150+100+100') {
  extension <- tools::file_ext(file)
  if (destination != "./") {
    new_filename <- destination
  }
  else {
    if (style == "blur") {
      tag <- "_blurred"
    }
    else {
      tag <- "_censored"
    }
    new_filename <- paste0(destination, paste0(gsub(paste0(".", extension), "", gsub(".*/", "", file)), tag, ".", extension))
  }
  if (automatic == FALSE) {
    if (style == "blur") {
      system(paste0("convert ", file, " -region ", region, " -blur 0x", blur, " ", new_filename))
    }
    else {
      system(paste0("convert ", file, " -region ", region, " -fill black -colorize 100% ", new_filename))
    }
  }
  else {
    img <- opencv::ocv_read(file)
    mask <- opencv::ocv_facemask(img)
    if (style == "blur") {
      img <- opencv::ocv_read(file)
      masked <- opencv::ocv_copyto(opencv::ocv_blur(img, k=(blur+.1)*10), img, mask)
      opencv::ocv_write(masked, new_filename)
    }
    else {
      tmp_dir <- tempdir()
      width <- as.numeric(opencv::ocv_info(img)$width)
      height <- as.numeric(opencv::ocv_info(img)$height)
      mask_file <- paste0(tmp_dir, "black_mask_bg.jpg")
      system(paste0("convert -size ", width, "x", height, " xc:black ", mask_file))
      masked <- opencv::ocv_copyto(opencv::ocv_read(paste0(mask_file)), img, mask)
      opencv::ocv_write(masked, new_filename)
      system(paste0("rm ", mask_file))
    }
  }
  return(new_filename)
}
