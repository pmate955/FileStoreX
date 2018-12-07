class ApplicationController < ActionController::Base
    before_action :datas

  def datas
    if Statistic.find_by(dateTime: Date.today) == nil
      record = Statistic.create(dateTime: Date.today, visits: 1, userVisit: 0, newUsers: 0)
      record.save
    else
      record = Statistic.find_by(dateTime: Date.today)
      record.increment(:visits, 1)
      record.save
    end
    @stat = Statistic.find_by(dateTime: Date.today)
  end
end
