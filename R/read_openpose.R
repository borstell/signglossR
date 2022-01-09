#' Read OpenPose data (.json)
#'
#' This function reads OpenPose generated JSON files in a directory and outputs a data frame
#'
#' @param path The path to the directory with OpenPose JSON data
#' @param wide Whether the output data frame should be transformed to wide format (default=TRUE)
#' @param fill_zero Whether zero values should be filled with nearest non-zero value (default=FALSE)
#' @return A data frame containing the OpenPose data
#' @export
read_openpose <- function(path, wide=TRUE, fill_zero=FALSE) {
  filenames = list.files(path = path, pattern="*.json")
  datalist = list()
  n <- 0
  for (f in filenames){
    fname <- substr(f, 1, nchar(f)-28)
    openpose <- jsonlite::fromJSON(paste0(path, f))
    kp <- openpose$people$pose_keypoints_2d[[1]]
    keys <- data.frame(x=kp[c(TRUE, FALSE, FALSE)], y=kp[c(FALSE, TRUE, FALSE)], ci=kp[c(FALSE, FALSE, TRUE)], keypoint=1:(length(kp)/3)-1, file=fname)
    keys$frame <- n+1
    datalist[[n+1]] <- keys
    n <- n+1
  }
  keys <- dplyr::bind_rows(datalist)
  if (wide == TRUE) {
    keys <- keys %>%
      dplyr::group_by("frame") %>%
      tidyr::pivot_wider(names_from = "keypoint", values_from = c("x", "y", "ci"))
    if (fill_zero) {
      keys <- dplyr::na_if(keys, 0)
      keys <- data.frame(keys)
      keys <- keys %>%
        tidyr::fill(.direction = "up", tidyr::everything()) %>%
        tidyr::fill(tidyr::everything())
    }
  }
  return(keys)
}

