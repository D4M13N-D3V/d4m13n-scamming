Config = {} -- Do not alter
Config.Debug = false -- Enable Debugging
Config.Locale = 'en' -- Change the locale

Config.MaxChecksBeforeCooldown = 15 --Maximum Amount Of Checked Allowed Before Cooldown
Config.CheckCooldownResetInterval = 3600000 -- How often the cooldown resets in MS globally for cashing checks.

Config.EnablePlayerFraud = true -- Enable or disable player skimming other players cards.
Config.AtmOpenEvent = "okokBanking:OpenATM" --Client side even for when your ATM is opened, this triggers player vs player skimming.

Config.CheckPrinterItem = "checkprinter" -- Item for the check printer
Config.SignedCheckItem = "signedcheck" -- Item for the signed check
Config.UnsignedCheckItem = "unsignedcheck" -- Item for the unsigned check
Config.PrinterProp = "prop_printer_01" -- Prop for the check printer
Config.CheckMinimum = 100 -- The minimum amount a check can be filled out for.
Config.CheckMaximum = 300 -- The maximum amount a check can be filled out for.
Config.CheckPrintTime = 15 -- How long it takes to print a check in seconds
Config.PlacePrinterTime = 5 -- How long it takes to place a printer in seconds
Config.PickupPrinterTime = 5 -- How long it takes to pickup a printer in seconds
Config.CheckSignatureMinigameCount = 3 -- How many minigame attempts are needed to forge a signature
Config.CheckSignatureQuality = { --Index is amount of succsesful minigame attempts when forging, value is the % chance of success
    [0] = 50,
    [1] = 75,
    [2] = 90,
    [3] = 97
}

Config.SkimmerItem = "skimmer" -- Item for the skimmer to be used on ATMS
Config.SkimmerUsedItem = "skimmerused" -- The item to be given to the player when they remove a skimmer that has cards on it
Config.SkimmingRate = 5000 -- How often the skimmer will collect card data from locals in MS (60000 = 1 minute)
Config.SkimmingChance = 10 -- 10 = 90% chance of skimming a card every 1 minute\
Config.SkimmerInstallTime = 15 -- How long it takes to install a skimmer on an ATM in seconds
Config.SkimmerUninstallTime = 5 -- How long it takes to uninstall a skimmer on an ATM in MS seconds

Config.RewardItem = "markedbills" -- Should the reward be an item?
Config.RewardAccount = "bank" -- Account to deposit the reward into if not an item
Config.RewardAmount = 1000 -- Amount to reward the player for successfully cashing a check

Config.EnableLockdown = true -- Enable or disable the lockdown event. This makes guard spawn and door lock.
Config.DoorResource = "cali-doors" -- Resource name for the door system
Config.DoorName = "cashcheckfrontdoor" -- Name of the door to lock/unlock when cashing checks
Config.SecurityPedModel = "s_m_m_security_01" -- Ped model for the security guard
Config.SecurityPedCoords = vector3(427.79,-1891.14,26.46) -- Coords for the security guard
Config.SecurityPedHeading = 180.0 -- Heading for the security guard
Config.SecurityPedWeapon = "WEAPON_NIGHTSTICK" -- Weapon for the security guard

-- Locations to cash checks
Config.CheckCashingLocation={
    Name = "Cash Check", -- Name of the check cashing location
    Location = vector3(425.79,-1896.14,26.46), -- Coords of the check cashing location
    Blip={
        Enabled = true, -- Enable or disable blips for check cashing locations
        Sprite = 500, -- Sprite to be used for blip of check cashing locations
        Scale = 0.8, -- Scale of blip for check cashing locations
        Colour = 2, -- Colour of blip for check cashing locations
        Label = "Check Cashing" -- Label of blip for check cashing locations
    }
}

--Change your dispatch script here.

function callPolice()
    print("TEST")
    local data = exports['cd_dispatch']:GetPlayerInfo()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = {'police', }, 
        coords = data.coords,
        title = 'Check Fraud',
        message = 'A '..data.sex..' was trying to cash a fraudulent check at '..data.street..", the doors have been locked come fast!", 
        flash = 0,
        unique_id = data.unique_id,
        sound = 1,
        blip = {
            sprite = 431, 
            scale = 1.2, 
            colour = 3,
            flashes = false, 
            text = '911 - Check Fraud',
            time = 5,
            radius = 0,
        }
    })
end

Config.AtmModels = { -- ATM model hashes, do not remove any of these. Add more if needed.
	{model = -870868698}, 
	{model = -1126237515}, 
	{model = -1364697528}, 
	{model = 506770882}
}

-- First names to use on cards skimmed from the skimmer
Config.LocalFirstNames = {
    "John", "Jane", "Michael", "Samantha", "David", "Emily", "Chris",
    "Amanda", "James", "Ashley", "Robert", "Jessica", "Daniel", "Sarah",
    "Matthew", "Megan", "Joseph", "Lauren", "Ryan", "Kayla", "Nicholas",
    "Rachel", "Brandon", "Stephanie", "Jonathan", "Elizabeth", "William",
    "Olivia", "Anthony", "Brittany", "Kyle", "Danielle", "Zachary", "Amber",
    "Erica", "Kevin", "Melissa", "Steven", "Rebecca", "Thomas", "Michelle",
    "Brian", "Tiffany", "Timothy", "Chelsea", "Alexander", "Christina",
    "Cody", "Katherine", "Adam", "Laura", "Benjamin", "Kimberly", "Aaron",
    "Victoria", "Richard", "Sara", "Patrick", "Amy", "Charles", "Erin",
    "Jeremy", "Crystal", "Mark", "Andrea", "Andrew", "Kelly", "Sean",
    "Mary", "Jeffrey", "Angela", "Scott", "Hannah", "Justin", "Shannon",
    "Gregory", "Allison", "Dylan", "Cassandra", "Derek", "Kaitlyn",
    "Nathan", "Lindsey", "Samuel", "Kristen", "Christian", "Eric",
    "Benjamin", "Alexandra", "Jesse", "Lindsay", "Cameron", "Courtney",
    "Jordan", "April", "Taylor", "Katie", "Austin", "Kathryn", "Ross",
    "Jenna", "Jared", "Jamie", "Corey", "Heather", "Dustin", "Alicia",
    "Ethan", "Morgan", "Luke", "Caitlin", "Carlos", "Kristin", "Ian",
    "Jacqueline", "Shane", "Monica", "Peter", "Catherine", "Antonio",
    "Bethany", "Victor", "Brianna", "Philip", "Natalie", "Joel", "Julia",
    "Taylor", "Katelyn", "Douglas"
}

-- Last names to use on cards skimmed from the skimmer
Config.LocalLastNames = {
    "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller",
    "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White",
    "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson",
    "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen",
    "Young", "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott",
    "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter", "Mitchell",
    "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker",
    "Evans", "Edwards", "Collins", "Stewart", "Sanchez", "Morris",
    "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey",
    "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres",
    "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks", "Kelly",
    "Sanders", "Price", "Bennett", "Wood", "Barnes", "Ross", "Henderson",
    "Coleman", "Jenkins", "Perry", "Powell", "Long", "Patterson", "Hughes",
    "Flores", "Washington", "Butler", "Simmons", "Foster", "Gonzales",
    "Bryant", "Alexander", "Russell", "Griffin", "Diaz", "Hayes"

}