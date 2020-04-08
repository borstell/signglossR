#' Find ID gloss from ID number (ASL Signbank)
#'
#' This function inputs an ASL ID number as an integer or string and outputs the
#' unique ID gloss linked to the same sign (its Signbank entry).
#'
#' @importFrom magrittr %>%
#' @param id ID number for the ASL sign
#' @return The unique ID gloss linked to the sign used as its label in Signbank
#' @export
id2gloss_asl <- function(id) {
  asl_id <- xml2::read_html(paste0("https://aslsignbank.haskins.yale.edu/dictionary/gloss/", id, ".html")) %>%
    rvest::html_nodes("[id='annotation_idgloss_en_US']") %>%
    rvest::html_text()
  return(asl_id)
}
