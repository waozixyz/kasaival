module stages

import ecs
import irishgreencitrus.raylibv as vraylib

const path = 'resources/scenery/'

const (
	ocean     = [50, 60, 220]
	beach     = [200, 180, 60]
	shrubland = [180, 120, 10]
	caveland  = [60, 0, 40]
)

struct Scenary {
pub mut:
	texture vraylib.Texture2D
	cx      f32
	y       int
}

pub struct Spawner {
pub mut:
	name     ecs.EntityName
	start_x  int
	end_x    int
	interval f32
	timer    f32
}

pub struct Scene {
pub mut:
	width int
	color []int
}

pub interface Stage {
	music string
	load()
}

/*
enum StageName {
	@none
	shrubland
	grassland
}*/
