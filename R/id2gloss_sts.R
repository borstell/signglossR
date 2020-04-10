#' Find ID gloss from ID number (Svenskt teckenspråkslexikon)
#'
#' This function inputs an STS ID number as an integer or string and outputs the
#' gloss linked to the same sign (its entry in Svenskt teckenspråkslexikon).
#'
#' @param id ID number for the STS sign
#' @return The unique ID gloss linked to the sign used as its label in Svenskt teckenspråkslexikon
#' @export
id2gloss_sts <- function(id) {
  if (signglossR::isNotNumeric(as.character(id))) {
    message("The <id> argument has to be numeric (e.g. '3' or '00004')")
    stop()
  }
  id <- stringr::str_pad(id, 5, pad = "0")
  sts_corpus_gloss_url <- xml2::read_html(paste0("https://teckensprakslexikon.su.se/ord/", id)) %>%
    rvest::html_nodes("[class='underline']") %>%
    rvest::html_attr("href")
  sts_corpus_gloss_url <- urltools::url_decode(sts_corpus_gloss_url)[1]
  gloss <- gsub(".*=", "", sts_corpus_gloss_url)
  return(gloss)
}
