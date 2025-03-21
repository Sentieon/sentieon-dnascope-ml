
<a href="https://www.sentieon.com/">		<img src="https://www.sentieon.com/wp-content/uploads/2017/05/cropped-companylogo.png"  alt="Sentieon" width="25%" >	</a>


# DNAscope Machine Learning Model 

**A machine learning model for accurate and efficient germline small-variants detection**
 
Sentieon DNAscope combines the robust and well-established preprocessing and assembly mathematics of the GATK’s HaplotypeCaller with a machine-learned genotyping model, achieving superb SNP and insertion/deletion accuracy as compared to state-of-the-art tools, while using much reduced computational cost.

## Table of Contents  
- [Goal of a machine learning model in DNAscope](#goal) 
- [Highlights](#highlights)
- [DNAscope machine learning pipeline](#pipeline)
- [Performance on Whole Genome Sequencing (WGS) data](#performance)

<a name="goal"/>

## Goal of a machine learning model in DNAscope


From Sentieon software version 201808.01 onwards, DNAscope allows you to use a model to perform variant calling with higher accuracy by improving the candidate detection and filtering.

Sentieon can provide you with a model trained using a subset of the data from the GIAB truth-set found in [https://github.com/genome-in-a-bottle](https://github.com/genome-in-a-bottle). The model was created by processing samples HG001 and HG005 through a pipeline consisting of Sentieon BWA-mem alignment and Sentieon deduplication, and using the variant calling results to calibrate a model to fit the truth-set. Sentieon also provides DNAscope model training tool for you to create your model based on your own data. 

<a name="highlights"/>

## Highlights

- High Accuracy 
- Rapid Turnaround Time
- Cost Reduction
- Easy Deployment
- Customizable Model 

<a name="pipeline"/>

## DNAscope machine learning pipeline

![pipeline](https://github.com/Sentieon/sentieon-dnascope-ml/blob/master/dnascope-pipeline.png)

### Running DNAscope on-premises
#### FASTQ -> BAM -> VCF

1. Sentieon license

   Update Sentieon packages location and license file in `dnascope.sh`.
   ```bash
   export SENTIEON_INSTALL_DIR=/home/release/sentieon-genomics-201808.06 #your Sentieon package location
   export SENTIEON_LICENSE=/home/bundle/sentieon.lic #your license file location
   ```
   If you do not have a Sentieon license/package yet, please feel free to request a free trial at [sentieon.com](https://www.sentieon.com).
   
2. Location of input files

   Before running, you need to set the following variables in `dnascope.sh`.  
   - `fastq_folder`: fastq file(s) folder

   - `fastq_1`: fastq file name
   
   -  `fastq_2`: second fastq file, if using Illumina paired data
   
   - `model`: DNAscope model file
   
   - `PCRFREE`: boolean to indicate whether the sample is PCR Free or not. Set to `true` for PCR Free samples. 
   -  `fasta`: reference file 
   -  `dbsnp`: dbSNP file
    
3. Running the pipeline
 
   ```bash
   sh dnascope.sh
   ```


 If you have any further question, please refer to [Sentieon's Appnotes for DNAscope Machine Learning Model](https://support.sentieon.com/appnotes/dnascope_ml/) and [DNAseq pipeline example script](https://support.sentieon.com/manual/examples/examples/) in the manual.


<a name="performance"/>

## Performance on Whole Genome Sequencing (WGS) data 
Here we demonstrate DNAscope's performance on PrecisionFDA Truth Challenge HG002 sample. 

### Software source

Sentieon packages/models are stored on AWS. You could get Sentieon tools by running: 

```bash
 SENTIEON_VERSION="version-you-want" #For example 201808.07, Find released versions here https://support.sentieon.com/manual/appendix/releasenotes/
 INSTALL_DIR="your-install-dir"
 wget -nv -O - "https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-${SENTIEON_VERSION}.tar.gz" | tar -zxf - -C ${INSTALL_DIR} 
```

Sentieon Models: 
```bash
https://s3.amazonaws.com/sentieon-release/other/SentieonDNAscopeModel1.0.model
```

### Data source 
1. Reference Genome: hs37d5.fa. 
2. Test Data: NIST HG002 from [PrecisionFDA Truth Challenge](https://precision.fda.gov/challenges/truth).
3. Model File: Sentieon DNAscope Machine Learning Model version 0.5.  
4. Truth VCF and BED file for evaluation: [NIST GIAB project](https://jimb.stanford.edu/giab-resources), version v3.3.2. *(ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/release/AshkenazimTrio/HG002_NA24385_son/NISTv3.3.2/GRCh37/)*

You could access these data from our google cloud bucket: 

 File |Location  |
 --|--|
 Reference Genome  |[`gs://sentieon-test/pipeline_test/reference/`](https://console.cloud.google.com/storage/browser/sentieon-test/pipeline_test/reference/)   |
 PrecisionFDA Truth Challenge HG002 FASTQs| [`gs://sentieon-dnascope-model/data/`](https://console.cloud.google.com/storage/browser/sentieon-dnascope-model/data/)|
 DNAscope Model| [`gs://sentieon-dnascope-model/models/SentieonModelBeta0.5.model`](https://console.cloud.google.com/storage/browser/_details/sentieon-dnascope-model/models/SentieonModelBeta0.5.model)| 
 Truth VCF and Bed files | [`gs://sentieon-dnascope-model/truth/`](https://console.cloud.google.com/storage/browser/sentieon-dnascope-model/truth/) |



### Variant Calling Performance

We use RTG's vcfeval + hap.py ([https://github.com/Illumina/hap.py](https://github.com/Illumina/hap.py)) for variants evaluation, same comparison methodology as used in precisionFDA Truth Challenge.

```bash
HAPPY="/opt/hap.py/bin/hap.py"
OUTPREFIX="happy_eval"
$HAPPY truth.vcf query.vcf -f truth.bed -o $OUTPREFIX -r hs37d5.fa --engine=vcfeval --engine-vcfeval-template hs37d5.sdf
```
You could find DNAscope output as well as the hap.py evaluation results published on Google Storage Buckets [`gs://sentieon-dnascope-model/`](https://console.cloud.google.com/storage/browser/sentieon-dnascope-model)
under `output/` and `happy_eval/` directories.  

Type | TP | FN | FP | Recall | Precision | F1_score | PrecisionFDA Truth Challenge Winning Fscore* | 
------| ----| ----| ----| --------| -----------| ---| --------------------------------------------|
SNP   |3046378 | **1459** | **700** | 0.999521 | 0.99977 | **99.9646%** | 99.9587% | 
INDEL |463754| **1010** | **685** | 0.997827 | 0.998585 | **99.8206%** | 99.4009%|

*\*PrecisionFDA Truth Challege Result taken from https://precision.fda.gov/challenges/truth/results*

##

**If you are interested in other Sentieon Products, please visit www.sentieon.com for more information.**
