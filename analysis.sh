eval "$(conda shell.bash hook)"

################## directories setup ##################
# QC before processing
mkdir -p 02_reads_QC_before_processing/long_reads

# processed reads
mkdir -p 03_reads_processed/long_reads

# QC after processing
mkdir -p 04_reads_QC_after_processing/long_reads

# hybrid genome assembly
mkdir -p 05_genome_assembly/long_reads_only_assembly

# Genome quality assessment
mkdir -p 06_genome_quality_assessment/01_checkm2/long_reads_only_assembly
mkdir -p 06_genome_quality_assessment/02_quast/long_reads_only_assembly
mkdir -p 06_genome_quality_assessment/03_busco/long_reads_only_assembly

# Genome annotation
mkdir -p 07_genome_annotation/01_prokka/long_reads_only_assembly
mkdir -p 07_genome_annotation/02_bakta/long_reads_only_assembly

################### long reads quality assessment tools ###################
conda activate 03a_long_read_nanoplot
NanoPlot --fastq 01_raw_reads/long_reads/codanics_long_reads.fastq.gz \
    -o 02_reads_QC_before_processing/long_reads/ \
    --threads 12

################### long reads processing ###################
# Nanofilt
conda activate 03b_long_read_nanofilt
zcat 01_raw_reads/long_reads/codanics_long_reads.fastq.gz | \
    NanoFilt -q 8 --length 1000 --headcrop 50 | \
    gzip > 03_reads_processed/long_reads/codanics_long_reads_processed.fastq.gz

# Filtlong
conda activate 03c_long_read_filtlong
filtlong --min_length 1000 --keep_percent 90 \
    03_reads_processed/long_reads/codanics_long_reads_processed.fastq.gz | \
    gzip > 03_reads_processed/long_reads/codanics_long_reads_processed_filtlong.fastq.gz

################## long reads quality assessment after processing ###################
conda activate 03a_long_read_nanoplot
NanoPlot --fastq 03_reads_processed/long_reads/codanics_long_reads_processed.fastq.gz \
    -o 04_reads_QC_after_processing/long_reads/ \
    --threads 12

################### genome assembly ###################
conda activate 04_unicycler

# long reads only assembly
unicycler -l 03_reads_processed/long_reads/codanics_long_reads_processed.fastq.gz \
    -o 05_genome_assembly/long_reads_only_assembly/ \
    -t 12 --verbosity 2


################### genome quality assessment using checkm2 ###################
conda activate 04a_checkm2
export CHECKM2DB=/home/kpchuang/Documents/databases_important/checkm2_database/CheckM2_database/uniref100.KO.1.dmnd
  
# long reads only assembly
checkm2 predict --threads 4 --input 05_genome_assembly/long_reads_only_assembly/assembly.fasta \
    --output_dir 06_genome_quality_assessment/01_checkm2/long_reads_only_assembly/  
        

################### genome quality assessment using quast ###################
conda activate 04b_quast

# long reads only assembly
quast -o 06_genome_quality_assessment/02_quast/long_reads_only_assembly/quast_results \
    -t 4 \
    05_genome_assembly/long_reads_only_assembly/assembly.fasta \
    --circos --glimmer --rna-finding --conserved-genes-finding

################### genome quality assessment using busco ###################
conda activate 04c_busco

# long reads only assembly
busco -i 05_genome_assembly/long_reads_only_assembly/assembly.fasta \
    -o busco_results_long \
    --out_path 06_genome_quality_assessment/03_busco/long_reads_only_assembly/ \
    -l bacteria_odb10 -m genome -c 4


# Generate BUSCO plots (run after all BUSCO analyses complete)
generate_plot.py -wd 06_genome_quality_assessment/03_busco/long_reads_only_assembly/busco_results_long

################### genome annotation using prokka ###################
conda activate 05_genome_annotation

# long reads only assembly
prokka --outdir 07_genome_annotation/01_prokka/long_reads_only_assembly/ \
    --prefix codanics_prokka_long_reads_only \
    --kingdom Bacteria --addgenes --cpus 4 \
    05_genome_assembly/long_reads_only_assembly/assembly.fasta --force


################### genome annotation using bakta ###################
conda activate 05_genome_annotation

# long reads only assembly
bakta 05_genome_assembly/long_reads_only_assembly/assembly.fasta \
    --db /home/kpchuang/Documents/databases_important/bakta_db/db-light \
    -t 4 --verbose \
    -o 07_genome_annotation/02_bakta/long_reads_only_assembly/ \
    --prefix codanics_bakta_long_reads_only \
    --skip-crispr \
    --skip-ncrna-region \
    --forces


