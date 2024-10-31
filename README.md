# Annotation_stat-
这是功能注释统计的软件，输入kegg、eggnog、interrproscan、uniprot数据库比对的文件
事例：
文件夹下这三个软件为一个目录：modify_id.py draw_annVenn.R stat_annotation_tools
下面给出五个比对好的数据文件
trembl_diamond.tsv、interproscan.tsv、sprot_diamond.tsv、user_ko.txt、nr_diamond.tsv
第一步：
./stat_annotation_tools modify_id -k kegg_out.tsv -e emapper_out.emapper.annotations -t trembl_diamond.tsv -n nr_diamond.tsv -s sprot_diamond.tsv -f protein.sf.fasta 
第二步：
已知15553为第一步的输出结果
./stat_annotation_tools draw_venn 15553  output_prefix
