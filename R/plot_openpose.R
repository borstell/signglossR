#' Plot OpenPose
#'
#' This function inputs a data frame from `read_openpose(wide=FALSE)` (.eaf) and plots the positions of the hands (keypoints 4 and 7)
#'
#' @param data The data frame with OpenPose data in wide format
#' @param point_size The size of the hand location points (default=5)
#' @param hands Which hands to plot: options are `both` (default), `right`, and `left`
#' @param right_color The color of the right hand (keypoint 4) articulation (default="green")
#' @param left_color The color of the left hand (keypoint 7) articulation (default="red")
#' @param path_color Whether to color the articulation based on the movement path, chronologically lighter to darker (default=FALSE)
#' @param silhouette Whether to include a "ghost" silhouette of a signer as reference (default=0; 1 is fully visible)
#' @return A ggplot2 object
#' @export
plot_openpose <- function(data, point_size=5, hands="both", right_color="green3", left_color="red3", path_color=FALSE, silhouette=0) {
  coord_dist <- function(x1,y1, x2, y2) {
    return(sqrt((x1-x2)^2+(y1-y2)^2))
  }
  silhouette_color <- "darkgrey"
  silhouette_alpha <- silhouette
  point_alpha <- 1
  if (path_color) {
    point_alpha <- data$frame/nrow(data)
  }
  right_alpha <- point_alpha
  left_alpha <- point_alpha
  if (hands == "right") {
    left_alpha <- 0
  }
  if (hands =="left") {
    right_alpha <- 0
  }
  plot <- ggplot2::ggplot() +
    # Head
    ggforce::geom_ellipse(data=subset(data, data$frame==1), ggplot2::aes(x0 = mean(data$x_0), y0 = mean(data$y_0), a = coord_dist(mean(data$x_0), mean(data$y_0), mean(data$x_18), mean(data$y_18))*1.1, b = coord_dist(mean(data$x_0), mean(data$y_0), mean(data$x_18), mean(data$y_18))*1.6, angle=0), fill = silhouette_color, alpha=silhouette_alpha, linetype=0) +
    # Chest
    ggforce::geom_ellipse(data=subset(data, data$frame==1), ggplot2::aes(x0 = mean(data$x_0), y0 = mean(data$y_1), a = coord_dist(mean(data$x_2), mean(data$y_2), mean(data$x_1), mean(data$y_1)), b =  coord_dist(mean(data$x_2), mean(data$y_2), mean(data$x_1), mean(data$y_1))*.7, angle=0), fill = silhouette_color, alpha=silhouette_alpha, linetype=0) +
    # Torso
    ggforce::geom_ellipse(data=subset(data, data$frame==1), ggplot2::aes(x0 = mean(data$x_0), y0 = mean(data$y_1)+abs(mean(data$y_0)-mean(data$y_8))*.3, a = coord_dist(mean(data$x_2), mean(data$y_2), mean(data$x_1), mean(data$y_1)), b =  coord_dist(mean(data$x_1), mean(data$y_1), mean(data$x_8), mean(data$y_8))*.45, angle=0), fill = silhouette_color, alpha=silhouette_alpha, linetype=0) +
    # Left + Right shoulder
    ggforce::geom_ellipse(data=subset(data, data$frame==1), ggplot2::aes(x0 = mean(data$x_2), y0 = mean(data$y_2), a = .08, b =  .08, angle=0), fill = silhouette_color, alpha=silhouette_alpha, linetype=0) +
    ggforce::geom_ellipse(data=subset(data, data$frame==1), ggplot2::aes(x0 = mean(data$x_5), y0 = mean(data$y_5), a = .08, b =  .08, angle=0), fill = silhouette_color, alpha=silhouette_alpha, linetype=0) +
    # Right arm (upper, lower)
    ggplot2::geom_segment(data=subset(data, data$frame==1), ggplot2::aes(x = mean(data$x_2), y = mean(data$y_2), xend = mean(data$x_3), yend = mean(data$y_3)), color = silhouette_color, alpha=silhouette_alpha, size=15, linejoin = "round") +
    ggplot2::geom_segment(data=subset(data, data$frame==1), ggplot2::aes(x = mean(data$x_3), y = mean(data$y_3), xend = mean(data$x_3), yend = data$y_3+coord_dist(mean(data$x_2), mean(data$y_2), mean(data$x_3), mean(data$y_3))*.6), color = silhouette_color, alpha=silhouette_alpha, size=13, linejoin = "round") +
    # Left arm (upper, lower)
    ggplot2::geom_segment(data=subset(data, data$frame==1), ggplot2::aes(x = mean(data$x_5), y = mean(data$y_5), xend = mean(data$x_6), yend = mean(data$y_6)), color = silhouette_color, alpha=silhouette_alpha, size=15, linejoin = "round") +
    ggplot2::geom_segment(data=subset(data, data$frame==1), ggplot2::aes(x = mean(data$x_6), y = mean(data$y_6), xend = mean(data$x_6), yend = data$y_6+coord_dist(mean(data$x_5), mean(data$y_5), mean(data$x_6), mean(data$y_6))*.6), color = silhouette_color, alpha=silhouette_alpha, size=13, linejoin = "round") +
    # Hands (right, left)
    ggplot2::geom_point(data=data, ggplot2::aes(x = data$x_4, y = data$y_4, color=right_color), alpha=right_alpha, size=point_size) +
    ggplot2::geom_point(data=data, ggplot2::aes(x = data$x_7, y = data$y_7, color=left_color), alpha=left_alpha, size=point_size) +
    # Plot styling
    ggplot2::xlim(0,1) + ggplot2::ylim(0,1) +
    ggplot2::scale_color_identity() +
    ggplot2::scale_y_reverse() +
    ggplot2::coord_fixed() +
    ggplot2::theme_void()
  return(plot)
}
