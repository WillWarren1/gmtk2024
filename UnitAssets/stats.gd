extends Node

@export var stats = {
	"weaponRange":0,
	"weaponDamage":0,
	"movementRange":0,
	"maxHealth":0,
	"currentHealth":0,
	"size":0,
	"currentAmmo":0,
	"maxAmmo":0
}

func edit_stat(stat, amount):
	stats[stat] += amount
	stats.currentHealth = clamp(stats.currentHealth, 0, stats.maxHealth)
	stats.currentAmmo = clamp(stats.currentAmmo, 0, stats.maxAmmo)
