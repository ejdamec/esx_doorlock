Config = {}
Config.Locale = 'en'

Config.DoorList = {

	{
        textCoords = vector3(434.71, -981.952, 31.00),
        authorizedJobs = { 'klice_izs' },
        locked = false,
        distance = 2.5,
        vrata = false,
        doors = {
            {
                objName = 'gabz_mrpd_reception_entrancedoor',
                objYaw = 270.083,
                objCoords = vector3(434.744, -980.756, 30.815),
            },

            {
                objName = 'gabz_mrpd_reception_entrancedoor',
                objYaw = 89.964,
                objCoords = vector3(434.744, -983.078, 30.815),
            }
        }
    },

	--- Galaxy ---

	{
		objName = 'apa_prop_apa_cutscene_doorb',
		objCoords  = vector3(-20.284, 238.9599, 109.6837),
		textCoords = vector3(-21.306, 239.086, 109.7537),
		authorizedJobs = { 'klice_galaxy' },
		locked = true,
		distance = 2.5,
		vrata = false
	},

}