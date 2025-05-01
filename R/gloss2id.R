#' Find ID number from ID gloss
#'
#' This function inputs an ID gloss and outputs an
#' ID number linked to the same sign (its dictionary entry).
#'
#' @param gloss ID gloss for the sign
#' @param lang The target sign language ("STS" or "ASL")
#' @return The unique ID gloss(es) linked to the gloss
#' @export
gloss2id <- function(gloss,
                     lang = "sts") {

  # Check inputs
  gloss <- c(gloss)
  lang = tolower(lang)

  stopifnot("The <lang> argument has to be either 'STS' or 'ASL'" = lang %in% c("sts", "ssl", "asl"))

  # Store output IDs
  out_ids <- rep(NA, length(gloss))

  # Get IDs
  for (i in seq_along(gloss)) {

    # Get ASL ID
    if (lang == "asl") {

      asl_gloss <-
        xml2::read_html(
          paste0(
            "http://aslsignbank.com/signs/search/?search=%5E",
            gloss[i],
            "%24&keyword="
          )
        ) |>
        rvest::html_elements("tbody") |>
        rvest::html_children() |>
        rvest::html_attr("id")

      asl_class <- gsub("_.*", "", as.character(asl_gloss))

      msg <- paste0("Sign <", gloss[i], "> not found!")

      stopifnot(msg = (asl_class == "focusgloss"))

      asl_id <- gsub(".*_", "", as.character(asl_gloss))

      out_ids[i] <- asl_id

    } else {

      sts_id <-
        xml2::read_html(
          paste0(
            "https://teckensprakslexikon.su.se/sok?q=",
            gloss[i])
        ) |>
        rvest::html_nodes(xpath=".//div[contains(@class, 'w-24 flex-shrink-0')]//following-sibling::a") |>
        rvest::html_attr("href") |>
        unique() |>
        gsub("/ord/", "", x = _)

      if (is.na(sts_id[1])) {

        message(paste0("Sign <", gloss[i], "> not found!"))
        out_ids[i] <- ""

      } else {

        out_ids[i] <- paste0(sts_id, collapse = "|")

      }

    }

  }

  # Return output IDs
  return(out_ids)

}
