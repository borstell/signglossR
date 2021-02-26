#' Find ID number from ID gloss (ASL Signbank)
#'
#' This function inputs an ASL ID gloss as a string and outputs the unique
#' ID number linked to the same sign (its Signbank index).
#'
#' @param gloss ID gloss for the ASL sign
#' @return The unique ID number linked to the sign used for indexing online
#' @export
gloss2id_asl <- function(gloss) {
  if (!signglossR::isNotNumeric(gloss)) {
    message("The <gloss> argument has to be a word string (e.g. 'DEAFix')")
  }
  else {
    asl_gloss <- xml2::read_html(paste0("https://aslsignbank.haskins.yale.edu/signs/search/?search=%5E", gloss, "%24&keyword=")) %>%
      rvest::html_nodes("*") %>%
      rvest::html_attrs()
    asl_class <- gsub("_.*", "", as.character(asl_gloss[745]))
    if (asl_class == "focusgloss") {
      asl_id <- gsub(".*_", "", as.character(asl_gloss[745]))
      return(as.character(asl_id))
    }
    else {
      message(paste0("Sign <", gloss, "> not found!"))
      stop()
    }
  }
}
