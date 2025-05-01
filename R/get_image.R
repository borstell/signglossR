#' Get sign image
#'
#' This function inputs an ID number and downloads the image
#' of the corresponding sign entry in the selected language.
#'
#' Arguments available for STS only:
#' Options include creating side-by-side or overlay images (default = `FALSE`)
#' and whether a horizontal trim (0 to 1; default = 1) should be applied.
#'
#' @param id ID number for the sign
#' @param filename The filename of the downloaded image
#' @param path The path to the downloaded image
#' @param lang The target sign language (i.e. "STS" or "ASL")
#' @param overlay Optional argument if overlay image wanted (default = `FALSE`)
#' @param blend Level of blending between images (if overlay = `TRUE`)
#' @param skip Whether to skip one image before applying pairwise composite (if overlay = `TRUE`)
#' @param trim Optional argument for horizontal image trim (0 to 1; default = 1)
#' @return The path of the image file that was downloaded
#' @export
get_image <- function(id,
                      filename = NULL,
                      path = NULL,
                      lang = "sts",
                      overlay = FALSE,
                      skip = 0,
                      blend = 80,
                      trim = 1) {

  # Check inputs
  id <- as.numeric(c(id))
  lang = tolower(lang)

  stopifnot("The <id> argument has to be numeric (e.g. '3' or '00004')" = all(!is.na(id)))
  stopifnot("The <lang> argument has to be either 'STS' or 'ASL'" = lang %in% c("sts", "ssl", "asl"))

  if (!is.null(filename)) {

    stopifnot("<id> and <filename> are of different lengths" = (length(id) == length(c(filename))))

  }

  # Store outfiles
  outfiles <- rep(NA, length(id))

  # Get images
  for (i in seq_along(id)) {

    if (lang == "asl") {

      # URL to sign video
      asl_vid <-
        xml2::read_html(
          paste0("http://aslsignbank.com",
                 "/dictionary/gloss/",
                 id[i],
                 ".html")
        ) |>
        rvest::html_elements("[id='videoplayer']") |>
        rvest::html_attr("src")

      # Replace video to image URL
      if (endsWith(asl_vid, ".mp4")){

        asl_img <- gsub("mp4", "jpg", gsub("/glossvideo/", "/glossimage/", asl_vid))

      } else {

        asl_img <- paste0(gsub("/glossvideo/", "/glossimage/", asl_vid), ".jpg")

      }

      if (is.null(filename)) {

        outfile <- paste0(path, basename(asl_img))

      } else {

        outfile <- paste0(path, filename[i])

      }

      utils::download.file(
        paste0(
          "http://aslsignbank.com",
          asl_img
        ),
        destfile = outfile)

      outfiles[i] <- outfile

    } else {

      idi <- paste0(paste0(rep("0", 5 - nchar(id[i])), collapse = ""), id[i])

      sts_imgs <-
        xml2::read_html(
          paste0("https://teckensprakslexikon.su.se/ord/",
                 idi
          )
        ) |>
        rvest::html_elements("[class='w-full']") |>
        rvest::html_attr("src") |>
        stats::na.omit() |>
        as.vector() |>
        gsub("-medium", "", x = _)

      tmp_dir <- tempdir()

      urls <- paste0("https://teckensprakslexikon.su.se", sts_imgs)

      img_names <- paste0(tmp_dir, "/", basename(sts_imgs))

      lapply(urls, \(x) utils::download.file(x, destfile = paste0(tmp_dir, "/", basename(x))))

      # Trim images if requested
      if (trim > 0 & trim < 1) {

        im <- magick::image_read(img_names[1])
        width <- magick::image_info(im)[, 2]
        height <- magick::image_info(im)[, 3]
        mid <- c(width * (1 - trim) / 2, height)
        new_width <- width * trim
        geomstring <- paste0(new_width, "x", height, "+", mid[1], "+", 0)
        lapply(img_names, \(x) magick::image_write(magick::image_crop(magick::image_read(x), geomstring), x))

      }

      img_name <- basename(gsub("-photo-1", "", img_names[1]))

      if (is.null(filename)) {

        outfile <- paste0(path, gsub("\\?.*", "", basename(img_name)))

      } else {

        outfile <- paste0(path, filename[i])

      }

      # Overlay images through blend combine
      if (overlay == TRUE) {

        signglossR::combine_images(img_names,
                                   overlay = TRUE,
                                   blend = blend,
                                   skip = skip,
                                   filename = outfile)

      } else {

        magick::image_read(img_names) |>
          magick::image_append() |>
          magick::image_write(path = outfile)

        }

      # Store output filenames
      outfiles[i] <- outfile

      # Unlink tempfiles
      lapply(img_names, unlink)

      }

  }

  # Return output filenames
  return(outfiles)

}
