# -----------------------------------------------
# Dockerfile: Local ZMK multi-matrix builder
# -----------------------------------------------
# Same environment as used in GitHub Actions
FROM zmkfirmware/zmk-build-arm:stable

# Install tools used in workflow (remarshal for yaml2json, jq for JSON parsing)
RUN apt-get update
RUN apt-get install -y python3-pip jq zip
RUN pip install remarshal --break-system-packages
RUN rm -rf /var/lib/apt/lists/*

# Set working directory inside container
WORKDIR /app

# Initialize and update Zephyr workspace
COPY config/west.yml config/west.yml
RUN west init -l config && \
    west update && \
    west zephyr-export

# Copy repository contents into container
COPY config config
COPY zmk-helpers zmk-helpers

# Default entrypoint (list build results)
CMD ["bash", "-c", "./build.sh"]
