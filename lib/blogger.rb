# frozen_string_literal: true

require_relative 'blogger/version'

require 'active_support/core_ext/hash/keys'
require 'date'
require 'fileutils'
require 'logger'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'
require 'tilt'
require 'yaml'

module Blogger
  class Error < StandardError; end

  class Renderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  class Engine
    def initialize(options = {})
      _validate_options!(options)

      @contents_dir = options[:contents_dir]
      @assets_dir   = options[:assets_dir]
      @layouts_dir  = options[:layouts_dir]
      @public_dir   = options[:public_dir]

      @scheme = options[:scheme] || 'http'
      @host   = options[:host]   || 'localhost'
      @port   = options[:port]   || 8080

      @markdown = Redcarpet::Markdown.new(Renderer, autolink: true, fenced_code_blocks: true)
      @log      = Logger.new(STDOUT)
    end

    def build
      # Layouts, Stylesheets, and Assets.
      assets_dir = File.join(@public_dir, 'assets')
      Dir.mkdir(@public_dir) unless File.exist?(@public_dir)
      Dir.mkdir(assets_dir) unless File.exist?(assets_dir)

      @template = Tilt.new(File.join(@layouts_dir, 'index.haml'))
      Dir[File.join(@layouts_dir, '*')].each do |f|
        FileUtils.cp_r(f, @public_dir) if File.directory?(f)
      end
      Dir[File.join(@assets_dir, '*')].each do |f|
        FileUtils.cp_r(f, assets_dir)
      end

      _build_index
      _build_contents
    end

    def link(path)
      path = path.delete_prefix(@public_dir)

      if @port != 80 && @port != 443
        "#{@scheme}://#{@host}:#{@port}/#{path}"
      else
        "#{@scheme}://#{@host}/#{path}"
      end
    end

    private

    def _validate_options!(options = {})
      options.assert_valid_keys(:contents_dir, :assets_dir, :layouts_dir, :public_dir, :scheme, :host, :port)
    end

    def _build_index(src = nil, dst = nil, nav = nil)
      src ||= @contents_dir
      dst ||= @public_dir

      # Reset nav.
      if nav.nil?
        @nav = {}
        nav = @nav
        nav[''] = [] # Root.
      end

      # Walk contents to create index/nav.
      Dir[File.join(src, '*')].each do |f|
        if File.directory?(f)
          nav[f.delete_prefix(@contents_dir)] = []
          section_dirpath = File.join(@public_dir, File.basename(f))
          _build_index(f, section_dirpath, nav)
        else
          dst_file = File.join(dst, File.basename(f, '.md')) + '.html'

          content = File.read(f)
          front_matter, = _extract_front_matter(content)
          title = front_matter['title']
          date  = Date.strptime(front_matter['date'], '%Y-%m-%d').strftime('%Y/%m/%d')

          nav[src.delete_prefix(@contents_dir)] << { title: title, link: link(dst_file), date: date }
        end
      end
    end

    def _build_contents(src = nil, dst = nil)
      src ||= @contents_dir
      dst ||= @public_dir
      changed_pages = []

      # Contents.
      Dir[File.join(src, '*')].each do |f|
        if File.directory?(f)
          section_dirpath = File.join(@public_dir, File.basename(f))

          @log.info "=== #{section_dirpath}"
          Dir.mkdir(section_dirpath) unless File.exist?(section_dirpath)

          changed_pages += _build_contents(f, section_dirpath)
        else
          dst_file = File.join(dst, File.basename(f, '.md')) + '.html'

          @log.info "#{f} => #{dst_file}"

          content = File.read(f)
          front_matter, body = _extract_front_matter(content)
          title              = front_matter['title']

          page = {
            title: title,
            link: link(dst_file),
            type: src.delete_prefix(@contents_dir)
          }

          context            = Context.new
          context.page_title = "Sarans' Blog | #{title}" # TODO: Configurable.
          context.title      = title
          context.content    = @markdown.render(body)
          context.date       = Date.strptime(front_matter['date'], '%Y-%m-%d').strftime('%-d %b, %Y')
          context.articles   = @nav['articles'].sort { |a, b| b[:date] <=> a[:date] }
          context.link       = ->(path) { link(path) } # TODO: Extract link() to helper.

          File.write(dst_file, @template.render(context))

          changed_pages << page
        end
      end

      changed_pages
    end

    def _extract_front_matter(content)
      splits = content.split('---')

      front_matter = YAML.load(splits[1])
      body         = splits[2]

      [front_matter, body]
    end
  end

  class Context
    attr_accessor :page_title, :title, :content, :date, :articles, :link

    def initialize
      @articles = []
    end
  end
end
