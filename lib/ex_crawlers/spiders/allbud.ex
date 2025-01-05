defmodule ExCrawlers.Spider.Allbud do
  @behaviour Crawly.Spider
  @letters Enum.map(?a..?z, fn x -> <<x::utf8>> end)
  @search_url "/marijuana-strains/search?sort=alphabet&results=500&letter="

  alias ExCrawlers.Spider.Allbud.Strain, as: Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.allbud.com"

  @impl Crawly.Spider
  def init() do
    start_urls =
      Enum.map(@letters, fn x ->
        letter = String.upcase(x)
        base_url() <> @search_url <> letter
      end)

    [
      start_urls: start_urls
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    next_url =
      document
      |> Floki.find("a.endless_more")
      |> Floki.attribute("href")
      |> Crawly.Utils.request_from_url()
      |> __MODULE__.build_absolute_url()

    items = __MODULE__.parse_document(document)

    items_urls =
      items
      |> Enum.map(fn {x, _} ->
        x
      end)

    Task.Supervisor.start_child(:spider_supervisor, Task.start_link(Spider.init(items_urls)))

    %Crawly.ParsedItem{:items => items, :requests => [next_url]}
  end

  def parse_document(document) do
    Floki.find(document, "#search-results")
    |> Floki.find("div.title-box")
    |> Enum.map(fn x ->
      [{_, [{_, href}], [name]}] = Floki.find(x, "a")
      {href, name}
    end)
  end

  defp build_absolute_url(url), do: URI.merge(base_url(), url) |> to_string()
end
