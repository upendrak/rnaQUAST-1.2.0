FROM ubuntu:14.04
MAINTAINER Upendra Devisetty <upendra@cyverse.org>
LABEL Description "This Dockerfile is for rnaQUAST-1.2.0"

# Install the dependencies
RUN apt-get update 
RUN apt-get install -y wget python-pip python-matplotlib make unzip samtools emboss emboss-lib zlib1g-dev
RUN pip install gffutils 
RUN pip install joblib 
# Install rnaQUAST-1.2.0
ENV BINPATH /usr/bin
RUN wget -O- http://spades.bioinf.spbau.ru/rnaquast/release1.2.0/rnaQUAST-1.2.0.tar.gz | tar zxvf -
# Set working directory
WORKDIR /rnaQUAST-1.2.0
RUN chmod +x rnaQUAST.py && cp rnaQUAST.py $BINPATH
# Install other softwares
# Blast
wget -O- http://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.3.0+-x64-linux.tar.gz | tar zxvf  -
# GMAP (The executable is already in path)
wget -O- http://research-pub.gene.com/gmap/src/gmap-gsnap-2015-12-31.v6.tar.gz | tar zxvf -
cd gmap-2015-12-31/
./configure
make
make check
make install
cd ..
# BLAT
mkdir blat
cd blat
wget http://hgwdev.cse.ucsc.edu/~kent/exe/linux/blatSuite.36.zip
unzip blatSuite.36.zip
chmod +x blat
cd ..
# BUSCO
wget -O- http://busco.ezlab.org/files/BUSCO_v1.1b1.tar.gz | tar zxvf -
cd BUSCO_v1.1b1/
# change the header to #/usr/bin/env python3
sed 's|/bin/python|/usr/bin/python3|' BUSCO_v1.1b1.py > temp && mv temp BUSCO_v1.1b1.py
chmod +x BUSCO_v1.1b1.py
cd ..
# Hmmer: (it should be set to path)
wget -O- http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz | tar zxvf -
cd hmmer-3.1b2-linux-intel-x86_64/
./configure
make
make check
make install	
cd ..
# GeneMarkS-T
mkdir GeneMarkS-T
cd GeneMarkS-T
wget -O- http://topaz.gatech.edu/GeneMark/tmp/GMtool_BJnvL/gmst_linux_64.tar.gz | tar zxvf -
chmod +x gmst.pl
cd ..
# STAR for read alignment
wget https://github.com/alexdobin/STAR/archive/2.5.1b.tar.gz
tar xvf 2.5.1b.tar.gz
cd STAR-2.5.1b
make STAR
cd ..
# TopHat read alignment
wget -O- https://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.0.Linux_x86_64.tar.gz | tar zxvf -
# Bowtie2
wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.7/bowtie2-2.2.7-linux-x86_64.zip/download
unzip download
# Set environmental paths
export PATH=/blat/:$PATH
export PATH=/BUSCO_v1.1b1/:$PATH
export PATH=/GeneMarkS-T/:$PATH
export PATH=/STAR-2.5.1b/bin/Linux_x86_64_static/:$PATH
export PATH=/tophat-2.1.0.Linux_x86_64/:$PATH
export PATH=/bowtie2-2.2.7/:$PATH
ENTRYPOINT ["rnaQUAST.py"]
CMD ["-h"]
