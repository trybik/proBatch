#' Plot peptide measurements
#'
#' Creates a peptide facetted ggplot2 plot of the value in \code{measure_col}
#' vs \code{order_col}. Additionally, the resulting plot can also be facetted
#' by batch.
#'
#' @inheritParams proBatch
#' @param pep_name name of the peptide for diagnostic profiling
#' @param geom whether to show the feature as points and/or connect by lines
#' @param color_by_batch (logical) whether to color points by batch
#' @param facet_by_batch (logical) whether to plot each batch in its own facet
#' @param color_by_col column to color by certain value denoted 
#' by \code{color_by_value}
#' @param color_by_value value in \code{color_by_col} to color 
#' @param plot_title the string indicating the source of the peptides
#' @param theme plot theme (default is 'classical'; other options not
#'   implemented)
#' @param vline_color color of vertical lines, typically denoting 
#'  different MS batches in ordered runs; should be \code{NULL} for 
#'  experiments without intrinsic order
#' @param color_scheme color scheme for \code{ggplot} representation
#'
#' @return ggplot2 type plot of \code{measure_col} vs \code{order_col},
#'   faceted by \code{pep_name} and (optionally) by \code{batch_col}
#' @examples 
#' single_feature_plot <- plot_single_feature(
#' pep_name = "46213_NVGVSFYADKPEVTQEQK_2", 
#' df_long = example_proteome, example_sample_annotation, 
#' color_by_col = NULL)
#'
#' @family feature-level diagnostic functions
#'
#' @export
#'

