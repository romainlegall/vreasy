class MessagesController < ApplicationController

	# Twilio configuration
	$account_sid = ''
	$auth_token = ''

	# index page
	def index
		@message = Message.new
		@messages = Message.all	
		check_msgs #check status of all messages
	end
	
	# Creation of a new message
	def create
		params[:message][:ref] = SecureRandom.hex(10) #generate a new ref
		params[:message][:sid] = twilio_new_msg(params[:message][:from], params[:message][:to], params[:message][:body],  params[:message][:ref]) #call twilio_new_msg
		if params[:message][:sid].blank?
			params[:message][:status] = "fail" 
		end
		@message = Message.new(message_params)
		@message.save		
		index
	end

	private
	# params acceptable
	def message_params
		params.require(:message).permit(:from, :to, :body, :ref, :status)
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
			message.sid
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
			message.StatusCallback
			if ["Ok", "Yes", "Si"].included_in?(message.response.message)

			elsif ["No"].included_in?(message.response.message)

			else

			end
		rescue

		end
	end

	# check all messages informations
	def check_msgs
		messages = Message.all	
		messages.each do |m|
			puts m.ref
			status = get_msg_info(m.ref)
			m.status = status
			m.save
		end
	end

end
