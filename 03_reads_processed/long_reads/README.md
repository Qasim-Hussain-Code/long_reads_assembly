# Processed Long Reads

This directory contains filtered and quality-controlled long reads.

## Expected Files

- `*_processed.fastq.gz` - NanoFilt processed reads
- `*_processed_filtlong.fastq.gz` - Filtlong processed reads

## Processing Steps

1. **NanoFilt**: Quality filtering (Q≥8), length filtering (≥1000bp), headcrop (50bp)
2. **Filtlong**: Keep top 90% quality reads, minimum length 1000bp


