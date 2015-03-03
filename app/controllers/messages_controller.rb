class MessagesController < ApplicationController

	# Twilio configuration
	$account_sid = 'ACb88d7015c3b1d42a1343125b0ab21508'
	$auth_token = '14136e72b550b54502adc9612e7b1bec'

	# index page
	def index
		@message = Message.new
		@messages = Message.all	
	end
	
	# Creation of a new message
	def create
		params[:message][:ref] = SecureRandom.hex(10) #generate a new ref
		result = twilio_new_msg(params[:message][:from], params[:message][:to], params[:message][:body], params[:message][:ref]) #call twilio_new_msg
		params[:message][:sid] = result[0] unless result.blank?
		puts params[:message][:status] = result[1] unless result.blank?
		@message = Message.new(message_params)
		@message.save		
		index
	end
	

	# check all messages informations
	def check_msgs
		messages = Message.all	
		messages.each do |m|
			status = get_msg_info(m.sid)
			m.status = status unless status=="Error" and m.status != "Error"
			m.save
		end
	end

	private
	# params acceptable
	def message_params
		params.require(:message).permit(:from, :to, :body, :ref, :status, :sid)
	end	

	#twilio calling for new message
	def twilio_new_msg(p_from, p_to, p_body, p_ref)
		begin
			client = Twilio::REST::Client.new $account_sid, $auth_token
			 
			message = client.account.messages.create(
				:body => p_body,
			    :to => p_to,     
			    :from => p_from,
			   	:media_url => "http://localhost:3000/#{p_ref}"
			   ) 
			return [message.sid, message.status]
		rescue

		end
	end

	#twilio calling for get info of a message
	def get_msg_info(sid)

		begin
			# Get your Account Sid and Auth Token from twilio.com/user/account
			client = Twilio::REST::Client.new $account_sid, $auth_token
			 
			# Get an object from its sid. If you do not have a sid,
			# check out the list resource examples on this page
			message = client.account.messages.get(sid)
			if  message.response.message.downcase.split.include?("yes") or message.downcase.response.message.split.include?("si") or message.downcase.response.message.split.include?("ok")
				status = "accepted"
			elsif  message.response.message.downcase.split.include?("no") 
				status = "refused"
			else
				status = "Unknown"
			end
			return status
		rescue
			return "Error"
		end
	end

end
