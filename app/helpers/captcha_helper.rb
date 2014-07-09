module CaptchaHelper
  require "noisy_image.rb"

  def generate_captcha_response
    noisy_image = NoisyImage.new(8)
    noisy_code = noisy_image.code
    image = noisy_image.code_image

    response = Hash.new
    response[:image] = Base64.encode64(image)
    response[:code] = Digest::MD5.hexdigest(JSON.parse(noisy_code).join)
    response
  end

end