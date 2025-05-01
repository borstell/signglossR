#' Get STS sign GIF (Svenskt teckenspråkslexikon)
#'
#' This function inputs an STS ID number and downloads the GIF
#' of the corresponding sign entry in Svenskt teckenspråkslexikon.
#'
#' @param id ID number for the STS sign
#' @param filename The filename of the downloaded image (GIF)
#' @param path The path to the downloaded image (GIF)
#' @return The path of the image file that was downloaded
#' @export
get_gif <- function(id,
                    filename = NULL,
                    path = NULL) {

  id <- as.numeric(c(id))

  stopifnot("The <id> argument has to be numeric (e.g. '3' or '00004')" = !is.na(id))

  if (!is.null(filename)) {

    stopifnot("<id> and <filename> are of different lengths" = (length(id) == length(c(filename))))

  }

  outfiles <- rep(NA, length(id))

  for (i in seq_along(id)) {

    idi <- paste0(paste0(rep("0", 5 - nchar(id[i])), collapse = ""), id[i])

    filler <- substr(idi, 1, 2)
    sts_gif <- paste0("https://teckensprakslexikon.su.se/photos/",
                      filler,
                      "/",
                      idi,
                      "-animation.gif")

    if (is.null(filename)) {

      outfile <- paste0(path, basename(sts_gif))

    } else {

      outfile <- paste0(path, filename[i])

    }

    utils::download.file(sts_gif, destfile = outfile)
    outfiles[i] <- outfile


  }

  return(outfiles)

}
