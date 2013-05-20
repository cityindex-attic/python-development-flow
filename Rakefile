  require 'fileutils'

  ##
  desc "install dependencies (via virtualenv)"
  ##
  task :install do
    unless File.exists? "vendor"
      puts "Installing dependencies to vendor/"
      sh 'virtualenv --clear --distribute vendor'
      sh 'vendor/bin/pip install -r src/requirements.txt'
      sh 'wget -qO /tmp/komodo-pydbgp.tgz "http://downloads.activestate.com/Komodo/releases/8.0.2/remotedebugging/Komodo-PythonRemoteDebugging-8.0.2-78971-linux-x86_64.tar.gz"'
      sh 'cd /tmp/ && tar -xzf /tmp/komodo-pydbgp.tgz'
      sh 'cp -r /tmp/Komodo-PythonRemoteDebugging-8.0.2-78971-linux-x86_64/pythonlib/dbgp vendor/lib/python2.7/site-packages/'
      sh 'cp /tmp/Komodo-PythonRemoteDebugging-8.0.2-78971-linux-x86_64/pydbgp vendor/bin/pydbgp'
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
    task :ti_debug do
      task_header("Starting browser based debug server (ti-debug)")
      sh "/usr/bin/ti-debug --ti-debug:host 0.0.0.0 &"
      task_header("Visit http://localhost:9222 before pressing enter to continue...")
      $stdin.gets.chomp
    end
    task :server_start_debug do
      task_header("Starting server with debug support")
      sh "vendor/bin/python vendor/bin/pydbgp src/run_httpbin.py 4567"
    end

    desc "Start dev server (Flask)"
    task :all => [:install, :server_start] 

    desc "Start dev server with ti-debug support (Flask)"
    task :all_debug => [:install, :ti_debug, :server_start_debug]
  end
  #end dev server setup

  ##
  desc "run  => [:install, dev_server:all]"
  ##
  task :run => ["dev_server:all"]

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
