#' Kendall rank correlation coefficient
#' 
#' Compute Kendall rank correlation coefficient between two objects. 
#' Kendall is a coefficient used in statistics to measure the ordinal 
#' association between two measured quantities. A tau test is a non-parametric 
#' hypothesis test for statistical dependence based on the tau coefficient.
#' The 'kendallTau' function applies the "kendall" method from 'stats::cor' 
#' with some previous treatment in the data, such as converting floating numbers
#' into ranks (from the higher being the first and negative being the last) 
#' and the possibility to remove zeros from incomplete ranks
#' 
#' @author Kauê de Sousa and Jacob van Etten
#' @family goodness-of-fit functions
#' @param x a numeric vector, matrix or data frame
#' @param y a vector, matrix or data frame with compatible dimensions to \code{x}
#' @param ... further arguments afecting the Kendall tau produced. See details 
#' @details 
#' 
#' null.rm logical, to remove zeros from \code{x} and \code{y} 
#' 
#' @return The Kendall correlation coefficient and the Effective N, which 
#' is the equivalent N needed if all items were compared to all items. 
#' Can be used for significance testing.
#' @references 
#' 
#' Kendall M. G. (1938). Biometrika, 30(1–2), 81–93. 
#' https://doi.org/10.1093/biomet/30.1-2.81.
#' 
#' @examples
#' 
#' # check the correlation between observed rankings 
#' # and the predicted rankings from PlackettLuce
#' 
#' library("PlackettLuce")
#' 
#' R <- matrix(c(1, 2, 4, 3,
#'               1, 4, 2, 3,
#'               1, 2, 4, 3,
#'               1, 2, 4, 3,
#'               1, 3, 4, 2,
#'               1, 4, 3, 2), nrow = 6, byrow = TRUE)
#' colnames(R) <- LETTERS[1:4]
#' 
#' G <- group(as.rankings(R), 1:6)
#' 
#' mod <- pltree(G ~ 1, data = G)
#' 
#' preds <- predict(mod)
#' 
#' k <- kendallTau(R, preds)
#' 
#' # also applies to a single observation in the matrix
#' 
#' k <- kendallTau(R[1,], preds[1,])
#' 
#' @seealso \code{\link[stats]{cor}}
#' 
#' @importFrom methods addNextMethod asMethodDefinition assignClassDef
#' @importFrom stats cor
#' @importFrom PlackettLuce as.grouped_rankings
#' @export
kendallTau<- function(x, y, ...){
  
  UseMethod("kendallTau")
  
}

#' @rdname kendallTau
#' @export
kendallTau.default <- function(x, y, ...){
  
  
  kt <- .get_kendall(x, y, ...)
  
  # Extract the values from the vector
  N <- kt[2]
  
  # Effective N is the equivalent N needed if all were compared to all
  # N_comparisons = ((N_effective - 1) * N_effective) / 2
  # This is used for significance testing later
  N_effective <- 0.5 + sqrt(0.25 + 2 * sum(N)) 
  
  kt[2] <- N_effective
  
  names(kt) <- c("kendallTau", "N_effective")
  
  kt <- t(as.data.frame(kt))
  
  
  kt <- tibble::as_tibble(kt)
  
  return(kt)
  
}

#' @rdname kendallTau
#' @method kendallTau matrix
#' @export
kendallTau.matrix <- function(x, y, ...){
  
  nc <- ncol(x)
  
  kt <- apply(cbind(x, y), 1, function(K){
    
    X <- K[1:nc]
    Y <- K[(nc + 1):(nc * 2)]
    
    .get_kendall(X, Y)
    
  })
  
  # Extract the values from the matrix
  tau <- kt[1,]
  N <- kt[2,]
  
  tau_average <- sum(tau * N, na.rm = TRUE) / sum(N)
  
  # Effective N is the equivalent N needed if all were compared to all
  # N_comparisons = ((N_effective - 1) * N_effective) / 2
  # This is used for significance testing later
  N_effective <- 0.5 + sqrt(0.25 + 2 * sum(N)) 
  
  kt <- c(tau_average, N_effective)
  
  names(kt) <- c("kendallTau", "N_effective")
  
  kt <- t(as.data.frame(kt))
  
  kt <- as.data.frame(kt)
  
  class(kt) <- union("gosset_df", class(kt))
  
  return(kt)
  
}


#' @rdname kendallTau
#' @method kendallTau data.frame
#' @export
kendallTau.data.frame <- function(x, y, ...){
  
  kendallTau.matrix(x, y, ...)

}

#' @rdname kendallTau
#' @method kendallTau rankings
#' @export
kendallTau.rankings <- function(x, y, ...){
  
  X <- x[1:nrow(x), , as.rankings = FALSE]
  
  Y <- y[1:nrow(y), , as.rankings = FALSE]
  
  kendallTau.matrix(X, Y, ...)
  
}


#' @rdname kendallTau
#' @method kendallTau grouped_rankings
#' @export
kendallTau.grouped_rankings <- function(x, y, ...){
  
  X <- x[1:length(x), , as.grouped_rankings = FALSE]
  
  Y <- y[1:length(y), , as.grouped_rankings = FALSE]
  
  kendallTau.matrix(X, Y, ...)
  
}

#' @rdname kendallTau
#' @method kendallTau paircomp
#' @export
kendallTau.paircomp <- function(x, y, ...) {
  
  x <- PlackettLuce::as.grouped_rankings(x)
  
  X <- x[1:length(x), as.grouped_rankings = FALSE]
  
  y <- PlackettLuce::as.grouped_rankings(y)
  
  Y <- y[1:length(y), as.grouped_rankings = FALSE]
  
  kendallTau.matrix(X, Y, ...)
  
}


#' Kendall tau for a vector
#' 
#' Applies the "kendall" method from stats::cor with some 
#' previous treatment in the data, such as converting floating number into 
#' ranks (from the higher being the first and negative being the last) 
#' and removing zeros from incomplete ranks
#'
#' @param x a object of class numeric 
#' @param y a object of class numeric 
#' @param null.rm logical, to remove zeros from \code{x} and \code{y} 
#' @return The Kendall correlation coefficient and the Effective N
#' @examples
#' p1 <- c(1,2,3,4,5,6,7)
#' p2 <- c(1,2,0,3,5,7,6)
#' 
#' .get_kendall(p1, p2, null.rm = TRUE)
#' .get_kendall(p1, p2, null.rm = FALSE)
#' @noRd
.get_kendall <- function(x, y, null.rm = TRUE, ...) {
  
  keep <- !is.na(x) & !is.na(y)
  
  # if TRUE, remove zeros in both rankings
  if (null.rm) {
    
    keep <- x != 0 & y != 0 & keep
    
  }
  
  x <- x[keep]
  
  y <- y[keep]
  
  # if any decimal in x or y transform it to integer rankings
  # decimals will be computed as descending rankings
  # where the highest values are the "best" 
  # negative values are placed as least positions
  if (any(.is_decimal(x))) {
    
    x <- .rank_decimal(x)$rank
    
  }
  
  if(any(.is_decimal(y))) {
    
    y <- .rank_decimal(y)$rank
  
  }
  
  tau_cor <- stats::cor(x, 
                        y, 
                        method = "kendall", 
                        ...)
  
  n <- length(x)
  
  weight <- n * (n - 1) / 2
  
  result <- c(tau_cor, weight)
  
  return(result)
  
  
}

