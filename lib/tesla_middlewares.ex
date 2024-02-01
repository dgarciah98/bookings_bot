defmodule TeslaMiddlewares do
  def retry() do
    {
      Tesla.Middleware.Retry,
      delay: 5_000,
      max_retries: 6,
      max_delay: 20_000,
      should_retry: fn
        {:ok, %{status: status}} when status in [429] -> true
        _ -> false
      end
    }
  end
end
