#' @importFrom ggplot2 aes
#' @importFrom ggplot2 element_text
#' @importFrom ggplot2 geom_bar
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 labs
#' @importFrom ggplot2 position_dodge
#' @importFrom ggplot2 scale_fill_discrete
#' @importFrom ggplot2 theme

plot_types_1 <- function(df_plot, df_names){
  # convert column names to factor
  df_plot <- df_plot %>% 
    mutate(type = factor(type, levels = as.character(type)))
  # construct bar plot of column types
  plt <- bar_plot(df_plot = df_plot, x = "type", y = "cnt", 
                  fill = "type", label = "cnt", 
                  ttl = paste0("df::", df_names$df1), " column types",
                  sttl = paste0("df::", df_names$df1,  " has ", sum(df_plot$cnt), 
                                " columns."), 
                  ylb = "Number of columns", lgnd = "Column types")
  # add text annotation to plot
  plt <- add_annotation_to_bars(x = df_plot$type, 
                                y = df_plot$cnt, 
                                z = df_plot$cnt,
                                plt = plt, thresh = 0.1, nudge = 0.3)
  # print plot
  print(plt)
}

plot_types_2 <- function(df_plot, df_names){
  # convert to a taller df for plotting
  d1 <- df_plot %>% select(1, 2:3) %>% mutate(df_input = df_names$df1)
  d2 <- df_plot %>% select(1, 4:5) %>% mutate(df_input = df_names$df2)
  colnames(d1) <- colnames(d2) <- c("type", "cnt", "pcnt", "df_input")
  z_tall <- bind_rows(d1, d2)

  # make axis names
  ttl_plt <- paste0(df_names$df1, " & ", df_names$df2, " column types.")
  # if same number of columns, print different subtitle
  if(sum(d1$cnt) == sum(d2$cnt)){
    sttl <- paste0("Both have ",  sum(d1$cnt), " columns")
  } else {
    sttl <- paste(paste0(unlist(df_names), " has ", 
                   c(sum(d1$cnt), sum(d2$cnt)), " columns"), 
                  collapse = " & ")
  }
  
  # labels above 0.8 max
  z_tall$black_labs <- z_tall$white_labs <- z_tall$cnt
  z_tall$black_labs[z_tall$black_labs >  0.7 * max(z_tall$black_labs)] <- NA
  z_tall$white_labs[z_tall$white_labs <= 0.7 * max(z_tall$white_labs)] <- NA
  
  # plot the result
  plt <- z_tall %>%
    mutate(type = factor(type, levels = df_plot$type)) %>%
    ggplot(aes(x = type, y = cnt)) + 
    geom_bar(stat = "identity", position = "dodge", 
             aes(x = type, y = cnt, 
                 fill = as.factor(df_input), 
                 group = as.factor(df_input)), 
             na.rm = TRUE) + 
    # add the black labels to small bars
    geom_text(
      aes(x = type, y = cnt, label = black_labs, 
          group = as.factor(df_input)),
      position = position_dodge(width = 1),
      vjust = -0.5, size = 3, col = "gray50", 
      na.rm = TRUE) + 
    # add the white labels to big bars
    geom_text(
      aes(x = type, y = cnt, label = white_labs, 
          group = as.factor(df_input)),
      position = position_dodge(width = 1),
      vjust = 2, size = 3, col = "white", 
      na.rm = TRUE) + 
    # labels the axes, add title and subtitle
    labs(x = "", y = "Number of columns", 
         title = ttl_plt, 
         subtitle = sttl) + 
    # label the legend 
    scale_fill_discrete(name = "Data frame")
  
  # return plot
  print(plt)
}