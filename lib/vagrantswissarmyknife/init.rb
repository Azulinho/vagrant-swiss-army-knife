module VagrantSwissArmyKnife
  class Init

    def first_run
      self.install_templates
    end

    def initialize
    end

    def setup
      @plugins, @boxes = load_config
    end

    def boxes
      @boxes = YAML.load(File.read('config/boxes.yaml'))
    end

    def plugins
      @plugins = YAML.load(File.read('config/plugins.yaml'))
    end

    def load_config
      return [ plugins, boxes ]
    end

    def bundle
      install_vagrant_plugins
      download_vagrant_boxes
      import_vagrant_boxes
    end

    def install_templates
      %w[Vagrantfile Berksfile Gemfile].each do |tt|

        template = File.read(File.expand_path("../templates/#{tt}", __FILE__))

        File.open "#{tt}", 'w', 0755 do |f|
          f.puts ERB.new(template, nil, '-').result(binding)
        end
      end

      %w[plugins.yaml boxes.yaml].each do |cfg|
        `mkdir config`
        `cp ../templates/#{cfg} config/#{cfg}`
      end
    end

    def install_vagrant_plugins
      # clean Vagrantfile
      system("rm Vagrantfile")

      # Bindler is going beserk on me, lets fall back to a simple
      # vagrant plugin install
      @plugins.each do |x|
        system("vagrant plugin install #{x}")
      end

      # we need the latest vagrant-vbguest
      # remind me why!
      cli = %w[vagrant plugin install
               --plugin-source http://rubygems.org/
               --plugin-prerelease vagrant-vbguest" ].join(' ')
      system(cli)
    end

    def download_vagrant_boxes
      @boxes.each_pair do |name,url|
        system("wget -c #{url}")
      end
    end

    def import_vagrant_boxes
      @boxes.each_pair do |name,url|
        system("vagrant box add #{name} #{url}")
      end
    end

    def clean_vagrant_boxes
      @boxes.each_pair do |name,url|
        system("rm #{name}.box")
      end
    end

    def uninstall_vagrant_plugins
      # Bindler is going beserk on me, lets fall back to a simple
      # vagrant plugin install
      @plugins.each do |x|
        system("vagrant plugin uninstall #{x}")
      end
    end

   def uninstall
     Vagrant::Swissarmyknife::Operations.destroy_vagrant_vms
     system("rm Vagrantfile")
     uninstall_vagrant_plugins
   end

   def bundler
     system("bundle install")
   end

    def destroy_vagrant_vms
      system("vagrant destroy -f")
    end

    def clean_downloaded_boxes
      @boxes.each_pair do |name,url|
        system("rm #{name}.box")
      end
    end

  end #class Init
end

