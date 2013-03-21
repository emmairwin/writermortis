class Story < ActiveRecord::Base
  attr_accessible :title, :max_sentences, :total_slices, :complete, :user_id

  validates :title, :presence => true
  validates :total_slices, :presence => true, :numericality => { :only_integer => true, :less_than => 99 }
  validates :max_sentences, :presence => true, :numericality => { :only_integer => true, :less_than => 15 }

  belongs_to :user
  has_many :slices, :dependent => :destroy
  has_many :users, :through => :slices

  def slices_left
      total_slices - slices.length
  end

  def slices_done
      slices.length  % total_slices
  end

  def done?
      complete || done_by_count?
  end

  def can_have_slice_by(user)
      if  users.last and user.id == users.last.id
          false
      else
          true
      end
  end

  def contributors
      if self.slices.empty?
          [] << self.user
      else
          self.users.unshift(self.user).uniq
      end
  end

  def self.complete_story(story)
      complete_story = []

      story.slices.each do |slice|
          complete_story << "<span id='user_#{slice.user.id}'>#{slice.body}</span>"
      end

      complete_story.join(" ")
  end

  def self.list(state, limit=nil)
      if limit.nil?
          Story.where("complete = ?", state).order('created_at DESC')
      else
          Story.where("complete = ?", state).limit(limit).order('created_at DESC')
      end
  end


  private

  def done_by_count?
      if slices.length >= total_slices
          true
      else
          false
      end
  end

end
