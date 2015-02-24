class Sites::Orzoro::CupRedeemerController < ApplicationController

  def step_1
    render template: "cup_redeemer/step_1"
  end

end