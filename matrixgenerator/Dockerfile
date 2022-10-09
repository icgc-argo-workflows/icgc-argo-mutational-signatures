FROM python:3.9

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/icgc-argo-mutational-signatures-mgen

### install python packages

RUN pip install SigProfilerMatrixGenerator
COPY refinstall.py .
CMD ["python" ,"./refinstall.py"]
ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["python"]

#CMD ["/bin/bash"]