plot_single_feature  <- function(pep_name, df_long, sample_annotation,
                                 order_col = 'order',
                                 sample_id_col = 'FullRunName',
                                 batch_col = 'MS_batch',
                                 measure_col = 'Intensity',
                                 feature_id_col = 'peptide_group_label',
                                 geom = c('point', 'line'),
                                 color_by_batch = FALSE, color_scheme = 'brewer',
                                 facet_by_batch = FALSE,
                                 color_by_col = NULL, color_by_value = NULL,
                                 plot_title = NULL,
                                 vline_color ='red',
                                 theme = 'classic'){
  #TODO: suggest faceting by instrument
  
  plot_df = df_long %>%
    filter(UQ(sym(feature_id_col)) %in% pep_name)
  if (!all(names(sample_annotation) %in% names(df_long))){
    sample_annotation = sample_annotation %>%
      arrange(!!sym(order_col))
    common_cols = intersect(names(sample_annotation), names(plot_df))
    cols_to_remove = setdiff(common_cols, sample_id_col)
    plot_df = plot_df %>%
      select(-one_of(cols_to_remove))
    plot_df = plot_df %>%
      merge(sample_annotation, by = sample_id_col)
  }
  
  sample_annotation = sample_annotation %>%
    subset(sample_annotation[[sample_id_col]] %in% plot_df[[sample_id_col]])
  
  if(is.null(order_col)){
    warning("order column wasn't specified, putting row 
            number as an order within a batch")
    plot_df = plot_df %>%
      group_by_at(vars(one_of(batch_col))) %>%
      mutate(order = row_number())
    order_col = 'order'
  }
  
  gg = ggplot(plot_df,
              aes_string(x = order_col, y = measure_col))
  if (identical(geom, 'line')){
    gg = gg + geom_line(color = 'darkgrey', size = .3)
  }
  if (identical(geom, 'point')){
    gg = gg + geom_point()
  }
  
  if (identical(geom, c('point', 'line'))){
    gg = gg + geom_point() +
      geom_line(color = 'black', alpha = .7, linetype = 'dashed')
  }
  if(color_by_batch & !is.null(batch_col)){
    gg = gg + aes_string(color = batch_col)
    if(length(color_scheme) == 1 & color_scheme == 'brewer'){
      n_batches <- length(unique(sample_annotation[[batch_col]]))
      if (n_batches <= 9){
        gg = gg + scale_color_brewer(palette = 'Set1')
      } else {
        if (n_batches <= 12){
          gg = gg + scale_color_brewer(palette = 'Set3')
        } else {
          warning(sprintf('brewer palettes have maximally 12 colors, you specified %s 
                          batches,consider defining color scheme with 
                          sample_annotation_to_colors function', n_batches))
        }
      }
      
    } else{
      gg = gg + scale_color_manual(values = color_scheme)
    }
  }
  
  if(!is.null(batch_col)){
    batch.tipping.points = cumsum(table(sample_annotation[[batch_col]]))+.5
    gg = gg + geom_vline(xintercept = batch.tipping.points,
                         color = vline_color, linetype = 'dashed')
  } 
  
  if(facet_by_batch){
    if (length(pep_name) > 1){
      gg = gg + facet_grid(reformulate(batch_col, pep_name), scales = 'free_y')
    } else {
      gg = gg  + facet_wrap(as.formula(paste("~", batch_col)), scales = 'free_y')
    }
  }
  
  if (length(pep_name) > 1){
    gg = gg + facet_wrap(as.formula(paste("~", feature_id_col)), scales = 'free_y')
  }
  if(!is.null(plot_title)){
    gg = gg + ggtitle(plot_title)
  }
  
  if(!is.null(color_by_col)){
    col_data = plot_df %>%
      filter(UQ(as.name(feature_id_col)) %in% pep_name) %>%
      filter(UQ(as.name(color_by_col)) == color_by_value)
    
    gg = gg + geom_point(data = col_data,
                         aes_string(x = order_col, y = measure_col),
                         color = 'red', size = .3, shape = 8)
  }
  
  if (theme == 'classic'){
    gg = gg + theme_classic()
  }
  return(gg)
}

#' Plot peptides of one protein
#'
#' Creates a spike-in facetted ggplot2 plot of the value in
#' \code{measure_col} vs \code{order_col} using
#' \code{\link{plot_single_feature}}. Additionally, the resulting plot can also
#' be facetted by batch.
#'
#' @inheritParams plot_single_feature
#' @param peptide_annotation long format data with peptide ID and their corresponding 
#' protein annotations
#' @param protein_name name of the protein as defined in \code{ProteinName}
#' @param protein_col column where protein names are specified
#' @param ... additional arguments to \code{\link{plot_single_feature}} function
#'
#' @return ggplot2 type plot of \code{measure_col} vs \code{order_col},
#'   faceted by \code{spike_ins} containing proteins and (optionally) by \code{batch_col}
#' @examples 
#' peptides_of_one_protein_plot <- plot_peptides_of_one_protein (
#' protein_name = "Haao",  
#' protein_col = "Gene", df_long = example_proteome, 
#' example_sample_annotation, 
#' order_col = 'order', sample_id_col = 'FullRunName', 
#' batch_col = 'MS_batch')
#' 
#' @family feature-level diagnostic functions
#'
#' @export
#'
plot_peptides_of_one_protein <- function(protein_name, protein_col = 'ProteinName',
                                         df_long, sample_annotation,
                                         peptide_annotation = NULL,
                                         order_col = 'order',
                                         sample_id_col = 'FullRunName',
                                         batch_col = 'MS_batch',
                                         measure_col = 'Intensity',
                                         feature_id_col = 'peptide_group_label',
                                         color_by_batch = FALSE, color_scheme = 'brewer',
                                         facet_by_batch = FALSE,
                                         color_by_col = NULL, color_by_value = NULL,
                                         plot_title = sprintf('Peptides of %s protein', 
                                                              protein_name),...){
  
  if(!setequal(unique(sample_annotation[[sample_id_col]]), 
               unique(df_long[[sample_id_col]]))){
    warning('Sample IDs in sample annotation not consistent 
            with samples in input data.')}
  
  if (!is.null(peptide_annotation)){
    peptides = peptide_annotation %>%
      filter((!!sym(protein_col)) == protein_name) %>%
      pull(!!sym(feature_id_col)) %>% unique()
    peptides = peptides[peptides %in% df_long[[feature_id_col]]]
  } else {
    peptides = df_long %>%
      filter((!!sym(protein_col)) == protein_name) %>%
      pull(feature_id_col) %>% unique()
  }
  gg = plot_single_feature(peptides, df_long = df_long,
                           sample_annotation = sample_annotation,
                           order_col = order_col,
                           sample_id_col = sample_id_col,
                           batch_col = batch_col, measure_col = measure_col,
                           feature_id_col = feature_id_col,
                           color_by_batch = color_by_batch, 
                           color_scheme = color_scheme,
                           facet_by_batch = facet_by_batch,
                           color_by_col = color_by_col, 
                           color_by_value = color_by_value,
                           plot_title = plot_title, ...)
  return(gg)
}

#' Plot spike-in measurements
#'
#' Creates a spike-in facetted ggplot2 plot of the value in
#' \code{measure_col} vs \code{order_col} using
#' \code{\link{plot_single_feature}}. Additionally, the resulting plot can also
#' be facetted by batch.
#'
#' @inheritParams plot_single_feature
#' @param spike_ins substring used to identify spike-in proteins in the column
#'   'ProteinName'
#' @param peptide_annotation long format data with peptide ID and their corresponding 
#' protein annotations
#' @param protein_col column where protein names are specified
#' @param ... additional arguments to \code{\link{plot_single_feature}} function
#'
#' @return ggplot2 type plot of \code{measure_col} vs \code{order_col},
#'   faceted by \code{spike_ins} containing proteins and (optionally) 
#'   by \code{batch_col}
#'
#' @family feature-level diagnostic functions
#' 
#' @examples 
#' spike_in_plot <- plot_spike_in(example_proteome, example_sample_annotation, 
#' protein_col = 'Gene', spike_ins = "BOVINE_A1ag", 
#' plot_title = "Spike-in BOVINE protein peptides")
#' 
#' @export
#'
plot_spike_in <- function(df_long, sample_annotation,
                          peptide_annotation = NULL,
                          protein_col = 'ProteinName',
                          order_col = 'order',
                          spike_ins = 'BOVIN',
                          sample_id_col = 'FullRunName',
                          batch_col = 'MS_batch',
                          measure_col = 'Intensity',
                          feature_id_col = 'peptide_group_label',
                          color_by_batch = FALSE, color_scheme = 'brewer',
                          facet_by_batch = FALSE,
                          color_by_col = NULL, color_by_value = NULL,
                          plot_title = 'Spike-in BOVINE protein peptides', ...){
  
  if(!setequal(unique(sample_annotation[[sample_id_col]]), 
               unique(df_long[[sample_id_col]]))){
    warning('Sample IDs in sample annotation not 
            consistent with samples in input data.')}
  
  if (!is.null(peptide_annotation)){
    df_long = df_long %>%
      merge(peptide_annotation, by = feature_id_col)
  }
  spike_in_peptides = df_long %>%
    filter(grepl(spike_ins, !!sym(protein_col))) %>%
    pull(feature_id_col) %>% as.character() %>% unique()
  gg = plot_single_feature(spike_in_peptides, df_long = df_long,
                           sample_annotation = sample_annotation,
                           order_col = order_col,
                           sample_id_col = sample_id_col,
                           batch_col = batch_col, measure_col = measure_col,
                           feature_id_col = feature_id_col,
                           color_by_batch = color_by_batch, 
                           color_scheme = color_scheme,
                           facet_by_batch = facet_by_batch,
                           color_by_col = color_by_col, 
                           color_by_value = color_by_value,
                           plot_title = plot_title, ...)
  return(gg)
}


#' Plot iRT measurements
#'
#' Creates a iRT facetted ggplot2 plot of the value in
#' \code{measure_col} vs \code{order_col} using
#' \code{\link{plot_single_feature}}. Additionally, the resulting plot can also
#' be facetted by batch.
#'
#' @inheritParams plot_single_feature
#' @param irt_pattern substring used to identify irts proteins in the column
#'   'ProteinName'
#' @param peptide_annotation long format data with peptide ID and their corresponding 
#' protein annotations
#' @param protein_col column where protein names are specified
#' @param ... additional arguments to \code{\link{plot_single_feature}} function
#'
#' @return ggplot2 type plot of \code{measure_col} vs \code{order_col},
#'   faceted by \code{irt_pattern} containing proteins 
#'   and (optionally) by \code{batch_col}
#'
#' @family feature-level diagnostic functions
#'
#' @examples 
#' irt_plot <- plot_iRT(example_proteome, 
#' example_sample_annotation, 
#' protein_col = 'Gene', irt_pattern = "BOVINE_A1ag")
#' 
#' @export
#'
plot_iRT <- function(df_long, sample_annotation,
                     peptide_annotation = NULL,
                     protein_col = 'ProteinName',
                     order_col = 'order',
                     irt_pattern = 'iRT',
                     sample_id_col = 'FullRunName',
                     batch_col = 'MS_batch',
                     measure_col = 'Intensity',
                     feature_id_col = 'peptide_group_label',
                     color_by_batch = FALSE, color_scheme = 'brewer',
                     facet_by_batch = FALSE,
                     color_by_col = NULL, color_by_value = NULL,
                     plot_title = 'iRT peptide profile', ...){
  
  if(!setequal(unique(sample_annotation[[sample_id_col]]), 
               unique(df_long[[sample_id_col]]))){
    warning('Sample IDs in sample annotation not consistent 
            with samples in input data.')}
  
  if (!is.null(peptide_annotation)){
    df_long = df_long %>%
      merge(peptide_annotation, by = protein_col)
  }
  iRT_peptides = df_long %>%
    filter(grepl(irt_pattern, !!sym(protein_col))) %>%
    pull(feature_id_col)  %>% unique()
  gg = plot_single_feature(iRT_peptides, df_long, sample_annotation,
                           order_col = order_col,
                           sample_id_col = sample_id_col,
                           batch_col = batch_col,
                           measure_col = measure_col,
                           feature_id_col = feature_id_col,
                           color_by_batch = color_by_batch, 
                           color_scheme = color_scheme,
                           facet_by_batch = facet_by_batch,
                           color_by_col = color_by_col, 
                           color_by_value = color_by_value,
                           plot_title = plot_title, ...)
  return(gg)
}


#' Plot peptide measurements across multi-step analysis
#'
#' Plot Intensity of a few representative peptides for each step of the analysis
#' including the fitting curve
#'
#' @inheritParams plot_single_feature
#' @param pep_name name of the peptide for diagnostic profiling
#' @param fit_df data frame typically output generated from nonlinear curve 
#'   fitting by \code{normalize_custom_fit}
#' @param fit_value_var column denoting intensity values, typically fitted to curve
#' @param geom for the intensity \code{measure_col} profile
#' @param ... additional arguments to \code{\link{plot_single_feature}} function
#'
#' @return \code{ggplot}-class plot with minimally two facets (before and after
#'   non-linear fit) with \code{measure_col} (Intensity) vs \code{order_col}
#'   (injection order) for selected peptides (specified in \code{pep_name})
#'
#' @family feature-level diagnostic functions
#' @examples 
#' loess_fit_70 <- adjust_batch_trend(example_proteome_matrix, 
#' example_sample_annotation, span = 0.7)
#' 
#' fitting_curve_plot <- plot_with_fitting_curve(
#' pep_name = "10231_QDVDVWLWQQEGSSK_2", 
#' df_long = example_proteome, example_sample_annotation, 
#' fit_df = loess_fit_70$fit_df, plot_title = "Curve fitting with 70% span")
#'
#' @export
#'

plot_with_fitting_curve <- function(pep_name, df_long,
                                    sample_annotation,
                                    fit_df,
                                    fit_value_var = 'fit', 
                                    order_col = 'order',
                                    sample_id_col = 'FullRunName',
                                    batch_col = 'MS_batch',
                                    measure_col = 'Intensity',
                                    feature_id_col = 'peptide_group_label',
                                    geom = c('point', 'line'),
                                    color_by_batch = FALSE, color_scheme = 'brewer',
                                    facet_by_batch = FALSE,
                                    plot_title = sprintf("Fitting curve of %s peptide", 
                                                         pep_name), 
                                    color_by_col = NULL, color_by_value = NULL,
                                    theme = 'classic', vline_color = 'grey', ...){
  
  if(length(pep_name) > 10){
    warning("Visualisation of individual features can be suboptimal,
            consider exploring no more than 5 features at a time")
  }
  gg = plot_single_feature(pep_name, df_long = df_long,
                           sample_annotation = sample_annotation,
                           order_col = order_col,
                           sample_id_col = sample_id_col,
                           batch_col = batch_col,
                           measure_col = measure_col,
                           feature_id_col = feature_id_col,
                           plot_title = plot_title,
                           facet_by_batch = facet_by_batch,
                           color_by_col = color_by_col, 
                           color_by_value = color_by_value,
                           vline_color = vline_color, ...)
  
  fit_df = fit_df %>%
    filter(UQ(sym(feature_id_col)) %in% pep_name) %>%
    merge(sample_annotation, by = c(sample_id_col, batch_col))
  if(identical(color_by_batch, FALSE)){
    gg = gg + geom_line(data = fit_df,
                        aes_string(y = fit_value_var, x = order_col, 
                                   group = batch_col), 
                        color = 'red')
  } else {
    gg = gg + geom_line(data = fit_df,
                        aes_string(y = fit_value_var, x = order_col,
                                   group = batch_col, 
                                   color = batch_col), size = 1.25)
    if(color_by_batch & length(color_scheme) == length(unique(fit_df[[batch_col]]))){
      gg = gg + scale_color_manual(values = color_scheme)
    }
  }
  
  return(gg)
}
