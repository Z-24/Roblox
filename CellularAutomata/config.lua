--[[
    config.lua
    Author: Afrxzo
    Sun, 04/25/2021 (MM/DD/YY)

    This module contains information for global configurations
    that affect gameplay mechanics.
--]]

local config = {
    Cells = {
        ZombieCell = {
            Name = "Zombie",
            Color = Color3.new(0.764705, 0, 1),
            MutatedColor = Color3.new(0.384313, 0.007843, 0.501960),
            Enabled = true,
            DNA = {
                MutationRate = 0.4,
                Strength = 1,
            }
        },
        HumanCell = {
            Name = "Human",
            Color = Color3.new(0, 0.376470, 0.592156),
            MutatedColor = Color3.new(0, 0.247058, 0.392156),
            Enabled = true,
            DNA = {
                MutationRate = 0.2,
                Strength = 0.8
            }
        },
        AlienCell = {
            Name = "Alien",
            Color = Color3.new(0.752941, 0, 0),
            MutatedColor = Color3.new(0.439215, 0, 0),
            Enabled = true,
            DNA = {
                MutationRate = 0.1,
                Strength = 1.1
            }
        },
        RatCell = {
            Name = "Rat",
            Color = Color3.new(0.654901, 0.654901, 0.654901),
            MutatedColor = Color3.new(0.407843, 0.403921, 0.403921),
            Enabled = true,
            DNA = {
                MutationRate = 10,
                Strength = 0.5
            }
        },
        CoronaCell = {
            Name = "Corona",
            Color = Color3.new(1, 0.733333, 0),
            MutatedColor = Color3.new(0.439215, 0.321568, 0),
            Enabled = false,
            DNA = {
                MutationRate = 1000,
                Strength = 9019294
            }
        },
        None = {
            Name = "None",
            Color = Color3.new(1, 1, 1),
            MutatedColor = Color3.new(1, 1, 1),
            DNA = {
                MutationRate = 0,
                Strength = 0
            }
        }
    },
    MapSize = {50, 50}
}

return config