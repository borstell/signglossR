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

  Julie A. Hochgesang, Onno Crasborn & Diane Lillo-Martin. 2020. ASL Signbank.
  New Haven, CT: Haskins Lab, Yale University.
  https://aslsignbank.haskins.yale.edu/

      (See also: https://aslsignbank.haskins.yale.edu/about/conditions/)

A BibTeX entry for LaTeX users is

@Manual{aslsignbank,
    title = {{ASL Signbank}},
    author = {Julie A. Hochgesang and Onno Crasborn and Diane Lillo-Martin},
    organization = {Haskins Lab, Yale University},
    address = {New Haven, CT},
    year = {2020},
    url = {https://aslsignbank.haskins.yale.edu/}
  }
      "
    )
  }
  if (acronym %in% c("sts", "ssl")) {
    message(
      "
To cite the STS dictionary in publications, please use:

  Svenskt teckenspråkslexikon. 2020. Svenskt teckenspråkslexikon. Stockholm:
  Sign Language Section, Department of Linguistics, Stockholm University.
  https://teckensprakslexikon.ling.su.se/

      (See also: https://teckensprakslexikon.ling.su.se/information)

A BibTeX entry for LaTeX users is

@Manual{tsplex,
    title = {Svenskt teckenspr{\aa}kslexikon},
    author = {Svenskt teckenspr{\aa}kslexikon},
    organization = {Sign Language Section, Department of Linguistics, Stockholm University},
    address = {Stockholm},
    year = {2020},
    url = {https://teckensprakslexikon.ling.su.se/}
  }
      "
    )
  }
  if (acronym == "signglossr") {
    message(
      "
To cite signglossR in publications, please use:

  Börstell, Carl. 2020. signglossR: Facilitating visual representation of sign
  language data. R package version 1.2.0. Radboud University, Nijmegen.
  https://github.com/borstell/signglossR

A BibTeX entry for LaTeX users is

@Manual{signglossR,
    title = {{signglossR}: Facilitating visual representation of sign language data},
    author = {Carl Börstell},
    organization = {Radboud University, Nijmegen},
    address = {Nijmegen},
    note = {R package version 1.2.0},
    year = {2020},
    url = {https://github.com/borstell/signglossR},
  }
      "
    )
  }
}
