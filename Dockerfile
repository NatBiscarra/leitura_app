# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.10
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
# Alterado para remover otimizações de produção e incluir sqlite3, build-essential e git.
RUN apt-get update -qq && \
    apt-get install -y nodejs npm sqlite3 build-essential git libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
# Originalmente "production". Alterado para "development" para permitir o uso de um ambiente de desenvolvimento dentro do contêiner. 
ENV RAILS_ENV="development"
    

# Install application gems
COPY Gemfile Gemfile.lock ./

RUN bundle install 
    
# Copy application code
COPY . .

# Start server via Thruster by default, this can be overwritten at runtime
# Alterado EXPOSE para 3000, que é a porta padrão do servidor Rails em desenvolvimento.
# Alterado CMD para iniciar o servidor Rails em vez do Thruster, adequado para desenvolvimento.
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

