################## short reads quality control tools ##################
# Initialize conda
eval "$(conda shell.bash hook)"

################### long reads quality control tools ###################
# NanoPlot
conda create -n 03a_long_read_nanoplot -y
conda activate 03a_long_read_nanoplot
conda install bioconda::nanoplot -y
python -m pip install 'kaleido>=1.0.0'
python -m pip install pillow
# nanofilt
conda create -n 03b_long_read_nanofilt -y
conda activate 03b_long_read_nanofilt
conda install bioconda::nanofilt -y
# filtlong
conda create -n 03c_long_read_filtlong -y
conda activate 03c_long_read_filtlong
conda install bioconda::filtlong -y

################### unicycler ###################
conda create -n 04_unicycler -y
conda activate 04_unicycler
conda install bioconda::unicycler -y

# install checkm2 for genome quality assessment
conda create -n 04a_checkm2 -c bioconda -c conda-forge checkm2 -y
conda activate 04a_checkm2
checkm2 -h

# download databases
wget https://zenodo.org/api/records/14897628/files/checkm2_database.tar.gz/content -O /home/kpchuang/Documents/databases_important/checkm2_database.tar.gz
mkdir -p /home/kpchuang/Documents/databases_important/checkm2_database
tar -xzvf /home/kpchuang/Documents/databases_important/checkm2_database.tar.gz -C /home/kpchuang/Documents/databases_important/checkm2_database
export CHECKM2DB=/home/kpchuang/Documents/databases_important/checkm2_database/CheckM2_database/uniref100.KO.1.dmnd

# test run
checkm2 testrun

# install QUAST for additional genome quality assessment
conda create -n 04b_quast -c bioconda quast -y
conda activate 04b_quast
# update quast to the latest version
pip install quast==5.2
# check installation
quast -h
quast --version

# databases
# GRIDSS (needed for structural variant detection)
quast-download-gridss 
# SILVA 16 S rRNA database (needed for reference genome detection in metagenomic datasets)                                                                                                                                                                                                                        
quast-download-silva      
# BUSCO lineage datasets (needed for BUSCO analysis/for searching BUSCO genes)                                                                                                                                                                                                                   
quast-download-busco    

# install busco seperately for busco analysis
conda env remove -n 04c_busco --yes || true
conda create -n 04c_busco -y
conda activate 04c_busco
conda install -c conda-forge -c bioconda busco sepp -y
# check installation
busco -h
busco --version
busco --list-datasets
# download busco lineage databases as per requirement, example for bacteria
# busco --download-lineage bacteria_odb12
# downloaded datasets will be stored in conda env path under /busco_downloads

# genome annotation
conda env remove -n 05_genome_annotation --yes || true
conda create -n 05_genome_annotation -c bioconda -c conda-forge prokka bakta infernal -y
conda activate 05_genome_annotation
# check installation
prokka --listdb
bakta --version
cmscan -h  # verify infernal is installed

## bakta database download
# bakta_db download --output /home/kpchuang/Documents/databases_important/bakta_db --type full
## manual way will end with 4GB
mkdir -p /home/kpchuang/Documents/databases_important/bakta_db
wget https://zenodo.org/records/14916843/files/db-light.tar.xz \
    -O /home/kpchuang/Documents/databases_important/bakta_db/db-light.tar.xz
tar -xJvf /home/kpchuang/Documents/databases_important/bakta_db/db-light.tar.xz -C /home/kpchuang/Documents/databases_important/bakta_db/
rm /home/kpchuang/Documents/databases_important/bakta_db/db-light.tar.xz
# set BAKTA_DB environment variable
export BAKTA_DB=/home/kpchuang/Documents/databases_important/bakta_db/db-light
# update amrfinderplus database if needed (optional, bakta includes its own)
# Note: The command is 'amrfinder_update' (with underscore)
mkdir -p /home/kpchuang/Documents/databases_important/amrfinder_db
amrfinder_update --force_update --database /home/kpchuang/Documents/databases_important/amrfinder_db
