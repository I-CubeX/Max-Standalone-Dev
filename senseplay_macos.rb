#!/usr/bin/env ruby

#
# Ruby script for making the I-CubeX SensePlay Max standalone app on MacOS distribution package
#
# 1. Place Readme.txt, the Connect app and SensePlay.icns in a folder named resources
# 2. Use Max to build and save the app in the folder appdir_name
# 3. Use a terminal to execute the script in the folder where folders appdir_name and resources are
# 4. After a short delay, the zipped SensePlay app is ready for distribution 
#
# SensePlay software provides a quick and easy way to setup audio, video or slide shows 
# controlled by gestures and other movements captured with sensors.
#
# http://icubex.com/senseplay
#
# I-CubeX comprises modular hardware and software to create interactive systems, 
# build sensor interfaces and perform data acquisition, amongst others.
# 
# I-CubeX - Capture Motion, Control Media
#
# Copyright 2019 Infusion Systems Ltd. 
#
# http://infusionsystems.com
#


require "fileutils"

appdir_name = 'SensePlay-100_macos'

# add settings directory
settings_path = File.join(Dir.pwd, appdir_name, 'settings')
unless File.exist?(settings_path)
  FileUtils.mkdir settings_path
end

# add Readme file
readme_path = File.join(Dir.pwd, appdir_name, 'Readme.txt')
unless File.exist?(readme_path)
  FileUtils.cp 'resources/Readme.txt', readme_path
end

# add Connect app
connect_path = File.join(Dir.pwd, appdir_name, 'Connect.app')
unless File.exist?(connect_path)
  FileUtils.cp_r 'resources/Connect.app', connect_path
end

app_path = File.join(Dir.pwd, appdir_name, 'SensePlay.app')
if File.exist?(app_path)
  
  icon_path = File.join(Dir.pwd, appdir_name, 'SensePlay.app/Contents/Resources/SensePlay.icns')

  unless File.exist?(icon_path)
    FileUtils.cp 'resources/SensePlay.icns', icon_path
  end

  # change app icon
  plist_path = File.join(Dir.pwd, appdir_name, 'SensePlay.app/Contents/info.plist')
  if File.foreach(plist_path).grep('Max.icns')
    plist_text = File.read(plist_path)
    plist_newtext = plist_text.gsub('Max.icns', 'SensePlay.icns')
    File.open(plist_path, "w") {|file| file.puts plist_newtext}
  end

  # edit the version number and copyright notice (visible in the file info with CMD-I)
  if File.foreach(plist_path).grep('8.0.3, Copyright 2014 Cycling \'74')
    plist_text = File.read(plist_path)
    plist_newtext = plist_text.gsub('8.0.3, Copyright 2014 Cycling \'74', '1.00, Copyright 2019 Infusion Systems Ltd.')
    File.open(plist_path, "w") {|file| file.puts plist_newtext}
  end

  FileUtils.touch app_path
  
  # zip the directory
  archive_path = File.join(appdir_name, 'zip').gsub(File::SEPARATOR, '.')
  unless File.exists?(archive_path)
    result = system("zip -r #{archive_path} #{appdir_name}")
  end
end
