# Use an official Ubuntu as a parent image
# FROM ubuntu:latest
FROM python

# Set environment variables
ENV HUGO_VERSION=0.111.2

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y wget nodejs npm dpkg git make python3 rsync python3-pip python3-venv && \
    wget -O /tmp/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-arm64.deb && \
    dpkg -i /tmp/hugo.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel
RUN pip3 install --upgrade pip setuptools wheel

# Install any needed packages specified in requirements.txt
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Set the working directory
WORKDIR /workspace

# Copy the repository files into the container
COPY . .

# Install dependencies and run Hugo
RUN make all

# Expose the port the server will run on
EXPOSE 8000

# Command to serve the static files
CMD ["python3", "-m", "http.server", "8000", "--directory", "/workspace/public"]