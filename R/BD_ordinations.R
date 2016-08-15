#' calculating beta diversity for a list of phyloseq objects
#'
#' For each phyloseq object in a list, calculates beta-diversity
#' between all samples using the phyloseq::distance function.
#'
#' @param physeq_l  A list of phyloseq objects
#' @param method  See phyloseq::distance
#' @param weighted  Weighted Unifrac (if calculating Unifrac)
#' @param fast  Fast calculation method
#' @param normalized  Normalized abundances
#' @param parallel  Calculate in parallel
#' @return List of dist objects
#'
#' @export
#'
#' @examples
#' data(physeq_l)
#' physeq_l_d = physeq_list_betaDiv(physeq_l)
#'
physeq_list_betaDiv = function(physeq_l, method='unifrac', weighted=TRUE,
                                fast=TRUE, normalized=TRUE, parallel=FALSE){
  if(is.null(names(physeq_l))){
    names(physeq_l) = as.character(1:length(physeq_l))
  }
  physeq_l_d = plyr::llply(physeq_l, phyloseq::distance,
                method=method,
                weighted=weighted,
                fast=fast,
                normalized=normalized,
                parallel=parallel)
  return(physeq_l_d)
}

#' calculating beta diversity for a list of phyloseq objects
#'
#' For each dist object in a list, calculates ordinations
#'
#' @param physeq_l  A list of phyloseq objects
#' @param physeq_l_d  A list of dist objects
#' @param ord_method  See phyloseq::ordinate
#' @return List of ordination objects
#'
#' @export
#'
#' @examples
#' data(physeq_l)
#' physeq_l_d = physeq_list_betaDiv(physeq_l)
#' physeq_l_d_ord = physeq_list_ord(physeq_l, physeq_l_d)
#'
physeq_list_ord = function(physeq_l, physeq_l_d, ord_method='NMDS'){
  ord_l = list()
  for (X in names(physeq_l_d)){
   ord_l[[X]] = ordinate(physeq_l[[X]],
                          method = ord_method,
                          distance = physeq_l_d[[X]])
  }
  return(ord_l)
}


#' Converting ordination objects to data.frames
#'
#' For each ordination object in a list, converts to a data.frame
#' for easy plotting with ggplot
#'
#' @param physeq_l  A list of phyloseq objects
#' @param physeq_l_ords  A list of ordination objects
#' @return List of data.frame objects
#'
#' @export
#'
#' @examples
#' data(physeq_l)
#' physeq_l_d = physeq_list_betaDiv(physeq_l)
#' physeq_l_d_ord = physeq_list_ord(physeq_l, physeq_l_d)
#' physeq_l_d_ord_df = phyloseq_list_ord_dfs(physeq_l, physeq_l_d_ord)
#'
phyloseq_list_ord_dfs = function(physeq_l, physeq_l_ords, parallel=FALSE){
  n = names(physeq_l) %>% as.array
  names(n) = n

  df = plyr::adply(n, .margins=1, .fun=function(x,physeq_l,physeq_l_ords){
     plot_ordination(physeq_l[[x]], physeq_l_ords[[x]], justDF=TRUE)
    }, physeq_l=physeq_l,
  physeq_l_ords=physeq_l_ords,
  .id='phyloseq_subset',
  .parallel=parallel)

  return(df)
}


#' Plotting beta diversity ordination
#'
#' For each data.frame object in a list (coverted from ordination objects),
#' creates a ggplot figure.
#'
#' @param physeq_ord_df  A list of data.frame objects (see phyloseq_list_ord_dfs)
#' @param title  Plot title
#' @param point_size  The data.frame column determining point size
#' @param point_fill  The data.frame column determining point fill color
#' @param point_alpha  The data.frame column (or just a single value) determining point alpha
#'
#' @export
#'
#' @examples
#' data(physeq_S2D2_l)
#' physeq_l_d = physeq_list_betaDiv(physeq_l)
#' physeq_l_d_ord = physeq_list_ord(physeq_l, physeq_l_d)
#' physeq_l_d_ord_df = phyloseq_list_ord_dfs(physeq_l, physeq_l_d_ord)
#' phyloseq_list_ord_plot(physeq_l_d_ord_df)
#'
phyloseq_ord_plot = function(physeq_ord_df, title=NULL,
                             point_size='Buoyant_density',
                             point_fill='Substrate',
                             point_alpha=0.5){

  if(! is.null(physeq_ord_df$NMDS1)){
    AES = aes(x=NMDS1, y=NMDS2)
  } else if(! is.null(physeq_ord_df$Axis.1)){
    AES = aes(x=Axis.1, y=Axis.2)
  } else if(! is.null(physeq_ord_df$CA1)){
    AES = aes(x=CA1, y=CA2)
  } else {
    stop('Do not recognize ordination axes')
  }

  p = ggplot2::ggplot(physeq_ord_df, AES) +
    geom_point(aes_string(fill = point_fill,
                  size = point_size),
                  pch=21, alpha=point_alpha) +
    scale_size(range=c(2,8)) +
    labs(title=title) +
    facet_wrap(~ phyloseq_subset) +
    theme_bw()

  return(p)
}


#' Calculating & plotting beta diversity for a list of phyloseq objects
#'
#' For each phyloseq object in a list, calculates beta-diversity
#' between all samples using the phyloseq::distance function.
#'
#' @param physeq_l  A list of phyloseq objects
#' @inheritParams physeq_list_betaDiv
#' @inheritParams physeq_list_ord
#' @inheritParams phyloseq_ord_plot
#' @return List of dist objects
#'
#' @export
#'
#' @examples
#' data(physeq_l)
#' physeq_l_df = SIP_betaDiv(physeq_l)
#' head(physeq_l_df, n=3)
#'
SIP_betaDiv_ord = function(physeq_l, method='unifrac', weighted=TRUE,
                          fast=TRUE, normalized=TRUE, parallel=FALSE,
                          plot=FALSE){
  physeq_l_d = physeq_list_betaDiv(physeq_l,
                                   method=method,
                                   weighted=weighted,
                                   fast=fast,
                                   normalized=normalized,
                                   parallel=parallel)
  physeq_l_d_ord = physeq_list_ord(physeq_l, physeq_l_d)
  physeq_l_d_ord_df = phyloseq_list_ord_dfs(physeq_l, physeq_l_d_ord)
  if(plot==TRUE){
    p = phyloseq_ord_plot(physeq_l_d_ord_df)
    return(p)
  } else {  # just data.frame of ordination data
    return(physeq_l_d_ord_df)
  }
}
