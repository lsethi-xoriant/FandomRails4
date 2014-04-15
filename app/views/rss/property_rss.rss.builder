xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "RSS #{ @current_prop.name }"
    xml.description "RSS #{ @current_prop.name }"
    xml.link "TODOTODOTODO"

    for calltoaction in @calltoaction_list
      xml.item do

        xml.title "#{ calltoaction.title }"
        xml.description do
          xml.cdata! ("<p><img src=\"#{ calltoaction.image.url }\" width=\"400\" align=\"left\" hspace=\"10\"><p>")
        end

        xml.pubDate calltoaction.activated_at.to_s(:rfc822)
        xml.link "TODOTODOTODO"
      end
    end
  end
end