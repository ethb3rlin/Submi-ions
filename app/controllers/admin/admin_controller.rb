class Admin::AdminController < ApplicationController
  def index
    authorize :admin, :index?, policy_class: AdminPolicy
  end
end
