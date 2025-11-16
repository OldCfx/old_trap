Config = {}

Config.Debug = false

Config.CanPickupTraps = true      -- Permettre de ramasser les pièges
Config.PickupOwnTrapsOnly = false -- true = seulement ses propres pièges, false = tous les pièges
Config.ReturnItemOnPickup = true  -- Rendre l'item au ramassage

Config.Traps = {
    ['huile'] = {
        label = 'Flaque d\'huile',
        item = 'bouteille_huile',
        prop = 'm23_2_prop_m32_puddle_01a',
        duration = 300000, -- 5 minutes (en ms)
        effect = {
            type = 'slide',
            intensity = 0.8,
            spinForce = 0.5,
            duration = 5000 -- Durée de l'effet sur le véhicule (5 secondes)
        },
        notification = 'Vous avez placé une flaque d\'huile',
        triggerRadius = 3.0
    },

    ['verre'] = {
        label = 'Débris de verre',
        item = 'morceau_verre',
        prop = 'ng_proc_brkbottle_02b',
        duration = 300000, -- 5 minutes
        effect = {
            type = 'tire_burst',
            randomTires = true, -- Pneus aléatoires
            maxTires = 2        -- Nombre max de pneus crevés
        },
        notification = 'Vous avez placé des débris de verre',
        triggerRadius = 2.5
    }
}

Config.Animation = {
    dict = 'mp_car_bomb',
    anim = 'car_bomb_mechanic',
    duration = 3000,
    flag = 1
}

Config.Locale = {
    placing = 'Placement en cours...',
    too_close = 'Vous êtes trop proche d\'un autre piège',
    in_vehicle = 'Vous ne pouvez pas faire ça dans un véhicule',
    no_item = 'Vous n\'avez pas l\'item nécessaire',
    pickup_trap = '~INPUT_TALK~ pour nettoyer la zone'
}
