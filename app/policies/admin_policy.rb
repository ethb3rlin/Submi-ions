# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def index?
    user.present? && user.organizer?
  end
end
