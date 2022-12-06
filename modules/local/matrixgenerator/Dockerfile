FROM python:3.9

### install python packages

RUN pip install SigProfilerMatrixGenerator
COPY refinstall.py .
RUN python refinstall.py
COPY ICGC_convert_matGen_parser.py .
#CMD ["python" ,"./refinstall.py"]

RUN mkdir -p /lib/sigprofiler_ref
ENV PATH="/lib/sigprofiler_ref:${PATH}"
#COPY ICGC_convert_matGen_parser.py . /lib/sigprofiler_ref

ENTRYPOINT ["python"]

#CMD ["/bin/bash"]
