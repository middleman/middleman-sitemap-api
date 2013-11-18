require 'grape'
require 'pathname'

module Middleman
  class APIExtension < ::Middleman::Extension
    option :at, '/__api', 'Specify where the API should live'
    option :build, true, 'Whether the API is built to static files'
    option :source_file, false, 'Lookup resources by source file'
    option :include_body, false, 'Include rendered body in output'
    option :include_raw_body, false, 'Include raw body in output'
    option :include_layout, false, 'Include layout in rendered body'
    option :include_metadata, true, 'Include metadata in output'
    option :paginate, false, 'Max resources per page'

    def initialize(app, options_hash={})
      super

      @ready = false
    end

    def after_configuration
      app.use SelfReferential, app: app, options: options

      app.map options[:at] do
        run ::Middleman::APIExtension::API
      end

      app.logger.info "== API mounted at #{options[:at]}"

      @ready = true
    end

    def make_endpoint(relative_path)
      prefix = options[:at].sub(/^\//, '').sub(/\/$/, '')
      path = "#{prefix}/#{relative_path}"

      ::Middleman::Sitemap::Extensions::RequestEndpoints::EndpointResource.new(
        app.sitemap,
        path,
        path
      )
    end

    def manipulate_resource_list(resources)
      return resources unless @ready && app.build? && options[:build]

      endpoints = []

      endpoints << make_endpoint("config.json")

      # Search
      if options[:paginate]
        pages_count = (resources.length / options[:paginate]).ceil
        pages_count.times do |i|
          endpoints << make_endpoint("resources/pages/#{i+1}.json")
        end
      else
        endpoints << make_endpoint("resources.json")
      end


      resources.each do |r|
        next if r.is_a? ::Middleman::Sitemap::Extensions::RequestEndpoints::EndpointResource

        path = options[:source_file] ? r.source_file.sub("#{middleman.source_dir}/", '') : r.destination_path

        endpoints << make_endpoint("resources/details/#{path}.json")
        
        if !options[:include_body]
          endpoints << make_endpoint("resources/body/#{path}.json")
        end

        if !options[:include_metadata]
          endpoints << make_endpoint("resources/metadata/#{path}.json")
        end
      end

      resources + endpoints
    end

    class SelfReferential
      def initialize(app, options={})
        @app = app
        @options = options
      end

      def call(env)
        env['MIDDLEMAN_APP_REF'] = @options
        @app.call(env)
      end
    end

    class API < Grape::API
      format :json

      helpers do
        def options
          env['MIDDLEMAN_APP_REF'][:options]
        end

        def middleman
          env['MIDDLEMAN_APP_REF'][:app]
        end

        def sitemap
          middleman.sitemap
        end

        def sitemap_resources
          sitemap.resources
        end

        def metadata(resource)
          md = resource.metadata.dup
          md.delete :blocks
          md.delete :locals if md[:locals].empty?
          md.delete :options if md[:options].empty?
          md[:frontmatter] = md.delete(:page)
          md
        end

        def raw_body_content(resource)
          middleman.template_data_for_file(resource.source_file)
        end

        def body_content(resource)
          if options[:include_layout]
            resource.render
          else
            resource.render layout: false
          end
        end

        def serialize_article(resource, output={})
          output.merge({
            article: true,
            title: resource.title,
            date: resource.date,
            summary: resource.summary,
            slug: resource.slug,
            tags: resource.tags
          })
        end

        def serialize(resource)
          output = {
            source_file: resource.source_file.sub("#{middleman.source_dir}/", ''),
            path: resource.destination_path,
            binary: resource.binary?
          }

          if options[:include_body] && !resource.binary?
            output[:body] = body_content(resource)
          end

          if options[:include_raw_body] && !resource.binary?
            output[:raw_body] = raw_body_content(resource)
          end

          if options[:include_metadata]
            output[:metadata] = metadata(resource)
          end

          if resource.is_a? ::Middleman::Blog::BlogArticle
            serialize_article(resource, output)
          else 
            output
          end
        end

        def search(path)
          clean_path = path.sub(/\.json$/, '')

          if !options[:source_file]
            sitemap.find_resource_by_destination_path(clean_path)
          else
            full_path = File.join(middleman.source_dir, clean_path)
            sitemap_resources.find { |r| r.source_file === full_path }
          end
        end

        def serialize_option(option)
          {
            key: option.key,
            value: option.value,
            default: option.default,
            modified: option.value_set?,
            description: option.description
          }
        end
      end

      desc "Middleman Metadata"
      get 'config' do
        global_config = middleman.config.all_settings.map(&method(:serialize_option))

        modern_extensions = middleman.extensions.select do |ext_name, extension|
          extension.is_a?(::Middleman::Extension)
        end.dup

        extensions = ::Middleman::Extensions.registered.dup
        active_extensions = []
        modern_extensions.each do |ext_name, extension|
          extensions.delete ext_name

          active_extensions << {
            name: ext_name,
            options: extension.options.all_settings.map(&method(:serialize_option))
          }
        end

        {
          root: middleman.root,
          global_config: global_config,
          active_extensions: active_extensions,
          inactive_extensions: extensions.keys
        }
      end

      resource :resources do
        desc "Return a list of resources"
        get do
          sitemap_resources.map(&method(:serialize))
        end

        desc "Return paged resources"
        params do
          requires :page, type: Integer, desc: "Page number"
        end
        get 'pages/:page' do
          sitemap_resources.each_slice(options[:paginate] || 10).to_a[params['page']-1].map(&method(:serialize))
        end

        desc "Return a resource"
        params do
          requires :path, type: String, desc: "Destination page of resource"
        end
        get 'details/*path' do
          resource = search(params[:path])

          if resource
            serialize(resource)
          else
            error! "File Not Found", 404
          end
        end

        desc "Return a resource body"
        params do
          requires :path, type: String, desc: "Destination page of resource"
        end        
        get 'body/*path' do
          resource = search(params[:path])

          if resource
            if resource.binary?
              { binary: true }
            else
              output = { body: body_content(resource) }
              if options[:include_raw_body]
                output[:raw_body] = raw_body_content(resource)
              end
              output
            end
          else  
            nil
          end
        end

        desc "Return a resource metadata"
        params do
          requires :path, type: String, desc: "Destination page of resource"
        end
        get 'metadata/*path' do
          resource = search(params[:path])
          resource ? metadata(resource) : nil
        end
      end
    end
  end
end
