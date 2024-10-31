# Annotation_stat-
这是功能注释统计的软件，输入kegg、eggnog、interrproscan、uniprot数据库比对的文件
前面比对要用两次diamond比对nr和uniprot数据库，文件获取代码如下（数据库的路径是示例，要自己安装到本地数据库）
如：
#ncbi数据库
diamond blastp 
--outfmt 6 
--evalue 1e-5 
--threads 60 
--max-target-seqs 1 
--db /pub/database/nr/20230919/nr #数据库路径
--query proteins.sf.fasra #你的蛋白文件 
--out nr_diamond.tsv
#swissprot数据库
diamond blastp 
--outfmt 6
--evalue 1e-5
--threads 60 
--max-target-seqs 1
--db /pub/database/uniprot/20230919/uniprot_sorot
-o sprot_diamond.tsv 
#trembl数据库
diamond blastp 
--outfmt 6
--evalue 1e-5
--threads 60 
--max-target-seqs 1
--db /pub/database/uniprot/20230919/uniprot_trembl
-o sprot_diamond.tsv

#interproscan数据库
/pub/software/interproscan-5.63-95.0/interproscan.sh
-cpu 10
-i protein.sf.fasta
-dp #不联网搜索
-goterms #输出GO
-b interproscan_out #结果前缀
事例：
文件夹下这三个软件为一个目录：modify_id.py draw_annVenn.R stat_annotation_tools
下面给出五个比对好的数据文件
trembl_diamond.tsv、interproscan.tsv、sprot_diamond.tsv、user_ko.txt、nr_diamond.tsv

#第一步：
./stat_annotation_tools modify_id 
-k user_ko.txt #kegg数据，官网上比对的结果
-e emapper_out.emapper.annotations #eggnog比对的数据 
-t trembl_diamond.tsv #uniprot注释的trembl结果
-n nr_diamond.tsv #diamond注释的nr数据库结果
-s sprot_diamond.tsv #uniprot注释的Swissprot结果
-f protein.sf.fasta #蛋白文件

#第二步：
已知15553为第一步的输出结果
./stat_annotation_tools draw_venn 15553  output_prefix
