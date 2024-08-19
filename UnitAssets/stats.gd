extends Node

@export var stats = {
	"weaponRange":3,
	"meleeRange":1,
	"weaponDamage":3,
	"meleeDamage":1,
	"movementRange":6,
	"speed":600.0,
	"maxHealth":10,
	"currentHealth":10,
	"currentAmmo":6,
	"maxAmmo":6,
	"defense":2,
}

func edit_stat(stat, amount):
	stats[stat] += amount
	stats.currentHealth = clamp(stats.currentHealth, 0, stats.maxHealth)
	stats.currentAmmo = clamp(stats.currentAmmo, 0, stats.maxAmmo)
