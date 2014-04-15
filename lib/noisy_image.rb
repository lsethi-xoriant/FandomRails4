require 'RMagick'
require 'kconv'

class NoisyImage
	include Magick
	attr_reader :code, :code_image

	LINE = 3
	CIRCLE = 2
	LINE_WIDTH = 1

	FontName = nil
	FontFamily = "arial"
	Jiggle = 15
	Wobble = 15
	Shake = 5
	Expand = 10

	COLORS = ['darkred', 'indigo', 'blueviolet', 'teal', 'navy', 'darkgreen']

	def initialize(len, font_name = nil, lang = nil)
		@font_name = font_name
		@lang = lang
		canvas = Magick::ImageList.new
		@width = 32 * len
		@height = 50
		canvas.new_image(@width, @height)
		ncolor = COLORS[rand(COLORS.size)]
		acolor = (COLORS - [ncolor])[rand(COLORS.size - 1)]
		canvas = add_noise(canvas, ncolor)
		canvas = annotate(canvas, len, acolor)
		@code_image = canvas.to_blob { self.format = "JPG" }
	end

	private

	def random(n)
		rand(10) > 5 ? rand(n) : -rand(n)
	end

	def add_noise(image, color)
		image = image.add_noise(ImpulseNoise)
		draw = Draw.new
		draw.stroke = color
		draw.stroke_width = LINE_WIDTH
		draw.fill_opacity(0)
		draw = add_line(draw, LINE)
		draw = add_circle(draw, CIRCLE)
		draw.draw(image)
		image
	end

	def add_line(draw, n)
		x_base = 0
		n.times {|i|
		i += 1
		x1 = x_base * i + rand(@width / LINE)
		y1 = 0
		x2 = rand(@width)
		y2 = @height
		draw.line(x1, y1, x2, y2)
		x_base = x1
		}
		draw
	end

	def add_circle(draw, n)
		n.times {|i|
			x1 = rand(@width)
			y1 = @height + rand(@height)
			x2 = x1 + random(@width * 2)
			y2 = y1 + random(@height * 2)
			draw.circle(x1, y1, x2, y2)
		}
		draw
	end

	def annotate(image, len, color)
		chars = ('a'..'z').to_a - ['a','e','i','o','u']
		code_array=[]
		1.upto(len) {code_array << chars[rand(chars.length)]}
			text = Magick::Draw.new
			if @font_name then
			text.font = @font_name
			end
			cur = 20
			code_array.each {|c|
				rot = random(Wobble)
				rand(10) > 5 ? weight = NormalWeight : weight = BoldWeight
				text.annotate(image, 0, 0, cur, 30 + rand(Jiggle), c){
				self.pointsize = 30 + rand(Expand)
				self.rotation = rot
				self.font_weight = weight
				self.fill = color
			}
			cur += 25 + random(Shake)
		}
		@code = code_array.to_s
		image
	end
	
end