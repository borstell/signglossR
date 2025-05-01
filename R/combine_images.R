#' Combine images
#'
#' This function inputs a list of image files and outputs a concatenated or overlay image
#'
#' @param images A vector of image files to be combined
#' @param filename The filename of the combined output image
#' @param path The path to the combined output image
#' @param stack Optional argument if concatenated image wanted: default FALSE gives horizontal sequence; TRUE gives vertically stacked
#' @param overlay Optional argument if overlay image wanted (defaults to FALSE)
#' @param blend Level of blending between images (if overlay = `TRUE`)
#' @param skip Whether to skip one image before applying pairwise composite (if overlay = `TRUE`)
#' @param trim Optional argument if horizontal trim wanted (values 0 to 1; default = 1)
#' @return The name of the output image file
#' @export
combine_images <- function(images,
                           filename = NULL,
                           path = NULL,
                           stack = FALSE,
                           overlay = FALSE,
                           blend = 80,
                           skip = 0,
                           trim = 1) {

  # Check inputs
  stopifnot("Input needs to be a vector of multiple image files" = is.vector(images))
  stopifnot("Please provide a filename for the output file" = !is.null(filename))

  # Complete output filename
  outfile <- paste0(path, filename)

  # Set up tempfiles
  tmp_dir <- tempdir()
  temp_files <- paste0(tmp_dir, "/", basename(images))

  # Read image and metadata
  im <- magick::image_read(images[1])
  width <- magick::image_info(im)[, 2]
  height <- magick::image_info(im)[, 3]

  # Apply trimming
  if (trim > 0 & trim < 1) {

    mid <- c(width * (1 - trim) / 2, height)
    new_width <- width * trim
    geomstring <- paste0(new_width, "x", height, "+", mid[1], "+", 0)

    lapply(images, \(x) magick::image_write(magick::image_crop(magick::image_read(x), geomstring), paste0(tmp_dir, "/", basename(x))))

    # ... or not
  } else {

    lapply(images, \(x) magick::image_write(magick::image_read(x), paste0(tmp_dir, "/", basename(x))))

  }

  # Apply overlay by pairwise blending
  if (overlay == TRUE & length(temp_files) > 1) {

    # Store blended images
    overlays <- c()

    # Allow to skip first image for overlay pairing
    if (skip == 1) {

      ixs <- seq(2, length(temp_files) - 1, by = 2)

    } else {

      ixs <- seq(1, length(temp_files) - 1, by = 2)

    }

    # Blend pairwise images
    for (i in ixs) {

      img1 <- magick::image_read(temp_files[i])
      img2 <- magick::image_read(temp_files[i + 1])

      overlay_img <-
        magick::image_composite(img1, img2, operator = "dissolve", compose_args = paste0(blend, "%")) |>
        magick::image_write(temp_files[i])

      overlays <- c(overlays, overlay_img)

    }

    # Add unblended images
    if (length(temp_files) %% 2 == 1 & skip != 1) {

      overlays <- c(overlays, temp_files[length(temp_files)])

    }

    if (skip == 1) {

      overlays <- c(temp_files[1], overlays)

    }

    # Apply scaling and write file
    dimstring <- paste0("x", height)
    overlays |>
      magick::image_read() |>
      magick::image_scale(geometry = dimstring) |>
      magick::image_append() |>
      magick::image_write(path = outfile)

  } else {

    if (stack == TRUE) {

      dimstring <- paste0(width, "x")
      temp_files |>
        magick::image_read() |>
        magick::image_scale(geometry = dimstring) |>
        magick::image_append(stack = stack) |>
        magick::image_write(path = outfile)

    } else {

      dimstring <- paste0("x", height)
      temp_files |>
        magick::image_read() |>
        magick::image_scale(geometry = dimstring) |>
        magick::image_append() |>
        magick::image_write(path = outfile)

    }

    # Unlink tempfiles
    lapply(temp_files, unlink)

  }

  # Return output filename
  return(outfile)

}
