# ---- Build Stage ----
FROM rust:1.77 as builder

WORKDIR /app

# Optimize build by caching dependencies
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo fetch

# Copy source and build
COPY . .
RUN cargo build --release

# ---- Runtime Stage ----
FROM debian:buster-slim

# Install needed system libraries (libssl for some Rust crates)
RUN apt-get update && apt-get install -y libssl1.1 ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/rstash /usr/local/bin/rstash

# Set the default command (change 'rstash' if your binary is named differently)
CMD ["rstash"]
