# DO NOT MODIFY THIS FILE
module Bundler
 file = File.expand_path(__FILE__)
 dir = File.dirname(file)

  ENV["GEM_HOME"] = dir
  ENV["GEM_PATH"] = dir
  ENV["PATH"]     = "#{dir}/../../bin:#{ENV["PATH"]}"
  ENV["RUBYOPT"]  = "-r#{file} #{ENV["RUBYOPT"]}"

  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/extlib-0.9.14/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/extlib-0.9.14/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-1.0.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/rack-1.0.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sinatra-0.9.4/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/sinatra-0.9.4/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-aggregates-0.10.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-aggregates-0.10.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/addressable-2.1.1/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/addressable-2.1.1/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-core-0.10.2/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/dm-core-0.10.2/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/data_objects-0.10.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/data_objects-0.10.0/lib")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/do_sqlite3-0.10.0/bin")
  $LOAD_PATH.unshift File.expand_path("#{dir}/gems/do_sqlite3-0.10.0/lib")

  @gemfile = "#{dir}/../../Gemfile"

  require "rubygems"

  @bundled_specs = {}
  @bundled_specs["extlib"] = eval(File.read("#{dir}/specifications/extlib-0.9.14.gemspec"))
  @bundled_specs["extlib"].loaded_from = "#{dir}/specifications/extlib-0.9.14.gemspec"
  @bundled_specs["rack"] = eval(File.read("#{dir}/specifications/rack-1.0.1.gemspec"))
  @bundled_specs["rack"].loaded_from = "#{dir}/specifications/rack-1.0.1.gemspec"
  @bundled_specs["sinatra"] = eval(File.read("#{dir}/specifications/sinatra-0.9.4.gemspec"))
  @bundled_specs["sinatra"].loaded_from = "#{dir}/specifications/sinatra-0.9.4.gemspec"
  @bundled_specs["dm-aggregates"] = eval(File.read("#{dir}/specifications/dm-aggregates-0.10.2.gemspec"))
  @bundled_specs["dm-aggregates"].loaded_from = "#{dir}/specifications/dm-aggregates-0.10.2.gemspec"
  @bundled_specs["addressable"] = eval(File.read("#{dir}/specifications/addressable-2.1.1.gemspec"))
  @bundled_specs["addressable"].loaded_from = "#{dir}/specifications/addressable-2.1.1.gemspec"
  @bundled_specs["dm-core"] = eval(File.read("#{dir}/specifications/dm-core-0.10.2.gemspec"))
  @bundled_specs["dm-core"].loaded_from = "#{dir}/specifications/dm-core-0.10.2.gemspec"
  @bundled_specs["data_objects"] = eval(File.read("#{dir}/specifications/data_objects-0.10.0.gemspec"))
  @bundled_specs["data_objects"].loaded_from = "#{dir}/specifications/data_objects-0.10.0.gemspec"
  @bundled_specs["do_sqlite3"] = eval(File.read("#{dir}/specifications/do_sqlite3-0.10.0.gemspec"))
  @bundled_specs["do_sqlite3"].loaded_from = "#{dir}/specifications/do_sqlite3-0.10.0.gemspec"

  def self.add_specs_to_loaded_specs
    Gem.loaded_specs.merge! @bundled_specs
  end

  def self.add_specs_to_index
    @bundled_specs.each do |name, spec|
      Gem.source_index.add_spec spec
    end
  end

  add_specs_to_loaded_specs
  add_specs_to_index

  def self.require_env(env = nil)
    context = Class.new do
      def initialize(env) @env = env && env.to_s ; end
      def method_missing(*) ; yield if block_given? ; end
      def only(*env)
        old, @only = @only, _combine_only(env.flatten)
        yield
        @only = old
      end
      def except(*env)
        old, @except = @except, _combine_except(env.flatten)
        yield
        @except = old
      end
      def gem(name, *args)
        opt = args.last.is_a?(Hash) ? args.pop : {}
        only = _combine_only(opt[:only] || opt["only"])
        except = _combine_except(opt[:except] || opt["except"])
        files = opt[:require_as] || opt["require_as"] || name
        files = [files] unless files.respond_to?(:each)

        return unless !only || only.any? {|e| e == @env }
        return if except && except.any? {|e| e == @env }

        if files = opt[:require_as] || opt["require_as"]
          files = Array(files)
          files.each { |f| require f }
        else
          begin
            require name
          rescue LoadError
            # Do nothing
          end
        end
        yield if block_given?
        true
      end
      private
      def _combine_only(only)
        return @only unless only
        only = [only].flatten.compact.uniq.map { |o| o.to_s }
        only &= @only if @only
        only
      end
      def _combine_except(except)
        return @except unless except
        except = [except].flatten.compact.uniq.map { |o| o.to_s }
        except |= @except if @except
        except
      end
    end
    context.new(env && env.to_s).instance_eval(File.read(@gemfile), @gemfile, 1)
  end
end

module Gem
  @loaded_stacks = Hash.new { |h,k| h[k] = [] }

  def source_index.refresh!
    super
    Bundler.add_specs_to_index
  end
end