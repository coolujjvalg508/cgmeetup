ActiveAdmin.register Gallery , as: "Project" do
 menu false
	#	abort(current_admin_user.to_json)
    #menu label: 'Projects', parent: 'Gallery',priority: 2 
    
    permit_params :is_spam, :is_trash, :title,:user_id,:is_admin,:paramlink, {:challenge => []}, {:skill => []}, {:team_member => []},:show_on_cgmeetup,:show_on_website, :schedule_time, :description, :post_type_category_id, 
	:medium_category_id, {:subject_matter_id => []} , :has_adult_content, {:software_used => []} , :use_tag_from_previous_upload, :is_featured, 
	:status, :is_save_to_draft, :visibility, :publish, :company_logo,  {:where_to_show => []} , :images_attributes => [:id,:image,:caption_image,:imageable_id,:imageable_type, :_destroy,:tmp_image,:image_cache], :videos_attributes => [:id,:video,:caption_video,:videoable_id,:videoable_type, :_destroy,:tmp_image,:video_cache], :upload_videos_attributes => [:id,:uploadvideo,:caption_upload_video,:uploadvideoable_id,:uploadvideoable_type, :_destroy,:tmp_image,:uploadvideo_cache], :sketchfebs_attributes => [:id,:sketchfeb,:sketchfebable_id,:sketchfebable_type, :_destroy,:tmp_sketchfeb,:sketchfeb_cache, :caption_sketchfeb], :marmo_sets_attributes => [:id,:marmoset,:marmosetable_id,:marmosetable_type, :_destroy,:tmp_image,:marmoset_cache, :caption_marmoset],:tags_attributes => [:id,:tag,:tagable_id,:tagable_type, :_destroy,:tmp_tag,:tag_cache]
		
	
	
	 controller do 

		def action_methods
		  super                                  
				if current_admin_user.id.to_s == '1'
					super
		  else
				usergroup = UserGroup.where(:id => current_admin_user.group_id.to_s).first
				disallowed = []
				disallowed << 'index' if (!usergroup.has_permission('gallery_read') && !usergroup.has_permission('gallery_write') && !usergroup.has_permission('gallery_delete'))
				disallowed << 'delete' unless (usergroup.has_permission('gallery_delete'))
				disallowed << 'create' unless (usergroup.has_permission('gallery_write'))
				disallowed << 'new' unless (usergroup.has_permission('gallery_write'))
				disallowed << 'edit' unless (usergroup.has_permission('gallery_write'))
				disallowed << 'destroy' unless (usergroup.has_permission('gallery_delete'))
			
				super - disallowed
		  end
		end
	  end
	
	
		
		
	
	form multipart: true do |f|
		
		f.inputs "Project" do
		  f.input :title
		  f.input :paramlink,label:'Permalink'
		
		/ li do
			insert_tag(Arbre::HTML::Label, "Description", class: "label") { content_tag(:abbr, "*", title: "required") }
			f.bootsy_area :description, :rows => 15, :cols => 15, editor_options: { html: true }
		  end /
		  
		  div do
			f.input :description,  :input_html => { :class => "tinymce" }, :rows => 40, :cols => 50 ,label: false
		  end
		  
		  f.input :post_type_category_id, as: :select, collection: Category.where("parent_id IS NULL ").pluck(:name, :id), include_blank: 'Select Post Type Category', label: 'Post Type'
		  f.input :medium_category_id, as: :select, collection: MediumCategory.where("parent_id IS NULL ").pluck(:name, :id), include_blank: false, label: 'Medium'
		  f.input :subject_matter_id, as: :select, collection: SubjectMatter.where("id IS NOT NULL ").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false, label: 'Subject Matter',multiple: true
		  
		  f.input :skill, as: :select, collection: JobSkill.where("id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false, multiple: true
		 # f.input :location, label:'Location'
		 f.input :team_member, as: :select, collection: User.where("id IS NOT NULL").pluck(:firstname, :id), :input_html => { :class => "chosen-input" }, include_blank: false, multiple: true
		  
		  f.input :has_adult_content, as: :boolean,label: "Has Adult Content"

		  f.input :software_used, as: :select, collection: SoftwareExpertise.where("id IS NOT NULL").pluck(:name, :id), :input_html => { :class => "chosen-input" }, include_blank: false,multiple: true 
		 		 
		  
		  #f.input :tags, label:'Tags'
		  f.input :use_tag_from_previous_upload, as: :boolean,label: "Use Tag From Previous Upload"
		  f.input :is_featured, as: :boolean,label: "Feature this Post"
		  f.input :status, as: :select, collection: [['Active',1], ['Inactive', 0]], include_blank: false
		  f.input :is_save_to_draft, as: :select, collection: [['Yes',1], ['No', 0]], include_blank: false, label: 'Save Draft'
		  f.input :visibility, as: :select, collection: [['Private',1], ['Public', 0]], include_blank: false
		  f.input :publish, as: :select, collection: [['Immediately',1], ['Schedule', 0]], include_blank: false
		  f.input :schedule_time, as: :date_time_picker
		  f.input :company_logo,label: "Project Thumbnail"
		
		  f.input :challenge, as: :select, collection: Challenge.where("challenge_type_id = 0").pluck(:title, :id), :input_html => { :class => "chosen-input" }, include_blank: false, multiple: true
		 # f.input :where_to_show, as: :select, collection: [['On CGmeetup',1],['On Website',0]], include_blank: false,multiple: true
		  f.input :show_on_cgmeetup, as: :boolean,label: "Show On CGmeetup"
		  f.input :show_on_website, as: :boolean,label: "Show On Website"
		  f.input :is_spam, as: :boolean,label: "Make Spam"
		  f.input :is_trash, as: :boolean,label: "Trash"
			
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
			  ff.input :caption_sketchfeb
			end
		  end	
		
		f.inputs 'Marmoset' do
			f.has_many :marmo_sets, allow_destroy: true, new_record: true do |ff|
			  ff.input :marmoset, label: "Marmoset", hint: ff.template.video_tag(ff.object.marmoset.try(:url), :size => "150x150")
			  ff.input :marmoset_cache, :as => :hidden
			  ff.input :caption_marmoset
			end
		 end	
		 
		
	 end
		
		
	f.actions
  end
  
  controller do
	  def create
			params[:gallery][:user_id] = current_admin_user.id.to_s
			params[:gallery][:is_admin] = 'Y'
			if (params[:gallery].present? && params[:gallery][:images_attributes].present?)
					params[:gallery][:images_attributes].each do |index,img|
						  unless params[:gallery][:images_attributes][index][:image].present?
							params[:gallery][:images_attributes][index][:image] = params[:gallery][:images_attributes][index][:image_cache]
							params[:gallery][:images_attributes][index][:caption_image] = params[:gallery][:images_attributes][index][:caption_image]
						  end
					end
				super
			
			elsif (params[:gallery].present? && params[:gallery][:videos_attributes].present?)
					params[:gallery][:videos_attributes].each do |index,img|
						  unless params[:gallery][:videos_attributes][index][:video].present?
							params[:gallery][:videos_attributes][index][:video] = params[:gallery][:videos_attributes][index][:video_cache]
							params[:gallery][:videos_attributes][index][:caption_video] = params[:gallery][:videos_attributes][index][:caption_video]
						  end
					end
				super
				
				
			elsif (params[:gallery].present? && params[:gallery][:upload_videos_attributes].present?)
					params[:gallery][:upload_videos_attributes].each do |index,img|
						  unless params[:gallery][:upload_videos_attributes][index][:uploadvideo].present?
							params[:gallery][:upload_videos_attributes][index][:uploadvideo] = params[:gallery][:upload_videos_attributes][index][:uploadvideo_cache]
							params[:gallery][:upload_videos_attributes][index][:caption_upload_video] = params[:gallery][:upload_videos_attributes][index][:caption_upload_video]
						  end
					end
				super	
				
				
			elsif (params[:gallery].present? && params[:gallery][:sketchfebs_attributes].present?)
					params[:gallery][:sketchfebs_attributes].each do |index,img|
						  unless params[:gallery][:sketchfebs_attributes][index][:sketchfeb].present?
							params[:gallery][:sketchfebs_attributes][index][:sketchfeb] = params[:gallery][:sketchfebs_attributes][index][:sketchfeb_cache]
							params[:gallery][:sketchfebs_attributes][index][:caption_sketchfeb] = params[:gallery][:sketchfebs_attributes][index][:caption_sketchfeb]
						  end
					end
				super
				
			elsif (params[:gallery].present? && params[:gallery][:marmosets_attributes].present?)
					params[:gallery][:marmosets_attributes].each do |index,img|
						  unless params[:gallery][:marmosets_attributes][index][:marmoset].present?
							params[:gallery][:marmosets_attributes][index][:marmoset] = params[:gallery][:marmosets_attributes][index][:marmoset_cache]
							params[:gallery][:marmosets_attributes][index][:marmoset] = params[:gallery][:marmosets_attributes][index][:caption_marmoset]
						  end
					end
				super
		  else
				super
		  end
		end

		def update
			#abort(current_admin_user.id.to_s)
			#params[:gallery][:user_id] = current_admin_user.id.to_s
			#params[:gallery][:is_admin] = 'Y'
			if (params[:gallery].present? && params[:gallery][:images_attributes].present?)
					params[:gallery][:images_attributes].each do |index,img|
						  unless params[:gallery][:images_attributes][index][:image].present?
							params[:gallery][:images_attributes][index][:image]  = params[:gallery][:images_attributes][index][:image_cache]
						  end
					params[:gallery][:images_attributes][index][:caption_image]  = params[:gallery][:images_attributes][index][:caption_image]
			
				end
			super
		
			elsif (params[:gallery].present? && params[:gallery][:videos_attributes].present?)
					params[:gallery][:videos_attributes].each do |index,img|
						  unless params[:gallery][:videos_attributes][index][:video].present?
							params[:gallery][:videos_attributes][index][:video] = params[:gallery][:videos_attributes][index][:video_cache]
						  end
					params[:gallery][:videos_attributes][index][:caption_video]  = params[:gallery][:videos_attributes][index][:caption_video]	  
					end
				super
			
			elsif (params[:gallery].present? && params[:gallery][:upload_videos_attributes].present?)
					params[:gallery][:upload_videos_attributes].each do |index,img|
						  unless params[:gallery][:upload_videos_attributes][index][:uploadvideo].present?
							params[:gallery][:upload_videos_attributes][index][:uploadvideo] = params[:gallery][:upload_videos_attributes][index][:uploadvideo_cache]
						  end
					params[:gallery][:upload_videos_attributes][index][:uploadvideo]  = params[:gallery][:upload_videos_attributes][index][:uploadvideo]	  
					end
				super	
			
			elsif (params[:gallery].present? && params[:gallery][:sketchfebs_attributes].present?)
					params[:gallery][:sketchfebs_attributes].each do |index,img|
						  unless params[:gallery][:sketchfebs_attributes][index][:sketchfeb].present?
							params[:gallery][:sketchfebs_attributes][index][:sketchfeb] = params[:gallery][:sketchfebs_attributes][index][:sketchfeb_cache]
							
						  end
						params[:gallery][:sketchfebs_attributes][index][:caption_sketchfeb] = params[:gallery][:sketchfebs_attributes][index][:caption_sketchfeb]
					end
				super	
			
			elsif (params[:gallery].present? && params[:gallery][:marmosets_attributes].present?)
					params[:gallery][:marmosets_attributes].each do |index,img|
						  unless params[:gallery][:marmosets_attributes][index][:marmoset].present?
							params[:gallery][:marmosets_attributes][index][:marmoset] = params[:gallery][:marmosets_attributes][index][:marmoset_cache]
							
						  end
						  params[:gallery][:marmosets_attributes][index][:marmoset] = params[:gallery][:marmosets_attributes][index][:caption_marmoset]
					end
				super	
		 else
				super
		  end
		  
		end
			
  end

  filter :title
  filter :post_type_category_id, as: :select, collection: Category.where("parent_id IS NULL ").pluck(:name, :id), label: 'Post Type'
  filter :medium_category_id, as: :select, collection: MediumCategory.where("parent_id IS NULL ").pluck(:name, :id), label: 'Medium'
  filter :has_adult_content, as: :select, collection: [['Yes',1], ['No', 0]], label: 'Adult content'
  filter :status, as: :select, collection: [['Active',1], ['Inactive', 0]], label: 'Status'
  filter :is_featured, as: :select, collection: [['Yes',1], ['No', 0]], label: 'Featured'
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
	   column 'Featured' do |feature|
			(feature.is_featured == true) ? 'Yes' : 'No'
	   end
	

	   column 'Status' do |user|
		  user.status? ? 'Active' : 'Inactive'
		end
		actions
  end
    
  
   show do
		attributes_table do
		  row :title
		  row 'Description' do |cat|
			cat.description.html_safe
		  end
		  row :post_type_category_id do |cat|
		    Category.find_by(id: cat.post_type_category_id).try(:name)
		  end
		  row :medium_category_id do |cat|
		    MediumCategory.find_by(id: cat.medium_category_id).try(:name)
		  end
	
		 
		  row :has_adult_content do |hac|
		    hac.has_adult_content? ? 'Yes' : 'No'
		  end

		  row :use_tag_from_previous_upload do |utag|
		    utag.use_tag_from_previous_upload? ? 'Yes' : 'No'
		  end
		  row :is_featured do |ifeature|
		   (ifeature.is_featured == true) ? 'Yes' : 'No'
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
				if project.images.present?
				  project.images.each do |img|
					span do
					  image_tag(img.try(:image).try(:thumb).try(:url), class: "show-img")
					end
				  end
				end
			end
		  end
		  row 'Videos' do
			ul class: "image-blk" do
				if project.videos.present?
					project.videos.each do |img|
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

												raw('<iframe width="300" height="200" src="https://player.vimeo.com/video/'+vimeoid+'" width="640" height="270" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>')
											end
											
							
								  elsif(img.video.include?('dailymotion'))	
											match =  img.video.gsub('http://www.dailymotion.com/video/', "")
											match1	= match.index('_')
											match	= match[0...match1]
											if match.present?
												dailymotionid	=	match

											raw('<iframe width="300" height="200" frameborder="0"  src="//www.dailymotion.com/embed/video/'+ dailymotionid +'" allowfullscreen></iframe>')	
											end	
									
										
							
								  end
						 end
					end
				end
			end
		  end
		  
		  row 'Uploaded Videos' do
			ul class: "image-blk" do
				if project.upload_videos.present?
				  project.upload_videos.each do |img|
					span do
						raw('<iframe title="Gallery Video" width="300" height="200" src="'+img.uploadvideo.url+'" frameborder="0" allowfullscreen></iframe>')
					
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
		column 'Post Type' do |cat|
			Category.find_by(id: cat.post_type_category_id).try(:name)
		end
		column :medium_category_id do |cat|
		    MediumCategory.find_by(id: cat.medium_category_id).try(:name)
		  end
	
		column :has_adult_content do |hac|
		    hac.has_adult_content? ? 'Yes' : 'No'
		 end 
 
	    column :use_tag_from_previous_upload do |utag|
		    utag.use_tag_from_previous_upload? ? 'Yes' : 'No'
		  end
		column :is_featured do |ifeature|
			ifeature.is_featured? ? 'Yes' : 'No'
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

	 batch_action "Make Spam for", form: { is_spam: [['Yes',true],['No',false]] } do |ids, inputs|    
		Gallery.where(id: ids).update_all(is_spam: inputs[:is_spam])
		redirect_to collection_path, notice: "Post has successfully marked as spam"
	 end
	 
	batch_action "Update Status for", form: { status: [['Active',1],['Inactive',0]] } do |ids, inputs|    
		Gallery.where(id: ids).update_all(status: inputs[:status])
		redirect_to collection_path, notice: "Status has successfully changed"
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
