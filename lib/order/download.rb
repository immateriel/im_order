module ImOrder
  module DownloadList
    def to_downloads(resp)
      downloads={}
      resp.result.children.each do |pr|
        if pr.element?
          downloads[pr["isbn"]]||=[]
          pr.children.each do |l|
            if l.element?
              downloads[pr["isbn"]]<<ImOrder::Download.new(l["ean"],l["name"],l["mimetype"],l["format_key"],l["url"])
            end
          end
        end
      end
      downloads
    end
  end

  class Download
    attr_accessor :ean, :name, :mimetype, :key, :url
    def initialize(ean,name,mimetype,key,url)
      @ean=ean
      @name=name
      @mimetype=mimetype
      @key=key
      @url=url
    end
  end
end