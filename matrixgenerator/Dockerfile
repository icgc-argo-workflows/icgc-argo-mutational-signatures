FROM python:3.9

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/icgc-argo-mutational-signatures-mgen

### install python packages

RUN pip install SigProfilerMatrixGenerator
COPY refinstall.py .
RUN python refinstall.py
COPY ICGC_convert_matGen_parser.py .
#CMD ["python" ,"./refinstall.py"]

RUN mkdir -p /tools
ENV PATH="/tools:${PATH}"
COPY ICGC_convert_matGen_parser.py . /tools/

ENTRYPOINT ["python"]

#CMD ["/bin/bash"]
