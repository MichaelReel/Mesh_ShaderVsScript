extends MeshInstance

export(StreamTexture) var heightmap
export(Vector2)       var gridSize     = Vector2(16,16)
export(float)         var maxHeight    = 0.2

func _ready():

	var surfTool = SurfaceTool.new()
	var mesh = Mesh.new()

	var textureStep = Vector2(1 / gridSize.x, 1 / gridSize.y)
	var cellScale = Vector3(1 / gridSize.x, 1 / gridSize.y, maxHeight)

	print (heightmap.get_height(), "x", heightmap.get_width())
	print (heightmap.load_path)

	var gridStep = Vector2(heightmap.get_width() / (gridSize.x), heightmap.get_height() / (gridSize.y))

	var data = heightmap.get_data()
	
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)

	data.lock()

	for cy in range(int(gridSize.y) - 1):
		for cx in range(int(gridSize.x) - 1):

			var x = cx * int(gridStep.x)
			var y = cy * int(gridStep.y)
			var x2 = (cx + 1) * int(gridStep.x)
			var y2 = (cy + 1) * int(gridStep.y)

			var tl = Vector3(cellScale.x *  cx     , cellScale.z * data.get_pixel(x , y ).r, cellScale.y *  cy     )
			var tr = Vector3(cellScale.x * (cx + 1), cellScale.z * data.get_pixel(x2, y ).r, cellScale.y *  cy     )
			var bl = Vector3(cellScale.x *  cx     , cellScale.z * data.get_pixel(x , y2).r, cellScale.y * (cy + 1))
			var br = Vector3(cellScale.x * (cx + 1), cellScale.z * data.get_pixel(x2, y2).r, cellScale.y * (cy + 1))

			var tlUv = Vector2(textureStep.x *  cx     , textureStep.y *  cy     )
			var trUv = Vector2(textureStep.x * (cx + 1), textureStep.y *  cy     )
			var blUv = Vector2(textureStep.x *  cx     , textureStep.y * (cy + 1))
			var brUv = Vector2(textureStep.x * (cx + 1), textureStep.y * (cy + 1))

			surfTool.add_uv(tlUv)
			surfTool.add_vertex(tl)
			
			surfTool.add_uv(trUv)
			surfTool.add_vertex(tr)
			
			surfTool.add_uv(blUv)
			surfTool.add_vertex(bl)
			
			surfTool.add_uv(blUv)
			surfTool.add_vertex(bl)

			surfTool.add_uv(trUv)
			surfTool.add_vertex(tr)
	
			surfTool.add_uv(brUv)
			surfTool.add_vertex(br)
	
	data.unlock()
	
	surfTool.generate_normals()
	surfTool.index()
	
	surfTool.commit(mesh)
	
	self.set_mesh(mesh)
