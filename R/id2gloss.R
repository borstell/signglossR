#' Find ID gloss from ID number
#'
#' This function inputs an ID number as an integer or string and outputs the
#' unique ID gloss linked to the same sign (its dictionary entry).
#'
#' @param id ID number for the sign
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @return The unique ID gloss linked to the sign used as its label in Signbank
#' @export
id2gloss <- function(id, acronym="sts") {
  acronym <- tolower(acronym)
  if (acronym == "asl") {
    gloss <- signglossR::id2gloss_asl(id)
  }
  if (acronym %in% c("sts", "ssl")) {
    gloss <- signglossR::id2gloss_sts(id)
  }
  return(gloss)
}
