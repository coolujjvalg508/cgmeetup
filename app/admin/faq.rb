ActiveAdmin.register Faq do
 
 menu label: 'Faq'
 config.sort_order = 'position_asc'
 permit_params :question, :answer, :active, :bootsy_image_gallery_id

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

	 # New/Edit Form
  form :title => 'New FAQ' do |f|
    f.inputs "FAQ" do
      f.input :question, :rows => 15, :cols => 15
      li do
        insert_tag(Arbre::HTML::Label, "Answer") { content_tag(:abbr, "*", title: "required") }
        f.bootsy_area :answer, :rows => 15, :cols => 15, editor_options: { html: true }
      end
      f.input :active
    end
    f.actions
  end  
  
   # Index Page
  index :download_links => ['csv'], :title => "FAQs" do
    selectable_column
    column 'Question' do |faq|
      tr_con = faq.question.first(50)
      link_to tr_con.html_safe, admin_faq_path(faq)
    end
    column 'Answer' do |faq|
      tr_con = faq.answer.first(50)
      tr_con.html_safe
    end
    column "Status" do |status|
      status.try(:active) ? 'Active' : 'Inactive'
    end
    column :created_at
    actions
  end
  
    # Filters
  filter :question
  filter :answer
  filter :active, as: :select, collection: [['Active',1], ['Inactive', 0]], label: "Status"
  filter :created_at
  
    # Show Page
  show :title => 'FAQ' do 
    attributes_table do
      row 'Question' do |faq|
        text_node faq.question.html_safe
      end
      row 'Answer' do |faq|
        text_node faq.answer.html_safe
      end      
      row :active
      row :created_at
    end
  end

end
