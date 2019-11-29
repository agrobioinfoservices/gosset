% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rank_tricot.R
\name{rank_tricot}
\alias{rank_tricot}
\title{Build Plackett-Luce rankings from tricot dataset}
\usage{
rank_tricot(
  data = NULL,
  items = NULL,
  input = NULL,
  additional.rank = NULL,
  group = FALSE,
  ...
)
}
\arguments{
\item{data}{a data frame with columns specified by items and input values}

\item{items}{a data frame or index of \code{data} for the column(s) containing the item names}

\item{input}{a data frame or index of \code{data} for the column(s) containing the values to be ranked}

\item{additional.rank}{optional, a data frame for the comparisons between tricot items and the local item}

\item{group}{logical, if TRUE return an object of class "grouped_rankings"}

\item{...}{additional arguments passed to methods. See details}
}
\value{
a PlackettLuce "rankings" object, which is a matrix of dense rankings
}
\description{
Create an object of class "rankings" from tricot data. Tricot stands for "triadic 
comparison of technologies". Is a methodology to carry out large agronomic field experiments allowing 
the comparison between many alternative technologies, in many different environments. Each participant
evaluates a set of three randomised technologies from a larger set.
}
\details{
full.output: logical, to return a list with a "rankings", a "grouped_rankings" and the ordered items
}
\examples{

# using breadwheat data
data("breadwheat", package = "gosset")

# convert the tricot rankings from breadwheat data
# into a object of class 'rankings' from PlackettLuce
R <- rank_tricot(breadwheat,
                 items = c("variety_a","variety_b","variety_c"),
                 input = c("overall_best","overall_worst"))
                 
############################################################
  
# beans data where each observer compares 3 varieties randomly distributed
# from a list of 11 and additionally compares these 3 varieties
# with their local variety
library("PlackettLuce")
data("beans", package = "PlackettLuce")

# first build rankings with only tricot items
# and return an object of class 'rankings'
R <- rank_tricot(data = beans,
                    items = c(1:3),
                    input = c(4:5))
head(R)

############################################################

# pass the comparison with local item as an additional rankings, then
# each of the 3 varieties are compared separately with the local item
# and return an object of class grouped_rankings
G <- rank_tricot(data = beans,
                    items = c(1:3),
                    input = c(4:5),
                    additional.rank = beans[c(6:8)],
                    group = TRUE)

head(G)

}
\references{
van Etten J., et al. (2019). Experimental Agriculture, 55(S1), 275–296. https://doi.org/10.1017/S0014479716000739.
}
\seealso{
\code{\link[PlackettLuce]{rankings}}  \code{\link{breadwheat}}
}