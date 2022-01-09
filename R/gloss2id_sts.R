#' Find ID number from ID gloss (STS)
#'
#' This function inputs an STS gloss as a string and outputs the unique
#' ID number linked to the same sign (its Signbank index).
#'
#' @param gloss ID gloss for the sign
#' @return An ID number linked to the sign gloss
#' @export
gloss2id_sts <- function(gloss) {
  if (!signglossR::isNotNumeric(gloss)) {
    message("The <gloss> argument has to be a word string (e.g. 'TAXI')")
  }
  else {
    id <- xml2::read_html(paste0("https://teckensprakslexikon.su.se/sok?q=", gloss)) %>%
      rvest::html_element("[class='id nomobile']") %>%
      rvest::html_element("span") %>%
      rvest::html_text()
    return(id)
  }
}
