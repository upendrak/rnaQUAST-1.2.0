FROM ubuntu:14.04.3
MAINTAINER Upendra Devisetty <upendra@cyverse.org>
LABEL Description "This Dockerfile is for rnaQUAST-1.2.0"

# Install the dependencies
RUN apt-get update 
RUN apt-get install -y wget python-pip python-matplotlib make unzip samtools emboss emboss-lib zlib1g-dev
RUN pip install gffutils 
RUN pip install joblib 

# Install rnaQUAST-1.2.0
RUN wget -O- http://spades.bioinf.spbau.ru/rnaquast/release1.2.0/rnaQUAST-1.2.0.tar.gz | tar zxvf -

# Set working directory
WORKDIR /rnaQUAST-1.2.0

RUN chmod +x rnaQUAST.py && cp rnaQUAST.py /usr/bin

# Install other softwares
# Blast
RUN wget -O- http://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.3.0+-x64-linux.tar.gz | tar zxvf  -

# GMAP (The executable is already in path)
RUN wget -O- http://research-pub.gene.com/gmap/src/gmap-gsnap-2015-12-31.v6.tar.gz | tar zxvf -
RUN cd gmap-2015-12-31/
RUN ./configure
RUN make
RUN make check
RUN make install
RUN cd ..

# BLAT
RUN mkdir blat
RUN cd blat
RUN wget http://hgwdev.cse.ucsc.edu/~kent/exe/linux/blatSuite.36.zip
RUN unzip blatSuite.36.zip
RUN chmod +x blat
RUN cd ..

# BUSCO
RUN wget -O- http://busco.ezlab.org/files/BUSCO_v1.1b1.tar.gz | tar zxvf -
RUN cd BUSCO_v1.1b1/
# change the header to #/usr/bin/env python3
RUN sed 's|/bin/python|/usr/bin/python3|' BUSCO_v1.1b1.py > temp && mv temp BUSCO_v1.1b1.py
RUN chmod +x BUSCO_v1.1b1.py
RUN cd ..

# Hmmer: (it should be set to path)
RUN wget -O- http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz | tar zxvf -
RUN cd hmmer-3.1b2-linux-intel-x86_64 && ./configure
RUN make
RUN make check
RUN make install	
RUN cd ..

# GeneMarkS-T
RUN mkdir GeneMarkS-T
RUN cd GeneMarkS-T
RUN wget -O- http://topaz.gatech.edu/GeneMark/tmp/GMtool_BJnvL/gmst_linux_64.tar.gz | tar zxvf -
RUN chmod +x gmst.pl
RUN cd ..

# STAR for read alignment
RUN wget -O- https://github.com/alexdobin/STAR/archive/2.5.1b.tar.gz | tar zxvf -
RUN cd STAR-2.5.1b
RUN make STAR
RUN cd ..

# TopHat read alignment
RUN wget -O- https://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.0.Linux_x86_64.tar.gz | tar zxvf -

# Bowtie2
RUN wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.7/bowtie2-2.2.7-linux-x86_64.zip/download
RUN unzip download

# Set environmental paths
ENV PATH=/blat/:$PATH
ENV PATH=/BUSCO_v1.1b1/:$PATH
ENV PATH=/GeneMarkS-T/:$PATH
ENV PATH=/STAR-2.5.1b/bin/Linux_x86_64_static/:$PATH
ENV PATH=/tophat-2.1.0.Linux_x86_64/:$PATH
ENV PATH=/bowtie2-2.2.7/:$PATH

ENTRYPOINT ["rnaQUAST.py"]
CMD ["-h"]
