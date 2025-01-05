defmodule ExCrawlers.Spider.Allbud.Strain do
  @behaviour Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.allbud.com"

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
    result = Floki.find(document, "#strain_detail_accordion")

    name = Floki.find(result, "span.fallback-strains") |> String.replace("Strain", "")

    strain_percentages =
      case Floki.find(result, "span.strain-percentages") do
        [{_, _, [strain_percentages]}] -> strain_percentages
        _ -> "unknown"
      end

    thc =
      case Floki.find(result, "h4.percentage") do
        [{_, _, [thc]}] ->
          {thc, "unknown"}

        [
          {"h4", [{"class", "percentage"}], [{"span", [{"class", "heading"}], ["THC: "]}, thc]}
        ] ->
          {thc, "unknown"}

        [
          {"h4", [{"class", "percentage"}],
           [
             {"span", [{"class", "heading"}], ["THC: "]},
             thc,
             {"span", [{"class", "heading"}], ["CBN: "]},
             {"em", [], [cbn]},
             pct
           ]}
        ] ->
          {thc, cbn <> pct}

        _ ->
          {"unknown", "unknown"}
      end

    [{_, _, [variety]}] =
      Floki.find(result, "h4.variety")
      |> Floki.find("a")

    data = Floki.find(result, "div.description")

    description = Floki.find(data, "span")

    {_, _, description} = List.last(description)

    description =
      Enum.map(description, fn x ->
        case x do
          {_, _, [name]} -> String.replace(name, "“", "") |> String.replace("”", "")
          str -> String.replace(str, "“", "") |> String.replace("”", "")
        end
      end)
      |> Enum.join("")

    data = Floki.find(result, "div#collapse_positive")
    data = Floki.find(data, "div.tags-list")
    data = Floki.find(data, "a")

    moods =
      Enum.map(data, fn x ->
        [{_, _, [name]}] = Floki.find(x, "a")

        name
      end)

    data = Floki.find(result, "div#collapse_relieved")
    data = Floki.find(data, "div.tags-list")
    data = Floki.find(data, "a")

    symptoms =
      Enum.map(data, fn x ->
        [{_, _, [name]}] = Floki.find(x, "a")

        name
      end)

    data = Floki.find(result, "div#collapse_flavors")
    data = Floki.find(data, "div.tags-list")
    data = Floki.find(data, "a")

    flavors =
      Enum.map(data, fn x ->
        [{_, _, [name]}] = Floki.find(x, "a")

        name
      end)

    data = Floki.find(result, "div#collapse_aromas")
    data = Floki.find(data, "div.tags-list")
    data = Floki.find(data, "a")

    aromas =
      Enum.map(data, fn x ->
        [{_, _, [name]}] = Floki.find(x, "a")

        name
      end)

    {thc, cbn} = thc

    %{
      description: description,
      name: String.trim(name),
      variety: String.trim(variety),
      thc: String.replace(thc, "\n", "") |> String.replace(~r/\s+/, " ") |> String.trim(),
      cbn: String.replace(cbn, "\n", "") |> String.replace(~r/\s+/, " ") |> String.trim(),
      strain_percentages: String.trim(strain_percentages),
      moods: moods,
      symptoms: symptoms,
      flavors: flavors,
      aromas: aromas
    }
  end
end
