defmodule Kiq.Reporter.LoggerTest do
  use Kiq.Case, async: true

  import ExUnit.CaptureLog

  alias Kiq.Reporter.Logger, as: Reporter

  setup do
    Logger.flush()

    {:ok, job: job()}
  end

  test "job start is logged", %{job: job} do
    message = capture_log(fn -> Reporter.handle_started(job, nil) end)

    assert message =~ "Worker"
    assert message =~ "testing"
    assert message =~ job.jid
    assert message =~ "started"
  end

  test "job success is logged with timing information", %{job: job} do
    message = capture_log(fn -> Reporter.handle_success(job, [timing: 103], nil) end)

    assert message =~ "Worker"
    assert message =~ "testing"
    assert message =~ job.jid
    assert message =~ "103 µs"
    assert message =~ "success"
  end

  test "job abort is logged with the reason", %{job: job} do
    message = capture_log(fn -> Reporter.handle_aborted(job, [reason: :expired], nil) end)

    assert message =~ "Worker"
    assert message =~ "expired"
    assert message =~ "aborted"
  end

  test "job failure is logged with exception information", %{job: job} do
    message = capture_log(fn -> Reporter.handle_failure(job, %RuntimeError{}, [], nil) end)

    assert message =~ "Worker"
    assert message =~ "testing"
    assert message =~ job.jid
    assert message =~ "RuntimeError"
    assert message =~ "failure"
  end
end
