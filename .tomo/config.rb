# rubocop:disable Style/FormatStringToken
plugin "git"
plugin "env"
plugin "bundler"
plugin "rails"
plugin "nodenv"
plugin "puma"
plugin "rbenv"
plugin "./plugins/minimal.rb"

# host "user@hostname.or.ip.address"
host "deployer1@energy-fr.swegon.com"

set application: "minimal"
set deploy_to: "/var/www/%{application}"
set nodenv_node_version: nil # FIXME
set nodenv_yarn_version: ""
set git_url: "https://github.com/francois0690/minimal.git"
set git_branch: "master"
set git_exclusions: %w[
  .tomo/
  spec/
  test/
]
set env_vars: {
  RACK_ENV: "production",
  RAILS_ENV: "production",
  RAILS_LOG_TO_STDOUT: "1",
  RAILS_SERVE_STATIC_FILES: "1",
  DATABASE_URL: "postgres://energy:energy@localhost/energy",
  SECRET_KEY_BASE: "a8d4537f7efe2d94fa89b8119c125d7047aafc90ef65caf79143c44b2673e6c58ec3b7e728dc59bd620a09b8c8f3b3e68a23790244b89317de866503cbf9a7aa"
}
set linked_dirs: %w[
  log
  node_modules
  public/assets
  public/packs
  tmp/cache
  tmp/pids
  tmp/sockets
]

setup do
  run "env:setup"
  run "core:setup_directories"
  run "git:clone"
  run "git:create_release"
  run "core:symlink_shared"
  run "nodenv:install"
  run "rbenv:install"
  run "bundler:upgrade_bundler"
  run "bundler:config"
  run "bundler:install"
  run "rails:db_create"
  run "rails:db_schema_load"
  run "rails:db_seed"
  run "puma:setup_systemd"
end

deploy do
  run "env:update"
  run "git:create_release"
  run "core:symlink_shared"
  run "core:write_release_json"
  run "bundler:install"
  run "rails:db_migrate"
  run "rails:db_seed"
  run "rails:assets_precompile"
  run "core:symlink_current"
  run "puma:restart"
  run "puma:check_active"
  run "core:clean_releases"
  run "bundler:clean"
  run "core:log_revision"
end
# rubocop:enable Style/FormatStringToken
