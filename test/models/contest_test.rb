require "test_helper"

class ContestTest < ActiveSupport::TestCase
  test "a contest that never started is not open" do
    contest = Contest.new

    assert_not contest.started?
    assert_not contest.open?
    assert_not contest.ended?
  end

  test "starting opens the window and sets the zero mark" do
    contest = Contest.create!

    contest.start

    assert contest.started?
    assert contest.open?
  end

  # O relógio é do início real, e o encerramento é três horas depois dele (ADR-0008).
  test "the contest lasts three hours counted from the real start" do
    contest = contests(:maratona)

    assert_equal contest.started_at + 3.hours, contest.deadline
  end

  test "starting twice does not move the zero mark" do
    contest = contests(:maratona)
    started_at = contest.started_at

    contest.start

    assert_equal started_at, contest.reload.started_at
  end

  test "closing early ends the window before the three hours" do
    contest = contests(:maratona)

    contest.finish

    assert contest.ended?
    assert_not contest.open?
  end

  test "a contest whose three hours ran out is ended without anyone closing it" do
    contest = contests(:maratona)
    contest.update! started_at: 4.hours.ago

    assert contest.ended?
    assert_not contest.open?
  end

  test "the accumulated time counts whole minutes from the real start" do
    contest = contests(:maratona)

    assert_equal 12, contest.minutes_until(contest.started_at + 12.minutes + 30.seconds)
  end

  test "the standings stay secret until they are published" do
    contest = contests(:maratona)

    assert_not contest.published?
    contest.publish
    assert contest.published?
    contest.unpublish
    assert_not contest.published?
  end
end
