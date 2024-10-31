#!/usr/bin/env Rscript

# 加载必要的库
library(argparser, quietly=TRUE)
library(ggVennDiagram)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(ComplexUpset)
library(UpSetR)

###############################################
# 解析参数
###############################################
p <- arg_parser("从文件列表中绘制 Venn 图并生成统计文件")
p <- add_argument(p, "list", help="包含文件路径的列表文件", type="character")
p <- add_argument(p, "number", help="总条数", type="numeric")
p <- add_argument(p, "prefix", help="输出文件前缀", type="character")

argv <- parse_args(p)

# 读取输入文件
input_data <- read.table(argv$list, header = FALSE, stringsAsFactors = FALSE)
colnames(input_data) <- c("name", "file")

# 读取各个文件的基因列表，并计算每个文件的条数
gene_lists <- lapply(input_data$file, function(file) {
  if (!file.exists(file)) {
    stop(paste("文件不存在:", file))
  }
  # 读取文件的第一列
  read.table(file, stringsAsFactors = FALSE)[, 1]
})
names(gene_lists) <- input_data$name

# 统计文件注释条数和比例
type_counts <- sapply(gene_lists, length)
total_number <- as.numeric(argv$number)
type_percent <- round(type_counts / total_number * 100, 2)

# 创建统计数据框
type_stats <- data.frame(
  Type = names(type_counts),
  Number = type_counts,
  Percent = type_percent
)

# 保存统计数据框到文件
type_stat_file <- paste0(argv$prefix, "_type_statistics.txt")
write.table(type_stats, file = type_stat_file, sep = "\t", row.names = FALSE, quote = FALSE)

# 绘制第一个 Venn 图：仅显示计数
p1 <- ggVennDiagram(gene_lists, label = "count") +
  scale_fill_distiller(palette = "Reds", direction = 1) +
  scale_color_brewer(palette = "Dark2") +
  ggtitle(paste("Venn Diagram with", argv$number, "total entries (Count)"))

# 绘制第二个 Venn 图：仅显示比例
p2 <- ggVennDiagram(gene_lists, label = "percent") +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  scale_color_brewer(palette = "Dark2") +
  ggtitle(paste("Venn Diagram with", argv$number, "total entries (Percent)"))

# 保存两个并排的 Venn 图到 PDF 文件
output_file <- paste0(argv$prefix, "_venn_diagrams.pdf")
pdf(output_file, width = 16, height = 8)
grid.arrange(p1, p2, ncol = 2)
dev.off()

# 使用 fromList 函数将 gene_lists 转换为适合 UpSet 图的数据格式
gene_presence <- UpSetR::fromList(gene_lists)

# 绘制 UpSet 图，包含每个集合的条目数量和交集数量
upset_plot <- ComplexUpset::upset(
  gene_presence,
  names(gene_lists),
  width_ratio = 0.1 )


# 保存 UpSet 图到 PDF 文件
output_file_upset <- paste0(argv$prefix, "_upset_diagrams.pdf")
ggsave(output_file_upset, plot = upset_plot, width = 11, height = 8)

# 创建 Venn 对象并提取统计信息
venn_obj <- Venn(gene_lists)
venn_stats <- ggVennDiagram::process_region_data(venn_obj)

# 将统计数据转换为适合保存的格式
venn_stats_cleaned <- venn_stats %>%
  mutate(across(where(is.list), ~ sapply(., toString)))

# 保存交集统计文件
stat_file <- paste0(argv$prefix, "_venn_statistics.txt")
write.table(venn_stats_cleaned, file = stat_file, sep = "\t", row.names = FALSE, quote = FALSE)

# 打印输出文件路径
cat("Venn 图已保存到:", output_file, "\n")
cat("Type 统计文件已保存到:", type_stat_file, "\n")
cat("UpSet 图已保存到:", output_file_upset, "\n")
cat("统计文件已保存到:", stat_file, "\n")

