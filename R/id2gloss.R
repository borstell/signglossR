#' Find ID gloss from ID number
#'
#' This function inputs an ID number as an integer or string and outputs the
#' unique ID gloss linked to the same sign (its dictionary entry).
#'
#' @param id ID number for the sign
#' @param lang The target sign language ("STS" or "ASL")
#' @return The unique ID gloss linked to the sign in the dictionary
#' @export
id2gloss <- function(id,
                     lang = "sts") {

  # Check inputs
  id <- as.numeric(c(id))
  lang = tolower(lang)

  stopifnot("The <id> argument has to be numeric (e.g. '3' or '00004')" = all(!is.na(id)))
  stopifnot("The <lang> argument has to be either 'STS' or 'ASL'" = lang %in% c("sts", "ssl", "asl"))

  # Store output glosses
  out_glosses <- rep(NA, length(id))

  # Get glosses
  for (i in seq_along(id)) {

    # Get ASL gloss
    if (lang == "asl") {

      asl_gloss <-
        xml2::read_html(
          paste0(
            "http://aslsignbank.com/dictionary/gloss/",
            id[i],
            ".html")
        ) |>
        rvest::html_elements("[id='annotation_idgloss_en_US']") |>
        rvest::html_text()

      if (identical(character(0), asl_gloss) || length(asl_gloss) == 0 || asl_gloss == "") {

        message(paste0("Gloss for ID <", id[i], "> not found!"))
        out_glosses[i] <- ""

      } else {

        out_glosses[i] <- asl_gloss

      }

    } else {

      idi <- paste0(paste0(rep("0", 5 - nchar(id[i])), collapse = ""), id[i])

      sts_gloss <-
        xml2::read_html(
          paste0(
            "https://teckensprakslexikon.su.se/ord/",
            idi)
        ) |>
        rvest::html_nodes(xpath=".//b[contains(., 'Glosa i STS-korpus:')]//following-sibling::a") |>
        rvest::html_text()

      if (is.na(sts_gloss[1])) {

        message(paste0("Gloss for ID <", idi, "> not found!"))
        out_glosses[i] <- ""

      } else {

        out_glosses[i] <- sts_gloss

      }

    }

  }

  # Return output glosses
  return(out_glosses)


}
