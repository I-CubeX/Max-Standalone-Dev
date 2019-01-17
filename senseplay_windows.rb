#!/usr/bin/env ruby

#
# Ruby script for making the I-CubeX SensePlay Max standalone app on Windows distribution package
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

# requires ResourceHacker to be installed, see http://angusj.com/resourcehacker/
# requires ResourceHacker to be added to the Windows PATH, see eg. https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/
# you may not need the substitutions effectuated by ".gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)"

require 'fileutils'
require 'zip'

appdir_name = 'SensePlay-100_windows'

# modified from https://github.com/rubyzip/rubyzip/blob/master/samples/example_recursive.rb
class ZipFileGenerator

  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
	@input_dir = input_dir
	@output_file = output_file
  end

  # Zip the input directory.
  def write
	entries = Dir.entries(@input_dir) - %w(. ..)

	::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
	  write_entries entries, '', zipfile
	end
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
	entries.each do |e|
	  zipfile_path = path == '' ? e : File.join(path, e).gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
	  disk_file_path = File.join(@input_dir, zipfile_path).gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
	  puts "Deflating #{disk_file_path}"

	  if File.directory? disk_file_path
		recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
	  else
		put_into_archive(disk_file_path, zipfile, zipfile_path)
	  end
	end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
	subdir = Dir.entries(disk_file_path) - %w(. ..)
	if subdir.length > 0
		write_entries subdir, zipfile_path, zipfile
	else
		put_into_archive(disk_file_path, zipfile, zipfile_path)
	end
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
	zipfile_path = File.join(File.basename(@input_dir), zipfile_path).gsub(File::SEPARATOR,File::ALT_SEPARATOR || File::SEPARATOR)
	if File.directory?(disk_file_path)
		zipfile.mkdir zipfile_path
	else
		zipfile.add(zipfile_path, disk_file_path)
	end
  end
end


appdir_path = File.join(Dir.pwd, appdir_name).gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
settings_path = File.join(Dir.pwd, appdir_name, 'settings').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)

appdir_path_tmp = File.join(Dir.pwd, 'SensePlay').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)

# rename the app directory
unless File.exist?(appdir_path)
	FileUtils.mv appdir_path_tmp, appdir_path
end

# add settings directory
unless File.exist?(settings_path)
  FileUtils.mkdir settings_path
end

# add Readme file
readme_path = File.join(Dir.pwd, appdir_name, 'Readme.txt').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
unless File.exist?(readme_path)
  FileUtils.cp 'resources\Readme.txt', readme_path
end

# add Connect app
connect_path = File.join(Dir.pwd, appdir_name, 'Connect.exe').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
unless File.exist?(connect_path)
  FileUtils.cp 'resources\Connect.exe', connect_path
end

app_path = File.join(Dir.pwd, appdir_name, 'SensePlay.exe').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
app_path_tmp = File.join(Dir.pwd, appdir_name, 'SensePlay_tmp.exe').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
if File.exist?(app_path)
  
	# change app icon
	result = system("resourcehacker.exe -open #{app_path} -save #{app_path_tmp} -action addskip -res resources/SensePlay.ico -mask ICONGROUP,MAINICON")
	if File.exist?(app_path_tmp)
		File.delete(app_path)
		File.rename(app_path_tmp, app_path)
	end
    
	# zip the app directory
	directory_to_zip = appdir_path
	output_file = File.join(appdir_name, 'zip').gsub(File::SEPARATOR, '.').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
	zf = ZipFileGenerator.new(directory_to_zip, output_file)
	zf.write()

end
