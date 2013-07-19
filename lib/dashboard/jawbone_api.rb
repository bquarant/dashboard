require 'jawbone-up'

module Dashboard::JawboneAPI

  def jawbone_up_session
    @up = JawboneUP::Session.new
    #@up.signin ENV['JAWBONE_UP_EMAIL'], ENV['JAWBONE_UP_PWD']
    @up.signin "quaranto@gmail.com", ""
  end

  def new_sleep
    jawbone_up_session

    if sleep_summary = @up.get_sleep_summary
      quality = sleep_summary['items'].first['details']['quality']
      light = sleep_summary['items'].first['details']['light']
      deep = sleep_summary['items'].first['details']['deep']
    end

    if last = Sleep.last
      unless (light == last.light_sleep && deep == last.deep_sleep && quality == last.quality)
        create_sleep(light, deep, quality)
      end
    else
      create_sleep(light, deep, quality)
    end
  end

  def new_steps
    jawbone_up_session
    if score = @up.get("/nudge/api/users/@me/score")
      if data = score['data']['move']
        quantity = data['bg_steps']
        if Step.last.quantity > quantity
          create_steps(quantity)
        else
          Step.last.update_attributes!(quantity: quantity)
        end
      end
    end
  end

  def new_calories
    jawbone_up_session
    if score = @up.get("/nudge/api/users/@me/score")
      if data = score['data']['move']
        active_burn  = data['calories']
        resting_burn = data['bmr_calories']
        quantity = active_burn + resting_burn
        if Calorie.last.quantity > quantity.to_i
          create_calories(quantity)
        else
          Calorie.last.update_attributes!(quantity: quantity)
        end
      end
    end
  end

  def new_mood
    jawbone_up_session
    if score = @up.get("/nudge/api/users/@me/score")
      if data = score['data']['mood']
        title = data['title']
        sub_type = data['sub_type']
        create_mood(title, sub_type)
      end
    end
  end

  private

  def create_sleep(light, deep, quality)
    Sleep.create(light_sleep: light, deep_sleep: deep, quality: quality)
  end

  def create_steps(quantity)
    Step.create(quantity: quantity)
  end

  def create_calories(quantity)
    Calorie.create(quantity: quantity)
  end

  def create_mood(title, sub_type)
    Mood.create(title: title, sub_type: sub_type)
  end
end
