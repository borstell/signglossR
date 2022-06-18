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

  B\u00f6rstell, Carl. 2022. Introducing the signglossR Package.
  In Eleni Efthimiou, Stavroula-Evita Fotinea, Thomas Hanke, Julie A. Hochgesang,
  Jette Kristoffersen, Johanna Mesch & Marc Schulder (eds.), Proceedings of the
  LREC2022 10th Workshop on the Representation and Processing of Sign Languages:
  Multilingual Sign Language Resources, 16–23. Marseille: European Language Resources
  Association (ELRA). https://www.sign-lang.uni-hamburg.de/lrec/pub/22006.pdf.

A BibTeX entry for LaTeX users is

@inproceedings{borstell:22006:sign-lang:lrec,
  author    = {B{\"o}rstell, Carl},
  title     = {Introducing the {signglossR} Package},
  pages     = {16--23},
  editor    = {Efthimiou, Eleni and Fotinea, Stavroula-Evita and Hanke, Thomas and Hochgesang, Julie A. and Kristoffersen, Jette and Mesch, Johanna and Schulder, Marc},
  booktitle = {Proceedings of the {LREC2022} 10th Workshop on the Representation and Processing of Sign Languages: Multilingual Sign Language Resources},
  maintitle = {13th International Conference on Language Resources and Evaluation ({LREC} 2022)},
  publisher = {{European Language Resources Association (ELRA)}},
  address   = {Marseille, France},
  day       = {25},
  month     = jun,
  year      = {2022},
  isbn      = {979-10-95546-86-3},
  language  = {english},
  url       = {https://www.sign-lang.uni-hamburg.de/lrec/pub/22006.pdf}
}
      "
    )
  }
}
