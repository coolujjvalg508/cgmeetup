ActiveAdmin.register Download do

	menu false
	#menu label: 'Download' , parent: 'Downloads'
    
    permit_params :title, :unit, :has_adult_content, :license_type, :license_custom_info, :file_format_id, :paramlink, :product_id, :topic, :is_feature, :user_id,:is_admin, :changelog, {:challenge => []} , {:post_type_id => []}, {:post_type_category_id => []}, {:sub_category_id => []},  :schedule_time, :description, {:software_used => []} , :tags, :status, :free,  :is_paid, :price, :is_save_to_draft, :visibility, :publish, :company_logo, :sub_title, :user_title, :animated, :rigged, :lowpoly, :geometry, :polygon, :vertice, :texture, :material, :uv_mapping, :unwrapped_uv, :plugin_used, {:where_to_show => []} , :images_attributes => [:id,:image,:caption_image,:imageable_id,:imageable_type, :_destroy,:tmp_image,:image_cache], :videos_attributes => [:id,:video,:caption_video,:videoable_id,:videoable_type, :_destroy,:tmp_image,:video_cache], :upload_videos_attributes => [:id,:uploadvideo,:caption_upload_video,:uploadvideoable_id,:uploadvideoable_type, :_destroy,:tmp_image,:uploadvideo_cache], :sketchfebs_attributes => [:id,:sketchfeb,:sketchfebable_id,:sketchfebable_type, :_destroy,:tmp_sketchfeb,:sketchfeb_cache], :marmo_sets_attributes => [:id,:marmoset,:marmosetable_id,:marmosetable_type, :_destroy,:tmp_marmoset,:marmoset_cache],  :zip_files_attributes => [:id,:zipfile, :zipfileable_id,:zipfileable_type, :_destroy,:tmp_zipfile,:zipfile_cache,:zip_caption,{:software => []},{:software_version => []},{:renderer => []},{:renderer_version => []}],:tags_attributes => [:id,:tag,:tagable_id,:tagable_type, :_destroy,:tmp_tag,:tag_cache]
		
		
	collection_action :post_types, method: :get do
		ids		 =	params[:id]
		category = PostTypeCategory.where("parent_id IS NULL AND post_type_id IN (?)", ids).order('name asc').pluck(:name, :id)
		render json: category, status: 200
	end
	
	collection_action :post_category_types, method: :get do
		ids		 =	params[:id]
		category = PostTypeCategory.where('parent_id IN (?)', ids).order('name asc').pluck(:name, :id)
		render json: category, status: 200
	end
		
		
	controller do 

		def action_methods
		  super                                  
				if current_admin_user.id.to_s == '1'
					super
		  else
				usergroup = UserGroup.where(:id => current_admin_user.group_id.to_s).first
				disallowed = []
				disallowed << 'index' if (!usergroup.has_permission('download_read') && !usergroup.has_permission('download_write') && !usergroup.has_permission('download_delete'))
				disallowed << 'delete' unless (usergroup.has_permission('download_delete'))
				disallowed << 'create' unless (usergroup.has_permission('download_write'))
				disallowed << 'new' unless (usergroup.has_permission('download_write'))
				disallowed << 'edit' unless (usergroup.has_permission('download_write'))
				disallowed << 'destroy' unless (usergroup.has_permission('download_delete'))
			
				super - disallowed
		  end
		end
	  end
	
		
	form multipart: true do |f|
		
		f.inputs "Download" do
		  f.input :title
		  f.input :paramlink
		   / li do
			insert_tag(Arbre::HTML::Label, "Description", class: "label") { content_tag(:abbr, "*", title: "required") }
			f.bootsy_area :description, :rows => 15, :cols => 15, editor_options: { html: true }
		  end /
		 
		  div do
			f.input :description,  :input_html => { :class => "tinymce" }, :rows => 40, :cols => 50 ,label: false
		  end
		  
		  
		  f.input :post_type_id, as: :select, collection: PostType.where("parent_id IS NULL").pluck(:type_name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: true ,label: 'Post Type'
		  
		  f.input :post_type_category_id, as: :select, collection: PostTypeCategory.where("parent_id IS NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: true ,label: 'Category'
		
		  f.input :sub_category_id, as: :select, collection: PostTypeCategory.where("parent_id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: true ,label: 'Sub Category'
		 
		  f.input :software_used, as: :select, collection: SoftwareExpertise.where("id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: true 

		  f.input :file_format_id, as: :select, collection: FileFormat.where("id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: false 
		  # f.input :tags, label:'Tags'
		 
		  f.input :free, as: :boolean,label: "Share for free"
		  f.input :price, label: "Price ($)" 
		  #f.input :is_paid, as: :boolean,label: "Is Paid"
		  f.input :is_feature, as: :boolean,label: "Is Feature"
		  f.input :has_adult_content, as: :boolean,label: "Has Adult Content"
		 
		  
		  
		  f.input :status, as: :select, collection: [['Active',1], ['Inactive', 0]], include_blank: false
		  f.input :is_save_to_draft, as: :select, collection: [['Yes',1], ['No', 0]], include_blank: false, label: 'Save Draft'
		  f.input :visibility, as: :select, collection: [['Private',1], ['Public', 0]], include_blank: false
		  f.input :publish, as: :select, collection: [['Immediately',1], ['Schedule', 0]], include_blank: false
		  
		  f.input :schedule_time, as: :date_time_picker
		  f.input :company_logo,label: "Custom Thumbnail"
		  f.input :changelog,label: "Changelog"
		  f.input :challenge, as: :select, collection: Challenge.where("challenge_type_id = 2").pluck(:title, :id), :input_html => { :class => "chosen-input" }, include_blank: false, multiple: true
		
		  f.input :license_type, as: :select, collection: Download::LICENSE_TYPE, :input_html => { :class => "chosen-input1", :id => "license_type_dropdown_download" }, include_blank: false, multiple: false

		   f.input :license_custom_info, as: :text
		     f.input :show_on_cgmeetup, as: :boolean,label: "Show On CGmeetup"
		  f.input :show_on_website, as: :boolean,label: "Show On Website"
		   f.inputs 'Tags' do
			f.has_many :tags, allow_destroy: true, new_record: true do |ff|
			  ff.input :tag
			 # ff.input :tag_cache, :as => :hidden
			end 
		  end	
		
		  f.inputs 'Images' do
			f.has_many :images, allow_destroy: true, new_record: true do |ff|
			  ff.input :image, label: "Image", hint: ff.template.image_tag(ff.object.image.try(:url,:thumb))
			  ff.input :image_cache, :as => :hidden
			  ff.input :caption_image
			end 
		  end	 
		  
		  f.inputs 'Add Video' do
			f.has_many :videos, allow_destroy: true, new_record: true do |ff|
			  ff.input :video, label: "Video"
			  ff.input :caption_video
			end
		  end	
		  
		 f.inputs 'Upload Video' do
			f.has_many :upload_videos, allow_destroy: true, new_record: true do |ff|
			  ff.input :uploadvideo, label: "Video", hint: ff.template.video_tag(ff.object.uploadvideo.try(:url), :size => "150x150")
			  ff.input :uploadvideo_cache, :as => :hidden
			  ff.input :caption_upload_video
			end
		 end	
		 
		 f.inputs 'Sketchfeb' do
			f.has_many :sketchfebs, allow_destroy: true, new_record: true do |ff|
			  ff.input :sketchfeb, label: "Sketchfeb"
			end
		  end	
		
		f.inputs 'Marmoset' do
			f.has_many :marmo_sets, allow_destroy: true, new_record: true do |ff|
			  ff.input :marmoset, label: "Marmoset", hint: ff.template.video_tag(ff.object.marmoset.try(:url), :size => "150x150")
			  ff.input :marmoset_cache, :as => :hidden
			end
		 end	
		 
		  	f.inputs '3D Model Details' do
				f.input :animated,label: "Animated"
				f.input :rigged,label: "Rigged"
				f.input :lowpoly,label: "Lowpoly (game-ready)"
				f.input :geometry,label: "Geometry", as: :select, collection: Download::GEOMETRY, include_blank: '---Choose geometry---'
				f.input :polygon,label: "Polygon"
				f.input :vertice,label: "vertice"
				f.input :unit, as: :select, collection: Download::UNIT_VALUE, :input_html => { :class => "chosen-input1"}, include_blank: '---Select Unit---', multiple: false
				f.input :texture,label: "Textures"
				f.input :material,label: "Material"
				f.input :uv_mapping,label: "UV Mapping"
				f.input :unwrapped_uv,label: "Unwrapped UVs", as: :select, collection: Download::UNWRAPPED_UV, include_blank: '---Select Unwrapped UVs---'
				f.input :plugin_used,label: "Plugins used"
		  	end	 

		 
		 f.inputs 'Upload Zip/Rar files' do
			f.has_many :zip_files, allow_destroy: true, new_record: true do |ff|
			  ff.input :zipfile, label: "Zip/Rar file", hint: ff.object.zipfile.try(:url)
			  ff.input :zipfile_cache, :as => :hidden
			  ff.input :zip_caption, label: "Caption"
			 
			 

			 ff.input :software, as: :select, collection: SoftwareExpertise.where("id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: true 
		      
			  ff.input :software_version, as: :select, collection: [], :input_html => { :class => "form-control js-example-tags" }, include_blank: false,multiple: true
			  #ff.input :software_version, as: :string


			  ff.input :renderer, as: :select, collection: Renderer.where("id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: true 
			 
			 ff.input :renderer_version, as: :select, collection: [], :input_html => { :class => "form-control js-example-tags" }, include_blank: false,multiple: true
			# ff.input :renderer_version, as: :string
			 
			

			end

		 end	
		 
		 
		 		 
		
	 end
		
		
	f.actions
  end
  
   controller do
	  def create
	  	
	  	
			params[:download][:user_id] = current_admin_user.id.to_s
			params[:download][:is_admin] = 'Y'

			
			random_password 			   = get_rendom_password
			params[:download][:product_id] = random_password

			if params[:download][:free] == '1'
				params[:download][:price] = 0
			end
				
			if params[:download][:license_type] != 'Custom'
				params[:download][:license_custom_info] = ''
			end


			#abort(params.to_json)
			
			if (params[:download].present? && params[:download][:images_attributes].present?)
					params[:download][:images_attributes].each do |index,img|
						  unless params[:download][:images_attributes][index][:image].present?
							params[:download][:images_attributes][index][:image] = params[:download][:images_attributes][index][:image_cache]
							params[:download][:images_attributes][index][:caption_image] = params[:download][:images_attributes][index][:caption_image]
						  end
					end
				super
			
			elsif (params[:download].present? && params[:download][:videos_attributes].present?)
					params[:download][:videos_attributes].each do |index,img|
						  unless params[:download][:videos_attributes][index][:video].present?
							params[:download][:videos_attributes][index][:video] = params[:download][:videos_attributes][index][:video_cache]
							params[:download][:videos_attributes][index][:caption_video] = params[:download][:videos_attributes][index][:caption_video]
						  end
					end
				super
				
				
			elsif (params[:download].present? && params[:download][:upload_videos_attributes].present?)
					params[:download][:upload_videos_attributes].each do |index,img|
						  unless params[:download][:upload_videos_attributes][index][:uploadvideo].present?
							params[:download][:upload_videos_attributes][index][:uploadvideo] = params[:download][:upload_videos_attributes][index][:uploadvideo_cache]
							params[:download][:upload_videos_attributes][index][:caption_upload_video] = params[:download][:upload_videos_attributes][index][:caption_upload_video]
						  end
					end
				super	
				
				
			elsif (params[:download].present? && params[:download][:sketchfebs_attributes].present?)
					params[:download][:sketchfebs_attributes].each do |index,img|
						  unless params[:download][:sketchfebs_attributes][index][:sketchfeb].present?
							params[:download][:sketchfebs_attributes][index][:sketchfeb] = params[:download][:sketchfebs_attributes][index][:sketchfeb_cache]
						  end
					end
				super
				
			elsif (params[:download].present? && params[:download][:marmosets_attributes].present?)
					params[:download][:marmosets_attributes].each do |index,img|
						  unless params[:download][:marmosets_attributes][index][:marmoset].present?
							params[:download][:marmosets_attributes][index][:marmoset] = params[:download][:marmosets_attributes][index][:marmoset_cache]
						  end
					end
				super
				
  		elsif (params[:download].present? && params[:download][:zip_files_attributes].present?)
					params[:download][:zip_files_attributes].each do |index,img|
						  unless params[:download][:zip_files_attributes][index][:zipfile].present?
							params[:download][:zip_files_attributes][index][:zipfile] = params[:download][:zip_files_attributes][index][:zipfile_cache]							
							params[:download][:zip_files_attributes][index][:zip_caption] = params[:download][:zip_files_attributes][index][:zip_caption]							
												
						  end

						params[:download][:zip_files_attributes][index][:software] = params[:download][:zip_files_attributes][index][:software]

				 		params[:download][:zip_files_attributes][index][:software_version] = params[:download][:zip_files_attributes][index][:software_version].to_json

				  		params[:download][:zip_files_attributes][index][:renderer] = params[:download][:zip_files_attributes][index][:renderer]

				  		params[:download][:zip_files_attributes][index][:renderer_version] = params[:download][:zip_files_attributes][index][:renderer_version].to_json
					#	params[:download][:zip_files_attributes][index][:zip_caption] = params[:download][:zip_files_attributes][index][:zip_caption]
	  
					end
			super
				
				
		  else
				super
		  end
		end


	
   		def get_rendom_password
			random_password = ([*'A'..'Z'] + [*'a'..'z'] + [*'0'..'9']).shuffle.take(10).join
   			result 			= Download.where('product_id = ?', random_password).count

            if result == 0
                return random_password
            else
                
                get_rendom_password
            end  


   		end	

		def update
		#abort(params.to_json)
			
			if params[:download][:free] == '1'
				params[:download][:price] = 0
			end
			
			
			if params[:download][:license_type] != 'Custom'
				params[:download][:license_custom_info] = ''
			end

			

			#random_password = Array.new(10).map { (65 + rand(58)).chr }.join

			if (params[:download].present? && params[:download][:images_attributes].present?)
					params[:download][:images_attributes].each do |index,img|
						  unless params[:download][:images_attributes][index][:image].present?
							params[:download][:images_attributes][index][:image]  = params[:download][:images_attributes][index][:image_cache]
						  end
					params[:download][:images_attributes][index][:caption_image]  = params[:download][:images_attributes][index][:caption_image]
			
				end
			super
		
			elsif (params[:download].present? && params[:download][:videos_attributes].present?)
					params[:download][:videos_attributes].each do |index,img|
						  unless params[:download][:videos_attributes][index][:video].present?
							params[:download][:videos_attributes][index][:video] = params[:download][:videos_attributes][index][:video_cache]
						  end
					params[:download][:videos_attributes][index][:caption_video]  = params[:download][:videos_attributes][index][:caption_video]	  
					end
				super
			
			elsif (params[:download].present? && params[:download][:upload_videos_attributes].present?)
					params[:download][:upload_videos_attributes].each do |index,img|
						  unless params[:download][:upload_videos_attributes][index][:uploadvideo].present?
							params[:download][:upload_videos_attributes][index][:uploadvideo] = params[:download][:upload_videos_attributes][index][:uploadvideo_cache]
						  end
					params[:download][:upload_videos_attributes][index][:uploadvideo]  = params[:download][:upload_videos_attributes][index][:uploadvideo]	  
					end
				super	
			
			elsif (params[:download].present? && params[:download][:sketchfebs_attributes].present?)
					params[:download][:sketchfebs_attributes].each do |index,img|
						  unless params[:download][:sketchfebs_attributes][index][:sketchfeb].present?
							params[:download][:sketchfebs_attributes][index][:sketchfeb] = params[:download][:sketchfebs_attributes][index][:sketchfeb_cache]
						  end
					end
				super	
			
			elsif (params[:download].present? && params[:download][:marmosets_attributes].present?)
					params[:download][:marmosets_attributes].each do |index,img|
						  unless params[:download][:marmosets_attributes][index][:marmoset].present?
							params[:download][:marmosets_attributes][index][:marmoset] = params[:download][:marmosets_attributes][index][:marmoset_cache]
						  end
					end
				super	

			elsif (params[:download].present? && params[:download][:zip_files_attributes].present?)
				
					params[:download][:zip_files_attributes].each do |index,img|
						 
							unless params[:download][:zip_files_attributes][index][:zipfile].present?
									params[:download][:zip_files_attributes][index][:zipfile] = params[:download][:zip_files_attributes][index][:zipfile_cache]
									
									params[:download][:zip_files_attributes][index][:zip_caption] = params[:download][:zip_files_attributes][index][:zip_caption]

									params[:download][:zip_files_attributes][index][:software] = params[:download][:zip_files_attributes][index][:software]

							 		params[:download][:zip_files_attributes][index][:software_version] = params[:download][:zip_files_attributes][index][:software_version]

							  		params[:download][:zip_files_attributes][index][:renderer] = params[:download][:zip_files_attributes][index][:renderer]

							  		params[:download][:zip_files_attributes][index][:renderer_version] = params[:download][:zip_files_attributes][index][:renderer_version]

							end
									

						
							end
					super	
						
			
				
		 else
				super
		  end
		  
		end
			
  end
  
  
  filter :title
  filter :status, as: :select, collection: [['Active',1], ['Inactive', 0]], label: 'Status'
  filter :created_at

	
	
     # Users List View
  index :download_links => ['csv'] do
	   selectable_column
	   column 'Image' do |img|
		  image_tag img.try(:company_logo).try(:url, :thumb), height: 50, width: 50
	   end
	   column 'Username' do |uname|
			(uname.user_id == 1 && uname.is_admin == 'Y') ? 'Admin' : User.find_by(id: uname.user_id).try(:firstname)
		end
	   column 'title' 

	

	   column 'Status' do |user|
		  user.status? ? 'Active' : 'Inactive'
		end
		actions
  end	
  
  
  show do
		attributes_table do
		  row :title
		#  row :description
		  row 'Description' do |cat|
			cat.description.html_safe
		  end
		
		  row :status do |st|
		    st.status? ? 'Active' : 'Inactive'
		  end
		  row :is_save_to_draft do |st|
		    st.is_save_to_draft? ? 'Yes' : 'No'
		  end
		  row :visibility do |st|
		    st.visibility? ? 'Private' : 'Public'
		  end
		  row :publish do |st|
		    st.publish? ? 'Yes' : 'No'
		  end

		  row :company_logo do |cat|
			unless !cat.company_logo.present?
			  image_tag(cat.try(:company_logo).try(:url, :event_small))
			else
			  image_tag('/assets/default-blog.png', height: '50', width: '50')
			end
		  end
		  
		  row 'Images' do
			ul class: "image-blk" do
				if download.images.present?
				  download.images.each do |img|
					span do
					  image_tag(img.try(:image).try(:thumb).try(:url), class: "show-img")
					end
				  end
				end
			end
		  end
		  row 'Videos' do
			ul class: "image-blk" do
				if download.videos.present?
					download.videos.each do |img|
						span do
								if(img.video.include?('youtube'))	
										if img.video[/youtu\.be\/([^\?]*)/]
											youtube_id = $1
										  else
											img.video[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
											youtube_id = $5
										  end
										raw('<iframe title="Gallery Video" width="300" height="200" src="https://www.youtube.com/embed/' + youtube_id + '" frameborder="0" allowfullscreen></iframe>')
	
								 elsif(img.video.include?('vimeo'))	
											match = img.video.match(/https?:\/\/(?:[\w]+\.)*vimeo\.com(?:[\/\w]*\/?)?\/(?<id>[0-9]+)[^\s]*/)

											if match.present?
												vimeoid	=	match[:id]
											end
											raw('<iframe width="300" height="200" src="https://player.vimeo.com/video/'+vimeoid+'" width="640" height="270" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>')
							
								  elsif(img.video.include?('dailymotion'))	
											match =  img.video.gsub('http://www.dailymotion.com/video/', "")
											match1	= match.index('_')
											match	= match[0...match1]
											if match.present?
												dailymotionid	=	match
											end	
									
										raw('<iframe width="300" height="200" frameborder="0"  src="//www.dailymotion.com/embed/video/'+ dailymotionid +'" allowfullscreen></iframe>')	
							
								  end
						 end
					end
				end
			end
		  end
		  
		  row 'Uploaded Videos' do
			ul class: "image-blk" do
				if download.upload_videos.present?
				  download.upload_videos.each do |img|
					span do
						raw('<iframe title="Video" width="300" height="200" src="'+img.uploadvideo.url+'" frameborder="0" allowfullscreen></iframe>')
					
					end
				  end
				end
			end
		  end
	
		  row :created_at
		end
    end
  
  csv do
		column :title
		column 'Description' do |cat|
			cat.description.html_safe
		end

		column :status do |st|
			st.status? ? 'Active' : 'Inactive'
		  end
		column :is_save_to_draft do |st|
			st.is_save_to_draft? ? 'Yes' : 'No'
		  end
		column :visibility do |st|
			st.visibility? ? 'Private' : 'Public'
		  end
		column :publish do |st|
			st.publish? ? 'Yes' : 'No'
		  end
		  
		column :created_at
		
  end
  
  batch_action "Update Status for", form: { status: [['Active',1],['Inactive',0]] } do |ids, inputs|    
		Download.where(id: ids).update_all(status: inputs[:status])
		redirect_to collection_path, notice: "Status has successfully changed"
 end
  
  
end
