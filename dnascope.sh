#!/bin/sh
# *******************************************
# Script to perform DNAscope + Machine Learning variant calling
# using a single sample with fastq files
# named 1.fastq.gz and 2.fastq.gz
# *******************************************

# Update with the fullpath location of your sample fastq
fastq_folder="/home/pipeline/samples"
fastq_1="1.fastq.gz"
fastq_2="2.fastq.gz" #If using Illumina paired data
model="/net/c1n18/data/user/renke/DNAscope_models/SentieonModelBeta0.4a.model" #DNAscope model file 
sample="sample_name"
group="read_group_name"
platform="ILLUMINA"
PCRFREE=true #PCRFREE=1 means the sample is PCRFree

# Update with the location of the reference data files
fasta="/home/regression/references/b37/human_g1k_v37_decoy.fasta"
dbsnp="/home/regression/references/b37/dbsnp_138.b37.vcf.gz"

# Update with the location of the Sentieon software package and license file
export SENTIEON_INSTALL_DIR=/home/release/sentieon-genomics-201808.06
export SENTIEON_LICENSE=/home/bundle/sentieon.lic

# Other settings
nt=16 #number of threads to use in computation
workdir="$PWD/DNAscope" #Determine where the output files will be stored

# ******************************************
# 0. Setup
# ******************************************
mkdir -p $workdir
logfile=$workdir/run.log
exec >$logfile 2>&1
cd $workdir

# ******************************************
# 1. Mapping reads with BWA-MEM, sorting
# ******************************************
#The results of this call are dependent on the number of threads used. To have number of threads independent results, add chunk size option -K 10000000 
( $SENTIEON_INSTALL_DIR/bin/sentieon bwa mem -M -R "@RG\tID:$group\tSM:$sample\tPL:$platform" -t $nt -K 10000000 $fasta $fastq_folder/$fastq_1 $fastq_folder/$fastq_2 || echo -n 'error' ) | $SENTIEON_INSTALL_DIR/bin/sentieon util sort -r $fasta -o sorted.bam -t $nt --sam2bam -i -

# ******************************************
# 2. Remove Duplicate Reads
# ******************************************
$SENTIEON_INSTALL_DIR/bin/sentieon driver -t $nt -i sorted.bam --algo LocusCollector --fun score_info score.txt
$SENTIEON_INSTALL_DIR/bin/sentieon driver -t $nt -i sorted.bam --algo Dedup --rmdup --score_info score.txt --metrics dedup_metrics.txt deduped.bam 

# ******************************************
# 3. DNAscope Variant Caller
# ******************************************
if [ "$PCRFREE" = true ] ; then
    echo 'PCR Indel Model: None'
    $SENTIEON_INSTALL_DIR/bin/sentieon driver -r $fasta -t $nt -i deduped.bam --algo DNAscope -d $dbsnp --pcr_indel_model none --model $model output-ds.vcf.gz
else 
    $SENTIEON_INSTALL_DIR/bin/sentieon driver -r $fasta -t $nt -i deduped.bam --algo DNAscope -d $dbsnp --model $model output-ds.vcf.gz
fi

# ******************************************
# 3. DNAModelApply Machine Learning Model
# ******************************************
$SENTIEON_INSTALL_DIR/bin/sentieon driver -r $fasta -t $nt --algo DNAModelApply --model $model -v output-ds.vcf.gz output-ds-ml.vcf.gz


