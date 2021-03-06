% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/HTSSIP_sim.R
\name{gradient_sim}
\alias{gradient_sim}
\title{Simulate HTS-SIP communities for 1 density gradient}
\usage{
gradient_sim(locs, params, responseModel = "gaussian",
  countModel = "poisson", ...)
}
\arguments{
\item{locs}{Buoyant densities of each gradient fraction}

\item{params}{A matrix of parameters for \code{coenocliner::coenocline()}.
See that function's documentation for more details.}

\item{responseModel}{See \code{coenocliner::coenocline()}}

\item{countModel}{See \code{coenocliner::coenocline()}}

\item{...}{Other parameters passed to \code{coenocliner::coenocline()}}
}
\value{
A data.frame of OTU counts.
}
\description{
Simulate HTS-SIP communities for 1 density gradient
}
\examples{
# setting parameters
set.seed(2)
M = 10                                  # number of species (OTUs)
ming = 1.67                             # gradient minimum...
maxg = 1.78                                # ...and maximum
nfrac = 24                                 # number of gradient fractions
locs = seq(ming, maxg, length=nfrac)       # gradient fraction BD values
tol = rep(0.005, M)                       # species tolerances
h = ceiling(rlnorm(M, meanlog=11))    # max abundances
opt = rnorm(M, mean=1.7, sd=0.005)      # species optima
params = cbind(opt=opt, tol=tol, h=h)  # put in a matrix
# simulate the OTU abundances
df_OTU = gradient_sim(locs, params)
head(df_OTU)

}
