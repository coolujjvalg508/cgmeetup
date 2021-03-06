ActiveAdmin.register PostTypeCategory do

	menu label: 'Category', parent: 'Download',priority: 4
	permit_params :name, :parent_id, :image, :description, :slug,:post_type_id

	
	controller do 
		def action_methods
		 super                                    
		 if current_admin_user.id.to_s == '1'
			super
		  else
			usergroup = UserGroup.where(:id => current_admin_user.group_id.to_s).first
			disallowed = []
			disallowed << 'index' if (!usergroup.has_permission('post_type_category_read') && !usergroup.has_permission('post_type_category_write') && !usergroup.has_permission('post_type_category_delete'))
			disallowed << 'delete' unless (usergroup.has_permission('post_type_category_delete'))
			disallowed << 'create' unless (usergroup.has_permission('post_type_category_write'))
			disallowed << 'new' unless (usergroup.has_permission('post_type_category_write'))
			disallowed << 'edit' unless (usergroup.has_permission('post_type_category_write'))
			disallowed << 'destroy' unless (usergroup.has_permission('post_type_category_delete'))
			
			super - disallowed
		  end
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
  	# Users List View
  index :download_links => ['csv'] do
     selectable_column
    column :post_type_id do |cat|
      PostType.find_by(id: cat.post_type_id).try(:type_name)
    end
    column :name
    column :parent do |cat|
      PostTypeCategory.find_by(id: cat.parent_id).try(:name)
    end
    column 'Image' do |img|
      image_tag img.try(:image).try(:url, :thumb), height: 50, width: 50
    end
	column :created_at
    actions
  end

	
   controller do
			def create
			  unless params[:post_type_category][:image].present?
				params[:post_type_category][:image] = params[:post_type_category][:image_cache]
				super
			  else
				super
			  end
			end
	end



 form multipart: true do |f|
      f.inputs "Category" do
      f.input :post_type_id, as: :select, collection: PostType.where("id IS NOT NULL ").pluck(:type_name, :id), include_blank: 'Select Post Type'
      f.input :parent_id, as: :select, collection: PostTypeCategory.where("parent_id IS NULL ").pluck(:name, :id), include_blank: 'Select Parent'
      #f.input :parent_id, :as => :select
      f.input :image
      f.input :name
      f.input :description
      f.input :slug
    end

    f.actions
  end
  
  filter :name
  filter :created_at


  # Show Page
  show do
    attributes_table do
    row :post_type_id do |cat|
      PostType.find_by(id: cat.post_type_id).try(:type_name)
    end
      row :name
      row :parent do |cat|
       PostTypeCategory.find_by(id: cat.parent_id).try(:name)
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

end
