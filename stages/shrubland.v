module stages

pub struct Shrubland {
pub mut:
	music    string
	scenes   []Scene
	spawners []Spawner
}

pub fn (mut self Shrubland) load() {
	self.music = 'spring/maintheme.ogg'

	// add start
	self.scenes << Scene{1500, [21, 0, 13]}

	// add ocean
	self.scenes << Scene{1500, ocean}
	// add beach
	self.scenes << Scene{1000, beach}
	// add shrubland
	self.scenes << Scene{7000, shrubland}
	// add beach
	self.scenes << Scene{1000, beach}
	// add ocean
	self.scenes << Scene{1500, ocean}
	// add end for color gradient
	mut end := Scene{}
	end.color = [21, 0, 13]
	self.scenes << end

	// add shrub spawner
	self.spawners << Spawner{.kali, 3500, 7000, 1, 0}
}
