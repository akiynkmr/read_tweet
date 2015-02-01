require 'twitter'
require 'voice_text_api'
require 'open3'
 
CONSUMER_KEY = 'your_consumer_key_xxx'
CONSUMER_SECRET = 'your_consumer_key_xxx'
OAUTH_TOKEN = 'your_oauth_token_xxx'
OAUTH_TOKEN_SECRET = 'your_oauth_token_secret_xxx'
API_KEY = 'your_voice_text_api_key_xxx'
 
SPEAKER = ["haruka", "hikari", "takeru"]
begin
  client = Twitter::REST::Client.new do |config|
    config.consumer_key       = CONSUMER_KEY
    config.consumer_secret    = CONSUMER_SECRET
    config.access_token        = OAUTH_TOKEN
    config.access_token_secret = OAUTH_TOKEN_SECRET
  end

  voice_text = VoiceTextAPI.new(API_KEY)
 
  client.search("嫁 -rt", lang: "ja", result_type: "recent").take(10).each do |tweet|
    puts "#{tweet.user.screen_name}: #{tweet.text}"

    # TwitterAPIの仕様上、15分に15人までフォロー可能。それ以上フォローすると制限に引っかかるので念のためコメントアウト。
    ###  client.follow(tweet.user.id)

    speaker = SPEAKER[rand(3)]
    text = "#{tweet.text}"
 
    if /[!!]/ =~ text then
      emotion_level = 2
    else
      emotion_level = 1
    end
 
    if /[喜嬉楽幸]/ =~ text then
      emotion = "happiness"
    elsif /[悲辛苦]/ =~ text then
      emotion = "sadness"
    elsif /[怒]/ =~ text then
      emotion = "anger"
    else
      emotion = nil
    end
 
    if emotion.nil?
      wav = voice_text.tts(text, :"#{speaker}")
    else
      wav = voice_text.tts(text, :"#{speaker}", emotion: :"#{emotion}", emotion_level: emotion_level)
    end
    Open3.capture3("Users/your_directory_xxx/sox/play -", :stdin_data=>wav)
  end
 
rescue
  print "RuntimeError: ", $!, "\n";
end
