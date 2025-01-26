ARG PYTHON_VERSION=3.12.7
FROM python:${PYTHON_VERSION}-slim

LABEL source="https://github.com/Akkudoktor-EOS/EOS"

ENV MPLCONFIGDIR="/tmp/mplconfigdir"
ENV EOS_DIR="/opt/eos"
ENV EOS_CACHE_DIR="${EOS_DIR}/cache"
ENV EOS_OUTPUT_DIR="${EOS_DIR}/output"
ENV EOS_CONFIG_DIR="${EOS_DIR}/config"

WORKDIR ${EOS_DIR}

RUN adduser --system --group --no-create-home eos \
    && mkdir -p "${MPLCONFIGDIR}" \
    && chown eos "${MPLCONFIGDIR}" \
    && mkdir -p "${EOS_CACHE_DIR}" \
    && chown eos "${EOS_CACHE_DIR}" \
    && mkdir -p "${EOS_OUTPUT_DIR}" \
    && chown eos "${EOS_OUTPUT_DIR}" \
    && mkdir -p "${EOS_CONFIG_DIR}" \
    && chown eos "${EOS_CONFIG_DIR}"

ARG APT_PACKAGES
ENV APT_PACKAGES="${APT_PACKAGES}"
RUN --mount=type=cache,sharing=locked,target=/var/lib/apt/lists \
    --mount=type=cache,sharing=locked,target=/var/cache/apt \
    rm /etc/apt/apt.conf.d/docker-clean; \
    if [ -n "${APT_PACKAGES}" ]; then \
        apt-get update \
        && apt-get install -y --no-install-recommends ${APT_PACKAGES}; \
    fi

COPY requirements.txt .

ARG PIP_EXTRA_INDEX_URL
ENV PIP_EXTRA_INDEX_URL="${PIP_EXTRA_INDEX_URL}"
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=tmpfs,target=/root/.cargo \
    pip install -r requirements.txt

COPY pyproject.toml .
RUN mkdir -p src && pip install -e .

COPY src src

USER eos
ENTRYPOINT []

EXPOSE 8503
EXPOSE 8504

CMD ["python", "src/akkudoktoreos/server/eos.py", "--host", "0.0.0.0"]

VOLUME ["${MPLCONFIGDIR}", "${EOS_CACHE_DIR}", "${EOS_OUTPUT_DIR}", "${EOS_CONFIG_DIR}"]
