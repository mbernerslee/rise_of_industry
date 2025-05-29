defmodule RiseOfIndustry do
  @moduledoc """

  Given a list of products and their demand per 15 days,
  returns the produder buildings you need

  iex> RiseOfIndustry.run([{"sugar", 6}])
  "farm produce,sugar,farm,plantation,1,0\nraw resources,water (siphon),gatherer,water siphon,0,67"

  RiseOfIndustry.run([{"berry pie", 1}]) |> IO.puts()
  """

  def run(resources) do
    resources |> buildings_needed() |> group() |> format_output()
  end

  def buildings_needed(resources) do
    buildings_needed([], resources)
  end

  defp format_output(buildings) do
    buildings
    |> Enum.flat_map(fn {_, x} -> x end)
    |> Enum.map(fn x ->
      "#{x.tier},#{x.resource},#{x.building_type},#{x.producer},#{x.max_efficiency_needed},#{x.additional_producer_needed_with_efficiency}"
    end)
    |> Enum.join("\n")
  end

  def group(buildings) do
    buildings
    |> Enum.reduce(%{}, fn building, acc ->
      Map.update(acc, building.resource, building, fn b ->
        %{b | max_efficiency_needed: b.max_efficiency_needed + building.max_efficiency_needed}
      end)
    end)
    |> Enum.map(fn {_, building} ->
      max_efficiency_needed = building.max_efficiency_needed

      building
      |> Map.replace!(:max_efficiency_needed, trunc(max_efficiency_needed))
      |> Map.put(
        :additional_producer_needed_with_efficiency,
        round((max_efficiency_needed - trunc(max_efficiency_needed)) * 200)
      )
    end)
    |> Enum.group_by(& &1.tier)
  end

  defp buildings_needed(acc, []) do
    acc
  end

  defp buildings_needed(acc, [{resource, demand_per_15} | rest]) do
    {demand, recipe} = calc_demand(resource, demand_per_15)
    child_resources = parse_recipe(recipe, demand_per_15)
    child_demands = buildings_needed(child_resources)
    buildings_needed([demand | child_demands] ++ acc, rest)
  end

  defp parse_recipe(:raw_resource, _demand_per_15) do
    []
  end

  defp parse_recipe(recipe, demand_per_15) do
    recipe
    |> String.split("|")
    |> Enum.map(fn item ->
      [resource, amount] = String.split(item, ",")
      {amount, _} = Float.parse(amount)
      {String.trim(resource), amount * demand_per_15}
    end)
  end

  defp calc_demand(resource, demand_per_15) do
    %{
      default_production_time_in_days: default_production_time_in_days,
      production_amount: production_amount,
      building_type: building_type,
      recipe: recipe,
      producer: producer,
      tier: tier
    } = get_resource(resource)

    max_efficiency_needed =
      demand_per_15 / (production_amount / default_production_time_in_days * 15 * 200 / 100)

    {%{
       resource: resource,
       building_type: building_type,
       max_efficiency_needed: max_efficiency_needed,
       producer: producer,
       tier: tier
     }, recipe}
  end

  defp get_resource(name) do
    case Map.get(resources(), name) do
      nil -> raise "Resource #{name} not in my dataset"
      resource -> resource
    end
  end

  defp resources do
    %{
      "chicken dinner" => %{
        default_production_time_in_days: 180,
        production_amount: 1,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "components",
        recipe: "fried chicken,1|cooked vegetables,1|orange soda,1"
      },
      "cooked vegetables" => %{
        default_production_time_in_days: 90,
        production_amount: 1,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "components",
        recipe: "vegetables,2|potatoes,2|olive oil,1"
      },
      "dinner container" => %{
        default_production_time_in_days: 180,
        production_amount: 1,
        producer: "papermill",
        building_type: "factory",
        harvester_type: "land",
        tier: "components",
        recipe: "thin cardboard,2|plastic cutlery,2|napkins,1"
      },
      "fried chicken" => %{
        default_production_time_in_days: 90,
        production_amount: 1,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "components",
        recipe: "chicken meat,3|flour,1|olive oil,1"
      },
      "apples" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "orchard",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "berries" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "plantation",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "cocoa" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "plantation",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "cotton" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "plantation",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "grapes" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "orchard",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "hops" => %{
        default_production_time_in_days: 35,
        production_amount: 6,
        producer: "crop farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "olives" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "orchard",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "oranges" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "orchard",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "potatoes" => %{
        default_production_time_in_days: 35,
        production_amount: 6,
        producer: "crop farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "raw rubber" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "orchard",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "sugar" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "plantation",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "vegetables" => %{
        default_production_time_in_days: 35,
        production_amount: 6,
        producer: "crop farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "wheat" => %{
        default_production_time_in_days: 35,
        production_amount: 6,
        producer: "crop farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
      },
      "beef" => %{
        default_production_time_in_days: 35,
        production_amount: 3,
        producer: "livestock farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "livestock",
        recipe: "water (siphon),1|wheat,1"
      },
      "chicken meat" => %{
        default_production_time_in_days: 25,
        production_amount: 3,
        producer: "livestock farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "livestock",
        recipe: "water (siphon),1|wheat,1"
      },
      "eggs" => %{
        default_production_time_in_days: 25,
        production_amount: 6,
        producer: "livestock farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "livestock",
        recipe: "water (siphon),0.5|wheat,0.5"
      },
      "leather" => %{
        default_production_time_in_days: 35,
        production_amount: 3,
        producer: "livestock farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "livestock",
        recipe: "water (siphon),1|wheat,1"
      },
      "milk" => %{
        default_production_time_in_days: 35,
        production_amount: 3,
        producer: "livestock farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "livestock",
        recipe: "water (siphon),1|wheat,1"
      },
      "mutton" => %{
        default_production_time_in_days: 30,
        production_amount: 3,
        producer: "livestock farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "livestock",
        recipe: "water (siphon),1|wheat,1"
      },
      "wool" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "livestock farm",
        building_type: "farm",
        harvester_type: "land",
        tier: "livestock",
        recipe: "water (siphon),0.5|wheat,0.5"
      },
      "coal" => %{
        default_production_time_in_days: 15,
        production_amount: 3,
        producer: "coal mine",
        building_type: "gatherer",
        harvester_type: "land",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "copper" => %{
        default_production_time_in_days: 15,
        production_amount: 3,
        producer: "copper mine",
        building_type: "gatherer",
        harvester_type: "land",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "fish" => %{
        default_production_time_in_days: 10,
        production_amount: 3,
        producer: "fisherman pier",
        building_type: "gatherer",
        harvester_type: "offshore",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "gas" => %{
        default_production_time_in_days: 15,
        production_amount: 3,
        producer: "gas pump",
        building_type: "gatherer",
        harvester_type: "land",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "oil" => %{
        default_production_time_in_days: 15,
        production_amount: 3,
        producer: "oil drill",
        building_type: "gatherer",
        harvester_type: "land",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "sand" => %{
        default_production_time_in_days: 10,
        production_amount: 3,
        producer: "sand collector",
        building_type: "gatherer",
        harvester_type: "coastal",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "water (siphon)" => %{
        default_production_time_in_days: 10,
        production_amount: 3,
        producer: "water siphon",
        building_type: "gatherer",
        harvester_type: "coastal",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "water (well)" => %{
        default_production_time_in_days: 15,
        production_amount: 3,
        producer: "water well",
        building_type: "gatherer",
        harvester_type: "land",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "wood" => %{
        default_production_time_in_days: 10,
        production_amount: 3,
        producer: "lumber yard",
        building_type: "gatherer",
        harvester_type: "land",
        tier: "raw resources",
        recipe: :raw_resource
      },
      "apple smoothie" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "drinks factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "apple,0.5|water (siphon),0.5"
      },
      "berry smoothie" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "drinks factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "berries,1|water (siphon)1"
      },
      "bricks" => %{
        default_production_time_in_days: 15,
        production_amount: 2,
        producer: "glassworks & smelter",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "sand,1|water (siphon),0.5"
      },
      "chemicals" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "petrochemical plant",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "gas,1.5"
      },
      "concrete" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "glassworks & smelter",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "sand,1|water (siphon),1"
      },
      "copper tubing" => %{
        default_production_time_in_days: 15,
        production_amount: 2,
        producer: "glassworks & smelter",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "copper,1"
      },
      "copper wire" => %{
        default_production_time_in_days: 15,
        production_amount: 2,
        producer: "glassworks & smelter",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "copper,1"
      },
      "dye" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "textile factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "berries,2|water (siphon),0.5"
      },
      "fibers" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "textile factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "cotton,1"
      },
      "flour" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "wheat,1"
      },
      "glass" => %{
        default_production_time_in_days: 15,
        production_amount: 2,
        producer: "glassworks & smelter",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "sand,1|coal,0.5"
      },
      "grape juice" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "drinks factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "grapes,0.5|water (siphon),0.5"
      },
      "hard cider" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "brewery & distillery",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "apples,0.5|sugar,0.5"
      },
      "heavy pulp" => %{
        default_production_time_in_days: 30,
        production_amount: 2,
        producer: "papermill",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "wood,1|water (siphon),0.5"
      },
      "ink" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "papermill",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "coal,0.5|water (siphon),1"
      },
      "olive oil" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "olives,1"
      },
      "orange juice" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "drinks factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "oranges,0.5|water (siphon),0.5"
      },
      "paper roll" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "paper mill",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "wood,1|water (siphon),0.5"
      },
      "plastic" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "petrochemical plant",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "oil,1|gas,0.5"
      },
      "refined oil" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "petrochemical plant",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "oil,1.5"
      },
      "rubber" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "orchard",
        building_type: "farm",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "raw rubber,1"
      },
      "soda water" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "drinks factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "sugar,0.5|water (siphon),0.5"
      },
      "soup" => %{
        default_production_time_in_days: 15,
        production_amount: 2,
        producer: "preservation factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "vegetables,0.5|water (siphon),0.5"
      },
      "steel" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "glassworks & smelter",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "iron ore,1|coal,0.5"
      },
      "stuffing" => %{
        default_production_time_in_days: 15,
        production_amount: 2,
        producer: "toy factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "cotton,0.5"
      },
      "toy furniture" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "toy factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "wood,0.5"
      },
      "wine" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "brewery & distillery",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "grapes,1"
      },
      "wooden planks" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "carpentry center",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "wood,1.5"
      },
      "wooden train" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "toy factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "wood,1"
      },
      "yeast" => %{
        default_production_time_in_days: 20,
        production_amount: 2,
        producer: "brewery & distillery",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 1",
        recipe: "water (siphon),0.5|sugar,0.5"
      },
      "beef stew" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "beef,1.5|vegetables,0.5|water (siphon),0.5"
      },
      "bottles" => %{
        default_production_time_in_days: 30,
        production_amount: 2,
        producer: "glassworks & smelter",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "glass,3"
      },
      "buttons" => %{
        default_production_time_in_days: 30,
        production_amount: 2,
        producer: "petrochemical plant",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "plastic,1|copper wire,0.5"
      },
      "cardboard" => %{
        default_production_time_in_days: 30,
        production_amount: 2,
        producer: "papermill",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "heavy pulp,1.5"
      },
      "cheese" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "milk, 1.5|water (siphon), 1"
      },
      "chocolate bar" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "cocoa,1|milk,1|sugar,0.5"
      },
      "dough" => %{
        default_production_time_in_days: 30,
        production_amount: 2,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "flour,1|water (siphon),0.5"
      },
      "furniture base (s)" => %{
        default_production_time_in_days: 25,
        production_amount: 2,
        producer: "carpentry center",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "wooden planks, 1"
      },
      "light fabric" => %{
        default_production_time_in_days: 30,
        production_amount: 2,
        producer: "textile factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "fibers,1|dye,0.5"
      },
      "plastic cutlery" => %{
        default_production_time_in_days: 35,
        production_amount: 2,
        producer: "petrochemical plant",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "plastic,1.5"
      },
      "wall panels" => %{
        default_production_time_in_days: 25,
        production_amount: 1,
        producer: "carpentry center",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 2",
        recipe: "wooden planks, 1| copper tubing, 1"
      },
      "berry pie" => %{
        default_production_time_in_days: 40,
        production_amount: 2,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 3",
        recipe: "berries,1|dough,1|sugar,0.5"
      },
      "napkins" => %{
        default_production_time_in_days: 45,
        production_amount: 2,
        producer: "textile factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 3",
        recipe: "light fabric,1.5"
      },
      "orange soda" => %{
        default_production_time_in_days: 40,
        production_amount: 2,
        producer: "drinks factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 3",
        recipe: "soda water,0.5|orange juice,0.5|bottles,0.5"
      },
      "thin cardboard" => %{
        default_production_time_in_days: 45,
        production_amount: 2,
        producer: "papermill",
        building_type: "factory",
        harvester_type: "land",
        tier: "tier 3",
        recipe: "cardboard,1.5"
      },
      "premade dinner" => %{
        default_production_time_in_days: 360,
        production_amount: 1,
        producer: "meal megafactory",
        building_type: "factory",
        harvester_type: "land",
        tier: "prototype",
        recipe: "chicken dinner,2|dinner container,1|berry pie,2"
      },
      "burgers" => %{
        default_production_time_in_days: 40,
        production_amount: 2,
        producer: "food factory",
        building_type: "factory",
        harvester_type: "land",
        tier: "",
        recipe: "flour,1|beef,0.5|vegetables,0.5"
      }
    }
  end
end
