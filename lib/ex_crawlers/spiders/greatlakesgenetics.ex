defmodule ExCrawlers.Spider.GreatlakesGenetics do
  @behaviour Crawly.Spider

  alias ExCrawlers.Spider.GreatlakesGenetics.Product, as: Spider

  @impl Crawly.Spider
  def base_url(), do: "https://greatlakesgenetics.com/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: "https://www.greatlakesgenetics.com/breeders/"
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    pagination_urls =
      document |> Floki.find("ul.page-numbers") |> Floki.find("a") |> Floki.attribute("href")

    product_urls =
      Floki.find(document, "ul.products")
      |> Floki.find("li")
      |> Enum.map(fn x ->
        [{_, [{_, href}], [_name]}] = Floki.find(x, "a")
        href
      end)

    Task.Supervisor.start_child(:spider_supervisor, Task.start_link(Spider.init(product_urls)))

    requests =
      pagination_urls
      |> Enum.uniq()
      |> Enum.map(&build_absolute_url/1)
      |> Enum.map(&Crawly.Utils.request_from_url/1)

    items = []
    %Crawly.ParsedItem{:items => items, :requests => requests}
  end

  defp build_absolute_url(url), do: URI.merge(base_url(), url) |> to_string()
end
