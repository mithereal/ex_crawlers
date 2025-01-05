defmodule ExCrawlers.Spider.GreatlakesGenetics.Product do
  @behaviour Crawly.Spider
  alias HtmlQuery, as: Hq

  @impl Crawly.Spider
  def base_url(), do: "https://greatlakesgenetics.com/"

  @impl Crawly.Spider
  def init(item_urls) do
    [
      start_urls: item_urls
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    items = __MODULE__.parse_document(document)

    Enum.each(items, fn x ->
      Cachex.put(:spiders, x.name, x)
    end)

    %Crawly.ParsedItem{:items => items, :requests => []}
  end

  def parse_document(document) do
    result = Floki.find(document, "div.et_pb_row_0_tb_body")

    gallery =
      Floki.find(result, "div.woocommerce-product-gallery__wrapper") |> Floki.find("data-src")

    description_block = Floki.find(result, "div.et_pb_column")

    [{"h1", [], [product_name]}] =
      Floki.find(description_block, "div.et_pb_wc_title")
      |> Floki.find("div.et_pb_module_inner")
      |> Floki.find("h1")

    description =
      Floki.find(description_block, "div.et_pb_wc_description")
      |> Floki.find("div.et_pb_module_inner")

    [{"h3", [], [name]}] = Floki.find(description, "h3")
    data = Floki.find(description, "p")

    {info_block, notes_block} =
      case data do
        [{"p", _, info_block}, {_, _, notes_block}, _] -> {info_block, notes_block}
        [{"p", _, info_block}, {_, _, notes_block}] -> {info_block, notes_block}
        [{"p", _, info_block}] -> {info_block, []}
      end

    info =
      Enum.reduce(info_block, %{last_element: nil}, fn x, acc ->
        current_element =
          case x do
            {"strong", [], ["Genetics: "]} -> :genetics
            {"strong", [], ["Genetics:"]} -> :genetics
            {"strong", [], ["Lineage: "]} -> :genetics
            {"strong", [], ["Lineage:"]} -> :genetics
            {"strong", [], ["Flavor: "]} -> :flavor
            {"strong", [], ["Flavor:"]} -> :flavor
            {"strong", [], ["Type:"]} -> :type
            {"strong", [], ["Type: "]} -> :type
            {"strong", [], ["Filial Generation: "]} -> :filial_generation
            {"strong", [], ["Filial Generation:"]} -> :filial_generation
            {"strong", [], ["Nutritional Wants:"]} -> :nutritional_wants
            {"strong", [], ["Nutritional Wants: "]} -> :nutritional_wants
            {"strong", [], ["Humidity Resistance Rating:"]} -> :humidity_resistance_rating
            {"strong", [], ["Humidity Resistance Rating: "]} -> :humidity_resistance_rating
            {"strong", [], ["Sexual Stability:"]} -> :sexual_stability
            {"strong", [], ["Sexual Stability: "]} -> :sexual_stability
            {"strong", [], ["Seeds per pack: "]} -> :seeds_per_pack
            {"strong", [], ["Seeds per pack:"]} -> :seeds_per_pack
            {"strong", [], ["Type (Indica, Sativa, Hybrid):"]} -> :type
            {"strong", [], ["Type (Indica, Sativa, Hybrid): "]} -> :type
            {"strong", [], ["Type: "]} -> :type
            {"strong", [], ["Type:"]} -> :type
            {"strong", [], ["Sex:"]} -> :type
            {"strong", [], ["Sex: "]} -> :type
            {"strong", [], ["Flowering Time: "]} -> :flowering_time
            {"strong", [], ["Flowering Time:"]} -> :flowering_time
            {"strong", [], ["Yield:"]} -> :yield
            {"strong", [], ["Yield: "]} -> :yield
            {"strong", [], ["Yield:\u00A0 Very "]} -> :yield
            {"strong", [], ["Yield:\u00A0 Very"]} -> :yield
            {"strong", [], ["Area (Indoor, Outdoor, Both):"]} -> :area
            {"strong", [], ["Area (Indoor, Outdoor, Both): "]} -> :area
            _ -> nil
          end

        value =
          case is_binary(x) do
            true -> x
            false -> nil
          end

        last_element = acc.last_element

        case is_nil(last_element) do
          true ->
            Map.merge(acc, %{last_element: current_element})

          false ->
            map = %{last_element => value}
            Map.merge(acc, %{last_element: current_element}) |> Map.merge(map)
        end
      end)
      |> Map.drop([:last_element])

    %{product_name: product_name, name: name, info: info}
  end
end
