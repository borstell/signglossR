#' Segment image(s) from video based on ELAN annotations
#'
#' This function inputs an ELAN file and a video and
#' outputs images from the ELAN annotations as segments
#'
#' @param eaf The ELAN files that supplies annotations as segments
#' @param segmentation_tier Specify tier (TIER_ID) for segments
#' @param gloss_tier Specify tier(s) (TIER_ID) for glosses
#' @param target_glosses Specify which glosses to be kept (default is all glosses)
#' @param frame_offset Select image +/-n from the gloss annotation's start frame (default = 0)
#' @param gloss_text Whether to include text from `gloss_tier` (default = `FALSE`)
#' @param video The filename of the video to be modified
#' @param image_format The format of the output images (default = '.jpg')
#' @param path The path to the output images
#' @param tag Whether to use annotations as tags in filenames (default = `TRUE`)
#' @param trim Optional argument for horizontal image trim (0 to 1; default = 1)
#' @param scale The resizing proportion of the original image (0 to 1; default is 1 = original size)
#' @param crop_region The region to be cropped (e.g. '100x150+100+100', (width x height +upper_x +upper_y)).
#' @param text The text string to be added to the image
#' @param textcolor The color of the text annotation (default is "white")
#' @param boxcolor The color of the textbox (default is `NULL`)
#' @param font The font of the text annotation (default is "Helvetica")
#' @param fontsize The fontsize of the text annotation (default is 70)
#' @param rel_fontsize Whether to adjust the fontsize relative to width (x) or height (y)
#' @param gravity The anchor point of the added text (default is "southwest")
#' @param location The location of the text relative to the anchor point
#' @param border Set to `TRUE` if you want a black border frame for the output image
#' @return The names of the output image files
#' @export
segment_elan_image <- function(eaf,
                               segmentation_tier = NULL,
                               gloss_tier = NULL,
                               target_glosses = NULL,
                               frame_offset = 0,
                               gloss_text = F,
                               video = NULL,
                               image_format = ".jpg",
                               path = NULL,
                               tag = T,
                               trim = 1,
                               scale = 1,
                               crop_region = NULL,
                               text = NULL,
                               textcolor = "white",
                               boxcolor = NULL,
                               font = "Helvetica",
                               fontsize = "70",
                               rel_fontsize = NULL,
                               gravity = "southwest",
                               location = "+20+20",
                               border = FALSE) {

  # Check inputs
  stopifnot("Please provide a path for the input <video>" = !is.null(video))
  stopifnot("Please provide a name for the <segmentation_tier>" = !is.null(segmentation_tier))
  stopifnot("<eaf> does not exist" = file.exists(eaf))
  stopifnot("<video> does not exist" = file.exists(video))

  # Get video metadata
  vid_info <- av::av_video_info(video)
  fps <- vid_info$video$framerate

  # Read video as images
  imgs <-
    av::av_video_images(video, format = "png")

  # Read EAF
  data <-
    read_elan(eaf,
              tiers = c(segmentation_tier, gloss_tier)) |>
    dplyr::arrange(.data$start) |>
    dplyr::mutate(frame = as.integer(.data$start / 1000 * fps))

  # Store segments
  segs <-
    data |>
    dplyr::filter(.data$tier %in% c(segmentation_tier)) |>
    dplyr::mutate(seg = dplyr::row_number()) |>
    dplyr::select(.data$seg, .data$start, .data$end) |>
    dplyr::rename("seg_start" = .data$start,
                  "seg_end" = .data$end)

  # Store glosses
  glosses <-
    data |>
    dplyr::filter(.data$tier %in% c(gloss_tier)) |>
    dplyr::inner_join(segs, by = dplyr::join_by(within("start", "end", "seg_start", "seg_end")))

  # Stem of outfile
  outbase <- paste0(path, gsub("\\.eaf$", "", basename(eaf)))

  # Store outfiles
  outfiles <- rep(NA, max(glosses$seg))

  # Get ELAN segments
  for (s in min(glosses$seg):max(glosses$seg)) {

    start_time <- min(glosses[glosses$seg == s, ]$start)
    start_label <- paste0(paste0(rep("0", 8 - nchar(as.character(start_time))), collapse = ""), as.character(start_time))

    outfile <- paste0(outbase, "_", start_label, image_format)

    # Annotate image
    if (gloss_text) {

      compose_image(image = imgs[glosses[glosses$seg == s, ]$frame + frame_offset],
                    filename = imgs[glosses[glosses$seg == s, ]$frame + frame_offset],
                    text = glosses[glosses$seg == s, ]$annotation,
                    path = NULL,
                    scale = scale,
                    crop_region = crop_region,
                    textcolor = textcolor,
                    boxcolor = boxcolor,
                    font = font,
                    fontsize = fontsize,
                    rel_fontsize = rel_fontsize,
                    gravity = gravity,
                    location = location,
                    border = border)

      combine_images(images = imgs[glosses[glosses$seg == s, ]$frame + frame_offset],
                     filename = outfile,
                     trim = trim)

    } else {

      combine_images(imgs[glosses[glosses$seg == s, ]$frame + frame_offset],
                     filename = outfile,
                     trim = trim)

    }

    # Store outfile
    outfiles[s] <- outfile

  }

  # Return outfiles
  return(outfiles)

}

