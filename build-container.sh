#!/usr/bin/env bash
set -euo pipefail

# --- Determine git commit SHA ---
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    COMMIT_SHA="$(git rev-parse --short HEAD)"
    CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
else
    COMMIT_SHA="nogit"
    CURRENT_BRANCH="nogit"
fi

IMAGE_TAG="nvim-container:${COMMIT_SHA}"
LATEST_TAG="nvim-container:latest"

# --- Create a temporary Dockerfile ---
TMP_DOCKERFILE="$(mktemp)"
echo "Generating Dockerfile at $TMP_DOCKERFILE"

cat > "$TMP_DOCKERFILE" <<'EOF'
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    ripgrep \
    fd-find \
    fzf \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    lua5.1 \
    luarocks \
    cargo \
    rustc \
    cmake \
    pkg-config \
    build-essential \
    ghostscript \
    bash \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Neovim (latest stable)
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
    rm nvim-linux-x86_64.tar.gz

# 3. fd symlink
RUN ln -s $(which fdfind) /usr/local/bin/fd

# 4. Lazygit
RUN LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | \
    grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz \
      https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin && \
    rm -f lazygit lazygit.tar.gz

# 5. Create user
RUN useradd -m -s /bin/bash nvimuser

# 6. XDG env
ENV XDG_CONFIG_HOME=/home/nvimuser/.config \
    XDG_DATA_HOME=/home/nvimuser/.local/share \
    XDG_CACHE_HOME=/home/nvimuser/.cache \
    PATH="/home/nvimuser/.local/bin:${PATH}"

# 7. Create dirs
RUN mkdir -p \
    /home/nvimuser/.config \
    /home/nvimuser/.local/share \
    /home/nvimuser/.cache

# 8. COPY NEOVIM CONFIG (repo root → XDG location)
COPY . /home/nvimuser/.config/nvim
RUN chown -R nvimuser:nvimuser /home/nvimuser/.config/nvim

# 9. Drop privileges
USER nvimuser

WORKDIR /work

ENTRYPOINT ["nvim"]
EOF

# --- Build docker image ---
echo "Building Docker image $IMAGE_TAG ..."
docker build -f "$TMP_DOCKERFILE" -t "$IMAGE_TAG" .

# --- Tag as latest if on master ---
if [[ "$CURRENT_BRANCH" == "master" ]]; then
    docker tag "$IMAGE_TAG" "$LATEST_TAG"
    echo "Also tagged as $LATEST_TAG"
fi

# --- Cleanup ---
rm -f "$TMP_DOCKERFILE"
echo "Done. Temporary Dockerfile removed."

docker images "$IMAGE_TAG"
