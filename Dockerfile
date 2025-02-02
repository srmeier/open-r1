# docker build . -t open-r1
# docker run -it --rm --entrypoint=/bin/bash -v $(pwd):/root/openr1-code --runtime=nvidia --gpus all open-r1

FROM nvidia/cuda:12.1.0-devel-ubuntu22.04
WORKDIR /root

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates

ADD https://astral.sh/uv/install.sh /root/uv-installer.sh
RUN sh /root/uv-installer.sh && rm /root/uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"
RUN uv venv openr1 --python 3.11
ENV PATH="/root/openr1/bin:$PATH"

RUN uv pip install --upgrade pip
RUN pip install vllm>=0.7.0 --extra-index-url https://download.pytorch.org/whl/cu121
ENV LD_LIBRARY_PATH="$(python -c 'import site; print(site.getsitepackages()[0] + '/nvidia/nvjitlink/lib')'):$LD_LIBRARY_PATH"

WORKDIR /root/openr1-code

RUN apt-get update && apt-get install -y git git-lfs numactl

COPY . /root/openr1-code/
RUN pip install -e ".[dev]"
RUN pip install wandb

# source /root/openr1/bin/activate
# git-lfs --version
# huggingface-cli login
# wandb login
# git clone https://github.com/srmeier/open-r1.git
