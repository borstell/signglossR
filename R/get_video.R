#' Get sign video
#'
#' This function inputs an ID number and downloads the video
#' of the corresponding sign entry in the selected language.
#'
#' @param id ID number for the sign
#' @param filename The filename of the downloaded video
#' @param path The path to the downloaded video
#' @param lang The target sign language (i.e. "STS" or "ASL")
#' @return The path of the video file that was downloaded
#' @export
get_video <- function(id,
                      filename = NULL,
                      path = NULL,
                      lang = "sts") {

  # Check inputs
  id <- as.numeric(c(id))
  lang = tolower(lang)

  stopifnot("The <id> argument has to be numeric (e.g. '3' or '00004')" = !is.na(id))
  stopifnot("The <lang> argument has to be either 'STS' or 'ASL'" = lang %in% c("sts", "ssl", "asl"))

  if (!is.null(filename)) {

    stopifnot("<id> and <filename> are of different lengths" = (length(id) == length(c(filename))))

  }

  # Store outfiles
  outfiles <- rep(NA, length(id))

  # Get videos
  for (i in seq_along(id)) {

    # Get ASL video
    if (lang == "asl") {

      asl_vid <-
        xml2::read_html(
          paste0("http://aslsignbank.com",
                 "/dictionary/gloss/",
                 id[i],
                 ".html")) |>
        rvest::html_elements("[id='videoplayer']") |>
        rvest::html_attr("src")

      if (is.null(filename)) {

        outfile <- paste0(path, basename(asl_vid))

      } else {

        outfile <- paste0(path, filename[i])

      }


      utils::download.file(paste0("http://aslsignbank.com", asl_vid), destfile = outfile)

      outfiles[i] <- outfile

    } else {

      idi <- paste0(paste0(rep("0", 5 - nchar(id[i])), collapse = ""), id[i])

      sts_vid <-
        xml2::read_html(
          paste0("https://teckensprakslexikon.su.se/ord/",
                 idi)
        ) |>
        rvest::html_elements("[type='video/mp4']") |>
        rvest::html_attr("src")

      sts_vid <- paste0("https://teckensprakslexikon.su.se", sts_vid[1])

      if (is.null(filename)) {

        outfile <- paste0(path, gsub("\\?.*", "", basename(sts_vid)))

      } else {

        outfile <- paste0(path, filename[i])

      }

      utils::download.file(sts_vid, destfile = outfile)

      outfiles[i] <- outfile

    }

  }

  # Return outfiles
  return(outfiles)

}
