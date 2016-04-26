# frozen_string_literal: true

require 'test_helper'

# Tests to assure that admins (owners) can create and update broadcast
# categories.
class Admin::CategoriesControllerTest < ActionController::TestCase
  setup do
    @admin_category = admin_categories(:one)
    @admin = users(:owner)
  end

  def category_params
    {
      name: 'New Category',
      slug: 'new-slug'
    }
  end

  test 'should get index' do
    login(@admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_categories)
  end

  test 'should get new' do
    login(@admin)
    get :new
    assert_response :success
  end

  test 'should create category' do
    login(@admin)
    assert_difference('Admin::Category.count') do
      post :create, admin_category: category_params
    end
    assert_redirected_to admin_category_path(assigns(:admin_category))
  end

  test 'should not create category with blank name' do
    login(@admin)
    assert_difference('Admin::Category.count', 0) do
      post :create, admin_category: category_params.merge(name: '')
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should show category' do
    login(@admin)
    get :show, id: @admin_category
    assert_response :success
  end

  test 'should get edit' do
    login(@admin)
    get :edit, id: @admin_category
    assert_response :success
  end

  test 'should update category' do
    login(@admin)
    patch :update, id: @admin_category, admin_category: category_params
    assert_redirected_to admin_category_path(assigns(:admin_category))
  end

  test 'should not update category with blank name' do
    login(@admin)
    patch :update, id: @admin_category, admin_category: category_params.merge(name: '')
    assert_template 'edit'
    assert_response :success
  end

  test 'should destroy category' do
    login(@admin)
    assert_difference('Admin::Category.current.count', -1) do
      delete :destroy, id: @admin_category
    end

    assert_redirected_to admin_categories_path
  end
end