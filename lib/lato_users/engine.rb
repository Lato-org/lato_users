module LatoUsers
  class Engine < ::Rails::Engine
    isolate_namespace LatoUsers

    initializer 'lato_users.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << root.join('config/importmap.rb')
    end

    initializer "lato_users.precompile" do |app|
      app.config.assets.precompile << "lato_users_manifest.js"
    end
  end
end
