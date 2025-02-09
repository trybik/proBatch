#' Long to wide conversion
#'
#' Convert from a long data frame representation to a wide matrix representation
#'
#' @inheritParams proBatch
#'
#' @return \code{data_matrix} (\link{proBatch}) like matrix 
#' (features in rows, samples in columns)
#'
#' @family matrix manipulation functions
#' @examples 
#' proteome_matrix <- long_to_matrix(example_proteome)
#'
#' @export
#'
long_to_matrix <- function(df_long,
                           feature_id_col = 'peptide_group_label',
                           measure_col = 'Intensity',
                           sample_id_col = 'FullRunName') {
  casting_formula =  as.formula(paste(feature_id_col, sample_id_col,
                                      sep =  " ~ "))
  proteome_wide = dcast(df_long, formula = casting_formula,
                        value.var = measure_col) %>%
    column_to_rownames(feature_id_col) %>%
    as.matrix()
  return(proteome_wide)
}


#' Wide to long conversion
#'
#' Convert from wide matrix to a long data frame representation
#'
#' @inheritParams proBatch
#'
#' @param step normalization step (e.g. \code{Raw} or \code{Quantile_normalized} or
#'   \code{qNorm_ComBat}). Useful if consecutive steps are compared in plots. Note
#'   that in plots these are usually ordered alphabetically, so it's worth
#'   naming with numbers, e.g. \code{1_raw}, \code{2_quantile}
#'
#' @return \code{df_long} (\link{proBatch}) like data frame
#'
#' @family matrix manipulation functions
#' @examples 
#' proteome_long <- matrix_to_long(example_proteome_matrix, 
#' example_sample_annotation)
#'
#' @export
#'
matrix_to_long <- function(data_matrix, sample_annotation = NULL,
                           feature_id_col = 'peptide_group_label',
                           measure_col = 'Intensity',
                           sample_id_col = 'FullRunName',
                           step = NULL){
  if(!is.null(sample_annotation)){
    if(!setequal(unique(sample_annotation[[sample_id_col]]), 
                 unique(colnames(data_matrix)))){
      warning('Sample IDs in sample annotation not 
                    consistent with samples in input data.')}
  }
  
  df_long = data_matrix %>%
    as.data.frame() %>%
    rownames_to_column(var = feature_id_col) %>%
    melt(id.var = feature_id_col, value.name = measure_col,
         variable.name = sample_id_col, factorsAsStrings = FALSE)
  if(!is.null(step)){
    df_long = df_long %>%
      mutate(Step = step)
  }
  if(!is.null(sample_annotation))
    df_long = df_long %>%
    merge(sample_annotation, by = sample_id_col)
  return(df_long)
}



#' Prepare peptide annotation from long format data frame
#'  
#' Create light-weight peptide annotation data frame 
#' for selection of illustrative proteins
#'
#' @inheritParams proBatch
#' 
#' @param annotation_col one or more columns contatining protein ID
#'
#' @return data frame containing petpide annotations 
#' @export
#' @examples 
#' generated_peptide_annotation <- create_peptide_annotation(
#' example_proteome, feature_id_col = "peptide_group_label",
#' annotation_col = c("ProteinName" ))
#' 
#' @seealso \code{\link{plot_peptides_of_one_protein}}, 
#' \code{\link{plot_protein_corrplot}}
create_peptide_annotation <- function(df_long, feature_id_col = 'peptide_group_label',
                                      annotation_col = c("ProteinName" )){
  peptide_annotation = df_long %>%
    select(one_of(c(feature_id_col, annotation_col))) %>%
    distinct()
  return(peptide_annotation)
}
