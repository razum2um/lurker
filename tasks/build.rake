namespace :assets do
  desc 'compiles static css & js for web'
  task :precompile do
    require 'pathname'
    require 'logger'
    require 'fileutils'

    require 'lurker/cli'

    require 'sprockets'
    require 'sass-rails'

    ROOT        = Pathname(File.dirname(__FILE__))
    LOGGER      = Logger.new(STDOUT)
    BUNDLES     = %w( application.css application.js )
    BUILD_DIR   = Lurker::Cli.assets_root
    SOURCE_DIR  = Lurker::Cli.templates_root

    FileUtils.rm_rf(BUILD_DIR)
    FileUtils.mkdir_p(BUILD_DIR)

    # raw copy
    %w[fonts bootstrap.css.map].each do |subdir|
      FileUtils.cp_r(SOURCE_DIR.join(subdir), BUILD_DIR)
    end

    sprockets = Sprockets::Environment.new(ROOT) do |env|
      env.logger = LOGGER
    end

    sprockets.context_class.class_eval do
      def asset_path(path, options = {})
        '/'
      end
    end

    sprockets.append_path(SOURCE_DIR.join('javascripts').to_s)
    sprockets.append_path(SOURCE_DIR.join('stylesheets').to_s)

    %w[jquery-rails bootstrap-sass remotipart lurker].each do |gem|
      gem_path = Pathname.new(Bundler.rubygems.find_name(gem).first.full_gem_path)
      %w[javascripts stylesheets fonts].each do |prefix|
        %w[assets vendor/assets lib/lurker/templates].each do |interfix|
          path = gem_path.join(interfix, prefix).to_s
          sprockets.append_path(path) if File.exists? path
        end
      end
    end

    unless ENV['TRAVIS']
      sprockets.js_compressor  = :uglify
      sprockets.css_compressor  = :scss
    end

    BUNDLES.each do |bundle|
      assets = sprockets.find_asset(bundle)
      realname = (assets.pathname.basename.to_s.split(".").take_while { |s| !s.match /^(js|css|scss)$/ } + [$~.to_s]).join(".").gsub(/\.scss$/, '.css')
      assets.write_to(BUILD_DIR.join(realname))
    end
  end
end

