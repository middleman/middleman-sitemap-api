require "middleman-core"
require "middleman-api/version"
  
::Middleman::Extensions.register(:api) do
  require "middleman-api/extension"
  ::Middleman::APIExtension
end
