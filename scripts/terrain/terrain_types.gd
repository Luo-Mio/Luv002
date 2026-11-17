class_name TerrainTypes
extends RefCounted

# R Channel: Terrain ID (0 is strictly EMPTY / Void)
enum ID {
	EMPTY = 0,     # 空地 / 虚空 / 未生成地块
	SAND = 1,      # 沙地
	DIRT = 2,      # 泥土
	GRASS = 3,     # 草地
	FARMLAND = 4,  # 耕地
	STONE = 5,     # 石砖 / 硬化地面
}

# G Channel: 8-bit Flags Bitmask
const FLAG_SPREAD_ACTIVE: int = 1 << 0  # Bit 0 (0x01): 活跃蔓延边缘种子
const FLAG_WET: int           = 1 << 1  # Bit 1 (0x02): 湿润 / 浇水状态
const FLAG_TILLED: int        = 1 << 2  # Bit 2 (0x04): 松土耕作
const FLAG_BURNT: int         = 1 << 3  # Bit 3 (0x08): 焦土 / 枯黄

# Helper: check if a flag is set
static func has_flag(flags: int, flag: int) -> bool:
	return (flags & flag) != 0

# Helper: set flag
static func set_flag(flags: int, flag: int) -> int:
	return flags | flag

# Helper: clear flag
static func clear_flag(flags: int, flag: int) -> int:
	return flags & ~flag
