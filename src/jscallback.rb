require 'json'

class Jscallback

  def initialize context
    @context = context
  end

  def onReceiveValue json
    android::util::Log.i "Webviewtutorial", "Jscallback#onReceiveValue: #{json}"
    value = JSON.load( json, nil, symbolize_names: true )
    @context.toast "Received value: #{value.inspect}"
  end

end

