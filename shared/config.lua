Config = {}

Config.CarModel = 'JOURNEY' -- May not work with all vehicles, I think it pulls this from maybe vehicle.meta ??

Config.Debug = false

Config.ItemNames = {
    lithium = 'lithium',
    acid = 'sacid',
    acetone = 'acetone'
}

Config.MethNames = {
    lowqual = 'meth1',
    midqual = 'meth2',
    highqual = 'meth3'
}

Config.lowQualRecipe = {
    lithium = 3,
    acid = 5,
    acetone = 4
}

Config.midQualRecipe = {
    lithium = 2,
    acid = 5,
    acetone = 14
}

Config.highQualRecipe = {
    lithium = 4,
    acid = 3,
    acetone = 8
}

Config.SmokeColour = 'ent_amb_smoke_foundry_white' -- ent_amb_smoke_foundry_white = White | ent_amb_smoke_foundry = Black | exp_grd_flare = Orange

Config.HowMuchMeth = 20

Config.TickLength = 1000 -- How often 0.01 adds to the progbar | In theory, increasing the tick lenght will make you cook longer.

Config.Particle = { -- https://docs.fivem.net/natives/?_0xE184F4F0DC5910E7
    xRot = 0.0,
    yRot = 0.0,
    zRot = 0.0,
    scale = 2.0,
    posZ = 1.7 -- Change original Z
}

Config.Language = {
    noLithium = 'You do not have lithium!',
    noAcetone = 'You do not have acetone!',
    noAcid = 'You do not have acid!',
    startCook = '[E] to start the cooking process',
    progBarMsg = 'Cooking Meth',
    cookInProg = 'You are already cooking!',
    wrongCar = 'Wrong Car',
    seatOccupied = 'Seat Occupied',
    batchStable = 'The batch is stable!',
    increaseTemp = 'Try increasing the temperature!',
    decreaseTemp = 'Try decreasing the temperature!',
    batchWeird = 'The batch is weird!',
    wrongIngredients = 'You do not have the right ingredients!',
    batchMessed = 'You messed up the batch heavily!',
    notifyTitle = 'Meth',
    increaseTempMsg = 'Increase temperature',
    decreaseTempMsg = 'Decrease temperature',
    addLithium = 'Add lithium',
    addAcetone = 'Add acetone',
    addAcid = 'Add sulfuric acid'
}