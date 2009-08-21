class TruncateExtension < Radiant::Extension
  version "0.1"
  description "Adds truncate tag to Radiant for truncating content"
  url "http://github.com/saturnflyer/radiant-truncate-extension"
  
  extension_config do |config|
    config.gem 'nokogiri'
  end
  
  def activate
    Page.send :include, TruncateTags
  end
end