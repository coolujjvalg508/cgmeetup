module ApplicationHelper
	
	#The below method is for display error messages next to field (ActiveModel validation messages)
	def form_error_msg_for(model_obj, field_name, field_name_as=nil)
		begin
			field_name_as ||= field_name
			if model_obj.errors.present? && model_obj.errors[field_name.to_sym].present?
				"<div class='error-msg'>#{field_name_as.to_s.humanize+' '+model_obj.errors.messages[field_name.to_sym].first}</div>".html_safe
			end
		rescue Exception => e
			""
		end
	end

	def error_message(object, field)

		if object.errors.present? && object.errors.messages.present?
			if object.is_a?(User) && object.errors.messages[field.to_sym].present?
				if field.to_s == "email" && object.errors.messages[field.to_sym].include?("Email can't be blank")
					err_msg = "<div class='error-msg'>Email can't be blank</div>"
					return err_msg.html_safe
				elsif field.to_s == "username" && object.errors.messages[field.to_sym].include?("can't be blank")
					err_msg = "<div class='error-msg'>Username can't be blank</div>"
					return err_msg.html_safe		
				elsif field.to_s == "firstname" && object.errors.messages[field.to_sym].include?("can't be blank")
					err_msg = "<div class='error-msg'>First name can't be blank</div>"
					return err_msg.html_safe	
				elsif field.to_s == "lastname" && object.errors.messages[field.to_sym].include?("can't be blank")
					err_msg = "<div class='error-msg'>last name can't be blank</div>"
					return err_msg.html_safe		
				elsif field.to_s == "email" && object.errors.messages[field.to_sym].include?("Please enter a valid email")
					err_msg = "<div class='error-msg'>Please enter a valid email</div>"
					return err_msg.html_safe
				elsif field.to_s == "email" && object.errors.messages[field.to_sym].include?("has already been taken")
					err_msg = "<div class='error-msg'>Email has already been taken</div>"
					return err_msg.html_safe
				elsif field.to_s == "email" && object.errors.messages[field.to_sym].include?("not found")
				err_msg = "<div class='error-msg'>Email not found</div>"
				return err_msg.html_safe
				elsif field.to_s == "email_confirmation" && object.errors.messages[field.to_sym].include?("doesn't match Email")
					err_msg = "<div class='error-msg'>Email confirmation doesn't match</div>"
					return err_msg.html_safe
				elsif field.to_s == "password" && object.errors.messages[field.to_sym].include?("can't be blank")
					err_msg = "<div class='error-msg'>Password can't be blank</div>"
					return err_msg.html_safe
				elsif field.to_s == "password" && object.errors.messages[field.to_sym].include?("is too short (minimum is 6 characters)")
					err_msg = "<div class='error-msg'>Password can't be less then 6 characters</div>"
					return err_msg.html_safe
				elsif field.to_s == "password_confirmation" && object.errors.messages[field.to_sym].include?("doesn't match Password")
					err_msg = "<div class='error-msg'>Password confirmation doesn't match</div>"
					return err_msg.html_safe
				else
					err_msg = "<div class='error-msg'>" + object.errors.messages[field.to_sym].try(:first).to_s + "</div>"
					return err_msg.html_safe
				end
			else
				err_msg = "<div class='error-msg'>" + object.errors.messages[field.to_sym].try(:first).to_s + "</div>"
				return err_msg.html_safe
			end
		else
			return nil
		end
	end

	
	def format_time(time)
		begin
			time.strftime("%m/%d/%Y %I:%M%p")
		rescue Exception => e
			""
		end
	end

	def format_date(date)
		begin
			date.strftime("%m/%d/%Y")
		rescue Exception => e
			""
		end
	end

	## Mailboxer conversations
	def has_attachment?(conversation)
		return false unless conversation.is_a?(Mailboxer::Conversation)
    status = false
    conversation.messages.each do |message|
      if message.attachment?
        status = true
        break
      end
    end
    return status    
	end

	def last_message_from(conversation,user)		
		return "" unless conversation.is_a?(Mailboxer::Conversation)
		receipt = conversation.receipts.sentbox.where.not(receiver_type: user.class.name, receiver_id: user.try(:id)).last
		receipt.try(:receiver).try(:name).to_s
	end

	def last_message_to(conversation,user)		
		return "" unless conversation.is_a?(Mailboxer::Conversation)
		receipt = conversation.receipts.inbox.where.not(receiver_type: user.class.name,receiver_id: user.try(:id)).last
		receipt.try(:receiver).try(:name).to_s
	end

	#Active admin helper methods
	def message_time_format(time)
		begin
			time.in_time_zone("Mumbai").strftime("%m/%d/%Y %I:%M%p")
		rescue Exception => e
			""
		end
	end

	def asset_data_base64(path)
	  asset = Rails.application.assets.find_asset(path)
	  throw "Could not find asset '#{path}'" if asset.nil?
	  base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
	  "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
	end
	
	def resource_name
		:user
	end

	def resource
		@resource ||= User.new
	end

	def devise_mapping
		@devise_mapping ||= Devise.mappings[:user]
	end

	def get_random_one_questionaire
		Questionaire.order('random()').first
	end

	def get_previous_uploaded_gallery_tags

		previous_gallery = Gallery.where("user_id = ? AND is_admin = 'N'", current_user.id).order('id DESC').first

		#abort(previous_gallery.to_json)

		tags = []

		if previous_gallery.present?
			if previous_gallery.tags.present?

				previous_gallery.tags.each_with_index do |tag, i|
					#abort(tag['tag'].to_json)

					tags[i] = tag['tag']

				end

			end
		end
		return tags
		#abort(tags.to_json)

	end

	def get_previous_uploaded_job_tags

		previous_job = Job.where("user_id = ? AND is_admin = 'N'", current_user.id).order('id DESC').first
		tags = []

		if previous_job.present?
			if previous_job.tags.present?

				previous_job.tags.each_with_index do |tag, i|
					#abort(tag['tag'].to_json)

					tags[i] = tag['tag']

				end

			end
		end
		return tags

	end	

	def get_previous_uploaded_download_tags

		previous_download = Download.where("user_id = ? AND is_admin = 'N'", current_user.id).order('id DESC').first
		tags = []
		if previous_download.present?
			if previous_download.tags.present?
				previous_download.tags.each_with_index do |tag, i|
					tags[i] = tag['tag']
				end
			end
		end
		return tags

	end

	def get_previous_uploaded_tutorial_tags

		previous_tutorial = Tutorial.where("user_id = ? AND is_admin = 'N'", current_user.id).order('id DESC').first
		tags = []
		if previous_tutorial.present?
			if previous_tutorial.tags.present?
				previous_tutorial.tags.each_with_index do |tag, i|
					tags[i] = tag['tag']
				end
			end
		end
		return tags

	end


	def get_previous_uploaded_news_tags

		previous_news = News.where("user_id = ? AND is_admin = 'N'", current_user.id).order('id DESC').first
		tags = []
		if previous_news.present?
			if previous_news.tags.present?
				previous_news.tags.each_with_index do |tag, i|
					tags[i] = tag['tag']
				end
			end
		end
		return tags

	end



	def connection_like_count()		
		 
		 follower         = Follow.where('artist_id = ?', current_user.id).count
         following        = Follow.where('user_id = ?', current_user.id).count
         like       	  = PostLike.where('user_id = ?', current_user.id).count
         myartworklike    = PostLike.where('artist_id = ?', current_user.id).count
       
         res 			  =	{'follower':follower, 'following':following, 'like':like, 'myartworklike':myartworklike} 
         return res
	end


	def connection_like_count_by_artist_id(artist_id)		
		 
		 follower         = Follow.where('artist_id = ?', artist_id).count
         following        = Follow.where('user_id = ?', artist_id).count
         like       	  = PostLike.where('user_id = ?', artist_id).count
         myartworklike    = PostLike.where('artist_id = ?', artist_id).count
       
         res 			  =	{'follower':follower, 'following':following, 'like':like, 'myartworklike':myartworklike} 
         return res
	end

	def notification_data

		final_data = []
		notification_list  = Notification.where(artist_id: current_user.id).order('id desc').limit(5)
		notification_count = Notification.where(artist_id: current_user.id, is_read: 0).count
		final_data[0] 	   = notification_list
		final_data[1] 	   = notification_count
		return final_data

	end

	def get_artist_info(artist_username)

		artist_data  = User.where(username: artist_username).first
		return artist_data

	end
		

end

