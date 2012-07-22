#Old syntax of Factory Girl
#Factory.define :user do |user|
#		user.name "Sam Serpoosh"
#		user.email "ssjesus287@gmail.com"
#		user.password "foobar"
#		user.password_confirmation "foobar"
#end
#
#Factory.sequence :email do |n|
#	"person-#{n}@exapmle.com"
#end
#
#Factory.define :micropost do |micropost|
#		micropost.content "Foo bar"
#		micropost.association :user
#end

#New Syntax of Factory Girl
FactoryGirl.define do
  sequence :email do |n|
    "person-#{n}@example.com"
  end

  factory :user do
    name "Sam Serpoosn"
    email "ssjesus287@gmail.com"
    password "foobar"
    password_confirmation "foobar"
  end

  factory :micropost do
    content "Foo Bar"
    user
  end
end
