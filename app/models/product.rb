class Product < ActiveRecord::Base
  belongs_to :brand
  has_and_belongs_to_many :specification_values
  has_many :offers
  validates :name, :small_img_url, :big_img_url, :brand, :presence => true
  attr_reader :price


  #gets the minimal price between all offers
  after_initialize :process_price!
  def process_price!
    @price = self.offers.sort{|o1, o2| o1.price <=> o2.price}.first.price
  end
end

