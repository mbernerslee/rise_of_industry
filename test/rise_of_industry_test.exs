defmodule RiseOfIndustryTest do
  use ExUnit.Case
  doctest RiseOfIndustry

  @doc """
      "sugar" => %{
        default_production_time_in_days: 30,
        production_amount: 6,
        producer: "plantation",
        building_type: "farm",
        harvester_type: "land",
        tier: "farm produce",
        recipe: "water (siphon),0.5"
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
  """

  describe "buildings_needed/1" do
    test "simple case with 1 resource" do
      # Sugar produces 6 in 30 days at normal efficiency,
      # so produces 6 in 15 days at max (double) efficiency
      # so if 6 are demanded every 15 days, 1 farm is enough
      assert [
               %{
                 resource: "sugar",
                 building_type: "farm",
                 max_efficiency_needed: 1.0,
                 producer: "plantation",
                 tier: "farm produce"
               },
               %{
                 resource: "water (siphon)",
                 building_type: "gatherer",
                 max_efficiency_needed: 0.3333333333333333,
                 producer: "water siphon",
                 tier: "raw resources"
               }
             ] == RiseOfIndustry.buildings_needed([{"sugar", 6}])
    end

    test "returns each resource multiple times" do
      assert [
               %{
                 resource: "sugar",
                 building_type: "farm",
                 max_efficiency_needed: 1.0
               },
               %{
                 resource: "water (siphon)",
                 building_type: "gatherer",
                 max_efficiency_needed: 0.3333333333333333
               },
               %{
                 resource: "sugar",
                 building_type: "farm",
                 max_efficiency_needed: 1.0
               },
               %{
                 resource: "water (siphon)",
                 building_type: "gatherer",
                 max_efficiency_needed: 0.3333333333333333
               }
             ] = RiseOfIndustry.buildings_needed([{"sugar", 6}, {"sugar", 6}])
    end
  end

  describe "group/1" do
    test "puts buildings for the same res together" do
      buildings = [
        %{
          resource: "sugar",
          building_type: "farm",
          arbitrary_other_field: "dave1",
          tier: "farm produce",
          max_efficiency_needed: 1.0
        },
        %{
          resource: "water (siphon)",
          building_type: "gatherer",
          arbitrary_other_field: "dave2",
          tier: "raw resources",
          max_efficiency_needed: 0.3333333333333333
        },
        %{
          resource: "sugar",
          building_type: "farm",
          arbitrary_other_field: "dave1",
          tier: "farm produce",
          max_efficiency_needed: 1.0
        },
        %{
          resource: "water (siphon)",
          building_type: "gatherer",
          arbitrary_other_field: "dave2",
          tier: "raw resources",
          max_efficiency_needed: 0.3333333333333333
        }
      ]

      assert %{
               "farm produce" => [
                 %{
                   resource: "sugar",
                   building_type: "farm",
                   max_efficiency_needed: 2,
                   arbitrary_other_field: "dave1",
                   tier: "farm produce",
                   additional_producer_needed_with_efficiency: 0
                 }
               ],
               "raw resources" => [
                 %{
                   resource: "water (siphon)",
                   building_type: "gatherer",
                   max_efficiency_needed: 0,
                   arbitrary_other_field: "dave2",
                   tier: "raw resources",
                   additional_producer_needed_with_efficiency: 133
                 }
               ]
             } ==
               RiseOfIndustry.group(buildings)
    end
  end
end
