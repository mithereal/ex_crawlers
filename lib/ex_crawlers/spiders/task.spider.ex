defmodule ExCrawlers.Task.Spider do
  use Task

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(arg) do
  end
end
