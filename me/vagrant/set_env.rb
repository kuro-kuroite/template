

File.open(".env", "r") do |f|
  f.each_line do |line|
    p line[0]
    if line[0] == "#" || line[0] == " "
      puts "next!"
      next
    end

    k, v = line.scan(/[A-Za-z_][A-Za-z0-9_]+/)
    ENV[k] = v
  end
end
