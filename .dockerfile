# Ignore version control files:
.git/
.gitignore

# Ignore docker and environment files:
Dockerfile
docker-compose.yml
bin/entrypoint-dev
.dockerignore

# Ignore all dotenv files - we don't want any secret pushed inside any Docker image:
**/*.env

# Ignore log files:
log/*.log

# Ignore temporary files:
tmp/

# Ignore test files:
.rspec
Guardfile
spec/

# Ignore OS artifacts:
**/.DS_Store

# Ignore bundler cache:
.bundle/

# Ignore springified binstubs - we'll leave the `bin/rails` and `bin/rake` as they are used by hutch
# to detect a rails app:
bin/rspec
config/spring.rb

# Ignore bash / IRB / Byebug history files
.bash_history
.byebug_hist
.byebug_history
.pry_history
.guard_history

# Ignore development executables:
bin/checkdb
bin/setup
bin/spring
bin/update
