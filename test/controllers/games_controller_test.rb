require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @game = games(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:games)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game" do
    assert_difference('Game.count') do
      post :create, game: { away_team_covered_spread: @game.away_team_covered_spread, away_team_id: @game.away_team_id, away_team_pref_pick: @game.away_team_pref_pick, away_team_spread_pick: @game.away_team_spread_pick, game_selected_by_admin: @game.game_selected_by_admin, home_team_covered_spread: @game.home_team_covered_spread, home_team_id: @game.home_team_id, home_team_pref_pick: @game.home_team_pref_pick, home_team_spread_pick: @game.home_team_spread_pick, is_home_team: @game.is_home_team, points: @game.points, spread: @game.spread, tie_game: @game.tie_game, user_id: @game.user_id, week_id: @game.week_id }
    end

    assert_redirected_to game_path(assigns(:game))
  end

  test "should show game" do
    get :show, id: @game
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game
    assert_response :success
  end

  test "should update game" do
    patch :update, id: @game, game: { away_team_covered_spread: @game.away_team_covered_spread, away_team_id: @game.away_team_id, away_team_pref_pick: @game.away_team_pref_pick, away_team_spread_pick: @game.away_team_spread_pick, game_selected_by_admin: @game.game_selected_by_admin, home_team_covered_spread: @game.home_team_covered_spread, home_team_id: @game.home_team_id, home_team_pref_pick: @game.home_team_pref_pick, home_team_spread_pick: @game.home_team_spread_pick, is_home_team: @game.is_home_team, points: @game.points, spread: @game.spread, tie_game: @game.tie_game, user_id: @game.user_id, week_id: @game.week_id }
    assert_redirected_to game_path(assigns(:game))
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete :destroy, id: @game
    end

    assert_redirected_to games_path
  end
end
