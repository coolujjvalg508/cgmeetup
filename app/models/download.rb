class Download < ActiveRecord::Base
include Bootsy::Container

 mount_uploader :company_logo, ImageUploader

 validates :title, presence: true

 belongs_to :user
 
 has_many :images, as: :imageable, dependent: :destroy
 has_many :caption_image
 
 has_many :videos, as: :videoable, dependent: :destroy
 has_many :caption_video
 
 has_many :collection
 has_many :upload_videos, as: :uploadvideoable, dependent: :destroy
 has_many :caption_upload_video
 
 has_many :sketchfebs, as: :sketchfebable, dependent: :destroy
 has_many :marmo_sets, as: :marmosetable, dependent: :destroy
 
 has_many :lessons, as: :lessonable, dependent: :destroy
 has_many :zip_files, as: :zipfileable, dependent: :destroy
 has_many :zip_caption
 has_many :software
 has_many :software_version
 has_many :renderer
 has_many :renderer_version
 
 has_many :lesson_title
 has_many :lesson_description
 has_many :lesson_video_link
 has_many :lesson_video
 has_many :lesson_image
 
 
 has_many :tags, as: :tagable, dependent: :destroy

 UNWRAPPED_UV = ['Unknown', 'Non-overlapping', 'Overlapping', 'Mixed', 'No']
 GEOMETRY = ['Polygon mesh', 'Subdivision-ready', 'Nurbs', 'Other']
 LICENSE_TYPE = ['Royalty free', 'Editorial', 'Custom']
 UNIT_VALUE = ['Millimeters (mm)', 'Centimeters (cm)', 'Inches (in)', 'Meters (m)']
   
 accepts_nested_attributes_for :images, reject_if: proc { |attributes| attributes['image'].blank? || attributes['image'].nil? }, allow_destroy: true 
 
 accepts_nested_attributes_for :videos, reject_if: proc { |attributes| attributes['video'].blank? || attributes['video'].nil? }, allow_destroy: true
 accepts_nested_attributes_for :upload_videos, reject_if: proc { |attributes| attributes['uploadvideo'].blank? || attributes['uploadvideo'].nil? }, allow_destroy: true
 accepts_nested_attributes_for :sketchfebs, reject_if: proc { |attributes| attributes['sketchfeb'].blank? || attributes['sketchfeb'].nil? }, allow_destroy: true
 accepts_nested_attributes_for :marmo_sets, reject_if: proc { |attributes| attributes['marmoset'].blank? || attributes['marmoset'].nil? }, allow_destroy: true
 
 accepts_nested_attributes_for :lessons, reject_if: proc { |attributes| attributes['lesson_video'].blank? || attributes['lesson_video'].nil? }, allow_destroy: true
 accepts_nested_attributes_for :zip_files, reject_if: proc { |attributes| attributes['zipfile'].blank? || attributes['zipfile'].nil? }, allow_destroy: true
 
 accepts_nested_attributes_for :tags, reject_if: proc { |attributes| attributes['tag'].blank? || attributes['tag'].nil? }, allow_destroy: true
end
