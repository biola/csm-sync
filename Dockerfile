FROM biola/ruby_app:2.1.6

# Setting the CI_BUILD_STAGE build argument to `true` will prevent initializers
# from connecting to dependencies during asset precompilation
ARG CI_BUILD_STAGE
# The relative URL root is overridden in CI config
ARG RELATIVE_URL_ROOT=/
# Use the production env by default
ENV RACK_ENV production
ENV LD_LIBRARY_PATH /opt/oracle/instantclient_12_2
ENV NLS_LANG AMERICAN_AMERICA.UTF8

# Put the app in /application
RUN mkdir /application && chown ruby:www-data /application
ENV APP_ROOT /application
WORKDIR $APP_ROOT

# Use the ruby user when running the container (and for the RUN commands below)
USER ruby

# Copy the Gemfile first so we can build gems
# This will allow us to cache this layer to speed up builds
COPY --chown=ruby:www-data Gemfile Gemfile.lock $APP_ROOT/
RUN bundle install --deployment --without test development

# Copy the rest of the app to /application
COPY --chown=ruby:www-data . $APP_ROOT

CMD ["bundle", "exec", "sidekiq -r /application/config/environment.rb --index 0 --tag csm-sync"]
