FROM ghcr.io/gleam-lang/gleam:v1.4.1-erlang

WORKDIR /app

# Copy everything
COPY . .

WORKDIR /app/server
RUN gleam deps download
RUN gleam build

EXPOSE 8000

CMD ["gleam", "run"]
