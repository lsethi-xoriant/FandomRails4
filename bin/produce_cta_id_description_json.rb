require "pg"
require "csv"
require "json"

def main

  if ARGV.size != 3
    puts <<-EOF
      Usage: #{$0} <dc_db_name>, <violetta_db_name>, <disney_db_name>
    EOF
    exit
  end
  
  dc_db_name = ARGV[0]
  violetta_db_name = ARGV[1]
  disney_db_name = ARGV[2]

  res = Array.new

  dc_conn = PG::Connection.open(:dbname => dc_db_name)
  violetta_conn = PG::Connection.open(:dbname => violetta_db_name)
  disney_conn = PG::Connection.open(:dbname => disney_db_name)

  contents_dc = dc_conn.exec("SELECT name, description FROM contents WHERE cnt_type = 'Experience::PostContent'")
  contents_violetta = violetta_conn.exec("SELECT name, description FROM contents WHERE cnt_type = 'Experience::PostContent'")

  contents_dc.values.each do |line|
    hash = { 'title' => line[0], 'description' => line[1] }
    res.push(hash)
  end

  contents_violetta.values.each do |line|
    hash = { 'title' => line[0], 'description' => line[1] }
    res.push(hash)
  end

  puts res.to_json

end

main()

