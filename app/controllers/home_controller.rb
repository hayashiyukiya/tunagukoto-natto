class HomeController < ApplicationController
  def top
  	@events = Event.all
  	@quests = Quest.all
  	# @busi_cons = BusinessContest.all
  end

  def admin_top
  	@events = Event.all
  	@quests = Quest.all
  	# @busi_cons = BusinessContest.all
  	@schools = School.all
  end

  def admin_event
    @hash = {}
    Event.all.each do |e|
      @hash.merge!(e.event_name => EventCustomer.where(event_id: e.id))
    end
  end

  def policy
  end
end
