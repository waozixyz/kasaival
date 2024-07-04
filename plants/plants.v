module plants

pub fn saguaro() &Plant {
	return &Plant{
		w: 14
		h: 42
		max_row: 7
		cs_branch: [125, 178, 122, 160, 76, 90]
		cs_leaf: [150, 204, 190, 230, 159, 178]
		change_color: [-25, -64, -50, 0]
		grow_time: 20
		split_chance: 40
		points: 30
	}
}

pub fn oak() &Plant {
	return &Plant{
		w: 20
		h: 50
		points: 20
		cs_branch: [40, 70, 170, 202, 60, 100]
		change_color: [-10, -10, -10]
		max_row: 8
		split_chance: 70
		split_angle: [20, 30]
		grow_time: 20
	}
}

pub fn kali() &Plant {
	return &Plant{
		points: 15
		w: 22
		h: 22
		max_row: 5
		grow_time: 20
		cs_branch: [140, 170, 160, 190, 25, 50]
		change_color: [-70, -100, -10]
		split_chance: 100
		split_angle: [40, 60]
		two_start_branches: true
	}
}
