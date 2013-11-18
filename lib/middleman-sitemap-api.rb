require "middleman-core"
require "middleman-sitemap-api/version"
  
::Middleman::Extensions.register(:sitemap_api) do
  require "middleman-sitemap-api/extension"
  ::Middleman::SitemapAPIExtension
end
