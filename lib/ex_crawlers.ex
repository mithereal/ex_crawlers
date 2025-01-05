defmodule ExCrawlers do
  import Cachex

  @moduledoc """
  Documentation for `ExCrawlers`.
  """

  @doc """
  Run.

  ## Examples

      iex> ExCrawlers.run()
      {:error, "Unknown Crawler"}

  """
  def run() do
    {:error, "Unknown Crawler"}
  end

  def run(:allbud) do
    ExCrawlers.Spider.Allbud.init()
    :ok
  end

  def run(:greatlakesgenetics) do
    ExCrawlers.Spider.GreatlakesGenetics.init()
    :ok
  end
end
