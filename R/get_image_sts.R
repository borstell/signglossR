#' Get STS sign image (Svenskt teckenspråkslexikon)
#'
#' This function inputs an STS ID number and downloads the image
#' of the corresponding sign entry in Svenskt teckenspråkslexikon.
#'
#' Options include creating side-by-side or overlay images (defaults to FALSE) and
#' whether a horizontal trim (0 to 1; default=1) should be applied.
#'
#' @param id ID number for the STS sign
#' @param destination The path/filename of the downloaded image
#' @param overlay Optional argument if overlay image wanted (defaults to FALSE)
#' @param trim Optional argument if horizontal trim wanted (values 0 to 1; default=1)
#' @return The path of the image file that was downloaded
#' @export
get_image_sts <- function(id, destination="./", overlay=FALSE, trim=1) {
  if (signglossR::isNotNumeric(as.character(id))) {
    message("The <id> argument has to be numeric (e.g. '3' or '00004')")
    stop()
  }
  id <- stringr::str_pad(id, 5, pad = "0")
  sts_imgs <- xml2::read_html(paste0("https://teckensprakslexikon.su.se/ord/", id)) %>%
    rvest::html_elements("[class='w-full']") %>%
    rvest::html_attr("src") %>%
    na.omit() %>%
    as.vector()
  urls <- c()
  tmp_dir <- tempdir()
  img_names <- c()
  for (i in sts_imgs) {
    large <- gsub("-medium", "", i)
    url <- paste0("https://teckensprakslexikon.su.se",large)
    urls <- c(urls, url)
    img_names <- c(img_names, paste0(tmp_dir, "/", gsub(".*/", "", large)))
  }
  for (url in urls) {
    utils::download.file(url, destfile = paste0(tmp_dir, "/", gsub(".*/", "", url)))
  }
  if (trim < 1) {
    im <- magick::image_read(img_names[1])
    width <- magick::image_info(im)[,2]
    height <- magick::image_info(im)[,3]
    mid <- c(width*(1-trim)/2, height)
    new_width <- width*trim
    geomstring <- paste0(new_width,"x",height,"+",mid[1],"+",0)
    for (i in img_names) {
      magick::image_write(magick::image_crop(magick::image_read(i), geomstring), i)
    }
  }
  new_name <- paste0("./STS_",gsub("-photo-.*", ".jpg", gsub(".*/", "", img_names[1])))
  if (destination != "./") {
    new_name <- destination
  }
  if (overlay == TRUE) {
    unlist(sapply(2:length(img_names), function(i) system(paste("convert",img_names[i], img_names[i-1],"-alpha set -compose dissolve -define compose:args='25' -gravity Center -composite",new_name,sep=" "))))
  }
  else {
    magick::image_write(magick::image_append(magick::image_read(img_names)), new_name)
  }
  for (i in img_names) {
    system(paste0("rm ", i))
  }
  return(new_name)
}
