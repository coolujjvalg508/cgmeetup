ActiveAdmin.register NewsPackage do

	 menu label: 'News Package', parent: 'Package'
	 permit_params :title, :description, :amount, :image
	 actions :all, except: [:destroy]
	 

	controller do 
		def action_methods
		 super                                    
			if current_admin_user.id.to_s == '1'
			super
		  else
			usergroup = UserGroup.where(:id => current_admin_user.group_id.to_s).first
			disallowed = []
			disallowed << 'index' if (!usergroup.has_permission('newspackage_read') && !usergroup.has_permission('newspackage_write') && !usergroup.has_permission('newspackage_delete'))
			disallowed << 'delete' unless (usergroup.has_permission('newspackage_delete'))
			disallowed << 'create' unless (usergroup.has_permission('newspackage_write'))
			disallowed << 'new' unless (usergroup.has_permission('newspackage_write'))
			disallowed << 'edit' unless (usergroup.has_permission('newspackage_write'))
			disallowed << 'destroy' unless (usergroup.has_permission('newspackage_delete'))
			
			super - disallowed
		  end
		end
	  end




	  form multipart: true do |f|
		  f.inputs "News Package" do
			  f.input :image
			  f.input :title
			  f.input :description
			  f.input :amount
		  end

			f.actions
	  end

	  controller do
			def create
			  unless params[:news_package][:image].present?
				params[:news_package][:image] = params[:news_package][:image_cache]
				super
			  else
				super
			  end
			end
	end

	index :download_links => ['csv'] do
		selectable_column
		
		column 'Image' do |img|
		  image_tag img.try(:image).try(:url, :thumb), height: 50, width: 50
		end
		column :title
		column :description do |description|
		   tr_con = description.description.first(45)
		end
		
		column :amount
		column :created_at
		actions
	  end
	  
	filter :title
	filter :created_at  
	  

	# Show Page
	  show do
		attributes_table do
			  row :image do |cat|
				unless !cat.image.present?
				  image_tag(cat.try(:image).try(:url, :event_small))
				else
				  image_tag('/assets/default-blog.png', height: '50', width: '50')
				end
			  end
		  row :title
		  row :description do |description|
				tr_con = description.description.first(45)
		   end
		  row :amount
		  row :created_at
		end
	  end
	
end

