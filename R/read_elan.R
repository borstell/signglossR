#' Reads an ELAN (.eaf) file
#'
#' @param eaf_file Path to ELAN (.eaf) file
#' @param tiers Specify tiers (TIER_ID or TIER_TYPE) to be read
#' @param target_annotations Specify which annotations to be kept (default `NULL` = all)
#' @return Tibble of the ELAN annotations
#' @export
#' @importFrom rlang .data
read_elan <- function(eaf_file = NULL,
                      tiers = NULL,
                      target_annotations = NULL) {

  # Check that at least one .eaf file is found
  stopifnot("No .eaf file found" = (endsWith(eaf_file, "eaf") & file.exists(eaf_file)))

  # Read as .xml
  eaf <- xml2::read_xml(eaf_file)

  # Make tibble from timestamp data
  ts <- xml2::xml_find_all(eaf, ".//TIME_SLOT")
  times <- dplyr::tibble(TIME_SLOT_ID = xml2::xml_attr(ts, "TIME_SLOT_ID"),
                         TIME_VALUE = xml2::xml_attr(ts, "TIME_VALUE"))

  # Restrict parse to custom selected tiers only
  stopifnot("No tiers selected!" = length(tiers) > 0)
  tier_attrs <- paste0(".//TIER[", paste0("@TIER_ID='", tiers, "'", collapse = " or "), "]")

  # Make tibble from annotations
  annotations <-
    eaf |>
    xml2::xml_find_all(tier_attrs) |>
    xml2::xml_children() |>
    xml2::xml_children()

  # Iterate through nodes and find parent attributes
  if (length(annotations) > 0) {
    annotations <-
      annotations |>
      purrr::map(
        \(x)
        c(
          a = xml2::xml_attr(x, "ANNOTATION_ID"),
          ts1 = xml2::xml_attr(x, "TIME_SLOT_REF1"),
          ts2 = xml2::xml_attr(x, "TIME_SLOT_REF2"),
          annotation = xml2::xml_text(x),
          tier = xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(x)), "TIER_ID"),
          tier_type = xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(x)), "LINGUISTIC_TYPE_REF"),
          participant = xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(x)), "PARTICIPANT"),
          annotator = xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(x)), "ANNOTATOR"),
          parent_ref = xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(x)), "PARENT_REF"),
          a_ref = xml2::xml_attr(x, "ANNOTATION_REF")
        )
      ) |>
      dplyr::bind_rows() |>

      # Mutate columns and join with timestamp data
      dplyr::left_join(dplyr::rename(times, start = dplyr::all_of("TIME_VALUE")), by = dplyr::join_by("ts1" == "TIME_SLOT_ID")) |>
      dplyr::left_join(dplyr::rename(times, end = dplyr::all_of("TIME_VALUE")), by = dplyr::join_by("ts2" == "TIME_SLOT_ID")) |>
      dplyr::mutate(dplyr::across(dplyr::all_of("start"):dplyr::all_of("end"), as.double)) |>
      dplyr::mutate(file = basename(eaf_file),
                    duration = .data$end - .data$start) |>
      dplyr::relocate(dplyr::all_of("file"), .before = 1)

    }

    # Filter to only glosses specified in input
    if (length(target_annotations) > 0) {

      annotations <-
        annotations |>
        dplyr::filter(.data$annotation %in% target_annotations)

    }

    # Return annotations
    return(annotations)

  }

