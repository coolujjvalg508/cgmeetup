ActiveAdmin.register User do
   menu label: 'Users Management', parent: 'Account', priority: 1
	permit_params :firstname, :confirmed_at, :username, :password, :is_subscribed, :subscription_end_date, :lastname,:image,:professional_headline,:email,:phone_number, :profile_type, :country_id, :city,:show_message_button, :full_time_employment, :contract , :freelance, :available_from,:summary, :demo_reel, {:skill_expertise => []}, {:software_expertise => []}, :public_email_address, :website_url, :facebook_url,
	:linkedin_profile_url,:twitter_handle,:instagram_username ,:behance_username,:tumbler_url,:pinterest_url, :youtube_url, :vimeo_url, :google_plus_url, :stream_profile_url,:professional_experiences_attributes => [:id,:company_id,:title,:location,:description, :from_month,:from_year, :to_month,:to_year,:currently_worked,:professionalexperienceable_id,:professionalexperienceable_type, :_destroy,:tmp_professionalexperience,:professionalexperience_cache], :production_experiences_attributes => [:id,:production_title,:release_year,:production_type,:your_role, :company,:productionexperienceable_id,:productionexperienceable_type, :_destroy,:tmp_productionexperience,:productionexperience_cache],

	:education_experiences_attributes => [:id,:school_name,:field_of_study,:month_val,:year_val, :description,:educationexperienceable_id,:educationexperienceable_type, :_destroy,:tmp_educationexperience,:educationexperience_cache],
	 :company_attributes => [:id,:name]



	action_item only: :edit do
		user		  	    =	User.find_by(id: params[:id])
		if(user.is_deleted == 1)
			link_to "Permit User", 'javascript:void(0);', method: :get, id: 'removebanned',title: params[:id]
		else
			link_to "Restrict User", 'javascript:void(0);', method: :get, id: 'userbanned',title: params[:id]
		end



	end

	action_item only: :edit do
		comment =	PostComment.find_by(user_id: params[:id])
		if(comment)
			link_to "Delete Comment", 'javascript:void(0);', method: :get, id: 'deletecomment',title: params[:id]
		end
	end


	collection_action :user_ban, method: :get do
		id   				=	params[:id]
		user		  	    =	User.find_by(id: id)
		user.update(is_deleted: 1)
		flash[:success] 	= "User has successfully restricted."
		render json: {message: 'ok',status: '200'}
	end

	collection_action :remove_user_ban, method: :get do
		id   				=	params[:id]
		user		  	    =	User.find_by(id: id)
		user.update(is_deleted: 0)
		flash[:success] = "User has successfully permitted."
		render json: {message: 'ok',status: '200'}
	end

	collection_action :deletecomment, method: :get do
		id   =	params[:id]
		PostComment.where(:user_id => id).destroy_all
		flash[:success] = "Comment has successfully deleted."
		render json: {message: 'ok',status: '200'}
	end


	controller do
		def action_methods
		 super
			if current_admin_user.id.to_s == '1'
			super
		  else
			usergroup  = UserGroup.where(:id => current_admin_user.group_id.to_s).first
			disallowed = []
			disallowed << 'index' if (!usergroup.has_permission('user_read') && !usergroup.has_permission('user_write') && !usergroup.has_permission('user_delete'))
			disallowed << 'delete' unless (usergroup.has_permission('user_delete'))
			disallowed << 'create' unless (usergroup.has_permission('user_write'))
			disallowed << 'new' unless (usergroup.has_permission('user_write'))
			disallowed << 'edit' unless (usergroup.has_permission('user_write'))
			disallowed << 'destroy' unless (usergroup.has_permission('user_delete'))

			super - disallowed
		  end
	end
  end




	form multipart: true do |f|

		f.inputs "Basic Details" do
		  f.input :firstname
		  f.input :lastname
		  f.input :username
		   f.input :profile_type, as: :select, collection: User::PROFILE_TYPE, include_blank: false, label: 'Profile Type'
		  #f.input :group_id, as: :select, collection:  UserGroup.where("name != '' ").pluck(:name, :id),include_blank:'Select Group'
		  f.input :password
		  f.input :image
		  f.input :professional_headline
		  f.input :email
		  f.input :phone_number

		  f.input :country_id, as: :select, collection: Country.active.pluck(:name,:id), include_blank: 'Select Country', label: 'Country'
		  f.input :city

		  f.inputs "Contact Information" do
			  f.input :show_message_button, as: :select, collection: [['Yes',1],['No',0]], include_blank: false, label: 'Show Message Button'
			  f.input :full_time_employment, as: :boolean,label: "Full-time employment"
			  f.input :contract, as: :boolean,label: "Contract"
			  f.input :freelance, as: :boolean,label: "Freelance"
			  f.input :available_from, as: :date_time_picker

		 end
     f.inputs "Subscription Detail" do
       f.input :is_subscribed, label: "Status ", as: :select, collection: [['On',true], ['Off', false]], include_blank: false
       f.input :subscription_end_date, as: :date_time_picker
     end
		 f.inputs "Professional Summary" do
			  f.input :summary

		 end
		 f.inputs "Demo Reel" do
			  f.input :demo_reel

		 end

		 f.inputs "Professional Experience" do
			 f.has_many :professional_experiences, allow_destroy: true, new_record: true do |ff|
				  ff.input :company_id, as: :select, collection: Company.where("name != '' ").pluck(:name, :id),include_blank:'Select Company Name'
				  ff.input :title
				  ff.input :location
				  ff.input :description
				  ff.input :from_month, as: :select, collection: User::MONTH_VALUE , include_blank: false, label: 'From Month'
				  ff.input :from_year
				  ff.input :to_month, as: :select, collection: User::MONTH_VALUE , include_blank: false, label: 'To Month'
				  ff.input :to_year
				  ff.input :currently_worked, as: :check_boxes, collection:[['Yes',1]]
				 # ff.input :professionalexperience_cache, :as => :hidden

				end
		 end

		f.inputs "Production Experience" do
			 f.has_many :production_experiences, allow_destroy: true, new_record: true do |ff|
				  ff.input :production_title
				  ff.input :release_year
				  ff.input :production_type, as: :select, collection: User::PRODUCTION_TYPE, include_blank: false, label: 'Production Type'
				  ff.input :your_role
				  ff.input :company
				 # ff.input :productionexperience_cache, :as => :hidden

			 end

		end

		f.inputs "Education Experience" do
			 f.has_many :education_experiences, allow_destroy: true, new_record: true do |ff|
				  ff.input :school_name
				  ff.input :field_of_study
				  ff.input :month_val, as: :select, collection: User::MONTH_VALUE , include_blank: false, label: 'Expected Graduation Month'
				  ff.input :year_val, label: 'Expected Graduation Year'
				  ff.input :description
				 # ff.input :educationexperience_cache, :as => :hidden
			 end
		 end

		f.inputs "Skill" do

			 f.input :skill_expertise, as: :select, collection: JobSkill.where("id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" },multiple: true, include_blank: false, label: 'Skill Expertise'
			 f.input :software_expertise, as: :select, collection: SoftwareExpertise.where("id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: true,label: 'Software Expertise'


		 end

		      f.inputs "Contact & Social Media" do
			  f.input :public_email_address,label: 'Public Email Address'
			  f.input :website_url,label: 'Website URL'
			  f.input :facebook_url,label: 'Facebook Page URL'
			  f.input :linkedin_profile_url,label: 'linkedin Profile URL'
			  f.input :twitter_handle,label: 'Twitter Handle'
			  f.input :instagram_username,label: 'Instagram Username'
			  f.input :behance_username,label: 'Behance Username'
			  f.input :tumbler_url,label: 'Tumblr URL'
			  f.input :pinterest_url,label: 'Pinterest URL'
			  f.input :youtube_url,label: 'Youtube URL'
			  f.input :vimeo_url,label: 'Vimeo URL'
			  f.input :google_plus_url,label: 'Google Plus URL'
			  f.input :stream_profile_url,label: 'Steam Profile URL'

		 end

	 end

	f.actions
  end



   controller do
	  def create
	  	  #@current_Time = DateTime.now
  			#@current_Time = @current_time.strftime("%Y-%m-%d %H:%M")

  			#abort(@current_Time.to_json)
      # if subscription is switched off then subscription end date should be nil
      if params[:user][:is_subscribed] == "false"
          params[:user][:subscription_end_date] = nil
      end
	  	params[:user][:confirmed_at] = DateTime.now
	  	#abort(params[:user][:confirmed_at].to_json)
			if (params[:user].present? && params[:user][:professional_experiences_attributes].present?)
					params[:user][:professional_experiences_attributes].each do |index,img|
						  unless params[:user][:professional_experiences_attributes][index][:title].present?
								params[:user][:professional_experiences_attributes][index][:company_id] = params[:user][:professional_experiences_attributes][index][:company_id]
								params[:user][:professional_experiences_attributes][index][:title] = params[:user][:professional_experiences_attributes][index][:title]
								params[:user][:professional_experiences_attributes][index][:location] = params[:user][:professional_experiences_attributes][index][:location]
								params[:user][:professional_experiences_attributes][index][:description] = params[:user][:professional_experiences_attributes][index][:description]
								params[:user][:professional_experiences_attributes][index][:from_month] = params[:user][:professional_experiences_attributes][index][:from_month]
								params[:user][:professional_experiences_attributes][index][:to_month] = params[:user][:professional_experiences_attributes][index][:to_month]
								params[:user][:professional_experiences_attributes][index][:to_year] = params[:user][:professional_experiences_attributes][index][:to_year]
								params[:user][:professional_experiences_attributes][index][:currently_worked] = params[:user][:professional_experiences_attributes][index][:currently_worked]
						  end

					end
				super

			elsif (params[:user].present? && params[:user][:production_experiences_attributes].present?)
					params[:user][:production_experiences_attributes].each do |index,img|
						  unless params[:user][:production_experiences_attributes][index][:production_title].present?
								params[:user][:production_experiences_attributes][index][:production_title] = params[:user][:production_experiences_attributes][index][:production_title]
								params[:user][:production_experiences_attributes][index][:release_year] = params[:user][:production_experiences_attributes][index][:release_year]
								params[:user][:production_experiences_attributes][index][:production_type] = params[:user][:production_experiences_attributes][index][:production_type]
								params[:user][:production_experiences_attributes][index][:your_role] = params[:user][:production_experiences_attributes][index][:your_role]
								params[:user][:production_experiences_attributes][index][:description] = params[:user][:production_experiences_attributes][index][:company]

						  end

					end
				super


			elsif (params[:user].present? && params[:user][:education_experiences_attributes].present?)
					params[:user][:education_experiences_attributes].each do |index,img|
						  unless params[:user][:education_experiences_attributes][index][:school_name].present?
								params[:user][:education_experiences_attributes][index][:school_name] = params[:user][:education_experiences_attributes][index][:school_name]
								params[:user][:education_experiences_attributes][index][:field_of_study] = params[:user][:education_experiences_attributes][index][:field_of_study]
								params[:user][:education_experiences_attributes][index][:month_val] = params[:user][:education_experiences_attributes][index][:month_val]
								params[:user][:education_experiences_attributes][index][:year_val] = params[:user][:education_experiences_attributes][index][:year_val]
								params[:user][:education_experiences_attributes][index][:description] = params[:user][:education_experiences_attributes][index][:description]

						  end

					end
				super


		 else
				super
		  end
		end

		def update
		# abort(params.to_json)
      # if subscription is switched off then subscription end date should be nil
      if params[:user][:is_subscribed] == "false"
          params[:user][:subscription_end_date] = nil
      end
  	  if params[:user][:password].blank?
          params[:user].delete("password")
      end
			if (params[:user].present? && params[:user][:professional_experiences_attributes].present?)
					params[:user][:professional_experiences_attributes].each do |index,img|
						  unless params[:user][:professional_experiences_attributes][index][:title].present?
							params[:user][:professional_experiences_attributes][index][:company_id] = params[:user][:professional_experiences_attributes][index][:company_id]
							params[:user][:professional_experiences_attributes][index][:title] = params[:user][:professional_experiences_attributes][index][:title]
							params[:user][:professional_experiences_attributes][index][:location] = params[:user][:professional_experiences_attributes][index][:location]
							params[:user][:professional_experiences_attributes][index][:description] = params[:user][:professional_experiences_attributes][index][:description]
							params[:user][:professional_experiences_attributes][index][:from_month] = params[:user][:professional_experiences_attributes][index][:from_month]
							params[:user][:professional_experiences_attributes][index][:to_month] = params[:user][:professional_experiences_attributes][index][:to_month]
							params[:user][:professional_experiences_attributes][index][:to_year] = params[:user][:professional_experiences_attributes][index][:to_year]
							params[:user][:professional_experiences_attributes][index][:currently_worked] = params[:user][:professional_experiences_attributes][index][:currently_worked]
						  end
						 # abort(params.to_json)
					end
				super

			elsif (params[:user].present? && params[:user][:production_experiences_attributes].present?)
					params[:user][:production_experiences_attributes].each do |index,img|
						  unless params[:user][:production_experiences_attributes][index][:production_title].present?
							params[:user][:production_experiences_attributes][index][:production_title] = params[:user][:production_experiences_attributes][index][:production_title]
							params[:user][:production_experiences_attributes][index][:release_year] = params[:user][:production_experiences_attributes][index][:release_year]
							params[:user][:production_experiences_attributes][index][:production_type] = params[:user][:production_experiences_attributes][index][:production_type]
							params[:user][:production_experiences_attributes][index][:your_role] = params[:user][:production_experiences_attributes][index][:your_role]
							params[:user][:production_experiences_attributes][index][:description] = params[:user][:production_experiences_attributes][index][:company]

						  end
					end
				super


			elsif (params[:user].present? && params[:user][:education_experiences_attributes].present?)
					params[:user][:education_experiences_attributes].each do |index,img|
						  unless params[:user][:education_experiences_attributes][index][:school_name].present?
							params[:user][:education_experiences_attributes][index][:school_name] = params[:user][:education_experiences_attributes][index][:school_name]
							params[:user][:education_experiences_attributes][index][:field_of_study] = params[:user][:education_experiences_attributes][index][:field_of_study]
							params[:user][:education_experiences_attributes][index][:month_val] = params[:user][:education_experiences_attributes][index][:month_val]
							params[:user][:education_experiences_attributes][index][:year_val] = params[:user][:education_experiences_attributes][index][:year_val]
							params[:user][:education_experiences_attributes][index][:description] = params[:user][:education_experiences_attributes][index][:description]
					end

					end

				super


		 else
				super
		  end

		end

  end



  filter :firstname
  filter :username
  filter :email
  filter :profile_type, as: :select, collection: [['Artist','Artist'],['Recruiter','Recruiter'],['Studio','Studio']], label: 'Profile Type'
  filter :is_deleted, as: :select, collection: [['Banned',1],['Not Banned',0]], label: 'Banned User'
  filter :profile_type, as: :select, collection: [['Artist',1],['Recruiter',2],['Studio',3]], label: 'Profile Type'
  filter :created_at


    # Users List View
  index :download_links => ['csv'] do
	   selectable_column
	    column 'Image' do |img|
		  image_tag img.try(:image).try(:url, :thumb), height: 50, width: 50
		end
	    column 'First Name' do |fname|
		 fname.firstname
	    end
	    column 'Last Name' do |lname|
		 lname.lastname
	   end
	   column 'User Name' do |uname|
		 uname.username
	   end
	   column 'Profile Type' do |fname|
	 	 fname.profile_type
	    end
	   column 'Email' do |email|
		  email.email
	   end
	   column 'Country' do |user|
			user.try(:country).try(:name)

	   end
	   column 'City' do |city|
		  city.city
	   end

	   column 'Banned' do |ub|
		  (ub.is_deleted == 1) ? 'YES' : 'NO'
	   end

	   column 'Restrict/Permit' do |user|

		if(user.is_deleted == 1)

			link_to "Permit User", 'javascript:void(0);', method: :get, id: 'removebanned',title: user.id
		else
			link_to "Restrict User", 'javascript:void(0);', method: :get, id: 'userbanned',title: user.id
		end
	   end

		actions
  end


   show do
    attributes_table do
      row :firstname
      row :lastname
      row 'User Name' do |uname|
		    uname.username
	  end

  	  row 'Profile Type' do |fname|
  		 fname.profile_type
  	  end
      row 'Subscription Status' do |s|
        s.is_subscribed ? 'On' : 'Off'
      end
      row :subscription_end_date
      row :email
      row :professional_headline
      row :phone_number
      row :demo_reel
      row 'Country' do |user|
  			user.try(:country).try(:name)
  	  end
      row :city
      row 'Banned' do |ub|
  	     (ub.is_deleted == 1) ? 'YES' : 'NO'
  	  end

      row :image do |cat|
        unless !cat.image.present?
          image_tag(cat.try(:image).try(:url, :event_small))
        else
          image_tag('/assets/default-blog.png', height: '50', width: '50')
        end
      end
      row :created_at
    end
  end





# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


end
