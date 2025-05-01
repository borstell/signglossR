#' Cite source
#'
#' This function outputs the preferred citation for the
#' signglossR package and its main dictionary sources.
#'
#' @return The preferred citation format for the package and language resources
#' @export
cite_source <- function() {

  year <- substr(Sys.time(), 1, 4)

  message(
    paste0(
      "
To cite ASL Signbank in publications, please use:

  Julie A. Hochgesang, Onno Crasborn & Diane Lillo-Martin. ", year, " ASL Signbank.
  New Haven, CT: Haskins Lab, Yale University.
  http://aslsignbank.com/

      (See also: http://aslsignbank.com/about/conditions/)

A BibTeX entry for LaTeX users is

@Manual{aslsignbank,
    title = {{ASL Signbank}},
    author = {Julie A. Hochgesang and Onno Crasborn and Diane Lillo-Martin},
    organization = {Haskins Lab, Yale University},
    address = {New Haven, CT},
    year = {", year, "},
    url = {http://aslsignbank.com}
  }

To cite the STS dictionary in publications, please use:

  Svenskt teckenspr\u00e5kslexikon. ", year, ". Svenskt teckenspr\u00e5kslexikon. Stockholm:
  Sign Language Section, Department of Linguistics, Stockholm University.
  https://teckensprakslexikon.ling.su.se

      (See also: https://teckensprakslexikon.ling.su.se/information)

A BibTeX entry for LaTeX users is

@Manual{tsplex,
    title = {Svenskt teckenspr\u00e5kslexikon},
    author = {Svenskt teckenspr\u00e5kslexikon},
    organization = {Sign Language Section, Department of Linguistics, Stockholm University},
    address = {Stockholm},
    year = {", year, "},
    url = {https://teckensprakslexikon.ling.su.se}
  }


To cite signglossR in publications, please use:

  B\u00f6rstell, Carl. 2022. Introducing the signglossR Package.
  In Eleni Efthimiou, Stavroula-Evita Fotinea, Thomas Hanke, Julie A. Hochgesang,
  Jette Kristoffersen, Johanna Mesch & Marc Schulder (eds.), Proceedings of the
  LREC2022 10th Workshop on the Representation and Processing of Sign Languages:
  Multilingual Sign Language Resources, 16-23. Marseille: European Language Resources
  Association (ELRA). https://aclanthology.org/2022.signlang-1.3/.

A BibTeX entry for LaTeX users is

@inproceedings{borstell-2022-introducing,
  author    = {B{\\\"o}rstell, Carl},
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
  url       = {https://aclanthology.org/2022.signlang-1.3/}
}

The signglossR package relies heavily on the {magick} package.
Use citation('magick') for the appropriate citation.

      "
    )
  )
}
