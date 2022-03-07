## use ubuntu minimal base image
FROM ubuntu:focal

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/icgc-argo-mutational-signatures

# install dependencies
RUN apt-get clean && \
	apt-get update -y && \
	apt-get install --no-install-recommends -y \
	python3-minimal \
	git \
	wget \
	build-essential \
	python3-pip \
	procps

RUN pip install  matplotlib==3.4.0 sigProSS

RUN python3 -c "from SigProfilerMatrixGenerator import install as genInstall;genInstall.install('GRCh38')"

ENTRYPOINT ["python3"]

#	zlib1g-dev \
#	libbz2-dev \
#	liblzma-dev \
