# Long Reads Genome Assembly Pipeline

A comprehensive bacterial genome assembly and annotation pipeline using Oxford Nanopore long reads.

## Overview

This pipeline performs:
1. Quality control of long reads (NanoPlot)
2. Read filtering and processing (NanoFilt, Filtlong)
3. Genome assembly (Unicycler)
4. Genome quality assessment (CheckM2, QUAST, BUSCO)
5. Genome annotation (Prokka, Bakta)

## Directory Structure

```
long_reads_assembly/
├── 01_raw_reads/                    # Raw sequencing data
│   └── long_reads/                  # Long read FASTQ files
├── 02_reads_QC_before_processing/   # QC reports before filtering
│   └── long_reads/                  # NanoPlot output
├── 03_reads_processed/              # Filtered and processed reads
│   └── long_reads/                  # Processed FASTQ files
├── 04_reads_QC_after_processing/    # QC reports after filtering
│   └── long_reads/                  # NanoPlot output
├── 05_genome_assembly/              # Assembly output
│   └── long_reads_only_assembly/    # Unicycler assembly results
├── 06_genome_quality_assessment/    # Quality metrics
│   ├── 01_checkm2/                  # CheckM2 results
│   ├── 02_quast/                    # QUAST results
│   └── 03_busco/                    # BUSCO results
├── 07_genome_annotation/            # Annotation results
│   ├── 01_prokka/                   # Prokka annotation
│   └── 02_bakta/                    # Bakta annotation
├── installation.sh                  # Environment setup script
├── analysis.sh                      # Main analysis pipeline
└── README.md                        # This file
```

## Requirements

- Conda/Miniconda
- ~20GB disk space for databases
- Linux operating system

## Installation

### Step 1: Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/long_reads_assembly.git
cd long_reads_assembly
```

### Step 2: Run installation script

```bash
bash installation.sh
```

This will create the following conda environments:
- `03a_long_read_nanoplot` - NanoPlot for QC visualization
- `03b_long_read_nanofilt` - NanoFilt for read filtering
- `03c_long_read_filtlong` - Filtlong for quality filtering
- `04_unicycler` - Unicycler for genome assembly
- `04a_checkm2` - CheckM2 for genome completeness
- `04b_quast` - QUAST for assembly statistics
- `04c_busco` - BUSCO for gene completeness
- `05_genome_annotation` - Prokka and Bakta for annotation

### Step 3: Download databases

The installation script will download:
- CheckM2 database (~3GB)
- Bakta db-light database (~4GB)
- QUAST databases (GRIDSS, SILVA, BUSCO)

## Usage

### Step 1: Prepare your data

Place your long read FASTQ files in:
```
01_raw_reads/long_reads/
```

### Step 2: Modify analysis.sh (if needed)

Update input file names in `analysis.sh` to match your data:
```bash
# Example: change this line
NanoPlot --fastq 01_raw_reads/long_reads/YOUR_READS.fastq.gz \
```

### Step 3: Run the analysis pipeline

```bash
bash analysis.sh
```

## Pipeline Steps

### 1. Quality Control (Before Processing)
```bash
conda activate 03a_long_read_nanoplot
NanoPlot --fastq 01_raw_reads/long_reads/reads.fastq.gz \
    -o 02_reads_QC_before_processing/long_reads/ \
    --threads 12
```

### 2. Read Filtering

**NanoFilt** - Quality and length filtering:
```bash
conda activate 03b_long_read_nanofilt
zcat reads.fastq.gz | NanoFilt -q 8 --length 1000 --headcrop 50 | gzip > processed.fastq.gz
```

**Filtlong** - Keep top 90% quality reads:
```bash
conda activate 03c_long_read_filtlong
filtlong --min_length 1000 --keep_percent 90 input.fastq.gz | gzip > output.fastq.gz
```

### 3. Quality Control (After Processing)
```bash
conda activate 03a_long_read_nanoplot
NanoPlot --fastq 03_reads_processed/long_reads/processed.fastq.gz \
    -o 04_reads_QC_after_processing/long_reads/ \
    --threads 12
```

### 4. Genome Assembly
```bash
conda activate 04_unicycler
unicycler -l processed_reads.fastq.gz \
    -o 05_genome_assembly/long_reads_only_assembly/ \
    -t 12 --verbosity 2
```

### 5. Genome Quality Assessment

**CheckM2** - Genome completeness and contamination:
```bash
conda activate 04a_checkm2
export CHECKM2DB=/path/to/checkm2_database/uniref100.KO.1.dmnd
checkm2 predict --threads 4 --input assembly.fasta --output_dir checkm2_results/
```

**QUAST** - Assembly statistics:
```bash
conda activate 04b_quast
quast -o quast_results -t 4 assembly.fasta \
    --circos --glimmer --rna-finding --conserved-genes-finding
```

**BUSCO** - Gene completeness:
```bash
conda activate 04c_busco
busco -i assembly.fasta -o busco_results \
    -l bacteria_odb10 -m genome -c 4
```

### 6. Genome Annotation

**Prokka**:
```bash
conda activate 05_genome_annotation
prokka --outdir prokka_output/ --prefix sample \
    --kingdom Bacteria --addgenes --cpus 4 assembly.fasta
```

**Bakta**:
```bash
conda activate 05_genome_annotation
bakta assembly.fasta --db /path/to/bakta_db/db-light \
    -t 4 --verbose -o bakta_output/ --prefix sample \
    --skip-crispr --skip-ncrna-region --force
```

## Output Files

### Assembly (05_genome_assembly/)
- `assembly.fasta` - Final assembled genome
- `assembly.gfa` - Assembly graph

### Quality Assessment (06_genome_quality_assessment/)
- CheckM2: `quality_report.tsv` - Completeness and contamination
- QUAST: `report.html` - Interactive assembly statistics
- BUSCO: `short_summary.txt` - Gene completeness scores

### Annotation (07_genome_annotation/)
- Prokka: `.gff`, `.gbk`, `.faa`, `.ffn` files
- Bakta: `.gff3`, `.gbff`, `.faa`, `.ffn`, `.json` files

## Troubleshooting

### Bakta cmscan error
If you encounter `cmscan error! error code: 1`, add these flags:
```bash
bakta ... --skip-crispr --skip-ncrna-region
```
## Citation

If you use this pipeline, please cite the individual tools:
- **NanoPlot**: De Coster et al. (2018)
- **Unicycler**: Wick et al. (2017)
- **CheckM2**: Chklovski et al. (2023)
- **QUAST**: Gurevich et al. (2013)
- **BUSCO**: Manni et al. (2021)
- **Prokka**: Seemann (2014)
- **Bakta**: Schwengers et al. (2021)
