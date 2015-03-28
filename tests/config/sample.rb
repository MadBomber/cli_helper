
configatron.test do |test|
  test.host = 'localhost'
  test.ip   = '127.0.0.1'
end

configatron.development do |dev|
  dev.host = 'devhost'
  dev.ip   = '127.0.0.1'
end

configatron.production do |prod|
  prod.host = 'prodhost'
  prod.ip   = '0.0.0.0'
end
