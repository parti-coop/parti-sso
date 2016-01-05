%w(uploads).each do |folder|
  run "echo 'release_path: #{config.release_path}/public/#{folder}' >> #{config.shared_path}/logs.log"
  run "ln -nfs #{config.shared_path}/public/#{folder} #{config.release_path}/public/"
end
