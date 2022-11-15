ARG BASE_IMAGE=rstudio/r-base
FROM ${BASE_IMAGE}:centos7

LABEL org.opencontainers.image.source https://github.com/paulastancl/awesome-wfpkgs1


ARG R_VERSION=4.1.2
ARG OS_IDENTIFIER=centos-7

# Install 

RUN wget https://cdn.rstudio.com/r/${OS_IDENTIFIER}/pkgs/R-${R_VERSION}-1-1.x86_64.rpm && \   
 yum -y install epel-release && \    
 yum -y install ./R-${R_VERSION}-1-1.x86_64.rpm && \    
 ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R && \    
 ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript && \    
 ln -s /opt/R/${R_VERSION}/lib/R /usr/lib/R && \    
 rm R-${R_VERSION}-1-1.x86_64.rpm && \    
 yum -y remove epel-release && \    
 yum clean all

 
RUN R -e "install.packages('remotes', dependencies=TRUE,repos='http://cran.rstudio.com/')"


## Installing packages from Bioconductor
# Docker inheritance
FROM bioconductor/bioconductor_docker:devel

RUN apt-get update   
           
## Install R packages

RUN R -e "install.packages('optparse',dependencies=TRUE,repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install('VariantAnnotation'); BiocManager::install('BSgenome.Hsapiens.UCSC.hg38')"
RUN R -e "BiocManager::install('BSgenome.Cfamiliaris.UCSC.canFam3')"
RUN R -e "options(timeout = 5000); remotes::install_github('Nik-Zainal-Group/signature.tools.lib'); library('signature.tools.lib')"

## Add main wrapper
RUN mkdir -p /scripts

ENV PATH="/scripts:${PATH}"

COPY SignatureToolsLib.R /scripts/
 
ENTRYPOINT ["R"]
