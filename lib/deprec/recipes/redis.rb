# Copyright 2006-2008 by Mike Bailey. All rights reserved.
Capistrano::Configuration.instance(:must_exist).load do 
  namespace :deprec do
    namespace :redis do
  
  set :redis_port, 6379
  set :redis_host, '127.0.0.1'

  SYSTEM_CONFIG_FILES[:redis] = [
    
    {:template => 'config.erb',
     :path => "/etc/redis/#{redis_port}.conf",
     :mode => 0755,
     :owner => 'root:root'} ]

  # start
  task :start do
    sudo "service redis start"
    #sudo '/bin/bash -l -c "redis-server /etc/redis/6379.conf &"'
  end
  
  # stop
  task :stop do
    #sudo "service redis stop"
    sudo "rm -f /var/run/redis_#{redis_port}.pid"
    sudo "killall -q redis-server"
  end
  
  # restart
  task :restart do
    stop
    start
  end
  
  task :install do
    version = 'redis-2.0.4'
    set :src_package, {
      :file => version + '.tar.gz',   
      :sha1sum => 'fee2f1960eda22385503517a9a6dcae610df84d5', 
      :dir => version,  
      :url => "http://redis.googlecode.com/files/#{version}.tar.gz",
      :unpack => "tar zxf #{version}.tar.gz;",
      :configure => %w{
        }.reject{|arg| arg.match '#'}.join(' '),
      :make => 'make;',
      :install => 'make install;',
      :post_install => 'install -b utils/redis_init_script /etc/init.d/redis;'
    }
    deprec2.download_src(src_package, src_dir)
    deprec2.install_from_src(src_package, src_dir)
    sudo 'mkdir /opt/redis'
    #sudo 'touch /etc/redis/6379.conf'

    SYSTEM_CONFIG_FILES[:redis].each do |file|
      deprec2.render_template(:redis, file.merge(:remote=>true))
    end
    deprec2.push_configs(:redis, SYSTEM_CONFIG_FILES[:redis])
  end
end end
  
end
