MRuby::CrossBuild.new(ENV['MRUBY_CONFIG_NAME'] || 'minimal') do |conf|
  conf.toolchain :gcc

  toolchain = {
    cc:       { name: "gcc", env: 'CC' },
    linker:   { name: "ld",  env: 'LD' },
    archiver: { name: "ar",  env: 'AR' }
  }

  # Override commands with cross-compiler
  cross = String(ENV['CROSS_COMPILE'])
  toolchain.each do |tool, exe|
    conf.send(tool).command = ENV[exe[:env]] || "#{cross}#{exe[:name]}"
  end

  conf.cc.flags    << ENV['CROSS_CFLAGS']  || []
  conf.linker.flags = ENV['CROSS_LDFLAGS'] || []

  # Stop mruby from adding platform includes
  conf.cc.include_paths.clear
  conf.cc.include_paths << ['include']

  conf.gem :core => 'mruby-compiler'
end
