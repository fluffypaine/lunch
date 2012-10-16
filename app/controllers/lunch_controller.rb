class LunchController < ApplicationController
require 'rest_client'
require 'json'
require 'geocoder'
#require 'socket' 


	def index
		baseUrl = 'https://maps.googleapis.com/maps/api/place/search/json?'
		location = 'location=-33.8670522,151.1957362&'
		radius = 'radius=500&'
		name = 'name=harbour&'
		types = 'types=food&'
		sensor = 'sensor=false&'
		key = 'key=AIzaSyAfJzJIJ6R-iLp5aUFjUF4pmZYROe2JE-o'
		#url = baseUrl+location+radius+name+types+sensor+key

		listResultsLATLONG
		extraDetails
		
		 #gets the ip
		#@ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
		#@ha = request.location.country		
		#@ip = request.remote_ip		
		render
	end
	


	def listResultsLATLONG

		@url = "https://maps.googleapis.com/maps/api/place/search/json?location=53.38169,-1.480175&radius=500&types=food&sensor=true&key=AIzaSyDiogJ7G24s2Dlj7ifbSt7FaK3g3G8vNuo"
		response = RestClient.get @url
		@list = JSON.parse(response)
		
		getList
				
	end
	
	def getList
		eachResult = []
		@allResults = []
		
		@list["results"].each do |res|
			eachResult.push(res["name"])
			eachResult.push(res["vicinity"])
			eachResult.push(res["rating"])
			eachResult.push(res["geometry"]["location"]["lat"])
			eachResult.push(res["geometry"]["location"]["lng"])
			
			if (res["opening_hours"]) != nil
				eachResult.push(res["opening_hours"].values[0])
			else
				eachResult.push("")
			end
			
			@allResults.push(eachResult)
			eachResult = []
		end
		
		return @allResults

	end
	
	
	def extraDetails
		@url2 = "https://maps.googleapis.com/maps/api/place/details/json?sensor=false&reference=CnRnAAAAXETTpdZnhyTXY8SAVDgYsh-eiJ4AK8H73qzxs2kZPmkfKw4rt8_-zGQU2h3F7SVbMyzKzPfA6UktGM8buaKOyU3zX8PYYlEscX5tODlj0OZKCNFOBV0PBCBYEQEBiAz_uiL_zVPLx_Wg_Rg8UEOD7BIQdzSRQckiQCs2i57nbH42NRoU0mnMQLRzpWKr7ZqgFgwgljnf7_g&sensor=false&key=AIzaSyDiogJ7G24s2Dlj7ifbSt7FaK3g3G8vNuo"
		response2 = RestClient.get @url2
		@details = JSON.parse(response2)
		
		getLocationHours
		getAddress
		getWebsite
		getReviews
		
			
	end
	
	def getReviews
	
		eachReview = []
		@allReviews = []
		
		@details["result"]["reviews"].each do |gotit2|
			eachReview.push( gotit2["text"] )
			eachReview.push( getAspects(gotit2["aspects"]) )
			eachReview.push( gotit2["author_name"] )
			eachReview.push( (Time.at(gotit2["time"])).strftime("%m/%d/%Y") ) # gets the timestamp, converts it into a full date, gets just the m/d/y
			
			@allReviews.push(eachReview) 
			eachReview = []
		end	
		return @allReviews
	end

	
	def	getAspects(aspect)
		str = ""	
			if aspect != nil
				aspect.each do |keyss|
					str = str +"\n"+keyss.values[1].to_s+" = "+keyss.values[0].to_s
				end
			else
				return str
			end
			
			return str
	end
		
	
	def getAddress
		address = []
		
		@details["result"]["address_components"].each do |val|
			address.push( (val.values[0]) )
		end
		@fullAddress = (address.join(',')).gsub("," , ", ")
		
	end
	
	def getWebsite
		@website = @details["result"]["website"]
	end
	
	
	def getLocationHours
		@allOpenHours = []
		@allCloseHours = []
		
		@details["result"]["opening_hours"]["periods"].each do |opens|
			opens["open"].each do |o|
				if (o[1]).is_a? String
					@allOpenHours.push(o[1])
				end
			end
		
			opens["close"].each do |o|
				if (o[1]).is_a? String
					@allCloseHours.push(o[1])
				end
			end
		end
		
		@completeHours = @allOpenHours.zip(@allCloseHours)
	
	end
	
	
	
	def listResultsTEXT
		@url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants+in+sheffield&radius=500&types=food&sensor=true&key=AIzaSyDiogJ7G24s2Dlj7ifbSt7FaK3g3G8vNuo"
		response = RestClient.get @url
		@list = JSON.parse(response)		
	end
	
	
	
	
	def show
		render
	end
end
