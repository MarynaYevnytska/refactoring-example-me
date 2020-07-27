module Storage
  save(object, file_path)
  File.new(file_path, 'w+') unless File.exist?(file_path)
  File.open(file_path, 'w+') { |file| file.write object.to_yaml }
end
