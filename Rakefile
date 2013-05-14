  require 'fileutils'

  ##
  desc "install dependencies (via virtualenv)"
  ##
  task :install do
    unless File.exists? "vendor"
      puts "Installing dependencies to vendor/"
      sh 'virtualenv --clear --distribute vendor'
      sh 'vendor/bin/pip install -r src/requirements.txt'
    end
  end

  ##
  desc "delete created assets"
  ##
  task :clean do
    puts "Deleting vendor/"
    sh 'rm -rf vendor/'
  end

  ##
  desc "dev server setup"
  ##
  namespace :dev_server do
    task :server_start do
      task_header("Starting server")
      sh "vendor/bin/python src/run_httpbin.py 4567" # 'sh' streams the cmnd's stdout
    end
    desc "Start dev server (Flask)"
    task :all => [:server_start] 
  end
  #end dev server setup

  ##
  desc "run  => [:install, dev_server:all]"
  ##
  task :run => [:install, "dev_server:all"]

  ##
  task :default => [:run] do
    puts "Ready for the day!"
    puts ""
  end
  #end default

  def task_header(title)
    puts "\n##########################"
    puts "#\t#{title}"
    puts "##########################"
  end
