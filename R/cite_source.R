#' Cite source
#'
#' This function inputs a sign language acronym (e.g. "ASL") and
#' outputs the preferred citation for the original source used in signglossR.
#'
#' @param acronym A sign language acronym used by signglossR
#' @return The preferred citation format for the language resource used
#' @export
cite_source <- function(acronym="signglossR") {
  acronym <- tolower(acronym)
  if (acronym == "asl") {
    message(
      "
To cite ASL Signbank in publications, please use:

  Julie A. Hochgesang, Onno Crasborn & Diane Lillo-Martin. 2022. ASL Signbank.
  New Haven, CT: Haskins Lab, Yale University.
  https://aslsignbank.haskins.yale.edu/

      (See also: https://aslsignbank.haskins.yale.edu/about/conditions/)

A BibTeX entry for LaTeX users is

@Manual{aslsignbank,
    title = {{ASL Signbank}},
    author = {Julie A. Hochgesang and Onno Crasborn and Diane Lillo-Martin},
    organization = {Haskins Lab, Yale University},
    address = {New Haven, CT},
    year = {2022},
    url = {https://aslsignbank.haskins.yale.edu/}
  }
      "
    )
  }
  if (acronym %in% c("sts", "ssl")) {
    message(
      "
To cite the STS dictionary in publications, please use:

  Svenskt teckenspr\u00e5kslexikon. 2022. Svenskt teckenspr\u00e5kslexikon. Stockholm:
  Sign Language Section, Department of Linguistics, Stockholm University.
  https://teckensprakslexikon.ling.su.se/

      (See also: https://teckensprakslexikon.ling.su.se/information)

A BibTeX entry for LaTeX users is

@Manual{tsplex,
    title = {Svenskt teckenspr\u00e5kslexikon},
    author = {Svenskt teckenspr\u00e5kslexikon},
    organization = {Sign Language Section, Department of Linguistics, Stockholm University},
    address = {Stockholm},
    year = {2022},
    url = {https://teckensprakslexikon.ling.su.se/}
  }
      "
    )
  }
  if (acronym == "signglossr") {
    message(
      "
To cite signglossR in publications, please use:

  B\u00f6rstell, Carl. 2022. signglossR: Facilitating visual representation of sign
  language data. R package version 2.2.0. University of Bergen.
  https://github.com/borstell/signglossR

A BibTeX entry for LaTeX users is

@Manual{signglossR,
    title = {{signglossR}: Facilitating visual representation of sign language data},
    author = {Carl B\u00f6rstell},
    organization = {Stockholm University},
    address = {Stockholm},
    note = {R package version 2.2.2},
    year = {2022},
    url = {https://github.com/borstell/signglossR},
  }
      "
    )
  }
}
