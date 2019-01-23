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
    set_locale
  end



    def default_url_options
      { locale: I18n.locale }
    end

    def set_locale
      I18n.locale = params[:locale] || session[:locale]         #lifehack
      session[:locale] = I18n.locale
    end
end
