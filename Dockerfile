FROM mambaorg/micromamba:1.5.10-noble

COPY --chown=$MAMBA_USER:$MAMBA_USER conda.yml /tmp/conda.yml

RUN micromamba install -y -n base -f /tmp/conda.yml \
    && micromamba install -y -n base conda-forge::procps-ng \
    && micromamba env export --name base --explicit > environment.lock \
    && echo ">> CONDA_LOCK_START" \
    && cat environment.lock \
    && echo "<< CONDA_LOCK_END" \
    && micromamba clean -a -y

USER root

ENV PATH="$MAMBA_ROOT_PREFIX/bin:$PATH"

COPY . /strvctvresrc

RUN cd /strvctvresrc && \
    chmod a+x *.py && \
    mkdir -p $MAMBA_ROOT_PREFIX/bin && \
    cp *.py $MAMBA_ROOT_PREFIX/bin/ && \
    # Add missing shebang lines
    sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $MAMBA_ROOT_PREFIX/bin/StrVCTVRE.py && \
    sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $MAMBA_ROOT_PREFIX/bin/annotationFinalForStrVCTVRE.py && \
    sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $MAMBA_ROOT_PREFIX/bin/liftover_hg19_to_hg38_public.py && \
    sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $MAMBA_ROOT_PREFIX/bin/test_StrVCTVRE.py && \
    sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $MAMBA_ROOT_PREFIX/bin/test_StrVCTVRE_GRCh37.py

RUN rm -rf /strvctvresrc