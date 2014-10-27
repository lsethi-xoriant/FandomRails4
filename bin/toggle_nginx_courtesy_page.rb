#!/bin/ruby

#
# Set or remove a courtesy page in nginx
#

require('fileutils.rb')

COURTESY_PAGE = '/etc/nginx/sites-available/courtesy_page'
COURTESY_PAGE_LINK = '/etc/nginx/sites-enabled/00courtesy_page'

def main
  if File.exists?(COURTESY_PAGE_LINK)
    FileUtils.rm(COURTESY_PAGE_LINK)
  else
    FileUtils.ln_s(COURTESY_PAGE, COURTESY_PAGE_LINK)
  end
  system('service nginx restart')
end

main()
