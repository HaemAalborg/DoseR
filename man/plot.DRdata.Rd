\name{plot.DRdata}
\alias{plot.DRdata}
\title{
Plot of the dose response curves.
}
\description{
Plot of the dose response curves according to the specified model.
}
\usage{
\method{plot}{DRdata}(x, ..., drug = 1, 
     ylim = NULL, xlim = NULL, main = drug, 
     plot.data = FALSE, model = "G", type = "AUC", 
     ylab = NULL, xlab = NULL, cex = 1, names = NULL, 
     times = NULL, col.scheme = NULL,
     color.palette = "Dark2", n.colors = NULL, 
     reverse.col = FALSE, col = NULL, lty = NULL, pch = NULL, 
     lwd = 2, legend.place = "bottomleft", plot.order = NULL, 
     dose.scale = "mol/l", dose.logfun = "log10", legend = TRUE, 
     n.columns = 2, legend.cex = 1, use.col.order = FALSE, split = "all")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
An A.data object created by the function \code{doseResponseModel}.
}
  \item{\dots}{
Further arguments passed to plot.
}
  \item{drug}{
Character specifying the drug to be plotted.
}
  \item{ylim}{
Limits of the y-axis
}
  \item{xlim}{
Limits of the x-axis
}
  \item{main}{
Main title of the plot.
}
  \item{plot.data}{
Should the data be plotted along with the fitted curves.
}
  \item{model}{
Character specifying which dose response model the boxplot should be produced for. Currently the follwing models are implemented \code{G}, \code{Gres}, \code{R}, \code{D}, \code{DG}, and \code{RG}. Only models estimated by the function \code{doseResponseModel} can be used.
}
  \item{type}{
Character indicating the summary statistic used in the plot. This can be either of \code{GI50}, \code{TGI}, \code{LC50}, or \code{AUC}.
}
  \item{ylab}{
Name of the y-axis 
}
  \item{xlab}{
Name of the x-axis 
}
  \item{cex}{
Specify \code{cex} for the plot.
}
  \item{names}{
Character vector of the cell line names used in the plot.
}
  \item{times}{
Numeric vector specifying the timepoints the dose response curves should be based upon.
}
  \item{col.scheme}{
Specific colscheme used. A number of colours to choose from when generating the plot.
}
  \item{color.palette}{
The colour palette used for generating colours defeaults to \code{"Dark2"}
}
  \item{n.colors}{
Numeric indicator for the number of colours to use.
}
  \item{reverse.col}{
should the automatically generated colours be reversed.
}
  \item{col}{
Vector of colours.
}
  \item{lty}{
Numeric value for line of type.
}
  \item{pch}{
Numeric value for type of points.
}
  \item{lwd}{
Numeric value for line width
}
  \item{legend.place}{
Where should the legend be placed: \code{"bottomleft"} is defeault.
}
  \item{plot.order}{
Character vector of names specifying the order the cell lines should be plotted.
Can be used in combination with the argument \code{use.col.order} to colour each cell line specifically.
}
 \item{dose.scale}{
Character indicating the scale used for concentrations when estimating the isotonic regression and the summary statistcs. The unit is written as e.g. ug/ml to indicate micro grams per milli litre and defaults to \code{mol/l}. The unit is written as ug/ml The current implementations for multiples are:
 \tabular{lccccccccccc}{
    Name  \tab  \tab deca  \tab hecto \tab kilo \tab mega \tab giga \tab tera \tab peta \tab exa \tab zetta \tab yotta \cr
    Prefix  \tab  \tab da  \tab h \tab k \tab M \tab G \tab T \tab P \tab E \tab Z \tab Y \cr
    Factor \tab 10^0 \tab 10^1  \tab 10^2 \tab 10^3 \tab 10^6 \tab 10^9 \tab 10^12 \tab 10^15 \tab 10^18 \tab 10^21 \tab 10^24 
  }
  The current implementations for fractions are: 
\tabular{lcccccccccc}{
    Name   \tab deci  \tab centi \tab milli \tab micro \tab nano \tab pico \tab femto \tab atto \tab zepto \tab yocto \cr
    Prefix  \tab d  \tab c \tab m \tab u \tab n \tab p \tab f \tab a \tab z \tab y \cr
    Factor  \tab 10^-1  \tab 10^-2 \tab 10^-3 \tab 10^-6 \tab 10^-9 \tab 10^-12 \tab 10^-15 \tab 10^-18 \tab 10^-21 \tab 10^-24 
  }
}
  \item{dose.logfun}{
Character indicating if the concentrations should be log transformed. The possible inputs are \code{nolog} for non log transformation, \code{log10, log2, log} for log transforming with base 10, 2, and e, respectively.
}
  \item{legend}{
Should a legend be created.
}
  \item{n.columns}{
The number of columns in the legend.
}
  \item{legend.cex}{
numeric indicator for the size of the legend.
}
  \item{use.col.order}{
Should the colours specified be used in the order by which they are given. 
}
  \item{split}{
Character specifying a variable according to which the dose response curves should be separated e.g. a column specifying the disease origin of the cell lines.
}
}
\value{
Dose response curves according to the specifyed model.
}
\references{
Steffen Falgreen et al. Exposure time independent summary statistics for assessment of drug dependent cell line growth inhibition (2013)
}
\author{
The function was written at department of haematology, Aalborg University Hospital and maintained by Steffen Falgreen.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{CI}},\code{\link{DRdataBoxplot}},\code{\link{plot.DRdata}},\code{\link{plot.growthModel}},\code{\link{plotGrid}}
}

\examples{
require(DoseR)
data(A.data)

par(mfrow = c(1,2))
plot.DRdata(x          = A.data,
            model      = "D",
            col.scheme =  c("#71965A", "#4F6E9F"),
            drug       = "Doxorubicin",
            legend     = TRUE,
            n.columns  = 1, 
            plot.data  = TRUE,
            legend.cex = 1, 
            times      = c(12, 24, 36, 48))

plot.DRdata(x          = A.data,
            model      = "D",
            col.scheme =  c("#71965A", "#4F6E9F"),
            drug       = "Rituximab",
            legend     = TRUE,
            n.columns  = 1, 
            plot.data  = TRUE,
            legend.cex = 1, 
            times      = c(12, 24, 36, 48))

par(mfrow = c(1,2))

plot.DRdata(x     = A.data,
            model = "G", 
            drug  = "Rituximab",
            col.scheme =  c("#71965A", "#4F6E9F"),
            n.columns  = 1,
            plot.data  = TRUE,legend = TRUE,
            legend.cex = 1)

plot.DRdata(x     = A.data,
            model = "G", 
            drug  = "Doxorubicin",
            col.scheme =  c("#71965A", "#4F6E9F"),
            n.columns  = 1,
            plot.data  = TRUE,legend = TRUE,
            legend.cex = 1)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{~dose}
\keyword{~response}
\keyword{~curves}